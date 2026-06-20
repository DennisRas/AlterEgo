LiqUIDB = LiqUIDB or {}
LiqUIDB.dev = LiqUIDB.dev or {}

local function devGet(key) return LiqUIDB.dev and LiqUIDB.dev[key] end
local function devSet(key, val)
  LiqUIDB.dev = LiqUIDB.dev or {}
  LiqUIDB.dev[key] = val
end

local function printMsg(...) print("|cff67AFD6LiqUI:|r", ...) end

local options = {
  type = "group",
  args = {
    headers = {
      type = "group",
      name = "Headers",
      order = 1,
      args = {
        header = { type = "header", name = "Header styles", order = 0 },
        desc = { type = "description", name = "Test header and description layout.", order = 1 },
        divider = { type = "divider", order = 2 },
        headerOnly = { type = "header", name = "Header only (no description)", order = 10 },
        toggle1 = {
          type = "toggle",
          name = "Toggle under header",
          get = function() return devGet("h_toggle1") end,
          set = function(_, v) devSet("h_toggle1", v) end,
          order = 11,
        },
        descOnly = { type = "description", name = "Description only (no header above).", order = 20 },
        toggle2 = {
          type = "toggle",
          name = "Toggle under description",
          get = function() return devGet("h_toggle2") end,
          set = function(_, v) devSet("h_toggle2", v) end,
          order = 21,
        },
        toggleDisabled = {
          type = "toggle",
          name = "Disabled toggle",
          disabled = true,
          get = function() return true end,
          set = function() end,
          order = 30,
        },
      },
    },
    dropdowns = {
      type = "group",
      name = "Dropdowns",
      order = 2,
      args = {
        header = { type = "header", name = "Dropdowns", order = 0 },
        desc = { type = "description", name = "Select, multiselect, and texture dropdown (placeholder for LibSharedMedia).", order = 1 },
        divider = { type = "divider", order = 2 },
        select = {
          type = "select",
          name = "Single choice",
          values = { a = "Option A", b = "Option B", c = "Option C" },
          get = function() return devGet("dd_select") or "a" end,
          set = function(_, v) devSet("dd_select", v) end,
          order = 10,
        },
        multiselect = {
          type = "multiselect",
          name = "Multi choice",
          desc = "Pick multiple options.",
          values = { x = "Extra", y = "Yes", z = "Zoom" },
          get = function(_, k) return (devGet("dd_multi") or {})[k] end,
          set = function(_, k, v)
            LiqUIDB.dev = LiqUIDB.dev or {}
            LiqUIDB.dev.dd_multi = LiqUIDB.dev.dd_multi or {}
            LiqUIDB.dev.dd_multi[k] = v
          end,
          order = 20,
        },
        texture = {
          type = "select",
          name = "Texture",
          desc = "Placeholder for LibSharedMedia texture dropdown.",
          values = {
            white8x8 = "White 8x8",
            tooltip_border = "Tooltip Border",
            solid = "Solid",
          },
          get = function() return devGet("dd_texture") or "white8x8" end,
          set = function(_, v) devSet("dd_texture", v) end,
          order = 30,
        },
        selectDisabled = {
          type = "select",
          name = "Disabled select",
          disabled = true,
          values = { a = "A", b = "B" },
          get = function() return "a" end,
          set = function() end,
          order = 40,
        },
        multiselectDisabled = {
          type = "multiselect",
          name = "Disabled multiselect",
          disabled = true,
          values = { x = "X", y = "Y" },
          get = function() return false end,
          set = function() end,
          order = 50,
        },
        textureDisabled = {
          type = "select",
          name = "Disabled texture",
          disabled = true,
          values = { solid = "Solid" },
          get = function() return "solid" end,
          set = function() end,
          order = 60,
        },
      },
    },
    toggles = {
      type = "group",
      name = "Toggles",
      order = 3,
      args = {
        header = { type = "header", name = "Toggles", order = 0 },
        desc = { type = "description", name = "Checkbox controls.", order = 1 },
        divider = { type = "divider", order = 2 },
        toggle1 = {
          type = "toggle",
          name = "Toggle option",
          get = function() return devGet("tg_1") end,
          set = function(_, v) devSet("tg_1", v) end,
          order = 10,
        },
        toggle2 = {
          type = "toggle",
          name = "Toggle with description",
          desc = "Additional text below the label.",
          get = function() return devGet("tg_2") end,
          set = function(_, v) devSet("tg_2", v) end,
          order = 20,
        },
        toggleChecked = {
          type = "toggle",
          name = "Checked toggle",
          get = function() return devGet("tg_checked") ~= false end,
          set = function(_, v) devSet("tg_checked", v) end,
          order = 30,
        },
        toggleDisabled = {
          type = "toggle",
          name = "Disabled toggle",
          disabled = true,
          get = function() return false end,
          set = function() end,
          order = 40,
        },
        toggleCheckedDisabled = {
          type = "toggle",
          name = "Checked disabled toggle",
          disabled = true,
          get = function() return true end,
          set = function() end,
          order = 50,
        },
      },
    },
    inputs = {
      type = "group",
      name = "Inputs",
      order = 4,
      args = {
        header = { type = "header", name = "Inputs", order = 0 },
        desc = { type = "description", name = "Edit box controls.", order = 1 },
        divider = { type = "divider", order = 2 },
        input1 = {
          type = "input",
          name = "Text input",
          get = function() return tostring(devGet("in_1") or "") end,
          set = function(_, v) devSet("in_1", v) end,
          order = 10,
        },
        input2 = {
          type = "input",
          name = "Input with description",
          desc = "Placeholder for numeric or text value.",
          get = function() return tostring(devGet("in_2") or "") end,
          set = function(_, v) devSet("in_2", v) end,
          order = 20,
        },
        input3 = {
          type = "input",
          name = "Number input",
          desc = "inputType = number. Widget will filter/parse when implemented.",
          inputType = "number",
          get = function() return tostring(devGet("in_num") or 0) end,
          set = function(_, v)
            local n = tonumber(v)
            devSet("in_num", n or 0)
          end,
          order = 30,
        },
        inputDisabled = {
          type = "input",
          name = "Disabled input",
          disabled = true,
          get = function() return "Disabled" end,
          set = function() end,
          order = 40,
        },
        inputNumberDisabled = {
          type = "input",
          name = "Disabled number input",
          disabled = true,
          inputType = "number",
          get = function() return "42" end,
          set = function() end,
          order = 50,
        },
      },
    },
    colors = {
      type = "group",
      name = "Colors",
      order = 5,
      args = {
        header = { type = "header", name = "Colors", order = 0 },
        desc = { type = "description", name = "Color picker with and without alpha.", order = 1 },
        divider = { type = "divider", order = 2 },
        colorNoAlpha = {
          type = "color",
          name = "Color (no alpha)",
          hasAlpha = false,
          get = function()
            local c = LiqUIDB.dev and LiqUIDB.dev.col1
            if c then return c.r, c.g, c.b, 1 end
            return 0.3, 0.5, 0.8, 1
          end,
          set = function(_, r, g, b)
            LiqUIDB.dev = LiqUIDB.dev or {}
            LiqUIDB.dev.col1 = { r = r, g = g, b = b }
          end,
          order = 10,
        },
        colorWithAlpha = {
          type = "color",
          name = "Color (with alpha)",
          hasAlpha = true,
          get = function()
            local c = LiqUIDB.dev and LiqUIDB.dev.col2
            if c then return c.r, c.g, c.b, c.a or 1 end
            return 0.5, 0.5, 0.5, 1
          end,
          set = function(_, r, g, b, a)
            LiqUIDB.dev = LiqUIDB.dev or {}
            LiqUIDB.dev.col2 = { r = r, g = g, b = b, a = a or 1 }
          end,
          order = 20,
        },
        colorDisabled = {
          type = "color",
          name = "Disabled color",
          disabled = true,
          hasAlpha = false,
          get = function() return 0.5, 0.5, 0.5, 1 end,
          set = function() end,
          order = 30,
        },
      },
    },
    buttons = {
      type = "group",
      name = "Buttons",
      order = 6,
      args = {
        header = { type = "header", name = "Buttons", order = 0 },
        desc = { type = "description", name = "Execute / button controls.", order = 1 },
        divider = { type = "divider", order = 2 },
        btnPrint = {
          type = "execute",
          name = "Print test",
          func = function() printMsg("Button clicked") end,
          order = 10,
        },
        btnReload = {
          type = "execute",
          name = "Reload UI",
          func = function() ReloadUI() end,
          order = 20,
        },
        btnDisabled = {
          type = "execute",
          name = "Disabled button",
          disabled = true,
          func = function() end,
          order = 30,
        },
      },
    },
    scroll = {
      type = "group",
      name = "Scroll",
      order = 7,
      args = {},
    },
    debug = {
      type = "group",
      name = "Debug",
      order = 8,
      args = {
        header = { type = "header", name = "Debug", order = 0 },
        desc = { type = "description", name = "Development utilities.", order = 1 },
        divider = { type = "divider", order = 2 },
        verboseLogging = {
          type = "toggle",
          name = "Verbose logging",
          get = function() return devGet("verbose") end,
          set = function(_, v) devSet("verbose", v) end,
          order = 10,
        },
        dumpSettings = {
          type = "execute",
          name = "Dump settings to chat",
          func = function()
            printMsg("LiqUIDB keys: " .. (LiqUIDB and "present" or "nil"))
            if LiqUIDB and LiqUIDB.dev then
              for k, v in pairs(LiqUIDB.dev) do printMsg("  dev." .. tostring(k) .. " = " .. tostring(v)) end
            end
          end,
          order = 20,
        },
        verboseDisabled = {
          type = "toggle",
          name = "Disabled toggle",
          disabled = true,
          get = function() return false end,
          set = function() end,
          order = 30,
        },
        dumpDisabled = {
          type = "execute",
          name = "Disabled dump",
          disabled = true,
          func = function() end,
          order = 40,
        },
      },
    },
  },
}

do
  local scrollArgs = options.args.scroll.args
  scrollArgs.header = { type = "header", name = "Scroll", order = 0 }
  scrollArgs.desc = { type = "description", name = "Many rows to test scrollbar visibility.", order = 1 }
  scrollArgs.divider = { type = "divider", order = 2 }
  for i = 1, 28 do
    local isInput = (i % 4 == 0)
    local isDisabled = (i <= 2)
    scrollArgs["row" .. i] = {
      type = isInput and "input" or "toggle",
      name = "Option " .. i .. (isDisabled and " (disabled)" or ""),
      disabled = isDisabled,
      order = 10 + i,
    }
    if isInput then
      scrollArgs["row" .. i].get = function() return tostring(devGet("scroll_" .. i) or "") end
      scrollArgs["row" .. i].set = function(_, v) devSet("scroll_" .. i, v) end
    else
      scrollArgs["row" .. i].get = function() return devGet("scroll_" .. i) end
      scrollArgs["row" .. i].set = function(_, v) devSet("scroll_" .. i, v) end
    end
  end
end

LiqUI.Settings:Register("LiqUITesting", options, "LiqUI Testing")

SLASH_LIQUI1 = "/liqui"
SlashCmdList.LIQUI = function() LiqUI.Settings:Toggle() end
