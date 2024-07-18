---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Utils = addon.Utils

---@class AE_Table
local Table = {}
addon.Table = Table

local TableCollection = {}

function Table:New(config)
  local frame = Utils:CreateScrollFrame(addonName .. "Table" .. (Utils:TableCount(TableCollection) + 1))
  -- local frame = CreateFrame("Frame", addonName .. "Table" .. (Utils:TableCount(TableCollection) + 1))
  frame.config = CreateFromMixins(
    {
      header = {
        enabled = true,
        sticky = true,
        -- firstRow = true
      },
      rows = {
        height = 22,
        highlight = true,
        striped = true
      },
      columns = {
        width = 100,
        highlight = false,
        striped = true
      },
      cells = {
        padding = 8,
        highlight = false
      },
      width = 600,
      height = 400,
      -- maxHeight = 0,
      -- maxWidth = 0,
      -- width = 600,
      -- rowHeight = 22,
      -- cellPadding = 8,
      -- frame = CreateFrame("Frame"),
      -- rowFrames = {},
      -- config = {
      --   width = 600,
      --   rowHeight = 22,
      --   cellPadding = 8,
      -- },
      data = {},
    },
    config or {}
  )
  -- frame.body = Utils:CreateScrollFrame("$parentBody", frame)
  frame:SetAllPoints()
  frame.rows = {}
  frame.data = frame.config.data

  ---Set the table data
  ---@param data AE_TableData
  function frame:SetData(data)
    frame.data = data
    frame:Update()
  end

  -- function frame:SetWidth(width)
  --   self.width = width
  --   self:Update()
  -- end

  -- function frame:SetRowHeight(height)
  --   self.config.rows.height = height
  --   self:Update()
  -- end

  -- function frame:GetSize()
  --   return self.frame:GetSize()
  -- end

  function frame:Update()
    local offsetY = 0
    local offsetX = 0

    frame:SetSize(frame.config.width, frame.config.height)

    Utils:TableForeach(frame.rows, function(rowFrame) rowFrame:Hide() end)
    Utils:TableForEach(frame.data.rows, function(row, rowIndex)
      -- for rowIndex = 1, #rows do
      -- local row = rows[rowIndex]
      -- local columns = rowData.cols
      local rowFrame = frame.rows[rowIndex]
      local rowAnchor = frame.config.headers.sticky and rowIndex == 1 and frame or frame.content

      if not rowFrame then
        rowFrame = CreateFrame("Button", "$parentRow" .. rowIndex, frame)
        rowFrame.columns = {}
        frame.rows[rowIndex] = rowFrame
      end

      rowFrame:SetPoint("TOPLEFT", rowAnchor, "TOPLEFT", 0, -offsetY)
      rowFrame:SetPoint("TOPRIGHT", rowAnchor, "TOPRIGHT", 0, -offsetY)
      rowFrame:SetHeight(frame.config.rows.height)
      rowFrame:Show()

      if frame.config.rows.striped and rowIndex % 2 == 1 then
        Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
      end

      function rowFrame:onEnterHandler(...)
        Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
        if row.OnEnter then
          row:OnEnter(...)
        end
      end

      function rowFrame:onLeaveHandler(...)
        -- TODO: Fix stripe
        Utils:SetBackgroundColor(rowFrame, 1, 1, 1, 0)
        if row.OnLeave then
          row:OnLeave(...)
        end
      end

      function rowFrame:onClickHandler(...)
        if row.OnClick then
          row:OnClick(...)
        end
      end

      -- if not rowFrame.colFrames then
      --   rowFrame.colFrames = {}
      -- end

      -- if rowIndex > 1 then
      --   rowFrame:SetPoint("TOPLEFT", rowFrames[rowIndex - 1], "BOTTOMLEFT", 0, 0)
      --   rowFrame:SetPoint("TOPRIGHT", rowFrames[rowIndex - 1], "BOTTOMRIGHT", 0, 0)

      --   if rowIndex % 2 == 1 then
      --     Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
      --   end
      -- else
      --   rowFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
      --   rowFrame:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", 0, 0)
      --   -- Utils:SetBackgroundColor(rowFrame, 0, 0, 0, .3)
      -- end

      offsetX = 0
      Utils:TableForeach(rowFrame.columns, function(columnFrame) columnFrame:Hide() end)
      Utils:TableForEach(row.columns, function(column, columnIndex)
        -- for colIndex = 1, #columns do
        -- local dataColumn = columns[columnIndex]
        local columnFrame = rowFrame.columns[columnIndex]
        local columnConfig = frame.data.columns[columnIndex]
        local columnWidth = columnConfig and columnConfig.width or frame.config.columns.width
        local columnTextAlign = columnConfig and columnConfig.align or "LEFT"

        if not columnFrame then
          columnFrame = CreateFrame("Button", "$parentCol" .. columnIndex, rowFrame)
          columnFrame.text = columnFrame:CreateFontString("$parentText", "OVERLAY")
          columnFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          -- colFrame.Text:SetAllPoints()
          rowFrame.colFrames[columnIndex] = columnFrame
        end

        columnFrame.data = column
        columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
        columnFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
        columnFrame:SetWidth(columnWidth)
        columnFrame.text:SetWordWrap(false)
        columnFrame.text:SetJustifyH(columnTextAlign)
        columnFrame.text:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", frame.config.cells.padding, -frame.config.cells.padding)
        columnFrame.text:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT", -frame.config.cells.padding, frame.config.cells.padding)
        columnFrame.text:SetText(column.text)
        columnFrame:Show()
        -- if columnIndex > 1 then
        --   columnFrame:SetPoint("LEFT", rowFrame.colFrames[columnIndex - 1], "RIGHT")
        -- else
        -- end

        function columnFrame:onEnterHandler(...)
          rowFrame:onEnterHandler(...)
          if column.onEnter then
            column.onEnter(...)
          end
        end

        function columnFrame:onLeaveHandler(...)
          rowFrame:onLeaveHandler(...)
          if column.onLeave then
            column.onLeave(...)
          end
          -- TODO: move tooltip stuff to the callback source
          if column.onEnter then
            GameTooltip:Hide()
          end
        end

        function columnFrame:onClickHandler(...)
          rowFrame:onClickHandler(...)
          if column.onClick then
            column:onClick(...)
          end
        end

        -- if column.OnEnter then
        --   columnFrame:SetScript("OnEnter", function()
        --     GameTooltip:ClearAllPoints()
        --     GameTooltip:ClearLines()
        --     GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
        --     column.OnEnter(column)
        --     GameTooltip:Show()
        --     if not column.backgroundColor then
        --       Utils:SetBackgroundColor(columnFrame, 1, 1, 1, 0.05)
        --     end
        --   end)
        --   columnFrame:SetScript("OnLeave", function()
        --     GameTooltip:Hide()
        --     if not column.backgroundColor then
        --       Utils:SetBackgroundColor(columnFrame, 1, 1, 1, 0)
        --     end
        --   end)
        -- else
        --   if not column.backgroundColor then
        --     columnFrame:SetScript("OnEnter", function()
        --       Utils:SetBackgroundColor(columnFrame, 1, 1, 1, 0.05)
        --     end)
        --     columnFrame:SetScript("OnLeave", function()
        --       Utils:SetBackgroundColor(columnFrame, 1, 1, 1, 0)
        --     end)
        --   end
        -- end

        -- if column.OnClick then
        --   columnFrame:SetScript("OnClick", column.OnClick)
        -- else
        --   columnFrame:SetScript("OnClick", nil)
        -- end

        if column.backgroundColor then
          Utils:SetBackgroundColor(columnFrame, column.backgroundColor.r, column.backgroundColor.g, column.backgroundColor.b, column.backgroundColor.a)
        end

        -- columnFrame:SetSize(self.data.columns[columnIndex].width, self.config.rowHeight)
        -- end

        columnFrame:SetScript("OnEnter", columnFrame.onEnterHandler)
        columnFrame:SetScript("OnLeave", columnFrame.onLeaveHandler)
        columnFrame:SetScript("OnClick", columnFrame.onClickHandler)
        offsetX = offsetX + columnWidth
      end)

      -- Hide extra unused columns
      -- local ce = #columns + 1
      -- while rowFrame.colFrames[ce] do
      --   rowFrame.colFrames[ce]:Hide()
      --   ce = ce + 1
      -- end
      -- end

      rowFrame:SetScript("OnEnter", rowFrame.onEnterHandler)
      rowFrame:SetScript("OnLeave", rowFrame.onLeaveHandler)
      rowFrame:SetScript("OnClick", rowFrame.onClickHandler)
      offsetY = offsetY + frame.config.rows.height
    end)

    -- Hide extra unused rows
    -- local re = #rows + 1
    -- while rowFrames[re] do
    --   rowFrames[re]:Hide()
    --   re = re + 1
    -- end

    local width = 0
    for colIndex = 1, #self.data.columns do
      width = width + self.data.columns[colIndex].width
    end

    -- self.frame:SetSize(width, #rows * self.config.rowHeight)
    frame.content:SetSize(offsetX, offsetY)
  end

  frame:SetScript("OnSizeChanged", frame.Update)
  table.insert(TableCollection, frame)
  return frame;
end
