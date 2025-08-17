# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.spicetify-nix.nixosModules.default
#      inputs.nixos-hardware.nixosModules.common-pc-ssd
#      inputs.nixos-hardware.nixosModules.common-pc-laptop
#      inputs.nixos-hardware.nixosModules.cpu-intel-comet-lake
#      inputs.nixos-hardware.nixosModules.gpu-nvidia-ampere
#       import "${inputs.nixos-hardware}/common/gpu/nvidia/ampere"
#      <nixos-hardware/common/cpu/intel/comet-lake/default.nix>
#      <nixos-hardware/common/gpu/nvidia/ampere>
    ];

  nix.settings.substituters = [
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    # Compare to the key published at https://nix-community.org/cache
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    cups
    glib
    nss
    nspr
    dbus
    atk
    gtk3
    mesa
    # libexpat.so.1
    expat
    # libxcb.so.1
    xorg.libxcb
    # libxkbcommon.so.0
    libxkbcommon
    # libpango-1.0.so.0
    pango
    # libcairo.so.2
    cairo
    # libasound.so.2
    alsa-lib
    # Add any missing dynamic libraries for unpackaged programs
    libgbm
    # here, NOT in environment.systemPackages

  ];

  # CUDA
    nixpkgs.config.cudaSupport = true;
    nixpkgs.config.allowUnfreePredicate =
    p:
    builtins.all (
      license:
      license.free
      || builtins.elem license.shortName [
        "CUDA EULA"
        "cuDNN EULA"
        "cuTENSOR EULA"
        "NVidia OptiX EULA"
      ]
    ) (if builtins.isList p.meta.license then p.meta.license else [ p.meta.license ]);


  zramSwap.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "dave" ]; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  fonts.packages = [
   pkgs.nerd-fonts._0xproto
   pkgs.nerd-fonts.droid-sans-mono
  ];

  programs.fuse.userAllowOther = true;

  #fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  security.wrappers = {

  fusermount.setuid = true;
  mount.setuid = true;
  umount.setuid = true;
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
#  services.printing.logLevel = "debug";

  # Bootloader.
  boot.loader = {
	systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        systemd-boot.configurationLimit = 4;
	timeout = 1; # not set as NixOS defaults to 5 seconds
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than +5";
  };
  nix.settings.auto-optimise-store = true;
  boot.kernelParams= [ 
   "nvidia_modeset.hdmi_deepcolor=0"
#   "boot.debug1devices"
  ];
  networking.hostName = "mattone"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };
  # Necessary for wireguard
  networking.firewall.checkReversePath = "loose"; 


  systemd.services.nix-daemon.serviceConfig = {
    # kill Nix builds instead of important services when OOM
    OOMScoreAdjust = 1000;
  };

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "winkeys";
  };

  # Configure console keymap
  console.keyMap = "it2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dave = {
    isNormalUser = true;
    description = "Davide";
    extraGroups = [ "plugdrv" "input" "storage" "networkmanager" "adbusers" "wheel" "docker" "kvm" "scanner" "lp"];
    packages = with pkgs; [
#    devenv
    anydesk
    libreoffice
    android-tools
    scrcpy
    vesktop
    qbittorrent
    xfce.xfce4-terminal
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
    inputs.hyprwm.packages."${pkgs.system}".hypridle
  ];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "dave";

  programs.adb.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    htop  
    hyprlock
    git
    gcc
    killall
    rclone
    libsecret
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  
  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    #xwayland.enable = true; # Xwayland can be disabled.
  };
  programs.steam.enable = true;
  services.pipewire.enable = true;
  system.autoUpgrade.enable = true;
  
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    #VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    #GTK_THEME = "Adwaita-dark";
   };
  
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  boot.supportedFilesystems = [ "ntfs" ] ;
  fileSystems."/mnt/win" = {
    device = "/dev/disk/by-uuid/A2E2BDE8E2BDC0B9";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000"];
  };
  
  fileSystems."/mnt/tmp" = {
    device = "/dev/disk/by-uuid/56EC4345EC431E9D";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000"];
  };
  
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = false;
  virtualisation.docker.daemon.settings.features.cdi = false;

  programs.nm-applet.enable = true;
#  programs.kdeconnect.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
  thunar-archive-plugin
  thunar-volman
  thunar-media-tags-plugin
  ];

  programs.file-roller.enable = true;

  services.devmon.enable = true;
  services.udisks2.enable = true;
  
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      #... # your Open GL, Vulkan and VAAPI drivers
      intel-compute-runtime
      intel-media-driver
      vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
      # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
      # intel-media-sdk   # for older GPUs
    ];
  };

#services.dnscrypt-proxy2 = {
#enable = true;
#settings = {
#require_dnssec = true;
#ipv4_servers = true;
#require_nolog = true;

#  sources.relays = {
#    urls = [
#      "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
#      "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
#    ];
#    cache_file = "/var/lib/dnscrypt-proxy2/relays.md";
#    minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
#  };

 
#  anonymized_dns = {
#    routes = [
#      { server_name = "X"; via = [ "X" "X" ]; }
#    ];
#  };
#};

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fileSystems."/home/dave/rclone/hope" = {
  device = "hope-sftp:";
  fsType = "rclone";
  options = [
    "nodev"
    "nofail"
    "allow_other"
    "args2env"
    "config=/home/dave/.config/rclone/rclone.conf,rw,_netdev,allow_other,args2env,vfs-cache-mode=full,cache-dir=/home/dave/rclone-cache/,dir-cache-time=1h,vfs-read-chunk-size=1M,vfs-cache-max-age=10h,buffer-size=64M,attr-timeout=5s,stats=360m,bwlimit=off,vfs-cache-min-free-space=10G"
  ];
  };
  
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
	General = {
                Enable = "Source,Sink,Media,Socket";
		Experimental = true;
	};
  };

  services.pulseaudio.extraConfig = "
    load-module module-switch-on-connect
  ";

  services.blueman.enable = true;
#  hardware.pulseaudio = {
#    enable = true;
#    package = pkgs.pulseaudioFull;
#  };
  services.gnome.gnome-keyring.enable = true;
programs.seahorse.enable = true;
security.pam.services = {
  greetd.enableGnomeKeyring = true;
  greetd-password.enableGnomeKeyring = true;
  login.enableGnomeKeyring = true;
  };

services.dbus.packages = [ pkgs.gnome-keyring pkgs.gcr ];
  hardware.sane.enable=true;
  services.ipp-usb.enable=true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.udev.packages = [ pkgs.sane-airscan     pkgs.android-udev-rules];
  

programs.spicetify =
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  enable = true;

  enabledExtensions = with spicePkgs.extensions; [
    adblock
    volumePercentage
    oneko
    hidePodcasts
#    shuffle # shuffle+ (special characters are sanitized out of extension names)
  ];
  enabledCustomApps = with spicePkgs.apps; [
#    newReleases
#    ncsVisualizer
  ];
  enabledSnippets = with spicePkgs.snippets; [
#    rotatingCoverart
#    pointer
  ];

};

}
