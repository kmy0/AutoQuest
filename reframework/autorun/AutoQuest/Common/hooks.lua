local common_hooks = {}

local singletons
local functions
local methods
local config
local vars
local dump
local mystery_mode
local randomizer
local bind

local quest_data = nil


function common_hooks.hook()
	sdk.hook(methods.online_warn, function(args) return sdk.PreHookResult.SKIP_ORIGINAL end)
	sdk.hook(methods.after_area_act,function(args) singletons.vilman = nil end)

    sdk.hook(methods.quest_counter_on_destroy,
    	function(args)
    		quest_data = nil
    		vars.quest_type = nil
			if dump.ed and not vars.posting then
				dump.random_mystery()
				randomizer.filter_quests()
			end
    	end
    )

	sdk.hook(methods.cancel_button,function(args)end,
	    function(retval)
	        if vars.close_trigger then return sdk.to_ptr(true) else return retval end
	    end
	)

    sdk.hook(methods.decide_button,function(args)end,
        function(retval)
            if vars.decide_trigger then
                vars.decide_trigger = false
                if vars.posting then
                	return sdk.to_ptr(true)
                else
                	return retval
                end
            else
                return retval
            end
        end
    )

	sdk.hook(methods.quest_activate,function(args)end,
	    function(retval)
	        config.current.auto_quest.quest_no = singletons.questman:get_field('_QuestIdentifier'):get_field('_QuestNo')
	    end
	)

	sdk.hook(methods.get_selected_quest,function(args)end,
	    function(retval)
	        if vars.posting then
	        	if config.current.auto_quest.posting_method == 2 and vars.quest_type ~= 'Random Mystery'
	        	or config.current.auto_quest.posting_method == 1 then
		        	if not quest_data then
		        		quest_data = methods.get_quest_data:call(singletons.questman,sdk.create_int32(config.current.auto_quest.quest_no))
		        	end
		        	return sdk.to_ptr(quest_data)
		        else
		        	return retval
		        end
	        else
	        	return retval
	        end
	    end
	)

	sdk.hook(methods.routine_quit,
	    function(args)
	        config.save()
	    end
	)

	sdk.hook(methods.quest_start,
	    function(args)
	        mystery_mode.stop = true
	        if config.current.randomizer.exclude_posted_quests then
	            config.current.randomizer.posted_quests[tostring(config.current.auto_quest.quest_no)] = 1
	        end
	    end
	)

    sdk.hook(methods.update_yn_window,function(args)end,
		function(retval)
			if vars.posting then
			    return sdk.to_ptr(0)
			else
			    return retval
			end
		end
	)

	re.on_frame(function()
		if singletons.spacewatcher then

			vars.prev_game_state = vars.game_state
			vars.game_state = singletons.spacewatcher:get_field('_GameState')

			if not dump.ed and vars.game_state == 4 then
				dump.quest_data()
				randomizer.filter_quests()
			end

			if vars.game_state == 4 and vars.prev_game_state == 3 then
				bind.block = false
			end

			if vars.game_state == 4 and vars.prev_game_state ~= 4 and vars.prev_game_state ~= 3 and vars.prev_game_state ~= nil then
				mystery_mode.stop = false
				bind.block = false
				if dump.ed then
					dump.random_mystery()
					randomizer.filter_quests()
				end

				local no = tonumber(config.current.auto_quest.quest_no)

		        if dump.ed and no and dump.quest_data_list[no] then
		            if not dump.quest_data_list[no]['completed'] then
		                dump.quest_data_list[no]['completed'] = methods.is_quest_clear:call(singletons.progquestman,no)
		            end
		        end
		        if config.current.auto_quest.anomaly_investigation_cap_max_lvl then
		        	functions.set_random_myst_lvl_to_max()
		        end
		        if config.current.auto_quest.auto_post then vars.post_quest_trigger = true end
			end
		end
	end
	)

    re.on_frame(function()
        if vars.selection_trigger then
            vars.selection_timer = vars.selection_timer + methods.get_delta_time:call(nil)
            if vars.selection_timer >= vars.selection_timer_max then
                vars.selection_timer = 0
                vars.selected = nil
                vars.selection_trigger = nil
            end

            if methods.menu_list_cursor_get_index:call(vars.cursor) == vars.selection_trigger then
                vars.selection_timer = 0
                vars.selection_trigger = nil
                vars.selected = true
            end
        end
    end
    )

   	re.on_frame(function()
   	    if aie_autoquest_reload and dump.ed then
			dump.random_mystery()
			randomizer.filter_quests()
			aie_autoquest_reload = false
   	    end
		if vars.post_quest_trigger then
			if sdk.get_managed_singleton('snow.VillageState'):get_Status() == 11 then
			    functions.post_quest()
			    vars.post_quest_trigger = false
			end
		end
	end
	)
end

function common_hooks.init()
    singletons = require("AutoQuest.singletons")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    vars = require("AutoQuest.Common.vars")
    config = require("AutoQuest.config")
    dump = require("AutoQuest.dump")
    mystery_mode = require("AutoQuest.mystery_mode")
    randomizer = require("AutoQuest.randomizer")
    bind = require("AutoQuest.bind")
	common_hooks.hook()
end

return common_hooks