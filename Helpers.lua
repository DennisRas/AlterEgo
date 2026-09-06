---@class AE_Addon
local addon = select(2, ...)

---@class AE_Helpers
local Helpers = {}
addon.Helpers = Helpers

local LiqUI = addon.Libs.LiqUI
local TableFilter = LiqUI.Utils.TableFilter

---Calculate the dungeon timer
---@param time number
---@param level number
---@param tier number
---@param seasonID number
---@return number
function Helpers:calculateDungeonTimer(time, level, tier, seasonID)
  if tier == 3 then
    time = time * 0.6
  elseif tier == 2 then
    time = time * 0.8
  end

  if seasonID == 13 and level >= 7 then
    time = time + 90
  end

  return time
end

---Get the lowest keystone level completed from highest <numRuns> runs.
---Example: 4, 2, 2, 5, with numRuns = 2 would return 4
---@param character AE_Character
---@param numRuns integer
---@return integer?, integer?
function Helpers:GetLowestLevelInTopDungeonRuns(character, numRuns)
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

  local runHistory = TableFilter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end)
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
---@return "RAID"|"PARTY"|nil
function Helpers:GetGroupChannel()
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
---@param isPreviousSeason boolean?
---@return ColorMixin
function Helpers:GetRatingColor(rating, useRIOScoreColor, isPreviousSeason)
  local color
  local RIO = _G["RaiderIO"]
  if useRIOScoreColor and RIO then
    color = CreateColor(RIO.GetScoreColor(rating, isPreviousSeason or false))
  else
    color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
  end
  return color
end
