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

-- Function to find layout in list and set current index
local function find_current_layout(name)
    for index, layout in ipairs(kbdcfg.additional_layouts) do
        if layout.name == name then
            return index, layout
        end
    end
    return nil, nil
end

-- Function to change current layout based on the name
function kbdcfg.switch_by_name(name)
    local index, layout = find_current_layout(name)
    kbdcfg.switch(layout)
end

-- Function to change layout
function kbdcfg.switch(layout)
    local index = find_current_layout(layout.name)
    kbdcfg.current = index

    if client.focus then
        local layout = kbdcfg.additional_layouts[kbdcfg.current]
        client.focus.kbd_layout = layout.name
    end

    if kbdcfg.type == "tui" then
        kbdcfg.widget:set_text(kbdcfg.tui_wrap_left .. layout.label .. kbdcfg.tui_wrap_right)
    else
        kbdcfg.widget.image = layout.label
    end

    os.execute(kbdcfg.cmd .. " \"" .. layout.subcmd .. "\"")
end

-- Function to add primary layouts
function kbdcfg.add_primary_layout(name, label, subcmd)
    local layout = { name   = name,
                     label  = label,
                     subcmd = subcmd };

    table.insert(kbdcfg.layouts, layout)
    table.insert(kbdcfg.additional_layouts, layout)
end

-- Function to add additional layouts
function kbdcfg.add_additional_layout(name, label, subcmd)
    local layout = { name   = name,
                     label  = label,
                     subcmd = subcmd };

    table.insert(kbdcfg.additional_layouts, layout)
end

-- Bind function. Applies all settings to the widget
function kbdcfg.bind()
    -- Menu for choose additional keyboard layouts
    local menu_items = {}

    for i = 1, #kbdcfg.additional_layouts do
        local layout = kbdcfg.additional_layouts[i]
        table.insert(menu_items, {
                         layout.name,
                         function () kbdcfg.switch(layout) end,
                         -- show a fancy image in gui mode
                         kbdcfg.type == "gui" and layout.label or nil
        })
    end

    kbdcfg.menu = awful.menu({ items = menu_items })

    if kbdcfg.type == "tui" then
        kbdcfg.widget = wibox.widget.textbox()
    else
        kbdcfg.widget = wibox.widget.imagebox()
    end

    if kbdcfg.default_layout_index > #kbdcfg.layouts then
        kbdcfg.default_layout_index = 1;
        kbdcfg.current = kbdcfg.default_layout_index;
    end

    if kbdcfg.remember_layout then
        client.connect_signal("focus", kbd_client_update)
    end

    local current_layout = kbdcfg.layouts[kbdcfg.current]
    if current_layout then
        kbdcfg.switch(current_layout)
    end
end

-- Callback function for set remembering layout for windows
function kbd_client_update(c)
    if not c then
        return
    end

    if not c.kbd_layout then
        c.kbd_layout = kbdcfg.layouts[kbdcfg.default_layout_index].name
    end

    kbdcfg.switch_by_name(c.kbd_layout)
end

-- Factory function. Creates the widget.
local function factory(args)
    local args                   = args or {}
    kbdcfg.cmd                   = args.cmd or "setxkbmap"
    kbdcfg.layouts               = args.layouts or {}
    kbdcfg.additional_layouts    = args.additional_layouts or {}
    kbdcfg.default_layout_index  = args.default_layout_index or 1
    kbdcfg.current               = args.current or kbdcfg.default_layout_index
    kbdcfg.menu                  = nil
    kbdcfg.type                  = args.type or "tui"
    kbdcfg.tui_wrap_left         = args.tui_wrap_left  or " "
    kbdcfg.tui_wrap_right        = args.tui_wrap_right or " "
    kbdcfg.remember_layout       = args.remember_layout or false

    for i = 1, #kbdcfg.layouts do
        table.insert(kbdcfg.additional_layouts, kbdcfg.layouts[i])
    end

    return kbdcfg
end

setmetatable(kbdcfg, { __call = function(_, ...) return factory(...) end })

return kbdcfg
