local addonName = ...

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
local DEFAULTS = {
    enabled = true,
    onlyInDungeons = true,
    combatOnly = false,
    iconSize = 36,
    offsetY = 6,
    alpha = 1,
    debug = false,
    enabledDungeons = {},
    minimap = {
        hide = false,
        angle = 220,
    },
}
local MEDIA_FORMATS, TEST_FORMATS = {}, {}
local overlays, activeNameplates = {}, {}
local settingsControls = {}
local testMode = false
local challengeModeActive = false
local currentDungeonFolder, currentInstanceName, currentInstanceID, settingsCategory, db
local minimapButton
local UpdateMinimapButtonPosition, UpdateMinimapButtonVisibility

for index, folder in ipairs(DUNGEON_FOLDERS) do
    MEDIA_FORMATS[index] = "|TInterface\\AddOns\\" .. addonName .. "\\Media\\" .. folder .. "\\%s:%d:%d|t"
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

local function InitializeDatabase()
    PriorityMarkerIconsDB = PriorityMarkerIconsDB or {}
    CopyDefaults(PriorityMarkerIconsDB, DEFAULTS)
    db = PriorityMarkerIconsDB
    for _, folder in ipairs(DUNGEON_FOLDERS) do
        if db.enabledDungeons[folder] == nil then db.enabledDungeons[folder] = true end
    end
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
    for index = 1, #MEDIA_FORMATS do
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
        local totalWidth = (#markerOverlays - 1) * spacing
        for index, overlay in ipairs(markerOverlays) do
            overlay:ClearAllPoints()
            overlay:SetPoint("BOTTOM", anchor, "TOP", (index - 1) * spacing - totalWidth / 2, db.offsetY)
            overlay:SetAlpha(db.alpha)
            overlay:SetFormattedText(TEST_FORMATS[index], size, size)
            overlay:Show()
        end
    else
        -- Secret unit names may be formatted into texture paths, but must not
        -- be concatenated, compared, or used as Lua table keys.
        local unitName = UnitName(unitToken)
        for index, overlay in ipairs(markerOverlays) do
            local folder = DUNGEON_FOLDERS[index]
            if db.enabledDungeons[folder] and (not currentDungeonFolder or folder == currentDungeonFolder) then
                overlay:ClearAllPoints()
                overlay:SetPoint("BOTTOM", anchor, "TOP", 0, db.offsetY)
                overlay:SetAlpha(db.alpha)
                overlay:SetFormattedText(MEDIA_FORMATS[index], unitName, size, size)
                overlay:Show()
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

local function ResetSettings()
    wipe(PriorityMarkerIconsDB)
    CopyDefaults(PriorityMarkerIconsDB, DEFAULTS)
    db = PriorityMarkerIconsDB
    for _, folder in ipairs(DUNGEON_FOLDERS) do db.enabledDungeons[folder] = true end
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
    local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reset:SetSize(150, 24)
    reset:SetPoint("TOPLEFT", 16, -435)
    reset:SetText("Reset defaults")
    reset:SetScript("OnClick", ResetSettings)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(settingsCategory)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
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
