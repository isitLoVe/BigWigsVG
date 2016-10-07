------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Princess Huhuran"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local berserkannounced
local prior
local started

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Huhuran",

	wyvern_cmd = "wyvern",
	wyvern_name = "Wyvern Sting Alert",
	wyvern_desc = "Warn for Wyvern Sting",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",

	berserk_cmd = "berserk",
	berserk_name = "Berserk Alert",
	berserk_desc = "Warn for Berserk",

	triggerchat_frenzy = "Princess Huhuran gains Frenzy",
	frenzyfade_trigger = "Frenzy fades from Princess Huhuran",
	frenzy_bar = "Frenzy",

	frenzytrigger = "%s goes into a frenzy!",
	berserktrigger = "%s goes into a berserker rage!",
	frenzy_message = "Frenzy - Tranq Shot!",
	berserkwarn = "Berserk! Berserk! Berserk!",
	berserksoonwarn = "Berserk Soon!",
	stingtrigger = "afflicted by Wyvern Sting",
	stingwarn = "Wyvern Sting!",
	stingdelaywarn = "Possible Wyvern Sting in ~3 seconds!",
	bartext = "Wyvern Sting",

	startwarn = "Huhuran engaged, 5 minutes to berserk!",
	berserkbar = "Berserk",
	berserkwarn1 = "Berserk in 1 minute!",
	berserkwarn2 = "Berserk in 30 seconds!",
	berserkwarn3 = "Berserk in 5 seconds!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsHuhuran = BigWigs:NewModule(boss)
BigWigsHuhuran.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsHuhuran.enabletrigger = boss
BigWigsHuhuran.toggleoptions = {"wyvern", "frenzy", "berserk", "bosskill"}
BigWigsHuhuran.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsHuhuran:OnEnable()
	prior = nil
	berserkannounced = nil
	started = nil

	self:RegisterEvent("BigWigs_Message")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "checkSting")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "checkSting")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "checkSting")

	self:RegisterEvent("BigWigs_RecvSync")
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsHuhuran:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.berserk then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["berserkbar"], 300, "Interface\\Icons\\INV_Shield_01")
			self:ScheduleEvent("bwhuhuranenragewarn1", "BigWigs_Message", 240, L["berserkwarn1"], "Attention")
			self:ScheduleEvent("bwhuhuranenragewarn2", "BigWigs_Message", 270, L["berserkwarn2"], "Urgent")
			self:ScheduleEvent("bwhuhuranenragewarn3", "BigWigs_Message", 295, L["berserkwarn3"], "Important")
		end
	end
end

function BigWigsHuhuran:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if self.db.profile.frenzy and string.find(arg1, L["triggerchat_frenzy"]) then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["frenzy_message"], "Important", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 8, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsHuhuran:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsHuhuran:CHAT_MSG_MONSTER_EMOTE(arg1)
	if self.db.profile.frenzy and arg1 == L["frenzytrigger"] then
		self:TriggerEvent("BigWigs_Message", L["frenzywarn"], "Urgent")
	elseif self.db.profile.berserk and arg1 == L["berserktrigger"] then
		self:CancelScheduledEvent("bwhuhuranenragewarn1")
		self:CancelScheduledEvent("bwhuhuranenragewarn2")
		self:CancelScheduledEvent("bwhuhuranenragewarn3")

		self:TriggerEvent("BigWigs_StopBar", self, L["berserkbar"])

		self:TriggerEvent("BigWigs_Message", L["berserkwarn"], "Important")

		berserkannounced = true
	end
end

function BigWigsHuhuran:UNIT_HEALTH(arg1)
	if not self.db.profile.berserk then return end
	if UnitName(arg1) == boss then
		local health = UnitHealth(arg1)
		if health > 30 and health <= 33 and not berserkannounced then
			self:TriggerEvent("BigWigs_Message", L["berserksoonwarn"], "Important")
			berserkannounced = true
		elseif (health > 40 and berserkannounced) then
			berserkannounced = false
		end
	end
end

function BigWigsHuhuran:checkSting(arg1)
	if not self.db.profile.wyvern then return end
	if not prior and string.find(arg1, L["stingtrigger"]) then
		self:TriggerEvent("BigWigs_Message", L["stingwarn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 25, "Interface\\Icons\\INV_Spear_02")
		self:ScheduleEvent("BigWigs_Message", 22, L["stingdelaywarn"], "Urgent")
		prior = true
	end
end

function BigWigsHuhuran:BigWigs_Message(text)
	if text == L["stingdelaywarn"] then prior = nil end
end

function BigWigsHuhuran:Tranq()
            if (UnitClass("player") == "Hunter") then
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsHuhuran:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end
