------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Grand Widow Faerlina"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Faerlina",

	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warn for silence",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	buff_cmd = "buff",
	buff_name = "Buff Alert",
	buff_desc = "Notify on Buffs Fading",
	
	rof_cmd = "rof",
	rof_name = "Rain of Fire Timer",
	rof_desc = "Timer for Rain of Fire",
	
	GNPPtrigger	= "Nature Protection",
	GFPPtrigger	= "Fire Protection",

	starttrigger1 = "Kneel before me, worm!",
	starttrigger2 = "Slay them in the master's name!",
	starttrigger3 = "You cannot hide from me!",
	starttrigger4 = "Run while you still can!",
	trigger = "Rain of Fire",

	silencetrigger = "Grand Widow Faerlina is afflicted by Widow's Embrace.", -- EDITED it affects her too.
	enragetrigger = "Grand Widow Faerlina gains Enrage.",
	enragefade = "Enrage fades from Grand Widow Faerlina.",

	startwarn = "Grand Widow Faerlina engaged, 60 seconds to enrage!",
	enragewarn15sec = "15 seconds until enrage!",
	enragewarn = "Enrage!",
	enrageremovewarn = "Enrage removed! %d seconds until next!", -- added
	silencewarn = "Silence! Delaying Enrage!",
	silencewarnnodelay = "Silence!",
	silencewarn5sec = "Silence ends in 5 sec",
	firewarn = "Run from FIRE!",

	enragebar = "Enrage",
	silencebar = "Silence",
	rofbar = "Rain of Fire",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFaerlina = BigWigs:NewModule(boss)
BigWigsFaerlina.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsFaerlina.enabletrigger = boss
BigWigsFaerlina.toggleoptions = {"silence", "enrage", "rof", "buff", "bosskill"}
BigWigsFaerlina.revision = tonumber(string.sub("$Revision: 15233 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFaerlina:OnEnable()
	self.initialenragetime = 40
	self.enragetime = 30
	self.enragetimewhilesilenced = 60
	self.enrageTimerStarted = 0
	self.silencetime = 30
	self.enraged = nil

	started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FaerlinaEnrage", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "FaerlinaSilence", 5)
end

function BigWigsFaerlina:CHAT_MSG_MONSTER_YELL( msg )
	if not started and msg == L["starttrigger1"] or msg == L["starttrigger2"] or msg == L["starttrigger3"] or msg == L["starttrigger4"] then
		self:TriggerEvent("BigWigs_Message", L["startwarn"], "Orange")
		if self.db.profile.enrage then
			self:ScheduleEvent("bwfaerlinaenrage15", "BigWigs_Message", self.initialenragetime - 15, L["enragewarn15sec"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["enragebar"], self.initialenragetime, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		end
		if self.db.profile.rof then
			self:TriggerEvent("BigWigs_StartBar", self, L["rofbar"], 16, "Interface\\Icons\\Spell_Shadow_RainOfFire")		
			self:ScheduleRepeatingEvent("bwfaerlinarofrepeat", self.RoF, 16, self)
		end
		self.enrageTimerStarted = GetTime()
		started = true
	end
end

function BigWigsFaerlina:RoF()
	self:TriggerEvent("BigWigs_StartBar", self, L["rofbar"], 16, "Interface\\Icons\\Spell_Shadow_RainOfFire")		
end

function BigWigsFaerlina:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if string.find(msg, L["GNPPtrigger"]) then
            BigWigsThaddiusArrows:GNPPstop()
	elseif string.find(msg, L["GFPPtrigger"]) then
            BigWigsThaddiusArrows:GFPPstop()
	end
end

function BigWigsFaerlina:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE( msg )
	if string.find(msg, L["trigger"]) then
		self:CancelScheduledEvent("bwfaerlinafire")
		self:ScheduleEvent("bwfaerlinafire", self.Stopf, 6, self )
		self:TriggerEvent("BigWigs_Message", L["firewarn"], "Personal", true, "Alarm")
	        BigWigsThaddiusArrows:Direction("Fire")
	end
end

function BigWigsFaerlina:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if self.db.profile.buff then
		if string.find(msg, L["trigger"]) then
				BigWigsThaddiusArrows:Firestop()
		elseif string.find(msg, L["GNPPtrigger"]) then
				BigWigsThaddiusArrows:Direction("GNPP")
		elseif string.find(msg, L["GFPPtrigger"]) then
				BigWigsThaddiusArrows:Direction("GFPP")
		end
	end
end

function BigWigsFaerlina:Stopf()
	if self.db.profile.buff then
            BigWigsThaddiusArrows:Firestop()
	end
end

function BigWigsFaerlina:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if msg == L["enragetrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "FaerlinaEnrage")
	end
end

function BigWigsFaerlina:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE( msg )
	if msg == L["silencetrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "FaerlinaSilence")
	end
end

function BigWigsFaerlina:BigWigs_RecvSync( sync )
	if sync == "FaerlinaEnrage" then
		if self.db.profile.enrage then
			self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Urgent")
		end
		self:TriggerEvent("BigWigs_StopBar", self, L["enragebar"])
		self:CancelScheduledEvent("bwfaerlinaenrage15") 
		--if self.db.profile.enrage then
		--	self:TriggerEvent("BigWigs_StartBar", self, L["enragebar"], self.enragetime, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		--	self:ScheduleEvent("bwfaerlinaenrage15", "BigWigs_Message", self.enragetime - 15, L["enragewarn15sec"], "Important")
		--end
		self.enrageTimerStarted = GetTime()
		self.enraged = true
	elseif sync == "FaerlinaSilence" then
		-- nonono Zeard cant script that
		
		--[[if not self.enraged then -- preemptive, 30s silence
		
			--[[ The enrage timer should only be reset if it's less than 30sec
			to her next enrage, because if you silence her when there's 30+
			sec to the enrage, it won't actually stop her from enraging. ]]

			local currentTime = GetTime()

			if self.db.profile.silence then
				if (self.enrageTimerStarted + 30) < currentTime then
					self:TriggerEvent("BigWigs_Message", L["silencewarnnodelay"], "Urgent")
				else
					self:TriggerEvent("BigWigs_Message", L["silencewarn"], "Urgent")
				end
				self:TriggerEvent("BigWigs_StartBar", self, L["silencebar"], self.silencetime, "Interface\\Icons\\Spell_Holy_Silence")
				self:ScheduleEvent("bwfaerlinasilence5", "BigWigs_Message", self.silencetime -5, L["silencewarn5sec"], "Urgent")
			end
			if (self.enrageTimerStarted + 30) < currentTime then
				if self.db.profile.enrage then
					-- We SHOULD reset the enrage timer, since it's more than 30
					-- sec since enrage started. This is only visuals ofcourse.
					self:TriggerEvent("BigWigs_StopBar", self, L["enragebar"])
					self:CancelScheduledEvent("bwfaerlinaenrage15")
					self:ScheduleEvent( "bwfaerlinaenrage15", "BigWigs_Message", self.silencetime - 15, L["enragewarn15sec"], "Important")
					self:TriggerEvent("BigWigs_StartBar", self, L["enragebar"], self.silencetime, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
				end
				self.enrageTimerStarted = currentTime
			end

		else -- Reactive enrage removed
			if self.db.profile.enrage then
				self:TriggerEvent("BigWigs_Message", string.format(L["enrageremovewarn"], self.enragetime), "Urgent")
			end
			if self.db.profile.silence then
				self:TriggerEvent("BigWigs_StartBar", self, L["silencebar"], self.silencetime, "Interface\\Icons\\Spell_Holy_Silence")
				self:ScheduleEvent("bwfaerlinasilence5", "BigWigs_Message", self.silencetime -5, L["silencewarn5sec"], "Urgent")
 			end
			self.enraged = nil
		end]]
		
		--VG Silence Bar 30sec
		if self.db.profile.silence then
			self:ScheduleEvent("bwfaerlinasilence5", "BigWigs_Message", self.silencetime -5, L["silencewarn5sec"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["silencebar"], self.silencetime, "Interface\\Icons\\Spell_Holy_Silence")
		end
		if self.enraged then
			--VG Enrage Bar 60sec after silence when enraged
			self:ScheduleEvent( "bwfaerlinaenrage15", "BigWigs_Message", self.enragetimewhilesilenced - 15, L["enragewarn15sec"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["enragebar"], self.enragetimewhilesilenced, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		else
			--VG Enrage Bar 30sec after silence when not enraged
			self:ScheduleEvent( "bwfaerlinaenrage15", "BigWigs_Message", self.enragetime - 15, L["enragewarn15sec"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["enragebar"], self.enragetime, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		end
		self.enraged = nil
	end
end


