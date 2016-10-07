------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Moam"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Moam",

	adds_cmd = "adds",
	adds_name = "Mana Fiend Alert",
	adds_desc = "Warn for Mana fiends",

	paralyze_cmd = "paralyze",
	paralyze_name = "Paralyze Alert",
	paralyze_desc = "Warn for Paralyze",

	starttrigger = "%s senses your fear.",
	startwarn = "Moam Engaged! 90 Seconds until adds!",
	addsbar = "Adds",
	addsincoming = "Mana Fiends incoming in %s seconds!",
	addstrigger = "%s drains your mana and turns to stone.",
	addswarn = "Mana Fiends spawned! Moam Paralyzed for 90 seconds!",
	paralyzebar = "Paralyze",
	returnincoming = "Moam unparalyzed in %s seconds!",
	returntrigger = "^Energize fades from Moam%.$",
	returnwarn = "Moam unparalyzed! 90 seconds until Mana Fiends!",	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMoam = BigWigs:NewModule(boss)
BigWigsMoam.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsMoam.enabletrigger = boss
BigWigsMoam.toggleoptions = {"adds", "paralyze", "bosskill"}
BigWigsMoam.revision = tonumber(string.sub("$Revision: 17083 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMoam:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath" )
end

function BigWigsMoam:PLAYER_REGEN_DISABLED()
	if UnitExists("target") and UnitName("target") == "Moam" and UnitExists("targettarget") then
		self:Moamstart()
		return
	end
	local num = GetNumRaidMembers()
	for i = 1, num do
		local raidUnit = string.format("raid%starget", i)
		if UnitExists(raidUnit) and UnitName(raidUnit) == "Moam" and UnitExists(raidUnit.."target") then
			self:Moamstart()
			return
		end
	end
end

function BigWigsMoam:Moamstart()
	if self.db.profile.adds then
		self:ScheduleEvent("BigWigs_Message", 30, format(L["addsincoming"], 60), "Attention")
		self:ScheduleEvent("BigWigs_Message", 60, format(L["addsincoming"], 30), "Attention")
		self:ScheduleEvent("BigWigs_Message", 75, format(L["addsincoming"], 15), "Urgent")
		self:ScheduleEvent("BigWigs_Message", 85, format(L["addsincoming"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["addsbar"], 90, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
end
		if self.db.profile.paralyze then
			self:ScheduleEvent("BigWigs_Message", 120, format(L["returnincoming"], 60), "Attention")
			self:ScheduleEvent("BigWigs_Message", 150, format(L["returnincoming"], 30), "Attention")
			self:ScheduleEvent("BigWigs_Message", 165, format(L["returnincoming"], 15), "Urgent")
			self:ScheduleEvent("BigWigs_Message", 175, format(L["returnincoming"], 5), "Important")
			self:ScheduleEvent("BigWigs_StartBar", 90, self, L["paralyzebar"], 90, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
end
	end

function BigWigsMoam:AddsStart()
	if self.db.profile.adds then
		self:ScheduleEvent("BigWigs_Message", 30, format(L["addsincoming"], 60), "Attention")
		self:ScheduleEvent("BigWigs_Message", 60, format(L["addsincoming"], 30), "Attention")
		self:ScheduleEvent("BigWigs_Message", 75, format(L["addsincoming"], 15), "Urgent")
		self:ScheduleEvent("BigWigs_Message", 85, format(L["addsincoming"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["addsbar"], 90, "Interface\\Icons\\Spell_Shadow_CurseOfTounges") 
	end
end

function BigWigsMoam:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["starttrigger"] then
		if self.db.profile.adds then self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important") end
		self:AddsStart()
	elseif msg == L["addstrigger"] then
		if self.db.profile.adds then
			self:TriggerEvent("BigWigs_Message", L["addswarn"], "Important")
		end
		if self.db.profile.paralyze then
			self:ScheduleEvent("BigWigs_Message", 30, format(L["returnincoming"], 60), "Attention")
			self:ScheduleEvent("BigWigs_Message", 60, format(L["returnincoming"], 30), "Attention")
			self:ScheduleEvent("BigWigs_Message", 75, format(L["returnincoming"], 15), "Urgent")
			self:ScheduleEvent("BigWigs_Message", 85, format(L["returnincoming"], 5), "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["paralyzebar"], 90, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		end
	end
end

function BigWigsMoam:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if string.find( msg, L["returntrigger"]) then
		if self.db.profile.paralyze then self:TriggerEvent("BigWigs_Message", L["returnwarn"], "Important") end
		self:AddsStart()
	end
end


