local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

LiqUIDB = LiqUIDB or {}

---@return LiqUI_DB
local function getEmbedDB()
  local liqui = LiqUIDB.liqui
  if type(liqui) ~= "table" or type(liqui.windows) ~= "table" or type(liqui.tables) ~= "table" or type(liqui.loggers) ~= "table" then
    ---@type LiqUI_DB
    LiqUIDB.liqui = {
      windows = type(liqui) == "table" and type(liqui.windows) == "table" and liqui.windows or {},
      tables = type(liqui) == "table" and type(liqui.tables) == "table" and liqui.tables or {},
      loggers = type(liqui) == "table" and type(liqui.loggers) == "table" and liqui.loggers or {},
    }
  end
  return LiqUIDB.liqui
end

local liqui = LiqUI:New({ name = "LiqUI", db = getEmbedDB() })

local galleryWindow
local galleryTable
local progressVisible = false

---@param row LiqUI_TableDataRowExtended
---@param columnIndex integer
---@return LiqUI_TableDataValue
local function sortCellValue(row, columnIndex)
  local cell = row.data[columnIndex]
  if type(cell) == "table" then
    return cell.data or ""
  end
  return cell or ""
end

---@return LiqUI_TableData
local function galleryData()
  ---@type LiqUI_TableData
  local data = {}
  for index = 1, 40 do
    local flag = index % 3 == 0 and "Yes" or "No"
    if index % 5 == 0 then
      ---@type LiqUI_TableDataRowExtended
      local row = {
        data = {
          format("Row %d", index),
          index * 10,
          {
            data = flag,
            onEnter = function(cellFrame, rowFrame, rowIndex, columnIndex, columnId, rowData, cellData)
              GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
              GameTooltip:SetText(format("Extended cell on row %d", index), 1, 1, 1)
              GameTooltip:Show()
            end,
            onLeave = function(cellFrame, rowFrame, rowIndex, columnIndex, columnId, rowData, cellData)
              GameTooltip:Hide()
            end,
          },
        },
        backgroundColor = { r = 0.2, g = 0.4, b = 0.6, a = 0.25 },
      }
      data[index] = row
    else
      ---@type LiqUI_TableDataRow
      data[index] = { format("Row %d", index), index * 10, flag }
    end
  end
  return data
end

local function ensureGallery()
  if galleryWindow then
    return
  end

  ---@type LiqUI_WindowOptions
  local windowOptions = {
    name = "Gallery",
    title = "LiqUI Gallery",
    width = 520,
    height = 400,
    titlebarButtons = {
      {
        name = "Progress",
        icon = "Interface/ICONS/INV_Misc_Gear_01",
        tooltipTitle = "Toggle progress overlay",
        tooltipDescription = "Demonstrates ShowProgressOverlay / HideProgressOverlay.",
        onClick = function()
          if not galleryWindow then
            return
          end
          progressVisible = not progressVisible
          if progressVisible then
            galleryWindow:ShowProgressOverlay("Loading sample data...", 0.65)
          else
            galleryWindow:HideProgressOverlay()
          end
        end,
      },
    },
  }

  galleryWindow = liqui.Window:New(windowOptions)

  ---@type LiqUI_TableOptions
  local tableConfig = {
    name = "Gallery",
    columns = {
      {
        id = "name",
        headerText = "Name",
        width = 180,
        sorting = {
          enabled = true,
          compare = function(rowA, rowB)
            return sortCellValue(rowA, 1) < sortCellValue(rowB, 1)
          end,
        },
      },
      {
        id = "value",
        headerText = "Value",
        width = 80,
        sorting = {
          enabled = true,
          compare = function(rowA, rowB)
            return sortCellValue(rowA, 2) < sortCellValue(rowB, 2)
          end,
        },
      },
      {
        id = "flag",
        headerText = "Flag",
        width = 60,
        sorting = {
          enabled = true,
          compare = function(rowA, rowB)
            if sortCellValue(rowA, 3) ~= sortCellValue(rowB, 3) then
              return sortCellValue(rowA, 3) == "Yes"
            end
            return sortCellValue(rowA, 1) < sortCellValue(rowB, 1)
          end,
        },
      },
    },
    header = {
      enabled = true,
      sticky = true,
    },
    sorting = {
      enabled = true,
      defaultOrder = "asc",
      defaultCompare = function(rowA, rowB)
        return sortCellValue(rowA, 1) < sortCellValue(rowB, 1)
      end,
    },
  }

  galleryTable = liqui.Table:New(tableConfig)
  galleryTable:SetParent(galleryWindow.body)
  galleryTable:SetAllPoints(galleryWindow.body)
  galleryTable:SetData(galleryData())
end

SLASH_LIQUI1 = "/liqui"
SlashCmdList.LIQUI = function()
  ensureGallery()
  galleryWindow:Toggle()
end
