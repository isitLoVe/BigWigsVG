------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Gahz'ranka"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Gahzranka",

	slam_cmd = "slam",
	slam_name = "Gahz'ranka Slam Alert",
	slam_desc = "Warn for Gahz'ranka Slam",
	
	slam_trigger = "Gahz'ranka Slam",
	slam_bar = "Gahz'ranka Slam",
	slam_warn = "Gahz'ranka Slam in ~5sec",
	
	
	frost_cmd = "frost",
	frost_name = "Frost Breath Alert",
	frost_desc = "Warn for Frost Breath",
	
	frost_trigger = "Frost Breath",
	frost_bar = "Frost Breath",
	frost_warn = "Frost Breath in ~5sec",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGahzranka = BigWigs:NewModule(boss)
BigWigsGahzranka.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsGahzranka.enabletrigger = boss
BigWigsGahzranka.toggleoptions = {"slam", "frost", "bosskill"}
BigWigsGahzranka.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------
--frost 10 sec

function BigWigsGahzranka:OnEnable()

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "SpellEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "SpellEvent")

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "GahzrankaFrost", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "GahzrankaSlam", 5)
	
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsGahzranka:BigWigs_RecvSync(sync, rest)	
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.frost then
			self:TriggerEvent("BigWigs_StartBar", self, L["frost_bar"], 10, "Interface\\Icons\\Spell_Frost_FrostNova")
			--self:ScheduleEvent("BigWigs_Message", 5, L["frost_warn"], "Important")
		end
		if self.db.profile.slam then
			self:TriggerEvent("BigWigs_StartBar", self, L["slam_bar"], 30, "Interface\\Icons\\Ability_Devour")
			self:ScheduleEvent("BigWigs_Message", 25, L["slam_warn"], "Important")
		end
	elseif sync == "GahzrankaFrost" and self.db.profile.frost then
		self:TriggerEvent("BigWigs_StartBar", self, L["frost_bar"], 10, "Interface\\Icons\\Spell_Frost_FrostNova")
		--self:ScheduleEvent("BigWigs_Message", 5, L["frost_warn"], "Important")
	elseif sync == "GahzrankaSlam" and self.db.profile.slam then
		self:TriggerEvent("BigWigs_StartBar", self, L["slam_bar"], 25, "Interface\\Icons\\Ability_Devour")
		self:ScheduleEvent("BigWigs_Message", 20, L["slam_warn"], "Important")
	end
end

function BigWigsGahzranka:SpellEvent( msg )
	if string.find(msg, L["slam_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "GahzrankaSlam")
	elseif string.find(msg, L["frost_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "GahzrankaFrost")
	end
end