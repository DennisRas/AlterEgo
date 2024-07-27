---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Utils = addon.Utils
local Constants = addon.Constants

---@class AE_Table
local Table = {}
addon.Table = Table

local TableCollection = {}

function Table:New(config)
  local frame = Utils:CreateScrollFrame(addonName .. "Table" .. (Utils:TableCount(TableCollection) + 1))
  frame.config = CreateFromMixins(
    {
      header = {
        enabled = true,
        sticky = false,
      },
      rows = {
        height = 22,
        highlight = true,
        striped = true
      },
      columns = {
        width = 100,
        highlight = false,
        striped = false
      },
      cells = {
        padding = 8,
        highlight = false
      },
      -- width = 400,
      -- height = 100,
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
      ---@type AE_TableData
      data = {
        columns = {},
        rows = {},
      },
    },
    config or {}
  )
  frame.rows = {}
  frame.data = frame.config.data

  ---Set the table data
  ---@param data AE_TableData
  function frame:SetData(data)
    frame.data = data
    frame:RenderTable()
  end

  function frame:SetRowHeight(height)
    self.config.rows.height = height
    self:Update()
  end

  function frame:RenderTable()
    local offsetY = 0
    local offsetX = 0

    Utils:TableForEach(frame.rows, function(rowFrame) rowFrame:Hide() end)
    Utils:TableForEach(frame.data.rows, function(row, rowIndex)
      local rowFrame = frame.rows[rowIndex]

      if not rowFrame then
        rowFrame = CreateFrame("Button", "$parentRow" .. rowIndex, frame.content)
        rowFrame.columns = {}
        frame.rows[rowIndex] = rowFrame
      end

      rowFrame.data = row
      rowFrame:SetPoint("TOPLEFT", frame.content, "TOPLEFT", 0, -offsetY)
      rowFrame:SetPoint("TOPRIGHT", frame.content, "TOPRIGHT", 0, -offsetY)
      rowFrame:SetHeight(frame.config.rows.height)
      rowFrame:SetScript("OnEnter", function() rowFrame:onEnterHandler(rowFrame) end)
      rowFrame:SetScript("OnLeave", function() rowFrame:onLeaveHandler(rowFrame) end)
      rowFrame:SetScript("OnClick", function() rowFrame:onClickHandler(rowFrame) end)
      rowFrame:Show()

      if frame.config.rows.striped and rowIndex % 2 == 1 then
        Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
      end

      if row.backgroundColor then
        Utils:SetBackgroundColor(rowFrame, row.backgroundColor.r, row.backgroundColor.g, row.backgroundColor.b, row.backgroundColor.a)
      end

      function rowFrame:onEnterHandler(arg1, arg2, arg3)
        Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
        if row.OnEnter then
          row:OnEnter(arg1, arg2, arg3)
        end
      end

      function rowFrame:onLeaveHandler(...)
        -- TODO: Fix stripe or original background color
        -- Let's make use of a new SetHightlightColor instead
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

      -- Sticky header
      if frame.config.header.sticky and rowIndex == 1 then
        if frame then
          rowFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -offsetY)
          rowFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -offsetY)
          -- rowFrame:SetToplevel(true)
          rowFrame:SetFrameStrata("HIGH")
        end
        if not row.backgroundColor then
          Utils:SetBackgroundColor(rowFrame, Constants.colors.sidebar.r, Constants.colors.sidebar.g, Constants.colors.sidebar.b, 1)
        end
      end

      offsetX = 0
      Utils:TableForEach(rowFrame.columns, function(columnFrame) columnFrame:Hide() end)
      Utils:TableForEach(row.columns, function(column, columnIndex)
        local columnFrame = rowFrame.columns[columnIndex]
        local columnConfig = frame.data.columns[columnIndex]
        local columnWidth = columnConfig and columnConfig.width or frame.config.columns.width
        local columnTextAlign = columnConfig and columnConfig.align or "LEFT"

        if not columnFrame then
          columnFrame = CreateFrame("Button", "$parentCol" .. columnIndex, rowFrame)
          columnFrame.text = columnFrame:CreateFontString("$parentText", "OVERLAY")
          columnFrame.text:SetFontObject("GameFontHighlight_NoShadow")
          rowFrame.columns[columnIndex] = columnFrame
        end

        columnFrame.data = column
        columnFrame:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", offsetX, 0)
        columnFrame:SetPoint("BOTTOMLEFT", rowFrame, "BOTTOMLEFT", offsetX, 0)
        columnFrame:SetWidth(columnWidth)
        columnFrame:SetScript("OnEnter", function() columnFrame:onEnterHandler(columnFrame) end)
        columnFrame:SetScript("OnLeave", function() columnFrame:onLeaveHandler(columnFrame) end)
        columnFrame:SetScript("OnClick", function() columnFrame:onClickHandler(columnFrame) end)
        columnFrame.text:SetWordWrap(false)
        columnFrame.text:SetJustifyH(columnTextAlign)
        columnFrame.text:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", frame.config.cells.padding, -frame.config.cells.padding)
        columnFrame.text:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT", -frame.config.cells.padding, frame.config.cells.padding)
        columnFrame.text:SetText(column.text)
        columnFrame:Show()

        if column.backgroundColor then
          Utils:SetBackgroundColor(columnFrame, column.backgroundColor.r, column.backgroundColor.g, column.backgroundColor.b, column.backgroundColor.a)
        end

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

        offsetX = offsetX + columnWidth
      end)

      offsetY = offsetY + frame.config.rows.height
    end)

    frame.content:SetSize(offsetX, offsetY)
  end

  frame:HookScript("OnSizeChanged", function() frame:RenderTable() end)
  frame:RenderTable()
  table.insert(TableCollection, frame)
  return frame;
end
