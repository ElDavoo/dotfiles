_: {
  users.users.dave = {
    isNormalUser = true;
    description = "Davide";
    # Solo gruppi che esistono davvero su ogni host: quelli creati da un
    # modulo opzionale si aggiungono dal modulo stesso (docker da
    # virtualization.nix, scanner da printing.nix), così non restano elencati
    # su una macchina che non li ha.
    #
    # "video": le regole udev di brightnessctl passano
    # /sys/class/backlight/*/brightness al gruppo video, altrimenti i tasti
    # Fn di luminosità non hanno permesso di scrittura. Vedi modules/desktop.nix.
    #
    # Rimossi "plugdrv" (refuso di plugdev) e "storage": sono roba di Arch, su
    # NixOS non li definisce nessuno e venivano scartati in silenzio. Rimosso
    # anche "adbusers": lo creava programs.adb.enable, opzione tolta da nixpkgs
    # perché da systemd 258 i permessi sui device USB li dà uaccess da solo.
    extraGroups = ["input" "video" "networkmanager" "wheel" "kvm" "lp"];
  };

  # L'autologin (e quindi l'avvio automatico di Hyprland da .bash_profile,
  # vedi home/bash.nix) resta solo su mattone: si dichiara in
  # hosts/mattone/default.nix.
}
