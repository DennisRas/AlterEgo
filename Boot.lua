---@class AE_Addon
local addon = select(2, ...)

local name, title, notes = C_AddOns.GetAddOnInfo(select(1, ...))
addon.name = name
addon.title = title
addon.notes = notes
addon.version = C_AddOns.GetAddOnMetadata(name, "Version") or ""

addon.Libs = addon.Libs or {}
addon.Libs.LibDataBroker = LibStub("LibDataBroker-1.1")
addon.Libs.LibDBIcon = LibStub("LibDBIcon-1.0")
addon.Libs.AceDB = LibStub("AceDB-3.0")
addon.Libs.AceAddon = LibStub("AceAddon-3.0")
addon.Libs.LiqUI = LibStub("LiqUI-1.0")

--@debug@
_G[addon.name] = addon
--@end-debug@
