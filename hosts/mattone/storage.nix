{...}: {
  boot.supportedFilesystems = ["ntfs"];

  fileSystems."/mnt/win" = {
    device = "/dev/disk/by-uuid/A2E2BDE8E2BDC0B9";
    fsType = "ntfs-3g";
    options = ["rw" "uid=1000"];
  };

  fileSystems."/mnt/tmp" = {
    device = "/dev/disk/by-uuid/56EC4345EC431E9D";
    fsType = "ntfs-3g";
    options = ["rw" "uid=1000"];
  };

  fileSystems."/home/dave/rclone/hope" = {
    device = "hope-sftp:";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=/run/secrets/rclone.conf,rw,_netdev,allow_other,args2env,vfs-cache-mode=full,cache-dir=/home/dave/rclone-cache/,dir-cache-time=1h,vfs-read-chunk-size=1M,vfs-cache-max-age=10h,buffer-size=64M,attr-timeout=5s,stats=360m,bwlimit=off,vfs-cache-min-free-space=10G"
    ];
  };
}
