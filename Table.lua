---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Table
local Table = {}
addon.Table = Table

---@type AE_TableFrame[]
local TableCollection = {}

---Create a new table frame
---@param config AE_TableConfig
---@return AE_TableFrame
function Table:New(config)
  local frame = CreateFrame("Frame", addonName .. "Table" .. (addon.Utils:TableCount(TableCollection) + 1))
  -- local frame = addon.Utils:CreateScrollFrame(addonName .. "Table" .. (addon.Utils:TableCount(TableCollection) + 1))
  frame.config = CreateFromMixins(
    {
      header = {
        enabled = true,
        sticky = false,
        height = 30,
        clickable = false,
        sortable = false,
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
  frame.sortState = nil
  frame.scrollFrame = addon.Utils:CreateScrollFrame({
    name = "$parentScrollFrame",
    scrollSpeedVertical = frame.config.rows.height * 2,
  })

  ---Set the table data
  ---@param data AE_TableData
  function frame:SetData(data)
    self.data = data

    -- Apply current sort state to new data if it exists
    if self.sortState and self.sortState.columnIndex then
      self:SortByColumn(self.sortState.columnIndex, self.sortState.direction)
    else
      self:RenderTable()
    end
  end

  ---Set the row height
  ---@param height number
  function frame:SetRowHeight(height)
    self.config.rows.height = height
    self:Update()
  end

  ---Sort the table by a specific column
  ---@param columnIndex number The column index to sort by (1-based)
  ---@param direction "asc"|"desc"? The sort direction (defaults to "asc" or toggles if same column)
  function frame:SortByColumn(columnIndex, direction)
    if not self.config.header.sortable or not self.data or not self.data.columns or not self.data.rows then
      return
    end

    local columnConfig = self.data.columns[columnIndex]
    if not columnConfig or not columnConfig.sortable then
      return
    end

    -- Determine sort direction
    local newDirection = direction
    if not newDirection then
      if self.sortState and self.sortState.columnIndex == columnIndex then
        -- Toggle direction if same column
        newDirection = self.sortState.direction == "asc" and "desc" or "asc"
      else
        -- Default to ascending
        newDirection = "asc"
      end
    end

    -- Update sort state
    self.sortState = {
      columnIndex = columnIndex,
      direction = newDirection,
      sortKey = columnConfig.sortKey,
      sortCallback = columnConfig.sortCallback,
    }

    -- Sort the data rows (skip header row)
    local dataRows = {}
    for i = 2, #self.data.rows do
      table.insert(dataRows, self.data.rows[i])
    end

    table.sort(dataRows, function(a, b)
      local aValue = a.columns[columnIndex] and a.columns[columnIndex].text or ""
      local bValue = b.columns[columnIndex] and b.columns[columnIndex].text or ""

      -- Use custom sort callback if provided
      if columnConfig.sortCallback then
        return columnConfig.sortCallback(aValue, bValue, newDirection, a, b)
      end

      -- Default string comparison
      if newDirection == "asc" then
        return aValue < bValue
      else
        return aValue > bValue
      end
    end)

    -- Reconstruct data with header row
    self.data.rows = {self.data.rows[1]}
    for _, row in ipairs(dataRows) do
      table.insert(self.data.rows, row)
    end

    -- Re-render the table
    self:RenderTable()
  end

  ---Get the current sort state
  ---@return AE_TableSortState?
  function frame:GetSortState()
    return self.sortState
  end

  ---Clear the current sort
  function frame:ClearSort()
    self.sortState = nil
    -- Note: This doesn't re-sort the data, just clears the sort state
    -- To restore original order, you'd need to store the original data separately
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
        -- Make header clickable if sorting is enabled
        if frame.config.header.sortable and frame.config.header.clickable then
          rowFrame:SetScript("OnClick", nil) -- Remove row click handler for header
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
        columnFrame.text:SetWordWrap(false)
        columnFrame.text:SetJustifyH(columnTextAlign)
        columnFrame.text:SetPoint("TOPLEFT", columnFrame, "TOPLEFT", frame.config.cells.padding, -frame.config.cells.padding)
        columnFrame.text:SetPoint("BOTTOMRIGHT", columnFrame, "BOTTOMRIGHT", -frame.config.cells.padding, frame.config.cells.padding)

        -- Handle header column clicks for sorting
        if rowIndex == 1 and frame.config.header.sortable and frame.config.header.clickable then
          local columnConfig = frame.data.columns[columnIndex]
          if columnConfig and columnConfig.sortable then
            columnFrame:SetScript("OnClick", function()
              frame:SortByColumn(columnIndex)
            end)
            -- Add hover effect for sortable headers
            columnFrame:SetScript("OnEnter", function()
              addon.Utils:SetHighlightColor(columnFrame, 1, 1, 1, 0.1)
            end)
            columnFrame:SetScript("OnLeave", function()
              addon.Utils:SetHighlightColor(columnFrame, 1, 1, 1, 0)
            end)
            columnFrame.text:SetText(column.text)
          else
            columnFrame:SetScript("OnClick", function() columnFrame:onClickHandler(columnFrame) end)
            columnFrame:SetScript("OnEnter", function() columnFrame:onEnterHandler(columnFrame) end)
            columnFrame:SetScript("OnLeave", function() columnFrame:onLeaveHandler(columnFrame) end)
            columnFrame.text:SetText(column.text)
          end
        else
          columnFrame:SetScript("OnClick", function() columnFrame:onClickHandler(columnFrame) end)
          columnFrame:SetScript("OnEnter", function() columnFrame:onEnterHandler(columnFrame) end)
          columnFrame:SetScript("OnLeave", function() columnFrame:onLeaveHandler(columnFrame) end)
          columnFrame.text:SetText(column.text)
        end

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
  table.insert(TableCollection, frame)
  return frame
end
