local numTables = 0
function AlterEgo:CreateTable(initialData, parent)
    numTables = numTables + 1
    local rows = {}
    local data = initialData or {}
    local tableFrame = CreateFrame("Frame", parent:GetName() .. "Table" .. numTables, parent)

    local function add(row)
        table.insert(data, row)
        render()
    end

    local function clear()
        wipe(data or {})
        render()
    end

    local function render()
        for r = 1, #data do
            local row = rows[r]
            if row then
                row:Show()
            else
                row = CreateFrame("Button", tableFrame:GetName() .. "Row" .. r, tableFrame)
                if r == 1 then
                    self:SetBackgroundColor(row, 0, 0, 0, .2)
                end
                rows[r] = row
                row.cols = {}
            end
            if r > 1 then
                row:SetPoint("TOPLEFT", rows[r - 1], "BOTTOMLEFT", 0, 0);
                row:SetPoint("TOPRIGHT", rows[r - 1], "BOTTOMRIGHT", 0, 0);
            else
                row:SetPoint("TOPLEFT", tableFrame, "TOPLEFT", 0, 0);
                row:SetPoint("TOPRIGHT", tableFrame, "TOPRIGHT", 0, 0);
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
                    col:SetPoint("LEFT", row.cols[c - 1], "RIGHT", self.constants.sizes.padding * 2, 0);
                else
                    col:SetPoint("LEFT", row, "LEFT", self.constants.sizes.padding, 0);
                end
                col:SetSize(parent:GetWidth() / #data[r] - self.constants.sizes.padding * 2, self.constants.sizes.row);
                col:Show()
                col:SetText(data[r][c])
            end
            -- if r == 1 then
            --     frame:SetSize(#data[r] * colWidth, #data * self.constants.sizes.row)
            -- end
        end
    end

    tableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT")
    tableFrame:SetAllPoints(parent)
    parent["Table" .. numTables] = tableFrame

    render()

    return {
        data = data,
        add = add,
        clear = clear,
        render = render
    }
end