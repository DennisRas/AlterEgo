---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = {}
addon.Data = Data

local Constants = addon.Constants
local LibAceDB = addon.Libs.AceDB
local LiqUI = addon.Libs.LiqUI
local TableCopy = LiqUI.Utils.TableCopy
local TableCount = LiqUI.Utils.TableCount
local TableFilter = LiqUI.Utils.TableFilter
local TableFind = LiqUI.Utils.TableFind
local TableForEach = LiqUI.Utils.TableForEach
local TableGet = LiqUI.Utils.TableGet

Data.dbVersion = 38

Data.defaultDB = {
  ---@type AE_Global
  global = {
    weeklyReset = 0,
    characters = {},
    minimap = {
      minimapPos = 195,
      hide = false,
      lock = false,
    },
    sorting = "lastUpdate",
    showTiers = true,
    showScores = true,
    showAffixColors = true,
    showAffixHeader = true,
    showZeroRatedCharacters = true,
    showRealms = true,
    showGuildInformation = false,
    currentCharacterMarker = "dot",
    announceKeystones = {
      autoParty = true,
      multiline = false,
      multilineNames = false,
    },
    announceResets = true,
    vault = {
      raids = true,
      dungeons = true,
      world = true,
    },
    prey = {
      enabled = true,
      hiddenDifficulties = {},
    },
    raids = {
      enabled = true,
      colors = true,
      currentTierOnly = true,
      hiddenDifficulties = {},
      killIcon = "skull",
      modifiedInstanceOnly = true,
    },
    dungeons = {
      enabled = true,
    },
    world = {
      enabled = true,
    },
    currencies = {
      enabled = true,
      hiddenCurrencies = {},
      showIcons = true,
      showMaxEarned = true,
      alignCenter = true,
    },
    interface = {
      -- fontSize = 12,
      windowScale = 100,
      windowColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
    },
    liqui = {
      windows = {
        Main = {},
        Affixes = {},
        Equipment = {},
      },
      tables = {
        Affixes = { hiddenColumns = {} },
        Equipment = { hiddenColumns = {} },
      },
    },
    useRIOScoreColor = false,
  },
}

---@type AE_Character
Data.defaultCharacter = {
  GUID = "",
  lastUpdate = 0,
  currentSeason = 0,
  enabled = true,
  order = 0,
  info = {
    name = "",
    realm = "",
    level = 0,
    race = {
      name = "",
      file = "",
      id = 0,
    },
    class = {
      name = "",
      file = "",
      id = 0,
    },
    factionGroup = {
      english = "",
      localized = "",
    },
    ilvl = {
      level = 0,
      equipped = 0,
      pvp = 0,
      color = "ffffffff",
    },
    guild = {
      isInGuild = false,
      name = "",
      rankName = "",
      rankIndex = 0,
      realm = "",
    },
  },
  equipment = {},
  money = 0,
  currencies = {},
  prey = {
    questsCompleted = {},
  },
  raids = {
    savedInstances = {},
  },
  mythicplus = {
    numCompletedDungeonRuns = {
      heroic = 0,
      mythic = 0,
      mythicPlus = 0,
    },
    rating = 0,
    keystone = {
      challengeModeID = 0,
      mapId = 0,
      level = 0,
      color = "",
      itemId = 0,
      itemLink = "",
    },
    bestSeasonScore = 0,
    bestSeasonNumber = 0,
    runHistory = {},
    dungeons = {},
  },
  vault = {
    hasAvailableRewards = false,
    slots = {},
    activityEncounterInfo = {},
    worldActivityProgress = {},
  },
}

---@type AE_Cache
Data.cache = {
  ---@type MythicPlusKeystoneAffix[]
  currentAffixes = {},
}

---Initiate AceDB
function Data:Initialize()
  self.db = LibAceDB:New(
    "AlterEgoDB",
    self.defaultDB,
    true
  )
end

---Get the currencies of the current season enriched with C_CurrencyInfo data
---@return AE_CurrencyInfo[]
function Data:GetCurrencies()
  local currencies = {}
  local seasonID = LiqUI.Data:GetCurrentSeason()
  TableForEach(self.currencies, function(currency)
    if currency.seasonID ~= seasonID then
      return
    end
    if currency.currencyType == "delveMap" then
      ---@type AE_CurrencyInfo
      local currencyInfo = {
        id = currency.id,
        name = currency.name or "Trovehunter's Bounty",
        description = "Weekly Trovehunter's Bounty map status.",
        iconFileID = C_Item.GetItemIconByID(currency.id) or 0,
        quality = Enum.ItemQuality.Rare,
        currencyType = currency.currencyType,
        useTotalEarnedForMaxQty = currency.useTotalEarnedForMaxQty,
        tooltipNote = currency.tooltipNote,
        maxQuantity = 0,
        maxWeeklyQuantity = 0,
        quantity = 0,
        totalEarned = 0,
        quantityEarnedThisWeek = 0,
      }
      table.insert(currencies, currencyInfo)
      return
    end
    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currency.id)
    if currencyInfo then
      currencyInfo.id = currency.id
      currencyInfo.currencyType = currency.currencyType
      currencyInfo.tooltipNote = currency.tooltipNote
      table.insert(currencies, currencyInfo)
    end
  end)
  return currencies
end

---Get stored character by GUID
---@param playerGUID WOWGUID?
---@return AE_Character|nil
function Data:GetCharacter(playerGUID)
  if playerGUID == nil then
    playerGUID = UnitGUID("player")
  end

  if playerGUID == nil then
    return nil
  end

  if self.db.global.characters[playerGUID] == nil then
    self.db.global.characters[playerGUID] = TableCopy(Data.defaultCharacter)
  end

  self.db.global.characters[playerGUID].GUID = playerGUID

  return self.db.global.characters[playerGUID]
end

---Remove a character from the addon. No undo; log in on that character again to reintroduce.
---@param characterOrGUID AE_Character|string
function Data:DeleteCharacter(characterOrGUID)
  local GUID = type(characterOrGUID) == "table" and characterOrGUID.GUID or characterOrGUID
  if not GUID or self.db.global.characters[GUID] == nil then return end
  self.db.global.characters[GUID] = nil
end

---Get prey difficulties for the current season
---@param unfiltered boolean?
---@return AE_PreyDifficulty[]
function Data:GetPreyDifficulties(unfiltered)
  local seasonID = LiqUI.Data:GetCurrentSeason()
  local result = {}
  for _, difficulty in pairs(self.preyDifficulties) do
    if difficulty.seasonID == seasonID then
      table.insert(result, difficulty)
    end
  end

  table.sort(result, function(a, b)
    return a.id < b.id
  end)

  if unfiltered then
    return result
  end

  local filtered = {}
  for _, difficulty in ipairs(result) do
    if self.db.global.prey.hiddenDifficulties and not self.db.global.prey.hiddenDifficulties[difficulty.id] then
      table.insert(filtered, difficulty)
    end
  end

  return filtered
end

---Get prey quests
---@param unfiltered boolean?
---@return AE_PreyQuest[]
function Data:GetPreyQuests(unfiltered)
  local result = {}
  for _, quest in pairs(self.preyQuests) do
    table.insert(result, quest)
  end
  return result
end

---Get raid difficulties, optionally including ones hidden in settings
---@param unfiltered boolean?
---@return LiqUI_RaidDifficulty[]
function Data:GetRaidDifficulties(unfiltered)
  local difficulties = LiqUI.Data:GetRaidDifficulties()
  if unfiltered then
    return difficulties
  end
  local hiddenDifficulties = self.db.global.raids.hiddenDifficulties
  return TableFilter(difficulties, function(difficulty)
    return hiddenDifficulties and not hiddenDifficulties[difficulty.id]
  end)
end

---Get the current affixes of the week
---@return MythicPlusKeystoneAffix[]
function Data:GetCurrentAffixes()
  if TableCount(self.cache.currentAffixes) == 0 then
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
      self.cache.currentAffixes = currentAffixes
    end
  end
  return self.cache.currentAffixes
end

---Get either all affixes or just the base seasonal affixes
---@param baseOnly boolean?
---@return AE_Affix[]
function Data:GetAffixes(baseOnly)
  return TableFilter(self.affixes, function(dataAffix)
    return not baseOnly or dataAffix.base == 1
  end)
end

---Get affix rotation of the current season
---@return AE_AffixRotation|nil
function Data:GetAffixRotation()
  local seasonID = LiqUI.Data:GetCurrentSeason()
  return TableGet(self.affixRotations, "seasonID", seasonID)
end

---Get the index of the active affix week
---@param currentAffixes MythicPlusKeystoneAffix[]|nil
---@return number
function Data:GetActiveAffixRotation(currentAffixes)
  local affixRotation = self:GetAffixRotation()
  local index = 0
  if currentAffixes and affixRotation then
    TableForEach(affixRotation.affixes, function(affixWeek, affixWeekIndex)
      local thisWeek = true
      TableForEach(affixWeek, function(affixID, affixIndex)
        if not (currentAffixes[affixIndex] and currentAffixes[affixIndex].id == affixID) then
          thisWeek = false
        end
      end)
      if thisWeek then
        index = affixWeekIndex
      end
    end)
  end
  return index
end

---Get the Keystone ItemID of the current season
---@return number|nil
function Data:GetKeystoneItemID()
  local seasonID = LiqUI.Data:GetCurrentSeason()
  local keystone = TableGet(self.keystones, "seasonID", seasonID)

  if keystone ~= nil then
    return keystone.itemID
  end

  return nil
end


---Set a new character order
---@param character AE_Character
---@param direction number
function Data:SortCharacter(character, direction)
  local characters = self:GetCharacters()
  for i, _ in pairs(characters) do
    if characters[i].GUID == character.GUID then
      if direction > 0 and i < #characters and characters[i + 1] then
        self.db.global.characters[character.GUID].order = characters[i + 1].order + 0.5
        break
      end
      if direction < 0 and i > 1 and characters[i - 1] then
        self.db.global.characters[character.GUID].order = characters[i - 1].order - 0.5
      end
    end
  end
end

---Get user characters
---@param unfiltered boolean?
---@return AE_Character[]
function Data:GetCharacters(unfiltered)
  local characters = {}
  for _, character in pairs(self.db.global.characters) do
    if character.info.level ~= nil and character.info.level >= 80 then -- Todo later: GetMaxLevelForPlayerExpansion()
      table.insert(characters, character)
    end
  end

  -- Update custom order
  local order = 1
  table.sort(characters, function(a, b)
    return (a.order or 0) < (b.order or 0)
  end)
  TableForEach(characters, function(character)
    self.db.global.characters[character.GUID].order = order
    order = order + 1
  end)

  -- Sorting
  table.sort(characters, function(a, b)
    if self.db.global.sorting == "name.asc" then
      return strcmputf8i(a.info.name, b.info.name) < 0
    elseif self.db.global.sorting == "name.desc" then
      return strcmputf8i(a.info.name, b.info.name) > 0
    elseif self.db.global.sorting == "realm.asc" then
      return strcmputf8i(a.info.realm, b.info.realm) < 0
    elseif self.db.global.sorting == "realm.desc" then
      return strcmputf8i(a.info.realm, b.info.realm) > 0
    elseif self.db.global.sorting == "rating.asc" then
      return a.mythicplus.rating < b.mythicplus.rating
    elseif self.db.global.sorting == "rating.desc" then
      return a.mythicplus.rating > b.mythicplus.rating
    elseif self.db.global.sorting == "ilvl.asc" then
      return a.info.ilvl.level < b.info.ilvl.level
    elseif self.db.global.sorting == "ilvl.desc" then
      return a.info.ilvl.level > b.info.ilvl.level
    elseif self.db.global.sorting == "class.asc" then
      return strcmputf8i(a.info.class.name, b.info.class.name) < 0
    elseif self.db.global.sorting == "class.desc" then
      return strcmputf8i(a.info.class.name, b.info.class.name) > 0
    elseif self.db.global.sorting == "custom" then
      return (a.order or 0) < (b.order or 0)
    end
    return a.lastUpdate > b.lastUpdate
  end)

  -- Filters
  if unfiltered then
    return characters
  end

  local charactersFiltered = {}
  for _, character in ipairs(characters) do
    local keep = true
    if not character.enabled then
      keep = false
    end
    if self.db.global.showZeroRatedCharacters == false and (character.mythicplus.rating and character.mythicplus.rating <= 0) then
      keep = false
    end
    if keep then
      table.insert(charactersFiltered, character)
    end
  end

  return charactersFiltered
end

---Update everything!
function Data:UpdateDB()
  self:UpdateCharacterInfo()
  self:UpdatePreyProgress()
  self:UpdateEquipment()
  self:UpdateMoney()
  self:UpdateCurrencies()
  self:UpdateKeystoneItem()
  self:UpdateRaidInstances()
  self:UpdateVault()
  self:UpdateMythicPlus()
end

---Run database migrations when dbVersion changes
function Data:MigrateDB()
  ---@diagnostic disable: undefined-field, inject-field
  if type(self.db.global.dbVersion) ~= "number" then
    self.db.global.dbVersion = self.dbVersion
  end
  if self.db.global.dbVersion < self.dbVersion then
    if self.db.global.dbVersion == 1 then
      for characterIndex in pairs(self.db.global.characters) do
        self.db.global.characters[characterIndex].raids.killed = nil
        if self.db.global.characters[characterIndex].raids.savedInstances then
          for savedInstanceIndex, savedInstance in ipairs(self.db.global.characters[characterIndex].raids.savedInstances) do
            if savedInstance.instanceID == 2549 and savedInstance.encounters then
              self.db.global.characters[characterIndex].raids.savedInstances[savedInstanceIndex].encounters[4].instanceEncounterID = 2731
              self.db.global.characters[characterIndex].raids.savedInstances[savedInstanceIndex].encounters[5].instanceEncounterID = 2728
            end
          end
        end
      end
    end
    -- Add missing affix IDs
    if self.db.global.dbVersion == 10 then
      local affixes = self:GetAffixes()
      for characterIndex in pairs(self.db.global.characters) do
        local character = self.db.global.characters[characterIndex]
        if character.mythicplus.dungeons ~= nil then
          TableForEach(character.mythicplus.dungeons, function(dungeon)
            TableForEach(dungeon.affixScores, function(affixScore)
              local affix = TableGet(affixes, "name", affixScore.name)
              if affixScore.id == nil then
                affixScore.id = affix and affix.id or 0
              end
            end)
          end)
        end
      end
    end
    -- Convert season ID from display ID to season major version ID
    if self.db.global.dbVersion == 15 then
      for _, character in pairs(self.db.global.characters) do
        if character.currentSeason ~= nil and character.currentSeason == 3 then
          character.currentSeason = 11
        end
      end
    end
    -- Fix SavedInstance/EncounterJournal name mismatch for "Sennarth, t|The Cold Breath"
    if self.db.global.dbVersion == 16 then
      for _, character in pairs(self.db.global.characters) do
        if character.raids and character.raids.savedInstances then
          for _, savedInstance in pairs(character.raids.savedInstances) do
            if savedInstance.instanceID == 2522 and savedInstance.encounters then
              for _, encounter in pairs(savedInstance.encounters) do
                if encounter.index and encounter.index == 5 and encounter.instanceEncounterID == 0 then
                  encounter.instanceEncounterID = 2592
                end
              end
            end
          end
        end
      end
    end
    -- Midnight Pre-patch stat squish
    if self.db.global.dbVersion == 30 then
      local function GetPostSquishItemLevel(preSquishItemLevel)
        return C_CurveUtil.EvaluateGameCurve(92181, preSquishItemLevel)
      end
      for _, character in pairs(self.db.global.characters) do
        character.info.ilvl.level = GetPostSquishItemLevel(character.info.ilvl.level) or 0
        character.info.ilvl.pvp = GetPostSquishItemLevel(character.info.ilvl.pvp) or 0
        character.info.ilvl.level = GetPostSquishItemLevel(character.info.ilvl.level) or 0
        for _, equipment in pairs(character.equipment or {}) do
          equipment.itemLevel = GetPostSquishItemLevel(equipment.itemLevel) or 0
          equipment.itemMinLevel = GetPostSquishItemLevel(equipment.itemMinLevel) or 0
        end
      end
    end
    -- Add prey progress slice if missing
    if self.db.global.dbVersion == 33 then
      for _, character in pairs(self.db.global.characters) do
        if character.prey == nil or character.prey.questsCompleted == nil then
          character.prey = {
            questsCompleted = {},
          }
        end
      end
    end
    if self.db.global.dbVersion == 34 then
      local interface = self.db.global.interface
      ---@type LiqUI_DB
      local liqui = {
        windows = {},
        tables = {},
        loggers = {},
      }
      for _, windowName in ipairs({"Main", "Affixes", "Equipment"}) do
        ---@type LiqUI_WindowDB
        local windowSettings = {}
        if interface and interface.windowScale then
          windowSettings.scale = interface.windowScale
        end
        if interface and interface.windowColor then
          windowSettings.windowColor = TableCopy(interface.windowColor)
        end
        liqui.windows[windowName] = windowSettings
      end
      self.db.global.liqui = liqui
    end
    if self.db.global.dbVersion == 35 then
      if self.db.global.preyHunts ~= nil then
        self.db.global.prey = self.db.global.preyHunts
        self.db.global.preyHunts = nil
      end
      for _, character in pairs(self.db.global.characters) do
        if character.preyHunts ~= nil then
          character.prey = character.preyHunts
          character.preyHunts = nil
        end
      end
      self.db.global.raids.killIcon = "skull"
      self.db.global.raids.boxes = nil
    end
    if self.db.global.dbVersion == 36 then
      self.db.global.currentCharacterMarker = "dot"
    end
    self.db.global.dbVersion = self.db.global.dbVersion + 1
    self:MigrateDB()
  end
  ---@diagnostic enable: undefined-field, inject-field
end

---Perform weekly reset tasks (e.g., vault, weekly-earn currency progress for offline alts)
function Data:TaskWeeklyReset()
  if type(self.db.global.weeklyReset) == "number" and self.db.global.weeklyReset <= time() then
    TableForEach(self.db.global.characters, function(character)
      -- Check if vault has available rewards
      TableForEach(character.vault.slots, function(slot)
        if slot.progress >= slot.threshold then
          character.vault.hasAvailableRewards = true
        end
      end)
      -- Mark previous m+ runs as not this week
      TableForEach(character.mythicplus.runHistory, function(run)
        run.thisWeek = false
      end)
      -- Reset Prey Hunts
      character.prey.questsCompleted = wipe(character.prey.questsCompleted or {})
      character.vault.activityEncounterInfo = wipe(character.vault.activityEncounterInfo or {})
      character.vault.slots = wipe(character.vault.slots or {})
      character.vault.worldActivityProgress = wipe(character.vault.worldActivityProgress or {})
      character.mythicplus.keystone = wipe(character.mythicplus.keystone or {})
      character.mythicplus.numCompletedDungeonRuns = wipe(character.mythicplus.numCompletedDungeonRuns or {})
      -- Reset quantityEarnedThisWeek if maxWeeklyQuantity is set
      TableForEach(character.currencies or {}, function(characterCurrency)
        if characterCurrency.maxWeeklyQuantity and characterCurrency.maxWeeklyQuantity > 0 then
          characterCurrency.quantityEarnedThisWeek = 0
        end
        if characterCurrency.currencyType == "delveMap" then
          characterCurrency.questCompleted = false
        end
      end)
    end)
  end
  self.db.global.weeklyReset = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()
end

---Perform season reset tasks
function Data:TaskSeasonReset()
  local seasonID = LiqUI.Data:GetCurrentSeason()
  if seasonID then
    TableForEach(self.db.global.characters, function(character)
      if character.currentSeason == nil or character.currentSeason < seasonID then
        wipe(character.mythicplus.runHistory or {})
        wipe(character.mythicplus.dungeons or {})
        wipe(character.currencies or {})
        character.mythicplus.rating = 0
        character.currentSeason = seasonID
        character.currentSeasonID = seasonID
      end
    end)
  end
end

---Load journal fill from LiqUI and affix names from the API
function Data:loadGameData()
  LiqUI.Data:RequestGameData()

  for _, affix in pairs(self.affixes) do
    local name, description, fileDataID = C_ChallengeMode.GetAffixInfo(affix.id)
    affix.name = name
    affix.description = description
    affix.fileDataID = fileDataID
  end
end

---Refresh saved raid instances from the API
function Data:UpdateRaidInstances()
  local character = self:GetCharacter()
  if not character then return end
  character.raids.savedInstances = wipe(character.raids.savedInstances or {})

  local raids = LiqUI.Data:GetRaids()
  local numSavedInstances = GetNumSavedInstances()
  if numSavedInstances == 0 then return end

  for savedInstanceIndex = 1, numSavedInstances do
    local name, lockoutId, reset, difficultyID, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceID = GetSavedInstanceInfo(savedInstanceIndex)
    local raid = TableGet(raids, "instanceID", instanceID)
    ---@type AE_SavedInstance
    local savedInstance = {
      index = savedInstanceIndex,
      id = lockoutId,
      name = name,
      lockoutId = lockoutId,
      reset = reset,
      difficultyID = difficultyID,
      locked = locked,
      extended = extended,
      instanceIDMostSig = instanceIDMostSig,
      isRaid = isRaid,
      maxPlayers = maxPlayers,
      difficultyName = difficultyName,
      numEncounters = numEncounters,
      encounterProgress = encounterProgress,
      extendDisabled = extendDisabled,
      instanceID = instanceID,
      link = GetSavedInstanceChatLink(savedInstanceIndex),
      expires = 0,
      encounters = {},
    }
    if reset and reset > 0 then
      savedInstance.expires = reset + time()
    end
    for encounterIndex = 1, numEncounters do
      local bossName, fileDataID, isKilled = GetSavedInstanceEncounterInfo(savedInstanceIndex, encounterIndex)
      local instanceEncounterID = 0
      if raid then
        TableForEach(raid.encounters, function(encounter)
          if string.lower(encounter.name) == string.lower(bossName) then
            instanceEncounterID = encounter.instanceEncounterID
          end
        end)
      end
      ---@type AE_SavedInstanceEncounter
      local savedInstanceEncounter = {
        index = encounterIndex,
        instanceEncounterID = instanceEncounterID,
        bossName = bossName,
        fileDataID = fileDataID or 0,
        isKilled = isKilled,
      }
      savedInstance.encounters[encounterIndex] = savedInstanceEncounter
    end
    character.raids.savedInstances[savedInstanceIndex] = savedInstance
  end
  addon.Core:Render()
end

function Data:UpdatePreyProgress()
  local character = self:GetCharacter()
  if not character then return end
  character.prey = character.prey or {}
  character.prey.questsCompleted = wipe(character.prey.questsCompleted or {})
  TableForEach(self.preyQuests, function(quest)
    character.prey.questsCompleted[quest.questID] = C_QuestLog.IsQuestFlaggedCompleted(quest.questID)
  end)
end

---Refresh general character info from the API
function Data:UpdateCharacterInfo()
  local character = self:GetCharacter()
  if not character then return end

  local playerName = UnitName("player")
  local playerRealm = GetRealmName()
  local playerLevel = UnitLevel("player")
  local playerRaceName, playerRaceFile, playerRaceID = UnitRace("player")
  local playerClassName, playerClassFile, playerClassID = UnitClass("player")
  local playerFactionGroupEnglish, playerFactionGroupLocalized = UnitFactionGroup("player")
  local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
  local itemLevelColorR, itemLevelColorG, itemLevelColorB = GetItemLevelColor()
  local guildName, guildRankName, guildRankIndex, guildRealm = GetGuildInfo("player")
  local isInGuild = IsInGuild()

  if playerName then character.info.name = playerName end
  if playerRealm then character.info.realm = playerRealm end
  if playerLevel then character.info.level = playerLevel end
  if type(character.info.race) ~= "table" then character.info.race = self.defaultCharacter.info.race end
  if playerRaceName then character.info.race.name = playerRaceName end
  if playerRaceFile then character.info.race.file = playerRaceFile end
  if playerRaceID then character.info.race.id = playerRaceID end
  if type(character.info.class) ~= "table" then character.info.class = self.defaultCharacter.info.class end
  if playerClassName then character.info.class.name = playerClassName end
  if playerClassFile then character.info.class.file = playerClassFile end
  if playerClassID then character.info.class.id = playerClassID end
  if type(character.info.factionGroup) ~= "table" then character.info.factionGroup = self.defaultCharacter.info.factionGroup end
  if playerFactionGroupEnglish then character.info.factionGroup.english = playerFactionGroupEnglish end
  if playerFactionGroupLocalized then character.info.factionGroup.localized = playerFactionGroupLocalized end
  if avgItemLevel then character.info.ilvl.level = avgItemLevel end
  if avgItemLevelEquipped then character.info.ilvl.equipped = avgItemLevelEquipped end
  if avgItemLevelPvp then character.info.ilvl.pvp = avgItemLevelPvp end
  if itemLevelColorR and itemLevelColorG and itemLevelColorB then character.info.ilvl.color = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor() end
  if type(character.info.guild) ~= "table" then character.info.guild = self.defaultCharacter.info.guild end
  character.info.guild.name = guildName
  character.info.guild.rankName = guildRankName
  character.info.guild.rankIndex = guildRankIndex
  character.info.guild.realm = guildRealm
  character.info.guild.isInGuild = isInGuild

  character.lastUpdate = GetServerTime()
  addon.Core:Render()
end

---Refresh character money from the API
function Data:UpdateMoney()
  local character = self:GetCharacter()
  if not character then return end

  local money = GetMoney()
  if not money then return end

  character.money = money
end

---Refresh currencies from the API
function Data:UpdateCurrencies()
  local character = self:GetCharacter()
  if not character then return end
  local seasonID = LiqUI.Data:GetCurrentSeason()

  character.currencies = wipe(character.currencies or {})

  TableForEach(self.currencies or {}, function(dataCurrency)
    if dataCurrency.seasonID ~= seasonID then
      return
    end
    if dataCurrency.currencyType == "delveMap" then
      local bagCount = C_Item.GetItemCount(dataCurrency.id, true) or 0
      local hasBuff = false
      if dataCurrency.spellID then
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(dataCurrency.spellID)
        if aura ~= nil and not issecretvalue(aura) then
          hasBuff = true
        end
      end

      ---@type AE_CharacterCurrency
      local delveMapCurrency = {
        id = dataCurrency.id,
        currencyType = dataCurrency.currencyType,
        name = dataCurrency.name or "Trovehunter's Bounty",
        iconFileID = C_Item.GetItemIconByID(dataCurrency.id) or 0,
        quantity = bagCount,
        bagCount = bagCount,
        hasBuff = hasBuff,
        questCompleted = dataCurrency.questID ~= nil and C_QuestLog.IsQuestFlaggedCompleted(dataCurrency.questID) == true,
      }
      table.insert(character.currencies, delveMapCurrency)
      return
    end

    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(dataCurrency.id)
    if not currencyInfo then return end
    ---@type AE_CharacterCurrency
    local currency = currencyInfo
    currency.id = dataCurrency.id
    currency.currencyType = dataCurrency.currencyType
    if dataCurrency.itemID then
      currency.quantity = C_Item.GetItemCount(dataCurrency.itemID, true)
      currency.iconFileID = C_Item.GetItemIconByID(dataCurrency.itemID) or 0
    end
    table.insert(character.currencies, currency)
  end)
end

---Refresh equipment from the API
function Data:UpdateEquipment()
  local character = self:GetCharacter()
  if not character then return end

  character.equipment = wipe(character.equipment or {})

  local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
  upgradePattern = upgradePattern:gsub("%%d", "%%s")
  upgradePattern = upgradePattern:format("(.+)", "(%d+)", "(%d+)")

  TableForEach(LiqUI.Data:GetInventorySlots(), function(slot)
    local inventoryItemLink = GetInventoryItemLink("player", slot.id)
    if not inventoryItemLink then return end

    local itemUpgradeTrack, itemUpgradeLevel, itemUpgradeMax, itemUpgradeColor = "", 0, 0, ""
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expansionID, setID, isCraftingReagent = C_Item.GetItemInfo(inventoryItemLink)
    if itemName == nil then return end

    local upgradeInfo = C_Item.GetItemUpgradeInfo(inventoryItemLink)
    if upgradeInfo and upgradeInfo.trackString and upgradeInfo.trackString ~= "" and upgradeInfo.currentLevel > 0 and upgradeInfo.maxLevel > 0 then
      itemUpgradeTrack = upgradeInfo.trackString
      itemUpgradeLevel = upgradeInfo.currentLevel
      itemUpgradeMax = upgradeInfo.maxLevel
    end

    local tooltipData = C_TooltipInfo.GetInventoryItem("player", slot.id)
    if tooltipData and tooltipData.lines then
      TableForEach(tooltipData.lines, function(line)
        if not line.leftText then return end
        local match, _, uTrack, uLevel, uMax = line.leftText:find(upgradePattern)
        if not match then return end
        if itemUpgradeTrack == "" then
          if uTrack then
            itemUpgradeTrack = uTrack
          end
          if uLevel then
            itemUpgradeLevel = tonumber(uLevel) or itemUpgradeLevel
          end
          if uMax then
            itemUpgradeMax = tonumber(uMax) or itemUpgradeMax
          end
        end
        if line.leftColor then
          itemUpgradeColor = line.leftColor:GenerateHexColor()
        end
      end)
    end

    ---@type AE_Equipment
    local equipment = {
      itemName = itemName,
      itemLink = itemLink,
      itemQuality = itemQuality,
      itemLevel = itemLevel,
      itemMinLevel = itemMinLevel,
      itemType = itemType,
      itemSubType = itemSubType,
      itemStackCount = itemStackCount,
      itemEquipLoc = itemEquipLoc,
      itemTexture = itemTexture,
      sellPrice = sellPrice,
      classID = classID,
      subclassID = subclassID,
      bindType = bindType,
      expansionID = expansionID,
      setID = setID,
      isCraftingReagent = isCraftingReagent,
      itemUpgradeTrack = itemUpgradeTrack,
      itemUpgradeLevel = itemUpgradeLevel,
      itemUpgradeMax = itemUpgradeMax,
      itemUpgradeColor = itemUpgradeColor,
      itemSlotID = slot.id,
      itemSlotName = slot.token,
    }
    table.insert(character.equipment, equipment)
  end)
end

local function isKeystoneAnnounceBlocked()
  return InCombatLockdown()
    or C_ChatInfo.InChatMessagingLockdown()
    or C_RestrictedActions.IsAddOnRestrictionActive(Enum.AddOnRestrictionType.Chat)
    or C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.WeeklyRewards)
end

---@param itemLink string?
---@param dungeon LiqUI_Dungeon?
---@param keystoneLevel number?
local function sendNewKeystoneAnnounce(itemLink, dungeon, keystoneLevel)
  if isKeystoneAnnounceBlocked() then
    Data.cache.pendingKeystoneAnnounce = true
    return
  end
  local announceText
  if itemLink and not issecretvalue(itemLink) and itemLink ~= "" then
    announceText = itemLink
  elseif dungeon and type(keystoneLevel) == "number" and keystoneLevel > 0 then
    local name = dungeon.abbr or dungeon.short or dungeon.name
    if type(name) == "string" and name ~= "" then
      announceText = name .. " +" .. tostring(keystoneLevel)
    end
  end
  if not announceText then
    Data.cache.pendingKeystoneAnnounce = true
    return
  end
  local message = Constants.prefix .. "New Keystone: " .. announceText
  if not (IsInGroup() and Data.db.global.announceKeystones.autoParty) then
    Data.cache.pendingKeystoneAnnounce = nil
    return
  end
  if pcall(C_ChatInfo.SendChatMessage, message, "PARTY") then
    Data.cache.pendingKeystoneAnnounce = nil
  else
    Data.cache.pendingKeystoneAnnounce = true
  end
end

---Send a queued new-keystone announce once chat is unrestricted
function Data:FlushPendingKeystoneAnnounce()
  if not self.cache.pendingKeystoneAnnounce then
    return
  end
  local character = self:GetCharacter()
  if not character then
    return
  end
  local keystone = character.mythicplus.keystone
  local dungeons = LiqUI.Data:GetDungeons()
  local dungeon = TableGet(dungeons, "challengeModeID", keystone.challengeModeID) or TableGet(dungeons, "mapId", keystone.mapId)
  sendNewKeystoneAnnounce(keystone.itemLink, dungeon, keystone.level)
end

---Refresh keystone item from bags
function Data:UpdateKeystoneItem()
  local character = self:GetCharacter()
  if not character then return end
  local dungeons = LiqUI.Data:GetDungeons()
  local seasonKeystoneItemID = self:GetKeystoneItemID()
  local characterKeystoneMapID = character.mythicplus.keystone.mapId
  local characterKeystoneLevel = character.mythicplus.keystone.level

  do -- Base keystone data
    local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    local keyStoneChallengeModeID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    if keyStoneMapID ~= nil then character.mythicplus.keystone.mapId = tonumber(keyStoneMapID) or 0 end
    if keyStoneLevel ~= nil then character.mythicplus.keystone.level = tonumber(keyStoneLevel) or 0 end
    if keyStoneChallengeModeID ~= nil then character.mythicplus.keystone.challengeModeID = tonumber(keyStoneChallengeModeID) or 0 end
  end

  local keystoneItemID = nil
  local keystoneItemLink = nil
  for bagID = 0, NUM_BAG_SLOTS do
    for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
      local containerItemId = C_Container.GetContainerItemID(bagID, slotID)
      if containerItemId then
        local isSeasonKeystone = seasonKeystoneItemID and containerItemId == seasonKeystoneItemID
        if isSeasonKeystone or C_Item.IsItemKeystoneByID(containerItemId) then
          keystoneItemLink = C_Container.GetContainerItemLink(bagID, slotID)
          keystoneItemID = containerItemId
          break
        end
      end
    end
    if keystoneItemLink then
      break
    end
  end

  if not keystoneItemLink then return addon.Core:Render() end
  if not LinkUtil.IsLinkType(keystoneItemLink, "keystone") then return addon.Core:Render() end

  local _, linkOptions = LinkUtil.ExtractLink(keystoneItemLink)
  if not linkOptions then return addon.Core:Render() end

  local _, linkChallengeModeID, linkLevel = LinkUtil.SplitLinkOptions(linkOptions)
  if not linkChallengeModeID or not linkLevel then return addon.Core:Render() end
  local keystoneChallengeModeID = tonumber(linkChallengeModeID) or 0
  local keystoneLevel = tonumber(linkLevel) or 0

  local dungeon = TableGet(dungeons, "challengeModeID", keystoneChallengeModeID)
  if not dungeon then return addon.Core:Render() end
  local dungeonMapId = tonumber(dungeon.mapId) or 0

  local newKeystone = false
  if characterKeystoneMapID and characterKeystoneLevel then
    if characterKeystoneMapID ~= dungeonMapId or characterKeystoneLevel < keystoneLevel then
      newKeystone = true
    end
  elseif dungeonMapId and keystoneLevel then
    newKeystone = true
  end

  local keystoneColor = "ffffffff"
  local color = C_ChallengeMode.GetKeystoneLevelRarityColor(keystoneLevel)
  if color then
    keystoneColor = color:GenerateHexColor()
  end

  local storedItemLink = keystoneItemLink
  if issecretvalue(storedItemLink) then
    storedItemLink = ""
  end

  character.mythicplus.keystone = {
    challengeModeID = keystoneChallengeModeID,
    mapId = dungeonMapId,
    level = keystoneLevel,
    color = keystoneColor,
    itemId = keystoneItemID or seasonKeystoneItemID or 0,
    itemLink = storedItemLink,
  }

  if newKeystone then
    sendNewKeystoneAnnounce(keystoneItemLink, dungeon, keystoneLevel)
  end

  addon.Core:Render()
end

---Refresh Great Vault progress/info
function Data:UpdateVault()
  local character = self:GetCharacter()
  if not character then return end

  character.vault.activityEncounterInfo = wipe(character.vault.activityEncounterInfo or {})
  character.vault.slots = wipe(character.vault.slots or {})
  character.vault.worldActivityProgress = wipe(character.vault.worldActivityProgress or {})

  TableForEach(self.vaultTypes or {}, function(vaultType)
    for index = 1, 3 do
      local encounters = C_WeeklyRewards.GetActivityEncounterInfo(vaultType.id, index)
      if encounters then
        TableForEach(encounters, function(encounter)
          if not encounter then return end
          encounter.type = vaultType.id
          encounter.index = index
          table.insert(character.vault.activityEncounterInfo, encounter)
        end)
      end
    end
  end)

  local activities = C_WeeklyRewards.GetActivities()
  TableForEach(activities, function(activity)
    activity.exampleRewardLink = ""
    activity.exampleRewardUpgradeLink = ""
    if activity.progress >= activity.threshold then
      local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)
      activity.exampleRewardLink = itemLink
      activity.exampleRewardUpgradeLink = upgradeItemLink
    end
    table.insert(character.vault.slots, activity)
  end)

  local worldActivityProgress = C_WeeklyRewards.GetSortedProgressForActivity(Enum.WeeklyRewardChestThresholdType.World, true)
  if worldActivityProgress then
    TableForEach(worldActivityProgress, function(tierProgress)
      ---@type WeeklyRewardActivityTierProgress
      local row = {
        activityTierID = tierProgress.activityTierID,
        difficulty = tierProgress.difficulty,
        numPoints = tierProgress.numPoints,
      }
      table.insert(character.vault.worldActivityProgress, row)
    end)
  end

  character.vault.hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards() == true
  addon.Core:Render()
end

---Refresh Mythic+ data from the API
function Data:UpdateMythicPlus()
  local character = self:GetCharacter()
  if not character then return end

  local dungeons = LiqUI.Data:GetDungeons()
  local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
  local runHistory = C_MythicPlus.GetRunHistory(true, true)
  local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion()
  local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns()
  local affixes = self:GetAffixes()

  if ratingSummary ~= nil and ratingSummary.currentSeasonScore ~= nil then character.mythicplus.rating = ratingSummary.currentSeasonScore end
  if runHistory ~= nil then character.mythicplus.runHistory = runHistory end
  if bestSeasonScore ~= nil then character.mythicplus.bestSeasonScore = bestSeasonScore end
  if bestSeasonNumber ~= nil then character.mythicplus.bestSeasonNumber = bestSeasonNumber end

  character.vault.hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards() == true

  character.mythicplus.numCompletedDungeonRuns = {
    heroic = numHeroic or 0,
    mythic = numMythic or 0,
    mythicPlus = numMythicPlus or 0,
  }

  character.mythicplus.dungeons = wipe(character.mythicplus.dungeons or {})
  for _, dataDungeon in pairs(dungeons) do
    local bestTimedRun, bestNotTimedRun = C_MythicPlus.GetSeasonBestForMap(dataDungeon.challengeModeID)
    local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dataDungeon.challengeModeID)

    if affixScores then
      TableForEach(affixScores, function(affixScore)
        local affix = TableGet(affixes, "name", affixScore.name)
        affixScore.id = affix and affix.id or 0
      end)
    end

    ---@type AE_CharacterDungeon
    local dungeon = {
      challengeModeID = dataDungeon.challengeModeID,
      rating = 0,
      level = 0,
      finishedSuccess = false,
      bestTimedRun = bestTimedRun,
      bestNotTimedRun = bestNotTimedRun,
      affixScores = affixScores,
      bestOverAllScore = bestOverAllScore,
    }

    if ratingSummary then
      local run = TableFind(ratingSummary.runs or {}, function(ratingRun)
        return ratingRun.challengeModeID == dataDungeon.challengeModeID
      end)
      if run then
        dungeon.rating = run.mapScore
        dungeon.level = run.bestRunLevel
        dungeon.finishedSuccess = run.finishedSuccess
      end
    end
    table.insert(character.mythicplus.dungeons, dungeon)
  end
  addon.Core:Render()
end
