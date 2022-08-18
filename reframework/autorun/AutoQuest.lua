local guiman = nil
local questman = nil
local progquestman = nil
local chatman = nil
local vilman = nil
local objaccman = nil
local lobbyman = nil
local hwpad = nil
local hwkb = nil

local quest_board_cmd_id = sdk.find_type_definition('snow.gui.GuiManager.OtherCmdId'):get_field('QuestBoard'):get_data(nil)
local send_quest_to_qm = sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmCreateQuestSessionAction'):get_method('setQuestInfoToQuestManager')

local ui_vol = nil
local quest_data = nil
local stop_hidden = false
local posting = false
local dumped = false
local returned = true
local qc_open = false
local pressed = false
local draw = false
local interact = false
local selected = false
local decide = false
local target_name = nil
local random = false
local multi_flag = false
local single_flag = false
local qb_update = false
local check_selection = nil
local top_menu_cursor = nil

local window_pos = Vector2f.new(400, 200)
local window_pivot = Vector2f.new(0, 0)
local window_size = Vector2f.new(560, 600)

local loop_count = 0
local loop_max = 100

local noncustom_ids = {}
local posted_quests = {}
local filtered_quest_list = {}
local quest_data_list = {}
local quest_cat_list = {}
local quest_types = {
                INVALID=0,
                HUNTING=1,
                KILL=2,
                CAPTURE=4,
                BOSSRUSH=8,
                COLLECTS=16,
                TOUR=32,
                ARENA=64,
                SPECIAL=128,
                HYAKURYU=256,
                TRAINING=512,
                KYOUSEI=1024
                }
local ranks_ids = {
                Village=0,
                Low=1,
                High=2,
                Master=3,
                Max=4
                }
local quest_categories = {
                    Kingdom=11,
                    Kyousei=10,
                    Mystery=12,
                    ServantRequest=9,
                    }
local qc_ids = {
            [0]='nid002', --village
            [3]='nid102', --hub
            [6]='nid601'  --elgado
            }
local top_menu_types = {
            [7]=true, --Arena
            [8]=true, --Challenge
            [5]=true, --Event
            [1]=true, --Normal_Hall_High
            [20]=true, --Normal_Hall_HighLow
            [2]=true, --Normal_Hall_Low
            [12]=true, --Normal_Hall_Master
            [4]=true, --Training
            [13]=false --Mystery
            }

local settings = {
        hide_gui=true,
        mute_ui=true,
        auto_post=false,
        auto_rand=false,
        keep_rng=false,
        mystery_mode=false,
        quest_no='',
        exc_vil=false,
        exc_lr=false,
        exc_hr=false,
        exc_mr=false,
        exc_m1=false,
        exc_m2=false,
        exc_m3=false,
        exc_m4=false,
        exc_m5=false,
        exc_m6=false,
        exc_aff=false,
        exc_a1=false,
        exc_a2=false,
        exc_a3=false,
        exc_a4=false,
        exc_a5=false,
        -- exc_a6=false,
        exc_arena=false,
        exc_ram=false,
        exc_king=false,
        exc_fol=false,
        exc_ev=false,
        exc_tr=false,
        exc_tour=false,
        exc_cap=false,
        exc_slay=false,
        exc_hunt=false,
        exc_bs=false,
        exc_gat=false,
        exc_smallm=false,
        exc_sinm=false,
        exc_mulm=false,
        exc_notu=false,
        exc_arena_lr=false,
        exc_arena_hr=false,
        exc_arena_mr=false,
        exc_ram_lr=false,
        exc_ram_lr=false,
        exc_ram_hr=false,
        exc_ev_lr=false,
        exc_ev_hr=false,
        exc_ev_mr=false,
        exc_comp=false,
        exc_cust=false,
        exc_rand_myst=false,
        exc_noncust=false,
        post_btn='',
        use_kb=false,
        use_pad=false,
        posted_quests={dummy=1},
        skip_posted=false,
        post_multi=true,
        post_single=false,
        exc_rand_myst_below=0,
        exc_rand_myst_above=0
        }


local function load_settings()
    local l_settings = json.load_file('AutoQuest_settings.json')
    local str = json.load_file('AutoQuest/noncustom_ids.json')
    if str then
        noncustom_ids = str
    end
    if l_settings then
        settings = l_settings
    end
end


load_settings()


local function get_questman()
    if not questman then
        questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return questman
end

local function get_objaccman()
    if not objaccman then
        objaccman = sdk.get_managed_singleton('snow.access.ObjectAccessManager')
    end
    return objaccman
end

local function get_lobbyman()
    if not lobbyman then
        lobbyman = sdk.get_managed_singleton('snow.LobbyManager')
    end
    return lobbyman
end

local function get_wwiseman()
    if not wwiseman then
        wwiseman = sdk.get_managed_singleton('snow.wwise.SnowWwiseManager')
    end
    return wwiseman
end

local function get_vilman()
    if not vilman then
        vilman = sdk.get_managed_singleton('snow.VillageAreaManager')
    end
    return vilman
end

local function get_chatman()
    if not chatman then
        chatman = sdk.get_managed_singleton('snow.gui.ChatManager')
    end
    return chatman
end

local function get_guiman()
    if not guiman then
        guiman = sdk.get_managed_singleton('snow.gui.GuiManager')
    end
    return guiman
end

local function get_progquestman()
    if not progquestman then
        progquestman = sdk.get_managed_singleton('snow.progress.quest.ProgressQuestManager')
    end
    return progquestman
end

local function get_hwpad()
    if not hwpad then
        hwpad = sdk.get_managed_singleton("snow.Pad"):get_field("hard")
    end
    return hwpad
end

local function get_hwkb()
    if not hwkb then
        hwkb = sdk.get_managed_singleton("snow.GameKeyboard"):get_field("hardKeyboard")
    end
    return hwkb
end

local function create_qi()
    return sdk.create_instance('snow.LobbyManager.QuestIdentifier'):add_ref()
end

local function restore_state()
    if settings.hide_gui then get_guiman():call('setInvisibleAllGUI',false) end
    if settings.mute_ui and ui_vol then get_wwiseman():set_field('_CurrentVolumeUI',ui_vol) end
end

local function set_state()
    if settings.hide_gui then get_guiman():call('setInvisibleAllGUI',true) end
    if settings.mute_ui then
        ui_vol = get_wwiseman():get_field('_CurrentVolumeUI')
        get_wwiseman():set_field('_CurrentVolumeUI',0)
    end
end

local function recover_gui()
    posting = false
    close = false
    qc_open = false
    restore_state()
end

local function open_quest_board()
    set_state()
    get_guiman():call('invokeShortcutAsOtherCommand',quest_board_cmd_id)
end

local function is_online()
    if get_lobbyman() and get_lobbyman():call("isOnline") then
        return true
    else
        return false
    end
end

local function get_location()
    return get_vilman():call('get__CurrentAreaNo')
end

local function can_open_quest_board()
    return get_guiman():call('IsCanInvokeQuestBoard')
end

local function quest_posted()
    return get_questman():call('isActiveQuest')
end

local function create_int32(val)
    local obj = sdk.create_instance('System.Int32')
    obj:set_field('mValue', val)
    return obj
end

local function get_quest_data(no)
    return get_questman():call('getQuestData',create_int32(no))
end

local function get_quest_category(quest_no)
    local cat = nil
    local lvl = nil
    for k,v in pairs(quest_cat_list) do
        if v[quest_no] then
            cat = k
            lvl = v[quest_no]
            break
        end
    end
    return cat,lvl
end

local function parse_quest_data(quest_data,event_ids,random_mystery)
    local no = nil
    local target_type = {}
    local multi_monster = false
    local single_monster = false
    local small_monster = false
    local quest_cat = nil
    local quest_level = nil
    local highrank_unlock = get_progquestman():call('get_IsUnlockHighRank')
    local unlocked = nil
    local type = nil
    local rank = nil

    for no,quest in pairs(quest_data) do

        quest_cat,quest_level = get_quest_category(no)

        type = quest:get_field("_QuestType")
        if not quest_cat then
            if event_ids[no] then
                quest_cat = 'Event'

            elseif random_mystery[no] then
                quest_cat = 'Random Mystery'
            elseif type == quest_types['ARENA'] then
                quest_cat = 'Arena'
            elseif type == quest_types['HYAKURYU'] then
                quest_cat = 'Rampage'
            else
                quest_cat = 'Normal'
            end
        end

        if quest_cat ~= 'Mystery' then
            quest_level = quest:get_field("_QuestLv")
        end

        if quest_cat == 'Rampage' then
            multi_monster = 'Unknown'
            single_monster = 'Unknown'
            small_monster = 'Unknown'
        elseif quest_cat == 'Random Mystery' then
            single_monster = true
        else
            local tt = quest:get_field('_TargetType')
            target_type.a = tt:get_element(0):get_field("value__")
            target_type.b = tt:get_element(1):get_field("value__")
            if target_type.b ~= 0 or target_type.a == 5 then
                multi_monster = true
            elseif target_type.a == 6 then
                small_monster = true
            elseif target_type.a < 5 and target_type.a > 1 then
                single_monster = true
            end
        end

        if quest_cat == 'Rampage' then
            if quest:get_field("_isVIllage") then
                rank = ranks_ids['Village']
            else
                rank = ranks_ids['High']
            end
            quest_level = quest:get_field("_QuestLv")
            type = quest_types['HYAKURYU']
            completed = false
        else
            rank = quest:get_field("_EnemyLv")
            completed = get_progquestman():call('isClear',no)
        end

        if quest_cat == 'Event' and quest:get_field("_EnemyLv") == ranks_ids['High'] and not highrank_unlock then
            unlocked = false
        else
            unlocked = get_progquestman():call('isUnlock',no)
        end
        quest_data_list[no] = {
                        type=type,
                        rank=rank,
                        level=quest_level,
                        category=quest_cat,
                        small_monster=small_monster,
                        single_monster=single_monster,
                        multi_monster=multi_monster,
                        unlocked=unlocked,
                        completed=completed
                        }

        multi_monster = false
        single_monster = false
        small_monster = false
        ::continue::
    end
end

local function dump_random_mystery()
    local random_mystery = {}
    local quest_data = {}
    for _,quest in pairs(get_questman():get_field('_RandomMysteryQuestData'):get_elements()) do
        no = quest:get_field("_QuestNo")
        quest_data[no] = quest
        random_mystery[no] = 1
    end
    for i=0,120 do
        quest_data_list[700000 + i] = nil
    end
    parse_quest_data(quest_data,{},random_mystery)
end

local function dump_questdata()
    local no = nil
    local quest_data = {}
    local quest_dict = get_questman():get_field("_QuestDataDictionary"):get_field('_entries'):get_elements()
    local event_ids = {}
    local random_mystery = {}
    quest_cat_list = {}
    quest_data_list = {}

    for k,v in pairs(quest_categories) do
        quest_cat_list[k] = {}
        for i=0,7 do
            lst = get_questman():call('getQuestNumberArray',v,i)
            if lst then
                lst = lst:get_elements()
                for _,e in pairs(lst) do
                    no = e:get_field("value__")
                    quest_cat_list[k][no] = i
                end
            end
        end
    end

    for _,k in pairs(quest_dict) do
        no = k:get_field('key')
        if no ~= 0 and no ~= -1 then
            quest_data[no] = k:get_field('value'):get_field('<RawNormal>k__BackingField')
        end
    end

    for _,quest in pairs(get_questman():get_field('_DlQuestData'):get_field("_Param"):get_elements()) do
        no = quest:get_field("_QuestNo")
        event_ids[no] = 1
    end

    for _,quest in pairs(get_questman():get_field('_RandomMysteryQuestData'):get_elements()) do
        no = quest:get_field("_QuestNo")
        quest_data[no] = quest
        random_mystery[no] = 1
    end

    parse_quest_data(quest_data,event_ids,random_mystery)

    if not next(noncustom_ids) then
        local str = json.load_string('AutoQuest/noncustom_ids.json')
        if str then
            noncustom_ids = str
        else
            for no,_ in pairs(quest_data) do
                noncustom_ids[tostring(no)] = 1
            end
            for i=0,120 do
                noncustom_ids[700000 + i] = 1
            end
            json.dump_file('AutoQuest/noncustom_ids.json',noncustom_ids)
        end
    end
    dumped = true
end

local function get_top_menu()
    local qc_type_def = sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager')
    local qc_top_menu_list = qc_type_def:get_field('<QuestCounterTopMenuList>k__BackingField'):get_data()
    top_menu_cursor = qc_type_def:get_field('<TopMenuCursor>k__BackingField'):get_data()
    local qc_top_menu_list_size = qc_top_menu_list:get_field('mSize')
    local cursor_index = top_menu_cursor:call('get_index')
    local top_menu_id = qc_top_menu_list:call('get_Item',cursor_index)
    local bool = nil

    if not dumped then dump_questdata() end

    if quest_data_list[tonumber(settings.quest_no)]['category'] == 'Random Mystery' then
        bool = false
    else
        bool = true
    end

    if top_menu_types[top_menu_id] ~= bool then
        for i=0,qc_top_menu_list_size-1 do
            top_menu_id = qc_top_menu_list:call('get_Item',i)
            if top_menu_types[top_menu_id] == bool then
                top_menu_cursor:call('set_index',i)
                check_selection = i
                return true
            end
        end
    else
        selected = true
        return true
    end
    return false
end

local function filter_quests()
    filtered_quest_list = {}
    for no,data in pairs(quest_data_list) do
        if not data then goto continue end
        if data['type'] == quest_types['INVALID'] then goto continue end
        if settings.skip_posted and settings.posted_quests[tostring(no)] then goto continue end
        if settings.exc_cust and not noncustom_ids[tostring(no)] then goto continue end
        if settings.exc_noncust and noncustom_ids[tostring(no)] then goto continue end
        if data['category'] == 'Random Mystery' then
            if settings.exc_rand_myst then goto continue end
            if settings.exc_rand_myst_below and settings.exc_rand_myst_below > 0 then
                if data['level'] < settings.exc_rand_myst_below then goto continue end
            end
            if settings.exc_rand_myst_above and settings.exc_rand_myst_above > 0 then
                if data['level'] > settings.exc_rand_myst_above then goto continue end
            end
        end
        if data['category'] == 'Normal' then
            if settings.exc_vil and data['rank'] == ranks_ids['Village'] then goto continue end
            if settings.exc_lr and data['rank'] == ranks_ids['Low'] then goto continue end
            if settings.exc_hr and data['rank'] == ranks_ids['High'] then goto continue end
            if settings.exc_mr and data['rank'] == ranks_ids['Master'] then
                goto continue
            elseif not settings.exc_mr then
                if settings.exc_m1 and data['level'] == 0 then goto continue end
                if settings.exc_m2 and data['level'] == 1 then goto continue end
                if settings.exc_m3 and data['level'] == 2 then goto continue end
                if settings.exc_m4 and data['level'] == 3 then goto continue end
                if settings.exc_m5 and data['level'] == 4 then goto continue end
                if settings.exc_m6 and data['level'] == 5 then goto continue end
            end
        end
        if data['category'] == 'Mystery' then
            if settings.exc_aff then
                goto continue
            else
                if settings.exc_a1 and data['level'] == 0 then goto continue end
                if settings.exc_a2 and data['level'] == 1 then goto continue end
                if settings.exc_a3 and data['level'] == 2 then goto continue end
                if settings.exc_a4 and data['level'] == 3 then goto continue end
                if settings.exc_a5 and data['level'] == 4 then goto continue end
                -- if settings.exc_a6 and data['level'] == 5 then goto continue end
            end
        end
        if data['category'] == 'Arena' then
            if settings.exc_arena then
                goto continue
            else
                if settings.exc_arena_lr and data['rank'] == ranks_ids['Low'] then goto continue end
                if settings.exc_arena_hr and data['rank'] == ranks_ids['High'] then goto continue end
                if settings.exc_arena_mr and data['rank'] == ranks_ids['Master'] then goto continue end
            end
        end
        if data['type'] == quest_types['HYAKURYU'] then
            if settings.exc_ram then
                goto continue
            else
                if settings.exc_ram_vil and data['rank'] == ranks_ids['Village'] then goto continue end
                if settings.exc_ram_lr and data['rank'] == ranks_ids['Low'] then goto continue end
                if settings.exc_ram_hr and data['rank'] == ranks_ids['High'] then goto continue end
            end
        end
        if data['category'] == 'Event' then
            if settings.exc_ev then
                goto continue
            else
                if settings.exc_ev_lr and data['rank'] == ranks_ids['Low'] then goto continue end
                if settings.exc_ev_hr and data['rank'] == ranks_ids['High'] then goto continue end
                if settings.exc_ev_mr and data['rank'] == ranks_ids['Master'] then goto continue end
            end
        end
        if settings.exc_king and data['category'] == 'Kingdom' then goto continue end
        if settings.exc_fol and data['category'] == 'ServantRequest' then goto continue end
        if settings.exc_tr and data['type'] == quest_types['TRAINING'] then goto continue end
        if settings.exc_tour and data['type'] == quest_types['TOUR'] then goto continue end
        if settings.exc_cap and data['type'] == quest_types['CAPTURE'] then goto continue end
        if settings.exc_slay and data['type'] == quest_types['KILL'] then goto continue end
        if settings.exc_hunt and data['type'] == quest_types['HUNTING'] then goto continue end
        if settings.exc_bs and data['type'] == quest_types['BOSSRUSH'] then goto continue end
        if settings.exc_gat and data['type'] == quest_types['COLLECTS'] then goto continue end
        if settings.exc_smallm and (data['small_monster'] == true or data['small_monster'] == "Unknown") then goto continue end
        if settings.exc_sinm and (data['single_monster'] == true or data['single_monster'] == "Unknown") then goto continue end
        if settings.exc_mulm and (data['multi_monster'] == true or data['multi_monster'] == "Unknown") then goto continue end
        if settings.exc_notu and not data['unlocked'] then goto continue end
        if settings.exc_comp and data['completed'] then goto continue end

        table.insert(filtered_quest_list,no)
        ::continue::
    end
end

local function post_message(message)
    get_chatman():call("reqAddChatInfomation",'<COL YEL>AutoQuest</COL>\n' .. message,true and 2412657311)
end

local function roll()
    if not dumped then dump_questdata() end
    filter_quests()
    if #filtered_quest_list == 0 then
        post_message('<COL RED>There are no quests to randomize. Turn off some exclusions.<COL>')
        return true
    else
        settings.quest_no = filtered_quest_list[ math.random(#filtered_quest_list) ]
        return false
    end
end

local function post_quest()
    if settings.post_multi and single_flag
    or settings.post_single and multi_flag then
       post_message("<COL RED>Script restart required.<COL>")
    else
        local empty_pool = false
        if settings.post_multi then
            target_name = qc_ids[get_location()]
            if not target_name then post_message("<COL RED>Can't post in this area.<COL>") end
        else
            target_name = true
        end
        if can_open_quest_board() and not quest_posted() and target_name then
            random = false
            if settings.auto_rand then
                empty_pool = roll()
                random = true
            end
            quest_data = get_quest_data(settings.quest_no)
            if quest_data and not empty_pool then
                posting = true
                if settings.post_single then open_quest_board() end
            elseif not quest_data and not empty_pool then
                post_message("<COL RED>Invalid quest ID.<COL>")
            end
        end
    end
    pressed = false
end

local function toggle_options(state)
    for k,v in pairs(settings) do
        if string.find(k,'exc') and not string.match(k, "%d+") then
            settings[k] = state
        end
    end
end


if settings.post_multi then
    multi_flag = true

    sdk.hook(
        sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager'):get_method('setOpenQuestCounterOnState'),
        function(args)
        end,
        function(args)
            qc_open = true
            if posting then
                interact = false
                local bool = get_top_menu()
                if bool then
                    decide = true
                else
                    close = true
                end
            end
        end
    )

    sdk.hook(sdk.find_type_definition('snow.LobbyManager.QuestIdentifier'):get_method('reset'),
        function(args)
            if settings.keep_rng then
                args[3] = sdk.to_ptr(false)
            end
        end
    )

    sdk.hook(
        sdk.find_type_definition('snow.gui.StmGuiInput'):get_method('getDecideButtonTrg'),
        function(args) end,
        function(retval)
            if decide and selected then return sdk.to_ptr(true) else return retval end
        end
    )

    sdk.hook(sdk.find_type_definition('snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('onDestroy'),
        function(args)
            if posting then
                returned = true
                posting = false
                pressed = false
                close = false
                decide = false
            end
            qc_open = false

        end
    )

    sdk.hook(
        sdk.find_type_definition('snow.access.ObjectPopSensor.DetectedInfo'):get_method('checkAccess'),
        function(args)
            if posting then
                return sdk.PreHookResult.SKIP_ORIGINAL
            end
        end,
        function(retval)
            if posting and target_name then
                local name = nil
                local sensor = get_objaccman():call('getRegisteredSensor',1)
                local obj = sensor:call('get_AccessTarget')

                if obj then
                    name = obj:call('get_Name')
                    if loop_count == loop_max then
                        returned = true
                        posting = false
                        qc_open = false
                        pressed = false
                        target_name = nil
                        loop_count = 0
                        post_message('<COL RED>Failed to find Quest Counter NPC\nMove closer and try again.<COL>')
                        return retval
                    end
                    if not first_target then first_target = name end
                    if name == target_name then
                        target_name = nil
                        interact = true
                        loop_count = 0
                    else
                        get_objaccman():call('focusNextTarget')
                    end
                end
                loop_count = loop_count + 1
                return sdk.to_ptr(true)
            else
                return retval
            end
        end
    )

    sdk.hook(
        sdk.find_type_definition('snow.player.PlayerInput'):get_method('isDecideButton'),
        function(args) end,
        function(retval)
            if interact then return sdk.to_ptr(true) else return retval end
        end
    )

    re.on_frame(function()
        if check_selection then
            print(check_selection,top_menu_cursor:call('get_index'))
            if top_menu_cursor:call('get_index') == check_selection then
                check_selection = nil
                selected = true
            end
        end
    end
    )

else
    single_flag = true

    sdk.hook(sdk.find_type_definition('snow.gui.GuiQuestBoard'):get_method('routineTopMenuStart'),
        function(args) end,
        function(retval)
            if posting and not qc_open then get_guiman():call('get_refGuiQuestBoard'):call('decideQuick',0,1) end
        end
    )

    sdk.hook(
        sdk.find_type_definition('snow.SnowSingletonBehaviorRoot`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('awake'),
        function(args)
        end,
        function(args)
            qc_open = true
            if posting then
                if not settings.keep_rng then sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager'):call('resetRequestQuestIdentifier') end
                send_quest_to_qm:call(nil)
            end
        end
    )

    sdk.hook(sdk.find_type_definition('snow.gui.GuiQuestBoard'):get_method('onDestroy'),
        function(args) end,
        function(retval)
            if posting then
                posting = false
                close = false
                qc_open = false
                posted = true
                pressed = false
                restore_state()
            end
            qc_open = false
        end
    )

    sdk.hook(sdk.find_type_definition('snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('onDestroy'),
        function(args)
            if not posting then
                qc_open = false
            end
        end
    )

    re.on_frame(function()
        if posted and is_online() and can_open_quest_board() then
            local active_qi = get_questman():call('getActiveQuestIdentifier')
            local qi = create_qi()
            qi:call('copyFrom',active_qi)
            get_lobbyman():call('createRoom',qi)
            posted = false
        elseif posted and not is_online() then
            posted = false
        end
    end
    )
end

sdk.hook(
    sdk.find_type_definition('snow.gui.StmGuiInput'):get_method('getCancelButtonOrTrg'),
    function(args) end,
    function(retval)
        if close then return sdk.to_ptr(true) else return retval end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager'):get_method('getQuestCounterSelectedQuest'),
    function(args) end,
    function(retval)
        if posting then return sdk.to_ptr(get_quest_data(settings.quest_no)) else return retval end
    end
)

sdk.hook(sdk.find_type_definition('snow.QuestManager'):get_method('questActivate'),
    function(args) end,
    function(retval)
        settings.quest_no = get_questman():get_field('_QuestIdentifier'):get_field('_QuestNo')
        if posting then
            close = true
        end
    end
)

sdk.hook(sdk.find_type_definition('snow.QuestManager'):get_method('questStart'),
    function(args)
        returned = false
        stop_hidden = true
        bool_pick = nil
        if random and settings.skip_posted then
            settings.posted_quests[tostring(settings.quest_no)] = 1
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.GuiManager'):get_method('notifyReturnInVillage'),
    function(args)
        if not next(noncustom_ids) then
            local str = json.load_string('AutoQuest/noncustom_ids.json')
            if str then
                noncustom_ids = str
            else
                dump_questdata()
            end
        end
        stop_hidden = false

        local no = tonumber(settings.quest_no)
        if dumped then dump_random_mystery() end
        if dumped and no and quest_data_list[no] then
            if not quest_data_list[no]['completed'] then
                quest_data_list[no]['completed'] = get_progquestman():call('isClear',no)
            end
        end
        if settings.auto_post and not returned then
            returned = true
            post_quest()
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.StmGuiGameQuitFlowCtrl'):get_method('routineQuit'),
    function(args)
        json.dump_file('AutoQuest/noncustom_ids.json',{})
    end
)


sdk.hook(
    sdk.find_type_definition('snow.quest.QuestData'):get_method('getIcon'),
    function(args)
    end,
    function(retval)
        if settings.mystery_mode and not stop_hidden and not qc_open then
            return sdk.to_ptr(0)
        else
            return retval
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.SnowGuiCommonUtility.Icon'):get_method('getQuestIconFrame'),
    function(args)
        if settings.mystery_mode and not stop_hidden and not qc_open then return sdk.PreHookResult.SKIP_ORIGINAL end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.SnowGuiCommonUtility.Icon'):get_method('getEnemyIconFrameForQuestOrder(snow.gui.SnowGuiCommonUtility.Icon.EnemyIconFrameForQuestOrder, System.String, System.Boolean, System.Boolean)'),
    function(args)
        if settings.mystery_mode and not stop_hidden and not qc_open then return sdk.PreHookResult.SKIP_ORIGINAL end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.quest.QuestData'):get_method('getQuestLvEx'),
    function(args)
        if settings.mystery_mode and not stop_hidden and not qc_open then return sdk.PreHookResult.SKIP_ORIGINAL end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.quest.QuestData'):get_method('getQuestTextCore'),
    function(args)
    end,
    function(retval)
        if settings.mystery_mode and not stop_hidden and not qc_open then
            local txt = sdk.create_managed_string('Hidden')
            return sdk.to_ptr(txt)
        else
            return retval
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.quest.QuestData'):get_method('getMapNo'),
    function(args)
        if settings.mystery_mode and not stop_hidden and not qc_open and qb_update then return sdk.PreHookResult.SKIP_ORIGINAL end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.QuestBoardOrder'):get_method('_update_normal'),
    function(args)
        if settings.mystery_mode and not stop_hidden and not qc_open then
            qb_update = true
        end
    end,
    function(retval)
        if settings.mystery_mode and not stop_hidden and not qc_open then
            local qo = get_guiman():call('get_refGuiQuestBoard'):get_field('_QuestOrderCtrl')
            qo:get_field('_txt_Place'):call('set_Message','Hidden')
            qo:get_field('_txt_MainMony'):call('set_Message','Hidden')
            qo:get_field('_txt_Time'):call('set_Message','Hidden')
            qo:get_field('_txt_H_QuestCategory'):call('set_Message','Hidden')
            qo:get_field('_txt_H_QuestDifficulty'):call('set_Message','Hidden')
            qb_update = false
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.GuiLobbyQuestInfoWindow'):get_method('updateQuestInfo'),
    function(args)
    end,
    function(retval)
        if settings.mystery_mode and not stop_hidden and not qc_open then
            local quest_info_window = get_guiman():get_field('<refGuiLobbyQuestInfoWindow>k__BackingField')
            quest_info_window:get_field('QuestSpotNameText'):call('set_Message','Hidden')
            quest_info_window:get_field('StarText'):call('set_Message','Hidden')
            quest_info_window:get_field('RandomMysteryLVText'):call('set_Message','Hidden')
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.quest.QuestData'):get_method('getQuestType'),
    function(args)
    end,
    function(retval)
        if settings.mystery_mode and not stop_hidden and not qc_open then
            return sdk.to_ptr(create_int32(0))
        else
            return retval
        end
    end
)


re.on_frame(function()
    if settings.post_btn ~= ''
    and not pressed
    and get_questman()
    and not quest_posted() then
        local btn = tonumber(settings.post_btn)
        if btn and not pressed then
            if settings.use_kb and get_hwkb():call("getTrg", btn)
            or settings.use_pad and get_hwpad():call("andTrg", btn) then
                pressed = true
                post_quest()
            end
        end
    end
end
)

re.on_frame(function()
    if draw then
        imgui.set_next_window_pos(window_pos, 1 << 3, window_pivot)
        imgui.set_next_window_size(window_size, 1 << 3)
        if imgui.begin_window('AutoQuest', true) then
            _,settings.auto_post = imgui.checkbox('Auto Post Quest', settings.auto_post)
            _,settings.auto_rand = imgui.checkbox('Auto Randomize Quest', settings.auto_rand)
            _,settings.keep_rng = imgui.checkbox('Keep RNG', settings.keep_rng)
             _,settings.mystery_mode = imgui.checkbox('Mystery Mode', settings.mystery_mode)
            _,settings.quest_no = imgui.input_text('Quest ID', settings.quest_no)
            post = imgui.button('Post Quest')
            imgui.same_line()
            rand = imgui.button('Randomize')
            imgui.same_line()
            dump = imgui.button('Reload Quest Data')
            if imgui.tree_node('Posting Method') then
                imgui.text('Requires script restart')
                _,settings.post_multi = imgui.checkbox('Multiplayer',settings.post_multi)
                imgui.same_line()
                changed_post_method,settings.post_single = imgui.checkbox('Singleplayer',settings.post_single)
                if settings.post_multi and not changed_post_method then settings.post_single = false
                elseif settings.post_single then settings.post_multi = false
                end
                imgui.tree_pop()
            end
            if imgui.tree_node('Randomizer Settings') then
                _,settings.skip_posted = imgui.checkbox('Exclude Already Posted Quests', settings.skip_posted)
                imgui.same_line()
                reset_array = imgui.button('Reset List')
                select_all = imgui.button('Select All')
                imgui.same_line()
                unselect_all = imgui.button('Unselect All')
                if imgui.tree_node('Quest Ranks') then
                    _,settings.exc_vil = imgui.checkbox('Exclude Village', settings.exc_vil)
                    _,settings.exc_lr = imgui.checkbox('Exclude Low Rank', settings.exc_lr)
                    _,settings.exc_hr = imgui.checkbox('Exclude High Rank', settings.exc_hr)
                    _,settings.exc_mr = imgui.checkbox('Exclude Master Rank', settings.exc_mr)
                    if not settings.exc_mr then
                        if imgui.tree_node('Exclude MR Level') then
                            _,settings.exc_m1 = imgui.checkbox('M1', settings.exc_m1)
                            _,settings.exc_m2 = imgui.checkbox('M2', settings.exc_m2)
                            _,settings.exc_m3 = imgui.checkbox('M3', settings.exc_m3)
                            _,settings.exc_m4 = imgui.checkbox('M4', settings.exc_m4)
                            _,settings.exc_m5 = imgui.checkbox('M5', settings.exc_m5)
                            _,settings.exc_m6 = imgui.checkbox('M6', settings.exc_m6)
                            imgui.tree_pop()
                        end
                    end
                    imgui.tree_pop()
                end
                if imgui.tree_node('Quest Categories') then
                    _,settings.exc_aff = imgui.checkbox('Exclude Afflicted', settings.exc_aff)
                    if not settings.exc_aff then
                        if imgui.tree_node('Exclude Afflicted Level') then
                            _,settings.exc_a1 = imgui.checkbox('A1', settings.exc_a1)
                            _,settings.exc_a2 = imgui.checkbox('A2', settings.exc_a2)
                            _,settings.exc_a3 = imgui.checkbox('A3', settings.exc_a3)
                            _,settings.exc_a4 = imgui.checkbox('A4', settings.exc_a4)
                            _,settings.exc_a5 = imgui.checkbox('A5', settings.exc_a5)
                            -- _,settings.exc_a6 = imgui.checkbox('A6', settings.exc_a6)
                            imgui.tree_pop()
                        end
                    end
                    _,settings.exc_rand_myst = imgui.checkbox('Exclude Anomaly Investigations', settings.exc_rand_myst)
                    if not settings.exc_rand_myst then
                        if imgui.tree_node('Exclude Anomaly Level') then
                            imgui.text('Set to 0 to disable.')
                            _,settings.exc_rand_myst_below = imgui.slider_int('Exclude Below', settings.exc_rand_myst_below, 0, 200)
                            _,settings.exc_rand_myst_above = imgui.slider_int('Exclude Above', settings.exc_rand_myst_above, 0, 200)
                            imgui.tree_pop()
                        end
                    end
                    _,settings.exc_arena = imgui.checkbox('Exclude Arena', settings.exc_arena)
                    if not settings.exc_arena then
                        if imgui.tree_node('Exclude Arena Ranks') then
                            _,settings.exc_arena_lr = imgui.checkbox('Low Rank', settings.exc_arena_lr)
                            _,settings.exc_arena_hr = imgui.checkbox('High Rank', settings.exc_arena_hr)
                            _,settings.exc_arena_mr = imgui.checkbox('Master Rank', settings.exc_arena_mr)
                            imgui.tree_pop()
                        end
                    end
                    _,settings.exc_ram = imgui.checkbox('Exclude Rampage', settings.exc_ram)
                    if not settings.exc_ram then
                        if imgui.tree_node('Exclude Rampage Ranks') then
                            _,settings.exc_ram_vil = imgui.checkbox('Village', settings.exc_ram_vil)
                            _,settings.exc_ram_lr = imgui.checkbox('Low Rank', settings.exc_ram_lr)
                            _,settings.exc_ram_hr = imgui.checkbox('High Rank', settings.exc_ram_hr)
                            imgui.tree_pop()
                        end
                    end
                    _,settings.exc_king = imgui.checkbox('Exclude Support Surveys', settings.exc_king)
                    _,settings.exc_fol = imgui.checkbox('Exclude Follower Quests', settings.exc_fol)
                    _,settings.exc_ev = imgui.checkbox('Exclude Event', settings.exc_ev)
                    if not settings.exc_ev then
                        if imgui.tree_node('Exclude Event Ranks') then
                            _,settings.exc_ev_lr = imgui.checkbox('Low Rank', settings.exc_ev_lr)
                            _,settings.exc_ev_hr = imgui.checkbox('High Rank', settings.exc_ev_hr)
                            _,settings.exc_ev_mr = imgui.checkbox('Master Rank', settings.exc_ev_mr)
                            imgui.tree_pop()
                        end
                    end
                    _,settings.exc_tr = imgui.checkbox('Exclude Training', settings.exc_tr)
                    _,settings.exc_tour = imgui.checkbox('Exclude Tour', settings.exc_tour)
                    imgui.tree_pop()
                end
                if imgui.tree_node('Quest Types') then
                    _,settings.exc_cap = imgui.checkbox('Exclude Capture', settings.exc_cap)
                    _,settings.exc_slay = imgui.checkbox('Exclude Slay', settings.exc_slay)
                    _,settings.exc_hunt = imgui.checkbox('Exclude Hunt', settings.exc_hunt)
                    _,settings.exc_bs = imgui.checkbox('Exclude Boss Rush', settings.exc_bs)
                    _,settings.exc_gat = imgui.checkbox('Exclude Gathering', settings.exc_gat)
                    imgui.tree_pop()
                end
                if imgui.tree_node('Other') then
                    _,settings.exc_smallm = imgui.checkbox('Exclude Small Monsters', settings.exc_smallm)
                    _,settings.exc_sinm = imgui.checkbox('Exclude Single Monster', settings.exc_sinm)
                    _,settings.exc_mulm = imgui.checkbox('Exclude Mutli Monsters', settings.exc_mulm)
                    _,settings.exc_notu = imgui.checkbox('Exclude Not Unlocked', settings.exc_notu)
                    _,settings.exc_comp = imgui.checkbox('Exclude Completed', settings.exc_comp)
                    _,settings.exc_cust = imgui.checkbox('Exclude Custom', settings.exc_cust)
                    _,settings.exc_noncust = imgui.checkbox('Exclude Non Custom', settings.exc_noncust)
                    imgui.tree_pop()
                end
                imgui.tree_pop()
            end
            if settings.post_single and single_flag then
                if imgui.tree_node('GUI Settings') then
                    _,settings.hide_gui = imgui.checkbox('Hide GUI while posting', settings.hide_gui)
                    _,settings.mute_ui = imgui.checkbox('Mute UI sounds while posting', settings.mute_ui)
                    rec_gui = imgui.button('Restore GUI')
                    imgui.tree_pop()
                end
            end
            if imgui.tree_node('Post Quest Bind') then
                _,settings.use_kb = imgui.checkbox('Keyboard', settings.use_kb)
                imgui.same_line()
                changed,settings.use_pad = imgui.checkbox('Pad', settings.use_pad)
                imgui.text('Button IDs - pastebin.com/Sc9tNLah')
                _,settings.post_btn = imgui.input_text('Button ID', settings.post_btn)
                if settings.use_kb and not changed then settings.use_pad = false
                elseif settings.use_pad then settings.use_kb = false
                end
                imgui.tree_pop()
            end
            if imgui.tree_node('Explanations') then
                if imgui.tree_node('Posting Method') then
                    if imgui.tree_node('Multiplayer') then
                        imgui.text(
                            'Required method if you want to post quest for people in your lobby\n' ..
                            'or activate Join Request later. Also can be used if you play singleplayer.\n' ..
                            'Quests can be posted only in 3 areas, Elgado, Kamura Village and Kamura Hub\n'..
                            'while somewhat close to Quest Counter. GUI cant be disabled while posting.'
                            )
                        imgui.tree_pop()
                    end
                    if imgui.tree_node('Singleplayer') then
                        imgui.text(
                            'Other people cant join quests posted with this method.\n'..
                            'Quests can be posted from each area that lets you open Quest Board.\n'..
                            'Is faster than Multiplayer method and GUI can be disabled while posting.'
                            )
                        imgui.tree_pop()
                    end
                    imgui.tree_pop()
                end
                if imgui.tree_node('Keep RNG') then
                    imgui.text(
                        'Lets you keep random seed used in last quest. Affects spawned monsters,\n'..
                        'their spawn postitions and probably some less important stuff.\n'..
                        'Quest rewards are not affected.'
                        )
                    imgui.tree_pop()
                end
                if imgui.tree_node('Mystery Mode') then
                    imgui.text('Hides quest info displayed in top left corner and while signing for lobby quest.')
                    imgui.tree_pop()
                end
                if imgui.tree_node('Randomizer Settings') then
                    if imgui.tree_node('Un/Select All') then
                        imgui.text('Un/Selects all Exclude toggles other than Master Rank,Afflicted Levels and Anomaly Levels.')
                        imgui.tree_pop()
                    end
                    if imgui.tree_node('Reset list') then
                        imgui.text('Resets list of posted quests.')
                        imgui.tree_pop()
                    end
                    imgui.tree_pop()
                end
                if imgui.tree_node('GUI Settings') then
                    if imgui.tree_node('Restore GUI') then
                        imgui.text('Unhides GUI and restores ui volume if something went wrong.')
                        imgui.tree_pop()
                    end
                    imgui.tree_pop()
                end
                if imgui.tree_node('Custom Quests') then
                    imgui.text(
                            'After loading custom quests press Reload Quest Data button\n'..
                            'for them to appear in the randomizer quest pool.'
                            )
                    imgui.tree_pop()
                end
                imgui.tree_pop()
            end

            if post then
                post_quest()
            elseif rec_gui then
                restore_state()
            elseif rand then
                roll()
            elseif select_all then
                toggle_options(true)
            elseif unselect_all then
                toggle_options(false)
            elseif reset_array then
                settings.posted_quests = {dummy=1}
            elseif dump then
                dump_questdata()
            end
            imgui.end_window()
        else
            draw = false
        end
    end
end
)

re.on_draw_ui(function()
    if imgui.tree_node('AutoQuest') then
        if imgui.button('Settings') then
             draw = true
        end
        imgui.tree_pop()
    end
end
)

re.on_config_save(function()
    json.dump_file('AutoQuest_settings.json', settings)
end)