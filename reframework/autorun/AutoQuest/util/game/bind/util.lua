local cache = require("AutoQuest.util.misc.cache")
local enum = require("AutoQuest.util.game.bind.enum")
local game_data = require("AutoQuest.util.game.data")
local s = require("AutoQuest.util.ref.singletons")

local this = {}

---@return "KEYBOARD" | "PAD"
function this.get_input_device()
    local active_device = s.get("snow.StmInputManager")._ActiveDevice
    return enum.input_device[active_device._ActiveDevice] == "Pad" and "PAD" or "KEYBOARD"
end

---@return snow.Pad.Device
function this.get_pad()
    return s.get("snow.Pad").hard
end

---@return snow.GameKeyboard.HardwareKeyboard
function this.get_kb()
    return s.get("snow.GameKeyboard").hardKeyboard
end

this.get_pad = cache.memoize(this.get_pad)
this.get_kb = cache.memoize(this.get_kb)

return this
