# waybar NON viene avviata via systemd (programs.waybar.systemd.enable = false,
# default): la lancia il proxy waybar-hypr-proxy.py da hyprland.lua, che
# riscrive i click sui workspace per la config in Lua.
_: {
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 27;
      spacing = 2;

      modules-left = ["image#launcher" "hyprland/workspaces" "mpd"];
      modules-center = ["custom/media" "custom/adb"];
      modules-right = [
        "custom/nvidia"
        "custom/weather"
        "custom/wl-gammarelay-temperature"
        "custom/wl-gammarelay-brightness"
        "tray"
        "pulseaudio"
        "cpu"
        "memory"
        "temperature"
        "backlight"
        "keyboard-state"
        "battery"
        "clock"
        "image#exit"
      ];

      margin-top = 0;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;

      keyboard-state = {
        numlock = true;
        capslock = true;
        format = "{name} {icon}";
        format-icons = {
          locked = "";
          unlocked = "";
        };
        rotate = 357;
      };

      "hyprland/workspaces" = {
        all-outputs = true;
        # 5 workspace di default su ogni monitor, ma solo 3 su HDMI-A-1.
        persistent-workspaces = {
          "*" = 5;
          "HDMI-A-1" = 3;
        };
      };

      "hyprland/window" = {
        max-length = 200;
        separate-outputs = true;
        rotate = 1;
      };

      tray = {
        spacing = 8;
        rotate = 359;
      };

      clock = {
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%A %d %T}";
        interval = 1;
        rotate = 359;
      };

      cpu = {
        format = "{usage}% ";
        on-click = "xfce4-terminal -e htop";
        rotate = 357;
      };

      memory = {
        format = "{}% ";
        on-click = "xfce4-terminal -e htop";
        rotate = 357;
      };

      temperature = {
        critical-threshold = 90;
        format = "{temperatureC}°C";
        format-icons = ["" "" ""];
        rotate = 357;
      };

      backlight = {
        format = "{percent}{icon}";
        format-icons = ["󰳲"];
        scroll-step = 1;
        rotate = 357;
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% 󱈑";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        format-full = "";
        format-icons = ["󰳲" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        rotate = 357;
      };

      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };

      pulseaudio = {
        scroll-step = 1;
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = "󰝟 {icon} {format_source}";
        format-muted = "󰝟 {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = ["" "" ""];
        };
        on-click = "pavucontrol";
        rotate = 358;
        max-volume = 125;
      };

      "custom/media" = {
        format = "{icon} {}";
        return-type = "json";
        max-length = 60;
        format-icons = {
          spotify = "";
          default = "🎜";
        };
        escape = true;
        on-click = "playerctl play-pause";
        exec = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null";
      };

      "custom/weather" = {
        format = "{} °";
        tooltip = true;
        interval = 1800;
        exec = "wttrbar --location Valbonne";
        return-type = "json";
      };

      "custom/wl-gammarelay-temperature" = {
        format = "{} ";
        exec = "wl-gammarelay-rs watch {t}";
        on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +300";
        on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -300";
        rotate = 359;
      };

      "custom/wl-gammarelay-brightness" = {
        format = "{} ";
        exec = "wl-gammarelay-rs watch {bp}";
        on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.05";
        on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.05";
        rotate = 358;
      };

      "custom/nvidia" = {
        format = "{}";
        exec = "cat /sys/devices/pci0000:00/0000:00:01.0/power_state";
        interval = 10;
        rotate = 4;
        size = 10;
      };

      "custom/adb" = {
        format = "{}%📱";
        exec = "adb shell dumpsys battery | grep level | cut -c10-";
        on-click = "scrcpy --no-audio";
        interval = 60;
        rotate = 6;
      };

      "image#exit" = {
        path = "${./config/waybar/icons/system-shutdown.svg}";
        size = 24;
        # "interval": "once" è obbligatorio: in waybar 0.15 l'intervallo di
        # default del modulo image è 1ms (bug upstream) -> 100% CPU.
        interval = "once";
        on-click = "nwg-bar";
      };

      "image#launcher" = {
        path = "${./config/waybar/icons/tux.svg}";
        size = 24;
        interval = "once";
        on-click = "pkill wofi || wofi -I --show drun";
      };
    };

    style = builtins.readFile ./config/waybar/style.css;
  };
}
