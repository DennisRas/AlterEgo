---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_UI
local UI = {}
addon.UI = UI

local LibDBIcon = LibStub("LibDBIcon-1.0")
local CHARACTER_WIDTH = 120

local function calculateDungeonTimer(time, level, tier)
  if tier == 3 then
    time = time * 0.6
  elseif tier == 2 then
    time = time * 0.8
  end

  if level >= 7 then
    time = time + 90
  end

  return time
end

--- Calculate the main window size
---@return number, number
function UI:GetBodySize()
  local numCharacters = addon.Utils:TableCount(addon.Data:GetCharacters())
  local numDungeons = addon.Utils:TableCount(addon.Data:GetDungeons())
  local numRaids = addon.Utils:TableCount(addon.Data:GetRaids())
  local numDifficulties = addon.Utils:TableCount(addon.Data:GetRaidDifficulties())
  local numCharacterInfo = addon.Utils:TableCount(self:GetCharacterInfo())
  local maxWidth = addon.Window:GetMaxWindowWidth()
  local width, height = 0, 0

  -- Width
  if numCharacters == 0 then
    width = 500
  else
    width = width + numCharacters * CHARACTER_WIDTH
  end
  if width > maxWidth then
    width = maxWidth
  end

  -- Height
  height = height + numCharacterInfo * addon.Constants.sizes.row                   -- Character info
  height = height + (numDungeons + 1) * addon.Constants.sizes.row                  -- Dungeons
  if addon.Data.db.global.raids.enabled == true then
    height = height + numRaids * (numDifficulties + 1) * addon.Constants.sizes.row -- Raids
  end

  return width, height
end

function UI:Render()
  self:RenderMainWindow()
  self:RenderAffixWindow()
  self:RenderEquipmentWindow()
end

function UI:GetCharacterInfo(unfiltered)
  local dungeons = addon.Data:GetDungeons()
  local difficulties = addon.Data:GetRaidDifficulties(true)
  local _, seasonDisplayID = addon.Data:GetCurrentSeason()

  ---@type AE_CharacterInfo[]
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
                currencyValue
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
        if character.mythicplus.rating ~= nil then
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
          local bestSeasonValue = bestSeasonScoreColor:WrapTextInColorCode(bestSeasonScore)
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
            unpack(dungeonScoreDungeonTable)
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
          return GREEN_FONT_COLOR:WrapTextInColorCode("Rewards")
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
      label = WHITE_FONT_COLOR:WrapTextInColorCode("Raids"),
      value = function(character)
        local activities = addon.Utils:TableFilter(character.vault.slots or {}, function(activity) return activity.type == Enum.WeeklyRewardChestThresholdType.Raid end)
        local values = {}

        for i = 1, 3 do
          local activity = addon.Utils:TableGet(activities, "index", i)
          local value = "-"
          local color = LIGHTGRAY_FONT_COLOR

          if activity then
            if activity.level > 0 then
              local dataDifficulty = addon.Utils:TableGet(difficulties, "id", activity.level)
              if dataDifficulty then
                value = dataDifficulty.abbr
                if addon.Data.db.global.raids.colors then
                  color = dataDifficulty.color
                end
              end
              if value == nil then
                local difficultyName = GetDifficultyInfo(activity.level)
                if difficultyName ~= nil then
                  value = tostring(difficultyName):sub(1, 1)
                else
                  value = "?"
                end
              end
              if color == nil then
                color = UNCOMMON_GREEN_COLOR
              end
            end
          end

          table.insert(values, color:WrapTextInColorCode(value))
        end
        return table.concat(values, "  ")
      end,
      onEnter = function(infoFrame, character)
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Vault Progress", 1, 1, 1)
        local characterSlots = character.vault.slots or {}
        local activities = addon.Utils:TableFilter(characterSlots, function(slot)
          return slot.type and slot.type == Enum.WeeklyRewardChestThresholdType.Raid
        end)

        do -- Show boss progress
          for i = 1, 3 do
            local activity = addon.Utils:TableGet(activities, "index", i)
            local label = format("%d bosses:", i * 2)
            local value = "Locked"
            local color = LIGHTGRAY_FONT_COLOR
            if activity then
              label = format("%d bosses:", activity.threshold)
              if activity.progress >= activity.threshold then
                color = WHITE_FONT_COLOR
                if activity.exampleRewardLink ~= nil and activity.exampleRewardLink ~= "" then
                  local itemLevel = GetDetailedItemLevelInfo(activity.exampleRewardLink)
                  local difficultyName = GetDifficultyInfo(activity.level)
                  local dataDifficulty = addon.Utils:TableGet(difficulties, "id", activity.level)
                  if dataDifficulty then
                    difficultyName = dataDifficulty.short and dataDifficulty.short or dataDifficulty.name
                  end
                  value = format("%s (%d+)", difficultyName, itemLevel)
                else
                  value = "?"
                end
              end
            end
            GameTooltip:AddDoubleLine(label, value, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
          end
        end

        do -- Show improvement info
          local tooltip = ""
          local incompleteSlots = addon.Utils:TableFilter(activities, function(slot) return slot.progress < slot.threshold end)
          table.sort(incompleteSlots, function(a, b) return a.threshold < b.threshold end)

          if addon.Utils:TableCount(activities) > 0 then
            if addon.Utils:TableCount(incompleteSlots) > 0 then
              if addon.Utils:TableCount(incompleteSlots) == addon.Utils:TableCount(activities) then
                tooltip = format("Defeat %d bosses this week to unlock your first Great Vault reward.", incompleteSlots[1].threshold)
              else
                local diff = incompleteSlots[1].threshold - incompleteSlots[1].progress
                if diff == 1 then
                  tooltip = format("Defeat %d more boss this week to unlock another Great Vault reward.", diff)
                else
                  tooltip = format("Defeat another %d bosses this week to unlock another Great Vault reward.", diff)
                end
              end
            end
          else
            tooltip = "Defeat 2 bosses this week to unlock your first Great Vault reward."
          end

          if tooltip ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
          end
        end
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
      enabled = addon.Data.db.global.raids.enabled,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("Dungeons"),
      value = function(character)
        local value = {}
        if character.vault.slots ~= nil then
          local slots = addon.Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.Activities
          end)
          if #slots > 0 then
            addon.Utils:TableForEach(slots, function(slot)
              local level = "-"
              local color = LIGHTGRAY_FONT_COLOR
              if slot.progress >= slot.threshold then
                level = tostring(slot.level)
                color = UNCOMMON_GREEN_COLOR
              end
              table.insert(value, color:WrapTextInColorCode(level))
            end)
          else
            for i = 1, 3 do
              table.insert(value, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode("-"))
            end
          end
        else
          for i = 1, 3 do
            table.insert(value, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode("-"))
          end
        end
        return table.concat(value, "  ")
      end,
      onEnter = function(infoFrame, character)
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Vault Progress", 1, 1, 1)
        local addBlankLine = false

        do -- Stats
          local lineAdded = false
          if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
            local numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
            local numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
            local numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
            if numHeroic > 0 then
              GameTooltip:AddLine("Heroic runs this Week: " .. "|cffffffff" .. tostring(numHeroic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
              lineAdded = true
            end
            if numMythic > 0 then
              GameTooltip:AddLine("Mythic runs this Week: " .. "|cffffffff" .. tostring(numMythic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
              lineAdded = true
            end
            if numMythicPlus > 0 then
              GameTooltip:AddLine("Mythic+ runs this Week: " .. "|cffffffff" .. tostring(numMythicPlus) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
              lineAdded = true
            end
          end
          addBlankLine = lineAdded
        end

        do -- Show progress
          local lineAdded = false
          local runsThisWeek = addon.Utils:TableFilter(character.mythicplus.runHistory or {}, function(run)
            return run.thisWeek == true
          end)
          local numRunsThisWeek = addon.Utils:TableCount(runsThisWeek) or 0
          if numRunsThisWeek > 0 then
            table.sort(runsThisWeek, function(a, b)
              return a.level > b.level
            end)

            if addBlankLine then GameTooltip_AddBlankLineToTooltip(GameTooltip) end
            GameTooltip:AddLine("Top Runs This Week:", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            lineAdded = true

            for runIndex, run in ipairs(runsThisWeek) do
              local threshold = addon.Utils:TableFind(character.vault.slots, function(slot)
                return slot.type and slot.type == Enum.WeeklyRewardChestThresholdType.Activities and slot.threshold and slot.threshold == runIndex
              end)
              local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
              local dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", run.mapChallengeModeID)
              local color = WHITE_FONT_COLOR
              if threshold then
                color = GREEN_FONT_COLOR
              end
              if dungeon then
                GameTooltip:AddDoubleLine(dungeon.short and dungeon.short or dungeon.name, string.format("+%d (%d)", run.level, rewardLevel), WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, color.r, color.g, color.b)
              end
              if runIndex == 8 then
                break
              end
            end
          end
          addBlankLine = lineAdded
        end

        do -- Show improvement info
          local lineAdded = false
          if addBlankLine then
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            addBlankLine = false
          end
          local lastCompletedActivityInfo, nextActivityInfo = addon.Utils:GetActivitiesProgress(character)
          if not lastCompletedActivityInfo then
            GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE)
            lineAdded = true
          else
            if nextActivityInfo then
              local globalString = (lastCompletedActivityInfo.index == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND
              GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress))
              lineAdded = true
            else
              GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD)
              local level, count = addon.Utils:GetLowestLevelInTopDungeonRuns(character, lastCompletedActivityInfo.threshold)
              if level == WeeklyRewardsUtil.HeroicLevel then
                GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR)
                GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_HEROIC_IMPROVE:format(count))
                lineAdded = true
              else
                local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level)
                -- Blizzard bug: Above function always does +1 even at max reward level lol
                if nextLevel < 10 then
                  GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR)
                  GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, nextLevel))
                  lineAdded = true
                end
              end
            end
          end
          addBlankLine = lineAdded
        end
        GameTooltip:Show()
      end,
      OnLeave = function()
        GameTooltip:Hide()
      end,
      enabled = true,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("World"),
      value = function(character)
        local activities = addon.Utils:TableFilter(character.vault.slots or {}, function(activity) return activity.type and activity.type == Enum.WeeklyRewardChestThresholdType.World end)
        local values = {}

        for i = 1, 3 do
          local activity = addon.Utils:TableGet(activities, "index", i)
          local value = "-"
          local color = LIGHTGRAY_FONT_COLOR
          if activity then
            if activity.progress >= activity.threshold then
              value = tostring(activity.level)
              color = UNCOMMON_GREEN_COLOR
            end
          end
          table.insert(values, color:WrapTextInColorCode(value))
        end

        return table.concat(values, "  ")
      end,
      onEnter = function(infoFrame, character)
        GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Vault Progress", 1, 1, 1)
        local activities = addon.Utils:TableFilter(character.vault.slots or {}, function(actvity) return actvity.type and actvity.type == Enum.WeeklyRewardChestThresholdType.World end)
        local lockedActivities = addon.Utils:TableFilter(activities, function(activity) return activity.progress < activity.threshold end)
        table.sort(lockedActivities, function(a, b) return a.threshold < b.threshold end)

        do -- Show activity status
          for i = 1, 3 do
            local activity = addon.Utils:TableGet(activities, "index", i)
            local value = "Locked"
            local valueColor = LIGHTGRAY_FONT_COLOR
            local label = format("%d activities:", i * 2)

            if activity then
              label = format("%d activities:", activity.threshold)
              if activity.progress >= activity.threshold then
                valueColor = WHITE_FONT_COLOR
                value = format("Tier %d", activity.level)
                if activity.exampleRewardLink ~= nil and activity.exampleRewardLink ~= "" then
                  local itemLevel = GetDetailedItemLevelInfo(activity.exampleRewardLink)
                  if itemLevel then
                    value = format("Tier %d (%d+)", activity.level, itemLevel)
                  end
                end
              end
            end
            GameTooltip:AddDoubleLine(label, value, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, valueColor.r, valueColor.g, valueColor.b)
          end
        end

        do -- Show improvement info
          local tooltip = ""
          if addon.Utils:TableCount(activities) > 0 then
            if addon.Utils:TableCount(lockedActivities) == 0 then
              -- Item level improvements
            else
              local diff = lockedActivities[1].threshold - lockedActivities[1].progress
              if addon.Utils:TableCount(lockedActivities) == 1 then
                tooltip = GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND:format(diff)
              elseif addon.Utils:TableCount(lockedActivities) == 2 then
                tooltip = GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST:format(diff)
              elseif addon.Utils:TableCount(lockedActivities) == 3 then
                tooltip = GREAT_VAULT_REWARDS_WORLD_INCOMPLETE:format(diff)
              end
            end
          else
            tooltip = GREAT_VAULT_REWARDS_WORLD_INCOMPLETE:format(2)
          end

          if tooltip ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
          end
        end
        GameTooltip:Show()
      end,
      onLeave = function()
        GameTooltip:Hide()
      end,
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
  local difficulties = addon.Data:GetRaidDifficulties()
  local characterInfo = self:GetCharacterInfo()
  local raids = addon.Data:GetRaids()
  local characters = addon.Data:GetCharacters()
  local numCharacters = addon.Utils:TableCount(characters)
  local affixes = addon.Data:GetAffixes(true)

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
        local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(affix.id);
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
          GameTooltip:SetText(name, 1, 1, 1);
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

        if dungeon.spellID and IsSpellKnown(dungeon.spellID) and not InCombatLockdown() then
          dungeonFrame:SetAttribute("type", "spell")
          dungeonFrame:SetAttribute("spell", dungeon.spellID)
        end

        dungeonFrame:SetScript("OnEnter", function()
          ---@diagnostic disable-next-line: param-type-mismatch
          GameTooltip:SetOwner(dungeonFrame, "ANCHOR_RIGHT")
          GameTooltip:SetText(dungeon.name, 1, 1, 1);
          if dungeon.spellID then
            if IsSpellKnown(dungeon.spellID) then
              GameTooltip:ClearLines()
              GameTooltip:SetSpellByID(dungeon.spellID)
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Click to Teleport>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
              _G[GameTooltip:GetName() .. "TextLeft1"]:SetText(dungeon.name)
            else
              GameTooltip:AddLine("Time this dungeon on level 10 or above to unlock teleportation.", nil, nil, nil, true)
            end
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
              GameTooltip:SetText(raid.name, 1, 1, 1);
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
            addon.Utils:TableForEach(difficulties, function(difficulty, difficultyIndex)
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
                GameTooltip:SetText(difficulty.name, 1, 1, 1);
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
            infoFrame.text:SetPoint("LEFT", infoFrame, "LEFT", addon.Constants.sizes.padding, 0)
            infoFrame.text:SetPoint("RIGHT", infoFrame, "RIGHT", -addon.Constants.sizes.padding, 0)
            infoFrame.text:SetJustifyH("CENTER")
            infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            characterFrame.infoFrames[infoIndex] = infoFrame
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
            if not info.backgroundColor then
              addon.Utils:SetHighlightColor(infoFrame)
            end
          end)
          infoFrame:SetScript("OnLeave", function()
            -- GameTooltip:Hide()
            if info.onLeave then
              info.onLeave(infoFrame, character)
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

          local characterDungeon = addon.Utils:TableGet(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
          local affixScores
          local overallScore
          local inTimeInfo
          local overTimeInfo
          local bestAffixScore
          local level = "-"
          local color = HIGHLIGHT_FONT_COLOR
          local tier = ""
          local dungeonLevel = 0

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
              bestAffixScore = TableUtil.FindMax(affixScores, function(affixScore)
                return affixScore.score
              end)

              if bestAffixScore then
                level = bestAffixScore.level
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
          dungeonFrame.Score:SetText(color:WrapTextInColorCode(overallScore or "-"))
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
                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(overallScore)), GREEN_FONT_COLOR)
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
            addon.Utils:TableForEach(difficulties, function(difficulty, difficultyIndex)
              local difficultyFrame = raidFrame.difficultyFrames[difficultyIndex]
              if not difficultyFrame then
                difficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, raidFrame)
                difficultyFrame.encounterFrames = {}
                raidFrame.difficultyFrames[difficultyIndex] = difficultyFrame
              end

              difficultyFrame:SetScript("OnEnter", function()
                GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true);
                GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name));
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
                    if savedInstance ~= nil then
                      local savedEncounter = addon.Utils:TableFind(savedInstance.encounters, function(enc)
                        return enc.instanceEncounterID == encounter.instanceEncounterID and enc.isKilled == true
                      end)
                      if savedEncounter ~= nil then
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
                    local savedEncounter = addon.Utils:TableFind(savedInstance.encounters, function(savedEncounter)
                      return savedEncounter.instanceEncounterID == encounter.instanceEncounterID and savedEncounter.isKilled == true
                    end)
                    if savedEncounter then
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
    end)
  end

  self.window:SetBodySize(self:GetBodySize())
  self.window.body.scrollparent.scrollchild:SetSize(numCharacters * CHARACTER_WIDTH, self.window.body.scrollparent:GetHeight())
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

  -- if numCharacters == 1 then
  --   self.window.titlebar.title:Hide()
  -- else
  --   self.window.titlebar.title:Show()
  -- end
end

function UI:SetupButtons()
  local currentAffixes = addon.Data:GetCurrentAffixes()
  local activeWeek = addon.Data:GetActiveAffixRotation(currentAffixes)
  local seasonID = addon.Data:GetCurrentSeason()
  local dungeons = addon.Data:GetDungeons()
  local affixRotation = addon.Data:GetAffixRotation()
  local difficulties = addon.Data:GetRaidDifficulties()
  local characterInfo = self:GetCharacterInfo()
  local raids = addon.Data:GetRaids()
  local characters = addon.Data:GetCharacters()
  local numCharacters = addon.Utils:TableCount(characters)
  local affixes = addon.Data:GetAffixes(true)

  self.window.titlebar.SettingsButton = CreateFrame("Button", "$parentSettingsButton", self.window.titlebar)
  self.window.titlebar.SettingsButton:SetPoint("RIGHT", self.window.titlebar.CloseButton, "LEFT", 0, 0)
  self.window.titlebar.SettingsButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  self.window.titlebar.SettingsButton:RegisterForClicks("AnyUp")
  self.window.titlebar.SettingsButton.HandlesGlobalMouseEvent = function()
    return true
  end
  self.window.titlebar.SettingsButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, self.window.titlebar.SettingsButton.Dropdown)
  end)
  self.window.titlebar.SettingsButton.Icon = self.window.titlebar:CreateTexture(self.window.titlebar.SettingsButton:GetName() .. "Icon", "ARTWORK")
  self.window.titlebar.SettingsButton.Icon:SetPoint("CENTER", self.window.titlebar.SettingsButton, "CENTER")
  self.window.titlebar.SettingsButton.Icon:SetSize(12, 12)
  self.window.titlebar.SettingsButton.Icon:SetTexture(addon.Constants.media.IconSettings)
  self.window.titlebar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.SettingsButton.Dropdown = CreateFrame("Frame", self.window.titlebar.SettingsButton:GetName() .. "Dropdown", self.window.titlebar, "UIDropDownMenuTemplate")
  self.window.titlebar.SettingsButton.Dropdown:SetPoint("CENTER", self.window.titlebar.SettingsButton, "CENTER", 0, -6)
  self.window.titlebar.SettingsButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.SettingsButton.Dropdown, addon.Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.SettingsButton.Dropdown,
    function(frame, level, subMenuName)
      if subMenuName == "raiddifficulties" then
        addon.Utils:TableForEach(difficulties, function(difficulty)
          UIDropDownMenu_AddButton(
            {
              text = difficulty.name,
              value = difficulty.id,
              checked = addon.Data.db.global.raids.hiddenDifficulties and not addon.Data.db.global.raids.hiddenDifficulties[difficulty.id],
              keepShownOnClick = true,
              func = function(button, arg1, arg2, checked)
                addon.Data.db.global.raids.hiddenDifficulties[button.value] = not checked
                self:Render()
              end
            },
            level
          )
        end)
      elseif subMenuName == "windowscale" then
        for i = 80, 200, 10 do
          UIDropDownMenu_AddButton(
            {
              text = i .. "%",
              value = i,
              checked = addon.Data.db.global.interface.windowScale == i,
              keepShownOnClick = false,
              func = function(button)
                addon.Data.db.global.interface.windowScale = button.value
                self:Render()
              end
            },
            level
          )
        end
      elseif level == 1 then
        UIDropDownMenu_AddButton({text = "General", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show the weekly affixes",
          checked = addon.Data.db.global.showAffixHeader,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show the weekly affixes",
          tooltipText = "The affixes will be shown at the top.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.showAffixHeader = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Show characters with zero rating",
          checked = addon.Data.db.global.showZeroRatedCharacters,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show characters with zero rating",
          tooltipText = "Too many alts?",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.showZeroRatedCharacters = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Show realm names",
          checked = addon.Data.db.global.showRealms,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show realm names",
          tooltipText = "One big party!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.showRealms = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Use Raider.io rating colors",
          checked = addon.Data.db.global.useRIOScoreColor,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Use Raider.io rating colors",
          tooltipText = "So many colors!",
          tooltipOnButton = true,
          disabled = type(_G.RaiderIO) == "nil",
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.useRIOScoreColor = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Automatic Announcements", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Announce instance resets",
          checked = addon.Data.db.global.announceResets,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Announce instance resets",
          tooltipText = "Let others in your group know when you've reset the instances.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.announceResets = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Announce new keystones (Party)",
          checked = addon.Data.db.global.announceKeystones.autoParty,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "New keystones (Party)",
          tooltipText = "Announce to your party when you loot a new keystone.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.announceKeystones.autoParty = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Announce new keystones (Guild)",
          checked = addon.Data.db.global.announceKeystones.autoGuild,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "New keystones (Guild)",
          tooltipText = "Announce to your guild when you loot a new keystone.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.announceKeystones.autoGuild = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show raid progress",
          checked = addon.Data.db.global.raids and addon.Data.db.global.raids.enabled,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show raid progress",
          tooltipText = "Because Mythic Plus ain't enough!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.raids.enabled = checked
            self:Render()
          end,
          hasArrow = true,
          menuList = "raiddifficulties"
        })
        if seasonID == 12 then
          UIDropDownMenu_AddButton({
            text = "Show |cFF00FFFFAwakened|r raids only",
            checked = addon.Data.db.global.raids and addon.Data.db.global.raids.modifiedInstanceOnly,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show |cFF00FFFFAwakened|r raids only",
            tooltipText = "It's time to move on!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              addon.Data.db.global.raids.modifiedInstanceOnly = checked
              self:Render()
            end
          })
        end
        UIDropDownMenu_AddButton({
          text = "Show difficulty colors",
          checked = addon.Data.db.global.raids and addon.Data.db.global.raids.colors,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show difficulty colors",
          tooltipText = "Argharhggh! So much greeeen!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.raids.colors = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show icons",
          checked = addon.Data.db.global.showTiers,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show icons",
          tooltipText = "Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.showTiers = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Show rating",
          checked = addon.Data.db.global.showScores,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show rating",
          tooltipText = "Show some values!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.showScores = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Use rating colors",
          checked = addon.Data.db.global.showAffixColors,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Use rating colors",
          tooltipText = "Show some colors!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.showAffixColors = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "World", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show world progress",
          checked = addon.Data.db.global.world and addon.Data.db.global.world.enabled,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show world progress",
          tooltipText = "Is Brann being a good guy?",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.world.enabled = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Minimap", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show the minimap button",
          checked = not addon.Data.db.global.minimap.hide,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show the minimap button",
          tooltipText = "It does get crowded around the minimap sometimes.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.minimap.hide = not checked
            LibDBIcon:Refresh(addonName, addon.Data.db.global.minimap)
          end
        })
        UIDropDownMenu_AddButton({
          text = "Lock the minimap button",
          checked = addon.Data.db.global.minimap.lock,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Lock the minimap button",
          tooltipText = "No more moving the button around accidentally!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.minimap.lock = checked
            LibDBIcon:Refresh(addonName, addon.Data.db.global.minimap)
          end
        })
        UIDropDownMenu_AddButton({text = "Interface", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Window color",
          keepShownOnClick = false,
          notCheckable = true,
          hasColorSwatch = true,
          r = addon.Data.db.global.interface.windowColor.r,
          g = addon.Data.db.global.interface.windowColor.g,
          b = addon.Data.db.global.interface.windowColor.b,
          -- notClickable = true,
          hasOpacity = false,
          func = UIDropDownMenuButton_OpenColorPicker,
          swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            addon.Data.db.global.interface.windowColor.r = r
            addon.Data.db.global.interface.windowColor.g = g
            addon.Data.db.global.interface.windowColor.b = b
            addon.Window:SetWindowBackgroundColor(addon.Data.db.global.interface.windowColor)
            -- addon.Utils:SetBackgroundColor(winMain, addon.Data.db.global.interface.windowColor.r, addon.Data.db.global.interface.windowColor.g, addon.Data.db.global.interface.windowColor.b, addon.Data.db.global.interface.windowColor.a)
          end,
          cancelFunc = function(color)
            addon.Data.db.global.interface.windowColor.r = color.r
            addon.Data.db.global.interface.windowColor.g = color.g
            addon.Data.db.global.interface.windowColor.b = color.b
            addon.Window:SetWindowBackgroundColor(addon.Data.db.global.interface.windowColor)
            -- addon.Utils:SetBackgroundColor(winMain, addon.Data.db.global.interface.windowColor.r, addon.Data.db.global.interface.windowColor.g, addon.Data.db.global.interface.windowColor.b, addon.Data.db.global.interface.windowColor.a)
          end
        })
        UIDropDownMenu_AddButton({text = "Window scale", notCheckable = true, hasArrow = true, menuList = "windowscale"})
      end
    end,
    "MENU"
  )
  self.window.titlebar.SettingsButton:SetScript("OnEnter", function()
    self.window.titlebar.SettingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.SettingsButton, 1, 1, 1, 0.05)
    GameTooltip:SetOwner(self.window.titlebar.SettingsButton, "ANCHOR_TOP")
    GameTooltip:SetText("Settings", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  self.window.titlebar.SettingsButton:SetScript("OnLeave", function()
    self.window.titlebar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.SettingsButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  self.window.titlebar.SortingButton = CreateFrame("Button", "$parentSorting", self.window.titlebar)
  self.window.titlebar.SortingButton:SetPoint("RIGHT", self.window.titlebar.SettingsButton, "LEFT", 0, 0)
  self.window.titlebar.SortingButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  self.window.titlebar.SortingButton.HandlesGlobalMouseEvent = function()
    return true
  end
  self.window.titlebar.SortingButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, self.window.titlebar.SortingButton.Dropdown)
  end)
  self.window.titlebar.SortingButton.Icon = self.window.titlebar:CreateTexture(self.window.titlebar.SortingButton:GetName() .. "Icon", "ARTWORK")
  self.window.titlebar.SortingButton.Icon:SetPoint("CENTER", self.window.titlebar.SortingButton, "CENTER")
  self.window.titlebar.SortingButton.Icon:SetSize(16, 16)
  self.window.titlebar.SortingButton.Icon:SetTexture(addon.Constants.media.IconSorting)
  self.window.titlebar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.SortingButton.Dropdown = CreateFrame("Frame", self.window.titlebar.SortingButton:GetName() .. "Dropdown", self.window.titlebar.SortingButton, "UIDropDownMenuTemplate")
  self.window.titlebar.SortingButton.Dropdown:SetPoint("CENTER", self.window.titlebar.SortingButton, "CENTER", 0, -6)
  self.window.titlebar.SortingButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.SortingButton.Dropdown, addon.Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.SortingButton.Dropdown,
    function()
      for _, option in ipairs(addon.Constants.sortingOptions) do
        UIDropDownMenu_AddButton({
          text = option.text,
          checked = addon.Data.db.global.sorting == option.value,
          arg1 = option.value,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.sorting = arg1
            self:Render()
          end
        })
      end
    end,
    "MENU"
  )
  self.window.titlebar.SortingButton:SetScript("OnEnter", function()
    self.window.titlebar.SortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.SortingButton, 1, 1, 1, 0.05)
    GameTooltip:SetOwner(self.window.titlebar.SortingButton, "ANCHOR_TOP")
    GameTooltip:SetText("Sorting", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  self.window.titlebar.SortingButton:SetScript("OnLeave", function()
    self.window.titlebar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.SortingButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  self.window.titlebar.CharactersButton = CreateFrame("Button", "$parentCharacters", self.window.titlebar)
  self.window.titlebar.CharactersButton:SetPoint("RIGHT", self.window.titlebar.SortingButton, "LEFT", 0, 0)
  self.window.titlebar.CharactersButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  self.window.titlebar.CharactersButton.HandlesGlobalMouseEvent = function()
    return true
  end
  self.window.titlebar.CharactersButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, self.window.titlebar.CharactersButton.Dropdown)
  end)
  self.window.titlebar.CharactersButton.Icon = self.window.titlebar:CreateTexture(self.window.titlebar.CharactersButton:GetName() .. "Icon", "ARTWORK")
  self.window.titlebar.CharactersButton.Icon:SetPoint("CENTER", self.window.titlebar.CharactersButton, "CENTER")
  self.window.titlebar.CharactersButton.Icon:SetSize(14, 14)
  self.window.titlebar.CharactersButton.Icon:SetTexture(addon.Constants.media.IconCharacters)
  self.window.titlebar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.CharactersButton.Dropdown = CreateFrame("Frame", self.window.titlebar.CharactersButton:GetName() .. "Dropdown", self.window.titlebar.CharactersButton, "UIDropDownMenuTemplate")
  self.window.titlebar.CharactersButton.Dropdown:SetPoint("CENTER", self.window.titlebar.CharactersButton, "CENTER", 0, -6)
  self.window.titlebar.CharactersButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.CharactersButton.Dropdown, addon.Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.CharactersButton.Dropdown,
    function()
      local charactersUnfilteredList = addon.Data:GetCharacters(true)
      for _, character in ipairs(charactersUnfilteredList) do
        local nameColor = "ffffffff"
        if character.info.class.file ~= nil then
          local classColor = C_ClassColor.GetClassColor(character.info.class.file)
          if classColor ~= nil then
            nameColor = classColor.GenerateHexColor(classColor)
          end
        end
        UIDropDownMenu_AddButton({
          text = "|c" .. nameColor .. character.info.name .. "|r (" .. character.info.realm .. ")",
          checked = character.enabled,
          isNotRadio = true,
          keepShownOnClick = true,
          arg1 = character.GUID,
          func = function(button, arg1, arg2, checked)
            addon.Data.db.global.characters[arg1].enabled = checked
            self:Render()
          end
        })
      end
    end,
    "MENU"
  )
  self.window.titlebar.CharactersButton:SetScript("OnEnter", function()
    self.window.titlebar.CharactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.CharactersButton, 1, 1, 1, 0.05)
    GameTooltip:SetOwner(self.window.titlebar.CharactersButton, "ANCHOR_TOP")
    GameTooltip:SetText("Characters", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Enable/Disable your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  self.window.titlebar.CharactersButton:SetScript("OnLeave", function()
    self.window.titlebar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.CharactersButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  self.window.titlebar.AnnounceButton = CreateFrame("Button", "$parentCharacters", self.window.titlebar)
  self.window.titlebar.AnnounceButton:SetPoint("RIGHT", self.window.titlebar.CharactersButton, "LEFT", 0, 0)
  self.window.titlebar.AnnounceButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
  self.window.titlebar.AnnounceButton.HandlesGlobalMouseEvent = function()
    return true
  end
  self.window.titlebar.AnnounceButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, self.window.titlebar.AnnounceButton.Dropdown)
  end)
  self.window.titlebar.AnnounceButton.Icon = self.window.titlebar:CreateTexture(
    self.window.titlebar.AnnounceButton:GetName() .. "Icon", "ARTWORK")
  self.window.titlebar.AnnounceButton.Icon:SetPoint("CENTER", self.window.titlebar.AnnounceButton, "CENTER")
  self.window.titlebar.AnnounceButton.Icon:SetSize(12, 12)
  self.window.titlebar.AnnounceButton.Icon:SetTexture(addon.Constants.media.IconAnnounce)
  self.window.titlebar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.AnnounceButton.Dropdown = CreateFrame("Frame", self.window.titlebar.AnnounceButton:GetName() .. "Dropdown", self.window.titlebar.AnnounceButton, "UIDropDownMenuTemplate")
  self.window.titlebar.AnnounceButton.Dropdown:SetPoint("CENTER", self.window.titlebar.AnnounceButton, "CENTER", 0, -6)
  self.window.titlebar.AnnounceButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.AnnounceButton.Dropdown, addon.Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.AnnounceButton.Dropdown,
    function()
      UIDropDownMenu_AddButton({
        text = "Send to Party Chat",
        isNotRadio = true,
        notCheckable = true,
        tooltipTitle = "Party",
        tooltipText = "Announce all your keystones to the party chat",
        tooltipOnButton = true,
        func = function()
          if not IsInGroup() then
            self:Print("No announcement. You are not in a party.")
            return
          end
          addon.Core:AnnounceKeystones("PARTY")
        end
      })
      UIDropDownMenu_AddButton({
        text = "Send to Guild Chat",
        isNotRadio = true,
        notCheckable = true,
        tooltipTitle = "Guild",
        tooltipText = "Announce all your keystones to the guild chat",
        tooltipOnButton = true,
        func = function()
          if not IsInGuild() then
            self:Print("No announcement. You are not in a guild.")
            return
          end
          addon.Core:AnnounceKeystones("GUILD")
        end
      })
      UIDropDownMenu_AddButton({text = "Settings", isTitle = true, notCheckable = true})
      UIDropDownMenu_AddButton({
        text = "Multiple chat messages",
        checked = addon.Data.db.global.announceKeystones.multiline,
        keepShownOnClick = true,
        isNotRadio = true,
        tooltipTitle = "Announce keystones with multiple chat messages",
        tooltipText = "With too many alts it could get spammy though.",
        tooltipOnButton = true,
        func = function(button, arg1, arg2, checked)
          addon.Data.db.global.announceKeystones.multiline = checked
        end
      })
      UIDropDownMenu_AddButton({
        text = "With character names",
        checked = addon.Data.db.global.announceKeystones.multilineNames,
        keepShownOnClick = true,
        isNotRadio = true,
        tooltipTitle = "Add character names before each keystone",
        tooltipText = "Character names are only added if multiple chat messages is enabled.",
        tooltipOnButton = true,
        func = function(button, arg1, arg2, checked)
          addon.Data.db.global.announceKeystones.multilineNames = checked
        end
      })
    end,
    "MENU"
  )
  self.window.titlebar.AnnounceButton:SetScript("OnEnter", function()
    self.window.titlebar.AnnounceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.AnnounceButton, 1, 1, 1, 0.05)
    GameTooltip:SetOwner(self.window.titlebar.AnnounceButton, "ANCHOR_TOP")
    GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true)
    GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    GameTooltip:Show()
  end)
  self.window.titlebar.AnnounceButton:SetScript("OnLeave", function()
    self.window.titlebar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    addon.Utils:SetBackgroundColor(self.window.titlebar.AnnounceButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
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
      title = "Weekly Affixes"
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
      title = "Character"
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
        }
      }
    }
  }
  tableHeight = tableHeight + 30

  addon.Utils:TableForEach(character.equipment, function(item)
    local upgradeLevel = ""
    if item.itemUpgradeTrack ~= "" then
      upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
      if item.itemUpgradeLevel == item.itemUpgradeMax then
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
          end
        },
        {text = WrapTextInColorCode(tostring(item.itemLevel), select(4, GetItemQualityColor(item.itemQuality)))},
        {text = upgradeLevel},
      }
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
