------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Baron Geddon"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	bomb_trigger = "^([^%s]+) ([^%s]+) afflicted by Living Bomb",
	inferno_trigger = "Baron Geddon gains Inferno.",
	service_trigger = "%s performs one last service for Ragnaros.",
	ignitemana_trigger = "afflicted by Ignite Mana",
	
	you = "You",
	are = "are",

	bomb_message_you = "You are the bomb!",
	bomb_message_other = "%s is the bomb!",

	bombtimer_bar = "%s: Living Bomb",
	inferno_bar = "Inferno",
	inferno_bar_next = "Next Inferno",
	inferno_message = "5sec until Inferno!",
	service_bar = "Last Service",
	nextbomb_bar = "Next Bomb",
	
	ignitemana_bar = "Next Ignite Mana",
	ignitemana_message = "Ignite Mana in 5 sec!",
	
	service_message = "Last Service, Geddon exploding in 5sec!",

	cmd = "Baron",

	service_cmd = "service",
	service_name = "Last service",
	service_desc = "Timer bar for Geddon's last service.",

	inferno_cmd = "inferno",
	inferno_name = "Inferno",
	inferno_desc = "Timer bar for Geddons Inferno.",

	ignitemana_cmd = "ignitemana",
	ignitemana_name = "Ignite Mana",
	ignitemana_desc = "Timer bar for Geddons Ignite Mana.",
	
	bombtimer_cmd = "bombtimer",
	bombtimer_name = "Bar for when the bomb goes off",
	bombtimer_desc = "Shows a 8 second bar for when the bomb goes off at the target.",

	youbomb_cmd = "youbomb",
	youbomb_name = "You are the bomb alert",
	youbomb_desc = "Warn when you are the bomb",

	elsebomb_cmd = "elsebomb",
	elsebomb_name = "Someone else is the bomb alert",
	elsebomb_desc = "Warn when others are the bomb",

	icon_cmd = "icon",
	icon_name = "Raid Icon on bomb",
	icon_desc = "Put a Raid Icon on the person who's the bomb. (Requires promoted or higher)",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBaronGeddon = BigWigs:NewModule(boss)
BigWigsBaronGeddon.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsBaronGeddon.enabletrigger = boss
BigWigsBaronGeddon.toggleoptions = {"inferno", "ignitemana", "service", -1, "bombtimer", "youbomb", "elsebomb", "icon", "bosskill"}
BigWigsBaronGeddon.revision = tonumber(string.sub("$Revision: 19004 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsBaronGeddon:OnEnable()
	started = nil
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "GeddonBomb", 1)
	self:TriggerEvent("BigWigs_ThrottleSync", "GeddonInferno", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "GeddonIgniteMana", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBaronGeddon:Event(msg)
	if string.find(msg, L["ignitemana_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "GeddonIgniteMana")
	end
	local _, _, EPlayer, EType = string.find(msg, L["bomb_trigger"])
	if EPlayer and EType then
		if EPlayer == L["you"] and EType == L["are"] then
			EPlayer = UnitName("player")
		end
		self:TriggerEvent("BigWigs_SendSync", "GeddonBomb "..EPlayer)
	end
end

function BigWigsBaronGeddon:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if msg == L["inferno_trigger"] then
		self:TriggerEvent("BigWigs_SendSync", "GeddonInferno")
	end
end

function BigWigsBaronGeddon:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L["service_trigger"] and self.db.profile.service then
		self:TriggerEvent("BigWigs_StartBar", self, L["service_bar"], 5, "Interface\\Icons\\Spell_Shadow_MindBomb", "Red")
		self:TriggerEvent("BigWigs_Message", L["service_message"], "Important")
	end
end

function BigWigsBaronGeddon:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		if self.db.profile.bombtimer then
				self:TriggerEvent("BigWigs_StartBar", self, L["nextbomb_bar"], 35, "Interface\\Icons\\Spell_Shadow_MindBomb", "Red")
		end
		if self.db.profile.inferno then
			self:TriggerEvent("BigWigs_StartBar", self, L["inferno_bar_next"], 45, "Interface\\Icons\\Spell_Fire_SealOfFire", "Orange")
			self:ScheduleEvent("bwgeddoninfernowarn", "BigWigs_Message", 40, L["inferno_message"], "Urgent")
		end
		if self.db.profile.ignitemana then
			self:TriggerEvent("BigWigs_StartBar", self, L["ignitemana_bar"], 30, "Interface\\Icons\\Spell_Fire_Incinerate", "Orange")
			self:ScheduleEvent("bwgeddonignitemanawarn", "BigWigs_Message", 25, L["ignitemana_message"], "Urgent")
		end

	elseif sync == "GeddonBomb" and rest then
		local player = rest
		
		if player == UnitName("player") and self.db.profile.youbomb then
                        BigWigsThaddiusArrows:Direction("Geddon")

			self:TriggerEvent("BigWigs_Message", L["bomb_message_you"], "Personal", true, "Alarm")
			self:TriggerEvent("BigWigs_Message", string.format(L["bomb_message_other"], player), "Attention", nil, nil, true )
		elseif self.db.profile.elsebomb then
			self:TriggerEvent("BigWigs_Message", string.format(L["bomb_message_other"], player), "Attention")
			self:TriggerEvent("BigWigs_SendTell", player, L["bomb_message_you"])
		end

		if self.db.profile.bombtimer then
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["bombtimer_bar"], player), 8, "Interface\\Icons\\Spell_Shadow_MindBomb", "Red")
			self:TriggerEvent("BigWigs_StartBar", self, L["nextbomb_bar"], 35, "Interface\\Icons\\Spell_Shadow_MindBomb", "Red")
		end

		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", player)
		end
	elseif sync == "GeddonInferno" and self.db.profile.inferno then
		self:TriggerEvent("BigWigs_StartBar", self, L["inferno_bar"], 8, "Interface\\Icons\\Spell_Fire_SealOfFire", "Orange")
		self:CancelScheduledEvent("bwgeddoninfernowarn")
		self:TriggerEvent("BigWigs_StartBar", self, L["inferno_bar_next"], 45, "Interface\\Icons\\Spell_Fire_SealOfFire", "Orange")
		self:ScheduleEvent("bwgeddoninfernowarn", "BigWigs_Message", 40, L["inferno_message"], "Urgent")
	elseif sync == "GeddonIgniteMana" and self.db.profile.ignitemana then
		self:TriggerEvent("BigWigs_StartBar", self, L["ignitemana_bar"], 30, "Interface\\Icons\\Spell_Fire_Incinerate", "Orange")
		self:ScheduleEvent("bwgeddonignitemanawarn", "BigWigs_Message", 25, L["ignitemana_message"], "Urgent")
	end
end


