_G._AUTO_QUEST_RELOAD = false

local config = require("AutoQuest.config.init")
local config_menu = require("AutoQuest.gui.init")
local data = require("AutoQuest.data.init")
local util = require("AutoQuest.util.init")
local logger = util.misc.logger.g
local bind = require("AutoQuest.bind.init")
local hook = require("AutoQuest.hook")
local randomizer = require("AutoQuest.randomizer")
local routine_post = require("reframework.autorun.AutoQuest.routine_post")
local s = require("AutoQuest.util.ref.singletons")
local update = require("AutoQuest.update")

local init = util.misc.init_chain:new(
    "MAIN",
    config.init,
    data.init,
    randomizer.init,
    config_menu.init,
    data.mod.init,
    bind.init
)
init.max_retries = 999
---@class MethodUtil
local m = util.ref.methods

m.checkRandomMysteryQuestOrderBan = m.wrap(
    m.get(
        "snow.quest.nRandomMysteryQuest.checkRandomMysteryQuestOrderBan(snow.quest.RandomMysteryQuestData, System.Boolean)"
    )
) --[[@as fun(quest_data: snow.quest.RandomMysteryQuestData, unknown: System.Boolean): snow.quest.nRandomMysteryQuest.QuestCheckResult]]
m.getItemName = m.wrap(m.get("snow.data.DataShortcut.getName(snow.data.ContentsIdSystem.ItemId)")) --[[@as fun(item_id: snow.data.ContentsIdSystem.ItemId): System.String]]

m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.getQuestCounterSelectedQuest()",
    nil,
    hook.get_selected_quest_post
)
m.hook(
    "snow.QuestManager.questActivate(snow.LobbyManager.QuestIdentifier)",
    nil,
    hook.quest_activate_post
)
m.hook("snow.gui.GuiManager.IsPlayerAllInputDisable()", nil, hook.ret_true_post)
m.hook(

    "snow.gui.fsm.questcounter.GuiQuestCounterFsmTopMenuAction.start(via.behaviortree.ActionArg)",
    hook.skip_func_pre
)
m.hook(

    "snow.gui.fsm.questcounter.GuiQuestCounterFsmTopMenuAction.update(via.behaviortree.ActionArg)",
    hook.skip_func_pre
)
m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.awake()",
    hook.set_quest_counter_type_pre
)
m.hook("snow.gui.GuiManager.IsCanFieldObjectAccessSub()", nil, hook.ret_true_post)
m.hook("snow.gui.GuiManager.isDisplayForHeadMessage(System.Boolean)", nil, hook.ret_true_post)
m.hook(

    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.isSelectedSubMenuCheck(snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.QuestCounterSubMenuType)",
    hook.quest_counter_sub_menu_check_pre,
    hook.thread_ret_post
)
m.hook("snow.SnowSessionManager.reqOnlineWarning()", hook.skip_func_pre)
m.hook("snow.gui.GuiManager.updateYNInfoWindow(System.UInt32)", nil, hook.update_yn_post)
m.hook("snow.QuestManager.questStart()", hook.quest_start_pre)
m.hook("via.wwise.WwiseContainer.trigger(System.UInt32)", hook.skip_sound_pre)
m.hook(
    "snow.gui.StmGuiInput.getDecideButtonTrg(snow.StmInputConfig.KeyConfigType, System.Boolean)",
    nil,
    hook.force_decide_post
)
m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction.getRandamQuickQuestType()",
    nil,
    hook.quick_quest_post
)
m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.getHyakuryuQuestTarget(snow.gui.fsm.questcounter.GuiQuestCounterMenu.SearchQuestType)",
    nil,
    hook.get_rampage_target_post
)
m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.selectedRandomMysteryQuestLevel_Max(snow.gui.fsm.questcounter.GuiQuestCounterMenu.SearchQuestType)",
    nil,
    hook.get_random_mystery_lv_max_post
)
m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.selectedRandomMysteryQuestLevel_Min(snow.gui.fsm.questcounter.GuiQuestCounterMenu.SearchQuestType)",
    nil,
    hook.get_random_mystery_lv_min_post
)
m.hook(
    "snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.selectedRandomMysteryQuestItemId(snow.gui.fsm.questcounter.GuiQuestCounterMenu.SearchQuestType)",
    nil,
    hook.get_random_mystery_item_post
)

re.on_draw_ui(function()
    if imgui.button(string.format("%s %s", config.name, config.commit)) and init.ok then
        local gui_main = config.gui.current.gui.main
        gui_main.is_opened = not gui_main.is_opened
    end

    if not init.failed then
        local errors = logger:format_errors()
        if errors then
            imgui.same_line()
            imgui.text_colored("Error!", config_menu.state.colors.bad)
            util.imgui.tooltip_exclamation(errors)
        elseif not init.ok then
            imgui.same_line()
            imgui.text_colored("Initializing...", config_menu.state.colors.info)
        end
    else
        imgui.same_line()
        imgui.text_colored("Init failed!", config_menu.state.colors.bad)
    end
end)

re.on_application_entry("BeginRendering", function()
    init:init() -- reframework does not like nested re.on_frame

    if s.get_no_cache("snow.gui.fsm.title.GuiTitleMenuFsmManager") and init.ok then
        init:reset()
    end
end)

re.on_frame(function()
    if not init.ok then
        return
    end

    local config_gui = config.gui.current.gui

    if not reframework:is_drawing_ui() then
        config_gui.main.is_opened = false
    end

    if config_gui.main.is_opened then
        config_menu.draw()
    end

    update.update()
    config.run_save()
end)

re.on_config_save(function()
    if data.mod.initialized then
        config.save_no_timer_global()
    end
end)
re.on_script_reset(routine_post.clear)
