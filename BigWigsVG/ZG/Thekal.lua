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

	punch_cmd = "punch",
	punch_name = "Force Punch Alert",
	punch_desc = "Warn for Force Punch",

	tigers_trigger = "High Priest Thekal performs Summon Zulian Guardians.",
	heal_trigger = "Zealot Lor'Khan begins to cast Great Heal.",
	punch_trigger = "High Priest Thekal begins to perform Force Punch.",
	
	healbar = "Great Heal",
	punch_bar = "Force Punch",
	tigers_bar = "Tigers",

	tigers_message = "Incoming Tigers!",
	heal_message = "Lor'Khan Casting Heal!",
	punch_message = "Force Punch in ~5sec",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsThekal = BigWigs:NewModule(boss)
BigWigsThekal.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsThekal.enabletrigger = boss
BigWigsThekal.toggleoptions = {"heal", "tiger", "punch", "bosskill"}
BigWigsThekal.revision = tonumber(string.sub("$Revision: 19011 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsThekal:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	--self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsThekal:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if self.db.profile.tiger and msg == L["tigers_trigger"] then
		self:TriggerEvent("BigWigs_Message", L["tigers_message"], "Attention")
		self:TriggerEvent("BigWigs_StartBar", self, L["tigers_bar"], 13, "Interface\\Icons\\INV_Misc_Pelt_04")
	elseif self.db.profile.heal and msg == L["heal_trigger"] then
		self:TriggerEvent("BigWigs_StartBar", self, L["healbar"], 4, "Interface\\Icons\\Spell_Holy_Heal")
		self:TriggerEvent("BigWigs_Message", L["heal_message"], "Urgent", nil, "Alert")
	end
end

function BigWigsThekal:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	if self.db.profile.punch and msg == L["punch_trigger"] then
		self:ScheduleEvent("BigWigs_Message", 20, L["punch_message"], "Urgent", nil, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["punch_bar"], 25, "Interface\\Icons\\Ability_WarStomp")
	end
end