# Servizi utente gestiti da home-manager (prima erano exec-once in hyprland.lua
# o file .conf symlinkati). Ora sono unit systemd --user con lifecycle proprio
# (restart, log via journalctl) legate a graphical-session.target (avviato da
# UWSM insieme a Hyprland).
_: {
  #### Hyprland companion daemons (config generate da Nix) ####

  # Idle: lock dopo 30s, dpms off dopo 30.5s. lock via loginctl (session lock).
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 30000;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 30500;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Lockscreen. $foreground non è definito (come nella config originale):
  # hyprlock ripiega sul default. Sfondo = foto personale in ~/Immagini.
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "/home/dave/Immagini/PXL_20240805_194544484.jpg";
          blur_passes = 2;
          contrast = 1;
          brightness = 0.8;
          vibrancy = 0.3;
          vibrancy_darkness = 0.3;
        }
      ];

      general = {
        no_fade_in = false;
        no_fade_out = true;
        hide_cursor = true;
        grace = 1;
        disable_loading_bar = true;
        ignore_empty_input = true;
        immediate_render = true;
      };

      input-field = [
        {
          monitor = "";
          size = "250, 60";
          outline_thickness = 0;
          dots_size = 0.2;
          dots_spacing = 0.35;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(0, 0, 0, 0.2)";
          font_color = "$foreground";
          placeholder_text = "";
          fade_on_empty = true;
          rounding = -1;
          check_color = "rgb(204, 136, 34)";
          hide_input = false;
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # Data
        {
          monitor = "";
          text = ''cmd[update:1000000] echo "$(date +"%A, %B %d")"'';
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 22;
          font_family = "JetBrains Mono";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        # Ora
        {
          monitor = "";
          text = ''cmd[update:5000] echo "$(date +"%-I:%M")"'';
          color = "rgba(242, 243, 244, 0.75)";
          font_size = 120;
          font_family = "JetBrains Mono Extrabold";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Batteria
        {
          monitor = "";
          text = ''cmd[update:10000] cat /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0A:00/power_supply/BAT0/capacity'';
          color = "$foreground";
          font_size = 24;
          font_family = "JetBrains Mono";
          position = "-90, -10";
          halign = "right";
          valign = "top";
        }
      ];
    };
  };

  # Wallpaper. Sintassi a blocchi hyprpaper >= 0.8; monitor vuoto = tutti.
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
      splash = false;
      wallpaper = {
        monitor = "";
        path = "~/Immagini/PXL_20240805_194544484.jpg";
        fit_mode = "cover";
      };
    };
  };

  #### Tray / applet / daemon (prima exec-once in hyprland.lua) ####

  # dunst: vedi home/dunst.nix

  # Clipboard history (rimpiazza i due `wl-paste --watch cliphist store`).
  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  services.udiskie.enable = true;

  services.blueman-applet.enable = true;

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Bluetooth media controls via MPRIS.
  services.mpris-proxy.enable = true;

  # Secret Service. Solo `secrets` come nella config originale
  # (gnome-keyring-daemon --components=secrets).
  services.gnome-keyring = {
    enable = true;
    components = ["secrets"];
  };
}
