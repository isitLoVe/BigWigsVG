------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Broodlord Lashlayer"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Broodlord",

	trigger1 = "^([^%s]+) ([^%s]+) afflicted by Mortal Strike",
	triggerms = "afflicted by Mortal Strike",
	trigger2 = "afflicted by Blast Wave",

	you = "You",
	are = "are",

	warn1 = "Mortal Strike on you!",
	warn2 = "Mortal Strike on %s!",
        warn3 = "Blast Wave in 3sec!",

        wavebartext = "Blast Wave",

	youms_cmd = "youms",
	youms_name = "Mortal strike on you alert",
	youms_desc = "Warn when you get mortal strike",

	elsems_cmd = "elsems",
	elsems_name = "Mortal strike on others alert",
	elsems_desc = "Warn when someone else gets mortal strike",

	wavebar_cmd = "wavebar",
	wavebar_name = "Blast Wave bar",
	wavebar_desc = "Shows a bar with the possible Blast Wave cooldown",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBroodlord = BigWigs:NewModule(boss)
BigWigsBroodlord.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsBroodlord.enabletrigger = boss
BigWigsBroodlord.toggleoptions = {"youms", "elsems", "wavebar", "bosskill"}
BigWigsBroodlord.revision = tonumber(string.sub("$Revision: 19008 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsBroodlord:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBroodlord:Event(msg)
	if string.find(msg, L["triggerms"]) then
		local _, _, EPlayer, EType = string.find(msg, L["trigger1"])
		if (EPlayer and EType) then
			if EPlayer == L["you"] and EType == L["are"] and self.db.profile.youms then
				self:TriggerEvent("BigWigs_Message", L["warn1"], "Personal",  true, "Alert")
				self:TriggerEvent("BigWigs_StartBar", self, string.format(L["warn2"], UnitName("player")), 5, "Interface\\Icons\\Ability_Warrior_SavageBlow")
			elseif self.db.profile.elsems then
				self:TriggerEvent("BigWigs_Message", string.format(L["warn2"], EPlayer), "Attention", true, "Alert")
				self:TriggerEvent("BigWigs_StartBar", self, string.format(L["warn2"], EPlayer), 5, "Interface\\Icons\\Ability_Warrior_SavageBlow")
			end
		end
	elseif string.find(msg, L["trigger2"]) and self.db.profile.wavebar then
		        self:TriggerEvent("BigWigs_StartBar", self, L["wavebartext"], 11, "Interface\\Icons\\Spell_Holy_Excorcism_02")
		        self:ScheduleEvent("BigWigs_Message", 8, L["warn3"], "Urgent", true, "Alarm")
	end
end


function BigWigsBroodlord:Prehide()
        self:ScheduleEvent("bwbroodprehide", self.Hide, 4, self)
end

function BigWigsBroodlord:Hide()
        Powa_Frames[5]:Hide();
end
