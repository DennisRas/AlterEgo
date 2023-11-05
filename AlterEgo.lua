---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.Libs = {}
AlterEgo.Libs.AceDB = LibStub:GetLibrary("AceDB-3.0")
AlterEgo.Libs.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
AlterEgo.Libs.LDBIcon = LibStub("LibDBIcon-1.0")

local defaultDB = {
    global = {
        characters = {},
        minimap = {
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

function AlterEgo:RefreshLockInfo() -- throttled lock update with retry
    local now = GetTime()
    if now > (self.lastrefreshlock or 0) + 1 then
        self.lastrefreshlock = now
        self:RequestLockInfo()
    end
    if now > (self.lastrefreshlocksched or 0) + 120 then
        -- make sure we update any lockout info (sometimes there's server-selfde delay)
        self:Print("(self.lastrefreshlocksched or 0)")
        self.lastrefreshlockshed = now
        self:ScheduleTimer("RequestLockInfo", 5)
        self:ScheduleTimer("RequestLockInfo", 30)
        self:ScheduleTimer("RequestLockInfo", 60)
        self:ScheduleTimer("RequestLockInfo", 90)
        self:ScheduleTimer("RequestLockInfo", 120)
    end
end

function AlterEgo:RequestLockInfo() -- request lock info from the server immediately
    RequestRaidInfo()
    RequestLFDPlayerLockInfo()
end

function AlterEgo:OnInitialize()
    self.db = self.Libs.AceDB:New("AlterEgoDB", defaultDB, true)
    self:RegisterChatCommand("ae", "ToggleWindow")
    self:RegisterChatCommand("alterego", "ToggleWindow")
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 3, function()
        self:Print("BAG_UPDATE_DELAYED")
        self:UpdateDB()
    end)
    self:RegisterBucketEvent("RAID_INSTANCE_WELCOME", 2, function()
        self:Print("RAID_INSTANCE_WELCOME")
        RequestRaidInfo()
    end)
    self:RegisterBucketEvent("LFG_LOCK_INFO_RECEIVED", 2, function()
        self:Print("LFG_LOCK_INFO_RECEIVED")
        RequestRaidInfo()
    end)
    self:RegisterBucketEvent({"BOSS_KILL", "ENCOUNTER_END"}, 5, function()
        self:Print("BOSS_KILL, ENCOUNTER_END")
        RequestRaidInfo()
    end)
    self:RegisterBucketEvent({"WEEKLY_REWARDS_UPDATE", "CHALLENGE_MODE_MAPS_UPDATE"}, 2, function()
        self:Print("WEEKLY_REWARDS_UPDATE")
        self:UpdateDB()
    end)
    self:RegisterBucketEvent("LFG_UPDATE_RANDOM_INFO", 2, function()
        self:Print("LFG_UPDATE_RANDOM_INFO")
        self:UpdateDB()
    end)
    self:RegisterBucketEvent("UPDATE_INSTANCE_INFO", 2, function()
        self:Print("UPDATE_INSTANCE_INFO")
        self:UpdateDB()
    end)
    self:RegisterBucketEvent("CHALLENGE_MODE_COMPLETED", 5, function()
        self:Print("CHALLENGE_MODE_COMPLETED")
        self:UpdateDB()
    end)
    self:RegisterBucketEvent("CHALLENGE_MODE_RESET", 2, function()
        self:Print("CHALLENGE_MODE_RESET")
        self:UpdateDB()
    end)
    self:RegisterBucketEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD", 2, function()
        self:Print("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
        self:UpdateDB()
    end)
    self.Libs.LDB:NewDataObject("AlterEgo", libDataObject)
    self.Libs.LDBIcon:Register("AlterEgo", libDataObject, self.db.global.minimap)

    C_Timer.After(2, function()
        C_MythicPlus.RequestMapInfo()
        RequestRaidInfo()
    end)

    self:UpdateDB()
    self:CreateUI()
end