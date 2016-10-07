------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Shazzrah"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	trigger1 = "casts Gate of Shazzrah",
	daedentrigger = "Shazzrah is afflicted by Deaden Magic",
	trigger3 = "afflicted by Shazzrah",

	warn2 = "~5 seconds to Blink!",
	warn3 = "Shazzrah got buff! Spelldmg redused by 50% for 30sec!",
	warn4 = "Shazzrah's curse! Decurse NOW!",

	bar1text = "Blink",
	bar2text = "Deaden Magic active",
	daedenmagicnextbar = "next Deaden Magic",

	cmd = "Shazzrah",
	
	cursecd = "Incoming Curse",
	curse_cmd = "curse",
	curse_name = "Curse alert",
	curse_desc = "Warn for Shazzrah's Curse",

	selfbuff_cmd = "selfbuff",
	selfbuff_name = "Self Buff Alert",
	selfbuff_desc = "Warn when Shazzrah casts a Self Buff",
	
	blink_cmd = "blink",
	blink_name = "Blink Alert",
	blink_desc = "Warn when Shazzrah Blinks",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsShazzrah = BigWigs:NewModule(boss)
BigWigsShazzrah.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsShazzrah.enabletrigger = boss
BigWigsShazzrah.toggleoptions = {"curse", "selfbuff", "blink", "bosskill"}
BigWigsShazzrah.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsShazzrah:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("BigWigs_RecvSync")
	
	self:TriggerEvent("BigWigs_ThrottleSync", "ShazzrahBlink", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "ShazzrahDeadenMagic", 5)
	
	started = nil
	blinktime = 20
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsShazzrah:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if string.find(msg, L["daedentrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "ShazzrahDeadenMagic")
	end
end

function BigWigsShazzrah:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if (string.find(msg, L["trigger1"])) then
		self:TriggerEvent("BigWigs_SendSync", "ShazzrahBlink")
	end
end

function BigWigsShazzrah:BigWigs_RecvSync( sync, rest )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.selfbuff then
			self:TriggerEvent("BigWigs_StartBar", self, L["daedenmagicnextbar"], 24, "Interface\\Icons\\Spell_Holy_SealOfSalvation")
		end
		if self.db.profile.curse then
			self:TriggerEvent("BigWigs_StartBar", self, L["cursecd"], 10, "Interface\\Icons\\Spell_Shadow_AntiShadow")
		end
		if self.db.profile.blink then
			self:ScheduleEvent("BigWigs_Message", 25, L["warn2"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			--self:ScheduleEvent("bwshazzrahblinkstart", self.StartBlink, 30, self )
		end
	elseif sync == "ShazzrahBlink" and self.db.profile.blink then
		--self:ScheduleEvent("BigWigs_Message", blinktime - 5, L["warn2"], "Urgent")
		--self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], blinktime, "Interface\\Icons\\Spell_Arcane_Blink")
	elseif (sync == "ShazzrahDeadenMagic" and self.db.profile.selfbuff) then
		self:TriggerEvent("BigWigs_Message", L["warn3"], "Urgent", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["bar2text"], 30, "Interface\\Icons\\Spell_Holy_SealOfSalvation")
		self:TriggerEvent("BigWigs_StartBar", self, L["daedenmagicnextbar"], 35, "Interface\\Icons\\Spell_Holy_SealOfSalvation")
	end
end

function BigWigsShazzrah:StartBlink()
	self:Blink()
	self:ScheduleRepeatingEvent("bwshazzrahblink", self.Blink, blinktime, self)
end

function BigWigsShazzrah:Blink()
	self:TriggerEvent("BigWigs_SendSync", "ShazzrahBlink")
end

function BigWigsShazzrah:Event(msg)
	if string.find(msg, L["trigger3"]) and self.db.profile.curse then
		self:TriggerEvent("BigWigs_Message", L["warn4"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["cursecd"], 20, "Interface\\Icons\\Spell_Shadow_AntiShadow")
	end
end
