---@class AE_Libs
---@field AceAddon AceAddon-3.0
---@field AceDB AceDB-3.0
---@field LibDBIcon LibDBIcon-1.0
---@field LibDataBroker LibDataBroker-1.1
---@field LiqUI LiqUI

---@class AE_LibDataBrokerLauncher : LibDataBroker.QuickLauncher
---@field OnTooltipShow fun(tooltip: GameTooltip)?

---@class AE_RaiderIO
---@field GetScoreColor fun(score: number, isPreviousSeason: boolean): number, number, number

---@class AE_Core : AceAddon, AceConsole-3.0, AceTimer-3.0
---@field renderQueued boolean?

---@class AE_Module_Main : AceModule
---@field window LiqUI_WindowInstance|nil

---@class AE_Module_Equipment : AceModule
---@field window LiqUI_WindowInstance|nil
---@field dataTable LiqUI_TableInstance|nil

---@class AE_Module_WeeklyAffixes : AceModule
---@field window LiqUI_WindowInstance|nil
---@field table LiqUI_TableInstance|nil

---@class AE_Helpers

---@class AE_Addon
---@field name string
---@field title string
---@field version string
---@field notes string
---@field Core AE_Core
---@field Libs AE_Libs
---@field Constants AE_Constants
---@field Helpers AE_Helpers
---@field Data AE_Data
---@field Module_Main AE_Module_Main
---@field Module_WeeklyAffixes AE_Module_WeeklyAffixes
---@field Module_Equipment AE_Module_Equipment
