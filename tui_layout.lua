--[[

     Licensed under MIT
     * (c) 2017, Egor Churaev egor.churaev@gmail.com

--]]

local awful = require("awful")
local wibox = require("wibox")
local kbdcfg = {}

-- Function to change current layout to the next available layout
function kbdcfg.switch_next()
    kbdcfg.current = kbdcfg.current % #(kbdcfg.layouts) + 1
    kbdcfg.switch(kbdcfg.layouts[kbdcfg.current])
end

-- Function to change current layout based on the name
function kbdcfg.switch_by_name(name)
    for i, layout in ipairs(kbdcfg.layouts) do
        if layout.name == name then
            kbdcfg.current = i
            kbdcfg.switch(layout)
        end
    end
end

function kbdcfg.switch(layout)
    for i, current in ipairs(kbdcfg.layouts) do
        if current.name == layout.name then
            kbdcfg.current = i
            break
        end
    end

    kbdcfg.widget:set_text(" " .. layout.keymap .. " ")
    os.execute(kbdcfg.cmd .. " " .. layout.keymap)
end

function kbdcfg.add_primary_layout(layout_name, keymap_name)
    local layout = { name   = layout_name,
                     keymap = keymap_name };

    table.insert(kbdcfg.layouts, layout)
    table.insert(kbdcfg.additional_layouts, layout)
end

function kbdcfg.add_additional_layout(layout_name, keymap_name)
    local layout = { name   = layout_name,
                     keymap = keymap_name };

    table.insert(kbdcfg.additional_layouts, layout)
end

function kbdcfg.bind()
    -- Menu for choose additional keyboard layouts
    local menu_items = {}

    for i = 1, #kbdcfg.additional_layouts do
        local layout = kbdcfg.additional_layouts[i]
        table.insert(menu_items,
                     {layout.name, function () kbdcfg.switch(layout) end})
    end

    kbdcfg.menu = awful.menu({ items = menu_items })
    kbdcfg.widget = wibox.widget.textbox()

    local current_layout = kbdcfg.layouts[kbdcfg.current]
    if current_layout then
        kbdcfg.switch(current_layout)
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
