# Scritto a mano, non generato da nixos-generate-config: la root è
# identificata per label ("nixos"), così il file resta valido anche se la
# partizione viene ricreata. L'ESP è quella di Windows (sda1), montata su
# /boot/efi perché /boot deve stare sulla root (vedi hardware.nix).
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/06E8-108C";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
