---@class ModData
---@field map ModMap
---@field enum ModEnum
---@field initialized boolean

---@class (exact) ModMap
---@field actions table<string, string>

---@class (exact) ModEnum
---@field quest_hunt_type QuestHuntType.*
---@field quest_category QuestCategory.*
---@field mod_mode ModMode.*
---@field quest_board_quest QuestBoardQuest.*
---@field servant_weapon ServantWeapon.*
---@field servant_type ServantType.*

---@class ModData
local this = {
    ---@diagnostic disable-next-line: missing-fields
    enum = {},
    map = {
        actions = {
            action_post = "actions.button_post",
            action_randomize = "actions.button_randomize",
            option_auto_post = "options.box_auto_post",
            option_auto_randomize = "options.box_auto_randomize",
            option_auto_depart = "options.box_auto_depart",
            option_send_join_request = "options.box_send_join_request",
            option_filter_quest_reference = "options.box_filter_quest_reference",
            option_bring_servant = "options.box_bring_servant",
        },
    },
}

---@enum QuestHuntType
this.enum.quest_hunt_type = { ---@class QuestHuntType.*
    NONE = 1,
    ONE = 2,
    MULTI = 3,
    ZAKO = 4,
}
---@enum QuestCategory
this.enum.quest_category = { ---@class QuestCategory.*
    NORMAL = 1,
    MYSTERY = 2,
    RANDOM_MYSTERY = 3,
    SPECIAL_RANDOM_MYSTERY = 4,
    KINGDOM = 5,
    SERVANT_REQUEST = 6,
    ARENA = 7,
    EVENT = 8,
    TRAINING = 9,
    TOUR = 10,
    RAMPAGE = 11,
    RANDOM_RAMPAGE = 12,
}
---@enum ModMode
this.enum.mod_mode = { ---@class ModMode.*
    QUEST_COUNTER = 1,
    QUEST_BOARD = 2.,
}
---@enum QuestBoardQuest
this.enum.quest_board_quest = { ---@class QuestBoardQuest.*
    SPECIFIC = 1,
    RANDOM_LOW_RANK = 2,
    RANDOM_HIGH_RANK = 3,
    RANDOM_MASTER_RANK = 4,
    RANDOM_MYSTERY = 5,
    RANDOM_RAMPAGE = 6,
    RANDOM_RANDOM_MYSTERY = 7,
    RANDOM_SPECIAL_RANDOM_MYSTERY = 8,
}
---@enum ServantWeapon
this.enum.servant_weapon = { ---@class ServantWeapon.*
    RANDOM = 1,
    FAVOURITE = 2,
}
---@enum ServantType
this.enum.servant_type = { ---@class ServantType.*
    RANDOM = 1,
    NONE = 2,
}

---@return boolean
function this.init()
    this.initialized = true
    return true
end

return this
