---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.Libs = {}
AlterEgo.Libs.LDB = LibStub:GetLibrary("LibDataBroker-1.1")
AlterEgo.Libs.LDBIcon = LibStub("LibDBIcon-1.0")
AlterEgo.Libs.AceConfig = LibStub("AceConfig-3.0")
AlterEgo.Libs.AceConfigDialog = LibStub("AceConfigDialog-3.0")
AlterEgo.Libs.AceDBOptions = LibStub("AceDBOptions-3.0")
-- AlterEgo.Libs.LibSharedMedia = LibStub("LibSharedMedia-3.0")

local defaultDB = {
    global = {
        characters = {},
    },
    profile = {
        minimap = {
            hide = false,
            lock = false
        },
        sorting = "lastUpdate",
        filters = {
            hidezero = false
        }
    }
}

local options = {
    name = "AlterEgo",
    desc = "Varius options for the AlterEgo addon",
    -- handler = AlterEgo,
    type = "group",
    -- get = getOpt,
    -- set = setOpt,
    args = {
        version = {
            order = 1,
            type = "description",
            name = "Version: v1.0.0\n\n"
        },
        sorting = {
            order = 2,
            name = "Sorting",
            desc = "Various options for sorting your characters",
            type = "group",
            args = {
                header = {
                    order = 1,
                    type = "header",
                    name = "Sorting Options",
                },
                sorting = {
                    order = 2,
                    type = "select",
                    name = "Sort Characters By:",
                    desc = "How should your characters be sorted?",
                    style = "radio",
                    width = "double",
                    values = {
                        ["name.asc"] = "Name (A-Z)",
                        ["name.desc"] = "Name (Z-A)",
                        ["realm.asc"] = "Realm (A-Z)",
                        ["realm.desc"] = "Realm (Z-A)",
                        ["rating.asc"] = "Rating (Lowest)",
                        ["rating.desc"] = "Rating (Highest)",
                        ["ilvl.asc"] = "Item Level (Lowest)",
                        ["ilvl.desc"] = "Item Level (Highest)",
                        ["lastUpdate"] = "Recently played",
                    }
                }
            }
        },
        filters = {
            order = 3,
            name = "Filters",
            desc = "Various options for filtering your characters",
            type = "group",
            args = {
                header = {
                    order = 1,
                    type = "header",
                    name = "Filter Options",
                },
                hidezero = {
                    order = 2,
                    name = "Hide characters with zero rating",
                    desc = "I'm sure you'll play them again some time",
                    type = "toggle",
                    width = "double",
                    get = function()
                        return AlterEgo.db.profile.filters.hidezero
                    end,
                    set = function(_, value)
                        AlterEgo.db.profile.minimap.hidezero = value or false
                    end
                },
            }
        },
        minimap = {
            order = 4,
            name = "Minimap",
            desc = "Various options for the minimap button",
            type = "group",
            args = {
                header = {
                    order = 1,
                    type = "header",
                    name = "Minimap Options",
                },
                hide = {
                    order = 2,
                    name = "Hide the minimap button",
                    desc = "It does get crowded around the minimap sometimes",
                    type = "toggle",
                    width = "double",
                    get = function()
                        return AlterEgo.db.profile.minimap.hide
                    end,
                    set = function(_, value)
                        AlterEgo.db.profile.minimap.hide = value or false
                        AlterEgo.Libs.LDBIcon:Refresh("AlterEgo", AlterEgo.db.profile.minimap)
                    end
                },
                lock = {
                    order = 3,
                    name = "Lock the minimap button",
                    desc = "No more accidentally moving the button around!",
                    type = "toggle",
                    width = "double",
                    get = function()
                        return AlterEgo.db.profile.minimap.lock
                    end,
                    set = function(_, value)
                        AlterEgo.db.profile.minimap.lock = value or false
                        AlterEgo.Libs.LDBIcon:Refresh("AlterEgo", AlterEgo.db.profile.minimap)
                    end
                }
            }
        }
    }
}

function AlterEgo:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AlterEgoDB", defaultDB)
	-- self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
	-- self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
	-- self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")
    -- self:RegisterChatCommand("alterego", "OnSlashCommand")
    -- self:RegisterChatCommand("ae", "OnSlashCommand")
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 3, "OnInventoryEvent")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "OnMythicPlusEvent")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "OnMythicPlusEvent")

	-- self.Libs.LibSharedMedia:RegisterCallback("LibSharedMedia_Registered", "ApplySettings")
	-- self.Libs.LibSharedMedia:RegisterCallback("LibSharedMedia_SetGlobal", "ApplySettings")

    local libDataObject = {
        label = "AlterEgo",
        tocname = "AlterEgo",
        type = "launcher",
        icon = "Interface/AddOns/AlterEgo/Media/Logo.blp",
        OnClick = function()
            self:ToggleWindow()
        end,
        OnTooltipShow = function(tooltip)
            tooltip:SetText("AlterEgo", 1, 1, 1)
            tooltip:AddLine("Click to show the character summary.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            tooltip:AddLine("Drag to reposition this icon.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        end
    }
    self.Libs.LDB:NewDataObject("AlterEgo", libDataObject)
    self.Libs.LDBIcon:Register("AlterEgo", libDataObject, self.db.profile.minimap)

    options.args.profiles = self.Libs.AceDBOptions:GetOptionsTable(self.db)
    self.Libs.AceConfig:RegisterOptionsTable("AlterEgo", options, {"ae", "alterego"})
    -- self.Libs.AceConfig:RegisterOptionsTable("AlterEgo-Profiles", options.args.profiles)
    -- self.Libs.AceConfig:RegisterOptionsTable("AlterEgo", {
    --     type = "group",
    --     args = {
    --         version = {
    --             order = 1,
    --             type = "description",
    --             name = function() return "Version: !" end,
    
    --         }
    --     },
    -- })

    self.optionsFrames = {
        General = self.Libs.AceConfigDialog:AddToBlizOptions("AlterEgo", "AlterEgo"),
        -- Profiles = self.Libs.AceConfigDialog:AddToBlizOptions("AlterEgo-Profiles", "Profiles", "AlterEgo", "Profiles")
    }

    -- local optionsFrame, optionsFrameName = self.Libs.AceConfigDialog:AddToBlizOptions("AlterEgo", "AlterEgo", nil, "General")
    -- self.Libs.AceConfigDialog:AddToBlizOptions("AlterEgo", "Profiles", "AlterEgo", "Profiles")
    -- if optionsFrame ~= nil then
    --     self.optionsFrame = optionsFrame
    -- end
    -- if optionsFrameName ~= nil then
    --     self.optionsFrameName = optionsFrameName
    -- end

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

function AlterEgo:ToggleOptions()
    if self.optionsFrames.General ~= nil then
        if _G.SettingsPanel:IsShown() then
            HideUIPanel(_G.SettingsPanel)
        else
            if InterfaceOptionsFrame_OpenToCategory then
                InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.General)
            elseif Settings then
                Settings.OpenToCategory("AlterEgo")
            end
        end
    end
end

function AlterEgo:tablen(table)
    local n = 0
    for _ in pairs(table) do n = n + 1 end
    return n
end