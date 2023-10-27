---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.Libs = {}
AlterEgo.Libs.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
AlterEgo.Libs.LDBIcon = LibStub("LibDBIcon-1.0")

local defaultDB = {
    global = {
        characters = {},
        settings = {
            minimap = {
                hide = false
            }
        }
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

    local libDataObject = {
        label = "AlterEgo",
        tocname = "AlterEgo",
        type = "launcher",
        icon = "Interface/AddOns/AlterEgo/Logo.tga",
        OnClick = function()
            self:OnSlashCommand()
        end,
    }

    self.Libs.LDB:NewDataObject("AlterEgo", libDataObject)
    self.Libs.LDBIcon:Register("AlterEgo", libDataObject, self.db.global.settings.minimap)

    self:UpdateDB()
    self:CreateUI()
end

function AlterEgo:OnSlashCommand(message)
    self:ToggleWindow()
end

function AlterEgo:OnInventoryEvent()
    self:UpdateCharacterInfo()
end

function AlterEgo:OnMythicPlusEvent()
    self:UpdateDB()
end