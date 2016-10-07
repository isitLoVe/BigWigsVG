------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Flamegor"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	wingbuffet_trigger = "Flamegor begins to cast Wing Buffet",
	shadowflame_trigger = "Flamegor begins to cast Shadow Flame.",
	frenzy_trigger = "^Flamegor gains Frenzy",
	frenzyfade_trigger = "Frenzy fades from Flamegor",

	startwarn = "Flamegor Engaged! First Wing Buffet in 27 seconds!",
	wingbuffet_message = "Wing Buffet! 25sec to next!",
	wingbuffet_warning = "3sec to Wing Buffet!",
	shadowflame_warning = "Shadow Flame incoming!",
	frenzy_message = "Frenzy - Tranq Shot!",

	wingbuffet_bar = "Wing Buffet",
	shadowflame_bar = "Shadow Flame casting",
	frenzy_bar = "Frenzy",

	shadowflamenext_bar = "Shadow Flame",
	shadowflamenext_message = "Shadow Flame soon",
	
	cmd = "Flamegor",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn for Wing Buffet",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when for frenzy",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFlamegor = BigWigs:NewModule(boss)
BigWigsFlamegor.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsFlamegor.enabletrigger = boss
BigWigsFlamegor.toggleoptions = {"wingbuffet", "shadowflame", "frenzy", "bosskill"}
BigWigsFlamegor.revision = tonumber(string.sub("$Revision: 19004 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFlamegor:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FlamegorWingBuffet", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "FlamegorShadowflame", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsFlamegor:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["wingbuffet_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "FlamegorWingBuffet")
	elseif msg == L["shadowflame_trigger"] then
		self:TriggerEvent("BigWigs_SendSync", "FlamegorShadowflame")
	end
end

function BigWigsFlamegor:BigWigs_RecvSync(sync, rest)	
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		self:TriggerEvent("BigWigs_SendSync", "FlamegorStart")
	elseif sync == "FlamegorStart" then
		if self.db.profile.wingbuffet then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:ScheduleEvent("BigWigs_Message", 32, L["wingbuffet_warning"], "Important", true, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 35, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		end
		if self.db.profile.shadowflame then
			self:TriggerEvent("BigWigs_StartBar", self, L["shadowflamenext_bar"], 30, "Interface\\Icons\\Spell_Fire_Incinerate")
			self:ScheduleEvent("BigWigs_Message", 27, L["shadowflamenext_message"], "Important", true, "Alarm")
		end
	elseif sync == "FlamegorWingBuffet" and self.db.profile.wingbuffet then
		self:ScheduleEvent("BigWigs_Message", 22, L["wingbuffet_warning"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	elseif sync == "FlamegorShadowflame" and self.db.profile.shadowflame then
		--when he got frenzy buff shadow flame cast is only 2sec
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 2.5, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflamenext_bar"], 15, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:ScheduleEvent("BigWigs_Message", 12, L["shadowflamenext_message"], "Important", true, "Alarm")
	end
end

function BigWigsFlamegor:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if self.db.profile.frenzy and string.find(arg1, L["frenzy_trigger"]) then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["frenzy_message"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 10, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsFlamegor:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsFlamegor:Tranq()
            if (UnitClass("player") == "Hunter") then
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsFlamegor:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end
