local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local game_data = require("AutoQuest.util.game.data")
local gui_state = require("AutoQuest.gui.state")
local randomizer = require("AutoQuest.randomizer")
local routine_post = require("reframework.autorun.AutoQuest.routine_post")
local s = require("AutoQuest.util.ref.singletons")
local util_ref = require("AutoQuest.util.ref.init")
local util_table = require("AutoQuest.util.misc.table")

local snow_enum = data.snow.enum
local mod_enum = data.mod.enum
local rl = game_data.reverse_lookup

local this = {}

function this.quest_activate_post(retval)
    local qi = s.get("snow.QuestManager")._QuestIdentifier
    config.current.mod.quest_id = tostring(qi._QuestNo)
end

function this.get_selected_quest_post(retval)
    if routine_post.has_instance() then
        local quest = routine_post.get_quest()
        if quest.category == mod_enum.quest_category.RANDOM_RAMPAGE then
            return data.get_rampage_quest_data(quest.no)
        end

        return s.get("snow.QuestManager"):call("getQuestData(System.Int32)", quest.no)
    end
end

function this.ret_true_post(retval)
    if routine_post.has_instance() then
        return true
    end
end

function this.skip_func_pre(args)
    if routine_post.has_instance() then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.set_quest_counter_type_pre(args)
    if routine_post.has_instance() then
        local quest_counter = sdk.to_managed_object(args[2]) --[[@as snow.gui.fsm.questcounter.GuiQuestCounterFsmManager]]
        local mode = config.current.mod.combo.mode
        local enum_mode = mod_enum.mod_mode

        if mode == enum_mode.QUEST_BOARD then
            s.get("snow.gui.GuiManager"):set_IsActivateQuestCounterFromQuestBoard(true)
            quest_counter:set__BoardOrderNum(
                gui_state.combo.random_mystery_party_size:get_key(
                    config.current.mod.combo.random_mystery_party_size
                )
            )
        end

        quest_counter:set_QuestCounterType(rl(snow_enum.quest_counter_type, "HallCounter"))
    end
end

function this.quest_counter_sub_menu_check_pre(args)
    if routine_post.has_instance() then
        local quest = routine_post.get_quest()
        local type = util_ref.to_int(args[3])
        local is_type_special = type
            == rl(snow_enum.quest_counter_sub_menu_type, "Special_Random_Mystery")
        local is_type_random = type == rl(snow_enum.quest_counter_sub_menu_type, "Random_Mystery")

        local mode = config.current.mod.combo.mode
        local quest_board_quest = config.current.mod.combo.quest
        local enum_category = mod_enum.quest_category
        local enum_quest = mod_enum.quest_board_quest
        local enum_mode = mod_enum.mod_mode

        if mode == enum_mode.QUEST_COUNTER then
            if
                (quest.category == enum_category.SPECIAL_RANDOM_MYSTERY and is_type_special)
                or (quest.category == enum_category.RANDOM_MYSTERY and is_type_random)
            then
                ---@diagnostic disable-next-line: no-unknown
                thread.get_hook_storage()["ret"] = true
            end
        elseif
            mode == mod_enum.mod_mode.QUEST_BOARD
            and (
                (quest_board_quest == enum_quest.RANDOM_SPECIAL_RANDOM_MYSTERY and is_type_special)
                or (quest_board_quest == enum_quest.RANDOM_RANDOM_MYSTERY and is_type_random)
                or quest_board_quest == enum_quest.RANDOM_RAMPAGE
                    and type == rl(snow_enum.quest_counter_sub_menu_type, "Hyakuryu")
            )
        then
            ---@diagnostic disable-next-line: no-unknown
            thread.get_hook_storage()["ret"] = true
        end
    end
end

function this.update_yn_post(retval)
    if
        routine_post.has_instance()
        and config.current.mod.combo.mode == mod_enum.mod_mode.QUEST_COUNTER
    then
        return rl(snow_enum.yn_ui_state, "Yes_on")
    end
end

function this.force_decide_post(retval)
    --[[
        FIXME: update_yn_post instantly cancels the yn window when the quest board is open, but works fine when the quest counter is open.
        Manual clicking or this workaround works perfectly fine...
    ]]
    if
        routine_post.has_instance()
        and config.current.mod.combo.mode == mod_enum.mod_mode.QUEST_BOARD
        and routine_post.is_state(routine_post.state.WAIT_COMPLETE)
    then
        return true
    end
end

function this.quest_start_pre(args)
    randomizer.posted_quests:set(config.current.mod.quest_id, true)
    randomizer.posted_quests:dump()
end

function this.skip_sound_pre(args)
    if routine_post.has_instance() then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end

function this.quick_quest_post(retval)
    if
        routine_post.has_instance()
        and config.current.mod.combo.mode == mod_enum.mod_mode.QUEST_BOARD
    then
        local quest = config.current.mod.combo.quest
        local enum_quest = mod_enum.quest_board_quest
        local random = util_table.find({
            enum_quest.RANDOM_HIGH_RANK,
            enum_quest.RANDOM_LOW_RANK,
            enum_quest.RANDOM_MASTER_RANK,
            enum_quest.RANDOM_MYSTERY,
            ---@diagnostic disable-next-line: param-type-mismatch
        }, quest)

        if not random then
            return
        end

        local enum_top = snow_enum.quest_counter_top_menu_type
        if random == enum_quest.RANDOM_LOW_RANK then
            return rl(enum_top, "Normal_Hall_Low")
        elseif random == enum_quest.RANDOM_HIGH_RANK then
            return rl(enum_top, "Normal_Hall_High")
        elseif random == enum_quest.RANDOM_MASTER_RANK then
            return rl(enum_top, "Normal_Hall_Master")
        elseif random == enum_quest.RANDOM_MYSTERY then
            return rl(enum_top, "Mystery")
        end
    end
end

function this.thread_ret_post(retval)
    local ret = thread.get_hook_storage()["ret"] --[[@as boolean?]]
    if ret ~= nil then
        return ret
    end
end

function this.get_rampage_target_post(retval)
    local config_combo = config.current.mod.combo
    if routine_post.has_instance() and config_combo.mode == mod_enum.mod_mode.QUEST_BOARD then
        if config_combo.quest == mod_enum.quest_board_quest.RANDOM_RAMPAGE then
            return gui_state.combo.random_rampage_target:get_key(config_combo.random_rampage_target)
        elseif
            config_combo.quest == mod_enum.quest_board_quest.RANDOM_RANDOM_MYSTERY
            or config_combo.quest == mod_enum.quest_board_quest.RANDOM_SPECIAL_RANDOM_MYSTERY
        then
            return gui_state.combo.random_mystery_target:get_key(config_combo.random_mystery_target)
        end
    end
end

function this.get_random_mystery_lv_min_post(retval)
    local config_mod = config.current.mod
    local config_combo = config_mod.combo
    if
        routine_post.has_instance()
        and config_combo.mode == mod_enum.mod_mode.QUEST_BOARD
        and config_combo.quest == mod_enum.quest_board_quest.RANDOM_RANDOM_MYSTERY
    then
        return config_mod.slider.random_mystery_lvl_min
    end
end

function this.get_random_mystery_lv_max_post(retval)
    local config_mod = config.current.mod
    local config_combo = config_mod.combo
    if
        routine_post.has_instance()
        and config_combo.mode == mod_enum.mod_mode.QUEST_BOARD
        and config_combo.quest == mod_enum.quest_board_quest.RANDOM_RANDOM_MYSTERY
    then
        return config_mod.slider.random_mystery_lvl_max
    end
end

function this.get_random_mystery_item_post(retval)
    local config_combo = config.current.mod.combo
    if routine_post.has_instance() and config_combo.mode == mod_enum.mod_mode.QUEST_BOARD then
        if
            config_combo.quest == mod_enum.quest_board_quest.RANDOM_RANDOM_MYSTERY
            or config_combo.quest == mod_enum.quest_board_quest.RANDOM_SPECIAL_RANDOM_MYSTERY
        then
            return gui_state.combo.random_mystery_item:get_key(config_combo.random_mystery_item)
        end
    end
end

return this
