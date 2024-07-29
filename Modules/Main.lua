---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Constants = addon.Constants
local Utils = addon.Utils
local Window = addon.Window
local Core = addon.Core
local Data = addon.Data
local Module = Core:NewModule("Main", "AceEvent-3.0")

-- local SIDEBAR_WIDTH = 150
local CHARACTER_WIDTH = 120

--- Does the main window need scrollbars?
---@return boolean
function Module:IsScrollbarNeeded()
  local numCharacters = Utils:TableCount(Data:GetCharacters())
  return numCharacters > 0 and numCharacters * CHARACTER_WIDTH > Window:GetMaxWindowWidth()
end

--- Calculate the main window size
---@return number, number
function Module:GetBodySize()
  local numCharacters = Utils:TableCount(Data:GetCharacters())
  local numDungeons = Utils:TableCount(Data:GetDungeons())
  local numRaids = Utils:TableCount(Data:GetRaids())
  local numDifficulties = Utils:TableCount(Data:GetRaidDifficulties())
  local numCharacterInfo = Utils:TableCount(self:GetCharacterInfo())
  local maxWidth = Window:GetMaxWindowWidth()
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
  height = height + numCharacterInfo * Constants.sizes.row                 -- Character info
  height = height + (numDungeons + 1) * Constants.sizes.row                -- Dungeons
  height = height + numRaids * (numDifficulties + 1) * Constants.sizes.row -- Raids

  return width, height
end

function Module:OnEnable()
  Core:RegisterBucketEvent(
    {
      "BAG_UPDATE_DELAYED",
      "BONUS_ROLL_RESULT",
      "BOSS_KILL",
      "CHALLENGE_MODE_COMPLETED",
      "CHALLENGE_MODE_MAPS_UPDATE",
      "CHALLENGE_MODE_RESET",
      "CHAT_MSG_CURRENCY",
      "CHAT_MSG_SYSTEM",
      "CURRENCY_DISPLAY_UPDATE",
      "ENCOUNTER_END",
      "ITEM_CHANGED",
      "LFG_LOCK_INFO_RECEIVED",
      "LFG_UPDATE_RANDOM_INFO",
      "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE",
      "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE",
      "MYTHIC_PLUS_NEW_WEEKLY_RECORD",
      "PLAYER_EQUIPMENT_CHANGED",
      "PLAYER_LEVEL_UP",
      "PLAYER_TRADE_CURRENCY",
      "POST_MATCH_CURRENCY_REWARD_UPDATE",
      "QUEST_CURRENCY_LOOT_RECEIVED",
      "RAID_INSTANCE_WELCOME",
      "SPELL_CONFIRMATION_PROMPT",
      "TRADE_CURRENCY_CHANGED",
      "TRADE_SKILL_CURRENCY_REWARD_RESULT",
      "UNIT_INVENTORY_CHANGED",
      "UPDATE_INSTANCE_INFO",
      "WEEKLY_REWARDS_UPDATE",
    },
    1,
    function()
      self:Render()
    end
  )
  Core:RegisterMessage("AE_SETTINGS_UPDATED", function()
    self:Render()
  end)
  self:Render()
end

function Module:ToggleWindow()
  self:Render()
  if not self.window then
    return
  end
  self.window:Toggle()
end

function Module:Render()
  local currentAffixes = Data:GetCurrentAffixes()
  local activeWeek = Data:GetActiveAffixRotation(currentAffixes)
  local seasonID = Data:GetCurrentSeason()
  local dungeons = Data:GetDungeons()
  local affixRotation = Data:GetAffixRotation()
  local difficulties = Data:GetRaidDifficulties()
  local characterInfo = self:GetCharacterInfo()
  local raids = Data:GetRaids()
  local characters = Data:GetCharacters()
  local affixes = Data:GetAffixes(true)

  if not self.window then
    self.window = Window:New({
      name = "Main",
      title = addonName,
      sidebar = 150,
    })
    self.window.affixes = CreateFrame("Frame", "$parentAffixes", self.window.titlebar)
    self.window.affixes.buttons = {}
    self:SetupButtons()
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
    local affixAnchor = self.window.titlebar
    if Data.db.global.showAffixHeader then
      Utils:TableForEach(currentAffixes, function(affix, affixIndex)
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
          GameTooltip:ClearAllPoints()
          GameTooltip:ClearLines()
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
          local module = Core:GetModule("WeeklyAffixes")
          if module then
            module:Open()
          end
        end)
        if affixIndex == 1 then
          if Utils:TableCount(characters) == 1 then
            affixFrame:SetPoint("LEFT", self.window.titlebar.icon, "RIGHT", 6, 0)
          else
            affixFrame:SetPoint("CENTER", self.window.titlebar, "CENTER", -26, 0)
          end
        else
          affixFrame:SetPoint("LEFT", affixAnchor, "RIGHT", 6, 0)
        end
        affixAnchor = affixFrame
      end)
      self.window.affixes:Show()
    else
      self.window.affixes:Hide()
    end
  end

  do   -- Sidebar
    local rowCount = 0
    do -- CharacterInfo Labels
      self.window.sidebar.infoFrames = self.window.sidebar.infoFrames or {}
      Utils:TableForEach(self.window.sidebar.infoFrames, function(f) f:Hide() end)
      Utils:TableForEach(characterInfo, function(info, infoIndex)
        local infoFrame = self.window.sidebar.infoFrames[infoIndex]
        if not infoFrame then
          infoFrame = CreateFrame("Frame", "$parentInfo" .. infoIndex, self.window.sidebar)
          infoFrame.text = infoFrame:CreateFontString(infoFrame:GetName() .. "Text", "OVERLAY")
          infoFrame.text:SetPoint("LEFT", infoFrame, "LEFT", Constants.sizes.padding, 0)
          infoFrame.text:SetPoint("RIGHT", infoFrame, "RIGHT", -Constants.sizes.padding, 0)
          infoFrame.text:SetJustifyH("LEFT")
          infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          infoFrame.text:SetVertexColor(1.0, 0.82, 0.0, 1)
          self.window.sidebar.infoFrames[infoIndex] = infoFrame
        end

        infoFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
        infoFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
        infoFrame:SetHeight(Constants.sizes.row)
        infoFrame.text:SetText(info.label)
        infoFrame:Show()
        rowCount = rowCount + 1
      end)
    end

    do -- MythicPlus Header
      local label = self.window.sidebar.mpluslabel
      if not label then
        label = CreateFrame("Frame", "$parentMythicPlusLabel", self.window.sidebar)
        label:SetHeight(Constants.sizes.row)
        label.text = label:CreateFontString(label:GetName() .. "Text", "OVERLAY")
        label.text:SetPoint("TOPLEFT", label, "TOPLEFT", Constants.sizes.padding, 0)
        label.text:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", -Constants.sizes.padding, 0)
        label.text:SetFontObject("GameFontHighlight_NoShadow")
        label.text:SetJustifyH("LEFT")
        label.text:SetText("Mythic Plus")
        label.text:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.window.sidebar.mpluslabel = label
      end

      label:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
      label:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
      label:Show()
      rowCount = rowCount + 1
    end

    do -- MythicPlus Labels
      self.window.sidebar.mpluslabels = self.window.sidebar.mpluslabels or {}
      Utils:TableForEach(self.window.sidebar.mpluslabels, function(f) f:Hide() end)
      if Utils:TableCount(dungeons) > 0 then
        Utils:TableForEach(dungeons, function(dungeon, dungeonIndex)
          local dungeonFrame = self.window.sidebar.mpluslabels[dungeonIndex]
          if not dungeonFrame then
            dungeonFrame = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, self.window.sidebar, "InsecureActionButtonTemplate")
            dungeonFrame:RegisterForClicks("AnyUp", "AnyDown")
            dungeonFrame:EnableMouse(true)
            dungeonFrame:SetHeight(Constants.sizes.row)
            dungeonFrame.icon = dungeonFrame:CreateTexture(dungeonFrame:GetName() .. "Icon", "ARTWORK")
            dungeonFrame.icon:SetSize(16, 16)
            dungeonFrame.icon:SetPoint("LEFT", dungeonFrame, "LEFT", Constants.sizes.padding, 0)
            -- label.icon:SetTexture(dungeon.icon)
            dungeonFrame.text = dungeonFrame:CreateFontString(dungeonFrame:GetName() .. "Text", "OVERLAY")
            dungeonFrame.text:SetPoint("TOPLEFT", dungeonFrame, "TOPLEFT", 16 + Constants.sizes.padding * 2, -3)
            dungeonFrame.text:SetPoint("BOTTOMRIGHT", dungeonFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
            dungeonFrame.text:SetJustifyH("LEFT")
            dungeonFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            self.window.sidebar.mpluslabels[dungeonIndex] = dungeonFrame
          end

          if dungeon.spellID and IsSpellKnown(dungeon.spellID) and not InCombatLockdown() then
            dungeonFrame:SetAttribute("type", "spell")
            dungeonFrame:SetAttribute("spell", dungeon.spellID)
          end

          dungeonFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
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

          dungeonFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
          dungeonFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
          dungeonFrame.icon:SetTexture(tostring(dungeon.texture))
          dungeonFrame.text:SetText(dungeon.short and dungeon.short or dungeon.name)
          dungeonFrame:Show()
          rowCount = rowCount + 1
        end)
      end

      do -- Raid Labels
        self.window.sidebar.raidFrames = self.window.sidebar.raidFrames or {}
        self.window.sidebar.difficultyFrames = self.window.sidebar.difficultyFrames or {}
        Utils:TableForEach(self.window.sidebar.raidFrames, function(f) f:Hide() end)
        Utils:TableForEach(self.window.sidebar.difficultyFrames, function(f) f:Hide() end)
        if Data.db.global.raids.enabled then
          Utils:TableForEach(raids, function(raid, raidIndex)
            local raidFrame = self.window.sidebar.raidFrames[raidIndex]
            if not raidFrame then
              raidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, self.window.sidebar)
              raidFrame.difficultyFrames = {}
              raidFrame.text = raidFrame:CreateFontString(raidFrame:GetName() .. "Text", "OVERLAY")
              raidFrame.text:SetPoint("LEFT", raidFrame, "LEFT", Constants.sizes.padding, 0)
              raidFrame.text:SetFontObject("GameFontHighlight_NoShadow")
              raidFrame.text:SetJustifyH("LEFT")
              raidFrame.text:SetWordWrap(false)
              raidFrame.text:SetVertexColor(1.0, 0.82, 0.0, 1)
              raidFrame.ModifiedIcon = raidFrame:CreateTexture("$parentModifiedIcon", "ARTWORK")
              raidFrame.ModifiedIcon:SetSize(18, 18)
              raidFrame.ModifiedIcon:SetPoint("RIGHT", raidFrame, "RIGHT", -(Constants.sizes.padding / 2), 0)
              self.window.sidebar.raidFrames[raidIndex] = raidFrame
            end

            if raid.modifiedInstanceInfo and raid.modifiedInstanceInfo.uiTextureKit then
              raidFrame.ModifiedIcon:SetAtlas(GetFinalNameFromTextureKit("%s-small", raid.modifiedInstanceInfo.uiTextureKit))
              raidFrame.ModifiedIcon:Show()
              raidFrame.text:SetPoint("RIGHT", raidFrame.ModifiedIcon, "LEFT", -(Constants.sizes.padding / 2), 0)
            else
              raidFrame.ModifiedIcon:Hide()
              raidFrame.text:SetPoint("RIGHT", raidFrame, "RIGHT", -Constants.sizes.padding, 0)
            end

            raidFrame:SetHeight(Constants.sizes.row)
            raidFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
            raidFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
            raidFrame:SetScript("OnEnter", function()
              GameTooltip:ClearAllPoints()
              GameTooltip:ClearLines()
              GameTooltip:SetOwner(raidFrame, "ANCHOR_RIGHT")
              GameTooltip:SetText(raid.name, 1, 1, 1);
              if raid.modifiedInstanceInfo and raid.modifiedInstanceInfo.description then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(raid.modifiedInstanceInfo.description)
              end
              GameTooltip:Show()
            end)
            raidFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            raidFrame.text:SetText(raid.short and raid.short or raid.name)
            raidFrame:Show()
            rowCount = rowCount + 1

            -- Difficulties
            Utils:TableForEach(raidFrame.difficultyFrames, function(f) f:Hide() end)
            Utils:TableForEach(difficulties, function(difficulty, difficultyIndex)
              local difficultyFrame = raidFrame.difficultyFrames[difficultyIndex]
              if not difficultyFrame then
                difficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, raidFrame)
                difficultyFrame:SetHeight(Constants.sizes.row)
                difficultyFrame.text = difficultyFrame:CreateFontString(difficultyFrame:GetName() .. "Text", "OVERLAY")
                difficultyFrame.text:SetPoint("TOPLEFT", difficultyFrame, "TOPLEFT", Constants.sizes.padding, -3)
                difficultyFrame.text:SetPoint("BOTTOMRIGHT", difficultyFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
                difficultyFrame.text:SetJustifyH("LEFT")
                difficultyFrame.text:SetFontObject("GameFontHighlight_NoShadow")
                raidFrame.difficultyFrames[difficultyIndex] = difficultyFrame
              end

              difficultyFrame:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(difficulty.name, 1, 1, 1);
                GameTooltip:Show()
              end)
              difficultyFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
              difficultyFrame:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
              difficultyFrame:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
              difficultyFrame.text:SetText(difficulty.short and difficulty.short or difficulty.name)
              difficultyFrame:Show()
              rowCount = rowCount + 1
            end)
          end)
        end
      end
    end
  end

  do -- Body
    local characterAnchor = self.window.body.scrollparent.scrollchild
    self.window.characterFrames = self.window.characterFrames or {}
    Utils:TableForEach(self.window.characterFrames, function(f) f:Hide() end)
    Utils:TableForEach(characters, function(character, characterIndex)
      local rowCount = 0
      local characterFrame = self.window.characterFrames[characterIndex]
      if not characterFrame then
        characterFrame = CreateFrame("Frame", "$parentCharacterColumn" .. characterIndex, self.window.body.scrollparent.scrollchild)
        characterFrame.infoFrames = {}
        characterFrame.dungeonFrames = {}
        characterFrame.affixFrames = {}
        characterFrame.raidFrames = {}
        characterFrame.affixHeaderFrame = CreateFrame("Frame", "$parentAffixes", characterFrame)
        Utils:SetBackgroundColor(characterFrame.affixHeaderFrame, 0, 0, 0, 0.3)
        self.window.characterFrames[characterIndex] = characterFrame
      end

      if characterIndex == 1 then
        characterFrame:SetPoint("TOPLEFT", characterAnchor, "TOPLEFT")
        characterFrame:SetPoint("BOTTOMLEFT", characterAnchor, "BOTTOMLEFT")
      else
        characterFrame:SetPoint("TOPLEFT", characterAnchor, "TOPRIGHT")
        characterFrame:SetPoint("BOTTOMLEFT", characterAnchor, "BOTTOMRIGHT")
      end
      characterAnchor = characterFrame

      Utils:SetBackgroundColor(characterFrame, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
      characterFrame:SetWidth(CHARACTER_WIDTH)
      characterFrame:Show()

      do -- Info
        Utils:TableForEach(characterFrame.infoFrames, function(f) f:Hide() end)
        Utils:TableForEach(characterInfo, function(info, infoIndex)
          local infoFrame = characterFrame.infoFrames[infoIndex]
          if not infoFrame then
            infoFrame = CreateFrame(info.OnClick and "Button" or "Frame", "$parentInfo" .. infoIndex, characterFrame)
            infoFrame.text = infoFrame:CreateFontString(infoFrame:GetName() .. "Text", "OVERLAY")
            infoFrame.text:SetPoint("LEFT", infoFrame, "LEFT", Constants.sizes.padding, 0)
            infoFrame.text:SetPoint("RIGHT", infoFrame, "RIGHT", -Constants.sizes.padding, 0)
            infoFrame.text:SetJustifyH("CENTER")
            infoFrame.text:SetFontObject("GameFontHighlight_NoShadow")
            if info.backgroundColor then
              Utils:SetBackgroundColor(infoFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
            end
            characterFrame.infoFrames[infoIndex] = infoFrame
          end

          if info.value then
            infoFrame.text:SetText(info.value(character))
          end

          if info.OnEnter then
            infoFrame:SetScript("OnEnter", function()
              GameTooltip:ClearAllPoints()
              GameTooltip:ClearLines()
              GameTooltip:SetOwner(infoFrame, "ANCHOR_RIGHT")
              info.OnEnter(character)
              GameTooltip:Show()
              if not info.backgroundColor then
                Utils:SetBackgroundColor(infoFrame, 1, 1, 1, 0.05)
              end
            end)
            infoFrame:SetScript("OnLeave", function()
              GameTooltip:Hide()
              if not info.backgroundColor then
                Utils:SetBackgroundColor(infoFrame, 1, 1, 1, 0)
              end
            end)
          else
            if not info.backgroundColor then
              infoFrame:SetScript("OnEnter", function()
                Utils:SetBackgroundColor(infoFrame, 1, 1, 1, 0.05)
              end)
              infoFrame:SetScript("OnLeave", function()
                Utils:SetBackgroundColor(infoFrame, 1, 1, 1, 0)
              end)
            end
          end

          if info.OnClick then
            infoFrame:SetScript("OnClick", function()
              info.OnClick(character)
            end)
          end

          infoFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
          infoFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
          infoFrame:SetHeight(Constants.sizes.row)
          infoFrame:Show()
          rowCount = rowCount + 1
        end)
      end


      do -- Affix headers
        characterFrame.affixHeaderFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
        characterFrame.affixHeaderFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
        characterFrame.affixHeaderFrame:SetHeight(Constants.sizes.row)
        Utils:TableForEach(characterFrame.affixFrames, function(f) f:Hide() end)
        Utils:TableForEach(affixes, function(affix, affixIndex)
          local affixFrame = characterFrame.affixFrames[affixIndex]
          if not affixFrame then
            affixFrame = CreateFrame("Frame", "$parentAffix" .. affixIndex, characterFrame.affixHeaderFrame)
            affixFrame.Icon = affixFrame:CreateTexture(affixFrame:GetName() .. "Icon", "ARTWORK")
            affixFrame.Icon:SetSize(16, 16)
            affixFrame.Icon:SetPoint("CENTER", affixFrame, "CENTER", 0, 0)
            characterFrame.affixFrames[affixIndex] = affixFrame
          end

          if affixIndex == 1 then
            affixFrame:SetPoint("TOPLEFT", characterFrame.affixHeaderFrame, "TOPLEFT")
            affixFrame:SetPoint("BOTTOMRIGHT", characterFrame.affixHeaderFrame, "BOTTOM")
          else
            affixFrame:SetPoint("TOPLEFT", characterFrame.affixHeaderFrame, "TOP")
            affixFrame:SetPoint("BOTTOMRIGHT", characterFrame.affixHeaderFrame, "BOTTOMRIGHT")
          end

          affixFrame:Show()
          affixFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(affixFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(affix.name, 1, 1, 1, 1, true);
            GameTooltip:AddLine(affix.description, nil, nil, nil, true);
            GameTooltip:Show()
          end)
          affixFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
          affixFrame.Icon:SetTexture(affix.fileDataID)

          local active = false
          if currentAffixes and Utils:TableCount(currentAffixes) > 0 then
            Utils:TableForEach(currentAffixes, function(currentAffix)
              if currentAffix.id == affix.id then
                active = true
              end
            end)
          end
          if active then
            affixFrame:SetAlpha(1)
          else
            affixFrame:SetAlpha(0.2)
          end
        end)
        rowCount = rowCount + 1
      end

      do -- Dungeons
        Utils:TableForEach(characterFrame.dungeonFrames, function(f) f:Hide() end)
        Utils:TableForEach(dungeons, function(dungeon, dungeonIndex)
          local dungeonFrame = characterFrame.dungeonFrames[dungeonIndex]
          if not dungeonFrame then
            dungeonFrame = CreateFrame("Frame", "$parentDungeons" .. dungeonIndex, characterFrame)
            dungeonFrame.affixFrames = {}
            characterFrame.dungeonFrames[dungeonIndex] = dungeonFrame
          end

          local characterDungeon = Utils:TableGet(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
          local overallScoreColor = HIGHLIGHT_FONT_COLOR
          if characterDungeon and characterDungeon.affixScores and Utils:TableCount(characterDungeon.affixScores) > 0 then
            if characterDungeon.rating then
              local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(characterDungeon.rating);
              if color ~= nil then
                overallScoreColor = color
              end
            end
          end

          dungeonFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(dungeonFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(dungeon.name, 1, 1, 1);
            if characterDungeon and characterDungeon.affixScores and Utils:TableCount(characterDungeon.affixScores) > 0 then
              if (characterDungeon.rating) then
                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(overallScoreColor:WrapTextInColorCode(characterDungeon.rating)), GREEN_FONT_COLOR);
              end
              for _, affixInfo in ipairs(characterDungeon.affixScores) do
                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name));
                GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level), HIGHLIGHT_FONT_COLOR);
                if (affixInfo.overTime) then
                  if (affixInfo.durationSec >= SECONDS_PER_HOUR) then
                    GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR);
                  else
                    GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR);
                  end
                else
                  if (affixInfo.durationSec >= SECONDS_PER_HOUR) then
                    GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, true), HIGHLIGHT_FONT_COLOR);
                  else
                    GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, false), HIGHLIGHT_FONT_COLOR);
                  end
                end
              end
            end
            GameTooltip:Show()
            Utils:SetBackgroundColor(dungeonFrame, 1, 1, 1, 0.05)
          end)
          dungeonFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            Utils:SetBackgroundColor(dungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
          end)

          Utils:SetBackgroundColor(dungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
          dungeonFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
          dungeonFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
          dungeonFrame:SetHeight(Constants.sizes.row)
          dungeonFrame:Show()
          rowCount = rowCount + 1

          Utils:TableForEach(dungeonFrame.affixFrames, function(f) f:Hide() end)
          Utils:TableForEach(affixes, function(affix, affixIndex)
            local affixFrame = dungeonFrame.affixFrames[affixIndex]
            if not affixFrame then
              affixFrame = CreateFrame("Frame", "$parentAffix" .. affixIndex, dungeonFrame)
              affixFrame.text = affixFrame:CreateFontString(affixFrame:GetName() .. "Text", "OVERLAY")
              affixFrame.text:SetPoint("TOPLEFT", affixFrame, "TOPLEFT", 1, -1)
              affixFrame.text:SetPoint("BOTTOMRIGHT", affixFrame, "BOTTOM", -1, 1)
              affixFrame.text:SetFontObject("GameFontHighlight_NoShadow")
              affixFrame.text:SetJustifyH("RIGHT")
              affixFrame.tier = affixFrame:CreateFontString(affixFrame:GetName() .. "Tier", "OVERLAY")
              affixFrame.tier:SetPoint("TOPLEFT", affixFrame, "TOP", 1, -1)
              affixFrame.tier:SetPoint("BOTTOMRIGHT", affixFrame, "BOTTOMRIGHT", -1, 1)
              affixFrame.tier:SetFontObject("GameFontHighlight_NoShadow")
              affixFrame.tier:SetJustifyH("LEFT")
              dungeonFrame.affixFrames[affixIndex] = affixFrame
            end

            local level = "-"
            local levelColor = "ffffffff"
            local tier = ""

            if characterDungeon == nil or characterDungeon.affixScores == nil then
              level = "-"
              levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
            else
              local affixScore = Utils:TableGet(characterDungeon.affixScores, "id", affix.id)
              if affixScore then
                level = affixScore.level

                if affixScore.durationSec <= dungeon.time * 0.6 then
                  tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                elseif affixScore.durationSec <= dungeon.time * 0.8 then
                  tier = "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                elseif affixScore.durationSec <= dungeon.time then
                  tier = "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
                end

                if tier == "" then
                  levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                elseif Data.db.global.showAffixColors then
                  local scoreColor = C_ChallengeMode.GetSpecificDungeonScoreRarityColor(affixScore.score)
                  if scoreColor ~= nil then
                    levelColor = scoreColor:GenerateHexColor()
                  else
                    levelColor = overallScoreColor:GenerateHexColor()
                  end
                end
              end
            end

            if Data.db.global.showTiers then
              affixFrame.text:SetPoint("BOTTOMRIGHT", affixFrame, "BOTTOM", -1, 1)
              affixFrame.text:SetJustifyH("RIGHT")
              affixFrame.tier:Show()
            else
              affixFrame.text:SetPoint("BOTTOMRIGHT", affixFrame, "BOTTOMRIGHT", -1, 1)
              affixFrame.text:SetJustifyH("CENTER")
              affixFrame.tier:Hide()
            end

            if affixIndex == 1 then
              affixFrame:SetPoint("TOPLEFT", dungeonFrame, "TOPLEFT")
              affixFrame:SetPoint("BOTTOMRIGHT", dungeonFrame, "BOTTOM")
            else
              affixFrame:SetPoint("TOPLEFT", dungeonFrame, "TOP")
              affixFrame:SetPoint("BOTTOMRIGHT", dungeonFrame, "BOTTOMRIGHT")
            end

            affixFrame.text:SetText("|c" .. levelColor .. level .. "|r")
            affixFrame.tier:SetText(tier)
            affixFrame:Show()
          end)
        end)
      end

      do -- Raids
        Utils:TableForEach(characterFrame.raidFrames, function(f) f:Hide() end)
        if Data.db.global.raids.enabled then
          Utils:TableForEach(raids, function(raid, raidIndex)
            local raidFrame = characterFrame.raidFrames[raidIndex]
            if not raidFrame then
              raidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, characterFrame)
              raidFrame.difficultyFrames = {}
              raidFrame.headerFrame = CreateFrame("Frame", "$parentHeader" .. raidIndex, characterFrame)
              raidFrame.headerFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
              raidFrame.headerFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
              raidFrame.headerFrame:SetHeight(Constants.sizes.row)
              raidFrame.headerFrame:Show()
              Utils:SetBackgroundColor(raidFrame.headerFrame, 0, 0, 0, 0.3)
              characterFrame.raidFrames[raidIndex] = raidFrame
            end

            raidFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
            raidFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
            raidFrame:Show()
            rowCount = rowCount + 1

            -- Difficulties
            Utils:TableForEach(raidFrame.difficultyFrames, function(f) f:Hide() end)
            Utils:TableForEach(difficulties, function(difficulty, difficultyIndex)
              local difficultyFrame = raidFrame.difficultyFrames[difficultyIndex]
              if not difficultyFrame then
                difficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, raidFrame)
                difficultyFrame.encounterFrames = {}
                raidFrame.difficultyFrames[difficultyIndex] = difficultyFrame
              end

              Utils:SetBackgroundColor(difficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
              difficultyFrame:SetPoint("TOPLEFT", characterFrame, "TOPLEFT", 0, -rowCount * Constants.sizes.row)
              difficultyFrame:SetPoint("TOPRIGHT", characterFrame, "TOPRIGHT", 0, -rowCount * Constants.sizes.row)
              difficultyFrame:SetHeight(Constants.sizes.row)
              difficultyFrame:Show()
              rowCount = rowCount + 1
              difficultyFrame:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(difficultyFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true);
                GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name));
                if character.raids.savedInstances ~= nil then
                  local savedInstance = Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                  end)
                  if savedInstance ~= nil then
                    GameTooltip:AddLine(format("Expires: |cffffffff%s|r", date("%c", savedInstance.expires)))
                  end
                end
                GameTooltip:AddLine(" ")
                Utils:TableForEach(raid.encounters, function(encounter, encounterIndex)
                  local color = LIGHTGRAY_FONT_COLOR
                  if character.raids.savedInstances then
                    local savedInstance = Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                      return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                    end)
                    if savedInstance ~= nil then
                      local savedEncounter = Utils:TableFind(savedInstance.encounters, function(enc)
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
                Utils:SetBackgroundColor(difficultyFrame, 1, 1, 1, 0.05)
              end)
              difficultyFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
                Utils:SetBackgroundColor(difficultyFrame, 1, 1, 1, 0)
              end)

              -- Encounters
              local anchorEncounter = difficultyFrame
              Utils:TableForEach(difficultyFrame.encounterFrames, function(f) f:Hide() end)
              Utils:TableForEach(raid.encounters, function(encounter, encounterIndex)
                local encounterFrame = difficultyFrame.encounterFrames[encounterIndex]
                if not encounterFrame then
                  encounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, difficultyFrame)
                  difficultyFrame.encounterFrames[encounterIndex] = encounterFrame
                end

                local color = {r = 1, g = 1, b = 1}
                local alpha = 0.1
                local size = CHARACTER_WIDTH
                size = size - Constants.sizes.padding                     -- left/right cell padding
                size = size - (Utils:TableCount(raid.encounters) - 1) * 4 -- gaps
                size = size / Utils:TableCount(raid.encounters)           -- box sizes

                if character.raids.savedInstances then
                  local savedInstance = Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                  end)
                  if savedInstance then
                    local savedEncounter = Utils:TableFind(savedInstance.encounters, function(savedEncounter)
                      return savedEncounter.instanceEncounterID == encounter.instanceEncounterID and savedEncounter.isKilled == true
                    end)
                    if savedEncounter then
                      color = UNCOMMON_GREEN_COLOR
                      if Data.db.global.raids.colors then
                        color = difficulty.color
                      end
                      alpha = 0.5
                    end
                  end
                end

                Utils:SetBackgroundColor(encounterFrame, color.r, color.g, color.b, alpha)
                if encounterIndex == 1 then
                  encounterFrame:SetPoint("LEFT", anchorEncounter, "LEFT", Constants.sizes.padding / 2, 0)
                else
                  encounterFrame:SetPoint("LEFT", anchorEncounter, "RIGHT", Constants.sizes.padding / 2, 0)
                end
                encounterFrame:SetSize(size, Constants.sizes.row - 12)
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
  self.window.body.scrollparent.scrollchild:SetSize(Utils:TableCount(characters) * CHARACTER_WIDTH, self.window.body.scrollparent:GetHeight())
  Window:SetWindowScale(Data.db.global.interface.windowScale / 100)
  Window:SetWindowBackgroundColor(Data.db.global.interface.windowColor)

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
  if Utils:TableCount(characters) <= 0 then
    if not Data.db.global.showZeroRatedCharacters and Utils:TableCount(Data:GetCharacters(true)) > 0 then
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

  if Utils:TableCount(characters) == 1 then
    self.window.titlebar.title:Hide()
  else
    self.window.titlebar.title:Show()
  end
end

function Module:SetupButtons()
  local seasonID = Data:GetCurrentSeason()
  local difficulties = Data:GetRaidDifficulties(true)

  self.window.titlebar.SettingsButton = CreateFrame("Button", "$parentSettingsButton", self.window.titlebar)
  self.window.titlebar.SettingsButton:SetPoint("RIGHT", self.window.titlebar.CloseButton, "LEFT", 0, 0)
  self.window.titlebar.SettingsButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
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
  self.window.titlebar.SettingsButton.Icon:SetTexture(Constants.media.IconSettings)
  self.window.titlebar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.SettingsButton.Dropdown = CreateFrame("Frame", self.window.titlebar.SettingsButton:GetName() .. "Dropdown", self.window.titlebar, "UIDropDownMenuTemplate")
  self.window.titlebar.SettingsButton.Dropdown:SetPoint("CENTER", self.window.titlebar.SettingsButton, "CENTER", 0, -6)
  self.window.titlebar.SettingsButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.SettingsButton.Dropdown, Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.SettingsButton.Dropdown,
    function(frame, level, subMenuName)
      if subMenuName == "raiddifficulties" then
        Utils:TableForEach(difficulties, function(difficulty)
          UIDropDownMenu_AddButton(
            {
              text = difficulty.name,
              value = difficulty.id,
              checked = Data.db.global.raids.hiddenDifficulties and not Data.db.global.raids.hiddenDifficulties[difficulty.id],
              keepShownOnClick = true,
              func = function(button, arg1, arg2, checked)
                Data.db.global.raids.hiddenDifficulties[button.value] = not checked
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
              checked = Data.db.global.interface.windowScale == i,
              keepShownOnClick = false,
              func = function(button)
                Data.db.global.interface.windowScale = button.value
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
          checked = Data.db.global.showAffixHeader,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show the weekly affixes",
          tooltipText = "The affixes will be shown at the top.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.showAffixHeader = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Show characters with zero rating",
          checked = Data.db.global.showZeroRatedCharacters,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show characters with zero rating",
          tooltipText = "Too many alts?",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.showZeroRatedCharacters = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Show realm names",
          checked = Data.db.global.showRealms,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show realm names",
          tooltipText = "One big party!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.showRealms = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Use Raider.io rating colors",
          checked = Data.db.global.useRIOScoreColor,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Use Raider.io rating colors",
          tooltipText = "So many colors!",
          tooltipOnButton = true,
          disabled = type(_G.RaiderIO) == "nil",
          func = function(button, arg1, arg2, checked)
            Data.db.global.useRIOScoreColor = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Automatic Announcements", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Announce instance resets",
          checked = Data.db.global.announceResets,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Announce instance resets",
          tooltipText = "Let others in your group know when you've reset the instances.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.announceResets = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Announce new keystones (Party)",
          checked = Data.db.global.announceKeystones.autoParty,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "New keystones (Party)",
          tooltipText = "Announce to your party when you loot a new keystone.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.announceKeystones.autoParty = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Announce new keystones (Guild)",
          checked = Data.db.global.announceKeystones.autoGuild,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "New keystones (Guild)",
          tooltipText = "Announce to your guild when you loot a new keystone.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.announceKeystones.autoGuild = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show raid progress",
          checked = Data.db.global.raids and Data.db.global.raids.enabled,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show raid progress",
          tooltipText = "Because Mythic Plus ain't enough!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.raids.enabled = checked
            self:Render()
          end,
          hasArrow = true,
          menuList = "raiddifficulties"
        })
        if seasonID == 12 then
          UIDropDownMenu_AddButton({
            text = "Show |cFF00FFFFAwakened|r raids only",
            checked = Data.db.global.raids and Data.db.global.raids.modifiedInstanceOnly,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show |cFF00FFFFAwakened|r raids only",
            tooltipText = "It's time to move on!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.raids.modifiedInstanceOnly = checked
              self:Render()
            end
          })
        end
        UIDropDownMenu_AddButton({
          text = "Show difficulty colors",
          checked = Data.db.global.raids and Data.db.global.raids.colors,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show difficulty colors",
          tooltipText = "Argharhggh! So much greeeen!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.raids.colors = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show timed icons",
          checked = Data.db.global.showTiers,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show timed icons",
          tooltipText = "Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.showTiers = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({
          text = "Show score colors",
          checked = Data.db.global.showAffixColors,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show score colors",
          tooltipText = "Show some colors!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.showAffixColors = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "PvP", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show PvP progress",
          checked = Data.db.global.pvp and Data.db.global.pvp.enabled,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show PvP progress",
          tooltipText = "Because Mythic Plus ain't enough!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.pvp.enabled = checked
            self:Render()
          end
        })
        UIDropDownMenu_AddButton({text = "Minimap", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Show the minimap button",
          checked = not Data.db.global.minimap.hide,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Show the minimap button",
          tooltipText = "It does get crowded around the minimap sometimes.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.minimap.hide = not checked
            self.Libs.LDBIcon:Refresh("AlterEgo", Data.db.global.minimap)
          end
        })
        UIDropDownMenu_AddButton({
          text = "Lock the minimap button",
          checked = Data.db.global.minimap.lock,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Lock the minimap button",
          tooltipText = "No more moving the button around accidentally!",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.minimap.lock = checked
            self.Libs.LDBIcon:Refresh("AlterEgo", Data.db.global.minimap)
          end
        })
        UIDropDownMenu_AddButton({text = "Interface", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Window color",
          keepShownOnClick = false,
          notCheckable = true,
          hasColorSwatch = true,
          r = Data.db.global.interface.windowColor.r,
          g = Data.db.global.interface.windowColor.g,
          b = Data.db.global.interface.windowColor.b,
          -- notClickable = true,
          hasOpacity = false,
          func = UIDropDownMenuButton_OpenColorPicker,
          swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB();
            Data.db.global.interface.windowColor.r = r
            Data.db.global.interface.windowColor.g = g
            Data.db.global.interface.windowColor.b = b
            self:SetWindowBackgroundColor(Data.db.global.interface.windowColor)
            -- Utils:SetBackgroundColor(self.window, Data.db.global.interface.windowColor.r, Data.db.global.interface.windowColor.g, Data.db.global.interface.windowColor.b, Data.db.global.interface.windowColor.a)
          end,
          cancelFunc = function(color)
            Data.db.global.interface.windowColor.r = color.r
            Data.db.global.interface.windowColor.g = color.g
            Data.db.global.interface.windowColor.b = color.b
            self:SetWindowBackgroundColor(Data.db.global.interface.windowColor)
            -- Utils:SetBackgroundColor(self.window, Data.db.global.interface.windowColor.r, Data.db.global.interface.windowColor.g, Data.db.global.interface.windowColor.b, Data.db.global.interface.windowColor.a)
          end
        })
        UIDropDownMenu_AddButton({text = "Window scale", notCheckable = true, hasArrow = true, menuList = "windowscale"})
      end
    end,
    "MENU"
  )
  self.window.titlebar.SettingsButton:SetScript("OnEnter", function()
    self.window.titlebar.SettingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    Utils:SetBackgroundColor(self.window.titlebar.SettingsButton, 1, 1, 1, 0.05)
    GameTooltip:ClearAllPoints()
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.window.titlebar.SettingsButton, "ANCHOR_TOP")
    GameTooltip:SetText("Settings", 1, 1, 1, 1, true);
    GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:Show()
  end)
  self.window.titlebar.SettingsButton:SetScript("OnLeave", function()
    self.window.titlebar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    Utils:SetBackgroundColor(self.window.titlebar.SettingsButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  self.window.titlebar.SortingButton = CreateFrame("Button", "$parentSorting", self.window.titlebar)
  self.window.titlebar.SortingButton:SetPoint("RIGHT", self.window.titlebar.SettingsButton, "LEFT", 0, 0)
  self.window.titlebar.SortingButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
  self.window.titlebar.SortingButton.HandlesGlobalMouseEvent = function()
    return true
  end
  self.window.titlebar.SortingButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, self.window.titlebar.SortingButton.Dropdown)
  end)
  self.window.titlebar.SortingButton.Icon = self.window.titlebar:CreateTexture(self.window.titlebar.SortingButton:GetName() .. "Icon", "ARTWORK")
  self.window.titlebar.SortingButton.Icon:SetPoint("CENTER", self.window.titlebar.SortingButton, "CENTER")
  self.window.titlebar.SortingButton.Icon:SetSize(16, 16)
  self.window.titlebar.SortingButton.Icon:SetTexture(Constants.media.IconSorting)
  self.window.titlebar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.SortingButton.Dropdown = CreateFrame("Frame", self.window.titlebar.SortingButton:GetName() .. "Dropdown", self.window.titlebar.SortingButton, "UIDropDownMenuTemplate")
  self.window.titlebar.SortingButton.Dropdown:SetPoint("CENTER", self.window.titlebar.SortingButton, "CENTER", 0, -6)
  self.window.titlebar.SortingButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.SortingButton.Dropdown, Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.SortingButton.Dropdown,
    function()
      for _, option in ipairs(Constants.sortingOptions) do
        UIDropDownMenu_AddButton({
          text = option.text,
          checked = Data.db.global.sorting == option.value,
          arg1 = option.value,
          func = function(button, arg1, arg2, checked)
            Data.db.global.sorting = arg1
            self:Render()
          end
        })
      end
    end,
    "MENU"
  )
  self.window.titlebar.SortingButton:SetScript("OnEnter", function()
    self.window.titlebar.SortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    Utils:SetBackgroundColor(self.window.titlebar.SortingButton, 1, 1, 1, 0.05)
    GameTooltip:ClearAllPoints()
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.window.titlebar.SortingButton, "ANCHOR_TOP")
    GameTooltip:SetText("Sorting", 1, 1, 1, 1, true);
    GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:Show()
  end)
  self.window.titlebar.SortingButton:SetScript("OnLeave", function()
    self.window.titlebar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    Utils:SetBackgroundColor(self.window.titlebar.SortingButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  self.window.titlebar.CharactersButton = CreateFrame("Button", "$parentCharacters", self.window.titlebar)
  self.window.titlebar.CharactersButton:SetPoint("RIGHT", self.window.titlebar.SortingButton, "LEFT", 0, 0)
  self.window.titlebar.CharactersButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
  self.window.titlebar.CharactersButton.HandlesGlobalMouseEvent = function()
    return true
  end
  self.window.titlebar.CharactersButton:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, self.window.titlebar.CharactersButton.Dropdown)
  end)
  self.window.titlebar.CharactersButton.Icon = self.window.titlebar:CreateTexture(self.window.titlebar.CharactersButton:GetName() .. "Icon", "ARTWORK")
  self.window.titlebar.CharactersButton.Icon:SetPoint("CENTER", self.window.titlebar.CharactersButton, "CENTER")
  self.window.titlebar.CharactersButton.Icon:SetSize(14, 14)
  self.window.titlebar.CharactersButton.Icon:SetTexture(Constants.media.IconCharacters)
  self.window.titlebar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.CharactersButton.Dropdown = CreateFrame("Frame", self.window.titlebar.CharactersButton:GetName() .. "Dropdown", self.window.titlebar.CharactersButton, "UIDropDownMenuTemplate")
  self.window.titlebar.CharactersButton.Dropdown:SetPoint("CENTER", self.window.titlebar.CharactersButton, "CENTER", 0, -6)
  self.window.titlebar.CharactersButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.CharactersButton.Dropdown, Constants.sizes.titlebar.height)
  UIDropDownMenu_Initialize(
    self.window.titlebar.CharactersButton.Dropdown,
    function()
      local charactersUnfilteredList = Data:GetCharacters(true)
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
            Data.db.global.characters[arg1].enabled = checked
            self:Render()
          end
        })
      end
    end,
    "MENU"
  )
  self.window.titlebar.CharactersButton:SetScript("OnEnter", function()
    self.window.titlebar.CharactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    Utils:SetBackgroundColor(self.window.titlebar.CharactersButton, 1, 1, 1, 0.05)
    GameTooltip:ClearAllPoints()
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.window.titlebar.CharactersButton, "ANCHOR_TOP")
    GameTooltip:SetText("Characters", 1, 1, 1, 1, true);
    GameTooltip:AddLine("Enable/Disable your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:Show()
  end)
  self.window.titlebar.CharactersButton:SetScript("OnLeave", function()
    self.window.titlebar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    Utils:SetBackgroundColor(self.window.titlebar.CharactersButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
  self.window.titlebar.AnnounceButton = CreateFrame("Button", "$parentCharacters", self.window.titlebar)
  self.window.titlebar.AnnounceButton:SetPoint("RIGHT", self.window.titlebar.CharactersButton, "LEFT", 0, 0)
  self.window.titlebar.AnnounceButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
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
  self.window.titlebar.AnnounceButton.Icon:SetTexture(Constants.media.IconAnnounce)
  self.window.titlebar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
  self.window.titlebar.AnnounceButton.Dropdown = CreateFrame("Frame", self.window.titlebar.AnnounceButton:GetName() .. "Dropdown", self.window.titlebar.AnnounceButton, "UIDropDownMenuTemplate")
  self.window.titlebar.AnnounceButton.Dropdown:SetPoint("CENTER", self.window.titlebar.AnnounceButton, "CENTER", 0, -6)
  self.window.titlebar.AnnounceButton.Dropdown.Button:Hide()
  UIDropDownMenu_SetWidth(self.window.titlebar.AnnounceButton.Dropdown, Constants.sizes.titlebar.height)
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
        checked = Data.db.global.announceKeystones.multiline,
        keepShownOnClick = true,
        isNotRadio = true,
        tooltipTitle = "Announce keystones with multiple chat messages",
        tooltipText = "With too many alts it could get spammy though.",
        tooltipOnButton = true,
        func = function(button, arg1, arg2, checked)
          Data.db.global.announceKeystones.multiline = checked
        end
      })
      UIDropDownMenu_AddButton({
        text = "With character names",
        checked = Data.db.global.announceKeystones.multilineNames,
        keepShownOnClick = true,
        isNotRadio = true,
        tooltipTitle = "Add character names before each keystone",
        tooltipText = "Character names are only added if multiple chat messages is enabled.",
        tooltipOnButton = true,
        func = function(button, arg1, arg2, checked)
          Data.db.global.announceKeystones.multilineNames = checked
        end
      })
    end,
    "MENU"
  )
  self.window.titlebar.AnnounceButton:SetScript("OnEnter", function()
    self.window.titlebar.AnnounceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
    Utils:SetBackgroundColor(self.window.titlebar.AnnounceButton, 1, 1, 1, 0.05)
    GameTooltip:ClearAllPoints()
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self.window.titlebar.AnnounceButton, "ANCHOR_TOP")
    GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true);
    GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:Show()
  end)
  self.window.titlebar.AnnounceButton:SetScript("OnLeave", function()
    self.window.titlebar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    Utils:SetBackgroundColor(self.window.titlebar.AnnounceButton, 1, 1, 1, 0)
    GameTooltip:Hide()
  end)
end

function Module:GetCharacterInfo(unfiltered)
  local dungeons = Data:GetDungeons()
  local difficulties = Data:GetRaidDifficulties(true)
  local _, seasonDisplayID = Data:GetCurrentSeason()
  local result = {
    {
      label = CHARACTER,
      enabled = true,
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
        if not Data.db.global.showRealms then
          name = name .. format(" (%s)", character.info.realm)
        end
        GameTooltip:AddLine(name, 1, 1, 1);
        GameTooltip:AddLine(format("Level %d %s", character.info.level, character.info.race ~= nil and character.info.race.name or ""), 1, 1, 1);
        if character.info.factionGroup ~= nil and character.info.factionGroup.localized ~= nil then
          GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1);
        end
        if character.currencies ~= nil and Utils:TableCount(character.currencies) > 0 then
          local dataCurrencies = Data:GetCurrencies()
          local characterCurrencies = {}
          Utils:TableForEach(dataCurrencies, function(dataCurrency)
            local characterCurrency = Utils:TableGet(character.currencies, "id", dataCurrency.id)
            if characterCurrency then
              local icon = CreateSimpleTextureMarkup(characterCurrency.iconFileID or [[Interface\Icons\INV_Misc_QuestionMark]])
              local currencyLabel = format("%s %s", icon, characterCurrency.maxQuantity > 0 and math.min(characterCurrency.quantity, characterCurrency.maxQuantity) or characterCurrency.quantity)
              local currencyValue = characterCurrency.maxQuantity
              if characterCurrency.useTotalEarnedForMaxQty then
                if characterCurrency.maxQuantity > 0 then
                  currencyValue = format("%d/%d", characterCurrency.totalEarned, characterCurrency.maxQuantity)
                else
                  currencyValue = "No limit"
                end
              end
              table.insert(characterCurrencies, {
                currencyLabel,
                currencyValue
              })
            end
          end)
          if Utils:TableCount(characterCurrencies) > 0 then
            GameTooltip:AddLine(" ");
            GameTooltip:AddDoubleLine("Currencies:", "Maximum:")
            Utils:TableForEach(characterCurrencies, function(characterCurrency)
              GameTooltip:AddDoubleLine(characterCurrency[1], characterCurrency[2], 1, 1, 1, 1, 1, 1)
            end)
          end
        end
        if character.lastUpdate ~= nil then
          GameTooltip:AddLine(" ");
          GameTooltip:AddLine(format("Last update:\n|cffffffff%s|r", date("%c", character.lastUpdate)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        end
        if type(character.equipment) == "table" then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Click to View Equipment>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
      end,
      OnClick = function(character)
        local module = Core:GetModule("Equipment")
        if module then
          module:Open(character)
        end
        -- self:SendMessage("AE_EQUIPMENT_OPEN", character)
      end,
    },
    {
      label = "Realm",
      enabled = Data.db.global.showRealms,
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
    },
    {
      label = STAT_AVERAGE_ITEM_LEVEL,
      enabled = true,
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
            itemLevelTooltip = itemLevelTooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, character.info.ilvl.equipped);
          end
          if character.info.ilvl.level ~= nil then
            itemLevelTooltip = itemLevelTooltip .. FONT_COLOR_CODE_CLOSE
          end
          if character.info.ilvl.level ~= nil and character.info.ilvl.pvp ~= nil and floor(character.info.ilvl.level) ~= character.info.ilvl.pvp then
            itemLevelTooltip2 = itemLevelTooltip2 .. "\n\n" .. STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.info.ilvl.pvp)));
          end
        end
        GameTooltip:AddLine(itemLevelTooltip, 1, 1, 1);
        GameTooltip:AddLine(itemLevelTooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
      end,
    },
    {
      label = "Rating",
      enabled = true,
      value = function(character)
        local rating = "-"
        local ratingColor = LIGHTGRAY_FONT_COLOR
        if character.mythicplus.rating ~= nil then
          rating = tostring(character.mythicplus.rating)
          local color = Utils:GetRatingColor(character.mythicplus.rating, Data.db.global.useRIOScoreColor, false)
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
          numSeasonRuns = Utils:TableCount(character.mythicplus.runHistory)
        end
        if character.mythicplus.bestSeasonNumber ~= nil then
          bestSeasonNumber = character.mythicplus.bestSeasonNumber
        end
        if character.mythicplus.bestSeasonScore ~= nil then
          bestSeasonScore = character.mythicplus.bestSeasonScore
          local color = Utils:GetRatingColor(bestSeasonScore, Data.db.global.useRIOScoreColor, bestSeasonNumber ~= nil and bestSeasonNumber < seasonDisplayID)
          if color ~= nil then
            bestSeasonScoreColor = color
          end
        end
        if character.mythicplus.rating ~= nil then
          local color = Utils:GetRatingColor(character.mythicplus.rating, Data.db.global.useRIOScoreColor, false)
          if color ~= nil then
            ratingColor = color
          end
          rating = tostring(character.mythicplus.rating)
        end
        GameTooltip:AddLine("Mythic+ Rating", 1, 1, 1);
        GameTooltip:AddLine(format("Current Season: %s", ratingColor:WrapTextInColorCode(rating)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:AddLine(format("Runs this Season: %s", WHITE_FONT_COLOR:WrapTextInColorCode(tostring(numSeasonRuns))), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        if bestSeasonNumber ~= nil and bestSeasonScore ~= nil then
          local bestSeasonValue = bestSeasonScoreColor:WrapTextInColorCode(bestSeasonScore)
          if bestSeasonNumber > 0 then
            local season = LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(format("(Season %s)", bestSeasonNumber))
            bestSeasonValue = format("%s %s", bestSeasonValue, season)
          end
          GameTooltip:AddLine(format("Best Season: %s", bestSeasonValue), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        end
        if character.mythicplus.dungeons ~= nil and Utils:TableCount(character.mythicplus.dungeons) > 0 then
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
          numSeasonRuns = Utils:TableCount(character.mythicplus.runHistory)
        end
        if character.mythicplus.dungeons ~= nil
          and Utils:TableCount(character.mythicplus.dungeons) > 0
          and numSeasonRuns > 0
          and IsModifiedClick("CHATLINK")
        then
          local dungeonScoreDungeonTable = {};
          for _, dungeon in pairs(character.mythicplus.dungeons) do
            table.insert(dungeonScoreDungeonTable, dungeon.challengeModeID);
            table.insert(dungeonScoreDungeonTable, dungeon.finishedSuccess and 1 or 0);
            table.insert(dungeonScoreDungeonTable, dungeon.level);
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
          };
          local link = NORMAL_FONT_COLOR:WrapTextInColorCode(LinkUtil.FormatLink("dungeonScore", DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)));
          if not ChatEdit_InsertLink(link) then
            ChatFrame_OpenChat(link);
          end
        end
      end,
    },
    {
      label = "Current Keystone",
      enabled = true,
      value = function(character)
        local currentKeystone = LIGHTGRAY_FONT_COLOR:WrapTextInColorCode("-")
        if character.mythicplus.keystone ~= nil then
          local dungeon
          if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
            dungeon = Utils:TableGet(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
          elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
            dungeon = Utils:TableGet(dungeons, "mapId", character.mythicplus.keystone.mapId)
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
              ChatFrame_OpenChat(character.mythicplus.keystone.itemLink);
            end
          end
        end
      end,
    },
    {
      label = "Vault",
      enabled = true,
      value = function(character)
        if character.vault.hasAvailableRewards ~= nil and character.vault.hasAvailableRewards == true then
          return GREEN_FONT_COLOR:WrapTextInColorCode("Rewards")
        end
        return ""
      end,
      OnEnter = function(character)
        if character.vault.hasAvailableRewards ~= nil and character.vault.hasAvailableRewards == true then
          GameTooltip:AddLine("It's payday!", WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
          GameTooltip:AddLine(GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)
        end
      end,
      backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("Raids"),
      enabled = Data.db.global.raids.enabled,
      value = function(character)
        local value = {}
        if character.vault.slots ~= nil then
          local slots = Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.Raid
          end)
          if #slots > 0 then
            Utils:TableForEach(slots, function(slot)
              local name = "-"
              local nameColor = LIGHTGRAY_FONT_COLOR
              if slot.level > 0 then
                local dataDifficulty = Utils:TableGet(difficulties, "id", slot.level)
                if dataDifficulty then
                  name = dataDifficulty.abbr
                  if Data.db.global.raids.colors then
                    nameColor = dataDifficulty.color
                  end
                end
                if name == nil then
                  local difficultyName = GetDifficultyInfo(slot.level)
                  if difficultyName ~= nil then
                    name = tostring(difficultyName):sub(1, 1)
                  else
                    name = "?"
                  end
                end
                if nameColor == nil then
                  nameColor = UNCOMMON_GREEN_COLOR
                end
              end
              table.insert(value, nameColor:WrapTextInColorCode(name))
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
        if character.vault.slots ~= nil then
          local slots = Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.Raid
          end)
          for _, slot in ipairs(slots) do
            local color = LIGHTGRAY_FONT_COLOR
            local result = "Locked"
            if slot.progress >= slot.threshold then
              color = WHITE_FONT_COLOR
              if slot.exampleRewardLink ~= nil and slot.exampleRewardLink ~= "" then
                local itemLevel = GetDetailedItemLevelInfo(slot.exampleRewardLink)
                local difficultyName = GetDifficultyInfo(slot.level)
                local dataDifficulty = Utils:TableGet(difficulties, "id", slot.level)
                if dataDifficulty then
                  difficultyName = dataDifficulty.short and dataDifficulty.short or dataDifficulty.name
                end
                result = format("%s (%d+)", difficultyName, itemLevel)
              else
                result = "?"
              end
            end
            GameTooltip:AddDoubleLine(format("%d boss kills:", slot.threshold), result, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
          end

          local incompleteSlots = Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.Raid and slot.progress < slot.threshold
          end)
          if Utils:TableCount(incompleteSlots) > 0 then
            table.sort(incompleteSlots, function(a, b)
              return a.threshold < b.threshold
            end)
            GameTooltip:AddLine(" ")
            local tooltip = ""
            if Utils:TableCount(incompleteSlots) == Utils:TableCount(slots) then
              tooltip = format("Defeat %d bosses this week to unlock your first Great Vault reward.", incompleteSlots[1].threshold)
            else
              local diff = incompleteSlots[1].threshold - incompleteSlots[1].progress
              if diff == 1 then
                tooltip = format("Defeat %d more boss this week to unlock another Great Vault reward.", diff)
              else
                tooltip = format("Defeat another %d bosses this week to unlock another Great Vault reward.", diff)
              end
            end
            GameTooltip:AddLine(tooltip, nil, nil, nil, true)
          end
        end
      end,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("Dungeons"),
      enabled = true,
      value = function(character)
        local value = {}
        if character.vault.slots ~= nil then
          local slots = Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.Activities
          end)
          if #slots > 0 then
            Utils:TableForEach(slots, function(slot)
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
        local weeklyRuns = Utils:TableFilter(character.mythicplus.runHistory, function(run)
          return run.thisWeek == true
        end)
        local weeklyRunsCount = Utils:TableCount(weeklyRuns) or 0
        GameTooltip:AddLine("Vault Progress", 1, 1, 1);
        -- GameTooltip:AddLine("Runs this Week: " .. "|cffffffff" .. tostring(weeklyRunsCount) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

        if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
          local numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
          if numHeroic > 0 then
            GameTooltip:AddLine("Heroic runs this Week: " .. "|cffffffff" .. tostring(numHeroic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
          end
          local numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
          if numMythic > 0 then
            GameTooltip:AddLine("Mythic runs this Week: " .. "|cffffffff" .. tostring(numMythic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
          end
          local numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
          if numMythicPlus > 0 then
            GameTooltip:AddLine("Mythic+ runs this Week: " .. "|cffffffff" .. tostring(numMythicPlus) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
          end
        end
        GameTooltip_AddBlankLineToTooltip(GameTooltip);

        local lastCompletedActivityInfo, nextActivityInfo = Utils:GetActivitiesProgress(character);
        if not lastCompletedActivityInfo then
          GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
        else
          if nextActivityInfo then
            local globalString = (lastCompletedActivityInfo.index == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
            GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress));
          else
            GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
            local level, count = Utils:GetLowestLevelInTopDungeonRuns(character, lastCompletedActivityInfo.threshold);
            if level == WeeklyRewardsUtil.HeroicLevel then
              GameTooltip_AddBlankLineToTooltip(GameTooltip);
              GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
              GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_HEROIC_IMPROVE:format(count));
            else
              local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level);
              if nextLevel < 20 then
                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
                GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, nextLevel));
              end
            end
          end
        end

        if weeklyRunsCount > 0 then
          GameTooltip_AddBlankLineToTooltip(GameTooltip)
          table.sort(weeklyRuns, function(a, b)
            return a.level > b.level
          end)
          for runIndex, run in ipairs(weeklyRuns) do
            local threshold = Utils:TableFind(character.vault.slots, function(slot)
              return slot.type == Enum.WeeklyRewardChestThresholdType.Activities and runIndex == slot.threshold
            end)
            local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
            local dungeon = Utils:TableGet(dungeons, "challengeModeID", run.mapChallengeModeID)
            local color = WHITE_FONT_COLOR
            if threshold then
              color = GREEN_FONT_COLOR
            end
            if dungeon then
              GameTooltip:AddDoubleLine(dungeon.short and dungeon.short or dungeon.name, string.format("+%d (%d)", run.level, rewardLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
            end
            if runIndex == 8 then
              break
            end
          end
        end
      end,
    },
    {
      label = WHITE_FONT_COLOR:WrapTextInColorCode("PvP"),
      enabled = Data.db.global.pvp and Data.db.global.pvp.enabled == true,
      value = function(character)
        local text = "- / -"
        local textColor = LIGHTGRAY_FONT_COLOR
        if character.vault.slots ~= nil then
          local slots = Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.RankedPvP
          end)
          local completed = Utils:TableFilter(slots, function(slot)
            return slot.progress >= slot.threshold
          end)
          if #slots > 0 then
            text = format("%d / %d", #completed, #slots)
          end
          if #completed > 0 then
            if #slots == #completed then
              textColor = UNCOMMON_GREEN_COLOR
            else
              textColor = WHITE_FONT_COLOR
            end
          end
        end
        return textColor:WrapTextInColorCode(text)
      end,
      OnEnter = function(character)
        GameTooltip:AddLine("Vault Progress", 1, 1, 1)
        if character.vault.slots ~= nil then
          local slots = Utils:TableFilter(character.vault.slots, function(slot)
            return slot.type == Enum.WeeklyRewardChestThresholdType.RankedPvP
          end)
          Utils:TableForEach(slots, function(slot)
            local value = "Locked"
            local valueColor = LIGHTGRAY_FONT_COLOR
            if slot.progress >= slot.threshold then
              value = "Unlocked"
              valueColor = WHITE_FONT_COLOR
            end
            GameTooltip:AddDoubleLine(format("%d Honor:", slot.threshold), value, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, valueColor.r, valueColor.g, valueColor.b)
          end)
        end
      end,
    },
  }

  if unfiltered then
    return result
  end

  return Utils:TableFilter(result, function(info)
    return info.enabled
  end)
end
