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
        hidezero = false
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
        tooltip:AddLine("Drag to move this icon.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end
}

function AlterEgo:OnInitialize()
    self.db = self.Libs.AceDB:New("AlterEgoDB", defaultDB, true)
    self:RegisterChatCommand("ae", "ToggleWindow")
    self:RegisterChatCommand("alterego", "ToggleWindow")
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 3, "UpdateCharacterInfo")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "UpdateDB")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "UpdateDB")
    self.Libs.LDB:NewDataObject("AlterEgo", libDataObject)
    self.Libs.LDBIcon:Register("AlterEgo", libDataObject, self.db.global.minimap)

    self:UpdateDB()
    self:CreateUI()
end

function AlterEgo:tablen(table)
    local n = 0
    for _ in pairs(table) do n = n + 1 end
    return n
end