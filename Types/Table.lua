---@class AE_TableDataColumn
---@field width number
---@field align string?

---@class AE_TableDataRowColumn
---@field text string?
---@field backgroundColor table?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?

---@class AE_TableDataRow
---@field columns AE_TableDataRowColumn[]

---@class AE_TableData
---@field columns AE_TableDataColumn[]?
---@field rows AE_TableDataRow[]

---@class AE_TableConfigHeader
---@field enabled boolean?
---@field sticky boolean?
---@field height number?

---@class AE_TableConfigRows
---@field height number?
---@field highlight boolean?
---@field striped boolean?

---@class AE_TableConfigColumns
---@field width number?
---@field highlight boolean?
---@field striped boolean?

---@class AE_TableConfigCells
---@field padding number?
---@field highlight boolean?

---@class AE_TableConfig
---@field header AE_TableConfigHeader?
---@field rows AE_TableConfigRows?
---@field columns AE_TableConfigColumns?
---@field cells AE_TableConfigCells?
---@field data AE_TableData?

---@class AE_TableFrame : Frame
---@field config AE_TableConfig
---@field rows table
---@field data AE_TableData
---@field scrollFrame ScrollFrame

---@class AE_Table
---@field frames AE_TableFrame[]
