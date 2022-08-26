local randomizer = {}
local dump
local config
local functions

local posted_quests = {}

randomizer.filtered_quest_list = {}

function randomizer.filter_quests()
    randomizer.filtered_quest_list = {}
    for no,data in pairs(dump.quest_data_list) do
        if not data then goto continue end
        if config.current.auto_quest.posting_method == 3 and config.current.auto_quest.join_multi_type == 7 and not data['online'] then goto continue end
        if data['type'] == dump.quest_types['INVALID'] then goto continue end
        if config.current.randomizer.exclude_posted_quests and config.current.randomizer.posted_quests[tostring(no)] then goto continue end
        if config.current.randomizer.exclude_custom and not dump.non_custom_quest_ids[tostring(no)] then goto continue end
        if config.current.randomizer.exclude_non_custom and dump.non_custom_quest_ids[tostring(no)] then goto continue end
        if data['category'] == 'Random Mystery' then
            if config.current.randomizer.exclude_anomaly_investigations then goto continue end
            if config.current.randomizer.exclude_anomaly_i_below > 0 then
                if data['level'] < config.current.randomizer.exclude_anomaly_i_below then goto continue end
            end
            if config.current.randomizer.exclude_anomaly_i_above > 0 then
                if data['level'] > config.current.randomizer.exclude_anomaly_i_above then goto continue end
            end
        end
        if data['category'] == 'Normal' then
            if config.current.randomizer.exclude_village and data['rank'] == dump.ranks_ids['Village'] then goto continue end
            if config.current.randomizer.exclude_low_rank and data['rank'] == dump.ranks_ids['Low'] then goto continue end
            if config.current.randomizer.exclude_high_rank and data['rank'] == dump.ranks_ids['High'] then goto continue end
            if config.current.randomizer.exclude_master_rank and data['rank'] == dump.ranks_ids['Master'] then
                goto continue
            elseif not config.current.randomizer.exclude_master_rank then
                if config.current.randomizer.exclude_master_1 and data['level'] == 0 then goto continue end
                if config.current.randomizer.exclude_master_2 and data['level'] == 1 then goto continue end
                if config.current.randomizer.exclude_master_3 and data['level'] == 2 then goto continue end
                if config.current.randomizer.exclude_master_4 and data['level'] == 3 then goto continue end
                if config.current.randomizer.exclude_master_5 and data['level'] == 4 then goto continue end
                if config.current.randomizer.exclude_master_6 and data['level'] == 5 then goto continue end
            end
        end
        if data['category'] == 'Mystery' then
            if config.current.randomizer.exclude_anomaly then
                goto continue
            else
                if config.current.randomizer.exclude_anomaly_1 and data['level'] == 0 then goto continue end
                if config.current.randomizer.exclude_anomaly_2 and data['level'] == 1 then goto continue end
                if config.current.randomizer.exclude_anomaly_3 and data['level'] == 2 then goto continue end
                if config.current.randomizer.exclude_anomaly_4 and data['level'] == 3 then goto continue end
                if config.current.randomizer.exclude_anomaly_5 and data['level'] == 4 then goto continue end
                -- if config.current.randomizer.exclude_anomaly_6 and data['level'] == 5 then goto continue end
            end
        end
        if data['category'] == 'Arena' then
            if config.current.randomizer.exclude_arena then
                goto continue
            else
                if config.current.randomizer.exclude_arena_low_rank and data['rank'] == dump.ranks_ids['Low'] then goto continue end
                if config.current.randomizer.exclude_arena_high_rank and data['rank'] == dump.ranks_ids['High'] then goto continue end
                if config.current.randomizer.exclude_arena_master_rank and data['rank'] == dump.ranks_ids['Master'] then goto continue end
            end
        end
        if data['type'] == dump.quest_types['HYAKURYU'] then
            if config.current.randomizer.exclude_rampage then
                goto continue
            else
                if config.current.randomizer.exclude_rampage_village and data['rank'] == dump.ranks_ids['Village'] then goto continue end
                if config.current.randomizer.exclude_rampage_low_rank and data['rank'] == dump.ranks_ids['Low'] then goto continue end
                if config.current.randomizer.exclude_rampage_high_rank and data['rank'] == dump.ranks_ids['High'] then goto continue end
            end
        end
        if data['category'] == 'Event' then
            if config.current.randomizer.exclude_event then
                goto continue
            else
                if config.current.randomizer.exclude_event_low_rank and data['rank'] == dump.ranks_ids['Low'] then goto continue end
                if config.current.randomizer.exclude_event_high_rank and data['rank'] == dump.ranks_ids['High'] then goto continue end
                if config.current.randomizer.exclude_event_master_rank and data['rank'] == dump.ranks_ids['Master'] then goto continue end
            end
        end
        if config.current.randomizer.exclude_support_survey and data['category'] == 'Kingdom' then goto continue end
        if config.current.randomizer.exclude_follower and data['category'] == 'ServantRequest' then goto continue end
        if config.current.randomizer.exclude_training and data['type'] == dump.quest_types['TRAINING'] then goto continue end
        if config.current.randomizer.exclude_tour and data['type'] == dump.quest_types['TOUR'] then goto continue end
        if config.current.randomizer.exclude_capture and data['type'] == dump.quest_types['CAPTURE'] then goto continue end
        if config.current.randomizer.exclude_slay and data['type'] == dump.quest_types['KILL'] then goto continue end
        if config.current.randomizer.exclude_hunt and data['type'] == dump.quest_types['HUNTING'] then goto continue end
        if config.current.randomizer.exclude_boss_rush and data['type'] == dump.quest_types['BOSSRUSH'] then goto continue end
        if config.current.randomizer.exclude_gathering and data['type'] == dump.quest_types['COLLECTS'] then goto continue end
        if config.current.randomizer.exclude_small_monsters and (data['small_monster'] == true or data['small_monster'] == "Unknown") then goto continue end
        if config.current.randomizer.exclude_single_monsters and (data['single_monster'] == true or data['single_monster'] == "Unknown") then goto continue end
        if config.current.randomizer.exclude_multi_monster and (data['multi_monster'] == true or data['multi_monster'] == "Unknown") then goto continue end
        if config.current.randomizer.exclude_not_unlocked and not data['unlocked'] then goto continue end
        if config.current.randomizer.exclude_completed and data['completed'] then goto continue end

        table.insert(randomizer.filtered_quest_list,no)
        ::continue::
    end
end

function randomizer.roll()
    if not dump.ed then dump.quest_data() end

    randomizer.filter_quests()

    if #randomizer.filtered_quest_list == 0 then
        functions.error_handler("There are no quests to randomize.\nTurn off some exclusions.")
        return false
    else
        config.current.auto_quest.quest_no = randomizer.filtered_quest_list[ math.random(#randomizer.filtered_quest_list) ]
        return true
    end

end

function randomizer.init()
    dump = require("AutoQuest.dump")
    config = require("AutoQuest.config")
    functions = require("AutoQuest.Common.functions")
    methods = require("AutoQuest.methods")
end

return randomizer