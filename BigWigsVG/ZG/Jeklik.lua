------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priestess Jeklik"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Jeklik",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for healing",
	
	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for Terrifying Screech",

	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warn for Sonic Burst",
	
	bomb_cmd = "bomb",
	bomb_name = "Bomb Bat Alert",
	bomb_desc = "Warn for Bomb Bats",

	swarm_cmd = "swarm",
	swarm_name = "Bat Swarm Alert",
	swarm_desc = "Warn for the Bat swarms",

	swarm_trigger = "emits a deafening shriek",
	bomb_trigger = "I command you to rain fire down upon these invaders!",
	heal_trigger = "begins to cast Great Heal",
	fear_trigger = "afflicted by Terrifying Screech",
	silence_trigger = "afflicted by Sonic Burst",

	swarm_message = "Incoming bat swarm!",
	bomb_message = "Incoming bomb bats!",
	heal_message = "Casting heal!",
	
	fear_bar = "Terrifying Screech",
	fear_message = "Terrifying Screech in ~5 seconds",
	
	silence_bar = "Sonic Burst",
	silence_message = "Sonic Burst in ~5 seconds",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsJeklik = BigWigs:NewModule(boss)
BigWigsJeklik.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsJeklik.enabletrigger = boss
BigWigsJeklik.toggleoptions = {"swarm", "heal", "bomb", "fear", "silence", "bosskill"}
BigWigsJeklik.revision = tonumber(string.sub("$Revision: 19011 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsJeklik:OnEnable()
	started = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	--self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AbilityEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AbilityEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AbilityEvent")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "JeklikSilence", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "JeklikFear", 5)
end

------------------------------
--      Events              --
------------------------------

function BigWigsJeklik:CHAT_MSG_MONSTER_YELL(msg)
	if self.db.profile.bomb and string.find(msg, L["bomb_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["bomb_message"], "Attention")
	end
end

function BigWigsJeklik:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if self.db.profile.heal and string.find(msg, L["heal_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["heal_message"], "Urgent", nil, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["heal_message"], 4, "Interface\\Icons\\Spell_Holy_GreaterHeal")
	--elseif self.db.profile.swarm and string.find(msg, L["swarm_trigger"]) then
	--	self:TriggerEvent("BigWigs_Message", L["swarm_message"], "Urgent")
	end
end


function BigWigsJeklik:AbilityEvent(msg)
	if self.db.profile.silence and string.find(msg, L["silence_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "JeklikSilence")
	end
	if self.db.profile.fear and string.find(msg, L["fear_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "JeklikFear")
	end
end

function BigWigsJeklik:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		if self.db.profile.silence then
		self:ScheduleEvent("BigWigs_Message", 25, L["silence_message"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["silence_bar"], 30, "Interface\\Icons\\Spell_Shadow_Teleport")
		end
		if self.db.profile.fear then
			self:ScheduleEvent("BigWigs_Message", 8, L["fear_message"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["fear_bar"], 13, "Interface\\Icons\\Racial_Troll_Berserk")
		end
		
	elseif sync == "JeklikFear" then
		self:ScheduleEvent("BigWigs_Message", 15, L["fear_message"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["fear_bar"], 20, "Interface\\Icons\\Racial_Troll_Berserk")
	elseif sync == "JeklikSilence" then
		self:ScheduleEvent("BigWigs_Message", 15, L["silence_message"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["silence_bar"], 20, "Interface\\Icons\\Spell_Shadow_Teleport")
	end
end
