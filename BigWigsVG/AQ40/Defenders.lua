------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Anubisath Defender"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started = nil
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Defender",

	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn if you got the Plague",

	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn if others got the Plague",

	plaguebar = "Plague on ",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",

	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for Explode",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for add summons",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",

	explodetrigger = "Anubisath Defender gains Explode.",
	explodewarn = "Exploding!",
	enragetrigger = "Anubisath Defender gains Enrage.",
	enragewarn = "Enraged!",
	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plagueyouwarn = "You have the plague!",
	plagueyou = "You",
	plagueare = "are",
	thunderclaptrigger = "^Anubisath Defender's Thunderclap hits ([^%s]+) for %d+%.",
	thunderclapwarn = "Thunderclap!",
	summonbar = "Summon adds",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsDefenders = BigWigs:NewModule(boss)
BigWigsDefenders.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsDefenders.enabletrigger = boss
BigWigsDefenders.toggleoptions = { "plagueyou", "plagueother", "icon", -1, "thunderclap", "explode", "enrage", "summon", "bosskill"}
BigWigsDefenders.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsDefenders:OnEnable()
	started = nil

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckPlague")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Thunderclap")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Thunderclap")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Thunderclap")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "DefenderEnrage", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "DefenderExplode", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "DefenderThunderclap", 6)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsDefenders:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, boss) then
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsDefenders:BigWigs_RecvSync(sync, rest, nick)
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
	elseif sync == "DefenderExplode" and self.db.profile.explode then
		self:TriggerEvent("BigWigs_Message", L["explodewarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["explodewarn"], 6, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		--self:TriggerEvent("BigWigs_StopBar", self, L["summonbar"])
	elseif sync == "DefenderEnrage" and self.db.profile.enrage then
		self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important")
		--self:TriggerEvent("BigWigs_StopBar", self, L["summonbar"])
	elseif sync == "DefenderThunderclap" and self.db.profile.thunderclap then
		self:TriggerEvent("BigWigs_Message", L["thunderclapwarn"], "Important")
	end
end

function BigWigsDefenders:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if msg == L["explodetrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "DefenderExplode")
	elseif msg == L["enragetrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "DefenderEnrage")
	end
end

function BigWigsDefenders:CheckPlague(msg)
	local _,_, pplayer, ptype = string.find(msg, L["plaguetrigger"])
	if pplayer then
		if self.db.profile.plagueyou and pplayer == L["plagueyou"] then
			self:TriggerEvent("BigWigs_Message", L["plagueyouwarn"], "Personal", true)
			self:TriggerEvent("BigWigs_Message", UnitName("player") .. L["plaguewarn"], "Attention", nil, nil, true)
			self:TriggerEvent("BigWigs_StartBar", self, L["plaguebar"] .. pplayer, 40, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		elseif self.db.profile.plagueother then
			self:TriggerEvent("BigWigs_Message", pplayer .. L["plaguewarn"], "Attention")
			self:TriggerEvent("BigWigs_SendTell", pplayer, L["plagueyouwarn"])
			self:TriggerEvent("BigWigs_StartBar", self, L["plaguebar"] .. pplayer, 40, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		end

		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", pplayer)
		end
	end
end

function BigWigsDefenders:Thunderclap(msg)
	if string.find(msg, L["thunderclaptrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "DefenderThunderclap")
	end
end


