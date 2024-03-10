local speedrun = {}
local config
local singletons
local methods
local functions
local vars
local randomizer
local dump

function speedrun.switch()
	function functions.post_quest()
		if
			methods.can_open_quest_board:call(singletons.guiman)
			and not methods.is_quest_posted:call(singletons.questman)
		then
			if not methods.is_online:call(singletons.lobbyman) then
				if config.current.auto_quest.auto_randomize then
					randomizer.roll()
				end
				if
					config.current.auto_quest.auto_randomize
						and #randomizer.filtered_quest_list ~= 0
					or not config.current.auto_quest.auto_randomize
				then
					if dump.quest_data_list[config.current.auto_quest.quest_no] then
						vars.posting = true

						if config.current.auto_quest.use_legacy then
							functions.open_quest_board()
						else
							singletons.quest_counter = sdk.create_instance(
								"snow.gui.fsm.questcounter.GuiQuestCounterFsmManager"
							):add_ref()
							methods.quest_counter_awake:call(singletons.quest_counter)

							if not config.current.auto_quest.keep_rng then
								methods.reset_quest_identifier:call(singletons.quest_counter)
							end

							methods.send_quest_to_questman:call(nil)
							methods.quest_counter_on_destroy:call(singletons.quest_counter)
							singletons.quest_counter = nil

							vars.posting = false
							if
								config.current.auto_quest.auto_depart
								and methods.is_quest_posted:call(singletons.questman)
							then
								methods.go_quest:call(
									singletons.guiman:get_field(
										"<refQuestStartFlowHandler>k__BackingField"
									),
									true
								)
							end
						end
					else
						functions.error_handler("Invalid Quest ID.")
					end
				end
			else
				functions.error_handler("Speedrun Mode cant be used in online lobby.")
			end
		end
	end
end

function speedrun.legacy_hook()
	sdk.hook(methods.quest_board_top_start, function(args) end, function()
		if
			config.current.auto_quest.posting_method == 1
			and config.current.auto_quest.use_legacy
			and vars.posting
			and not singletons.quest_board
		then
			singletons.quest_board = methods.get_quest_board:call(singletons.guiman)
			methods.quest_board_decide_quick:call(singletons.quest_board, 0, 1)
		end
	end)

	sdk.hook(methods.quest_counter_awake, function(args) end, function()
		if
			config.current.auto_quest.posting_method == 1
			and config.current.auto_quest.use_legacy
			and vars.posting
		then
			if not config.current.auto_quest.keep_rng then
				methods.reset_quest_identifier:call(
					sdk.get_managed_singleton("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager")
				)
			end

			methods.send_quest_to_questman:call(nil)
		end
	end)

	sdk.hook(methods.quest_board_on_destroy, function(args) end, function()
		if
			config.current.auto_quest.posting_method == 1
			and config.current.auto_quest.use_legacy
			and vars.posting
		then
			vars.posting = false
			vars.close_trigger = false
			singletons.quest_board = nil

			if config.current.auto_quest.auto_depart then
				methods.go_quest:call(
					singletons.guiman:get_field("<refQuestStartFlowHandler>k__BackingField"),
					true
				)
			end
		end
	end)

	sdk.hook(methods.quest_activate, function(args) end, function()
		if
			config.current.auto_quest.posting_method == 1
			and config.current.auto_quest.use_legacy
			and vars.posting
		then
			vars.close_trigger = true
		end
	end)
end

function speedrun.init()
	singletons = require("AutoQuest.singletons")
	vars = require("AutoQuest.Common.vars")
	methods = require("AutoQuest.methods")
	functions = require("AutoQuest.Common.functions")
	config = require("AutoQuest.config")
	randomizer = require("AutoQuest.randomizer")
	dump = require("AutoQuest.dump")
	speedrun.legacy_hook()
end

return speedrun
