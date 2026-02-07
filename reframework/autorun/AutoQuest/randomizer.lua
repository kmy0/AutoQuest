---@class Randomizer
---@field filtered Quest[]
---@field research_targets Quest[]
---@field posted_quests SimpleJsonCache

local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local e = require("AutoQuest.util.game.enum")
local simple_json_cache = require("AutoQuest.util.misc.simple_json_cache")
local util_mod = require("AutoQuest.util.mod.init")
local util_table = require("AutoQuest.util.misc.table")

local snow_map = data.snow.map
local mod_enum = data.mod.enum

---@class Randomizer
local this = {
    filtered = {},
    research_targets = {},
    posted_quests = simple_json_cache:new(config.posted_quests_path),
}

function this.filter_quests()
    this.filtered = {}
    this.research_targets = {}
    local config_randomizer = config.current.mod.randomizer
    for quest_no, quest in pairs(snow_map.quest_data) do
        if quest.type == e.get("snow.quest.QuestType").INVALID then
            goto continue
        end

        -- other
        if
            (config_randomizer.exclude_post and this.posted_quests:get(quest_no))
            or (config_randomizer.exclude_non_online and not quest.is_online)
            or (config_randomizer.exclude_custom and not snow_map.default_quest_no[quest_no])
            or (config_randomizer.exclude_no_custom and snow_map.default_quest_no[quest_no])
            or (config_randomizer.exclude_complete and quest.is_completed)
            or (config_randomizer.exclude_lock and not quest.is_unlocked)
            or (quest.hunt_type == mod_enum.quest_hunt_type.ONE and config_randomizer.exclude_one)
            or (quest.hunt_type == mod_enum.quest_hunt_type.MULTI and config_randomizer.exclude_multi)
            or (quest.hunt_type == mod_enum.quest_hunt_type.ZAKO and config_randomizer.exclude_zako)
        then
            goto continue
        end

        local is_mystery = util_table.any({
            mod_enum.quest_category.MYSTERY,
            mod_enum.quest_category.RANDOM_MYSTERY,
            mod_enum.quest_category.SPECIAL_RANDOM_MYSTERY,
            mod_enum.quest_category.SERVANT_REQUEST,
            mod_enum.quest_category.KINGDOM,
            ---@diagnostic disable-next-line: no-unknown
        }, function(_, v)
            return quest.category == v
        end)

        -- quest rank
        if
            (
                config_randomizer.exclude_village
                and quest.enemy_level == e.get("snow.quest.EnemyLv").Village
            )
            or (config_randomizer.exclude_low_rank and quest.enemy_level == e.get(
                "snow.quest.EnemyLv"
            ).Low)
            or (config_randomizer.exclude_high_rank and quest.enemy_level == e.get(
                "snow.quest.EnemyLv"
            ).High)
            or (
                config_randomizer.exclude_master_rank
                and quest.enemy_level == e.get("snow.quest.EnemyLv").Master
                and not is_mystery
            )
        then
            goto continue
        end

        -- quest category
        if
            (config_randomizer.exclude_normal and quest.category == mod_enum.quest_category.NORMAL)
            or (config_randomizer.exclude_arena and quest.category == mod_enum.quest_category.ARENA)
            or (config_randomizer.exclude_rampage and quest.category == mod_enum.quest_category.RAMPAGE)
            or (config_randomizer.exclude_random_rampage and quest.category == mod_enum.quest_category.RANDOM_RAMPAGE)
            or (config_randomizer.exclude_mystery and quest.category == mod_enum.quest_category.MYSTERY)
            or (config_randomizer.exclude_random_mystery and quest.category == mod_enum.quest_category.RANDOM_MYSTERY)
            or (config_randomizer.exclude_special_random_mystery and quest.category == mod_enum.quest_category.SPECIAL_RANDOM_MYSTERY)
            or (config_randomizer.exclude_servant_request and quest.category == mod_enum.quest_category.SERVANT_REQUEST)
            or (config_randomizer.exclude_kingdom and quest.category == mod_enum.quest_category.KINGDOM)
            or (config_randomizer.exclude_event and quest.category == mod_enum.quest_category.EVENT)
            or (config_randomizer.exclude_tour and quest.category == mod_enum.quest_category.TOUR)
            or (
                config_randomizer.exclude_training
                and quest.category == mod_enum.quest_category.TRAINING
            )
        then
            goto continue
        end

        -- quest type
        if
            (
                config_randomizer.exclude_capture
                and quest.type == e.get("snow.quest.QuestType").CAPTURE
            )
            or (config_randomizer.exclude_slay and quest.type == e.get("snow.quest.QuestType").KILL)
            or (config_randomizer.exclude_hunt and quest.type == e.get("snow.quest.QuestType").HUNTING)
            or (config_randomizer.exclude_boss_rush and quest.type == e.get("snow.quest.QuestType").BOSSRUSH)
            or (
                config_randomizer.exclude_gathering
                and quest.type == e.get("snow.quest.QuestType").COLLECTS
            )
        then
            goto continue
        end

        -- quest level
        if
            (
                quest.category == mod_enum.quest_category.MYSTERY
                and config_randomizer["exclude_mystery" .. quest.level]
            )
            or (not is_mystery and quest.enemy_level == e.get("snow.quest.EnemyLv").Master and config_randomizer["exclude_master_rank" .. quest.level])
            or (
                (
                    quest.category == mod_enum.quest_category.RANDOM_MYSTERY
                    or quest.category == mod_enum.quest_category.SPECIAL_RANDOM_MYSTERY
                )
                and (
                    (
                        config_randomizer.exclude_random_mystery_below ~= 0
                        and quest.level < config_randomizer.exclude_random_mystery_below
                    )
                    or (
                        config_randomizer.exclude_random_mystery_above ~= 0
                        and quest.level > config_randomizer.exclude_random_mystery_above
                    )
                )
            )
        then
            goto continue
        end

        if quest.is_research_request then
            table.insert(this.research_targets, quest)
        end

        table.insert(this.filtered, quest)
        ::continue::
    end
end

---@return Quest?
function this.get_quest()
    ---@type Quest?
    local ret
    local config_randomizer = config.current.mod.randomizer

    if config_randomizer.prefer_research_target and #this.research_targets > 0 then
        ret = util_table.pick_random_value(this.research_targets)
    else
        ret = util_table.pick_random_value(this.filtered)
    end

    return ret
end

---@return boolean
function this.roll()
    local quest = this.get_quest()
    if not quest then
        util_mod.send_error_message(config.lang:tr("errors.no_quests"))
        return false
    end

    config.current.mod.quest_id = quest.no_key
    return true
end

---@return boolean
function this.init()
    this.posted_quests:init()
    this.filter_quests()

    return true
end

return this
