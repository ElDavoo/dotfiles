_: {
  # il modulo fuse di nixpkgs ora fornisce solo il wrapper fusermount3
  programs.fuse = {
    enable = true;
    userAllowOther = true;
  };

  security.wrappers = {
    mount.setuid = true;
    umount.setuid = true;
  };
}
