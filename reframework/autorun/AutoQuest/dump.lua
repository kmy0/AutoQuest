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
local quest_categories = {
                    Arena=6,
                    Kingdom=11,
                    Kyousei=10,
                    Mystery=12,
                    ServantRequest=9,
}

local function parse_quest_data(quest_data)
    local no = nil
    local monster_hunt_type = ''
    local quest_cat = nil
    local quest_level = nil
    local highrank_unlock = methods.is_hr_unlocked:call(singletons.progquestman)
    local unlocked = nil
    local type = nil
    local rank = nil
    local online = false
    local target_num = 0

    for no,quest in pairs(quest_data) do

        quest_cat = quest['category']
        quest_level = quest['level']
        quest = quest['data']

        online = false
        monster_hunt_type = 'none'
        target_num = 0
        type = quest:get_field("_QuestType")

        if type == dump.quest_types['HYAKURYU'] then
            quest_cat = 'Rampage'
        end

        if not quest_cat then
            quest_cat = 'Normal'
        end

        if quest_cat ~= 'Random Mystery'
        and quest_cat ~= 'Kingdom'
        and quest_cat ~= 'ServantRequest'
        and type ~= dump.quest_types['TRAINING'] then
            online = true
        end

        if quest_cat ~= 'Mystery' then
            quest_level = quest:get_field("_QuestLv")
        end

        if quest_cat == 'Rampage' then
            monster_hunt_type = 'multi'
        elseif quest_cat == 'Random Mystery' then
            if quest:get_field('_HuntTargetNum') > 1 then
                monster_hunt_type = 'multi'
            else
                monster_hunt_type = 'single'
            end
        elseif type ~= dump.quest_types['TOUR'] and type ~= dump.quest_types['COLLECTS'] then

            target_num = quest:get_field('_TgtNum'):get_elements()
            target_num = target_num[1]:get_field('mValue') + target_num[2]:get_field('mValue')

            if target_num == 1 then
                monster_hunt_type = 'single'
            elseif target_num > 5 then
                monster_hunt_type = 'small'
            elseif target_num > 1 then
                monster_hunt_type = 'multi'
            end
        end

        if quest_cat == 'Rampage' then
            if quest:get_field("_isVIllage") then
                rank = dump.ranks_ids['Village']
            else
                rank = dump.ranks_ids['High']
            end
            quest_level = quest:get_field("_QuestLv")
            type = dump.quest_types['HYAKURYU']
        else
            rank = quest:get_field("_EnemyLv")
        end

        completed = methods.is_quest_clear:call(singletons.progquestman,no)

        if quest_cat == 'Event' and quest:get_field("_EnemyLv") == dump.ranks_ids['High'] and not highrank_unlock then
            unlocked = false
        elseif quest_cat == 'Event' then
            unlocked = true
        else
            unlocked = methods.is_quest_unlocked:call(singletons.progquestman,no)
        end

        dump.quest_data_list[no] = {
                        type=type,
                        rank=rank,
                        level=quest_level,
                        category=quest_cat,
                        monster_hunt_type=monster_hunt_type,
                        unlocked=unlocked,
                        completed=completed,
                        online=online
                        }

    end
end

function dump.random_mystery()
    local quest_data = {}
    for _,quest in pairs(singletons.questman:get_field('_RandomMysteryQuestData'):get_elements()) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            quest_data[no] = {data=quest,category='Random Mystery'}
        end
    end
    for i=0,120 do
        dump.quest_data_list[700000 + i] = nil
    end
    parse_quest_data(quest_data)
end

function dump.quest_data()
    local no = nil
    local quest_data = {}
    local quest_dict = singletons.questman:get_field("_QuestDataDictionary"):get_field('_entries'):get_elements()
    dump.quest_data_list = {}

    for k,v in pairs(quest_categories) do
        for i=0,7 do
            lst = methods.get_quest_no_array:call(singletons.questman,v,i)
            if lst then
                lst = lst:get_elements()
                for _,e in pairs(lst) do
                    no = e:get_field("value__")
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

    for _,quest in pairs(singletons.questman:get_field('_DlQuestData'):get_field("_Param"):get_elements()) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            quest_data[no]['category'] = 'Event'
        end
    end

    for _,quest in pairs(singletons.questman:get_field('_RandomMysteryQuestData'):get_elements()) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            quest_data[no] = {data=quest,category='Random Mystery'}
        end
    end

    parse_quest_data(quest_data)

    if not next(dump.non_custom_quest_ids) then

        for no,_ in pairs(quest_data) do
            dump.non_custom_quest_ids[tostring(no)] = 1
        end
        for i=0,120 do
            dump.non_custom_quest_ids[700000 + i] = 1
        end
        json.dump_file(dump.non_custom_quest_ids_file_name,dump.non_custom_quest_ids)

    end
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