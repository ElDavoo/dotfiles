_: {
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

  # Mount rclone (hope) nixificato ma DISABILITATO.
  # Convertito da `fileSystems` a `systemd.mounts` con `wantedBy = []`: l'unità
  # esiste in modo dichiarativo ma non viene montata automaticamente al boot e
  # non entra in remote-fs.target. Questo evita che switch-to-configuration
  # mascheri in massa le unità mount durante l'attivazione (bug che faceva
  # fallire `nixos-rebuild switch`).
  # Per montarlo a mano:  systemctl start home-dave-rclone-hope.mount
  # NB: il remote dichiarato è `hope-sftp:`, ma risultava montato come
  # `hope-webdav:` — verifica quale remote vuoi prima di riabilitarlo.
  systemd.mounts = [
    {
      what = "hope-sftp:";
      where = "/home/dave/rclone/hope";
      type = "rclone";
      options = "nodev,nofail,allow_other,args2env,config=/run/secrets/rclone.conf,rw,_netdev,vfs-cache-mode=full,cache-dir=/home/dave/rclone-cache/,dir-cache-time=1h,vfs-read-chunk-size=1M,vfs-cache-max-age=10h,buffer-size=64M,attr-timeout=5s,stats=360m,bwlimit=off,vfs-cache-min-free-space=10G";
      wantedBy = []; # disabilitato: nessun target lo avvia
    }
  ];
}
