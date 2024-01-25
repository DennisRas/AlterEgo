local Table = {}
AlterEgo.Table = Table

function Table:New(data)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance.frame = CreateFrame("Frame")
    instance.data = data or {
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
    instance.rowFrames = {}
    instance.width = 600
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

        rowFrame:SetHeight(AlterEgo.constants.sizes.row)

        for colIndex = 1, #columns do
            local column = columns[colIndex]
            local colFrame = rowFrame.colFrames[colIndex]
            if colFrame then
                colFrame:Show()
            else
                colFrame = CreateFrame("Button", "$parentCol" .. colIndex, rowFrame)
                colFrame.Text = colFrame:CreateFontString("$parentText", "OVERLAY")
                colFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
                colFrame.Text:SetJustifyH(self.data.columns[colIndex].align or "LEFT")
                -- colFrame.Text:SetAllPoints()
                colFrame.Text:SetPoint("LEFT", colFrame, "LEFT", AlterEgo.constants.sizes.padding, 0)
                colFrame.Text:SetPoint("RIGHT", colFrame, "RIGHT", -AlterEgo.constants.sizes.padding, 0)
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

            -- if r == 1 then
            --     col:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            -- end
            colFrame:SetSize(self.data.columns[colIndex].width, AlterEgo.constants.sizes.row)
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

    self.frame:SetSize(width, #rows * AlterEgo.constants.sizes.row)
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