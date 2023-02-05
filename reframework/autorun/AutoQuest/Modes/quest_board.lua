local quest_board = {}
local vars
local singletons
local methods
local config
local functions
local dump
local randomizer

local menu_list_type_def = sdk.find_type_definition('snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase')

local hall_status = nil
local quest_board_rank = 'master'

local auto_join = {
    trigger=false,
    current=0,
    min=500,
    max=2500
}
local actions = {
    select_menu=true,
    set_random_mystery_fields=true,
    start_random_mystery_matchmaking=true,
    select_hub_quest_slot=true
}
local indexes = {
    order=1,
    hub_quest_list=0
}
local quest_board_menu_fields = {
    top={
        menu_list='<QuestCounterTopMenuList>k__BackingField',
        cursor='<TopMenuCursor>k__BackingField'
    },
    sub={
        menu_list='<QuestCounterSubMenuList>k__BackingField',
        cursor='<SubMenuCursor>k__BackingField'
    },
    level={
        menu_list='<QuestLevelMenuList>k__BackingField',
        cursor='<LevelMenuCursor>k__BackingField'
    }
}
local quest_board_menu_id = {
    master={
        [2]={ --investigations
            top=13,
            sub=5,
            order={
                'top',
                'sub'
            },
            id={
                top=32,
                sub=16
            }
        },
        [3]={ --anomaly
            top=13,
            sub=6,
            level=8,
            order={
                'top',
                'sub',
                'level'
            },
            id={
                top=32,
                sub=1
            }
        },
        [4]={ --master
            top=12,
            level=8,
            order={
                'top',
                'level'},
            id={top=1}
        },
        [5]={ --high
            top=20,
            sub=0,
            level=8,
            order={
                'top',
                'sub',
                'level'
            },
            id={
                top=32,
                sub=1
            }
        },
        [6]={ --low
            top=20,
            sub=1,
            level=8,
            order={
                'top',
                'sub',
                'level'
            },
            id={
                top=32,
                sub=1
            }
        },
        [7]={ --specific
            top=12,
            order={'top'},
            id={top=1}
            }
    },
    low_high={
        [5]={ --high
            top=1,
            level=8,
            order={
                'top',
                'level'
            },
            id={
                top=1,
            }
        },
        [6]={ --low
            top=2,
            level=8,
            order={
                'top',
                'level'
            },
            id={
                top=1,
            },
        },
        [7]={ --specific
            top=2,
            order={'top'},
            id={top=1}
        }
    }
}


local function get_quest_board_menu(target_id,target_field)
    local menu = {}
    menu.list = singletons.quest_counter:get_field(quest_board_menu_fields[target_field]['menu_list'])
    menu.size = menu.list:get_field('mSize')

    if menu.size == 0 then return false end

    vars.cursor = singletons.quest_counter:get_field(quest_board_menu_fields[target_field]['cursor'])
    menu.cursor_index = methods.menu_list_cursor_get_index:call(vars.cursor)

    if menu.list:get_Item(menu.cursor_index) == target_id then
        vars.selected = true
        return true
    else
        for i=0,menu.size-1 do
            if menu.list:get_Item(i) == target_id then
                methods.menu_list_cursor_set_index:call(vars.cursor,i)
                vars.selection_trigger = i
                return true
            end
        end
    end
    return false
end

local function check_posted_quests()
    for _,hunter in pairs(functions.to_array(singletons.lobbyman:get_field('_hunterInfo'))) do
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

local function set_random_mystery_fields()
    local settings = {
        max_lvl=config.current.auto_quest.anomaly_investigation_max_lv,
        min_lvl=config.current.auto_quest.anomaly_investigation_min_lv,
        hunter_num=tonumber(dump.hunter_num_array[config.current.auto_quest.anomaly_investigation_hunter_num]),
        monster=dump.anomaly_investigations_main_monsters[
                    dump.anomaly_investigations_main_monsters_array[
                        config.current.auto_quest.anomaly_investigation_monster
                        ]
                    ]
    }

    if config.current.auto_quest.anomaly_investigation_monster == 2 then
        local mysterylabo = methods.get_mystery_labo:call(singletons.facilitydataman)
        local research_request = methods.get_research_target:call(mysterylabo)

        if research_request then
            settings.monster = research_request:get_field('_MainTargetEnemyType')
            local monster_min_lvl = methods.get_limit_lvl:call(mysterylabo,research_request:get_field('_QuestCondition'))
            if settings.min_lvl < monster_min_lvl then
                settings.min_lvl = monster_min_lvl
            end
            if settings.max_lvl < settings.min_lvl then
                settings.max_lvl = methods.get_mystery_research_level:call(singletons.progman)
                if settings.max_lvl < settings.min_lvl then
                    settings.max_lvl = settings.min_lvl
                end
            end
        end
    else
        if settings.monster then
            local monster_min_lvl = methods.get_monster_min_lvl_appearance:call(singletons.questman,settings.monster)
            if settings.min_lvl < monster_min_lvl then
                settings.min_lvl = monster_min_lvl
            end
        end
        if settings.max_lvl < settings.min_lvl then
            settings.max_lvl = settings.min_lvl
        end
    end

    singletons.quest_counter:set_field('<_BoardLevelMin>k__BackingField',settings.min_lvl)
    singletons.quest_counter:set_field('<_BoardLevelMax>k__BackingField',settings.max_lvl)
    singletons.quest_counter:set_field('<_BoardOrderNum>k__BackingField',settings.hunter_num)
    singletons.quest_counter:set_field('<_BoardEnemyType>k__BackingField',settings.monster)
    singletons.quest_counter:set_field('<_BoardSearchSave>k__BackingField',true)
    methods.save_random_mystery_search_info:call(singletons.quest_counter)
end

function quest_board.switch()
    function functions.post_quest()
        if methods.can_open_quest_board:call(singletons.guiman)
        and not methods.is_quest_posted:call(singletons.questman) then

            if config.current.auto_quest.posting_method == 3
            and config.current.auto_quest.join_multi_type == 7
            and config.current.auto_quest.auto_randomize then
                randomizer.roll()
            end

            if config.current.auto_quest.join_multi_type == 1
            and not methods.is_online:call(singletons.lobbyman) then
                functions.error_handler("Can't join hub quests while not in the lobby.")
            elseif config.current.auto_quest.join_multi_type == 1
            and not check_posted_quests() then
                functions.error_handler("No quests to join.")
            elseif config.current.auto_quest.posting_method == 3
            and config.current.auto_quest.join_multi_type == 7
            and config.current.auto_quest.auto_randomize
            and #randomizer.filtered_quest_list == 0 then
                return
            elseif config.current.auto_quest.posting_method == 3
            and config.current.auto_quest.join_multi_type == 7
            and not dump.quest_data_list[tonumber(config.current.auto_quest.quest_no)] then
                functions.error_handler("Invalid Quest ID.")
            elseif config.current.auto_quest.posting_method == 3
            and config.current.auto_quest.join_multi_type == 7
            and not dump.quest_data_list[tonumber(config.current.auto_quest.quest_no)]['online'] then
                functions.error_handler("Cant be played online.")
            else
                for k,_ in pairs(actions) do actions[k] = true end
                indexes.order = 1
                indexes.hub_quest_list = 0
                hall_status = nil
                vars.matching = false
                vars.posting = true
                functions.open_quest_board()
            end
        end
    end
end

function quest_board.hook()
    sdk.hook(methods.quest_board_top_start,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 3 then
                if vars.posting and not singletons.quest_board then
                    singletons.quest_board = methods.get_quest_board:call(singletons.guiman)
                    if singletons.quest_board:get_field('_IsMasterRank') then
                        quest_board_rank = 'master'
                    else
                        quest_board_rank = 'low_high'
                    end
                    if config.current.auto_quest.join_multi_type ~= 1 then
                        methods.quest_board_decide_quick:call(singletons.quest_board,0,1)
                    else
                        methods.quest_board_decide_hall:call(singletons.quest_board,0,0)
                    end
                end
            else
                return retval
            end
        end
    )

    sdk.hook(methods.check_quest_hr,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 3
            and config.current.auto_quest.join_multi_type == 7
            and vars.posting then
                return sdk.to_ptr(true)
            else
                return retval
            end
        end
    )

    sdk.hook(methods.get_quest_data_quest_counter,
        function(args)
            if vars.posting
            and config.current.auto_quest.posting_method == 3
            and config.current.auto_quest.join_multi_type == 7 then
                args[3] = sdk.to_ptr(tonumber(config.current.auto_quest.quest_no))
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
                singletons.quest_counter = nil
                singletons.quest_board = nil
                vars.close_trigger = false
                vars.decide_trigger = false
                vars.posting = false
                vars.matching = false
            end
        end
    )

    sdk.hook(methods.recieve_chat_info,
        function(args)
            if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 1 then
                if methods.get_hash_code:call(sdk.to_managed_object(args[3]):get_field('_textId')) == 56971447 then
                    auto_join.trigger = true
                end
            end
        end
    )

    re.on_frame(function()
        if config.current.auto_quest.posting_method == 3 then
            if vars.posting then

                if config.current.auto_quest.join_multi_type ~= 1 then

                    if not singletons.quest_counter then
                        singletons.quest_counter = sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')
                    end

                    if singletons.quest_counter then

                        if methods.is_open_info:call(singletons.guiman) then
                            vars.posting = false
                            vars.matching = true
                        end

                        if vars.selected then
                            vars.selected = false
                            vars.decide_trigger = true
                        elseif vars.selected == nil then
                            vars.posting = false
                            vars.close_trigger = true
                            functions.error_handler("Menu selection timeout.")
                        end

                        local menu = {}
                        menu.order = quest_board_menu_id[quest_board_rank][config.current.auto_quest.join_multi_type]['order']
                        menu.type = menu.order[indexes.order]
                        menu.index = quest_board_menu_id[quest_board_rank][config.current.auto_quest.join_multi_type][menu.type]
                        menu.id = quest_board_menu_id[quest_board_rank][config.current.auto_quest.join_multi_type]['id'][menu.type]
                        menu.current = singletons.quest_counter:get_field('<QuestCounterState>k__BackingField')

                        if config.current.auto_quest.join_multi_type == 2
                        and actions.set_random_mystery_fields then
                            set_random_mystery_fields()
                            actions.set_random_mystery_fields = false
                        end

                        if (
                        config.current.auto_quest.join_multi_type ~= 2
                        or
                        config.current.auto_quest.join_multi_type == 2
                        and not actions.start_random_mystery_matchmaking
                        )
                        and indexes.order > #menu.order then
                            vars.decide_trigger = true
                        elseif indexes.order > #menu.order
                        and config.current.auto_quest.join_multi_type == 2
                        and actions.start_random_mystery_matchmaking then
                            methods.tree_set_node_by_id:call(
                                singletons.quest_counter:get_field('<refQuestCounterBehaviorTree>k__BackingField'),
                                1107141891,
                                0,
                                nil
                                )
                            actions.start_random_mystery_matchmaking = false
                        else
                            if actions.select_menu then
                                if not get_quest_board_menu(menu.index,menu.type) then
                                    vars.posting = false
                                    vars.close_trigger = true
                                    functions.error_handler("Can't join chosen quest type.")
                                end
                                actions.select_menu = false
                            end
                        end

                        if (
                        menu.current == menu.id
                        or
                        not menu.id
                        )
                        and indexes.order <= #menu.order then
                            indexes.order = indexes.order + 1
                            if indexes.order <= #menu.order then
                                actions.select_menu = true
                            end
                        end
                    end

                elseif config.current.auto_quest.join_multi_type == 1
                and singletons.quest_board then

                    if methods.is_open_yn:call(singletons.guiman) then
                        vars.decide_trigger = true
                    else
                        local quest = {}
                        quest.list = singletons.quest_board:get_field('_QuestBoardListCtrl')

                        if actions.select_hub_quest_slot then
                            vars.cursor = menu_list_type_def:get_field('_Cursor'):get_data(quest.list)
                            methods.menu_list_cursor_set_index:call(vars.cursor,indexes.hub_quest_list)
                            vars.selection_trigger = indexes.hub_quest_list
                            actions.select_hub_quest_slot = false
                        end

                        if vars.selected then
                            vars.selected = false
                            quest.hunter_info = methods.get_selected_hunter_info:call(quest.list)
                            if quest.hunter_info then
                                if methods.quest_check:call(quest.list,indexes.hub_quest_list) == 0 then
                                    quest.member_list = singletons.quest_board:get_field('_MemberListCtrl')
                                    quest.member_list_scroll = quest.member_list:get_field('_MemberList')
                                    quest.member_count = quest.member_list_scroll:get_field('_QuestMemberInfoList'):get_Count()
                                    quest.data = quest.member_list_scroll:get_field('_QuestData')
                                    if quest.data then
                                        quest.member_max = get_quest_max_join(quest.data)

                                        if quest.member_count < quest.member_max then
                                            hall_status = quest.hunter_info
                                            vars.decide_trigger = true
                                        else
                                            indexes.hub_quest_list = indexes.hub_quest_list + 1
                                            actions.select_hub_quest_slot = true
                                        end
                                    end

                                else
                                    indexes.hub_quest_list = indexes.hub_quest_list + 1
                                    actions.select_hub_quest_slot = true
                                end
                            else
                                if indexes.hub_quest_list == 0 then
                                    quest.error = "No quests to join."
                                else
                                    quest.error = "All quests are full."
                                end
                            end
                        end
                        if indexes.hub_quest_list == 3 then
                            quest.error = "All quests are full."
                        end
                        if quest.error then
                            vars.posting = false
                            vars.close_trigger = true
                            functions.error_handler(quest.error)
                        end
                    end
                end

            end
        end
    end
    )

    re.on_frame(function()
        if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 1 then
            if auto_join.trigger then
                auto_join.current = auto.current + methods.get_delta_time:call(nil)
                if auto_join.current >= auto_join.min then
                    if check_posted_quests() then
                        auto_join.current = 0
                        auto_join.trigger = false
                        vars.post_quest_trigger = true
                    else
                        if auto_join.current >= auto_join.max then
                            auto_join.current = 0
                            auto_join.trigger = false
                        end
                    end
                end
            end
        end
    end
    )

end

function quest_board.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    config = require("AutoQuest.config")
    dump = require("AutoQuest.dump")
    randomizer = require("AutoQuest.randomizer")
    quest_board.hook()
end

return quest_board

