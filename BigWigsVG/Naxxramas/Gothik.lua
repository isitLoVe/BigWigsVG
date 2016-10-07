------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Gothik the Harvester"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Gothik",

	room_cmd = "room",
	room_name = "Room Arrival Warnings",
	room_desc = "Warn for Gothik's arrival",

	add_cmd = "add",
	add_name = "Add Warnings",
	add_desc = "Warn for adds",

	adddeath_cmd = "adddeath",
	adddeath_name = "Add Death Alert",
	adddeath_desc = "Alerts when an add dies.",

	buff_cmd = "buff",
	buff_name = "Buff Alert",
	buff_desc = "Notify on Buffs Fading",
	
	GSPPtrigger	= "Shadow Protection",

	disabletrigger = "I... am... undone.",

	starttrigger1 = "Foolishly you have sought your own demise.",
	starttrigger2 = "Teamanare shi rikk mannor rikk lok karkun",
	casttrigger = "Unrelenting Rider begins to cast Shadow Bolt Volley.",
	castwarn = "Shadow Bolt Volley!",
	startwarn = "Gothik the Harvester engaged! 4:42 till he's in the room.",

	rider_name = "Unrelenting Rider",
	spectral_rider_name = "Spectral Rider",
	deathknight_name = "Unrelenting Deathknight",
	spectral_deathknight_name = "Spektral Deathknight",
	trainee_name = "Unrelenting Trainee",
	spectral_trainee_name = "Spectral Trainee",

	riderdiewarn = "Rider dead!",
	dkdiewarn = "Death Knight dead!",

	warn1 = "In room in 3 minutes",
	warn2 = "In room in 90 seconds",
	warn3 = "In room in 60 seconds",
	warn4 = "In room in 30 seconds",
	warn5 = "Gothik Incoming in 10 seconds",

	wave = "%d/23: ",

	trawarn = "Trainees in 3 seconds",
	dkwarn = "Deathknight in 3 seconds",
	riderwarn = "Rider in 3 seconds",

	trabar = "Trainee - %d",
	dkbar = "Deathknight - %d",
	riderbar = "Rider - %d",

	inroomtrigger = "I have waited long enough! Now, you face the harvester of souls!",
	inroomwarn = "He's in the room!",
	
	dooropen_bar = "Doors opening",
	blink_bar = "Blink",
	
	inroombartext = "In Room",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGothik = BigWigs:NewModule(boss)
BigWigsGothik.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsGothik.enabletrigger = { boss }
BigWigsGothik.wipemobs = {
	L["rider_name"], L["deathknight_name"], L["trainee_name"],
	L["spectral_rider_name"], L["spectral_deathknight_name"], L["spectral_trainee_name"]
}
BigWigsGothik.toggleoptions = { "room", "buff", -1, "add", "adddeath", "bosskill" }
BigWigsGothik.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGothik:OnEnable()
	self.wave = 0
	self.tratime = 24
	self.dktime = 74
	self.ridertime = 134

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
end

function BigWigsGothik:CHAT_MSG_COMBAT_HOSTILE_DEATH( msg )
	if self.db.profile.adddeath and msg == string.format(UNITDIESOTHER, L["rider_name"]) then
		self:TriggerEvent("BigWigs_Message", L["riderdiewarn"], "Important", true, "Alert")
	elseif self.db.profile.adddeath and msg == string.format(UNITDIESOTHER, L["deathknight_name"]) then
		self:TriggerEvent("BigWigs_Message", L["dkdiewarn"], "Important")
	end
end

function BigWigsGothik:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["casttrigger"]) and UnitName("target") == "Unrelenting Rider" then
			self:TriggerEvent("BigWigs_Message", L["castwarn"], "Personal", true, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, L["castwarn"], 1, "Interface\\Icons\\Spell_Shadow_Shadowbolt")
	end
end

function BigWigsGothik:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if self.db.profile.buff then
		if string.find(msg, L["GSPPtrigger"]) then
            BigWigsThaddiusArrows:GSPPstop()
		end
	end
end

function BigWigsGothik:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if self.db.profile.buff then
		if string.find(msg, L["GSPPtrigger"]) then
	        BigWigsThaddiusArrows:Direction("GSPP")
		end
	end
end

function BigWigsGothik:StopRoom()
	self:CancelScheduledEvent("bwgothikwarn1")
	self:CancelScheduledEvent("bwgothikwarn2")
	self:CancelScheduledEvent("bwgothikwarn3")
	self:CancelScheduledEvent("bwgothikwarn4")
	self:CancelScheduledEvent("bwgothikwarn5")
	if self.tranum and self.dknum and self.ridernum then
		self:TriggerEvent("BigWigs_StopBar", self, string.format(L["trabar"], self.tranum - 1))
		self:TriggerEvent("BigWigs_StopBar", self, string.format(L["dkbar"], self.dknum - 1))
		self:TriggerEvent("BigWigs_StopBar", self, string.format(L["riderbar"], self.ridernum - 1))
	end
	self:CancelScheduledEvent("bwgothiktrawarn")
	self:CancelScheduledEvent("bwgothikdkwarn")
	self:CancelScheduledEvent("bwgothikriderwarn")
	self:CancelScheduledEvent("bwgothiktrarepop")
	self:CancelScheduledEvent("bwgothikdkrepop")
	self:CancelScheduledEvent("bwgothikriderrepop")
	

end

function BigWigsGothik:WaveWarn(message, L, color)
	self.wave = self.wave + 1
        if self.wave == 23 then
        self:StopRoom()
		CHAT_FRAME_DEFAULT:AddMessage("stoproom")
        self.wave = 0
	self.tratime = 27
	self.dktime = 77
	self.ridertime = 137
        end
	if self.db.profile.add then self:TriggerEvent("BigWigs_Message", string.format(L["wave"], self.wave) .. message, color) end
end

function BigWigsGothik:Trainee()
	if self.db.profile.add and self.tranum <= 11 then
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["trabar"], self.tranum), self.tratime, "Interface\\Icons\\Ability_Seal")
		self:ScheduleEvent("bwgothiktrawarn", self.WaveWarn, self.tratime - 3, self, L["trawarn"], L, "Attention")
	end
	self:ScheduleRepeatingEvent("bwgothiktrarepop", self.Trainee, self.tratime, self)
	self.tranum = self.tranum + 1
end

function BigWigsGothik:DeathKnight()
	if self.db.profile.add and self.dknum <= 7 then
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["dkbar"], self.dknum), self.dktime, "Interface\\Icons\\INV_Boots_Plate_08")
		self:ScheduleEvent("bwgothikdkwarn", self.WaveWarn, self.dktime - 3, self, L["dkwarn"], L, "Urgent")
	end
	self:ScheduleRepeatingEvent("bwgothikdkrepop", self.DeathKnight, self.dktime, self)
	self.dknum = self.dknum + 1
end

function BigWigsGothik:Rider()
	if self.db.profile.add and self.ridernum <= 4 then
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["riderbar"], self.ridernum), self.ridertime, "Interface\\Icons\\Spell_Shadow_DeathPact")
		self:ScheduleEvent("bwgothikriderwarn", self.WaveWarn, self.ridertime - 3, self, L["riderwarn"], L, "Important", true, "Alarm")
	end
	self:ScheduleRepeatingEvent("bwgothikriderrepop", self.Rider, self.ridertime, self)
	self.ridernum = self.ridernum + 1
end

function BigWigsGothik:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["starttrigger1"] or msg == L["starttrigger2"] then
    self.wave = 0
	self.tratime = 23
	self.dktime = 73
	self.ridertime = 133
		if self.db.profile.room then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["inroombartext"], 282, "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
			self:ScheduleEvent("bwgothikwarn1", "BigWigs_Message", 102, L["warn1"], "Attention")
			self:ScheduleEvent("bwgothikwarn2", "BigWigs_Message", 192, L["warn2"], "Attention")
			self:ScheduleEvent("bwgothikwarn3", "BigWigs_Message", 222, L["warn3"], "Urgent")
			self:ScheduleEvent("bwgothikwarn4", "BigWigs_Message", 252, L["warn4"], "Important")
			self:ScheduleEvent("bwgothikwarn5", "BigWigs_Message", 272, L["warn5"], "Important")
		end
		self.tranum = 1
		self.dknum = 1
		self.ridernum = 1
		if self.db.profile.add then
			self:Trainee()
			self:DeathKnight()
			self:Rider()
		end
		-- set the new times
		self.tratime = 20
		self.dktime = 25
		self.ridertime = 30
		
		--Blink
		self:ScheduleEvent("BigWigs_StartBar", 282, self, L["blink_bar"], 20, "Interface\\Icons\\Spell_Arcane_Blink")
		self:ScheduleEvent("BigWigs_StartBar", 302, self, L["blink_bar"], 20, "Interface\\Icons\\Spell_Arcane_Blink")
		self:ScheduleEvent("BigWigs_StartBar", 322, self, L["blink_bar"], 20, "Interface\\Icons\\Spell_Arcane_Blink")
		self:ScheduleEvent("BigWigs_StartBar", 342, self, L["blink_bar"], 20, "Interface\\Icons\\Spell_Arcane_Blink")
		self:ScheduleEvent("BigWigs_StartBar", 362, self, L["blink_bar"], 20, "Interface\\Icons\\Spell_Arcane_Blink")
		self:ScheduleEvent("BigWigs_StartBar", 382, self, L["blink_bar"], 20, "Interface\\Icons\\Spell_Arcane_Blink")

		
	elseif msg == L["inroomtrigger"] then
		if self.db.profile.room then self:TriggerEvent("BigWigs_Message", L["inroomwarn"], "Important") end
	        self:TriggerEvent("BigWigs_StopBar", self, L["inroombartext"])
	elseif string.find(msg, L["disabletrigger"]) then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], boss), "Bosskill", nil, "Victory") end
		self.core:ToggleModuleActive(self, false)
	end
end
