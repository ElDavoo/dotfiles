_: {
  virtualisation.docker.enable = true;
  # Il gruppo docker esiste solo dove è abilitato il demone: sta qui e non in
  # modules/users.nix, che è condiviso da tutti gli host.
  users.users.dave.extraGroups = ["docker"];
  programs.virt-manager.enable = true;

  # I container girano a oom_score_adj 0, cioè *dopo* le app grafiche (200):
  # li si porta a 1000 come la roba da terminale e i build di nix, così gli OOM
  # killer li scelgono per primi. Docker lo permette solo per container
  # (--oom-score-adj), quindi lo si forza dall'esterno sui processi dei loro
  # cgroup; i figli nati dopo lo ereditano dal padre.
  systemd.services.docker-oom-score = {
    description = "Make docker containers the first OOM-killer victims";
    serviceConfig.Type = "oneshot";
    script = ''
      for f in /sys/fs/cgroup/system.slice/docker-*.scope/cgroup.procs \
        /sys/fs/cgroup/system.slice/docker-*.scope/*/cgroup.procs; do
        [ -f "$f" ] || continue
        while read -r pid; do
          echo 1000 > "/proc/$pid/oom_score_adj" 2>/dev/null || true
        done < "$f"
      done
    '';
  };
  systemd.timers.docker-oom-score = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "10s";
      AccuracySec = "1s";
    };
  };

  users.groups.libvirtd.members = ["dave"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
}
