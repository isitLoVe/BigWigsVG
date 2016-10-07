------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Hakkar"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	-- Chat message triggers
	engage_trigger = "FACE THE WRATH OF THE SOULFLAYER!",
	drain_trigger = "^Hakkar suffers (.+) from (.+) Blood Siphon",
	mindcontrol_trigger = "(.*) (.*) afflicted by Cause Insanity",

	you = "You",
	are = "are",

	flee = "Fleeing will do you no good, mortals!",

	-- Warnings and bar texts
	start_message = "Hakkar engaged - 90sec to drain - 10min to enrage!",
	drain_warning = "%d sec to Life Drain!",
	drain_message = "Life Drain - 90sec to next!",

	mindcontrol_message = "%s is mindcontrolled!",
	mindcontrol_bar = "MC: %s",

	["Enrage"] = true,
	["Life Drain"] = true,

	cmd = "Hakkar",

	drain_cmd = "drain",
	drain_name = "Drain Alerts",
	drain_desc = "Warn for Drains",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alerts",
	enrage_desc = "Warn for Enrage",

	mc_cmd = "mc",
	mc_name = "Mind Control",
	mc_desc = "Alert when someone is mind controlled.",

	icon_cmd = "icon",
	icon_name = "Place Icon",
	icon_desc = "Place a skull icon on the mind controlled person (requires promoted or higher)",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsHakkar = BigWigs:NewModule(boss)
BigWigsHakkar.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsHakkar.enabletrigger = boss
BigWigsHakkar.toggleoptions = { "drain", "enrage", -1, "mc", "icon", "bosskill" }
BigWigsHakkar.revision = tonumber(string.sub("$Revision: 17555 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsHakkar:OnEnable()
	self.prior = nil
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_Message")
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsHakkar:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["engage_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["start_message"], "Important")
		if self.db.profile.enrage then self:TriggerEvent("BigWigs_StartBar", self, L["Enrage"], 600, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy") end
		self:BeginTimers(true)
	elseif string.find(msg, L["flee"]) then
		self:TriggerEvent("BigWigs_RebootModule", self)
	end
end

function BigWigsHakkar:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if not self.prior and string.find(msg, L["drain_trigger"]) then
		self.prior = true
		self:BeginTimers()
	end
end

function BigWigsHakkar:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE(msg)
	local _,_, mcplayer, mctype = string.find(msg, L["mindcontrol_trigger"])
	if mcplayer then
		if mcplayer == L["you"] then
			mcplayer = UnitName("player")
		end
		if self.db.profile.mc then
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["mindcontrol_bar"], mcplayer), 9.5, "Interface\\Icons\\Spell_Shadow_ShadowWordDominate")
			self:TriggerEvent("BigWigs_Message", string.format(L["mindcontrol_message"], mcplayer), "Urgent")
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", mcplayer)
		end
	end
end

function BigWigsHakkar:BigWigs_Message(text)
	if text == string.format(L["drain_warning"], 60) then self.prior = nil end
end

function BigWigsHakkar:BeginTimers(first)
	if self.db.profile.drain then
		if not first then self:TriggerEvent("BigWigs_Message", L["drain_message"], "Attention") end
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Hakkar") end, 60)
		self:ScheduleEvent("bwhakkarld60", "BigWigs_Message", 30, string.format(L["drain_warning"], 60), "Attention")
		self:ScheduleEvent("bwhakkarld45", "BigWigs_Message", 55, string.format(L["drain_warning"], 45), "Attention", true, "Alert")
		self:ScheduleEvent("bwhakkarld30", "BigWigs_Message", 60, string.format(L["drain_warning"], 30), "Urgent", true, "Alert")
		self:ScheduleEvent("bwhakkarld15", "BigWigs_Message", 75, string.format(L["drain_warning"], 15), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["Life Drain"], 90, "Interface\\Icons\\Spell_Shadow_LifeDrain")
	end
end


