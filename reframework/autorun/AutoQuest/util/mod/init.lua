local config = require("AutoQuest.config.init")
local snow_misc = require("AutoQuest.util.snow.misc")

local this = {}

---@param message string
local function wrap_message(message)
    return "<COL YEL>AutoQuest</COL>\n" .. message
end

---@param message string
function this.send_message(message)
    if not config.current.mod.enable_notification then
        return
    end

    snow_misc.send_message(wrap_message(message))
end

---@param message string
function this.send_error_message(message)
    if not config.current.mod.enable_notification then
        return
    end

    snow_misc.send_error_message(wrap_message(message))
end

return this
