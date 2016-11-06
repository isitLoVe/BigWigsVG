------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priest Venoxis"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local prior

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Venoxis",

	renew_cmd = "renew",
	renew_name = "Renew Alert",
	renew_desc = "Warn for Renew",

	phase_cmd = "phase",
	phase_name = "Phase 2 Alert",
	phase_desc = "Warn for Phase 2",
	
	poisonyou_cmd = "poisonyou",
	poisonyou_name = "Poison Cloud on You Alert",
	poisonyou_desc = "Warn if you are standing in a poison cloud",

	poisonother_cmd = "poisonother",
	poisonother_name = "Poison Cloud on Others Alert",
	poisonother_desc = "Warn if others are standing in a poison cloud",
	
	renew_trigger = "High Priest Venoxis gains Renew.",
	phase2_trigger = "Let the coils of hate unfurl!",

	renew_message = "Renew!",
	phase2_message = "Incoming phase 2 - poison clouds spawning!",
	
	poison_trigger = "^([^%s]+) ([^%s]+) afflicted by Poison Cloud%.$",
	poison_trigger_gone = "Toxin",
	
	poison_bar = "Poison Cloud",
	poison_message = "Poison Cloud",

	poison_other_warn = " is in a poison cloud!",
	poison_you_warn = "You are in the poison cloud!",
	runwarn = "Run from Poison Cloud!",
	
	you 		= "You",
	are 		= "are",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsVenoxis = BigWigs:NewModule(boss)
BigWigsVenoxis.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsVenoxis.enabletrigger = boss
BigWigsVenoxis.toggleoptions = {"renew", "phase", "poisonyou", "poisonother", "bosskill"}
BigWigsVenoxis.revision = tonumber(string.sub("$Revision: 19011 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsVenoxis:OnEnable()
	started = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "PeriodicEvent")
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")
end

------------------------------
--      Events              --
------------------------------

function BigWigsVenoxis:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if self.db.profile.renew and msg == L["renew_trigger"] then
		self:TriggerEvent("BigWigs_Message", L["renew_message"], "Urgent")
	end
end

function BigWigsVenoxis:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.phase and string.find(msg, L["phase2_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["phase2_message"], "Attention")
	end
end

function BigWigsVenoxis:PeriodicEvent( msg )
	if string.find(arg1, L["poison_trigger"]) then
		local _,_, pl, ty = string.find(arg1, L["poison_trigger"])
		if (pl and ty) then
			if self.db.profile.poisonyou and pl == L["you"] and ty == L["are"] then
				BigWigsOnScreenIcons:Direction("Run")
				--self:TriggerEvent("BigWigs_Message", L["poison_you_warn"], "Personal", true, "Alarm")
				--self:TriggerEvent("BigWigs_Message", UnitName("player") .. L["poison_other_warn"], "Important", nil, nil, true)
				self:TriggerEvent("BigWigs_StartBar", self, L["poison_bar"], 15, "Interface\\Icons\\Spell_Nature_NatureTouchDecay")
			elseif self.db.profile.poisonother then
				--self:TriggerEvent("BigWigs_Message", pl .. L["poison_other_warn"], "Important")
				self:TriggerEvent("BigWigs_SendTell", pl, L["poison_you_warn"])
				self:TriggerEvent("BigWigs_StartBar", self, L["poison_bar"], 15, "Interface\\Icons\\Spell_Nature_NatureTouchDecay")
			end
		end
	end
end

function BigWigsVenoxis:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["poison_trigger_gone"]) then
		BigWigsOnScreenIcons:Runstop()
	end
end

function BigWigsVenoxis:BigWigs_RecvSync(sync, rest)	
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if BigWigs:CheckYourPrivilege(UnitName("player")) then
			if klhtm.isloaded and klhtm.isenabled then
				klhtm.net.sendmessage("targetbw " ..boss)
			end
		end
	end
end
