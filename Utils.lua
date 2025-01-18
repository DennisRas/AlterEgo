---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Utils
local Utils = {}
addon.Utils = Utils

Utils.ScrollCollection = {}

---Set the background color for a parent frame
---@param parent Frame
---@param r number
---@param g number
---@param b number
---@param a number
function Utils:SetBackgroundColor(parent, r, g, b, a)
  if not parent.Background then
    parent.Background = parent:CreateTexture("Background", "BACKGROUND")
    parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Background:SetAllPoints()
  end

  parent.Background:SetVertexColor(r, g, b, a)
end

---Set the highlight color for a parent frame
---@param parent Frame
---@param r number|table?
---@param g number?
---@param b number?
---@param a number?
function Utils:SetHighlightColor(parent, r, g, b, a)
  if not parent.Highlight then
    parent.Highlight = parent:CreateTexture("Highlight", "OVERLAY")
    parent.Highlight:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Highlight:SetAllPoints()
  end

  if type(r) == "table" then
    r, g, b, a = r.a, r.g, r.b, r.a
  end

  if r == nil then
    r = 1
  end
  if g == nil then
    g = 1
  end
  if b == nil then
    b = 1
  end
  if a == nil then
    a = 0.05
  end

  parent.Highlight:SetVertexColor(r, g, b, a)
end

---Find a table item by callback
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): boolean
---@return T|nil, number|nil
function Utils:TableFind(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  for i, v in ipairs(tbl) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil, nil
end

---Find a table item by key and value
---@generic T
---@param tbl T[]
---@param key string
---@param val any
---@return T|nil
function Utils:TableGet(tbl, key, val)
  assert(type(tbl) == "table", "Must be a table!")
  return self:TableFind(tbl, function(elm)
    return elm[key] and elm[key] == val
  end)
end

---Create a new table containing all elements that pass truth test
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): boolean
---@return T[]
function Utils:TableFilter(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  for i, v in pairs(tbl) do
    if callback(v, i) then
      table.insert(t, v)
    end
  end
  return t
end

---Count table items
---@param tbl table
---@return number
function Utils:TableCount(tbl)
  assert(type(tbl) == "table", "Must be a table!")
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

---Deep copy a table
---@generic T
---@param tbl T[]
---@param cache table?
---@return T[]
function Utils:TableCopy(tbl, cache)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  cache = cache or {}
  cache[tbl] = t
  self:TableForEach(tbl, function(v, k)
    if type(v) == "table" then
      t[k] = cache[v] or self:TableCopy(v, cache)
    else
      t[k] = v
    end
  end)
  return t
end

---Map each item in a table
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): any
---@return T[]
function Utils:TableMap(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  self:TableForEach(tbl, function(v, k)
    local newv, newk = callback(v, k)
    t[newk and newk or k] = newv
  end)
  return t
end

---Run a callback on each table item
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number)
---@return T[]
function Utils:TableForEach(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  for ik, iv in pairs(tbl) do
    callback(iv, ik)
  end
  return tbl
end

---Get character activity progress
---@param character AE_Character
---@return AE_CharacterVault|nil, AE_CharacterVault|nil
function Utils:GetActivitiesProgress(character)
  local activities = Utils:TableFilter(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities end)
  table.sort(activities, function(left, right)
    return left.index < right.index
  end)
  local lastCompletedIndex = 0
  for i, activityInfo in ipairs(activities) do
    if activityInfo.progress >= activityInfo.threshold then
      lastCompletedIndex = i
    end
  end

  if lastCompletedIndex == 0 then
    return nil, nil
  end

  if lastCompletedIndex == #activities then
    local info = activities[lastCompletedIndex]
    return info, nil
  end

  local nextInfo = activities[lastCompletedIndex + 1]
  return activities[lastCompletedIndex], nextInfo
end

---Get the lowest keystone level completed from highest <numRuns> runs.
---Example: 4, 2, 2, 5, with numRuns = 2 would return 4
---@param character any
---@param numRuns number
---@return number|nil, number
function Utils:GetLowestLevelInTopDungeonRuns(character, numRuns)
  local lowestLevel
  local lowestCount   = 0
  local numHeroic     = 0
  local numMythic     = 0
  local numMythicPlus = 0

  if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
    numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
    numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
    numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
  end

  if numRuns > numMythicPlus and (numHeroic + numMythic) > 0 then
    if numRuns > numMythicPlus + numMythic and numHeroic > 0 then
      lowestLevel = WeeklyRewardsUtil.HeroicLevel
      lowestCount = numRuns - numMythicPlus - numMythic
    else
      lowestLevel = WeeklyRewardsUtil.MythicLevel
      lowestCount = numRuns - numMythicPlus
    end
    return lowestLevel, lowestCount
  end

  local runHistory = Utils:TableFilter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end)
  table.sort(runHistory, function(left, right)
    return left.level > right.level
  end)
  for i = math.min(numRuns, #runHistory), 1, -1 do
    local run = runHistory[i]
    if not lowestLevel then
      lowestLevel = run.level
    end
    if lowestLevel == run.level then
      lowestCount = lowestCount + 1
    else
      break
    end
  end
  return lowestLevel, lowestCount
end

---Get the group type
---@return string|nil
function Utils:GetGroupChannel()
  if IsInRaid() then
    return "RAID"
  end
  if IsInGroup() then
    return "PARTY"
  end
  return nil
end

---Get a rating color
---@param rating number
---@param useRIOScoreColor boolean
---@param isPreviousSeason boolean
---@return ColorMixin|nil
function Utils:GetRatingColor(rating, useRIOScoreColor, isPreviousSeason)
  local color
  local RIO = _G["RaiderIO"]
  if useRIOScoreColor and RIO then
    color = CreateColor(RIO.GetScoreColor(rating, isPreviousSeason or false))
  else
    color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
  end
  return color
end

function Utils:CreateScrollFrame(config)
  local frame = CreateFrame("ScrollFrame", addonName .. "ScrollFrame" .. (Utils:TableCount(self.ScrollCollection) + 1))
  frame.config = CreateFromMixins(
    {
      scrollSpeedHorizontal = 20,
      scrollSpeedVertical = 20,
    },
    config or {}
  )

  frame.content = CreateFrame("Frame", "$parentContent", frame)
  frame.scrollbarH = CreateFrame("Slider", "$parentScrollbarH", frame, "UISliderTemplate")
  frame.scrollbarV = CreateFrame("Slider", "$parentScrollbarV", frame, "UISliderTemplate")

  frame:SetScript("OnMouseWheel", function(_, delta)
    if IsModifierKeyDown() then
      if frame.scrollbarH:IsVisible() then
        frame.scrollbarH:SetValue(frame.scrollbarH:GetValue() - delta * frame.config.scrollSpeedHorizontal)
      end
    else
      if frame.scrollbarV:IsVisible() then
        frame.scrollbarV:SetValue(frame.scrollbarV:GetValue() - delta * frame.config.scrollSpeedVertical)
      end
    end
  end)
  frame:SetScript("OnSizeChanged", function() frame:RenderScrollFrame() end)
  frame:SetScrollChild(frame.content)
  frame.content:SetScript("OnSizeChanged", function() frame:RenderScrollFrame() end)

  frame.scrollbarH:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  frame.scrollbarH:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  frame.scrollbarH:SetHeight(6)
  frame.scrollbarH:SetMinMaxValues(0, 100)
  frame.scrollbarH:SetValue(0)
  frame.scrollbarH:SetValueStep(1)
  frame.scrollbarH:SetOrientation("HORIZONTAL")
  frame.scrollbarH:SetObeyStepOnDrag(true)
  frame.scrollbarH.thumb = frame.scrollbarH:GetThumbTexture()
  frame.scrollbarH.thumb:SetPoint("CENTER")
  frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15)
  frame.scrollbarH.thumb:SetHeight(10)
  frame.scrollbarH:SetScript("OnValueChanged", function(_, value) frame:SetHorizontalScroll(value) end)
  frame.scrollbarH:SetScript("OnEnter", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.2) end)
  frame.scrollbarH:SetScript("OnLeave", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15) end)

  frame.scrollbarV:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  frame.scrollbarV:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  frame.scrollbarV:SetWidth(6)
  frame.scrollbarV:SetMinMaxValues(0, 100)
  frame.scrollbarV:SetValue(0)
  frame.scrollbarV:SetValueStep(1)
  frame.scrollbarV:SetOrientation("VERTICAL")
  frame.scrollbarV:SetObeyStepOnDrag(true)
  frame.scrollbarV.thumb = frame.scrollbarV:GetThumbTexture()
  frame.scrollbarV.thumb:SetPoint("CENTER")
  frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15)
  frame.scrollbarV.thumb:SetWidth(10)
  frame.scrollbarV:SetScript("OnValueChanged", function(_, value) frame:SetVerticalScroll(value) end)
  frame.scrollbarV:SetScript("OnEnter", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.2) end)
  frame.scrollbarV:SetScript("OnLeave", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15) end)

  if frame.scrollbarH.NineSlice then frame.scrollbarH.NineSlice:Hide() end
  if frame.scrollbarV.NineSlice then frame.scrollbarV.NineSlice:Hide() end

  function frame:RenderScrollFrame()
    local viewportBuffer = 4
    local viewportWidth = frame:GetWidth()
    local viewportHeight = frame:GetHeight()
    local contentWidth = frame.content:GetWidth()
    local contentHeight = frame.content:GetHeight()
    local ratioWidth = (viewportWidth + viewportBuffer) / contentWidth
    local ratioHeight = (viewportHeight + viewportBuffer) / contentHeight
    -- Horizontal
    if ratioWidth < 1 then
      frame.scrollbarH:SetValueStep(frame.config.scrollSpeedHorizontal)
      frame.scrollbarH:SetMinMaxValues(0, contentWidth - viewportWidth)
      frame.scrollbarH.thumb:SetWidth(viewportWidth * ratioWidth)
      frame.scrollbarH.thumb:SetHeight(frame.scrollbarH:GetHeight())
      frame.scrollbarH:Show()
    else
      frame:SetHorizontalScroll(0)
      frame.scrollbarH:Hide()
    end
    -- Vertical
    if ratioHeight < 1 then
      frame.scrollbarV:SetValueStep(frame.config.scrollSpeedVertical)
      frame.scrollbarV:SetMinMaxValues(0, contentHeight - viewportHeight)
      frame.scrollbarV.thumb:SetHeight(math.min(viewportHeight * ratioHeight, viewportHeight / 3))
      frame.scrollbarV.thumb:SetWidth(frame.scrollbarV:GetWidth())
      frame.scrollbarV:Show()
    else
      frame:SetVerticalScroll(0)
      frame.scrollbarV:Hide()
    end
  end

  frame:RenderScrollFrame()
  return frame
end

-- function Utils:CreateScrollFrame(name, parent)
--   local frame = CreateFrame("ScrollFrame", name, parent)
--   frame.content = CreateFrame("Frame", "$parentContent", frame)
--   frame.scrollbarH = CreateFrame("Slider", "$parentScrollbarH", frame, "UISliderTemplate")
--   frame.scrollbarV = CreateFrame("Slider", "$parentScrollbarV", frame, "UISliderTemplate")

--   frame:SetScript("OnMouseWheel", function(_, delta)
--     if IsModifierKeyDown() or not frame.scrollbarV:IsVisible() then
--       frame.scrollbarH:SetValue(frame.scrollbarH:GetValue() - delta * ((frame.content:GetWidth() - frame:GetWidth()) * 0.1))
--     else
--       frame.scrollbarV:SetValue(frame.scrollbarV:GetValue() - delta * ((frame.content:GetHeight() - frame:GetHeight()) * 0.1))
--     end
--   end)
--   frame:SetScript("OnSizeChanged", function() frame:RenderScrollFrame() end)
--   frame:SetScrollChild(frame.content)
--   frame.content:SetScript("OnSizeChanged", function() frame:RenderScrollFrame() end)

--   frame.scrollbarH:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
--   frame.scrollbarH:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
--   frame.scrollbarH:SetHeight(6)
--   frame.scrollbarH:SetMinMaxValues(0, 100)
--   frame.scrollbarH:SetValue(0)
--   frame.scrollbarH:SetValueStep(1)
--   frame.scrollbarH:SetOrientation("HORIZONTAL")
--   frame.scrollbarH:SetObeyStepOnDrag(true)
--   frame.scrollbarH.thumb = frame.scrollbarH:GetThumbTexture()
--   frame.scrollbarH.thumb:SetPoint("CENTER")
--   frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15)
--   frame.scrollbarH.thumb:SetHeight(10)
--   frame.scrollbarH:SetScript("OnValueChanged", function(_, value) frame:SetHorizontalScroll(value) end)
--   frame.scrollbarH:SetScript("OnEnter", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.2) end)
--   frame.scrollbarH:SetScript("OnLeave", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15) end)

--   frame.scrollbarV:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
--   frame.scrollbarV:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
--   frame.scrollbarV:SetWidth(6)
--   frame.scrollbarV:SetMinMaxValues(0, 100)
--   frame.scrollbarV:SetValue(0)
--   frame.scrollbarV:SetValueStep(1)
--   frame.scrollbarV:SetOrientation("VERTICAL")
--   frame.scrollbarV:SetObeyStepOnDrag(true)
--   frame.scrollbarV.thumb = frame.scrollbarV:GetThumbTexture()
--   frame.scrollbarV.thumb:SetPoint("CENTER")
--   frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15)
--   frame.scrollbarV.thumb:SetWidth(10)
--   frame.scrollbarV:SetScript("OnValueChanged", function(_, value) frame:SetVerticalScroll(value) end)
--   frame.scrollbarV:SetScript("OnEnter", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.2) end)
--   frame.scrollbarV:SetScript("OnLeave", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15) end)

--   if frame.scrollbarH.NineSlice then frame.scrollbarH.NineSlice:Hide() end
--   if frame.scrollbarV.NineSlice then frame.scrollbarV.NineSlice:Hide() end

--   function frame:RenderScrollFrame()
--     local buffer = 4
--     if math.floor(frame.content:GetWidth()) - buffer > math.floor(frame:GetWidth()) then
--       frame.scrollbarH:SetMinMaxValues(0, frame.content:GetWidth() - frame:GetWidth())
--       frame.scrollbarH.thumb:SetWidth(frame.scrollbarH:GetWidth() / 10)
--       frame.scrollbarH.thumb:SetHeight(frame.scrollbarH:GetHeight())
--       frame.scrollbarH:Show()
--     else
--       frame:SetHorizontalScroll(0)
--       frame.scrollbarH:Hide()
--     end
--     if math.floor(frame.content:GetHeight()) - buffer > math.floor(frame:GetHeight()) then
--       frame.scrollbarV:SetMinMaxValues(0, frame.content:GetHeight() - frame:GetHeight())
--       frame.scrollbarV.thumb:SetHeight(frame.scrollbarV:GetHeight() / 10)
--       frame.scrollbarV.thumb:SetWidth(frame.scrollbarV:GetWidth())
--       frame.scrollbarV:Show()
--     else
--       frame:SetVerticalScroll(0)
--       frame.scrollbarV:Hide()
--     end
--   end

--   frame:RenderScrollFrame()
--   return frame
-- end
