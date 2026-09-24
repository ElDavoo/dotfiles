{
  config,
  pkgs,
  ...
}: let
  uniwill-laptop = config.boot.kernelPackages.callPackage ../pkgs/uniwill-laptop.nix {};

  # setta il refresh del pannello interno: refresh-rate [165|40|auto]
  # (il BOE supporta solo questi due mode; "auto" sceglie in base
  # all'alimentazione). Funziona sia da utente che da root (udev).
  refresh-rate = pkgs.writeShellApplication {
    name = "refresh-rate";
    runtimeInputs = [
      config.programs.hyprland.package
      pkgs.util-linux
      pkgs.coreutils
    ];
    text = ''
      rate="''${1:-auto}"
      if [ "$rate" = auto ]; then
        if [ "$(cat /sys/class/power_supply/AC0/online)" = 1 ]; then
          rate=165
        else
          rate=40
        fi
      fi
      for sock in /run/user/*/hypr/*/.socket.sock; do
        [ -e "$sock" ] || continue
        rundir="''${sock%/hypr/*}"
        sig="''${sock#*/hypr/}"
        sig="''${sig%%/*}"
        # config Lua: "hyprctl keyword" non è supportato, serve eval
        cmd=(env "XDG_RUNTIME_DIR=$rundir" "HYPRLAND_INSTANCE_SIGNATURE=$sig" \
          hyprctl eval "hl.monitor({output = \"desc:BOE 0x0974\", mode = \"2560x1440@$rate.0\", position = \"1920x0\", scale = 1.6})")
        if [ "$(id -u)" = 0 ]; then
          runuser -u "$(stat -c %U "$rundir")" -- "''${cmd[@]}"
        else
          "''${cmd[@]}"
        fi
      done
    '';
  };

  # legge/imposta i power limit della CPU, in watt:
  #   powerlimit                 → mostra PL1/PL2/PL4 attuali
  #   powerlimit PL1 [PL2 [PL4]] → imposta; "-" lascia invariato
  #                                (es. "powerlimit - 90" cambia solo PL2)
  # PL1/PL2 passano da powercap (intel-rapl:0), PL4 non è esposto dal kernel
  # sul Comet Lake quindi va scritto a mano nell'MSR 0x601 (bit 12:0, stesse
  # unità di potenza dell'MSR 0x606). Non persistono al riavvio.
  powerlimit = pkgs.writeShellApplication {
    name = "powerlimit";
    runtimeInputs = [pkgs.msr-tools pkgs.coreutils pkgs.gawk pkgs.kmod];
    text = ''
      if [ "$(id -u)" != 0 ]; then
        exec /run/wrappers/bin/sudo "$0" "$@"
      fi

      rapl=/sys/class/powercap/intel-rapl:0
      modprobe msr

      # trova il constraint per nome invece di assumere l'indice
      constraint() {
        for c in "$rapl"/constraint_*_name; do
          if [ "$(cat "$c")" = "$1" ]; then
            echo "''${c%_name}"
            return
          fi
        done
        echo "constraint $1 non trovato in $rapl" >&2
        exit 1
      }
      pl1=$(constraint long_term)
      pl2=$(constraint short_term)

      # unità di potenza: 1/2^n W, n nei bit 3:0 dell'MSR 0x606
      unit=$((1 << ($(rdmsr -p0 -d -f 3:0 0x606))))

      show() {
        printf 'PL1  %4d W  (finestra %s s)\n' \
          "$(($(cat "$pl1"_power_limit_uw) / 1000000))" \
          "$(awk "BEGIN{print $(cat "$pl1"_time_window_us) / 1000000}")"
        printf 'PL2  %4d W\n' "$(($(cat "$pl2"_power_limit_uw) / 1000000))"
        printf 'PL4  %4d W\n' "$(($(rdmsr -p0 -d -f 12:0 0x601) / unit))"
        if [ "$(cat "$rapl"/enabled)" != 1 ]; then
          echo "attenzione: RAPL package disabilitato, PL1/PL2 non applicati" >&2
        fi
        if [ "$(rdmsr -p0 -f 63:63 0x610)" = 1 ]; then
          echo "attenzione: MSR 0x610 bloccato dal BIOS, PL1/PL2 in sola lettura" >&2
        fi
      }

      if [ $# = 0 ]; then
        show
        exit
      fi

      if [ $# -gt 3 ]; then
        echo "uso: powerlimit [PL1|- [PL2|- [PL4|-]]]   (watt)" >&2
        exit 1
      fi
      for w in "$@"; do
        if [ "$w" != - ] && ! [[ "$w" =~ ^[1-9][0-9]*$ ]]; then
          echo "valore non valido: $w (watt interi o -)" >&2
          exit 1
        fi
      done

      set_pl4() {
        local cur new
        if [ "$(rdmsr -p0 -f 31:31 0x601)" = 1 ]; then
          echo "MSR 0x601 bloccato dal BIOS, PL4 non modificabile" >&2
          exit 1
        fi
        if [ $(($1 * unit)) -gt 8191 ]; then
          echo "PL4 massimo: $((8191 / unit)) W" >&2
          exit 1
        fi
        cur=$(rdmsr -p0 -c 0x601)
        new=$(((cur & ~0x1FFF) | ($1 * unit)))
        wrmsr -a 0x601 "$(printf '0x%x' "$new")"
      }

      [ "''${1:--}" = - ] || echo $(($1 * 1000000)) > "$pl1"_power_limit_uw
      [ "''${2:--}" = - ] || echo $(($2 * 1000000)) > "$pl2"_power_limit_uw
      [ "''${3:--}" = - ] || set_pl4 "$3"

      show
    '';
  };
in {
  environment.systemPackages = [refresh-rate powerlimit];

  # senza, ogni wrmsr su un MSR fuori dalla allowlist del kernel (0x601 lo è)
  # sporca dmesg e marca il kernel come tainted
  boot.kernelParams = ["msr.allow_writes=on"];

  # al cambio di alimentazione adegua il refresh (165 su AC, 40 a batteria)
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${refresh-rate}/bin/refresh-rate auto"
  '';

  # risparmio energetico aggressivo a batteria (TLP è già abilitato da
  # nixos-hardware common-pc-laptop, qui solo le impostazioni)
  services.tlp.settings = {
    # EPP al minimo consumo invece del default balance_power
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    # niente turbo boost a batteria: sul i7-10875H è il singolo
    # risparmio più grande, al costo di picchi di CPU più lenti
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    # runtime PM per tutti i dispositivi PCIe e powersave wifi
    RUNTIME_PM_ON_BAT = "auto";
    WIFI_PWR_ON_BAT = "on";

    # NON sospendere via USB il controller Bluetooth: l'autosuspend del
    # combo Intel (8087:0026) dopo ~2s di idle causa il "firmware bug"
    # (missing completion reports) → il transport A2DP cade e le cuffie
    # si spengono da sole. Escluso da TLP, power/control resta "on".
    USB_EXCLUDE_BTUSB = 1;

    # ASPM aggressivo sui link PCIe a batteria
    PCIE_ASPM_ON_BAT = "powersupersave";

    # powersave audio dopo 1 secondo di inattività
    SOUND_POWER_SAVE_ON_BAT = 1;

    # limita la iGPU a batteria (range hardware: 350-1200 MHz)
    INTEL_GPU_MAX_FREQ_ON_BAT = 800;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 800;
  };

  # --- profilo di ricarica della batteria -----------------------------------
  #
  # La scheda non è nella tabella DMI del driver (quella elenca solo modelli
  # TUXEDO/Schenker/Intel NUC), quindi serve force=1. force abilita tutte le
  # feature TRANNE la soglia numerica charge_control_end_threshold, che viene
  # mascherata apposta per non danneggiare la batteria su schede non validate.
  # Non è una perdita: il registro della soglia (EC 0x07B9) su questo firmware
  # non è nemmeno mappato in ACPI, la field list di ECMG salta esattamente
  # quel byte. Resta l'interfaccia a profili, che è quella giusta per i GM7.
  boot.extraModulePackages = [uniwill-laptop];
  boot.extraModprobeConfig = "options uniwill-laptop force=1";

  # Niente autoload: gli alias DMI del modulo non coprono questa scheda.
  boot.kernelModules = ["uniwill-laptop"];

  # ATTENZIONE ai nomi, sono controintuitivi. La mappatura driver → EC è:
  #   Standard    → HIGH_CAPACITY (100%)
  #   Long Life   → BALANCED      (~90%)
  #   Trickle     → STATIONARY    (~80%, e carica anche più lenta)
  # Quindi il profilo "stationary" da scrivere è "Trickle", NON "Long Life".
  systemd.services.battery-charge-profile = {
    description = "Battery charging profile (Uniwill EC) → stationary";
    wantedBy = ["multi-user.target"];
    after = ["systemd-modules-load.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      attr=/sys/class/power_supply/BAT0/charge_types

      # il battery hook del driver si registra poco dopo il probe
      for _ in $(seq 20); do
        [ -e "$attr" ] && break
        sleep 0.25
      done

      if [ ! -e "$attr" ]; then
        echo "$attr assente: il driver non ha esposto i profili di ricarica" >&2
        exit 1
      fi

      echo Trickle > "$attr"

      # l'EC può accettare la scrittura e ignorarla: rileggiamo per sapere
      # se il profilo è davvero attivo (l'attivo è quello fra parentesi)
      if ! grep -q '\[Trickle\]' "$attr"; then
        echo "profilo non applicato, l'EC riporta: $(cat "$attr")" >&2
        exit 1
      fi
    '';
  };
}
