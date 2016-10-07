------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Razorgore the Untamed"]
local controller = AceLibrary("Babble-Boss-2.2")["Grethok the Controller"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local eggs

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Razorgore",

	start_trigger = "Intruders have breached",
	start_message = "Razorgore engaged! Mobs in 45sec!Enrage in 15min!",
	start_incsoon = "Mob Spawn in 20sec!",
	start_soon = "Mob Spawn in 10sec!",
	start_verysoon = "Mob Spawn in 5sec!",
	start_mob = "Mob Spawn",
    enragebartext = "Enrage",
	

	mc_trigger = "^([^%s]+) ([^%s]+) afflicted by Mind Exhaustion%.$",
	mc_bar = "Mind Exhaustion: ",
	mcyou = "You",
	mcare = "are",
		
	egg_trigger = "Destroy Egg",
	egg_message = "%d/30 eggs destroyed!",

	phase2_trigger = "Razorgore the Untamed's Warming Flames heals Razorgore the Untamed for .*.",
	phase2_message = "All eggs destroyed, Razorgore loose!",

	mc_cmd = "mindcontrol",
	mc_name = "Mind Control",
	mc_desc = "Warn when players are mind controlled",

	eggs_cmd = "eggs",
	eggs_name = "Count eggs",
	eggs_desc = "Count down the remaining eggs",

	phase_cmd = "phase",
	phase_name = "Phases",
	phase_desc = "Alert on phase 1 and 2",
} end)

------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRazorgore = BigWigs:NewModule(boss)
BigWigsRazorgore.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsRazorgore.enabletrigger = { boss, controller }
BigWigsRazorgore.toggleoptions = { "mc", "eggs", "phase", "bosskill" }
BigWigsRazorgore.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsRazorgore:OnEnable()
	eggs = 0

	--self:RegisterEvent("CHAT_MSG_PLAYER_YELL")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "MC")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "MC")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "MC")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "RazorgoreEgg", 8)
end

------------------------------
--      Event Handlers      --
------------------------------
function BigWigsRazorgore:MC(msg)
	local _,_, pplayer, ptype = string.find(msg, L["mc_trigger"])
	if pplayer then
		if self.db.profile.mc then
			self:TriggerEvent("BigWigs_StartBar", self, L["mc_bar"] .. pplayer, 180, "Interface\\Icons\\Spell_Shadow_Teleport")
		end
	end
end

function BigWigsRazorgore:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["start_trigger"]) then
		if self.db.profile.phase then
		    self:TriggerEvent("BigWigs_StartBar", self, L["enragebartext"], 900, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
			self:TriggerEvent("BigWigs_Message", L["start_message"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["start_mob"], 35, "Interface\\Icons\\Spell_Holy_PrayerOfHealing")
			self:ScheduleEvent("BigWigs_Message", 15, L["start_incsoon"], "Important")
			self:ScheduleEvent("BigWigs_Message", 25, L["start_soon"], "Important")
			self:ScheduleEvent("BigWigs_Message", 30, L["start_verysoon"], "Important")
		end
		eggs = 0
	end
end

function BigWigsRazorgore:CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF(msg)
	if string.find(msg, L["egg_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "RazorgoreEgg "..tostring(eggs + 1))
	end
end

function BigWigsRazorgore:BigWigs_RecvSync(sync, rest)
	if sync ~= "RazorgoreEgg" or not rest then return end
	rest = tonumber(rest)

	if rest == (eggs + 1) then
		eggs = eggs + 1
		if not self.db.profile.eggs then
			self:TriggerEvent("BigWigs_Message", string.format(L["egg_message"], eggs), "Positive")
		end

		if eggs == 30 and self.db.profile.phase then
			self:TriggerEvent("BigWigs_Message", L["phase2_message"], "Important")
		end
	end
end


