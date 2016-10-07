------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Instructor Razuvious"]
local understudy = AceLibrary("Babble-Boss-2.2")["Deathknight Understudy"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Razuvious",

	shout_cmd = "shout",
	shout_name = "Shout Alert",
	shout_desc = "Warn for disrupting shout",

	unbalance_cmd = "unbalancing",
	unbalance_name = "Unbalancing Strike Alert",
	unbalance_desc = "Warn for Unbalancing Strike",
	
	shieldwall_cmd = "shieldwall",
	shieldwall_name = "Shield Wall Timer",
	shieldwall_desc = "Show timer for Shield Wall",

	startwarn = "Instructor Razuvious engaged! 25sec to Shout, ~20sec to Unbalancing Strike!",

	starttrigger1 = "Stand and fight!",
	starttrigger2 = "Show me what you've got!",
	starttrigger3 = "Hah hah, I'm just getting warmed up!",
	
	Sundertrigger1 = "Sunder Armor fades from Instructor Razuvious",
	Sundertrigger2 = "Instructor Razuvious is afflicted by Sunder Armor",

	shouttrigger = "Disrupting Shout",
	shout10secwarn = "10 sec to Disrupting Shout",
	shout5secwarn = "5 sec to Disrupting Shout!",
	shoutwarn = "Disrupting Shout!",
	noshoutwarn = "No shout! Next in 25secs",
	shoutbar = "Disrupting Shout",

    unbalance_trigger = "afflicted by Unbalancing Strike",
	unbalancesoonwarn = "Unbalancing Strike coming soon!",
	unbalancewarn = "Unbalancing Strike! Next in ~20sec",
	unbalancebar = "Unbalancing Strike",
	
	shieldwalltrigger   = "Death Knight Understudy gains Shield Wall.",
	shieldwallbar       = "Shield Wall",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRazuvious = BigWigs:NewModule(boss)
BigWigsRazuvious.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsRazuvious.enabletrigger = { boss }
BigWigsRazuvious.wipemobs = { understudy }
BigWigsRazuvious.toggleoptions = {"shout", "shieldwall", "unbalance", "bosskill"}
BigWigsRazuvious.revision = tonumber(string.sub("$Revision: 19004 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsRazuvious:OnEnable()
	self.timeShout = 30
	self.prior = nil
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Shout")
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Shout")
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Shout")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Unbalance")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Unbalance")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Unbalance")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Unbalance")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Shieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "Shieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "Shieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Shieldwall")
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

	
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "RazuviousShout", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "RazuviousShieldwall", 5)
end

function BigWigsRazuvious:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["starttrigger1"] or msg == L["starttrigger2"] or msg == L["starttrigger3"] then
	        if (UnitClass("player") == "Warrior") then
				BigWigsThaddiusArrows:Direction("Sunder")
	        end
		if self.db.profile.shout then
			self:ScheduleRepeatingEvent("bwreazuviousshoutvg", self.RazuviousShoutVG, 25, self)
			
			self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 15, L["shout10secwarn"], "Attention")
			self:ScheduleEvent("bwrazuviousshout5sec", "BigWigs_Message", 20, L["shout5secwarn"], "Urgent", nil, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 25, "Interface\\Icons\\Ability_Warrior_WarCry")
			
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Urgent", nil, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["unbalancebar"], 20, "Interface\\Icons\\Ability_Warrior_DecisiveStrike")
		end
		--self:ScheduleEvent("bwrazuviousnoshout", self.noShout, self.timeShout - 5, self )
	end
end

function BigWigsRazuvious:BigWigs_Message(text)
	if text == L["shout10secwarn"] then self.prior = nil end
end

function BigWigsRazuvious:Shieldwall( msg ) 
	if string.find(msg, L["shieldwalltrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "RazuviousShieldwall")
	end
end
--[[
function BigWigsRazuvious:Shout( msg )
	if string.find(msg, L["shouttrigger"]) and not self.prior then
		self:TriggerEvent("BigWigs_SendSync", "RazuviousShout")
	end
end

function BigWigsRazuvious:noShout()	
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:ScheduleEvent("bwrazuviousnoshout", self.noShout, self.timeShout, self )
	if self.db.profile.shout then
		self:TriggerEvent("BigWigs_Message", L["noshoutwarn"], "Attention")
		self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 15, L["shout10secwarn"], "Attention")
			self:Run2()
		self:ScheduleEvent("bwrazuviousshout5sec", "BigWigs_Message", 20, L["shout5secwarn"], "Urgent", nil, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 25, "Interface\\Icons\\Ability_Warrior_WarCry")
	end
end
]]--

function BigWigsRazuvious:RazuviousShoutVG()	
	self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 15, L["shout10secwarn"], "Attention")
	self:ScheduleEvent("bwrazuviousshout5sec", "BigWigs_Message", 20, L["shout5secwarn"], "Urgent", nil, "Alert")
	self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 25, "Interface\\Icons\\Ability_Warrior_WarCry")
end

function BigWigsRazuvious:Unbalance(msg)	
	if string.find(msg, L["unbalance_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "RazuviousUnbalance")
	end
end

function BigWigsRazuvious:BigWigs_RecvSync( sync )
	if sync == "RazuviousShout" then
		--self:CancelScheduledEvent("bwrazuviousnoshout")
		--self:ScheduleEvent("bwrazuviousnoshout", self.noShout, self.timeShout, self )		
		if self.db.profile.shout then
			--self:TriggerEvent("BigWigs_Message", L["shoutwarn"], "Attention", nil, "Alarm")
			--self:ScheduleEvent("bwrazuviousshout10sec", "BigWigs_Message", 15, L["shout10secwarn"], "Urgent")
			--	self:Run2()
			--self:ScheduleEvent("bwrazuviousshout5sec", "BigWigs_Message", 20, L["shout5secwarn"], "Urgent", nil, "Alert")
			--self:TriggerEvent("BigWigs_StartBar", self, L["shoutbar"], 25, "Interface\\Icons\\Ability_Warrior_WarCry")
		end
		self.prior = true
	elseif sync == "RazuviousShieldwall" then
		if self.db.profile.shieldwall then
		self:TriggerEvent("BigWigs_StartBar", self, L["shieldwallbar"], 20, "Interface\\Icons\\Ability_Warrior_ShieldWall")
		end
	elseif sync == "RazuviousUnbalance" then
		if self.db.profile.unbalance then
		self:TriggerEvent("BigWigs_Message", L["unbalancewarn"], "Urgent")
		self:ScheduleEvent("bwrazuviousunbalance5sec", "BigWigs_Message", 15, L["unbalancesoonwarn"], "Urgent", nil, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["unbalancebar"], 20, "Interface\\Icons\\Ability_Warrior_DecisiveStrike")
		end
	end
end

function BigWigsRazuvious:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["Sundertrigger1"]) then
	        BigWigsThaddiusArrows:Direction("Sunder")
	end
end

function BigWigsRazuvious:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if string.find(msg, L["Sundertrigger2"]) and (UnitClass("player") == "Warrior") then
                BigWigsThaddiusArrows:Sunderstop()
	end
end

function BigWigsRazuvious:Run1()
            if (UnitClass("player") == "Mage") or (UnitClass("player") == "Warlock") or (UnitClass("player") == "Hunter") then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 22)
	end
end

function BigWigsRazuvious:Run2()
            if (UnitClass("player") == "Mage") or (UnitClass("player") == "Warlock") or (UnitClass("player") == "Hunter") then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 17)
	end
end
