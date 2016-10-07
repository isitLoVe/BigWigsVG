------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Patchwerk"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Patchwerk",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	debuff_cmd = "Debuff",
	debuff_name = "Deuff Alert",
	debuff_desc = "Notify on Debuffs Fading",
	
	buff_cmd = "buff",
	buff_name = "Buff Alert",
	buff_desc = "Notify on Buffs Fading",
	
	enragetrigger = "%s goes into a berserker rage!",

	Sundertrigger	= "Sunder Armor",
	CoEtrigger	= "Curse of the Elements",
	CoStrigger	= "Curse of Shadow",
	CoRtrigger	= "Curse of Recklessness",
	Firevulntrigger	= "Fire Vulnerability",
	FFiretrigger	= "Faerie Fire",
	Stoneshieldtrigger	= "Greater Stoneshield",

	enragewarn = "Enrage!",
	starttrigger = "Patchwerk",
	starttrigger1 = "Patchwerk want to play!",
	starttrigger2 = "Kel'thuzad make Patchwerk his avatar of war!",
	startwarn = "Patchwerk Engaged! Enrage in 7 minutes!",
	enragebartext = "Enrage",
	warn1 = "Enrage in 5 minutes",
	warn2 = "Enrage in 3 minutes",
	warn3 = "Enrage in 90 seconds",
	warn4 = "Enrage in 60 seconds",
	warn5 = "Enrage in 30 seconds",
	warn6 = "Enrage in 10 seconds",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsPatchwerk = BigWigs:NewModule(boss)
BigWigsPatchwerk.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsPatchwerk.enabletrigger = boss
BigWigsPatchwerk.toggleoptions = {"enrage", "buff", "debuff", "bosskill"}
BigWigsPatchwerk.revision = tonumber(string.sub("$Revision: 15709 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsPatchwerk:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

function BigWigsPatchwerk:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["Sundertrigger"]) and (UnitClass("player") == "Warrior") then
	        BigWigsThaddiusArrows:Direction("Sunder")
	elseif string.find(msg, L["CoEtrigger"]) and (UnitClass("player") == "Warlock") then
	        BigWigsThaddiusArrows:Direction("CoE")
	elseif string.find(msg, L["CoStrigger"]) and (UnitClass("player") == "Warlock") then
	        BigWigsThaddiusArrows:Direction("CoS")
	elseif string.find(msg, L["CoRtrigger"]) and (UnitClass("player") == "Warlock") then
	        BigWigsThaddiusArrows:Direction("CoR")
	elseif string.find(msg, L["Firevulntrigger"]) and (UnitClass("player") == "Mage") then
	        BigWigsThaddiusArrows:Direction("Firevuln")
	elseif string.find(msg, L["FFiretrigger"]) and (UnitClass("player") == "Druid") then
	        BigWigsThaddiusArrows:Direction("FFire")
	end
end

function BigWigsPatchwerk:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if string.find(msg, L["Sundertrigger"]) then
                BigWigsThaddiusArrows:Sunderstop()
	elseif string.find(msg, L["CoEtrigger"]) then
                BigWigsThaddiusArrows:CoEstop()
	elseif string.find(msg, L["CoStrigger"]) then
                BigWigsThaddiusArrows:CoSstop()
	elseif string.find(msg, L["CoRtrigger"]) then
                BigWigsThaddiusArrows:CoRstop()
	elseif string.find(msg, L["Firevulntrigger"]) then
                BigWigsThaddiusArrows:Firevulnstop()
	elseif string.find(msg, L["FFiretrigger"]) then
                BigWigsThaddiusArrows:FFirestop()
	end
end

function BigWigsPatchwerk:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.enrage and string.find(msg, L["starttrigger"]) then
		self:Start()
		self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["enragebartext"], 420, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		self:ScheduleEvent("bwpatchwarn1", "BigWigs_Message", 120, L["warn1"], "Attention")
		self:ScheduleEvent("bwpatchwarn2", "BigWigs_Message", 240, L["warn2"], "Attention")
		self:ScheduleEvent("bwpatchwarn3", "BigWigs_Message", 330, L["warn3"], "Urgent")
		self:ScheduleEvent("bwpatchwarn4", "BigWigs_Message", 360, L["warn4"], "Urgent")
		self:ScheduleEvent("bwpatchwarn5", "BigWigs_Message", 390, L["warn5"], "Important")
		self:ScheduleEvent("bwpatchwarn6", "BigWigs_Message", 410, L["warn6"], "Important")
	end
end

function BigWigsPatchwerk:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["enragetrigger"] then
		if self.db.profile.enrage then
			self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important")
		end
		self:TriggerEvent("BigWigs_StopBar", self, L["enragebartext"])
		self:CancelScheduledEvent("bwpatchwarn1")
		self:CancelScheduledEvent("bwpatchwarn2")
		self:CancelScheduledEvent("bwpatchwarn3")
		self:CancelScheduledEvent("bwpatchwarn4")
		self:CancelScheduledEvent("bwpatchwarn5")
		self:CancelScheduledEvent("bwpatchwarn6")
	end
end

function BigWigsPatchwerk:Start()
	if self.db.profile.debuff then
		if (UnitClass("player") == "Warrior")  then
				BigWigsThaddiusArrows:Direction("Sunder")
				if UnitHealth("player") >= 7000 then
				BigWigsThaddiusArrows:Direction("Stoneshield")
				self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
				self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")end
		elseif (UnitClass("player") == "Warlock")  then
				BigWigsThaddiusArrows:Direction("CoE")
				BigWigsThaddiusArrows:Direction("CoS")
				BigWigsThaddiusArrows:Direction("CoR")
		elseif (UnitClass("player") == "Mage")  then
				BigWigsThaddiusArrows:Direction("Firevuln")
		elseif (UnitClass("player") == "Druid")  then
				BigWigsThaddiusArrows:Direction("FFire")
		end
	end
end

function BigWigsPatchwerk:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if self.db.profile.buff then
	if string.find(msg, L["Stoneshieldtrigger"]) then
            BigWigsThaddiusArrows:Stoneshieldstop()
		end
	end
end

function BigWigsPatchwerk:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if self.db.profile.buff then
		if string.find(msg, L["Stoneshieldtrigger"]) then
	        BigWigsThaddiusArrows:Direction("Stoneshield")
		end
	end
end
	