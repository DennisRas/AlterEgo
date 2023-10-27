---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")

local defaultDB = {
    global = {
        characters = {},
    },
    profile = {
        settings = {}
    }
}

local options = {
    name = "AlterEgo",
    handler = AlterEgo,
    type = "group",
    args = {}
}

function AlterEgo:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AlterEgoDB", defaultDB)
    self:RegisterChatCommand("alterego", "OnSlashCommand")
    self:RegisterChatCommand("ae", "OnSlashCommand")
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 3, "OnInventoryEvent")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "OnMythicPlusEvent")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "OnMythicPlusEvent")

    self:UpdateDB()
    self:CreateUI()
end

function AlterEgo:OnSlashCommand(message)
    if not self.Window then return end
    if self.Window:IsVisible() then
        self.Window:Hide()
    else
        self.Window:Show()
    end
end

function AlterEgo:OnInventoryEvent()
    self:UpdateCharacterInfo()
end

function AlterEgo:OnMythicPlusEvent()
    self:UpdateDB()
end