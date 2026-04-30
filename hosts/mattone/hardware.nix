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

  boot.kernelParams = [
    "nvidia_modeset.hdmi_deepcolor=0"
    "nvidia_drm.fbdev=0"
  ];

  boot.extraModprobeConfig = "options nvidia-drm fbdev=0";
  boot.blacklistedKernelModules = [
  ];

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
  virtualisation.docker.daemon.settings.features.cdi = true;
}
