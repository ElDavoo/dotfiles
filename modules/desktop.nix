{pkgs, ...}: {
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvp";
  services.xserver.xkb.options = "eurosign:e";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.pipewire.enable = true;

  # Codec Bluetooth A2DP: escludo aptx_hd (latenza ~200-250ms) e lascio
  # aptx come qualità massima praticabile. WirePlumber negozia il primo
  # codec supportato in comune, quindi le Accentum Plus si attestano su
  # aptx invece di aptx_hd, e la scelta è persistente al reboot.
  services.pipewire.wireplumber.extraConfig."51-bluez-lowlatency" = {
    "monitor.bluez.properties" = {
      "bluez5.codecs" = ["sbc" "sbc_xq" "aac" "aptx"];
      "bluez5.enable-sbc-xq" = true;
    };
  };

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS non serve più con explicit sync (driver >=555)
    NIXOS_OZONE_WL = "1";
  };

  # I bind XF86MonBrightnessUp/Down di Hyprland chiamano brightnessctl, che non
  # era installato da nessuna parte: da qui il "non funziona" dei tasti Fn.
  # Le regole udev del pacchetto danno al gruppo video il permesso di scrittura
  # su /sys/class/backlight/*/brightness (root-only di default) — senza di esse
  # brightnessctl fallirebbe comunque da utente. dave è nel gruppo video
  # (modules/users.nix).
  environment.systemPackages = [pkgs.brightnessctl];
  services.udev.packages = [pkgs.brightnessctl];

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.nm-applet.enable = true;
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];
}
