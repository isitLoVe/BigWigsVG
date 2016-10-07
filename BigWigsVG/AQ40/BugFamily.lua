------------------------------
--      Are you local?      --
------------------------------

local kri = AceLibrary("Babble-Boss-2.2")["Lord Kri"]
local yauj = AceLibrary("Babble-Boss-2.2")["Princess Yauj"]
local vem = AceLibrary("Babble-Boss-2.2")["Vem"]
local boss = AceLibrary("Babble-Boss-2.2")["The Bug Family"]

local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local deaths = 0
local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "BugFamily",
	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for Fear",

	AoE_cmd = "AoE",
	AoE_name = "Toxic Volley",
	AoE_desc = "Warn for Toxic Volley",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for Heal",
	
	charge_cmd = "charge",
	charge_name = "Berserker Charge Alert",
	charge_desc = "Berserker Charge Alert and Timer",

	healtrigger = "Princess Yauj begins to cast Great Heal.",
	healbar = "Great Heal",
	healwarn = "Casting heal!",
	
	feartrigger = "afflicted by Panic",
	fearbar = "AoE Fear",
	fearwarn = "AoE Fear in 5 Seconds!",

	AoEtrigger = "afflicted by Toxic Volley",
	AoEbar = "Toxic Volley",
	AoEwarn = "Toxic Volley in 3 Seconds!",

	chargetrigger = "Berserker Charge",
	chargebar = "Berserker Charge",
	chargewarn = "Berserker Charge in 3 Seconds!",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBugFamily = BigWigs:NewModule(boss)
BigWigsBugFamily.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsBugFamily.enabletrigger = {kri, yauj, vem}
BigWigsBugFamily.toggleoptions = {"fear", "AoE", "heal", "charge", "bosskill"}
BigWigsBugFamily.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsBugFamily:OnEnable()
	started = nil
	deaths = 0
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "DeathCount")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "BugFamilyEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "BugFamilyEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "BugFamilyEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "BugFamilyEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "BugFamilyEvent")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "KriBolt", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "YaujHeal", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "YaujFear", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "VemCharge", 5)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBugFamily:BugFamilyEvent(msg)
	if string.find(msg, L["feartrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "YaujFear")
	elseif string.find(msg, L["AoEtrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "KriBolt")
	elseif string.find(msg, L["chargetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "VemCharge")
	end
end

function BigWigsBugFamily:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		self:TriggerEvent("BigWigs_StartBar", self, L["AoEbar"], 7, "Interface\\Icons\\Spell_Nature_Corrosivebreath")
		self:TriggerEvent("BigWigs_StartBar", self, L["fearbar"], 21, "Interface\\Icons\\Spell_Shadow_Possession")
		--self:TriggerEvent("BigWigs_StartBar", self, L["chargebar"], 13, "Interface\\Icons\\Ability_Warrior_Charge")
	elseif sync == "KriBolt" and self.db.profile.AoE then
		self:TriggerEvent("BigWigs_StartBar", self, L["AoEbar"], 12, "Interface\\Icons\\Spell_Nature_Corrosivebreath")
		self:ScheduleEvent("BigWigs_Message", 9, L["AoEwarn"], "Urgent")
	elseif sync == "YaujHeal" and self.db.profile.heal then
		--self:TriggerEvent("BigWigs_StartBar", self, L["healbar"], 30, "Interface\\Icons\\Spell_Holy_Heal")
		self:TriggerEvent("BigWigs_StartBar", self, L["healwarn"], 2, "Interface\\Icons\\Spell_Holy_Heal")
		self:TriggerEvent("BigWigs_Message", L["healwarn"], "Urgent")
	elseif sync == "YaujFear" and self.db.profile.fear then
		self:TriggerEvent("BigWigs_StartBar", self, L["fearbar"], 20, "Interface\\Icons\\Spell_Shadow_Possession")
		self:ScheduleEvent("BigWigs_Message", 35, L["fearwarn"], "Urgent", true, "Alarm")
	elseif sync == "VemCharge" and self.db.profile.charge then
		--self:TriggerEvent("BigWigs_StartBar", self, L["chargebar"], 10, "Interface\\Icons\\Ability_Warrior_Charge")
		--self:ScheduleEvent("BigWigs_Message", 5, L["chargewarn"], "Urgent", true, "Alarm")
	end
end

function BigWigsBugFamily:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if msg == L["healtrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "YaujHeal")
	end
end

function BigWigsBugFamily:DeathCount(msg)
	if (msg == string.format(UNITDIESOTHER, kri) or msg == string.format(UNITDIESOTHER, yauj) or msg == string.format(UNITDIESOTHER, vem)) then
		deaths = deaths + 1
		if (deaths == 3) then
			if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], boss), "Bosskill", nil, "Victory") end
			self.core:ToggleModuleActive(self, false)
		end
	end
end
