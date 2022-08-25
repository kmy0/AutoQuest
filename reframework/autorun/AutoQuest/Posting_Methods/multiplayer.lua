local multiplayer = {}
local config
local singletons
local methods
local functions
local vars
local dump

local menu_list_type_def = sdk.find_type_definition('snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase')
local quest_counter_type_def = sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')

local loop_count = 0
local loop_max = 100
local target_name = nil

local quest_counter_obj_ids = {
            [0]='nid002', --village
            [3]='nid102', --hub
            [6]='nid601'  --elgado
}
local quest_counter_top_menu_types = {
                        [7]=true, --Arena
                        [8]=true, --Challenge
                        [5]=true, --Event
                        [1]=true, --Normal_Hall_High
                        [20]=true, --Normal_Hall_HighLow
                        [2]=true, --Normal_Hall_Low
                        [12]=true, --Normal_Hall_Master
                        [4]=true, --Training
                        [13]=false --Mystery
}

local function select_mystery_quest()
    local quest_counter_singleton = sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')
    local menu_list = methods.get_active_menu_quest_list:call(quest_counter_singleton)
    local menu_list_size = menu_list:get_field('mSize')
    vars.cursor = quest_counter_type_def:get_field('<QuestMenuCursor>k__BackingField'):get_data()
    for i=0,menu_list_size do
        local quest = menu_list:call('get_Item',i)
        local quest_no = quest:get_field('<RandomMystery>k__BackingField'):get_field('_QuestNo')
        if quest_no == tonumber(config.current.auto_quest.quest_no) then
            methods.menu_list_cursor_set_index:call(vars.cursor,i)
            vars.selection_trigger = i
            return true
        end
    end
    return false
end

local function get_quest_counter_menu()
    local quest_counter_menu_list = quest_counter_type_def:get_field('<QuestCounterTopMenuList>k__BackingField'):get_data()
    vars.cursor = quest_counter_type_def:get_field('<TopMenuCursor>k__BackingField'):get_data()
    local quest_counter_menu_list_size = quest_counter_menu_list:get_field('mSize')
    local cursor_index = methods.menu_list_cursor_get_index:call(vars.cursor)
    local menu_id = quest_counter_menu_list:call('get_Item',cursor_index)
    local bool = nil

    -- if not dump.ed then dump.quest_data() end

    if dump.quest_data_list[tonumber(config.current.auto_quest.quest_no)]['category'] == 'Random Mystery' then
        vars.quest_type = 'Random Mystery'
        bool = false
    else
        vars.quest_type = "Normal"
        bool = true
    end

    if quest_counter_top_menu_types[menu_id] ~= bool then
        for i=0,quest_counter_menu_list_size-1 do
            menu_id = quest_counter_menu_list:call('get_Item',i)
            if quest_counter_top_menu_types[menu_id] == bool then
                methods.menu_list_cursor_set_index:call(vars.cursor,i)
                vars.selection_trigger = i
                return true
            end
        end
    else
        vars.selected = true
        return true
    end
    return false
end

local function select_index_selection_window(index)
    local select_window_scroll_list = singletons.guiman:get_field('<refGuiCommonSelectWindow>k__BackingField'):get_field('_ScrollListCtrl')
    vars.cursor = menu_list_type_def:get_field('_Cursor'):get_data(select_window_scroll_list)
    methods.menu_list_cursor_set_index:call(vars.cursor,index)
    vars.selection_trigger = index
end

function multiplayer.switch()
    function functions.post_quest()
        local random_pool = true
        if methods.can_open_quest_board:call(singletons.guiman) then
            if not methods.is_quest_posted:call(singletons.questman) then
                target_name = quest_counter_obj_ids[ singletons.vilman:get_field('<_CurrentAreaNo>k__BackingField') ]
                if target_name then
                    if config.current.auto_quest.auto_randomize then
                        random_pool = randomizer.roll()
                    end
                    local quest_data = dump.quest_data_list[tonumber(config.current.auto_quest.quest_no)]
                    if quest_data and random_pool then
                        vars.posting = true
                    elseif not quest_data then
                        functions.error_handler("Invalid Quest ID.")
                    end
                elseif not target_name then
                    functions.error_handler("Can't post in this area.")
                end
            end
        end
    end
end

function multiplayer.hook()
    sdk.hook(methods.quest_session_action_update,
        function(args)
            if config.current.auto_quest.posting_method == 2 then
                if vars.posting and config.current.auto_quest.send_join_request and not vars.selection_trigger and not vars.selected and methods.is_internet:call(nil) then
                    select_index_selection_window(1)
                elseif vars.posting and config.current.auto_quest.send_join_request and vars.selected then
                    vars.decide_trigger = true
                    vars.selected = false
                end
            end
        end
    )

    sdk.hook(methods.quest_session_action_start,
        function(args)
            if config.current.auto_quest.posting_method == 2 then
                if vars.posting and config.current.auto_quest.send_join_request then
                    vars.decide_trigger = false
                end
            end
        end
    )

    sdk.hook(methods.set_quest_counter_state,function(args)end,
        function(args)
            if config.current.auto_quest.posting_method == 2 then
                vars.quest_counter_open = true
                if vars.posting then
                    vars.interact_trigger = false

                    if get_quest_counter_menu() then
                        vars.decide_trigger = true
                    else
                        vars.close_trigger = true
                        functions.error_handler("Can't post chosen quest type.")
                    end

                end
            end
        end
    )

    sdk.hook(methods.quest_id_reset,
        function(args)
            if config.current.auto_quest.posting_method == 2 then
                if config.current.auto_quest.keep_rng then
                    args[3] = sdk.to_ptr(false)
                end
            end
        end
    )

    sdk.hook(methods.decide_button,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 2 then
                local current_menu = nil
                if vars.decide_trigger then

                    current_menu = quest_counter_type_def:get_field('<QuestCounterState>k__BackingField'):get_data()

                end
                if vars.decide_trigger and vars.selected or vars.decide_trigger and vars.quest_type == 'Normal' and current_menu ~= 0 then

                    vars.selected = false
                    return sdk.to_ptr(true)

                elseif vars.decide_trigger and current_menu == 30 and not vars.selection_trigger then

                    if not select_mystery_quest() then vars.selected = nil end
                    return retval

                elseif vars.decide_trigger and vars.selected == nil then

                    vars.posting = false
                    vars.decide_trigger = false
                    vars.close_trigger = true
                    functions.error_handler("Menu selection timeout.")
                    return retval

                elseif vars.decide_trigger and not vars.selected and vars.quest_type == 'Normal' then

                    return sdk.to_ptr(true)

                else
                    return retval
                end
            else
                return retval
            end
        end
    )

    sdk.hook(methods.quest_counter_on_destroy,
        function(args)
            if config.current.auto_quest.posting_method == 2 then
                if vars.posting then
                    vars.posting = false
                    vars.close_trigger = false
                    vars.decide_trigger = false
                end
                dump.random_mystery()
                vars.quest_counter_open = false
            end

        end
    )

    sdk.hook(methods.pop_sensor_check_access,
        function(args)
            if config.current.auto_quest.posting_method == 2 and vars.posting then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end,
        function(retval)
            if config.current.auto_quest.posting_method == 2 then
                if vars.posting and target_name then
                    local name = nil
                    local sensor = methods.get_sensor:call(singletons.objaccman,1)
                    local obj = methods.pop_sensor_get_access_target:call(sensor)

                    if obj then
                        name = methods.get_gameobject_name:call(obj)
                        if loop_count == loop_max then
                            vars.posting = false
                            vars.quest_counter_open = false
                            target_name = nil
                            loop_count = 0
                            functions.error_handler("Failed to find Quest Counter NPC\nMove closer and try again.")
                            return retval
                        end

                        if name == target_name then
                            target_name = nil
                            vars.interact_trigger = true
                            loop_count = 0
                        else
                            methods.focus_next_target:call(singletons.objaccman)
                        end
                    end
                    loop_count = loop_count + 1
                    return sdk.to_ptr(true)
                else
                    return retval
                end
            else
                return retval
            end
        end
    )

    sdk.hook(methods.interact_button,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 2 then
                if vars.interact_trigger then return sdk.to_ptr(true) else return retval end
            else
                return retval
            end
        end
    )

end

function multiplayer.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    dump = require("AutoQuest.dump")
    config = require("AutoQuest.config")
    randomizer = require("AutoQuest.randomizer")
    multiplayer.hook()
end

return multiplayer