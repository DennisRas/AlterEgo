local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Table = AlterEgo.Table
local Window = AlterEgo.Window
local Core = AlterEgo.Core
local Data = AlterEgo.Data
local Constants = AlterEgo.Constants
local Module = Core:NewModule("RunHistory")

function Module:OnEnable()
  self:Render()
end

function Module:OnDisable()
  self:Render()
end

function Module:Open()
  self.winddow:Show()
end

function Module:Render()
  if not self.window then
    self.window = Window:CreateWindow({
      name = "RunHistory",
      title = "Run History",
      sidebar = true,
    })
  end
end
