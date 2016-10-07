------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priestess Mar'li"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local lastdrain = 0

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Marli",

	spider_cmd = "spider",
	spider_name = "Spider Alert",
	spider_desc = "Warn when spiders spawn",

	drain_cmd = "drain",
	drain_name = "Drain Alert",
	drain_desc = "Warn for life drain",

	spiders_trigger = "Aid me my brood!$",
	drainlife_trigger = "heals High Priestess Mar'li",

	spiders_message = "Spiders spawned!",
	drainlife_message = "High Priestess Mar'li is draining life!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMarli = BigWigs:NewModule(boss)
BigWigsMarli.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsMarli.enabletrigger = boss
BigWigsMarli.toggleoptions = {"spider", "drain", "bosskill"}
BigWigsMarli.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMarli:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
end

------------------------------
--      Events              --
------------------------------

function BigWigsMarli:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.spider and string.find(msg, L["spiders_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["spiders_message"], "Attention")
	end
end

function BigWigsMarli:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if self.db.profile.drain and string.find(msg, L["drainlife_trigger"]) and lastdrain < (GetTime()-3) then
		lastdrain = GetTime()
		self:TriggerEvent("BigWigs_Message", L["drainlife_message"], "Urgent", true, "Alert")
	end
end


