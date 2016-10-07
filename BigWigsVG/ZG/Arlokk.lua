------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priestess Arlokk"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local playerName = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Arlokk",

	youmark_cmd = "youmark",
	youmark_name = "You're marked alert",
	youmark_desc = "Warn when you are marked",

	othermark_cmd = "othermark",
	othermark_name = "Others are marked alert",
	othermark_desc = "Warn when others are marked",

	icon_cmd = "icon",
	icon_name = "Place Icon",
	icon_desc = "Place a skull icon on the marked person (requires promoted or higher)",

	mark_trigger = "Feast on ([^%s]+), my pretties!$",

	mark_warning_self = "You are marked!",
	mark_warning_other = "%s is marked!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsArlokk = BigWigs:NewModule(boss)
BigWigsArlokk.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsArlokk.enabletrigger = boss
BigWigsArlokk.toggleoptions = {"youmark", "othermark", "icon", "bosskill"}
BigWigsArlokk.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsArlokk:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
end

------------------------------
--      Events              --
------------------------------

function BigWigsArlokk:CHAT_MSG_MONSTER_YELL( msg )
	local _,_, n = string.find(msg, L["mark_trigger"])
	if n then
		if n == playerName and self.db.profile.youmark then
			self:TriggerEvent("BigWigs_Message", L["mark_warning_self"], "Important", true, "Alarm")
			self:TriggerEvent("BigWigs_Message", string.format(L["mark_warning_other"], UnitName("player")), "Attention", nil, nil, true)
		elseif self.db.profile.othermark then
			self:TriggerEvent("BigWigs_Message", string.format(L["mark_warning_other"], n), "Attention")
			self:TriggerEvent("BigWigs_SendTell", n, L["mark_warning_self"])
		end

		if self.db.profile.icon then
			self:TriggerEvent("BigWigs_SetRaidIcon", n)
		end

	end
end


