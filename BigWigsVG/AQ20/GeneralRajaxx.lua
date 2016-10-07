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

	trigger1 = "Kill first, ask questions later... Incoming!",
	trigger2 = "?????",  -- There is no callout for wave 2 ><
	trigger3 = "The time of our retribution is at hand! Let darkness reign in the hearts of our enemies!",
	trigger4 = "No longer will we wait behind barred doors and walls of stone! No longer will our vengeance be denied! The dragons themselves will tremble before our wrath!\013\n",
	trigger5 = "Fear is for the enemy! Fear and death!",
	trigger6 = "Staghelm will whimper and beg for his life, just as his whelp of a son did! One thousand years of injustice will end this day!\013\n",
	trigger7 = "Fandral! Your time has come! Go and hide in the Emerald Dream and pray we never find you!\013\n",
	trigger8 = "Impudent fool! I will kill you myself!",
	trigger9 = "Remember, Rajaxx, when I said I'd kill you last?",

	warn1 = "Wave 1/8",
	warn2 = "Wave 2/8",
	warn3 = "Wave 3/8",
	warn4 = "Wave 4/8",
	warn5 = "Wave 5/8",
	warn6 = "Wave 6/8",
	warn7 = "Wave 7/8",
	warn8 = "Incoming General Rajaxx",
	warn9 = "Wave 1/8", -- trigger for starting the event by pulling the first wave instead of talking to andorov

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGeneralRajaxx = BigWigs:NewModule(boss)
BigWigsGeneralRajaxx.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsGeneralRajaxx.enabletrigger = andorov
BigWigsGeneralRajaxx.toggleoptions = {"wave", "bosskill"}
BigWigsGeneralRajaxx.revision = tonumber(string.sub("$Revision: 17293 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGeneralRajaxx:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
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
end

function BigWigsGeneralRajaxx:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString()) then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(L2["%s has been defeated"], self:ToString()), "Bosskill", nil, "Victory") end
                BigWigs:Flawless()
		self.core:ToggleModuleActive(self, false)
		rajdead = true
	end
end


