---@class (exact) RoutinePostQuest
---@field quest Quest
---@field servant Servant[]?
---@field protected _create_session_action snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction
---@field protected _state RoutinePostQuestState
---@field protected _actions table<RoutinePostQuestState, fun(self: RoutinePostQuest)>
---@field protected _servant_ok boolean

---@class RoutinePostQuestHolder
---@field protected _instance RoutinePostQuest?

local config = require("AutoQuest.config.init")
local data = require("AutoQuest.data.init")
local game_data = require("AutoQuest.util.game.data")
local randomizer = require("AutoQuest.randomizer")
local s = require("AutoQuest.util.ref.singletons")
local servant = require("AutoQuest.servant")
local util_misc = require("AutoQuest.util.misc.init")
local util_mod = require("AutoQuest.util.mod.init")
local util_ref = require("AutoQuest.util.ref.init")

local snow_map = data.snow.map
local snow_enum = data.snow.enum
local mod_enum = data.mod.enum
local rl = game_data.reverse_lookup

---@class RoutinePostQuestHolder
local this = {}

---@class RoutinePostQuest
local RoutinePostQuest = {}
---@diagnostic disable-next-line: inject-field
RoutinePostQuest.__index = RoutinePostQuest

---@enum RoutinePostQuestState
this.state = {
    OPEN_QUEST_COUNTER = 1,
    START_SESSION_ACTION = 2,
    DECIDE_SELECT = 3,
    WAIT_COMPLETE = 4,
    WAIT_CLOSE = 5,
    ROUTINE_END = 6,
    SET_SERVANT = 7,
    AUTO_DEPART = 8,
    END = 9,
    ERR = 10,
}

---@param quest Quest
---@param servant Servant[]?
---@return RoutinePostQuest
function RoutinePostQuest:new(quest, servant)
    local o = {
        quest = quest,
        servant = servant,
        _state = 1,
        _servant_ok = false,
        _create_session_action = util_ref
            .ctor("snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction")
            :add_ref() --[[@as snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction]],
        _actions = {
            [this.state.OPEN_QUEST_COUNTER] = RoutinePostQuest._open_quest_counter,
            [this.state.START_SESSION_ACTION] = RoutinePostQuest._start_action,
            [this.state.DECIDE_SELECT] = RoutinePostQuest._decide_select,
            [this.state.WAIT_COMPLETE] = RoutinePostQuest._wait_complete,
            [this.state.WAIT_CLOSE] = RoutinePostQuest._wait_close,
            [this.state.ROUTINE_END] = RoutinePostQuest._routine_end,
            [this.state.SET_SERVANT] = RoutinePostQuest._set_servant,
            [this.state.AUTO_DEPART] = RoutinePostQuest._auto_depart,
        },
    }
    setmetatable(o, self)
    return o
end

---@protected
---@param next_state RoutinePostQuestState
function RoutinePostQuest:_set_state(next_state)
    self._state = next_state
end

---@protected
function RoutinePostQuest:_open_quest_counter()
    s.get_no_cache("snow.LobbyFacilityUIManager")
        :activateOnly(rl(snow_enum.facility_ui_type, "QuestCounter"))
    self:_set_state(this.state.START_SESSION_ACTION)
end

---@protected
function RoutinePostQuest:_start_action()
    local quest_counter = s.get_no_cache("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager")
    if quest_counter then
        local arg = sdk.create_instance("via.behaviortree.ActionArg"):add_ref() --[[@as via.behaviortree.ActionArg]]
        local behavior_tree = quest_counter:get_refQuestCounterBehaviorTree()
        arg:setOwnerComponentPtr(behavior_tree:get_address())
        self._create_session_action:start(arg)
        self:_set_state(this.state.DECIDE_SELECT)
    end
end

---@protected
function RoutinePostQuest:_decide_select()
    local guiman = s.get("snow.gui.GuiManager")

    if guiman:isOpenYNInfo() then
        self:_set_state(this.state.WAIT_COMPLETE)
        return
    end

    ---@type snow.gui.GuiServantSelectInfoWindow | snow.gui.GuiCommonSelectWindow
    local sel
    if guiman:isOpenServantSelectInfoWindow() then
        sel = guiman:get_refGuiServantSelectInfoWindow()
        local quest_save = s.get("snow.QuestManager"):get_SaveData()
        quest_save._IsServantSelectCheck = false
        self._servant_ok = true
    elseif guiman:isOpenSelectInfo() then
        sel = guiman:get_refGuiCommonSelectWindow()
    else
        return
    end

    local index = 0
    local scroll_ctrl = sel._ScrollListCtrl
    local cursor = scroll_ctrl._Cursor

    if
        config.current.mod.send_join_request
        and config.current.mod.combo.mode == mod_enum.mod_mode.QUEST_COUNTER
        and (not self._servant_ok or not self.servant)
    then
        local scroll = scroll_ctrl._scrL_List
        local items = scroll:get_Items()
        local item = items[1]

        if item:get_PlayState() ~= "UNFOCUS" then --FIXME: there should be a better way to check if its not selectable...
            index = 1
        end
    end

    scroll_ctrl._result = rl(snow_enum.select_result, "Decide")
    cursor:set_index(index)
    self:_set_state(this.state.WAIT_COMPLETE)
end

---@protected
function RoutinePostQuest:_wait_complete()
    local quest_counter = s.get_no_cache("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager")

    if
        s.get("snow.SnowSessionManager"):get_lastRequestResult()
                == rl(snow_enum.request_result, "Failed")
            and not quest_counter
        or ( --FIXME: this completely breaks quest counter routine, it's the only way that I could find in a reasonable amount of time to detect if user canceled matching
            config.current.mod.combo.mode == mod_enum.mod_mode.QUEST_BOARD
            and self._create_session_action._RoutineCtrl.Rno
                == rl(snow_enum.quest_session_action_state, "WarningStart")
        )
    then
        self:_set_state(this.state.ERR)
    end

    if
        quest_counter
            and quest_counter:get_BaseBranchValue() == rl(snow_enum.base_branch_value, "SUCCESS")
        or (not quest_counter and config.current.mod.combo.mode == mod_enum.mod_mode.QUEST_BOARD)
    then
        s.get("snow.gui.GuiManager"):set_IsActivateQuestCounterFromQuestBoard(false)
        s.get_no_cache("snow.LobbyFacilityUIManager")
            :deactivateOnly(rl(snow_enum.facility_ui_type, "QuestCounter"))
        self:_set_state(this.state.WAIT_CLOSE)
    end
end

---@protected
function RoutinePostQuest:_wait_close()
    local quest_counter = s.get_no_cache("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager")
    if not quest_counter then
        self:_set_state(this.state.ROUTINE_END)
    end
end

---@protected
function RoutinePostQuest:_routine_end()
    self:_set_state(this.state.SET_SERVANT)
end

function RoutinePostQuest:_set_servant()
    if self.servant and self._servant_ok and s.get("snow.QuestManager"):isActiveQuest() then
        local qi = s.get("snow.QuestManager")._QuestIdentifier
        for i = 1, #self.servant do
            local _servant = self.servant[i]
            qi._selectedQuestServanInfoList:Add(_servant.info)
            qi._servantIds:Add(_servant.servant_id)
        end
    end

    self:_set_state(this.state.AUTO_DEPART)
end

---@protected
function RoutinePostQuest:_auto_depart()
    if config.current.mod.auto_depart and s.get("snow.QuestManager"):isActiveQuest() then
        local flow = s.get("snow.gui.GuiManager"):get_refQuestStartFlowHandler()
        flow:requestGoQuest(true)
    end

    self:_set_state(this.state.END)
end

---@return boolean?
function RoutinePostQuest:update()
    self._actions[self._state](self)

    if self._state == this.state.ERR then
        return
    end

    if self._state == this.state.END then
        return false
    end

    if self._state < this.state.ROUTINE_END then
        local routine = self._create_session_action._RoutineCtrl
        if routine and routine:isExecute() then
            routine:execute()
        end
    end

    return true
end

---@return boolean?
function this.new()
    local config_mod = config.current.mod
    if
        this._instance
        or not s.get("snow.gui.GuiManager"):IsCanInvokeQuestBoard()
        or s.get("snow.QuestManager"):isActiveQuest()
        or (config_mod.auto_randomize and not randomizer.roll())
    then
        return
    end

    local quest = snow_map.quest_data[config_mod.quest_id]
    if not quest then
        util_mod.send_error_message(config.lang:tr("errors.invalid_quest_id"))
        return false
    end

    this._instance = RoutinePostQuest:new(quest, servant.get())
    return true
end

---@return boolean
function this.has_instance()
    return this._instance ~= nil
end

function this.update()
    util_misc.try(function()
        local res = this._instance:update()
        if res == nil then
            this.clear()
        elseif not res then
            this._instance = nil
        end
    end, function(err)
        log.debug(err)
        this.clear()
    end)
end

---@return Quest
function this.get_quest()
    return this._instance.quest
end

---@return RoutinePostQuestState
function this.get_state()
    ---@diagnostic disable-next-line: invisible
    return this._instance._state
end

---@param state RoutinePostQuestState
---@return boolean
function this.is_state(state)
    return state == this.get_state()
end

function this.clear()
    if this.has_instance() then
        local guiman = s.get("snow.gui.GuiManager")
        guiman:closeYNInfo()
        guiman:closeServantSelectInfoWindow()
        guiman:closeSelectWindow()
        guiman:closeInfo()
        s.get("snow.gui.GuiManager"):set_IsActivateQuestCounterFromQuestBoard(false)
        s.get_no_cache("snow.LobbyFacilityUIManager")
            :deactivateOnly(rl(snow_enum.facility_ui_type, "QuestCounter"))
        this._instance = nil
    end
end

return this
