local addonName = ...

BINDING_HEADER_PRIORITYMARKERICONS = "Priority Marker Icons"
BINDING_NAME_PRIORITYMARKERICONS_TRIANGLE = "Mark mouseover with Triangle"
BINDING_NAME_PRIORITYMARKERICONS_SQUARE = "Mark mouseover with Square"

local PREFIX = "|cff33ff99Priority Marker Icons:|r "
local DUNGEON_FOLDERS = {
    "Kings Rest",
    "Den of Nalorakk",
    "Murder Row",
    "The Blinding Vale",
    "Voidscar Arena",
    "Altar of Fangs",
    "Ruby Life Pools",
    "Temple of Sethraliss",
}
local MEDIA_FORMATS = {}
for index, folder in ipairs(DUNGEON_FOLDERS) do
    MEDIA_FORMATS[index] = "|TInterface\\AddOns\\" .. addonName .. "\\Media\\" .. folder .. "\\%s:36:36|t"
end
local overlays = {}
local testMode = false

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. message)
end

local function CreateMarkerButton(name, markerIndex)
    local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    button:RegisterForClicks("AnyUp")
    button:SetAttribute("type", "macro")
    button:SetAttribute("macrotext", string.format("/tm [@mouseover,exists,nodead] %d", markerIndex))
    -- Hidden buttons do not receive CLICK bindings. Keep this one visible,
    -- transparent, and off-screen so it cannot intercept the mouse.
    button:SetSize(1, 1)
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -10, -10)
    button:SetAlpha(0)
    button:Show()
    return button
end

-- Blizzard raid marker indices: 4 = Triangle, 6 = Square.
CreateMarkerButton("PriorityMarkerIconsTriangleButton", 4)
CreateMarkerButton("PriorityMarkerIconsSquareButton", 6)

-- Midnight can hide NPC identities from Lua, but SetFormattedText accepts a
-- secret name as an argument. The database lives in dungeon folders under
-- Media. Every path is attempted without reading or comparing the name; only
-- an existing texture is rendered.
local function GetNameplateAnchor(nameplate)
    local unitFrame = nameplate.UnitFrame or nameplate.unitFrame
    if unitFrame then
        return unitFrame.healthBar or unitFrame.HealthBar or unitFrame.Health or nameplate
    end
    return nameplate
end

local function GetOverlays(nameplate)
    local markerOverlays = overlays[nameplate]
    if markerOverlays then
        return markerOverlays
    end

    markerOverlays = {}
    for index = 1, #MEDIA_FORMATS do
        local overlay = nameplate:CreateFontString(nil, "OVERLAY")
        overlay:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        overlay:SetJustifyH("CENTER")
        markerOverlays[index] = overlay
    end
    overlays[nameplate] = markerOverlays
    return markerOverlays
end

local function UpdateNameplate(unitToken)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)
    if not nameplate then
        return
    end

    local markerOverlays = GetOverlays(nameplate)
    for _, overlay in ipairs(markerOverlays) do
        overlay:ClearAllPoints()
        overlay:SetPoint("BOTTOM", GetNameplateAnchor(nameplate), "TOP", 0, 6)
    end

    if testMode then
        markerOverlays[1]:SetText("|TInterface\\Icons\\INV_Misc_QuestionMark:36:36|t")
        for index = 2, #markerOverlays do
            markerOverlays[index]:SetText("")
        end
    else
        -- Do not concatenate, compare, or index with unitName: it may be secret.
        local unitName = UnitName(unitToken)
        for index, overlay in ipairs(markerOverlays) do
            overlay:SetFormattedText(MEDIA_FORMATS[index], unitName)
        end
    end
    for _, overlay in ipairs(markerOverlays) do
        overlay:Show()
    end
end

local function HideNameplate(unitToken)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)
    local markerOverlays = nameplate and overlays[nameplate]
    if markerOverlays then
        for _, overlay in ipairs(markerOverlays) do
            overlay:Hide()
        end
    end
end

local function RefreshNameplates()
    for i = 1, 40 do
        local unitToken = "nameplate" .. i
        if UnitExists(unitToken) then
            UpdateNameplate(unitToken)
        end
    end
end

local function IsSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function InspectMouseover()
    if not UnitExists("mouseover") then
        Print("there is no unit under the cursor.")
        return
    end

    local guid = UnitGUID("mouseover")
    local name = UnitName("mouseover")

    local guidIsSecret = IsSecret(guid)
    local nameIsSecret = IsSecret(name)

    if nameIsSecret then
        Print("the mouseover name is secret; it can be rendered directly, but Lua cannot read it.")
        return
    end

    local npcID
    if guid and not guidIsSecret then
        local unitType, _, _, _, _, id = strsplit("-", guid)
        if unitType == "Creature" or unitType == "Vehicle" then
            npcID = tonumber(id)
        end
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    Print(string.format(
        "mouseover=%s, npcID=%s, mapID=%s",
        name or "unknown",
        guidIsSecret and "secret" or (npcID and tostring(npcID) or "unavailable"),
        mapID and tostring(mapID) or "unavailable"
    ))
end

local function ShowHelp()
    Print("loaded.")
    Print("Local icons appear automatically and require no key presses.")
    Print("The Square and Triangle keybinds remain available as optional fallbacks.")
    Print("Use /pmi inspect while hovering over a unit.")
    Print("Local icons are loaded from dungeon folders under Media.")
    Print("Use /pmi test to check icon placement on all visible nameplates.")
end

SLASH_PRIORITYMARKERICONS1 = "/prioritymarkericons"
SLASH_PRIORITYMARKERICONS2 = "/pmi"
SLASH_PRIORITYMARKERICONS3 = "/automarker"
SLASH_PRIORITYMARKERICONS4 = "/am"
SlashCmdList.PRIORITYMARKERICONS = function(message)
    local command = strtrim(message or ""):lower()
    if command == "inspect" or command == "id" then
        InspectMouseover()
    elseif command == "test" then
        testMode = not testMode
        Print("test mode " .. (testMode and "enabled" or "disabled") .. ".")
        RefreshNameplates()
    else
        ShowHelp()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function(_, event, unitToken)
    if event == "PLAYER_LOGIN" then
        Print("loaded. Type /pmi for instructions.")
        C_Timer.NewTicker(3, RefreshNameplates)
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        UpdateNameplate(unitToken)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        HideNameplate(unitToken)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, RefreshNameplates)
    end
end)
