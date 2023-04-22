local bind = {}

local config
local singletons
local methods
local config_menu
local vars

bind.timer_max = 5000
bind.timer = 0
bind.timer_string = nil
bind.block = false
bind.listen_trigger = false
bind.new_bind_trigger = false

bind.keyboard_keys = {
	[0] = "None",
	[1] = "Left Mouse Button",
	[2] = "Right Mouse Button",
	[3] = "Control-Break",
	[4] = "Middle Mouse Button",
	[5] = "X1 Mouse Button",
	[6] = "X2 Mouse Button",

	--[7] = "Undefined 7",
	[8] = "Backspace",
	[9] = "Tab",
	--[10] = "Reserved 10",
	--[11] = "Reserved 11",
	[12] = "Clear",
	[13] = "Enter",
	--[14] = "Undefined 14",
	--[15] = "Undefined 15",
	[16] = "Shift",
	[17] = "Ctrl",
	[18] = "Alt",
	[19] = "Pause Break",
	[20] = "Caps Lock",

	[21] = "IME Kana/Hanguel/Hangul Mode",
	[22] = "IME On",
	[23] = "IME Junja Mode",
	[24] = "IME Final Mode",
	[25] = "IME Hanja/Kanji Mode",
	[26] = "IME On",
	[27] = "Esc",
	[28] = "IME Convert",
	[29] = "IME NonConvert",
	[30] = "IME Accept",
	[31] = "IME Mode Change Request",

	[32] = "Spacebar",
	[33] = "Page Up",
	[34] = "Page Down",
	[35] = "End",
	[36] = "Home",
	[37] = "Left Arrow",
	[38] = "Up Arrow",
	[39] = "Right Arrow",
	[40] = "Down Arrow",
	[41] = "Select",
	[42] = "Print Screen", -- Print
	[43] = "Execute",
	[44] = "Print Screen",
	[45] = "Ins",
	[46] = "Del",
	[47] = "Help",

	[48] = "0",
	[49] = "1",
	[50] = "2",
	[51] = "3",
	[52] = "4",
	[53] = "5",
	[54] = "6",
	[55] = "7",
	[56] = "8",
	[57] = "9",

	--[58] = "Undefined 58",
	--[59] = "Undefined 59",
	--[60] = "Undefined 60",
	--[61] = "Undefined 60"", -- =+
	--[62] = "Undefined 62",
	--[63] = "Undefined 63",
	--[64] = "Undefined 64",

	[65] = "A",
	[66] = "B",
	[67] = "C",
	[68] = "D",
	[69] = "E",
	[70] = "F",
	[71] = "G",
	[72] = "H",
	[73] = "I",
	[74] = "J",
	[75] = "K",
	[76] = "L",
	[77] = "M",
	[78] = "N",
	[79] = "O",
	[80] = "P",
	[81] = "Q",
	[82] = "R",
	[83] = "S",
	[84] = "T",
	[85] = "U",
	[86] = "V",
	[87] = "W",
	[88] = "X",
	[89] = "Y",
	[90] = "Z",

	[91] = "Left Win",
	[92] = "Right Win",
	[93] = "Applications",
	--[94] = "Reserved 94",
	[95] = "Sleep",

	[96] = "Numpad 0",
	[97] = "Numpad 1",
	[98] = "Numpad 2",
	[99] = "Numpad 3",
	[100] = "Numpad 4",
	[101] = "Numpad 5",
	[102] = "Numpad 6",
	[103] = "Numpad 7",
	[104] = "Numpad 8",
	[105] = "Numpad 9",
	[106] = "Numpad *",
	[107] = "Numpad +",
	[108] = "Numpad Separator",
	[109] = "Numpad -",
	[110] = "Numpad .",
	[111] = "Numpad /",

	[112] = "F1",
	[113] = "F2",
	[114] = "F3",
	[115] = "F4",
	[116] = "F5",
	[117] = "F6",
	[118] = "F7",
	[119] = "F8",
	[120] = "F9",
	[121] = "F10",
	[122] = "F11",
	[123] = "F12",
	[124] = "F13",
	[125] = "F14",
	[126] = "F15",
	[127] = "F16",
	[128] = "F17",
	[129] = "F18",
	[130] = "F19",
	[131] = "F20",
	[132] = "F21",
	[133] = "F22",
	[134] = "F23",
	[135] = "F24",

	--[136] = "Unassigned 136",
	--[137] = "Unassigned 137",
	--[138] = "Unassigned 138",
	--[139] = "Unassigned 139",
	--[140] = "Unassigned 140",
	--[141] = "Unassigned 141",
	--[142] = "Unassigned 142",
	--[143] = "Unassigned 143",

	[144] = "Num Lock",
	[145] = "Scroll Lock",

	[146] = "Numpad Enter", -- OEM Specific 146
	[147] = "OEM Specific 147",
	[148] = "OEM Specific 148",
	[149] = "OEM Specific 149",
	[150] = "OEM Specific 150",
	[151] = "OEM Specific 151",
	[152] = "OEM Specific 152",
	[153] = "OEM Specific 153",
	[154] = "OEM Specific 154",
	[155] = "OEM Specific 155",
	[156] = "OEM Specific 156",
	[157] = "OEM Specific 157",
	[158] = "OEM Specific 158",
	[159] = "OEM Specific 159",

	[160] = "Left Shift",
	[161] = "Right Shift",
	[162] = "Left Ctrl",
	[163] = "Right Ctrl",
	[164] = "Left Alt",
	[165] = "Right Alt",

	[166] = "Browser Back",
	[167] = "Browser Forward",
	[168] = "Browser Refresh",
	[169] = "Browser Stop",
	[170] = "Browser Search",
	[171] = "Browser Favourites",
	[172] = "Browser Start and Home",

	[173] = "Volume Mute",
	[174] = "Volume Down",
	[175] = "Volume Up",
	[176] = "Next Track",
	[177] = "Previous Track",
	[178] = "Stop Media",
	[179] = "Play/Pause Media",
	[180] = "Start Mail",
	[181] = "Select Media",
	[182] = "Start Application 1",
	[183] = "Start Application 2",

	--[184] = "Reserved!",
	--[185] = "Reserved!",

	[186] = ";:",
	[187] = ";:", -- +
	[188] = ",<",
	[189] = "-",
	[190] = ".>",
	[191] = "/?",
	[192] = "`~",

	--[193] = "Reserved!",
	--[194] = "Reserved!",
	--[195] = "Reserved!",
	--[196] = "Reserved!",
	--[197] = "Reserved!",
	--[198] = "Reserved!",
	--[199] = "Reserved!",
	--[200] = "Reserved!",
	--[201] = "Reserved!",
	--[202] = "Reserved!",
	--[203] = "Reserved!",
	--[204] = "Reserved!",
	--[205] = "Reserved!",
	--[206] = "Reserved!",
	--[207] = "Reserved!",
	--[208] = "Reserved!",
	--[209] = "Reserved!",
	--[210] = "Reserved!",
	--[211] = "Reserved!",
	--[212] = "Reserved!",
	--[213] = "Reserved!",
	--[214] = "Reserved!",
	--[215] = "Reserved!",
	--[216] = "Unassigned 216",
	--[217] = "Unassigned 217",
	--[218] = "Unassigned 218",

	[219] = "[{",
	[220] = "\\|",
	[221] = "]}",
	[222] = "\' \"",
	[223] = "OEM_8",
	--[224] = "Reserved",
	[225] = "OEM Specific 225",
	[226] = "<>",
	[227] = "OEM Specific 227",
	[228] = "OEM Specific 228",
	[229] = "IME Process",
	[230] = "OEM Specific 230",
	[231] = "!!!!!!!!!!!!!!!!!!!!!!!",
	--[232] = "Unassigned 232",
	[233] = "OEM Specific 233",
	[234] = "OEM Specific 234",
	[235] = "OEM Specific 235",
	[236] = "OEM Specific 236",
	[237] = "OEM Specific 237",
	[238] = "OEM Specific 238",
	[239] = "OEM Specific 239",
	[240] = "OEM Specific 240",
	[241] = "OEM Specific 241",
	[242] = "OEM Specific 242",
	[243] = "OEM Specific 243",
	[244] = "OEM Specific 244",
	[245] = "OEM Specific 245",

	[246] = "Attn",
	[247] = "CrSel",
	[248] = "ExSel",
	[249] = "Erase EOF",
	[250] = "Play",
	[251] = "Zoom",
	--[252] = "Reserved 252",
	[253] = "PA1",
	--[254] = "Clear"
}

bind.listen_valid_keys = {
	[8] = "Backspace",
	[13] = "Enter",
	[48] = "0",
	[49] = "1",
	[50] = "2",
	[51] = "3",
	[52] = "4",
	[53] = "5",
	[54] = "6",
	[55] = "7",
	[56] = "8",
	[57] = "9",
	[96] = "0",
	[97] = "1",
	[98] = "2",
	[99] = "3",
	[100] = "4",
	[101] = "5",
	[102] = "6",
	[103] = "7",
	[104] = "8",
	[105] = "9",
	[146] = "Numpad Enter" -- OEM Specific 146
}

bind.pad_keys = {
			-- [1]={
			-- 	Xbox='DPAD Up',
			-- 	Nintendo='DPAD Up',
			-- 	Playstation='DPAD Up'
			-- },
			-- [2]={
			-- 	Xbox='DPAD Down',
			-- 	Nintendo='DPAD Down',
			-- 	Playstation='DPAD Down'
			-- },
			-- [4]={
			-- 	Xbox='DPAD Left',
			-- 	Nintendo='DPAD Left',
			-- 	Playstation='DPAD Left'
			-- },
			-- [8]={
			-- 	Xbox='DPAD Right',
			-- 	Nintendo='DPAD Right',
			-- 	Playstation='DPAD Right'
			-- },
			-- [16]={
			-- 	Xbox='Y',
			-- 	Nintendo='X',
			-- 	Playstation='▲'
			-- },
			-- [32]={
			-- 	Xbox='A',
			-- 	Nintendo='B',
			-- 	Playstation='X'
			-- },
			-- [64]={
			-- 	Xbox='X',
			-- 	Nintendo='Y',
			-- 	Playstation='⬤'
			-- },
			-- [128]={
			-- 	Xbox='B',
			-- 	Nintendo='A',
			-- 	Playstation='■'
			-- },
			[256]={
				Xbox='LB',
				Nintendo='L',
				Playstation='L1'
			},
			[512]={
				Xbox='LT',
				Nintendo='ZL',
				Playstation='L2'
			},
			[1024]={
				Xbox='RB',
				Nintendo='R',
				Playstation='R1'
			},
			[2048]={
				Xbox='RT',
				Nintendo='ZR',
				Playstation='R2'
			},
			[4096]={
				Xbox='LS',
				Nintendo='L3',
				Playstation='LS'
			},
			[8192]={
				Xbox='RS',
				Nintendo='R3',
				Playstation='RS'
			},
			[16384]={
				Xbox='View',
				Nintendo='-',
				Playstation='Select'
			},
			-- [32768]={
			-- 	Xbox='Menu',
			-- 	Nintendo='+',
			-- 	Playstation='Start'
			-- },
}

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

function bind.hook()
	sdk.hook(methods.open_hud,function(args) bind.block = false end)
	sdk.hook(methods.open_all_quest_hud,function(args) bind.block = false end)
	sdk.hook(methods.close_hud,function(args) bind.block = true end)
end

function bind.register()
	if bind.new_bind_trigger then
		if bind.hard_kb then
			for key, key_name in pairs(bind.keyboard_keys) do
				if methods.get_kb_down_btn:call(bind.hard_kb, key) then
					config.current.button_bind.button_type = 'Keyboard'
					config.current.button_bind.pad_type = nil
					config.current.button_bind.button = key
					config.current.button_bind.button_name = key_name
					config.save()
					bind.new_bind_trigger = false
					return true
				end
			end
		end
		if bind.hard_pad then
			local btn = bind.hard_pad:get_field('_on')
			if btn ~= 0 and bind.pad_keys[btn] then
				config.current.button_bind.button_type = 'Pad'
				config.current.button_bind.button = btn
				config.current.button_bind.button_name = bind.pad_keys[btn][bind.pad_type]
				config.save()
				bind.new_bind_trigger = false
				return true
			end
		end
	end
	return false
end

-- function bind.listen()
-- 	if bind.hard_kb then
-- 		for key, key_name in pairs(bind.listen_valid_keys) do
-- 			if methods.check_kb_btn:call(bind.hard_kb, key) then
-- 				local text = tostring(config.current.auto_quest.quest_no)
-- 				if key == 8 then
-- 					if #text > 0 then
-- 						text = text:sub(1, -2)
-- 					end
-- 				elseif key == 13 or key == 146 then
-- 					bind.listen_trigger = false
-- 				else
-- 					text = text .. key_name
-- 				end

-- 				config.current.auto_quest.quest_no = text
-- 			end
-- 		end
-- 	end
-- end

function bind.update()
	if singletons.hwkb then bind.hard_kb = singletons.hwkb:get_field("hardKeyboard") end
	if singletons.hwpad then
		bind.hard_pad = singletons.hwpad:get_field("hard")
		local pad_type = methods.get_pad_type:call(bind.hard_pad)
		if pad_type then
            if pad_type < 10 then
                bind.pad_type = 'Xbox'
            elseif pad_type > 15 then
                bind.pad_type = 'Nintendo'
            else
                bind.pad_type = 'Playstation'
            end
        else
            bind.pad_type = 'Xbox'
        end
	end

    if bind.new_bind_trigger then
        bind.timer = bind.timer + methods.get_delta_time:call(nil)
        if bind.timer <= bind.timer_max then
        	bind.timer_string = split(tostring( (bind.timer_max - bind.timer) / 1000), '.')[1]
            if bind.register() then bind.timer = 0 end
        else
            bind.new_bind_trigger = false
            config.current.button_bind.button = nil
			config.current.button_bind.button_name = "None"
			config.save()
            bind.timer = 0
        end
    else
		bind.check()
    end
end

function bind.check()
	if config.current.button_bind.button then
		if not vars.posting
		and vars.game_state == 4
		and singletons.questman
		and not bind.block
		and not methods.is_quest_posted:call(singletons.questman) then
			if config.current.button_bind.button_type == 'Keyboard' and bind.hard_kb then
				if methods.check_kb_btn:call(bind.hard_kb,tonumber(config.current.button_bind.button)) then
	                vars.post_quest_trigger = true
				end
			elseif config.current.button_bind.button_type == 'Pad' and bind.hard_pad then
				if methods.check_pad_btn:call(bind.hard_pad,tonumber(config.current.button_bind.button)) then
	                vars.post_quest_trigger = true
				end
			end
		end
	end
end

function bind.init()
	singletons = require("AutoQuest.singletons")
	config = require("AutoQuest.config")
	config_menu = require("AutoQuest.config_menu")
	methods = require("AutoQuest.methods")
	vars = require("AutoQuest.Common.vars")
	bind.hook()
end

return bind