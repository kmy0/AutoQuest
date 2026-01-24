---@class BindEnum
---@field pad_btn table<snow.Pad.Button, string>
---@field kb_btn table<via.hid.KeyboardKey, string>
---@field input_device table<snow.StmInputManager.ActiveDevice, string>

local game_data = require("AutoQuest.util.game.data")
local util_table = require("AutoQuest.util.misc.table")

---@class BindEnum
local this = {
    pad_btn = {},
    kb_btn = {},
    input_device = {},
}

---@return boolean
function this.init()
    game_data.get_enum("snow.Pad.Button", this.pad_btn)
    game_data.get_enum(
        "via.hid.KeyboardKey",
        this.kb_btn,
        nil,
        { "Control", "Menu", "DefinedEnter", "Shift" }
    )
    game_data.get_enum("snow.StmInputManager.ActiveDevice", this.input_device)

    if
        util_table.any(this, function(key, value)
            if type(value) ~= "table" then
                return false
            end

            return util_table.empty(value)
        end)
    then
        return false
    end

    -- removes unnecessary buttons/masks
    for bit, _ in pairs(this.pad_btn) do
        if bit > 65536 then
            this.pad_btn[bit] = nil
        end
    end

    return true
end

return this
