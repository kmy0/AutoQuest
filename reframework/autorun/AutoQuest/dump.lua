local dump = {}
local singletons
local vars
local methods
local config
local functions

local quest_cat_list = {}

dump.ed = false
dump.no_of_quests = 0
dump.non_custom_quest_ids_file_name = 'AutoQuest/noncustom_ids.json'

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
                    Kingdom=11,
                    Kyousei=10,
                    Mystery=12,
                    ServantRequest=9,
}

local function get_quest_category(quest_no)
    local cat = nil
    local lvl = nil
    for k,v in pairs(quest_cat_list) do
        if v[quest_no] then
            cat = k
            lvl = v[quest_no]
            break
        end
    end
    return cat,lvl
end

local function parse_quest_data(quest_data,event_ids,random_mystery)
    local no = nil
    local target_type = {}
    local multi_monster = false
    local single_monster = false
    local small_monster = false
    local quest_cat = nil
    local quest_level = nil
    local highrank_unlock = methods.is_hr_unlocked:call(singletons.progquestman)
    local unlocked = nil
    local type = nil
    local rank = nil

    for no,quest in pairs(quest_data) do

        quest_cat,quest_level = get_quest_category(no)

        type = quest:get_field("_QuestType")
        if not quest_cat then
            if event_ids[no] then
                quest_cat = 'Event'

            elseif random_mystery[no] then
                quest_cat = 'Random Mystery'
            elseif type == dump.quest_types['ARENA'] then
                quest_cat = 'Arena'
            elseif type == dump.quest_types['HYAKURYU'] then
                quest_cat = 'Rampage'
            else
                quest_cat = 'Normal'
            end
        end

        if quest_cat ~= 'Mystery' then
            quest_level = quest:get_field("_QuestLv")
        end

        if quest_cat == 'Rampage' then
            multi_monster = 'Unknown'
            single_monster = 'Unknown'
            small_monster = 'Unknown'
        elseif quest_cat == 'Random Mystery' then
            single_monster = true
        else
            local tt = quest:get_field('_TargetType')
            target_type.a = tt:get_element(0):get_field("value__")
            target_type.b = tt:get_element(1):get_field("value__")
            if target_type.b ~= 0 or target_type.a == 5 then
                multi_monster = true
            elseif target_type.a == 6 then
                small_monster = true
            elseif target_type.a < 5 and target_type.a > 1 then
                single_monster = true
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
            completed = false
        else
            rank = quest:get_field("_EnemyLv")
            completed = methods.is_quest_clear:call(singletons.progquestman,no)
        end

        if quest_cat == 'Event' and quest:get_field("_EnemyLv") == dump.ranks_ids['High'] and not highrank_unlock then
            unlocked = false
        else
            unlocked = methods.is_quest_unlocked:call(singletons.progquestman,no)
        end
        dump.quest_data_list[no] = {
                        type=type,
                        rank=rank,
                        level=quest_level,
                        category=quest_cat,
                        small_monster=small_monster,
                        single_monster=single_monster,
                        multi_monster=multi_monster,
                        unlocked=unlocked,
                        completed=completed,
                        data=data
                        }

        multi_monster = false
        single_monster = false
        small_monster = false
    end
end

function dump.random_mystery()
    local random_mystery = {}
    local quest_data = {}
    for _,quest in pairs(singletons.questman:get_field('_RandomMysteryQuestData'):get_elements()) do
        no = quest:get_field("_QuestNo")
        quest_data[no] = quest
        random_mystery[no] = 1
    end
    for i=0,120 do
        dump.quest_data_list[700000 + i] = nil
    end
    parse_quest_data(quest_data,{},random_mystery)
end

function dump.quest_data()
    local no = nil
    local quest_data = {}
    local quest_dict = singletons.questman:get_field("_QuestDataDictionary"):get_field('_entries'):get_elements()
    local event_ids = {}
    local random_mystery = {}
    quest_cat_list = {}
    dump.quest_data_list = {}

    for k,v in pairs(quest_categories) do
        quest_cat_list[k] = {}
        for i=0,7 do
            lst = methods.get_quest_no_array:call(singletons.questman,v,i)
            if lst then
                lst = lst:get_elements()
                for _,e in pairs(lst) do
                    no = e:get_field("value__")
                    quest_cat_list[k][no] = i
                end
            end
        end
    end

    for _,k in pairs(quest_dict) do
        no = k:get_field('key')
        if no ~= 0 and no ~= -1 then
            quest_data[no] = k:get_field('value'):get_field('<RawNormal>k__BackingField')
        end
    end

    for _,quest in pairs(singletons.questman:get_field('_DlQuestData'):get_field("_Param"):get_elements()) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            event_ids[no] = 1
        end
    end

    for _,quest in pairs(singletons.questman:get_field('_RandomMysteryQuestData'):get_elements()) do
        no = quest:get_field("_QuestNo")
        if no ~= 0 and no ~= -1 then
            quest_data[no] = quest
            random_mystery[no] = 1
        end
    end

    -- local rampage_ids = {}
    -- for _,quest in pairs(singletons.questman:get_field('_HyakuryuQuestData'):get_elements()) do
    --     no = quest:get_field("_QuestNo")
    --     if no ~= 0 and no ~= -1 then
    --         quest_data[no] = quest
    --         rampage_ids[no] = 1
    --     end
    -- end

    parse_quest_data(quest_data,event_ids,random_mystery)

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

function dump.non_custom_ids_load()
	dump.non_custom_quest_ids = json.load_file(config.non_custom_quest_ids_file_name)
	if not dump.non_custom_quest_ids then dump.non_custom_quest_ids = {} end
end

function dump.init()
    singletons = require("AutoQuest.singletons")
    vars = require("AutoQuest.Common.vars")
    methods = require("AutoQuest.methods")
    functions = require("AutoQuest.Common.functions")
    config = require("AutoQuest.config")
    dump.non_custom_ids_load()
end

return dump