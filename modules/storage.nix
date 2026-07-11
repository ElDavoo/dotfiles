_: {
  programs.fuse.userAllowOther = true;

  security.wrappers = {
    fusermount.setuid = true;
    mount.setuid = true;
    umount.setuid = true;
  };
}
