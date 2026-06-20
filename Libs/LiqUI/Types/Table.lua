---@alias LiqUI_TableDataValue string|number

---@alias LiqUI_TableCellHandler fun(cellFrame: LiqUI_TableCellFrame, rowFrame: LiqUI_TableRowFrame, rowIndex: integer, columnIndex: integer, columnId: string|nil, rowData: LiqUI_TableDataRowExtended, cellData: LiqUI_TableDataCellExtended|nil)

---@alias LiqUI_TableCellClickHandler fun(cellFrame: LiqUI_TableCellFrame, rowFrame: LiqUI_TableRowFrame, rowIndex: integer, columnIndex: integer, columnId: string|nil, rowData: LiqUI_TableDataRowExtended, cellData: LiqUI_TableDataCellExtended|nil, button: string)

---@alias LiqUI_TableHeaderCellHandler fun(cellFrame: Button, columnIndex: integer, columnId: string|nil, column: LiqUI_TableOptionsColumn)

---@class LiqUI_TableDataCellExtended
---@field data LiqUI_TableDataValue|nil
---@field backgroundColor ColorTable|nil
---@field onEnter LiqUI_TableCellHandler|nil
---@field onLeave LiqUI_TableCellHandler|nil
---@field onClick LiqUI_TableCellClickHandler|nil

---@alias LiqUI_TableDataCellValue LiqUI_TableDataValue|LiqUI_TableDataCellExtended

---@class LiqUI_TableDataRowExtended
---@field data LiqUI_TableDataCellValue[]
---@field height number|nil
---@field backgroundColor ColorTable|nil
---@field onEnter LiqUI_TableCellHandler|nil
---@field onLeave LiqUI_TableCellHandler|nil
---@field onClick LiqUI_TableCellClickHandler|nil

---@alias LiqUI_TableDataRow LiqUI_TableDataCellValue[]|LiqUI_TableDataRowExtended

---@alias LiqUI_TableData LiqUI_TableDataRow[]

---@class LiqUI_TableOptionsColumn
---@field id string
---@field dataIndex integer?
---@field headerText string|nil
---@field width number
---@field align "LEFT"|"CENTER"|"RIGHT"|nil
---@field hideable boolean|nil
---@field render? fun(cell: LiqUI_TableDataCellExtended|nil, row: LiqUI_TableDataRowExtended, rowIndex: integer): LiqUI_TableDataValue|nil
---@field sorting LiqUI_TableOptionsColumnSorting|nil
---@field onEnter LiqUI_TableHeaderCellHandler|nil
---@field onLeave LiqUI_TableHeaderCellHandler|nil

---@class LiqUI_TableOptionsColumnSorting
---@field enabled boolean
---@field compare? fun(rowA: LiqUI_TableDataRowExtended, rowB: LiqUI_TableDataRowExtended, rowIndexA: integer, rowIndexB: integer): boolean

---@class LiqUI_TableOptionsHeader
---@field enabled boolean?
---@field sticky boolean?
---@field height number?
---@field fontObject string?

---@class LiqUI_TableOptionsRowStyle
---@field height number?
---@field highlight boolean?
---@field striped boolean?

---@class LiqUI_TableOptionsCellStyle
---@field padding number?
---@field highlight boolean?
---@field fontObject string?

---@class LiqUI_TableOptionsSorting
---@field enabled boolean
---@field defaultOrder "asc"|"desc"
---@field defaultCompare fun(rowA: LiqUI_TableDataRowExtended, rowB: LiqUI_TableDataRowExtended, rowIndexA: integer, rowIndexB: integer): boolean
---@field savedState LiqUI_TableSortState?
---@field onStateChanged fun(state: LiqUI_TableSortState)?

---@class LiqUI_TableOptions
---@field name string?
---@field columns LiqUI_TableOptionsColumn[]?
---@field header LiqUI_TableOptionsHeader?
---@field rowStyle LiqUI_TableOptionsRowStyle?
---@field cellStyle LiqUI_TableOptionsCellStyle?
---@field sorting LiqUI_TableOptionsSorting?

---@class LiqUI_TableSortState
---@field columnId string|nil
---@field direction "asc"|"desc"|nil

---@class LiqUI_TableDB
---@field sortState LiqUI_TableSortState?
---@field hiddenColumns table<string, boolean>?

---@class LiqUI_TableLayoutSize
---@field shownWidth number
---@field shownHeight number

---@class LiqUI_Table
---@field embed LiqUI_Instance
---@field instances table<string, LiqUI_TableInstance>

---@class LiqUI_TableCellFrame : Button
---@field label FontString
---@field rowIndex integer
---@field columnIndex integer
---@field columnId string|nil
---@field tableFrame LiqUI_TableInstance

---@class LiqUI_TableRowFrame : Frame
---@field cells table<integer, LiqUI_TableCellFrame>

---@class LiqUI_TableInstance : Frame
---@field options LiqUI_TableOptions
---@field data LiqUI_TableDataRowExtended[]
---@field headerRowFrame LiqUI_TableRowFrame|nil
---@field rowFrames table<integer, LiqUI_TableRowFrame>
---@field scrollArea LiqUI_ScrollArea
---@field layoutSize LiqUI_TableLayoutSize
---@field db LiqUI_TableDB|nil
---@field sortState LiqUI_TableSortState
