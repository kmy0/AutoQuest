local s = require("AutoQuest.util.ref.singletons")

local this = {}

---@param message string
---@param sound_id integer?
function this.send_message(message, sound_id)
    sound_id = sound_id or 0
    s.get("snow.gui.ChatManager"):reqAddChatInfomation(message, sound_id)
end

---@param message string
function this.send_error_message(message)
    s.get("snow.gui.ChatManager")
        :reqAddChatInfomation("<COL RED>" .. message .. "<COL>", 2412657311)
end

return this
