# Tema cursore unico per tutto (Hyprland, GTK/waybar, XWayland).
# Senza questo, waybar non trovava "Adwaita" e Hyprland ripiegava
# sul cursore builtin (la goccia blu).
{pkgs, ...}: {
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    x11.enable = true;
    hyprcursor = {
      enable = true;
      size = 24;
    };
  };
}
