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
    self.window = Window:New({
      name = "RunHistory",
      title = "Run History",
      sidebar = true,
    })
  end
end
