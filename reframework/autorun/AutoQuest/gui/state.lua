---@class GuiState
---@field combo GuiCombo
---@field input_action string?
---@field listener NewBindListener?
---@field set ImguiConfigSet

---@class (exact) GuiCombo
---@field action Combo
---@field mode Combo
---@field quest Combo
---@field random_rampage_level Combo
---@field random_rampage_target Combo
---@field random_mystery_target Combo
---@field random_mystery_item Combo
---@field random_mystery_party_size Combo
---@field servant1 Combo
---@field servant1_weapon Combo
---@field servant2 Combo
---@field servant2_weapon Combo

---@class (exact) NewBindListener
---@field opt string
---@field opt_name string
---@field listener BindListener
---@field collision string?

local combo = require("AutoQuest.gui.combo")
local config = require("AutoQuest.config.init")
local config_set = require("AutoQuest.util.imgui.config_set")
local data = require("AutoQuest.data.init")
local game_data = require("AutoQuest.util.game.data")
local m = require("AutoQuest.util.ref.methods")
local s = require("AutoQuest.util.ref.singletons")
local util_table = require("AutoQuest.util.misc.table")

local snow_map = data.snow.map
local mod = data.mod
local rl = game_data.reverse_lookup

---@class GuiState
local this = {
    combo = {
        action = combo:new(
            mod.map.actions,
            function(a, b)
                return a.key < b.key
            end,
            nil,
            function(key)
                return config.lang:tr(mod.map.actions[key])
            end
        ),
        mode = combo:new(mod.enum.mod_mode, function(a, b)
            return mod.enum.mod_mode[a.key] < mod.enum.mod_mode[b.key]
        end, function(value)
            return rl(mod.enum.mod_mode, value)
        end, function(key)
            return config.lang:tr("mod.combo_mode_values." .. key)
        end),
        quest = combo:new(mod.enum.quest_board_quest, function(a, b)
            return mod.enum.quest_board_quest[a.key] < mod.enum.quest_board_quest[b.key]
        end, function(value)
            return rl(mod.enum.quest_board_quest, value)
        end, function(key)
            return config.lang:tr("mod.combo_quest_values." .. key)
        end),
        random_rampage_level = combo:new(nil, nil, nil, function(key)
            if key == 7 then
                return string.format(
                    "%s%s%s",
                    config.lang:tr("misc.text_star"),
                    key,
                    config.lang:tr("misc.text_special")
                )
            end

            return config.lang:tr("misc.text_star") .. key + 1
        end),
        random_rampage_target = combo:new(
            nil,
            function(a, b)
                if a.key == 0 then
                    return true
                elseif b.key == 0 then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == 0 then
                    return config.lang:tr("misc.text_any")
                end
                return s.get("snow.gui.MessageManager"):getEnemyNameMessage(key)
            end
        ),
        random_mystery_item = combo:new(
            nil,
            function(a, b)
                if a.key == 67108864 then
                    return true
                elseif b.key == 67108864 then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == 67108864 then
                    return config.lang:tr("misc.text_any")
                end
                return m.getItemName(key)
            end
        ),
        random_mystery_target = combo:new(
            nil,
            function(a, b)
                if a.key == 0 then
                    return true
                elseif b.key == 0 then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == 0 then
                    return config.lang:tr("misc.text_any")
                end
                return s.get("snow.gui.MessageManager"):getEnemyNameMessage(key)
            end
        ),
        random_mystery_party_size = combo:new(
            nil,
            function(a, b)
                return a.value < b.value
            end,
            nil,
            function(key)
                return config.lang:tr("mod.combo_party_size_values." .. key)
            end
        ),
        servant1 = combo:new(
            nil,
            function(a, b)
                if type(a.key) == "string" and type(b.key) == "string" then
                    return mod.enum.servant_type[a.key] < mod.enum.servant_type[b.key]
                elseif type(a.key) == "string" then
                    return true
                elseif type(b.key) == "string" then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == "RANDOM" then
                    return config.lang:tr("misc.text_any")
                elseif key == "NONE" then
                    return config.lang:tr("misc.text_none")
                end
                return s.get("snow.ai.ServantManager"):getServantName(key)
            end
        ),
        servant1_weapon = combo:new(
            nil,
            function(a, b)
                if type(a.key) == "string" and type(b.key) == "string" then
                    return mod.enum.servant_weapon[a.key] < mod.enum.servant_weapon[b.key]
                elseif type(a.key) == "string" then
                    return true
                elseif type(b.key) == "string" then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == "RANDOM" then
                    return config.lang:tr("misc.text_any")
                elseif key == "FAVOURITE" then
                    return config.lang:tr("misc.text_favourite")
                end

                return data.get_weapon_name(key)
            end
        ),
        servant2 = combo:new(
            nil,
            function(a, b)
                if type(a.key) == "string" and type(b.key) == "string" then
                    return mod.enum.servant_type[a.key] < mod.enum.servant_type[b.key]
                elseif type(a.key) == "string" then
                    return true
                elseif type(b.key) == "string" then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == "RANDOM" then
                    return config.lang:tr("misc.text_any")
                elseif key == "NONE" then
                    return config.lang:tr("misc.text_none")
                end
                return s.get("snow.ai.ServantManager"):getServantName(key)
            end
        ),
        servant2_weapon = combo:new(
            nil,
            function(a, b)
                if type(a.key) == "string" and type(b.key) == "string" then
                    return mod.enum.servant_weapon[a.key] < mod.enum.servant_weapon[b.key]
                elseif type(a.key) == "string" then
                    return true
                elseif type(b.key) == "string" then
                    return false
                end

                return a.value < b.value
            end,
            nil,
            function(key)
                if key == "RANDOM" then
                    return config.lang:tr("misc.text_any")
                elseif key == "FAVOURITE" then
                    return config.lang:tr("misc.text_favourite")
                end

                return data.get_weapon_name(key)
            end
        ),
    },
    set = config_set:new(config),
}
---@enum GuiColors
this.colors = {
    bad = 0xff1947ff,
    good = 0xff47ff59,
    info = 0xff27f3f5,
}

local function make_servant_combo_values()
    return util_table.map_value_to_value(
        util_table.array_merge(
            util_table.keys(snow_map.servant_data),
            util_table.keys(mod.enum.servant_type)
        )
    )
end

function this.swap_servant_weapon_combo(combo_obj, config_key, servant_id)
    local servant_data = snow_map.servant_data[servant_id]
    local weapons = {}

    if servant_data then
        weapons = servant_data.weapons
    end

    local values = util_table.map_value_to_value(
        util_table.array_merge(util_table.keys(weapons), util_table.keys(mod.enum.servant_weapon))
    )

    local index = combo_obj:swap(values, config:get(config_key)) --[[@as integer?]]
    if index then
        config:set(config_key, index)
    end
end

---@param rampage_level snow.quest.QuestLevel
function this.swap_rampage_target_combo(rampage_level)
    local index = this.combo.random_rampage_target:swap(
        util_table.map_value_to_value(snow_map.rampage_data[rampage_level]),
        config.current.mod.combo.random_rampage_target
    )

    if index then
        config.current.mod.combo.random_rampage_target = index
    end
end

---@param item_id snow.data.ContentsIdSystem.ItemId
function this.swap_random_mystery_target_combo(item_id)
    local index = this.combo.random_mystery_target:swap(
        util_table.map_value_to_value(snow_map.mystery_data.item[item_id].ems),
        config.current.mod.combo.random_mystery_target
    )

    if index then
        config.current.mod.combo.random_mystery_target = index
    end
end

---@param item_id snow.data.ContentsIdSystem.ItemId
function this.swap_random_mystery_lv_slider_by_item_id(item_id)
    local item_data = snow_map.mystery_data.item[item_id]
    local config_slider = config.current.mod.slider

    if item_data.lv_lower_limit > 0 then
        config_slider.random_mystery_lvl_min = item_data.lv_lower_limit
    end

    if item_data.lv_upper_limit > 0 then
        config_slider.random_mystery_lvl_max = item_data.lv_upper_limit
    end
end

---@param em_id snow.enemy.EnemyDef.EmTypes
function this.swap_random_mystery_lv_slider_by_em_id(em_id)
    local em_lv_min = snow_map.mystery_data.em[em_id]
    local config_slider = config.current.mod.slider
    if config_slider.random_mystery_lvl_min < em_lv_min then
        config_slider.random_mystery_lvl_min = em_lv_min
    end

    if config_slider.random_mystery_lvl_max < em_lv_min then
        config_slider.random_mystery_lvl_max = em_lv_min
    end
end

function this.translate_combo()
    this.combo.action:translate()
    this.combo.mode:translate()
    this.combo.quest:translate()
    this.combo.random_rampage_level:translate()
    this.combo.random_rampage_target:translate()
    this.combo.random_mystery_item:translate()
    this.combo.random_mystery_target:translate()
    this.combo.random_mystery_party_size:translate()
    this.combo.servant1:translate()
    this.combo.servant1_weapon:translate()
    this.combo.servant2:translate()
    this.combo.servant2_weapon:translate()
end

function this.init()
    local config_combo = config.current.mod.combo

    this.combo.random_rampage_level:swap(util_table.keys(snow_map.rampage_data))
    this.combo.random_mystery_item:swap(
        util_table.map_value_to_value(util_table.keys(snow_map.mystery_data.item))
    )
    this.combo.random_mystery_party_size:swap(snow_map.mystery_data.party_size)
    this.combo.servant1:swap(make_servant_combo_values())
    this.combo.servant2:swap(make_servant_combo_values())

    this.swap_servant_weapon_combo(
        this.combo.servant1_weapon,
        "mod.combo.servant1_weapon",
        this.combo.servant1:get_key(config_combo.servant1)
    )
    this.swap_servant_weapon_combo(
        this.combo.servant2_weapon,
        "mod.combo.servant2_weapon",
        this.combo.servant2:get_key(config_combo.servant2)
    )
    this.swap_rampage_target_combo(
        this.combo.random_rampage_level:get_key(config_combo.random_rampage_level)
    )
    this.swap_random_mystery_target_combo(
        this.combo.random_mystery_item:get_key(config_combo.random_mystery_item)
    )
    this.translate_combo()
end

return this
