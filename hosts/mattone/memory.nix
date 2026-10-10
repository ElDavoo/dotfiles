# Swap su disco in aggiunta a zram, ma senza thrashing: prima di arrivare a
# una macchina congelata che fa solo swap-in/swap-out si uccide qualcosa.
#
# NB: niente ManagedOOM di systemd-oomd sulle slice utente. Le app lanciate da
# Hyprland (firefox compreso) finiscono nel cgroup del compositore,
# wayland-wm@hyprland.desktop.service, e oomd uccide cgroup interi: sceglierebbe
# tutta la sessione.
_: {
  # Priorità sotto quella di zram (5 di default): si va su disco solo quando
  # la RAM compressa è piena, e lì finiscono le pagine più fredde.
  swapDevices = [
    {
      device = "/swapfile";
      priority = -2;
      size = 8192;
    }
  ];

  # Primo livello, nel kernel: protezione del working set di MGLRU. Se le
  # pagine usate nell'ultimo secondo non possono restare in RAM, invece di
  # continuare a sfrattarle (= thrashing) il kernel chiama subito l'OOM killer.
  # Vedi Documentation/admin-guide/mm/multigen_lru.rst, "Thrashing prevention".
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
  ];

  # Secondo livello, in userspace: earlyoom manda SIGTERM (chiusura pulita)
  # quando sia la RAM sia lo swap scendono sotto soglia, SIGKILL più in basso.
  # Le percentuali sono su 31 GB di RAM e ~23,5 GB di swap (zram + swapfile).
  services.earlyoom = {
    enable = true;

    # ~1,9 GB / ~0,9 GB disponibili.
    freeMemThreshold = 6;
    freeMemKillThreshold = 3;

    # ~4,7 GB / ~2,3 GB di swap liberi: zram è già piena e lo swapfile è a
    # metà, oltre si entra nella zona in cui la macchina rallenta davvero.
    freeSwapThreshold = 20;
    freeSwapKillThreshold = 10;

    # Niente --prefer: l'ordine "prima la roba da terminale, poi le app
    # grafiche" lo dà già oom_score_adj (vedi home/bash.nix e
    # modules/virtualization.nix), che vale anche per l'OOM killer del kernel.
    extraArgs = [
      "--avoid"
      "^(systemd|systemd-.*|Hyprland|Xwayland|sshd|dbus-daemon|waybar|dunst)$"
    ];

    enableNotifications = true;
  };
}
