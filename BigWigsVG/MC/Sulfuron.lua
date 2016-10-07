------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Sulfuron Harbinger"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local prior

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	triggerdead = "Flamewaker Priest",
	triggercast = "begins to cast Dark Mending",
	healbar = "Heal",
	healwarn = "Healing!",

	addmsg = "%d/4 Priests dead!",

	cmd = "Sulfuron",
	
	adds_cmd = "adds",
	adds_name = "Sulf's adds",
	adds_desc = "Mods for Sulf's adds",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSulfuron = BigWigs:NewModule(boss)
BigWigsSulfuron.zonename = AceLibrary("Babble-Zone-2.2")["Molten Core"]
BigWigsSulfuron.enabletrigger = boss
BigWigsSulfuron.toggleoptions = {"adds", "bosskill"}
BigWigsSulfuron.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsSulfuron:OnEnable()
	self.adddead = 0

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "SulfAddDead", 2)
	self:TriggerEvent("BigWigs_ThrottleSync", "SulfHeal", 2)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsSulfuron:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if string.find(msg, L["triggerdead"]) then
		self:TriggerEvent("BigWigs_SendSync", "SulfAddDead "..tostring(self.adddead + 1) )
	else
		self:GenericBossDeath(msg)
	end
end

function BigWigsSulfuron:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if string.find(msg, L["triggercast"]) then
		self:TriggerEvent("BigWigs_SendSync", "SulfHeal")
	end
end

function BigWigsSulfuron:BigWigs_RecvSync( sync, rest )
	if sync == "SulfAddDead" and rest then
		rest = tonumber(rest)
		if not rest then return end
		if rest == (self.adddead + 1) then
			self.adddead = self.adddead + 1
			if self.db.profile.adds then
				self:TriggerEvent("BigWigs_Message", string.format(L["addmsg"], self.adddead), "Positive")
			end
			if self.adddead == 4 then
				self.adddead = 0 -- reset counter
                         end
		end
	elseif sync == "SulfHeal" then
		self:TriggerEvent("BigWigs_Message", L["healwarn"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["healbar"], 2, "Interface\\Icons\\Spell_Holy_Heal")
	end
end
