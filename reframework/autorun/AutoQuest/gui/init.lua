---@class Gui
---@field window GuiWindow
---@field state GuiState

---@class (exact) GuiWindow
---@field flags integer
---@field condition integer

local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local menu_bar = require("AutoQuest.gui.menu_bar")
local randomizer = require("AutoQuest.randomizer")
local routine_post = require("reframework.autorun.AutoQuest.routine_post")
local state = require("AutoQuest.gui.state")
local util_gui = require("AutoQuest.gui.util")
local util_imgui = require("AutoQuest.util.imgui.init")

local mod = data.mod
local snow = data.snow
local set = state.set

---@class Gui
local this = {
    window = {
        flags = 1024,
        condition = 2,
    },
    state = state,
}

local function draw_random_rampage()
    local config_mod = config.current.mod
    local disabled = config_mod.combo.mode == mod.enum.mod_mode.QUEST_COUNTER
        or config_mod.combo.quest ~= mod.enum.quest_board_quest.RANDOM_RAMPAGE

    if not disabled or not config_mod.hide_disabled then
        imgui.begin_disabled(disabled)
        util_imgui.separator_text(config.lang:tr("mod.category_random_rampage"))

        local config_key = "mod.combo.random_rampage_level"
        if
            set:combo(
                util_gui.tr("mod.combo_level", config_key),
                config_key,
                state.combo.random_rampage_level.values
            )
        then
            state.swap_rampage_target_combo(
                state.combo.random_rampage_level:get_key(config:get(config_key))
            )
        end

        config_key = "mod.combo.random_rampage_target"
        set:combo(
            util_gui.tr("mod.combo_rampage_target", config_key),
            config_key,
            state.combo.random_rampage_target.values
        )

        imgui.end_disabled()
    end
end

local function draw_random_random_mystery()
    local config_mod = config.current.mod
    local disabled = config_mod.combo.quest
            ~= mod.enum.quest_board_quest.RANDOM_SPECIAL_RANDOM_MYSTERY
        and config_mod.combo.quest ~= mod.enum.quest_board_quest.RANDOM_RANDOM_MYSTERY

    if not disabled or not config_mod.hide_disabled then
        imgui.begin_disabled(disabled)
        util_imgui.separator_text(config.lang:tr("mod.category_random_random_mystery"))
        local is_special = config_mod.combo.quest
            == mod.enum.quest_board_quest.RANDOM_SPECIAL_RANDOM_MYSTERY

        imgui.begin_disabled(is_special)
        local config_key = "mod.slider.random_mystery_lvl_min"
        set:slider_int(
            util_gui.tr("mod.slider_level_min"),
            config_key,
            1,
            300,
            string.format("%s %s", config:get(config_key), config.lang:tr("misc.text_or_higher"))
        )
        config_key = "mod.slider.random_mystery_lvl_max"
        set:slider_int(
            util_gui.tr("mod.slider_level_max"),
            config_key,
            1,
            300,
            string.format("%s %s", config:get(config_key), config.lang:tr("misc.text_or_lower"))
        )
        imgui.end_disabled()

        if config_mod.slider.random_mystery_lvl_min > config_mod.slider.random_mystery_lvl_max then
            config_mod.slider.random_mystery_lvl_min = config_mod.slider.random_mystery_lvl_max
        end

        config_key = "mod.combo.random_mystery_target"
        if
            set:combo(
                util_gui.tr("mod.combo_target", config_key),
                config_key,
                state.combo.random_mystery_target.values
            )
        then
            local em_id =
                state.combo.random_mystery_target:get_key(config_mod.combo.random_mystery_target)
            state.swap_random_mystery_lv_slider_by_em_id(em_id)
        end

        imgui.begin_disabled(is_special)
        if
            set:combo(
                util_gui.tr("mod.combo_item"),
                "mod.combo.random_mystery_item",
                state.combo.random_mystery_item.values
            )
        then
            local item_id =
                state.combo.random_mystery_item:get_key(config_mod.combo.random_mystery_item)
            state.swap_random_mystery_target_combo(item_id)
            state.swap_random_mystery_lv_slider_by_item_id(item_id)
        end
        imgui.end_disabled()

        set:combo(
            util_gui.tr("mod.combo_party_size"),
            "mod.combo.random_mystery_party_size",
            state.combo.random_mystery_party_size.values
        )

        imgui.end_disabled()
    end
end

local function draw_quest_board()
    local config_mod = config.current.mod
    local disabled = config_mod.combo.mode == mod.enum.mod_mode.QUEST_COUNTER

    if not disabled or not config_mod.hide_disabled then
        imgui.begin_disabled(disabled)

        util_imgui.separator_text(config.lang:tr("mod.category_quest_board"))
        set:combo(util_gui.tr("mod.combo_quest"), "mod.combo.quest", state.combo.quest.values)
        draw_random_random_mystery()
        draw_random_rampage()

        imgui.end_disabled()
    end
end

local function draw_servant()
    local config_mod = config.current.mod
    local disabled = not config_mod.bring_servant
        or config_mod.combo.mode == mod.enum.mod_mode.QUEST_BOARD

    if not disabled or not config_mod.hide_disabled then
        imgui.begin_disabled(disabled)
        util_imgui.separator_text(config.lang:tr("mod.category_servant"))

        for i = 1, 2 do
            local follower_key = "servant" .. i
            local follower_config_key = "mod.combo." .. follower_key
            local weapon_key = follower_key .. "_weapon"
            local weapon_config_key = "mod.combo." .. weapon_key

            if
                set:combo(
                    string.format("%s %s", config.lang:tr("mod.combo_servant"), i),
                    follower_config_key,
                    state.combo[follower_key].values
                )
            then
                state.swap_servant_weapon_combo(
                    state.combo[weapon_key],
                    weapon_config_key,
                    state.combo[follower_key]:get_key(config:get(follower_config_key))
                )
            end

            imgui.begin_disabled(config:get(follower_config_key) == mod.enum.servant_type.NONE)
            set:combo(
                util_gui.tr("mod.combo_servant_weapon", weapon_config_key),
                weapon_config_key,
                state.combo[weapon_key].values
            )
            imgui.end_disabled()
        end

        imgui.end_disabled()
    end
end

function this.draw()
    local gui_main = config.gui.current.gui.main
    local config_mod = config.current.mod

    imgui.set_next_window_pos(Vector2f.new(gui_main.pos_x, gui_main.pos_y), this.window.condition)
    imgui.set_next_window_size(
        Vector2f.new(gui_main.size_x, gui_main.size_y),
        this.window.condition
    )

    if config.lang.font then
        imgui.push_font(config.lang.font)
    end

    gui_main.is_opened = imgui.begin_window(
        string.format("%s %s", config.name, config.commit),
        gui_main.is_opened,
        this.window.flags
    )

    util_imgui.set_win_state(gui_main)

    if not gui_main.is_opened then
        if config.lang.font then
            imgui.pop_font()
        end

        config.save_global()
        menu_bar.quest_ref.items = nil
        imgui.end_window()
        return
    end

    if imgui.begin_menu_bar() then
        menu_bar.draw()
        imgui.end_menu_bar()
    end

    imgui.spacing()
    imgui.indent(2)

    if imgui.button(util_gui.tr("actions.button_post")) then
        routine_post.new()
    end
    imgui.same_line()
    if imgui.button(util_gui.tr("actions.button_randomize")) then
        randomizer.roll()
    end

    imgui.separator()

    imgui.begin_disabled(
        config_mod.combo.mode == mod.enum.mod_mode.QUEST_BOARD
            and config_mod.combo.quest ~= mod.enum.quest_board_quest.SPECIFIC
    )
    set:input_text(util_gui.tr("mod.input_quest_id"), "mod.quest_id")
    imgui.end_disabled()
    local quest_name = config.lang:tr("misc.text_none")
    local quest = snow.map.quest_data[config_mod.quest_id]

    if quest then
        quest_name = string.format(
            "%s | %s | %s",
            quest.title,
            quest.map_name,
            util_gui.format_quest_level(quest)
        )
    end
    util_imgui.tooltip(quest_name)

    imgui.begin_disabled(routine_post.has_instance())
    set:combo(util_gui.tr("mod.combo_mode"), "mod.combo.mode", state.combo.mode.values)
    draw_servant()
    draw_quest_board()
    imgui.end_disabled()

    imgui.unindent(3)

    if config.lang.font then
        imgui.pop_font()
    end

    imgui.spacing()
    imgui.end_window()
end

---@return boolean
function this.init()
    state.init()
    return true
end

return this
