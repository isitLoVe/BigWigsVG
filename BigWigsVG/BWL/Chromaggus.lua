------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Chromaggus"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local twenty
local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Chromaggus",

	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Warn before Enrage at 20%",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",

	breath_cmd = "breath",
	breath_name = "Breath Alerts",
	breath_desc = "Warn for Breaths",

	vulnerability_cmd = "vulnerability",
	vulnerability_name = "Vulnerability Alerts",
	vulnerability_desc = "Warn for Vulnerability changes",

	breath_trigger = "^Chromaggus begins to cast ([%w ]+)\.",
	vulnerability_test = "^[%w']+ [%w' ]+ ([%w]+) Chromaggus for ([%d]+) ([%w ]+) damage%..*",
	frenzy_trigger = "%s goes into a killing frenzy!",
	vulnerability_trigger = "%s flinches as its skin shimmers.", 
	triggerchat_frenzy = "^Chromaggus gains Frenzy",
	frenzyfade_trigger = "Frenzy fades from Chromaggus",

	hit = "hits",
	crit = "crits",

	breath_warning_initial = "Unknown Breath in 5 seconds!",
	breath_bar_1st = "1st Unknown Breath",
	breath_bar_2nd = "2nd Unknown Breath",
	
	breath_warning = "%s in 5 seconds!",
	breath_message = "%s is casting!",
	vulnerability_message = "Vulnerability: %s!",
	vulnerability_bar = "Vulnerability: %s!",
	vulnerability_warning = "Spell vulnerability changed!",
	frenzy_message = "Frenzy! Tranquil NOW!",
	enrage_warning = "Enrage soon!",

	breath1 = "Time Lapse",
	breath2 = "Corrosive Acid",
	breath3 = "Ignite Flesh",
	breath4 = "Incinerate",
	breath5 = "Frost Burn",

	iconunknown = "Interface\\Icons\\INV_Misc_QuestionMark",
	icon1 = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar",
	icon2 = "Interface\\Icons\\Spell_Nature_Acid_01",
	icon3 = "Interface\\Icons\\Spell_Fire_Fire",
	icon4 = "Interface\\Icons\\Spell_Shadow_ChillTouch",
	icon5 = "Interface\\Icons\\Spell_Frost_ChillingBlast",

	castingbar = "Cast %s",
	frenzy_bar = "Frenzy",
	
	icon_vuln_shadow = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
	icon_vuln_fire = "Interface\\Icons\\Spell_Fire_FlameBolt",
	icon_vuln_frost = "Interface\\Icons\\Spell_Frost_FrostBolt02",
	icon_vuln_arcane = "Interface\\Icons\\Spell_Nature_StarFall",
	icon_vuln_nature = "Interface\\Icons\\Spell_Nature_AbolishMagic",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsChromaggus = BigWigs:NewModule(boss)
BigWigsChromaggus.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsChromaggus.enabletrigger = boss
BigWigsChromaggus.toggleoptions = { "enrage", "frenzy", "breath", "vulnerability", "bosskill"}
BigWigsChromaggus.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsChromaggus:OnEnable()
	-- in the module itself for resetting via schedule
	self.vulnerability = nil
	twenty = nil
	started = nil

	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "PlayerDamageEvents")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("UNIT_HEALTH")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "ChromaggusBreath", 25)
	self:TriggerEvent("BigWigs_ThrottleSync", "ChromaggusVuln1", 10)
end

function BigWigsChromaggus:UNIT_HEALTH( msg )
	if self.db.profile.enrage then
		local health = UnitHealth(msg)
		if health == 23 then
			if self.db.profile.enrage then self:TriggerEvent("BigWigs_Message", L["enrage_warning"], "Important") end
			twenty = true
		elseif health > 40 and twenty then
			twenty = nil
		end
	end
end

function BigWigsChromaggus:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if self.db.profile.frenzy and string.find(arg1, L["triggerchat_frenzy"]) then
		self:Tranq()
		self:TriggerEvent("BigWigs_Message", L["frenzy_message"], "Important", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["frenzy_bar"], 8, "Interface\\Icons\\Ability_Druid_ChallangingRoar")
	end
end

function BigWigsChromaggus:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["frenzyfade_trigger"]) then
		self:Tranqoff()
	        self:TriggerEvent("BigWigs_StopBar", self, L["frenzy_bar"])
	end
end

function BigWigsChromaggus:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	local _,_, spellName = string.find(msg, L["breath_trigger"])
	if spellName then
		local breath = L:HasReverseTranslation(spellName) and L:GetReverseTranslation(spellName) or nil
		if not breath then return end
		breath = string.sub(breath, -1)
		self:TriggerEvent("BigWigs_SendSync", "ChromaggusBreath "..breath)
	end
end

function BigWigsChromaggus:BigWigs_RecvSync(sync, spellId)
	--using some nasty code here for engage check and spellid for breath
	if sync == self:GetEngageSync() and spellId and spellId == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		
		self:ScheduleEvent("bwchromaggusbreathinitial1", "BigWigs_Message", 25, L["breath_warning_initial"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["breath_bar_1st"], 30, L["iconunknown"])
		self:ScheduleEvent("bwchromaggusbreathinitial2", "BigWigs_Message", 55, L["breath_warning_initial"], "Important", true, "Alarm")
		self:TriggerEvent("BigWigs_StartBar", self, L["breath_bar_2nd"], 60, L["iconunknown"])
		
	elseif sync == "ChromaggusVuln1" then
		if self.db.profile.vulnerability then
			if spellId == "Shadow" then
				self:TriggerEvent("BigWigs_StartBar", self, format(L["vulnerability_message"], spellId), 30, L["icon_vuln_shadow"])
			elseif spellId == "Rire" then
				self:TriggerEvent("BigWigs_StartBar", self, format(L["vulnerability_message"], spellId), 30, L["icon_vuln_fire"])
			elseif spellId == "Frost" then
				self:TriggerEvent("BigWigs_StartBar", self, format(L["vulnerability_message"], spellId), 30, L["icon_vuln_frost"])
			elseif spellId == "Arcane" then
				self:TriggerEvent("BigWigs_StartBar", self, format(L["vulnerability_message"], spellId), 30, L["icon_vuln_arcane"])
			elseif spellId == "Nature" then
				self:TriggerEvent("BigWigs_StartBar", self, format(L["vulnerability_message"], spellId), 30, L["icon_vuln_nature"])
			elseif spellId == nil then
				return
			end
			
			self:TriggerEvent("BigWigs_Message", format(L["vulnerability_message"], spellId), "Positive")
			--end vulnerability after 30 secs
			self:ScheduleEvent(function() BigWigsChromaggus.vulnerability = nil end, 30)
		end
	
	elseif sync ~= "ChromaggusBreath" or not spellId or not self.db.profile.breath then return end
	local spellName = L:HasTranslation("breath"..spellId) and L["breath"..spellId] or nil
	if not spellName then return end

	self:TriggerEvent("BigWigs_StartBar", self, string.format( L["castingbar"], spellName), 2 )
	self:TriggerEvent("BigWigs_Message", string.format(L["breath_message"], spellName), "Important")
	self:ScheduleEvent("bwchromaggusbreath"..spellName, "BigWigs_Message", 55, string.format(L["breath_warning"], spellName), "Important", true, "Alarm")
	self:TriggerEvent("BigWigs_StartBar", self, spellName, 60, L["icon"..spellId])
	
    if (UnitClass("player") == "Warrior") or (UnitClass("player") == "Rogue") or (UnitClass("player") == "Mage") or (UnitClass("player") == "Warlock") or (UnitClass("player") == "Paladin") then
		self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Run") end, 27) 
	end
	
end

--[[ not working on vg
function BigWigsChromaggus:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L["vulnerability_trigger"] then
		if self.db.profile.vulnerability then
			self:TriggerEvent("BigWigs_Message", L["vulnerability_warning"], "Positive")
		end
		self:ScheduleEvent(function() BigWigsChromaggus.vulnerability = nil end, 2.5)
	end
end
]]

function BigWigsChromaggus:PlayerDamageEvents(msg)
	if (not self.vulnerability) then
		local _,_, type, dmg, school = string.find(msg, L["vulnerability_test"])
		if ( type == L["hit"] or type == L["crit"] ) and tonumber(dmg or "") and school then
			--nature
			if school == "Nature" and (tonumber(dmg) >= 3000 and type == L["hit"]) or (tonumber(dmg) >= 4000 and type == L["crit"]) then
				self.vulnerability = school
				self:TriggerEvent("BigWigs_SendSync", "ChromaggusVuln1 "..school)
			elseif (tonumber(dmg) >= 5000 and type == L["hit"]) or (tonumber(dmg) >= 8000 and type == L["crit"]) then
				self.vulnerability = school
				self:TriggerEvent("BigWigs_SendSync", "ChromaggusVuln1 "..school)
			end
		end
	end
end


function BigWigsChromaggus:Tranq()
            if (UnitClass("player") == "Hunter") then
                BigWigsThaddiusArrows:Direction("Tranq")
	end
end

function BigWigsChromaggus:Tranqoff()
            if (UnitClass("player") == "Hunter") then
            BigWigsThaddiusArrows:Tranqstop()
	end
end
