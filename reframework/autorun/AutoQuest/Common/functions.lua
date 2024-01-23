local functions = {}
local methods
local config
-- local native_config_menu
local singletons

local quest_board_cmd_id = sdk.find_type_definition('snow.gui.GuiManager.OtherCmdId'):get_field('QuestBoard'):get_data(nil)


function functions.endswith(str, suffix)
    return str:sub(-#suffix) == suffix
end

function functions.sanitize_quest_no(quest_no)
    quest_no = tostring(quest_no)
    if functions.endswith(quest_no, "S") then
        quest_no = quest_no:sub(1, -2)
    end
    return tonumber(quest_no)
end

function functions.post_info_message(message)
	methods.post_info_message:call(singletons.chatman,'<COL YEL>AutoQuest</COL>\n' .. message,true and 2412657311)
end

function functions.open_quest_board()
    methods.invoke_action_bar_id:call(singletons.guiman,quest_board_cmd_id)
end

function functions.set_random_myst_lvl_to_max()
    config.current.auto_quest.anomaly_investigation_max_lv = methods.get_mystery_research_level:call(singletons.progman)
end

function functions.table_length(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function functions.error_handler(error_message)
    -- if native_config_menu.active then
        -- native_config_menu.mod_menu.PromptMsg(error_message)
    -- else
        functions.post_info_message("<COL RED>" .. error_message .. "<COL>")
    -- end
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

    -- if native_config_menu.active then
    --     native_config_menu.mod_menu.Repaint()
    -- end
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

function functions.to_array(obj)
    local array = {}
    for i=0,obj:call('get_Count')-1 do
        table.insert(array,obj:call('get_Item',i))
    end
    return array
end


function functions.init()
	singletons = require("AutoQuest.singletons")
	methods = require("AutoQuest.methods")
	config = require("AutoQuest.config")
    -- native_config_menu = require("AutoQuest.native_config_menu")
end

return functions