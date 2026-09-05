local addonName, addon = ...
local NPC_DATABASE = addon.NPC_DATABASE

BINDING_HEADER_PRIORITYMARKERICONS = "Priority Marker Icons"
BINDING_NAME_PRIORITYMARKERICONS_TRIANGLE = "Mark mouseover with Triangle"
BINDING_NAME_PRIORITYMARKERICONS_SQUARE = "Mark mouseover with Square"

local PREFIX = "|cff33ff99Priority Marker Icons:|r "
local DUNGEON_FOLDERS = {
    "Kings Rest", "Den of Nalorakk", "Murder Row", "The Blinding Vale",
    "Voidscar Arena", "Altar of Fangs", "Ruby Life Pools", "Temple of Sethraliss",
}
local DUNGEON_ALIASES = {
    ["King's Rest"] = "Kings Rest",
    ["Kings Rest"] = "Kings Rest",
}
local TEST_MARKERS = {
    "_star", "_circle", "_diamond", "_triangle",
    "_moon", "_square", "_cross", "_skull",
}
local MARKER_OPTIONS = {
    { id = "star", label = "Star", texture = "_star" },
    { id = "circle", label = "Circle", texture = "_circle" },
    { id = "diamond", label = "Diamond", texture = "_diamond" },
    { id = "triangle", label = "Triangle", texture = "_triangle" },
    { id = "moon", label = "Moon", texture = "_moon" },
    { id = "square", label = "Square", texture = "_square" },
    { id = "cross", label = "Cross", texture = "_cross" },
    { id = "skull", label = "Skull", texture = "_skull" },
}
local MARKER_OPTION_BY_ID = {}
local DUNGEON_CODES = {
    ["Kings Rest"] = "KR",
    ["Den of Nalorakk"] = "DN",
    ["Murder Row"] = "MR",
    ["The Blinding Vale"] = "BV",
    ["Voidscar Arena"] = "VA",
    ["Altar of Fangs"] = "AF",
    ["Ruby Life Pools"] = "RL",
    ["Temple of Sethraliss"] = "TS",
}
local DUNGEON_BY_CODE = {}
local CUSTOM_MARKER_DUNGEONS = {
    ["Kings Rest"] = true,
    ["Den of Nalorakk"] = true,
    ["Murder Row"] = true,
    ["The Blinding Vale"] = true,
    ["Voidscar Arena"] = true,
    ["Altar of Fangs"] = true,
    ["Ruby Life Pools"] = true,
    ["Temple of Sethraliss"] = true,
}
local DEFAULTS = {
    enabled = true,
    onlyInDungeons = true,
    combatOnly = false,
    iconSize = 36,
    offsetY = 6,
    alpha = 1,
    debug = false,
    enabledDungeons = {},
    enabledNPCs = {},
    selectedMarkers = {},
    minimap = {
        hide = false,
        angle = 220,
    },
}
local LEGACY_MEDIA_FORMATS, NPC_MEDIA_FORMATS, TEST_FORMATS = {}, {}, {}
local overlays, activeNameplates = {}, {}
local settingsControls = {}
local dungeonPanelStates = {}
local testMode = false
local challengeModeActive = false
local currentDungeonFolder, currentInstanceName, currentInstanceID, settingsCategory, db
local minimapButton
local UpdateMinimapButtonPosition, UpdateMinimapButtonVisibility
local MAX_OVERLAYS = #TEST_MARKERS
local NPC_DEFAULTS_VERSION = 3

for _, marker in ipairs(MARKER_OPTIONS) do
    MARKER_OPTION_BY_ID[marker.id] = marker
end
for folder, code in pairs(DUNGEON_CODES) do
    DUNGEON_BY_CODE[code] = folder
end

for index, folder in ipairs(DUNGEON_FOLDERS) do
    LEGACY_MEDIA_FORMATS[index] = "|TInterface\\AddOns\\" .. addonName .. "\\Media\\" .. folder .. "\\%s:%d:%d|t"
    NPC_MEDIA_FORMATS[folder] = {}
    local dungeonNPCs = NPC_DATABASE[folder]
    MAX_OVERLAYS = math.max(MAX_OVERLAYS, #dungeonNPCs)
    for npcIndex, npc in ipairs(dungeonNPCs) do
        if CUSTOM_MARKER_DUNGEONS[folder] then
            NPC_MEDIA_FORMATS[folder][npcIndex] = {}
            for _, marker in ipairs(MARKER_OPTIONS) do
                NPC_MEDIA_FORMATS[folder][npcIndex][marker.id] = "|TInterface\\AddOns\\" .. addonName .. "\\Media\\NPCs\\" .. folder .. "\\" .. npc.path .. "\\" .. marker.id .. "\\%s:%d:%d|t"
            end
        else
            NPC_MEDIA_FORMATS[folder][npcIndex] = "|TInterface\\AddOns\\" .. addonName .. "\\Media\\NPCs\\" .. folder .. "\\" .. npc.path .. "\\%s:%d:%d|t"
        end
    end
end
for index, marker in ipairs(TEST_MARKERS) do
    TEST_FORMATS[index] = "|TInterface\\AddOns\\" .. addonName .. "\\Media\\" .. marker .. ":%d:%d|t"
end

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. message)
end

local function Debug(message)
    if db and db.debug then
        Print("|cffaaaaaa[debug]|r " .. message)
    end
end

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            CopyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local function CopyTable(source)
    local copy = {}
    if type(source) ~= "table" then return copy end
    for key, value in pairs(source) do
        copy[key] = type(value) == "table" and CopyTable(value) or value
    end
    return copy
end

local function CreateDefaultConfiguration()
    local configuration = {
        enabledDungeons = {},
        enabledNPCs = {},
        selectedMarkers = {},
    }
    for _, folder in ipairs(DUNGEON_FOLDERS) do
        configuration.enabledDungeons[folder] = true
        configuration.enabledNPCs[folder] = {}
        configuration.selectedMarkers[folder] = {}
        for _, npc in ipairs(NPC_DATABASE[folder]) do
            configuration.enabledNPCs[folder][npc.name] = npc.defaultEnabled ~= false
            configuration.selectedMarkers[folder][npc.name] = npc.marker or "diamond"
        end
    end
    return configuration
end

local function NormalizeConfiguration(configuration)
    if type(configuration.enabledDungeons) ~= "table" then configuration.enabledDungeons = {} end
    if type(configuration.enabledNPCs) ~= "table" then configuration.enabledNPCs = {} end
    if type(configuration.selectedMarkers) ~= "table" then configuration.selectedMarkers = {} end
    for _, folder in ipairs(DUNGEON_FOLDERS) do
        if configuration.enabledDungeons[folder] == nil then configuration.enabledDungeons[folder] = true end
        if type(configuration.enabledNPCs[folder]) ~= "table" then configuration.enabledNPCs[folder] = {} end
        if type(configuration.selectedMarkers[folder]) ~= "table" then configuration.selectedMarkers[folder] = {} end
        for _, npc in ipairs(NPC_DATABASE[folder]) do
            if configuration.enabledNPCs[folder][npc.name] == nil then
                configuration.enabledNPCs[folder][npc.name] = npc.defaultEnabled ~= false
            end
            if not MARKER_OPTION_BY_ID[configuration.selectedMarkers[folder][npc.name]] then
                configuration.selectedMarkers[folder][npc.name] = npc.marker or "diamond"
            end
        end
    end
end

local function InitializeDatabase()
    PriorityMarkerIconsDB = PriorityMarkerIconsDB or {}
    local activeProfile = PriorityMarkerIconsDB.profiles and PriorityMarkerIconsDB.profiles[PriorityMarkerIconsDB.activeProfile]
    if tonumber(PriorityMarkerIconsDB.profileVersion) == 1 and type(activeProfile) == "table" then
        PriorityMarkerIconsDB.enabledDungeons = CopyTable(activeProfile.enabledDungeons)
        PriorityMarkerIconsDB.enabledNPCs = CopyTable(activeProfile.enabledNPCs)
        PriorityMarkerIconsDB.selectedMarkers = CopyTable(activeProfile.selectedMarkers)
    end
    CopyDefaults(PriorityMarkerIconsDB, DEFAULTS)
    db = PriorityMarkerIconsDB
    NormalizeConfiguration(db)
    db.profiles, db.activeProfile, db.profileVersion = nil, nil, nil
    db.npcDefaultsVersion = NPC_DEFAULTS_VERSION
end

local function CreateMarkerButton(name, markerIndex)
    local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    button:RegisterForClicks("AnyUp")
    button:SetAttribute("type", "macro")
    button:SetAttribute("macrotext", string.format("/tm [@mouseover,exists,nodead] %d", markerIndex))
    button:SetSize(1, 1)
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -10, -10)
    button:SetAlpha(0)
    button:Show()
    return button
end

CreateMarkerButton("PriorityMarkerIconsTriangleButton", 4)
CreateMarkerButton("PriorityMarkerIconsSquareButton", 6)

local function GetNameplateAnchor(nameplate)
    local unitFrame = nameplate.UnitFrame or nameplate.unitFrame
    if unitFrame then
        if unitFrame.healthBar then return unitFrame.healthBar, "UnitFrame.healthBar" end
        if unitFrame.HealthBar then return unitFrame.HealthBar, "UnitFrame.HealthBar" end
        if unitFrame.Health then return unitFrame.Health, "UnitFrame.Health" end
    end
    return nameplate, "nameplate"
end

local function GetOverlays(nameplate)
    if overlays[nameplate] then return overlays[nameplate] end
    local markerOverlays = {}
    for index = 1, MAX_OVERLAYS do
        local overlay = nameplate:CreateFontString(nil, "OVERLAY")
        overlay:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        overlay:SetJustifyH("CENTER")
        markerOverlays[index] = overlay
    end
    overlays[nameplate] = markerOverlays
    return markerOverlays
end

local function ClearOverlays(markerOverlays)
    if not markerOverlays then return end
    for _, overlay in ipairs(markerOverlays) do
        overlay:SetText("")
        overlay:Hide()
    end
end

local function IsSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function FindDungeonFolder(instanceName)
    if not instanceName or IsSecret(instanceName) then return nil end
    local aliasedFolder = DUNGEON_ALIASES[instanceName] or instanceName
    for _, folder in ipairs(DUNGEON_FOLDERS) do
        if folder == aliasedFolder then return folder end
    end
end

local function UpdateInstanceContext()
    local inInstance, instanceType = IsInInstance()
    local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo()

    if not inInstance then
        currentDungeonFolder, currentInstanceName, currentInstanceID = nil, nil, nil
        challengeModeActive = false
        Debug("left instance; cached dungeon cleared")
        return
    end

    local nameIsSecret = IsSecret(instanceName)
    local idIsSecret = IsSecret(instanceID)
    if not nameIsSecret then currentInstanceName = instanceName end

    local detectedFolder
    if instanceType == "party" or instanceType == "scenario" then
        detectedFolder = FindDungeonFolder(instanceName)
    end

    if detectedFolder then
        currentDungeonFolder = detectedFolder
        if not idIsSecret then currentInstanceID = instanceID end
        Debug("cached dungeon before challenge mode: " .. detectedFolder)
    elseif currentDungeonFolder then
        -- Once Mythic+ starts, identity-related values may become secret. Keep
        -- the folder detected on entry unless a different readable instance ID
        -- proves that the player moved to another instance.
        if not idIsSecret and currentInstanceID and instanceID ~= currentInstanceID then
            currentDungeonFolder, currentInstanceID = nil, nil
            if nameIsSecret then currentInstanceName = nil end
        else
            Debug("instance identity unavailable; preserving cached folder=" .. currentDungeonFolder)
        end
    end
    Debug(string.format("instance=%s, type=%s, folder=%s", nameIsSecret and "secret" or (currentInstanceName or "unknown"), instanceType or "none", currentDungeonFolder or "unsupported"))
end

local function ShouldDisplay()
    if not db or not db.enabled then return false end
    if db.combatOnly and not UnitAffectingCombat("player") then return false end
    if db.onlyInDungeons and not currentDungeonFolder then return false end
    return true
end

local function UpdateNameplate(unitToken)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)
    if not nameplate then return end
    activeNameplates[unitToken] = nameplate
    local markerOverlays = GetOverlays(nameplate)
    ClearOverlays(markerOverlays)
    if not ShouldDisplay() and not testMode then return end

    local anchor, anchorName = GetNameplateAnchor(nameplate)
    local size = db.iconSize
    if testMode then
        local spacing = size + 2
        local totalWidth = (#TEST_FORMATS - 1) * spacing
        for index, format in ipairs(TEST_FORMATS) do
            local overlay = markerOverlays[index]
            overlay:ClearAllPoints()
            overlay:SetPoint("BOTTOM", anchor, "TOP", (index - 1) * spacing - totalWidth / 2, db.offsetY)
            overlay:SetAlpha(db.alpha)
            overlay:SetFormattedText(format, size, size)
            overlay:Show()
        end
    else
        -- Secret unit names may be formatted into texture paths, but must not
        -- be concatenated, compared, or used as Lua table keys.
        local unitName = UnitName(unitToken)
        if currentDungeonFolder and db.enabledDungeons[currentDungeonFolder] then
            local overlayIndex = 0
            for npcIndex, npc in ipairs(NPC_DATABASE[currentDungeonFolder]) do
                if db.enabledNPCs[currentDungeonFolder][npc.name] then
                    overlayIndex = overlayIndex + 1
                    local overlay = markerOverlays[overlayIndex]
                    overlay:ClearAllPoints()
                    overlay:SetPoint("BOTTOM", anchor, "TOP", 0, db.offsetY)
                    overlay:SetAlpha(db.alpha)
                    local mediaFormat = NPC_MEDIA_FORMATS[currentDungeonFolder][npcIndex]
                    if CUSTOM_MARKER_DUNGEONS[currentDungeonFolder] then
                        local selectedMarker = db.selectedMarkers[currentDungeonFolder][npc.name]
                        mediaFormat = mediaFormat[selectedMarker] or mediaFormat[npc.marker] or mediaFormat.diamond
                    end
                    overlay:SetFormattedText(mediaFormat, unitName, size, size)
                    overlay:Show()
                end
            end
        elseif not currentDungeonFolder and not db.onlyInDungeons then
            -- Outside a detected supported dungeon, retain the legacy folder
            -- fallback. Per-NPC toggles apply once the dungeon is detected.
            for index, folder in ipairs(DUNGEON_FOLDERS) do
                local overlay = markerOverlays[index]
                if db.enabledDungeons[folder] then
                    overlay:ClearAllPoints()
                    overlay:SetPoint("BOTTOM", anchor, "TOP", 0, db.offsetY)
                    overlay:SetAlpha(db.alpha)
                    overlay:SetFormattedText(LEGACY_MEDIA_FORMATS[index], unitName, size, size)
                    overlay:Show()
                end
            end
        end
    end
    Debug(unitToken .. " updated; anchor=" .. anchorName)
end

local function HideNameplate(unitToken)
    local nameplate = activeNameplates[unitToken] or C_NamePlate.GetNamePlateForUnit(unitToken)
    ClearOverlays(nameplate and overlays[nameplate])
    activeNameplates[unitToken] = nil
end

local function RefreshNameplates()
    for i = 1, 40 do
        local unitToken = "nameplate" .. i
        if UnitExists(unitToken) then
            UpdateNameplate(unitToken)
        elseif activeNameplates[unitToken] then
            HideNameplate(unitToken)
        end
    end
end

local function InspectMouseover()
    if not UnitExists("mouseover") then
        Print("there is no unit under the cursor.")
        return
    end
    local guid, name = UnitGUID("mouseover"), UnitName("mouseover")
    local nameplate = C_NamePlate.GetNamePlateForUnit("mouseover")
    local anchorName
    if nameplate then
        local anchor
        anchor, anchorName = GetNameplateAnchor(nameplate)
    end
    local guidIsSecret, nameIsSecret = IsSecret(guid), IsSecret(name)
    if nameIsSecret then
        Print("mouseover name=secret, anchor=" .. (anchorName or "unavailable") .. ".")
        return
    end
    local npcID
    if not guidIsSecret and guid then
        local unitType, _, _, _, _, id = strsplit("-", guid)
        if unitType == "Creature" or unitType == "Vehicle" then npcID = tonumber(id) end
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    Print(string.format("mouseover=%s, npcID=%s, mapID=%s, anchor=%s", name or "unknown", guidIsSecret and "secret" or (npcID and tostring(npcID) or "unavailable"), mapID and tostring(mapID) or "unavailable", anchorName or "unavailable"))
end

local function ShowStatus()
    local visible = 0
    for i = 1, 40 do if UnitExists("nameplate" .. i) then visible = visible + 1 end end
    local mapID = C_Map.GetBestMapForUnit("player")
    Print(string.format("enabled=%s, instance=%s, instanceID=%s, folder=%s, mythicPlus=%s, mapID=%s, nameplates=%d.", tostring(db.enabled), currentInstanceName or "world/secret", currentInstanceID and tostring(currentInstanceID) or "unavailable", currentDungeonFolder or "unsupported/all", tostring(challengeModeActive), mapID and tostring(mapID) or "unavailable", visible))
    Print(string.format("size=%d, offset=%d, alpha=%.2f, dungeonOnly=%s, combatOnly=%s, debug=%s.", db.iconSize, db.offsetY, db.alpha, tostring(db.onlyInDungeons), tostring(db.combatOnly), tostring(db.debug)))
end

local function RefreshSettingsControls()
    for _, control in ipairs(settingsControls) do
        control:RefreshFromDB()
    end
end

local function ClearBulkSelections()
    for _, state in pairs(dungeonPanelStates) do
        wipe(state.selectedNPCs)
    end
end

local MARKER_CODE_BY_ID = {
    star = "1", circle = "2", diamond = "3", triangle = "4",
    moon = "5", square = "6", cross = "7", skull = "8",
}
local MARKER_ID_BY_CODE = {
    ["1"] = "star", ["2"] = "circle", ["3"] = "diamond", ["4"] = "triangle",
    ["5"] = "moon", ["6"] = "square", ["7"] = "cross", ["8"] = "skull",
}

local function SerializeDungeon(folder)
    local enabledBits, markerCodes = {}, {}
    for _, npc in ipairs(NPC_DATABASE[folder]) do
        enabledBits[#enabledBits + 1] = db.enabledNPCs[folder][npc.name] and "1" or "0"
        local selectedMarker = db.selectedMarkers[folder][npc.name]
        if not MARKER_OPTION_BY_ID[selectedMarker] then selectedMarker = npc.marker or "diamond" end
        markerCodes[#markerCodes + 1] = MARKER_CODE_BY_ID[selectedMarker] or "3"
    end
    return table.concat(enabledBits), table.concat(markerCodes)
end

local function ExportDungeon(folder)
    local enabledBits, markerCodes = SerializeDungeon(folder)
    return "PMID3" .. DUNGEON_CODES[folder] .. (db.enabledDungeons[folder] and "1" or "0") .. enabledBits .. markerCodes
end

local function DecodeDungeonImport(serialized)
    serialized = strtrim(serialized or ""):gsub("%s+", ""):upper()

    local folder, dungeonEnabled, enabledBits, markerCodes
    local compactDungeon = serialized:match("PMID3[A-Z][A-Z]%d+")
    if compactDungeon then
        serialized = compactDungeon
        folder = DUNGEON_BY_CODE[serialized:sub(6, 7)]
        local dungeonNPCs = folder and NPC_DATABASE[folder]
        local expectedLength = dungeonNPCs and (8 + #dungeonNPCs * 2) or 0
        if not folder or #serialized ~= expectedLength then return nil, "invalid or incompatible dungeon import string." end
        dungeonEnabled = serialized:sub(8, 8)
        local enabledEnd = 8 + #dungeonNPCs
        enabledBits = serialized:sub(9, enabledEnd)
        markerCodes = serialized:sub(enabledEnd + 1)
    else
        -- Continue accepting dungeon strings from the 1.6.0 test builds.
        local compactLegacy = serialized:match("PMID2%d+")
        if compactLegacy then
            serialized = compactLegacy
            folder = DUNGEON_FOLDERS[tonumber(serialized:sub(6, 6)) or 0]
            local dungeonNPCs = folder and NPC_DATABASE[folder]
            local expectedLength = dungeonNPCs and (7 + #dungeonNPCs * 2) or 0
            if not folder or #serialized ~= expectedLength then return nil, "invalid or incompatible dungeon import string." end
            dungeonEnabled = serialized:sub(7, 7)
            local enabledEnd = 7 + #dungeonNPCs
            enabledBits = serialized:sub(8, enabledEnd)
            markerCodes = serialized:sub(enabledEnd + 1)
        else
            serialized = serialized:gsub("||", "|")
            local parts = { strsplit("|", serialized) }
            if parts[1] ~= "PMID1" or #parts ~= 5 then
                if serialized:match("PMI[12]") then
                    return nil, "profile imports are no longer supported; import a PMID3 dungeon string."
                end
                return nil, "unknown import format. Expected a PMID3 dungeon string."
            end
            folder = DUNGEON_FOLDERS[tonumber(parts[2]) or 0]
            dungeonEnabled, enabledBits, markerCodes = parts[3], parts[4], parts[5]
        end
    end

    local dungeonNPCs = folder and NPC_DATABASE[folder]
    if not dungeonNPCs or (dungeonEnabled ~= "0" and dungeonEnabled ~= "1")
        or #enabledBits ~= #dungeonNPCs or #markerCodes ~= #dungeonNPCs
        or enabledBits:find("[^01]") or markerCodes:find("[^12345678]") then
        return nil, "invalid or incompatible dungeon import string."
    end
    return folder, dungeonEnabled, enabledBits, markerCodes, serialized
end

local function ApplySerializedDungeon(targetProfile, folder, dungeonEnabled, enabledBits, markerCodes)
    local dungeonNPCs = NPC_DATABASE[folder]
    if (dungeonEnabled ~= "0" and dungeonEnabled ~= "1") or #enabledBits ~= #dungeonNPCs or #markerCodes ~= #dungeonNPCs then
        return false
    end
    if enabledBits:find("[^01]") or markerCodes:find("[^12345678]") then return false end

    targetProfile.enabledDungeons[folder] = dungeonEnabled == "1"
    for index, npc in ipairs(dungeonNPCs) do
        targetProfile.enabledNPCs[folder][npc.name] = enabledBits:sub(index, index) == "1"
        targetProfile.selectedMarkers[folder][npc.name] = MARKER_ID_BY_CODE[markerCodes:sub(index, index)]
    end
    return true
end

local function ImportDungeon(serialized)
    local imported = {
        enabledDungeons = CopyTable(db.enabledDungeons),
        enabledNPCs = CopyTable(db.enabledNPCs),
        selectedMarkers = CopyTable(db.selectedMarkers),
    }
    NormalizeConfiguration(imported)

    local folder, decodedValue, enabledBits, markerCodes = DecodeDungeonImport(serialized)
    if not folder then
        Print(decodedValue or "invalid or incompatible dungeon import string.")
        return false
    end
    local dungeonEnabled = decodedValue

    if not folder or not ApplySerializedDungeon(imported, folder, dungeonEnabled, enabledBits, markerCodes) then
        Print("invalid or incompatible dungeon import string.")
        return false
    end

    db.enabledDungeons = imported.enabledDungeons
    db.enabledNPCs = imported.enabledNPCs
    db.selectedMarkers = imported.selectedMarkers
    ClearBulkSelections()
    RefreshSettingsControls()
    RefreshNameplates()
    Print(folder .. " configuration imported.")
    return true
end

local function GetPopupEditBox(dialog)
    return dialog.EditBox or dialog.editBox
end

StaticPopupDialogs.PRIORITYMARKERICONS_EXPORT = {
    text = "Copy the %s dungeon configuration (%s):",
    button1 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 420,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self, data)
        local editBox = GetPopupEditBox(self)
        editBox:SetMaxLetters(4096)
        editBox:SetText(data or "")
        editBox:HighlightText()
        editBox:SetFocus()
    end,
}

StaticPopupDialogs.PRIORITYMARKERICONS_IMPORT = {
    text = "Paste a Priority Marker Icons dungeon string (for example PMID3KR...):",
    button1 = "Import",
    button2 = CANCEL,
    hasEditBox = true,
    editBoxWidth = 420,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        local editBox = GetPopupEditBox(self)
        editBox:SetMaxLetters(4096)
        editBox:SetText("")
        editBox:SetFocus()
    end,
    OnAccept = function(self)
        ImportDungeon(GetPopupEditBox(self):GetText())
    end,
    EditBoxOnEnterPressed = function(editBox)
        ImportDungeon(editBox:GetText())
        editBox:GetParent():Hide()
    end,
}

StaticPopupDialogs.PRIORITYMARKERICONS_SHARE_IMPORT = {
    text = "Import shared marks for %s?\n\nThis will replace your current configuration for this dungeon.",
    button1 = "Import",
    button2 = CANCEL,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function(_, data)
        ImportDungeon(data)
    end,
}

local function ShowExportDialog(folder)
    local displayName = folder == "Kings Rest" and "King's Rest" or folder
    StaticPopup_Show("PRIORITYMARKERICONS_EXPORT", displayName, DUNGEON_CODES[folder], ExportDungeon(folder))
end

local function ShowImportDialog()
    StaticPopup_Show("PRIORITYMARKERICONS_IMPORT")
end

local function FindDungeonFromArgument(argument)
    argument = strtrim(argument or "")
    if argument == "" then return currentDungeonFolder end
    local byCode = DUNGEON_BY_CODE[argument:upper()]
    if byCode then return byCode end
    for _, folder in ipairs(DUNGEON_FOLDERS) do
        local displayName = folder == "Kings Rest" and "King's Rest" or folder
        if argument:lower() == folder:lower() or argument:lower() == displayName:lower() then return folder end
    end
end

local function CreateSharedMarksHyperlink(folder, payload)
    local displayName = folder == "Kings Rest" and "King's Rest" or folder
    return "|Haddon:prioritymarkericons:" .. payload .. "|h|cff33ff99[PMI: Marks for " .. displayName .. "]|r|h"
end

local function ShareDungeonMarks(folder)
    if not folder or not NPC_DATABASE[folder] then
        Print("choose a dungeon in settings or use /pmi share KR. Codes: KR, DN, MR, BV, VA, AF, RL, TS.")
        return
    end
    local payload = ExportDungeon(folder)
    -- WoW does not transmit custom addon hyperlinks through normal chat. Send a
    -- plain token and convert it into a local clickable link in the chat filter.
    local message = "[PMI Marks for " .. DUNGEON_CODES[folder] .. ": " .. payload .. "]"
    if ChatFrame_OpenChat then
        ChatFrame_OpenChat(message)
    else
        Print("could not open the chat edit box.")
    end
end

local shareLinksRegistered = false
local function HandleSharedMarksLink(link)
    local payload = link and link:match("^addon:prioritymarkericons:(PMID3[A-Z][A-Z]%d+)$")
    if not payload then return end
    local folder, errorMessage = DecodeDungeonImport(payload)
    if not folder then
        Print(errorMessage or "invalid or incompatible shared marks link.")
        return
    end
    local displayName = folder == "Kings Rest" and "King's Rest" or folder
    StaticPopup_Show("PRIORITYMARKERICONS_SHARE_IMPORT", displayName, nil, payload)
end

local function FilterSharedMarksLinks(_, _, message, ...)
    if type(message) ~= "string" then return end
    local replaced = false
    local filteredMessage = message:gsub("%[PMI Marks for ([A-Z][A-Z]): (PMID3[A-Z][A-Z]%d+)%]", function(code, payload)
        local folder = DUNGEON_BY_CODE[code]
        local decodedFolder = DecodeDungeonImport(payload)
        if not folder or decodedFolder ~= folder then
            return "[PMI Marks for " .. code .. ": " .. payload .. "]"
        end
        replaced = true
        return CreateSharedMarksHyperlink(folder, payload)
    end)
    if replaced then return false, filteredMessage, ... end
end

local function RegisterShareLinks()
    if shareLinksRegistered then return end
    shareLinksRegistered = true
    if EventRegistry and EventRegistry.RegisterCallback then
        EventRegistry:RegisterCallback("SetItemRef", function(_, link)
            HandleSharedMarksLink(link)
        end)
    elseif hooksecurefunc then
        hooksecurefunc("SetItemRef", function(link)
            HandleSharedMarksLink(link)
        end)
    end

    local addMessageFilter = ChatFrame_AddMessageEventFilter or (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter)
    if addMessageFilter then
        local chatEvents = {
            "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
            "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_INSTANCE_CHAT",
            "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
            "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_CHANNEL",
        }
        for _, event in ipairs(chatEvents) do
            addMessageFilter(event, FilterSharedMarksLinks)
        end
    end
end

local function ResetSettings()
    wipe(PriorityMarkerIconsDB)
    db = nil
    InitializeDatabase()
    ClearBulkSelections()
    UpdateInstanceContext()
    RefreshNameplates()
    UpdateMinimapButtonPosition()
    UpdateMinimapButtonVisibility()
    RefreshSettingsControls()
    Print("settings restored to defaults.")
end

local function SetNumericSetting(key, value, minimum, maximum, label)
    value = tonumber(value)
    if not value then
        Print(label .. " requires a number between " .. minimum .. " and " .. maximum .. ".")
        return
    end
    db[key] = math.max(minimum, math.min(maximum, value))
    RefreshNameplates()
    RefreshSettingsControls()
    Print(label .. " set to " .. string.format(key == "alpha" and "%.2f" or "%d", db[key]) .. ".")
end

local function OpenSettings()
    if settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory("Priority Marker Icons")
    else
        Print("the settings panel is unavailable; use /pmi for commands.")
    end
end

UpdateMinimapButtonPosition = function()
    if not minimapButton or not db then return end
    local angle = math.rad(db.minimap.angle or 220)
    -- Derive the radius from the current minimap size so UI replacements and
    -- minimap scaling keep the button on the outer rim instead of inside it.
    local radiusX = (Minimap:GetWidth() / 2) + 6
    local radiusY = (Minimap:GetHeight() / 2) + 6
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radiusX, math.sin(angle) * radiusY)
end

UpdateMinimapButtonVisibility = function()
    if not minimapButton or not db then return end
    if db.minimap.hide then minimapButton:Hide() else minimapButton:Show() end
end

local function UpdateMinimapButtonDrag()
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local centerX, centerY = Minimap:GetCenter()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    db.minimap.angle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX)) % 360
    UpdateMinimapButtonPosition()
end

local function CreateMinimapButton()
    local button = CreateFrame("Button", "PriorityMarkerIconsMinimapButton", Minimap)
    minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Media\\_diamond.tga")

    local initials = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    initials:SetPoint("CENTER", 0, 0)
    initials:SetText("PMI")
    initials:SetTextColor(1, 0.82, 0)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    button:SetScript("OnClick", OpenSettings)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", UpdateMinimapButtonDrag)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Priority Marker Icons")
        GameTooltip:AddLine("Click to open addon options.", 1, 1, 1)
        GameTooltip:AddLine("Drag to move the PMI button.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    Minimap:HookScript("OnSizeChanged", UpdateMinimapButtonPosition)
    UpdateMinimapButtonPosition()
    UpdateMinimapButtonVisibility()
end

local function ShowHelp()
    Print("commands: /pmi test, status, inspect, options, on, off, reset.")
    Print("sharing: /pmi share KR, /pmi export KR, /pmi import.")
    Print("appearance: /pmi size 36, /pmi offset 6, /pmi alpha 1.")
    Print("filters: /pmi dungeononly, /pmi combatonly, /pmi minimap, /pmi debug.")
end

local function ToggleSetting(key, label)
    db[key] = not db[key]
    Print(label .. " " .. (db[key] and "enabled" or "disabled") .. ".")
    RefreshNameplates()
    RefreshSettingsControls()
end

local function AddCheckboxLabel(checkbox, label, description)
    local text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    text:SetText(label)
    checkbox:SetHitRectInsets(0, -text:GetStringWidth() - 6, 0, 0)
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(label)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    checkbox:SetScript("OnLeave", GameTooltip_Hide)
end

local function CreateCheckbox(parent, name, label, description, x, y, key)
    local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("TOPLEFT", x, y)
    AddCheckboxLabel(checkbox, label, description)
    function checkbox:RefreshFromDB() self:SetChecked(db and db[key]) end
    checkbox:SetScript("OnShow", checkbox.RefreshFromDB)
    checkbox:SetScript("OnClick", function(self)
        db[key] = self:GetChecked() and true or false
        RefreshNameplates()
    end)
    settingsControls[#settingsControls + 1] = checkbox
    checkbox:RefreshFromDB()
    return checkbox
end

local function CreateDungeonCheckbox(parent, name, label, x, y, folder)
    local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("TOPLEFT", x, y)
    AddCheckboxLabel(checkbox, label, "Enable automatic markers for this dungeon.")
    function checkbox:RefreshFromDB()
        self:SetChecked(db and db.enabledDungeons[folder])
    end
    checkbox:SetScript("OnShow", checkbox.RefreshFromDB)
    checkbox:SetScript("OnClick", function(self)
        db.enabledDungeons[folder] = self:GetChecked() and true or false
        RefreshNameplates()
    end)
    settingsControls[#settingsControls + 1] = checkbox
    checkbox:RefreshFromDB()
    return checkbox
end

local function SetAllNPCMarkers(folder, enabled)
    for _, npc in ipairs(NPC_DATABASE[folder]) do
        db.enabledNPCs[folder][npc.name] = enabled
    end
    RefreshSettingsControls()
    RefreshNameplates()
end

local function GetSelectedMarker(folder, npc)
    local selectedMarker = db.selectedMarkers[folder][npc.name]
    if MARKER_OPTION_BY_ID[selectedMarker] then return selectedMarker end
    return npc.marker or "diamond"
end

local function SetSelectedMarker(folder, npc, markerID)
    if not MARKER_OPTION_BY_ID[markerID] then return end
    db.selectedMarkers[folder][npc.name] = markerID
    RefreshSettingsControls()
    RefreshNameplates()
end

local function OpenOptionMenu(owner, title, options, currentID, onSelect)
    if MenuUtil and MenuUtil.CreateContextMenu then
        MenuUtil.CreateContextMenu(owner, function(_, rootDescription)
            rootDescription:CreateTitle(title)
            for _, option in ipairs(options) do
                local menuOption = option
                local icon = menuOption.texture and ("|TInterface\\AddOns\\" .. addonName .. "\\Media\\" .. menuOption.texture .. ".tga:18:18|t ") or ""
                local prefix = currentID == menuOption.id and "|cff33ff99> |r" or ""
                rootDescription:CreateButton(prefix .. icon .. menuOption.label, function()
                    onSelect(menuOption.id)
                end)
            end
        end)
        return
    end

    for index, option in ipairs(options) do
        if option.id == currentID then
            onSelect(options[index % #options + 1].id)
            return
        end
    end
    if options[1] then onSelect(options[1].id) end
end

local function OpenMarkerMenu(owner, folder, npc)
    OpenOptionMenu(owner, npc.name, MARKER_OPTIONS, GetSelectedMarker(folder, npc), function(markerID)
        SetSelectedMarker(folder, npc, markerID)
    end)
end

local function ResetDungeon(folder)
    local defaults = CreateDefaultConfiguration()
    db.enabledDungeons[folder] = true
    db.enabledNPCs[folder] = CopyTable(defaults.enabledNPCs[folder])
    db.selectedMarkers[folder] = CopyTable(defaults.selectedMarkers[folder])
    RefreshSettingsControls()
    RefreshNameplates()
    Print(folder .. " restored to defaults.")
end

local function CreateNPCMarkerRow(parent, folderIndex, npcIndex, folder, npc, state)
    local name = "PriorityMarkerIconsNPC" .. folderIndex .. "_" .. npcIndex
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(540, 30)
    row.npc = npc

    local selection = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    selection:SetSize(24, 24)
    selection:SetPoint("LEFT", 0, 0)
    selection:SetScript("OnClick", function(self)
        state.selectedNPCs[npc.name] = self:GetChecked() and true or nil
        state:RefreshFromDB()
    end)
    selection:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Select " .. npc.name)
        GameTooltip:AddLine("Include this NPC in the next bulk marker assignment.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    selection:SetScript("OnLeave", GameTooltip_Hide)

    local checkbox = CreateFrame("CheckButton", name, row, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("LEFT", 30, 0)

    local selector = CreateFrame("Button", name .. "MarkerSelector", row, "UIPanelButtonTemplate")
    selector:SetSize(54, 26)
    selector:SetPoint("LEFT", 60, 0)
    local selectorIcon = selector:CreateTexture(nil, "ARTWORK")
    selectorIcon:SetSize(20, 20)
    selectorIcon:SetPoint("LEFT", 5, 0)
    local arrow = selector:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    arrow:SetPoint("RIGHT", -7, 0)
    arrow:SetText("v")
    selector:SetScript("OnClick", function(self) OpenMarkerMenu(self, folder, npc) end)
    selector:SetScript("OnEnter", function(self)
        local marker = MARKER_OPTION_BY_ID[GetSelectedMarker(folder, npc)]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(npc.name .. ": " .. marker.label)
        GameTooltip:AddLine("Click to choose a different local marker.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    selector:SetScript("OnLeave", GameTooltip_Hide)

    local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", selector, "RIGHT", 8, 0)
    label:SetText(npc.name)
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(npc.name)
        GameTooltip:AddLine("Show or hide this NPC's local priority marker.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    checkbox:SetScript("OnLeave", GameTooltip_Hide)
    checkbox:SetScript("OnClick", function(self)
        db.enabledNPCs[folder][npc.name] = self:GetChecked() and true or false
        RefreshSettingsControls()
        RefreshNameplates()
    end)
    function row:RefreshFromDB()
        if not db then return end
        selection:SetChecked(state.selectedNPCs[npc.name])
        checkbox:SetChecked(db.enabledNPCs[folder][npc.name])
        local marker = MARKER_OPTION_BY_ID[GetSelectedMarker(folder, npc)]
        selectorIcon:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Media\\" .. marker.texture .. ".tga")
    end
    settingsControls[#settingsControls + 1] = row
    row:RefreshFromDB()
    return row
end

local function CreateNPCSettingsPanels(parentCategory)
    for folderIndex, folder in ipairs(DUNGEON_FOLDERS) do
        local panelFolder = folder
        local panel = CreateFrame("Frame", "PriorityMarkerIconsNPCPanel" .. folderIndex)
        local displayName = panelFolder == "Kings Rest" and "King's Rest" or panelFolder
        panel.name = displayName .. " NPCs"

        local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetText(displayName .. " NPC markers")
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        description:SetText("Search, filter, select, enable, and assign local markers for this dungeon.")

        local state = {
            folder = panelFolder,
            rows = {},
            selectedNPCs = {},
            searchText = "",
            visibilityFilter = "all",
            markerFilter = "all",
        }
        dungeonPanelStates[panelFolder] = state

        local enableAll = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        enableAll:SetSize(78, 24)
        enableAll:SetPoint("TOPLEFT", 16, -58)
        enableAll:SetText("Enable all")
        enableAll:SetScript("OnClick", function() SetAllNPCMarkers(panelFolder, true) end)

        local disableAll = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        disableAll:SetSize(78, 24)
        disableAll:SetPoint("LEFT", enableAll, "RIGHT", 6, 0)
        disableAll:SetText("Disable all")
        disableAll:SetScript("OnClick", function() SetAllNPCMarkers(panelFolder, false) end)

        local resetDungeon = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        resetDungeon:SetSize(88, 24)
        resetDungeon:SetPoint("LEFT", disableAll, "RIGHT", 6, 0)
        resetDungeon:SetText("Reset")
        resetDungeon:SetScript("OnClick", function()
            wipe(state.selectedNPCs)
            ResetDungeon(panelFolder)
        end)

        local exportDungeon = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        exportDungeon:SetSize(65, 24)
        exportDungeon:SetPoint("LEFT", resetDungeon, "RIGHT", 6, 0)
        exportDungeon:SetText("Export")
        exportDungeon:SetScript("OnClick", function() ShowExportDialog(panelFolder) end)

        local importDungeon = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        importDungeon:SetSize(65, 24)
        importDungeon:SetPoint("LEFT", exportDungeon, "RIGHT", 6, 0)
        importDungeon:SetText("Import")
        importDungeon:SetScript("OnClick", ShowImportDialog)

        local shareDungeon = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        shareDungeon:SetSize(104, 24)
        shareDungeon:SetPoint("LEFT", importDungeon, "RIGHT", 6, 0)
        shareDungeon:SetText("Share Marks")
        shareDungeon:SetScript("OnClick", function() ShareDungeonMarks(panelFolder) end)

        local search = CreateFrame("EditBox", "PriorityMarkerIconsSearch" .. folderIndex, panel, "InputBoxTemplate")
        search:SetSize(205, 24)
        search:SetPoint("TOPLEFT", 20, -92)
        search:SetAutoFocus(false)
        search:SetMaxLetters(60)
        local searchHint = search:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        searchHint:SetPoint("LEFT", 6, 0)
        searchHint:SetText("Search NPC...")
        search:SetScript("OnTextChanged", function(self)
            state.searchText = self:GetText():lower()
            searchHint:SetShown(self:GetText() == "")
            state:RefreshFromDB()
        end)
        search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

        local visibilityOptions = {
            { id = "all", label = "All NPCs" },
            { id = "enabled", label = "Enabled only" },
            { id = "disabled", label = "Disabled only" },
        }
        local visibilityButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        visibilityButton:SetSize(130, 24)
        visibilityButton:SetPoint("LEFT", search, "RIGHT", 12, 0)
        visibilityButton:SetScript("OnClick", function(self)
            OpenOptionMenu(self, "Visibility filter", visibilityOptions, state.visibilityFilter, function(filterID)
                state.visibilityFilter = filterID
                state:RefreshFromDB()
            end)
        end)

        local markerFilterOptions = { { id = "all", label = "All markers" } }
        for _, marker in ipairs(MARKER_OPTIONS) do markerFilterOptions[#markerFilterOptions + 1] = marker end
        local markerFilterButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        markerFilterButton:SetSize(130, 24)
        markerFilterButton:SetPoint("LEFT", visibilityButton, "RIGHT", 8, 0)
        markerFilterButton:SetScript("OnClick", function(self)
            OpenOptionMenu(self, "Marker filter", markerFilterOptions, state.markerFilter, function(markerID)
                state.markerFilter = markerID
                state:RefreshFromDB()
            end)
        end)

        local selectVisible = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        selectVisible:SetSize(105, 24)
        selectVisible:SetPoint("TOPLEFT", 16, -126)
        selectVisible:SetText("Select visible")
        selectVisible:SetScript("OnClick", function()
            for _, row in ipairs(state.rows) do
                if row:IsShown() then state.selectedNPCs[row.npc.name] = true end
            end
            state:RefreshFromDB()
        end)

        local clearSelection = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        clearSelection:SetSize(105, 24)
        clearSelection:SetPoint("LEFT", selectVisible, "RIGHT", 8, 0)
        clearSelection:SetText("Clear selection")
        clearSelection:SetScript("OnClick", function()
            wipe(state.selectedNPCs)
            state:RefreshFromDB()
        end)

        local bulkMarker = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        bulkMarker:SetSize(150, 24)
        bulkMarker:SetPoint("LEFT", clearSelection, "RIGHT", 8, 0)
        bulkMarker:SetText("Assign selected...")
        bulkMarker:SetScript("OnClick", function(self)
            OpenOptionMenu(self, "Assign marker to selected NPCs", MARKER_OPTIONS, nil, function(markerID)
                local changed = 0
                for _, npc in ipairs(NPC_DATABASE[panelFolder]) do
                    if state.selectedNPCs[npc.name] then
                        db.selectedMarkers[panelFolder][npc.name] = markerID
                        changed = changed + 1
                    end
                end
                if changed == 0 then
                    Print("select at least one NPC first.")
                    return
                end
                RefreshSettingsControls()
                RefreshNameplates()
                Print(string.format("%d NPC marker(s) changed in %s.", changed, panelFolder))
            end)
        end)

        local summary = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        summary:SetPoint("TOPLEFT", 16, -160)
        summary:SetWidth(550)
        summary:SetHeight(50)
        summary:SetJustifyH("LEFT")
        summary:SetJustifyV("TOP")

        local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", 17, -211)
        header:SetText("Select       On       Marker          NPC")

        local scrollFrame = CreateFrame("ScrollFrame", "PriorityMarkerIconsNPCScroll" .. folderIndex, panel, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 16, -226)
        scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(560, math.max(1, #NPC_DATABASE[panelFolder] * 32))
        scrollFrame:SetScrollChild(scrollChild)

        for npcIndex, npc in ipairs(NPC_DATABASE[panelFolder]) do
            state.rows[#state.rows + 1] = CreateNPCMarkerRow(scrollChild, folderIndex, npcIndex, panelFolder, npc, state)
        end

        function state:RefreshFromDB()
            if not db then return end
            local enabledCount, selectedCount, visibleCount = 0, 0, 0
            local markerCounts = {}
            for _, marker in ipairs(MARKER_OPTIONS) do markerCounts[marker.id] = 0 end
            for _, npc in ipairs(NPC_DATABASE[panelFolder]) do
                if db.enabledNPCs[panelFolder][npc.name] then
                    enabledCount = enabledCount + 1
                    markerCounts[GetSelectedMarker(panelFolder, npc)] = markerCounts[GetSelectedMarker(panelFolder, npc)] + 1
                end
                if state.selectedNPCs[npc.name] then selectedCount = selectedCount + 1 end
            end

            for _, row in ipairs(state.rows) do
                local npc = row.npc
                local enabled = db.enabledNPCs[panelFolder][npc.name]
                local markerID = GetSelectedMarker(panelFolder, npc)
                local matchesSearch = state.searchText == "" or npc.name:lower():find(state.searchText, 1, true)
                local matchesVisibility = state.visibilityFilter == "all" or (state.visibilityFilter == "enabled" and enabled) or (state.visibilityFilter == "disabled" and not enabled)
                local matchesMarker = state.markerFilter == "all" or state.markerFilter == markerID
                if matchesSearch and matchesVisibility and matchesMarker then
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", 4, -visibleCount * 32)
                    row:Show()
                    visibleCount = visibleCount + 1
                else
                    row:Hide()
                end
                row:RefreshFromDB()
            end
            scrollChild:SetHeight(math.max(1, visibleCount * 32))

            local markerSummary, busiestMarker, busiestCount = {}, nil, 0
            for _, marker in ipairs(MARKER_OPTIONS) do
                markerSummary[#markerSummary + 1] = marker.label .. " " .. markerCounts[marker.id]
                if markerCounts[marker.id] > busiestCount then
                    busiestMarker, busiestCount = marker.label, markerCounts[marker.id]
                end
            end
            local summaryText = string.format("Enabled %d/%d  |  Visible %d  |  Selected %d\n%s", enabledCount, #NPC_DATABASE[panelFolder], visibleCount, selectedCount, table.concat(markerSummary, "  "))
            if busiestCount >= 5 then
                summaryText = summaryText .. string.format("\n|cffffcc00Notice: %d enabled NPCs use %s.|r", busiestCount, busiestMarker)
            end
            summary:SetText(summaryText)
            visibilityButton:SetText(state.visibilityFilter == "all" and "All NPCs" or (state.visibilityFilter == "enabled" and "Enabled only" or "Disabled only"))
            local markerFilter = MARKER_OPTION_BY_ID[state.markerFilter]
            markerFilterButton:SetText(markerFilter and markerFilter.label or "All markers")
        end
        settingsControls[#settingsControls + 1] = state
        state:RefreshFromDB()

        if Settings and Settings.RegisterCanvasLayoutSubcategory and parentCategory then
            Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel, displayName)
        elseif InterfaceOptions_AddCategory then
            panel.parent = "Priority Marker Icons"
            InterfaceOptions_AddCategory(panel)
        end
    end
end

local function CreateMinimapCheckbox(parent, x, y)
    local checkbox = CreateFrame("CheckButton", "PriorityMarkerIconsMinimapCheck", parent, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("TOPLEFT", x, y)
    AddCheckboxLabel(checkbox, "Show minimap button", "Show the draggable PMI shortcut on the minimap.")
    function checkbox:RefreshFromDB() self:SetChecked(db and not db.minimap.hide) end
    checkbox:SetScript("OnShow", checkbox.RefreshFromDB)
    checkbox:SetScript("OnClick", function(self)
        db.minimap.hide = not self:GetChecked()
        UpdateMinimapButtonVisibility()
    end)
    settingsControls[#settingsControls + 1] = checkbox
    checkbox:RefreshFromDB()
    return checkbox
end

local function CreateSlider(parent, name, label, x, y, key, minimum, maximum, step)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(220)
    _G[name .. "Text"]:SetText(label)
    _G[name .. "Low"]:SetText(tostring(minimum))
    _G[name .. "High"]:SetText(tostring(maximum))
    function slider:RefreshFromDB() self:SetValue(db and db[key] or minimum) end
    slider:SetScript("OnShow", slider.RefreshFromDB)
    slider:SetScript("OnValueChanged", function(_, value)
        if not db then return end
        if step >= 1 then value = math.floor(value + 0.5) end
        db[key] = value
        _G[name .. "Text"]:SetText(label .. ": " .. string.format(step < 1 and "%.2f" or "%d", value))
        RefreshNameplates()
    end)
    settingsControls[#settingsControls + 1] = slider
    slider:RefreshFromDB()
    return slider
end

local function CreateSettingsPanel()
    local panel = CreateFrame("Frame", "PriorityMarkerIconsSettingsPanel")
    panel.name = "Priority Marker Icons"
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Priority Marker Icons")
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Local priority icons above enemy nameplates")
    CreateCheckbox(panel, "PriorityMarkerIconsEnabledCheck", "Enable addon", "Show configured local markers.", 16, -64, "enabled")
    CreateCheckbox(panel, "PriorityMarkerIconsDungeonCheck", "Only in supported dungeons", "Avoid scanning all texture folders outside supported dungeons.", 16, -96, "onlyInDungeons")
    CreateCheckbox(panel, "PriorityMarkerIconsCombatCheck", "Only in combat", "Hide automatic markers while out of combat.", 16, -128, "combatOnly")
    CreateCheckbox(panel, "PriorityMarkerIconsDebugCheck", "Debug messages", "Print nameplate and instance diagnostics.", 16, -160, "debug")
    CreateMinimapCheckbox(panel, 16, -192)
    CreateSlider(panel, "PriorityMarkerIconsSizeSlider", "Icon size", 32, -250, "iconSize", 16, 64, 1)
    CreateSlider(panel, "PriorityMarkerIconsOffsetSlider", "Vertical offset", 32, -315, "offsetY", -20, 60, 1)
    CreateSlider(panel, "PriorityMarkerIconsAlphaSlider", "Opacity", 32, -380, "alpha", 0.2, 1, 0.05)
    local dungeonTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dungeonTitle:SetPoint("TOPLEFT", 330, -64)
    dungeonTitle:SetText("Enabled dungeons")
    for index, folder in ipairs(DUNGEON_FOLDERS) do
        local displayName = folder == "Kings Rest" and "King's Rest" or folder
        CreateDungeonCheckbox(panel, "PriorityMarkerIconsDungeon" .. index, displayName, 330, -72 - index * 32, folder)
    end
    local npcHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    npcHint:SetPoint("TOPLEFT", 330, -365)
    npcHint:SetWidth(280)
    npcHint:SetJustifyH("LEFT")
    npcHint:SetText("Expand Priority Marker Icons in the left navigation to configure individual NPC markers.")
    local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reset:SetSize(150, 24)
    reset:SetPoint("TOPLEFT", 16, -435)
    reset:SetText("Reset defaults")
    reset:SetScript("OnClick", ResetSettings)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(settingsCategory)
        CreateNPCSettingsPanels(settingsCategory)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        CreateNPCSettingsPanels(nil)
    end
end

SLASH_PRIORITYMARKERICONS1 = "/prioritymarkericons"
SLASH_PRIORITYMARKERICONS2 = "/pmi"
SLASH_PRIORITYMARKERICONS3 = "/automarker"
SLASH_PRIORITYMARKERICONS4 = "/am"
SlashCmdList.PRIORITYMARKERICONS = function(message)
    local command, argument = strsplit(" ", strtrim(message or ""), 2)
    command, argument = (command or ""):lower(), strtrim(argument or "")
    if command == "inspect" or command == "id" then InspectMouseover()
    elseif command == "test" then
        testMode = not testMode
        Print("test mode " .. (testMode and "enabled" or "disabled") .. ".")
        RefreshNameplates()
    elseif command == "status" then ShowStatus()
    elseif command == "options" or command == "config" then OpenSettings()
    elseif command == "on" then db.enabled = true; RefreshNameplates(); RefreshSettingsControls(); Print("enabled.")
    elseif command == "off" then db.enabled = false; RefreshNameplates(); RefreshSettingsControls(); Print("disabled.")
    elseif command == "size" then SetNumericSetting("iconSize", argument, 16, 64, "icon size")
    elseif command == "offset" then SetNumericSetting("offsetY", argument, -20, 60, "vertical offset")
    elseif command == "alpha" then SetNumericSetting("alpha", argument, 0.2, 1, "opacity")
    elseif command == "dungeononly" then ToggleSetting("onlyInDungeons", "dungeon-only mode")
    elseif command == "combatonly" then ToggleSetting("combatOnly", "combat-only mode")
    elseif command == "minimap" then
        db.minimap.hide = not db.minimap.hide
        UpdateMinimapButtonVisibility()
        RefreshSettingsControls()
        Print("minimap button " .. (db.minimap.hide and "hidden" or "shown") .. ".")
    elseif command == "debug" then ToggleSetting("debug", "debug mode")
    elseif command == "export" then
        local exportFolder = FindDungeonFromArgument(argument)
        if exportFolder then ShowExportDialog(exportFolder)
        else Print("choose a dungeon in settings or use /pmi export KR. Codes: KR, DN, MR, BV, VA, AF, RL, TS.") end
    elseif command == "import" then ShowImportDialog()
    elseif command == "share" then ShareDungeonMarks(FindDungeonFromArgument(argument))
    elseif command == "reset" then ResetSettings()
    else ShowHelp() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("CHALLENGE_MODE_START")
events:SetScript("OnEvent", function(_, event, unitToken)
    if event == "ADDON_LOADED" and unitToken == addonName then
        InitializeDatabase()
        RegisterShareLinks()
        CreateMinimapButton()
        CreateSettingsPanel()
    elseif event == "PLAYER_LOGIN" then
        UpdateInstanceContext()
        UpdateMinimapButtonPosition()
        Print("loaded. Type /pmi for instructions.")
        C_Timer.NewTicker(3, RefreshNameplates)
    elseif event == "NAME_PLATE_UNIT_ADDED" then UpdateNameplate(unitToken)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then HideNameplate(unitToken)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        UpdateInstanceContext()
        UpdateMinimapButtonPosition()
        C_Timer.After(1, RefreshNameplates)
    elseif event == "CHALLENGE_MODE_START" then
        challengeModeActive = true
        Debug("Mythic+ started; using cached folder=" .. (currentDungeonFolder or "unavailable"))
        RefreshNameplates()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        if db.combatOnly then RefreshNameplates() end
    end
end)
