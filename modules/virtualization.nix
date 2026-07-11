{...}: {
  virtualisation.docker.enable = true;
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["dave"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
}
