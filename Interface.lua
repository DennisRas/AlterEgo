---@diagnostic disable: inject-field, deprecated
function AlterEgo:GetCharacterInfo()
  local dungeons = self:GetDungeons()
  local difficulties = self:GetRaidDifficulties(true)
  local _, seasonDisplayID = self:GetCurrentSeason()
  return {
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
      OnEnter = function(character)
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
        if not self.db.global.showRealms then
          name = name .. format(" (%s)", character.info.realm)
        end
        GameTooltip:AddLine(name, 1, 1, 1)
        GameTooltip:AddLine(format("Level %d %s", character.info.level, character.info.race ~= nil and character.info.race.name or ""), 1, 1, 1)
        if character.info.factionGroup ~= nil and character.info.factionGroup.localized ~= nil then
          GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1)
        end
        if character.currencies ~= nil and AE_table_count(character.currencies) > 0 then
          local dataCurrencies = self:GetCurrencies()
          AE_table_foreach(dataCurrencies, function(dataCurrency)
            local characterCurrency = AE_table_get(character.currencies, "id", dataCurrency.id)
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
        if AE_table_count(characterCurrencies) > 0 then
          GameTooltip:AddLine(" ")
          GameTooltip:AddDoubleLine("Currencies:", "Maximum:")
          AE_table_foreach(characterCurrencies, function(characterCurrency)
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
      end,
      OnClick = function(character)
        local windowCharacter = self:GetWindow("Character")
        if windowCharacter.character and windowCharacter.character == character and windowCharacter:IsVisible() then
          windowCharacter:Hide()
          return
        end
        local data = {
          columns = {
            {width = 100},
            {width = 280},
            {width = 80, align = "CENTER"},
            {width = 150},
          },
          rows = {
            {
              cols = {
                {text = "Slot",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                {text = "Item",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                {text = "iLevel",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
                {text = "Upgrade Level", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
              }
            }
          }
        }
        if type(character.equipment) == "table" then
          AE_table_foreach(character.equipment, function(item)
            local upgradeLevel = ""
            if item.itemUpgradeTrack ~= "" then
              upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
              if item.itemUpgradeLevel == item.itemUpgradeMax then
                upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
              end
            end
            local row = {
              cols = {
                {text = _G[item.itemSlotName]},
                {
                  text = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
                  OnEnter = function()
                    GameTooltip:SetHyperlink(item.itemLink)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                  end,
                  OnClick = function()
                    if IsModifiedClick("CHATLINK") then
                      if not ChatEdit_InsertLink(item.itemLink) then
                        ChatFrame_OpenChat(item.itemLink)
                      end
                    end
                  end
                },
                {text = WrapTextInColorCode(item.itemLevel, select(4, GetItemQualityColor(item.itemQuality)))},
                {text = upgradeLevel},
              }
            }
            table.insert(data.rows, row)
          end)
          windowCharacter.Body.Table:SetData(data)
          local w, h = windowCharacter.Body.Table:GetSize()
          windowCharacter:SetSize(w, h + self.constants.sizes.titlebar.height)
          local nameColor = WHITE_FONT_COLOR
          if character.info.class.file ~= nil then
            local classColor = C_ClassColor.GetClassColor(character.info.class.file)
            if classColor ~= nil then
              nameColor = classColor
            end
          end
          windowCharacter.TitleBar.Text:SetText(format("%s (%s)", nameColor:WrapTextInColorCode(character.info.name), character.info.realm))
          windowCharacter:Show()
          windowCharacter.character = character
        end
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
      enabled = self.db.global.showRealms,
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
      OnEnter = function(character)
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
        GameTooltip:AddLine(itemLevelTooltip, 1, 1, 1)
        GameTooltip:AddLine(itemLevelTooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
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
          local color = AE_GetRatingColor(character.mythicplus.rating, self.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = color
          else
            ratingColor = WHITE_FONT_COLOR
          end
        end
        return ratingColor:WrapTextInColorCode(rating)
      end,
      OnEnter = function(character)
        local rating = "-"
        local ratingColor = WHITE_FONT_COLOR
        local bestSeasonScore = nil
        local bestSeasonScoreColor = WHITE_FONT_COLOR
        local bestSeasonNumber = nil
        local numSeasonRuns = 0
        if character.mythicplus.runHistory ~= nil then
          numSeasonRuns = AE_table_count(character.mythicplus.runHistory)
        end
        if character.mythicplus.bestSeasonNumber ~= nil then
          bestSeasonNumber = character.mythicplus.bestSeasonNumber
        end
        if character.mythicplus.bestSeasonScore ~= nil then
          bestSeasonScore = character.mythicplus.bestSeasonScore
          local color = AE_GetRatingColor(bestSeasonScore, self.db.global.useRIOScoreColor, bestSeasonNumber ~= nil and bestSeasonNumber < seasonDisplayID)
          if color ~= nil then
            bestSeasonScoreColor = color
          end
        end
        if character.mythicplus.rating ~= nil then
          local color = AE_GetRatingColor(character.mythicplus.rating, self.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = color
          end
          rating = tostring(character.mythicplus.rating)
        end
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
        if character.mythicplus.dungeons ~= nil and AE_table_count(character.mythicplus.dungeons) > 0 then
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
      end,
      OnClick = function(character)
        local numSeasonRuns = 0
        if character.mythicplus.runHistory ~= nil then
          numSeasonRuns = AE_table_count(character.mythicplus.runHistory)
        end
        if character.mythicplus.dungeons ~= nil
          and AE_table_count(character.mythicplus.dungeons) > 0
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
            dungeon = AE_table_get(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
          elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
            dungeon = AE_table_get(dungeons, "mapId", character.mythicplus.keystone.mapId)
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
      enabled = true,
      OnEnter = function(character)
        if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
          GameTooltip:SetHyperlink(character.mythicplus.keystone.itemLink)
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
      end,
      OnClick = function(character)
        if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
          if IsModifiedClick("CHATLINK") then
            if not ChatEdit_InsertLink(character.mythicplus.keystone.itemLink) then
              ChatFrame_OpenChat(character.mythicplus.keystone.itemLink)
            end
          end
        end
      end,
    },
    {
      label = "Vault",
      value = function(character)
        if character.vault.hasAvailableRewards == true then
          return GREEN_FONT_COLOR:WrapTextInColorCode("Rewards")
        end
        return ""
      end,
      OnEnter = function(character)
        if character.vault.hasAvailableRewards == true then
          GameTooltip:AddLine("It's payday!", WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
          GameTooltip:AddLine(GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)
        end
      end,
      backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("Raids"),
      value = function(character)
        local activities = AE_table_filter(character.vault.slots or {}, function(activity) return activity.type == Enum.WeeklyRewardChestThresholdType.Raid end)
        local values = {}

        for i = 1, 3 do
          local activity = AE_table_get(activities, "index", i)
          local value = "-"
          local color = LIGHTGRAY_FONT_COLOR

          if activity then
            if activity.level > 0 then
              local dataDifficulty = AE_table_get(difficulties, "id", activity.level)
              if dataDifficulty then
                value = dataDifficulty.abbr
                if self.db.global.raids.colors then
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
      OnEnter = function(character)
        GameTooltip:AddLine("Vault Progress", 1, 1, 1)
        local characterSlots = character.vault.slots or {}
        local activities = AE_table_filter(characterSlots, function(slot)
          return slot.type and slot.type == Enum.WeeklyRewardChestThresholdType.Raid
        end)

        do -- Show boss progress
          for i = 1, 3 do
            local activity = AE_table_get(activities, "index", i)
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
                  local dataDifficulty = AE_table_get(difficulties, "id", activity.level)
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
          local incompleteSlots = AE_table_filter(activities, function(slot) return slot.progress < slot.threshold end)
          table.sort(incompleteSlots, function(a, b) return a.threshold < b.threshold end)

          if AE_table_count(activities) > 0 then
            if AE_table_count(incompleteSlots) > 0 then
              if AE_table_count(incompleteSlots) == AE_table_count(activities) then
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
      end,
      enabled = self.db.global.raids.enabled,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("Dungeons"),
      value = function(character)
        local value = {}
        if character.vault.slots ~= nil then
          local slots = AE_table_filter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.Activities
          end)
          if #slots > 0 then
            AE_table_foreach(slots, function(slot)
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
      OnEnter = function(character)
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
          local runsThisWeek = AE_table_filter(character.mythicplus.runHistory or {}, function(run)
            return run.thisWeek == true
          end)
          local numRunsThisWeek = AE_table_count(runsThisWeek) or 0
          if numRunsThisWeek > 0 then
            table.sort(runsThisWeek, function(a, b)
              return a.level > b.level
            end)

            if addBlankLine then GameTooltip_AddBlankLineToTooltip(GameTooltip) end
            GameTooltip:AddLine("Top Runs This Week:", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            lineAdded = true

            for runIndex, run in ipairs(runsThisWeek) do
              local threshold = AE_table_find(character.vault.slots, function(slot)
                return slot.type and slot.type == Enum.WeeklyRewardChestThresholdType.Activities and slot.threshold and slot.threshold == runIndex
              end)
              local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
              local dungeon = AE_table_get(dungeons, "challengeModeID", run.mapChallengeModeID)
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
          local lastCompletedActivityInfo, nextActivityInfo = AE_GetActivitiesProgress(character)
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
              local level, count = AE_GetLowestLevelInTopDungeonRuns(character, lastCompletedActivityInfo.threshold)
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
      end,
      enabled = true,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("World"),
      value = function(character)
        local activities = AE_table_filter(character.vault.slots or {}, function(activity) return activity.type and activity.type == Enum.WeeklyRewardChestThresholdType.World end)
        local values = {}

        for i = 1, 3 do
          local activity = AE_table_get(activities, "index", i)
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
      OnEnter = function(character)
        GameTooltip:AddLine("Vault Progress", 1, 1, 1)
        local activities = AE_table_filter(character.vault.slots or {}, function(actvity) return actvity.type and actvity.type == Enum.WeeklyRewardChestThresholdType.World end)
        local lockedActivities = AE_table_filter(activities, function(activity) return activity.progress < activity.threshold end)
        table.sort(lockedActivities, function(a, b) return a.threshold < b.threshold end)

        do -- Show activity status
          for i = 1, 3 do
            local activity = AE_table_get(activities, "index", i)
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
          if AE_table_count(activities) > 0 then
            if AE_table_count(lockedActivities) == 0 then
              -- Item level improvements
            else
              local diff = lockedActivities[1].threshold - lockedActivities[1].progress
              if AE_table_count(lockedActivities) == 1 then
                tooltip = GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND:format(diff)
              elseif AE_table_count(lockedActivities) == 2 then
                tooltip = GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST:format(diff)
              elseif AE_table_count(lockedActivities) == 3 then
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
      end,
      enabled = self.db.global.world and self.db.global.world.enabled == true,
    },
  }
end

--- Set the background color for a parent frame
---@param parent table
---@param r number
---@param g number
---@param b number
---@param a number
function AlterEgo:SetBackgroundColor(parent, r, g, b, a)
  if not parent.Background then
    parent.Background = parent:CreateTexture(parent:GetName() .. "Background", "BACKGROUND")
    parent.Background:SetTexture(self.constants.media.WhiteSquare)
    parent.Background:SetAllPoints()
  end

  parent.Background:SetVertexColor(r, g, b, a)
end

function AlterEgo:CreateCharacterColumn(parent, index)
  local affixes = self:GetAffixes(true)
  local dungeons = self:GetDungeons()
  local raids = self:GetRaids(true)
  local difficulties = self:GetRaidDifficulties(true)
  local anchorFrame

  local CharacterColumn = CreateFrame("Frame", "$parentCharacterColumn" .. index, parent)
  CharacterColumn:SetWidth(self.constants.sizes.column)
  self:SetBackgroundColor(CharacterColumn, 1, 1, 1, index % 2 == 0 and 0.01 or 0)
  anchorFrame = CharacterColumn

  -- Character info
  do
    local labels = self:GetCharacterInfo()
    for labelIndex, info in ipairs(labels) do
      local CharacterFrame = CreateFrame(info.OnClick and "Button" or "Frame", "$parentInfo" .. labelIndex, CharacterColumn)
      if labelIndex > 1 then
        CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      else
        CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
        CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
      end

      CharacterFrame:SetHeight(self.constants.sizes.row)
      CharacterFrame.Text = CharacterFrame:CreateFontString(CharacterFrame:GetName() .. "Text", "OVERLAY")
      CharacterFrame.Text:SetPoint("LEFT", CharacterFrame, "LEFT", self.constants.sizes.padding, 0)
      CharacterFrame.Text:SetPoint("RIGHT", CharacterFrame, "RIGHT", -self.constants.sizes.padding, 0)
      CharacterFrame.Text:SetJustifyH("CENTER")
      CharacterFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
      if info.backgroundColor then
        self:SetBackgroundColor(CharacterFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
      end

      anchorFrame = CharacterFrame
    end
  end

  -- Dungeon Header
  CharacterColumn.DungeonHeader = CreateFrame("Frame", "$parentAffixes", CharacterColumn)
  CharacterColumn.DungeonHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
  CharacterColumn.DungeonHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
  CharacterColumn.DungeonHeader:SetHeight(self.constants.sizes.row)
  self:SetBackgroundColor(CharacterColumn.DungeonHeader, 0, 0, 0, 0.3)
  anchorFrame = CharacterColumn.DungeonHeader

  -- Dungeon rows
  for dungeonIndex in ipairs(dungeons) do
    local DungeonFrame = CreateFrame("Frame", "$parentDungeons" .. dungeonIndex, CharacterColumn)
    DungeonFrame:SetHeight(self.constants.sizes.row)
    DungeonFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    DungeonFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    self:SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)

    DungeonFrame.Text = DungeonFrame:CreateFontString(DungeonFrame:GetName() .. "Text", "OVERLAY")
    DungeonFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
    DungeonFrame.Tier = DungeonFrame:CreateFontString(DungeonFrame:GetName() .. "Tier", "OVERLAY")
    DungeonFrame.Tier:SetPoint("LEFT", DungeonFrame.Text, "RIGHT", 3, 1)
    DungeonFrame.Tier:SetJustifyH("LEFT")
    DungeonFrame.Tier:SetFontObject("GameFontHighlight_NoShadow")
    DungeonFrame.Score = DungeonFrame:CreateFontString(DungeonFrame:GetName() .. "Score", "OVERLAY")
    DungeonFrame.Score:SetPoint("RIGHT", DungeonFrame, "RIGHT", -self.constants.sizes.padding * 2, 1)
    DungeonFrame.Score:SetJustifyH("RIGHT")
    DungeonFrame.Score:SetFontObject("GameFontHighlight_NoShadow")

    anchorFrame = DungeonFrame
  end

  -- Raid Rows
  for raidIndex, raid in ipairs(raids) do
    local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, CharacterColumn)
    RaidFrame:SetHeight(self.constants.sizes.row)
    RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    self:SetBackgroundColor(RaidFrame, 0, 0, 0, 0.3)
    anchorFrame = RaidFrame

    for difficultyIndex in pairs(difficulties) do
      local DifficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
      DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
      DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      DifficultyFrame:SetHeight(self.constants.sizes.row)
      self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
      anchorFrame = DifficultyFrame

      for encounterIndex in ipairs(raid.encounters) do
        local EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
        local size = self.constants.sizes.column
        size = size - self.constants.sizes.padding -- left/right cell padding
        size = size - (raid.numEncounters - 1) * 4 -- gaps
        size = size / raid.numEncounters           -- box sizes
        EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", self.constants.sizes.padding / 2, 0)
        EncounterFrame:SetSize(size, self.constants.sizes.row - 12)
        self:SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
        anchorFrame = EncounterFrame
      end
      anchorFrame = DifficultyFrame
    end
  end

  return CharacterColumn
end

local CharacterColumns = {}
function AlterEgo:GetCharacterColumn(parent, index)
  if CharacterColumns[index] == nil then
    CharacterColumns[index] = self:CreateCharacterColumn(parent, index)
  end
  CharacterColumns[index]:Show()
  return CharacterColumns[index]
end

--- Hide all character columns
function AlterEgo:HideCharacterColumns()
  AE_table_foreach(CharacterColumns, function(CharacterColumn)
    CharacterColumn:Hide()
  end)
end

--- Does the main window need scrollbars?
---@return boolean
function AlterEgo:IsScrollbarNeeded()
  local numCharacters = AE_table_count(self:GetCharacters())
  return numCharacters > 0 and self.constants.sizes.sidebar.width + numCharacters * self.constants.sizes.column > self:GetMaxWindowWidth()
end

--- Calculate the main window size
---@return number, number
function AlterEgo:GetWindowSize()
  local numCharacters = AE_table_count(self:GetCharacters())
  local numDungeons = AE_table_count(self:GetDungeons())
  local numRaids = AE_table_count(self:GetRaids())
  local numDifficulties = AE_table_count(self:GetRaidDifficulties())
  local numCharacterInfo = AE_table_count(AE_table_filter(self:GetCharacterInfo(), function(label)
    return label.enabled == nil or label.enabled == true
  end))
  local width = 0
  local maxWidth = self:GetMaxWindowWidth()
  local height = 0

  -- Width
  if numCharacters == 0 then
    width = 500
  else
    width = width + self.constants.sizes.sidebar.width
    width = width + numCharacters * self.constants.sizes.column
  end
  if width > maxWidth then
    width = maxWidth
    if numCharacters > 0 then
      height = height + self.constants.sizes.footer.height -- Shoes?
    end
  end

  -- Height
  height = height + self.constants.sizes.titlebar.height                          -- Titlebar duh
  height = height + numCharacterInfo * self.constants.sizes.row                   -- Character info
  height = height + (numDungeons + 1) * self.constants.sizes.row                  -- Dungeons
  if self.db.global.raids.enabled == true then
    height = height + numRaids * (numDifficulties + 1) * self.constants.sizes.row -- Raids
  end

  return width, height
end

function AlterEgo:CreateUI()
  local currentAffixes = self:GetCurrentAffixes()
  local activeWeek = self:GetActiveAffixRotation(currentAffixes)
  local seasonID = self:GetCurrentSeason()
  local affixes = self:GetAffixes()
  local affixRotation = self:GetAffixRotation()
  local difficulties = self:GetRaidDifficulties(true)
  local dungeons = self:GetDungeons()
  local labels = self:GetCharacterInfo()
  local raids = self:GetRaids(true)
  local anchorFrame

  local winMain = self:CreateWindow("Main", "AlterEgo", UIParent)
  local winAffixRotation = self:CreateWindow("Affixes", "Affixes", UIParent)
  local winEquipment = self:CreateWindow("Character", "Character", UIParent)
  local winKeyManager = self:CreateWindow("KeyManager", "KeyManager", UIParent)

  winEquipment.Body.Table = self.Table:New()
  winEquipment.Body.Table.frame:SetParent(winEquipment.Body)
  winEquipment.Body.Table.frame:SetPoint("TOPLEFT", winEquipment.Body, "TOPLEFT")

  do -- Affix window
    local data = {columns = {}, rows = {}}
    local firstRow = {cols = {}}
    winAffixRotation.Body.Table = self.Table:New({rowHeight = 28})
    winAffixRotation.Body.Table.frame:SetParent(winAffixRotation.Body)
    winAffixRotation.Body.Table.frame:SetPoint("TOPLEFT", winAffixRotation.Body, "TOPLEFT")
    winAffixRotation.TitleBar.Text:SetText("Weekly Affixes")
    if not affixRotation then
      table.insert(data.columns, {width = 500})
      table.insert(data.rows, {cols = {{text = "The weekly schedule is not updated. Check back next addon update!"}}})
    else
      AE_table_foreach(affixRotation.activation, function(activationLevel, activationLevelIndex)
        table.insert(data.columns, {width = activationLevelIndex == 1 and 220 or 140})
        table.insert(firstRow.cols, {text = "+" .. activationLevel, backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}})
      end)
      table.insert(data.rows, firstRow)
      AE_table_foreach(affixRotation.affixes, function(affixValues, weekIndex)
        local row = {cols = {}}
        local backgroundColor = weekIndex == activeWeek and {r = 1, g = 1, b = 1, a = 0.1} or nil
        AE_table_foreach(affixValues, function(affixValue)
          if type(affixValue) == "number" then
            local affix = AE_table_get(affixes, "id", affixValue)
            if affix then
              local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
              table.insert(row.cols, {
                text = "|T" .. affix.fileDataID .. ":18|t " .. name,
                backgroundColor = backgroundColor or nil,
                OnEnter = function()
                  GameTooltip:SetText(affix.name, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, 1, true)
                  GameTooltip:AddLine(affix.description, nil, nil, nil, true)
                end,
              })
            end
          else
            table.insert(row.cols, {
              text = affixValue,
              backgroundColor = backgroundColor or nil,
            })
          end
        end)
        table.insert(data.rows, row)
      end)
    end
    winAffixRotation.Body.Table:SetData(data)
    local w, h = winAffixRotation.Body.Table:GetSize()
    winAffixRotation:SetSize(w, h + self.constants.sizes.titlebar.height)
  end

  do -- TitleBar
    anchorFrame = winMain.TitleBar
    winMain.TitleBar.Affixes = CreateFrame("Button", "$parentAffixes", winMain.TitleBar)
    if currentAffixes and AE_table_count(currentAffixes) > 0 then
      for i = 1, AE_table_count(currentAffixes) do
        local affixButton = CreateFrame("Button", "$parent" .. i, winMain.TitleBar.Affixes)
        affixButton:SetSize(20, 20)
        local currentAffix = currentAffixes[i]
        if currentAffix ~= nil then
          local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(currentAffix.id)
          affixButton:SetNormalTexture(fileDataID)
          affixButton:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(affixButton, "ANCHOR_TOP")
            GameTooltip:SetText(name, 1, 1, 1)
            GameTooltip:AddLine(desc, nil, nil, nil, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Click to View Weekly Affixes>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()
          end)
          affixButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
          end)
        end
        affixButton:SetScript("OnClick", function()
          self:ToggleWindow("Affixes")
        end)
      end
    end
    winMain.TitleBar.SettingsButton = CreateFrame("Button", "$parentSettingsButton", winMain.TitleBar)
    winMain.TitleBar.SettingsButton:SetPoint("RIGHT", winMain.TitleBar.CloseButton, "LEFT", 0, 0)
    winMain.TitleBar.SettingsButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
    winMain.TitleBar.SettingsButton:RegisterForClicks("AnyUp")
    winMain.TitleBar.SettingsButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.SettingsButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.SettingsButton.Dropdown)
    end)
    winMain.TitleBar.SettingsButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.SettingsButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.SettingsButton.Icon:SetPoint("CENTER", winMain.TitleBar.SettingsButton, "CENTER")
    winMain.TitleBar.SettingsButton.Icon:SetSize(12, 12)
    winMain.TitleBar.SettingsButton.Icon:SetTexture(self.constants.media.IconSettings)
    winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.SettingsButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.SettingsButton:GetName() .. "Dropdown", winMain.TitleBar, "UIDropDownMenuTemplate")
    winMain.TitleBar.SettingsButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.SettingsButton, "CENTER", 0, -6)
    winMain.TitleBar.SettingsButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.SettingsButton.Dropdown, self.constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.SettingsButton.Dropdown,
      function(frame, level, subMenuName)
        if subMenuName == "raiddifficulties" then
          AE_table_foreach(difficulties, function(difficulty)
            UIDropDownMenu_AddButton(
              {
                text = difficulty.name,
                value = difficulty.id,
                checked = self.db.global.raids.hiddenDifficulties and not self.db.global.raids.hiddenDifficulties[difficulty.id],
                keepShownOnClick = true,
                func = function(button, arg1, arg2, checked)
                  self.db.global.raids.hiddenDifficulties[button.value] = not checked
                  self:UpdateUI()
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
                checked = self.db.global.interface.windowScale == i,
                keepShownOnClick = false,
                func = function(button)
                  self.db.global.interface.windowScale = button.value
                  self:UpdateUI()
                end
              },
              level
            )
          end
        elseif level == 1 then
          UIDropDownMenu_AddButton({text = "General", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show the weekly affixes",
            checked = self.db.global.showAffixHeader,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show the weekly affixes",
            tooltipText = "The affixes will be shown at the top.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.showAffixHeader = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Show characters with zero rating",
            checked = self.db.global.showZeroRatedCharacters,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show characters with zero rating",
            tooltipText = "Too many alts?",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.showZeroRatedCharacters = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Show realm names",
            checked = self.db.global.showRealms,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show realm names",
            tooltipText = "One big party!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.showRealms = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Use Raider.io rating colors",
            checked = self.db.global.useRIOScoreColor,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Use Raider.io rating colors",
            tooltipText = "So many colors!",
            tooltipOnButton = true,
            disabled = type(_G.RaiderIO) == "nil",
            func = function(button, arg1, arg2, checked)
              self.db.global.useRIOScoreColor = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Automatic Announcements", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Announce instance resets",
            checked = self.db.global.announceResets,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Announce instance resets",
            tooltipText = "Let others in your group know when you've reset the instances.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.announceResets = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Announce new keystones (Party)",
            checked = self.db.global.announceKeystones.autoParty,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "New keystones (Party)",
            tooltipText = "Announce to your party when you loot a new keystone.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.announceKeystones.autoParty = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Announce new keystones (Guild)",
            checked = self.db.global.announceKeystones.autoGuild,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "New keystones (Guild)",
            tooltipText = "Announce to your guild when you loot a new keystone.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.announceKeystones.autoGuild = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show raid progress",
            checked = self.db.global.raids and self.db.global.raids.enabled,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show raid progress",
            tooltipText = "Because Mythic Plus ain't enough!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.raids.enabled = checked
              self:UpdateUI()
            end,
            hasArrow = true,
            menuList = "raiddifficulties"
          })
          if seasonID == 12 then
            UIDropDownMenu_AddButton({
              text = "Show |cFF00FFFFAwakened|r raids only",
              checked = self.db.global.raids and self.db.global.raids.modifiedInstanceOnly,
              keepShownOnClick = true,
              isNotRadio = true,
              tooltipTitle = "Show |cFF00FFFFAwakened|r raids only",
              tooltipText = "It's time to move on!",
              tooltipOnButton = true,
              func = function(button, arg1, arg2, checked)
                self.db.global.raids.modifiedInstanceOnly = checked
                self:UpdateUI()
              end
            })
          end
          UIDropDownMenu_AddButton({
            text = "Show difficulty colors",
            checked = self.db.global.raids and self.db.global.raids.colors,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show difficulty colors",
            tooltipText = "Argharhggh! So much greeeen!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.raids.colors = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show icons",
            checked = self.db.global.showTiers,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show icons",
            tooltipText = "Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.showTiers = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Show rating",
            checked = self.db.global.showScores,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show rating",
            tooltipText = "Show some values!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.showScores = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Use rating colors",
            checked = self.db.global.showAffixColors,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Use rating colors",
            tooltipText = "Show some colors!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.showAffixColors = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "World", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show world progress",
            checked = self.db.global.world and self.db.global.world.enabled,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show world progress",
            tooltipText = "Is Brann being a good guy?",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.world.enabled = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Minimap", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show the minimap button",
            checked = not self.db.global.minimap.hide,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show the minimap button",
            tooltipText = "It does get crowded around the minimap sometimes.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.minimap.hide = not checked
              self.Libs.LDBIcon:Refresh("AlterEgo", self.db.global.minimap)
            end
          })
          UIDropDownMenu_AddButton({
            text = "Lock the minimap button",
            checked = self.db.global.minimap.lock,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Lock the minimap button",
            tooltipText = "No more moving the button around accidentally!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              self.db.global.minimap.lock = checked
              self.Libs.LDBIcon:Refresh("AlterEgo", self.db.global.minimap)
            end
          })
          UIDropDownMenu_AddButton({text = "Interface", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Window color",
            keepShownOnClick = false,
            notCheckable = true,
            hasColorSwatch = true,
            r = self.db.global.interface.windowColor.r,
            g = self.db.global.interface.windowColor.g,
            b = self.db.global.interface.windowColor.b,
            -- notClickable = true,
            hasOpacity = false,
            func = UIDropDownMenuButton_OpenColorPicker,
            swatchFunc = function()
              local r, g, b = ColorPickerFrame:GetColorRGB()
              self.db.global.interface.windowColor.r = r
              self.db.global.interface.windowColor.g = g
              self.db.global.interface.windowColor.b = b
              self:SetWindowBackgroundColor(self.db.global.interface.windowColor)
              -- self:SetBackgroundColor(winMain, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
            end,
            cancelFunc = function(color)
              self.db.global.interface.windowColor.r = color.r
              self.db.global.interface.windowColor.g = color.g
              self.db.global.interface.windowColor.b = color.b
              self:SetWindowBackgroundColor(self.db.global.interface.windowColor)
              -- self:SetBackgroundColor(winMain, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
            end
          })
          UIDropDownMenu_AddButton({text = "Window scale", notCheckable = true, hasArrow = true, menuList = "windowscale"})
        end
      end,
      "MENU"
    )
    winMain.TitleBar.SettingsButton:SetScript("OnEnter", function()
      winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.SettingsButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.SettingsButton, "ANCHOR_TOP")
      GameTooltip:SetText("Settings", 1, 1, 1, 1, true)
      GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      GameTooltip:Show()
    end)
    winMain.TitleBar.SettingsButton:SetScript("OnLeave", function()
      winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.SettingsButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
    winMain.TitleBar.SortingButton = CreateFrame("Button", "$parentSorting", winMain.TitleBar)
    winMain.TitleBar.SortingButton:SetPoint("RIGHT", winMain.TitleBar.SettingsButton, "LEFT", 0, 0)
    winMain.TitleBar.SortingButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
    winMain.TitleBar.SortingButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.SortingButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.SortingButton.Dropdown)
    end)
    winMain.TitleBar.SortingButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.SortingButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.SortingButton.Icon:SetPoint("CENTER", winMain.TitleBar.SortingButton, "CENTER")
    winMain.TitleBar.SortingButton.Icon:SetSize(16, 16)
    winMain.TitleBar.SortingButton.Icon:SetTexture(self.constants.media.IconSorting)
    winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.SortingButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.SortingButton:GetName() .. "Dropdown", winMain.TitleBar.SortingButton, "UIDropDownMenuTemplate")
    winMain.TitleBar.SortingButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.SortingButton, "CENTER", 0, -6)
    winMain.TitleBar.SortingButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.SortingButton.Dropdown, self.constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.SortingButton.Dropdown,
      function()
        for _, option in ipairs(self.constants.sortingOptions) do
          UIDropDownMenu_AddButton({
            text = option.text,
            checked = self.db.global.sorting == option.value,
            arg1 = option.value,
            func = function(button, arg1, arg2, checked)
              self.db.global.sorting = arg1
              self:UpdateUI()
            end
          })
        end
      end,
      "MENU"
    )
    winMain.TitleBar.SortingButton:SetScript("OnEnter", function()
      winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.SortingButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.SortingButton, "ANCHOR_TOP")
      GameTooltip:SetText("Sorting", 1, 1, 1, 1, true)
      GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      GameTooltip:Show()
    end)
    winMain.TitleBar.SortingButton:SetScript("OnLeave", function()
      winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.SortingButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
    winMain.TitleBar.CharactersButton = CreateFrame("Button", "$parentCharacters", winMain.TitleBar)
    winMain.TitleBar.CharactersButton:SetPoint("RIGHT", winMain.TitleBar.SortingButton, "LEFT", 0, 0)
    winMain.TitleBar.CharactersButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
    winMain.TitleBar.CharactersButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.CharactersButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.CharactersButton.Dropdown)
    end)
    winMain.TitleBar.CharactersButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.CharactersButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.CharactersButton.Icon:SetPoint("CENTER", winMain.TitleBar.CharactersButton, "CENTER")
    winMain.TitleBar.CharactersButton.Icon:SetSize(14, 14)
    winMain.TitleBar.CharactersButton.Icon:SetTexture(self.constants.media.IconCharacters)
    winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.CharactersButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.CharactersButton:GetName() .. "Dropdown", winMain.TitleBar.CharactersButton, "UIDropDownMenuTemplate")
    winMain.TitleBar.CharactersButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.CharactersButton, "CENTER", 0, -6)
    winMain.TitleBar.CharactersButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.CharactersButton.Dropdown, self.constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.CharactersButton.Dropdown,
      function()
        local charactersUnfilteredList = self:GetCharacters(true)
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
              self.db.global.characters[arg1].enabled = checked
              self:UpdateUI()
            end
          })
        end
      end,
      "MENU"
    )
    winMain.TitleBar.CharactersButton:SetScript("OnEnter", function()
      winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.CharactersButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.CharactersButton, "ANCHOR_TOP")
      GameTooltip:SetText("Characters", 1, 1, 1, 1, true)
      GameTooltip:AddLine("Enable/Disable your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      GameTooltip:Show()
    end)
    winMain.TitleBar.CharactersButton:SetScript("OnLeave", function()
      winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.CharactersButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
    winMain.TitleBar.AnnounceButton = CreateFrame("Button", "$parentCharacters", winMain.TitleBar)
    winMain.TitleBar.AnnounceButton:SetPoint("RIGHT", winMain.TitleBar.CharactersButton, "LEFT", 0, 0)
    winMain.TitleBar.AnnounceButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
    winMain.TitleBar.AnnounceButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.AnnounceButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.AnnounceButton.Dropdown)
    end)
    winMain.TitleBar.AnnounceButton.Icon = winMain.TitleBar:CreateTexture(
      winMain.TitleBar.AnnounceButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.AnnounceButton.Icon:SetPoint("CENTER", winMain.TitleBar.AnnounceButton, "CENTER")
    winMain.TitleBar.AnnounceButton.Icon:SetSize(12, 12)
    winMain.TitleBar.AnnounceButton.Icon:SetTexture(self.constants.media.IconAnnounce)
    winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.AnnounceButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.AnnounceButton:GetName() .. "Dropdown", winMain.TitleBar.AnnounceButton, "UIDropDownMenuTemplate")
    winMain.TitleBar.AnnounceButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.AnnounceButton, "CENTER", 0, -6)
    winMain.TitleBar.AnnounceButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.AnnounceButton.Dropdown, self.constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.AnnounceButton.Dropdown,
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
            self:AnnounceKeystones("PARTY")
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
            self:AnnounceKeystones("GUILD")
          end
        })
        UIDropDownMenu_AddButton({text = "Settings", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Multiple chat messages",
          checked = self.db.global.announceKeystones.multiline,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Announce keystones with multiple chat messages",
          tooltipText = "With too many alts it could get spammy though.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            self.db.global.announceKeystones.multiline = checked
          end
        })
        UIDropDownMenu_AddButton({
          text = "With character names",
          checked = self.db.global.announceKeystones.multilineNames,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Add character names before each keystone",
          tooltipText = "Character names are only added if multiple chat messages is enabled.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            self.db.global.announceKeystones.multilineNames = checked
          end
        })
      end,
      "MENU"
    )
    winMain.TitleBar.AnnounceButton:SetScript("OnEnter", function()
      winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.AnnounceButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.AnnounceButton, "ANCHOR_TOP")
      GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true)
      GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      GameTooltip:Show()
    end)
    winMain.TitleBar.AnnounceButton:SetScript("OnLeave", function()
      winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.AnnounceButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  do -- No characters enabled
    winMain.Body.NoCharacterText = winMain.Body:CreateFontString("$parentNoCharacterText", "ARTWORK")
    winMain.Body.NoCharacterText:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT", 50, -50)
    winMain.Body.NoCharacterText:SetPoint("BOTTOMRIGHT", winMain.Body, "BOTTOMRIGHT", -50, 50)
    winMain.Body.NoCharacterText:SetJustifyH("CENTER")
    winMain.Body.NoCharacterText:SetJustifyV("MIDDLE")
    winMain.Body.NoCharacterText:SetFontObject("GameFontHighlight_NoShadow")
    local introductionText = "|cffffffffHi there :-)|r\nEnable a character top right for AlterEgo to show you some goodies!"
    if not self.db.global.showZeroRatedCharacters and AE_table_count(self:GetCharacters(true)) > 0 then
      introductionText = introductionText .. "\n\n|cff00ee00New Season?|r\nYou are currently hiding characters with zero rating. If this is not your intention then enable the setting |cffffffffShow characters with zero rating|r"
    end
    winMain.Body.NoCharacterText:SetText(introductionText)
    winMain.Body.NoCharacterText:SetVertexColor(1.0, 0.82, 0.0, 1)
    winMain.Body.NoCharacterText:Hide()
  end

  do -- Sidebar
    winMain.Body.Sidebar = CreateFrame("Frame", "$parentSidebar", winMain.Body)
    winMain.Body.Sidebar:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT")
    winMain.Body.Sidebar:SetPoint("BOTTOMLEFT", winMain.Body, "BOTTOMLEFT")
    winMain.Body.Sidebar:SetWidth(self.constants.sizes.sidebar.width)
    self:SetBackgroundColor(winMain.Body.Sidebar, 0, 0, 0, 0.3)
    anchorFrame = winMain.Body.Sidebar
  end

  do -- Character info
    for labelIndex, info in ipairs(labels) do
      local Label = CreateFrame("Frame", "$parentLabel" .. labelIndex, winMain.Body.Sidebar)
      if labelIndex > 1 then
        Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      else
        Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
        Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
      end
      Label:SetHeight(self.constants.sizes.row)
      Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
      Label.Text:SetPoint("LEFT", Label, "LEFT", self.constants.sizes.padding, 0)
      Label.Text:SetPoint("RIGHT", Label, "RIGHT", -self.constants.sizes.padding, 0)
      Label.Text:SetJustifyH("LEFT")
      Label.Text:SetFontObject("GameFontHighlight_NoShadow")
      Label.Text:SetText(info.label)
      Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
      anchorFrame = Label
    end
  end

  do -- MythicPlus Label
    local Label = CreateFrame("Frame", "$parentMythicPlusLabel", winMain.Body.Sidebar)
    Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    Label:SetHeight(self.constants.sizes.row)
    Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
    Label.Text:SetPoint("TOPLEFT", Label, "TOPLEFT", self.constants.sizes.padding, 0)
    Label.Text:SetPoint("BOTTOMRIGHT", Label, "BOTTOMRIGHT", -self.constants.sizes.padding, 0)
    Label.Text:SetFontObject("GameFontHighlight_NoShadow")
    Label.Text:SetJustifyH("LEFT")
    Label.Text:SetText("Mythic Plus")
    Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
    anchorFrame = Label
  end

  do -- Dungeon Labels
    for dungeonIndex, dungeon in ipairs(dungeons) do
      local Label = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, winMain.Body.Sidebar, "InsecureActionButtonTemplate")
      Label:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
      Label:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
      Label:SetHeight(self.constants.sizes.row)
      Label.Icon = Label:CreateTexture(Label:GetName() .. "Icon", "ARTWORK")
      Label.Icon:SetSize(16, 16)
      Label.Icon:SetPoint("LEFT", Label:GetName(), "LEFT", self.constants.sizes.padding, 0)
      Label.Icon:SetTexture(dungeon.icon)
      Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
      Label.Text:SetPoint("TOPLEFT", Label:GetName(), "TOPLEFT", 16 + self.constants.sizes.padding * 2, -3)
      Label.Text:SetPoint("BOTTOMRIGHT", Label:GetName(), "BOTTOMRIGHT", -self.constants.sizes.padding, 3)
      Label.Text:SetJustifyH("LEFT")
      Label.Text:SetFontObject("GameFontHighlight_NoShadow")
      Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
      anchorFrame = Label
    end
  end

  do -- Raids & Difficulties
    for raidIndex, raid in ipairs(raids) do
      local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, winMain.Body.Sidebar)
      RaidFrame:SetHeight(self.constants.sizes.row)
      RaidFrame:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
      RaidFrame:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
      RaidFrame:SetScript("OnEnter", function()
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(RaidFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(raid.name, 1, 1, 1)
        if raid.modifiedInstanceInfo then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(raid.modifiedInstanceInfo.description)
        end
        GameTooltip:Show()
      end)
      RaidFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      RaidFrame.Text = RaidFrame:CreateFontString(RaidFrame:GetName() .. "Text", "OVERLAY")
      RaidFrame.Text:SetPoint("LEFT", RaidFrame, "LEFT", self.constants.sizes.padding, 0)
      RaidFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
      RaidFrame.Text:SetJustifyH("LEFT")
      RaidFrame.Text:SetText(raid.short and raid.short or raid.name)
      RaidFrame.Text:SetWordWrap(false)
      RaidFrame.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
      RaidFrame.ModifiedIcon = RaidFrame:CreateTexture("$parentModifiedIcon", "ARTWORK")
      RaidFrame.ModifiedIcon:SetSize(18, 18)
      RaidFrame.ModifiedIcon:SetPoint("RIGHT", RaidFrame, "RIGHT", -(self.constants.sizes.padding / 2), 0)
      if raid.modifiedInstanceInfo then
        RaidFrame.ModifiedIcon:SetAtlas(GetFinalNameFromTextureKit("%s-small", raid.modifiedInstanceInfo.uiTextureKit))
        RaidFrame.ModifiedIcon:Show()
        RaidFrame.Text:SetPoint("RIGHT", RaidFrame.ModifiedIcon, "LEFT", -(self.constants.sizes.padding / 2), 0)
      else
        RaidFrame.ModifiedIcon:Hide()
        RaidFrame.Text:SetPoint("RIGHT", RaidFrame, "RIGHT", -self.constants.sizes.padding, 0)
      end
      anchorFrame = RaidFrame

      for difficultyIndex, difficulty in ipairs(difficulties) do
        local DifficultFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
        DifficultFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        DifficultFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        DifficultFrame:SetHeight(self.constants.sizes.row)
        DifficultFrame:SetScript("OnEnter", function()
          GameTooltip:ClearAllPoints()
          GameTooltip:ClearLines()
          GameTooltip:SetOwner(DifficultFrame, "ANCHOR_RIGHT")
          GameTooltip:SetText(difficulty.name, 1, 1, 1)
          GameTooltip:Show()
        end)
        DifficultFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)
        DifficultFrame.Text = DifficultFrame:CreateFontString(DifficultFrame:GetName() .. "Text", "OVERLAY")
        DifficultFrame.Text:SetPoint("TOPLEFT", DifficultFrame, "TOPLEFT", self.constants.sizes.padding, -3)
        DifficultFrame.Text:SetPoint("BOTTOMRIGHT", DifficultFrame, "BOTTOMRIGHT", -self.constants.sizes.padding, 3)
        DifficultFrame.Text:SetJustifyH("LEFT")
        DifficultFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
        DifficultFrame.Text:SetText(difficulty.short and difficulty.short or difficulty.name)
        -- RaidLabel.Icon = RaidLabel:CreateTexture(RaidLabel:GetName() .. "Icon", "ARTWORK")
        -- RaidLabel.Icon:SetSize(16, 16)
        -- RaidLabel.Icon:SetPoint("LEFT", RaidLabel, "LEFT", self.constants.sizes.padding, 0)
        -- RaidLabel.Icon:SetTexture(raid.icon)
        anchorFrame = DifficultFrame
      end
    end
  end

  winMain.Body.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", winMain.Body)
  winMain.Body.ScrollFrame:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT", self.constants.sizes.sidebar.width, 0)
  winMain.Body.ScrollFrame:SetPoint("BOTTOMLEFT", winMain.Body, "BOTTOMLEFT", self.constants.sizes.sidebar.width, 0)
  winMain.Body.ScrollFrame:SetPoint("BOTTOMRIGHT", winMain.Body, "BOTTOMRIGHT")
  winMain.Body.ScrollFrame:SetPoint("TOPRIGHT", winMain.Body, "TOPRIGHT")
  winMain.Body.ScrollFrame.ScrollChild = CreateFrame("Frame", "$parentScrollChild", winMain.Body.ScrollFrame)
  winMain.Body.ScrollFrame:SetScrollChild(winMain.Body.ScrollFrame.ScrollChild)

  winMain.Footer = CreateFrame("Frame", "$parentFooter", winMain)
  winMain.Footer:SetHeight(self.constants.sizes.footer.height)
  winMain.Footer:SetPoint("BOTTOMLEFT", winMain, "BOTTOMLEFT")
  winMain.Footer:SetPoint("BOTTOMRIGHT", winMain, "BOTTOMRIGHT")
  self:SetBackgroundColor(winMain.Footer, 0, 0, 0, .3)

  winMain.Footer.Scrollbar = CreateFrame("Slider", "$parentScrollbar", winMain.Footer, "UISliderTemplate")
  winMain.Footer.Scrollbar:SetPoint("TOPLEFT", winMain.Footer, "TOPLEFT", self.constants.sizes.sidebar.width, 0)
  winMain.Footer.Scrollbar:SetPoint("BOTTOMRIGHT", winMain.Footer, "BOTTOMRIGHT", -self.constants.sizes.padding / 2, 0)
  winMain.Footer.Scrollbar:SetMinMaxValues(0, 100)
  winMain.Footer.Scrollbar:SetValue(0)
  winMain.Footer.Scrollbar:SetValueStep(1)
  winMain.Footer.Scrollbar:SetOrientation("HORIZONTAL")
  winMain.Footer.Scrollbar:SetObeyStepOnDrag(true)
  winMain.Footer.Scrollbar.NineSlice:Hide()
  winMain.Footer.Scrollbar.thumb = winMain.Footer.Scrollbar:GetThumbTexture()
  winMain.Footer.Scrollbar.thumb:SetPoint("CENTER")
  winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
  winMain.Footer.Scrollbar.thumb:SetHeight(self.constants.sizes.footer.height - 10)
  winMain.Footer.Scrollbar:SetScript("OnValueChanged", function(_, value)
    winMain.Body.ScrollFrame:SetHorizontalScroll(value)
  end)
  winMain.Footer.Scrollbar:SetScript("OnEnter", function()
    winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.2)
  end)
  winMain.Footer.Scrollbar:SetScript("OnLeave", function()
    winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
  end)
  winMain.Body.ScrollFrame:SetScript("OnMouseWheel", function(_, delta)
    winMain.Footer.Scrollbar:SetValue(winMain.Footer.Scrollbar:GetValue() - delta * ((winMain.Body.ScrollFrame.ScrollChild:GetWidth() - winMain.Body.ScrollFrame:GetWidth()) * 0.1))
  end)

  winMain.Body:SetPoint("BOTTOMLEFT", winMain.Footer, "TOPLEFT")
  winMain.Body:SetPoint("BOTTOMRIGHT", winMain.Footer, "TOPRIGHT")
  winMain:SetScript("OnShow", function()
    self:UpdateUI()
  end)
  self:UpdateUI()
end

function AlterEgo:UpdateUI()
  local winMain = self:GetWindow("Main")
  if not winMain then
    return
  end
  if not winMain:IsVisible() then
    return
  end

  local affixes = self:GetAffixes(true)
  local currentAffixes = self:GetCurrentAffixes()
  local characters = self:GetCharacters()
  local numCharacters = AE_table_count(characters)
  local dungeons = self:GetDungeons()
  local raids = self:GetRaids(true)
  local difficulties = self:GetRaidDifficulties(true)
  local labels = self:GetCharacterInfo()
  local anchorFrame

  if numCharacters == 0 then
    winMain.Body.Sidebar:Hide()
    winMain.Body.ScrollFrame:Hide()
    winMain.Footer:Hide()
    winMain.Body.NoCharacterText:Show()
  else
    winMain.Body.Sidebar:Show()
    winMain.Body.ScrollFrame:Show()
    winMain.Footer:Show()
    winMain.Body.NoCharacterText:Hide()
  end

  winMain:SetSize(self:GetWindowSize())

  self:SetWindowScale(self.db.global.interface.windowScale / 100)
  self:SetWindowBackgroundColor(self.db.global.interface.windowColor)
  -- winMain:SetScale(self.db.global.interface.windowScale / 100)
  -- self:SetBackgroundColor(winMain, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
  winMain.Body.ScrollFrame.ScrollChild:SetSize(numCharacters * self.constants.sizes.column, winMain.Body.ScrollFrame:GetHeight())

  if self:IsScrollbarNeeded() then
    winMain.Footer.Scrollbar:SetMinMaxValues(0, winMain.Body.ScrollFrame.ScrollChild:GetWidth() - winMain.Body.ScrollFrame:GetWidth())
    winMain.Footer.Scrollbar.thumb:SetWidth(winMain.Footer.Scrollbar:GetWidth() / 10)
    winMain.Body:SetPoint("BOTTOMLEFT", winMain.Footer, "TOPLEFT")
    winMain.Body:SetPoint("BOTTOMRIGHT", winMain.Footer, "TOPRIGHT")
    winMain.Footer:Show()
  else
    winMain.Body.ScrollFrame:SetHorizontalScroll(0)
    winMain.Body:SetPoint("BOTTOMLEFT", winMain, "BOTTOMLEFT")
    winMain.Body:SetPoint("BOTTOMRIGHT", winMain, "BOTTOMRIGHT")
    winMain.Footer:Hide()
  end

  do -- TitleBar
    anchorFrame = winMain.TitleBar
    if numCharacters < 3 then
      winMain.TitleBar.Text:Hide()
    else
      winMain.TitleBar.Text:Show()
    end
    if currentAffixes and AE_table_count(currentAffixes) > 0 and self.db.global.showAffixHeader then
      if numCharacters < 2 then
        winMain.TitleBar.Affixes:Hide()
      else
        winMain.TitleBar.Affixes:Show()
      end
    else
      winMain.TitleBar.Affixes:Hide()
    end

    if currentAffixes and AE_table_count(currentAffixes) > 0 then
      for i = 1, AE_table_count(currentAffixes) do
        local affixButton = _G[winMain.TitleBar.Affixes:GetName() .. i]
        if affixButton ~= nil then
          if i == 1 then
            affixButton:ClearAllPoints()
            if numCharacters < 3 then
              affixButton:SetPoint("LEFT", winMain.TitleBar.Icon, "RIGHT", 6, 0)
            else
              affixButton:SetPoint("CENTER", anchorFrame, "CENTER", -((AE_table_count(currentAffixes) * 20) / 2), 0)
            end
          else
            affixButton:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)
          end
          anchorFrame = affixButton
        end
      end
    end
  end

  self:HideCharacterColumns()

  do -- Character Labels
    anchorFrame = winMain.Body.Sidebar
    for labelIndex, info in ipairs(labels) do
      local Label = _G[winMain.Body.Sidebar:GetName() .. "Label" .. labelIndex]
      if info.enabled ~= nil and info.enabled == false then
        Label:Hide()
      else
        if labelIndex > 1 then
          Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
          Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        else
          Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
          Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
        end
        Label:Show()
        anchorFrame = Label
      end
    end
  end

  do -- MythicPlus Label
    local Label = _G[winMain.Body.Sidebar:GetName() .. "MythicPlusLabel"]
    if Label then
      Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
      Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      anchorFrame = Label
    end
  end

  do -- Dungeon Labels
    for dungeonIndex, dungeon in ipairs(dungeons) do
      local Label = _G[winMain.Body.Sidebar:GetName() .. "Dungeon" .. dungeonIndex]
      Label:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
      Label:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
      Label.Icon:SetTexture(dungeon.icon)
      Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
      Label.Icon:SetTexture(tostring(dungeon.texture))
      if dungeon.spellID and IsSpellKnown(dungeon.spellID) and not InCombatLockdown() then
        Label:SetAttribute("type", "spell")
        Label:SetAttribute("spell", dungeon.spellID)
        Label:RegisterForClicks("AnyUp", "AnyDown")
        Label:EnableMouse(true)
      end
      Label:SetScript("OnEnter", function()
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(Label, "ANCHOR_RIGHT")
        GameTooltip:SetText(dungeon.name, 1, 1, 1)
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
      Label:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      anchorFrame = Label
    end
  end

  do -- Raids & Difficulties
    for raidIndex, raid in ipairs(raids) do
      local RaidFrame = _G[winMain.Body.Sidebar:GetName() .. "Raid" .. raidIndex]
      if RaidFrame then
        if self.db.global.raids.enabled and (not self.db.global.raids.modifiedInstanceOnly or raid.modifiedInstanceInfo or self:GetCurrentSeason() ~= 12) then
          RaidFrame:Show()
          RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
          RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
          anchorFrame = RaidFrame
          for difficultyIndex, difficulty in ipairs(difficulties) do
            local DifficultyFrame = _G[RaidFrame:GetName() .. "Difficulty" .. difficultyIndex]
            if DifficultyFrame then
              if self.db.global.raids.hiddenDifficulties and self.db.global.raids.hiddenDifficulties[difficulty.id] then
                DifficultyFrame:Hide()
              else
                DifficultyFrame:Show()
                DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                anchorFrame = DifficultyFrame
              end
            end
          end
        else
          RaidFrame:Hide()
        end
      end
    end
  end

  do -- Characters
    anchorFrame = winMain.Body.ScrollFrame.ScrollChild
    for characterIndex, character in ipairs(characters) do
      local CharacterColumn = self:GetCharacterColumn(winMain.Body.ScrollFrame.ScrollChild, characterIndex)
      if characterIndex > 1 then
        CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT")
        CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT")
      else
        CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
        CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT")
      end
      self:SetBackgroundColor(CharacterColumn, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
      anchorFrame = CharacterColumn

      do -- Character info
        anchorFrame = CharacterColumn
        for labelIndex, info in ipairs(labels) do
          local CharacterFrame = _G[CharacterColumn:GetName() .. "Info" .. labelIndex]

          CharacterFrame.Text:SetText(info.value(character))
          if info.OnEnter then
            CharacterFrame:SetScript("OnEnter", function()
              GameTooltip:ClearAllPoints()
              GameTooltip:ClearLines()
              GameTooltip:SetOwner(CharacterFrame, "ANCHOR_RIGHT")
              info.OnEnter(character)
              GameTooltip:Show()
              if not info.backgroundColor then
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
              end
            end)
            CharacterFrame:SetScript("OnLeave", function()
              GameTooltip:Hide()
              if not info.backgroundColor then
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
              end
            end)
          else
            if not info.backgroundColor then
              CharacterFrame:SetScript("OnEnter", function()
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
              end)
              CharacterFrame:SetScript("OnLeave", function()
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
              end)
            end
          end
          if info.OnClick then
            CharacterFrame:SetScript("OnClick", function()
              info.OnClick(character)
            end)
          end
          if info.enabled ~= nil and not info.enabled then
            CharacterFrame:Hide()
          else
            if labelIndex > 1 then
              CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
              CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            else
              CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
              CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
            end
            anchorFrame = CharacterFrame
            CharacterFrame:Show()
          end
        end
      end

      do -- Dungeon Header
        if CharacterColumn.DungeonHeader then
          CharacterColumn.DungeonHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
          CharacterColumn.DungeonHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
          anchorFrame = CharacterColumn.DungeonHeader
        end
      end

      do -- Dungeon rows
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

        for dungeonIndex, dungeon in ipairs(dungeons) do
          local DungeonFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex]
          local characterDungeon = AE_table_get(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
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

            if overallScore and self.db.global.showAffixColors then
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

          if level ~= "-" and self.db.global.showTiers then
            level = format("%s %s", level, tier)
          end

          DungeonFrame.Text:ClearAllPoints()
          DungeonFrame.Text:SetText(color:WrapTextInColorCode(level))
          DungeonFrame.Text:SetPoint("LEFT", DungeonFrame, "LEFT")
          DungeonFrame.Text:SetPoint("RIGHT", DungeonFrame, "CENTER", 0, 0)
          DungeonFrame.Text:SetJustifyH("CENTER")
          DungeonFrame.Tier:ClearAllPoints()
          DungeonFrame.Tier:SetText("")
          DungeonFrame.Score:ClearAllPoints()
          if overallScore then
            DungeonFrame.Score:SetText(color:WrapTextInColorCode(overallScore))
          else
            DungeonFrame.Score:SetText(color:WrapTextInColorCode("-"))
          end
          DungeonFrame.Score:SetPoint("LEFT", DungeonFrame, "CENTER")
          DungeonFrame.Score:SetPoint("RIGHT", DungeonFrame, "RIGHT")
          DungeonFrame.Score:SetJustifyH("CENTER")

          if not self.db.global.showScores then
            DungeonFrame.Text:ClearAllPoints()
            DungeonFrame.Text:SetPoint("CENTER", DungeonFrame, "CENTER")
            DungeonFrame.Score:SetText("")
          else
            if not self.db.global.showTiers then
              DungeonFrame.Text:SetPoint("RIGHT", DungeonFrame, "CENTER", 0, 0)
              DungeonFrame.Text:SetJustifyH("CENTER")
            end
          end

          if level == "-" then
            DungeonFrame.Text:ClearAllPoints()
            DungeonFrame.Text:SetPoint("CENTER", DungeonFrame, "CENTER")
            DungeonFrame.Tier:SetText("")
            DungeonFrame.Score:SetText("")
          end

          DungeonFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(DungeonFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(dungeon.name, 1, 1, 1)

            if affixScores and AE_table_count(affixScores) > 0 then
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
            self:SetBackgroundColor(DungeonFrame, 1, 1, 1, 0.05)
          end)
          DungeonFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            self:SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
          end)

          anchorFrame = DungeonFrame
        end
      end

      do -- Raid Rows
        for raidIndex, raid in ipairs(raids) do
          local RaidFrame = _G[CharacterColumn:GetName() .. "Raid" .. raidIndex]
          if self.db.global.raids.enabled and (not self.db.global.raids.modifiedInstanceOnly or raid.modifiedInstanceInfo or self:GetCurrentSeason() ~= 12) then
            RaidFrame:Show()
            RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            anchorFrame = RaidFrame
            for difficultyIndex, difficulty in pairs(difficulties) do
              local DifficultyFrame = _G[RaidFrame:GetName() .. "Difficulty" .. difficultyIndex]
              if DifficultyFrame then
                if self.db.global.raids.hiddenDifficulties and self.db.global.raids.hiddenDifficulties[difficulty.id] then
                  DifficultyFrame:Hide()
                else
                  DifficultyFrame:Show()
                  DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                  DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                  anchorFrame = DifficultyFrame
                  DifficultyFrame:SetScript("OnEnter", function()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(DifficultyFrame, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true)
                    GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name))
                    if character.raids.savedInstances ~= nil then
                      local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                        return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                      end)
                      if savedInstance ~= nil then
                        GameTooltip:AddLine(format("Expires: |cffffffff%s|r", date("%c", savedInstance.expires)))
                      end
                    end
                    GameTooltip:AddLine(" ")
                    for _, encounter in ipairs(raid.encounters) do
                      local color = LIGHTGRAY_FONT_COLOR
                      if character.raids.savedInstances then
                        local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                          return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                        end)
                        if savedInstance ~= nil then
                          local savedEncounter = AE_table_find(savedInstance.encounters, function(enc)
                            return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                          end)
                          if savedEncounter ~= nil then
                            color = GREEN_FONT_COLOR
                          end
                        end
                      end
                      GameTooltip:AddLine(encounter.name, color.r, color.g, color.b)
                    end
                    GameTooltip:Show()
                    self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0.05)
                  end)
                  DifficultyFrame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                    self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0)
                  end)
                  for encounterIndex, encounter in ipairs(raid.encounters) do
                    local color = {r = 1, g = 1, b = 1}
                    local alpha = 0.1
                    local EncounterFrame = _G[DifficultyFrame:GetName() .. "Encounter" .. encounterIndex]
                    if not EncounterFrame then
                      EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
                      local size = self.constants.sizes.column
                      size = size - self.constants.sizes.padding -- left/right cell padding
                      size = size - (raid.numEncounters - 1) * 4 -- gaps
                      size = size / raid.numEncounters           -- box sizes
                      EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", self.constants.sizes.padding / 2, 0)
                      EncounterFrame:SetSize(size, self.constants.sizes.row - 12)
                      self:SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                    end
                    if character.raids.savedInstances then
                      local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                        return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                      end)
                      if savedInstance ~= nil then
                        local savedEncounter = AE_table_find(savedInstance.encounters, function(enc)
                          return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                        end)
                        if savedEncounter ~= nil then
                          color = UNCOMMON_GREEN_COLOR
                          if self.db.global.raids.colors then
                            color = difficulty.color
                          end
                          alpha = 0.5
                        end
                      end
                    end
                    self:SetBackgroundColor(EncounterFrame, color.r, color.g, color.b, alpha)
                    anchorFrame = EncounterFrame
                  end
                  anchorFrame = DifficultyFrame
                end
              end
            end
          else
            RaidFrame:Hide()
          end
        end
      end
      anchorFrame = CharacterColumn
    end
  end
end
