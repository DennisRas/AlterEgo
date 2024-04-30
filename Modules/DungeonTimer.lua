local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Table = AlterEgo.Table
local Window = AlterEgo.Window
local Core = AlterEgo.Core
local Data = AlterEgo.Data
local Constants = AlterEgo.Constants
local Module = Core:NewModule("DungeonTimer")

function Module:OnEnable()
  self:Render()
end

function Module:OnDisable()
end

function Module:Render()
  if not self.window then
    self.window = Window:CreateWindow()
  end

  if Data.db.dungeonTimer and Data.db.dungeonTimer.currentRun then
    self.window:Show()
  else
    self.window:Hide()
  end
end
