---@class AE_Addon
local addon = select(2, ...)

addon.Libs = addon.Libs or {}
addon.Libs.LibDataBroker = LibStub("LibDataBroker-1.1")
addon.Libs.LibDBIcon = LibStub("LibDBIcon-1.0")
addon.Libs.LiqUI = LibStub("LiqUI-1.0")
