------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Ayamiss the Hunter"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Ayamiss",
	sacrifice_cmd = "sacrifice",
	sacrifice_name = "Sacrifice Alert",
	sacrifice_desc = "Warn for Sacrifice",

	sacrificetrigger = "^([^%s]+) ([^%s]+) afflicted by Paralyze",
	sacrificewarn = " is being Sacrificed!",
	sacrificebar = " is being Sacrificed!",
	larva = "Hive'Zara Larva",
	
	you = "You",
	are = "are",	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsAyamiss = BigWigs:NewModule(boss)
BigWigsAyamiss.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsAyamiss.enabletrigger = boss
BigWigsAyamiss.toggleoptions = {"sacrifice", "bosskill"}
BigWigsAyamiss.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsAyamiss:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath" )
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckSacrifice")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckSacrifice")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckSacrifice")
end

function BigWigsAyamiss:CheckSacrifice( msg )
	local _, _, player, type = string.find(msg, L["sacrificetrigger"])
	if (player and type) then
		if (player == L["you"] and type == L["are"]) then
			player = UnitName("player")
		end
		if self.db.profile.sacrifice then
			self:TriggerEvent("BigWigs_Message", player .. L["sacrificewarn"], "Important", "Alarm")
			self:TriggerEvent("BigWigs_StartBar", self, player .. L["sacrificebar"], 6, "Interface\\Icons\\Ability_Creature_Poison_05")
		end
	end
end


