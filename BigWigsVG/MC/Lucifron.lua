------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Lucifron"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	trigger1 = "afflicted by Lucifron",
	trigger2 = "afflicted by Impending Doom",

	lucicurse_warn = "5 seconds until Lucifron's Curse!",
	lucicurse = "Lucifron's Curse - 15 seconds until next!",
	lucidoom_warn = "5 seconds until Impending Doom!",
	lucidoom = "Impending Doom - 20 seconds until next!",

	lucicurse_bar = "Lucifron's Curse",
	lucidoom_bar = "Impending Doom",

	cmd = "Lucifron",
	
	curse_cmd = "curse",
	curse_name = "Lucifron's Curse alert",
	curse_desc = "Warn for Lucifron's Curse",
	
	doom_cmd = "doom",
	doom_name = "Impending Doom alert",
	doom_desc = "Warn for Impending Doom",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsLucifron = BigWigs:NewModule(boss)
BigWigsLucifron.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsLucifron.enabletrigger = boss
BigWigsLucifron.toggleoptions = {"curse", "doom", "bosskill"}
BigWigsLucifron.revision = tonumber(string.sub("$Revision: 19008 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsLucifron:OnEnable()
	--self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsLucifron:BigWigs_RecvSync( sync, rest, nick )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.curse then
			self:TriggerEvent("BigWigs_Message", L["lucicurse"], "Important")
			self:ScheduleEvent("BigWigs_Message", 15, L["lucicurse_warn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["lucicurse_bar"], 20, "Interface\\Icons\\Spell_Shadow_BlackPlague")
		end
		if self.db.profile.doom then
			self:TriggerEvent("BigWigs_Message", L["lucidoom"], "Important")
			self:ScheduleEvent("BigWigs_Message", 5, L["lucidoom_warn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["lucidoom_bar"], 10, "Interface\\Icons\\Spell_Shadow_NightOfTheDead")
		end
	end
end
		
		
function BigWigsLucifron:Event(msg)
	if (string.find(msg, L["trigger1"]) and self.db.profile.curse) then
		self:TriggerEvent("BigWigs_Message", L["lucicurse"], "Important")
		self:ScheduleEvent("BigWigs_Message", 10, L["lucicurse_warn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["lucicurse_bar"], 15, "Interface\\Icons\\Spell_Shadow_BlackPlague")
	elseif (string.find(msg, L["trigger2"]) and self.db.profile.doom) then
		self:TriggerEvent("BigWigs_Message", L["lucidoom"], "Important")
		self:ScheduleEvent("BigWigs_Message", 15, L["lucidoom_warn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["lucidoom_bar"], 20, "Interface\\Icons\\Spell_Shadow_NightOfTheDead")
	end
end
