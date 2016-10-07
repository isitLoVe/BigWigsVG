------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Magmadar"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	-- Chat message triggers
	trigger1 = "gains Frenzy",
	trigger2 = "by Panic.",
	frenzyfade_trigger = "Frenzy fades from Magmadar",

	frenzy_bar = "Frenzy",

	-- Warnings and bar texts
	["Frenzy alert!"] = true,
	["5 seconds until AoE Fear!"] = true,
	["AoE Fear - 35 seconds until next!"] = true,
	["AoE Fear - 20 seconds until next!"] = true,
	["AoE Fear"] = true,

	-- AceConsole strings
	cmd = "Magmadar",
	
	fear_cmd = "fear",
	fear_name = "Warn for Fear",
	fear_desc = "Warn when Magmadar casts AoE Fear",
	
	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy alert",
	frenzy_desc = "Warn when Magmadar goes into a frenzy",
	
	conflag_cmd = "conflag",
	conflag_name = "Conflagration alert",
	conflag_desc = "Timer Bar for Conflagration",
	
	conflagtrigger = "afflicted by Conflagration",
	conflagbar = "Conflagration"
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMagmadar = BigWigs:NewModule(boss)
BigWigsMagmadar.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsMagmadar.enabletrigger = boss
BigWigsMagmadar.toggleoptions = {"fear", "frenzy", "conflag", "bosskill"}
BigWigsMagmadar.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMagmadar:OnEnable()
	self.prior = nil
	started = nil
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "MagEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "MagEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "MagEvent")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "MagmadarFear", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "MagmadarConflag", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsMagmadar:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(arg1, L["trigger1"]) and self.db.profile.frenzy then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["Frenzy alert!"], "Important", nil, true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 8, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsMagmadar:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsMagmadar:BigWigs_RecvSync( sync, rest) 
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.fear then
			self:TriggerEvent("BigWigs_StartBar", self, L["AoE Fear"], 20, "Interface\\Icons\\Spell_Shadow_PsychicScream")
			self:TriggerEvent("BigWigs_Message", L["AoE Fear - 20 seconds until next!"], "Important")
			self:ScheduleEvent("BigWigs_Message", 15, L["5 seconds until AoE Fear!"], "Urgent", true, "Alert")
		end
		if self.db.profile.conflag then
			self:TriggerEvent("BigWigs_StartBar", self, L["conflagbar"], 12, "Interface\\Icons\\Spell_Fire_Incinerate")
		end
	elseif sync == "MagmadarFear" and self.db.profile.fear then 
		self:TriggerEvent("BigWigs_StartBar", self, L["AoE Fear"], 35, "Interface\\Icons\\Spell_Shadow_PsychicScream")
		self:TriggerEvent("BigWigs_Message", L["AoE Fear - 35 seconds until next!"], "Important")
		self:ScheduleEvent("BigWigs_Message", 30, L["5 seconds until AoE Fear!"], "Urgent", true, "Alert")
	elseif sync == "MagmadarConflag" and self.db.profile.conflag then
		self:TriggerEvent("BigWigs_StartBar", self, L["conflagbar"], 12, "Interface\\Icons\\Spell_Fire_Incinerate")
	end
end

function BigWigsMagmadar:MagEvent(msg)
	if not self.prior and string.find(msg, L["trigger2"]) then
		self:TriggerEvent("BigWigs_SendSync", "MagmadarFear")
		self.prior = true
	elseif string.find(msg, L["conflagtrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "MagmadarConflag")
	end
end

function BigWigsMagmadar:BigWigs_Message(text)
	if text == L["5 seconds until AoE Fear!"] then self.prior = nil end
end

function BigWigsMagmadar:Tranq()
            if (UnitClass("player") == "Hunter") then
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsMagmadar:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end

