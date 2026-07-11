# Config di Hyprland e Waybar, versionate nel repo.
# Symlink fuori dallo store: si possono modificare senza rebuild,
# ma il repo deve stare in ~/git/dotfiles.
{config, ...}: let
  dotfiles = "${config.home.homeDirectory}/git/dotfiles/home/config";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in {
  xdg.configFile = {
    # hyprland.lua ha precedenza; hyprland.conf resta come fallback
    "hypr/hyprland.lua".source = link "hypr/hyprland.lua";
    "hypr/hyprland.conf".source = link "hypr/hyprland.conf";
    "hypr/hypridle.conf".source = link "hypr/hypridle.conf";
    "hypr/hyprlock.conf".source = link "hypr/hyprlock.conf";
    "hypr/hyprpaper.conf".source = link "hypr/hyprpaper.conf";
    "hypr/monitors.conf".source = link "hypr/monitors.conf";
    "hypr/workspaces.conf".source = link "hypr/workspaces.conf";
    "waybar/config".source = link "waybar/config";
    "waybar/style.css".source = link "waybar/style.css";
    "waybar/mediaplayer.py".source = link "waybar/mediaplayer.py";
    "waybar/icons".source = link "waybar/icons";
  };
}
