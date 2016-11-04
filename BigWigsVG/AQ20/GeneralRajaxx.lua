------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["General Rajaxx"]
local andorov = AceLibrary("Babble-Boss-2.2")["Lieutenant General Andorov"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local L2 = AceLibrary("AceLocale-2.2"):new("BigWigs")

local rajdead


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Rajaxx",

	wave_cmd = "wave",
	wave_name = "Wave Alert",
	wave_desc = "Warn for incoming waves",
	
	thunder_cmd = "thunder",
	thunder_name = "Thundercrash Alert",
	thunder_desc = "Warn for incoming Thundercrash",
	
	trigger1 = "Kill first, ask questions later... Incoming!",
	trigger2 = "?????",  -- There is no callout for wave 2 ><
	trigger3 = "The time of our retribution is at hand! Let darkness reign in the hearts of our enemies!",
	trigger4 = "No longer will we wait behind barred doors and walls of stone! No longer will our vengeance be denied! The dragons themselves will tremble before our wrath!\013\n",
	trigger5 = "Fear is for the enemy! Fear and death!",
	trigger6 = "Staghelm will whimper and beg for his life, just as his whelp of a son did! One thousand years of injustice will end this day!\013\n",
	trigger7 = "Fandral! Your time has come! Go and hide in the Emerald Dream and pray we never find you!\013\n",
	trigger8 = "Impudent fool! I will kill you myself!",
	trigger9 = "Remember, Rajaxx, when I said I'd kill you last?",

	thunder_trigger = "Thundercrash",
	thunder_bar = "Thundercrash (50% HP)",
	thunder_warn = "Thundercrash (50% HP) in 5sec",
	
	warn1 = "Wave 1/8",
	warn2 = "Wave 2/8",
	warn3 = "Wave 3/8",
	warn4 = "Wave 4/8",
	warn5 = "Wave 5/8",
	warn6 = "Wave 6/8",
	warn7 = "Wave 7/8",
	warn8 = "Incoming General Rajaxx",
	warn9 = "Wave 1/8", -- trigger for starting the event by pulling the first wave instead of talking to andorov

	miniboss1 = "Captain Qeez",
	miniboss2 = "Captain Tuubid",
	miniboss3 = "Captain Drenn",
	miniboss4 = "Captain Xurrem",
	miniboss5 = "Major Yeggeth",
	miniboss6 = "Major Pakkon",
	miniboss7 = "Colonel Zerran",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGeneralRajaxx = BigWigs:NewModule(boss)
BigWigsGeneralRajaxx.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsGeneralRajaxx.enabletrigger = andorov
BigWigsGeneralRajaxx.toggleoptions = {"wave", "thunder", "bosskill"}
BigWigsGeneralRajaxx.revision = tonumber(string.sub("$Revision: 19012 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGeneralRajaxx:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "DamageEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "DamageEvent")
	
	self.warnsets = {}
	for i=1,9 do self.warnsets[L["trigger"..i]] = L["warn"..i] end
end

function BigWigsGeneralRajaxx:VerifyEnable(unit)
	return not rajdead
end

function BigWigsGeneralRajaxx:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.wave and msg and self.warnsets[msg] then
		self:TriggerEvent("BigWigs_Message", self.warnsets[msg], "Urgent")
	end
	if self.db.profile.thunder and string.find(msg, L["trigger8"]) then
		self:ScheduleEvent("BigWigs_Message", 20, L["thunder_warn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["thunder_bar"], 25, "Interface\\Icons\\Spell_Nature_ThunderClap")
	end
end

function BigWigsGeneralRajaxx:DamageEvent(msg)
	if self.db.profile.thunder and string.find(msg, L["thunder_trigger"]) then
		self:ScheduleEvent("BigWigs_Message", 20, L["thunder_warn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["thunder_bar"], 25, "Interface\\Icons\\Spell_Nature_ThunderClap")
	end
end

function BigWigsGeneralRajaxx:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if self.db.profile.wave and string.find(msg, L["miniboss1"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn2"], "Urgent")
	elseif self.db.profile.wave and string.find(msg, L["miniboss2"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn3"], "Urgent")
	elseif self.db.profile.wave and string.find(msg, L["miniboss3"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn4"], "Urgent")
	elseif self.db.profile.wave and string.find(msg, L["miniboss4"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn5"], "Urgent")
	elseif self.db.profile.wave and string.find(msg, L["miniboss5"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn6"], "Urgent")
	elseif self.db.profile.wave and string.find(msg, L["miniboss6"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn7"], "Urgent")
	elseif self.db.profile.wave and string.find(msg, L["miniboss7"]) then
		self:ScheduleEvent("BigWigs_Message", 3, L["warn8"], "Urgent")
	end
	if msg == string.format(UNITDIESOTHER, self:ToString()) then
		if self.db.profile.bosskill then
			self:TriggerEvent("BigWigs_Message", string.format(L2["%s has been defeated"], self:ToString()), "Bosskill", nil, "Victory")
			BigWigs:Flawless()
		end
		self.core:ToggleModuleActive(self, false)
		rajdead = true
	end
end


