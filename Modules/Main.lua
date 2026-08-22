---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_Main
local Module = addon.Core:NewModule("Main", "AceConsole-3.0", "AceTimer-3.0")
addon.Module_Main = Module

local Data = addon.Data
local Helpers = addon.Helpers
local Constants = addon.Constants
local LibLiqUI = addon.Libs.LiqUI
local SetBackgroundColor = LibLiqUI.Utils.SetBackgroundColor
local SetHighlightColor = LibLiqUI.Utils.SetHighlightColor
local TableCount = LibLiqUI.Utils.TableCount
local TableFilter = LibLiqUI.Utils.TableFilter
local TableFind = LibLiqUI.Utils.TableFind
local TableForEach = LibLiqUI.Utils.TableForEach
local TableGet = LibLiqUI.Utils.TableGet
local CreateScrollArea = LibLiqUI.Utils.CreateScrollArea

function Module:OnInitialize()
  self:Render()
end

do
  local dialogName = "ALTEREGO_DELETE_CHARACTER"
  StaticPopupDialogs[dialogName] = {
    text = "Remove %s?\n\nThis cannot be undone.\nTo add this character again, log in on them.",
    button1 = YES,
    button2 = CANCEL,
    OnAccept = function(_, character)
      if character then
        Data:DeleteCharacter(character)
        Module:Render()
      end
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
  }
end

local CHARACTER_WIDTH = 130
local RAIDS_ROW_HEIGHT = 48
local dungeonPortalUnlockLevel = 10
local vaultMaxLevelRewardMythic = 10
local vaultMaxLevelRewardWorld = 8
local vaultMaxNumRunsMythic = 8
local preyWeeklyHuntCap = 5
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
    ["default"] = "Complete delves, world activities, Prey, or Ritual Sites this week to unlock your first Great Vault reward.",
    ["firstSlotStart"] = "Complete %1$d |4activity:activities; this week (delves, world activities, Prey, or Ritual Sites) to unlock your first Great Vault reward.",
    ["firstSlotMore"] = "Complete %1$d more |4activity:activities; this week (delves, world activities, Prey, or Ritual Sites) to unlock your first Great Vault reward.",
    ["nextSlotMore"] = "Complete %1$d more |4activity:activities; this week (delves, world activities, Prey, or Ritual Sites) to unlock another Great Vault reward.",
    ["rewardsImprove"] = "Complete delves on tier %d or higher to improve your Great Vault rewards.",
    ["rewardsMaxed"] = "Good job - You are done! There are no more rewards to improve.",
  },
}

---Check if an activity is completed at a heroic level
---@param activityTierID number
---@return boolean
local function isCompletedAtHeroicLevel(activityTierID)
  local difficultyID = C_WeeklyRewards.GetDifficultyIDForActivityTier(activityTierID)
  return difficultyID == DifficultyUtil.ID.DungeonHeroic
end

---Print vault progress to tooltip
---@param infoFrame Frame
---@param character AE_Character
---@param activityType Enum.WeeklyRewardChestThresholdType
local function getVaultProgressTooltip(infoFrame, character, activityType)
  local loggedCharacter = Data:GetCharacter()
  local difficulties = Data:GetRaidDifficulties(true)
  local dungeons = Data:GetDungeons()
  local raids = Data:GetRaids()
  local activities = TableFilter(character.vault.slots or {}, function(activity) return activity.type and activity.type == activityType end)
  local numActivities = TableCount(activities)
  local activitiesInProgress = TableFilter(activities, function(slot) return slot.progress < slot.threshold end)
  local numActivitiesInProgress = TableCount(activitiesInProgress)
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

      local activity = TableGet(activities, "index", i)
      if activity then
        textLeft = format("%d %s:", activity.threshold, string.lower(activity.type and vaultTooltipTexts[activity.type] and vaultTooltipTexts[activity.type]["objective"] or vaultTooltipText["objective"]))
        if activity.progress >= activity.threshold then
          textRight = "Unlocked"
          color = WHITE_FONT_COLOR

          -- Difficulty name
          if activity.type == Enum.WeeklyRewardChestThresholdType.Raid then
            local raidDifficultyID = GetBaseDifficultyID(activity.level)
            local difficultyName = GetDifficultyInfo(raidDifficultyID)
            local dataDifficulty = TableGet(difficulties, "id", raidDifficultyID)
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
        local activityInfo = TableFind(loggedCharacter and loggedCharacter.vault and loggedCharacter.vault.slots or {}, function(slot) return slot.type == activityType and slot.index == i end)
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
      TableForEach(raids, function(raid)
        if raidInstanceID ~= raid.instanceID then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(raid.name)
        end

        TableForEach(raid.encounters or {}, function(encounter)
          local bestDifficulty = nil
          local color = DISABLED_FONT_COLOR
          local difficultyName = "-"

          local encounterInfo = TableFind(activityEncounterInfo, function(activityEncounter)
            return activityEncounter.instanceID == raid.journalInstanceID and activityEncounter.encounterID == encounter.journalEncounterID and activityEncounter.index == 1
          end)

          if encounterInfo and encounterInfo.bestDifficulty then
            bestDifficulty = TableGet(difficulties, "id", GetBaseDifficultyID(encounterInfo.bestDifficulty))
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
      local runsThisWeek = TableFilter(character.mythicplus.runHistory or {}, function(run) return run.thisWeek == true end)
      local numRunsThisWeek = TableCount(runsThisWeek)
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
        TableForEach(runsThisWeek, function(run, i)
          if i > numMaxRuns then return end
          local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
          local dungeon = TableGet(dungeons, "challengeModeID", run.mapChallengeModeID)
          local dungeonName = "Mythic+"
          local color = WHITE_FONT_COLOR
          local matchesThreshold = TableFind(character.vault.slots or {}, function(activity)
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

  do -- World activities
    if activityType == Enum.WeeklyRewardChestThresholdType.World then
      local worldActivityProgress = character.vault.worldActivityProgress or {}
      local desiredRuns = vaultMaxLevelRewardWorld
      local lastActivity = activities[numActivities]
      if lastActivity then
        desiredRuns = lastActivity.threshold
      end

      local hasProgress = false
      TableForEach(worldActivityProgress, function(tierProgress)
        if tierProgress.numPoints and tierProgress.numPoints > 0 then
          hasProgress = true
        end
      end)

      if hasProgress and desiredRuns > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(WEEKLY_REWARDS_WORLD_TOP_ACTIVITIES:format(desiredRuns))
        for _, tierProgress in ipairs(worldActivityProgress) do
          if desiredRuns <= 0 then
            break
          end
          local numRuns = math.min(tierProgress.numPoints, desiredRuns)
          if numRuns <= 0 then
            break
          end
          desiredRuns = desiredRuns - numRuns
          if tierProgress.difficulty > 1 then
            GameTooltip:AddLine(WEEKLY_REWARDS_DELVE_TIER_INFO:format(tierProgress.difficulty, numRuns), 1, 1, 1)
          else
            GameTooltip:AddLine(WEEKLY_REWARDS_DELVE_TIER_AND_WORLD_INFO:format(tierProgress.difficulty, numRuns), 1, 1, 1)
          end
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
          local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(GetBaseDifficultyID(activity.level))
          if nextDifficultyID then
            local difficulty = TableGet(difficulties, "id", nextDifficultyID)
            if difficulty then
              text = format(vaultTooltipText["rewardsImprove"], difficulty.name)
            end
          else
            text = vaultTooltipText["rewardsMaxed"]
          end
        elseif activityType == Enum.WeeklyRewardChestThresholdType.Activities then
          local activity = activities[numActivities]
          local level = Helpers:GetLowestLevelInTopDungeonRuns(character, activity.threshold)
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

---Get vault progress value for display
---@param character AE_Character
---@param activityType Enum.WeeklyRewardChestThresholdType
---@return string
local function getVaultProgressValue(character, activityType)
  local difficulties = Data:GetRaidDifficulties(true)
  local activities = TableFilter(character.vault.slots or {}, function(activity) return activity.type and activity.type == activityType end)
  local texts = {}

  for i = 1, 3 do
    local text = "-"
    local color = LIGHTGRAY_FONT_COLOR

    local activity = TableGet(activities, "index", i)
    if activity and activity.progress >= activity.threshold then
      text = "?"
      color = UNCOMMON_GREEN_COLOR

      if activityType == Enum.WeeklyRewardChestThresholdType.Raid then
        local raidDifficultyID = GetBaseDifficultyID(activity.level)
        local dataDifficulty = TableGet(difficulties, "id", raidDifficultyID)
        local difficultyName = GetDifficultyInfo(raidDifficultyID)
        if difficultyName then
          text = difficultyName
        end
        if dataDifficulty then
          text = dataDifficulty.abbr and dataDifficulty.abbr or dataDifficulty.name
          if Data.db.global.raids.colors and dataDifficulty.color then
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

---Get character info rows for the grid
---@param unfiltered boolean?
---@return AE_CharacterRows[]
function Module:GetCharacterInfo(unfiltered)
  local dungeons = Data:GetDungeons()
  local _, seasonDisplayID = Data:GetCurrentSeason()
  local equipmentModule = addon.Core:GetModule("Equipment", true)

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
        local coloredName = "|c" .. nameColor .. name .. "|r"
        if character.GUID ~= UnitGUID("player") then
          return coloredName
        end
        local marker = Data.db.global.currentCharacterMarker
        local currentColor = GREEN_FONT_COLOR
        if marker == "brackets" then
          return currentColor:WrapTextInColorCode("[ ") .. coloredName .. currentColor:WrapTextInColorCode(" ]")
        end
        if marker == "parentheses" then
          return currentColor:WrapTextInColorCode("( ") .. coloredName .. currentColor:WrapTextInColorCode(" )")
        end
        if marker == "dot" then
          return coloredName .. Constants.currentCharacterNameMarker
        end
        return coloredName
      end,
      onEnter = function(infoFrame, character)
        local name = "-"
        local nameColor = WHITE_FONT_COLOR
        if character.info.name ~= nil then
          name = character.info.name
        end
        if character.info.class.file ~= nil then
          local classColor = C_ClassColor.GetClassColor(character.info.class.file)
          if classColor ~= nil then
            nameColor = CreateColor(classColor.r, classColor.g, classColor.b, 1)
          end
        end
        name = format("%s (%s)", nameColor:WrapTextInColorCode(name), character.info.realm)
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine(name, 1, 1, 1)
        if character.info.guild ~= nil and character.info.guild.isInGuild then
          GameTooltip:AddLine(format("<%s>", character.info.guild.name), NECROLORD_GREEN_COLOR.r, NECROLORD_GREEN_COLOR.g, NECROLORD_GREEN_COLOR.b)
        end
        GameTooltip:AddLine(format("Level %d %s", character.info.level, character.info.race ~= nil and character.info.race.name or ""), 1, 1, 1)
        if character.info.factionGroup ~= nil and character.info.factionGroup.localized ~= nil then
          GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1)
        end
        if character.money ~= nil then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(GetMoneyString(character.money, true), 1, 1, 1)
        end
        if character.lastUpdate ~= nil then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(format("Last update:\n|cffffffff%s|r", date("%c", character.lastUpdate)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        end
        if type(character.equipment) == "table" and equipmentModule then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Click to View Equipment>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      onClick = function(infoFrame, character)
        if not equipmentModule then return end
        equipmentModule:OpenCharacter(character)
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
      enabled = Data.db.global.showRealms,
    },
    {
      label = "Guild",
      value = function(character)
        local guild = "-"
        local guildColor = WHITE_FONT_COLOR
        if character.info.guild == nil then
          guildColor = LIGHTGRAY_FONT_COLOR
        elseif character.info.guild.isInGuild then
          if character.info.guild.name ~= nil and character.info.guild.name ~= "" then
            guild = character.info.guild.name
            guildColor = NECROLORD_GREEN_COLOR
          else
            guildColor = LIGHTGRAY_FONT_COLOR
          end
        end
        return guildColor:WrapTextInColorCode(guild)
      end,
      onEnter = function(infoFrame, character)
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        if character.info.guild == nil then
          GameTooltip:AddLine("Guild", 1, 1, 1)
          GameTooltip:AddLine("Log in to update your guild information.")
        elseif character.info.guild.isInGuild and character.info.guild.name ~= nil then
          local realmName = character.info.realm
          if character.info.guild.realm ~= nil and strlenutf8(character.info.guild.realm) > 0 then
            realmName = character.info.guild.realm
          end
          GameTooltip:AddLine(character.info.guild.name, 1, 1, 1)
          GameTooltip:AddDoubleLine("Rank:", character.info.guild.rankName ~= nil and character.info.guild.rankName or "-", nil, nil, nil, 1, 1, 1)
          GameTooltip:AddDoubleLine("Realm:", realmName, nil, nil, nil, 1, 1, 1)
        else
          GameTooltip:AddLine("Guild", 1, 1, 1)
          GameTooltip:AddLine("Not in a guild.")
        end
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      enabled = Data.db.global.showGuildInformation,
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
        if character.mythicplus.rating ~= nil and C_MythicPlus.IsMythicPlusActive() then
          rating = tostring(character.mythicplus.rating)
          local color = Helpers:GetRatingColor(character.mythicplus.rating, Data.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = CreateColor(color.r, color.g, color.b, color.a)
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
          numSeasonRuns = TableCount(character.mythicplus.runHistory)
        end
        if character.mythicplus.bestSeasonNumber ~= nil then
          bestSeasonNumber = character.mythicplus.bestSeasonNumber
        end
        if character.mythicplus.bestSeasonScore ~= nil then
          bestSeasonScore = character.mythicplus.bestSeasonScore
          local color = Helpers:GetRatingColor(bestSeasonScore, Data.db.global.useRIOScoreColor, bestSeasonNumber ~= nil and bestSeasonNumber < seasonDisplayID)
          if color ~= nil then
            bestSeasonScoreColor = CreateColor(color.r, color.g, color.b, color.a)
          end
        end
        if type(character.mythicplus.rating) == "number" then
          local color = Helpers:GetRatingColor(character.mythicplus.rating, Data.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = CreateColor(color.r, color.g, color.b, color.a)
          end
          rating = tostring(character.mythicplus.rating)
        end

        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Mythic+ Rating", 1, 1, 1)
        if not C_MythicPlus.IsMythicPlusActive() then
          GameTooltip:AddLine("Mythic+ is not active.", DIM_RED_FONT_COLOR.r, DIM_RED_FONT_COLOR.g, DIM_RED_FONT_COLOR.b)
        else
          -- Season information
          GameTooltip:AddDoubleLine("Current Season:", ratingColor:WrapTextInColorCode(rating), nil, nil, nil, ratingColor.r, ratingColor.g, ratingColor.b)
          if bestSeasonNumber ~= nil and bestSeasonScore ~= nil then
            local bestSeasonValue = bestSeasonScoreColor:WrapTextInColorCode(tostring(bestSeasonScore))
            if bestSeasonNumber > 0 then
              local season = LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(format("(Season %s)", bestSeasonNumber))
              bestSeasonValue = format("%s %s", bestSeasonValue, season)
            end
            GameTooltip:AddDoubleLine("Best Season:", bestSeasonValue, nil, nil, nil, 1, 1, 1)
          end
          GameTooltip:AddDoubleLine("Runs this Season:", WHITE_FONT_COLOR:WrapTextInColorCode(tostring(numSeasonRuns)), nil, nil, nil, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)

          -- Dungeon information
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("Highest Keys:")
          TableForEach(dungeons, function(dungeon)
            local level = "-"
            local levelColor = LIGHTGRAY_FONT_COLOR
            if character.mythicplus.dungeons ~= nil and TableCount(character.mythicplus.dungeons) > 0 then
              local characterDungeon = TableGet(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
              if characterDungeon ~= nil and type(characterDungeon.level) == "number" and characterDungeon.level > 0 then
                level = format("+%s", tostring(characterDungeon.level))
                levelColor = WHITE_FONT_COLOR
              end
            end
            GameTooltip:AddDoubleLine(dungeon.name, level, 1, 1, 1, levelColor.r, levelColor.g, levelColor.b)
          end)
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
          numSeasonRuns = TableCount(character.mythicplus.runHistory)
        end
        if character.mythicplus.dungeons ~= nil
          and TableCount(character.mythicplus.dungeons) > 0
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
            dungeon = TableGet(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
          elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
            dungeon = TableGet(dungeons, "mapId", character.mythicplus.keystone.mapId)
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
        if character.mythicplus.keystone == nil then return end
        local itemLink = character.mythicplus.keystone.itemLink
        if type(itemLink) == "string" and itemLink ~= "" then
          GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
          GameTooltip:SetHyperlink(itemLink)
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          GameTooltip:Show()
          return
        end
        local dungeon
        if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
          dungeon = TableGet(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
        elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
          dungeon = TableGet(dungeons, "mapId", character.mythicplus.keystone.mapId)
        end
        if dungeon == nil then return end
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(dungeon.name, 1, 1, 1)
        if type(character.mythicplus.keystone.level) == "number" and character.mythicplus.keystone.level > 0 then
          GameTooltip:AddLine(format("Mythic Keystone Level %d", character.mythicplus.keystone.level), 1, 1, 1)
        end
        GameTooltip:Show()
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
      label = DELVES_GREAT_VAULT_LABEL,
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
      enabled = Data.db.global.vault.raids or Data.db.global.vault.dungeons or Data.db.global.vault.world,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode(RAIDS),
      value = function(character) return getVaultProgressValue(character, Enum.WeeklyRewardChestThresholdType.Raid) end,
      onEnter = function(infoFrame, character) getVaultProgressTooltip(infoFrame, character, Enum.WeeklyRewardChestThresholdType.Raid) end,
      onLeave = function() GameTooltip:Hide() end,
      enabled = Data.db.global.vault.raids,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode(DUNGEONS),
      value = function(character) return getVaultProgressValue(character, Enum.WeeklyRewardChestThresholdType.Activities) end,
      onEnter = function(infoFrame, character) getVaultProgressTooltip(infoFrame, character, Enum.WeeklyRewardChestThresholdType.Activities) end,
      onLeave = function() GameTooltip:Hide() end,
      enabled = Data.db.global.vault.dungeons,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode(WORLD),
      value = function(character) return getVaultProgressValue(character, Enum.WeeklyRewardChestThresholdType.World) end,
      onEnter = function(infoFrame, character) getVaultProgressTooltip(infoFrame, character, Enum.WeeklyRewardChestThresholdType.World) end,
      onLeave = function() GameTooltip:Hide() end,
      enabled = Data.db.global.vault.world,
    },
  }

  if unfiltered then
    return rows
  end

  return TableFilter(rows, function(info)
    return info.enabled
  end)
end

---Render the main window
function Module:Render()
  local currentAffixes = Data:GetCurrentAffixes()
  local seasonID = Data:GetCurrentSeason()
  local dungeons = Data:GetDungeons()
  local currencies = Data:GetCurrencies()
  local raidDifficulties = Data:GetRaidDifficulties()
  local characterInfo = self:GetCharacterInfo()
  local raids = Data:GetRaids()
  local characters = Data:GetCharacters()
  local numCharacters = TableCount(characters)
  local affixes = Data:GetAffixes(true)
  local windowWidthMax = LibLiqUI.Utils.GetMaxWindowWidth()
  local windowWidth, windowHeight = numCharacters == 0 and 500 or 0, 0
  local weeklyAffixesModule = addon.Core:GetModule("WeeklyAffixes", true)

  if not self.window then
    local windows = Data.db.global.liqui.windows
    self.window = LibLiqUI:NewElement("Window", {
      name = addon.name .. "Main",
      storage = windows.Main,
      title = addon.name,
      icon = Constants.media.LogoTransparent,
      overlayFontObject = "GameFontHighlight_NoShadow",
      overlayTextColor = {r = 1, g = 0.82, b = 0, a = 1},
      onShow = function()
        Module:Render()
      end,
      onSettingsMenu = function(window, menu)
            menu:CreateTitle(CHARACTER)
            local currentCharacterMarkerSetting = menu:CreateButton("Current character")
            TableForEach(Constants.currentCharacterMarkers, function(marker)
              currentCharacterMarkerSetting:CreateRadio(
                marker.label,
                function(id) return Data.db.global.currentCharacterMarker == id end,
                function(id)
                  Data.db.global.currentCharacterMarker = id
                  self:Render()
                end,
                marker.id
              )
            end)
            currentCharacterMarkerSetting:SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Mark the character you are playing in the grid.", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show characters with zero rating",
              function() return Data.db.global.showZeroRatedCharacters end,
              function()
                Data.db.global.showZeroRatedCharacters = not Data.db.global.showZeroRatedCharacters
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Too many alts?", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show realm",
              function() return Data.db.global.showRealms end,
              function()
                Data.db.global.showRealms = not Data.db.global.showRealms
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("They're everywhere!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show guild",
              function() return Data.db.global.showGuildInformation end,
              function()
                Data.db.global.showGuildInformation = not Data.db.global.showGuildInformation
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Show the guild name, rank, and realm.", nil, nil, nil, true)
            end)
            local rioColors = menu:CreateCheckbox(
              "Use Raider.IO rating colors",
              function() return Data.db.global.useRIOScoreColor end,
              function()
                Data.db.global.useRIOScoreColor = not Data.db.global.useRIOScoreColor
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
            menu:CreateTitle(DELVES_GREAT_VAULT_LABEL)
            menu:CreateCheckbox(
              "Show Raids",
              function() return Data.db.global.vault.raids end,
              function()
                Data.db.global.vault.raids = not Data.db.global.vault.raids
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Just one more!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show Dungeons",
              function() return Data.db.global.vault.dungeons end,
              function()
                Data.db.global.vault.dungeons = not Data.db.global.vault.dungeons
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Just one more!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show World",
              function() return Data.db.global.vault.world end,
              function()
                Data.db.global.vault.world = not Data.db.global.vault.world
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Just one more!", nil, nil, nil, true)
            end)
            menu:CreateTitle("Prey Hunts")
            menu:CreateCheckbox(
              "Enable Prey Hunts",
              function() return Data.db.global.prey.enabled end,
              function()
                Data.db.global.prey.enabled = not Data.db.global.prey.enabled
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Let's go for a hunt!", nil, nil, nil, true)
            end)
            local preyDifficultiesSetting = menu:CreateButton(
              "Difficulties"
            )
            TableForEach(Data:GetPreyDifficulties(true), function(difficulty)
              local hiddenDifficulties = Data.db.global.prey.hiddenDifficulties or {}
              preyDifficultiesSetting:CreateCheckbox(
                difficulty.name,
                function(difficultyID) return not hiddenDifficulties[difficultyID] end,
                function(difficultyID)
                  Data.db.global.prey.hiddenDifficulties[difficultyID] = not hiddenDifficulties[difficultyID]
                  self:Render()
                end,
                difficulty.id
              )
            end)
            menu:CreateTitle(DUNGEONS)
            menu:CreateCheckbox(
              "Enable Dungeons",
              function() return Data.db.global.dungeons.enabled end,
              function()
                Data.db.global.dungeons.enabled = not Data.db.global.dungeons.enabled
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Show Mythic+ dungeon information!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show icons",
              function() return Data.db.global.showTiers end,
              function()
                Data.db.global.showTiers = not Data.db.global.showTiers
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show rating",
              function() return Data.db.global.showScores end,
              function()
                Data.db.global.showScores = not Data.db.global.showScores
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Show some scores!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Use rating colors",
              function() return Data.db.global.showAffixColors end,
              function()
                Data.db.global.showAffixColors = not Data.db.global.showAffixColors
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Show some colors!", nil, nil, nil, true)
            end)
            menu:CreateTitle(RAIDS)
            menu:CreateCheckbox(
              "Enable Raids",
              function() return Data.db.global.raids.enabled end,
              function()
                Data.db.global.raids.enabled = not Data.db.global.raids.enabled
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Because MythicPlus ain't enough!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Use difficulty colors",
              function() return Data.db.global.raids.colors end,
              function()
                Data.db.global.raids.colors = not Data.db.global.raids.colors
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Argharhggh! So much greeeen!", nil, nil, nil, true)
            end)
            local raidKillIconSetting = menu:CreateButton("Kill icon")
            TableForEach(Constants.raidKillIcons, function(icon)
              raidKillIconSetting:CreateRadio(
                icon.label,
                function(id) return (Data.db.global.raids.killIcon or "skull") == id end,
                function(id)
                  Data.db.global.raids.killIcon = id
                  self:Render()
                end,
                icon.id
              )
            end)
            local raidDifficultiesSetting = menu:CreateButton(
              "Difficulties"
            )
            TableForEach(Data:GetRaidDifficulties(true), function(difficulty)
              local hiddenDifficulties = Data.db.global.raids.hiddenDifficulties or {}
              raidDifficultiesSetting:CreateCheckbox(
                difficulty.name,
                function(id) return not hiddenDifficulties[id] end,
                function(id)
                  Data.db.global.raids.hiddenDifficulties[id] = not hiddenDifficulties[id]
                  self:Render()
                end,
                difficulty.id
              )
            end)
            menu:CreateTitle("Currencies")
            menu:CreateCheckbox(
              "Enable Currencies",
              function() return Data.db.global.currencies.enabled end,
              function()
                Data.db.global.currencies.enabled = not Data.db.global.currencies.enabled
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Time to farm!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show icons",
              function() return Data.db.global.currencies.showIcons end,
              function()
                Data.db.global.currencies.showIcons = not Data.db.global.currencies.showIcons
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("So fancy!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Align text center",
              function() return Data.db.global.currencies.alignCenter end,
              function()
                Data.db.global.currencies.alignCenter = not Data.db.global.currencies.alignCenter
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Left or right? Center it is!", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Highlight max earned",
              function() return Data.db.global.currencies.showMaxEarned end,
              function()
                Data.db.global.currencies.showMaxEarned = not Data.db.global.currencies.showMaxEarned
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("They really do this, huh?", nil, nil, nil, true)
            end)
            local enabledCurrenciesOption = menu:CreateButton(
              "Currencies"
            )
            TableForEach(Data:GetCurrencies(), function(currency)
              local hiddenCurrencies = Data.db.global.currencies.hiddenCurrencies or {}
              enabledCurrenciesOption:CreateCheckbox(
                currency.name,
                function(id) return not hiddenCurrencies[id] end,
                function(id)
                  Data.db.global.currencies.hiddenCurrencies[id] = not hiddenCurrencies[id]
                  self:Render()
                end,
                currency.id
              )
            end)
            menu:CreateDivider()
            menu:CreateTitle(INTERFACE_OPTIONS)
            menu:CreateCheckbox(
              "Show Weekly Affixes",
              function() return Data.db.global.showAffixHeader end,
              function()
                Data.db.global.showAffixHeader = not Data.db.global.showAffixHeader
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("The affixes will be shown at the top.", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Show the minimap button",
              function() return not Data.db.global.minimap.hide end,
              function()
                Data.db.global.minimap.hide = not Data.db.global.minimap.hide
                addon.Libs.LibDBIcon:Refresh(addon.name, Data.db.global.minimap)
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("It does get crowded around the minimap sometimes.", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Lock the minimap button",
              function() return Data.db.global.minimap.lock end,
              function()
                Data.db.global.minimap.lock = not Data.db.global.minimap.lock
                addon.Libs.LibDBIcon:Refresh(addon.name, Data.db.global.minimap)
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("No more moving the button around accidentally!", nil, nil, nil, true)
            end)
          end,
      titlebarButtons = {
        {
          name = "Characters",
          icon = Constants.media.IconCharacters,
          tooltipTitle = "Characters",
          tooltipDescription = "Toggle your characters.",
          onMenu = function(_, rootMenu)
            local charactersUnfiltered = Data:GetCharacters(true)
            rootMenu:SetScrollMode(math.min(20 * 50, GetScreenHeight() - 20)) -- 20 pixels per row, 50 rows
            TableForEach(charactersUnfiltered, function(char)
              local nameColor = WHITE_FONT_COLOR
              if char.info.class.file ~= nil then
                local classColor = C_ClassColor.GetClassColor(char.info.class.file)
                if classColor ~= nil then
                  nameColor = CreateColor(classColor.r, classColor.g, classColor.b, 1)
                end
              end
              local characterName = format("%s (%s)", nameColor:WrapTextInColorCode(char.info.name), char.info.realm)
              local characterButton = rootMenu:CreateCheckbox(
                characterName,
                function(value) return Data.db.global.characters[value].enabled end,
                function(value)
                  Data.db.global.characters[value].enabled = not Data.db.global.characters[value].enabled
                  self:Render()
                end,
                char.GUID
              )
              if char.GUID ~= UnitGUID("player") then
                local removeButton = characterButton:CreateButton("Remove character", function()
                  StaticPopup_Show("ALTEREGO_DELETE_CHARACTER", characterName, nil, char)
                end)
                removeButton:SetTooltip(function(tooltip, elm)
                  tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
                  tooltip:AddLine(format("Remove %s?", characterName), nil, nil, nil, true)
                end)
              end
            end)
          end,
          iconSize = 14,
        },
        {
          name = "Sorting",
          icon = Constants.media.IconSorting,
          tooltipTitle = "Sorting",
          tooltipDescription = "Sort your characters.",
          onMenu = function(_, rootMenu)
            for _, option in ipairs(Constants.sortingOptions) do
              local button = rootMenu:CreateRadio(
                option.text,
                function(value) return Data.db.global.sorting == value end,
                function(value)
                  Data.db.global.sorting = value
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
          end,
          iconSize = 16,
        },
        {
          name = "Announce",
          icon = Constants.media.IconAnnounce,
          tooltipTitle = "Announcements",
          tooltipDescription = "Sharing is caring.",
          onMenu = function(window, menu)
            menu:CreateTitle("Announce Current Keystones")
            local sendToParty = menu:CreateButton(
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
            local sendToGuild = menu:CreateButton(
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
            menu:CreateTitle(OPTIONS)
            local withCharacterNames
            local withMultipleMessages = menu:CreateCheckbox(
              "Multiple chat messages",
              function() return Data.db.global.announceKeystones.multiline end,
              function()
                Data.db.global.announceKeystones.multiline = not Data.db.global.announceKeystones.multiline
                withCharacterNames:SetEnabled(Data.db.global.announceKeystones.multiline)
              end
            )
            withCharacterNames = menu:CreateCheckbox(
              "Include character names",
              function() return Data.db.global.announceKeystones.multilineNames end,
              function() Data.db.global.announceKeystones.multilineNames = not Data.db.global.announceKeystones.multilineNames end
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
              if not Data.db.global.announceKeystones.multiline then
                tooltip:AddLine(" ")
                tooltip:AddLine("Multiple chat messages must be enabled.", 1, 0, 0, true)
              end
            end)
            withCharacterNames:SetEnabled(Data.db.global.announceKeystones.multiline)
            menu:CreateDivider()
            menu:CreateTitle("Automatic Announcements")
            menu:CreateCheckbox(
              "Announce instance resets",
              function() return Data.db.global.announceResets end,
              function()
                Data.db.global.announceResets = not Data.db.global.announceResets
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Let others in your group know when you've reset the instances.", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Announce new keystones (Party)",
              function() return Data.db.global.announceKeystones.autoParty end,
              function()
                Data.db.global.announceKeystones.autoParty = not Data.db.global.announceKeystones.autoParty
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Announce to your party when you loot a new keystone.", nil, nil, nil, true)
            end)
            menu:CreateCheckbox(
              "Announce new keystones (Guild)",
              function() return Data.db.global.announceKeystones.autoGuild end,
              function()
                Data.db.global.announceKeystones.autoGuild = not Data.db.global.announceKeystones.autoGuild
                self:Render()
              end
            ):SetTooltip(function(tooltip, elm)
              tooltip:AddLine(MenuUtil.GetElementText(elm), 1, 1, 1, true)
              tooltip:AddLine("Announce to your guild when you loot a new keystone.", nil, nil, nil, true)
            end)
          end,
          iconSize = 12,
        },
        {
          name = "GreatVault",
          icon = Constants.media.IconKeyhole,
          tooltipTitle = DELVES_GREAT_VAULT_LABEL,
          tooltipDescription = WEEKLY_REWARDS_ADD_ITEMS .. "\n\n" .. GREEN_FONT_COLOR:WrapTextInColorCode(format("<%s>", WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS)),
          onClick = function()
            addon.Core:ToggleVault()
          end,
          iconSize = 13,
        },
      },
    })
    local sidebarWidth = Constants.sizes.sidebar.width
    self.window.body.sidebar = CreateFrame("Frame", "$parentSidebar", self.window.body)
    self.window.body.sidebar:SetPoint("TOPLEFT", self.window.body, "TOPLEFT")
    self.window.body.sidebar:SetPoint("BOTTOMLEFT", self.window.body, "BOTTOMLEFT")
    self.window.body.sidebar:SetWidth(sidebarWidth)
    SetBackgroundColor(self.window.body.sidebar, 0, 0, 0, 0.3)
    self.window.body.content = CreateFrame("Frame", "$parentContent", self.window.body)
    self.window.body.content:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPRIGHT")
    self.window.body.content:SetPoint("BOTTOMRIGHT", self.window.body, "BOTTOMRIGHT")
    self.window.body.content.scrollArea = CreateScrollArea(self.window.body.content, {
      horizontal = true,
      name = "$parentCharacterScroll",
    })
    self.window.body.content.scrollArea:SetAllPoints()
    self.window.affixes = CreateFrame("Frame", "$parentAffixes", self.window.titlebar)
    self.window.affixes.buttons = {}
  end

  if not self.window:IsVisible() then
    return
  end

  local scrollContent = self.window.body.content.scrollArea.content

  do -- Titlebar: Affixes
    if numCharacters < 3 then
      self.window.titlebar.title:Hide()
    else
      self.window.titlebar.title:Show()
    end

    if currentAffixes and TableCount(currentAffixes) > 0 and Data.db.global.showAffixHeader then
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
      TableForEach(currentAffixes, function(affix, affixIndex)
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
          if weeklyAffixesModule then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Click to View Weekly Affixes>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          end
          GameTooltip:Show()
        end)
        affixFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)
        affixFrame:SetScript("OnClick", function()
          if not weeklyAffixesModule then return end
          local affixesWindow = LibLiqUI:GetElement("Window", addon.name .. "Affixes")
          if affixesWindow then
            affixesWindow:Toggle()
          end
        end)

        if affixIndex == 1 then
          affixFrame:ClearAllPoints()
          if numCharacters < 3 then
            affixFrame:SetPoint("LEFT", self.window.titlebar.icon, "RIGHT", 6, 0)
          else
            affixFrame:SetPoint("CENTER", affixAnchor, "CENTER", -((TableCount(currentAffixes) * 20) / 2), 0)
          end
        else
          affixFrame:SetPoint("LEFT", affixAnchor, "RIGHT", 6, 0)
        end
        affixAnchor = affixFrame
      end)
    end
  end

  do -- Sidebar
    local rowCount = 0
    local totalHeight = 0
    do -- CharacterInfo Labels
      self.window.body.sidebar.infoFrames = self.window.body.sidebar.infoFrames or {}
      TableForEach(self.window.body.sidebar.infoFrames, function(f) f:Hide() end)
      TableForEach(characterInfo, function(info, infoIndex)
        local infoFrame = self.window.body.sidebar.infoFrames[infoIndex]
        if not infoFrame then
          infoFrame = CreateFrame("Frame", "$parentInfo" .. infoIndex, self.window.body.sidebar)
          infoFrame.text = infoFrame:CreateFontString(infoFrame:GetName() .. "Text", "OVERLAY")
          infoFrame.text:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", Constants.sizes.padding, -3)
          infoFrame.text:SetPoint("BOTTOMRIGHT", infoFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
          infoFrame.text:SetJustifyH("LEFT")
          infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          infoFrame.text:SetVertexColor(1.0, 0.82, 0.0, 1)
          self.window.body.sidebar.infoFrames[infoIndex] = infoFrame
        end

        infoFrame:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
        infoFrame:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
        infoFrame:SetHeight(Constants.sizes.row)
        infoFrame.text:SetText(info.label)
        infoFrame:Show()
        rowCount = rowCount + 1
        totalHeight = totalHeight + Constants.sizes.row
      end)
    end

    do -- Prey Header
      local label = self.window.body.sidebar.preyLabel
      if not label then
        label = CreateFrame("Frame", "$parentPreyLabel", self.window.body.sidebar)
        label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
        label.text:SetPoint("TOPLEFT", label, "TOPLEFT", Constants.sizes.padding, 0)
        label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -Constants.sizes.padding, 0)
        label.text:SetFontObject("GameFontHighlight_NoShadow")
        label.text:SetJustifyH("LEFT")
        label.text:SetText("Prey Hunts")
        label.text:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.window.body.sidebar.preyLabel = label
      end
      if Data.db.global.prey.enabled then
        label:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
        label:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
        label:SetHeight(Constants.sizes.row)
        label:Show()
        rowCount = rowCount + 1
        totalHeight = totalHeight + Constants.sizes.row
      else
        label:Hide()
      end
    end

    do -- Prey Difficulties
      self.window.body.sidebar.preyDifficulties = self.window.body.sidebar.preyDifficulties or {}
      TableForEach(self.window.body.sidebar.preyDifficulties, function(f) f:Hide() end)
      TableForEach(Data:GetPreyDifficulties(), function(difficulty, difficultyIndex)
        if not Data.db.global.prey.enabled then return end
        local difficultyFrame = self.window.body.sidebar.preyDifficulties[difficultyIndex]
        if not difficultyFrame then
          difficultyFrame = CreateFrame("Frame", "$parentPreyDifficulty" .. difficultyIndex, self.window.body.sidebar)
          difficultyFrame.text = difficultyFrame:CreateFontString(difficultyFrame:GetName() .. "Text", "OVERLAY")
          difficultyFrame.text:SetPoint("TOPLEFT", difficultyFrame, "TOPLEFT", Constants.sizes.padding, -3)
          difficultyFrame.text:SetPoint("BOTTOMRIGHT", difficultyFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
          difficultyFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          difficultyFrame.text:SetJustifyH("LEFT")
          difficultyFrame.text:SetVertexColor(1.0, 1.0, 1.0, 1.0)
          self.window.body.sidebar.preyDifficulties[difficultyIndex] = difficultyFrame
        end

        difficultyFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
          GameTooltip:SetText(difficulty.name, 1, 1, 1)
          GameTooltip:AddLine("With each difficulty level, new affixes are added, leading to more challenging encounters.", nil, nil, nil, true)
          TableForEach(difficulty.affixes, function(affixID)
            local affix = TableGet(Data.preyAffixes, "id", affixID)
            if not affix then return end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(format("%s:", affix.name), nil, nil, nil, true)
            GameTooltip:AddLine(affix.description, 1, 1, 1, true)
          end)
          GameTooltip:Show()
        end)
        difficultyFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)

        difficultyFrame:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
        difficultyFrame:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
        difficultyFrame:SetHeight(Constants.sizes.row)
        difficultyFrame.text:SetText(difficulty.name)
        difficultyFrame:Show()
        rowCount = rowCount + 1
        totalHeight = totalHeight + Constants.sizes.row
      end)
    end

    do -- MythicPlus Header
      local label = self.window.body.sidebar.mpluslabel
      if not label then
        label = CreateFrame("Frame", "$parentMythicPlusLabel", self.window.body.sidebar)
        label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
        label.text:SetPoint("TOPLEFT", label, "TOPLEFT", Constants.sizes.padding, 0)
        label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -Constants.sizes.padding, 0)
        label.text:SetFontObject("GameFontHighlight_NoShadow")
        label.text:SetJustifyH("LEFT")
        label.text:SetText(DUNGEONS)
        label.text:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.window.body.sidebar.mpluslabel = label
      end

      if Data.db.global.dungeons.enabled then
        label:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
        label:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
        label:SetHeight(Constants.sizes.row)
        label:Show()
        rowCount = rowCount + 1
        totalHeight = totalHeight + Constants.sizes.row
      else
        label:Hide()
      end
    end

    do -- MythicPlus Labels
      self.window.body.sidebar.mpluslabels = self.window.body.sidebar.mpluslabels or {}
      TableForEach(self.window.body.sidebar.mpluslabels, function(f) f:Hide() end)
      if Data.db.global.dungeons.enabled then
        TableForEach(dungeons, function(dungeon, dungeonIndex)
          local dungeonFrame = self.window.body.sidebar.mpluslabels[dungeonIndex]
          if not dungeonFrame then
            dungeonFrame = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, self.window.body.sidebar, "InsecureActionButtonTemplate")
            dungeonFrame:RegisterForClicks("AnyUp", "AnyDown")
            dungeonFrame:EnableMouse(true)
            dungeonFrame.icon = dungeonFrame:CreateTexture(dungeonFrame:GetName() .. "Icon", "ARTWORK")
            dungeonFrame.icon:SetSize(16, 16)
            dungeonFrame.icon:SetPoint("LEFT", dungeonFrame, "LEFT", Constants.sizes.padding, 0)
            dungeonFrame.text = dungeonFrame:CreateFontString(dungeonFrame:GetName() .. "Text", "OVERLAY")
            dungeonFrame.text:SetPoint("TOPLEFT", dungeonFrame, "TOPLEFT", 16 + Constants.sizes.padding * 2, -3)
            dungeonFrame.text:SetPoint("BOTTOMRIGHT", dungeonFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
            dungeonFrame.text:SetJustifyH("LEFT")
            dungeonFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            self.window.body.sidebar.mpluslabels[dungeonIndex] = dungeonFrame
          end

          local knownTeleportSpellID = TableFind(dungeon.teleports or {}, function(spellID)
            return C_SpellBook.IsSpellInSpellBook(spellID)
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

          dungeonFrame:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
          dungeonFrame:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
          dungeonFrame:SetHeight(Constants.sizes.row)
          dungeonFrame.icon:SetTexture(tostring(dungeon.texture))
          dungeonFrame.text:SetText(dungeon.short and dungeon.short or dungeon.name)
          dungeonFrame:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        end)
      end
    end

    do -- Raid Header
      local label = self.window.body.sidebar.raidHeader
      if not label then
        label = CreateFrame("Frame", "$parentRaidHeader", self.window.body.sidebar)
        label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
        label.text:SetPoint("TOPLEFT", label, "TOPLEFT", Constants.sizes.padding, 0)
        label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -Constants.sizes.padding, 0)
        label.text:SetFontObject("GameFontHighlight_NoShadow")
        label.text:SetJustifyH("LEFT")
        label.text:SetText(RAIDS)
        label.text:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.window.body.sidebar.raidHeader = label
      end

      if Data.db.global.raids.enabled then
        label:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
        label:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
        label:SetHeight(Constants.sizes.row)
        label:Show()
        rowCount = rowCount + 1
        totalHeight = totalHeight + Constants.sizes.row
      else
        label:Hide()
      end
    end

    do -- Raid Difficulties
      self.window.body.sidebar.raidDifficulties = self.window.body.sidebar.raidDifficulties or {}
      TableForEach(self.window.body.sidebar.raidDifficulties, function(f) f:Hide() end)
      if Data.db.global.raids.enabled then
        TableForEach(raidDifficulties, function(difficulty, difficultyIndex)
          local difficultyFrame = self.window.body.sidebar.raidDifficulties[difficultyIndex]
          if not difficultyFrame then
            difficultyFrame = CreateFrame("Frame", "$parentRaidDifficulty" .. difficultyIndex, self.window.body.sidebar)
            difficultyFrame.text = difficultyFrame:CreateFontString(difficultyFrame:GetName() .. "Text", "OVERLAY")
            difficultyFrame.text:SetPoint("TOPLEFT", difficultyFrame, "TOPLEFT", Constants.sizes.padding, -3)
            difficultyFrame.text:SetPoint("BOTTOMRIGHT", difficultyFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
            difficultyFrame.text:SetJustifyH("LEFT")
            difficultyFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            self.window.body.sidebar.raidDifficulties[difficultyIndex] = difficultyFrame
          end

          difficultyFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(difficulty.name, 1, 1, 1)
            GameTooltip:Show()
          end)
          difficultyFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
          end)

          difficultyFrame:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
          difficultyFrame:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
          difficultyFrame:SetHeight(RAIDS_ROW_HEIGHT)
          difficultyFrame.text:SetText(difficulty.short and difficulty.short or difficulty.name)
          difficultyFrame:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + RAIDS_ROW_HEIGHT
        end)
      end
    end

    do -- Currencies Header
      local label = self.window.body.sidebar.currencyLabel
      if not label then
        label = CreateFrame("Frame", "$parentCurrencyLabel", self.window.body.sidebar)
        label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
        label.text:SetPoint("TOPLEFT", label, "TOPLEFT", Constants.sizes.padding, 0)
        label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -Constants.sizes.padding, 0)
        label.text:SetFontObject("GameFontHighlight_NoShadow")
        label.text:SetJustifyH("LEFT")
        label.text:SetText("Currencies")
        label.text:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.window.body.sidebar.currencyLabel = label
      end

      if Data.db.global.currencies.enabled then
        label:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
        label:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
        label:SetHeight(Constants.sizes.row)
        label:Show()
        rowCount = rowCount + 1
        totalHeight = totalHeight + Constants.sizes.row
      else
        label:Hide()
      end
    end

    do -- Currency Labels
      self.window.body.sidebar.currencyLabels = self.window.body.sidebar.currencyLabels or {}
      TableForEach(self.window.body.sidebar.currencyLabels, function(f) f:Hide() end)
      if Data.db.global.currencies.enabled then
        TableForEach(currencies, function(currency, currencyIndex)
          if Data.db.global.currencies.hiddenCurrencies and Data.db.global.currencies.hiddenCurrencies[currency.id] then
            return
          end
          local label = self.window.body.sidebar.currencyLabels[currencyIndex]
          if not label then
            label = CreateFrame("Frame", "$parentCurrency" .. currencyIndex, self.window.body.sidebar)
            label.icon = label:CreateTexture(label:GetName() .. "Icon", "ARTWORK")
            label.icon:SetSize(16, 16)
            label.icon:SetPoint("LEFT", label, "LEFT", Constants.sizes.padding, 0)
            label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
            label.text:SetPoint("TOPLEFT", label, "TOPLEFT", 16 + Constants.sizes.padding * 2, -3)
            label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
            label.text:SetJustifyH("LEFT")
            label.text:SetFontObject("GameFontHighlight_NoShadow")
            self.window.body.sidebar.currencyLabels[currencyIndex] = label
          end

          local color = ITEM_QUALITY_COLORS[currency.quality]

          label:SetScript("OnEnter", function()
            GameTooltip:SetOwner(label, "ANCHOR_RIGHT")
            GameTooltip:SetText(currency.name, color.r, color.g, color.b)
            GameTooltip:AddLine(currency.description, nil, nil, nil, true)
            if currency.tooltipNote then
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine(format("%s %s", RARE_BLUE_COLOR:WrapTextInColorCode(addon.name .. ":"), currency.tooltipNote), 1, 1, 1, true)
            end
            GameTooltip:Show()
          end)
          label:SetScript("OnLeave", function()
            GameTooltip:Hide()
          end)

          label:SetPoint("TOPLEFT", self.window.body.sidebar, "TOPLEFT", 0, -totalHeight)
          label:SetPoint("TOPRIGHT", self.window.body.sidebar, "TOPRIGHT", 0, -totalHeight)
          label:SetHeight(Constants.sizes.row)
          label.icon:SetTexture(currency.iconFileID or [[Interface\Icons\INV_Misc_QuestionMark]])
          label.text:SetText(currency.short and currency.short or currency.name)
          label.text:SetTextColor(color.r, color.g, color.b)
          label:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        end)
      end
    end

    windowHeight = windowHeight + totalHeight
  end

  do -- Character Columns
    self.window.characterFrames = self.window.characterFrames or {}
    TableForEach(self.window.characterFrames, function(f) f:Hide() end)
    TableForEach(characters, function(character, characterIndex)
      local rowCount = 0
      local totalHeight = 0
      local characterFrame = self.window.characterFrames[characterIndex]
      if not characterFrame then
        characterFrame = CreateFrame("Frame", "$parentCharacterColumn" .. characterIndex, scrollContent)
        characterFrame.infoFrames = {}
        characterFrame.dungeonFrames = {}
        characterFrame.raidFrames = {}
        characterFrame.affixHeaderFrame = CreateFrame("Frame", "$parentAffixes", characterFrame)
        characterFrame.preyHeader = CreateFrame("Frame", "$parentPreyHeader", characterFrame)
        characterFrame.raidHeader = CreateFrame("Frame", "$parentRaidHeader", characterFrame)
        characterFrame.currencyHeaderFrame = CreateFrame("Frame", "$parentCurrencies", characterFrame)
        self.window.characterFrames[characterIndex] = characterFrame
      end

      characterFrame:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", (characterIndex - 1) * CHARACTER_WIDTH, 0)
      characterFrame:SetPoint("BOTTOMLEFT", scrollContent, "BOTTOMLEFT", (characterIndex - 1) * CHARACTER_WIDTH, 0)
      characterFrame:SetWidth(CHARACTER_WIDTH)
      SetBackgroundColor(characterFrame, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
      characterFrame:Show()

      do -- Current character overlay
        local overlay = characterFrame.currentCharacterOverlay
        if not overlay then
          overlay = CreateFrame("Frame", "$parentCurrentCharacterOverlay", characterFrame)
          overlay:SetAllPoints()
          overlay:EnableMouse(false)
          local color = DIM_GREEN_FONT_COLOR
          overlay.background = overlay:CreateTexture(nil, "BACKGROUND")
          overlay.background:SetAllPoints()
          overlay.background:SetColorTexture(color.r, color.g, color.b, 0.04)
          overlay.left = overlay:CreateTexture(nil, "ARTWORK")
          overlay.left:SetWidth(2)
          overlay.left:SetPoint("TOPLEFT")
          overlay.left:SetPoint("BOTTOMLEFT")
          overlay.left:SetColorTexture(color.r, color.g, color.b, 0.15)
          overlay.right = overlay:CreateTexture(nil, "ARTWORK")
          overlay.right:SetWidth(2)
          overlay.right:SetPoint("TOPRIGHT")
          overlay.right:SetPoint("BOTTOMRIGHT")
          overlay.right:SetColorTexture(color.r, color.g, color.b, 0.15)
          characterFrame.currentCharacterOverlay = overlay
        end
        overlay:SetFrameLevel(characterFrame:GetFrameLevel() + 50)
        if character.GUID == UnitGUID("player") and Data.db.global.currentCharacterMarker == "border" then
          overlay:Show()
        else
          overlay:Hide()
        end
      end

      do -- Info
        TableForEach(characterFrame.infoFrames, function(f) f:Hide() end)
        TableForEach(characterInfo, function(info, infoIndex)
          local infoFrame = characterFrame.infoFrames[infoIndex]
          if not infoFrame then
            infoFrame = CreateFrame("Button", "$parentInfo" .. infoIndex, characterFrame)
            infoFrame.text = infoFrame:CreateFontString(infoFrame:GetName() .. "Text", "OVERLAY")
            infoFrame.text:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", Constants.sizes.padding * 1.5, -Constants.sizes.padding)
            infoFrame.text:SetPoint("BOTTOMRIGHT", infoFrame, "BOTTOMRIGHT", -Constants.sizes.padding * 1.5, Constants.sizes.padding)
            infoFrame.text:SetJustifyH("CENTER")
            infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            characterFrame.infoFrames[infoIndex] = infoFrame
          end

          if infoIndex == 1 then
            if not infoFrame.SortLeftButton then
              infoFrame.SortLeftButton = CreateFrame("Button", infoFrame:GetName() .. "SortLeft", infoFrame)
              infoFrame.SortLeftButton:SetSize(Constants.sizes.row, Constants.sizes.row)
              infoFrame.SortLeftButton:SetPoint("LEFT", infoFrame, "LEFT")
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
              Data:SortCharacter(character, -1)
              self:Render()
            end)
            if not infoFrame.SortRightButton then
              infoFrame.SortRightButton = CreateFrame("Button", infoFrame:GetName() .. "SortRight", infoFrame)
              infoFrame.SortRightButton:SetSize(Constants.sizes.row, Constants.sizes.row)
              infoFrame.SortRightButton:SetPoint("RIGHT", infoFrame, "RIGHT")
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
              Data:SortCharacter(character, 1)
              self:Render()
            end)

            if not InCombatLockdown() then
              infoFrame.SortLeftButton:SetPropagateMouseMotion(true)
              infoFrame.SortRightButton:SetPropagateMouseMotion(true)
            end
          end

          if info.value then
            infoFrame.text:SetText(info.value(character))
          end

          if info.backgroundColor then
            SetBackgroundColor(infoFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
          else
            SetBackgroundColor(infoFrame, 0, 0, 0, 0)
          end

          infoFrame:SetScript("OnEnter", function()
            if info.onEnter then
              info.onEnter(infoFrame, character)
            end

            if infoIndex == 1 then
              infoFrame.SortLeftButton:Hide()
              infoFrame.SortRightButton:Hide()
              if Data.db.global.sorting == "custom" and not InCombatLockdown() then
                infoFrame.SortLeftButton:SetPropagateMouseMotion(true)
                infoFrame.SortRightButton:SetPropagateMouseMotion(true)
                if characterIndex > 1 then infoFrame.SortLeftButton:Show() end
                if characterIndex < numCharacters then infoFrame.SortRightButton:Show() end
              end
            end

            if not info.backgroundColor then
              SetHighlightColor(infoFrame)
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
              SetHighlightColor(infoFrame, 1, 1, 1, 0)
            end
          end)

          infoFrame:SetScript("OnClick", function()
            if info.onClick then
              info.onClick(infoFrame, character)
            end
          end)

          infoFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          infoFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          infoFrame:SetHeight(Constants.sizes.row)
          infoFrame:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        end)
      end

      do -- Prey Header
        if Data.db.global.prey.enabled then
          characterFrame.preyHeader:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          characterFrame.preyHeader:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          characterFrame.preyHeader:SetHeight(Constants.sizes.row)
          characterFrame.preyHeader:Show()
          SetBackgroundColor(characterFrame.preyHeader, 0, 0, 0, 0.3)
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        else
          characterFrame.preyHeader:Hide()
        end
      end

      do -- Prey Progress
        characterFrame.preyProgress = characterFrame.preyProgress or {}
        TableForEach(characterFrame.preyProgress, function(f) f:Hide() end)
        TableForEach(Data:GetPreyDifficulties(), function(difficulty, difficultyIndex)
          if not Data.db.global.prey.enabled then return end
          local difficultyFrame = characterFrame.preyProgress[difficultyIndex]
          if not difficultyFrame then
            difficultyFrame = CreateFrame("Frame", "$parentPreyProgress" .. difficultyIndex, characterFrame)
            difficultyFrame.Text = difficultyFrame:CreateFontString(difficultyFrame:GetName() .. "Text", "OVERLAY")
            difficultyFrame.Text:SetPoint("TOPLEFT", difficultyFrame, "TOPLEFT", Constants.sizes.padding * 1.5, -Constants.sizes.padding)
            difficultyFrame.Text:SetPoint("BOTTOMRIGHT", difficultyFrame, "BOTTOMRIGHT", -Constants.sizes.padding * 1.5, Constants.sizes.padding)
            difficultyFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
            difficultyFrame.Text:SetJustifyH("CENTER")
            characterFrame.preyProgress[difficultyIndex] = difficultyFrame
          end

          local textValue = "-"
          local textColor = LIGHTGRAY_FONT_COLOR
          local numQuestsCompleted = 0
          local characterQuestsCompleted = character.prey and character.prey.questsCompleted or {}

          local quests = TableFilter(Data.preyQuests, function(quest)
            return quest.difficultyID == difficulty.id
          end)
          local questsCompleted = TableFilter(quests, function(quest)
            return characterQuestsCompleted[quest.questID]
          end)
          numQuestsCompleted = TableCount(questsCompleted)

          if numQuestsCompleted >= preyWeeklyHuntCap then
            textValue = format("%d / %d", numQuestsCompleted, preyWeeklyHuntCap)
            textColor = GREEN_FONT_COLOR
          elseif numQuestsCompleted > 0 then
            textValue = format("%d / %d", numQuestsCompleted, preyWeeklyHuntCap)
            textColor = WHITE_FONT_COLOR
          end

          difficultyFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText("Prey Hunt Progress", 1, 1, 1)
            GameTooltip:AddDoubleLine("Difficulty:", difficulty.name, nil, nil, nil, 1, 1, 1)
            if character.prey == nil or character.prey.questsCompleted == nil then
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("No Data")
              GameTooltip:AddLine("Log your character to update.", 1, 1, 1, true)
            else
              GameTooltip:AddDoubleLine("Hunts Completed:", format("%d / %d", numQuestsCompleted, preyWeeklyHuntCap), nil, nil, nil, textColor.r, textColor.g, textColor.b)
            end
            if numQuestsCompleted > 0 then
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("Quests Done:")
              TableForEach(questsCompleted, function(quest)
                GameTooltip:AddLine(quest.name, 1, 1, 1)
              end)
            end
            GameTooltip:Show()
            SetHighlightColor(difficultyFrame, 1, 1, 1, 0.05)
          end)
          difficultyFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            SetHighlightColor(difficultyFrame, 1, 1, 1, 0)
          end)

          difficultyFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          difficultyFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          difficultyFrame:SetHeight(Constants.sizes.row)
          difficultyFrame:Show()
          difficultyFrame.Text:SetText(textValue)
          difficultyFrame.Text:SetTextColor(textColor.r, textColor.g, textColor.b)
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        end)
      end

      do -- Dungeon Header
        if Data.db.global.dungeons.enabled then
          characterFrame.affixHeaderFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          characterFrame.affixHeaderFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          characterFrame.affixHeaderFrame:SetHeight(Constants.sizes.row)
          characterFrame.affixHeaderFrame:Show()
          SetBackgroundColor(characterFrame.affixHeaderFrame, 0, 0, 0, 0.3)
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        else
          characterFrame.affixHeaderFrame:Hide()
        end
      end

      do -- Dungeons
        characterFrame.dungeonFrames = characterFrame.dungeonFrames or {}
        TableForEach(characterFrame.dungeonFrames, function(f) f:Hide() end)
        TableForEach(dungeons, function(dungeon, dungeonIndex)
          if not Data.db.global.dungeons.enabled then return end
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
            dungeonFrame.Score:SetPoint("RIGHT", dungeonFrame, "RIGHT", -Constants.sizes.padding * 2, 1)
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

          local characterDungeon = TableGet(character.mythicplus.dungeons or {}, "challengeModeID", dungeon.challengeModeID)
          if characterDungeon then
            affixScores = characterDungeon.affixScores
            overallScore = characterDungeon.bestOverAllScore
            inTimeInfo = characterDungeon.bestTimedRun
            overTimeInfo = characterDungeon.bestNotTimedRun

            if overallScore and Data.db.global.showAffixColors then
              local rarityColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overallScore)
              if rarityColor ~= nil then
                color = CreateColor(rarityColor.r, rarityColor.g, rarityColor.b, rarityColor.a)
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

                if bestAffixScore.durationSec <= Helpers:calculateDungeonTimer(dungeon.time, bestAffixScore.level, 3, seasonID) then
                  tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:0|a"
                elseif bestAffixScore.durationSec <= Helpers:calculateDungeonTimer(dungeon.time, bestAffixScore.level, 2, seasonID) then
                  tier = "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:0|a"
                elseif bestAffixScore.durationSec <= Helpers:calculateDungeonTimer(dungeon.time, bestAffixScore.level, 1, seasonID) then
                  tier = "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:0|a"
                end

                if bestAffixScore.overTime then
                  color = LIGHTGRAY_FONT_COLOR
                end
              end
            end
          end

          if level ~= "-" and Data.db.global.showTiers then
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

          if not Data.db.global.showScores then
            dungeonFrame.Text:ClearAllPoints()
            dungeonFrame.Text:SetPoint("CENTER", dungeonFrame, "CENTER")
            dungeonFrame.Score:SetText("")
          else
            if not Data.db.global.showTiers then
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

            if affixScores and TableCount(affixScores) > 0 then
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
            GameTooltip:AddLine("|A:Professions-ChatIcon-Quality-Tier1:14:14:0:0|a " .. SecondsToClock(Helpers:calculateDungeonTimer(dungeon.time, dungeonLevel, 1, seasonID), false), 1, 1, 1)
            GameTooltip:AddLine("|A:Professions-ChatIcon-Quality-Tier2:16:16:0:0|a " .. SecondsToClock(Helpers:calculateDungeonTimer(dungeon.time, dungeonLevel, 2, seasonID), false), 1, 1, 1)
            GameTooltip:AddLine("|A:Professions-ChatIcon-Quality-Tier3:16:16:0:0|a " .. SecondsToClock(Helpers:calculateDungeonTimer(dungeon.time, dungeonLevel, 3, seasonID), false), 1, 1, 1)
            GameTooltip:Show()

            SetHighlightColor(dungeonFrame, 1, 1, 1, 0.05)
          end)
          dungeonFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            SetHighlightColor(dungeonFrame, 1, 1, 1, 0)
          end)

          SetBackgroundColor(dungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
          dungeonFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          dungeonFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          dungeonFrame:SetHeight(Constants.sizes.row)
          dungeonFrame:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        end)
      end

      do -- Raid Header
        if Data.db.global.raids.enabled then
          characterFrame.raidHeader:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          characterFrame.raidHeader:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          characterFrame.raidHeader:SetHeight(Constants.sizes.row)
          characterFrame.raidHeader:Show()
          SetBackgroundColor(characterFrame.raidHeader, 0, 0, 0, 0.3)
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        else
          characterFrame.raidHeader:Hide()
        end
      end

      do -- Raids
        characterFrame.difficultyFrames = characterFrame.difficultyFrames or {}
        TableForEach(characterFrame.difficultyFrames, function(f) f:Hide() end)
        TableForEach(raidDifficulties or {}, function(difficulty, difficultyIndex)
          if not Data.db.global.raids.enabled then return end
          local difficultyFrame = characterFrame.difficultyFrames[difficultyIndex]
          if not difficultyFrame then
            difficultyFrame = CreateFrame("Frame", "$parentRaidDifficulty" .. difficultyIndex, characterFrame)
            difficultyFrame.iconFrames = {}
            -- difficultyFrame.dividers = {}
            characterFrame.difficultyFrames[difficultyIndex] = difficultyFrame
          end

          -- Update difficulty row
          SetBackgroundColor(difficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
          difficultyFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          difficultyFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          difficultyFrame:SetHeight(RAIDS_ROW_HEIGHT)
          difficultyFrame:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + RAIDS_ROW_HEIGHT

          -- Get all raid encounters
          ---@type AE_Encounter[]
          local encounters = {}
          local numEncounters = 0
          TableForEach(raids or {}, function(raid, raidIndex)
            TableForEach(raid.encounters or {}, function(encounter, encounterIndex)
              table.insert(encounters, encounter)
              numEncounters = numEncounters + 1
            end)
          end)

          difficultyFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true)
            GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name))
            TableForEach(raids, function(raid, raidIndex)
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine(raid.name)
              TableForEach(raid.encounters, function(encounter)
                local color = LIGHTGRAY_FONT_COLOR
                if character.raids.savedInstances then
                  local savedInstance = TableFind(character.raids.savedInstances, function(instance)
                    return GetBaseDifficultyID(instance.difficultyID) == difficulty.id and instance.instanceID == raid.instanceID and instance.expires > time()
                  end)
                  if savedInstance then
                    local savedEncounter = TableGet(savedInstance.encounters, "instanceEncounterID", encounter.instanceEncounterID)
                    if savedEncounter and savedEncounter.isKilled then
                      color = GREEN_FONT_COLOR
                    end
                  end
                end
                GameTooltip:AddLine(encounter.name, color.r, color.g, color.b)
              end)
            end)
            GameTooltip:Show()
            SetHighlightColor(difficultyFrame, 1, 1, 1, 0.05)
          end)

          difficultyFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            SetHighlightColor(difficultyFrame, 1, 1, 1, 0)
          end)

          local gapWidth = 6
          local encounterX = 3
          local halfEncounters = math.ceil(numEncounters / 2)
          local gapCount = halfEncounters + 1
          local gapWidthTotal = gapCount * gapWidth
          local iconSize = (CHARACTER_WIDTH - gapWidthTotal) / (halfEncounters + (numEncounters % 2 == 0 and 0.5 or 0))
          local iconSizeMax = RAIDS_ROW_HEIGHT * 0.5
          local killIcon = TableGet(Constants.raidKillIcons, "id", Data.db.global.raids.killIcon or "skull") or Constants.raidKillIcons[1]
          local killIconScale = killIcon.scale or 1
          TableForEach(difficultyFrame.iconFrames, function(f) f:Hide() end)
          TableForEach(encounters or {}, function(encounter, encounterIndex)
            local iconFrame = difficultyFrame.iconFrames[encounterIndex]
            if not iconFrame then
              iconFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, difficultyFrame)
              iconFrame.Background = iconFrame:CreateTexture("Background", "BACKGROUND")
              iconFrame.Background:SetAllPoints()
              difficultyFrame.iconFrames[encounterIndex] = iconFrame
            end

            local color = CreateColor(1, 1, 1)
            local alpha = 0.08

            if character.raids.savedInstances then
              local savedInstance = TableFind(character.raids.savedInstances, function(instance)
                return GetBaseDifficultyID(instance.difficultyID) == difficulty.id and instance.instanceID == encounter.instanceID and instance.expires > time()
              end)
              if savedInstance then
                local savedEncounter = TableGet(savedInstance.encounters, "instanceEncounterID", encounter.instanceEncounterID)
                if savedEncounter and savedEncounter.isKilled then
                  color = UNCOMMON_GREEN_COLOR
                  if Data.db.global.raids.colors then
                    color = difficulty.color
                  end
                  alpha = 0.5
                end
              end
            end

            iconFrame.Background:SetTexture(killIcon.texture)
            iconFrame.Background:SetVertexColor(color.r, color.g, color.b, alpha)

            local iconHeight = math.min(iconSize, iconSizeMax) * killIconScale
            local heightGap = (RAIDS_ROW_HEIGHT - iconHeight * 2) / 2
            local encounterY = heightGap
            encounterX = encounterX + gapWidth / 2 + (iconSize / 2)
            encounterY = encounterY + (iconHeight / 2) + 2
            if encounterIndex % 2 == 0 then -- Bottom
              encounterY = encounterY + iconHeight - 4
            end

            iconFrame:SetPoint("CENTER", difficultyFrame, "TOPLEFT", encounterX, -encounterY)
            iconFrame:SetSize(iconHeight, iconHeight)
            iconFrame:Show()
          end)
        end)
      end

      do -- Currency Header
        if Data.db.global.currencies.enabled then
          characterFrame.currencyHeaderFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          characterFrame.currencyHeaderFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          characterFrame.currencyHeaderFrame:SetHeight(Constants.sizes.row)
          characterFrame.currencyHeaderFrame:Show()
          SetBackgroundColor(characterFrame.currencyHeaderFrame, 0, 0, 0, 0.3)
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        else
          characterFrame.currencyHeaderFrame:Hide()
        end
      end

      do -- Currencies
        characterFrame.currencyFrames = characterFrame.currencyFrames or {}
        TableForEach(characterFrame.currencyFrames, function(f) f:Hide() end)
        TableForEach(currencies, function(currency, currencyIndex)
          if not Data.db.global.currencies.enabled then return end
          if Data.db.global.currencies.hiddenCurrencies and Data.db.global.currencies.hiddenCurrencies[currency.id] then return end

          local currencyFrame = characterFrame.currencyFrames[currencyIndex]
          if not currencyFrame then
            currencyFrame = CreateFrame("Frame", "$parentCurrencies" .. currencyIndex, characterFrame)
            currencyFrame.Text = currencyFrame:CreateFontString(currencyFrame:GetName() .. "TextLeft", "OVERLAY")
            currencyFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
            currencyFrame.Text:SetPoint("TOPLEFT", currencyFrame, "TOPLEFT", Constants.sizes.padding, -3)
            currencyFrame.Text:SetPoint("BOTTOMRIGHT", currencyFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
            currencyFrame.Text:SetJustifyH("LEFT")
            characterFrame.currencyFrames[currencyIndex] = currencyFrame
          end

          local infoMaxQuantity = currency.maxQuantity or 0
          local infoMaxWeeklyQuantity = currency.maxWeeklyQuantity or 0
          local infoIcon = CreateSimpleTextureMarkup(currency.iconFileID or [[Interface\Icons\INV_Misc_QuestionMark]])
          local charQuantity = 0
          local charTotalEarned = 0
          local charEarnedThisWeek = 0
          local hasEarnedMax = false
          local cellColor = CAMPAIGN_COMPLETE_COLOR
          local cellValue = "0"

          local characterCurrency = TableGet(character.currencies, "id", currency.id)
          if characterCurrency then
            charQuantity = characterCurrency.quantity or 0
            charTotalEarned = characterCurrency.totalEarned or 0
            charEarnedThisWeek = characterCurrency.quantityEarnedThisWeek or 0
          end

          if infoMaxQuantity > 0 then
            hasEarnedMax = charQuantity >= infoMaxQuantity
            if currency.useTotalEarnedForMaxQty then
              hasEarnedMax = charTotalEarned >= infoMaxQuantity
            end
          end
          if infoMaxWeeklyQuantity > 0 and charEarnedThisWeek >= infoMaxWeeklyQuantity then
            hasEarnedMax = true
          end

          cellValue = tostring(charQuantity)
          if Data.db.global.currencies.showIcons then
            cellValue = format("%s %s", infoIcon, cellValue)
          end

          if Data.db.global.currencies.showMaxEarned and hasEarnedMax then
            cellColor = DULL_RED_FONT_COLOR
          end

          if charQuantity == 0 then
            cellColor = GRAY_FONT_COLOR
            if currency.currencyType == "crest" and charTotalEarned == 0 then
              cellValue = "-"
            end
          end

          currencyFrame.Text:SetText(cellColor:WrapTextInColorCode(cellValue))
          currencyFrame.Text:SetJustifyH(Data.db.global.currencies.alignCenter and "CENTER" or "LEFT")
          currencyFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(currencyFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText("Currency Progress", 1, 1, 1)
            GameTooltip:AddDoubleLine("Owned:", tostring(charQuantity), nil, nil, nil, 1, 1, 1)
            if infoMaxWeeklyQuantity > 0 then
              GameTooltip:AddDoubleLine("Weekly Maximum:", format("%d/%d", charEarnedThisWeek, infoMaxWeeklyQuantity), nil, nil, nil, 1, 1, 1)
            end
            if currency.useTotalEarnedForMaxQty then
              if infoMaxQuantity > 0 then
                GameTooltip:AddDoubleLine("Season Maximum:", format("%d/%d", charTotalEarned, infoMaxQuantity), nil, nil, nil, 1, 1, 1)
              else
                if charTotalEarned > 0 then
                  GameTooltip:AddDoubleLine("Season Earned:", tostring(charTotalEarned), nil, nil, nil, 1, 1, 1)
                end
                GameTooltip:AddDoubleLine("Season Maximum:", "No limit", nil, nil, nil, 1, 1, 1)
              end
            else
              if charTotalEarned > 0 then
                GameTooltip:AddDoubleLine("Total Earned:", tostring(charTotalEarned), nil, nil, nil, 1, 1, 1)
              end
              if infoMaxQuantity > 0 then
                GameTooltip:AddDoubleLine("Total Maximum:", tostring(infoMaxQuantity), nil, nil, nil, 1, 1, 1)
              end
            end
            if currency.tooltipNote then
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine(format("%s %s", RARE_BLUE_COLOR:WrapTextInColorCode(addon.name .. ":"), currency.tooltipNote), 1, 1, 1, true)
            end
            GameTooltip:Show()
            SetHighlightColor(currencyFrame, 1, 1, 1, 0.05)
          end)
          currencyFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            SetHighlightColor(currencyFrame, 1, 1, 1, 0)
          end)

          SetBackgroundColor(currencyFrame, 1, 1, 1, currencyIndex % 2 == 0 and 0.01 or 0)
          currencyFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -totalHeight)
          currencyFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -totalHeight)
          currencyFrame:SetHeight(Constants.sizes.row)
          currencyFrame:Show()
          rowCount = rowCount + 1
          totalHeight = totalHeight + Constants.sizes.row
        end)
      end

      windowWidth = windowWidth + CHARACTER_WIDTH
    end)
  end

  local bodyWidth = math.min(windowWidth, windowWidthMax)
  if numCharacters > 0 then
    bodyWidth = bodyWidth + Constants.sizes.sidebar.width
  end
  self.window:SetBodySize(bodyWidth, windowHeight)
  self.window.body.content.scrollArea:UpdateLayout(windowWidth, windowHeight)

  local zeroCharactersText = "|cffffffffHi there :-)|r\nEnable a character top right for AlterEgo to show you some goodies!"
  if numCharacters <= 0 then
    if not Data.db.global.showZeroRatedCharacters and TableCount(Data:GetCharacters(true)) > 0 then
      zeroCharactersText = zeroCharactersText .. "\n\n|cff00ee00New Season?|r\nYou are currently hiding characters with zero rating. If this is not your intention then enable the setting |cffffffffShow characters with zero rating|r"
    end
    self.window:ShowOverlay(zeroCharactersText)
  else
    self.window:HideOverlay()
  end
end
