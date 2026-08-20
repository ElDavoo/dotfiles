# Lenovo Yoga 2 11 (machine type 20332): Pentium N3520 (Bay Trail), 4 GB di
# RAM, iGPU Gen7, SSD condiviso con Windows. (Il DMI dice product_name=20332,
# product_version="Lenovo Yoga 2 11": non è un IdeaPad Flex 15.)
{pkgs, ...}: {
  # L'ESP è quella di Windows: 100 MB totali, ~68 MB liberi. Non ci sta un
  # kernel, quindi niente systemd-boot (che tiene kernel e initrd sull'ESP).
  # GRUB invece lascia kernel/initrd in /boot sulla root ext4 e nell'ESP mette
  # solo grubx64.efi, pochi MB.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 10;

    # Boota Windows di default. Si seleziona per titolo invece che per indice
    # così non si rompe se un domani si aggiunge una voce prima: le virgolette
    # sono volutamente dentro la stringa, perché install-grub.pl emette
    # `set default=<valore>` senza quoting e GRUB si fermerebbe a "Windows".
    default = ''"Windows Boot Manager"'';

    # os-prober girato nel chroot dell'installazione non trovava niente (e
    # comunque dipende da cosa è montato al momento del rebuild): le altre
    # voci sono dichiarate a mano, per fs-uuid dell'ESP. Deterministico.
    useOSProber = false;
    extraEntries = ''
      menuentry "Windows Boot Manager" --class windows {
        insmod part_gpt
        insmod fat
        insmod chain
        search --no-floppy --fs-uuid --set=root 06E8-108C
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  # Un secondo di menu: abbastanza per scegliere NixOS, senza attese.
  boot.loader.timeout = 1;

  # Bay Trail: i C-state profondi causano freeze casuali su questa piattaforma
  # (bug noto della famiglia N3xxx/J1xxx). max_cstate=1 costa un po' di
  # autonomia ma evita i blocchi.
  boot.kernelParams = ["intel_idle.max_cstate=1"];

  # Firmware per il bluetooth Atheros AR3012 (0cf3:3004).
  hardware.enableRedistributableFirmware = true;

  hardware.graphics.enable = true;
  # Gen7 → driver VAAPI i965, non intel-media-driver (che parte da Gen8).
  hardware.graphics.extraPackages = [pkgs.intel-vaapi-driver];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "i965";

  # 4 GB di RAM: un derivation build alla volta, altrimenti l'OOM killer
  # arriva prima della fine (i 4 core restano usabili dentro il singolo build).
  nix.settings.max-jobs = 1;

  # Swapfile sulla root, in aggiunta a zram (vedi ../../modules/oom.nix).
  #
  # ATTENZIONE: mkswap-swapfile.service crea il file con `dd` sul percorso
  # critico del boot, e salta il lavoro solo se il file esiste gia' ed e'
  # esattamente di questa dimensione in MiB. Al primo boot il disco e' conteso
  # (fstrim di common-pc-ssd + attivazione home-manager) e la scrittura va a
  # ~7 MB/s invece dei 217 MB/s a riposo: 8 GB bloccavano il boot per oltre
  # 20 minuti. Se cambi `size`, ricrea il file a mano prima di riavviare:
  #   dd if=/dev/zero of=/swapfile bs=1M count=<size> && chmod 0600 /swapfile
  #   mkswap /swapfile
  swapDevices = [
    {
      device = "/swapfile";
      # Priorità sotto quella di zram: si usa il disco solo quando la RAM
      # compressa è esaurita.
      priority = -2;
      size = 2048;
    }
  ];
}
