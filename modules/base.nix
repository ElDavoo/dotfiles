{pkgs, ...}: {
  nix.settings = {
    trusted-users = [
      "root"
      "dave"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.flox.dev"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
    experimental-features = ["nix-command" "flakes"];

    # Deduplica dello store disattivata (girava a ogni build).
    auto-optimise-store = false;

    # GC automatico "a domanda": durante un build, se lo spazio libero nello
    # /nix/store scende sotto min-free, Nix raccoglie garbage fino a max-free.
    min-free = 5 * 1024 * 1024 * 1024; # 5 GiB
    max-free = 10 * 1024 * 1024 * 1024; # 10 GiB
  };

  # nh: rebuild con output leggibile (nh os switch). Il clean mensile serve
  # solo a potare le vecchie generazioni (che restano GC-root); la pulizia dei
  # path non referenziati resta demandata a min-free/max-free.
  programs.nh = {
    enable = true;
    flake = "/home/dave/git/dotfiles";
    clean = {
      enable = true;
      dates = "monthly";
      extraArgs = "--keep 5";
    };
  };
  nix.optimise.automatic = false;

  nixpkgs.config = {
    cudaSupport = false;
    cudaCapabilities = ["8.6"];
    allowUnfree = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    cups
    glib
    nss
    nspr
    dbus
    atk
    gtk3
    mesa
    expat
    libxcb
    libxkbcommon
    pango
    cairo
    alsa-lib
    libgbm
  ];

  zramSwap.enable = true;

  fonts.packages = [
    pkgs.nerd-fonts._0xproto
    pkgs.nerd-fonts.droid-sans-mono
  ];

  systemd.services.nix-daemon.serviceConfig = {
    OOMScoreAdjust = 1000;
  };

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "it_IT.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  console.keyMap = "it2";

  system.stateVersion = "24.11";
}
