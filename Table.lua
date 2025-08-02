---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Table
local Table = {}
addon.Table = Table

Table.TableCollection = {}

function Table:New(config)
  local frame = CreateFrame("Frame", addonName .. "Table" .. (addon.Utils:TableCount(self.TableCollection) + 1))
  -- local frame = addon.Utils:CreateScrollFrame(addonName .. "Table" .. (addon.Utils:TableCount(TableCollection) + 1))
  frame.config = CreateFromMixins(
    {
      header = {
        enabled = true,
        sticky = false,
        height = 30,
      },
      rows = {
        height = 22,
        highlight = true,
        striped = true,
      },
      columns = {
        width = 100,
        highlight = false,
        striped = false,
      },
      cells = {
        padding = 8,
        highlight = false,
      },
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
  frame.scrollFrame = addon.Utils:CreateScrollFrame({
    name = "$parentScrollFrame",
    scrollSpeedVertical = frame.config.rows.height * 2,
  })

  ---Set the table data
  ---@param data AE_TableData
  function frame:SetData(data)
    self.data = data
    self:RenderTable()
  end

  ---Set the row height
  ---@param height number
  function frame:SetRowHeight(height)
    self.config.rows.height = height
    self:Update()
  end

  function frame:RenderTable()
    local offsetY = 0
    local offsetX = 0

    addon.Utils:TableForEach(frame.rows, function(rowFrame) rowFrame:Hide() end)
    addon.Utils:TableForEach(frame.data.rows, function(row, rowIndex)
      local rowFrame = frame.rows[rowIndex]
      local rowHeight = rowIndex == 1 and 30 or frame.config.rows.height
      local isStickyRow = false

      if not rowFrame then
        rowFrame = CreateFrame("Button", "$parentRow" .. rowIndex, frame)
        rowFrame.columns = {}
        frame.rows[rowIndex] = rowFrame
      end

      if rowIndex == 1 then
        if frame.config.header.enabled then
          rowHeight = frame.config.header.height
        end
        if frame.config.header.sticky then
          isStickyRow = true
        end
      end

      -- Sticky header
      if isStickyRow then
        rowFrame:SetParent(frame)
        rowFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        rowFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        if not row.backgroundColor then
          addon.Utils:SetBackgroundColor(rowFrame, 0, 0, 0, 0.3)
        end
      else
        rowFrame:SetParent(frame.scrollFrame.content)
        rowFrame:SetPoint("TOPLEFT", frame.scrollFrame.content, "TOPLEFT", 0, -offsetY)
        rowFrame:SetPoint("TOPRIGHT", frame.scrollFrame.content, "TOPRIGHT", 0, -offsetY)
        if frame.config.rows.striped and rowIndex % 2 == 1 then
          addon.Utils:SetBackgroundColor(rowFrame, 1, 1, 1, .02)
        end
      end

      rowFrame.data = row
      rowFrame:SetHeight(rowHeight)
      rowFrame:SetScript("OnEnter", function() rowFrame:onEnterHandler(rowFrame) end)
      rowFrame:SetScript("OnLeave", function() rowFrame:onLeaveHandler(rowFrame) end)
      rowFrame:SetScript("OnClick", function() rowFrame:onClickHandler(rowFrame) end)
      rowFrame:Show()

      function rowFrame:onEnterHandler(f)
        if rowIndex > 1 or not frame.config.header.enabled then
          addon.Utils:SetHighlightColor(rowFrame, 1, 1, 1, .05)
        end
        if row.onEnter then
          row:onEnter(f)
        end
      end

      function rowFrame:onLeaveHandler(f)
        if rowIndex > 1 or not frame.config.header.enabled then
          addon.Utils:SetHighlightColor(rowFrame, 1, 1, 1, 0)
        end
        if row.onLeave then
          row:onLeave(f)
        end
      end

      function rowFrame:onClickHandler(f)
        if row.onClick then
          row:onClick(f)
        end
      end

      offsetX = 0
      addon.Utils:TableForEach(rowFrame.columns, function(columnFrame) columnFrame:Hide() end)
      addon.Utils:TableForEach(row.columns, function(column, columnIndex)
        local columnFrame = rowFrame.columns[columnIndex]
        local columnConfig = frame.data.columns[columnIndex]
        local columnWidth = columnConfig and columnConfig.width or frame.config.columns.width
        local columnTextAlign = columnConfig and columnConfig.align or "LEFT"

        if not columnFrame then
          columnFrame = CreateFrame("Button", "$parentCol" .. columnIndex, rowFrame)
          columnFrame.text = columnFrame:CreateFontString("$parentText", "OVERLAY")
          columnFrame.text:SetFontObject("GameFontHighlight")
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
          addon.Utils:SetBackgroundColor(columnFrame, column.backgroundColor.r, column.backgroundColor.g, column.backgroundColor.b, column.backgroundColor.a)
        else
          addon.Utils:SetBackgroundColor(columnFrame, 0, 0, 0, 0)
        end

        function columnFrame:onEnterHandler(f)
          rowFrame:onEnterHandler(f)
          if column.onEnter then
            column.onEnter(f)
          end
        end

        function columnFrame:onLeaveHandler(f)
          rowFrame:onLeaveHandler(f)
          if column.onLeave then
            column.onLeave(f)
          end
          -- TODO: move tooltip stuff to the callback source
          if column.onEnter then
            GameTooltip:Hide()
          end
        end

        function columnFrame:onClickHandler(f)
          rowFrame:onClickHandler(f)
          if column.onClick then
            column:onClick(f)
          end
        end

        offsetX = offsetX + columnWidth
      end)

      if not isStickyRow then
        offsetY = offsetY + rowHeight
      end
    end)

    frame.scrollFrame:SetParent(frame)
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, frame.config.header.sticky and -frame.config.header.height or 0)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.scrollFrame.content:SetSize(offsetX, offsetY)
  end

  frame.scrollFrame:HookScript("OnSizeChanged", function() frame:RenderTable() end)
  frame:RenderTable()
  table.insert(self.TableCollection, frame)
  return frame
end
