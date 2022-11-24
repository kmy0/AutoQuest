local dump = {}
local singletons
local vars
local methods
local config
local functions


dump.ed = false
dump.no_of_quests = 0
dump.non_custom_quest_ids_file_name = 'AutoQuest/noncustom_ids.json'
dump.anomaly_investigations_main_monsters_file_name = 'AutoQuest/monsters.json'
dump.anomaly_investigations_main_monsters_array = {}

dump.quest_types = {
                INVALID=0,
                HUNTING=1,
                KILL=2,
                CAPTURE=4,
                BOSSRUSH=8,
                COLLECTS=16,
                TOUR=32,
                ARENA=64,
                SPECIAL=128,
                HYAKURYU=256,
                TRAINING=512,
                KYOUSEI=1024
}
dump.ranks_ids = {
                Village=0,
                Low=1,
                High=2,
                Master=3,
                Max=4
}
dump.quest_data_list = {}
dump.quest_categories = {
                    Arena=6,
                    Kingdom=11,
                    Kyousei=10,
                    Mystery=12,
                    ServantRequest=9,
}

local function parse_quest_data(quest_data)
    local highrank_unlock = methods.is_hr_unlocked:call(singletons.progquestman)
    local mysterylabo = methods.get_mystery_labo:call(singletons.facilitydataman)
    local research = {}
    research.request = methods.get_research_target:call(mysterylabo)

    if research.request then
        research.monster = research.request:get_field('_MainTargetEnemyType')
        research.level = methods.get_limit_lvl:call(mysterylabo,research.request:get_field('_QuestCondition'))
    end

    for no,quest in pairs(quest_data) do

        local quest = {
            category=quest.category,
            level=quest.level,
            data=quest.data,
            is_research_request=false,
            is_online=false,
            monster_hunt_type='none',
            target_num=0
        }

        quest.type = quest.data:get_field("_QuestType")

        if quest.type == dump.quest_types['HYAKURYU'] then
            quest.category = 'Rampage'
        end

        if not quest.category then
            quest.category = 'Normal'
        end

        if quest.category ~= 'Random Mystery'
        and quest.category ~= 'Kingdom'
        and quest.category ~= 'ServantRequest'
        and quest.type ~= dump.quest_types['TRAINING']
        and quest.type ~= dump.quest_types['ARENA'] then
            quest.is_online = true
        end

        if quest.category ~= 'Mystery' then
            quest.level = quest.data:get_field("_QuestLv")
        end

        if quest.category == 'Rampage' then
            quest.monster_hunt_type = 'multi'
        elseif quest.category == 'Random Mystery' then
            if quest.data:get_field('_HuntTargetNum') > 1 then
                quest.monster_hunt_type = 'multi'
            else
                quest.monster_hunt_type = 'single'
            end
        elseif quest.type ~= dump.quest_types['TOUR'] and quest.type ~= dump.quest_types['COLLECTS'] then

            quest.target_num = functions.to_array(quest.data:get_field('_TgtNum'))
            quest.target_num = quest.target_num[1] + quest.target_num[2]

            if quest.target_num == 1 then
                quest.monster_hunt_type = 'single'
            elseif quest.target_num > 5 then
                quest.monster_hunt_type = 'small'
            elseif quest.target_num > 1 then
                quest.monster_hunt_type = 'multi'
            end
        end

        if quest.category == 'Rampage' then
            if quest.data:get_field("_isVIllage") then
                quest.rank = dump.ranks_ids['Village']
            else
                quest.rank = dump.ranks_ids['High']
            end
            quest.level = quest.data:get_field("_QuestLv")
            quest.type = dump.quest_types['HYAKURYU']
        else
            quest.rank = quest.data:get_field("_EnemyLv")
        end

        if quest.category == 'Random Mystery' and research.request then
            quest.main_target = methods.get_randmystery_target:call(quest.data)
            if quest.main_target == research.monster and quest.level >= research.level then
                quest.is_research_request = true
            end
        end

        quest.is_completed = methods.is_quest_clear:call(singletons.progquestman,no)

        if quest.category == 'Event' and quest.data:get_field("_EnemyLv") == dump.ranks_ids['High'] and not highrank_unlock then
            quest.is_unlocked = false
        elseif quest.category == 'Event' then
            quest.is_unlocked = true
        else
            quest.is_unlocked = methods.is_quest_unlocked:call(singletons.progquestman,no)
        end

        dump.quest_data_list[no] = {
                        type=quest.type,
                        rank=quest.rank,
                        level=quest.level,
                        category=quest.category,
                        monster_hunt_type=quest.monster_hunt_type,
                        unlocked=quest.is_unlocked,
                        completed=quest.is_completed,
                        online=quest.is_online,
                        research_request=quest.is_research_request
                        }

    end
end

function dump.random_mystery()
    local quest_data = {}

    for _,quest in pairs(functions.to_array(singletons.questman:get_field('_RandomMysteryQuestData'))) do
        no = quest:get_field("_QuestNo")

        if no ~= 0 and no ~= -1 then
            quest_data[no] = {data=quest,category='Random Mystery'}
        end
    end
    for i=0,120 do
        dump.quest_data_list[700000 + i] = nil
    end
    parse_quest_data(quest_data)
    dump.no_of_quests = functions.table_length(dump.quest_data_list)
end

function dump.quest_data()
    local no = nil
    local quest_data = {}
    local quest_dict = functions.to_array(singletons.questman:get_field("_QuestDataDictionary"):get_field('_entries'))
    dump.quest_data_list = {}

    for k,v in pairs(dump.quest_categories) do
        for i=0,7 do
            lst = methods.get_quest_no_array:call(singletons.questman,v,i)
            if lst then
                lst = functions.to_array(lst)
                for _,no in pairs(lst) do
                    quest_data[no] = {category=k,level=i}
                end
            end
        end
    end

    for _,k in pairs(quest_dict) do
        no = k:get_field('key')
        if no ~= 0 and no ~= -1 then
            if not quest_data[no] then
                quest_data[no] = {}
            end
            quest_data[no]['data'] = k:get_field('value'):get_field('<RawNormal>k__BackingField')
        end
    end

    for _,quest in pairs(functions.to_array(singletons.questman:get_field('_DlQuestData'):get_field("_Param"))) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            quest_data[no]['category'] = 'Event'
            dump.non_custom_quest_ids[tostring(no)] = 1
        end
    end

    for _,quest in pairs(functions.to_array(singletons.questman:get_field('_RandomMysteryQuestData'))) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            quest_data[no] = {data=quest,category='Random Mystery'}
        end
    end

    parse_quest_data(quest_data)

    dump.ed = true
    dump.no_of_quests = functions.table_length(dump.quest_data_list)
end

function dump.load()
	dump.non_custom_quest_ids = json.load_file(dump.non_custom_quest_ids_file_name)
	if not dump.non_custom_quest_ids then dump.non_custom_quest_ids = {} end
    dump.anomaly_investigations_main_monsters = json.load_file(dump.anomaly_investigations_main_monsters_file_name)
    if not dump.anomaly_investigations_main_monsters then
        dump.anomaly_investigations_main_monsters = {}
        dump.anomaly_investigations_main_monsters_array = {}
    else
        for k,_ in pairs(dump.anomaly_investigations_main_monsters) do
            table.insert(dump.anomaly_investigations_main_monsters_array,k)
        end
        table.sort(dump.anomaly_investigations_main_monsters_array)
        table.insert(dump.anomaly_investigations_main_monsters_array,1,'Any')
        table.insert(dump.anomaly_investigations_main_monsters_array,2,'Research Target')
    end

end

function dump.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    config = require("AutoQuest.config")
    dump.load()
end

return dump