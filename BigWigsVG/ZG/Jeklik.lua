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

	bomb_cmd = "bomb",
	bomb_name = "Bomb Bat Alert",
	bomb_desc = "Warn for Bomb Bats",

	swarm_cmd = "swarm",
	swarm_name = "Bat Swarm Alert",
	swarm_desc = "Warn for the Bat swarms",

	swarm_trigger = "emits a deafening shriek",
	bomb_trigger = "I command you to rain fire down upon these invaders!",
	heal_trigger = "begins to cast a Great Heal!",

	swarm_message = "Incoming bat swarm!",
	bomb_message = "Incoming bomb bats!",
	heal_message = "Casting heal!",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsJeklik = BigWigs:NewModule(boss)
BigWigsJeklik.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsJeklik.enabletrigger = boss
BigWigsJeklik.toggleoptions = {"swarm", "heal", "bomb", "bosskill"}
BigWigsJeklik.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsJeklik:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsJeklik:CHAT_MSG_MONSTER_YELL(msg)
	if self.db.profile.bomb and string.find(msg, L["bomb_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["bomb_message"], "Attention")
	end
end

function BigWigsJeklik:CHAT_MSG_MONSTER_EMOTE(msg)
	if self.db.profile.heal and string.find(msg, L["heal_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["heal_message"], "Urgent", "Alert")
	elseif self.db.profile.swarm and string.find(msg, L["swarm_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["swarm_message"], "Urgent")
	end
end


