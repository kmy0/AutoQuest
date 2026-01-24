local enum = require("AutoQuest.util.game.bind.enum")

local this = {
    listener = require("AutoQuest.util.game.bind.listener"),
    manager = require("AutoQuest.util.game.bind.manager"),
    monitor = require("AutoQuest.util.game.bind.monitor"),
    util = require("AutoQuest.util.game.bind.util"),
}

---@return boolean
function this.init()
    return enum.init()
end

return this
