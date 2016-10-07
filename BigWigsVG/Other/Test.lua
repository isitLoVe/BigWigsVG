
------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsTest")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["test"] = true,
	["Test"] = true,
	["Test Bar"] = true,
	["Test Bar 2"] = true,
	["Test Bar 3"] = true,
	["Test Bar 4"] = true,
	["Testing"] = true,
	["OMG Bear!"] = true,
	["*RAWR*"] = true,
	["Victory!"] = true,
	["Options for testing."] = true,
	["local"] = true,
	["Local test"] = true,
	["Perform a local test of BigWigs."] = true,
	["sync"] = true,
	["Sync test"] = true,
	["Perform a sync test of BigWigs."] = true,
	["Testing Sync"] = true,
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsTest = BigWigs:NewModule(L["Test"])
BigWigsTest.revision = tonumber(string.sub("$Revision: 14954 $", 12, -3))

BigWigsTest.consoleCmd = L["test"]
BigWigsTest.consoleOptions = {
	type = "group",
	name = L["Test"],
	desc = L["Options for testing."],
	args   = {
		[L["local"]] = {
			type = "execute",
			name = L["Local test"],
			desc = L["Perform a local test of BigWigs."],
			func = function() BigWigsTest:TriggerEvent("BigWigs_Test") end,
		},
		[L["sync"]] = {
			type = "execute",
			name = L["Sync test"],
			desc = L["Perform a sync test of BigWigs."],
			func = function() BigWigsTest:TriggerEvent("BigWigs_SyncTest") end,
			disabled = function() return ( not IsRaidLeader() and not IsRaidOfficer() ) end,
		},
	}
}

function BigWigsTest:OnEnable()
	self:RegisterEvent("BigWigs_Test")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "TestSync", 5)
	self:RegisterEvent("BigWigs_SyncTest")
end


function BigWigsTest:BigWigs_SyncTest()
	self:TriggerEvent("BigWigs_SendSync", "TestSync")
end


function BigWigsTest:BigWigs_RecvSync(sync)
	if sync == "TestSync" then
		self:TriggerEvent("BigWigs_Message", L["Testing Sync"], "Positive")
		self:TriggerEvent("BigWigs_StartBar", self, L["Testing Sync"], 10, "Interface\\Icons\\Spell_Frost_FrostShock", true, "Green", "Blue", "Yellow", "Red")
	end
end


function BigWigsTest:BigWigs_Test()
	self:TriggerEvent("BigWigs_StartBar", self, L["Test Bar"], 15, "Interface\\Icons\\Spell_Nature_ResistNature")
	self:TriggerEvent("BigWigs_Message", L["Testing"], "Attention", true, "Long")
	self:ScheduleEvent("BigWigs_Message", 5, L["OMG Bear!"], "Important", true, "Alert")
	self:ScheduleEvent("BigWigs_Message", 10, L["*RAWR*"], "Urgent", true, "Alarm")
	self:ScheduleEvent("BigWigs_Message", 15, L["Victory!"], "Bosskill", true, "Victory")

	self:TriggerEvent("BigWigs_StartBar", self, L["Test Bar 2"], 10, "Interface\\Icons\\Spell_Nature_ResistNature")
	self:TriggerEvent("BigWigs_StartBar", self, L["Test Bar 3"], 5, "Interface\\Icons\\Spell_Nature_ResistNature")
	self:TriggerEvent("BigWigs_StartBar", self, L["Test Bar 4"], 3, "Interface\\Icons\\Spell_Nature_ResistNature", true, "black")
end

