--[[

     Licensed under MIT
     * (c) 2017, Egor Churaev egor.churaev@gmail.com

--]]

local awful = require("awful")
local wibox = require("wibox")
local kbdcfg = {}

-- Function for changing keyboard by keys
function kbdcfg.switch()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layouts) + 1
  local keymap_name = kbdcfg.layouts[kbdcfg.current][2]
  kbdcfg.widget:set_text(" " .. keymap_name .. " ")
  os.execute( kbdcfg.cmd .. " " .. keymap_name .. " " )
end

-- Function for changing keyboard layout by name
function kbdcfg.switch_by_name(keymap_name)
  kbdcfg.current = #kbdcfg.layouts
  for i = 1, #kbdcfg.layouts do
    if kbdcfg.layouts[i][2] == keymap_name then
        kbdcfg.current = i
        break
    end
  end
  kbdcfg.widget:set_text(" " .. keymap_name .. " ")
  os.execute( kbdcfg.cmd .. " " .. keymap_name .. " " )
end

function kbdcfg.add_primary_layout(layout_name, keymap_name)
    if kbdcfg.layouts ~= nil then
        table.insert(kbdcfg.layouts, {layout_name, keymap_name})
    else
        kbdcfg.layouts = {{layout_name, keymap_name}}
    end
end

function kbdcfg.add_additional_layout(layout_name, keymap_name)
    if kbdcfg.additional_layouts ~= nil then
        table.insert(kbdcfg.additional_layouts, {layout_name, keymap_name})
    else
        kbdcfg.additional_layouts = {{layout_name, keymap_name}}
    end
end

function kbdcfg.bind()
    -- Menu for choose additional keyboard layouts
    local menu_items = {}
    for i = 1, #kbdcfg.additional_layouts do
        local layout_name  = kbdcfg.additional_layouts[i][1]
        local keymap_name  = kbdcfg.additional_layouts[i][2]
        table.insert(menu_items, {layout_name, function () kbdcfg.switch_by_name(keymap_name) end})
    end
    kbdcfg.menu = awful.menu({ items = menu_items })
    kbdcfg.widget = wibox.widget.textbox()

    local current_layout = kbdcfg.layouts[kbdcfg.current]
    if current_layout then
        kbdcfg.switch_by_name(current_layout[2])
    end
end

local function factory(args)
    local args                   = args or {}
    kbdcfg.cmd                   = args.cmd or "setxkbmap"
    kbdcfg.layouts               = args.layouts or {}
    kbdcfg.additional_layouts    = args.additional_layouts or {}
    kbdcfg.current               = args.current or 1
    kbdcfg.menu                  = nil

    for i = 1, #kbdcfg.layouts do
        table.insert(kbdcfg.additional_layouts, kbdcfg.layouts[i])
    end

    kbdcfg.bind()

    return kbdcfg
end

return setmetatable(kbdcfg, { __call = function(_, ...) return factory(...) end })
