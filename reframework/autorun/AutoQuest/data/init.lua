local this = {
    snow = require("AutoQuest.data.snow"),
    mod = require("AutoQuest.data.mod"),
}

local config = require("AutoQuest.config.init")
local e = require("AutoQuest.util.game.enum")
---@class MethodUtil
local m = require("AutoQuest.util.ref.methods")
local quest_data = require("AutoQuest.data.quest")
local s = require("AutoQuest.util.ref.singletons")
local util_game = require("AutoQuest.util.game.init")
local util_ref = require("AutoQuest.util.ref.init")
local util_table = require("AutoQuest.util.misc.table")

local snow_map = this.snow.map

m.getMessage = m.wrap(m.get("via.gui.message.get(System.Guid, via.Language)")) --[[@as fun(guid: System.Guid, lang: via.Language): System.String]]

function this.reload_random_mystery()
    snow_map.quest_data = quest_data.reload_random_mystery(snow_map.quest_data)
end

function this.reload_random_rampage()
    snow_map.quest_data = quest_data.reload_random_rampage(snow_map.quest_data)
end

---@param quest_no integer
---@return snow.quest.QuestData?
function this.get_rampage_quest_data(quest_no)
    local quest_arr = s.get("snow.QuestManager"):get_HyakuryuQuestDataArray()
    ---@type snow.quest.QuestData?
    local ret

    util_game.do_something(quest_arr, function(_, _, value)
        if value._QuestNo == quest_no then
            ret = util_ref.ctor("snow.quest.QuestData", true):add_ref() --[[@as snow.quest.QuestData]]
            ret:call(".ctor(snow.quest.HyakuryuQuestData)", value)
            return false
        end
    end)

    return ret
end

---@return table<snow.quest.QuestLevel, snow.enemy.EnemyDef.EmTypes[]>
local function make_rampage_data()
    ---@type table<snow.quest.QuestLevel, snow.enemy.EnemyDef.EmTypes[]>
    local ret = {}
    local getHyakuryuEmTypeList_Hall = m.wrap(
        m.get(
            "snow.quest.nHyakuryuQuest.getHyakuryuEmTypeList_Hall(snow.quest.QuestLevel, snow.quest.QuestLevel, System.Boolean)"
        )
    ) ---@as fun(min: snow.quest.QuestLevel, max: snow.quest.QuestLevel, only_final_boss: System.Boolean): System.Array<snow.enemy.EnemyDef.EmTypes>

    for i = 1, 7 do
        local ems = getHyakuryuEmTypeList_Hall(i, i, true)
        ret[i] = util_game.system_array_to_lua(ems)
        table.insert(ret[i], 0)
    end

    return ret
end

---@return {
--- em: table<snow.enemy.EnemyDef.EmTypes, integer>,
--- item: table<snow.data.ContentsIdSystem.ItemId, {
---     lv_lower_limit: integer,
---     lv_upper_limit: integer,
---     ems: snow.enemy.EnemyDef.EmTypes[],
---     }>,
--- party_size: table<integer, integer>,
--- }
local function make_random_mystery_data()
    ---@type table<snow.enemy.EnemyDef.EmTypes, integer>
    local em_to_level = {}
    ---@type table<snow.data.ContentsIdSystem.ItemId, {lv_lower_limit: integer, lv_upper_limit: integer, ems: table<snow.enemy.EnemyDef.EmTypes, boolean>, party_size: table<integer, integer>,}>
    local item_datas = {}
    local ems = sdk.find_type_definition("snow.enemy.EnemyDef")
        :get_field("RandomMysteryMainEmDataTbl")
        :get_data() --[[@as System.Array<snow.enemy.EnemyDef.EmTypes>]]

    util_game.do_something(ems, function(_, _, em)
        --FIXME: Surely there exists some easy isValid function?
        if s.get("snow.gui.MessageManager"):getEnemyNameMessage(em) == "未指定" then
            return
        end

        local min_lvl = s.get("snow.QuestManager"):getRandomMysteryAppearanceMainEmLevel(em)
        if min_lvl == -1 then
            return
        end

        min_lvl = math.max(min_lvl, 1)
        em_to_level[em] = min_lvl
        local items = s.get("snow.data.LotDataManager"):getMysteryRewardItems(em)

        util_game.do_something(items, function(_, _, item)
            local item_id = item._RewardItem
            --FIXME: Surely there exists some easy isValid function?
            if m.getItemName(item_id) == "" then
                return
            end

            local item_data = item_datas[item_id]
            local lv_lower_limit = item._LvLowerLimit
            local lv_upper_limit = item._LvUpperLimit

            if lv_lower_limit == 0 or lv_upper_limit == 0 then
                return
            end

            if not item_data then
                item_data = {
                    lv_lower_limit = lv_lower_limit,
                    lv_upper_limit = lv_upper_limit,
                    ems = { [0] = true },
                }
                item_datas[item_id] = item_data
            end

            item_data.lv_lower_limit = math.min(item_data.lv_lower_limit, lv_lower_limit)
            item_data.lv_upper_limit = math.max(item_data.lv_upper_limit, lv_upper_limit)
            item_data.ems[em] = true
        end)
    end)

    for _, v in pairs(item_datas) do
        v.ems = util_table.keys(v.ems)
    end

    ---@diagnostic disable-next-line: no-unknown
    em_to_level[0] = 0
    ---@diagnostic disable-next-line: no-unknown
    item_datas[67108864] = {
        lv_lower_limit = 0,
        lv_upper_limit = 0,
        ems = util_table.keys(em_to_level),
    }

    return { em = em_to_level, item = item_datas, party_size = { [2] = 2, [4] = 4 } }
end

---@return table<snow.data.ParamEnum.WeaponModelId, {content_id: snow.data.ContentsIdSystem.WeaponId, player_weapon: snow.player.PlayerWeaponType}>
local function make_weapon_map()
    ---@type table<snow.data.ParamEnum.WeaponModelId, {content_id: snow.data.ContentsIdSystem.WeaponId, player_weapon: snow.player.PlayerWeaponType}>
    local ret = {}

    local getModelId =
        m.wrap(m.get("snow.data.DataShortcut.getModelId(snow.data.ContentsIdSystem.WeaponId)")) --[[@as fun(wp_id: snow.data.ContentsIdSystem.WeaponId): snow.data.ParamEnum.WeaponModelId]]
    local getPlWeaponType =
        m.wrap(m.get("snow.data.DataShortcut.getPlWeaponType(snow.data.ContentsIdSystem.WeaponId)")) --[[@as fun(wp_id: snow.data.ContentsIdSystem.WeaponId): snow.player.PlayerWeaponType]]

    for _, content_id in pairs(util_game.get_fields("snow.data.ContentsIdSystem.WeaponId")) do
        ret[getModelId(content_id)] = {
            player_weapon = getPlWeaponType(content_id),
            content_id = content_id,
        }
    end

    return ret
end

---@return table<snow.ai.ServantDefine.ServantId, {
--- npc_id: any,
--- fav_weapon: snow.player.PlayerWeaponType,
--- weapons: table<snow.player.PlayerWeaponType, snow.data.ContentsIdSystem.WeaponId>,
--- }>
local function make_servant_data()
    ---@type table<snow.ai.ServantDefine.ServantId, {
    --- npc_id: any,
    --- fav_weapon: snow.player.PlayerWeaponType,
    --- weapons: table<snow.player.PlayerWeaponType, snow.data.ContentsIdSystem.WeaponId>,
    --- }>
    local ret = {}
    local servantman = s.get("snow.ai.ServantManager")
    local servant_data = servantman._ServantDataList
    local weapon_map = make_weapon_map()

    util_game.do_something(servant_data._ServantDataList, function(_, _, value)
        local id = value._ServantId
        --FIXME: Surely there exists some easy isValid function?
        if servantman:getServantName(id) == "" then
            return
        end

        local enabled_weapons = util_game.system_array_to_lua(
            servantman:call("getServantEnabledWeapon(snow.ai.ServantDefine.ServantId)", id) --[[@as System.Array<snow.player.PlayerWeaponType>]]
        )
        local weapon_models = value._WeaponModelList
        local fields = weapon_models:get_type_definition():get_fields()
        ---@type table<snow.player.PlayerWeaponType, snow.data.ContentsIdSystem.WeaponId>
        local player_weapon_to_content_id = {}

        for _, field in pairs(fields) do
            local weapon_model_id = field:get_data(weapon_models) --[[@as snow.data.ParamEnum.WeaponModelId]]
            local weapon_data = weapon_map[weapon_model_id]

            if util_table.contains(enabled_weapons, weapon_data.player_weapon) then
                player_weapon_to_content_id[weapon_data.player_weapon] = weapon_data.content_id
            end
        end

        ret[id] = {
            npc_id = s.get("snow.ai.ServantManager"):getNpcId(id),
            fav_weapon = value._FavoriteWeapon,
            weapons = player_weapon_to_content_id,
        }
    end)

    return ret
end

---@param player_weapon snow.player.PlayerWeaponType
---@return string
function this.get_weapon_name(player_weapon)
    local lang = util_game.get_language()
    local guid = util_ref.value_type("System.Guid"):Parse(snow_map.weapon_name_guid[player_weapon])
    return m.getMessage(guid, lang)
end

function this.reload_all_quest_data()
    snow_map.quest_data = quest_data.get()
end

---@return boolean
function this.init()
    local questman = s.get("snow.QuestManager")
    if
        not questman
        or not s.get("snow.ai.ServantManager")
        or s.get_no_cache("snow.gui.fsm.title.GuiTitleMenuFsmManager")
    then
        return false
    end

    local quest_dict = questman._QuestDataDictionary
    if not quest_dict or not quest_dict._entries then
        return false
    end

    e.new("snow.quest.QuestCategory", function(key, _)
        return key ~= "Min"
    end)
    e.new("snow.quest.QuestType")
    e.new("snow.quest.EnemyLv")
    e.new("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.QuestCounterAccessType")
    e.new("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.QuestCounterSubMenuType")
    e.new("snow.LobbyFacilityUIManager.SceneId")
    e.new("snow.gui.GuiCommonSelectWindow.Result")
    e.new("snow.gui.SnowGuiCommonUtility.BaseBranchValue")
    e.new("snow.gui.GuiCommonYNInfoWindow.YNInfoUIState")
    e.new("snow.player.GameStatePlayer")
    e.new("snow.SnowSessionManager.RequestResult")
    e.new("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.QuestCounterTopMenuType")
    e.new("snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction.AutoMatichState")

    if util_table.any(e.enums, function(_, value)
        return not value.ok
    end) then
        return false
    end

    snow_map.quest_data = quest_data.get()
    snow_map.default_quest_no = json.load_file(config.quest_no_path) or {}
    snow_map.rampage_data = make_rampage_data()
    snow_map.mystery_data = make_random_mystery_data()
    snow_map.servant_data = make_servant_data()
    return true
end

return this
