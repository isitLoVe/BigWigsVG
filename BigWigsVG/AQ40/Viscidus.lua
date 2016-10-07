------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Viscidus"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local prior

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Viscidus",
	volley_cmd = "volley",
	volley_name = "Poison Volley Alert",
	volley_desc = "Warn for Poison Volley",

	toxinyou_cmd = "toxinyou",
	toxinyou_name = "Toxin Cloud on You Alert",
	toxinyou_desc = "Warn if you are standing in a toxin cloud",

	toxinother_cmd = "toxinother",
	toxinother_name = "Toxin Cloud on Others Alert",
	toxinother_desc = "Warn if others are standing in a toxin cloud",

	freeze_cmd = "freeze",
	freeze_name = "Freezing States Alert",
	freeze_desc = "Warn for the different frozen states",

	freeze_trigger = "Viscidus Freeze",
	freeze_message = "Viscudus Freezed!",
	freeze_bar = "Viscidus Freezed",

	GNPPtrigger	= "Nature Protection",
	trigger1 	= "begins to slow!",
	trigger2 	= "is freezing up!",
	trigger3 	= "is frozen solid!",
	trigger4 	= "begins to crack!",
	trigger5 	= "looks ready to shatter!",
	trigger6	= "afflicted by Poison Bolt Volley",
	trigger7 	= "^([^%s]+) ([^%s]+) afflicted by Toxin%.$",
	trigger         = "Toxin",

	you 		= "You",
	are 		= "are",

	warn1 		= "First freeze phase!",
	warn2 		= "Second freeze phase!",
	warn3 		= "Viscidus is frozen!",
	warn4 		= "Cracking up - little more now!",
	warn5 		= "Cracking up - almost there!",
	warn6		= "Poison Bolt Volley!",
	warn7		= "Poison Bolt Volley in ~3 sec!",
	warn8		= " is in a toxin cloud!",
	warn9		= "You are in the toxin cloud!",
	firewarn = "Run from Toxin cloud!",

	bar1text	= "Poison Bolt Volley",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsViscidus = BigWigs:NewModule(boss)
BigWigsViscidus.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsViscidus.enabletrigger = boss
BigWigsViscidus.toggleoptions = {"freeze", "volley", "toxinyou", "toxinother", "bosskill"}
BigWigsViscidus.revision = tonumber(string.sub("$Revision: 19000 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsViscidus:OnEnable()
	prior = nil
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckVis")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckVis")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckVis")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")


	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "ViscidusAoE", 12)
end

------------------------------
--      Event Handlers      --
------------------------------
function BigWigsViscidus:CheckVis(arg1)
	if not prior and self.db.profile.volley and string.find(arg1, L["trigger6"]) then
                self:TriggerEvent("BigWigs_SendSync", "ViscidusAoE")
		prior = true
	elseif string.find(arg1, L["trigger7"]) then
		local _,_, pl, ty = string.find(arg1, L["trigger7"])
		if (pl and ty) then
			if self.db.profile.toxinyou and pl == L["you"] and ty == L["are"] then
	                        BigWigsThaddiusArrows:Direction("Fire")
				self:TriggerEvent("BigWigs_Message", L["warn9"], "Personal", true, "Alarm")
				self:TriggerEvent("BigWigs_Message", UnitName("player") .. L["warn8"], "Important", nil, nil, true)
			elseif self.db.profile.toxinother then
				self:TriggerEvent("BigWigs_Message", pl .. L["warn8"], "Important")
				self:TriggerEvent("BigWigs_SendTell", pl, L["warn9"])
			end
		end
	end
end

function BigWigsViscidus:BigWigs_RecvSync( sync )
	if sync == "ViscidusAoE" then
		self:ScheduleEvent("BigWigs_Message", 12, L["warn7"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bar1text"], 15, "Interface\\Icons\\Spell_Nature_CorrosiveBreath")
	end
end

function BigWigsViscidus:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if string.find(msg, L["GNPPtrigger"]) then
            BigWigsThaddiusArrows:GNPPstop()
	end
end

function BigWigsViscidus:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["trigger"]) then
            BigWigsThaddiusArrows:Firestop()
	elseif string.find(msg, L["GNPPtrigger"]) then
	        BigWigsThaddiusArrows:Direction("GNPP")
	end
end

function BigWigsViscidus:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(msg, L["freeze_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["freeze_message"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["freeze_bar"], 15, "Interface\\Icons\\Spell_Frost_Freezingbreath")
	end
end

function BigWigsViscidus:CHAT_MSG_MONSTER_EMOTE(arg1)
	if not self.db.profile.freeze then return end
	if arg1 == L["trigger1"] then
		self:TriggerEvent("BigWigs_Message", L["warn1"], "Atention")
	elseif arg1 == L["trigger2"] then
		self:TriggerEvent("BigWigs_Message", L["warn2"], "Urgent")
	elseif arg1 == L["trigger3"] then
		self:TriggerEvent("BigWigs_Message", L["warn3"], "Important")
	elseif arg1 == L["trigger4"] then
		self:TriggerEvent("BigWigs_Message", L["warn4"], "Urgent")
	elseif arg1 == L["trigger5"] then
		self:TriggerEvent("BigWigs_Message", L["warn5"], "Important")
	end
end

function BigWigsViscidus:BigWigs_Message(text)
	if text == L["warn7"] then prior = nil end
end

