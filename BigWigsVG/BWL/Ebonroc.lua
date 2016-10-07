------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Ebonroc"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	wingbuffet_trigger = "cast Wing Buffet",
	shadowflame_trigger = "Ebonroc begins to cast Shadow Flame.",
	shadowcurse_trigger = "^([^%s]+) ([^%s]+) afflicted by Shadow of Ebonroc",

	you = "You",
	are = "are",

	startwarn = "Ebonroc Engaged! First Wing Buffet in 27 seconds!",
	wingbuffet_message = "Wing Buffet! 25sec to next!",
	wingbuffet_warning = "3sec to Wing Buffet!",
	shadowflame_warning = "Shadow Flame incoming!",
	shadowflame_message_you = "You have Shadow of Ebonroc!",
	shadowflame_message_other = " has Shadow of Ebonroc!",

	wingbuffet_bar = "Wing Buffet",
	shadowcurse_bar = "%s - Shadow of Ebonroc",
	shadowflame_bar = "Shadow Flame casting",

	shadowflamenext_bar = "Shadow Flame",
	shadowflamenext_message = "Shadow Flame soon",
	
	cmd = "Ebonroc",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet alert",
	wingbuffet_desc = "Warn for Wing Buffet",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",

	youcurse_cmd = "youcurse",
	youcurse_name = "Shadow of Ebonroc on you alert",
	youcurse_desc = "Warn when you got Shadow of Ebonroc",

	elsecurse_cmd = "elsecurse",
	elsecurse_name = "Shadow of Ebonroc on others alert",
	elsecurse_desc = "Warn when others got Shadow of Ebonroc",

	shadowbar_cmd = "cursebar",
	shadowbar_name = "Shadow of Ebonroc timer bar",
	shadowbar_desc = "Shows a timer bar when someone gets Shadow of Ebonroc",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsEbonroc = BigWigs:NewModule(boss)
BigWigsEbonroc.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsEbonroc.enabletrigger = boss
BigWigsEbonroc.toggleoptions = { "youcurse", "elsecurse", "shadowbar", -1, "wingbuffet", "shadowflame", -1, "bosskill" }
BigWigsEbonroc.revision = tonumber(string.sub("$Revision: 19004 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsEbonroc:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE ", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "EbonrocWingBuffet", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "EbonrocShadowflame", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsEbonroc:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["shadowflame_trigger"] then
		self:TriggerEvent("BigWigs_SendSync", "EbonrocShadowflame")
	elseif string.find(msg, L["wingbuffet_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "EbonrocWingBuffet")
	end
end

function BigWigsEbonroc:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		self:TriggerEvent("BigWigs_SendSync", "EbonrocStart")
	elseif sync == "EbonrocStart" then
		if self.db.profile.wingbuffet then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:ScheduleEvent("BigWigs_Message", 24, L["wingbuffet_warning"], "Important", true, "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 27, "Interface\\Icons\\Spell_Fire_SelfDestruct")
		end
		if self.db.profile.shadowflame then
			self:TriggerEvent("BigWigs_StartBar", self, L["shadowflamenext_bar"], 30, "Interface\\Icons\\Spell_Fire_Incinerate")
			self:ScheduleEvent("BigWigs_Message", 27, L["shadowflamenext_message"], "Important", true, "Alarm")
		end
	elseif sync == "EbonrocWingBuffet" and self.db.profile.wingbuffet then
		self:TriggerEvent("BigWigs_Message", L["wingbuffet_message"], "Important")
		self:ScheduleEvent("BigWigs_Message", 22, L["wingbuffet_warning"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["wingbuffet_bar"], 25, "Interface\\Icons\\Spell_Fire_SelfDestruct")
	elseif sync == "EbonrocShadowflame" and self.db.profile.shadowflame then
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 2.5, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflamenext_bar"], 15, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:ScheduleEvent("BigWigs_Message", 12, L["shadowflamenext_message"], "Important", true, "Alarm")
	end
end

function BigWigsEbonroc:Event(msg)
	local _,_, EPlayer, EType = string.find(msg, L["shadowcurse_trigger"])
	if (EPlayer and EType) then
		if (EPlayer == L["you"] and EType == L["are"] and self.db.profile.youcurse) then
			self:TriggerEvent("BigWigs_Message", L["shadowflame_message_you"], "Personal", true, "Alarm")
			self:TriggerEvent("BigWigs_Message", UnitName("player") ..  L["shadowflame_message_other"], "Attention", nil, nil, true)
		elseif (self.db.profile.elsecurse) then
			self:TriggerEvent("BigWigs_Message", EPlayer .. L["shadowflame_message_other"], "Urgent", true, "Alarm")
			self:TriggerEvent("BigWigs_SendTell", EPlayer, L["shadowflame_message_you"])
		end
		if self.db.profile.shadowbar then
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["shadowcurse_bar"], EPlayer), 8, "Interface\\Icons\\Spell_Shadow_GatherShadows")
		end
	end
end


