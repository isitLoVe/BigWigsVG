------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Jin'do the Hexxer"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Jindo",

	brainwash_cmd = "brainwash",
	brainwash_name = "Brainwash Totem Alert",
	brainwash_desc = "Warn for Brainwash Totems",

	healing_cmd = "healing",
	healing_name = "Healing Totem Alert",
	healing_desc = "Warn for Healing Totems",

	youcurse_cmd = "youcurse",
	youcurse_name = "You're cursed Alert",
	youcurse_desc = "Warn when you get cursed",

	elsecurse_cmd = "elsecurse",
	elsecurse_name = "Others are cursed Alert",
	elsecurse_desc = "Warn when others are cursed",

	icon_cmd = "icon",
	icon_name = "Place Icon",
	icon_desc = "Place a skull icon on the cursed person (requires promoted or higher)",

	triggerbrainwash = "Jin'do the Hexxer casts Summon Brain Wash Totem.",
	triggerhealing = "Jin'do the Hexxer casts Powerful Healing Ward.",
	triggerhealing_vg = "Powerful Healing Ward hits",
	
	triggercurse = "^([^%s]+) ([^%s]+) afflicted by Jin'do the Hexxer's Delusion.", -- CHECK
	triggercurse_vg = "^([^%s]+) ([^%s]+) afflicted by Delusions of Jin'do.", -- Welcome to VanillaGaming ;)

	warnbrainwash = "Brain Wash Totem!",
	warnhealing = "Healing Totem!",

	cursewarn_self = "You are cursed!",
	cursewarn_other = "%s is cursed!",

	start = "Welcome to da great show friends! Step right up to die!",

	you = "You",
	are = "are",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsJindo = BigWigs:NewModule(boss)
BigWigsJindo.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsJindo.enabletrigger = boss
BigWigsJindo.toggleoptions = {"youcurse", "elsecurse", "icon", -1, "brainwash", "healing", "bosskill"}
BigWigsJindo.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsJindo:OnEnable()
	playerName = UnitName("player")

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")

	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "HealingWardEvent")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "HealingWardEvent")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "HealingWardEvent")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "HealingWardEvent")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "JindoCurse", 5)
end

------------------------------
--      Events              --
------------------------------

function BigWigsJindo:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["start"]) then
	    --self:ScheduleRepeatingEvent("bwjindototembar", self.Totembar, 16, self)
		if self.db.profile.healing then
			self:TriggerEvent("BigWigs_StartBar", self, L["warnhealing"], 16, "Interface\\Icons\\Spell_Nature_MagicImmunity")
		end
	end
end

function BigWigsJindo:HealingWardEvent(msg)
	if string.find(msg, L["triggerhealing_vg"]) and self.db.profile.healing then
		self:Totembar()
	end
end

function BigWigsJindo:Totembar()
		self:ScheduleEvent("BigWigs_Message", 1, L["warnhealing"], "Urgent")
		self:ScheduleEvent("BigWigs_SetRaidIcon", 1.5, "Powerful Healing Ward")
		self:TriggerEvent("BigWigs_StartBar", self, L["warnhealing"], 16, "Interface\\Icons\\Spell_Nature_MagicImmunity")
end

function BigWigsJindo:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if self.db.profile.brainwash and msg == L["triggerbrainwash"] then
		self:TriggerEvent("BigWigs_Message", L["warnbrainwash"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["warnbrainwash"], 16, "Interface\\Icons\\Ability_Creature_Disease_02")
	elseif self.db.profile.healing and msg == L["triggerhealing"] then
		self:TriggerEvent("BigWigs_Message", L["warnhealing"], "Important" )
		self:TriggerEvent("BigWigs_StartBar", self, L["warnhealing"], 20, "Interface\\Icons\\Spell_Nature_MagicImmunity")
	end
end

function BigWigsJindo:BigWigs_RecvSync(sync, rest, nick)
	if sync ~= "JindoCurse" or not rest then return end
	local player = rest

	if player == playerName and self.db.profile.youcurse then
		self:TriggerEvent("BigWigs_Message", L["cursewarn_self"], "Personal", true)
		self:TriggerEvent("BigWigs_Message", string.format(L["cursewarn_other"], playerName), "Attention", nil, nil, true)
	elseif self.db.profile.elsecurse then
		self:TriggerEvent("BigWigs_Message", string.format(L["cursewarn_other"], player), "Attention")
		self:TriggerEvent("BigWigs_SendTell", player, L["cursewarn_self"])
	end

	if self.db.profile.icon then 
		self:TriggerEvent("BigWigs_SetRaidIcon", player)
	end
end

function BigWigsJindo:Event(msg)
	local _, _, baPlayer = string.find(msg, L["triggercurse_vg"])
	if baPlayer then
		if baPlayer == L["you"] then
			baPlayer = UnitName("player")
		end
		self:TriggerEvent("BigWigs_SendSync", "JindoCurse "..baPlayer)
	end
end


