------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["High Priestess Mar'li"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local lastdrain = 0

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Marli",

	spider_cmd = "spider",
	spider_name = "Spider Alert",
	spider_desc = "Warn when spiders spawn",

	drain_cmd = "drain",
	drain_name = "Drain Alert",
	drain_desc = "Warn for life drain",
	
	web_cmd = "web",
	web_name = "Enveloping Webs Alert",
	web_desc = "Warn for Enveloping Webs",
	
	spiders_trigger = "Aid me my brood!$",
	drainlife_trigger = "afflicted by Drain Life",

	spiders_message = "Spiders spawned!",
	drainlife_message = "High Priestess Mar'li is draining life!",
	
	drainlife_bar = "Mar'li is draining life!",
	
	web_trigger = "(.*) (.*) afflicted by Enveloping Webs",
	web_message = "%s afflicted by Enveloping Webs",
	web_bar = "%s Cocooned!",

	you = "You",
	are = "are",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMarli = BigWigs:NewModule(boss)
BigWigsMarli.zonename = AceLibrary("Babble-Zone-2.2")["Zul'Gurub"]
BigWigsMarli.enabletrigger = boss
BigWigsMarli.toggleoptions = {"spider", "drain", "bosskill"}
BigWigsMarli.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMarli:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "PeriodicEvent")
end

------------------------------
--      Events              --
------------------------------

function BigWigsMarli:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.spider and string.find(msg, L["spiders_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["spiders_message"], "Attention")
	end
end

function BigWigsMarli:PeriodicEvent( msg )
	if self.db.profile.drain and string.find(msg, L["drainlife_trigger"]) then
		self:TriggerEvent("BigWigs_Message", L["drainlife_message"], "Urgent", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["drainlife_bar"], 7, "Interface\\Icons\\Spell_Shadow_LifeDrain02")
	elseif string.find(msg, L["web_trigger"]) then
		local _,_,wplayer,wtype = string.find(msg, L["web_trigger"])
		if wplayer and wtype then
			if wplayer == L["you"] and wtype == L["are"] then
				wplayer = UnitName("player")
			end
			self:TriggerEvent("BigWigs_Message", string.format(L["web_message"], wplayer), "Urgent" ) 
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["web_bar"], wplayer), 8, "Interface\\Icons\\Spell_Nature_EarthBind")
		end
	end
end

--[[
function BigWigsMarli:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF( msg )
	if self.db.profile.drain and string.find(msg, L["drainlife_trigger"]) and lastdrain < (GetTime()-3) then
		lastdrain = GetTime()
		self:TriggerEvent("BigWigs_Message", L["drainlife_message"], "Urgent", true, "Alert")
	end
end
--]]

