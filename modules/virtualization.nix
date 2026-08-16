_: {
  virtualisation.docker.enable = true;
  # Il gruppo docker esiste solo dove è abilitato il demone: sta qui e non in
  # modules/users.nix, che è condiviso da tutti gli host.
  users.users.dave.extraGroups = ["docker"];
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["dave"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
}
