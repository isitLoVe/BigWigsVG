------------------------------
--      Are you local?      --
------------------------------

local thane = AceLibrary("Babble-Boss-2.2")["Thane Korth'azz"]
local mograine = AceLibrary("Babble-Boss-2.2")["Highlord Mograine"]
local zeliek = AceLibrary("Babble-Boss-2.2")["Sir Zeliek"]
local blaumeux = AceLibrary("Babble-Boss-2.2")["Lady Blaumeux"]
local boss = AceLibrary("Babble-Boss-2.2")["The Four Horsemen"]

local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local times = nil

local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Horsemen",

	mark_cmd = "mark",
	mark_name = "Mark Alerts",
	mark_desc = "Warn for marks",

	shieldwall_cmd  = "shieldwall",
	shieldwall_name = "Shieldwall Alerts",
	shieldwall_desc = "Warn for shieldwall",

	void_cmd = "void",
	void_name = "Void Zone Alerts",
	void_desc = "Warn on Lady Blaumeux casting Void Zone.",

	meteor_cmd = "meteor",
	meteor_name = "Meteor Alerts",
	meteor_desc = "Warn on Thane casting Meteor.",

	wrath_cmd = "wrath",
	wrath_name = "Holy Wrath Alerts",
	wrath_desc = "Warn on Zeliek casting Wrath.",

	buff_cmd = "buff",
	buff_name = "Buff Alert",
	buff_desc = "Notify on Buffs Fading",

	markbar = "Mark %d",
	markwarn1 = "Mark %d!",
	markwarn2 = "Mark %d in 5 sec",
	marktrigger = "afflicted by Mark of ",

	voidtrigger = "cast Void Zone",
	voidtrigger2 = "casts Void Zone",
	--voidtrigger3 = "Consumption",
	voidwarn = "Void Zone Incoming!",
	voidbar = "Void Zone",
	voidzonewarn = "Move out of Void Zone",

	meteortrigger = "Meteor",
	meteorbar = "Meteor",

	wrathtrigger = "Holy Wrath",
	wrathbar = "Holy Wrath",

	startwarn = "The Four Horsemen Engaged! Mark in 20 sec",

	shieldwallbar = "%s - Shield Wall",
	shieldwalltrigger = "(.*) gains Shield Wall.",
	shieldwallwarn = "%s - Shield Wall for 20 sec",
	shieldwallwarn2 = "%s - Shield Wall GONE!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsHorsemen = BigWigs:NewModule(boss)
BigWigsHorsemen.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsHorsemen.enabletrigger = { thane, mograine, zeliek, blaumeux }
BigWigsHorsemen.toggleoptions = {"mark", "shieldwall", "buff", -1, "meteor", "void", "wrath", "bosskill"}
BigWigsHorsemen.revision = tonumber(string.sub("$Revision: 19007 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsHorsemen:OnEnable()
	self.marks = 1
	self.deaths = 0

	times = {}
	started = nil

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	-- creates error when loading ???
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "SkillEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "SkillEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "SkillEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "SkillEvent")
	self:RegisterEvent("CHAT_MSG_YELL", "SkillEvent")
	--Mark
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "SkillEvent")
	--Void Zone casts
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "VoidSkillEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE", "VoidSkillEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "VoidSkillEvent")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "HorsemenShieldWall3", 3)
	-- Upgraded to Horsemenxxx3 no more legacy addon problems
	self:TriggerEvent("BigWigs_ThrottleSync", "HorsemenMark3", 8)
	self:TriggerEvent("BigWigs_ThrottleSync", "HorsemenVoid3", 8)
	self:TriggerEvent("BigWigs_ThrottleSync", "HorsemenWrath3", 4)
	self:TriggerEvent("BigWigs_ThrottleSync", "HorsemenMeteor3", 8)
end

function BigWigsHorsemen:SkillEvent(msg)
	if string.find(msg, L["marktrigger"]) then
			self:TriggerEvent("BigWigs_SendSync", "HorsemenMark3 "..tostring(self.marks + 1))
	elseif string.find(msg, L["meteortrigger"]) then
			self:TriggerEvent("BigWigs_SendSync", "HorsemenMeteor3")
	elseif string.find(msg, L["wrathtrigger"]) then
			self:TriggerEvent("BigWigs_SendSync", "HorsemenWrath3")
	end
end

function BigWigsHorsemen:VoidSkillEvent(msg)
	if string.find(msg, L["voidtrigger"]) or string.find(msg, L["voidtrigger2"]) then
		self:TriggerEvent("BigWigs_SendSync", "HorsemenVoid3")
	end
end

function BigWigsHorsemen:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.mark then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, string.format( L["markbar"], self.marks), 20, "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde")
			self:ScheduleEvent("bwhorsemenmark2", "BigWigs_Message", 15, string.format( L["markwarn2"], self.marks ), "Urgent")
		end
		if self.db.profile.meteor then
			self:TriggerEvent("BigWigs_SendSync", "HorsemenMeteor3")
		end
		if self.db.profile.wrath then
		    self:TriggerEvent("BigWigs_SendSync", "HorsemenWrath3")
		end
		if self.db.profile.void then
		    self:TriggerEvent("BigWigs_SendSync", "HorsemenVoid3")
		end

		elseif sync == "HorsemenMark3" and rest then
		rest = tonumber(rest)
		if rest == nil then return end
		if rest == (self.marks + 1) then
			if self.db.profile.mark then
				self:TriggerEvent("BigWigs_Message", string.format( L["markwarn1"], self.marks ), "Important")
			end
			self.marks = self.marks + 1
			if self.db.profile.mark then 
				self:TriggerEvent("BigWigs_StartBar", self, string.format( L["markbar"], self.marks ), 20, "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde")
				self:ScheduleEvent("bwhorsemenmark2", "BigWigs_Message", 15, string.format( L["markwarn2"], self.marks ), "Urgent")
			end
		end
	elseif sync == "HorsemenMeteor3" then
		if self.db.profile.meteor then
			self:TriggerEvent("BigWigs_StartBar", self, L["meteorbar"], 12, "Interface\\Icons\\Spell_Fire_Fireball02")
		end
	elseif sync == "HorsemenWrath3" then
		if self.db.profile.wrath then
			self:TriggerEvent("BigWigs_StartBar", self, L["wrathbar"], 12, "Interface\\Icons\\Spell_Holy_Excorcism")
		end
	elseif sync == "HorsemenVoid3" then
		if self.db.profile.void then
			self:TriggerEvent("BigWigs_Message", L["voidwarn"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["voidbar"], 12, "Interface\\Icons\\Spell_Shadow_SealOfKings")
		end
	elseif sync == "HorsemenShieldWall3" and self.db.profile.shieldwall and rest then
		self:TriggerEvent("BigWigs_Message", string.format(L["shieldwallwarn"], rest), "Attention")
		self:ScheduleEvent("BigWigs_Message", 20, string.format(L["shieldwallwarn2"], rest), "Positive")
		self:TriggerEvent("BigWigs_StartBar", self, string.format(L["shieldwallbar"], rest), 20, "Interface\\Icons\\Ability_Warrior_ShieldWall")
	end
end

function BigWigsHorsemen:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	local _,_, mob = string.find(msg, L["shieldwalltrigger"])
	if mob then self:TriggerEvent("BigWigs_SendSync", "HorsemenShieldWall3 "..mob) end
end

function BigWigsHorsemen:CHAT_MSG_COMBAT_HOSTILE_DEATH( msg )
	if msg == string.format(UNITDIESOTHER, blaumeux) then
		self:CancelScheduledEvent("bwhorsemenvoid")
		self.deaths = self.deaths + 1
		if self.deaths == 4 then
			if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s have been defeated"], boss), "Bosskill", nil, "Victory") end
			self.core:ToggleModuleActive(self, false) end
	elseif msg == string.format(UNITDIESOTHER, thane ) or
		msg == string.format(UNITDIESOTHER, zeliek) or 
		msg == string.format(UNITDIESOTHER, mograine) then
		self.deaths = self.deaths + 1
		if self.deaths == 4 then
			if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s have been defeated"], boss), "Bosskill", nil, "Victory") end
			self.core:ToggleModuleActive(self, false)
		end
	end
end
