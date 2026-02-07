local bind = require("AutoQuest.bind.init")
local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local e = require("AutoQuest.util.game.enum")
local randomizer = require("AutoQuest.randomizer")
local routine_post = require("reframework.autorun.AutoQuest.routine_post")
local s = require("AutoQuest.util.ref.singletons")
local timer = require("AutoQuest.util.misc.timer")

local snow_map = data.snow.map

local this = {
    ---@type snow.player.GameStatePlayer
    state = -1,
}
local player_index_max =
    sdk.find_type_definition("snow.player.PlayerIndex"):get_field("QuestMax"):get_data() --[[@as snow.player.PlayerIndex]]
local player_index_min =
    sdk.find_type_definition("snow.player.PlayerIndex"):get_field("Pl0"):get_data() --[[@as snow.player.PlayerIndex]]
local auto_post_timer = timer:new(10, nil, nil, false, true)

function this.update()
    bind.monitor:monitor()

    if routine_post.has_instance() then
        routine_post.update()
        return
    end

    if auto_post_timer:active() then
        if routine_post.new() ~= nil then
            auto_post_timer:abort()
        end
    end

    if _G._AUTO_QUEST_RELOAD then
        data.reload_all_quest_data()
        randomizer.filter_quests()
        _G._AUTO_QUEST_RELOAD = false
    end

    local playman = s.get("snow.player.PlayerManager")
    local master_player_id = playman:getMasterPlayerID()

    if master_player_id > player_index_max or master_player_id < player_index_min then
        this.state = -1
        return
    end

    local player_params = playman:get_PlayerParam()
    local master_player_param = player_params[master_player_id]
    local master_player_state = master_player_param._gameStatePlayer

    -- whenever game is launched for the first time, player is always in the 'quest' state, which triggers auto post...
    if
        master_player_state == e.get("snow.player.GameStatePlayer").Quest
        and not s.get("snow.QuestManager"):isActiveQuest()
    then
        return
    end

    if
        master_player_state == e.get("snow.player.GameStatePlayer").Lobby
        and this.state == e.get("snow.player.GameStatePlayer").Quest
    then
        local progman = s.get("snow.progress.quest.ProgressQuestManager")
        local config_mod = config.current.mod

        local quest = snow_map.quest_data[config_mod.quest_id]
        quest.is_completed = progman:isClear(quest.no)

        for _, quest in pairs(snow_map.quest_data) do
            if not quest.is_unlocked then
                quest.is_unlocked = progman:isUnlock(quest.no)
            end
        end

        data.reload_random_mystery()
        data.reload_random_rampage()
        randomizer.filter_quests()
        if config_mod.auto_post then
            auto_post_timer:restart()
        end
    end

    this.state = master_player_state
end

return this
