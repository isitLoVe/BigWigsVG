------------------------------
--      Are you local??     --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Bloodlord Mandokir"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local whirlwind_counter

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Mandokir",

	you_cmd = "you",
	you_name = "You're being watched alert",
	you_desc = "Warn when you're being watched",

	other_cmd = "other",
	other_name = "Others being watched alert",
	other_desc = "Warn when others are being watched",

	icon_cmd = "icon",
	icon_name = "Raid icon and whisper on watched",
	icon_desc = "Puts a raid icon and whispers the watched person",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Timer for Whirlwind",
	whirlwind_desc = "Warns you for upcoming Whirlwind",

	watch_trigger = "([^%s]+)! I'm watching you!$",
	watch_trigger_vg = "I'm keeping my eye on you, ([^%s]+)!",
	enrage_trigger = "goes into a rage after seeing his raptor fall in battle!$",

	watched_warning_self = "You are being watched!",
	watched_warning_other = "%s is being watched!",
	watched_bar_self = "You are being watched!",
	watched_bar_other = "%s is being watched!",
	
	whirlwind_trigger = "gains Whirlwind",
	whirlwind_bar = "Whirlwind",
	
	enraged_message = "Ohgan down! Mandokir enraged!",	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMandokir = BigWigs:NewModule(boss)
BigWigsMandokir.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsMandokir.enabletrigger = boss
BigWigsMandokir.toggleoptions = {"you", "other", "icon", "whirlwind", "bosskill"}
BigWigsMandokir.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMandokir:OnEnable()
	whirlwind_counter = 0
	started = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")
end

------------------------------
--      Events              --
------------------------------

function BigWigsMandokir:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		
		if self.db.profile.whirlwind then
			self:TriggerEvent("BigWigs_StartBar", self, L["whirlwind_bar"], 20, "Interface\\Icons\\Ability_Whirlwind")
		end
	end
end

function BigWigsMandokir:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["enrage_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["enraged_message"], "Urgent")
	end
end

function BigWigsMandokir:CHAT_MSG_MONSTER_YELL(msg)
	local _,_, n = string.find(msg, L["watch_trigger_vg"])
	if n then
		if n == UnitName("player") and self.db.profile.you then
	        BigWigsThaddiusArrows:Direction("RunZG")
			self:TriggerEvent("BigWigs_Message", L["watched_warning_self"], "Personal", true, "Alarm")
			self:TriggerEvent("BigWigs_Message", string.format(L["watched_warning_other"], UnitName("player")), "Attention", nil, nil, true)
			--self:TriggerEvent("BigWigs_StartBar", self, string.format(L["watched_bar_self"], UnitName("player")), 20, "Interface\\Icons\\Spell_Shadow_Charm")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["watched_bar_other"], UnitName("player")), 20, "Interface\\Icons\\Spell_Shadow_Charm")
		elseif self.db.profile.other then
			self:TriggerEvent("BigWigs_Message", string.format(L["watched_warning_other"], n), "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["watched_bar_other"], UnitName("player")), 20, "Interface\\Icons\\Spell_Shadow_Charm")
			
			if self.db.profile.icon then
				self:TriggerEvent("BigWigs_SendTell", n, L["watched_warning_self"])
			end

		end
		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", n)
		end
	end
end

function BigWigsMandokir:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(msg, L["whirlwind_trigger"]) then
	
		whirlwind_counter = whirlwind_counter + 1 
		
		if self.db.profile.whirlwind then
			--check if whirlwind counter is even (VG Whirlwind: 20, ~34, ~26, ~34, ~26, ...)
			if math.mod(whirlwind_counter, 2) == 0 then
				self:TriggerEvent("BigWigs_StartBar", self, L["whirlwind_bar"], 26, "Interface\\Icons\\Ability_Whirlwind")
			else
				self:TriggerEvent("BigWigs_StartBar", self, L["whirlwind_bar"], 34, "Interface\\Icons\\Ability_Whirlwind")
			end
		end
	end
end


