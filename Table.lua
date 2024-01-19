local _, AlterEgo = ...
local Table = {}
AlterEgo.Table = Table

function Table:New(data)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance.frame = CreateFrame("Frame")
    instance.data = data or {}
    instance.rowFrames = {}
    instance.width = 300
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

function Table:Update()
    local rows = self.data
    local rowFrames = self.rowFrames
    for rowIndex = 1, #rows do
        local columns = rows[rowIndex]
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
            AlterEgo:SetBackgroundColor(rowFrame, 0, 0, 0, .3)
        end

        rowFrame:SetHeight(AlterEgo.constants.sizes.row)

        for colIndex = 1, #columns do
            local column = columns[colIndex]
            local colFrame = rowFrame.colFrames[colIndex]
            if colFrame then
                colFrame:Show()
            else
                colFrame = CreateFrame("Frame", "$parentCol" .. colIndex, rowFrame)
                colFrame.Text = colFrame:CreateFontString("$parentText", "OVERLAY")
                colFrame.Text:SetFont(AlterEgo.constants.font.file, AlterEgo.db.global.interface.fontSize, AlterEgo.constants.font.flags)
                colFrame.Text:SetJustifyH("LEFT")
                colFrame.Text:SetAllPoints()
                colFrame:SetPushedTextOffset(0,0);
                rowFrame.colFrames[colIndex] = colFrame
            end
            if colIndex > 1 then
                colFrame:SetPoint("LEFT", rowFrame.colFrames[colIndex - 1], "RIGHT", AlterEgo.constants.sizes.padding * 2, 0)
            else
                colFrame:SetPoint("LEFT", rowFrame, "LEFT", AlterEgo.constants.sizes.padding, 0)
            end
            -- if r == 1 then
            --     col:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            -- end
            colFrame:SetSize(self.width / #columns - AlterEgo.constants.sizes.padding * 2, AlterEgo.constants.sizes.row)
            colFrame:SetText(column)
            colFrame:Show()
        end

        -- Hide extra unused columns
        local ce = #columns + 1
        while rowFrame.colFrames[ce] do
            ce = ce + 1
            rowFrame.colFrames:Hide()
        end
    end

    -- Hide extra unused rows
    local re = #rows + 1
    while rowFrames[re] do
        re = re + 1
        rowFrames:Hide()
    end

    self.frame:SetSize(self.width, #rows * AlterEgo.constants.sizes.row)
end

-- local tables = {}
-- function Table:Create(name, initialData, parent)
--     local uniqueName = parent:GetName() .. name
--     if tables[uniqueName] then
--         return tables[uniqueName]
--     end

--     local data = initialData or {}
--     local tableFrame = CreateFrame("Frame", name, parent)
--     tableFrame.rows = {}

--     for r = 1, #data do
--         local row = tableFrame.rows[r]
--         if row then
--             row:Show()
--         else
--             row = CreateFrame("Button", tableFrame:GetName() .. "Row" .. r, tableFrame)

--             tableFrame.rows[r] = row
--             row.cols = {}
--         end
--         if r > 1 then
--             row:SetPoint("TOPLEFT", tableFrame.rows[r - 1], "BOTTOMLEFT", 0, 0)
--             row:SetPoint("TOPRIGHT", tableFrame.rows[r - 1], "BOTTOMRIGHT", 0, 0)
--             if r % 2 == 1 then
--                 AlterEgo:SetBackgroundColor(row, 1, 1, 1, .02)
--             end
--         else
--             row:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 0, 0)
--             row:SetPoint("TOPRIGHT", tableFrame, "TOPRIGHT", 0, 0)
--             AlterEgo:SetBackgroundColor(row, 0, 0, 0, .3)
--         end
--         row:SetHeight(AlterEgo.constants.sizes.row)

--         for c = 1, #data[r] do
--             local col = row.cols[c]
--             if col then
--                 col:Show()
--             else
--                 col = row:CreateFontString(row:GetName() .. "Col" .. c, "OVERLAY")
--                 col:SetFont(AlterEgo.constants.font.file, AlterEgo.constants.font.size, AlterEgo.constants.font.flags)
--                 col:SetJustifyH("LEFT")
--                 row.cols[c] = col
--             end
--             if c > 1 then
--                 col:SetPoint("LEFT", row.cols[c - 1], "RIGHT", AlterEgo.constants.sizes.padding * 2, 0)
--             else
--                 col:SetPoint("LEFT", row, "LEFT", AlterEgo.constants.sizes.padding, 0)
--             end
--             -- if r == 1 then
--             --     col:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
--             -- end
--             col:SetSize(parent:GetWidth() / #data[r] - AlterEgo.constants.sizes.padding * 2, AlterEgo.constants.sizes.row)
--             col:Show()
--             col:SetText(data[r][c])
--         end
--     end

--     tableFrame:SetAllPoints(parent)
--     tables[uniqueName] = tableFrame
--     return tables[uniqueName]
-- end
