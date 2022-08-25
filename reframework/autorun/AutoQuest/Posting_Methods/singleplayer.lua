local singleplayer = {}
local config
local singletons
local methods
local functions
local vars
local randomizer
local dump


function singleplayer.switch()
    function functions.post_quest()
        local random_pool = true
        if methods.can_open_quest_board:call(singletons.guiman) and not methods.is_quest_posted:call(singletons.questman) then
            if config.current.auto_quest.auto_randomize then
                random_pool = randomizer.roll()
            end
            local quest_data = dump.quest_data_list[tonumber(config.current.auto_quest.quest_no)]
            if quest_data and random_pool then
                vars.posting = true
                functions.set_state()
                functions.open_quest_board()
            elseif not quest_data then
                functions.error_handler("Invalid Quest ID.")
            end
        end
    end
end

function singleplayer.hook()
   	sdk.hook(methods.quest_board_top_start,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 1 then
                if vars.posting and not vars.quest_board_open then
                	local quest_board = methods.get_quest_board:call(singletons.guiman)
                	methods.quest_board_decide_quick:call(quest_board,0,1)
                	vars.quest_board_open = true
                end
            else
                return retval
            end
        end
    )

    sdk.hook(methods.quest_counter_awake,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 1 then
                vars.quest_counter_open = true
                if vars.posting then
                	local quest_counter_singleton = sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')
                    if not config.current.auto_quest.keep_rng then methods.reset_quest_identifier:call(quest_counter_singleton) end
                    methods.send_quest_to_questman:call(nil)
                end
            end
        end
    )

    sdk.hook(methods.quest_board_on_destroy,function(args)end,
        function(retval)
            if config.current.auto_quest.posting_method == 1 then
                if vars.posting then
                    vars.posting = false
                    vars.close_trigger = false
                    vars.quest_posted = true
                    functions.restore_state()
                end
                vars.quest_board_open = false
            else
                return retval
            end
        end
    )

    sdk.hook(methods.quest_counter_on_destroy,
        function(args)
            if config.current.auto_quest.posting_method == 1 then
                vars.quest_counter_open = false
            end
        end
    )

    re.on_frame(function()
        if config.current.auto_quest.posting_method == 1 then
            if vars.quest_posted and methods.is_online:call(singletons.lobbyman) and methods.can_open_quest_board:call(singletons.guiman) then
                local active_qi = methods.get_active_quest_id:call(singletons.questman)
                local qi = sdk.create_instance('snow.LobbyManager.QuestIdentifier'):add_ref()
                methods.quest_id_copy_from:call(qi,active_qi)
                methods.create_room:call(singletons.lobbyman,qi)
                vars.quest_posted = false
            elseif vars.quest_posted and not methods.is_online(singletons.lobbyman) then
                vars.quest_posted = false
            end
        end
    end
    )

end

function singleplayer.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    config = require("AutoQuest.config")
    randomizer = require("AutoQuest.randomizer")
    dump = require("AutoQuest.dump")
    singleplayer.hook()
end

return singleplayer