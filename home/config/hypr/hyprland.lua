-- Config Hyprland in Lua (hyprlang è deprecato dalla 0.55).
-- Convertita da hyprland.conf; quella resta come fallback: per usarla
-- di nuovo basta togliere questo file.
-- API: /run/current-system/sw/share/hypr/stubs/hl.meta.lua

------------------
---- MONITORS ----
------------------

-- Convertiti da monitors.conf (generata da nwg-displays).
-- NOTA: nwg-displays scrive ancora monitors.conf in hyprlang: se lo riusi,
-- riporta a mano i valori qui.
hl.monitor({
    output   = "desc:BOE 0x0974",
    mode     = "2560x1440@165.0",
    position = "1920x0",
    scale    = 1.6,
})
hl.monitor({
    output   = "desc:Dell Inc. DELL P2418D MY3ND7AN0ZKT",
    mode     = "1920x1080@60.0",
    position = "0x0",
    scale    = 1.0,
    bitdepth = 10,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("GDK_SCALE", "1") -- toolkit-specific scale
-- XCURSOR_* e HYPRCURSOR_* sono impostate da home-manager
-- (home.pointerCursor in home/cursor.nix)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },

    general = {
        gaps_in     = 3,
        gaps_out    = 0,
        border_size = 1,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",
        -- Vedi https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
        allow_tearing    = true,
        resize_on_border = true,
    },

    decoration = {
        rounding         = 3,
        inactive_opacity = 0.98,

        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },
    },

    group = {
        col = {
            border_active          = { colors = { "rgba(000000ff)", "rgba(000000ff)" }, angle = 45 },
            border_inactive        = { colors = { "rgba(000000ff)", "rgba(000000ff)" }, angle = 45 },
            border_locked_active   = { colors = { "rgba(FADA16ff)", "rgba(4DBD4Fff)" }, angle = 45 },
            border_locked_inactive = { colors = { "rgba(5032ACff)", "rgba(1F5322ff)" }, angle = 45 },
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    gestures = {
        workspace_swipe_touch    = true,
        workspace_swipe_distance = 1003,
    },

    misc = {
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        vrr                        = 1,
        mouse_move_enables_dpms    = true,
        key_press_enables_dpms     = true,
        allow_session_lock_restore = true,
    },

    -- unscale XWayland
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 2, bezier = "default" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "it,us",
        kb_variant = ",dvorak",

        follow_mouse = 1,

        sensitivity   = 0.4,
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll = false,
            scroll_factor  = 0.8,
        },
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"))

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("xfce4-terminal"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("nwg-bar"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock & bash -c 'sleep 3 && hyprctl dispatch dpms off'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("joplin-desktop"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("/home/dave/Scaricati/Zotero_linux-x86_64/zotero"))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + S", hl.dsp.window.swap({ next = true }))
hl.bind(mainMod .. " + T", hl.dsp.group.toggle())
hl.bind(mainMod .. " + tab", hl.dsp.group.next())
hl.bind(mainMod .. " + G", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + H", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspace 1-10 (mainMod), 11-20 (mainMod+CTRL);
-- + SHIFT per spostarci la finestra attiva
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,                    hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,            hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key,             hl.dsp.focus({ workspace = i + 10 }))
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i + 10 }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Clipboard history
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu -I | cliphist decode | wl-copy"))

-- Launcher on tapping SUPER
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("pkill wofi || wofi -I --show drun"), { release = true })

-- Screenshots
hl.bind(mainMod .. " + ALT + S",   hl.dsp.exec_cmd("grim"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp -d)"'))

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.2 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("kwalletd5")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-gammarelay")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
    hl.exec_cmd("xwaylandvideobridge")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("kdeconnectd")
    hl.exec_cmd("kdeconnect-indicator")
    hl.exec_cmd("libinput-gestures-setup autostart start")
    hl.exec_cmd("mpris-proxy")
    hl.exec_cmd("/home/dave/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/home/dave/Scaricati/whatpulse-linux-latest_amd64.AppImage")
    hl.exec_cmd("gnome-keyring-daemon --replace --components=secrets")
    -- Dalla vecchia config, path /usr/* inesistenti su NixOS (già no-op):
    -- /usr/libexec/polkit-gnome-authentication-agent-1
    -- /usr/lib64/libexec/polkit-kde-authentication-agent-1
end)

----------------------
---- WINDOW RULES ----
----------------------

hl.window_rule({
    name  = "hide-xwaylandvideobridge",
    match = { class = "^(xwaylandvideobridge)$" },

    opacity          = "0.0 override 0.0 override",
    no_initial_focus = true,
})

-- Firefox screen sharing indicator
hl.window_rule({
    name  = "float-ff-sharing-en",
    match = { class = "^(firefox)$", title = "^(Firefox — Sharing Indicator)$" },
    float = true,
})
hl.window_rule({
    name  = "float-ff-sharing-it",
    match = { class = "^(firefox)$", title = "^(Firefox – Indicatore condivisione)$" },
    float = true,
})
hl.window_rule({
    name  = "float-ff-sharing-it2",
    match = { title = "Firefox - Indicatore condivisione" },
    float = true,
})

hl.window_rule({
    name  = "float-polkit-kde",
    match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
})

hl.window_rule({
    name    = "kitty-opacity",
    match   = { class = "^(kitty)$" },
    opacity = "0.95 0.95",
})
hl.window_rule({
    name      = "kitty-update-sys-popin",
    match     = { class = "^(kitty)$", title = "^(update-sys)$" },
    animation = "popin",
})
hl.window_rule({
    name      = "thunar-popin",
    match     = { class = "^(thunar)$" },
    animation = "popin",
    opacity   = "0.95 0.95",
})
hl.window_rule({
    name    = "vscodium-opacity",
    match   = { class = "^(VSCodium)$" },
    opacity = "0.95 0.95",
})
hl.window_rule({
    name      = "chromium-popin",
    match     = { class = "^(chromium)$" },
    animation = "popin",
})
hl.window_rule({
    name      = "wofi-slide",
    match     = { class = "^(wofi)$" },
    animation = "slide",
})
hl.window_rule({
    name  = "wofi-clippick-move",
    match = { class = "^(wofi)$", title = "^(clippick)$" },
    move  = "100%-433 53",
})

-- Fix splash screen JetBrains
hl.window_rule({
    name   = "center-jetbrains-splash",
    match  = { class = "^(jetbrains-.*)$", title = "^(splash)$" },
    center = true,
})

-- Il blocco `plugin { hyprbars ... }` della vecchia config è stato rimosso:
-- il plugin non veniva mai caricato (l'exec-once era commentato).
