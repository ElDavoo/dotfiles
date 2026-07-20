# Notification daemon (avviato da services.nix in origine come solo
# `enable`, senza stile). Palette e font allineati a waybar/wofi.
{pkgs, ...}: {
  services.dunst = {
    enable = true;

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = "32x32";
    };

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";

        width = 320;
        height = 300;
        origin = "top-right";
        offset = "16x16";
        notification_limit = 20;

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_corner_radius = 5;

        frame_width = 2;
        frame_color = "#6a92d7";
        corner_radius = 12;
        separator_height = 2;
        separator_color = "frame";

        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 8;

        sort = true;
        idle_threshold = 120;

        font = "Ubuntu Nerd Font 11";
        line_height = 2;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        ellipsize = "middle";
        show_age_threshold = 60;

        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 64;

        sticky_history = true;
        history_length = 20;

        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#1f2530";
        foreground = "#e5e5e5";
        frame_color = "#3b4252";
        timeout = 5;
      };

      urgency_normal = {
        background = "#1f2530";
        foreground = "#ffffff";
        frame_color = "#6a92d7";
        timeout = 8;
      };

      urgency_critical = {
        background = "#1b242b";
        foreground = "#ffffff";
        frame_color = "#bf616a";
        timeout = 0;
      };
    };
  };
}
