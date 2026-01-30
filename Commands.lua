local ADDON_NAME, TST = ...


-------------------------------------------------------------------------------
--- Slash Commands
-------------------------------------------------------------------------------

TST.cmds = {}
TST.cmds.toggle_lock = {
    triggers = { 'lock', 'l' },
    name = "Lock",
    description = "Lock or Unlock the Frame.",
    func = function() TST:ToggleLock() end,
}

TST.cmds.toggle_test = {
    triggers = { 'test', 't' },
    name = "Toggle frame for testing",
    description = "Toggle the frame for test viewing",
    func = function() TST:ToggleTest() end,
}

TST.cmds.toggle_debug = {
    triggers = { 'debug', 'd' },
    name = "Debug Messages",
    description = "Show debug messages",
    func = function() TST:ToggleDebug() end,
}


-------------------------------------------------------------------------------
--- Slash Command Handling
-------------------------------------------------------------------------------

function TST:Help()
    TST:Print("Available Commands:")

    for _, cmd in pairs(TST.cmds) do
        print(string.format("  %s %-10s - %s",
                            SLASH_TIMESPIRALTEXT1,
                            table.concat(cmd.triggers, ", "),
                            cmd.description))
    end
end

SLASH_TIMESPIRALTEXT1 = "/tst"

SlashCmdList[strupper(ADDON_NAME)] = function(msg)
    msg = msg:lower():trim()

    TST:VPrint(string.format("%s %s received",
                             SLASH_TIMESPIRALTEXT1,
                             msg ~= "" and msg or "(no msg)"))

    for _, cmd in pairs(TST.cmds) do
        for _, trigger in ipairs(cmd.triggers) do
            if msg == trigger then
                cmd.func()
                return
            end
        end
    end

    TST:Help()
end
