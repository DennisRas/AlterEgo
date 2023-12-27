AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.Libs = {}
AlterEgo.Libs.AceDB = LibStub:GetLibrary("AceDB-3.0")
AlterEgo.Libs.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
AlterEgo.Libs.LDBIcon = LibStub("LibDBIcon-1.0")
AlterEgo.constants = {
    prefix = "<AlterEgo> "
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
    self:InitDB()
    self.Libs.LDB:NewDataObject("AlterEgo", libDataObject)
    self.Libs.LDBIcon:Register("AlterEgo", libDataObject, self.db.global.minimap)
    self:RegisterChatCommand("ae", "ToggleWindow")
    self:RegisterChatCommand("alterego", "ToggleWindow")
    self:CreateUI()
    _G["BINDING_NAME_ALTEREGO"] = "Show/Hide the window"
    hooksecurefunc("ResetInstances", function()
        self:OnInstanceReset()
    end)
end

function AlterEgo:OnEnable()
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED", "ITEM_CHANGED"}, 2, function()
        self:UpdateCharacterInfo()
        self:UpdateKeystoneItem()
    end)
    self:RegisterBucketEvent({"RAID_INSTANCE_WELCOME", "LFG_LOCK_INFO_RECEIVED", "BOSS_KILL"}, 2, RequestRaidInfo)
    self:RegisterEvent("ENCOUNTER_END", "OnEncounterEnd")
    self:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", "UpdateUI")
    -- self:RegisterEvent("WEEKLY_REWARDS_UPDATE", "UpdateVault")
    self:RegisterBucketEvent("WEEKLY_REWARDS_UPDATE", 2, "UpdateVault")
    self:RegisterBucketEvent({"UPDATE_INSTANCE_INFO", "LFG_UPDATE_RANDOM_INFO"}, 3, "UpdateRaidInstances")
    self:RegisterBucketEvent({"CHALLENGE_MODE_COMPLETED", "CHALLENGE_MODE_RESET", "CHALLENGE_MODE_MAPS_UPDATE", "MYTHIC_PLUS_NEW_WEEKLY_RECORD"}, 3, "UpdateMythicPlus")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateDB")
    self:RegisterEvent("SHOW_LOOT_TOAST", "OnToast")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "OnChatMessageSystem")

    C_Timer.After(5, function()
        C_MythicPlus.RequestCurrentAffixes();
        C_MythicPlus.RequestMapInfo()
        RequestRaidInfo()
    end)

    self:MigrateDB()
    self:loadGameData()
    self:UpdateDB()
end

function AlterEgo:OnToast(_, typeIdentifier, itemLink)
    if typeIdentifier ~= "item" then
        return
    end
    local _, itemId = strsplit(":", itemLink)
    if not itemId or tonumber(itemId) ~= 180653 then
        return
    end

    self.newKeystone = true
    self:UpdateKeystoneItem()
end

function AlterEgo:OnInstanceReset(event)
    local groupChannel = AE_GetGroupChannel()
    if groupChannel and self.db.global.announceResets then
        if not IsInInstance() and UnitIsGroupLeader("player") then
            SendChatMessage(self.constants.prefix .. "Resetting instances...", groupChannel)
        end
    end
end

function AlterEgo:OnChatMessageSystem(event, msg)
    local resetPatterns = {INSTANCE_RESET_SUCCESS, INSTANCE_RESET_FAILED, INSTANCE_RESET_FAILED_OFFLINE, INSTANCE_RESET_FAILED_ZONING}
    local groupChannel = AE_GetGroupChannel()
    if groupChannel and self.db.global.announceResets then
        if not IsInInstance() and UnitIsGroupLeader("player") then
            AE_table_foreach(resetPatterns, function(resetPattern)
                if msg:match("^" .. resetPattern:gsub("%%s", ".+") .. "$") then
                    if groupChannel and self.db.global.announceResets then
                        SendChatMessage(self.constants.prefix .. msg, groupChannel)
                    end
                end
            end)
        end
    end
end

function AlterEgo:AnnounceKeystones(chatType, multiline)
    local characters = self:GetCharacters()
    local dungeons = self:GetDungeons()
    local msg = "My Keystones: "

    if AE_table_count(characters) < 1 then
        self:Print("No announcement. You have no characters saved.")
        return
    end

    local keystoneCharacters = AE_table_filter(characters, function(character)
        local dungeon
        if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
            dungeon = AE_table_get(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
        elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
            dungeon = AE_table_get(dungeons, "mapId", character.mythicplus.keystone.mapId)
        end
        if dungeon and type(character.mythicplus.keystone.level) == "number" and character.mythicplus.keystone.level > 0 then
            return true
        end
        return false
    end)

    if AE_table_count(keystoneCharacters) < 1 then
        self:Print("No announcement. You have no keystones saved.")
        return
    end

    local count = 0
    AE_table_foreach(keystoneCharacters, function(character)
        local dungeon
        if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
            dungeon = AE_table_get(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
        elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
            dungeon = AE_table_get(dungeons, "mapId", character.mythicplus.keystone.mapId)
        end
        if dungeon then
            if type(character.mythicplus.keystone.level) == "number" and character.mythicplus.keystone.level > 0 then
                local currentKeystone = dungeon.abbr .. " +" .. tostring(character.mythicplus.keystone.level)
                if multiline then
                    SendChatMessage(character.info.name .. ": " .. (character.mythicplus.keystone.itemLink and character.mythicplus.keystone.itemLink or currentKeystone), chatType)
                else
                    if count > 0 then
                        msg = msg .. " || "
                    end
                    msg = msg .. currentKeystone
                end
                count = count + 1
            end
        end
    end)

    if not multiline then
        SendChatMessage(msg, chatType)
    end
end