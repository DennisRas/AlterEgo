local Table = {}
AlterEgo.Table = Table

function Table:New(config)
  local instance = {
    frame = CreateFrame("Frame"),
    rowFrames = {},
    config = {
      width = 600,
      rowHeight = 22,
      cellPadding = 8,
    },
    data = {
      columns = {
        -- [1] = {
        --     width = number,
        --     align? = string,
        -- }
      },
      rows = {
        -- [1] = {
        --     cols = {
        --         [1] = {
        --             text = string
        --         }
        --     }
        -- }
      }
    }
  }
  Mixin(instance.config, config or {})
  setmetatable(instance, self)
  self.__index = self
  return instance;
end

function Table:SetData(data)
  self.data = data
  self:Update()
end

function Table:SetWidth(width)
  self.width = width
  self:Update()
end

function Table:SetRowHeight(rowHeight)
  self.config.rowHeight = rowHeight
  self:Update()
end

function Table:GetSize()
  return self.frame:GetSize()
end

function Table:Update()
  local rows = self.data.rows
  local rowFrames = self.rowFrames
  for rowIndex = 1, #rows do
    local row = rows[rowIndex]
    local columns = row.cols
    local rowFrame = rowFrames[rowIndex]

    if rowFrame then
      rowFrame:Show()
    else
      rowFrame = CreateFrame("Button", "$parentRow" .. rowIndex, self.frame)
      rowFrames[rowIndex] = rowFrame
    end

    if not rowFrame.colFrames then
      rowFrame.colFrames = {}
    end

    if rowIndex > 1 then
      rowFrame:SetPoint("TOPLEFT", rowFrames[rowIndex - 1], "BOTTOMLEFT", 0, 0)
      rowFrame:SetPoint("TOPRIGHT", rowFrames[rowIndex - 1], "BOTTOMRIGHT", 0, 0)

      if rowIndex % 2 == 1 then
        AlterEgo:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
      end
    else
      rowFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
      rowFrame:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
      -- AlterEgo:SetBackgroundColor(rowFrame, 0, 0, 0, .3)
    end

    rowFrame:SetHeight(self.config.rowHeight)

    for colIndex = 1, #columns do
      local column = columns[colIndex]
      local colFrame = rowFrame.colFrames[colIndex]

      if colFrame then
        colFrame:Show()
      else
        colFrame = CreateFrame("Button", "$parentCol" .. colIndex, rowFrame)
        colFrame.Text = colFrame:CreateFontString("$parentText", "OVERLAY")
        colFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
        colFrame.Text:SetWordWrap(false)
        colFrame.Text:SetJustifyH(self.data.columns[colIndex].align or "LEFT")
        -- colFrame.Text:SetAllPoints()
        colFrame.Text:SetPoint("LEFT", colFrame, "LEFT", self.config.cellPadding, 0)
        colFrame.Text:SetPoint("RIGHT", colFrame, "RIGHT", -self.config.cellPadding, 0)
        rowFrame.colFrames[colIndex] = colFrame
      end

      if colIndex > 1 then
        colFrame:SetPoint("LEFT", rowFrame.colFrames[colIndex - 1], "RIGHT")
      else
        colFrame:SetPoint("LEFT", rowFrame, "LEFT")
      end

      if column.OnEnter then
        colFrame:SetScript("OnEnter", function()
          GameTooltip:ClearAllPoints()
          GameTooltip:ClearLines()
          GameTooltip:SetOwner(colFrame, "ANCHOR_RIGHT")
          column.OnEnter(column)
          GameTooltip:Show()
          if not column.backgroundColor then
            AlterEgo:SetBackgroundColor(colFrame, 1, 1, 1, 0.05)
          end
        end)
        colFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
          if not column.backgroundColor then
            AlterEgo:SetBackgroundColor(colFrame, 1, 1, 1, 0)
          end
        end)
      else
        if not column.backgroundColor then
          colFrame:SetScript("OnEnter", function()
            AlterEgo:SetBackgroundColor(colFrame, 1, 1, 1, 0.05)
          end)
          colFrame:SetScript("OnLeave", function()
            AlterEgo:SetBackgroundColor(colFrame, 1, 1, 1, 0)
          end)
        end
      end

      if column.OnClick then
        colFrame:SetScript("OnClick", column.OnClick)
      else
        colFrame:SetScript("OnClick", nil)
      end

      if column.backgroundColor then
        AlterEgo:SetBackgroundColor(colFrame, column.backgroundColor.r, column.backgroundColor.g, column.backgroundColor.b, column.backgroundColor.a)
      end

      colFrame:SetSize(self.data.columns[colIndex].width, self.config.rowHeight)
      colFrame.Text:SetText(column.text)
      colFrame:Show()
    end

    -- Hide extra unused columns
    local ce = #columns + 1
    while rowFrame.colFrames[ce] do
      rowFrame.colFrames[ce]:Hide()
      ce = ce + 1
    end
  end

  -- Hide extra unused rows
  local re = #rows + 1
  while rowFrames[re] do
    rowFrames[re]:Hide()
    re = re + 1
  end

  local width = 0
  for colIndex = 1, #self.data.columns do
    width = width + self.data.columns[colIndex].width
  end

  self.frame:SetSize(width, #rows * self.config.rowHeight)
end
