------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Moam"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local maxmana = 26200

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

	trample_cmd = "trample",
	trample_name = "Trample Alert",
	trample_desc = "Warn for Trample",
	
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
	
	mediummana = "Moat at 50% mana",
	highmana = "Moat at 75% mana, explosion soon",
	
	explode = "BOOM!",
	
	trample_trigger = "Trample",
	trample_bar = "Trample",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMoam = BigWigs:NewModule(boss)
BigWigsMoam.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsMoam.enabletrigger = boss
BigWigsMoam.toggleoptions = {"adds", "paralyze", "bosskill"}
BigWigsMoam.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMoam:OnEnable()
	started = nil
	--self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	--self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath" )
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "DamageEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "DamageEvent")
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("UNIT_MANA")

	self:TriggerEvent("BigWigs_ThrottleSync", "MoamManaMedium", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "MoamManaHigh", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "MoamManaFull", 5)
end

function BigWigsMoam:BigWigs_RecvSync( sync, rest )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		if self.db.profile.adds then self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important") end
		if self.db.profile.adds then
			self:ScheduleEvent("BigWigs_Message", 75, format(L["addsincoming"], 15), "Urgent")
			self:ScheduleEvent("BigWigs_Message", 85, format(L["addsincoming"], 5), "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["addsbar"], 90, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		end
	elseif sync == "MoamManaMedium" then
		if self.db.profile.paralyze then
			self:TriggerEvent("BigWigs_Message", L["mediummana"], "Attention")
		end
	elseif sync == "MoamManaHigh" then
		if self.db.profile.paralyze then
			self:TriggerEvent("BigWigs_Message", L["highmana"], "Important")
		end
	elseif sync == "MoamManaFull" then
		if self.db.profile.paralyze then
			self:TriggerEvent("BigWigs_Message", L["explode"], "Urgent")
			--self:ScheduleEvent("BigWigs_Message", 75, format(L["addsincoming"], 15), "Urgent")
			--self:ScheduleEvent("BigWigs_Message", 85, format(L["addsincoming"], 5), "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["addsbar"], 140, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
		end
	end
end

function BigWigsMoam:UNIT_MANA( msg )
	if UnitName(msg) == boss then
		local mana = UnitMana(msg)
		if mana > maxmana * 0.50 and mana < maxmana * 0.55 then
			self:TriggerEvent("BigWigs_SendSync", "MoamManaMedium")
		elseif mana > maxmana * 0.75 and mana < maxmana * 0.80 then
			self:TriggerEvent("BigWigs_SendSync", "MoamManaHigh")
			
		elseif mana > maxmana * 0.99 then --backup if eruption is out ranged
			self:TriggerEvent("BigWigs_SendSync", "MoamManaFull")
		end
	end
end

function BigWigsMoam:CHAT_MSG_SPELL_AURA_GONE_OTHER( msg )
	if string.find(msg, L["returntrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "MoamManaFull")
	end
end
function BigWigsMoam:DamageEvent( msg )
	if string.find(msg, L["trample_trigger"]) then
		self:TriggerEvent("BigWigs_StartBar", self, L["trample_bar"], 15, "Interface\\Icons\\Spell_Nature_NaturesWrath")
	end
end