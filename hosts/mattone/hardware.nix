{
  config,
  pkgs,
  ...
}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 4;
    timeout = 1;
  };

  # Serve >= 7.2 per uniwill-laptop (vedi modules/power.nix): il driver è in
  # mainline dal 7.2 ma nixpkgs non lo compila, e il repo fuori albero da cui
  # lo prendiamo richiede comunque quella versione minima.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "nvidia_modeset.hdmi_deepcolor=0"
    "nvidia_drm.fbdev=0"
  ];

  boot.extraModprobeConfig = "options nvidia-drm fbdev=0";
  boot.blacklistedKernelModules = [
  ];

  # ntsync: primitive di sincronizzazione NT nel kernel, usate da Wine/Proton
  # (CONFIG_NTSYNC=m nel kernel). Caricandolo si ottiene /dev/ntsync.
  boot.kernelModules = ["ntsync"];

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = true;
    powerManagement = {
      enable = true;
      finegrained = true;
      kernelSuspendNotifier = true;
    };
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    reverseSync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  hardware.nvidia-container-toolkit.enable = true;
  # con la dGPU disabilitata dal BIOS il modulo nvidia si carica ma non trova
  # schede, il generatore CDI fallisce ("Driver Not Loaded") e lo switch esce
  # con errore. Lo saltiamo se sul bus PCI non c'è una scheda video NVIDIA
  # (vendor 0x10de, classe 0x03): /dev/nvidia0 non andrebbe bene perché le
  # Condition* vengono valutate prima che udev abbia creato i nodi.
  systemd.services.nvidia-container-toolkit-cdi-generator.serviceConfig.ExecCondition = pkgs.writeShellScript "has-nvidia-gpu" ''
    for d in /sys/bus/pci/devices/*; do
      if [ "$(cat "$d/vendor")" = 0x10de ] && [[ "$(cat "$d/class")" == 0x03* ]]; then
        exit 0
      fi
    done
    exit 1
  '';
  virtualisation.docker.daemon.settings.features.cdi = true;

  # nix.settings.system-features = [ "gccarch-native" ];
  # nixpkgs.buildPlatform = {
  #   gcc.arch = "native";
  #   system = "x86_64-linux";
  #  };
}
