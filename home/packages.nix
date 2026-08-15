{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  # lenuovo ha 4 GB di RAM e una iGPU Bay Trail: la roba pesante (Electron,
  # IDE, CUDA) resta su mattone. Per promuovere un pacchetto basta spostarlo
  # nella lista di sopra.
  full = osConfig.networking.hostName == "mattone";
in {
  home.packages = with pkgs;
    [
      nix-output-monitor
      xfce4-terminal
      ncdu
      wl-clipboard
      wl-gammarelay-rs
      wttrbar
      grim
      slurp
      hyprpolkitagent
      font-awesome
      pavucontrol
      blueman
      nwg-bar
      nwg-look
      nwg-displays
      networkmanagerapplet
      feh
      file-roller
      mpv
      yt-dlp
      python3
      gh
    ]
    ++ lib.optionals full [
      #    devenv
      anydesk
      libreoffice
      android-tools
      scrcpy
      vesktop
      qbittorrent
      telegram-desktop
      gnome-calculator
      jetbrains-toolbox
      fractal
      #    subtitleedit
      thunderbird
      #    signal-desktop
      tremotesf
      vscode
      joplin-desktop
      #    mediainfo-gui
      #    amule-gui
      #    mkvtoolnix
      #    rdmsr
      #    wrmsr
      #    turbostat
      nodejs
      himalaya
      git-xet
      (hashcat.override {
        cudaSupport = true;
      })
      #(ollama.override {
      #  acceleration = "cuda";
      #})
      #ollama
    ];
}
