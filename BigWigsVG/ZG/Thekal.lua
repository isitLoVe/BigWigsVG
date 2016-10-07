------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priest Thekal"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Thekal",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for healing",

	tiger_cmd = "tiger",
	tiger_name = "Tigers Alert",
	tiger_desc = "Warn for incoming tigers",

	tigers_trigger = "High Priest Thekal performs Summon Zulian Guardians.",
	heal_trigger = "Zealot Lor'Khan begins to cast Great Heal.",
	healbar = "Great Heal",

	tigers_message = "Incoming Tigers!",
	heal_message = "Lor'Khan Casting Heal!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsThekal = BigWigs:NewModule(boss)
BigWigsThekal.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsThekal.enabletrigger = boss
BigWigsThekal.toggleoptions = {"heal", "tiger", "bosskill"}
BigWigsThekal.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsThekal:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsThekal:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if self.db.profile.tiger and msg == L["tigers_trigger"] then
		self:TriggerEvent("BigWigs_Message", L["tigers_message"], "Attention")
	elseif self.db.profile.heal and msg == L["heal_trigger"] then
		self:TriggerEvent("BigWigs_StartBar", self, L["healbar"], 4, "Interface\\Icons\\Spell_Holy_Heal")
		self:TriggerEvent("BigWigs_Message", L["heal_message"], "Urgent", true, "Alert")
	end
end


