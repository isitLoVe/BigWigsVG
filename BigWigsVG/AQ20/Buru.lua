------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Buru the Gorger"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local burueggs

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
	
	eggs_cmd = "egg",
	eggs_name = "Alert for eggs",
	eggs_desc = "Counts eggs and shows if dmg has been done to Buru",

	watchtrigger = "sets eyes on (.+)!",
	watchwarn = " is being watched!",
	watchwarnyou = "You are being watched!",
	you = "You",
	
	eggsdead_trigger = "Buru Egg dies",
	
	eggsdead_message = "%d/10 eggs destroyed!",
	alleggsdead_message = "All eggs destroyed, NUKE IT!",
	
	eggsdmg_trigger = "Buru Egg Trigger",
	eggsdmg_message = "Buru lost 7% HP", --43832
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBuru = BigWigs:NewModule(boss)
BigWigsBuru.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsBuru.enabletrigger = boss
BigWigsBuru.toggleoptions = {"you", "other", "icon", "eggs", "bosskill"}
BigWigsBuru.revision = tonumber(string.sub("$Revision: 19011 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsBuru:OnEnable()
	burueggs = 0
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS")
	
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "BuruEggDead", 1)
	self:TriggerEvent("BigWigs_ThrottleSync", "BuruEggDmg", 1)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBuru:BigWigs_RecvSync(sync, rest)
	if sync == "BuruEggDmg" then
		self:TriggerEvent("BigWigs_Message", L["eggsdmg_message"], "Positive")
	elseif sync ~= "BuruEggDead" or not rest then return end
	rest = tonumber(rest)

	if rest == (burueggs + 1) then
		burueggs = burueggs + 1

		if burueggs > 9 and self.db.profile.eggs then
			self:TriggerEvent("BigWigs_Message", L["alleggsdead_message"], "Urgent")
		elseif self.db.profile.eggs then
			self:TriggerEvent("BigWigs_Message", string.format(L["eggsdead_message"], burueggs), "Positive")
		end
	end
end

function BigWigsBuru:GenericBossDeath( msg )
	if string.find(msg, L["eggsdead_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "BuruEggDead "..tostring(burueggs + 1))
	end
end


function BigWigsBuru:CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS( msg )
	if string.find(msg, L["eggsdmg_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "BuruEggDmg")
	end
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