---@class ModBinds
---@field action ModBindManager
---@field monitor BindMonitor

---@class (exact) ModBindBase : BindBase
---@class (exact) ModBind : Bind, ModBindBase

local bind_monitor = require("AutoQuest.util.game.bind.monitor")
local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local mod_bind_manager = require("AutoQuest.bind.manager")
local randomizer = require("AutoQuest.randomizer")
local routine_post = require("reframework.autorun.AutoQuest.routine_post")
local util_game = require("AutoQuest.util.game.init")
local util_mod = require("AutoQuest.util.mod.init")

local mod_map = data.mod.map

---@class ModBinds
local this = {}

---@enum ModBindManagerType
this.manager_names = {
    ACTION = "action",
}

---@param bind ModBind
local function action(bind)
    local type, key = string.match(bind.bound_value, "([^_]*)_(.*)")
    if type == "action" then
        if key == "post" then
            routine_post.new()
        elseif key == "randomize" then
            randomizer.roll()
        end
    elseif type == "option" then
        local val = config:get("mod." .. key)
        config:set("mod." .. key, not val)
        util_mod.send_message(
            string.format(
                "%s %s %s",
                config.lang:tr(mod_map.actions[bind.bound_value]),
                config.lang:tr("misc.text_changed_notifcation_message"),
                not val
            )
        )
    end
end

---@return boolean
function this.init()
    if not util_game.bind.init() then
        return false
    end

    local bind_key = config.current.mod.bind

    this.action = mod_bind_manager:new(this.manager_names.ACTION, action)

    if not this.action:load(bind_key.action) then
        bind_key.action = this.action:get_base_binds()
    end

    this.monitor = bind_monitor:new(this.action)
    this.monitor:set_max_buffer_frame(bind_key.buffer)
    return true
end

return this
