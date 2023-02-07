local native_config_menu = {}

local config
local config_menu
local functions
local bind
local randomizer
local dump
local vars
local methods
local singletons

local mod_menu_api_package_name = "ModOptionsMenu.ModMenuApi"

local native_UI = nil
local mod_menu = nil

local random_changed = false
local changed = false

native_config_menu.show_quest_ranks = false
native_config_menu.show_quest_categories = false
native_config_menu.show_exclude_anomaly_level = false
native_config_menu.show_master_rank_level = false
native_config_menu.show_exclude_anomaly_investigations_level = false
native_config_menu.show_exclude_rampage_ranks = false
native_config_menu.show_exclude_event_ranks = false
native_config_menu.show_quest_types = false
native_config_menu.show_other = false
native_config_menu.show_anomaly_investigations_options = false
native_config_menu.show_hub_quest_options = false
native_config_menu.randomizer_options_toggle = false

local posting_methods_descs = {
						'Posts quests for singleplayer ONLY, faster than Quest Counter Mode.',
						'Posts quests for multiplayer and singleplayer, slower than Speedrun Mode.',
						'Joins Hub quests or multiplayer queues.'
}

local join_multi_type_descs = {
						'Join Hub Quest.',
						'Queue for Random Anomaly Investigation.',
						'Queue for Random Anomaly Quest.',
						'Queue for Random Master Rank Quest.',
						'Queue for Random High Rank Quest.',
						'Queue for Random Low Rank Quest.',
						'Queue for Specific Quest.'
}


function native_config_menu.is_module_available(name)
	if package.loaded[name] then
		return true;
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name);

			if type(loader) == 'function' then
				package.preload[name] = loader;
				return true;
			end
		end

		return false;
	end
end

function native_config_menu.draw()

	local button
	local option_window = methods.get_options_window:call(singletons.guiman)
	local cursor = option_window:get_field('<OptionMenuListCursor>k__BackingField')
	native_config_menu.active = true

	if random_changed and methods.menu_list_cursor_get_index:call(cursor) < 22 then
		randomizer.filter_quests()
		random_changed = false
	end

    if config.current.auto_quest.posting_method == 3 then

        config_menu.btn_text = 'Join'

    else

        config_menu.btn_text = 'Post'

    end

	mod_menu.Label("Created by: <COL RED>kmy</COL>", "")
	mod_menu.Label("Version: <COL RED>" ..config.version.."<COL>","")

	mod_menu.Header("Buttons")

	if config.current.auto_quest.posting_method ~= 3
	or config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 then

		button = mod_menu.Button(
							not bind.listen_trigger and "<COL AUTOQUESTBR>Quest ID</COL>"
							or bind.listen_trigger and "<COL AUTOQUESTGREEN>Quest ID</COL>",
							config.current.auto_quest.quest_no,
							false,
							not bind.listen_trigger and "Quest ID of next quest to be posted. Press to type."
							or bind.listen_trigger and "Type something in..."
							)

		if not bind.listen_trigger and button then

			bind.listen_trigger = true

		elseif bind.listen_trigger then

			bind.listen()

			if button or methods.menu_list_cursor_get_index:call(cursor) ~= 4 then

				bind.listen_trigger = false

			end
		end

		button = mod_menu.Button(
							"<COL AUTOQUESTBR>Randomize</COL>",
							"<COL GRAY>"..#randomizer.filtered_quest_list.."</COL>",
							false,
							"Randomize Quest ID - No. of quests in the Randomizer list."
							)

		if button then

			randomizer.roll()

		end

		button = mod_menu.Button(
							not native_config_menu.randomizer_options_toggle and "<COL AUTOQUESTBR>Select Randomizer Chekboxes</COL>"
							or native_config_menu.randomizer_options_toggle and "<COL AUTOQUESTBR>Unselect Randomizer Chekboxes</COL>",
							"",
							false,
							"Selects or Unselects all Randomizer Checkboxes."
							)

		if button then

			native_config_menu.randomizer_options_toggle = not native_config_menu.randomizer_options_toggle
			functions.toggle_options(native_config_menu.randomizer_options_toggle)
			randomizer.filter_quests()
			native_UI.regenOptions = true
		end

		button = mod_menu.Button(
							"<COL AUTOQUESTBR>Reload Quest Data</COL>",
							"<COL GRAY>"..dump.no_of_quests.."</COL>",
							false,
							"Use this after loading custom quests if you want them to appear in the randomizer quest list - No. of quests"
							)

		if button then

			dump.quest_data()
			randomizer.filter_quests()

		end

	else

		mod_menu.Label(
					"<COL GRAY>Quest ID</COL>",
					config.current.auto_quest.quest_no,
					"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
					)
		mod_menu.Label(
					"<COL GRAY>Randomize</COL>",
					"",
					"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
					)
		mod_menu.Label(
					not native_config_menu.randomizer_options_toggle and "<COL GRAY>Select Randomizer Chekboxes</COL>"
					or native_config_menu.randomizer_options_toggle and "<COL GRAY>Unselect Randomizer Chekboxes</COL>",
					"",
					"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
					)
		mod_menu.Label(
					"<COL GRAY>Reload Quest Data</COL>",
					"",
					"Quest Counter, Speedrun Modes only."
					)

	end

	button = mod_menu.Button(
						"<COL AUTOQUESTBR>"..config_menu.btn_text.. " Quest</COL>",
						"",
						false,
						"Close options and "..config_menu.btn_text.." Quest."
						)

	if button then

		config.save()
		vars.post_quest_trigger = true
		bind.block = false

	end

	button = mod_menu.Button(
						not bind.new_bind_trigger and "<COL AUTOQUESTBR>"..config_menu.btn_text.. " Quest Bind</COL>"
						or bind.new_bind_trigger and "<COL AUTOQUESTGREEN>"..config_menu.btn_text.. " Quest Bind</COL>",
						not bind.new_bind_trigger and config.current.button_bind.button_name
						or bind.new_bind_trigger and "<COL GRAY>Press any key... "..bind.timer_string.."</COL>",
						false,
						not bind.new_bind_trigger and "Your "..config_menu.btn_text.." Quest Bind. Press to bind."
						or bind.new_bind_trigger and "Press any key..."
						)

	if not bind.new_bind_trigger and button then

		bind.new_bind_trigger = true

	end

	if bind.new_bind_trigger and methods.menu_list_cursor_get_index:call(cursor) ~= 9 then

		bind.new_bind_trigger = false
		bind.timer = 0

	end


	mod_menu.Header("General")

	changed,config.current.auto_quest.posting_method = mod_menu.Options(
																	"Mode",
																	config.current.auto_quest.posting_method,
																	config_menu.post_methods,
																	posting_methods_descs,
																	"Choose your Mode."
																	)

	if changed then vars.posting_method_changed = true end

	if config.current.auto_quest.posting_method ~= 3 then

		mod_menu.Label(
					"<COL GRAY>Quest Type</COL>",
					config_menu.join_multi_types[ config.current.auto_quest.join_multi_type ],
					"Quest Board Mode only."
					)

	else

		changed,config.current.auto_quest.join_multi_type = mod_menu.Options(
																"Quest Type",
																config.current.auto_quest.join_multi_type,
																config_menu.join_multi_types,
																join_multi_type_descs,
																"Join Mulitplayer Quest Type."
																)
		if changed then random_changed = true end

	end

	if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 2 then

		button = mod_menu.Button(
						"<COL YEL>Anomaly Investigations Options</COL>",
						"",
						false,
						"Show/Hide Anomaly Investigations options."
						)
		if button then

			native_config_menu.show_anomaly_investigations_options = not native_config_menu.show_anomaly_investigations_options
			mod_menu.Repaint()

		end

		if native_config_menu.show_anomaly_investigations_options then

			mod_menu.IncreaseIndent()

			_,config.current.auto_quest.anomaly_investigation_min_lv = mod_menu.Slider(
																				"Anomaly Inv. Min Lv",
																				config.current.auto_quest.anomaly_investigation_min_lv,
																				1,
																				220,
																				"♥"
																				)
			_,config.current.auto_quest.anomaly_investigation_max_lv = mod_menu.Slider(
																				"Anomaly Inv. Max Lv",
																				config.current.auto_quest.anomaly_investigation_max_lv,
																				1,
																				220,
																				"You can set this higher than game lets you normally. "
																				)

			_,config.current.auto_quest.anomaly_investigation_monster = mod_menu.Options(
																		"Monster",
																		config.current.auto_quest.anomaly_investigation_monster,
																		dump.anomaly_investigations_main_monsters_array,
																		nil,
																		"Random Anomaly Investigation Target"
																		)
			_,config.current.auto_quest.anomaly_investigation_hunter_num = mod_menu.Options(
																		"Party Size",
																		config.current.auto_quest.anomaly_investigation_hunter_num,
																		dump.hunter_num_array,
																		nil,
																		""
																		)
			changed,config.current.auto_quest.anomaly_investigation_cap_max_lvl = mod_menu.CheckBox(
																'Set Max Lv At Current Research Lv',
																config.current.auto_quest.anomaly_investigation_cap_max_lvl,
																""
																)
			if changed and config.current.auto_quest.anomaly_investigation_cap_max_lvl then
				functions.set_random_myst_lvl_to_max()
				mod_menu.Repaint()
			end
		end

	end

	if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 1 then

		button = mod_menu.Button(
						"<COL YEL>Hub Quest Options</COL>",
						"",
						false,
						"Show/Hide Hub Quest options."
						)
		if button then

			native_config_menu.show_hub_quest_options = not native_config_menu.show_hub_quest_options
			mod_menu.Repaint()

		end

		if native_config_menu.show_hub_quest_options then

			mod_menu.IncreaseIndent()

			_,config.current.auto_quest.auto_join = mod_menu.CheckBox(
															'Join New Hub Quests',
															config.current.auto_quest.auto_join,
															"Enable/Disable joining Hub Quests whenever new one is posted."
															)
			_,config.current.auto_quest.auto_ready = mod_menu.CheckBox(
															'Auto Ready',
															config.current.auto_quest.auto_ready,
															"Enable/Disable readying up immediately after joining Hub Quest."
															)

		end

	end

	mod_menu.SetIndent(0)

	_,config.current.auto_quest.auto_post = mod_menu.CheckBox(
														'Auto ' ..config_menu.btn_text.. ' Quest',
														config.current.auto_quest.auto_post,
														"Enable/Disable Auto " .. config_menu.btn_text .. "ing quests upon returning to village."
														)

	if config.current.auto_quest.posting_method ~= 3
	or config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 then

		_,config.current.auto_quest.auto_randomize = mod_menu.CheckBox(
															'Auto Randomize Quest',
															config.current.auto_quest.auto_randomize,
															"Enable/Disable Auto Randomizing Quests upon posting."
															)

	else

    	mod_menu.Label(
				"<COL GRAY>Auto Randomize Quest</COL>",
				config.current.auto_quest.auto_randomize and '☒' or '☐',
				"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
				)

    end

    if config.current.auto_quest.posting_method ~= 3 then

		_,config.current.auto_quest.keep_rng = mod_menu.CheckBox(
															'Keep RNG',
															config.current.auto_quest.keep_rng,
															"Enable/Disable Keeping last quest RNG. Affects spawned monsters, "..
															"their spawn postitions and probably some less important stuff."
															)
    else


    	mod_menu.Label(
	    		"<COL GRAY>Keep RNG</COL>",
	    		config.current.auto_quest.keep_rng and '☒' or '☐',
	    		"Quest Counter, Speedrun Modes only."
	    		)

    end

    if config.current.auto_quest.posting_method == 2 then

		changed,config.current.auto_quest.send_join_request = mod_menu.CheckBox(
																	'Send Join Request',
																	config.current.auto_quest.send_join_request,
																	"Enable/Disable sending Join Request immediately after quest start."
																	)
		if changed then random_changed = true end

    else

    	mod_menu.Label(
				"<COL GRAY>Send Join Request</COL>",
				config.current.auto_quest.send_join_request and '☒' or '☐',
				"Quest Counter Mode only."
				)

    end

    if config.current.auto_quest.posting_method ~= 3 then

		_,config.current.auto_quest.auto_depart = mod_menu.CheckBox(
																'Auto Depart',
																config.current.auto_quest.auto_depart,
																"Enable/Disable departing immediately after quest post."
																)

    else

    	mod_menu.Label(
				"<COL GRAY>Auto Depart</COL>",
				config.current.auto_quest.auto_depart and '☒' or '☐',
				"Speedrun and Quest Counter Mode only."
				)

    end

	_,config.current.auto_quest.mystery_mode = mod_menu.CheckBox(
														'Mystery Mode',
														config.current.auto_quest.mystery_mode,
														"Enable/Disable hiding quest info displayed in top "..
														"left corner and while signing for Hub quest."
														)

	mod_menu.Header("Randomizer")

	if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type ~= 7 then

		mod_menu.Label(
				"<COL GRAY>Quest Ranks</COL>",
				'',
				"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
				)

	else

		button = mod_menu.Button(
							"<COL YEL>Quest Ranks</COL>",
							"",
							false,
							"Show/Hide Quest Ranks options."
							)
		if button then

			native_config_menu.show_quest_ranks = not native_config_menu.show_quest_ranks
			mod_menu.Repaint()

		end

	end

	if native_config_menu.show_quest_ranks then

		mod_menu.IncreaseIndent()

		changed,config.current.randomizer.exclude_village = mod_menu.CheckBox(
																'Exclude Village',
																config.current.randomizer.exclude_village,
																"Exclude/Include Village Quests."
																)
		if changed then random_changed = true end
        changed,config.current.randomizer.exclude_low_rank = mod_menu.CheckBox(
																'Exclude Low Rank',
																config.current.randomizer.exclude_low_rank,
																"Exclude/Include Low Rank Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_high_rank = mod_menu.CheckBox(
																'Exclude High Rank',
																config.current.randomizer.exclude_high_rank,
																"Exclude/Include High Rank Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_master_rank = mod_menu.CheckBox(
																'Exclude Master Rank',
																config.current.randomizer.exclude_master_rank,
																"Exclude/Include Master Rank Quests."
																)
        if changed then random_changed = true end


		if not config.current.randomizer.exclude_master_rank then

			button = mod_menu.Button(
								"<COL YEL>Exclude Master Rank Level</COL>",
								"",
								false,
								"Show/Hide Master Rank Level options."
								)
			if button then

				native_config_menu.show_master_rank_level = not native_config_menu.show_master_rank_level
				mod_menu.Repaint()

			end

		else

			mod_menu.Label(
					"<COL GRAY>Exclude Master Rank Level</COL>",
					'',
					"Include Master Rank Quests to show."
					)
			native_config_menu.show_master_rank_level = false

		end

		if native_config_menu.show_master_rank_level then

			mod_menu.IncreaseIndent()

            changed,config.current.randomizer.exclude_master_1 = mod_menu.CheckBox(
        																'Exclude Master Rank Level 1',
        																config.current.randomizer.exclude_master_1,
    																	"Exclude/Include Master Rank Level 1 Quests."
    																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_master_2 = mod_menu.CheckBox(
        																'Exclude Master Rank Level 2',
        																config.current.randomizer.exclude_master_2,
    																	"Exclude/Include Master Rank Level 2 Quests."
    																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_master_3 = mod_menu.CheckBox(
        																'Exclude Master Rank Level 3',
        																config.current.randomizer.exclude_master_3,
    																	"Exclude/Include Master Rank Level 3 Quests."
    																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_master_4 = mod_menu.CheckBox(
        																'Exclude Master Rank Level 4',
        																config.current.randomizer.exclude_master_4,
    																	"Exclude/Include Master Rank Level 4 Quests."
    																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_master_5 = mod_menu.CheckBox(
        																'Exclude Master Rank Level 5',
        																config.current.randomizer.exclude_master_5,
    																	"Exclude/Include Master Rank Level 5 Quests."
    																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_master_6 = mod_menu.CheckBox(
        																'Exclude Master Rank Level 6',
        																config.current.randomizer.exclude_master_6,
    																	"Exclude/Include Master Rank Level 6 Quests."
    																	)
            if changed then random_changed = true end
		end


	end

	mod_menu.SetIndent(0)

	if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type ~= 7 then

		mod_menu.Label(
					"<COL GRAY>Quest Categories</COL>",
					'',
					"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
					)

	else

		button = mod_menu.Button(
							"<COL YEL>Quest Categories</COL>",
							"",
							false,
							"Show/Hide Quest Categories options."
							)

		if button then

			native_config_menu.show_quest_categories = not native_config_menu.show_quest_categories
			mod_menu.Repaint()

		end

	end

	if native_config_menu.show_quest_categories then

		mod_menu.IncreaseIndent()

		changed,config.current.randomizer.exclude_anomaly = mod_menu.CheckBox(
																	'Exclude Anomaly',
																	config.current.randomizer.exclude_anomaly,
																	"Exclude/Include Anomnaly Quests."
																	)
		if changed then random_changed = true end

		if not config.current.randomizer.exclude_anomaly then

			button = mod_menu.Button(
								"<COL YEL>Exclude Anomaly Level</COL>",
								"",
								false,
								"Show/Hide Anomaly Level options."
								)
			if button then

				native_config_menu.show_exclude_anomaly_level = not native_config_menu.show_exclude_anomaly_level
				mod_menu.Repaint()

			end

		else

			mod_menu.Label(
									"<COL GRAY>Exclude Anomaly Level</COL>",
									'',
									"Include Anomaly Quests to show."
									)
			native_config_menu.show_exclude_anomaly_level = false

		end

		if native_config_menu.show_exclude_anomaly_level then

			mod_menu.IncreaseIndent()

            changed,config.current.randomizer.exclude_anomaly_1 = mod_menu.CheckBox(
																		'Exclude Anomaly Level 1',
																		config.current.randomizer.exclude_anomaly_1,
																		"Exclude/Include Anomaly Level 1 Quests."
																		)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_2 = mod_menu.CheckBox(
														            	'Exclude Anomaly Level 2',
														            	config.current.randomizer.exclude_anomaly_2,
														        		"Exclude/Include Anomaly Level 2 Quests."
														        		)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_3 = mod_menu.CheckBox(
														            	'Exclude Anomaly Level 3',
														            	config.current.randomizer.exclude_anomaly_3,
															        	"Exclude/Include Anomaly Level 3 Quests."
															        	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_4 = mod_menu.CheckBox(
																		'Exclude Anomaly Level 4',
																		config.current.randomizer.exclude_anomaly_4,
																		"Exclude/Include Anomaly Level 4 Quests."
																		)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_5 = mod_menu.CheckBox(
																		'Exclude Anomaly Level 5',
																		config.current.randomizer.exclude_anomaly_5,
																		"Exclude/Include Anomaly Level 5 Quests."
																		)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_6 = mod_menu.CheckBox(
																		'Exclude Anomaly Level 6',
																		config.current.randomizer.exclude_anomaly_6,
																		"Exclude/Include Anomaly Level 6 Quests."
																		)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_7 = mod_menu.CheckBox(
																		'Exclude Anomaly Level 7',
																		config.current.randomizer.exclude_anomaly_7,
																		"Exclude/Include Anomaly Level 7 Quests."
																		)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_anomaly_8 = mod_menu.CheckBox(
																		'Exclude Anomaly Level 8',
																		config.current.randomizer.exclude_anomaly_8,
																		"Exclude/Include Anomaly Level 8 Quests."
																		)
            if changed then random_changed = true end

        end

        mod_menu.SetIndent(1)

        changed,config.current.randomizer.exclude_anomaly_investigations = mod_menu.CheckBox(
																		'Exclude Anomaly Investigations',
																		config.current.randomizer.exclude_anomaly_investigations,
																		"Exclude/Include Anomaly Investigations Quests."
																		)
        if changed then random_changed = true end

		if not config.current.randomizer.exclude_anomaly_investigations then

			button = mod_menu.Button(
							"<COL YEL>Exclude Anomaly Investigations Level</COL>",
							"",
							false,
							"Show/Hide Anomaly Investigations Level options."
							)
			if button then

				native_config_menu.show_exclude_anomaly_investigations_level = not native_config_menu.show_exclude_anomaly_investigations_level
				mod_menu.Repaint()

			end

		else

			mod_menu.Label(
						"<COL GRAY>Exclude Anomaly Investigations Level</COL>",
						'',
						"Include Anomaly Investigations Quests to show."
						)
			native_config_menu.show_exclude_anomaly_investigations_level = false

		end

		if native_config_menu.show_exclude_anomaly_investigations_level then

			mod_menu.IncreaseIndent()
			changed,config.current.randomizer.exclude_anomaly_i_below = mod_menu.Slider(
																			"Exclude Below Level",
																			config.current.randomizer.exclude_anomaly_i_below,
																			0,
																			220,
																			"♥" --
																			)
			if changed then random_changed = true end
			changed,config.current.randomizer.exclude_anomaly_i_above = mod_menu.Slider(
																			"Exclude Above Level",
																			config.current.randomizer.exclude_anomaly_i_above,
																			0,
																			220,
																			"♥" --
																			)
			if changed then random_changed = true end

		end

		mod_menu.SetIndent(1)

        changed,config.current.randomizer.exclude_arena = mod_menu.CheckBox(
																'Exclude Arena',
																config.current.randomizer.exclude_arena,
																"Exclude/Include Arena Quests."
																)
		if not config.current.randomizer.exclude_arena then

			button = mod_menu.Button(
								"<COL YEL>Exclude Arena Ranks</COL>",
								"",
								false,
								"Show/Hide Arena Ranks options."
								)
			if button then

				native_config_menu.show_exclude_arena_ranks = not native_config_menu.show_exclude_arena_ranks
				mod_menu.Repaint()

			end

		else

			mod_menu.Label(
					"<COL GRAY>Exclude Arena Ranks</COL>",
					'',
					"Include Arena Quests to show."
					)
			native_config_menu.show_exclude_arena_ranks = false

		end

	    if native_config_menu.show_exclude_arena_ranks then

	        mod_menu.IncreaseIndent()

            changed,config.current.randomizer.exclude_arena_low_rank = mod_menu.CheckBox(
																			'Exclude Low Rank',
																			config.current.randomizer.exclude_arena_low_rank,
																			"Exclude/Include Arena Low Rank Quests.")
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_arena_high_rank = mod_menu.CheckBox(
																			'Exclude High Rank',
																			config.current.randomizer.exclude_arena_high_rank,
																			"Exclude/Include Arena Low Rank Quests."
																			)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_arena_master_rank = mod_menu.CheckBox(
																			'Exclude Master Rank',
																			config.current.randomizer.exclude_arena_master_rank,
																			"Exclude/Include Arena Low Rank Quests."
																			)
            if changed then random_changed = true end

	    end

	    mod_menu.SetIndent(1)

        changed,config.current.randomizer.exclude_rampage = mod_menu.CheckBox(
																'Exclude Rampage',
																config.current.randomizer.exclude_rampage,
																"Exclude/Include Rampage Quests."
																)
        if changed then random_changed = true end

		if not config.current.randomizer.exclude_rampage then

			button = mod_menu.Button(
								"<COL YEL>Exclude Rampage Ranks</COL>",
								"",
								false,
								"Show/Hide Rampage Ranks options."
								)
			if button then

				native_config_menu.show_exclude_rampage_ranks = not native_config_menu.show_exclude_rampage_ranks
				mod_menu.Repaint()

			end

		else

			mod_menu.Label(
					"<COL GRAY>Exclude Rampage Ranks</COL>",
					'',
					"Include Rampage Quests to show."
					)
			native_config_menu.show_exclude_rampage_ranks = false

		end
	    if native_config_menu.show_exclude_rampage_ranks then

	        mod_menu.IncreaseIndent()

            changed,config.current.randomizer.exclude_rampage_village = mod_menu.CheckBox(
																			'Exclude Village',
																			config.current.randomizer.exclude_rampage_village,
																			"Exclude/Include Rampage Village Quests."
																			)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_rampage_low_rank = mod_menu.CheckBox(
																			'Exclude Low Rank',
																			config.current.randomizer.exclude_rampage_low_rank,
																			"Exclude/Include Rampage Low Rank Quests."
																			)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_rampage_high_rank = mod_menu.CheckBox(
																			'Exclude High Rank',
																			config.current.randomizer.exclude_rampage_high_rank,
																			"Exclude/Include Rampage High Rank Quests."
																			)
            if changed then random_changed = true end

	    end

	    mod_menu.SetIndent(1)

        changed,config.current.randomizer.exclude_event = mod_menu.CheckBox(
																'Exclude Event',
																config.current.randomizer.exclude_event,
																"Exclude/Include Event Quests."
																)
        if changed then random_changed = true end

		if not config.current.randomizer.exclude_event then

			button = mod_menu.Button(
								"<COL YEL>Exclude Event Ranks</COL>",
								"",
								false,
								"Show/Hide Event Ranks options."
								)
			if button then

				native_config_menu.show_exclude_event_ranks = not native_config_menu.show_exclude_event_ranks
				mod_menu.Repaint()

			end

		else

			mod_menu.Label(
					"<COL GRAY>Exclude Event Ranks</COL>",
					'',
					"Include Event Quests to show."
					)
			native_config_menu.show_exclude_event_ranks = false

		end

	    if native_config_menu.show_exclude_event_ranks then

	        mod_menu.IncreaseIndent()

            changed,config.current.randomizer.exclude_event_low_rank = mod_menu.CheckBox(
																	'Exclude Low Rank',
																	config.current.randomizer.exclude_event_low_rank,
																	"Exclude/Include Event Low Rank Quests."
																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_event_high_rank = mod_menu.CheckBox(
																	'Exclude High Rank',
																	config.current.randomizer.exclude_event_high_rank,
																	"Exclude/Include Event High Rank Quests."
																	)
            if changed then random_changed = true end
            changed,config.current.randomizer.exclude_event_master_rank = mod_menu.CheckBox(
																	'Exclude Master Rank',
																	config.current.randomizer.exclude_event_master_rank,
																	"Exclude/Include Event Master Rank Quests."
																	)
            if changed then random_changed = true end

	    end

	    mod_menu.SetIndent(1)

        changed,config.current.randomizer.exclude_support_survey = mod_menu.CheckBox(
																	'Exclude Support Surveys',
																	config.current.randomizer.exclude_support_survey,
																	"Exclude/Include Support Surveys Quests."
																	)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_follower = mod_menu.CheckBox(
																	'Exclude Follower Quests',
																	config.current.randomizer.exclude_follower,
																	"Exclude/Include Follower Quests."
																	)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_training = mod_menu.CheckBox(
																	'Exclude Training',
																	config.current.randomizer.exclude_training,
																	"Exclude/Include Training Quests."
																	)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_tour = mod_menu.CheckBox(
																'Exclude Tour',
																config.current.randomizer.exclude_tour,
																"Exclude/Include Tour Quests."
																)
        if changed then random_changed = true end

    end

	mod_menu.SetIndent(0)

	if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type ~= 7 then

		mod_menu.Label(
					"<COL GRAY>Quest Types</COL>",
					'',
					"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
					)

	else

		button = mod_menu.Button(
						"<COL YEL>Quest Types</COL>",
						"",
						false,
						"Show/Hide Quest Types options."
						)
		if button then

			native_config_menu.show_quest_types = not native_config_menu.show_quest_types
			mod_menu.Repaint()

		end
	end

	if native_config_menu.show_quest_types then

		mod_menu.IncreaseIndent()

        changed,config.current.randomizer.exclude_capture = mod_menu.CheckBox(
																'Exclude Capture',
																config.current.randomizer.exclude_capture,
																"Exclude/Include Capture Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_slay = mod_menu.CheckBox(
																'Exclude Slay',
																config.current.randomizer.exclude_slay,
																"Exclude/Include Slay Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_hunt = mod_menu.CheckBox(
																'Exclude Hunt',
																config.current.randomizer.exclude_hunt,
																"Exclude/Include Hunt Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_boss_rush = mod_menu.CheckBox(
																'Exclude Boss Rush',
																config.current.randomizer.exclude_boss_rush,
																"Exclude/Include Boss Rush Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_gathering = mod_menu.CheckBox(
																'Exclude Gathering',
																config.current.randomizer.exclude_gathering,
																"Exclude/Include Gathering Quests."
																)
        if changed then random_changed = true end

	end

	mod_menu.SetIndent(0)

	if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type ~= 7 then

		mod_menu.Label(
					"<COL GRAY>Other</COL>",
					'',
					"Quest Counter, Speedrun Modes and Quest Board Specific Quest only."
					)

	else

		button = mod_menu.Button(
							"<COL YEL>Other</COL>",
							"",
							false,
							"Show/Hide Other options."
							)
		if button then

			native_config_menu.show_other = not native_config_menu.show_other
			mod_menu.Repaint()

		end
	end

	if native_config_menu.show_other then

		mod_menu.IncreaseIndent()

        changed,config.current.randomizer.exclude_small_monsters = mod_menu.CheckBox(
																'Exclude Small Monsters',
																config.current.randomizer.exclude_small_monsters,
																"Exclude/Include Quests with small monsters as a main target."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_single_monsters = mod_menu.CheckBox(
																'Exclude Single Monster',
																config.current.randomizer.exclude_single_monsters,
																"Exclude/Include Quests with single monster as a main target."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_multi_monster = mod_menu.CheckBox(
																'Exclude Mutli Monsters',
																config.current.randomizer.exclude_multi_monster,
																"Exclude/Include Multi Target Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_not_unlocked = mod_menu.CheckBox(
																'Exclude Not Unlocked',
																config.current.randomizer.exclude_not_unlocked,
																"Exclude/Include Not Unlocked Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_completed = mod_menu.CheckBox(
																'Exclude Completed',
																config.current.randomizer.exclude_completed,
																"Exclude/Include Completed Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_invalid_anomaly_investigations = mod_menu.CheckBox(
																'Exclude Invalid Anomaly Investigations',
																config.current.randomizer.exclude_invalid_anomaly_investigations,
																"Exclude/Include Invalid Anomaly Investigations."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_custom = mod_menu.CheckBox(
																'Exclude Custom',
																config.current.randomizer.exclude_custom,
																"Exclude/Include Custom Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_non_custom = mod_menu.CheckBox(
																'Exclude Non Custom',
																config.current.randomizer.exclude_non_custom,
																"Exclude/Include Non Custom Quests."
																)
        if changed then random_changed = true end
        changed,config.current.randomizer.exclude_posted_quests = mod_menu.CheckBox(
																'Exclude Posted',
																config.current.randomizer.exclude_posted_quests,
																"Exclude/Include Already Posted Quests."
																)
        if changed then random_changed = true end
        _,config.current.randomizer.prefer_research_target = mod_menu.CheckBox(
																'Prefer Anomaly Research Quests',
																config.current.randomizer.prefer_research_target,
																"Randomizer will pick Anomaly Research Quest over other quests if available."
																)

        button = mod_menu.Button(
							"<COL AUTOQUESTBR>Reset Posted Quests List<COL>",
							"",
							false,
							"You have ".. functions.table_length(config.current.randomizer.posted_quests) - 1 .. ' quests in the list.'
							)
        if button then

        	config.current.randomizer.posted_quests = {dummy=1}

        end

	end

	mod_menu.SetIndent(0)

end

function native_config_menu.init()
	config_menu = require("AutoQuest.config_menu")
	config = require("AutoQuest.config")
	functions = require("AutoQuest.Common.functions")
	bind = require("AutoQuest.bind")
	dump = require("AutoQuest.dump")
	randomizer = require("AutoQuest.randomizer")
	vars = require("AutoQuest.Common.vars")
	methods = require("AutoQuest.methods")
	singletons = require("AutoQuest.singletons")

	if native_config_menu.is_module_available(mod_menu_api_package_name) then
		mod_menu = require(mod_menu_api_package_name)
	end

	if mod_menu == nil then
		return
	end

	mod_menu.AddTextColor("AUTOQUESTBR", "B3A46D")
	mod_menu.AddTextColor("AUTOQUESTGREEN", "AFFF00")
	-- mod_menu.AddTextColor("AUTOQUESTPICK", "FBD686")

	native_config_menu.mod_menu = mod_menu

	native_UI = mod_menu.OnMenu(
		"AutoQuest",
		"Posts quests for you :)",
		native_config_menu.draw
	)

	re.on_frame(function()
		if native_config_menu.active
		and not methods.is_open_startmenu:call(singletons.guiman) then
			native_config_menu.active = false
		end
	end
	)

end

return native_config_menu