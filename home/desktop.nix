# Config di Hyprland versionate nel repo, come symlink fuori dallo store:
# si possono modificare senza rebuild, ma il repo deve stare in ~/git/dotfiles.
#
# Solo hyprland.lua (config attiva) e i suoi include restano qui: il resto
# (waybar, hypridle, hyprlock, hyprpaper) è ora gestito nativamente da
# home-manager (vedi waybar.nix e services.nix).
# Gli script Python di waybar restano symlink: mediaplayer.py e il proxy che
# riscrive i click sui workspace per la config Lua.
{config, ...}: let
  dotfiles = "${config.home.homeDirectory}/git/dotfiles/home/config";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in {
  xdg.configFile = {
    # hyprland.lua ha precedenza; hyprland.conf resta come fallback
    "hypr/hyprland.lua".source = link "hypr/hyprland.lua";
    "hypr/hyprland.conf".source = link "hypr/hyprland.conf";
    "hypr/monitors.conf".source = link "hypr/monitors.conf";
    "hypr/workspaces.conf".source = link "hypr/workspaces.conf";
    "waybar/mediaplayer.py".source = link "waybar/mediaplayer.py";
    "waybar/waybar-hypr-proxy.py".source = link "waybar/waybar-hypr-proxy.py";
  };
}
