local ADDON_NAME, TST = ...
local ADDON_ABVR = "TST"

-------------------------------------------------------------------------------
--- Configuration Variables
-------------------------------------------------------------------------------

local IMMEDIATELY = true

local addon_color = "ffffff77"
local r, g, b = 255/255, 255/255, 119/255

local      font_size = 36
local  handle_offset = 0 -- Adjust Handle to the left
local     mover_size = 32
local padding_bottom = -3 -- Adjust all text down

local COUNTDOWN_DURATION = 10
local COUNTDOWN_UPDATE_INTERVAL = 0.1
local DISPLAY_TEXT = "Time Spiral"

local testing = false
local verbose = false
local countdown_ends_at = nil
local countdown_ticker = nil

local DEFAULT_POSITION = {
    point = "CENTER",
    relPoint = "CENTER",
    x = 0,
    y = 0
}

-- Spell list
TST.data = {}
TST.data.affected_spell_ids = {}

TST.data.affected_spell_ids[48265]  = true -- Death Knight: Death's Advance
TST.data.affected_spell_ids[195072] = true -- Demon Hunter: Fel Rush
TST.data.affected_spell_ids[189110] = true -- Demon Hunter: Infernal Strike
TST.data.affected_spell_ids[1850]   = true --        Druid: Dash
TST.data.affected_spell_ids[252216] = true --        Druid: Tiger Dash
TST.data.affected_spell_ids[358267] = true --       Evoker: Hover
TST.data.affected_spell_ids[186257] = true --       Hunter: Aspect of the Cheetah
TST.data.affected_spell_ids[1953]   = true --         Mage: Blink
TST.data.affected_spell_ids[212653] = true --         Mage: Shimmer
TST.data.affected_spell_ids[361138] = true --         Monk: Roll
TST.data.affected_spell_ids[119085] = true --         Monk: Chi Torpedo
TST.data.affected_spell_ids[190784] = true --      Paladin: Divine Steed
TST.data.affected_spell_ids[73325]  = true --       Priest: Leap of Faith
TST.data.affected_spell_ids[2983]   = true --        Rogue: Sprint
TST.data.affected_spell_ids[192063] = true --       Shaman: Gust of Wind
TST.data.affected_spell_ids[58875]  = true --       Shaman: Spirit Walk
TST.data.affected_spell_ids[79206]  = true --       Shaman: Spiritwalker's Grace
TST.data.affected_spell_ids[48020]  = true --      Warlock: Demonic Circle: Teleport
TST.data.affected_spell_ids[6544]   = true --      Warrior: Heroic Leap

-------------------------------------------------------------------------------
--- Functions
-------------------------------------------------------------------------------

function TST:Print(msg)
    print("|c" .. addon_color .. ADDON_NAME .. ":|r " .. msg)
end

function TST:VPrint(msg)
    if not verbose then return end

    print("|c" .. addon_color .. ADDON_ABVR .. ":|r " .. msg)
end

function TST:ToggleLock()
    TimeSpiralTextDB.locked = not TimeSpiralTextDB.locked
    TST:Lock(TimeSpiralTextDB.locked)
    TST:Print("Frame " .. (TimeSpiralTextDB.locked and "L" or "Unl") .. "ocked")
end

function TST:Lock(locked)
    if locked then
        TST.frame:Hide()
        TST.frame.bg:Hide()
        TST.frame.handle:Hide()
        TST.frame:EnableMouse(false)
    else
        TST.frame:Show()
        TST.frame.bg:Show()
        TST.frame.handle:Show()
        TST.frame:EnableMouse(true)
    end
end

function TST:ToggleDebug()
    verbose = not verbose
    TST:Print("debug turned " .. (verbose and "on" or "off"))
end

function TST:ToggleTest()
    testing = not testing
    TST:Print("testing turned " .. (testing and "on" or "off"))

    if testing then
        TST:StartCountdown()
    else
        TST:StopCountdown()
        TST.frame:Hide()
    end
end

function TST:StopCountdown()
    if countdown_ticker then
        countdown_ticker:Cancel()
        countdown_ticker = nil
    end

    countdown_ends_at = nil
    TST.frame.text:SetText(DISPLAY_TEXT)

    if not testing and (not TimeSpiralTextDB or TimeSpiralTextDB.locked) then
        TST.frame:Hide()
    end
end

function TST:UpdateCountdown()
    if not countdown_ends_at then return end

    local remaining = countdown_ends_at - GetTime()
    if remaining <= 0 then
        TST:StopCountdown()
        return
    end

    TST.frame.text:SetText(string.format("%s %d", DISPLAY_TEXT, math.ceil(remaining)))
end

function TST:StartCountdown()
    if countdown_ticker then
        countdown_ticker:Cancel()
        countdown_ticker = nil
    end

    countdown_ends_at = GetTime() + COUNTDOWN_DURATION
    TST.frame:Show()
    TST:UpdateCountdown()

    countdown_ticker = C_Timer.NewTicker(COUNTDOWN_UPDATE_INTERVAL, function()
        TST:UpdateCountdown()
    end)
end

function TST:InitializeDB()
    TimeSpiralTextDB = TimeSpiralTextDB or {}

    if TimeSpiralTextDB.locked == nil then
        TimeSpiralTextDB.locked = false
    end

    if type(TimeSpiralTextDB.position) ~= "table" then
        TimeSpiralTextDB.position = {}
    end

    local position = TimeSpiralTextDB.position
    position.point = position.point or DEFAULT_POSITION.point
    position.relPoint = position.relPoint or DEFAULT_POSITION.relPoint
    position.x = position.x or DEFAULT_POSITION.x
    position.y = position.y or DEFAULT_POSITION.y
end

function TST:RestorePosition()
    local position = TimeSpiralTextDB and TimeSpiralTextDB.position
    if not position then return end

    TST.frame:ClearAllPoints()
    TST.frame:SetPoint(position.point, UIParent, position.relPoint, position.x, position.y)
end

function TST:SavePosition()
    if not TimeSpiralTextDB then return end

    local point, _, relPoint, x, y = TST.frame:GetPoint(1)
    TimeSpiralTextDB.position = {
        point = point,
        relPoint = relPoint,
        x = x,
        y = y
    }
end

-------------------------------------------------------------------------------
--- Initialization
-------------------------------------------------------------------------------

-- Create the main frame
TST.frame = CreateFrame("Frame", "TimeSpiralTextFrame", UIParent)
TST.frame:SetSize(mover_size, mover_size)
TST.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
TST.frame:SetMovable(true)
TST.frame:SetClampedToScreen(true)
TST.frame:SetToplevel(true)
TST.frame:Hide()

-- Create background
TST.frame.bg = TST.frame:CreateTexture(nil, "BACKGROUND")
TST.frame.bg:SetAllPoints(TST.frame)
TST.frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- Create mover texture
TST.frame.handle = TST.frame:CreateTexture(nil, "BACKGROUND")
TST.frame.handle:SetSize(mover_size - 2, mover_size - 2)
TST.frame.handle:SetPoint("CENTER", TST.frame, "CENTER", 0, 0)
TST.frame.handle:SetTexture("Interface\\CURSOR\\UI-Cursor-Move")
TST.frame.handle:SetVertexColor(1, 1, 1, 1)

-- Make the frame draggable
TST.frame:EnableMouse(true)
TST.frame:RegisterForDrag("LeftButton")
TST.frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
TST.frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    TST:SavePosition()
end)

-- Set up custom font (using a WoW built-in font, or replace with your own font file)
local FONT = "Interface\\AddOns\\TimeSpiralText\\media\\fonts\\PTSansNarrow-Bold.ttf"

TST.frame.font = CreateFont("TimeSpiralTextFont")
TST.frame.font:SetFont(FONT, font_size, "OUTLINE")
TST.frame.font:SetTextColor(1, 1, 1, 1)

-- Create the text for the item name on the right
TST.frame.text = TST.frame:CreateFontString(nil, "OVERLAY")
TST.frame.text:SetFontObject(TST.frame.font)
TST.frame.text:SetTextColor(r, g, b, 1)
TST.frame.text:SetPoint("BOTTOMLEFT", TST.frame, "BOTTOMRIGHT", handle_offset + 2, padding_bottom)
TST.frame.text:SetText(DISPLAY_TEXT)


-------------------------------------------------------------------------------
--- Event Handling
-------------------------------------------------------------------------------

local function EventHandler(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            TST:InitializeDB()
            TST:RestorePosition()
            TST:Lock(TimeSpiralTextDB.locked)

            TST.frame:UnregisterEvent("ADDON_LOADED")

            TST.frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
            -- Time Spiral lasts a flat 10 seconds from glow start; the
            -- countdown expires locally instead of using per-spell hides.

            TST:Print("Loaded. Use " .. SLASH_TIMESPIRALTEXT1 .. " for commands.")
        end
    elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
        if TST.data.affected_spell_ids[arg1] then
            TST:StartCountdown()
        end
    end
end

-- Register events
TST.frame:RegisterEvent("ADDON_LOADED")

TST.frame:SetScript("OnEvent", EventHandler)
