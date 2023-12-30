local tables = {}
function AlterEgo:CreateTable(name, initialData, parent)
    local uniqueName = parent:GetName() .. name
    if tables[uniqueName] then
        return tables[uniqueName]
    end

    local data = initialData or {}
    local tableFrame = CreateFrame("Frame", name, parent)
    tableFrame.rows = {}

    for r = 1, #data do
        local row = tableFrame.rows[r]
        if row then
            row:Show()
        else
            row = CreateFrame("Button", tableFrame:GetName() .. "Row" .. r, tableFrame)

            tableFrame.rows[r] = row
            row.cols = {}
        end
        if r > 1 then
            row:SetPoint("TOPLEFT", tableFrame.rows[r - 1], "BOTTOMLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", tableFrame.rows[r - 1], "BOTTOMRIGHT", 0, 0)
            if r % 2 == 1 then
                self:SetBackgroundColor(row, 1, 1, 1, .02)
            end
        else
            row:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", tableFrame, "TOPRIGHT", 0, 0)
            self:SetBackgroundColor(row, 0, 0, 0, .3)
        end
        row:SetHeight(self.constants.sizes.row)

        for c = 1, #data[r] do
            local col = row.cols[c]
            if col then
                col:Show()
            else
                col = row:CreateFontString(row:GetName() .. "Col" .. c, "OVERLAY")
                col:SetFont(self.constants.assets.font.file, self.constants.assets.font.size, self.constants.assets.font.flags)
                col:SetJustifyH("LEFT")
                row.cols[c] = col
            end
            if c > 1 then
                col:SetPoint("LEFT", row.cols[c - 1], "RIGHT", self.constants.sizes.padding * 2, 0)
            else
                col:SetPoint("LEFT", row, "LEFT", self.constants.sizes.padding, 0)
            end
            -- if r == 1 then
            --     col:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
            -- end
            col:SetSize(parent:GetWidth() / #data[r] - self.constants.sizes.padding * 2, self.constants.sizes.row)
            col:Show()
            col:SetText(data[r][c])
        end
    end

    tableFrame:SetAllPoints(parent)
    tables[uniqueName] = tableFrame
    return tables[uniqueName]
end