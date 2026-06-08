local cmds = {
    rofi = "rofi",
    grim = "grim",
    slurp = "slurp",
    satty = "satty",
    cliphist = "cliphist",
    wl_copy = "wl-copy",
    wl_paste = "wl-paste",
    kitty = "kitty",
    dolphin = "dolphin",
    helium = "helium",
    quickshell = "qs",
    pavucontrol = "pavucontrol"
}

for _, cmd in pairs(cmds) do
    local status = os.execute("command -v " .. cmd .. " >/dev/null 2>&1")
    if status ~= 0 and status ~= true then
        hl.notification.create({
            text = "Missing Dependency: " .. cmd .. " is not installed",
            duration = 10000,
            icon = 3,
            color = "rgb(ff1111)"
        })
    end
end

return cmds
