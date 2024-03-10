local singletons = require("AutoQuest.singletons")
local methods = require("AutoQuest.methods")
local vars = require("AutoQuest.Common.vars")
local functions = require("AutoQuest.Common.functions")
local config = require("AutoQuest.config")
local config_menu = require("AutoQuest.config_menu")
-- local native_config_menu = require("AutoQuest.native_config_menu")
local bind = require("AutoQuest.bind")
local common_hooks = require("AutoQuest.Common.hooks")
local dump = require("AutoQuest.dump")
local randomizer = require("AutoQuest.randomizer")
local quest_board = require("AutoQuest.Modes.quest_board")
local speedrun = require("AutoQuest.Modes.speedrun")
local quest_counter = require("AutoQuest.Modes.quest_counter")
local mystery_mode = require("AutoQuest.mystery_mode")

singletons.init()
functions.init()

config.init()

common_hooks.init()
dump.init()
mystery_mode.init()
randomizer.init()
bind.init()

config_menu.init()
-- native_config_menu.init()

quest_counter.init()
speedrun.init()
quest_board.init()

local function switch_posting_method()
	singletons.quest_counter = nil
	singletons.quest_board = nil
	if config.current.auto_quest.posting_method == 2 then
		quest_counter.switch()
	elseif config.current.auto_quest.posting_method == 1 then
		speedrun.switch()
	elseif config.current.auto_quest.posting_method == 3 then
		quest_board.switch()
	end
	randomizer.filter_quests()
end

switch_posting_method()

re.on_draw_ui(function()
	if imgui.button("AutoQuest " .. config.version) then
		config_menu.is_opened = not config_menu.is_opened
	end
end)

re.on_frame(function()
	singletons.init()
	bind.update()

	if not reframework:is_drawing_ui() then
		config_menu.is_opened = false
	end

	if config_menu.is_opened then
		pcall(config_menu.draw)
	end
	if vars.posting_method_changed then
		switch_posting_method()
		vars.posting_method_changed = false
	end
end)

re.on_config_save(function()
	config.save()
end)
