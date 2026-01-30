local ADDON_NAME, TST = ...

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

local testing = false
local verbose = false

-- Spell list
local targetSpells = {}
targetSpells[48265] 	= true --Death's Advance

targetSpells[195072] 	= true --Fel Rush
targetSpells[189110] 	= true --Infernal Strike

targetSpells[1850] 		= true --Dash
targetSpells[252216] 	= true --Tiger Dash

targetSpells[358267] 	= true --Hover

targetSpells[186257] 	= true --Aspect of the Cheetah

targetSpells[1953] 		= true --Blink
targetSpells[212653] 	= true --Shimmer

targetSpells[361138] 	= true --Roll
targetSpells[119085] 	= true --Chi Torpedo

targetSpells[190784] 	= true --Divine Steed

targetSpells[73325] 	= true --Leap of Faith

targetSpells[2983] 		= true --Sprint

targetSpells[192063] 	= true --Gust of Wind
targetSpells[58875] 	= true --Spirit Walk
targetSpells[79206] 	= true --Spiritwalker's Grace

targetSpells[48020] 	= true --Demonic Circle: Teleport

targetSpells[6544] 		= true --Heroic Leap

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
        TST.frame:Show()
    else
        TST.frame:Hide()
    end
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
TST.frame:SetScript("OnDragStart", TST.frame.StartMoving)
TST.frame:SetScript("OnDragStop", TST.frame.StopMovingOrSizing)

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
TST.frame.text:SetText("Time Spiral")


-------------------------------------------------------------------------------
--- Event Handling
-------------------------------------------------------------------------------

local function EventHandler(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            if not TimeSpiralTextDB then
                TST:Print("TimeSpiralTextDB not available, creating.")
                TimeSpiralTextDB = {
                    locked = false
                }
            else
                -- Set saved variables
                TST:Lock(TimeSpiralTextDB.locked)
            end

            TST.frame:UnregisterEvent("ADDON_LOADED")

            TST.frame:RegisterUnitEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
            TST.frame:RegisterUnitEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

            TST:Print("Loaded. Use " .. SLASH_TIMESPIRALTEXT1 .. " for commands.")
        end
    elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
        local spellId = arg1
        if targetSpells[spellId] then
            TST.frame:Show()
        end

    elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
        local spellId = arg1
        if targetSpells[spellId] then
            TST.frame:Hide()
        end
    end
end

-- Register events
TST.frame:RegisterEvent("ADDON_LOADED")

TST.frame:SetScript("OnEvent", EventHandler)
