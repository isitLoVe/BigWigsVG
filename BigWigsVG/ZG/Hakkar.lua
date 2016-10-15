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
	mindcontrol_trigger_vg = "(.*) (.*) afflicted by Will of Hakkar",

	you = "You",
	are = "are",

	flee = "Fleeing will do you no good, mortals!",

	-- Warnings and bar texts
	start_message = "Hakkar engaged - 90sec to drain - 10min to enrage!",
	start_message_vg = "Hakkar engaged - 10min to enrage!",
	drain_warning = "%d sec to Life Drain!",
	drain_message = "Life Drain - 90sec to next!",

	mindcontrol_message = "%s is mindcontrolled!",
	mindcontrol_bar = "MC: %s",
	
	blood_trigger = "(.*) (.*) afflicted by Corrupted Blood",
	blood_message = "Corrupted Blood in ~5sec",
	blood_bar = "Corrupted Blood",

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
	
	blood_cmd = "blood",
	blood_name = "Corrupted Blood Alerts",
	blood_desc = "Alert when Corrupted Blood is casted.",

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
BigWigsHakkar.toggleoptions = { "drain", "enrage", -1, "mc", "icon", "blood", "bosskill" }
BigWigsHakkar.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsHakkar:OnEnable()
	self.prior = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "PeriodicEvent")

	--self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "HakkarBlood", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "HakkarMC", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsHakkar:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["engage_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["start_message_vg"], "Important")
		if self.db.profile.enrage then self:TriggerEvent("BigWigs_StartBar", self, L["Enrage"], 600, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy") end
		if self.db.profile.blood then
			self:TriggerEvent("BigWigs_StartBar", self, L["blood_bar"], 25, "Interface\\Icons\\Spell_Shadow_LifeDrain")
			self:ScheduleEvent("BigWigs_Message", 20, L["blood_message"], "Urgent")
			end
		--commented out till the fight is blizzlike
		--self:BeginTimers(true)
	elseif string.find(msg, L["flee"]) then
		self:TriggerEvent("BigWigs_RebootModule", self)
	end
end

function BigWigsHakkar:PeriodicEvent(msg)
	local _,_, mcplayer, mctype = string.find(msg, L["mindcontrol_trigger_vg"])
	if mcplayer then
		if mcplayer == L["you"] then
			mcplayer = UnitName("player")
		end
		self:TriggerEvent("BigWigs_SendSync", "HakkarMC "..mcplayer)
	end
	
	if string.find(msg, L["blood_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "HakkarBlood")
	end
end

function BigWigsHakkar:BigWigs_RecvSync(sync, rest)
	if sync == "HakkarBlood" then
		if self.db.profile.blood then
			self:ScheduleEvent("BigWigs_Message", 20, L["blood_message"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["blood_bar"], 25, "Interface\\Icons\\Spell_Shadow_LifeDrain")
		end
	elseif sync == "HakkarMC" then
		if self.db.profile.mc then
			self:TriggerEvent("BigWigs_Message", string.format(L["mindcontrol_message"], rest), "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["mindcontrol_bar"], rest), 25, "Interface\\Icons\\Spell_Shadow_ShadowWordDominate")
		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", rest)
		end
	end
end

--[[commented out till the fight is blizzlike
function BigWigsHakkar:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if not self.prior and string.find(msg, L["drain_trigger"]) then
		self.prior = true
		self:BeginTimers()
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
]]

