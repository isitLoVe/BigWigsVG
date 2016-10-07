------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Garr"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local prior

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	triggerdead = "Firesworn dies",
	
	banish_trigger = "Banish fades from Firesworn",

	addmsg = "%d/8 Firesworns dead!",
	banish_msg = "Banish fades!",
	banish_bar = "Banish",

	cmd = "Garr",
	
	adds_cmd = "adds",
	adds_name = "Garr's adds",
	adds_desc = "Mods for Garr's adds",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGarr = BigWigs:NewModule(boss)
BigWigsGarr.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsGarr.enabletrigger = boss
BigWigsGarr.toggleoptions = {"adds", "bosskill"}
BigWigsGarr.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGarr:OnEnable()
	self.adddead = 0

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "GarrAddDead", 1)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsGarr:GenericBossDeath(msg)
	if string.find(msg, L["triggerdead"]) then
		self:TriggerEvent("BigWigs_SendSync", "GarrAddDead "..tostring(self.adddead + 1) )
	end
end

function BigWigsGarr:BigWigs_RecvSync( sync, rest )
	if sync == "GarrAddDead" and rest then
		rest = tonumber(rest)
		if not rest then return end
		if rest == (self.adddead + 1) then
			self.adddead = self.adddead + 1
			if self.db.profile.adds then
				self:TriggerEvent("BigWigs_Message", string.format(L["addmsg"], self.adddead), "Positive")
			end
			if self.adddead == 8 then
				self.adddead = 0 -- reset counter
                         end
		end
	end
end

function BigWigsGarr:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["banish_trigger"]) then
			self:TriggerEvent("BigWigs_Message", L["banish_msg"], "Important", true, "Alarm")
	end
end
