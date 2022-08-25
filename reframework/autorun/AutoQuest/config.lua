local config = {}

config.config_file_name = 'AutoQuest/config.json'
config.version = '1.4'

config.current  = {
    auto_quest={
        posting_method=1,
        join_multi_type=1,
        auto_post=true,
        auto_randomize=false,
        send_join_request=false,
        auto_ready=false,
        auto_depart=false,
        keep_rng=false,
        mystery_mode=false,
        quest_no=''
    },
    randomizer={
        exclude_village=false,
        exclude_low_rank=false,
        exclude_high_rank=false,
        exclude_master_rank=false,
        exclude_master_1=false,
        exclude_master_2=false,
        exclude_master_3=false,
        exclude_master_4=false,
        exclude_master_5=false,
        exclude_master_6=false,
        exclude_anomaly=false,
        exclude_anomaly_1=false,
        exclude_anomaly_2=false,
        exclude_anomaly_3=false,
        exclude_anomaly_4=false,
        exclude_anomaly_5=false,
        -- exclude_anomaly_6=false,
        exclude_anomaly_investigations=false,
        exclude_anomaly_i_below=0,
        exclude_anomaly_i_above=0,
        exclude_arena=false,
        exclude_arena_low_rank=false,
        exclude_arena_high_rank=false,
        exclude_arena_master_rank=false,
        exclude_rampage=false,
        exclude_rampage_village=false,
        exclude_rampage_low_rank=false,
        exclude_rampage_high_rank=false,
        exclude_support_survey=false,
        exclude_follower=false,
        exclude_event=false,
        exclude_event_low_rank=false,
        exclude_event_high_rank=false,
        exclude_event_master_rank=false,
        exclude_training=false,
        exclude_tour=false,
        exclude_capture=false,
        exclude_slay=false,
        exclude_hunt=false,
        exclude_boss_rush=false,
        exclude_gathering=false,
        exclude_small_monsters=false,
        exclude_single_monsters=false,
        exclude_multi_monster=false,
        exclude_not_unlocked=false,
        exclude_completed=false,
        exclude_custom=false,
        exclude_non_custom=false,
        exclude_posted_quests=false,
        posted_quests={dummy=1},
    },
    button_bind={
        button=nil,
        button_name='None',
        button_type=nil
    },
    gui={
        hide_gui=false,
        mute_ui_sounds=false,
    }
}

function config.load()
    local loaded_config = json.load_file(config.config_file_name)
    if loaded_config then
        config.current = loaded_config
    end
end

function config.save()
    json.dump_file(config.config_file_name, config.current)
end

function config.init()
    config.load()
end

return config