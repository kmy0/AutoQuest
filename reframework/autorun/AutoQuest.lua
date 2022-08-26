local singletons = require("AutoQuest.singletons")
local methods = require("AutoQuest.methods")
local vars = require("AutoQuest.Common.vars")
local functions = require("AutoQuest.Common.functions")
local config = require("AutoQuest.config")
local config_menu = require("AutoQuest.config_menu")
local native_config_menu = require("AutoQuest.native_config_menu")
local bind = require("AutoQuest.bind")
local common_hooks = require("AutoQuest.Common.hooks")
local dump = require("AutoQuest.dump")
local randomizer = require("AutoQuest.randomizer")
local join_multiplayer = require("AutoQuest.Posting_Methods.join_multiplayer")
local singleplayer = require("AutoQuest.Posting_Methods.singleplayer")
local multiplayer = require("AutoQuest.Posting_Methods.multiplayer")
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
native_config_menu.init()

multiplayer.init()
singleplayer.init()
join_multiplayer.init()


local function switch_posting_method()
    if config.current.auto_quest.posting_method == 2 then
        multiplayer.switch()
    elseif config.current.auto_quest.posting_method == 1 then
        singleplayer.switch()
    elseif config.current.auto_quest.posting_method == 3 then
        join_multiplayer.switch()
    end
    randomizer.filter_quests()
end


switch_posting_method()


re.on_draw_ui(function()
    if imgui.button("AutoQuest "..config.version) then
        config_menu.is_opened = not config_menu.is_opened
    end
end
)

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
end
)

re.on_config_save(function()
    config.save()
end
)
