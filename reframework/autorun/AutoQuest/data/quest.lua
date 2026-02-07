---@class (exact) Quest
---@field type snow.quest.QuestType
---@field enemy_level snow.quest.EnemyLv
---@field level snow.quest.QuestLevel | System.Int32
---@field category QuestCategory
---@field hunt_type QuestHuntType
---@field no snow.quest.QuestNo
---@field map snow.QuestMapManager.MapNoType
---@field map_name string
---@field no_key string
---@field title string
---@field is_unlocked boolean
---@field is_valid boolean
---@field is_completed boolean
---@field is_research_request boolean
---@field is_online boolean

local mod_enum = require("AutoQuest.data.mod").enum
local e = require("AutoQuest.util.game.enum")
local m = require("AutoQuest.util.ref.methods")
local s = require("AutoQuest.util.ref.singletons")
local util_game = require("AutoQuest.util.game.init")
local util_misc = require("AutoQuest.util.misc.init")
local util_ref = require("AutoQuest.util.ref.init")
local util_table = require("AutoQuest.util.misc.table")

local this = {}

---@param quest_no snow.quest.QuestNo
---@return Quest
local function quest_ctor(quest_no)
    return {
        type = 0,
        enemy_level = 0,
        level = 0,
        category = mod_enum.quest_category.NORMAL --[[@as QuestCategory]],
        hunt_type = mod_enum.quest_hunt_type.ONE --[[@as QuestHuntType]],
        no = quest_no,
        no_key = tostring(quest_no),
        title = "",
        map = 0,
        map_name = "",
        is_unlocked = s.get("snow.progress.quest.ProgressQuestManager"):isUnlock(quest_no),
        is_valid = true,
        is_completed = s.get("snow.progress.quest.ProgressQuestManager"):isClear(quest_no),
        is_research_request = false,
        is_online = true,
    }
end

---@return table<snow.quest.QuestNo, {category: snow.quest.QuestCategory, level: snow.quest.QuestLevel}>
local function get_category_data()
    ---@type table<snow.quest.QuestNo, {category: snow.quest.QuestCategory, level: snow.quest.QuestLevel}>>
    local ret = {}
    local max = sdk.find_type_definition("snow.quest.QuestLevel"):get_field("EX_MAX"):get_data() --[[@as snow.quest.QuestLevel]]
    local questman = s.get("snow.QuestManager")

    for _, quest_category in e.iter("snow.quest.QuestCategory") do
        for quest_level = 0, max do
            util_misc.try(function()
                -- this throws when index is out of range
                local arr = questman:getQuestNumberArray(quest_category, quest_level)
                if arr then
                    util_game.do_something(arr, function(_, _, value)
                        if value <= 0 then
                            return
                        end

                        ret[value] = {
                            category = quest_category,
                            level = quest_level,
                        }
                    end)
                end
            end)
        end
    end

    return ret
end

---@return table<snow.quest.QuestNo, boolean>
local function get_event_data()
    ---@type table<snow.quest.QuestNo, boolean>
    local ret = {}
    local event_quests = s.get("snow.QuestManager")._DlQuestData

    util_game.do_something(event_quests._Param, function(_, _, value)
        if value._QuestNo <= 0 then
            return
        end

        ret[value._QuestNo] = true
    end)

    return ret
end

---@return table<snow.quest.QuestNo, boolean>
local function get_arena_data()
    ---@type table<snow.quest.QuestNo, boolean>
    local ret = {}
    local arena_quest_data = s.get("snow.QuestManager")._ArenaQuestData

    -- cba to type those...
    for _, field_name in pairs({
        "_Param",
        "_Param1",
        "_Param2",
        "_Param3",
        "_Param_MR",
        "_Param_MR1",
    }) do
        local params = arena_quest_data:get_field(field_name) --[[@as System.Array<snow.quest.ArenaQuestData.Param>]]
        util_game.do_something(params, function(_, _, value)
            ret[value._QuestNo] = true
        end)
    end

    return ret
end

---@return table<snow.quest.QuestNo, snow.quest.RandomMysteryQuestData>
local function get_random_mystery_data()
    ---@type table<snow.quest.QuestNo, snow.quest.RandomMysteryQuestData>
    local ret = {}
    local mystery_quests = s.get("snow.QuestManager")._RandomMysteryQuestData

    util_game.do_something(mystery_quests, function(_, _, value)
        if value._QuestNo <= 0 then
            return
        end

        ret[value._QuestNo] = value
    end)

    return ret
end

---@param target_num integer
---@return QuestHuntType
local function get_hunt_type(target_num)
    if target_num == 1 then
        return mod_enum.quest_hunt_type.ONE
    elseif target_num > 5 then
        return mod_enum.quest_hunt_type.ZAKO
    elseif target_num > 1 then
        return mod_enum.quest_hunt_type.MULTI
    end

    return mod_enum.quest_hunt_type.NONE
end

---@param quest_data snow.quest.QuestData
---@param is_special_random_mystery boolean
---@return string
local function get_quest_name(quest_data, is_special_random_mystery)
    local is_changed = util_ref.value_type("System.Boolean")
    return quest_data:getQuestTextCore(0, nil, is_special_random_mystery, is_changed:get_address())
end

---@return table<string, Quest>
local function parse_random_mystery_quests()
    ---@type table<string, Quest>
    local ret = {}
    local quests = get_random_mystery_data()
    local mystery_lab = s.get("snow.data.FacilityDataManager"):getMysteryLaboFacility()
    local request = mystery_lab:get_LaboTarget()
    local request_monster = -1
    local request_level = -1

    if request then
        request_monster = request:get_MainTargetEnemyType()
        request_level = mystery_lab:getLimitLv(request:get_QuestCondition())
    end

    for quest_no, quest_param in pairs(quests) do
        local quest = quest_ctor(quest_no)
        local quest_data = util_ref.ctor("snow.quest.QuestData", true)
        quest_data:call(".ctor(snow.quest.RandomMysteryQuestData)", quest_param)

        quest.level = quest_param._QuestLv
        quest.type = quest_param._QuestType
        quest.category = mod_enum.quest_category.RANDOM_MYSTERY
        quest.enemy_level = e.get("snow.quest.EnemyLv").Master
        quest.hunt_type = get_hunt_type(quest_param._HuntTargetNum)
        quest.is_research_request = quest_param:getMainTargetEmType() == request_monster
            and quest.level >= request_level
        quest.is_valid = m.checkRandomMysteryQuestOrderBan(quest_param, false) == 0
        quest.title = get_quest_name(quest_data, false)
        quest.map = quest_param._MapNo
        quest.map_name = s.get("snow.gui.MessageManager"):getMapNameMessage(quest.map)
        ret[quest.no_key] = quest

        if quest_param._isSpecialQuestOpen then
            local quest_s = util_table.deep_copy(quest)
            quest_s.category = mod_enum.quest_category.SPECIAL_RANDOM_MYSTERY
            quest_s.no_key = quest.no_key .. "S"
            quest_s.title = get_quest_name(quest_data, true)
            ret[quest_s.no_key] = quest_s
        end
    end

    return ret
end

---@param quest_datas snow.quest.QuestData[]
---@param category QuestCategory
---@return table<string, Quest>
local function parse_rampage_quest_data(quest_datas, category)
    ---@type table<string, Quest>
    local ret = {}
    for _, quest_data in pairs(quest_datas) do
        ---@type Quest
        local quest = quest_ctor(quest_data:getQuestNo())
        if quest.no == -1 then
            goto continue
        end

        quest.level = quest_data:getQuestLv()
        quest.type = quest_data:getQuestType()
        quest.category = category
        quest.enemy_level = quest_data:getEnemyLv()
        quest.hunt_type = mod_enum.quest_hunt_type.MULTI
        quest.title = get_quest_name(quest_data, false)
        quest.map = quest_data:getMapNo()
        quest.map_name = s.get("snow.gui.MessageManager"):getMapNameMessage(quest.map)
        ret[quest.no_key] = quest
        ::continue::
    end

    return ret
end

local function parse_random_rampage_quests()
    local quest_arr = s.get("snow.QuestManager"):get_HyakuryuQuestDataArray()
    local quest_datas = {}

    util_game.do_something(quest_arr, function(_, _, value)
        local quest_data = util_ref.ctor("snow.quest.QuestData", true)
        quest_data:call(".ctor(snow.quest.HyakuryuQuestData)", value)

        table.insert(quest_datas, quest_data)
    end)

    return parse_rampage_quest_data(quest_datas, mod_enum.quest_category.RANDOM_RAMPAGE)
end

---@return table<string, Quest>
local function parse_normal_quests()
    ---@type table<string, Quest>
    local ret = {}
    local quest_dict = s.get("snow.QuestManager")._QuestDataDictionary
    local category_data = get_category_data()
    local event_quests = get_event_data()
    local arena_quests = get_arena_data()
    local is_high_rank = s.get("snow.progress.quest.ProgressQuestManager"):get_IsUnlockHighRank()
    ---@type snow.quest.QuestData[]
    local rampage_quests = {}

    util_game.do_something_dict(quest_dict, function(_, quest_no, quest_data)
        if not quest_data then
            return
        end

        local quest_param = quest_data:get_RawNormal()
        local quest_type = quest_param._QuestType

        if quest_type == e.get("snow.quest.QuestType").HYAKURYU then
            table.insert(rampage_quests, quest_data)
            return
        end

        ---@type Quest
        local quest = quest_ctor(quest_no)
        local cat = category_data[quest_no] and category_data[quest_no].category or -1
        quest.level = quest_param._QuestLv
        quest.enemy_level = quest_param._EnemyLv

        if event_quests[quest_no] then
            quest.category = mod_enum.quest_category.EVENT
            quest.is_unlocked = is_high_rank
                or (not is_high_rank and quest.enemy_level == e.get("snow.quest.EnemyLv").Low)
        elseif cat == e.get("snow.quest.QuestCategory").Arena or arena_quests[quest_no] then
            quest.category = mod_enum.quest_category.ARENA
            quest.is_online = false
        elseif cat == e.get("snow.quest.QuestCategory").Mystery then
            quest.category = mod_enum.quest_category.MYSTERY
            quest.level = category_data[quest_no].level
        elseif cat == e.get("snow.quest.QuestCategory").Kingdom then
            quest.category = mod_enum.quest_category.KINGDOM
            quest.is_online = false
        elseif cat == e.get("snow.quest.QuestCategory").ServantRequest then
            quest.category = mod_enum.quest_category.SERVANT_REQUEST
            quest.is_online = false
        elseif quest_type == e.get("snow.quest.QuestType").TOUR then
            quest.category = mod_enum.quest_category.TOUR
        elseif quest_type == e.get("snow.quest.QuestType").TRAINING then
            quest.category = mod_enum.quest_category.TRAINING
            quest.is_online = false
        else
            quest.category = mod_enum.quest_category.NORMAL
        end

        if quest.enemy_level == e.get("snow.quest.EnemyLv").Village then
            quest.is_online = false
        end

        local target_num = 0
        util_game.do_something(quest_param._TgtNum, function(_, _, value)
            target_num = target_num + value --[[@as integer]]
        end)

        quest.hunt_type = get_hunt_type(target_num)
        quest.type = quest_type
        quest.map = quest_param._MapNo
        quest.map_name = s.get("snow.gui.MessageManager"):getMapNameMessage(quest.map)
        quest.title = get_quest_name(quest_data, false)
        ret[quest.no_key] = quest
    end)

    return util_table.merge(
        ret,
        parse_rampage_quest_data(rampage_quests, mod_enum.quest_category.RAMPAGE)
    )
end

---@param quest_data table<string, Quest>
---@return table<string, Quest>
function this.reload_random_mystery(quest_data)
    for i = 0, 200 do
        local key = tostring(700000 + i)
        quest_data[key] = nil
        quest_data[key .. "S"] = nil
    end

    return util_table.merge(quest_data, parse_random_mystery_quests())
end

---@param quest_data table<string, Quest>
---@return table<string, Quest>
function this.reload_random_rampage(quest_data)
    for no_key, quest in pairs(quest_data) do
        if quest.category == mod_enum.quest_category.RANDOM_RAMPAGE then
            quest_data[no_key] = nil
        end
    end

    return util_table.merge(quest_data, parse_random_rampage_quests())
end

---@return table<string, Quest>
function this.get()
    return util_table.merge(
        parse_normal_quests(),
        parse_random_mystery_quests(),
        parse_random_rampage_quests()
    )
end

return this
