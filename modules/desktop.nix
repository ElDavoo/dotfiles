{pkgs, ...}: {
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvp";
  services.xserver.xkb.options = "eurosign:e";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [pkgs.proton-ge-bin];
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  services.pipewire.enable = true;

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS non serve più con explicit sync (driver >=555)
    NIXOS_OZONE_WL = "1";
  };

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
