------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Sapphiron"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local time
local started

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Sapphiron",

	deepbreath_cmd = "deepbreath",
	deepbreath_name = "Deep Breath alert",
	deepbreath_desc = "Warn when Sapphiron begins to cast Deep Breath.",

	lifedrain_cmd = "lifedrain",
	lifedrain_name = "Life Drain",
	lifedrain_desc = "Warns about the Life Drain curse.",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for berserk.",

	flight_cmd = "flight",
	flight_name = "Flight Timer",
	flight_desc = "Warn when Sapphiron starts flying.",
	flight_bar = "Airborne",

	
	berserk_bar = "Berserk",
	berserk_warn_10min = "10min to berserk!",
	berserk_warn_5min = "5min to berserk!",
	berserk_warn_rest = "%s sec to berserk!",

	engage_message = "Sapphiron engaged! Berserk in 15min!",

	lifedrain_message = "Life Drain!",
	lifedrain_warn1 = "Life Drain in 5sec!",
	lifedrain_bar = "Life Drain",

	lifedrain_trigger = "afflicted by Life Drain",
	lifedrain_trigger2 = "Life Drain was resisted by",

	deepbreath_incoming_message = "Ice Bomb casting in ~23sec!",
	deepbreath_incoming_soon_message = "Ice Bomb casting in ~5sec!",
	deepbreath_incoming_bar = "Ice Bomb Cast",
	deepbreath_trigger = "%s takes a deep breath...",
	deepbreath_warning = "Ice Bomb Incoming!",
	deepbreath_bar = "Ice Bomb Lands!",
	chill_trigger = "Chill",
	chill_warn = "Run from BLIZZARD!",
	sapphiron_dead = "Sapphiron dies",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSapphiron = BigWigs:NewModule(boss)
BigWigsSapphiron.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsSapphiron.enabletrigger = boss
BigWigsSapphiron.toggleoptions = { "berserk", "lifedrain", "deepbreath", "flight", "bosskill" }
BigWigsSapphiron.revision = tonumber(string.sub("$Revision: 19012 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsSapphiron:OnEnable()
	started = nil

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "LifeDrain")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "LifeDrain")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "LifeDrain")

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "SapphironLifeDrain", 4)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsSapphiron:BigWigs_RecvSync( sync, rest, nick )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		if self.db.profile.berserk then
			self:TriggerEvent("BigWigs_Message", L["engage_message"], "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, L["berserk_bar"], 900, "Interface\\Icons\\INV_Shield_01")
			self:ScheduleEvent("bwsapphberserk1", "BigWigs_Message", 300, L["berserk_warn_10min"], "Attention")
			self:ScheduleEvent("bwsapphberserk2", "BigWigs_Message", 600, L["berserk_warn_5min"], "Attention")
			self:ScheduleEvent("bwsapphberserk3", "BigWigs_Message", 840, string.format(L["berserk_warn_rest"], 60), "Urgent")
			self:ScheduleEvent("bwsapphberserk4", "BigWigs_Message", 870, string.format(L["berserk_warn_rest"], 30), "Important")
			self:ScheduleEvent("bwsapphberserk5", "BigWigs_Message", 890, string.format(L["berserk_warn_rest"], 10), "Important")
			self:ScheduleEvent("bwsapphberserk6", "BigWigs_Message", 895, string.format(L["berserk_warn_rest"], 5), "Important")
		end
		--VG initial flight timer
		if self.db.profile.flight then
			self:TriggerEvent("BigWigs_StartBar", self, L["flight_bar"], 50, "Interface\\Icons\\Spell_Frost_Wizardmark")
			self:ScheduleEvent("bwsapphirondeepbreathbar", "BigWigs_StartBar", 50, self, L["deepbreath_incoming_bar"], 26, "Interface\\Icons\\Spell_Arcane_PortalIronForge")
		end
		--VG initial drain life timer
		if self.db.profile.lifedrain then
			self:TriggerEvent("BigWigs_StartBar", self, L["lifedrain_bar"], 24, "Interface\\Icons\\Spell_Shadow_LifeDrain02")
		end
		self:ScheduleEvent("cancellifedrainbar", "BigWigs_StopBar", 50, self, L["lifedrain_bar"])
		
	elseif sync == "SapphironLifeDrain" and self.db.profile.lifedrain then
		self:TriggerEvent("BigWigs_Message", L["lifedrain_message"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["lifedrain_bar"], 24, "Interface\\Icons\\Spell_Shadow_LifeDrain02")
	end
end

function BigWigsSapphiron:LifeDrain(msg)
	if string.find(msg, L["lifedrain_trigger"]) or string.find(msg, L["lifedrain_trigger2"]) then
		self:TriggerEvent("BigWigs_SendSync", "SapphironLifeDrain")
	end
	if string.find(msg, L["chill_trigger"]) then
		self:CancelScheduledEvent("bwsapphironchill")
		self:ScheduleEvent("bwsapphironchill", self.Stopb, 3, self )
		self:TriggerEvent("BigWigs_Message", L["chill_warn"], "Personal", true, "Alarm")
		BigWigsOnScreenIcons:Direction("Blizzard")
	end
end

function BigWigsSapphiron:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L["deepbreath_trigger"] then
		if self.db.profile.deepbreath then
			self:TriggerEvent("BigWigs_Message", L["deepbreath_warning"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["deepbreath_bar"], 7, "Interface\\Icons\\Spell_Frost_FrostShock")
		end

		if self.db.profile.lifedrain then
			self:TriggerEvent("BigWigs_StartBar", self, L["lifedrain_bar"], 30, "Interface\\Icons\\Spell_Shadow_LifeDrain02")
		end
		self:ScheduleEvent("cancellifedrainbar", "BigWigs_StopBar", 69, self, L["lifedrain_bar"])

		--VG flight timer
		if self.db.profile.flight then
			self:TriggerEvent("BigWigs_StartBar", self, L["flight_bar"], 69, "Interface\\Icons\\Spell_Frost_Wizardmark")
			self:ScheduleEvent("bwsapphirondeepbreathbar", "BigWigs_StartBar", 69, self, L["deepbreath_incoming_bar"], 26, "Interface\\Icons\\Spell_Arcane_PortalIronForge")
		end
	end
end

function BigWigsSapphiron:Stopb()
	BigWigsOnScreenIcons:Blizzardstop()
end

function BigWigsSapphiron:GenericBossDeath( msg )
	if string.find(msg, L["sapphiron_dead"]) then
		BigWigsOnScreenIcons:Blizzardstop()
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s have been defeated"], boss), "Bosskill", nil, "Victory") end
		self.core:ToggleModuleActive(self, false)
	end
end

