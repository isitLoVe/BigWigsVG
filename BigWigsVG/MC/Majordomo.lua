------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Majordomo Executus"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local Texture1 = "Interface\\Icons\\Spell_Frost_FrostShock"
local Texture2 = "Interface\\Icons\\Spell_Shadow_AntiShadow"
local aura

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	disabletrigger = "Impossible! Stay your attack, mortals... I submit! I submit!",

	triggercast = "Flamewaker Healer begins to cast",
	healbar = "Heal",
	healwarn = "Healing!",

	trigger1 = "gains Magic Reflection",
	trigger2 = "gains Damage Shield",
	trigger3 = "Magic Reflection fades",
	trigger4 = "Damage Shield fades",

	warn1 = "Magic Reflection for 10 seconds!",
	warn2 = "Damage Shield for 10 seconds!",
	warn3 = "5 seconds until powers!",
	warn4 = "Magic Reflection down!",
	warn5 = "Damage Shield down!",
	bosskill = "Majordomo Executus has been defeated!",

	bar1text = "Magic Reflection",
	bar2text = "Damage Shield",
	bar3text = "New powers",

	cmd = "Majordomo",
	
	magic_cmd = "magic",
	magic_name = "Magic Reflection alert",
	magic_desc = "Warn for Magic Reflection",
	
	dmg_cmd = "dmg",
	dmg_name = "Damage Shields alert",
	dmg_desc = "Warn for Damage Shields",
	
	adds_cmd = "adds",
	adds_name = "Majordomo's adds",
	adds_desc = "Mods for Majordomo's adds",
	
	healerdeadmsg = "%d/4 Flamewaker Healer dead!",
	elitedeadmsg = "%d/4 Flamewaker Elite dead!",
	
	triggerhealerdead = "Flamewaker Healer",
	triggerelitedead = "Flamewaker Elite",
	
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMajordomo = BigWigs:NewModule(boss)
BigWigsMajordomo.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsMajordomo.enabletrigger = boss
BigWigsMajordomo.toggleoptions = {"magic", "dmg", "adds", "bosskill"}
BigWigsMajordomo.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMajordomo:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	aura = nil
	self.healerdead = 0
	self.elitedead = 0
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:TriggerEvent("BigWigs_ThrottleSync", "MajoHealerDead", 2)
	self:TriggerEvent("BigWigs_ThrottleSync", "MajoEliteDead", 2)
end

function BigWigsMajordomo:VerifyEnable(unit)
	return UnitCanAttack("player", unit)
end

------------------------------
--      Event Handlers      --
------------------------------
function BigWigsMajordomo:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if string.find(msg, L["triggerhealerdead"]) then
		self:TriggerEvent("BigWigs_SendSync", "MajoHealerDead "..tostring(self.healerdead + 1) )
	elseif string.find(msg, L["triggerelitedead"]) then
		self:TriggerEvent("BigWigs_SendSync", "MajoEliteDead "..tostring(self.elitedead + 1) )
	end
end

function BigWigsMajordomo:BigWigs_RecvSync( sync, rest )
	if sync == "MajoHealerDead" and rest then
		rest = tonumber(rest)
		if not rest then return	end
		if rest == (self.healerdead + 1) then
			self.healerdead = self.healerdead + 1
			if self.db.profile.adds then
				self:TriggerEvent("BigWigs_Message", string.format(L["healerdeadmsg"], self.healerdead), "Positive")
			end
			if self.healerdead == 4 then
				self.healerdead = 0 -- reset counter
            end
		end
	elseif sync == "MajoEliteDead" and rest then
		rest = tonumber(rest)
		if not rest then return end
		if rest == (self.elitedead + 1) then
			self.elitedead = self.elitedead + 1
			if self.db.profile.adds then
				self:TriggerEvent("BigWigs_Message", string.format(L["elitedeadmsg"], self.elitedead), "Positive")
			end
			if self.elitedead == 4 then
				self.elitedead = 0 -- reset counter
            end
		end
	end
end

function BigWigsMajordomo:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L["disabletrigger"]) then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], self:ToString()), "Bosskill", nil, "Victory") end
                --BigWigs:Flawless()
		self.core:ToggleModuleActive(self, false)
	end
end

--[[ Flamewaker Healer have no heal cast
function BigWigsMajordomo:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["triggercast"]) then
		self:TriggerEvent("BigWigs_Message", L["healwarn"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["healbar"], 2, "Interface\\Icons\\Spell_Holy_Heal")
	end
end
]]

function BigWigsMajordomo:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if (string.find(msg, L["trigger1"]) and not aura and self.db.profile.magic) then self:NewPowers(1)
	elseif (string.find(msg, L["trigger2"]) and not aura and self.db.profile.dmg) then self:NewPowers(2) end
end

function BigWigsMajordomo:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if ((string.find(msg, L["trigger3"]) or string.find(msg, L["trigger4"])) and aura) then
		self:TriggerEvent("BigWigs_Message", aura == 1 and L["warn4"] or L["warn5"], "Attention")
		aura = nil
	end
end

function BigWigsMajordomo:NewPowers(power)
	aura = power
	self:TriggerEvent("BigWigs_Message", power == 1 and L["warn1"] or L["warn2"], "Important")
	self:TriggerEvent("BigWigs_StartBar", self, L["bar3text"], 30, "Interface\\Icons\\Spell_Frost_Wisp")
	self:TriggerEvent("BigWigs_StartBar", self, power == 1 and L["bar1text"] or L["bar2text"], 10, power == 1 and Texture1 or Texture2)
	self:ScheduleEvent("BigWigs_Message", 25, L["warn3"], "Urgent")
end

