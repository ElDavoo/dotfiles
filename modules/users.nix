{
  inputs,
  pkgs,
  ...
}: {
  users.users.dave = {
    isNormalUser = true;
    description = "Davide";
    extraGroups = ["plugdrv" "input" "storage" "networkmanager" "adbusers" "wheel" "docker" "kvm" "scanner" "lp"];
    packages = with pkgs; [
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
      wofi
      jetbrains-toolbox
      fractal
      #    subtitleedit
      wl-gammarelay-rs
      wttrbar
      thunderbird
      firefox
      waybar
      mpv
      yt-dlp
      #    signal-desktop
      tremotesf
      grim
      slurp
      dunst
      hyprpaper
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
      cliphist
      #    amule-gui
      #    mkvtoolnix
      networkmanagerapplet
      #    rdmsr
      #    wrmsr
      #    turbostat
      feh
      inputs.hyprwm.packages."${pkgs.stdenv.hostPlatform.system}".hypridle
      file-roller
      android-tools
      python3
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
  };

  services.getty.autologinUser = "dave";
}
