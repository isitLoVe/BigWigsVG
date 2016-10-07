------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Onyxia"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Onyxia",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath alert",
	deepbreath_desc = "Warn when Onyxia begins to cast Deep Breath ",

	phase2_cmd = "phase2",
	phase2_name = "Phase 2 alert",
	phase2_desc = "Warn for Phase 2",

	phase3_cmd = "phase3",
	phase3_name = "Phase 3 alert",
	phase3_desc = "Warn for Phase 3",

	onyfear_cmd = "onyfear",
	onyfear_name = "Fear",
	onyfear_desc = "Warn for Bellowing Roar in phase 3",

	trigger1 = "Onyxia takes in a deep breath...",
	trigger2 = "from above",
	trigger3 = "It seems you'll need another lesson",
	trigger4 = "Onyxia begins to cast Bellowing Roar.",

	warn1 = "Deep Breath incoming!",
	warn2 = "Phase 2 incoming!",
	warn3 = "Phase 3 incoming!",
	warn4 = "Fear in 1.5sec!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsOnyxia = BigWigs:NewModule(boss)
BigWigsOnyxia.zonename = AceLibrary("Babble-Zone-2.2")["Onyxia's Lair"]
BigWigsOnyxia.enabletrigger = boss
BigWigsOnyxia.toggleoptions = {"deepbreath", "phase2", "phase3", "onyfear", "bosskill"}
BigWigsOnyxia.revision = tonumber(string.sub("$Revision: 16941 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsOnyxia:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsOnyxia:CHAT_MSG_MONSTER_EMOTE(msg)
	if (msg == L["trigger1"]) then
		if self.db.profile.deepbreath then self:TriggerEvent("BigWigs_Message", L["warn1"], "Important", true, "Alert") end
	end
end

function BigWigsOnyxia:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L["trigger1"]) then
		if self.db.profile.deepbreath then self:TriggerEvent("BigWigs_Message", L["warn1"], "Important", true, "Alert") end
	elseif (string.find(msg, L["trigger2"])) then
		if self.db.profile.phase2 then self:TriggerEvent("BigWigs_Message", L["warn2"], "Urgent") end
	elseif (string.find(msg, L["trigger3"])) then
		if self.db.profile.phase3 then self:TriggerEvent("BigWigs_Message", L["warn3"], "Urgent", true, "Alert") end
	end
end

function BigWigsOnyxia:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["trigger4"] and self.db.profile.onyfear then
		self:TriggerEvent("BigWigs_Message", L["warn4"], "Important", true, "Alert")
	end
end
