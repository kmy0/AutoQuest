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
        if methods.can_open_quest_board:call(singletons.guiman)
        and not methods.is_quest_posted:call(singletons.questman) then
            if config.current.auto_quest.auto_randomize then randomizer.roll() end
            if config.current.auto_quest.auto_randomize
            and #randomizer.filtered_quest_list ~= 0
            or
            not config.current.auto_quest.auto_randomize then
                if dump.quest_data_list[tonumber(config.current.auto_quest.quest_no)] then

                    vars.posting = true
                    local quest_counter = sdk.create_instance('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')

                    methods.quest_counter_awake:call(quest_counter)
                    if not config.current.auto_quest.keep_rng then methods.reset_quest_identifier:call(quest_counter) end
                    methods.send_quest_to_questman:call(nil)
                    methods.quest_counter_on_destroy:call(quest_counter)

                    if methods.is_online:call(singletons.lobbyman) then
                        local qi = sdk.create_instance('snow.LobbyManager.QuestIdentifier'):add_ref()
                        methods.quest_id_copy_from:call(qi,methods.get_active_quest_id:call(singletons.questman))
                        methods.create_room:call(singletons.lobbyman,qi)
                    end

                    vars.posting = false
                    if config.current.auto_quest.auto_depart
                    and methods.is_quest_posted:call(singletons.questman) then
                        methods.go_quest:call(singletons.guiman:get_field('<refQuestStartFlowHandler>k__BackingField'),true)
                    end

                else
                    functions.error_handler("Invalid Quest ID.")
                end
            end
        end
    end
end

function singleplayer.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    config = require("AutoQuest.config")
    randomizer = require("AutoQuest.randomizer")
    dump = require("AutoQuest.dump")
end

return singleplayer