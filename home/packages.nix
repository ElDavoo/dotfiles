{pkgs, ...}: {
  home.packages = with pkgs; [
    nix-output-monitor
    #    devenv
    anydesk
    libreoffice
    android-tools
    scrcpy
    vesktop
    qbittorrent
    xfce4-terminal
    ncdu
    telegram-desktop
    gnome-calculator
    jetbrains-toolbox
    fractal
    #    subtitleedit
    wl-gammarelay-rs
    wttrbar
    thunderbird
    mpv
    yt-dlp
    #    signal-desktop
    tremotesf
    grim
    slurp
    hyprpolkitagent
    font-awesome
    devmem2
    vscode
    pavucontrol
    joplin-desktop
    blueman
    nwg-bar
    nwg-look
    nwg-displays
    #    mediainfo-gui
    wl-clipboard
    #    amule-gui
    #    mkvtoolnix
    networkmanagerapplet
    #    rdmsr
    #    wrmsr
    #    turbostat
    feh
    file-roller
    python3
    nodejs
    himalaya
    git-xet
    gh
    (hashcat.override {
      cudaSupport = true;
    })
    #(ollama.override {
    #  acceleration = "cuda";
    #})
    #ollama
  ];
}
