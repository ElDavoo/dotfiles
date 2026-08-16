{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    ./hardware.nix
    ./storage.nix

    # Moduli che restano solo su mattone: o dipendono dal suo hardware
    # (power, gaming) o pesano troppo per le macchine piccole.
    ../../modules/power.nix
    ../../modules/gaming.nix
    ../../modules/printing.nix
    ../../modules/controller.nix
    ../../modules/virtualization.nix
    ../../modules/spicetify.nix
    ../../modules/hermes.nix
    ../../modules/secrets.nix
    ../../modules/gparted-live.nix
  ];

  networking.hostName = "mattone";

  # Solo qui: è la macchina personale che sta sempre in casa. Sugli altri host
  # si passa dal login normale della getty.
  services.getty.autologinUser = "dave";

  environment.systemPackages = [
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
  ];
}
