---@class (exact) MainSettings : SettingsBase
---@field version string
---@field mod ModSettings

---@class (exact) ModLanguage
---@field file string
---@field fallback boolean

---@class (exact) RandomizerSettings
---@field exclude_village boolean
---@field exclude_low_rank boolean
---@field exclude_high_rank boolean
---@field exclude_master_rank boolean
---@field exclude_master_rank0 boolean
---@field exclude_master_rank1 boolean
---@field exclude_master_rank2 boolean
---@field exclude_master_rank3 boolean
---@field exclude_master_rank4 boolean
---@field exclude_master_rank5 boolean
---@field exclude_mystery boolean
---@field exclude_mystery0 boolean
---@field exclude_mystery1 boolean
---@field exclude_mystery2 boolean
---@field exclude_mystery3 boolean
---@field exclude_mystery4 boolean
---@field exclude_mystery5 boolean
---@field exclude_mystery6 boolean
---@field exclude_mystery7 boolean
---@field exclude_mystery8 boolean
---@field exclude_special_random_mystery boolean
---@field exclude_random_mystery boolean
---@field exclude_random_mystery_below integer
---@field exclude_random_mystery_above integer
---@field exclude_normal false
---@field exclude_rampage boolean
---@field exclude_random_rampage boolean
---@field exclude_arena boolean
---@field exclude_servant_request boolean
---@field exclude_kingdom boolean
---@field exclude_event boolean
---@field exclude_training boolean
---@field exclude_tour boolean
---@field exclude_capture boolean
---@field exclude_slay boolean
---@field exclude_hunt boolean
---@field exclude_boss_rush boolean
---@field exclude_gathering boolean
---@field exclude_zako boolean
---@field exclude_one boolean
---@field exclude_multi boolean
---@field exclude_lock boolean
---@field exclude_complete boolean
---@field exclude_invalid_random_mystery boolean
---@field exclude_custom boolean
---@field exclude_no_custom boolean
---@field exclude_post boolean
---@field prefer_research_target boolean
---@field exclude_non_online boolean

---@class (exact) ModSettings
---@field enable_key_binds boolean
---@field enable_notification boolean
---@field auto_post boolean
---@field auto_randomize boolean
---@field auto_depart boolean
---@field send_join_request boolean
---@field filter_quest_reference boolean
---@field bring_servant boolean
---@field hide_disabled boolean
---@field quest_id string
---@field bind {
---     action: BindBase[],
---     buffer: integer,
--- }
---@field combo {
--- key_bind: {
---     action: integer,
---     },
--- mode: integer,
--- quest: integer,
--- random_rampage_target: integer,
--- random_rampage_level: integer,
--- random_mystery_item: integer,
--- random_mystery_party_size: integer,
--- random_mystery_target: integer,
--- servant1: integer,
--- servant1_weapon: integer,
--- servant2: integer,
--- servant2_weapon: integer,
--- }
---@field slider {
--- random_mystery_lvl_min: integer,
--- random_mystery_lvl_max: integer,
--- },
---@field lang ModLanguage
---@field randomizer RandomizerSettings
---@field quest_ref {
--- filter_text: string,
--- }

local version = require("AutoQuest.config.version")

---@type MainSettings
return {
    version = version.version,
    mod = {
        lang = {
            file = "en-us",
            fallback = true,
        },
        quest_id = "",
        enable_key_binds = true,
        enable_notification = true,
        auto_randomize = false,
        auto_post = false,
        auto_depart = false,
        send_join_request = false,
        filter_quest_reference = false,
        bring_servant = false,
        hide_disabled = false,
        bind = {
            action = {},
            buffer = 2,
        },
        combo = {
            key_bind = {
                action = 1,
            },
            mode = 1,
            quest = 1,
            random_rampage_target = 1,
            random_rampage_level = 1,
            random_mystery_item = 1,
            random_mystery_party_size = 1,
            random_mystery_target = 1,
            servant1 = 1,
            servant1_weapon = 1,
            servant2 = 1,
            servant2_weapon = 1,
        },
        slider = {
            random_mystery_lvl_max = 300,
            random_mystery_lvl_min = 1,
        },
        randomizer = {
            exclude_village = false,
            exclude_low_rank = false,
            exclude_high_rank = false,
            exclude_master_rank = false,
            exclude_master_rank0 = false,
            exclude_master_rank1 = false,
            exclude_master_rank2 = false,
            exclude_master_rank3 = false,
            exclude_master_rank4 = false,
            exclude_master_rank5 = false,
            exclude_mystery = false,
            exclude_mystery0 = false,
            exclude_mystery1 = false,
            exclude_mystery2 = false,
            exclude_mystery3 = false,
            exclude_mystery4 = false,
            exclude_mystery5 = false,
            exclude_mystery6 = false,
            exclude_mystery7 = false,
            exclude_mystery8 = false,
            exclude_special_random_mystery = false,
            exclude_random_mystery = false,
            exclude_random_mystery_below = 0,
            exclude_random_mystery_above = 0,
            exclude_normal = false,
            exclude_rampage = false,
            exclude_random_rampage = false,
            exclude_arena = false,
            exclude_servant_request = false,
            exclude_kingdom = false,
            exclude_event = false,
            exclude_training = false,
            exclude_tour = false,
            exclude_capture = false,
            exclude_slay = false,
            exclude_hunt = false,
            exclude_boss_rush = false,
            exclude_gathering = false,
            exclude_zako = false,
            exclude_one = false,
            exclude_multi = false,
            exclude_lock = false,
            exclude_complete = false,
            exclude_invalid_random_mystery = false,
            exclude_custom = false,
            exclude_no_custom = false,
            exclude_post = false,
            prefer_research_target = false,
            exclude_non_online = false,
        },
        quest_ref = {
            filter_text = "",
        },
    },
}
