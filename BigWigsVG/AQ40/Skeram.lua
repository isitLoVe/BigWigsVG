------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["The Prophet Skeram"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local skeramstarted = nil
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	aetrigger = "The Prophet Skeram begins to cast Arcane Explosion.",
	mctrigger = "The Prophet Skeram begins to cast True Fulfillment.",
	splittrigger = "The Prophet Skeram casts Summon Images.",
	splittriggervg = "Prepare for the return of the ancient ones!",

	aewarn = "Casting Arcane Explosion!",
	mcwarn = "Casting Mind Control!",
	mcplayer = "^([^%s]+) ([^%s]+) afflicted by True Fulfillment.$",
	mcplayerwarn = "%s is mindcontrolled!",
	mcbar = "MC: %s",
	mcyou = "You",
	mcare = "are",

	win = "The Prophet Skeram has been defeated",


	pull1	= "Cower mortals!",
	pull2	= "Are you so eager to die?",
	pull3	= "Tremble!",
	
	splitwarn = "Splitting!",
	win = "You only delay... The inevitable...",

	telewarn = "Teleport in 5sec!",
	bartext = "Teleport",

	cmd = "Skeram",
	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",

	ae_cmd = "ae",
	ae_name = "Arcane Explosion Alert",
	ae_desc = "Warn for Arcane Explosion",
	
	split_cmd = "split",
	split_name = "Split Alert",
	split_desc = "Warn before Create Image",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSkeram = BigWigs:NewModule(boss)
BigWigsSkeram.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsSkeram.enabletrigger = boss
BigWigsSkeram.toggleoptions = {"ae", "mc", "split", "bosskill"}
BigWigsSkeram.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsSkeram:OnEnable()
	skeramstarted = nil
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
end

------------------------------
--      Event Handlers      --
------------------------------

-- Note that we do not sync the MC at the moment, since you really only care
-- about people that are MC'ed close to you anyway.
function BigWigsSkeram:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE(msg)
	local _,_, player, type = string.find(msg, L["mcplayer"])
	if player and type then
		if player == L["mcyou"] and type == L["mcare"] then
			player = UnitName("player")
		end
		if self.db.profile.mc then
			self:TriggerEvent("BigWigs_Message", string.format(L["mcplayerwarn"], player), "Important")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["mcbar"], player), 20, "Interface\\Icons\\Spell_Shadow_ShadowWordDominate")
		end
	end
end


function BigWigsSkeram:CHAT_MSG_MONSTER_YELL(msg)
    if string.find(msg, L["win"]) then 
        self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], self:ToString()), "Bosskill", nil, "Victory")
		self.core:ToggleModuleActive(self, false)
	elseif string.find(msg, L["splittriggervg"]) and self.db.profile.split then
		self:TriggerEvent("BigWigs_Message", L["splitwarn"], "Important")
    end
end


function BigWigsSkeram:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["aetrigger"] and self.db.profile.ae then
		self:TriggerEvent("BigWigs_Message", L["aewarn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["aewarn"], 1, "Interface\\Icons\\Spell_Nature_WispSplode")
	elseif msg == L["mctrigger"] and self.db.profile.mc then
		self:TriggerEvent("BigWigs_Message", L["mcwarn"], "Urgent")
	elseif msg == L["splittrigger"] and self.db.profile.split then
		self:TriggerEvent("BigWigs_Message", L["splitwarn"], "Important")
	end
end
