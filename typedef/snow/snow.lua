---@meta

---@class snow.BehaviorRoot : via.Behavior
---@class snow.SnowSingletonBehaviorRoot : snow.BehaviorRoot
---@class snow.gui.fsm.GuiFsmBaseManager : snow.SnowSingletonBehaviorRoot
---@class snow.gui.fsm.questcounter.GuiQuestCounterFsmActionRoot : snow.gui.fsm.SnowGuiFsmActionRoot
---@class snow.gui.fsm.SnowGuiFsmActionRoot : via.behaviortree.Action
---@class via.behaviortree.Action : via.clr.ManagedObject
---@class via.behaviortree.ActionArg : via.behaviortree.ContentArg
---@class via.behaviortree.BehaviorTree : via.Component
---@class snow.gui.GuiBaseBehavior : snow.gui.GuiRootBaseBehavior
---@class snow.gui.GuiRootBaseBehavior : snow.BehaviorRoot
---@class snow.gui.SnowGuiCommonUtility.GuiCursorBase : via.clr.ManagedObject
---@class snow.SaveDataBase : via.clr.ManagedObject
---@class snow.quest.ArenaQuestData : via.UserData
---@class snow.ai.ServantWeaponModelList : via.clr.ManagedObject

---@class snow.GameKeyboard : snow.SnowSingletonBehaviorRoot
---@field hardKeyboard snow.GameKeyboard.HardwareKeyboard

---@class snow.GameKeyboard.HardwareKeyboard : via.clr.ManagedObject
---@field getDown fun(self: snow.GameKeyboard.HardwareKeyboard, key_enum: via.hid.KeyboardKey): System.Boolean

---@class snow.Pad : snow.SnowSingletonBehaviorRoot
---@field hard snow.Pad.Device

---@class snow.Pad.Device : via.clr.ManagedObject
---@field get_on fun(self: snow.Pad.Device): snow.Pad.Button

---@class snow.StmInputManager.ActiveGameDevice : via.clr.ManagedObject
---@field _ActiveDevice snow.StmInputManager.ActiveDevice

---@class snow.StmInputManager : snow.SnowSingletonBehaviorRoot
---@field _ActiveDevice snow.StmInputManager.ActiveGameDevice

---@class snow.gui.GuiManager : snow.SnowSingletonBehaviorRoot
---@field IsCanInvokeQuestBoard fun(self: snow.gui.GuiManager): System.Boolean
---@field get_refQuestStartFlowHandler fun(self: snow.gui.GuiManager): snow.gui.QuestStartFlowHandler
---@field get_refGuiServantSelectInfoWindow fun(self: snow.gui.GuiManager): snow.gui.GuiServantSelectInfoWindow
---@field get_refGuiCommonSelectWindow fun(self: snow.gui.GuiManager): snow.gui.GuiCommonSelectWindow
---@field isOpenYNInfo fun(self: snow.gui.GuiManager): System.Boolean
---@field isOpenServantSelectInfoWindow fun(self: snow.gui.GuiManager): System.Boolean
---@field isOpenSelectInfo fun(self: snow.gui.GuiManager): System.Boolean
---@field closeYNInfo fun(self: snow.gui.GuiManager)
---@field closeServantSelectInfoWindow fun(self: snow.gui.GuiManager)
---@field closeSelectWindow fun(self: snow.gui.GuiManager)
---@field closeInfo fun(self: snow.gui.GuiManager)
---@field set_IsActivateQuestCounterFromQuestBoard fun(self: snow.gui.GuiManager, val: System.Boolean)

---@class snow.QuestManager : snow.SnowSingletonBehaviorRoot
---@field getRandomMysteryAppearanceMainEmLevel fun(self: snow.QuestManager, em: snow.enemy.EnemyDef.EmTypes): System.Int32
---@field get_HyakuryuQuestDataArray fun(self: snow.QuestManager): System.Array<snow.quest.HyakuryuQuestData>
---@field get_SaveData fun(self: snow.QuestManager): snow.QuestManager.QuestSaveData
---@field isActiveQuest fun(self: snow.QuestManager): System.Boolean
---@field getQuestNumberArray fun(self: snow.QuestManager, category: snow.quest.QuestCategory, level: snow.quest.QuestLevel): System.Array<snow.quest.QuestNo>
---@field _QuestDataDictionary System.Dictionary<System.Int32, snow.quest.QuestData>
---@field _DlQuestData snow.quest.NormalQuestData
---@field _RandomMysteryQuestData System.Array<snow.quest.RandomMysteryQuestData>
---@field _ArenaQuestData System.Array<snow.quest.ArenaQuestData>
---@field _QuestIdentifier snow.LobbyManager.QuestIdentifier

---@class snow.LobbyManager : snow.SnowSingletonBehaviorRoot
---@field isOnline fun(self: snow.LobbyManager): System.Boolean

---@class snow.gui.ChatManager : snow.SnowSingletonBehaviorRoot
---@field reqAddChatInfomation fun(self: snow.gui.ChatManager, msg: System.String, wise_trigger: System.UInt32)

---@class snow.quest.QuestData : via.clr.ManagedObject
---@field getQuestNo fun(self: snow.quest.QuestData): System.Int32
---@field getQuestLv fun(self: snow.quest.QuestData): System.Int32
---@field getQuestType fun(self: snow.quest.QuestData): snow.quest.QuestType
---@field getEnemyLv fun(self: snow.quest.QuestData): snow.quest.EnemyLv
---@field getMapNo fun(self: snow.quest.QuestData): snow.QuestMapManager.MapNoType
---@field get_RawNormal fun(self: snow.quest.QuestData): snow.quest.NormalQuestData.Param
---@field getQuestTextCore fun(self: snow.quest.QuestData, type: snow.quest.QuestText, qi: snow.LobbyManager.QuestIdentifier?, is_special_random_mystery: boolean, is_changed_bool_ptr: integer): System.String
---@field QuestOrderMsgIdTbl System.Array<System.Guid>

---@class snow.quest.NormalQuestData : via.UserData
---@field _Param System.Array<snow.quest.NormalQuestData.Param>

---@class snow.quest.NormalQuestData.Param : via.clr.ManagedObject
---@field _QuestNo System.Int32
---@field _QuestType snow.quest.QuestType
---@field _EnemyLv snow.quest.EnemyLv
---@field _QuestLv snow.quest.QuestLevel
---@field _TgtNum System.Array<System.UInt32>
---@field _MapNo snow.QuestMapManager.MapNoType

---@class snow.quest.RandomMysteryQuestData : via.clr.ManagedObject
---@field getMainTargetEmType fun(self: snow.quest.RandomMysteryQuestData): snow.enemy.EnemyDef.EmTypes
---@field _QuestNo System.Int32
---@field _QuestType snow.quest.QuestType
---@field _QuestLv System.Int32
---@field _HuntTargetNum System.Int32
---@field _isSpecialQuestOpen System.Boolean
---@field _MapNo snow.QuestMapManager.MapNoType

---@class snow.progress.quest.ProgressQuestManager : snow.SnowSingletonBehaviorRoot
---@field isClear fun(self: snow.progress.quest.ProgressQuestManager, quest_no: snow.quest.QuestNo): System.Boolean
---@field get_IsUnlockHighRank fun(self: snow.progress.quest.ProgressQuestManager): System.Boolean
---@field isUnlock fun(self: snow.progress.quest.ProgressQuestManager, quest_no: snow.quest.QuestNo): System.Boolean

---@class snow.data.FacilityDataManager : snow.SnowSingletonBehaviorRoot
---@field getMysteryLaboFacility fun(self: snow.data.FacilityDataManager): snow.data.MysteryLaboFacility

---@class snow.data.MysteryLaboFacility : via.clr.ManagedObject
---@field get_LaboTarget fun(self: snow.data.MysteryLaboFacility): snow.data.MysteryLaboTarget
---@field getLimitLv fun(self: snow.data.MysteryLaboFacility, condition: snow.data.MysteryTargetQuestCondition): System.Int32

---@class snow.data.MysteryLaboTarget : via.clr.ManagedObject
---@field get_MainTargetEnemyType fun(self: snow.data.MysteryLaboTarget): snow.enemy.EnemyDef.EmTypes
---@field get_QuestCondition fun(self: snow.data.MysteryLaboTarget): snow.data.MysteryTargetQuestCondition

---@class snow.gui.MessageManager : via.clr.ManagedObject
---@field getMapNameMessage fun(self: snow.gui.MessageManager, map_id: snow.QuestMapManager.MapNoType): System.String
---@field getEnemyNameMessage fun(self: snow.gui.MessageManager ,em_type: snow.enemy.EnemyDef.EmTypes): System.String

---@class snow.gui.QuestStartFlowHandler : snow.BehaviorRoot
---@field requestGoQuest fun(self: snow.gui.QuestStartFlowHandler, is_shortcut: System.Boolean)

---@class snow.gui.fsm.questcounter.GuiQuestCounterFsmManager : snow.gui.fsm.GuiFsmBaseManager
---@field set_QuestCounterType fun(self: snow.gui.fsm.questcounter.GuiQuestCounterFsmManager, type: snow.gui.fsm.questcounter.GuiQuestCounterFsmManager.QuestCounterAccessType)
---@field get_refQuestCounterBehaviorTree fun(self: snow.gui.fsm.questcounter.GuiQuestCounterFsmManager): via.behaviortree.BehaviorTree
---@field get_BaseBranchValue fun(self: snow.gui.fsm.questcounter.GuiQuestCounterFsmManager): snow.gui.SnowGuiCommonUtility.BaseBranchValue
---@field set__BoardOrderNum fun(self: snow.gui.fsm.questcounter.GuiQuestCounterFsmManager, num: System.UInt32)
---@field requestQuestIdentifier snow.LobbyManager.QuestIdentifier

---@class snow.LobbyManager.QuestIdentifier : via.clr.ManagedObject
---@field _QuestNo System.Int32

---@class snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction : snow.gui.fsm.questcounter.GuiQuestCounterFsmActionRoot
---@field start fun(self: snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction, arg: via.behaviortree.ActionArg)
---@field _RoutineCtrl snow.RoutineCtrl

---@class snow.LobbyFacilityUIManager : snow.SnowSingletonBehaviorRoot
---@field activateOnly fun(self: snow.LobbyFacilityUIManager, type: snow.LobbyFacilityUIManager.SceneId)
---@field deactivateOnly fun(self: snow.LobbyFacilityUIManager, type: snow.LobbyFacilityUIManager.SceneId)

---@class via.behaviortree.ContentArg : via.clr.ManagedObject
---@field setOwnerComponentPtr fun(self: via.behaviortree.ContentArg, behavior_ptr: integer)

---@class snow.gui.GuiServantSelectInfoWindow : snow.gui.GuiBaseBehavior
---@field _ScrollListCtrl snow.gui.GuiServantSelectInfoWindow.ScrollListCtrl

---@class snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase : via.clr.ManagedObject
---@field _Cursor snow.gui.SnowGuiCommonUtility.MenuListCursor
---@field _scrL_List via.gui.ScrollList

---@class snow.gui.GuiServantSelectInfoWindow.ScrollListCtrl : snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase
---@field _result snow.gui.GuiCommonSelectWindow.Result

---@class snow.gui.SnowGuiCommonUtility.MenuListCursor : snow.gui.SnowGuiCommonUtility.GuiCursorBase
---@field set_index fun(self: snow.gui.SnowGuiCommonUtility.MenuListCursor, idx: System.Int32)

---@class snow.gui.GuiCommonSelectWindow : snow.gui.GuiBaseBehavior
---@field _ScrollListCtrl snow.gui.GuiCommonSelectWindow.ScrollListCtrl

---@class snow.gui.GuiCommonSelectWindow.ScrollListCtrl : snow.gui.SnowGuiCommonBehavior.MenuListCtrlBase
---@field _result snow.gui.GuiCommonSelectWindow.Result

---@class snow.QuestManager.QuestSaveData : snow.SaveDataBase
---@field _IsServantSelectCheck System.Boolean

---@class snow.RoutineCtrl : via.clr.ManagedObject
---@field execute fun(self: snow.RoutineCtrl)
---@field isExecute fun(self: snow.RoutineCtrl): System.Boolean
---@field Rno System.Int32

---@class snow.player.PlayerRequestEquipsData
---@field _gameStatePlayer snow.player.GameStatePlayer

---@class snow.player.PlayerManager : snow.SnowSingletonBehaviorRoot
---@field getMasterPlayerID fun(self: snow.player.PlayerManager): snow.player.PlayerIndex
---@field get_PlayerParam fun(self: snow.player.PlayerManager): System.Array<snow.player.PlayerRequestEquipsData>

---@class snow.quest.ArenaQuestData.Param : via.clr.ManagedObject
---@field _QuestNo System.Int32

---@class snow.quest.HyakuryuQuestData : via.clr.ManagedObject
---@field _QuestNo System.Int32

---@class snow.SnowSessionManager : snow.SnowSingletonBehaviorRoot
---@field get_lastRequestResult fun(self: snow.SnowSessionManager): snow.SnowSessionManager.RequestResult

---@class snow.data.LotDataManager : snow.SnowSingletonBehaviorRoot
---@field getMysteryRewardItems fun(self: snow.data.LotDataManager, em: snow.enemy.EnemyDef.EmTypes): System.Array<snow.data.MysteryRewardItemUserData.Param>

---@class snow.data.MysteryRewardItemUserData.Param : via.clr.ManagedObject
---@field _LvLowerLimit System.Int32
---@field _LvUpperLimit System.Int32
---@field _RewardItem snow.data.ContentsIdSystem.ItemId

---@class snow.ai.ServantManager : snow.SnowSingletonBehaviorRoot
---@field getServantName fun(self: snow.ai.ServantManager, servant_id: snow.ai.ServantDefine.ServantId): System.String
---@field getNpcId fun(self: snow.ai.ServantManager, servant_id: snow.ai.ServantDefine.ServantId): snow.NpcDefine.NpcID
---@field _ServantDataList snow.ai.ServantDataList

---@class snow.ai.ServantDataList : via.UserData
---@field _ServantDataList System.Array<snow.ai.ServantData>

---@class snow.ai.ServantData : via.UserData
---@field _ServantId snow.ai.ServantDefine.ServantId
---@field _WeaponModelList snow.ai.ServantWeaponModelList
---@field _FavoriteWeapon snow.player.PlayerWeaponType

---@class snow.quest.SelectedQuestServantInfo : System.ValueType
---@field _NpcId snow.NpcDefine.NpcID
---@field _WeaponId snow.data.ContentsIdSystem.WeaponId

---@class snow.LobbyManager.QuestIdentifier : via.clr.ManagedObject
---@field _servantIds System.Array<snow.ai.ServantDefine.ServantId>
---@field _selectedQuestServanInfoList System.Array<snow.quest.SelectedQuestServantInfo>
