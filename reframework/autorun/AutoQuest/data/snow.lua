---@class (exact) SnowData
---@field map SnowMap

---@class (exact) SnowMap
---@field quest_data table<string, Quest>
---@field default_quest_no table<string, boolean>
---@field rampage_data table<snow.quest.QuestLevel, snow.enemy.EnemyDef.EmTypes[]>
---@field mystery_data {
--- em: table<snow.enemy.EnemyDef.EmTypes, integer>,
--- item: table<snow.data.ContentsIdSystem.ItemId, {
---     lv_lower_limit: integer,
---     lv_upper_limit: integer,
---     ems: snow.enemy.EnemyDef.EmTypes[],
---     }>,
--- party_size: table<integer, integer>,
--- }
---@field servant_data table<snow.ai.ServantDefine.ServantId, {
--- npc_id: snow.NpcDefine.NpcID ,
--- fav_weapon: snow.player.PlayerWeaponType,
--- weapons: table<snow.player.PlayerWeaponType, snow.data.ContentsIdSystem.WeaponId>,
--- }>
---@field weapon_name_guid table<snow.player.PlayerWeaponType, string>

---@class SnowData
local this = {
    map = {
        quest_data = {},
        default_quest_no = {},
        rampage_data = {},
        mystery_data = {},
        servant_data = {},
        weapon_name_guid = { --FIXME: I can't believe that there seems to be no simple getter for weapon type names
            [0] = "ed6f9036-f551-4cfd-88dc-de4d656041cf",
            [1] = "9c946122-bf10-4685-a969-ee109988e4eb",
            [2] = "10e8498b-d978-42b0-997f-a0a224f17678",
            [3] = "72b150e3-f7bf-4b27-888f-405bffa13795",
            [4] = "e82d983d-698f-498c-8e3c-436c61fdb841",
            [5] = "99491f8a-df20-45a3-b054-de750ce5cb17",
            [6] = "cdf08ff7-e477-431f-87c0-5f061035a858",
            [7] = "8b28520b-c21b-49aa-aad6-5d8bf586ad33",
            [8] = "bd6d7e20-ccab-42d2-b1ab-e1a35b42a439",
            [9] = "eeda858e-bf81-4772-87ae-1bb090b6a40b",
            [10] = "677e7ab0-9a34-4682-83b4-7423e6264a21",
            [11] = "bcc33ef8-9585-4d07-b278-a32bb178ae7c",
            [12] = "5bec17f6-0a40-4d4b-823c-0de6d0eb940c",
            [13] = "3f769cfb-d60e-40cb-ac34-5328069649f6",
            [14] = "ed6f9036-f551-4cfd-88dc-de4d656041cf",
        },
    },
}

return this
