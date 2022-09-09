local functions = {}
local methods
local config
local vars
local native_config_menu

local quest_board_cmd_id = sdk.find_type_definition('snow.gui.GuiManager.OtherCmdId'):get_field('QuestBoard'):get_data(nil)

function functions.post_info_message(message)
	methods.post_info_message:call(singletons.chatman,'<COL YEL>AutoQuest</COL>\n' .. message,true and 2412657311)
end

function functions.open_quest_board()
    methods.invoke_action_bar_id:call(singletons.guiman,quest_board_cmd_id)
end

function functions.restore_state()
    if config.current.gui.hide_gui then methods.set_gui_invisible:call(singletons.guiman,false) end
    if config.current.gui.mute_ui_sounds and vars.ui_vol then singletons.wwiseman:set_field('_CurrentVolumeUI',vars.ui_vol) end
end

function functions.set_state()
    if config.current.gui.hide_gui then methods.set_gui_invisible:call(singletons.guiman,true) end
    if config.current.gui.mute_ui_sounds then
        vars.ui_vol = singletons.wwiseman:get_field('_CurrentVolumeUI')
        singletons.wwiseman:set_field('_CurrentVolumeUI',0)
    end
end

function functions.table_length(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function functions.error_handler(error_message)
    if native_config_menu.active then
        native_config_menu.mod_menu.PromptMsg(error_message)
    else
        functions.post_info_message("<COL RED>" .. error_message .. "<COL>")
    end
end

function functions.toggle_options(state)
    for k,v in pairs(config.current.randomizer) do
        if string.find(k,'exclude') then
            local check = tonumber(v)
            if check and not state then
                config.current.randomizer[k] = 0
            elseif not check then
                if state and not string.match(k, "%d+") then
                    config.current.randomizer[k] = state
                elseif not state then
                    config.current.randomizer[k] = state
                end
            end
        end
    end

    if native_config_menu.active then
        native_config_menu.mod_menu.Repaint()
    end
end

function functions.deep_copy(original, copies)
    copies = copies or {};
    local original_type = type(original);
    local copy;
    if original_type == "table" then
        if copies[original] then
            copy = copies[original];
        else
            copy = {};
            copies[original] = copy;
            for original_key, original_value in next, original, nil do
                copy[functions.deep_copy(original_key, copies)] = functions.deep_copy(original_value
                    ,
                    copies);
            end
            setmetatable(copy,
                functions.deep_copy(getmetatable(original)
                    , copies));
        end
    else -- number, string, boolean, etc
        copy = original;
    end
    return copy;
end

function functions.merge(...)
    local tables_to_merge = { ... };
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them");

    for key, table in ipairs(tables_to_merge) do
        assert(type(table) == "table", string.format("Expected a table as function parameter %d", key));
    end

    local result = functions.deep_copy(tables_to_merge[1]);

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i];
        for key, value in pairs(from) do
            if type(value) == "table" then
                result[key] = result[key] or {};
                assert(type(result[key]) == "table", string.format("Expected a table: '%s'", key));
                result[key] = functions.merge(result[key], value);
            else
                result[key] = value;
            end
        end
    end

    return result;
end

function functions.init()
	singletons = require("AutoQuest.singletons")
	methods = require("AutoQuest.methods")
	config = require("AutoQuest.config")
	vars = require("AutoQuest.Common.vars")
    native_config_menu = require("AutoQuest.native_config_menu")
end

return functions