---@class LiqUI
local LiqUI = _G.LiqUI
if not LiqUI then
  return
end

local C = LiqUI.Constants
local s = C.settings
local menuConfig = s.menu
local formConfig = s.form
local BACKDROP = C.shared.backdropTexture
local CONTENT_SCROLL_BAR_WIDTH = 6

LiqUIDB = LiqUIDB or {}

---@return LiqUI_DB
local function getEmbedDB()
  local liqui = LiqUIDB.liqui
  if type(liqui) ~= "table" or type(liqui.windows) ~= "table" or type(liqui.tables) ~= "table" or type(liqui.loggers) ~= "table" then
    ---@type LiqUI_DB
    LiqUIDB.liqui = {
      windows = type(liqui) == "table" and type(liqui.windows) == "table" and liqui.windows or {},
      tables = type(liqui) == "table" and type(liqui.tables) == "table" and liqui.tables or {},
      loggers = type(liqui) == "table" and type(liqui.loggers) == "table" and liqui.loggers or {},
    }
  end
  return LiqUIDB.liqui
end

local liqui = LiqUI:New({ name = "LiqUI", db = getEmbedDB() })

local Settings = {}
LiqUI.Settings = Settings

Settings.registrations = {}

---Register an addon's options with the Settings UI.
---Each addon has at least one page (e.g. General).
---AceConfig-compatible: { type = "group", args = { general = { type = "group", name = "General", args = {...} } } }
---@param id string Addon identifier (e.g. "LiqMe")
---@param options table|fun():table AceConfig format or { General = options }
---@param label string? Display name in menu (defaults to id)
---@param icon string? Texture path for addon icon (or nil to try TOC X-Icon / X-AddonIcon)
function Settings:Register(id, options, label, icon)
  self.registrations[id] = {
    options = options,
    label = label or id,
    icon = icon,
  }
  if self.menuScrollBox then
    self:UpdateMenu()
  end
end

---Extract pages from options. Supports:
---1. AceConfig: { type = "group", args = { general = { type = "group", name = "General", args = {...} } } }
---2. Shorthand: { General = { type = "group", args = {...} } }
---3. Single group: { type = "group", args = {...} } -> wrapped as General
---@param reg table registration with .options
---@return table? pages keyed by page id
local function NormalizePages(reg)
  local raw = type(reg.options) == "function" and reg.options() or reg.options
  if not raw then return nil end
  if raw.type == "group" and raw.args then
    local pages = {}
    for key, val in pairs(raw.args) do
      if type(val) == "table" and (val.type == "group" or val.args) then
        pages[key] = val
      end
    end
    if next(pages) then
      return pages
    end
    return { general = raw }
  end
  if raw.args then
    return { General = raw }
  end
  return raw
end

---Unregister an addon's options.
---@param id string
function Settings:Unregister(id)
  self.registrations[id] = nil
  if self.menuScrollBox then
    self:UpdateMenu()
  end
end

local function GetOptionValue(opt, path, handler)
  local get = opt.get
  if not get then return nil end
  local info = { arg = opt.arg }
  if type(get) == "function" then
    return get(info)
  end
  if type(get) == "string" and handler and handler[get] then
    return handler[get](handler, info)
  end
  return nil
end

local function SetOptionValue(opt, path, handler, value)
  local set = opt.set
  if not set then return end
  local info = { arg = opt.arg }
  if type(set) == "function" then
    set(info, value)
  elseif type(set) == "string" and handler and handler[set] then
    handler[set](handler, info, value)
  end
end

local function RefreshFormValues(formFrame)
  for _, row in ipairs(formFrame.formRows or {}) do
    if row.widget and row.widget.SetValue and row.getValue then
      local ok, a, b, c, d = pcall(row.getValue)
      if ok and a ~= nil then
        row.widget:SetValue(a, b, c, d)
      end
    end
  end
end

---@param parent Frame
---@param options table group options or AceConfig group
---@param handler table? optional get/set handler
local function BuildForm(parent, options, handler)
  local groupOptions = options
  if groupOptions.type == "group" then
    groupOptions = groupOptions
  else
    groupOptions = { type = "group", args = groupOptions.args or groupOptions }
  end

  parent.formRows = {}
  local args = groupOptions.args or {}
  local y = -formConfig.padding

  for key in LiqUI.Utils.SortedPairs(args) do
    local opt = args[key]
    if opt then
      local optType = opt.type or "input"
      local name = (type(opt.name) == "string") and opt.name or key
      local desc = (type(opt.desc) == "string") and opt.desc or nil
      local isDisabled = (type(opt.disabled) == "function" and opt.disabled({ arg = opt.arg })) or opt.disabled
      local control

      if optType == "input" then
        local val = GetOptionValue(opt, { key }, groupOptions.handler or handler)
        local widget = LiqUI.Widgets.CreateEditBox(parent, {
          value = tostring(val or ""),
          inputType = opt.inputType or "text",
          disabled = isDisabled,
          OnValueChanged = function(v)
            SetOptionValue(opt, { key }, groupOptions.handler or handler, v)
          end,
        })
        control = LiqUI.Layout.FormRow:New({
          parent = parent,
          label = name,
          description = desc,
          widget = widget,
        })
        table.insert(parent.formRows,
          { widget = widget, getValue = function() return GetOptionValue(opt, { key }, groupOptions.handler or handler) end })
      elseif optType == "toggle" then
        local val = GetOptionValue(opt, { key }, groupOptions.handler or handler)
        local widget = LiqUI.Widgets.CreateCheckBox(parent, {
          checked = val,
          disabled = isDisabled,
          OnValueChanged = function(v)
            SetOptionValue(opt, { key }, groupOptions.handler or handler, v)
          end,
        })
        control = LiqUI.Layout.FormRow:New({
          parent = parent,
          label = name,
          description = desc,
          widget = widget,
        })
        table.insert(parent.formRows,
          { widget = widget, getValue = function() return GetOptionValue(opt, { key }, groupOptions.handler or handler) end })
      elseif optType == "execute" then
        local func = opt.func
        if type(func) == "function" then
          local widget = LiqUI.Widgets.CreateButton(parent, {
            label = name,
            disabled = isDisabled,
            OnClick = function()
              func({ arg = opt.arg })
            end,
          })
          control = LiqUI.Layout.FormRow:New({
            parent = parent,
            label = name,
            description = desc,
            widget = widget,
          })
        end
      elseif optType == "select" then
        local values = opt.values
        if type(values) == "function" then values = values() end
        if type(values) == "table" then
          local val = GetOptionValue(opt, { key }, groupOptions.handler or handler)
          local widget = LiqUI.Widgets.CreateDropdown(parent, {
            values = values,
            value = val,
            disabled = isDisabled,
            OnValueChanged = function(v)
              SetOptionValue(opt, { key }, groupOptions.handler or handler, v)
            end,
          })
          control = LiqUI.Layout.FormRow:New({
            parent = parent,
            label = name,
            description = desc,
            widget = widget,
          })
          table.insert(parent.formRows,
            { widget = widget, getValue = function() return GetOptionValue(opt, { key }, groupOptions.handler or handler) end })
        end
      elseif optType == "multiselect" then
        local values = opt.values
        if type(values) == "function" then values = values() end
        if type(values) == "table" then
          local widget = LiqUI.Widgets.CreateMultiSelect(parent, {
            values = values,
            disabled = isDisabled,
            get = function(k)
              local info = { arg = opt.arg }
              if opt.get then
                if type(opt.get) == "function" then return opt.get(info, k) end
                if groupOptions.handler and groupOptions.handler[opt.get] then
                  return groupOptions.handler[opt.get](
                    groupOptions.handler, info, k)
                end
              end
              return false
            end,
            set = function(k, v)
              local info = { arg = opt.arg }
              if opt.set then
                if type(opt.set) == "function" then opt.set(info, k, v) end
                if groupOptions.handler and groupOptions.handler[opt.set] then
                  groupOptions.handler[opt.set](
                    groupOptions.handler, info, k, v)
                end
              end
            end,
          })
          control = LiqUI.Layout.FormRow:New({
            parent = parent,
            label = name,
            description = desc,
            widget = widget,
          })
        end
      elseif optType == "color" then
        local hasAlpha = opt.hasAlpha
        local function getColor()
          if not opt.get then return 1, 1, 1, 1 end
          local info = { arg = opt.arg }
          if type(opt.get) == "function" then return opt.get(info) end
          if groupOptions.handler and opt.get and groupOptions.handler[opt.get] then
            return groupOptions.handler
                [opt.get](groupOptions.handler, info)
          end
          return 1, 1, 1, 1
        end
        local gr, gg, gb, ga = getColor()
        if ga == nil then ga = 1 end
        local widget = LiqUI.Widgets.CreateColorPicker(parent, {
          r = gr,
          g = gg,
          b = gb,
          a = ga,
          hasAlpha = hasAlpha,
          disabled = isDisabled,
          OnValueChanged = function(nr, ng, nb, na)
            local info = { arg = opt.arg }
            if opt.set then
              if type(opt.set) == "function" then opt.set(info, nr, ng, nb, na) end
              if groupOptions.handler and opt.set and groupOptions.handler[opt.set] then
                groupOptions.handler[opt.set](groupOptions.handler, info, nr, ng,
                  nb, na)
              end
            end
          end,
        })
        control = LiqUI.Layout.FormRow:New({
          parent = parent,
          label = name,
          description = desc,
          widget = widget,
        })
        table.insert(parent.formRows, { widget = widget, getValue = getColor })
      elseif optType == "header" then
        control = LiqUI.Widgets.CreateHeader(parent, { text = name })
      elseif optType == "description" then
        control = LiqUI.Widgets.CreateDescription(parent, { text = name })
      elseif optType == "divider" then
        control = LiqUI.Widgets.CreateDivider(parent, {})
      end

      if control then
        control:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
        control:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
        local h = control:GetHeight() or 24
        local spacingAfter = formConfig.rowSpacingDefault
        if type(opt.spacingAfter) == "number" then
          spacingAfter = opt.spacingAfter
        elseif optType == "header" then
          spacingAfter = formConfig.rowSpacingAfterHeader
        elseif optType == "description" then
          spacingAfter = formConfig.rowSpacingAfterDescription
        elseif optType == "divider" then
          spacingAfter = 0
        end
        y = y - h - spacingAfter
      end
    end
  end

  parent:SetHeight(math.max(1, -y + formConfig.padding))
end

local function getFirstAddonId(registrations)
  local ids = {}
  for id in pairs(registrations) do ids[#ids + 1] = id end
  if #ids == 0 then return nil end
  table.sort(ids, function(a, b)
    return (registrations[a].label or a) < (registrations[b].label or b)
  end)
  return ids[1]
end

local function getFirstPageId(registration)
  local pages = NormalizePages(registration)
  if not pages then return nil end
  local raw = type(registration.options) == "function" and registration.options() or registration.options
  local args = raw and raw.args or pages
  for pageId in LiqUI.Utils.SortedPairs(args) do
    if pages[pageId] then return pageId end
  end
  return nil
end

---Rebuild menu from registrations. Pool buttons, hide all, then show/update per flat list. Call when registrations change or when showing a page.
function Settings:UpdateMenu()
  if not self.menuScrollBox then return end
  self.menuExpanded = self.menuExpanded or {}
  local scrollChild = self.menuScrollBox.scrollChild
  local addonIds = {}
  for id in pairs(self.registrations) do addonIds[#addonIds + 1] = id end
  table.sort(addonIds, function(a, b)
    return strcmputf8i(self.registrations[a].label or a, self.registrations[b].label or b) < 0
  end)
  local list = {}
  for _, id in ipairs(addonIds) do
    local reg = self.registrations[id]
    local pages = NormalizePages(reg)
    if pages then
      list[#list + 1] = { type = "addon", id = id, label = reg.label or id }
      if self.menuExpanded[id] ~= false then
        local raw = type(reg.options) == "function" and reg.options() or reg.options
        local args = raw and raw.args or pages
        for pageId in LiqUI.Utils.SortedPairs(args) do
          local pageOpts = pages[pageId]
          if pageOpts then
            local label = pageId
            if type(pageOpts) == "table" and type(pageOpts.name) == "string" then label = pageOpts.name end
            list[#list + 1] = { type = "page", id = pageId, label = label, addonId = id }
          end
        end
      end
    end
  end
  self.menuButtons = self.menuButtons or {}
  local padding = menuConfig.padding or 8
  local itemHeight = menuConfig.itemHeight or 24
  local pageIndent = menuConfig.pageIndent or 16
  for i = 1, #self.menuButtons do
    self.menuButtons[i]:Hide()
  end
  local offsetY = 0
  local currentAddonId = self.currentAddonId
  local currentPageId = self.currentPageId
  for index, entry in ipairs(list) do
    local button = self.menuButtons[index]
    if not button then
      button = CreateFrame("Button", "$parentMenuButton" .. index, scrollChild)
      Mixin(button, LiqUI.Mixins.Highlight)
      button.menuLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      button.menuLabel:SetJustifyH("LEFT")
      self.menuButtons[index] = button
    end
    local labelLeft = padding + ((entry.type == "page") and pageIndent or 0)
    button.menuLabel:ClearAllPoints()
    button.menuLabel:SetPoint("LEFT", button, "LEFT", labelLeft, 0)
    button.menuLabel:SetPoint("RIGHT", button, "RIGHT", -padding, 0)
    button.menuLabel:SetText(entry.label or entry.id)
    button:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -offsetY)
    button:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -offsetY)
    button:SetHeight(itemHeight)
    button.entry = entry


    local addonTextColor = CreateColorFromHexString("FFCCC562")
    local addonTextColorHover = CreateColorFromHexString("FFCCC562")
    local pageTextColor = CreateColorFromHexString("FFCCCCCC")
    local pageTextColorSelected = CreateColorFromHexString("FFFFFFFF")
    local pageTextColorHover = CreateColorFromHexString("FFFFFFFF")
    local highlightColor = CreateColorFromHexString("0CFFFFFF")
    local isSelected = self.currentAddonId == entry.addonId and self.currentPageId == entry.id

    button:SetScript("OnClick", function()
      if entry.type == "addon" then
        for id in pairs(self.registrations) do
          self.menuExpanded[id] = false
        end
        self.menuExpanded[entry.id] = not self.menuExpanded[entry.id]
        if self.menuExpanded[entry.id] then
          self:ShowPage(entry.id)
        else
          self:UpdateMenu()
        end
      else
        self:ShowPage(entry.addonId, entry.id)
      end
    end)
    button:SetScript("OnEnter", function()
      if entry.type == "page" then
        button.menuLabel:SetTextColor((isSelected and pageTextColorSelected or pageTextColorHover):GetRGBA())
        button:ShowHighlight(highlightColor:GetRGBA())
      else
        button.menuLabel:SetTextColor(addonTextColorHover:GetRGBA())
      end
    end)
    button:SetScript("OnLeave", function()
      if entry.type == "page" then
        button.menuLabel:SetTextColor((isSelected and pageTextColorSelected or pageTextColor):GetRGBA())
        button:HideHighlight()
      else
        button.menuLabel:SetTextColor(addonTextColor:GetRGBA())
      end
    end)

    local color
    if entry.type == "addon" then
      color = addonTextColor
    elseif isSelected then
      color = pageTextColorSelected
    else
      color = pageTextColor
    end
    button.menuLabel:SetTextColor(color:GetRGBA())
    button:Show()
    offsetY = offsetY + itemHeight
  end
  local menuWidth = math.max(1, (menuConfig.width or 200) - (menuConfig.scrollBarWidth or 12))
  scrollChild:SetSize(menuWidth, offsetY)
  self.menuScrollBox:FullUpdate(true)
end

function Settings:ShowPage(addonId, pageId)
  if not self.scrollChild then return end
  local registration = self.registrations[addonId]
  if not registration then return end

  if not pageId then
    pageId = getFirstPageId(registration)
    if not pageId then return end
  end

  self.currentAddonId = addonId
  self.currentPageId = pageId
  for id in pairs(self.registrations) do
    self.menuExpanded[id] = (id == addonId)
  end

  local pages = NormalizePages(registration)
  local pageOptions = pages and pages[pageId]
  if not pageOptions then return end
  if self.formFrame then
    self.formFrame:SetParent(nil)
    self.formFrame:Hide()
  end
  self.formCache[addonId] = self.formCache[addonId] or {}
  local cached = self.formCache[addonId][pageId]
  if cached then
    self.formFrame = cached
    self.formFrame:SetParent(self.scrollChild)
    self.formFrame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", formConfig.padding, 0)
    self.formFrame:SetPoint("TOPRIGHT", self.scrollChild, "TOPRIGHT", -formConfig.padding, 0)
    self.formFrame:Show()
    RefreshFormValues(self.formFrame)
  else
    self.formFrame = CreateFrame("Frame", nil, self.scrollChild)
    self.formFrame:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", formConfig.padding, 0)
    self.formFrame:SetPoint("TOPRIGHT", self.scrollChild, "TOPRIGHT", -formConfig.padding, 0)
    BuildForm(self.formFrame, pageOptions)
    self.formCache[addonId][pageId] = self.formFrame
  end
  local contentWidth = math.max(1, self.contentScrollBox:GetWidth() or 400)
  self.scrollChild:SetSize(contentWidth, self.formFrame:GetHeight())
  self.contentScrollBox:FullUpdate(true)

  self:UpdateMenu()
end

---Create all window frames on load. Call once (e.g. at end of file). Populates menu from current registrations.
function Settings:Init()
  if self.window then return end
  local window = liqui.Window:New({
    name = "LiqUISettings",
    title = "Settings",
    point = { "CENTER", 0, 0 },
  })
  window:SetBodySize(s.windowWidth, s.windowHeight)
  local body = window.body

  local menuContainer = CreateFrame("Frame", "$parentMenu", body, "BackdropTemplate")
  menuContainer:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)
  menuContainer:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 0, 0)
  menuContainer:SetWidth(menuConfig.width)
  menuContainer:SetBackdrop({ bgFile = BACKDROP, tile = true, tileSize = 8 })
  menuContainer:SetBackdropColor(C.menu.backgroundColor:GetRGBA())

  local contentContainer = CreateFrame("Frame", "$parentContent", body)
  contentContainer:SetPoint("TOPLEFT", menuContainer, "TOPRIGHT", 0, 0)
  contentContainer:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", 0, 0)
  contentContainer:SetFrameLevel(menuContainer:GetFrameLevel() + 1)

  local contentScrollBox = LiqUI.Utils.CreateScrollBox(contentContainer, "$parentScroll",
    { barWidth = CONTENT_SCROLL_BAR_WIDTH })
  contentScrollBox:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", 0, 0)
  contentScrollBox:SetPoint("BOTTOMRIGHT", contentContainer, "BOTTOMRIGHT", -CONTENT_SCROLL_BAR_WIDTH, 0)
  local scrollChild = contentScrollBox.scrollChild

  local menuScrollBox = LiqUI.Utils.CreateScrollBox(menuContainer, "$parentMenuScroll",
    { barWidth = menuConfig.scrollBarWidth or 12 })
  menuScrollBox:SetPoint("TOPLEFT", menuContainer, "TOPLEFT", 0, 0)
  menuScrollBox:SetPoint("BOTTOMRIGHT", menuContainer, "BOTTOMRIGHT", -(menuConfig.scrollBarWidth or 12), 0)

  self.window = window
  self.menu = menuContainer
  self.content = contentContainer
  self.contentScrollBox = contentScrollBox
  self.scrollChild = scrollChild
  self.menuScrollBox = menuScrollBox
  self.formFrame = nil
  self.formCache = {}
  self:UpdateMenu()
end

---Open the Settings window. Init must have run (on load). Shows first page if none selected.
---@return nil
function Settings:Open()
  local firstAddonId = getFirstAddonId(self.registrations)
  if firstAddonId then
    self:ShowPage(firstAddonId)
  end
  self.window:Show()
end

---Toggle the Settings window.
function Settings:Toggle()
  if self.window and self.window:IsVisible() then
    self.window:Hide()
  else
    self:Open()
  end
end

Settings:Register("LiqUI", {
  type = "group",
  args = {
    general = {
      type = "group",
      name = "General",
      args = {
        autoOpenSettings = {
          type = "toggle",
          name = "Open Settings on load",
          desc = "Automatically open the Settings window when you log in",
          get = function() return LiqUIDB.autoOpenSettings end,
          set = function(_, v) LiqUIDB.autoOpenSettings = v end,
          order = 1,
        },
      },
    },
  },
}, "LiqUI")

Settings:Init()

local autoOpenFrame = CreateFrame("Frame")
autoOpenFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
autoOpenFrame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    autoOpenFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if LiqUIDB.autoOpenSettings then
      Settings:Open()
    end
  end
end)
