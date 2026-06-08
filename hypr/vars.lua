local success, paths = pcall(require, "paths")
if not success then paths = require("fallback_paths") end

return {
    app = {
        terminal = paths.kitty,
        fileManager = paths.dolphin,
        browser = paths.helium
    },
    rofi = {
        menu = paths.rofi .. " -show drun",
        keys = paths.rofi .. " -show keys",
        clipboard = paths.rofi .. " -show clipboard",
    }
}
