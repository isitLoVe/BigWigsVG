------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Loatheb"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local started = nil
local sporerottime = 7

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Loatheb",

	doom_cmd = "doom",
	doom_name = "Inevitable Doom Alert",
	doom_desc = "Warn for Inevitable Doom",

	spore_cmd = "spore",
	spore_name = "Spore Spawning Alert",
	spore_desc = "Warn when a spore spawns",

	curse_cmd = "curse",
	curse_name = "Curse Alert",
	curse_desc = "Enable warning when curses are removed from Loatheb",

	debuff_cmd = "debuff",
	debuff_name = "Deuff Alert",
	debuff_desc = "Notify on Deuffs Fading",
	
	doombar = "Inevitable Doom %d",
	doomwarn = "Inevitable Doom %d! %d sec to next!",
	doomwarn5sec = "Inevitable Doom %d in 5 sec!",
	doomtrigger = "afflicted by Inevitable Doom.",

	sporewarn = "Spore %d Spawned",
	sporebar = "Summon Spore %d",
	sporespawntrigger = "Loatheb casts Summon Spore.",

	sporespawnbar1 = "Spore 1 inc",
	sporespawnbar2 = "Spore 2 inc",
	sporespawnbar3 = "Spore 3 inc",
	sporespawnbar4 = "Spore 4 inc",
	sporespawnbar5 = "Spore 5 inc",
	sporespawnbar6 = "Spore 6 inc",
	sporespawnbar7 = "Spore 7 inc",
	sporespawnbar8 = "Spore 8 inc",


	removecursewarn = "Update CURSES NOW!!",
	removecursebar = "Remove Curse",
	removecursetrigger = "Chains of Ice is removed",

	Sundertrigger	= "Sunder Armor",
	CoEtrigger	= "Curse of the Elements",
	CoStrigger	= "Curse of Shadow",
	CoRtrigger	= "Curse of Recklessness",
	Firevulntrigger	= "Fire Vulnerability",
	FFiretrigger	= "Faerie Fire",
	Lighttrigger	= "Judgement of Light",
	Wisdomtrigger	= "Judgement of Wisdom",

	doomtimerbar = "Doom every 15sec",
	doomtimerwarn = "Doom timerchange in %s sec!",
	doomtimerwarnnow = "Inevitable Doom now happens every 15sec!",

	startwarn = "Loatheb engaged, 2 minutes to Inevitable Doom!",

	you = "You",
	are = "are",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsLoatheb = BigWigs:NewModule(boss)
BigWigsLoatheb.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsLoatheb.enabletrigger = boss
BigWigsLoatheb.toggleoptions = {"doom", "spore", "curse", "debuff", "bosskill"}
BigWigsLoatheb.revision = tonumber(string.sub("$Revision: 19010 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsLoatheb:OnEnable()
	self.doomTime = 30
	self.sporeCount = 1
	self.doomCount = 1
	started = nil
	sporerottime = 8

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

	self:RegisterEvent("BigWigs_RecvSync")

	-- 2: Doom and SporeSpawn versioned up because of the sync including the
	-- doom/spore count now, so we don't hold back the counter.
	self:TriggerEvent("BigWigs_ThrottleSync", "LoathebDoom2", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "LoathebSporeSpawn2", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "LoathebRemoveCurse", 10)
end

function BigWigsLoatheb:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
                self:Start()
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.doom then
			self:TriggerEvent("BigWigs_StartBar", self, L["doomtimerbar"], 300, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
			self:ScheduleEvent("bwloathebtimerreduce1", "BigWigs_Message", 240, string.format(L["doomtimerwarn"], 60), "Attention")
			self:ScheduleEvent("bwloathebtimerreduce2", "BigWigs_Message", 270, string.format(L["doomtimerwarn"], 30), "Attention")
			self:ScheduleEvent("bwloathebtimerreduce3", "BigWigs_Message", 290, string.format(L["doomtimerwarn"], 10), "Urgent")
			self:ScheduleEvent("bwloathebtimerreduce4", "BigWigs_Message", 295, string.format(L["doomtimerwarn"], 5), "Important")
			self:ScheduleEvent("bwloathebtimerreduce5", "BigWigs_Message", 300, L["doomtimerwarnnow"], "Important")

            self:Sporespawnstart()
            self:ScheduleEvent("bwloathebcursesstart", self.Cursesstart, 6, self)
			--self:TriggerEvent("BigWigs_StartBar", self, L["removecursebar"], 36, "Interface\\Icons\\Spell_Holy_RemoveCurse")

			self:ScheduleEvent("bwloathebdoomtimerreduce", function () BigWigsLoatheb.doomTime = 15 end, 300)

			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Red")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["doombar"], self.doomCount), 120, "Interface\\Icons\\Spell_Shadow_NightOfTheDead")
			self:ScheduleEvent("bwloathebdoom", "BigWigs_Message", 115, string.format(L["doomwarn5sec"], self.doomCount), "Urgent")
		end
	elseif sync == "LoathebDoom2" and rest then
		rest = tonumber(rest)
		if not rest then return end

		if rest == (self.doomCount + 1) then
			if self.db.profile.doom then
				self:TriggerEvent("BigWigs_Message", string.format(L["doomwarn"], self.doomCount, self.doomTime), "Important")
			end
			self.doomCount = self.doomCount + 1
			if self.db.profile.doom then
				self:TriggerEvent("BigWigs_StartBar", self, string.format(L["doombar"], self.doomCount), self.doomTime, "Interface\\Icons\\Spell_Shadow_NightOfTheDead")
				self:ScheduleEvent("bwloathebdoom", "BigWigs_Message", self.doomTime - 5, string.format(L["doomwarn5sec"], self.doomCount), "Urgent")
			end
		end
	elseif sync == "LoathebSporeSpawn2" and rest then
		rest = tonumber(rest)
		if not rest then return end

		if rest == (self.sporeCount + 1) then
			if self.db.profile.spore then
				self:TriggerEvent("BigWigs_Message", string.format(L["sporewarn"], self.sporeCount), "Important")
			end
			self.sporeCount = self.sporeCount + 1
			if self.db.profile.spore then
				self:TriggerEvent("BigWigs_StartBar", self, string.format(L["sporebar"], self.sporeCount), 12, "Interface\\Icons\\Inv_Mushroom_02")
			end
		end
	elseif sync == "LoathebRemoveCurse" then
		if self.db.profile.curse then
			self:TriggerEvent("BigWigs_Message", L["removecursewarn"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["removecursebar"], 30, "Interface\\Icons\\Spell_Holy_RemoveCurse")
		end
	end
end

function BigWigsLoatheb:Event( msg )
	if string.find(msg, L["doomtrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "LoathebDoom2 "..tostring(self.doomCount + 1))
	end
end

function BigWigsLoatheb:CHAT_MSG_SPELL_BREAK_AURA( msg )
	if string.find(msg, L["removecursetrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "LoathebRemoveCurse")
	end
end

function BigWigsLoatheb:Start()
	if self.db.profile.debuff then
		if (UnitClass("player") == "Warrior")  then
				BigWigsThaddiusArrows:Direction("Sunder")
		elseif (UnitClass("player") == "Warlock")  then
				BigWigsThaddiusArrows:Direction("CoE")
				BigWigsThaddiusArrows:Direction("CoS")
				BigWigsThaddiusArrows:Direction("CoR")
		elseif (UnitClass("player") == "Mage")  then
				BigWigsThaddiusArrows:Direction("Firevuln")
		elseif (UnitClass("player") == "Druid")  then
				BigWigsThaddiusArrows:Direction("FFire")
		elseif (UnitClass("player") == "Paladin")  then
				BigWigsThaddiusArrows:Direction("Light")
				BigWigsThaddiusArrows:Direction("Wisdom")
		end
	end
end

function BigWigsLoatheb:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if self.db.profile.debuff then
		if string.find(msg, L["Sundertrigger"]) and (UnitClass("player") == "Warrior") then
	        BigWigsThaddiusArrows:Direction("Sunder")
		elseif string.find(msg, L["CoEtrigger"]) and (UnitClass("player") == "Warlock") then
	        BigWigsThaddiusArrows:Direction("CoE")
		elseif string.find(msg, L["CoStrigger"]) and (UnitClass("player") == "Warlock") then
	        BigWigsThaddiusArrows:Direction("CoS")
		elseif string.find(msg, L["CoRtrigger"]) and (UnitClass("player") == "Warlock") then
	        BigWigsThaddiusArrows:Direction("CoR")
		elseif string.find(msg, L["Firevulntrigger"]) and (UnitClass("player") == "Mage") then
	        BigWigsThaddiusArrows:Direction("Firevuln")
		elseif string.find(msg, L["FFiretrigger"]) and (UnitClass("player") == "Druid") then
	        BigWigsThaddiusArrows:Direction("FFire")
		elseif string.find(msg, L["Lighttrigger"]) and (UnitClass("player") == "Paladin") then
	        BigWigsThaddiusArrows:Direction("Light")
		elseif string.find(msg, L["Wisdomtrigger"]) and (UnitClass("player") == "Paladin") then
	        BigWigsThaddiusArrows:Direction("Wisdom")
		end
	end
end

function BigWigsLoatheb:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if self.db.profile.debuff then
		if string.find(msg, L["Sundertrigger"]) then
                BigWigsThaddiusArrows:Sunderstop()
		elseif string.find(msg, L["CoEtrigger"]) then
                BigWigsThaddiusArrows:CoEstop()
		elseif string.find(msg, L["CoStrigger"]) then
                BigWigsThaddiusArrows:CoSstop()
		elseif string.find(msg, L["CoRtrigger"]) then
                BigWigsThaddiusArrows:CoRstop()
		elseif string.find(msg, L["Firevulntrigger"]) then
                BigWigsThaddiusArrows:Firevulnstop()
		elseif string.find(msg, L["FFiretrigger"]) then
                BigWigsThaddiusArrows:FFirestop()
		elseif string.find(msg, L["Lighttrigger"]) then
                BigWigsThaddiusArrows:Lightstop()
		elseif string.find(msg, L["Wisdomtrigger"]) then
                BigWigsThaddiusArrows:Wisdomstop()
		end
	end
end

function BigWigsLoatheb:Sporespawnstart()
	self:GetSubGroupID()
    self:SporeRotationVisual1()
    self:ScheduleEvent("bwloathebsporerotationvisual", self.SporeRotationVisual2, 2, self)
    self:ScheduleEvent("bwloathebsporespawnone", self.Sporespawnone, 105, self)
	self:TriggerEvent("BigWigs_StartBar", self, L["sporespawnbar1"], 14, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 15, self, L["sporespawnbar2"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 28, self, L["sporespawnbar3"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 41, self, L["sporespawnbar4"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 54, self, L["sporespawnbar5"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 67, self, L["sporespawnbar6"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 80, self, L["sporespawnbar7"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 93, self, L["sporespawnbar8"], 13, "Interface\\Icons\\Inv_Mushroom_02")
end


function BigWigsLoatheb:Sporespawnone()
	self:ScheduleRepeatingEvent("bwloathebsporespawntwo", self.Sporespawntwo, 105, self)
	self:TriggerEvent("BigWigs_StartBar", self, L["sporespawnbar1"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 13, self, L["sporespawnbar2"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 26, self, L["sporespawnbar3"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 39, self, L["sporespawnbar4"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 52, self, L["sporespawnbar5"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 65, self, L["sporespawnbar6"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 78, self, L["sporespawnbar7"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 91, self, L["sporespawnbar8"], 13, "Interface\\Icons\\Inv_Mushroom_02")
end

function BigWigsLoatheb:Sporespawntwo()
	self:TriggerEvent("BigWigs_StartBar", self, L["sporespawnbar1"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 13, self, L["sporespawnbar2"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 26, self, L["sporespawnbar3"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 39, self, L["sporespawnbar4"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 52, self, L["sporespawnbar5"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 65, self, L["sporespawnbar6"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 78, self, L["sporespawnbar7"], 13, "Interface\\Icons\\Inv_Mushroom_02")
	self:ScheduleEvent("BigWigs_StartBar", 91, self, L["sporespawnbar8"], 13, "Interface\\Icons\\Inv_Mushroom_02")
end

function BigWigsLoatheb:Cursesstart()
	self:ScheduleRepeatingEvent("bwloathebcurses", self.Curses, 30.5, self)
end

function BigWigsLoatheb:Curses()
	self:TriggerEvent("BigWigs_SendSync", "LoathebRemoveCurse")
end

function BigWigsLoatheb:GetSubGroupID()
	if not UnitInRaid("PLAYER") then return end
		for i = 1 , GetNumRaidMembers() do
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			if ( name == UnitName("PLAYER") ) then
			return subgroup
		end
	end
end

function BigWigsLoatheb:SporeRotationVisual1()
	if subgroup == 1 then
		sporerottime = 7
	elseif subgroup == 2 then
		sporerottime = 20
	elseif subgroup == 3 then
		sporerottime = 33
	elseif subgroup == 4 then
		sporerottime = 46
	elseif subgroup == 5 then
		sporerottime = 59
	elseif subgroup == 6 then
		sporerottime = 72
	elseif subgroup == 7 then
		sporerottime = 85
	elseif subgroup == 8 then
		sporerottime = 98
	end
end

function BigWigsLoatheb:SporeRotationVisual2()
	self:ScheduleEvent("bwrloathebchatmsgpost", self.Chatmsgpost, sporerottime + 3, self)
	self:ScheduleRepeatingEvent("bwloathebsporerotationvisual2b", self.SporeRotationVisual2b, 104, self)
	self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Spore") end, sporerottime)
end

function BigWigsLoatheb:SporeRotationVisual2b()
	self:ScheduleEvent("bwrloathebchatmsgpost", self.Chatmsgpost, sporerottime + 3, self)
	self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Spore") end, sporerottime)
end

function BigWigsLoatheb:Chatmsgpost()
	SendChatMessage("<<< KILL THE SP0RE!!! >>>", "PARTY")
end
