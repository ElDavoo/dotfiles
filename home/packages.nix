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
      telegram-desktop
      joplin-desktop
      anydesk
      android-tools
      scrcpy
      vesktop
      gnome-calculator
      thunderbird
      vscode

      # Serve al click play/pause di custom/media e al typelib Playerctl di
      # mediaplayer.py: era riferito dalla config ma non installato, quindi il
      # modulo moriva in silenzio.
      playerctl
    ]
    ++ lib.optionals full [
      #    devenv
      libreoffice
      qbittorrent
      fractal
      #    subtitleedit
      #    signal-desktop
      tremotesf
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
