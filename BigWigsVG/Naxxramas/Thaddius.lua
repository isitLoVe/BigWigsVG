------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Thaddius"]
local feugen = AceLibrary("Babble-Boss-2.2")["Feugen"]
local stalagg = AceLibrary("Babble-Boss-2.2")["Stalagg"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local started
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Thaddius",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	phase_cmd = "phase",
	phase_name = "Phase Alerts",
	phase_desc = "Warn for Phase transitions",

	polarity_cmd = "polarity",
	polarity_name = "Polarity Shift Alert",
	polarity_desc = "Warn for polarity shifts",

	power_cmd = "power",
	power_name = "Power Surge Alert",
	power_desc = "Warn for Stalagg's power surge",

	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warn about Positive/Negative charge for yourself only.",

	throw_cmd = "throw",
	throw_name = "Throw Alerts",
	throw_desc = "Warn about tank platform swaps.",
	
	warstomp_cmd = "warstomp",
	warstomp_name = "War Stomp Alerts",
	warstomp_desc = "Warn about War Stomps.",

	enragetrigger = "%s goes into a berserker rage!",
	starttrigger = "Stalagg crush you!",
	starttrigger1 = "Feed you to master!",

	adddeath = "%s dies.",
	teslaoverload = "%s overloads!",

	pstrigger = "Now YOU feel pain!",
	trigger1 = "Thaddius begins to cast Polarity Shift.",
	chargetrigger = "You are afflicted by (%w+) Charge.",
	positivetype = "Interface\\Icons\\Spell_ChargePositive",
	negativetype = "Interface\\Icons\\Spell_ChargeNegative",
	stalaggtrigger = "Stalagg gains Power Surge.",

	you = "You",
	are = "are",
	testbar = "test",

	adddie1 = "Master save me...",
	adddie2 = "No... more... Feugen...",
	adddiebartext = "Resurrecting",
	P2inc = "Phase 2 start",

	enragewarn = "Enrage!",
	startwarn = "Thaddius Phase 1",
	startwarn2 = "Thaddius Phase 2, Enrage in 5 minutes!",
	
	redleftblueright = "|cffff0000 ----RED LEFT----|r     |cff0000ff++++BLUE RIGHT++++|r",
	
	addsdownwarn = "Adds are dead. Phase 2 inc!",
	thaddiusincoming = "Thaddius incoming in 3 sec!",
	pswarn1 = "Polarity Shift casting - CHECK DEBUFF!!!",
	pswarn3 = "5 seconds to Polarity Shift!",
	poswarn = "You changed to a POSITIVE Charge! RUN!",
	negwarn = "You changed to a NEGATIVE Charge! RUN!",
	nochange = "Your debuff did not change!",
	polaritytickbar = "Polarity tick",
	enragebartext = "Enrage",
	warn1 = "Enrage in 3 minutes",
	warn2 = "Enrage in 90 seconds",
	warn3 = "Enrage in 60 seconds",
	warn4 = "Enrage in 30 seconds",
	warn5 = "Enrage in 10 seconds",
	stalaggwarn = "Power Surge on Stalagg!",
	powersurgebar = "Power Surge",
	castbar = "Casting Shift!",

	bar1text = "Polarity Shift",
	barbossinc = "Thaddius activation",

	throwbar = "next Throw",
	throwbar_initial = "Throw",
	throwwarn = "Throw in ~4 seconds!",
	
	warstomp_bar_stalagg = " Stallag War Stomp",
	warstomp_warn_stalagg = "Stallag War Stomp in 2 sec",
	warstomp_trigger_stalagg = "Stalagg's War Stomp",
	
	warstomp_bar_feugen = " Feugen War Stomp",
	warstomp_warn_feugen = "Feugen War Stomp in 2 sec",
	warstomp_trigger_feugen = "Feugen's War Stomp",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsThaddius = BigWigs:NewModule(boss)
BigWigsThaddius.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsThaddius.enabletrigger = { boss, feugen, stalagg }
BigWigsThaddius.toggleoptions = {"enrage", "charge", "polarity", -1, "power", "throw", "warstomp", "phase", "bosskill"}
BigWigsThaddius.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsThaddius:OnEnable()
	self.enrageStarted = nil
	self.addsdead = 0
	self.teslawarn = nil
	self.stage1warn = nil
	self.previousCharge = ""
	self.throwtime_initial = 22
	self.throwtime = 21

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "WarStompEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "WarStompEvent")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "ThaddiusPolarity", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "StalaggPower", 4)
	self:TriggerEvent("BigWigs_ThrottleSync", "StalaggWarStomp", 4)
	self:TriggerEvent("BigWigs_ThrottleSync", "FeugenWarStomp", 4)
end

function BigWigsThaddius:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if msg == L["stalaggtrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "StalaggPower")
	end
end

function BigWigsThaddius:WarStompEvent(msg)
	if string.find(msg, L["warstomp_trigger_stalagg"]) then
		self:TriggerEvent("BigWigs_SendSync", "StalaggWarStomp")
	elseif string.find(msg, L["warstomp_trigger_feugen"]) then
		self:TriggerEvent("BigWigs_SendSync", "FeugenWarStomp")
	end
end


function BigWigsThaddius:CHAT_MSG_MONSTER_YELL( msg )
	if string.find(msg, L["pstrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "ThaddiusPolarity")
    elseif msg == L["starttrigger"] or msg == L["starttrigger1"] and not started then
		started = true
		if self.db.profile.phase and not self.stage1warn then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
		end
		self.stage1warn = true
		self:TriggerEvent("BigWigs_StartBar", self, L["throwbar_initial"], self.throwtime_initial, "Interface\\Icons\\Ability_Druid_Maul")
		self:ScheduleEvent("bwthaddiusthrowwarn", "BigWigs_Message", self.throwtime_initial - 4, L["throwwarn"], "Urgent")
		self:ScheduleRepeatingEvent( "bwthaddiusthrow", self.Throw, self.throwtime, self )
		
		if self.db.profile.warstomp then
			self:TriggerEvent("BigWigs_StartBar", self, L["warstomp_bar_stalagg"], 9, "Interface\\Icons\\Ability_WarStomp")
			self:ScheduleEvent("bwthaddiuswarstompstalaggwarn", "BigWigs_Message", 7, L["warstomp_warn_stalagg"], "Urgent")
			
			self:TriggerEvent("BigWigs_StartBar", self, L["warstomp_bar_feugen"], 9, "Interface\\Icons\\Ability_WarStomp")
			self:ScheduleEvent("bwthaddiuswarstompfeugenwarn", "BigWigs_Message", 7, L["warstomp_warn_feugen"], "Urgent")
		end
	elseif msg == L["adddie1"] or msg == L["adddie2"] then
		self.addsdead = self.addsdead + 1
		if self.addsdead == 1 then			
				self:TriggerEvent("BigWigs_StartBar", self, L["adddiebartext"], 10, "Interface\\Icons\\Spell_Holy_Resurrection")
				self:TriggerEvent("BigWigs_StopBar", self, L["throwbar"])
				self:TriggerEvent("BigWigs_StopBar", self, L["powersurgebar"])
				self:CancelScheduledEvent("bwthaddiusthrow")
				self:CancelScheduledEvent("bwthaddiusthrowwarn")
				self:CancelScheduledEvent("bwthaddiuswarstompstalaggwarn")
				self:CancelScheduledEvent("bwthaddiuswarstompfeugenwarn")
		else
				self:TriggerEvent("BigWigs_StartBar", self, L["P2inc"], 22, "Interface\\Icons\\Spell_Nature_Purge")
				self:ScheduleEvent("P2start", self.PhaseTwoStart, 22, self)
				self:TriggerEvent("BigWigs_StopBar", self, L["adddiebartext"])
				self:TriggerEvent("BigWigs_StopBar", self, L["powersurgebar"])
				self:TriggerEvent("BigWigs_StopBar", self, L["warstomp_bar_stalagg"])
				self:TriggerEvent("BigWigs_StopBar", self, L["warstomp_bar_feugen"])
				klhtm:ResetRaidThreat()
			if self.db.profile.phase then self:TriggerEvent("BigWigs_Message", L["addsdownwarn"], "Attention") end
		end
	end
end

function BigWigsThaddius:PhaseTwoStart()
    self:TriggerEvent("BigWigs_Message", L["redleftblueright"], _, _,"Warn")
	self:TriggerEvent("BigWigs_StartBar", self, L["enragebartext"], 301, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
	self:ScheduleEvent("bwthaddiuswarn1", "BigWigs_Message", 120, L["warn1"], "Attention")
	self:ScheduleEvent("bwthaddiuswarn2", "BigWigs_Message", 210, L["warn2"], "Attention")
	self:ScheduleEvent("bwthaddiuswarn3", "BigWigs_Message", 240, L["warn3"], "Urgent")
	self:ScheduleEvent("bwthaddiuswarn4", "BigWigs_Message", 270, L["warn4"], "Important")
	self:ScheduleEvent("bwthaddiuswarn5", "BigWigs_Message", 290, L["warn5"], "Important")
	self:ScheduleEvent("BigWigs_Message", 27, L["redleftblueright"], "Urgent")
	self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 30, "Interface\\Icons\\Spell_Nature_Lightning")
end

function BigWigsThaddius:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["enragetrigger"] then
		if self.db.profile.enrage then self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important") end
		self:TriggerEvent("BigWigs_StopBar", self, L["enragebartext"])
		self:CancelScheduledEvent("bwthaddiuswarn1")
		self:CancelScheduledEvent("bwthaddiuswarn2")
		self:CancelScheduledEvent("bwthaddiuswarn3")
		self:CancelScheduledEvent("bwthaddiuswarn4")
		self:CancelScheduledEvent("bwthaddiuswarn5")
	end
end

function BigWigsThaddius:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	if string.find(msg, L["trigger1"]) then
		self:TriggerEvent("BigWigs_Message", L["redleftblueright"], "Important")
	end
end

function BigWigsThaddius:PLAYER_AURAS_CHANGED( msg )
		self:RegisterEvent("PLAYER_AURAS_CHANGED")
	local chargetype = nil
	local iIterator = 1
	while UnitDebuff("player", iIterator) do
		local texture, applications = UnitDebuff("player", iIterator)
		if texture == L["positivetype"] or texture == L["negativetype"] then
			-- If we have a debuff with this texture that has more
			-- than one application, it means we still have the
			-- counter debuff, and thus nothing has changed yet.
			-- (we got a PW:S or Renew or whatever after he casted
			--  PS, but before we got the new debuff)
			if applications > 1 then return end
			chargetype = texture
			-- Note that we do not break out of the while loop when
			-- we found a debuff, since we still have to check for
			-- debuffs with more than 1 application.
		end
		iIterator = iIterator + 1
	end
	if not chargetype then return end

	self:UnregisterEvent("PLAYER_AURAS_CHANGED")

	if self.db.profile.charge then
		if self.previousCharge and self.previousCharge == chargetype then
			self:TriggerEvent("BigWigs_Message", L["nochange"], "Urgent", true, "Alarm")
		elseif chargetype == L["positivetype"] then
			self:TriggerEvent("BigWigs_Message", L["poswarn"], "Positive", true, "Alarm")
		elseif chargetype == L["negativetype"] then
			self:TriggerEvent("BigWigs_Message", L["negwarn"], "Important", true, "Alarm")
		end
		self:TriggerEvent("BigWigs_StartBar", self, L["polaritytickbar"], 5, chargetype, "Important")
	end
	self.previousCharge = chargetype
end

function BigWigsThaddius:BigWigs_RecvSync( sync )
	if sync == "ThaddiusPolarity" and self.db.profile.polarity then
	    self:ScheduleEvent("bwthaddiustestcheck", self.Testcheck, 3.5, self)
        self:TriggerEvent("BigWigs_StartBar", self, L["castbar"], 3.1, "Interface\\Icons\\Spell_Nature_Lightning")
		self:ScheduleEvent("BigWigs_Message", 27, L["redleftblueright"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 30, "Interface\\Icons\\Spell_Nature_Lightning")
	elseif sync == "StalaggPower" and self.db.profile.power then
		self:TriggerEvent("BigWigs_Message", L["stalaggwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["powersurgebar"], 10, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
	elseif sync == "StalaggWarStomp" and self.db.profile.warstomp then
		self:TriggerEvent("BigWigs_StartBar", self, L["warstomp_bar_stalagg"], 9, "Interface\\Icons\\Ability_Druid_Maul")
		self:ScheduleEvent("bwthaddiuswarstompstalaggwarn", "BigWigs_Message", 7, L["warstomp_warn_stalagg"], "Urgent")
	elseif sync == "FeugenWarStomp" and self.db.profile.warstomp then
		self:TriggerEvent("BigWigs_StartBar", self, L["warstomp_bar_feugen"], 9, "Interface\\Icons\\Ability_Druid_Maul")
		self:ScheduleEvent("bwthaddiuswarstompfeugenwarn", "BigWigs_Message", 7, L["warstomp_warn_feugen"], "Urgent")
	end
end

function BigWigsThaddius:Throw()
	if self.db.profile.throw then
		self:TriggerEvent("BigWigs_StartBar", self, L["throwbar"], self.throwtime, "Interface\\Icons\\Ability_Druid_Maul")
		self:ScheduleEvent("bwthaddiusthrowwarn", "BigWigs_Message", self.throwtime - 4, L["throwwarn"], "Urgent")
		klhtm:ResetRaidThreat()
	end
end

function BigWigsThaddius:Testcheck()
	local chargetype = nil
	local iIterator = 1
	while UnitDebuff("player", iIterator) do
		local texture, applications = UnitDebuff("player", iIterator)
		if texture == L["positivetype"] or texture == L["negativetype"] then
			-- If we have a debuff with this texture that has more
			-- than one application, it means we still have the
			-- counter debuff, and thus nothing has changed yet.
			-- (we got a PW:S or Renew or whatever after he casted
			--  PS, but before we got the new debuff)
			if applications > 1 then return end
			chargetype = texture
			-- Note that we do not break out of the while loop when
			-- we found a debuff, since we still have to check for
			-- debuffs with more than 1 application.
		end
		iIterator = iIterator + 1
	end
	if not chargetype then return end

	if self.db.profile.charge then
		if self.previousCharge and self.previousCharge == chargetype then
			self:TriggerEvent("BigWigs_Message", L["nochange"], "Positive", true, "Alarm")
		elseif chargetype == L["positivetype"] then
			self:TriggerEvent("BigWigs_Message", L["poswarn"], "Urgent", true, "Alert")
		elseif chargetype == L["negativetype"] then
			self:TriggerEvent("BigWigs_Message", L["negwarn"], "Urgent", true, "Alert")
		end
		self:TriggerEvent("BigWigs_StartBar", self, L["polaritytickbar"], 5, chargetype, "Important")
	end
	self.previousCharge = chargetype
end
