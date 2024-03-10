local quest_counter = {}
local config
local singletons
local methods
local functions
local vars
local dump
local randomizer

local menu_list_type_def =
	sdk.find_type_definition("snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase")

local quest_counter_obj_loop = {
	max = 100,
	count = 0,
	name = nil,
	sensor = nil,
}
local actions = {
	select_quest_counter = false,
	select_menu = false,
	select_sub_menu = false,
	select_option = false,
	select_mystery = false,
}
local quest_counter_obj_ids = {
	[0] = "nid002", --village
	[3] = "nid102", --hub
	[6] = "nid601", --elgado
}
local quest_counter_top_menu_types = {
	[7] = "Normal", --Arena
	[8] = "Normal", --Challenge
	[5] = "Normal", --Event
	[1] = "Normal", --Normal_Hall_High
	[20] = "Normal", --Normal_Hall_HighLow
	[2] = "Normal", --Normal_Hall_Low
	[12] = "Normal", --Normal_Hall_Master
	[4] = "Normal", --Training
	[13] = "Random Mystery", --Mystery
}

local quest_counter_sub_menu_types = {
	[5] = "Random Mystery",
	[7] = "Special Random Mystery",
}

local function select_mystery_quest()
	local menu = {}
	menu.list = methods.get_active_menu_quest_list:call(singletons.quest_counter)
	menu.size = menu.list:get_field("mSize")
	vars.cursor = singletons.quest_counter:get_field("<QuestMenuCursor>k__BackingField")

	for i = 0, menu.size - 1 do
		local quest = menu.list:get_Item(i)
		if
			quest:get_field("<RandomMystery>k__BackingField"):get_field("_QuestNo")
			== functions.sanitize_quest_no(config.current.auto_quest.quest_no)
		then
			methods.menu_list_cursor_set_index:call(vars.cursor, i)
			vars.selection_trigger = i
			return true
		end
	end
	return false
end

local function get_quest_counter_top_menu()
	local menu = {}
	menu.list = singletons.quest_counter:get_field("<QuestCounterTopMenuList>k__BackingField")
	vars.cursor = singletons.quest_counter:get_field("<TopMenuCursor>k__BackingField")
	menu.size = menu.list:get_field("mSize")
	menu.cursor_index = methods.menu_list_cursor_get_index:call(vars.cursor)
	menu.id = menu.list:get_Item(menu.cursor_index)

	local quest_type = vars.quest_type
	if quest_type == "Special Random Mystery" then
		quest_type = "Random Mystery"
	end

	if quest_counter_top_menu_types[menu.id] ~= quest_type then
		for i = 0, menu.size - 1 do
			menu.id = menu.list:get_Item(i)
			if quest_counter_top_menu_types[menu.id] == quest_type then
				methods.menu_list_cursor_set_index:call(vars.cursor, i)
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

local function get_quest_counter_sub_menu()
	local menu = {}
	menu.list = singletons.quest_counter:get_field("<QuestCounterSubMenuList>k__BackingField")
	vars.cursor = singletons.quest_counter:get_field("<SubMenuCursor>k__BackingField")
	menu.size = menu.list:get_field("mSize")
	menu.cursor_index = methods.menu_list_cursor_get_index:call(vars.cursor)
	menu.id = menu.list:get_Item(menu.cursor_index)

	if quest_counter_top_menu_types[menu.id] ~= vars.quest_type then
		for i = 0, menu.size - 1 do
			menu.id = menu.list:get_Item(i)
			if quest_counter_sub_menu_types[menu.id] == vars.quest_type then
				methods.menu_list_cursor_set_index:call(vars.cursor, i)
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
	local select_window_scroll_list = singletons.guiman
		:get_field("<refGuiCommonSelectWindow>k__BackingField")
		:get_field("_ScrollListCtrl")
	vars.cursor = menu_list_type_def:get_field("_Cursor"):get_data(select_window_scroll_list)
	methods.menu_list_cursor_set_index:call(vars.cursor, index)
	vars.selection_trigger = index
end

function quest_counter.switch()
	function functions.post_quest()
		if methods.can_open_quest_board:call(singletons.guiman) then
			if not methods.is_quest_posted:call(singletons.questman) then
				quest_counter_obj_loop.name = quest_counter_obj_ids[singletons.vilman:get_field(
					"<_CurrentAreaNo>k__BackingField"
				)]
				if quest_counter_obj_loop.name then
					if config.current.auto_quest.auto_randomize then
						randomizer.roll()
					end
					if
						config.current.auto_quest.auto_randomize
							and #randomizer.filtered_quest_list ~= 0
						or not config.current.auto_quest.auto_randomize
					then
						if dump.quest_data_list[config.current.auto_quest.quest_no] then
							for k, v in pairs(actions) do
								actions[k] = true
							end

							vars.quest_type =
								dump.quest_data_list[config.current.auto_quest.quest_no]["category"]
							if
								vars.quest_type ~= "Random Mystery"
								and vars.quest_type ~= "Special Random Mystery"
							then
								vars.quest_type = "Normal"
							end
							vars.posting = true
						else
							functions.error_handler("Invalid Quest ID.")
						end
					end
				elseif not quest_counter_obj_loop.name then
					functions.error_handler("Can't post in this area.")
				end
			end
		end
	end
end

function quest_counter.hook()
	sdk.hook(methods.check_quest_hr, function(args) end, function(retval)
		if config.current.auto_quest.posting_method == 2 and vars.posting then
			return sdk.to_ptr(true)
		else
			return retval
		end
	end)

	sdk.hook(methods.quest_id_reset, function(args)
		if
			config.current.auto_quest.posting_method == 2
			and vars.posting
			and config.current.auto_quest.keep_rng
		then
			args[3] = sdk.to_ptr(false)
		end
	end)

	sdk.hook(methods.pop_sensor_check_access, function(args)
		if config.current.auto_quest.posting_method == 2 and vars.posting then
			return sdk.PreHookResult.SKIP_ORIGINAL
		end
	end, function(retval)
		if
			config.current.auto_quest.posting_method == 2
			and vars.posting
			and actions.select_quest_counter
		then
			if not quest_counter_obj_loop.sensor then
				quest_counter_obj_loop.sensor = methods.get_sensor:call(singletons.objaccman, 1)
			end

			if quest_counter_obj_loop.count == quest_counter_obj_loop.max then
				vars.posting = false
				actions.select_quest_counter = false
				functions.error_handler(
					"Failed to find Quest Counter NPC\nMove closer and try again."
				)
			end

			local obj = methods.pop_sensor_get_access_target:call(quest_counter_obj_loop.sensor)

			if obj then
				if methods.get_gameobject_name:call(obj) == quest_counter_obj_loop.name then
					vars.interact_trigger = true
					actions.select_quest_counter = false
				else
					methods.focus_next_target:call(singletons.objaccman)
				end
			end

			if not actions.select_quest_counter then
				quest_counter_obj_loop.name = nil
				quest_counter_obj_loop.sensor = nil
				quest_counter_obj_loop.count = 0
			end

			quest_counter_obj_loop.count = quest_counter_obj_loop.count + 1

			return sdk.to_ptr(true)
		else
			return retval
		end
	end)

	sdk.hook(methods.interact_button, function(args) end, function(retval)
		if config.current.auto_quest.posting_method == 2 and vars.interact_trigger then
			return sdk.to_ptr(true)
		else
			return retval
		end
	end)

	sdk.hook(methods.is_servant_quest, function(args) end, function(retval)
		if config.current.auto_quest.posting_method == 2 and vars.posting then
			return sdk.to_ptr(false)
		else
			return retval
		end
	end)

	sdk.hook(methods.open_all_quest_hud, function(args) end, function(retval)
		if config.current.auto_quest.posting_method == 2 then
			vars.decide_trigger = false
			vars.close_trigger = false
			singletons.quest_counter = nil
			if
				vars.posting
				and config.current.auto_quest.auto_depart
				and methods.is_quest_posted:call(singletons.questman)
			then
				methods.go_quest:call(
					singletons.guiman:get_field("<refQuestStartFlowHandler>k__BackingField"),
					true
				)
			end
			vars.posting = false
		end
	end)

	re.on_frame(function()
		if config.current.auto_quest.posting_method == 2 then
			if vars.posting then
				if not singletons.quest_counter then
					singletons.quest_counter = sdk.get_managed_singleton(
						"snow.gui.fsm.questcounter.GuiQuestCounterFsmManager"
					)
				end

				if singletons.quest_counter then
					vars.interact_trigger = false

					if vars.selected then
						vars.selected = false
						vars.decide_trigger = true
					elseif vars.selected == nil then
						vars.posting = false
						vars.close_trigger = true
						functions.error_handler("Menu selection timeout.")
						return
					end

					local current_menu =
						singletons.quest_counter:get_field("<QuestCounterState>k__BackingField")

					if current_menu == 0 and actions.select_menu then
						if not get_quest_counter_top_menu() then
							vars.close_trigger = true
							vars.posting = false
							functions.error_handler("Can't post chosen quest type.")
							return
						end

						actions.select_menu = false
					end

					if
						current_menu == 32
						and actions.select_sub_menu
						and (
							vars.quest_type == "Special Random Mystery"
							or vars.quest_type == "Random Mystery"
						)
					then
						if not get_quest_counter_sub_menu() then
							vars.close_trigger = true
							vars.posting = false
							functions.error_handler("Can't post chosen quest type.")
						end

						actions.select_sub_menu = false
					elseif
						current_menu ~= 0 and current_menu ~= 30
						or (current_menu == 30 and methods.is_open_select:call(singletons.guiman))
					then
						if not methods.is_open_select:call(singletons.guiman) then
							vars.decide_trigger = true
						elseif
							config.current.auto_quest.send_join_request
							and actions.select_option
							and methods.is_open_select:call(singletons.guiman)
							and methods.is_internet:call(nil)
						then
							select_index_selection_window(1)
							actions.select_option = false
						elseif not methods.is_internet:call(nil) then
							vars.decide_trigger = true
						end
					elseif current_menu == 30 and actions.select_mystery then
						if not select_mystery_quest() then
							vars.close_trigger = true
							vars.posting = false
							functions.error_handler("Invalid Quest ID.")
						end
						actions.select_mystery = false
					end
				end
			end
		end
	end)
end

function quest_counter.init()
	singletons = require("AutoQuest.singletons")
	vars = require("AutoQuest.Common.vars")
	methods = require("AutoQuest.methods")
	functions = require("AutoQuest.Common.functions")
	dump = require("AutoQuest.dump")
	config = require("AutoQuest.config")
	randomizer = require("AutoQuest.randomizer")
	quest_counter.hook()
end

return quest_counter
