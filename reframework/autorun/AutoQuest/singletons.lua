local singletons = {}

singletons.guiman = nil
singletons.questman = nil
singletons.progquestman = nil
singletons.chatman = nil
singletons.vilman = nil
singletons.objaccman = nil
singletons.lobbyman = nil
singletons.hwpad = nil
singletons.hwkb = nil
singletons.facilitydataman = nil
singletons.spacewatcher = nil
singletons.quest_counter = nil
singletons.quest_board = nil
singletons.progman = nil

function singletons.get_questman()
	if not singletons.questman then
		singletons.questman = sdk.get_managed_singleton("snow.QuestManager")
	end
	return singletons.questman
end

function singletons.get_progman()
	if not singletons.progman then
		singletons.progman = sdk.get_managed_singleton("snow.progress.ProgressManager")
	end
	return singletons.progman
end

function singletons.get_objaccman()
	if not singletons.objaccman then
		singletons.objaccman = sdk.get_managed_singleton("snow.access.ObjectAccessManager")
	end
	return singletons.objaccman
end

function singletons.get_lobbyman()
	if not singletons.lobbyman then
		singletons.lobbyman = sdk.get_managed_singleton("snow.LobbyManager")
	end
	return singletons.lobbyman
end

function singletons.get_vilman()
	if not singletons.vilman then
		singletons.vilman = sdk.get_managed_singleton("snow.VillageAreaManager")
	end
	return singletons.vilman
end

function singletons.get_chatman()
	if not singletons.chatman then
		singletons.chatman = sdk.get_managed_singleton("snow.gui.ChatManager")
	end
	return singletons.chatman
end

function singletons.get_guiman()
	if not singletons.guiman then
		singletons.guiman = sdk.get_managed_singleton("snow.gui.GuiManager")
	end
	return singletons.guiman
end

function singletons.get_progquestman()
	if not singletons.progquestman then
		singletons.progquestman =
			sdk.get_managed_singleton("snow.progress.quest.ProgressQuestManager")
	end
	return singletons.progquestman
end

function singletons.get_spacewatcher()
	if not singletons.spacewatcher then
		singletons.spacewatcher = sdk.get_managed_singleton("snow.wwise.WwiseChangeSpaceWatcher")
	end
	return singletons.spacewatcher
end

function singletons.get_hwpad()
	if not singletons.hwpad then
		singletons.hwpad = sdk.get_managed_singleton("snow.Pad")
	end
	return singletons.hwpad
end

function singletons.get_hwkb()
	if not singletons.hwkb then
		singletons.hwkb = sdk.get_managed_singleton("snow.GameKeyboard")
	end
	return singletons.hwkb
end

function singletons.get_facilitydataman()
	if not singletons.facilitydataman then
		singletons.facilitydataman = sdk.get_managed_singleton("snow.data.FacilityDataManager")
	end
	return singletons.facilitydataman
end

function singletons.init()
	singletons.get_questman()
	singletons.get_spacewatcher()
	singletons.get_objaccman()
	singletons.get_lobbyman()
	singletons.get_vilman()
	singletons.get_chatman()
	singletons.get_guiman()
	singletons.get_progquestman()
	singletons.get_hwpad()
	singletons.get_hwkb()
	singletons.get_facilitydataman()
	singletons.get_progman()
end

return singletons
