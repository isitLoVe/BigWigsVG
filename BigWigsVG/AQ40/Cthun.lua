------------------------------
--      Are you local?      --
------------------------------

local eyeofcthun = AceLibrary("Babble-Boss-2.2")["Eye of C'Thun"]
local cthun = AceLibrary("Babble-Boss-2.2")["C'Thun"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. cthun)

local gianteye = "Giant Eye Tentacle"

local timeP1Tentacle = 85      -- tentacle timers for phase 1
local timeP1TentacleStart = 45 -- delay for first tentacles from engage onwards
local timeP1GlareStart = 50    -- delay for first dark glare from engage onwards
local timeP1Glare = 85         -- interval for dark glare
local timeP1GlareDuration = 40 -- duration of dark glare

--local timeP2Offset = 55        -- delay for all timers to restart after the Eye dies

local timeP2TentacleStart = 40     --tentacle start timer for phase 2
local timeP2GiantEyeStart = 56	   --Giant Eye start timer for phase 2
local timeP2GiantClawStart = 26	   --Giant Claw start timer for phase 2

local timeP2Tentacle = 30      -- tentacle timers for phase 2
local timeP2GiantEye = 60	   --Giant Eye timer for phase 2
local timeP2GiantClaw = 60	   --Giant Claw timer for phase 2


--local timeReschedule = 50      -- delay from the moment of weakening for timers to restart
--local timeTarget = 10          -- delay for target change checking on Eye of C'Thun
local timeWeakened = 45        -- duration of a weaken

local cthunstarted = nil
local phase2started = nil
local firstGlare = nil
local firstWarning = nil
local target = nil
local tentacletime = timeP1Tentacle

----------------------------
--      Localization      --
----------------------------


L:RegisterTranslations("enUS", function() return {
	cmd = "Cthun",

	tentacle_cmd = "tentacle",
	tentacle_name = "Tentacle Alert",
	tentacle_desc = "Warn for Tentacles",

	glare_cmd = "glare",
	glare_name = "Dark Glare Alert",
	glare_desc = "Warn for Dark Glare",

	group_cmd = "group",
	group_name = "Dark Glare Group Warning",
	group_desc = "Warn for Dark Glare on Group X",

	giant_cmd = "giant",
	giant_name = "Giant Eye & Claw Alert",
	giant_desc = "Warn for Giant Eyes & Giant Claws",

	weakened_cmd = "weakened",
	weakened_name = "Weakened Alert",
	weakened_desc = "Warn for Weakened State",

	rape_cmd = "rape",
	rape_name = "Rape Warnings",
	rape_desc = "Some people like rape jokes :/",

	weakenedtrigger = "is weakened",
	tentacle	= "Tentacle Rape Party - 5 sec",

	norape		= "Tentacles in 5sec!",

	testbar		= "time",
	say		= "say",

	weakened	= "C'Thun is weakened for 45 sec",
	invulnerable2	= "Party ends in 5 seconds",
	invulnerable1	= "Party over - C'Thun invulnerable",

	GNPPtrigger	= "Nature Protection",
	GSPPtrigger	= "Shadow Protection",
	Sundertrigger	= "Sunder Armor",
	CoEtrigger	= "Curse of the Elements",
	CoStrigger	= "Curse of Shadow",
	CoRtrigger	= "Curse of Recklessness",

	startwarn	= "C'Thun engaged! - 45 sec until Dark Glare and Eyes",

	glare		= "Dark glare!",

	barTentacle	= "Tentacle rape party!",
	barNoRape	= "Tentacle party!",
	barWeakened	= "C'Thun is weakened!",
	barGlare	= "Dark glare!",
	barGiantE	= "Giant Eye!",
	barGiantC	= "Giant Claw!",
	barDarkGlareCasting	= "Dark Glare - MOVE",
	gedownwarn	= "Giant Eye down!",

	eyebeam		= "Eye Beam",
	glarewarning	= "DARK GLARE ON YOU!",
	groupwarning	= "Dark Glare on group %s (%s)",
	positions2	= "Dark Glare ends in 5 sec",
	phase2starting	= "The Eye is dead! Body incoming!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsCThun = BigWigs:NewModule(cthun)
BigWigsCThun.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsCThun.enabletrigger = { eyeofcthun, cthun }
BigWigsCThun.toggleoptions = { "rape", -1, "tentacle", "glare", "group", -1, "giant", "weakened", "bosskill" }
BigWigsCThun.revision = tonumber(string.sub("$Revision: 19009 $", 12, -3))

function BigWigsCThun:OnEnable()
	target = nil
	cthunstarted = nil
	firstGlare = nil
	firstWarning = nil
	phase2started = nil

	tentacletime = timeP1Tentacle


	-- register events
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")		-- weakened triggering
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE") -- engage of Eye of C'Thun
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE") -- engage of Eye of C'Thun
	-- Not sure about this, since we get out of combat between the phases.
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("BigWigs_RecvSync")
	--rewrote to *VG for not syncing with older versions
	self:TriggerEvent("BigWigs_ThrottleSync", "CThunStartVG", 20)
	self:TriggerEvent("BigWigs_ThrottleSync", "CThunP2StartVG", 20)
	self:TriggerEvent("BigWigs_ThrottleSync", "CThunWeakenedVG", 20)
	self:TriggerEvent("BigWigs_ThrottleSync", "CThunGEdownVG", 3)
end

----------------------
--  Event Handlers  --
----------------------

--use macro /script BigWigsCThun:ManualWeakend() to trigger weakened
function BigWigsCThun:ManualWeakend()
	self:TriggerEvent("BigWigs_SendSync", "CThunWeakenedVG")
end

function BigWigsCThun:CHAT_MSG_MONSTER_EMOTE( arg1 )
	if arg1 == L["weakenedtrigger"] then self:TriggerEvent("BigWigs_SendSync", "CThunWeakenedVG") end
end

function BigWigsCThun:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["Sundertrigger"]) then
	        BigWigsThaddiusArrows:Direction("Sunder")
	elseif string.find(msg, L["CoEtrigger"]) then
	        BigWigsThaddiusArrows:Direction("CoE")
	elseif string.find(msg, L["CoStrigger"]) then
	        BigWigsThaddiusArrows:Direction("CoS")
	elseif string.find(msg, L["CoRtrigger"]) then
	        BigWigsThaddiusArrows:Direction("CoR")
	end
end

function BigWigsCThun:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if string.find(msg, L["Sundertrigger"]) then
                BigWigsThaddiusArrows:Sunderstop()
	elseif string.find(msg, L["CoEtrigger"]) then
                BigWigsThaddiusArrows:CoEstop()
	elseif string.find(msg, L["CoStrigger"]) then
                BigWigsThaddiusArrows:CoSstop()
	elseif string.find(msg, L["CoRtrigger"]) then
                BigWigsThaddiusArrows:CoRstop()
	end
end

function BigWigsCThun:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS( msg )
	if string.find(msg, L["GNPPtrigger"]) then
            BigWigsThaddiusArrows:GNPPstop()
	end
end

function BigWigsCThun:CHAT_MSG_SPELL_AURA_GONE_SELF( msg )
	if string.find(msg, L["GNPPtrigger"]) then
	        BigWigsThaddiusArrows:Direction("GNPP")
	end
end

function BigWigsCThun:CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE( arg1 )
	if not cthunstarted and arg1 and string.find(arg1, L["eyebeam"]) then 
        self:TriggerEvent("BigWigs_SendSync", "CThunStartVG")
        end
end

function BigWigsCThun:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if (msg == string.format(UNITDIESOTHER, eyeofcthun)) then
		self:TriggerEvent("BigWigs_SendSync", "CThunP2StartVG")
	elseif (msg == string.format(UNITDIESOTHER, gianteye)) then
		self:TriggerEvent("BigWigs_SendSync", "CThunGEdownVG")
	elseif (msg == string.format(UNITDIESOTHER, cthun)) then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s has been defeated"], cthun), "Bosskill", nil, "Victory") end
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsCThun:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == cthun and not cthunstarted then
		--cthunstarted = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
        self:TriggerEvent("BigWigs_SendSync", "CThunStartVG")
	elseif sync == "CThunStartVG" then
		self:CThunStartVG()
	elseif sync == "CThunP2StartVG" then
		self:CThunP2StartVG()
	elseif sync == "CThunWeakenedVG" then
		self:CThunWeakenedVG()
	elseif sync == "CThunGEdownVG" then
		self:TriggerEvent("BigWigs_Message", L["gedownwarn"], "Positive")
		BigWigsThaddiusArrows:GEyestop()
	end
end

-----------------------
--   Sync Handlers   --
-----------------------

function BigWigsCThun:CThunStartVG()
	if not cthunstarted then
		cthunstarted = true

		self:TriggerEvent("BigWigs_Message", L["startwarn"], "Attention")

		if self.db.profile.tentacle then
	        --self:ScheduleEvent("bwctea1", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, timeP1TentacleStart)
			self:TriggerEvent("BigWigs_StartBar", self, self.db.profile.rape and L["barTentacle"] or L["barNoRape"], timeP1TentacleStart, "Interface\\Icons\\Spell_Nature_CallStorm")
			self:ScheduleEvent("bwcthuntentacle", "BigWigs_Message", timeP1TentacleStart, self.db.profile.rape and L["tentacle"] or L["norape"], "Urgent", true, "Alert")
			self:ScheduleEvent("bwcthuntentaclesstart", self.StartTentacleRape, timeP1TentacleStart, self )
		end

		if self.db.profile.glare then
	        --self:ScheduleEvent("bwctga", function() BigWigsThaddiusArrows:Direction("Cthunglare") end, timeP1GlareStart)
			self:TriggerEvent("BigWigs_StartBar", self, L["barGlare"], timeP1GlareStart, "Interface\\Icons\\Spell_Shadow_ShadowBolt")
			self:ScheduleEvent("BigWigs_Message", timeP1GlareStart, L["glare"], "Urgent", true, "Alarm" )
			self:ScheduleEvent("bwcthundarkglarestart", self.DarkGlare, timeP1GlareStart, self )
			self:ScheduleEvent("bwcthungroupwarningstart", self.GroupWarning, timeP1GlareStart - 1, self )
		end

		firstGlare = true
		firstWarning = true

	end
end

function BigWigsCThun:CThunP2StartVG()
	if not phase2started then
		phase2started = true
		tentacletime = timeP2Tentacle

		self:TriggerEvent("BigWigs_Message", L["phase2starting"], "Bosskill")

		self:TriggerEvent("BigWigs_StopBar", self, L["barGlare"] )
		self:TriggerEvent("BigWigs_StopBar", self, L["barTentacle"] )
		self:TriggerEvent("BigWigs_StopBar", self, L["barNoRape"] )
		self:TriggerEvent("BigWigs_StopBar", self, L["barDarkGlareCasting"] )

		self:CancelScheduledEvent("bwcthuntentacle")
		self:CancelScheduledEvent("bwcthunglare")
		self:CancelScheduledEvent("bwcthunpositions2")
		self:CancelScheduledEvent("bwcthundarkglarestart")
		self:CancelScheduledEvent("bwcthungroupwarningstart")
		self:CancelScheduledEvent("bwcthuntentaclesstart")
		
		
		
		-- cancel the repeaters
		self:CancelScheduledEvent("bwcthuntentacles")
		self:CancelScheduledEvent("bwcthundarkglare")
		self:CancelScheduledEvent("bwcthungroupwarning")
		self:CancelScheduledEvent("bwcthuntarget")
		self:CancelScheduledEvent("bwctea1")
		self:CancelScheduledEvent("bwctea2")
		self:CancelScheduledEvent("bwctga")

		if self.db.profile.tentacle then
			--self:ScheduleEvent("bwctea1", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, timeP2Tentacle + timeP2Offset - 5)
			--self:ScheduleEvent("bwctea2", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, 55 + timeP2Offset)
			self:ScheduleEvent("bwcthuntentacle", "BigWigs_Message", timeP2TentacleStart - 5, self.db.profile.rape and L["tentacle"] or L["norape"], "Urgent", true, "Alert")
			self:TriggerEvent("BigWigs_StartBar", self, self.db.profile.rape and L["barTentacle"] or L["barNoRape"], timeP2TentacleStart, "Interface\\Icons\\Spell_Nature_CallStorm")
			--self:ScheduleEvent("BigWigs_StartBar", 41, self, L["barTentacle"], 30, "Interface\\Icons\\Spell_Nature_CallStorm")
			--self:ScheduleEvent("bwcthuntentacle2", "BigWigs_Message", 66, self.db.profile.rape and L["tentacle"] or L["norape"], "Urgent", true, "Alert")
			
			self:ScheduleEvent("bwcthunstarttentacles", self.StartTentacleRape, timeP2TentacleStart, self )
		end

		if self.db.profile.giant then
			--self:ScheduleEvent("bwctgca", function() BigWigsThaddiusArrows:Direction("Cthungclaw") end, 21)
			--self:ScheduleEvent("bwctgea", function() BigWigsThaddiusArrows:Direction("Cthungeyes") end, 51)
			--self:ScheduleEvent("bwctgeas", function() BigWigsThaddiusArrows:Direction("Cthungeyesactive") end, 56)
			self:TriggerEvent("BigWigs_StartBar", self, L["barGiantE"], timeP2GiantEyeStart, "Interface\\Icons\\Ability_EyeOfTheOwl")
			self:TriggerEvent("BigWigs_StartBar", self, L["barGiantC"], timeP2GiantClawStart, "Interface\\Icons\\Spell_Nature_Earthquake")
			
			self:ScheduleEvent("bwcthunstartgiant", self.StartGiantEyeRape, timeP2GiantEyeStart, self )
			self:ScheduleEvent("bwcthunstartgiantc", self.StartGiantClawRape, timeP2GiantClawStart, self )
		end

		--self:ScheduleRepeatingEvent("bwcthuntargetp2", self.CheckTargetP2, timeTarget, self )
	end

end

function BigWigsCThun:CThunWeakenedVG()
	if self.db.profile.weakened then
		self:TriggerEvent("BigWigs_Message", L["weakened"], "Positive" )
		self:TriggerEvent("BigWigs_StartBar", self, L["barWeakened"], timeWeakened, "Interface\\Icons\\INV_ValentinesCandy")
		self:ScheduleEvent("bwcthunweaken2", "BigWigs_Message", timeWeakened - 5, L["invulnerable2"], "Urgent")
		self:ScheduleEvent("bwcthunweaken1", "BigWigs_Message", timeWeakened, L["invulnerable1"], "Important" )
	end

	-- cancel tentacle timers
	self:CancelScheduledEvent("bwcthuntentacle")
	self:CancelScheduledEvent("bwcthuntentacle2")
	self:CancelScheduledEvent("bwcthungtentacles")
	self:CancelScheduledEvent("bwcthungctentacles")
	self:CancelScheduledEvent("bwctea1")
	self:CancelScheduledEvent("bwctea2")
	self:CancelScheduledEvent("bwctgea")
	self:CancelScheduledEvent("bwctgca")

	self:TriggerEvent("BigWigs_StopBar", self, L["barTentacle"])
	self:TriggerEvent("BigWigs_stopBar", self, L["barNoRape"])
	self:TriggerEvent("BigWigs_StopBar", self, L["barGiantE"])
	self:TriggerEvent("BigWigs_StopBar", self, L["barGiantC"])

	self:CancelScheduledEvent("bwcthuntentacles")
	--self:ScheduleEvent("bwctea1", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, 45)
	--self:ScheduleEvent("bwctgca", function() BigWigsThaddiusArrows:Direction("Cthungclaw") end, 50)
	--self:ScheduleEvent("bwctea2", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, 75)
	--self:ScheduleEvent("bwctgea", function() BigWigsThaddiusArrows:Direction("Cthungeyes") end, 80)
	--self:ScheduleEvent("bwctgeas", function() BigWigsThaddiusArrows:Direction("Cthungeyesactive") end, 85)
	--self:ScheduleEvent("BigWigs_StartBar", 45, self, L["barTentacle"], 5, "Interface\\Icons\\Spell_Nature_CallStorm")
	--self:ScheduleEvent("BigWigs_StartBar", 45, self, L["barGiantC"], 10, "Interface\\Icons\\Spell_Nature_Earthquake")
	--self:ScheduleEvent("BigWigs_StartBar", 45, self, L["barGiantE"], 40, "Interface\\Icons\\Ability_EyeOfTheOwl")
	--self:ScheduleEvent("BigWigs_StartBar", 50, self, L["barTentacle"], 30, "Interface\\Icons\\Spell_Nature_CallStorm")
	--self:ScheduleEvent("BigWigs_StartBar", 55, self, L["barGiantC"], 60, "Interface\\Icons\\Spell_Nature_Earthquake")

	--recalculate timers after weakened
	local t = GetTime()
	
	timeTentacleRapeleft = timeP2Tentacle - (t - timeTentacleRape)
	timeGiantEyeRapeleft = timeP2GiantEye - (t - timeGiantEyeRape)
	timeGiantClawRapeleft = timeP2GiantClaw - (t - timeGiantClawRape)
	
	--DEFAULT_CHAT_FRAME:AddMessage(timeTentacleRapeleft)
	--DEFAULT_CHAT_FRAME:AddMessage(timeGiantEyeRapeleft)
	--DEFAULT_CHAT_FRAME:AddMessage(timeGiantClawRapeleft)
	
	--schedule new events after weakened 
	self:ScheduleEvent("bwcthunstarttentacles", self.StartTentacleRape, timeTentacleRapeleft + timeWeakened, self )
	self:ScheduleEvent("bwcthunstartgiant", self.StartGiantEyeRape, timeGiantEyeRapeleft + timeWeakened, self )
	self:ScheduleEvent("bwcthunstartgiantc", self.StartGiantClawRape, timeGiantClawRapeleft + timeWeakened, self )
	
	--bars for events after weakened and before the repeater kicks in again
	if self.db.profile.tentacle then
		self:TriggerEvent("BigWigs_StartBar", self, self.db.profile.rape and L["barTentacle"] or L["barNoRape"], timeTentacleRapeleft + timeWeakened, "Interface\\Icons\\Spell_Nature_CallStorm")
		self:ScheduleEvent("bwcthuntentacle", "BigWigs_Message", timeTentacleRapeleft + timeWeakened - 5, self.db.profile.rape and L["tentacle"] or L["norape"], "Urgent", true, "Alert")
	end
	if self.db.profile.giant then
		self:TriggerEvent("BigWigs_StartBar", self, L["barGiantE"], timeGiantEyeRapeleft + timeWeakened, "Interface\\Icons\\Ability_EyeOfTheOwl")
		self:TriggerEvent("BigWigs_StartBar", self, L["barGiantC"], timeGiantClawRapeleft + timeWeakened, "Interface\\Icons\\Spell_Nature_Earthquake")
	end
end

-----------------------
-- Utility Functions --
-----------------------

function BigWigsCThun:StartTentacleRape()
	self:TentacleRape()
	self:ScheduleRepeatingEvent("bwcthuntentacles", self.TentacleRape, tentacletime, self )
end

function BigWigsCThun:StartGiantEyeRape()
	self:GiantEyeRape()
	self:ScheduleRepeatingEvent("bwcthungtentacles", self.GiantEyeRape, timeP2GiantEye, self )
end

function BigWigsCThun:StartGiantClawRape()
	self:GiantClawRape()
	self:ScheduleRepeatingEvent("bwcthungctentacles", self.GiantClawRape, timeP2GiantClaw, self )
end

function BigWigsCThun:TentacleRape()
	if self.db.profile.tentacle then
		--self:ScheduleEvent("bwctea1", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, tentacletime - 5)
		self:TriggerEvent("BigWigs_StartBar", self, self.db.profile.rape and L["barTentacle"] or L["barNoRape"], tentacletime, "Interface\\Icons\\Spell_Nature_CallStorm")
		self:ScheduleEvent("bwcthuntentacle", "BigWigs_Message", tentacletime - 5, self.db.profile.rape and L["tentacle"] or L["norape"], "Urgent", true, "Alert")
		timeTentacleRape = GetTime()
		--DEFAULT_CHAT_FRAME:AddMessage("Got Time timeTentacleRape " ..timeTentacleRape)
	end
end

function BigWigsCThun:GiantEyeRape()
	if phase2started then
		if self.db.profile.giant then
			--self:ScheduleEvent("bwctgca", function() BigWigsThaddiusArrows:Direction("Cthungclaw") end, 25)
			self:TriggerEvent("BigWigs_StartBar", self, L["barGiantE"], timeP2GiantEye, "Interface\\Icons\\Ability_EyeOfTheOwl")
			timeGiantEyeRape = GetTime()
			--DEFAULT_CHAT_FRAME:AddMessage("Got Time timeGiantEyeRape " ..timeGiantEyeRape)
		end
	end
end

function BigWigsCThun:GiantClawRape()
	if phase2started then
		if self.db.profile.giant then
			--self:ScheduleEvent("bwctgea", function() BigWigsThaddiusArrows:Direction("Cthungeyes") end, 25)
			--self:ScheduleEvent("bwctgeas", function() BigWigsThaddiusArrows:Direction("Cthungeyesactive") end, 30)
			self:TriggerEvent("BigWigs_StartBar", self, L["barGiantC"], timeP2GiantClaw, "Interface\\Icons\\Spell_Nature_Earthquake")
			timeGiantClawRape = GetTime()
			--DEFAULT_CHAT_FRAME:AddMessage("Got Time timeGiantClawRape " ..timeGiantClawRape)
		end
	end
end

function BigWigsCThun:CheckTarget()
	local i
	local newtarget = nil
	if( UnitName("playertarget") == eyeofcthun ) then
		newtarget = UnitName("playertargettarget")
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == eyeofcthun then
				newtarget = UnitName("Raid"..i.."targettarget")
				break
			end
		end
	end
	if( newtarget ) then
		target = newtarget
	end
end

function BigWigsCThun:CheckTargetP2()
	local i
	local newtarget = nil
	if( UnitName("playertarget") == gianteye ) then
		newtarget = UnitName("playertargettarget")
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == gianteye then
				newtarget = UnitName("Raid"..i.."targettarget")
				break
			end
		end
	end
	if( newtarget ) then
		target = newtarget
	end
end

function BigWigsCThun:GroupWarning()
	if target then
		local i, name, group
		for i = 1, GetNumRaidMembers(), 1 do
			name, _, group, _, _, _, _, _ = GetRaidRosterInfo(i)
			if name == target then break end
		end
		if self.db.profile.group then
			self:TriggerEvent("BigWigs_Message", string.format( L["groupwarning"], group, target), "Important", true, "Alarm")
			self:TriggerEvent("BigWigs_SendTell", target, L["glarewarning"])
		end
	end
	if firstWarning then
		self:CancelScheduledEvent("bwcthungroupwarning")
		self:ScheduleRepeatingEvent("bwcthungroupwarning", self.GroupWarning, timeP1Glare, self )
		firstWarning = nil
	end
end


function BigWigsCThun:DarkGlare()
	if self.db.profile.glare then
	        --self:ScheduleEvent("bwctga", function() BigWigsThaddiusArrows:Direction("Cthunglare") end, 75)
	        --self:ScheduleEvent("bwctea2", function() BigWigsThaddiusArrows:Direction("Cthuneyes") end, 25)
		self:TriggerEvent("BigWigs_StartBar", self, L["barDarkGlareCasting"], timeP1GlareDuration, "Interface\\Icons\\Spell_Nature_CallStorm")
		self:TriggerEvent("BigWigs_StartBar", self, L["barGlare"], timeP1Glare, "Interface\\Icons\\Spell_Shadow_ShadowBolt")
		self:ScheduleEvent("bwcthunglare", "BigWigs_Message", timeP1Glare - .1, L["glare"], "Urgent", true, "Alarm")
		self:ScheduleEvent("bwcthunpositions2", "BigWigs_Message", timeP1GlareDuration - 5, L["positions2"], "Urgent")
	end
	if firstGlare then
		self:CancelScheduledEvent("bwcthundarkglare")
		self:ScheduleRepeatingEvent("bwcthundarkglare", self.DarkGlare, timeP1Glare, self )
		firstGlare = nil
	end
end
