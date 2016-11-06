------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Onyxia"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Onyxia",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath",
	deepbreath_desc = "Warn when Onyxia begins to cast Deep Breath ",

	phase2_cmd = "phase2",
	phase2_name = "Phase 2 alert",
	phase2_desc = "Warn for Phase 2",

	phase3_cmd = "phase3",
	phase3_name = "Phase 3 alert",
	phase3_desc = "Warn for Phase 3",

	fear_cmd = "fear",
	fear_name = "Fear",
	fear_desc = "Warn for Bellowing Roar in phase 3",
	
	wing_cmd = "wingbuffet",
	wing_name = "Wing Buffet",
	wing_desc = "Warn for Wing Buffet",
	
	knock_cmd = "knockaway",
	knock_name = "Knock Away",
	knock_desc = "Warn for Knock Away (25% aggro reduce)",
	
	whelps_cmd = "whelps",
	whelps_name = "Whelps",
	whelps_desc = "Warn for Onyxian Whelps",

	knock_trigger = "Knock Away",
	wing_trigger = "Wing Buffet",
	deepbreath_trigger = "Onyxia takes in a deep breath...",
	phase1_trigger = "Usually, I must leave my lair to feed",
	phase2_trigger = "from above",
	phase3_trigger = "It seems you'll need another lesson",
	fear_trigger = "Onyxia begins to cast Bellowing Roar.",

	knock_warn = "Knock Away (25% aggro reduce) in ~5sec",
	wing_warn = "Wing Buffet in ~5sec",
	deepbreathnow_warn = "Deep Breath incoming!",
	phase2_warn = "Phase 2 incoming!",
	phase3_warn = "Phase 3 incoming!",
	fear_warn = "Fear in 1.5sec!",
	
	knock_bar = "~ Knock Away",
	wing_bar = "~ Wing Buffet",
	wingcast_bar = "casting Wing Buffet",
	deepbreath_bar = "Deep Breath",
	fear_bar = "Bellowing Roar",
	fearcast_bar = "casting Bellowing Roar",
	whelps_bar = "Whelps",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsOnyxia = BigWigs:NewModule(boss)
BigWigsOnyxia.zonename = AceLibrary("Babble-Zone-2.2")["Onyxia's Lair"]
BigWigsOnyxia.enabletrigger = boss
BigWigsOnyxia.toggleoptions = {"wing", "knock", "fear", "deepbreath", "whelps", -1, "phase2", "phase3", "bosskill"}
BigWigsOnyxia.revision = tonumber(string.sub("$Revision: 19012 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsOnyxia:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "SpellEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "SpellEvent")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "OnyxiaKnockAway", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "OnyxiaFear", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "OnyxiaWing", 5)
	starttime = nil
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsOnyxia:BigWigs_RecvSync( sync )
	if sync == "OnyxiaKnockAway" and self.db.profile.knock then
		self:TriggerEvent("BigWigs_StartBar", self, L["knock_bar"], 25, "Interface\\Icons\\Spell_Fire_Fire")
	elseif sync == "OnyxiaFear" and self.db.profile.fear then
		self:TriggerEvent("BigWigs_StartBar", self, L["fearcast_bar"], 1.5, "Interface\\Icons\\Spell_Fire_Fire")
		self:TriggerEvent("BigWigs_StartBar", self, L["fear_bar"], 30, "Interface\\Icons\\Spell_Fire_Fire")
	elseif sync == "OnyxiaWing" and self.db.profile.wing then
		self:TriggerEvent("BigWigs_StartBar", self, L["wingcast_bar"], 1, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		self:ScheduleEvent("BigWigs_Message", 15, L["wing_warn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["wing_bar"], 20, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	end
end

function BigWigsOnyxia:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	if string.find(msg, L["wing_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OnyxiaWing")
	elseif string.find(msg, L["fear_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OnyxiaFear")
	end
end

function BigWigsOnyxia:SpellEvent( msg )
	if string.find(msg, L["knock_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "OnyxiaKnockAway")
	end
end

function BigWigsOnyxia:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["deepbreath_trigger"] and self.db.profile.deepbreath then
		self:TriggerEvent("BigWigs_Message", L["deepbreathnow_warn"], "Important", true, "Alert")
		
	elseif string.find(msg, L["phase1_trigger"]) then
		if (IsRaidLeader() or IsRaidOfficer()) then
			if klhtm.isloaded and klhtm.isenabled then
				klhtm.net.sendmessage("targetbw " ..boss)
			end
		end
		starttime = GetTime()
		if self.db.profile.wing then
			self:TriggerEvent("BigWigs_StartBar", self, L["wing_bar"], 12, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		end
		if self.db.profile.knock then
			self:TriggerEvent("BigWigs_StartBar", self, L["knock_bar"], 20, "Interface\\Icons\\Spell_Fire_Fire")
		end
	elseif string.find(msg, L["phase2_trigger"]) then
		self:TriggerEvent("BigWigs_StopBar", self, L["wing_bar"])
		self:TriggerEvent("BigWigs_StopBar", self, L["knock_bar"])
		if self.db.profile.phase2 then
			self:TriggerEvent("BigWigs_Message", L["phase2_warn"], "Urgent")
		end
		if self.db.profile.whelps then
			self:TriggerEvent("BigWigs_StartBar", self, L["whelps_bar"], 16, "Interface\\Icons\\INV_Misc_Head_Dragon_Black")
			self:ScheduleEvent("bwonyfirstwhelps", self.Whelps, 16, self)				
			self:ScheduleEvent("bwonywhelpsrepeater", self.WhelpsRepeater, 16, self)				
		end
	elseif string.find(msg, L["phase3_trigger"]) then
		if self.db.profile.phase3 then
			self:TriggerEvent("BigWigs_Message", L["phase3_warn"], "Urgent", true, "Alert")
		end
		
		self:CancelScheduledEvent("bwonywhelps")
		self:TriggerEvent("BigWigs_StopBar", self, L["whelps_bar"])
		
		if self.db.profile.fear then
			self:TriggerEvent("BigWigs_StartBar", self, L["fear_bar"], 5, "Interface\\Icons\\Spell_Fire_Fire")
		end

			--[[ disabled till onyxia is fixed
		if BigWigs:CheckYourPrivilege(UnitName("player")) then
			if klhtm.isloaded and klhtm.isenabled then
				klhtm.net.sendmessage("targetbw " ..boss)
				klhtm.net.clearraidthreat()
			end
		end
		--]]
	end
end

function BigWigsOnyxia:WhelpsRepeater()
	self:ScheduleRepeatingEvent("bwonywhelps", self.Whelps, 91, self)
end	

function BigWigsOnyxia:Whelps()
	self:TriggerEvent("BigWigs_StartBar", self, L["whelps_bar"], 91, "Interface\\Icons\\INV_Misc_Head_Dragon_Black")
end

