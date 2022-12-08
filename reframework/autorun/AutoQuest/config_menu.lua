local config_menu = {}

local config
local functions
local randomizer
local bind
local dump
local vars

local random_changed = false
local changed = false

config_menu.window_flags = 0x10120
config_menu.window_pos = Vector2f.new(400, 200)
config_menu.window_pivot = Vector2f.new(0, 0)
config_menu.window_size = Vector2f.new(560, 600)

config_menu.is_opened = false
config_menu.btn_text = 'Post'
config_menu.post_methods = {'Singleplayer','Multiplayer','Join Multiplayer'}
config_menu.join_multi_types = {
                        'Hub Quest',
                        'Random Anomaly Investigations',
                        'Random Anomaly',
                        'Random Master Rank',
                        'Random High Rank',
                        'Random Low Rank',
                        'Specific Quest'
}


function config_menu.draw()
    imgui.set_next_window_pos(config_menu.window_pos, 1 << 3, config_menu.window_pivot)
    imgui.set_next_window_size(config_menu.window_size, 1 << 3)

   	config_menu.is_opened = imgui.begin_window("AutoQuest "..config.version,config_menu.is_opened, config_menu.window_flags)

	if not config_menu.is_opened then
		imgui.end_window()
		return
	end

    if config.current.auto_quest.posting_method == 3 then
        config_menu.btn_text = 'Join'
    else
        config_menu.btn_text = 'Post'
    end

    changed,config.current.auto_quest.posting_method = imgui.combo('Posting Method',config.current.auto_quest.posting_method,config_menu.post_methods)

    if changed then vars.posting_method_changed = true end

    if config.current.auto_quest.posting_method == 3 then
        changed,config.current.auto_quest.join_multi_type = imgui.combo('Quest Type',config.current.auto_quest.join_multi_type,config_menu.join_multi_types)
        if changed then random_changed = true end
    end

    if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 2 then
        _,config.current.auto_quest.anomaly_investigation_min_lv = imgui.slider_int(
                                                                            "Anomaly Inv. Min Lv",
                                                                            config.current.auto_quest.anomaly_investigation_min_lv,
                                                                            1,
                                                                            200
                                                                            )
        _,config.current.auto_quest.anomaly_investigation_max_lv = imgui.slider_int(
                                                                            "Anomaly Inv. Max Lv",
                                                                            config.current.auto_quest.anomaly_investigation_max_lv,
                                                                            1,
                                                                            200
                                                                            )
        _,config.current.auto_quest.anomaly_investigation_monster = imgui.combo('Monster',config.current.auto_quest.anomaly_investigation_monster,dump.anomaly_investigations_main_monsters_array)
        _,config.current.auto_quest.anomaly_investigation_hunter_num = imgui.combo('Party Size',config.current.auto_quest.anomaly_investigation_hunter_num,dump.hunter_num_array)
        changed,config.current.auto_quest.anomaly_investigation_cap_max_lvl = imgui.checkbox('Set Max Lv At Current Research Lv', config.current.auto_quest.anomaly_investigation_cap_max_lvl)
        if changed and config.current.auto_quest.anomaly_investigation_cap_max_lvl then functions.set_random_myst_lvl_to_max() end
    end

    _,config.current.auto_quest.auto_post = imgui.checkbox('Auto ' ..config_menu.btn_text.. ' Quest', config.current.auto_quest.auto_post)

    if config.current.auto_quest.posting_method ~= 3
    or config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 then
        _,config.current.auto_quest.auto_randomize = imgui.checkbox('Auto Randomize Quest', config.current.auto_quest.auto_randomize)
    end

    if config.current.auto_quest.posting_method ~= 3 then
         _,config.current.auto_quest.keep_rng = imgui.checkbox('Keep RNG', config.current.auto_quest.keep_rng)
    end

    if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 1 then
        _,config.current.auto_quest.auto_join = imgui.checkbox('Join New Hub Quests', config.current.auto_quest.auto_join)
        _,config.current.auto_quest.auto_ready = imgui.checkbox('Auto Ready', config.current.auto_quest.auto_ready)
    end

    if config.current.auto_quest.posting_method ~= 3 then
        _,config.current.auto_quest.auto_depart = imgui.checkbox('Auto Depart', config.current.auto_quest.auto_depart)
    end

    if config.current.auto_quest.posting_method == 2 then
        changed,config.current.auto_quest.send_join_request= imgui.checkbox('Send Join Request', config.current.auto_quest.send_join_request)
        if changed then random_changed = true end
    end

    _,config.current.auto_quest.mystery_mode = imgui.checkbox('Mystery Mode', config.current.auto_quest.mystery_mode)

    if config.current.auto_quest.posting_method ~= 3
    or config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 then
        _,config.current.auto_quest.quest_no = imgui.input_text('Quest ID', config.current.auto_quest.quest_no)
    end

    if imgui.button(config_menu.btn_text.. ' Quest') then vars.post_quest_trigger = true end

    if config.current.auto_quest.posting_method ~= 3
    or config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 then

        if imgui.button('Randomize') then randomizer.roll() end
        imgui.same_line()
        imgui.text(#randomizer.filtered_quest_list)

        if imgui.button('Reload Quest Data') then
            dump.quest_data()
            randomizer.filter_quests()
        end
        imgui.same_line()
        imgui.text(dump.no_of_quests)
    end

    if config.current.auto_quest.posting_method ~= 3
    or config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 then

        if imgui.tree_node('Randomizer Settings') then

            if imgui.button('Select All') then
                functions.toggle_options(true)
                randomizer.filter_quests()
            end
            imgui.same_line()
            if imgui.button('Unselect All') then
                functions.toggle_options(false)
                randomizer.filter_quests()
            end

            if imgui.tree_node('Quest Ranks') then
                changed,config.current.randomizer.exclude_village = imgui.checkbox('Exclude Village', config.current.randomizer.exclude_village)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_low_rank = imgui.checkbox('Exclude Low Rank', config.current.randomizer.exclude_low_rank)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_high_rank = imgui.checkbox('Exclude High Rank', config.current.randomizer.exclude_high_rank)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_master_rank = imgui.checkbox('Exclude Master Rank', config.current.randomizer.exclude_master_rank)
                if changed then random_changed = true end
                if not config.current.randomizer.exclude_master_rank then
                    if imgui.tree_node('Exclude MR Level') then
                        changed,config.current.randomizer.exclude_master_1 = imgui.checkbox('M1', config.current.randomizer.exclude_master_1)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_master_2 = imgui.checkbox('M2', config.current.randomizer.exclude_master_2)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_master_3 = imgui.checkbox('M3', config.current.randomizer.exclude_master_3)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_master_4 = imgui.checkbox('M4', config.current.randomizer.exclude_master_4)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_master_5 = imgui.checkbox('M5', config.current.randomizer.exclude_master_5)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_master_6 = imgui.checkbox('M6', config.current.randomizer.exclude_master_6)
                        if changed then random_changed = true end
                        imgui.tree_pop()
                    end
                end
                imgui.tree_pop()
            end
            if imgui.tree_node('Quest Categories') then
                changed,config.current.randomizer.exclude_anomaly = imgui.checkbox('Exclude Anomaly', config.current.randomizer.exclude_anomaly)
                if changed then random_changed = true end
                if not config.current.randomizer.exclude_anomaly then
                    if imgui.tree_node('Exclude Anomaly Level') then
                        changed,config.current.randomizer.exclude_anomaly_1 = imgui.checkbox('A1', config.current.randomizer.exclude_anomaly_1)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_2 = imgui.checkbox('A2', config.current.randomizer.exclude_anomaly_2)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_3 = imgui.checkbox('A3', config.current.randomizer.exclude_anomaly_3)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_4 = imgui.checkbox('A4', config.current.randomizer.exclude_anomaly_4)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_5 = imgui.checkbox('A5', config.current.randomizer.exclude_anomaly_5)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_6 = imgui.checkbox('A6', config.current.randomizer.exclude_anomaly_6)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_7 = imgui.checkbox('A7', config.current.randomizer.exclude_anomaly_7)
                        if changed then random_changed = true end
                        imgui.tree_pop()
                    end
                end
                changed,config.current.randomizer.exclude_anomaly_investigations = imgui.checkbox('Exclude Anomaly Investigations', config.current.randomizer.exclude_anomaly_investigations)
                if changed then random_changed = true end
                if not config.current.randomizer.exclude_anomaly_investigations then
                    if imgui.tree_node('Exclude Anomaly Investigations Level') then
                        changed,config.current.randomizer.exclude_anomaly_i_below = imgui.slider_int('Exclude Below', config.current.randomizer.exclude_anomaly_i_below, 0, 200)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_anomaly_i_above = imgui.slider_int('Exclude Above', config.current.randomizer.exclude_anomaly_i_above, 0, 200)
                        if changed then random_changed = true end
                        imgui.tree_pop()
                    end
                end
                changed,config.current.randomizer.exclude_arena = imgui.checkbox('Exclude Arena', config.current.randomizer.exclude_arena)
                if changed then random_changed = true end
                if not config.current.randomizer.exclude_arena then
                    if imgui.tree_node('Exclude Arena Ranks') then
                        changed,config.current.randomizer.exclude_arena_low_rank = imgui.checkbox('Low Rank', config.current.randomizer.exclude_arena_low_rank)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_arena_high_rank = imgui.checkbox('High Rank', config.current.randomizer.exclude_arena_high_rank)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_arena_master_rank = imgui.checkbox('Master Rank', config.current.randomizer.exclude_arena_master_rank)
                        if changed then random_changed = true end
                        imgui.tree_pop()
                    end
                end
                changed,config.current.randomizer.exclude_rampage = imgui.checkbox('Exclude Rampage', config.current.randomizer.exclude_rampage)
                if changed then random_changed = true end
                if not config.current.randomizer.exclude_rampage then
                    if imgui.tree_node('Exclude Rampage Ranks') then
                        changed,config.current.randomizer.exclude_rampage_village = imgui.checkbox('Village', config.current.randomizer.exclude_rampage_village)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_rampage_low_rank = imgui.checkbox('Low Rank', config.current.randomizer.exclude_rampage_low_rank)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_rampage_high_rank = imgui.checkbox('High Rank', config.current.randomizer.exclude_rampage_high_rank)
                        if changed then random_changed = true end
                        imgui.tree_pop()
                    end
                end
                changed,config.current.randomizer.exclude_support_survey = imgui.checkbox('Exclude Support Surveys', config.current.randomizer.exclude_support_survey)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_follower = imgui.checkbox('Exclude Follower Quests', config.current.randomizer.exclude_follower)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_event = imgui.checkbox('Exclude Event', config.current.randomizer.exclude_event)
                if changed then random_changed = true end
                if not config.current.randomizer.exclude_event then
                    if imgui.tree_node('Exclude Event Ranks') then
                        changed,config.current.randomizer.exclude_event_low_rank = imgui.checkbox('Low Rank', config.current.randomizer.exclude_event_low_rank)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_event_high_rank = imgui.checkbox('High Rank', config.current.randomizer.exclude_event_high_rank)
                        if changed then random_changed = true end
                        changed,config.current.randomizer.exclude_event_master_rank = imgui.checkbox('Master Rank', config.current.randomizer.exclude_event_master_rank)
                        if changed then random_changed = true end
                        imgui.tree_pop()
                    end
                end
                changed,config.current.randomizer.exclude_training = imgui.checkbox('Exclude Training', config.current.randomizer.exclude_training)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_tour = imgui.checkbox('Exclude Tour', config.current.randomizer.exclude_tour)
                if changed then random_changed = true end
                imgui.tree_pop()
            end
            if imgui.tree_node('Quest Types') then
                changed,config.current.randomizer.exclude_capture = imgui.checkbox('Exclude Capture', config.current.randomizer.exclude_capture)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_slay = imgui.checkbox('Exclude Slay', config.current.randomizer.exclude_slay)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_hunt = imgui.checkbox('Exclude Hunt', config.current.randomizer.exclude_hunt)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_boss_rush = imgui.checkbox('Exclude Boss Rush', config.current.randomizer.exclude_boss_rush)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_gathering = imgui.checkbox('Exclude Gathering', config.current.randomizer.exclude_gathering)
                if changed then random_changed = true end
                imgui.tree_pop()
            end
            if imgui.tree_node('Other') then
                changed,config.current.randomizer.exclude_small_monsters = imgui.checkbox('Exclude Small Monsters', config.current.randomizer.exclude_small_monsters)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_single_monsters = imgui.checkbox('Exclude Single Monster', config.current.randomizer.exclude_single_monsters)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_multi_monster = imgui.checkbox('Exclude Mutli Monsters', config.current.randomizer.exclude_multi_monster)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_not_unlocked = imgui.checkbox('Exclude Not Unlocked', config.current.randomizer.exclude_not_unlocked)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_completed = imgui.checkbox('Exclude Completed', config.current.randomizer.exclude_completed)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_invalid_anomaly_investigations = imgui.checkbox('Exclude Invalid Anomaly Investigations', config.current.randomizer.exclude_invalid_anomaly_investigations)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_custom = imgui.checkbox('Exclude Custom', config.current.randomizer.exclude_custom)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_non_custom = imgui.checkbox('Exclude Non Custom', config.current.randomizer.exclude_non_custom)
                if changed then random_changed = true end
                changed,config.current.randomizer.exclude_posted_quests = imgui.checkbox('Exclude Posted', config.current.randomizer.exclude_posted_quests)
                imgui.same_line()
                if imgui.button('Reset Posted Quests List') then config.current.randomizer.posted_quests = {dummy=1} end
                if changed then random_changed = true end
                _,config.current.randomizer.prefer_research_target = imgui.checkbox('Prefer Anomaly Research Quests', config.current.randomizer.prefer_research_target)
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
    end
    if random_changed then
        randomizer.filter_quests()
        random_changed = false
    end

    if imgui.tree_node(config_menu.btn_text.. ' Quest Bind') then

        if not bind.new_bind_trigger and imgui.button('         '.. config.current.button_bind.button_name..'           ') then
            bind.new_bind_trigger = true
        elseif bind.new_bind_trigger and imgui.button('Press any key...'..bind.timer_string) then
            bind.new_bind_trigger = false
            bind.timer = 0
        end

        imgui.tree_pop()
    end
    if imgui.tree_node('Explanations') then
        if imgui.tree_node('Posting Method') then
            if imgui.tree_node('Multiplayer') then
                imgui.text(
                    'Required method if you want to post quest for people in your lobby\n' ..
                    'or activate Join Request later. Also can be used if you play singleplayer.\n' ..
                    'Quests can be posted only in 3 areas, Elgado, Kamura Village and Kamura Hub\n'..
                    'while somewhat close to Quest Counter. GUI cant be disabled while posting.'
                    )
                imgui.tree_pop()
            end
            if imgui.tree_node('Singleplayer') then
                imgui.text(
                    'Other people cant join quests posted with this method.\n'..
                    'Quests can be posted from each area that lets you open Quest Board.\n'..
                    'Is faster than Multiplayer method and GUI can be disabled while posting.'
                    )
                imgui.tree_pop()
            end
            if imgui.tree_node('Join Multiplayer') then
                imgui.text(
                    'Queues for random multiplayer quests of your choosing or joins hub quests.'
                    )
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node('Keep RNG') then
            imgui.text(
                'Lets you keep random seed used in last quest. Affects spawned monsters,\n'..
                'their spawn postitions and probably some less important stuff.\n'..
                'Quest rewards are not affected.'
                )
            imgui.tree_pop()
        end
        if imgui.tree_node('Join New Hub Quests') then
            imgui.text(
                'When enabled mod will attempt to join new hub quests whenever one is posted.\n'..
                'Tbh I dislike this option as its essentially giving a bit of control to other players,\n'..
                'but its there if you want it.'
                )
            imgui.tree_pop()
        end
        if imgui.tree_node('Mystery Mode') then
            imgui.text('Hides quest info displayed in top left corner and while signing for hub quest.')
            imgui.tree_pop()
        end
        if imgui.tree_node('Randomizer Settings') then
            if imgui.tree_node('Reset list') then
                imgui.text('Resets list of posted quests.')
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node('GUI Settings') then
            if imgui.tree_node('Restore GUI') then
                imgui.text('Unhides GUI and restores ui volume if something went wrong.')
                imgui.tree_pop()
            end
            imgui.tree_pop()
        end
        if imgui.tree_node('Custom Quests') then
            imgui.text(
                    'After loading custom quests press Reload Quest Data button\n'..
                    'for them to appear in the randomizer quest pool.'
                    )
            imgui.tree_pop()
        end
        imgui.tree_pop()
    end
    imgui.end_window()
end

function config_menu.init()
	config = require("AutoQuest.config")
    bind = require("AutoQuest.bind")
    dump = require("AutoQuest.dump")
    randomizer = require("AutoQuest.randomizer")
    functions = require("AutoQuest.Common.functions")
    vars = require("AutoQuest.Common.vars")
end

return config_menu