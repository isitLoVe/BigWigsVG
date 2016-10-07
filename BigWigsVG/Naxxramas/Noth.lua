------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Noth the Plaguebringer"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local onbalcony = false

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Noth",

	blink_cmd = "blink",
	blink_name = "Blink Alert",
	blink_desc = "Warn for blink",

	teleport_cmd = "teleport",
	teleport_name = "Teleport Alert",
	teleport_desc = "Warn for teleport",

	curse_cmd = "curse",
	curse_name = "Curse Alert",
	curse_desc = "Warn for curse",

	wave_cmd = "wave",
	wave_name = "Wave Alert",
	wave_desc = "Warn for waves",

	buff_cmd = "buff",
	buff_name = "Buff Alert",
	buff_desc = "Notify on Buffs Fading",
	
	GSPPtrigger	= "Shadow Protection",
	starttrigger1 = "Die, trespasser!",
	starttrigger2 = "Glory to the master!",
	starttrigger3 = "Your life is forfeit!",
	startwarn = "Noth the Plaguebringer engaged! 90 seconds till teleport",

	addtrigger = "Rise, my soldiers! Rise and fight once more!",
	addbar = "Rise, my soldiers!",

	blinktrigger = "Noth the Plaguebringer gains Blink.",
	blinkwarn = "Blink!",
	blinkwarn2 = "Blink in 5 seconds!",
	blinkbar = "Blink",

	teleportwarn = "Teleport! He's on the balcony!",
	teleportwarn2 = "Teleport in 10 seconds!",

	teleportbar = "Teleport!",
	backbar = "Back in room!",

	backwarn = "He's back in the room for %d seconds!",
	backwarn2 = "10 seconds until he's back in the room!",

	cursetrigger = "afflicted by Curse of the Plaguebringer",
	cursewarn = "Curse! next in 28 seconds",
	curse10secwarn = "Curse in 10 seconds",
	cursewarn_initial = "Curse in 5 seconds",
	
	cursebar = "Next Curse",

	wave1bar = "Wave 1",
	wave2bar = "Wave 2",
	--wave3bar = "Wave 3",
	wave2_message = "Wave 2 in 5sec",
	--wave3_message = "Wave 3 in 5sec",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsNoth = BigWigs:NewModule(boss)
BigWigsNoth.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsNoth.enabletrigger = boss
BigWigsNoth.toggleoptions = {"blink", "teleport", "curse", "wave", "bosskill"}
BigWigsNoth.revision = tonumber(string.sub("$Revision: 19006 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsNoth:OnEnable()
	self.timeroom = 90
	self.timebalcony = 70
	self.cursetime = 28
	self.wave1time = 1
	self.wave2time = 40
	self.wave3time = 0
	self.prior = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "NothBlink", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "NothCurse", 5)

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Curse")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Curse")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Curse")
end


function BigWigsNoth:Curse( msg )
	if string.find(msg, L["cursetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "NothCurse")
	end
end

function BigWigsNoth:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if self.db.profile.buff then
		if string.find(msg, L["GSPPtrigger"]) then
            BigWigsThaddiusArrows:GSPPstop()
		end
	end
end

function BigWigsNoth:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if self.db.profile.buff then
		if string.find(msg, L["GSPPtrigger"]) then
	        BigWigsThaddiusArrows:Direction("GSPP")
		end
	end
end

function BigWigsNoth:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["addtrigger"] and (onbalcony == false) then
		self:TriggerEvent("BigWigs_StartBar", self, L["addbar"], 30, "Interface\\Icons\\Spell_Shadow_Darksummoning")
	elseif msg == L["starttrigger1"] or msg == L["starttrigger2"] or msg == L["starttrigger3"] then
		self.timeroom = 90
		self.timebalcony = 70

		if self.db.profile.teleport then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:ScheduleEvent("BigWigs_Message", self.timeroom-10, L["teleportwarn2"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["teleportbar"], self.timeroom, "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
		end
		if self.db.profile.curse then
			self:ScheduleEvent("bwnothinitialcurse", "BigWigs_Message", 5, L["cursewarn_initial"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["cursebar"], 10, "Interface\\Icons\\Spell_Shadow_AnimateDead")
		end
		if self.db.profile.blink then
			self:ScheduleEvent("bwnothblink", "BigWigs_Message", 25, L["blinkwarn2"], "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, L["blinkbar"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
		end
		self:TriggerEvent("BigWigs_StartBar", self, L["addbar"], 30, "Interface\\Icons\\Spell_Shadow_Darksummoning")
		self:ScheduleEvent("bwnothtobalcony", self.teleportToBalcony, self.timeroom, self)
	end
end

function BigWigsNoth:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if msg == L["blinktrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "NothBlink")
	end
end

function BigWigsNoth:BigWigs_RecvSync( sync )
	if sync == "NothCurse" then
		if self.db.profile.curse then
			self:TriggerEvent("BigWigs_Message", L["cursewarn"], "Important", nil, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["cursebar"], self.cursetime, "Interface\\Icons\\Spell_Shadow_AnimateDead")
		end
	elseif sync == "NothBlink" then
		if self.db.profile.blink then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Noth") end, 25)
			self:TriggerEvent("BigWigs_Message", L["blinkwarn"], "Important")
			self:ScheduleEvent("bwnothblink", "BigWigs_Message", 25, L["blinkwarn2"], "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, L["blinkbar"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
		end
	end
end

function BigWigsNoth:teleportToBalcony()
	if self.timeroom == 90 then
		self.timeroom = 110
	elseif self.timeroom == 110 then
		self.timeroom = 180
	end
	
	onbalcony = true
	
	self:CancelScheduledEvent("bwnothblink")
	self:CancelScheduledEvent("bwnothcurse")
	self:TriggerEvent("BigWigs_StopBar", self, L["blinkbar"])
	self:TriggerEvent("BigWigs_StopBar", self, L["addbar"])
	self:TriggerEvent("BigWigs_StopBar", self, L["cursebar"])

	if self.db.profile.teleport then 
		self:TriggerEvent("BigWigs_Message", L["teleportwarn"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["backbar"], self.timebalcony, "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
		self:ScheduleEvent("bwnothback", "BigWigs_Message", self.timebalcony - 10, L["backwarn2"], "Urgent")
	end
	if self.db.profile.wave then
		self:TriggerEvent("BigWigs_StartBar", self, L["wave1bar"], self.wave1time, "Interface\\Icons\\Spell_ChargePositive" )
		self:TriggerEvent("BigWigs_StartBar", self, L["wave2bar"], self.wave2time, "Interface\\Icons\\Spell_ChargePositive" )
		--self:TriggerEvent("BigWigs_StartBar", self, L["wave3bar"], self.wave3time, "Interface\\Icons\\Spell_ChargePositive" )
		self:ScheduleEvent("bwnothwave2inc", "BigWigs_Message", self.wave2time - 5, L["wave2_message"], "Urgent")
	end
	self:ScheduleEvent("bwnothtoroom", self.teleportToRoom, self.timebalcony, self)
	self.wave2time = self.wave2time +5
end

function BigWigsNoth:teleportToRoom()
	if self.timebalcony == 70 then
		self.timebalcony = 92
	elseif self.timebalcony == 92 then
		self.timebalcony = 120
	end

	onbalcony = false
	
	if self.db.profile.teleport then
		self:TriggerEvent("BigWigs_Message", string.format(L["backwarn"], self.timeroom), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["teleportbar"], self.timeroom, "Interface\\Icons\\Spell_Magic_LesserInvisibilty")
		self:ScheduleEvent("bwnothteleport", "BigWigs_Message", self.timeroom - 10, L["teleportwarn2"], "Urgent")
	end
	self.prior = nil
	self:TriggerEvent("BigWigs_StartBar", self, L["cursebar"], self.cursetime, "Interface\\Icons\\Spell_Shadow_AnimateDead")
	self:ScheduleEvent("bwnothtobalcony", self.teleportToBalcony, self.timeroom, self)
end
