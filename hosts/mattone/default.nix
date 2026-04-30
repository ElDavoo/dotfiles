{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    ./hardware.nix
    ./storage.nix
  ];

  networking.hostName = "mattone";
}
