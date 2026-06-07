local vars = require("vars")

-- ============================================================================
-- Monitors
-- ============================================================================
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "highrr",
    position = "0x0",
    scale    = 1.0,
})
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto"
})

-- ============================================================================
-- Environment Variables
-- ============================================================================
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_SIZE", "20")

-- ============================================================================
-- Autostart & Hooks
-- ============================================================================

local startup = function()
    hl.exec_cmd("uwsm app -u quickshell.scope -- qs")
    hl.exec_cmd("uwsm app -u cliphist-text.scope -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -u cliphist-image.scope -- wl-paste --type image --watch cliphist store")
end

hl.on("hyprland.start", function()
    startup()
end)

hl.on("config.reloaded", function()
    -- idk what to do here
end)

-- ============================================================================
-- Configuration
-- ============================================================================
hl.config({
    general    = {
        gaps_in          = 5,
        gaps_out         = 10,
        border_size      = 2,
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",

        col              = {
            active_border = {
                colors = { "rgba(7aa2f7ee)", "rgba(3d59a1ee)" },
                angle  = 45
            }
        },
    },
    decoration = {
        rounding         = 15,
        rounding_power   = 3,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3
        },
        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696
        }
    },
    animations = { enabled = true },
    dwindle    = { preserve_split = true },
    master     = { new_status = "master" },
    misc       = {
        disable_hyprland_logo    = false,
        disable_splash_rendering = false,
        force_default_wallpaper  = 3
    }
})

-- ============================================================================
-- Curves & Animations
-- ============================================================================
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidefade 50%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidefadevert 50%" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- ============================================================================
-- Workspace Rules
-- ============================================================================
hl.workspace_rule({ workspace = "special:magic", layout = "scrolling" })

-- ============================================================================
-- Window Rules
-- ============================================================================
hl.window_rule({ match = { tag = "opaque" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = "^helium$" }, tag = "+opaque" })

hl.window_rule({
    name   = "bar-nm",
    match  = { class = "^nm-connection-editor$" },
    float  = true,
    center = true,
    size   = { 800, 600 },
})

-- ============================================================================
-- Keybindings
-- ============================================================================

-- Apps & Launchers
hl.bind("SUPER + T", hl.dsp.exec_cmd(vars.app.terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(vars.app.fileManager))
hl.bind("SUPER + B", hl.dsp.exec_cmd(vars.app.browser))

hl.bind("SUPER + Space", hl.dsp.exec_cmd(vars.rofi.menu))
hl.bind("SUPER + K", hl.dsp.exec_cmd(vars.rofi.keys))
hl.bind("SUPER + V", hl.dsp.exec_cmd(vars.rofi.clipboard))

-- System & Session
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("qs ipc call power-control open"))
hl.bind("SUPER + SHIFT + R", function()
    startup()
end)

-- Window Management
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + O", hl.dsp.window.tag({ tag = "opaque" }))

-- Focus Movement
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }))

hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Window Movement
hl.bind("SUPER + SHIFT + Left", hl.dsp.window.move({ direction = "l", relative = true }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "r", relative = true }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ direction = "u", relative = true }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ direction = "d", relative = true }))

-- Mouse Operations
hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())
-- hl.bind("SUPER + mouse_down", hl.dsp.exec_cmd("...")) -- zoom in
-- hl.bind("SUPER + mouse_up",   hl.dsp.exec_cmd("...")) -- zoom out
-- hl.bind("SUPER + mouse:274",  hl.dsp.exec_cmd("...")) -- reset zoom

-- Workspaces
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + CTRL + ALT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Relative Workspace Focus
hl.bind("SUPER + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("SUPER + CTRL + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + mouse_down", hl.dsp.focus({ workspace = "e+1" }))

-- Relative Workspace Movement
hl.bind("SUPER + CTRL + ALT + Left", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + CTRL + ALT + Right", hl.dsp.window.move({ workspace = "r+1" }))

-- Special Workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + Z", hl.dsp.window.move({ workspace = "special:magic" }))

-- Media & Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ toggle"))

-- hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Volume (Function Keys)
hl.bind("F8", hl.dsp.exec_cmd("pavucontrol", { float = true, size = { 800, 600 }, center = true }))
hl.bind("F9", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("F10", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("grim - | satty -f -"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty -f -"))

-- Submaps
hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("Right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
    hl.bind("Left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
    hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
    hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- Some Extra
hl.bind("SUPER + M", function()
    local window = hl.get_active_window()
    if not window then return end
    hl.exec_cmd("wpctl set-mute -p " .. hl.get_active_window().pid .. " toggle")
end)
