------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Ossirian the Unscarred"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Ossirian",

	supreme_cmd = "supreme",
	supreme_name = "Supreme Alert",
	supreme_desc = "Warn for Supreme Mode",

	debuff_cmd = "debuff",
	debuff_name = "Debuff Alert",
	debuff_desc = "Warn for Defuff",

	supremetrigger = "Ossirian the Unscarred gains Strength of Ossirian.",
	supremewarn = "Ossirian Supreme Mode!",
	supremedelaywarn = "Supreme in %d seconds!",
	failtrigger = "I...have...failed.",

	debufftriggerS = "Ossirian the Unscarred is afflicted by Shadow Weakness.",
	debufftriggerF = "Ossirian the Unscarred is afflicted by Fire Weakness.",
	debufftriggerFR = "Ossirian the Unscarred is afflicted by Frost Weakness.",
	debufftriggerN = "Ossirian the Unscarred is afflicted by Nature Weakness.",
	debufftriggerA = "Ossirian the Unscarred is afflicted by Arcane Weakness.",

	debuffwarnS = "Ossirian now weak to Shadow!",
	debuffwarnF = "Ossirian now weak to Fire!",
	debuffwarnFR = "Ossirian now weak to Frost!",
	debuffwarnN = "Ossirian now weak to Nature!",
	debuffwarnA = "Ossirian now weak to Arcane!",

	bartext = "Supreme",
	expose = "Expose",
	windtrigger = "Enveloping Winds",
	boomtrigger = "War Stomp",
	tankwind = "Tank switched!",
	boom_inc = "War Stomp in 5sec!",

	["Shadow"] = true,
	["Fire"] = true,
	["Frost"] = true,
	["Nature"] = true,
	["Arcane"] = true,
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsOssirian = BigWigs:NewModule(boss)
BigWigsOssirian.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsOssirian.enabletrigger = boss
BigWigsOssirian.toggleoptions = {"supreme", "debuff", "bosskill"}
BigWigsOssirian.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsOssirian:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "DEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "DEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "DEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "DEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "DEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "DEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "WeakS", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "WeakF", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "WeakFR", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "WeakN", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "WeakA", 10)
end

function BigWigsOssirian:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if self.db.profile.supreme and arg1 == L["supremetrigger"] then
		self:TriggerEvent("BigWigs_Message", L["supremewarn"], "Attention")
	end
end

function BigWigsOssirian:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.supreme and string.find(msg, L["failtrigger"]) then
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 45, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
	end
end

function BigWigsOssirian:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE( msg )
	if string.find(msg, L["debufftriggerS"]) then
		self:TriggerEvent("BigWigs_SendSync", "WeakS")
	elseif string.find(msg, L["debufftriggerF"]) then
		self:TriggerEvent("BigWigs_SendSync", "WeakF")
	elseif string.find(msg, L["debufftriggerFR"]) then
		self:TriggerEvent("BigWigs_SendSync", "WeakFR")
	elseif string.find(msg, L["debufftriggerN"]) then
		self:TriggerEvent("BigWigs_SendSync", "WeakN")
	elseif string.find(msg, L["debufftriggerA"]) then
		self:TriggerEvent("BigWigs_SendSync", "WeakA")
	end
end

function BigWigsOssirian:BigWigs_RecvSync(sync)
	if sync == "Boom" then
			self:TriggerEvent("BigWigs_StartBar", self, L["boomtrigger"], 30, "Interface\\Icons\\Ability_BullRush")
		        self:ScheduleEvent("BigWigs_Message", 25, L["boom_inc"], "Important", true, "Alarm")
            if (UnitClass("player") == "Warrior") or (UnitClass("player") == "Rogue") then
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 25) end
	elseif sync == "Wind" then
		        self:TriggerEvent("BigWigs_Message", L["tankwind"], "Attention", true, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, L["windtrigger"], 20, "Interface\\Icons\\Spell_Nature_Cyclone")
	elseif sync == "WeakS" then
		self:TriggerEvent("BigWigs_Message", L["debuffwarnS"], "Positive")
	        self:CancelScheduledEvent("bwossiriansupreme1")
	        self:CancelScheduledEvent("bwossiriansupreme2")
	        self:CancelScheduledEvent("bwossiriansupreme3")
	        self:TriggerEvent("BigWigs_StopBar", self, L["bartext"])
		self:ScheduleEvent("bwossiriansupreme1", "BigWigs_Message", 30, string.format(L["supremedelaywarn"], 15), "Attention")
		self:ScheduleEvent("bwossiriansupreme2", "BigWigs_Message", 35, string.format(L["supremedelaywarn"], 10), "Urgent")
		self:ScheduleEvent("bwossiriansupreme3", "BigWigs_Message", 40, string.format(L["supremedelaywarn"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 45, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
	elseif sync == "WeakF" then
		self:TriggerEvent("BigWigs_Message", L["debuffwarnF"], "Positive")
	        self:CancelScheduledEvent("bwossiriansupreme1")
	        self:CancelScheduledEvent("bwossiriansupreme2")
	        self:CancelScheduledEvent("bwossiriansupreme3")
	        self:TriggerEvent("BigWigs_StopBar", self, L["bartext"])
		self:ScheduleEvent("bwossiriansupreme1", "BigWigs_Message", 30, string.format(L["supremedelaywarn"], 15), "Attention")
		self:ScheduleEvent("bwossiriansupreme2", "BigWigs_Message", 35, string.format(L["supremedelaywarn"], 10), "Urgent")
		self:ScheduleEvent("bwossiriansupreme3", "BigWigs_Message", 40, string.format(L["supremedelaywarn"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 45, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
	elseif sync == "WeakFR" then
		self:TriggerEvent("BigWigs_Message", L["debuffwarnFR"], "Positive")
	        self:CancelScheduledEvent("bwossiriansupreme1")
	        self:CancelScheduledEvent("bwossiriansupreme2")
	        self:CancelScheduledEvent("bwossiriansupreme3")
	        self:TriggerEvent("BigWigs_StopBar", self, L["bartext"])
		self:ScheduleEvent("bwossiriansupreme1", "BigWigs_Message", 30, string.format(L["supremedelaywarn"], 15), "Attention")
		self:ScheduleEvent("bwossiriansupreme2", "BigWigs_Message", 35, string.format(L["supremedelaywarn"], 10), "Urgent")
		self:ScheduleEvent("bwossiriansupreme3", "BigWigs_Message", 40, string.format(L["supremedelaywarn"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 45, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
	elseif sync == "WeakN" then
		self:TriggerEvent("BigWigs_Message", L["debuffwarnN"], "Positive")
	        self:CancelScheduledEvent("bwossiriansupreme1")
	        self:CancelScheduledEvent("bwossiriansupreme2")
	        self:CancelScheduledEvent("bwossiriansupreme3")
	        self:TriggerEvent("BigWigs_StopBar", self, L["bartext"])
		self:ScheduleEvent("bwossiriansupreme1", "BigWigs_Message", 30, string.format(L["supremedelaywarn"], 15), "Attention")
		self:ScheduleEvent("bwossiriansupreme2", "BigWigs_Message", 35, string.format(L["supremedelaywarn"], 10), "Urgent")
		self:ScheduleEvent("bwossiriansupreme3", "BigWigs_Message", 40, string.format(L["supremedelaywarn"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 45, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
	elseif sync == "WeakA" then
		self:TriggerEvent("BigWigs_Message", L["debuffwarnA"], "Positive")
	        self:CancelScheduledEvent("bwossiriansupreme1")
	        self:CancelScheduledEvent("bwossiriansupreme2")
	        self:CancelScheduledEvent("bwossiriansupreme3")
	        self:TriggerEvent("BigWigs_StopBar", self, L["bartext"])
		self:ScheduleEvent("bwossiriansupreme1", "BigWigs_Message", 30, string.format(L["supremedelaywarn"], 15), "Attention")
		self:ScheduleEvent("bwossiriansupreme2", "BigWigs_Message", 35, string.format(L["supremedelaywarn"], 10), "Urgent")
		self:ScheduleEvent("bwossiriansupreme3", "BigWigs_Message", 40, string.format(L["supremedelaywarn"], 5), "Important")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 45, "Interface\\Icons\\Spell_Shadow_CurseOfTounges")
	end
end

function BigWigsOssirian:DEvent(msg)
	if string.find(msg, L["boomtrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "Boom")
	elseif string.find(msg, L["windtrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "Wind")
	end
end
