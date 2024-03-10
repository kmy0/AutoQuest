local methods = {}

local guiman_type_def = sdk.find_type_definition("snow.gui.GuiManager")
methods.get_quest_board = guiman_type_def:get_method("get_refGuiQuestBoard")
methods.can_open_quest_board = guiman_type_def:get_method("IsCanInvokeQuestBoard")
methods.invoke_action_bar_id = guiman_type_def:get_method("invokeShortcutAsOtherCommand")
methods.close_hud = guiman_type_def:get_method("closeStartMenuHudWithOpen()")
methods.open_hud = guiman_type_def:get_method("openStartMenuHudWithClose")
methods.get_options_window = guiman_type_def:get_method("get_refGuiOptionWindow")
methods.open_all_quest_hud = guiman_type_def:get_method("openAllQuestHudUI")
methods.is_open_yn = guiman_type_def:get_method("isOpenYNInfo")
methods.is_open_info = guiman_type_def:get_method("isOpenInfo()")
methods.is_open_select = guiman_type_def:get_method("isOpenSelectInfo()")
methods.is_open_startmenu = guiman_type_def:get_method("IsStartMenuAndSubmenuOpen()")
methods.update_yn_window = guiman_type_def:get_method("updateYNInfoWindow")

local gui_quest_board_type_def = sdk.find_type_definition("snow.gui.GuiQuestBoard")
methods.quest_board_top_start = gui_quest_board_type_def:get_method("routineTopMenuStart")
methods.quest_board_decide_quick = gui_quest_board_type_def:get_method("decideQuick")
methods.quest_board_decide_hall = gui_quest_board_type_def:get_method("decideHall")
methods.quest_board_on_destroy = gui_quest_board_type_def:get_method("onDestroy")

local menu_list_cursor_type_def =
	sdk.find_type_definition("snow.gui.SnowGuiCommonUtility.MenuListCursor")
methods.menu_list_cursor_get_index = menu_list_cursor_type_def:get_method("get_index")
methods.menu_list_cursor_set_index = menu_list_cursor_type_def:get_method("set_index")

local quest_board_quest_list_type_def = sdk.find_type_definition("snow.gui.QuestboardList")
methods.get_selected_hunter_info = quest_board_quest_list_type_def:get_method("getSelectHunterInfo")
methods.quest_check = quest_board_quest_list_type_def:get_method("isSelectQuestOrder")

local lobbyman_type_def = sdk.find_type_definition("snow.LobbyManager")
methods.recieve_chat_info = lobbyman_type_def:get_method("receiveChatInfomation")
methods.is_online = lobbyman_type_def:get_method("isOnline")
methods.request_ready = lobbyman_type_def:get_method("requestPrepareQuest")

local questman_type_def = sdk.find_type_definition("snow.QuestManager")
methods.is_quest_posted = questman_type_def:get_method("isActiveQuest")
methods.get_active_quest_id = questman_type_def:get_method("getActiveQuestIdentifier")
methods.get_quest_data = questman_type_def:get_method("getQuestData")
methods.get_quest_data_quest_counter = questman_type_def:get_method("getQuestData(System.Int32)")
methods.quest_activate = questman_type_def:get_method("questActivate")
methods.get_quest_no_array = questman_type_def:get_method("getQuestNumberArray")
methods.quest_start = questman_type_def:get_method("questStart")
methods.get_monster_min_lvl_appearance =
	questman_type_def:get_method("getRandomMysteryAppearanceMainEmLevel")

local quest_data_type_def = sdk.find_type_definition("snow.quest.QuestData")
methods.get_quest_level = quest_data_type_def:get_method("getQuestLvEx")
methods.get_quest_text = quest_data_type_def:get_method("getQuestTextCore")
methods.get_quest_type = quest_data_type_def:get_method("getQuestType")
methods.is_random_mystery = quest_data_type_def:get_method("isRandomMysteryQuest")
methods.check_quest_hr = quest_data_type_def:get_method("checkQuestOrderHunterRank")

local gui_input_type_def = sdk.find_type_definition("snow.gui.StmGuiInput")
methods.decide_button = gui_input_type_def:get_method("getDecideButtonTrg")
methods.cancel_button = gui_input_type_def:get_method("getCancelButtonOrTrg")

local quest_counter_type_def =
	sdk.find_type_definition("snow.gui.fsm.questcounter.GuiQuestCounterFsmManager")
methods.reset_quest_identifier = quest_counter_type_def:get_method("resetRequestQuestIdentifier")
methods.get_selected_quest = quest_counter_type_def:get_method("getQuestCounterSelectedQuest")
methods.get_active_menu_quest_list = quest_counter_type_def:get_method("getActiveQuestMenuList")
methods.is_servant_quest =
	quest_counter_type_def:get_method("isCanJoinedServantQuest(System.Int32)")
methods.save_random_mystery_search_info =
	quest_counter_type_def:get_method("saveRandomMysteryQuestBoardSerchInfo()")
methods.get_mr_progress = quest_counter_type_def:get_method("getHallMRProgress")

local quest_id_type_def = sdk.find_type_definition("snow.LobbyManager.QuestIdentifier")
methods.quest_id_reset = quest_id_type_def:get_method("reset")
methods.quest_id_copy_from = quest_id_type_def:get_method("copyFrom")

local objaccman_type_def = sdk.find_type_definition("snow.access.ObjectAccessManager")
methods.get_sensor = objaccman_type_def:get_method("getRegisteredSensor")
methods.focus_next_target = objaccman_type_def:get_method("focusNextTarget")

local progquest_type_def = sdk.find_type_definition("snow.progress.quest.ProgressQuestManager")
methods.is_hr_unlocked = progquest_type_def:get_method("get_IsUnlockHighRank")
methods.is_quest_clear = progquest_type_def:get_method("isClear")
methods.is_quest_unlocked = progquest_type_def:get_method("isUnlock(snow.quest.QuestNo)")

local quest_session_action_type_def =
	sdk.find_type_definition("snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction")
methods.send_quest_to_questman =
	quest_session_action_type_def:get_method("setQuestInfoToQuestManager")

local session_manager_type_def = sdk.find_type_definition("snow.SnowSessionManager")
methods.is_internet = session_manager_type_def:get_method("IsInternet")
methods.online_warn = session_manager_type_def:get_method("reqOnlineWarning")

local hard_kb_type_def = sdk.find_type_definition("snow.GameKeyboard.HardwareKeyboard")
methods.check_kb_btn = hard_kb_type_def:get_method("getTrg")
methods.get_kb_down_btn = hard_kb_type_def:get_method("getDown")

local hard_pad_type_def = sdk.find_type_definition("snow.Pad.Device")
methods.check_pad_btn = hard_pad_type_def:get_method("andTrg")
methods.get_pad_type = hard_pad_type_def:get_method("get_deviceKindDetails")

local vilman_type_def = sdk.find_type_definition("snow.VillageAreaManager")
methods.get_location = vilman_type_def:get_method("get__CurrentAreaNo")
methods.after_area_act = vilman_type_def:get_method("callAfterAreaActivation")

local mysterylabo_type_def = sdk.find_type_definition("snow.data.MysteryLaboFacility")
methods.get_research_target = mysterylabo_type_def:get_method("get_LaboTarget")
methods.get_limit_lvl = mysterylabo_type_def:get_method("getLimitLv")

methods.get_delta_time = sdk.find_type_definition("via.Application")
	:get_method("get_FrameTimeMillisecond")
methods.get_hash_code = sdk.find_type_definition("System.Guid"):get_method("GetHashCode")
methods.quest_counter_awake = sdk.find_type_definition(
	"snow.SnowSingletonBehaviorRoot`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>"
):get_method("awake")
methods.quest_counter_order_update =
	sdk.find_type_definition("snow.gui.fsm.questcounter.GuiQuestCounterOrder")
		:get_method("updateQuestCounterOrderNormalQuestInfo")
methods.quest_counter_on_destroy = sdk.find_type_definition(
	"snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>"
):get_method("onDestroy")
methods.pop_sensor_check_access =
	sdk.find_type_definition("snow.access.ObjectPopSensor.DetectedInfo"):get_method("checkAccess")
methods.pop_sensor_get_access_target = sdk.find_type_definition("snow.access.ObjectPopSensor")
	:get_method("get_AccessTarget")
methods.get_gameobject_name = sdk.find_type_definition("via.GameObject"):get_method("get_Name")
methods.interact_button = sdk.find_type_definition("snow.player.PlayerInput")
	:get_method("isDecideButton")
methods.quest_board_update_order = sdk.find_type_definition("snow.gui.QuestBoardOrder")
	:get_method("_update_normal")
methods.quest_info_win_update = sdk.find_type_definition("snow.gui.GuiLobbyQuestInfoWindow")
	:get_method("updateQuestInfo")
methods.post_info_message = sdk.find_type_definition("snow.gui.ChatManager")
	:get_method("reqAddChatInfomation")
methods.text_set_message = sdk.find_type_definition("via.gui.Text"):get_method("set_Message")
methods.routine_quit = sdk.find_type_definition("snow.gui.StmGuiGameQuitFlowCtrl")
	:get_method("routineQuit")
methods.is_mystery = sdk.find_type_definition("snow.quest.QuestUtility")
	:get_method("isMysteryQuest")
methods.go_quest = sdk.find_type_definition("snow.gui.QuestStartFlowHandler")
	:get_method("requestGoQuest")
methods.get_mystery_labo = sdk.find_type_definition("snow.data.FacilityDataManager")
	:get_method("getMysteryLaboFacility")
methods.get_randmystery_target = sdk.find_type_definition("snow.quest.RandomMysteryQuestData")
	:get_method("getMainTargetEmType")
methods.random_mystery_quest_auth = sdk.find_type_definition("snow.quest.nRandomMysteryQuest")
	:get_method("checkRandomMysteryQuestOrderBan")
methods.tree_set_node_by_id = sdk.find_type_definition("via.behaviortree.BehaviorTree"):get_method(
	"setCurrentNode(System.UInt64, System.UInt32, via.behaviortree.SetNodeInfo)"
)
methods.get_mystery_research_level = sdk.find_type_definition("snow.progress.ProgressManager")
	:get_method("get_MysteryResearchLevel()")

return methods
