---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Window = addon.Window

---@class AE_Settings
local Settings = {}
addon.Settings = Settings
