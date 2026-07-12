# Launcher (SUPER, prima solo binario simlinkato senza stile). Palette e
# font allineati a waybar (vedi config/waybar/style.css) per coerenza visiva.
_: {
  programs.wofi = {
    enable = true;

    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "";
      layer = "overlay";
      allow_markup = true;
      allow_images = true;
      image_size = 40;
      dynamic_lines = true;
      no_actions = true;
      gtk_dark = true;
      hide_scroll = true;
      matching = "fuzzy";
      insensitive = true;
    };

    style = ''
      * {
        font-family: "Ubuntu Nerd Font";
        font-size: 15px;
      }

      window {
        background-color: rgba(10, 10, 20, 0.85);
        border: 2px solid #6a92d7;
        border-radius: 12px;
      }

      #input {
        margin: 10px;
        padding: 8px 12px;
        border: none;
        border-radius: 8px;
        background-color: #1f2530;
        color: #e5e5e5;
      }

      #input:focus {
        outline: none;
        box-shadow: inset 0 0 0 2px #6a92d7;
      }

      #outer-box {
        margin: 0;
        background-color: transparent;
      }

      #inner-box {
        margin: 0 10px 10px 10px;
        background-color: transparent;
      }

      #scroll {
        margin: 0;
      }

      #entry {
        padding: 6px;
        border-radius: 8px;
      }

      #entry image {
        margin-right: 8px;
      }

      #entry:selected {
        background-color: #1f2530;
        box-shadow: inset 0 0 0 1px #6a92d7;
      }

      #text {
        color: #e5e5e5;
      }

      #entry:selected #text {
        color: #6a92d7;
      }
    '';
  };
}
