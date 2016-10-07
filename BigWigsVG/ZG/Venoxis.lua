------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priest Venoxis"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Venoxis",

	renew_cmd = "renew",
	renew_name = "Renew Alert",
	renew_desc = "Warn for Renew",

	phase_cmd = "phase",
	phase_name = "Phase 2 Alert",
	phase_desc = "Warn for Phase 2",

	renew_trigger = "High Priest Venoxis gains Renew.",
	phase2_trigger = "Let the coils of hate unfurl!",

	renew_message = "Renew!",
	phase2_message = "Incoming phase 2 - poison clouds spawning!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsVenoxis = BigWigs:NewModule(boss)
BigWigsVenoxis.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsVenoxis.enabletrigger = boss
BigWigsVenoxis.toggleoptions = {"renew", "phase", "bosskill"}
BigWigsVenoxis.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsVenoxis:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsVenoxis:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if self.db.profile.renew and msg == L["renew_trigger"] then
		self:TriggerEvent("BigWigs_Message", L["renew_message"], "Urgent")
	end
end

function BigWigsVenoxis:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.phase and string.find(msg, L["phase2_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["phase2_message"], "Attention")
	end
end

