--[[

     Licensed under MIT
     * (c) 2017, Egor Churaev egor.churaev@gmail.com

--]]

local awful = require("awful")
local wibox = require("wibox")
local kbdcfg = {}
local widget_dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
local en_icon = widget_dir .. 'icons/en.png'
kbdcfg.layouts = { { "English", "us", en_icon } }

-- Function for changing keyboard by keys
function kbdcfg.switch()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layouts) + 1
  local t = kbdcfg.layouts[kbdcfg.current]
  kbdcfg.widget.image = t[3]
  os.execute( kbdcfg.cmd .. " " .. t[2] .. " " )
end

-- Function for changing keyboard layout by name
function kbdcfg.switch_by_name(keymap_name, layout_image)
  kbdcfg.current = #kbdcfg.layouts
  for i = 1, #kbdcfg.layouts do
    if kbdcfg.layouts[i][2] == keymap_name then
        kbdcfg.current = i
        break
    end
  end
  kbdcfg.widget.image = layout_image
  os.execute( kbdcfg.cmd .. " " .. keymap_name .. " " )
end


function kbdcfg.add_additional_layout(layout_name, keymap_name, layout_image)
    if kbdcfg.additional_layouts ~= nil then
        table.insert(kbdcfg.additional_layouts, {layout_name, keymap_name, layout_image})
    else
        kbdcfg.additional_layouts = {{layout_name, keymap_name, layout_image}}
    end
end

function kbdcfg.bind()
    -- Menu for choose additional keyboard layouts
    local menu_items = {}
    for i = 1, #kbdcfg.additional_layouts do
        local layout_name  = kbdcfg.additional_layouts[i][1]
        local keymap_name  = kbdcfg.additional_layouts[i][2]
        local layout_image = kbdcfg.additional_layouts[i][3]
        table.insert(menu_items, {layout_name, function () kbdcfg.switch_by_name(keymap_name, layout_image) end, layout_image})
    end
    kbdcfg.menu = awful.menu({ items = menu_items })
    kbdcfg.widget = wibox.widget.imagebox(kbdcfg.layouts[kbdcfg.current][3])
    kbdcfg.switch_by_name(kbdcfg.layouts[kbdcfg.current][2], kbdcfg.layouts[kbdcfg.current][3])
end

local function factory(args)
    local args                   = args or {}
    kbdcfg.cmd                   = args.cmd or "setxkbmap"
    kbdcfg.additional_layouts    = nil
    kbdcfg.current               = args.current or 1
    kbdcfg.menu                  = nil

    if args.layouts then
        kbdcfg.layouts = args.layouts
    end

    kbdcfg.additional_layouts = { kbdcfg.layouts[1] }
    for i = 2, #kbdcfg.layouts do
        table.insert(kbdcfg.additional_layouts, kbdcfg.layouts[i])
    end

    kbdcfg.bind()

    return kbdcfg
end

return setmetatable(kbdcfg, { __call = function(_, ...) return factory(...) end })
