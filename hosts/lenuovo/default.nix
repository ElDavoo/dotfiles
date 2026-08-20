{inputs, ...}: {
  imports = [
    # nixos-hardware non ha (ancora) un profilo per lo Yoga 2 11: le famiglie
    # coperte sotto lenovo/ sono thinkpad, legion, ideacentre, ideapad e yoga
    # 6/7, tutte macchine molto più recenti. Restano quindi solo i profili
    # generici qui sotto; le quirk di questa macchina (freeze da C-state,
    # VAAPI i965, ESP di Windows) stanno a mano in ./hardware.nix.
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    ./hardware-configuration.nix
    ./hardware.nix

    # 4 GB di RAM: zram al 100%, sysctl tarati per lo swap compresso e
    # earlyoom come rete di sicurezza prima dell'OOM killer del kernel.
    ../../modules/oom.nix
  ];

  networking.hostName = "lenuovo";

  # Steam senza il resto di modules/gaming.nix: qui serve solo il client (chat,
  # libreria, giochi vecchi), mentre Proton-GE, gamescope, gamemode e mangohud
  # sono centinaia di MB di closure per una Gen7 che non ci gioca comunque.
  programs.steam.enable = true;
}
