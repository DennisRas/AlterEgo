---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_UI
local UI = {}
addon.UI = UI

local LibDBIcon = LibStub("LibDBIcon-1.0")
local CHARACTER_WIDTH = 120

---Calculate the dungeon timer
---@param time number
---@param level number
---@param tier number
---@return number
local function calculateDungeonTimer(time, level, tier)
  if tier == 3 then
    time = time * 0.6
  elseif tier == 2 then
    time = time * 0.8
  end

  --- This was such a dumb thing to do by Blizzard
  local seasonID = addon.Data:GetCurrentSeason()
  if seasonID == 13 and level >= 7 then
    time = time + 90
  end

  return time
end

function UI:Render()
  self:RenderMainWindow()
  self:RenderAffixWindow()
  self:RenderEquipmentWindow()
end

local function isCompletedAtHeroicLevel(activityTierID)
  local difficultyID = C_WeeklyRewards.GetDifficultyIDForActivityTier(activityTierID)
  return difficultyID == DifficultyUtil.ID.DungeonHeroic
end

local dungeonPortalUnlockLevel = 10
local vaultMaxLevelRewardMythic = 10
local vaultMaxLevelRewardWorld = 8
local vaultMaxNumRunsMythic = 8
local vaultSlotOneIndex = 1
local vaultTooltipTexts = {
  [Enum.WeeklyRewardChestThresholdType.Raid] = {
    ["objective"] = "|4boss:bosses;",
    ["default"] = "Defeat bosses this week to unlock your first Great Vault reward.",
    ["firstSlotStart"] = "Defeat %1$d |4boss:bosses; this week to unlock your first Great Vault reward.",
    ["firstSlotMore"] = "Defeat %1$d more |4boss:bosses; this week to unlock your first Great Vault reward.",
    ["nextSlotMore"] = "Defeat %1$d more |4boss:bosses; this week to unlock another Great Vault reward.",
    ["rewardsImprove"] = "Defeat bosses on %s difficulty or higher to improve your Great Vault rewards.",
    ["rewardsMaxed"] = "Good job - You are done! There are no more rewards to improve.",
  },
  [Enum.WeeklyRewardChestThresholdType.Activities] = {
    ["objective"] = "|4dungeon:dungeons;",
    ["default"] = "Complete a Timewalking, Heroic or Mythic dungeon this week to unlock your first Great Vault reward.",
    ["firstSlotStart"] = "Complete %1$d Timewalking, Heroic or Mythic |4dungeon:dungeons; this week to unlock your first Great Vault reward.",
    ["firstSlotMore"] = "Complete %1$d more Timewalking, Heroic or Mythic |4dungeon:dungeons; this week to unlock your first Great Vault reward.",
    ["nextSlotMore"] = "Complete %1$d more Timewalking, Heroic or Mythic |4dungeon:dungeons; this week to unlock another Great Vault reward.",
    ["rewardsImprove"] = "Complete Mythic dungeons on level %d or higher to improve your Great Vault rewards.",
    ["rewardsMaxed"] = "Good job - You are done! There are no more rewards to improve. Time to work on your rating?",
  },
  [Enum.WeeklyRewardChestThresholdType.World] = {
    ["objective"] = "|4activity:activities;",
    ["default"] = "Complete delves or world activities this week to unlock your first Great Vault reward.",
    ["firstSlotStart"] = "Complete %1$d |4delve or world activity:delves or world activities; this week to unlock your first Great Vault reward.",
    ["firstSlotMore"] = "Complete %1$d more |4delve or world activity:delves or world activities; this week to unlock your first Great Vault reward.",
    ["nextSlotMore"] = "Complete %1$d more |4delve or world activity:delves or world activities; this week to unlock another Great Vault reward.",
    ["rewardsImprove"] = "Complete delves on tier %d or higher to improve your Great Vault rewards.",
    ["rewardsMaxed"] = "Good job - You are done! There are no more rewards to improve.",
  },
}

---Print vault progress to tooltip
---@param infoFrame Frame
---@param character AE_Character
---@param activityType Enum.WeeklyRewardChestThresholdType
local function getVaultProgressTooltip(infoFrame, character, activityType)
  local loggedCharacter = addon.Data:GetCharacter()
  local difficulties = addon.Data:GetRaidDifficulties(true)
  local dungeons = addon.Data:GetDungeons()
  local raids = addon.Data:GetRaids()
  local activities = addon.Utils:TableFilter(character.vault.slots or {}, function(activity) return activity.type and activity.type == activityType end)
  local numActivities = addon.Utils:TableCount(activities)
  local activitiesInProgress = addon.Utils:TableFilter(activities, function(slot) return slot.progress < slot.threshold end)
  local numActivitiesInProgress = addon.Utils:TableCount(activitiesInProgress)
  table.sort(activities, function(a, b) return a.index < b.index end)
  table.sort(activitiesInProgress, function(a, b) return a.threshold < b.threshold end)
  local vaultTooltipText = vaultTooltipTexts[activityType]
  local numHeroic = 0
  local numMythic = 0
  local numMythicPlus = 0

  if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
    numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
    numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
    numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
  end

  GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
  GameTooltip:AddLine("Vault Progress", 1, 1, 1)

  do -- Activity Progress
    for i = 1, 3 do
      local textLeft = format("Vault Slot %d:", i)
      local textRight = "Locked"
      local color = LIGHTGRAY_FONT_COLOR
      local rewardItemLevel = "?"

      local activity = addon.Utils:TableGet(activities, "index", i)
      if activity then
        textLeft = format("%d %s:", activity.threshold, string.lower(activity.type and vaultTooltipTexts[activity.type] and vaultTooltipTexts[activity.type]["objective"] or vaultTooltipText["objective"]))
        if activity.progress >= activity.threshold then
          textRight = "Unlocked"
          color = WHITE_FONT_COLOR

          -- Difficulty name
          if activity.type == Enum.WeeklyRewardChestThresholdType.Raid then
            local difficultyName = GetDifficultyInfo(activity.level)
            local dataDifficulty = addon.Utils:TableGet(difficulties, "id", activity.level)
            if dataDifficulty then
              textRight = dataDifficulty.short and dataDifficulty.short or dataDifficulty.name
            elseif difficultyName then
              textRight = difficultyName
            end
          elseif activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
            if isCompletedAtHeroicLevel(activity.activityTierID) then
              textRight = WEEKLY_REWARDS_HEROIC
            else
              textRight = WEEKLY_REWARDS_MYTHIC:format(activity.level)
            end
          elseif activity.type == Enum.WeeklyRewardChestThresholdType.World then
            textRight = GREAT_VAULT_WORLD_TIER:format(activity.level)
          end

          -- Reward iLvl
          if activity.exampleRewardLink ~= nil and activity.exampleRewardLink ~= "" then
            local detailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo(activity.exampleRewardLink)
            if detailedItemLevelInfo then
              rewardItemLevel = tostring(detailedItemLevelInfo)
            end
          end

          textRight = format("%s (%d+)", textRight, rewardItemLevel)
        else
          textRight = format("Locked (%d/%d)", activity.progress, activity.threshold)
        end
      else
        -- Get activity threshold and objective from logged in character since current character is missing vault activity data
        local activityInfo = addon.Utils:TableFind(loggedCharacter and loggedCharacter.vault and loggedCharacter.vault.slots or {}, function(slot) return slot.type == activityType and slot.index == i end)
        if activityInfo then
          textLeft = format("%d %s:", activityInfo.threshold, string.lower(activityInfo.type and vaultTooltipTexts[activityInfo.type] and vaultTooltipTexts[activityInfo.type]["objective"] or vaultTooltipText["objective"]))
          textRight = format("Locked (%d/%d)", 0, activityInfo.threshold)
        end
      end
      GameTooltip:AddDoubleLine(textLeft, textRight, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
    end
  end

  do -- Raid stats
    if activityType == Enum.WeeklyRewardChestThresholdType.Raid then
      local raidInstanceID = nil
      local activityEncounterInfo = character.vault.activityEncounterInfo or {}
      addon.Utils:TableForEach(raids, function(raid)
        if raidInstanceID ~= raid.instanceID then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(raid.name, 1, 1, 1)
        end

        addon.Utils:TableForEach(raid.encounters or {}, function(encounter)
          local bestDifficulty = nil
          local color = DISABLED_FONT_COLOR
          local difficultyName = "-"

          local encounterInfo = addon.Utils:TableFind(activityEncounterInfo, function(activityEncounter)
            return activityEncounter.instanceID == raid.journalInstanceID and activityEncounter.encounterID == encounter.journalEncounterID and activityEncounter.index == 1
          end)

          if encounterInfo and encounterInfo.bestDifficulty then
            bestDifficulty = addon.Utils:TableGet(difficulties, "id", encounterInfo.bestDifficulty)
          end

          if bestDifficulty then
            color = GREEN_FONT_COLOR
            difficultyName = bestDifficulty.short and bestDifficulty.short or bestDifficulty.name
          end

          GameTooltip:AddDoubleLine(encounter.name, difficultyName, color.r, color.g, color.b, color.r, color.g, color.b)
        end)

        raidInstanceID = raid.instanceID
      end)
    end
  end

  do -- Dungeon stats
    if activityType == Enum.WeeklyRewardChestThresholdType.Activities then
      if numHeroic + numMythic + numMythicPlus > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Total Runs This Week:")
        if numHeroic > 0 then
          GameTooltip:AddDoubleLine("Heroic", tostring(numHeroic), 1, 1, 1, 1, 1, 1)
        end
        if numMythic > 0 then
          GameTooltip:AddDoubleLine("Mythic", tostring(numMythic), 1, 1, 1, 1, 1, 1)
        end
        if numMythicPlus > 0 then
          GameTooltip:AddDoubleLine("Mythic+", tostring(numMythicPlus), 1, 1, 1, 1, 1, 1)
        end
      end
    end
  end

  do -- Dungeon runs
    if activityType == Enum.WeeklyRewardChestThresholdType.Activities then
      local runsThisWeek = addon.Utils:TableFilter(character.mythicplus.runHistory or {}, function(run) return run.thisWeek == true end)
      local numRunsThisWeek = addon.Utils:TableCount(runsThisWeek)
      local numMaxRuns = vaultMaxNumRunsMythic
      table.sort(runsThisWeek, function(a, b) return a.level > b.level end)

      if numRunsThisWeek + numHeroic + numMythic > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Top Runs This Week:")
      end

      -- Detect max runs needed
      local lastActivity = activities[numActivities]
      if lastActivity then
        numMaxRuns = lastActivity.threshold
      end
      local missingRuns = numMaxRuns - numRunsThisWeek

      if numRunsThisWeek > 0 then
        addon.Utils:TableForEach(runsThisWeek, function(run, i)
          if i > numMaxRuns then return end
          local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
          local dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", run.mapChallengeModeID)
          local dungeonName = "Mythic+"
          local color = WHITE_FONT_COLOR
          local matchesThreshold = addon.Utils:TableFind(character.vault.slots or {}, function(activity)
            return activity.type and activity.type == activityType and activity.threshold and activity.threshold == i
          end)
          if matchesThreshold then
            color = GREEN_FONT_COLOR
          end
          if dungeon then
            dungeonName = dungeon.short and dungeon.short or dungeon.name
          end
          GameTooltip:AddDoubleLine(dungeonName, string.format("+%d (%d)", run.level, rewardLevel), 1, 1, 1, color.r, color.g, color.b)
        end)
      end

      if missingRuns > 0 then
        local countHeroic = numHeroic
        local countMythic = numMythic
        while countMythic > 0 and missingRuns > 0 do
          GameTooltip:AddLine(format(WEEKLY_REWARDS_MYTHIC, WeeklyRewardsUtil.MythicLevel), 1, 1, 1)
          countMythic = countMythic - 1
          missingRuns = missingRuns - 1
        end
        while countHeroic > 0 and missingRuns > 0 do
          GameTooltip:AddLine(WEEKLY_REWARDS_HEROIC, 1, 1, 1)
          countHeroic = countHeroic - 1
          missingRuns = missingRuns - 1
        end
      end
    end
  end

  do -- Progress instructions
    local text = ""
    if vaultTooltipText then
      if numActivities == 0 then
        text = vaultTooltipText["default"]
      end
      if numActivitiesInProgress > 0 then -- Still unlocking vault slots
        local currentActivityInProgress = activitiesInProgress[1]
        if currentActivityInProgress then
          local missing = currentActivityInProgress.threshold - currentActivityInProgress.progress
          if currentActivityInProgress.index == vaultSlotOneIndex then
            if currentActivityInProgress.progress == 0 then
              text = format(vaultTooltipText["firstSlotStart"], missing)
            else
              text = format(vaultTooltipText["firstSlotMore"], missing)
            end
          else
            text = format(vaultTooltipText["nextSlotMore"], missing)
          end
        end
      elseif numActivities > 0 then -- All slots unlocked: What's next?
        if activityType == Enum.WeeklyRewardChestThresholdType.Raid then
          local activity = activities[numActivities]
          local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(activity.level)
          if nextDifficultyID then
            local difficulty = addon.Utils:TableGet(difficulties, "id", nextDifficultyID)
            if difficulty then
              text = format(vaultTooltipText["rewardsImprove"], difficulty.name)
            end
          else
            text = vaultTooltipText["rewardsMaxed"]
          end
        elseif activityType == Enum.WeeklyRewardChestThresholdType.Activities then
          local activity = activities[numActivities]
          local level = addon.Utils:GetLowestLevelInTopDungeonRuns(character, activity.threshold)
          if level and level < vaultMaxLevelRewardMythic then
            text = format(vaultTooltipText["rewardsImprove"], WeeklyRewardsUtil.GetNextMythicLevel(level))
          else
            text = vaultTooltipText["rewardsMaxed"]
          end
        elseif activityType == Enum.WeeklyRewardChestThresholdType.World then
          local activity = activities[numActivities]
          if activity then
            if activity.level < vaultMaxLevelRewardWorld then
              text = format(vaultTooltipText["rewardsImprove"], activity.level + 1)
            else
              text = vaultTooltipText["rewardsMaxed"]
            end
          end
        end
      end
      if text ~= "" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Next Step:")
        GameTooltip:AddLine(text, 1, 1, 1, true)
      end
    end
  end
  GameTooltip:Show()
end

local function getVaultProgressValue(character, activityType)
  local difficulties = addon.Data:GetRaidDifficulties(true)
  local activities = addon.Utils:TableFilter(character.vault.slots or {}, function(activity) return activity.type and activity.type == activityType end)
  local texts = {}

  for i = 1, 3 do
    local text = "-"
    local color = LIGHTGRAY_FONT_COLOR

    local activity = addon.Utils:TableGet(activities, "index", i)
    if activity and activity.progress >= activity.threshold then
      text = "?"
      color = UNCOMMON_GREEN_COLOR

      if activityType == Enum.WeeklyRewardChestThresholdType.Raid then
        local dataDifficulty = addon.Utils:TableGet(difficulties, "id", activity.level)
        local difficultyName = GetDifficultyInfo(activity.level)
        if difficultyName then
          text = difficultyName
        end
        if dataDifficulty then
          text = dataDifficulty.abbr and dataDifficulty.abbr or dataDifficulty.name
          if addon.Data.db.global.raids.colors and dataDifficulty.color then
            color = dataDifficulty.color
          end
        end

        text = tostring(text):sub(1, 1)
      elseif activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
        if isCompletedAtHeroicLevel(activity.activityTierID) then
          text = WEEKLY_REWARDS_HEROIC:sub(1, 1)
        else
          text = tostring(activity.level)
        end
      elseif activity.type == Enum.WeeklyRewardChestThresholdType.World then
        text = tostring(activity.level)
      end
    end

    table.insert(texts, color:WrapTextInColorCode(text))
  end

  return table.concat(texts, "  ")
end

---Get character rows for the grid
---@param unfiltered boolean?
---@return AE_CharacterRows[]
function UI:GetCharacterInfo(unfiltered)
  local dungeons = addon.Data:GetDungeons()
  local difficulties = addon.Data:GetRaidDifficulties(true)
  local _, seasonDisplayID = addon.Data:GetCurrentSeason()

  ---@type AE_CharacterRows[]
  local rows = {
    {
      label = CHARACTER,
      value = function(character)
        local name = "-"
        local nameColor = "ffffffff"
        if character.info.name ~= nil then
          name = character.info.name
        end
        if character.info.class.file ~= nil then
          local classColor = C_ClassColor.GetClassColor(character.info.class.file)
          if classColor ~= nil then
            nameColor = classColor.GenerateHexColor(classColor)
          end
        end
        return "|c" .. nameColor .. name .. "|r"
      end,
      onEnter = function(infoFrame, character)
        local name = "-"
        local nameColor = "ffffffff"
        local characterCurrencies = {}
        if character.info.name ~= nil then
          name = character.info.name
        end
        if character.info.class.file ~= nil then
          local classColor = C_ClassColor.GetClassColor(character.info.class.file)
          if classColor ~= nil then
            nameColor = classColor.GenerateHexColor(classColor)
          end
        end
        name = "|c" .. nameColor .. name .. "|r"
        if not addon.Data.db.global.showRealms then
          name = name .. format(" (%s)", character.info.realm)
        end
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine(name, 1, 1, 1)
        GameTooltip:AddLine(format("Level %d %s", character.info.level, character.info.race ~= nil and character.info.race.name or ""), 1, 1, 1)
        if character.info.factionGroup ~= nil and character.info.factionGroup.localized ~= nil then
          GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1)
        end
        if character.money ~= nil then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(GetMoneyString(character.money, true), 1, 1, 1)
        end
        if character.currencies ~= nil and addon.Utils:TableCount(character.currencies) > 0 then
          local dataCurrencies = addon.Data:GetCurrencies()
          addon.Utils:TableForEach(dataCurrencies, function(dataCurrency)
            local characterCurrency = addon.Utils:TableGet(character.currencies, "id", dataCurrency.id)
            if characterCurrency then
              local icon = CreateSimpleTextureMarkup(characterCurrency.iconFileID or [[Interface\Icons\INV_Misc_QuestionMark]])
              local currencyLabel = format("%s %s", icon, characterCurrency.maxQuantity > 0 and math.min(characterCurrency.quantity, characterCurrency.maxQuantity) or characterCurrency.quantity)
              local currencyValue = ""
              if characterCurrency.useTotalEarnedForMaxQty then
                if characterCurrency.maxQuantity > 0 then
                  currencyValue = format("%d/%d", characterCurrency.totalEarned, characterCurrency.maxQuantity)
                else
                  currencyValue = "No limit"
                end
              elseif characterCurrency.maxQuantity > 0 then
                currencyValue = characterCurrency.maxQuantity
              end
              table.insert(characterCurrencies, {
                currencyLabel,
                currencyValue,
              })
            end
          end)
        end
        if addon.Utils:TableCount(characterCurrencies) > 0 then
          GameTooltip:AddLine(" ")
          GameTooltip:AddDoubleLine("Currencies:", "Maximum:")
          addon.Utils:TableForEach(characterCurrencies, function(characterCurrency)
            GameTooltip:AddDoubleLine(characterCurrency[1], characterCurrency[2], 1, 1, 1, 1, 1, 1)
          end)
        end
        if character.lastUpdate ~= nil then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(format("Last update:\n|cffffffff%s|r", date("%c", character.lastUpdate)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        end
        if type(character.equipment) == "table" then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Click to View Equipment>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      onClick = function(infoFrame, character)
        local window = addon.Window:GetWindow("Equipment")
        if not window then return end
        if self.equipmentCharacter and self.equipmentCharacter == character and window:IsVisible() then
          window:Hide()
          return
        end
        self.equipmentCharacter = character
        self:RenderEquipmentWindow()
        window:Show()
      end,
      enabled = true,
    },
    {
      label = "Realm",
      value = function(character)
        local realm = "-"
        local realmColor = LIGHTGRAY_FONT_COLOR
        if character.info.realm ~= nil then
          realm = character.info.realm
          realmColor = WHITE_FONT_COLOR
        end
        return realmColor:WrapTextInColorCode(realm)
      end,
      tooltip = false,
      enabled = addon.Data.db.global.showRealms,
    },
    {
      label = STAT_AVERAGE_ITEM_LEVEL,
      value = function(character)
        local itemLevel = "-"
        local itemLevelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
        if character.info.ilvl ~= nil then
          if character.info.ilvl.level ~= nil then
            itemLevel = tostring(floor(character.info.ilvl.level))
          end
          if character.info.ilvl.color then
            itemLevelColor = character.info.ilvl.color
          else
            itemLevelColor = WHITE_FONT_COLOR:GenerateHexColor()
          end
        end
        return WrapTextInColorCode(itemLevel, itemLevelColor)
      end,
      onEnter = function(infoFrame, character)
        local itemLevelTooltip = ""
        local itemLevelTooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
        if character.info.ilvl ~= nil then
          if character.info.ilvl.level ~= nil then
            itemLevelTooltip = itemLevelTooltip .. HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. floor(character.info.ilvl.level)
          end
          if character.info.ilvl.level ~= nil and character.info.ilvl.equipped ~= nil and character.info.ilvl.level ~= character.info.ilvl.equipped then
            itemLevelTooltip = itemLevelTooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, character.info.ilvl.equipped)
          end
          if character.info.ilvl.level ~= nil then
            itemLevelTooltip = itemLevelTooltip .. FONT_COLOR_CODE_CLOSE
          end
          if character.info.ilvl.level ~= nil and character.info.ilvl.pvp ~= nil and floor(character.info.ilvl.level) ~= character.info.ilvl.pvp then
            itemLevelTooltip2 = itemLevelTooltip2 .. "\n\n" .. STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.info.ilvl.pvp)))
          end
        end
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine(itemLevelTooltip, 1, 1, 1)
        GameTooltip:AddLine(itemLevelTooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      enabled = true,
    },
    {
      label = "Rating",
      value = function(character)
        local rating = "-"
        local ratingColor = LIGHTGRAY_FONT_COLOR
        if character.mythicplus.rating ~= nil then
          rating = tostring(character.mythicplus.rating)
          local color = addon.Utils:GetRatingColor(character.mythicplus.rating, addon.Data.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = color
          else
            ratingColor = WHITE_FONT_COLOR
          end
        end
        return ratingColor:WrapTextInColorCode(rating)
      end,
      onEnter = function(infoFrame, character)
        local rating = "-"
        local ratingColor = WHITE_FONT_COLOR
        local bestSeasonScore = nil
        local bestSeasonScoreColor = WHITE_FONT_COLOR
        local bestSeasonNumber = nil
        local numSeasonRuns = 0
        if character.mythicplus.runHistory ~= nil then
          numSeasonRuns = addon.Utils:TableCount(character.mythicplus.runHistory)
        end
        if character.mythicplus.bestSeasonNumber ~= nil then
          bestSeasonNumber = character.mythicplus.bestSeasonNumber
        end
        if character.mythicplus.bestSeasonScore ~= nil then
          bestSeasonScore = character.mythicplus.bestSeasonScore
          local color = addon.Utils:GetRatingColor(bestSeasonScore, addon.Data.db.global.useRIOScoreColor, bestSeasonNumber ~= nil and bestSeasonNumber < seasonDisplayID)
          if color ~= nil then
            bestSeasonScoreColor = color
          end
        end
        if type(character.mythicplus.rating) == "number" then
          local color = addon.Utils:GetRatingColor(character.mythicplus.rating, addon.Data.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = color
          end
          rating = tostring(character.mythicplus.rating)
        end
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Mythic+ Rating", 1, 1, 1)
        GameTooltip:AddLine(format("Current Season: %s", ratingColor:WrapTextInColorCode(rating)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        GameTooltip:AddLine(format("Runs this Season: %s", WHITE_FONT_COLOR:WrapTextInColorCode(tostring(numSeasonRuns))), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        if bestSeasonNumber ~= nil and bestSeasonScore ~= nil then
          local bestSeasonValue = bestSeasonScoreColor:WrapTextInColorCode(tostring(bestSeasonScore))
          if bestSeasonNumber > 0 then
            local season = LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(format("(Season %s)", bestSeasonNumber))
            bestSeasonValue = format("%s %s", bestSeasonValue, season)
          end
          GameTooltip:AddLine(format("Best Season: %s", bestSeasonValue), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        end
        if character.mythicplus.dungeons ~= nil and addon.Utils:TableCount(character.mythicplus.dungeons) > 0 then
          GameTooltip:AddLine(" ")
          local characterDungeons = CopyTable(character.mythicplus.dungeons)
          for _, dungeon in pairs(characterDungeons) do
            local dungeonName = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeID)
            if dungeonName ~= nil then
              dungeon.name = dungeonName
            else
              dungeon.name = ""
            end
          end
          table.sort(characterDungeons, function(a, b)
            return strcmputf8i(a.name, b.name) < 0
          end)
          for _, dungeon in pairs(characterDungeons) do
            if dungeon.name ~= "" then
              local levelColor = LIGHTGRAY_FONT_COLOR
              local levelValue = "-"
              if dungeon.level > 0 then
                levelColor = WHITE_FONT_COLOR
                levelValue = "+" .. tostring(dungeon.level)
              end
              GameTooltip:AddDoubleLine(dungeon.name, levelValue, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, levelColor.r, levelColor.g, levelColor.b)
            end
          end
          if numSeasonRuns > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          end
        end
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      onClick = function(infoFrame, character)
        local numSeasonRuns = 0
        if character.mythicplus.runHistory ~= nil then
          numSeasonRuns = addon.Utils:TableCount(character.mythicplus.runHistory)
        end
        if character.mythicplus.dungeons ~= nil
          and addon.Utils:TableCount(character.mythicplus.dungeons) > 0
          and numSeasonRuns > 0
          and IsModifiedClick("CHATLINK")
        then
          local dungeonScoreDungeonTable = {}
          for _, dungeon in pairs(character.mythicplus.dungeons) do
            table.insert(dungeonScoreDungeonTable, dungeon.challengeModeID)
            table.insert(dungeonScoreDungeonTable, dungeon.finishedSuccess and 1 or 0)
            table.insert(dungeonScoreDungeonTable, dungeon.level)
          end
          local dungeonScoreTable = {
            character.mythicplus.rating,
            character.GUID,
            character.info.name,
            character.info.class.id,
            math.ceil(character.info.ilvl.level),
            character.info.level,
            numSeasonRuns,
            character.mythicplus.bestSeasonScore,
            character.mythicplus.bestSeasonNumber,
            unpack(dungeonScoreDungeonTable),
          }
          local link = NORMAL_FONT_COLOR:WrapTextInColorCode(LinkUtil.FormatLink("dungeonScore", DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)))
          if not ChatEdit_InsertLink(link) then
            ChatFrame_OpenChat(link)
          end
        end
      end,
      enabled = true,
    },
    {
      label = "Current Keystone",
      value = function(character)
        local currentKeystone = LIGHTGRAY_FONT_COLOR:WrapTextInColorCode("-")
        if character.mythicplus.keystone ~= nil then
          local dungeon
          if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
            dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
          elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
            dungeon = addon.Utils:TableGet(dungeons, "mapId", character.mythicplus.keystone.mapId)
          end
          if dungeon ~= nil then
            currentKeystone = dungeon.abbr
            if type(character.mythicplus.keystone.level) == "number" and character.mythicplus.keystone.level > 0 then
              currentKeystone = format("%s +%s", currentKeystone, tostring(character.mythicplus.keystone.level))
            end
          end
        end
        return currentKeystone
      end,
      onEnter = function(infoFrame, character)
        if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
          GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
          GameTooltip:SetHyperlink(character.mythicplus.keystone.itemLink)
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          GameTooltip:Show()
        end
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      onClick = function(infoFrame, character)
        if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
          if IsModifiedClick("CHATLINK") then
            if not ChatEdit_InsertLink(character.mythicplus.keystone.itemLink) then
              ChatFrame_OpenChat(character.mythicplus.keystone.itemLink)
            end
          end
        end
      end,
      enabled = true,
    },
    {
      label = "Vault",
      value = function(character)
        if character.vault.hasAvailableRewards == true then
          return GREEN_FONT_COLOR:WrapTextInColorCode(QUEST_REWARDS)
        end
        return ""
      end,
      onEnter = function(infoFrame, character)
        if character.vault.hasAvailableRewards == true then
          GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
          GameTooltip:AddLine("It's payday!", WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
          GameTooltip:AddLine(GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)
          GameTooltip:Show()
        end
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      backgroundColor = {r = 0, g = 0, b = 0, a = 0.3},
      enabled = true,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode(RAIDS),
      value = function(character) return getVaultProgressValue(character, Enum.WeeklyRewardChestThresholdType.Raid) end,
      onEnter = function(infoFrame, character) getVaultProgressTooltip(infoFrame, character, Enum.WeeklyRewardChestThresholdType.Raid) end,
      onLeave = function() GameTooltip:Hide() end,
      enabled = addon.Data.db.global.raids.enabled,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode(DUNGEONS),
      value = function(character) return getVaultProgressValue(character, Enum.WeeklyRewardChestThresholdType.Activities) end,
      onEnter = function(infoFrame, character) getVaultProgressTooltip(infoFrame, character, Enum.WeeklyRewardChestThresholdType.Activities) end,
      onLeave = function() GameTooltip:Hide() end,
      enabled = true,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode(WORLD),
      value = function(character) return getVaultProgressValue(character, Enum.WeeklyRewardChestThresholdType.World) end,
      onEnter = function(infoFrame, character) getVaultProgressTooltip(infoFrame, character, Enum.WeeklyRewardChestThresholdType.World) end,
      onLeave = function() GameTooltip:Hide() end,
      enabled = addon.Data.db.global.world and addon.Data.db.global.world.enabled == true,
    },
  }

  if unfiltered then
    return rows
  end

  return addon.Utils:TableFilter(rows, function(info)
    return info.enabled
  end)
end

function UI:RenderMainWindow()
  local currentAffixes = addon.Data:GetCurrentAffixes()
  local activeWeek = addon.Data:GetActiveAffixRotation(currentAffixes)
  local seasonID = addon.Data:GetCurrentSeason()
  local dungeons = addon.Data:GetDungeons()
  local affixRotation = addon.Data:GetAffixRotation()
  local raidDifficulties = addon.Data:GetRaidDifficulties()
  local characterInfo = self:GetCharacterInfo()
  local raids = addon.Data:GetRaids()
  local characters = addon.Data:GetCharacters()
  local numCharacters = addon.Utils:TableCount(characters)
  local affixes = addon.Data:GetAffixes(true)
  local windowWidthMax = addon.Window:GetMaxWindowWidth()
  local windowWidth, windowHeight = numCharacters == 0 and 500 or 0, 0

  if not self.window then
    self.window = addon.Window:New({
      name = "Main",
      title = addonName,
      sidebar = 150,
    })
    self.window.affixes = CreateFrame("Frame", "$parentAffixes", self.window.titlebar)
    self.window.affixes.buttons = {}
    self.window:SetScript("OnShow", function()
      self:Render()
    end)
    self:SetupButtons()
  end

  if not self.window:IsVisible() then
    return
  end

  -- Zero characters
  if not self.window.zeroCharacters then
    self.window.zeroCharacters = self.window:CreateFontString("$parentNoCharacterText", "ARTWORK")
    self.window.zeroCharacters:SetPoint("TOPLEFT", self.window, "TOPLEFT", 50, -50)
    self.window.zeroCharacters:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", -50, 50)
    self.window.zeroCharacters:SetJustifyH("CENTER")
    self.window.zeroCharacters:SetJustifyV("MIDDLE")
    self.window.zeroCharacters:SetFontObject("GameFontHighlight_NoShadow")
    self.window.zeroCharacters:SetVertexColor(1.0, 0.82, 0.0, 1)
    self.window.zeroCharacters:Hide()
  end

  if not self.window.body.scrollparent then
    self.window.body.scrollparent = CreateFrame("ScrollFrame", "$parentScrollFrame", self.window.body)
    self.window.body.scrollparent:SetAllPoints()
    self.window.body.scrollparent.scrollchild = CreateFrame("Frame", "$parentScrollChild", self.window.body.scrollparent)
    self.window.body.scrollparent:SetScrollChild(self.window.body.scrollparent.scrollchild)
    self.window.body.scrollbar = CreateFrame("Slider", "$parentScrollbar", self.window.body, "UISliderTemplate")
    self.window.body.scrollbar:SetPoint("BOTTOMLEFT", self.window.body, "BOTTOMLEFT", 0, 0)
    self.window.body.scrollbar:SetPoint("BOTTOMRIGHT", self.window.body, "BOTTOMRIGHT", 0, 0)
    self.window.body.scrollbar:SetHeight(6)
    self.window.body.scrollbar:SetMinMaxValues(0, 100)
    self.window.body.scrollbar:SetValue(0)
    self.window.body.scrollbar:SetValueStep(1)
    self.window.body.scrollbar:SetOrientation("HORIZONTAL")
    self.window.body.scrollbar:SetObeyStepOnDrag(true)
    if self.window.body.scrollbar.NineSlice then
      self.window.body.scrollbar.NineSlice:Hide()
    end
    self.window.body.scrollbar.thumb = self.window.body.scrollbar:GetThumbTexture()
    self.window.body.scrollbar.thumb:SetPoint("CENTER")
    self.window.body.scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
    self.window.body.scrollbar.thumb:SetHeight(10)
    self.window.body.scrollbar:SetScript("OnValueChanged", function(_, value)
      self.window.body.scrollparent:SetHorizontalScroll(value)
    end)
    self.window.body.scrollbar:SetScript("OnEnter", function()
      self.window.body.scrollbar.thumb:SetColorTexture(1, 1, 1, 0.2)
    end)
    self.window.body.scrollbar:SetScript("OnLeave", function()
      self.window.body.scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
    end)
    self.window.body.scrollparent:SetScript("OnMouseWheel", function(_, delta)
      self.window.body.scrollbar:SetValue(self.window.body.scrollbar:GetValue() - delta * ((self.window.body.scrollparent.scrollchild:GetWidth() - self.window.body.scrollparent:GetWidth()) * 0.1))
    end)
  end

  do -- Titlebar: Affixes
    if numCharacters < 3 then
      self.window.titlebar.title:Hide()
    else
      self.window.titlebar.title:Show()
    end

    if currentAffixes and addon.Utils:TableCount(currentAffixes) > 0 and addon.Data.db.global.showAffixHeader then
      if numCharacters < 2 then
        self.window.affixes:Hide()
      else
        self.window.affixes:Show()
      end
    else
      self.window.affixes:Hide()
    end

    if self.window.affixes:IsVisible() then
      local affixAnchor = self.window.titlebar
      addon.Utils:TableForEach(currentAffixes, function(affix, affixIndex)
        local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(affix.id)
        local affixFrame = self.window.affixes.buttons[affixIndex]
        if not affixFrame then
          affixFrame = CreateFrame("Button", "$parentAffix" .. affixIndex, self.window.affixes)
          self.window.affixes.buttons[affixIndex] = affixFrame
        end

        affixFrame:ClearAllPoints()
        affixFrame:SetSize(20, 20)
        affixFrame:SetNormalTexture(fileDataID)
        affixFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(affixFrame, "ANCHOR_TOP")
          GameTooltip:SetText(name, 1, 1, 1)
          GameTooltip:AddLine(desc, nil, nil, nil, true)
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Click to View Weekly Affixes>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          GameTooltip:Show()
        end)
        affixFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)
        affixFrame:SetScript("OnClick", function()
          addon.Window:ToggleWindow("Affixes")
        end)

        if affixIndex == 1 then
          affixFrame:ClearAllPoints()
          if numCharacters < 3 then
            affixFrame:SetPoint("LEFT", self.window.titlebar.icon, "RIGHT", 6, 0)
          else
            affixFrame:SetPoint("CENTER", affixAnchor, "CENTER", -((addon.Utils:TableCount(currentAffixes) * 20) / 2), 0)
          end
        else
          affixFrame:SetPoint("LEFT", affixAnchor, "RIGHT", 6, 0)
        end
        affixAnchor = affixFrame
      end)
    end
  end

  do   -- Sidebar
    local rowCount = 0
    do -- CharacterInfo Labels
      self.window.sidebar.infoFrames = self.window.sidebar.infoFrames or {}
      addon.Utils:TableForEach(self.window.sidebar.infoFrames, function(f) f:Hide() end)
      addon.Utils:TableForEach(characterInfo, function(info, infoIndex)
        local infoFrame = self.window.sidebar.infoFrames[infoIndex]
        if not infoFrame then
          infoFrame = CreateFrame("Frame", "$parentInfo" .. infoIndex, self.window.sidebar)
          infoFrame.text = infoFrame:CreateFontString(infoFrame:GetName() .. "Text", "OVERLAY")
          infoFrame.text:SetPoint("LEFT", infoFrame, "LEFT", addon.Constants.sizes.padding, 0)
          infoFrame.text:SetPoint("RIGHT", infoFrame, "RIGHT", -addon.Constants.sizes.padding, 0)
          infoFrame.text:SetJustifyH("LEFT")
          infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          infoFrame.text:SetVertexColor(1.0, 0.82, 0.0, 1)
          self.window.sidebar.infoFrames[infoIndex] = infoFrame
        end

        infoFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
        infoFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
        infoFrame:SetHeight(addon.Constants.sizes.row)
        infoFrame.text:SetText(info.label)
        infoFrame:Show()
        rowCount = rowCount + 1
      end)
    end

    do -- MythicPlus Header
      local label = self.window.sidebar.mpluslabel
      if not label then
        label = CreateFrame("Frame", "$parentMythicPlusLabel", self.window.sidebar)
        label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
        label.text:SetPoint("TOPLEFT", label, "TOPLEFT", addon.Constants.sizes.padding, 0)
        label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -addon.Constants.sizes.padding, 0)
        label.text:SetFontObject("GameFontHighlight_NoShadow")
        label.text:SetJustifyH("LEFT")
        label.text:SetText("Mythic Plus")
        label.text:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.window.sidebar.mpluslabel = label
      end

      label:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
      label:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
      label:SetHeight(addon.Constants.sizes.row)
      label:Show()
      rowCount = rowCount + 1
    end

    do -- MythicPlus Labels
      self.window.sidebar.mpluslabels = self.window.sidebar.mpluslabels or {}
      addon.Utils:TableForEach(self.window.sidebar.mpluslabels, function(f) f:Hide() end)
      addon.Utils:TableForEach(dungeons, function(dungeon, dungeonIndex)
        local dungeonFrame = self.window.sidebar.mpluslabels[dungeonIndex]
        if not dungeonFrame then
          dungeonFrame = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, self.window.sidebar, "InsecureActionButtonTemplate")
          dungeonFrame:RegisterForClicks("AnyUp", "AnyDown")
          dungeonFrame:EnableMouse(true)
          dungeonFrame.icon = dungeonFrame:CreateTexture(dungeonFrame:GetName() .. "Icon", "ARTWORK")
          dungeonFrame.icon:SetSize(16, 16)
          dungeonFrame.icon:SetPoint("LEFT", dungeonFrame, "LEFT", addon.Constants.sizes.padding, 0)
          dungeonFrame.text = dungeonFrame:CreateFontString(dungeonFrame:GetName() .. "Text", "OVERLAY")
          dungeonFrame.text:SetPoint("TOPLEFT", dungeonFrame, "TOPLEFT", 16 + addon.Constants.sizes.padding * 2, -3)
          dungeonFrame.text:SetPoint("BOTTOMRIGHT", dungeonFrame, "BOTTOMRIGHT", -addon.Constants.sizes.padding, 3)
          dungeonFrame.text:SetJustifyH("LEFT")
          dungeonFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          self.window.sidebar.mpluslabels[dungeonIndex] = dungeonFrame
        end

        local knownTeleportSpellID = addon.Utils:TableFind(dungeon.teleports or {}, function(spellID)
          return IsSpellKnown(spellID)
        end)

        if knownTeleportSpellID then
          if not InCombatLockdown() then
            dungeonFrame:SetAttribute("type", "spell")
            dungeonFrame:SetAttribute("spell", knownTeleportSpellID)
          end
        else
          -- TODO: Unset spell attribute? It's not like the dungeon pool changes during a session
        end

        dungeonFrame:SetScript("OnEnter", function()
          ---@diagnostic disable-next-line: param-type-mismatch
          GameTooltip:SetOwner(dungeonFrame, "ANCHOR_RIGHT")
          GameTooltip:SetText(dungeon.name, 1, 1, 1)
          if knownTeleportSpellID then
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(knownTeleportSpellID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Click to Teleport>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            _G[GameTooltip:GetName() .. "TextLeft1"]:SetText(dungeon.name)
          else
            GameTooltip:AddLine(format("Time this dungeon on level %d or above to unlock teleportation.", dungeonPortalUnlockLevel), nil, nil, nil, true)
          end
          GameTooltip:Show()
        end)
        dungeonFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)

        dungeonFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
        dungeonFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
        dungeonFrame:SetHeight(addon.Constants.sizes.row)
        dungeonFrame.icon:SetTexture(tostring(dungeon.texture))
        dungeonFrame.text:SetText(dungeon.short and dungeon.short or dungeon.name)
        dungeonFrame:Show()
        rowCount = rowCount + 1
      end)

      do -- Raid Labels
        self.window.sidebar.raidFrames = self.window.sidebar.raidFrames or {}
        -- self.window.sidebar.difficultyFrames = self.window.sidebar.difficultyFrames or {}
        addon.Utils:TableForEach(self.window.sidebar.raidFrames, function(f) f:Hide() end)
        -- addon.Utils:TableForEach(self.window.sidebar.difficultyFrames, function(f) f:Hide() end)
        if addon.Data.db.global.raids.enabled then
          addon.Utils:TableForEach(raids, function(raid, raidIndex)
            local raidFrame = self.window.sidebar.raidFrames[raidIndex]
            if not raidFrame then
              raidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, self.window.sidebar)
              raidFrame.difficultyFrames = {}
              raidFrame.text = raidFrame:CreateFontString(raidFrame:GetName() .. "Text", "OVERLAY")
              raidFrame.text:SetPoint("LEFT", raidFrame, "LEFT", addon.Constants.sizes.padding, 0)
              raidFrame.text:SetFontObject("GameFontHighlight_NoShadow")
              raidFrame.text:SetJustifyH("LEFT")
              raidFrame.text:SetWordWrap(false)
              raidFrame.text:SetVertexColor(1.0, 0.82, 0.0, 1)
              raidFrame.ModifiedIcon = raidFrame:CreateTexture("$parentModifiedIcon", "ARTWORK")
              raidFrame.ModifiedIcon:SetSize(18, 18)
              raidFrame.ModifiedIcon:SetPoint("RIGHT", raidFrame, "RIGHT", -(addon.Constants.sizes.padding / 2), 0)
              self.window.sidebar.raidFrames[raidIndex] = raidFrame
            end

            raidFrame:SetScript("OnEnter", function()
              GameTooltip:SetOwner(raidFrame, "ANCHOR_RIGHT")
              GameTooltip:SetText(raid.name, 1, 1, 1)
              if raid.modifiedInstanceInfo and raid.modifiedInstanceInfo.description then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(raid.modifiedInstanceInfo.description)
              end
              GameTooltip:Show()
            end)
            raidFrame:SetScript("OnLeave", function()
              GameTooltip:Hide()
            end)

            if raid.modifiedInstanceInfo and raid.modifiedInstanceInfo.uiTextureKit then
              raidFrame.ModifiedIcon:SetAtlas(GetFinalNameFromTextureKit("%s-small", raid.modifiedInstanceInfo.uiTextureKit))
              raidFrame.ModifiedIcon:Show()
              raidFrame.text:SetPoint("RIGHT", raidFrame.ModifiedIcon, "LEFT", -(addon.Constants.sizes.padding / 2), 0)
            else
              raidFrame.ModifiedIcon:Hide()
              raidFrame.text:SetPoint("RIGHT", raidFrame, "RIGHT", -addon.Constants.sizes.padding, 0)
            end

            raidFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
            raidFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
            raidFrame:SetHeight(addon.Constants.sizes.row)
            raidFrame.text:SetText(raid.short and raid.short or raid.name)
            raidFrame:Show()
            rowCount = rowCount + 1

            -- Difficulties
            addon.Utils:TableForEach(raidFrame.difficultyFrames, function(f) f:Hide() end)
            addon.Utils:TableForEach(raidDifficulties, function(difficulty, difficultyIndex)
              local difficultyFrame = raidFrame.difficultyFrames[difficultyIndex]
              if not difficultyFrame then
                difficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, raidFrame)
                difficultyFrame.text = difficultyFrame:CreateFontString(difficultyFrame:GetName() .. "Text", "OVERLAY")
                difficultyFrame.text:SetPoint("TOPLEFT", difficultyFrame, "TOPLEFT", addon.Constants.sizes.padding, -3)
                difficultyFrame.text:SetPoint("BOTTOMRIGHT", difficultyFrame, "BOTTOMRIGHT", -addon.Constants.sizes.padding, 3)
                difficultyFrame.text:SetJustifyH("LEFT")
                difficultyFrame.text:SetFontObject("GameFontHighlight_NoShadow")
                raidFrame.difficultyFrames[difficultyIndex] = difficultyFrame
              end

              difficultyFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(difficulty.name, 1, 1, 1)
                GameTooltip:Show()
              end)
              difficultyFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
              end)

              difficultyFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
              difficultyFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
              difficultyFrame:SetHeight(addon.Constants.sizes.row)
              difficultyFrame.text:SetText(difficulty.short and difficulty.short or difficulty.name)
              difficultyFrame:Show()
              rowCount = rowCount + 1
            end)
          end)
        end
      end
    end
    windowHeight = windowHeight + rowCount * addon.Constants.sizes.row
  end

  do -- Characrer Columns
    self.window.characterFrames = self.window.characterFrames or {}
    addon.Utils:TableForEach(self.window.characterFrames, function(f) f:Hide() end)
    addon.Utils:TableForEach(characters, function(character, characterIndex)
      local rowCount = 0
      local characterFrame = self.window.characterFrames[characterIndex]
      if not characterFrame then
        characterFrame = CreateFrame("Frame", "$parentCharacterColumn" .. characterIndex, self.window.body.scrollparent.scrollchild)
        characterFrame.infoFrames = {}
        characterFrame.dungeonFrames = {}
        characterFrame.raidFrames = {}
        characterFrame.affixHeaderFrame = CreateFrame("Frame", "$parentAffixes", characterFrame)
        self.window.characterFrames[characterIndex] = characterFrame
      end

      characterFrame:SetPoint("TOPLEFT", self.window.body.scrollparent.scrollchild, "TOPLEFT", (characterIndex - 1) * CHARACTER_WIDTH, 0)
      characterFrame:SetPoint("BOTTOMLEFT", self.window.body.scrollparent.scrollchild, "BOTTOMLEFT", (characterIndex - 1) * CHARACTER_WIDTH, 0)
      characterFrame:SetWidth(CHARACTER_WIDTH)
      addon.Utils:SetBackgroundColor(characterFrame, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
      characterFrame:Show()

      do -- Info
        addon.Utils:TableForEach(characterFrame.infoFrames, function(f) f:Hide() end)
        addon.Utils:TableForEach(characterInfo, function(info, infoIndex)
          local infoFrame = characterFrame.infoFrames[infoIndex]
          if not infoFrame then
            infoFrame = CreateFrame("Button", "$parentInfo" .. infoIndex, characterFrame)
            infoFrame.text = infoFrame:CreateFontString(infoFrame:GetName() .. "Text", "OVERLAY")
            infoFrame.text:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", addon.Constants.sizes.padding * 1.5, -addon.Constants.sizes.padding)
            infoFrame.text:SetPoint("BOTTOMRIGHT", infoFrame, "BOTTOMRIGHT", -addon.Constants.sizes.padding * 1.5, addon.Constants.sizes.padding)
            infoFrame.text:SetJustifyH("CENTER")
            infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            characterFrame.infoFrames[infoIndex] = infoFrame
          end

          if infoIndex == 1 then
            if not infoFrame.SortLeftButton then
              infoFrame.SortLeftButton = CreateFrame("Button", infoFrame:GetName() .. "SortLeft", infoFrame)
              infoFrame.SortLeftButton:SetSize(addon.Constants.sizes.row, addon.Constants.sizes.row)
              infoFrame.SortLeftButton:SetPoint("LEFT", infoFrame, "LEFT")
              infoFrame.SortLeftButton:SetPropagateMouseMotion(true)
              infoFrame.SortLeftButton.Icon = infoFrame.SortLeftButton:CreateTexture(infoFrame.SortLeftButton:GetName() .. "Icon", "ARTWORK")
              infoFrame.SortLeftButton.Icon:SetAtlas("common-icon-backarrow", true)
              infoFrame.SortLeftButton.Icon:SetDesaturation(1)
              infoFrame.SortLeftButton.Icon:SetSize(12, 12)
              infoFrame.SortLeftButton.Icon:SetPoint("CENTER", infoFrame.SortLeftButton, "CENTER", 0, 0)
              infoFrame.SortLeftButton:Hide()
            end
            infoFrame.SortLeftButton:SetScript("OnEnter", function()
              if info.onLeave then
                info.onLeave(infoFrame, character)
              end
              infoFrame.SortLeftButton.Icon:SetDesaturation(0)
              GameTooltip:SetOwner(infoFrame.SortLeftButton, "ANCHOR_RIGHT")
              GameTooltip:SetText("Custom Order", 1, 1, 1, 1, true)
              GameTooltip:AddLine("Move your character around.")
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Click to Move Left>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
              GameTooltip:Show()
            end)
            infoFrame.SortLeftButton:SetScript("OnLeave", function()
              infoFrame.SortLeftButton.Icon:SetDesaturation(1)
              GameTooltip:Hide()
              if info.onEnter then
                info.onEnter(infoFrame, character)
              end
            end)
            infoFrame.SortLeftButton:SetScript("OnClick", function()
              addon.Data:SortCharacter(character, -1)
              self:RenderMainWindow()
            end)
            if not infoFrame.SortRightButton then
              infoFrame.SortRightButton = CreateFrame("Button", infoFrame:GetName() .. "SortRight", infoFrame)
              infoFrame.SortRightButton:SetSize(addon.Constants.sizes.row, addon.Constants.sizes.row)
              infoFrame.SortRightButton:SetPoint("RIGHT", infoFrame, "RIGHT")
              infoFrame.SortRightButton:SetPropagateMouseMotion(true)
              infoFrame.SortRightButton.Icon = infoFrame.SortRightButton:CreateTexture(infoFrame.SortRightButton:GetName() .. "Icon", "ARTWORK")
              infoFrame.SortRightButton.Icon:SetAtlas("common-icon-forwardarrow", true)
              infoFrame.SortRightButton.Icon:SetDesaturation(1)
              infoFrame.SortRightButton.Icon:SetSize(12, 12)
              infoFrame.SortRightButton.Icon:SetPoint("CENTER", infoFrame.SortRightButton, "CENTER", 0, 0)
              infoFrame.SortRightButton:Hide()
            end
            infoFrame.SortRightButton:SetScript("OnEnter", function()
              if info.onLeave then
                info.onLeave(infoFrame, character)
              end
              infoFrame.SortRightButton.Icon:SetDesaturation(0)
              GameTooltip:SetOwner(infoFrame.SortRightButton, "ANCHOR_RIGHT")
              GameTooltip:SetText("Custom Order", 1, 1, 1, 1, true)
              GameTooltip:AddLine("Move your character around.")
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Click to Move Right>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
              GameTooltip:Show()
            end)
            infoFrame.SortRightButton:SetScript("OnLeave", function()
              infoFrame.SortRightButton.Icon:SetDesaturation(1)
              GameTooltip:Hide()
              if info.onEnter then
                info.onEnter(infoFrame, character)
              end
            end)
            infoFrame.SortRightButton:SetScript("OnClick", function()
              addon.Data:SortCharacter(character, 1)
              self:RenderMainWindow()
            end)
          end

          if info.value then
            infoFrame.text:SetText(info.value(character))
          end

          if info.backgroundColor then
            addon.Utils:SetBackgroundColor(infoFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
          else
            addon.Utils:SetBackgroundColor(infoFrame, 0, 0, 0, 0)
          end

          infoFrame:SetScript("OnEnter", function()
            if info.onEnter then
              info.onEnter(infoFrame, character)
            end
            if infoIndex == 1 then
              if addon.Data.db.global.sorting == "custom" then
                if characterIndex > 1 then
                  infoFrame.SortLeftButton:Show()
                else
                  infoFrame.SortLeftButton:Hide()
                end
                if characterIndex < numCharacters then
                  infoFrame.SortRightButton:Show()
                else
                  infoFrame.SortRightButton:Hide()
                end
              else
                infoFrame.SortLeftButton:Hide()
                infoFrame.SortRightButton:Hide()
              end
            end
            if not info.backgroundColor then
              addon.Utils:SetHighlightColor(infoFrame)
            end
          end)

          infoFrame:SetScript("OnLeave", function()
            if info.onLeave then
              info.onLeave(infoFrame, character)
            end

            if infoIndex == 1 then
              infoFrame.SortLeftButton:Hide()
              infoFrame.SortRightButton:Hide()
            end

            if not info.backgroundColor then
              addon.Utils:SetHighlightColor(infoFrame, 1, 1, 1, 0)
            end
          end)

          infoFrame:SetScript("OnClick", function()
            if info.onClick then
              info.onClick(infoFrame, character)
            end
          end)

          infoFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
          infoFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
          infoFrame:SetHeight(addon.Constants.sizes.row)
          infoFrame:Show()
          rowCount = rowCount + 1
        end)
      end

      do -- Dungeon Header
        characterFrame.affixHeaderFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
        characterFrame.affixHeaderFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
        characterFrame.affixHeaderFrame:SetHeight(addon.Constants.sizes.row)
        addon.Utils:SetBackgroundColor(characterFrame.affixHeaderFrame, 0, 0, 0, 0.3)
        rowCount = rowCount + 1
      end

      do -- Dungeons
        addon.Utils:TableForEach(characterFrame.dungeonFrames, function(f) f:Hide() end)
        addon.Utils:TableForEach(dungeons, function(dungeon, dungeonIndex)
          local dungeonFrame = characterFrame.dungeonFrames[dungeonIndex]
          if not dungeonFrame then
            dungeonFrame = CreateFrame("Frame", "$parentDungeons" .. dungeonIndex, characterFrame)
            dungeonFrame.Text = dungeonFrame:CreateFontString(dungeonFrame:GetName() .. "Text", "OVERLAY")
            dungeonFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
            dungeonFrame.Tier = dungeonFrame:CreateFontString(dungeonFrame:GetName() .. "Tier", "OVERLAY")
            dungeonFrame.Tier:SetPoint("LEFT", dungeonFrame.Text, "RIGHT", 3, 1)
            dungeonFrame.Tier:SetJustifyH("LEFT")
            dungeonFrame.Tier:SetFontObject("GameFontHighlight_NoShadow")
            dungeonFrame.Score = dungeonFrame:CreateFontString(dungeonFrame:GetName() .. "Score", "OVERLAY")
            dungeonFrame.Score:SetPoint("RIGHT", dungeonFrame, "RIGHT", -addon.Constants.sizes.padding * 2, 1)
            dungeonFrame.Score:SetJustifyH("RIGHT")
            dungeonFrame.Score:SetFontObject("GameFontHighlight_NoShadow")
            characterFrame.dungeonFrames[dungeonIndex] = dungeonFrame
          end

          local affixScores
          local overallScore
          local inTimeInfo
          local overTimeInfo
          local bestAffixScore
          local level = "-"
          local color = HIGHLIGHT_FONT_COLOR
          local tier = ""
          local dungeonLevel = 0

          local characterDungeon = addon.Utils:TableGet(character.mythicplus.dungeons or {}, "challengeModeID", dungeon.challengeModeID)
          if characterDungeon then
            affixScores = characterDungeon.affixScores
            overallScore = characterDungeon.bestOverAllScore
            inTimeInfo = characterDungeon.bestTimedRun
            overTimeInfo = characterDungeon.bestNotTimedRun

            if overallScore and addon.Data.db.global.showAffixColors then
              local rarityColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore)
              if rarityColor ~= nil then
                color = rarityColor
              end
            end

            if affixScores then
              ---@type AE_CharacterAffixScoreInfo
              bestAffixScore = TableUtil.FindMax(affixScores, function(affixScore)
                return affixScore.score
              end)

              if bestAffixScore then
                level = tostring(bestAffixScore.level)
                dungeonLevel = bestAffixScore.level or 0

                if bestAffixScore.durationSec <= calculateDungeonTimer(dungeon.time, bestAffixScore.level, 3) then
                  tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:0|a"
                elseif bestAffixScore.durationSec <= calculateDungeonTimer(dungeon.time, bestAffixScore.level, 2) then
                  tier = "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:0|a"
                elseif bestAffixScore.durationSec <= calculateDungeonTimer(dungeon.time, bestAffixScore.level, 1) then
                  tier = "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:0|a"
                end

                if bestAffixScore.overTime then
                  color = LIGHTGRAY_FONT_COLOR
                end
              end
            end
          end

          if level ~= "-" and addon.Data.db.global.showTiers then
            level = format("%s %s", level, tier)
          end

          dungeonFrame.Text:ClearAllPoints()
          dungeonFrame.Text:SetText(color:WrapTextInColorCode(level))
          dungeonFrame.Text:SetPoint("LEFT", dungeonFrame, "LEFT")
          dungeonFrame.Text:SetPoint("RIGHT", dungeonFrame, "CENTER", 0, 0)
          dungeonFrame.Text:SetJustifyH("CENTER")
          dungeonFrame.Tier:ClearAllPoints()
          dungeonFrame.Tier:SetText("")
          dungeonFrame.Score:ClearAllPoints()
          dungeonFrame.Score:SetText(color:WrapTextInColorCode(overallScore and tostring(overallScore) or "-"))
          dungeonFrame.Score:SetPoint("LEFT", dungeonFrame, "CENTER")
          dungeonFrame.Score:SetPoint("RIGHT", dungeonFrame, "RIGHT")
          dungeonFrame.Score:SetJustifyH("CENTER")

          if not addon.Data.db.global.showScores then
            dungeonFrame.Text:ClearAllPoints()
            dungeonFrame.Text:SetPoint("CENTER", dungeonFrame, "CENTER")
            dungeonFrame.Score:SetText("")
          else
            if not addon.Data.db.global.showTiers then
              dungeonFrame.Text:SetPoint("RIGHT", dungeonFrame, "CENTER", 0, 0)
              dungeonFrame.Text:SetJustifyH("CENTER")
            end
          end

          if level == "-" then
            dungeonFrame.Text:ClearAllPoints()
            dungeonFrame.Text:SetPoint("CENTER", dungeonFrame, "CENTER")
            dungeonFrame.Tier:SetText("")
            dungeonFrame.Score:SetText("")
          end

          dungeonFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(dungeonFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(dungeon.name, 1, 1, 1)

            if affixScores and addon.Utils:TableCount(affixScores) > 0 then
              if overallScore and (inTimeInfo or overTimeInfo) then
                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(tostring(overallScore))), GREEN_FONT_COLOR)
              end

              if bestAffixScore then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddNormalLine(GameTooltip, LFG_LIST_BEST_RUN)
                GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(bestAffixScore.level), HIGHLIGHT_FONT_COLOR)

                local displayZeroHours = bestAffixScore.durationSec >= SECONDS_PER_HOUR
                local durationText = SecondsToClock(bestAffixScore.durationSec, displayZeroHours)

                if bestAffixScore.overTime then
                  local overtimeText = DUNGEON_SCORE_OVERTIME_TIME:format(durationText)
                  GameTooltip_AddColoredLine(GameTooltip, overtimeText, LIGHTGRAY_FONT_COLOR)
                else
                  GameTooltip_AddColoredLine(GameTooltip, tier .. " " .. durationText, HIGHLIGHT_FONT_COLOR)
                end
              end
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Dungeon Timers")
            GameTooltip:AddLine("|A:Professions-ChatIcon-Quality-Tier1:14:14:0:0|a " .. SecondsToClock(calculateDungeonTimer(dungeon.time, dungeonLevel, 1), false), 1, 1, 1)
            GameTooltip:AddLine("|A:Professions-ChatIcon-Quality-Tier2:16:16:0:0|a " .. SecondsToClock(calculateDungeonTimer(dungeon.time, dungeonLevel, 2), false), 1, 1, 1)
            GameTooltip:AddLine("|A:Professions-ChatIcon-Quality-Tier3:16:16:0:0|a " .. SecondsToClock(calculateDungeonTimer(dungeon.time, dungeonLevel, 3), false), 1, 1, 1)
            GameTooltip:Show()

            addon.Utils:SetHighlightColor(dungeonFrame, 1, 1, 1, 0.05)
          end)
          dungeonFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            addon.Utils:SetHighlightColor(dungeonFrame, 1, 1, 1, 0)
          end)

          addon.Utils:SetBackgroundColor(dungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
          dungeonFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
          dungeonFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
          dungeonFrame:SetHeight(addon.Constants.sizes.row)
          dungeonFrame:Show()
          rowCount = rowCount + 1
        end)
      end

      do -- Raids
        addon.Utils:TableForEach(characterFrame.raidFrames, function(f) f:Hide() end)
        if addon.Data.db.global.raids.enabled then
          addon.Utils:TableForEach(raids, function(raid, raidIndex)
            local raidFrame = characterFrame.raidFrames[raidIndex]
            if not raidFrame then
              raidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, characterFrame)
              raidFrame.difficultyFrames = {}
              raidFrame.headerFrame = CreateFrame("Frame", "$parentHeader", raidFrame)
              characterFrame.raidFrames[raidIndex] = raidFrame
            end

            addon.Utils:SetBackgroundColor(raidFrame.headerFrame, 0, 0, 0, 0.3)
            raidFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
            raidFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
            raidFrame:Show()
            raidFrame.headerFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
            raidFrame.headerFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
            raidFrame.headerFrame:SetHeight(addon.Constants.sizes.row)
            raidFrame.headerFrame:Show()
            rowCount = rowCount + 1

            -- Difficulties
            addon.Utils:TableForEach(raidFrame.difficultyFrames, function(f) f:Hide() end)
            addon.Utils:TableForEach(raidDifficulties, function(difficulty, difficultyIndex)
              local difficultyFrame = raidFrame.difficultyFrames[difficultyIndex]
              if not difficultyFrame then
                difficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, raidFrame)
                difficultyFrame.encounterFrames = {}
                raidFrame.difficultyFrames[difficultyIndex] = difficultyFrame
              end

              difficultyFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true)
                GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name))
                if character.raids.savedInstances ~= nil then
                  local savedInstance = addon.Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                  end)
                  if savedInstance ~= nil then
                    GameTooltip:AddLine(format("Expires: |cffffffff%s|r", date("%c", savedInstance.expires)))
                  end
                end
                GameTooltip:AddLine(" ")
                addon.Utils:TableForEach(raid.encounters, function(encounter, encounterIndex)
                  local color = LIGHTGRAY_FONT_COLOR
                  if character.raids.savedInstances then
                    local savedInstance = addon.Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                      return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                    end)
                    if savedInstance then
                      local savedEncounter = savedInstance.encounters[encounterIndex]
                      if savedEncounter and savedEncounter.isKilled then
                        color = GREEN_FONT_COLOR
                      end
                    end
                  end
                  GameTooltip:AddLine(encounter.name, color.r, color.g, color.b)
                end)
                GameTooltip:Show()
                addon.Utils:SetHighlightColor(difficultyFrame, 1, 1, 1, 0.05)
              end)

              difficultyFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
                addon.Utils:SetHighlightColor(difficultyFrame, 1, 1, 1, 0)
              end)

              addon.Utils:SetBackgroundColor(difficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
              difficultyFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * addon.Constants.sizes.row)
              difficultyFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * addon.Constants.sizes.row)
              difficultyFrame:SetHeight(addon.Constants.sizes.row)
              difficultyFrame:Show()
              rowCount = rowCount + 1

              -- Encounters
              local anchorEncounter = difficultyFrame
              addon.Utils:TableForEach(difficultyFrame.encounterFrames, function(f) f:Hide() end)
              addon.Utils:TableForEach(raid.encounters, function(encounter, encounterIndex)
                local encounterFrame = difficultyFrame.encounterFrames[encounterIndex]
                if not encounterFrame then
                  encounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, difficultyFrame)
                  difficultyFrame.encounterFrames[encounterIndex] = encounterFrame
                end

                local color = {r = 1, g = 1, b = 1}
                local alpha = 0.1
                local size = CHARACTER_WIDTH
                size = size - addon.Constants.sizes.padding                     -- left/right cell padding
                size = size - (addon.Utils:TableCount(raid.encounters) - 1) * 4 -- gaps
                size = size / addon.Utils:TableCount(raid.encounters)           -- box sizes

                if character.raids.savedInstances then
                  local savedInstance = addon.Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                  end)
                  if savedInstance then
                    local savedEncounter = savedInstance.encounters[encounterIndex]
                    if savedEncounter and savedEncounter.isKilled then
                      color = UNCOMMON_GREEN_COLOR
                      if addon.Data.db.global.raids.colors then
                        color = difficulty.color
                      end
                      alpha = 0.5
                    end
                  end
                end

                addon.Utils:SetBackgroundColor(encounterFrame, color.r, color.g, color.b, alpha)
                if encounterIndex == 1 then
                  encounterFrame:SetPoint("LEFT", anchorEncounter, "LEFT", addon.Constants.sizes.padding / 2, 0)
                else
                  encounterFrame:SetPoint("LEFT", anchorEncounter, "RIGHT", addon.Constants.sizes.padding / 2, 0)
                end
                encounterFrame:SetSize(size, addon.Constants.sizes.row - 12)
                encounterFrame:Show()
                anchorEncounter = encounterFrame
              end)
            end)
          end)
        end
      end
      windowWidth = windowWidth + CHARACTER_WIDTH
    end)
  end

  self.window:SetBodySize(math.min(windowWidth, windowWidthMax), windowHeight)
  self.window.body.scrollparent.scrollchild:SetSize(windowWidth, windowHeight)
  addon.Window:SetWindowScale(addon.Data.db.global.interface.windowScale / 100)
  addon.Window:SetWindowBackgroundColor(addon.Data.db.global.interface.windowColor)

  if self.window.body.scrollparent.scrollchild:GetWidth() > self.window.body.scrollparent:GetWidth() then
    self.window.body.scrollbar:SetMinMaxValues(0, self.window.body.scrollparent.scrollchild:GetWidth() - self.window.body.scrollparent:GetWidth())
    self.window.body.scrollbar.thumb:SetWidth(self.window.body.scrollbar:GetWidth() / 10)
    self.window.body.scrollbar.thumb:SetHeight(self.window.body.scrollbar:GetHeight())
    self.window.body.scrollbar:Show()
  else
    self.window.body.scrollparent:SetHorizontalScroll(0)
    self.window.body.scrollbar:Hide()
  end

  local zeroCharactersText = "|cffffffffHi there :-)|r\nEnable a character top right for AlterEgo to show you some goodies!"
  if numCharacters <= 0 then
    if not addon.Data.db.global.showZeroRatedCharacters and addon.Utils:TableCount(addon.Data:GetCharacters(true)) > 0 then
      zeroCharactersText = zeroCharactersText .. "\n\n|cff00ee00New Season?|r\nYou are currently hiding characters with zero rating. If this is not your intention then enable the setting |cffffffffShow characters with zero rating|r"
    end
    self.window.zeroCharacters:Show()
    self.window.sidebar:Hide()
    self.window.body:Hide()
  else
    self.window.zeroCharacters:Hide()
    self.window.sidebar:Show()
    self.window.body:Show()
  end

  if self.window.zeroCharacters then
    self.window.zeroCharacters:SetText(zeroCharactersText)
  end
end

function UI:SetupButtons()
  self.window.titlebar.SettingsButton = CreateFrame("DropdownButton", "$parentSettingsButton", self.window.titlebar)
  local settingsButton = self.window.titlebar.SettingsButton
  settingsButton:SetPoint("RIGHT", self.window.titlebar.CloseButton, "LEFT", 0, 0)
  settingsButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  settingsButton:SetScript("OnEnter", function()
    settingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(settingsButton, 1, 1, 1, 0.05)
    ---@diagnostic disable-next-line: param-type-mismatch
    GameTooltip:SetOwner(settingsButton, "ANCHOR_TOP")
    GameTooltip:SetText("Settings", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  settingsButton:SetScript("OnLeave", function()
    settingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(settingsButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  settingsButton.Icon = self.window.titlebar:CreateTexture(settingsButton:GetName() .. "Icon", "ARTWORK")
  settingsButton.Icon:SetPoint("CENTER", settingsButton, "CENTER")
  settingsButton.Icon:SetSize(12, 12)
  settingsButton.Icon:SetTexture(addon.Constants.media.IconSettings)
  settingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  settingsButton:SetupMenu(function(_, menu)
    menu:CreateTitle("General")
    menu:CreateCheckbox(
      "Show the weekly affixes",
      function() return addon.Data.db.global.showAffixHeader end,
      function()
        addon.Data.db.global.showAffixHeader = not addon.Data.db.global.showAffixHeader
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("The affixes will be shown at the top.", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Show characters with zero rating",
      function() return addon.Data.db.global.showZeroRatedCharacters end,
      function()
        addon.Data.db.global.showZeroRatedCharacters = not addon.Data.db.global.showZeroRatedCharacters
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Too many alts?", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Show realm names",
      function() return addon.Data.db.global.showRealms end,
      function()
        addon.Data.db.global.showRealms = not addon.Data.db.global.showRealms
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("One big party!", nil, nil, nil, true)
    end)
    local rioColors = menu:CreateCheckbox(
      "Use Raider.IO rating colors",
      function() return addon.Data.db.global.useRIOScoreColor end,
      function()
        addon.Data.db.global.useRIOScoreColor = not addon.Data.db.global.useRIOScoreColor
        self:Render()
      end
    )
    rioColors:SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("So many colors!", nil, nil, nil, true)
      if type(_G.RaiderIO) == "nil" then
        tooltip:AddLine(" ")
        tooltip:AddLine("Requires addon: Raider.IO", 1, 0, 0, true)
      end
    end)
    rioColors:SetEnabled(type(_G.RaiderIO) ~= "nil")
    menu:CreateTitle("Automatic Announcements")
    menu:CreateCheckbox(
      "Announce instance resets",
      function() return addon.Data.db.global.announceResets end,
      function()
        addon.Data.db.global.announceResets = not addon.Data.db.global.announceResets
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Let others in your group know when you've reset the instances.", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Announce new keystones (Party)",
      function() return addon.Data.db.global.announceKeystones.autoParty end,
      function()
        addon.Data.db.global.announceKeystones.autoParty = not addon.Data.db.global.announceKeystones.autoParty
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Announce to your party when you loot a new keystone.", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Announce new keystones (Guild)",
      function() return addon.Data.db.global.announceKeystones.autoGuild end,
      function()
        addon.Data.db.global.announceKeystones.autoGuild = not addon.Data.db.global.announceKeystones.autoGuild
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Announce to your guild when you loot a new keystone.", nil, nil, nil, true)
    end)
    menu:CreateTitle(RAIDS)
    menu:CreateCheckbox(
      "Show raid progress",
      function() return addon.Data.db.global.raids.enabled end,
      function()
        addon.Data.db.global.raids.enabled = not addon.Data.db.global.raids.enabled
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Because MythicPlus ain't enough!", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Use difficulty colors",
      function() return addon.Data.db.global.raids.colors end,
      function()
        addon.Data.db.global.raids.colors = not addon.Data.db.global.raids.colors
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Argharhggh! So much greeeen!", nil, nil, nil, true)
    end)
    local raidDifficultiesSetting = menu:CreateButton(
      "Enabled raid difficulties"
    )
    addon.Utils:TableForEach(addon.Data:GetRaidDifficulties(true), function(difficulty)
      local hiddenDifficulties = addon.Data.db.global.raids.hiddenDifficulties or {}
      raidDifficultiesSetting:CreateCheckbox(
        difficulty.name,
        function(id) return not hiddenDifficulties[id] end,
        function(id)
          addon.Data.db.global.raids.hiddenDifficulties[id] = not hiddenDifficulties[id]
          self:Render()
        end,
        difficulty.id
      )
    end)
    -- TODO: Refactor to auto-detect if the season has awwakened raids
    --       if seasonID == 12 then
    --         UIDropDownMenu_AddButton({
    --           text = "Show |cFF00FFFFAwakened|r raids only",
    --           checked = addon.Data.db.global.raids and addon.Data.db.global.raids.modifiedInstanceOnly,
    --           keepShownOnClick = true,
    --           isNotRadio = true,
    --           tooltipTitle = "Show |cFF00FFFFAwakened|r raids only",
    --           tooltipText = "It's time to move on!",
    --           tooltipOnButton = true,
    --           func = function(button, arg1, arg2, checked)
    --             addon.Data.db.global.raids.modifiedInstanceOnly = checked
    --             self:Render()
    --           end,
    --         })
    --       end
    menu:CreateTitle(DUNGEONS)
    menu:CreateCheckbox(
      "Show icons",
      function() return addon.Data.db.global.showTiers end,
      function()
        addon.Data.db.global.showTiers = not addon.Data.db.global.showTiers
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Show rating",
      function() return addon.Data.db.global.showScores end,
      function()
        addon.Data.db.global.showScores = not addon.Data.db.global.showScores
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Show some scores!", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Use rating colors",
      function() return addon.Data.db.global.showAffixColors end,
      function()
        addon.Data.db.global.showAffixColors = not addon.Data.db.global.showAffixColors
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Show some colors!", nil, nil, nil, true)
    end)
    menu:CreateTitle(WORLD)
    menu:CreateCheckbox(
      "Show world progress",
      function() return addon.Data.db.global.world.enabled end,
      function()
        addon.Data.db.global.world.enabled = not addon.Data.db.global.world.enabled
        self:Render()
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Is Brann helping you out?", nil, nil, nil, true)
    end)
    menu:CreateTitle(MINIMAP_LABEL)
    menu:CreateCheckbox(
      "Show the minimap button",
      function() return not addon.Data.db.global.minimap.hide end,
      function()
        addon.Data.db.global.minimap.hide = not addon.Data.db.global.minimap.hide
        LibDBIcon:Refresh(addonName, addon.Data.db.global.minimap)
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("It does get crowded around the minimap sometimes.", nil, nil, nil, true)
    end)
    menu:CreateCheckbox(
      "Lock the minimap button",
      function() return addon.Data.db.global.minimap.lock end,
      function()
        addon.Data.db.global.minimap.lock = not addon.Data.db.global.minimap.lock
        LibDBIcon:Refresh(addonName, addon.Data.db.global.minimap)
      end
    ):SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("No more moving the button around accidentally!", nil, nil, nil, true)
    end)
    menu:CreateTitle(INTERFACE_OPTIONS)
    -- TODO: Make this a slider with a different button template
    local windowScaleButton = menu:CreateButton("Window scale")
    for i = 80, 200, 10 do
      windowScaleButton:CreateRadio(
        i .. "%",
        function(value) return addon.Data.db.global.interface.windowScale == value end,
        function(value)
          addon.Data.db.global.interface.windowScale = value
          self:Render()
          return MenuResponse.Refresh
        end,
        i
      )
    end
    local function saveAndRefresh(color)
      if color.r then
        addon.Data.db.global.interface.windowColor.r = color.r
        addon.Data.db.global.interface.windowColor.g = color.g
        addon.Data.db.global.interface.windowColor.b = color.b
      end
      if color.a then
        addon.Data.db.global.interface.windowColor.a = color.a
      end
      addon.Window:SetWindowBackgroundColor(addon.Data.db.global.interface.windowColor)
    end
    local colorInfo = {
      r = addon.Data.db.global.interface.windowColor.r,
      g = addon.Data.db.global.interface.windowColor.g,
      b = addon.Data.db.global.interface.windowColor.b,
      opacity = addon.Data.db.global.interface.windowColor.a,
      hasOpacity = 1,
      swatchFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()
        if r then
          saveAndRefresh({r = r, g = g, b = b, a = a or 1})
        end
      end,
      opacityFunc = function() end,
      cancelFunc = saveAndRefresh,
    }
    menu:CreateColorSwatch(
      "Window background color",
      function()
        ColorPickerFrame:SetupColorPickerAndShow(colorInfo)
      end,
      colorInfo
    )
  end)

  self.window.titlebar.SortingButton = CreateFrame("DropdownButton", "$parentSorting", self.window.titlebar)
  local sortingButton = self.window.titlebar.SortingButton
  sortingButton:SetPoint("RIGHT", settingsButton, "LEFT", 0, 0)
  sortingButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  sortingButton.Icon = self.window.titlebar:CreateTexture(sortingButton:GetName() .. "Icon", "ARTWORK")
  sortingButton.Icon:SetPoint("CENTER", sortingButton, "CENTER")
  sortingButton.Icon:SetSize(16, 16)
  sortingButton.Icon:SetTexture(addon.Constants.media.IconSorting)
  sortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  sortingButton:SetupMenu(function(_, rootMenu)
    for _, option in ipairs(addon.Constants.sortingOptions) do
      local button = rootMenu:CreateRadio(
        option.text,
        function(value) return addon.Data.db.global.sorting == value end,
        function(value)
          addon.Data.db.global.sorting = value
          self:Render()
          return MenuResponse.Refresh
        end,
        option.value
      )
      if option.tooltipTitle or option.tooltipText then
        button:SetTooltip(function(tooltip)
          if option.tooltipTitle then
            tooltip:AddLine(option.tooltipTitle, 1, 1, 1, true)
          end
          if option.tooltipText then
            tooltip:AddLine(option.tooltipText, nil, nil, nil, true)
          end
        end)
      end
    end
  end)
  sortingButton:SetScript("OnEnter", function()
    sortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(sortingButton, 1, 1, 1, 0.05)
    ---@diagnostic disable-next-line: param-type-mismatch
    GameTooltip:SetOwner(sortingButton, "ANCHOR_TOP")
    GameTooltip:SetText("Sorting", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  sortingButton:SetScript("OnLeave", function()
    sortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(sortingButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)

  self.window.titlebar.CharactersButton = CreateFrame("DropdownButton", "$parentCharacters", self.window.titlebar)
  local charactersButton = self.window.titlebar.CharactersButton
  charactersButton:SetPoint("RIGHT", sortingButton, "LEFT", 0, 0)
  charactersButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  charactersButton:SetScript("OnEnter", function()
    charactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(charactersButton, 1, 1, 1, 0.05)
    ---@diagnostic disable-next-line: param-type-mismatch
    GameTooltip:SetOwner(charactersButton, "ANCHOR_TOP")
    GameTooltip:SetText("Characters", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Toggle your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  charactersButton:SetScript("OnLeave", function()
    charactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(charactersButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  charactersButton.Icon = self.window.titlebar:CreateTexture(charactersButton:GetName() .. "Icon", "ARTWORK")
  charactersButton.Icon:SetPoint("CENTER", charactersButton, "CENTER")
  charactersButton.Icon:SetSize(14, 14)
  charactersButton.Icon:SetTexture(addon.Constants.media.IconCharacters)
  charactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  charactersButton:SetupMenu(function(_, rootMenu)
    local charactersUnfiltered = addon.Data:GetCharacters(true)
    addon.Utils:TableForEach(charactersUnfiltered, function(char)
      local nameColor = WHITE_FONT_COLOR
      if char.info.class.file ~= nil then
        local classColor = C_ClassColor.GetClassColor(char.info.class.file)
        if classColor ~= nil then
          nameColor = classColor
        end
      end
      rootMenu:CreateCheckbox(
        format("%s (%s)", nameColor:WrapTextInColorCode(char.info.name), char.info.realm),
        function(value) return addon.Data.db.global.characters[value].enabled end,
        function(value)
          addon.Data.db.global.characters[value].enabled = not addon.Data.db.global.characters[value].enabled
          self:Render()
        end,
        char.GUID
      )
    end)
  end)

  self.window.titlebar.AnnounceButton = CreateFrame("DropdownButton", "$parentCharacters", self.window.titlebar)
  local announceButton = self.window.titlebar.AnnounceButton
  announceButton:SetPoint("RIGHT", charactersButton, "LEFT", 0, 0)
  announceButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  announceButton:SetScript("OnEnter", function()
    announceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(announceButton, 1, 1, 1, 0.05)
    ---@diagnostic disable-next-line: param-type-mismatch
    GameTooltip:SetOwner(announceButton, "ANCHOR_TOP")
    GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  announceButton:SetScript("OnLeave", function()
    announceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    ---@diagnostic disable-next-line: param-type-mismatch
    addon.Utils:SetBackgroundColor(announceButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  announceButton.Icon = self.window.titlebar:CreateTexture(announceButton:GetName() .. "Icon", "ARTWORK")
  announceButton.Icon:SetPoint("CENTER", announceButton, "CENTER")
  announceButton.Icon:SetSize(12, 12)
  announceButton.Icon:SetTexture(addon.Constants.media.IconAnnounce)
  announceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  announceButton:SetupMenu(function(_, rootMenu)
    rootMenu:CreateTitle("Announce Keystones")
    local sendToParty = rootMenu:CreateButton(
      "Send to Party Chat",
      function()
        if not IsInGroup() then
          addon.Core:Print("You are not in a party.")
          return
        end
        addon.Core:AnnounceKeystones("PARTY")
      end
    )
    sendToParty:SetEnabled(IsInGroup())
    sendToParty:SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Announce all your keystones to the party chat.", nil, nil, nil, true)
      if not IsInGroup() then
        tooltip:AddLine(" ")
        tooltip:AddLine("You are not in a party.", 1, 0, 0, true)
      end
    end)
    local sendToGuild = rootMenu:CreateButton(
      "Send to Guild Chat",
      function()
        if not IsInGuild() then
          addon.Core:Print("You are not in a guild.")
          return
        end
        addon.Core:AnnounceKeystones("GUILD")
      end
    )
    sendToGuild:SetEnabled(IsInGuild())
    sendToGuild:SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Announce all your keystones to the guild chat.", nil, nil, nil, true)
      if not IsInGuild() then
        tooltip:AddLine(" ")
        tooltip:AddLine("You are not in a guild.", 1, 0, 0, true)
      end
    end)
    rootMenu:CreateTitle("Settings")
    local withCharacterNames
    local withMultipleMessages = rootMenu:CreateCheckbox(
      "Multiple chat messages",
      function() return addon.Data.db.global.announceKeystones.multiline end,
      function()
        addon.Data.db.global.announceKeystones.multiline = not addon.Data.db.global.announceKeystones.multiline
        withCharacterNames:SetEnabled(addon.Data.db.global.announceKeystones.multiline)
      end
    )
    withCharacterNames = rootMenu:CreateCheckbox(
      "Include character names",
      function() return addon.Data.db.global.announceKeystones.multilineNames end,
      function() addon.Data.db.global.announceKeystones.multilineNames = not addon.Data.db.global.announceKeystones.multilineNames end
    )
    withMultipleMessages:SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Announce keystones with multiple chat messages.", nil, nil, nil, true)
      tooltip:AddLine(" ")
      tooltip:AddLine("|cffff0000Warning: |rIf you have a lot of characters it could get spammy and the messages may get blocked.", nil, nil, nil, true)
    end)
    withCharacterNames:SetTooltip(function(tooltip, elm)
      tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
      tooltip:AddLine("Add character names before each keystone.", nil, nil, nil, true)
      if not addon.Data.db.global.announceKeystones.multiline then
        tooltip:AddLine(" ")
        tooltip:AddLine("Multiple chat messages must be enabled.", 1, 0, 0, true)
      end
    end)
    withCharacterNames:SetEnabled(addon.Data.db.global.announceKeystones.multiline)
  end)

  self.window.titlebar.GreatVaultButton = CreateFrame("Button", "$parentGreatVaultButton", self.window.titlebar)
  local vaultButton = self.window.titlebar.GreatVaultButton
  vaultButton:SetPoint("RIGHT", announceButton, "LEFT", 0, 0)
  vaultButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  vaultButton:RegisterForClicks("AnyUp")
  vaultButton:SetScript("OnClick", function()
    addon.Core:ToggleVault()
  end)
  vaultButton:SetScript("OnEnter", function()
    vaultButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    addon.Utils:SetBackgroundColor(vaultButton, 1, 1, 1, 0.05)
    GameTooltip:SetOwner(vaultButton, "ANCHOR_TOP")
    GameTooltip:SetText(DELVES_GREAT_VAULT_LABEL, 1, 1, 1, 1, true)
    GameTooltip:AddLine(WEEKLY_REWARDS_ADD_ITEMS, nil, nil, nil, true)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(format("<%s>", WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS), GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  vaultButton:SetScript("OnLeave", function()
    vaultButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    addon.Utils:SetBackgroundColor(vaultButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  vaultButton.Icon = self.window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
  vaultButton.Icon:SetPoint("CENTER", vaultButton, "CENTER")
  vaultButton.Icon:SetSize(13, 13)
  vaultButton.Icon:SetTexture(addon.Constants.media.IconKeyhole)
  vaultButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
end

function UI:RenderAffixWindow()
  local affixes = addon.Data:GetAffixes()
  local affixRotation = addon.Data:GetAffixRotation()
  local currentAffixes = addon.Data:GetCurrentAffixes()
  local activeWeek = addon.Data:GetActiveAffixRotation(currentAffixes)

  local tableWidth = 0
  local tableHeight = 0
  local columnWidth = 140
  local rowHeight = 28

  if not self.affixWindow then
    self.affixWindow = addon.Window:New({
      name = "Affixes",
      title = "Weekly Affixes",
      point = {"TOP", UIParent, "TOP", 0, -15},
    })
    self.affixTable = addon.Table:New({rows = {height = rowHeight, striped = true}})
    self.affixTable:SetParent(self.affixWindow.body)
    self.affixTable:SetAllPoints()
    self.affixWindow:SetScript("OnShow", function()
      self:RenderAffixWindow()
    end)
  end

  if not self.affixWindow:IsVisible() then
    return
  end

  ---@type AE_TableData
  local data = {columns = {}, rows = {}}

  if affixRotation then
    do -- First row with activation levels
      ---@type AE_TableDataRow
      local row = {columns = {}}
      addon.Utils:TableForEach(affixRotation.activation, function(activationLevel, activationLevelIndex)
        ---@type AE_TableDataColumn
        local column = {width = activationLevelIndex == 1 and 220 or columnWidth}
        ---@type AE_TableDataRowColumn
        local columnData = {text = "+" .. activationLevel, backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}}

        table.insert(data.columns, column)
        table.insert(row.columns, columnData)
        tableWidth = tableWidth + column.width
      end)
      table.insert(data.rows, row)
      tableHeight = tableHeight + rowHeight
    end

    addon.Utils:TableForEach(affixRotation.affixes, function(affixValues, weekIndex)
      ---@type AE_TableDataRow
      local row = {columns = {}}
      local backgroundColor = weekIndex == activeWeek and {r = 1, g = 1, b = 1, a = 0.1} or nil

      addon.Utils:TableForEach(affixValues, function(affixValue)
        if type(affixValue) == "number" then
          local affix = addon.Utils:TableGet(affixes, "id", affixValue)
          if affix then
            local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
            ---@type AE_TableDataRowColumn
            local columnData = {
              text = affix.fileDataID and "|T" .. affix.fileDataID .. ":0|t " .. name or name,
              backgroundColor = backgroundColor or nil,
              onEnter = function(columnFrame)
                GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(affix.name, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, 1, true)
                GameTooltip:AddLine(affix.description, nil, nil, nil, true)
                GameTooltip:Show()
              end,
              onLeave = function()
                GameTooltip:Hide()
              end,
            }
            table.insert(row.columns, columnData)
          end
        else
          ---@type AE_TableDataRowColumn
          local columnData = {
            text = affixValue,
            backgroundColor = backgroundColor or nil,
          }
          table.insert(row.columns, columnData)
        end
      end)
      table.insert(data.rows, row)
      tableHeight = tableHeight + rowHeight
    end)
  else
    ---@type AE_TableDataColumn
    local column = {width = 500}
    ---@type AE_TableDataRow
    local row = {columns = {{text = "The weekly schedule is not updated. Check back next addon update!"}}}

    table.insert(data.columns, column)
    table.insert(data.rows, row)
    tableWidth = tableWidth + 500
    tableHeight = tableHeight + rowHeight
  end

  self.affixTable:SetData(data)
  self.affixWindow:SetBodySize(tableWidth, tableHeight)
end

function UI:RenderEquipmentWindow()
  local tableWidth = 610
  local tableHeight = 0
  local rowHeight = 22

  if not self.equipmentWindow then
    self.equipmentWindow = addon.Window:New({
      name = "Equipment",
      title = "Character",
      point = {"TOPLEFT", UIParent, "TOPLEFT", 15, -15},
    })
    self.equipmentTable = addon.Table:New({rows = {height = rowHeight, striped = true}})
    self.equipmentTable:SetParent(self.equipmentWindow.body)
    self.equipmentTable:SetAllPoints()
    self.equipmentWindow:SetScript("OnShow", function()
      self:RenderEquipmentWindow()
    end)
  end

  if not self.equipmentWindow:IsVisible() then
    return
  end

  local character = self.equipmentCharacter
  if not character or type(character.equipment) ~= "table" then
    self.equipmentWindow:Hide()
    return
  end

  ---@type AE_TableData
  local data = {
    columns = {
      {width = 100},
      {width = 280},
      {width = 80, align = "CENTER"},
      {width = 150},
    },
    rows = {
      {
        columns = {
          {text = "Slot",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Item",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "iLevel",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Upgrade Level", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
        },
      },
    },
  }
  tableHeight = tableHeight + 30

  addon.Utils:TableForEach(character.equipment, function(item)
    local upgradeLevel = ""
    if item.itemUpgradeTrack ~= "" then
      upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
      if item.itemUpgradeColor and item.itemUpgradeColor == DISABLED_FONT_COLOR:GenerateHexColor() then
        upgradeLevel = DISABLED_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
      elseif item.itemUpgradeLevel == item.itemUpgradeMax then
        upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
      end
    end

    ---@type AE_TableDataRow
    local row = {
      columns = {
        {text = _G[item.itemSlotName]},
        {
          text = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
          onEnter = function(columnFrame)
            GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(item.itemLink)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()
          end,
          onLeave = function()
            GameTooltip:Hide()
          end,
          onClick = function()
            if IsModifiedClick("CHATLINK") then
              if not ChatEdit_InsertLink(item.itemLink) then
                ChatFrame_OpenChat(item.itemLink)
              end
            end
          end,
        },
        {text = WrapTextInColorCode(tostring(item.itemLevel), select(4, GetItemQualityColor(item.itemQuality)))},
        {text = upgradeLevel},
      },
    }
    table.insert(data.rows, row)
    tableHeight = tableHeight + rowHeight
  end)


  local nameColor = WHITE_FONT_COLOR
  if character.info.class.file ~= nil then
    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
    if classColor ~= nil then
      nameColor = classColor
    end
  end

  self.equipmentWindow:SetTitle(format("%s (%s)", nameColor:WrapTextInColorCode(character.info.name), character.info.realm))
  self.equipmentTable:SetData(data)
  self.equipmentWindow:SetBodySize(tableWidth, tableHeight)
end
