------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Gehennas"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started = nil

local prior

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	trigger1 = "afflicted by Gehennas",
	trigger2 = "Gehennas begins to cast Shadowbolt",

	warn1 = "5 seconds until Gehennas' Curse!",
	warn2 = "Gehennas' Curse - Decurse NOW!",

	bar1text = "Gehennas' Curse",
	bar2text = "Shadowbolt cast",
	bar3text = "Shadowbolt",
	trigger  = "Rain of Fire",
	trigger3  = "You are afflicted by Rain of Fire",
	firewarn = "Run from FIRE!",

	cmd = "Gehennas",

	shadowbolt_cmd = "shadowbolt",
	shadowbolt_name = "Gehennas' shadowbolt alert",
	shadowbolt_desc = "Warn when Gehennas start cast Shadowbolt",
	
	curse_cmd = "curse",
	curse_name = "Gehennas' Curse alert",
	curse_desc = "Warn for Gehennas' Curse",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGehennas = BigWigs:NewModule(boss)
BigWigsGehennas.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsGehennas.enabletrigger = boss
BigWigsGehennas.toggleoptions = {"shadowbolt", "curse", "bosskill"}
BigWigsGehennas.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGehennas:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("BigWigs_RecvSync")
	
	self:TriggerEvent("BigWigs_ThrottleSync", "GehennasCurse", 5)
	
	prior = nil
	started = nil
	
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsGehennas:Event(msg)
	if not prior and string.find(msg, L["trigger1"]) then
		self:TriggerEvent("BigWigs_SendSync", "GehennasCurse")
	elseif string.find(msg, L["trigger3"]) then
		self:CancelScheduledEvent("bwgehennasfire")
		self:TriggerEvent("BigWigs_Message", L["firewarn"], "Personal", true, "Alarm")
	end
end

function BigWigsGehennas:BigWigs_RecvSync( sync, rest) 
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.curse then
			self:ScheduleEvent("BigWigs_Message", 7, L["warn1"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 12, "Interface\\Icons\\Spell_Shadow_BlackPlague")
		end
	elseif sync == "GehennasCurse" and self.db.profile.curse then
		self:TriggerEvent("BigWigs_Message", L["warn2"], "Important", true, "Alarm")
		self:ScheduleEvent("BigWigs_Message", 20, L["warn1"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 25, "Interface\\Icons\\Spell_Shadow_BlackPlague")
		prior = true
	end
end


function BigWigsGehennas:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["trigger"]) then
	end
end

function BigWigsGehennas:BigWigs_Message(msg)
	if (msg == L["warn1"]) then prior = nil end
end

function BigWigsGehennas:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["trigger2"]) and self.db.profile.shadowbolt then
			self:TriggerEvent("BigWigs_StartBar", self, L["bar2text"], 0.5, "Interface\\Icons\\Spell_Shadow_Shadowbolt")
			self:TriggerEvent("BigWigs_StartBar", self, L["bar3text"], 10, "Interface\\Icons\\Spell_Shadow_Shadowbolt")
	end
end
