---@class (exact) Servant
---@field info snow.quest.SelectedQuestServantInfo
---@field servant_id snow.ai.ServantDefine.ServantId

local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local gui_state = require("AutoQuest.gui.state")
local util_ref = require("AutoQuest.util.ref.init")
local util_table = require("AutoQuest.util.misc.table")

local this = {}

local mod_enum = data.mod.enum
local snow_map = data.snow.map

---@return Servant[]?
function this.get()
    local config_mod = config.current.mod

    if not config_mod.bring_servant then
        return
    end

    local all_servants = util_table.map_table(util_table.keys(snow_map.servant_data)) --[[@as table<snow.ai.ServantDefine.ServantId, integer>]]
    local keys = { { index = 1, delayed = false }, { index = 2, delayed = false } }
    ---@type Servant[]
    local ret = {}

    -- ensuring that randomization is always done last
    local i = 1
    while i <= #keys do
        local key = keys[i]
        local follower_key = "servant" .. key.index
        local follower_config_key = "mod.combo." .. follower_key
        local follower_index = config:get(follower_config_key)
        local weapon_key = follower_key .. "_weapon"
        local weapon_config_key = "mod.combo." .. weapon_key
        local weapon_index = config:get(weapon_config_key)

        local servant_data
        local weapons
        local info
        ---@type snow.ai.ServantDefine.ServantId
        local servant_id
        ---@type snow.data.ContentsIdSystem.WeaponId
        local weapon_id

        if follower_index == mod_enum.servant_type.NONE then
            goto continue
        elseif follower_index == mod_enum.servant_type.RANDOM and not key.delayed then
            key.delayed = true
            table.insert(keys, key)
            goto continue
        elseif follower_index == mod_enum.servant_type.RANDOM and key.delayed then
            servant_id = util_table.pick_random_key(all_servants)
        else
            servant_id = gui_state.combo[follower_key]:get_key(follower_index) --[[@as snow.ai.ServantDefine.ServantId]]
        end

        all_servants[servant_id] = nil
        servant_data = snow_map.servant_data[servant_id]
        weapons = servant_data.weapons

        if weapon_index == mod_enum.servant_weapon.RANDOM then
            weapon_id = util_table.pick_random_value(weapons)
        elseif weapon_index == mod_enum.servant_weapon.FAVOURITE then
            weapon_id = weapons[snow_map.servant_data[servant_id].fav_weapon]
        else
            weapon_id = weapons[gui_state.combo[weapon_key]:get_key(weapon_index)]
        end

        info = util_ref.value_type("snow.quest.SelectedQuestServantInfo")
        info._NpcId = servant_data.npc_id
        info._WeaponId = weapon_id
        table.insert(ret, { info = info, servant_id = servant_id })

        ::continue::
        i = i + 1
    end

    if not util_table.empty(ret) then
        return ret
    end
end

return this
