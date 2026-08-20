# Contromisure OOM per le macchine con poca RAM (lenuovo: 4 GB reali, ~3,8 GB
# utilizzabili). L'idea è tre livelli: comprimere in RAM invece di andare su
# disco (zram), rendere il kernel disposto a usarla (sysctl), e avere un
# killer che intervenga *prima* che l'OOM killer del kernel congeli tutto.
_: {
  # zram al 100% della RAM invece del 50% di default: con zstd il rapporto di
  # compressione tipico è ~3:1, quindi 3,8 GB di swap compresso costano circa
  # 1,3 GB di RAM vera. Su un SSD condiviso con Windows conviene comunque
  # comprimere piuttosto che scrivere.
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    # Priorità alta: si riempie zram e solo dopo lo swapfile su disco, che è
    # dichiarato a priorità negativa in hosts/lenuovo/hardware.nix.
    priority = 100;
  };

  boot.kernel.sysctl = {
    # Con lo swap in RAM, swappare costa poco: 180 è il valore consigliato per
    # i setup zram-only (il massimo è 200). Il default di 60 è tarato su dischi.
    "vm.swappiness" = 180;

    # Il readahead dello swap ha senso solo su dispositivi con seek: su zram è
    # puro spreco di cicli e di RAM. 0 = una pagina alla volta.
    "vm.page-cluster" = 0;

    # Reclaim più aggressivo e anticipato: kswapd si sveglia prima e libera
    # più pagine per volta, così le allocazioni non finiscono in direct
    # reclaim (che è la fase in cui la macchina sembra bloccata).
    "vm.watermark_scale_factor" = 125;
    "vm.watermark_boost_factor" = 0;

    # Ricicla dentries/inodes un po' più volentieri: la page cache qui vale di
    # più delle strutture del VFS.
    "vm.vfs_cache_pressure" = 200;
  };

  # earlyoom guarda memoria e swap liberi in percentuale e manda SIGTERM al
  # processo più grosso quando si scende sotto soglia, SIGKILL se si continua
  # a scendere. È userspace e non dipende dai cgroup, quindi copre anche i
  # build di nix (che girano fuori dallo user slice).
  #
  # Nota: systemd-oomd resta com'è (abilitato ma senza slice gestite, vedi i
  # default di NixOS), così non ci sono due killer che decidono in parallelo.
  services.earlyoom = {
    enable = true;

    # 8% di 3,8 GB ≈ 300 MB: sotto quella soglia il sistema è già in thrashing.
    freeMemThreshold = 8;
    freeMemKillThreshold = 4;

    # Lo swap è quasi tutto zram, quindi riempirlo consuma RAM vera: si
    # interviene mentre ne resta ancora un po'.
    freeSwapThreshold = 15;
    freeSwapKillThreshold = 7;

    extraArgs = [
      # Da preferire come vittime: i divoratori di RAM che si riaprono senza
      # perdere niente di irrecuperabile.
      "--prefer"
      "^(firefox|\\.firefox-wrapped|chromium|electron|steam|steamwebhelper|nix|nix-build|cc1plus|rustc|ld)$"
      # Da risparmiare: se muore uno di questi si perde la sessione, non un
      # programma.
      "--avoid"
      "^(systemd|systemd-.*|Hyprland|Xwayland|sshd|dbus-daemon|waybar|dunst)$"
    ];

    # Notifica sul bus di sistema quando qualcosa viene ucciso, così il kill
    # non sembra un crash misterioso. Tira su anche systembus-notify.
    enableNotifications = true;
  };

  # Protezione del compositore dal reclaim.
  #
  # NON si usa mlock: `LimitMEMLOCK` alza solo il tetto di RLIMIT_MEMLOCK, cioè
  # dà il *permesso* di bloccare pagine; è il programma che deve chiamare
  # mlockall(), e né systemd né Hyprland lo fanno (zero simboli mlock* nei
  # binari). E anche potendo, mlockall(MCL_FUTURE) sul compositore
  # inchioderebbe pure i buffer wl_shm/GPU: centinaia di MB non recuperabili su
  # una macchina da 4 GB, cioè l'opposto di quello che serve.
  #
  # L'equivalente che il kernel onora senza collaborazione del programma è
  # memory.min (MemoryMin=): memoria protetta dal reclaim, non prenotata —
  # se non viene usata resta disponibile per tutti gli altri.
  #
  # ATTENZIONE: memory.min è limitato dagli antenati, la protezione effettiva
  # di un cgroup non può superare quella del padre. Va quindi dichiarata su
  # tutta la catena, che per il compositore (avviato da uwsm, quindi una vera
  # unit systemd) è:
  #   user.slice → user-.slice → user@.service → session.slice → wayland-wm@
  systemd.slices."user".sliceConfig.MemoryMin = "384M";
  systemd.slices."user-" = {
    overrideStrategy = "asDropin";
    sliceConfig.MemoryMin = "384M";
  };
  systemd.services."user@" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      MemoryMin = "384M";
      # Di default il gestore utente gira a oom_score_adj=100 e alza di altri
      # 100 i suoi servizi: il compositore finisce a 200, cioè *più* appetibile
      # della media per l'OOM killer del kernel. Riportandolo a 0 qui (dal
      # manager di sistema, che ha i privilegi per abbassarlo) i servizi utente
      # tornano a 100.
      OOMScoreAdjust = 0;
    };
  };

  # Lato utente il controller memory è delegato (Delegate=yes su user@.service),
  # quindi queste due unit possono davvero impostare memory.min.
  systemd.user.slices."session" = {
    overrideStrategy = "asDropin";
    sliceConfig.MemoryMin = "320M";
  };

  # Il compositore da solo: ~340 MB residenti, e se muore lui va giù tutta la
  # sessione. I figli (browser, Steam, terminali) stanno in app.slice e restano
  # volutamente scoperti — sono proprio le vittime che vogliamo.
  #
  # Qui niente OOMScoreAdjust negativo: il gestore utente non è privilegiato e
  # non può abbassare oom_score_adj sotto il proprio, la unit fallirebbe
  # all'avvio. Dal lato userspace ci pensa già --avoid di earlyoom.
  systemd.user.services."wayland-wm@" = {
    overrideStrategy = "asDropin";
    serviceConfig.MemoryMin = "320M";
  };
}
