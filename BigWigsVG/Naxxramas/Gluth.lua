------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Gluth"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Gluth",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for fear",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for frenzy",

	decimate_cmd = "decimate",
	decimate_name = "Decimate Alert",
	decimate_desc = "Warn for Decimate",

	trigger1 = "Gluth gains Frenzy.",
	trigger2 = "by Terrifying Roar.",
	starttrigger = "devours all nearby zombies!",

	warn1 = "Frenzy Alert!",
	warn2 = "5 second until AoE Fear!",

	startwarn = "Gluth Engaged! 100 seconds till Zombies!",
	decimatesoonwarn = "Decimate Soon!",
	decimatewarn = "Decimate!",
	decimatetrigger = "Decimate",
	frenzy_bar = "Frenzy",
	frenzyfade_trigger = "Frenzy fades from Gluth",

	enragesoon = "Enrage soon!",
	
	bar1text = "AoE Fear",
	decimatebartext = "Decimate Zombies",
	enragebartext = "Enrage",
	nextfrenzy = "Next Frenzy",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGluth = BigWigs:NewModule(boss)
BigWigsGluth.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsGluth.enabletrigger = boss
BigWigsGluth.toggleoptions = {"frenzy", "fear", "decimate", "bosskill"}
BigWigsGluth.revision = tonumber(string.sub("$Revision: 19004 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

-- XXX Need to add a timer bar for berserker rage.
-- XXX It happens some time after the 3rd decimate, but it's probably on a
-- XXX fixed timer, so just make it a bar like the Twins enrage timer.

function BigWigsGluth:OnEnable()
	self.prior = nil
	started = nil

	self:RegisterEvent("BigWigs_Message")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Frenzy")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Frenzy")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Fear")

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Decimate")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "GluthDecimate", 30)
	self:TriggerEvent("BigWigs_ThrottleSync", "GluthFear", 15)
end

function BigWigsGluth:Frenzy( msg )
	if self.db.profile.frenzy and msg == L["trigger1"] then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["warn1"], "Important", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 10, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsGluth:Fear( msg )
	if string.find(msg, L["trigger2"]) then
		self:TriggerEvent("BigWigs_SendSync", "GluthFear")
	end
end

--does not work on VG, no combat log message when decimate is used
function BigWigsGluth:Decimate( msg )
	if string.find(msg, L["decimatetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "GluthDecimate")
	end
end

function BigWigsGluth:BigWigs_RecvSync( sync, rest, nick )
	if sync == "GluthFear" and self.db.profile.fear and not self.prior then
		self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 20, "Interface\\Icons\\Spell_Shadow_PsychicScream")
		self:ScheduleEvent("BigWigs_Message", 15, L["warn2"], "Urgent")
		self.prior = true
		--does not work on VG, no combat log message when decimate is used
	elseif sync == "GluthDecimate" and self.db.profile.decimate then
		self:TriggerEvent("BigWigs_Message", L["decimatewarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["decimatebartext"], 100, "Interface\\Icons\\INV_Shield_01")
		self:ScheduleEvent("BigWigs_Message", 95, L["decimatesoonwarn"], "Urgent")
	elseif sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		if self.db.profile.decimate then
			self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 20, "Interface\\Icons\\Spell_Shadow_PsychicScream")
			self:ScheduleEvent("BigWigs_Message", 15, L["warn2"], "Urgent")
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Attention")
			--1st decimate bar and warning
			self:TriggerEvent("BigWigs_StartBar", self, L["decimatebartext"], 100, "Interface\\Icons\\INV_Shield_01")
			self:ScheduleEvent("BigWigs_Message", 95, L["decimatesoonwarn"], "Urgent")
			--2nd decimate bar and warning, visible after 120 seconds (20 sec after 1st deciamte when zombies are under control)
			self:ScheduleEvent("BigWigs_Message", 195, L["decimatesoonwarn"], "Urgent", true, "Alarm")
			self:ScheduleEvent("BigWigs_StartBar", 120, self, L["decimatebartext"], 80, "Interface\\Icons\\INV_Shield_01")
			--3rd decimate bar and warning, visible after 220 seconds (20 sec after 1st deciamte when zombies are under control)
			self:ScheduleEvent("BigWigs_Message", 295, L["decimatesoonwarn"], "Urgent", true, "Alarm")
			self:ScheduleEvent("BigWigs_StartBar", 220, self, L["decimatebartext"], 80, "Interface\\Icons\\INV_Shield_01")
			--enrage = wipe
			self:ScheduleEvent("BigWigs_Message", 305, L["enragesoon"], "Urgent", true, "Alarm")
			self:ScheduleEvent("BigWigs_StartBar", 300, self, L["enragebartext"], 11, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		end
	end
end

function BigWigsGluth:BigWigs_Message(text)
	if text == L["warn2"] then self.prior = nil end
end

function BigWigsGluth:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsGluth:Tranq()
            if (UnitClass("player") == "Hunter") then
		self:TriggerEvent("BigWigs_StartBar", self, L["nextfrenzy"], 10, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsGluth:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end
