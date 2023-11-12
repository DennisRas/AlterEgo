---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.Libs = {}
AlterEgo.Libs.AceDB = LibStub:GetLibrary("AceDB-3.0")
AlterEgo.Libs.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
AlterEgo.Libs.LDBIcon = LibStub("LibDBIcon-1.0")

local defaultDB = {
    global = {
        dbVersion = 1,
        weeklyReset = 0,
        characters = {},
        minimap = {
            minimapPos = 195,
            hide = false,
            lock = false
        },
        sorting = "lastUpdate",
        showTiers = true,
        showAffixColors = false,
        showZeroRatedCharacters = true,
        raids = {
            enabled = false,
            colors = false,
            currentTierOnly = true,
            lfr = true,
            normal = true,
            heroic = true,
            mythic = true,
            boxes = false
        }
    }
}

local libDataObject = {
    label = "AlterEgo",
    tocname = "AlterEgo",
    type = "launcher",
    icon = "Interface/AddOns/AlterEgo/Media/Logo.blp",
    OnClick = function()
        AlterEgo:ToggleWindow()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText("AlterEgo", 1, 1, 1)
        tooltip:AddLine("Click to show the character summary.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        local dragText = "Drag to move this icon"
        if AlterEgo.db.global.minimap.lock then
            dragText = dragText .. " |cffff0000(locked)|r"
        end
        tooltip:AddLine(dragText .. ".", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end
}

function AlterEgo:OnInitialize()
    self.db = self.Libs.AceDB:New("AlterEgoDB", defaultDB, true)
    self.Libs.LDB:NewDataObject("AlterEgo", libDataObject)
    self.Libs.LDBIcon:Register("AlterEgo", libDataObject, self.db.global.minimap)
    self:RegisterChatCommand("ae", "ToggleWindow")
    self:RegisterChatCommand("alterego", "ToggleWindow")
end

function AlterEgo:OnEnable()
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 2, function()
        self:UpdateCharacterInfo()
        self:UpdateKeystoneItem()
    end)
    self:RegisterBucketEvent({"RAID_INSTANCE_WELCOME", "LFG_LOCK_INFO_RECEIVED", "BOSS_KILL"}, 2, RequestRaidInfo)
    self:RegisterEvent("ENCOUNTER_END", "OnEncounterEnd")
    self:RegisterEvent("WEEKLY_REWARDS_UPDATE", "UpdateVault")
    self:RegisterBucketEvent({"UPDATE_INSTANCE_INFO", "LFG_UPDATE_RANDOM_INFO"}, 3, "UpdateRaidInstances")
    self:RegisterBucketEvent({"CHALLENGE_MODE_COMPLETED", "CHALLENGE_MODE_RESET", "CHALLENGE_MODE_MAPS_UPDATE", "MYTHIC_PLUS_NEW_WEEKLY_RECORD"}, 3, "UpdateMythicPlus")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateDB")

    C_Timer.After(5, function()
        C_MythicPlus.RequestMapInfo()
        RequestRaidInfo()
    end)

    self:loadGameData()
    self:CreateUI()
    self:UpdateDB()
end