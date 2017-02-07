------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Anubisath Guardian"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Guardian",

	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for summoned adds",

	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn for plague on you",

	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn for plague on others",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",

	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for incoming explosion",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",

	explodetrigger = "Anubisath Guardian gains Explode.",
	explodewarn = "Exploding!",
	enragetrigger = "Anubisath Guardian gains Enrage.",
	enragewarn = "Enraged!",
	summonguardtrigger = "Anubisath Guardian casts Summon Anubisath Swarmguard.",
	summonguardwarn = "Swarmguard Summoned",
	summonwarriortrigger = "Anubisath Guardian casts Summon Anubisath Warrior.",
	summonwarriorwarn = "Warrior Summoned",
	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plaguewarnyou = "You have the Plague!",
	plagueyou = "You",
	plagueare = "are",	
	
	summonbar = "Summon adds",
	plaguebar = "Plague on ",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGuardians = BigWigs:NewModule(boss)
BigWigsGuardians.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsGuardians.enabletrigger = boss
BigWigsGuardians.toggleoptions = {"summon", "explode", "enrage", -1, "plagueyou", "plagueother", "icon", "bosskill"}
BigWigsGuardians.revision = tonumber(string.sub("$Revision: 19013 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGuardians:OnEnable()
	started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckPlague")
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "GuardianEnrage", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "GuardianExplode", 10)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsGuardians:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, boss) then
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsGuardians:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.summon then
			self:TriggerEvent("BigWigs_StartBar", self, L["summonbar"], 4, "Interface\\Icons\\Spell_Nature_MirrorImage")
			self:ScheduleEvent("BigWigs_StartBar", 4, self, L["summonbar"], 60, "Interface\\Icons\\Spell_Nature_MirrorImage")
			self:ScheduleEvent("BigWigs_StartBar", 64, self, L["summonbar"], 60, "Interface\\Icons\\Spell_Nature_MirrorImage")
		end
	elseif sync == "GuardianExplode" and self.db.profile.explode then
		self:TriggerEvent("BigWigs_Message", L["explodewarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["explodewarn"], 6, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		--self:TriggerEvent("BigWigs_StopBar", self, L["summonbar"])
	elseif sync == "GuardianEnrage" and self.db.profile.enrage then
		self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important")
		--self:TriggerEvent("BigWigs_StopBar", self, L["summonbar"])
	end
end

function BigWigsGuardians:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if msg == L["explodetrigger"] then 
		self:TriggerEvent("BigWigs_SendSync", "GuardianExplode")
	elseif msg == L["enragetrigger"] then 
		self:TriggerEvent("BigWigs_SendSync", "GuardianEnrage")
	end
end

function BigWigsGuardians:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if self.db.profile.summon and msg == L["summonguardtrigger"] then 
		self:TriggerEvent("BigWigs_Message", L["summonguardwarn"], "Attention")
	elseif self.db.profile.summon and msg == L["summonwarriortrigger"] then 
		self:TriggerEvent("BigWigs_Message", L["summonwarriorwarn"], "Attention")
	end
end

function BigWigsGuardians:CheckPlague( msg )
	local _,_, player, type = string.find(msg, L["plaguetrigger"])
	if player and type then
		if self.db.profile.plagueyou and player == L["plagueyou"] and type == L["plagueare"] then
			self:TriggerEvent("BigWigs_Message", L["plaguewarnyou"], "Personal", true)
			self:TriggerEvent("BigWigs_Message", UnitName("player") .. L["plaguewarn"], "Attention", nil, nil, true )
			self:TriggerEvent("BigWigs_StartBar", self, L["plaguebar"] .. player, 40, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		elseif self.db.profile.plagueother then
			self:TriggerEvent("BigWigs_Message", player .. L["plaguewarn"], "Attention")
			self:TriggerEvent("BigWigs_SendTell", player, L["plaguewarnyou"])
			self:TriggerEvent("BigWigs_StartBar", self, L["plaguebar"] .. player, 40, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		end

		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", player)
		end
	end
end


