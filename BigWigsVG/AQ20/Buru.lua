------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Buru the Gorger"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Buru",

	you_cmd = "you",
	you_name = "You're being watched alert",
	you_desc = "Warn when you're being watched",

	other_cmd = "other",
	other_name = "Others being watched alert",
	other_desc = "Warn when others are being watched",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on watched person (requires promoted or higher)",

	watchtrigger = "sets eyes on (.+)!",
	watchwarn = " is being watched!",
	watchwarnyou = "You are being watched!",
	you = "You",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBuru = BigWigs:NewModule(boss)
BigWigsBuru.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsBuru.enabletrigger = boss
BigWigsBuru.toggleoptions = {"you", "other", "icon", "bosskill"}
BigWigsBuru.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsBuru:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

function BigWigsBuru:CHAT_MSG_MONSTER_EMOTE( msg )
	if GetLocale() == "koKR" then
		msg = string.gsub(msg, "%%s|1이;가; ", "")
	end
	local _, _, player = string.find(msg, L["watchtrigger"])
	if player then
		if player == L["you"] and self.db.profile.you then
			player = UnitName("player")
			self:TriggerEvent("BigWigs_Message", L["watchwarnyou"], "Personal", true)
			self:TriggerEvent("BigWigs_Message", UnitName("player") .. L["watchwarn"], "Attention", nil, nil, true)
		elseif self.db.profile.other then
			self:TriggerEvent("BigWigs_Message", player .. L["watchwarn"], "Attention")
			self:TriggerEvent("BigWigs_SendTell", player, L["watchwarnyou"])
		end

		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", player )
		end
	end
end


