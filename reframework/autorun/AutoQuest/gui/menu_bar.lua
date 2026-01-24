local bind_manager = require("AutoQuest.bind.init")
local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local gui_util = require("AutoQuest.gui.util")
local randomizer = require("AutoQuest.randomizer")
local state = require("AutoQuest.gui.state")
local util_bind = require("AutoQuest.util.game.bind.init")
local util_imgui = require("AutoQuest.util.imgui.init")
local util_table = require("AutoQuest.util.misc.table")

local mod = data.mod
local set = state.set

local this = {
    quest_ref = {
        table = {
            name = "quest_ref",
            flags = 1 << 8 | 1 << 7 | 1 << 10 | 1 << 25 | 3 << 13 | 1 << 0,
        },
        ---@type Quest[]?
        items = nil,
        changed = false,
    },
}

---@param label string
---@param draw_func fun()
---@param enabled_obj boolean?
---@param text_color integer?
---@param size number[]?
---@return boolean
local function draw_menu(label, draw_func, enabled_obj, text_color, size)
    enabled_obj = enabled_obj == nil and true or enabled_obj

    if text_color then
        imgui.push_style_color(0, text_color)
    end

    if size then
        imgui.set_next_window_size(size)
    end

    local menu = imgui.begin_menu(label, enabled_obj)

    if text_color then
        imgui.pop_style_color(1)
    end

    if menu then
        draw_func()
        imgui.end_menu()
    end

    return menu
end

local function draw_mod_menu()
    imgui.push_style_var(14, Vector2f.new(0, 2))

    set:menu_item(gui_util.tr("options.box_auto_post"), "mod.auto_post")
    util_imgui.tooltip(config.lang:tr("options.tooltip_auto_post"))
    set:menu_item(gui_util.tr("options.box_auto_depart"), "mod.auto_depart")
    util_imgui.tooltip(config.lang:tr("options.tooltip_auto_depart"))
    set:menu_item(gui_util.tr("options.box_auto_randomize"), "mod.auto_randomize")
    util_imgui.tooltip(config.lang:tr("options.tooltip_auto_randomize"))
    set:menu_item(gui_util.tr("options.box_send_join_request"), "mod.send_join_request")
    util_imgui.tooltip(config.lang:tr("options.tooltip_send_join_request"))
    set:menu_item(gui_util.tr("options.box_bring_servant"), "mod.bring_servant")
    util_imgui.tooltip(config.lang:tr("options.tooltip_bring_servant"))

    imgui.separator()

    set:menu_item(gui_util.tr("menu.config.enable_key_binds"), "mod.enable_key_binds")
    set:menu_item(gui_util.tr("menu.config.enable_notification"), "mod.enable_notification")
    set:menu_item(gui_util.tr("menu.config.hide_disabled"), "mod.hide_disabled")
    util_imgui.tooltip(config.lang:tr("menu.config.tooltip_hide_disabled"))

    imgui.pop_style_var(1)
end

local function draw_lang_menu()
    local config_lang = config.current.mod.lang
    imgui.push_style_var(14, Vector2f.new(0, 2))

    for i = 1, #config.lang.sorted do
        local menu_item = config.lang.sorted[i]
        if util_imgui.menu_item(menu_item, config_lang.file == menu_item) then
            config_lang.file = menu_item
            config.lang:change()
            state.translate_combo()
            config:save()
        end
    end

    imgui.separator()

    set:menu_item(gui_util.tr("menu.language.fallback"), "mod.lang.fallback")
    util_imgui.tooltip(config.lang:tr("menu.language.fallback_tooltip"))

    imgui.pop_style_var(1)
end

local function draw_bind_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_mod = config.current.mod

    if
        set:slider_int(
            gui_util.tr("menu.bind.slider_buffer"),
            "mod.bind.buffer",
            1,
            11,
            config_mod.bind.buffer - 1 == 0 and config.lang:tr("misc.text_disabled")
                or config_mod.bind.buffer - 1 == 1 and string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame")
                )
                or string.format(
                    "%s %s",
                    config_mod.bind.buffer - 1,
                    config.lang:tr("misc.text_frame_plural")
                )
        )
    then
        bind_manager.monitor:set_max_buffer_frame(config_mod.bind.buffer)
    end
    util_imgui.tooltip(config.lang:tr("menu.bind.tooltip_buffer"))

    imgui.separator()
    imgui.begin_disabled(state.listener ~= nil)

    local manager = bind_manager.action
    local config_key = "mod.bind.action"
    set:combo("##bind_action_combo", "mod.combo.key_bind.action", state.combo.action.values)

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.bind.button_add")) then
        state.listener = {
            opt = state.combo.action:get_key(config_mod.combo.key_bind.action),
            listener = util_bind.listener:new(),
            opt_name = state.combo.action:get_value(config_mod.combo.key_bind.action),
        }
    end

    imgui.end_disabled()

    if state.listener then
        bind_manager.monitor:pause()

        imgui.separator()

        local bind = state.listener.listener:listen() --[[@as ModBind]]
        ---@type string[]
        local bind_name

        if bind.name_display ~= "" then
            bind_name = { bind.name_display, "..." }
        else
            bind_name = { config.lang:tr("menu.bind.text_default") }
        end

        imgui.begin_table("keybind_listener", 1, 1 << 9)
        imgui.table_next_row()

        util_imgui.adjust_pos(0, 3)

        imgui.table_set_column_index(0)

        if manager:is_valid(bind) then
            bind.bound_value = state.listener.opt

            local is_col, col = manager:is_collision(bind)
            if is_col and col then
                state.listener.collision = string.format(
                    "%s %s",
                    config.lang:tr("menu.bind.tooltip_bound"),
                    config.lang:tr("actions." .. mod.map.actions[col.bound_value])
                )
            else
                state.listener.collision = nil
            end
        else
            state.listener.collision = nil
        end

        imgui.begin_disabled(state.listener.collision ~= nil or bind.name == "")

        local save_button = imgui.button(gui_util.tr("menu.bind.button_save"))

        if save_button then
            manager:register(bind)
            config:set(config_key, manager:get_base_binds())

            config:save()
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_disabled()
        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.button_clear")) then
            state.listener.listener:clear()
        end

        imgui.same_line()

        if imgui.button(gui_util.tr("menu.bind.button_cancel")) then
            state.listener = nil
            bind_manager.monitor:unpause()
        end

        imgui.end_table()
        imgui.separator()

        if state.listener and state.listener.collision then
            imgui.text_colored(state.listener.collision, state.colors.bad)
            imgui.separator()
        end

        imgui.text(table.concat(bind_name, " + "))
        imgui.separator()
    end

    if
        not util_table.empty(config:get(config_key))
        and imgui.begin_table("keybind_state", 3, 1 << 9)
    then
        imgui.separator()

        ---@type ModBind[]
        local remove = {}
        local binds = config:get(config_key) --[=[@as ModBind[]]=]
        for i = 1, #binds do
            local bind = binds[i]
            imgui.table_next_row()
            imgui.table_set_column_index(0)

            if
                imgui.button(gui_util.tr("menu.bind.button_remove", bind.name, bind.bound_value))
            then
                table.insert(remove, bind)
            end

            imgui.table_set_column_index(1)
            imgui.text(config.lang:tr(mod.map.actions[bind.bound_value]))
            imgui.table_set_column_index(2)
            imgui.text(bind.name_display)
        end

        if not util_table.empty(remove) then
            for _, bind in pairs(remove) do
                manager:unregister(bind)
            end

            config:set(config_key, manager:get_base_binds())
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

---@param key string
---@param max integer
---@return boolean
local function draw_star_boxes(key, max)
    local changed = false
    for i = 0, max do
        local key_i = key .. i
        changed = set:checkbox(
            string.format("%s%s##%s", config.lang:tr("misc.text_star"), i + 1, key_i),
            "mod.randomizer." .. key_i
        ) or changed
    end

    return changed
end

local function draw_randomizer_settings_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_randomizer = config.current.mod.randomizer
    local changed = false

    util_imgui.separator_text(config.lang:tr("menu.randomizer.category_quest_rank"))
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_village"),
        "mod.randomizer.exclude_village"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_low_rank"),
        "mod.randomizer.exclude_low_rank"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_high_rank"),
        "mod.randomizer.exclude_high_rank"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_master_rank"),
        "mod.randomizer.exclude_master_rank"
    ) or changed
    util_imgui.tooltip(config.lang:tr("menu.randomizer.tooltip_exclude_master_rank"))

    util_imgui.separator_text(config.lang:tr("menu.randomizer.category_quest_level"))
    imgui.begin_disabled(config_randomizer.exclude_master_rank)

    if imgui.tree_node(gui_util.tr("menu.randomizer.category_exclude_master_rank_level")) then
        changed = draw_star_boxes("exclude_master_rank", 5) or changed
        imgui.tree_pop()
    end

    imgui.end_disabled()
    imgui.begin_disabled(config_randomizer.exclude_mystery)

    if imgui.tree_node(gui_util.tr("menu.randomizer.category_exclude_mystery_level")) then
        changed = draw_star_boxes("exclude_mystery", 8) or changed
        imgui.tree_pop()
    end

    imgui.end_disabled()
    imgui.begin_disabled(config_randomizer.exclude_random_mystery)

    if imgui.tree_node(gui_util.tr("menu.randomizer.category_exclude_random_mystery_level")) then
        local config_key = "mod.randomizer.exclude_random_mystery_below"
        local value = config:get(config_key)

        changed = set:slider_int(
            gui_util.tr("menu.randomizer.slider_exclude_random_mystery_below"),
            config_key,
            0,
            300,
            value == 0 and config.lang:tr("misc.text_disabled") or value
        ) or changed

        config_key = "mod.randomizer.exclude_random_mystery_above"
        value = config:get(config_key)
        changed = set:slider_int(
            gui_util.tr("menu.randomizer.slider_exclude_random_mystery_above"),
            config_key,
            0,
            300,
            value == 0 and config.lang:tr("misc.text_disabled") or value
        ) or changed

        imgui.tree_pop()
    end

    imgui.end_disabled()

    util_imgui.separator_text(config.lang:tr("menu.randomizer.category_quest_category"))
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_mystery"),
        "mod.randomizer.exclude_mystery"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_special_random_mystery"),
        "mod.randomizer.exclude_special_random_mystery"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_random_mystery"),
        "mod.randomizer.exclude_random_mystery"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_normal"),
        "mod.randomizer.exclude_normal"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_rampage"),
        "mod.randomizer.exclude_rampage"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_random_rampage"),
        "mod.randomizer.exclude_random_rampage"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_arena"),
        "mod.randomizer.exclude_arena"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_servant_request"),
        "mod.randomizer.exclude_servant_request"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_kingdom"),
        "mod.randomizer.exclude_kingdom"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_event"),
        "mod.randomizer.exclude_event"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_training"),
        "mod.randomizer.exclude_training"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_tour"),
        "mod.randomizer.exclude_tour"
    ) or changed

    util_imgui.separator_text(config.lang:tr("menu.randomizer.category_quest_type"))
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_capture"),
        "mod.randomizer.exclude_capture"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_slay"),
        "mod.randomizer.exclude_slay"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_hunt"),
        "mod.randomizer.exclude_hunt"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_boss_rush"),
        "mod.randomizer.exclude_boss_rush"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_gathering"),
        "mod.randomizer.exclude_gathering"
    ) or changed

    util_imgui.separator_text(config.lang:tr("menu.randomizer.category_other"))
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_non_online"),
        "mod.randomizer.exclude_non_online"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_zako"),
        "mod.randomizer.exclude_zako"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_one"),
        "mod.randomizer.exclude_one"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_multi"),
        "mod.randomizer.exclude_multi"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_lock"),
        "mod.randomizer.exclude_lock"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_complete"),
        "mod.randomizer.exclude_complete"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_invalid_random_mystery"),
        "mod.randomizer.exclude_invalid_random_mystery"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_custom"),
        "mod.randomizer.exclude_custom"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_no_custom"),
        "mod.randomizer.exclude_no_custom"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_exclude_post"),
        "mod.randomizer.exclude_post"
    ) or changed
    changed = set:checkbox(
        gui_util.tr("menu.randomizer.box_prefer_research_target"),
        "mod.randomizer.prefer_research_target"
    ) or changed
    util_imgui.tooltip(config.lang:tr("menu.randomizer.tooltip_prefer_research_target"))

    if changed then
        randomizer.filter_quests()
        this.quest_ref.changed = true
    end

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_randomizer_menu()
    imgui.spacing()
    imgui.indent(2)

    if imgui.button(gui_util.tr("menu.randomizer.button_reset")) then
        config.current.mod.randomizer = util_table.deep_copy(config.default.mod.randomizer)
        randomizer.filter_quests()
        this.quest_ref.changed = true
    end

    imgui.same_line()

    if imgui.button(gui_util.tr("menu.randomizer.button_reset_post")) then
        randomizer.posted_quests:clear()
    end

    imgui.separator()
    imgui.text(config.lang:tr("menu.randomizer.text_quests") .. #randomizer.filtered)
    imgui.text(config.lang:tr("menu.randomizer.text_post_quest") .. randomizer.posted_quests:size())
    imgui.separator()
    imgui.unindent(2)

    if
        set:menu_item(
            gui_util.tr("options.box_filter_quest_reference"),
            "mod.filter_quest_reference"
        )
    then
        this.quest_ref.changed = true
    end

    imgui.separator()
    imgui.indent(2)

    draw_menu(
        gui_util.tr("menu.randomizer.item_settings"),
        draw_randomizer_settings_menu,
        nil,
        nil,
        { 450, 0 }
    )

    imgui.unindent(2)
    imgui.spacing()
end

local function draw_quest_ref_menu()
    imgui.spacing()
    imgui.indent(2)

    local config_quest_ref = config.current.mod.quest_ref

    imgui.set_next_item_width(-1)
    if
        set:input_text("##quest_ref_filter", "mod.quest_ref.filter_text")
        or not this.quest_ref.items
        or this.quest_ref.changed
    then
        this.quest_ref.changed = false
        this.quest_ref.items = {}
        local t = (config.current.mod.filter_quest_reference and randomizer.filtered)
            or data.snow.map.quest_data
        local query = config_quest_ref.filter_text:lower()
        for _, quest in pairs(t) do
            local name = quest.title:lower()
            if query == "" or name:find(query) ~= nil then
                table.insert(this.quest_ref.items, quest)
            end
        end

        table.sort(this.quest_ref.items, function(a, b)
            return a.no < b.no
        end)
    end

    util_imgui.tooltip(config.lang:tr("menu.quest_ref.tooltip_input_filter"))

    if
        imgui.begin_table(
            this.quest_ref.table.name,
            4,
            this.quest_ref.table.flags --[[@as ImGuiTableFlags]],
            Vector2f.new(0, 10 * 28)
        )
    then
        imgui.table_setup_column(gui_util.tr("menu.quest_ref.header_name"))
        imgui.table_setup_column(gui_util.tr("menu.quest_ref.header_map"))
        imgui.table_setup_column(gui_util.tr("menu.quest_ref.header_level"))
        imgui.table_setup_column(gui_util.tr("menu.quest_ref.header_id"))
        imgui.table_headers_row()

        for row = 1, #this.quest_ref.items do
            local quest = this.quest_ref.items[row]
            imgui.table_next_row()
            imgui.table_set_column_index(0)
            imgui.text(quest.title)
            imgui.table_set_column_index(1)
            imgui.text(quest.map_name)
            imgui.table_set_column_index(2)
            imgui.text(gui_util.format_quest_level(quest))
            imgui.table_set_column_index(3)
            if imgui.button(quest.no_key) then
                config.current.mod.quest_id = quest.no_key
            end
            util_imgui.tooltip(config.lang:tr("menu.quest_ref.tooltip_quest_no"))
        end

        imgui.end_table()
    end

    imgui.unindent(2)
    imgui.spacing()
end

function this.draw()
    draw_menu(gui_util.tr("menu.config.name"), draw_mod_menu)
    draw_menu(gui_util.tr("menu.language.name"), draw_lang_menu)

    if not draw_menu(gui_util.tr("menu.bind.name"), draw_bind_menu) then
        if state.listener then
            state.listener = nil
            bind_manager.monitor:unpause()
        end
    end

    draw_menu(gui_util.tr("menu.randomizer.name"), draw_randomizer_menu)
    draw_menu(gui_util.tr("menu.quest_ref.name"), draw_quest_ref_menu, nil, nil, { 500, 0 })
end

return this
