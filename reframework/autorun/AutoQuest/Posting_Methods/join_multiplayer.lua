local join_multiplayer = {}
local vars
local singletons
local methods
local config
local functions

local quest_counter_type_def = sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')
local quest_counter_menu_type_def = sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterMenu')
local menu_list_type_def = sdk.find_type_definition('snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase')

local auto_join_trigger = false
local auto_join_timer = 0
local auto_join_timer_max = 1500
local order_index = 1
local quest_board_quest_list_index = 0
local quest_counter_menu_index = 1
local set_ano_inv_fields = true
local menu_type = nil
local hall_status = nil

local quest_board_menu_fields = {
                    top={
                        list='<QuestCounterTopMenuList>k__BackingField',
                        cursor='<TopMenuCursor>k__BackingField',
                        type_def=quest_counter_type_def
                    },
                    sub={
                        list='<QuestCounterSubMenuList>k__BackingField',
                        cursor='<SubMenuCursor>k__BackingField',
                        type_def=quest_counter_type_def
                    },
                    level={
                        list='<QuestLevelMenuList>k__BackingField',
                        cursor='<LevelMenuCursor>k__BackingField',
                        type_def=quest_counter_type_def
                    },
                    quest_counter_menu={
                        list=nil,
                        cursor='<ParticipationTopCursor>k__BackingField',
                        type_def=quest_counter_menu_type_def
                    },
                    quest_counter_menu_clickthrough={
                        list=nil,
                        cursor='<ParticipationTopCursor>k__BackingField',
                        type_def=quest_counter_menu_type_def
                    }
}
local quest_board_menu_id = {
                        [2]={ --investigations
                            top=13,
                            sub=5,
                            quest_counter_menu={0,1,4},
                            order={
                                'top',
                                'sub',
                                'quest_counter_menu',
                                'quest_counter_menu_clickthrough',
                                'quest_counter_menu',
                                'quest_counter_menu_clickthrough',
                                'quest_counter_menu'
                            }
                        },
                        [3]={ --anomaly
                            top=13,
                            sub=6,
                            level=8,
                            order={'top','sub','level'}
                        },
                        [4]={ --master
                            top=12,
                            level=8,
                            order={'top','level'}
                        },
                        [5]={ --high
                            top=20,
                            sub=0,
                            level=8,
                            order={'top','sub','level'}
                        },
                        [6]={ --low
                            top=20,
                            sub=1,
                            level=8,
                            order={'top','sub','level'}
                        }
}
local function get_quest_board_menu_listless(target_id,target_type)
    local type_def = quest_board_menu_fields[target_type]['type_def']
    vars.cursor = type_def:get_field( quest_board_menu_fields[target_type]['cursor'] ):get_data()
    local cursor_index = methods.menu_list_cursor_get_index:call(vars.cursor)

    if set_ano_inv_fields then
        local quest_counter_singleton = sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')
        local quest_counter_menu = quest_counter_singleton:get_field('<QuestCounterMenu>k__BackingField')
        quest_counter_menu:set_field("_LevelMin",config.current.auto_quest.anomaly_investigation_min_lv)
        quest_counter_menu:set_field("_LevelMax",config.current.auto_quest.anomaly_investigation_max_lv)
        set_ano_inv_fields = false
    end

    if cursor_index == target_id or target_id == nil then
        vars.selected = true
        return true
    else
        methods.menu_list_cursor_set_index:call(vars.cursor,target_id)
        vars.selection_trigger = target_id
        return true
    end
end

local function get_quest_board_menu(target_id,target_type)
    local type_def = quest_board_menu_fields[target_type]['type_def']
    local quest_counter_menu_list = type_def:get_field(quest_board_menu_fields[target_type]['list']):get_data()
    local quest_counter_menu_list_size = quest_counter_menu_list:get_field('mSize')

    if quest_counter_menu_list_size == 0 then return nil end

    vars.cursor = type_def:get_field(quest_board_menu_fields[target_type]['cursor']):get_data()
    local cursor_index = methods.menu_list_cursor_get_index:call(vars.cursor)
    local menu_id = quest_counter_menu_list:call('get_Item',cursor_index)

    if menu_id == target_id then
        vars.selected = true
        return true
    else
        for i=0,quest_counter_menu_list_size-1 do
            local menu_id = quest_counter_menu_list:call('get_Item',i)
            if menu_id  == target_id then
                methods.menu_list_cursor_set_index:call(vars.cursor,i)
                vars.selection_trigger = i
                return true
            end
        end
    end
    return false
end

local function check_posted_quests()
    local hunter_info = singletons.lobbyman:get_field('_hunterInfo'):get_elements()
    for _,hunter in pairs(hunter_info) do
        if hunter then
            local status = hunter:get_field('_hallStatus')
            if status == 2 or status == 5 or status == 6 then
                return true
            end
        end
    end
    return false
end

local function get_quest_max_join(quest_data)
    local mystery = quest_data:get_field('<RandomMystery>k__BackingField')

    if not mystery then
        return 4
    else
        return mystery:get_field('_QuestOrderNum')
    end
end

function join_multiplayer.switch()
    function functions.post_quest()
        if methods.can_open_quest_board:call(singletons.guiman) and not methods.is_quest_posted:call(singletons.questman) then
            if config.current.auto_quest.join_multi_type == 1 and not methods.is_online:call(singletons.lobbyman) then
                functions.error_handler("Can't join hub quests while not in the lobby.")
            elseif config.current.auto_quest.join_multi_type == 1 and not check_posted_quests() then
                functions.error_handler("No quests to join.")
            else
                order_index = 1
                quest_counter_menu_index = 1
                set_ano_inv_fields = true
                vars.posting = true
                functions.open_quest_board()
            end
        end
    end
end

function join_multiplayer.hook()
    sdk.hook(methods.quest_board_top_start,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 3 then
                if vars.posting and not vars.quest_board_open then
                    local quest_board = methods.get_quest_board:call(singletons.guiman)
                    if config.current.auto_quest.join_multi_type ~= 1 then
                        methods.quest_board_decide_quick:call(quest_board,0,1)
                    else
                        methods.quest_board_decide_hall:call(quest_board,0,0)
                    end
                    vars.get_menu = true
                    vars.quest_board_open = true
                end
            else
                return retval
            end
        end
    )


    sdk.hook(methods.quest_board_on_destroy,
        function(args)
            if config.current.auto_quest.posting_method == 3 then
                if vars.posting
                and config.current.auto_quest.join_multi_type == 1
                and config.current.auto_quest.auto_ready
                and hall_status then
                    if hall_status:get_field('_hallStatus') == 2 then
                        methods.request_ready:call(singletons.lobbyman)
                    end
                end
                vars.quest_board_open = false
                vars.close_trigger = false
                vars.decide_trigger = false
                vars.posting = false
                hall_status = nil
            end
        end

    )

    sdk.hook(methods.close_yn_box,
        function(args)
            if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type ~= 1 then
                if vars.quest_board_open then
                    vars.posting = false
                    vars.decide_trigger = false
                end
            end
        end
    )

    sdk.hook(methods.decide_button,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 3 then
                if vars.posting and config.current.auto_quest.join_multi_type ~= 1 then
                    if vars.get_menu then

                        menu_type = quest_board_menu_id[config.current.auto_quest.join_multi_type]['order'][order_index]

                        local menu_id = quest_board_menu_id[config.current.auto_quest.join_multi_type][menu_type]

                        if type(menu_id) == 'table' then
                            menu_id = menu_id[quest_counter_menu_index]
                        end

                        local bool = nil

                        if quest_board_menu_fields[menu_type]['list'] then
                            bool = get_quest_board_menu(menu_id,menu_type)
                        else
                            bool = get_quest_board_menu_listless(menu_id,menu_type)
                        end

                        if bool == false then
                            vars.posting = false
                            vars.close_trigger = true
                            functions.error_handler("Can't join chosen quest type.")
                        elseif bool == nil then
                            vars.error = true
                            vars.posting = false
                            vars.close_trigger = true
                            functions.error_handler("Something went wrong.")
                        end

                        vars.get_menu = false
                    end

                    if vars.selected == nil then
                        vars.posting = false
                        vars.close_trigger = true
                        functions.error_handler("Menu selection timeout.")
                    end
                elseif vars.posting then
                    if vars.get_menu then
                        local quest_board = methods.get_quest_board:call(singletons.guiman)
                        local quest_board_quest_list = quest_board:get_field('_QuestBoardListCtrl')
                        vars.cursor = menu_list_type_def:get_field('_Cursor'):get_data(quest_board_quest_list)

                        methods.menu_list_cursor_set_index:call(vars.cursor,quest_board_quest_list_index)
                        vars.selection_trigger = quest_board_quest_list_index

                        if vars.selected then
                            hunter_info = methods.get_selected_hunter_info:call(quest_board_quest_list)
                            vars.selected = false
                            if hunter_info then
                                if methods.quest_check:call(quest_board_quest_list,quest_board_quest_list_index) == 0 then
                                    local quest_board_member_list = quest_board:get_field('_MemberListCtrl')
                                    local quest_board_member_scroll_list = quest_board_member_list:get_field('_MemberList')
                                    local quest_member_count = quest_board_member_scroll_list:get_field('_QuestMemberInfoList'):call('get_Count')
                                    local quest_data = quest_board_member_scroll_list:get_field('_QuestData')
                                    if quest_data then
                                        local quest_member_max = get_quest_max_join(quest_data)

                                        if quest_member_count < quest_member_max then
                                            hall_status = hunter_info
                                            vars.decide_trigger = true
                                            vars.get_menu = false
                                        else
                                            quest_board_quest_list_index = quest_board_quest_list_index + 1
                                        end
                                    end

                                else
                                    quest_board_quest_list_index = quest_board_quest_list_index + 1
                                end
                            else
                                if quest_board_quest_list_index == 0 then
                                    functions.error_handler("No quests to join.")
                                else
                                    functions.error_handler("All quests are full.")
                                end
                                quest_board_quest_list_index = 0
                                vars.posting = false
                                vars.get_menu = false
                                vars.close_trigger = true
                            end
                        end
                        if quest_board_quest_list_index == 3 then
                            quest_board_quest_list_index = 0
                            vars.posting = false
                            vars.get_menu = false
                            vars.close_trigger = true
                            functions.error_handler("All quests are full.")

                        end
                    end
                end

                if vars.posting and vars.selected and config.current.auto_quest.join_multi_type ~= 1 then
                    vars.selected = false

                    order_index = order_index + 1
                    if menu_type == 'quest_counter_menu' then
                        quest_counter_menu_index = quest_counter_menu_index + 1
                    end
                    if order_index <= #quest_board_menu_id[config.current.auto_quest.join_multi_type]['order'] then
                        vars.get_menu = true
                    else
                        vars.decide_trigger = true
                    end

                    return sdk.to_ptr(true)
                elseif vars.decide_trigger then
                    return sdk.to_ptr(true)
                else
                    return retval
                end
            else
                return retval
            end
        end
    )

    sdk.hook(methods.recieve_chat_info,
        function(args)
            if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 1 then
                local guid = sdk.to_managed_object(args[3]):get_field('_textId')
                if methods.get_hash_code:call(guid) == 56971447 then
                    auto_join_trigger = true
                end
            end
        end
    )

    re.on_frame(function()
        if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 1 then
            if auto_join_trigger then
                if check_posted_quests() then
                    auto_join_timer = 0
                    auto_join_trigger = false
                    vars.post_quest_trigger = true
                else
                    auto_join_timer = auto_join_timer + methods.get_delta_time:call(nil)
                    if auto_join_timer >= auto_join_timer_max then
                        auto_join_timer = 0
                        auto_join_trigger = false
                    end
                end
            end
        end
    end
    )

end

function join_multiplayer.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    config = require("AutoQuest.config")
    join_multiplayer.hook()
end

return join_multiplayer

