---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Utils = addon.Utils
local Table = addon.Table
local Window = addon.Window
local Core = addon.Core
local Data = addon.Data
local Constants = addon.Constants
local Module = Core:NewModule("DungeonTimer")

function Module:OnEnable()
  self:Render()
end

function Module:OnDisable()
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "DungeonTimer",
      titlebar = false
    })
  end

  if Data.db.dungeonTimer and Data.db.dungeonTimer.currentRun then
    self.window:Show()
  else
    self.window:Hide()
  end
end
