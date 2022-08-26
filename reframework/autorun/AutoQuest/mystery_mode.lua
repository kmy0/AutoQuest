local mystery_mode = {}
local methods
local singletons
local config
local vars

local quest_board_order_type_def = sdk.find_type_definition('snow.gui.QuestBoardOrder')
local quest_board_order_fields = {}

for _,field in pairs(quest_board_order_type_def:get_fields()) do
	if field:get_type():get_name() == 'Text' then
    	table.insert(quest_board_order_fields,field:get_name())
    end
end

mystery_mode.stop = false

function mystery_mode.hook()
	sdk.hook(methods.open_hud,function(args) mystery_mode.stop = false end)
	sdk.hook(methods.close_hud,function(args) mystery_mode.stop = true end)

	sdk.hook(methods.get_quest_level,
		function(args)
			if config.current.auto_quest.mystery_mode
			and not mystery_mode.stop then
				return sdk.PreHookResult.SKIP_ORIGINAL
			end
		end
	)

	sdk.hook(methods.get_quest_icon,function(args)end,
	    function(retval)
	        if config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            return sdk.to_ptr(0)
	        else
	            return retval
	        end
	    end
	)


	sdk.hook(methods.get_quest_text,function(args)end,
	    function(retval)
	    	if config.current.auto_quest.mystery_mode and (config.current.auto_quest.posting_method == 3 and vars.posting or vars.matching)
	    	or config.current.auto_quest.mystery_mode and vars.posting and config.current.auto_quest.posting_method == 2 and vars.quest_type == 'Random Mystery'
	    	or config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            local txt = sdk.create_managed_string('Hidden')
	            return sdk.to_ptr(txt)
	        else
	            return retval
	        end
	    end
	)

	sdk.hook(methods.quest_board_update_order,
		function(args)
	        if config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            local quest_order_ctrl = methods.get_quest_board:call(singletons.guiman):get_field('_QuestOrderCtrl')
	            for _,field in pairs(quest_board_order_fields) do
	            	 methods.text_set_message:call(quest_order_ctrl:get_field(field),'Hidden')
	           	end
	            return sdk.PreHookResult.SKIP_ORIGINAL
	        end
	    end
	)

	sdk.hook(methods.quest_counter_order_update,
		function(args)
	        if config.current.auto_quest.mystery_mode and (config.current.auto_quest.posting_method == 3 and vars.posting or vars.matching)
	        or config.current.auto_quest.mystery_mode and vars.posting and config.current.auto_quest.posting_method == 2 and vars.quest_type == 'Random Mystery' then
	            return sdk.PreHookResult.SKIP_ORIGINAL
	        end
	    end
	)

	sdk.hook(methods.quest_info_win_update,function(args)end,
	    function(retval)
	        if singletons.guiman and config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            local quest_info_window = singletons.guiman:get_field('<refGuiLobbyQuestInfoWindow>k__BackingField')
	            methods.text_set_message:call(quest_info_window:get_field('QuestSpotNameText'),'Hidden')
	            methods.text_set_message:call(quest_info_window:get_field('StarText'),'Hidden')
	            methods.text_set_message:call(quest_info_window:get_field('RandomMysteryLVText'),'Hidden')
	        end
	    end
	)

	sdk.hook(methods.is_random_mystery,function(args)end,
	    function(retval)
	        if config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            return sdk.to_ptr(false)
	        else
	            return retval
	        end
	    end
	)

	sdk.hook(methods.is_mystery,function(args)end,
	    function(retval)
	        if config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            return sdk.to_ptr(false)
	        else
	            return retval
	        end
	    end
	)


	sdk.hook(methods.get_quest_type,function(args)end,
	    function(retval)
	    	if config.current.auto_quest.mystery_mode and (config.current.auto_quest.posting_method == 3 and vars.posting or vars.matching)
	        or config.current.auto_quest.mystery_mode and not mystery_mode.stop then
	            return sdk.to_ptr(sdk.create_int32(0))
	        else
	            return retval
	        end
	    end
	)

    sdk.hook(methods.quest_counter_awake,
    	function(args)
    		mystery_mode.stop = true
    	end
    )

    sdk.hook(methods.quest_counter_on_destroy,
        function(args)
            mystery_mode.stop = false
        end
    )
end


function mystery_mode.init()
	vars = require("AutoQuest.Common.vars")
	methods = require("AutoQuest.methods")
	config = require("AutoQuest.config")
	singletons = require("AutoQuest.singletons")

	if singletons.startmenuman and singletons.startmenuman:get_field('<isOpenStartMenu>k__BackingField') then mystery_mode.stop = true end

	mystery_mode.hook()
end

return mystery_mode