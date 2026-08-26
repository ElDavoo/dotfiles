# waybar NON viene avviata via systemd (programs.waybar.systemd.enable = false,
# default): la lancia il proxy waybar-hypr-proxy.py da hyprland.lua, che
# riscrive i click sui workspace per la config in Lua.
{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  # Moduli che hanno senso solo su mattone: nvidia legge il power_state della
  # dGPU, che lenuovo non ha.
  full = osConfig.networking.hostName == "mattone";

  # Il meteo segue la macchina, non l'utente: mattone sta a Valbonne,
  # lenuovo ad Apricena.
  weatherCoords =
    if full
    then {
      lat = "43.6408";
      lon = "7.0075";
      name = "Valbonne";
    }
    else {
      lat = "41.7833";
      lon = "15.4444";
      name = "Apricena";
    };

  # wttrbar interroga wttr.in, che restituisce "weather data source not
  # available" (HTTP 500) per qualsiasi localita' quando il suo backend e'
  # giu': wttrbar allora stampa "invalid wttr.in response" nella barra.
  # Qui usiamo direttamente Open-Meteo (nessuna API key, coordinate fisse)
  # ed emettiamo il JSON che waybar si aspetta.
  weather = pkgs.writeShellApplication {
    name = "waybar-weather";
    runtimeInputs = [pkgs.curl pkgs.jq];
    text = ''
      url="https://api.open-meteo.com/v1/forecast?latitude=${weatherCoords.lat}&longitude=${weatherCoords.lon}&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto&forecast_days=3"

      if ! body=$(curl -sf --max-time 15 "$url"); then
        jq -nc '{text: "󰅤", tooltip: "meteo non disponibile", class: "offline"}'
        exit 0
      fi

      printf '%s' "$body" | jq -c --arg place "${weatherCoords.name}" '
        # WMO weather code -> (icona, descrizione)
        def wmo:
          if   . == 0 then ["☀️", "sereno"]
          elif . <= 2 then ["🌤️", "poco nuvoloso"]
          elif . == 3 then ["☁️", "coperto"]
          elif . <= 48 then ["🌫️", "nebbia"]
          elif . <= 57 then ["🌦️", "pioviggine"]
          elif . <= 67 then ["🌧️", "pioggia"]
          elif . <= 77 then ["🌨️", "neve"]
          elif . <= 82 then ["🌧️", "rovesci"]
          elif . <= 86 then ["🌨️", "rovesci di neve"]
          else ["⛈️", "temporale"] end;
        (.current.weather_code | wmo) as $w
        | {
            text: "\($w[0]) \(.current.temperature_2m | round)°",
            class: "weather",
            tooltip: ([
              "\($place): \($w[1])",
              "Temperatura: \(.current.temperature_2m)° (percepita \(.current.apparent_temperature)°)",
              "Umidita: \(.current.relative_humidity_2m)%",
              "Vento: \(.current.wind_speed_10m) km/h",
              "Alba \(.daily.sunrise[0][11:16]) · Tramonto \(.daily.sunset[0][11:16])",
              ""
            ] + (. as $d | [
              range(0; $d.daily.time | length)
              | "\($d.daily.time[.]): min \($d.daily.temperature_2m_min[.])° / max \($d.daily.temperature_2m_max[.])°"
            ])) | join("\n")
          }' 2>/dev/null \
        || jq -nc '{text: "󰅤", tooltip: "risposta meteo non valida", class: "offline"}'
    '';
  };

  # mediaplayer.py fa `import gi` + `gi.require_version("Playerctl", "2.0")`:
  # il python3 nudo di home/packages.nix non ha né PyGObject né il typelib di
  # playerctl, quindi il modulo custom/media moriva all'avvio (ModuleNotFound:
  # gi) e la barra restava vuota. Qui il python giusto e GI_TYPELIB_PATH.
  #
  # Lo script sta nello store (non è più un symlink fuori-store): per vedere
  # una modifica serve un rebuild.
  mediaplayer = pkgs.writeShellApplication {
    name = "waybar-mediaplayer";
    runtimeInputs = [
      (pkgs.python3.withPackages (ps: [ps.pygobject3]))
      pkgs.playerctl
    ];
    text = ''
      export GI_TYPELIB_PATH="${pkgs.playerctl}/lib/girepository-1.0''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
      exec python3 ${./config/waybar/mediaplayer.py} "$@"
    '';
  };
in {
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 27;
      spacing = 2;

      modules-left = ["image#launcher" "hyprland/workspaces" "mpd"];
      # custom/adb non è più gated su mattone: adb (programs.adb.enable) e
      # scrcpy ora ci sono su tutti gli host.
      modules-center = ["custom/media" "custom/adb"];
      modules-right =
        lib.optionals full ["custom/nvidia"]
        ++ [
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

      temperature =
        {
          critical-threshold = 90;
          format = "{temperatureC}°C";
          format-icons = ["" "" ""];
          rotate = 357;
        }
        # Senza hwmon-path waybar legge thermal_zone0, che su lenuovo è
        # INT3400: un sensore di policy ACPI, non un termometro, e resta
        # inchiodato a 20 °C. Il sensore vero è coretemp/Core 0, cioè
        # temp2_input (su Bay Trail manca il "Package id 0" = temp1).
        // lib.optionalAttrs (!full) {
          hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
          input-filename = "temp2_input";
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
        exec = "${lib.getExe mediaplayer} 2> /dev/null";
      };

      "custom/weather" = {
        format = "{}";
        tooltip = true;
        interval = 1800;
        exec = "${lib.getExe weather}";
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
