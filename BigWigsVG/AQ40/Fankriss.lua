------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Fankriss the Unyielding"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local worms
local times = {}
local prior = nil
local started
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Fankriss",
	worm_cmd = "worm",
	worm_name = "Worm Alert",
	worm_desc = "Warn for Incoming Worms",
	
	entangle_cmd = "entangle",
	entangle_name = "Entangle Alert",
	entangle_desc = "Warn for entangled players",
	
	entangletrigger = "(.*) (.*) afflicted by Entangle.",
	entanglebar = "%s entangled",
	
	you = "You",
	are = "are",
	
	-- not working because no combatlog messages when a worm spawns on VG
	wormtrigger = "Fankriss the Unyielding casts Summon Worm.",
	wormwarn = "Incoming Worm! (%d)",
	wormbar = "Sandworm Enrage (%d)",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFankriss = BigWigs:NewModule(boss)
BigWigsFankriss.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsFankriss.enabletrigger = boss
BigWigsFankriss.toggleoptions = {"worm", "entangle", "bosskill"}
BigWigsFankriss.revision = tonumber(string.sub("$Revision: 16639 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsFankriss:OnEnable()
	worms = 0
	prior = nil
	times = {}
	started = nil
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "SprayEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "SprayEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "SprayEvent")
	
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "FankrissWormSpawn", .1)
	self:TriggerEvent("BigWigs_ThrottleSync", "FankrissEntangle", 0)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsFankriss:SprayEvent( msg )
	if string.find(msg, L["entangletrigger"]) then
		local _,_,wplayer,wtype = string.find(msg, L["entangletrigger"])
		if wplayer and wtype then
			if wplayer == L["you"] and wtype == L["are"] then
				wplayer = UnitName("player")
			end
			local t = GetTime()
			if ( not times[wplayer] ) or ( times[wplayer] and ( times[wplayer] + 10 ) < t) then
				self:TriggerEvent("BigWigs_SendSync", "FankrissEntangle "..wplayer)
			end
		end
	end
end

function BigWigsFankriss:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if msg == L["wormtrigger"] then
		self:TriggerEvent("BigWigs_SendSync", "FankrissWormSpawn "..tostring(worms + 1) )
	end
end

function BigWigsFankriss:BigWigs_RecvSync(sync, rest)
	if sync == "FankrissEntangle" then
		local t = GetTime()
		if ( not times[rest] ) or ( times[rest] and ( times[rest] + 10 ) < t) then
			if self.db.profile.entangle then self:TriggerEvent("BigWigs_StartBar", self, string.format(L["entanglebar"], rest), 7, "Interface\\Icons\\Spell_Nature_Web") end
			times[rest] = t
		end
	elseif sync ~= "FankrissWormSpawn" then return end
	if not rest then return end
	rest = tonumber(rest)
	if rest == (worms + 1) then
		-- we accept this worm
		-- Yes, this could go completely wrong when you don't reset your module and the whole raid does after a wipe
		-- or you reset your module and the rest doesn't. Anyway. it'll work a lot better than anything else.
		worms = worms + 1
		if self.db.profile.worm then
			self:TriggerEvent("BigWigs_Message", string.format(L["wormwarn"], worms), "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["wormbar"], worms), 20, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
		end	
	end
end

