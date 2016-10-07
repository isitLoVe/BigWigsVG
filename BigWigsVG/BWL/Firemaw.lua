------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Firemaw"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	wingbuffet_trigger = "cast Wing Buffet",
	shadowflame_trigger = "Firemaw begins to cast Shadow Flame.",
    flame_trigger = "afflicted by Flame Buffet",

	startwarn = "Firemaw Engaged! First Wing Buffet in 25 seconds!",
	wingbuffet_message = "Wing Buffet! 50sec to next!",
	wingbuffet_warning = "3sec to Wing Buffet!",
	shadowflame_warning = "Shadow Flame Incoming!",

	wingbuffet_bar = "Wing Buffet",
	shadowflame_bar = "Shadow Flame casting",
	flamebuffet_bar = "Flame Buffet",
	
	shadowflamenext_bar = "Shadow Flame",
	shadowflamenext_message = "Shadow Flame soon",
	
	cmd = "Firemaw",


	flamebuffet_cmd = "flamebuffet",
	flamebuffet_name = "Flame Buffet alert",
	flamebuffet_desc = "Warn for Flame Buffet next proc",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn for Wing Buffet",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFiremaw = BigWigs:NewModule(boss)
BigWigsFiremaw.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsFiremaw.enabletrigger = boss
BigWigsFiremaw.toggleoptions = {"wingbuffet", "flamebuffet", "shadowflame", "bosskill"}
BigWigsFiremaw.revision = tonumber(string.sub("$Revision: 19008 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFiremaw:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FiremawWingBuffet", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "FiremawShadowflame", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsFiremaw:Event(msg)
	if string.find(msg, L["flame_trigger"]) and self.db.profile.flamebuffet then
		self:TriggerEvent("BigWigs_StartBar", self, L["flamebuffet_bar"], 5, "Interface\\Icons\\Spell_Fire_Fireball")
	end
end

function BigWigsFiremaw:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["wingbuffet_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "FiremawWingBuffet")
	elseif msg == L["shadowflame_trigger"] then 
		self:TriggerEvent("BigWigs_SendSync", "FiremawShadowflame")
	end
end

function BigWigsFiremaw:BigWigs_RecvSync( sync, rest )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		self:TriggerEvent("BigWigs_SendSync", "FiremawStart")
	elseif sync == "FiremawStart" then
		if self.db.profile.wingbuffet then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:ScheduleEvent("BigWigs_Message", 22, L["wingbuffet_warning"], "Important", true, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		end
		if self.db.profile.shadowflame then
			self:TriggerEvent("BigWigs_StartBar", self, L["shadowflamenext_bar"], 30, "Interface\\Icons\\Spell_Fire_Incinerate")
			self:ScheduleEvent("BigWigs_Message", 27, L["shadowflamenext_message"], "Important", true, "Alarm")
		end
		if self.db.profile.flamebuffet then
			self:TriggerEvent("BigWigs_StartBar", self, L["flamebuffet_bar"], 5, "Interface\\Icons\\Spell_Fire_Fireball")
		end
	elseif sync == "FiremawWingBuffet" and self.db.profile.wingbuffet then
		self:TriggerEvent("BigWigs_Message", L["wingbuffet_message"], "Important")
		self:ScheduleEvent("BigWigs_Message", 22, L["wingbuffet_warning"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	elseif sync == "FiremawShadowflame" and self.db.profile.shadowflame then
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 2.5, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflamenext_bar"], 15, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:ScheduleEvent("BigWigs_Message", 12, L["shadowflamenext_message"], "Important", true, "Alarm")
	end
end
