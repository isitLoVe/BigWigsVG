------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Kurinnaxx"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Kurinnaxx",
	
	sand_cmd = "sand",
	sand_name = "Sand Trap Alert",
	sand_desc = "Warn for Sand Trap",
	
	mortal_cmd = "mortal",
	mortal_name = "Mortal Wound Alert",
	mortal_desc = "Warn for Mortal Wound",

	sand_trigger = "Sand Trap hits",
	sand_warn = "Sand Trap in 5sec",
	sand_bar = "Sand Trap",
	
	mortal_trigger = "^([^%s]+) ([^%s]+) afflicted by Mortal Wound",
	mortal_trigger_num = "(%d+)",
	mortal_warn = "Mortal Wound on %s",
	mortal_warn_num = "Mortal Wound (%d) on %s",
	mortal_bar = "Mortal Wound on %s",
	mortal_bar_num = "Mortal Wound (%d) on %s",
	
	you = "You",
	are = "are",	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsKurinnaxx = BigWigs:NewModule(boss)
BigWigsKurinnaxx.zonename = AceLibrary("Babble-Zone-2.2")["Ruins of Ahn'Qiraj"]
BigWigsKurinnaxx.enabletrigger = boss
BigWigsKurinnaxx.toggleoptions = {"sand", "mortal", "bosskill"}
BigWigsKurinnaxx.revision = tonumber(string.sub("$Revision: 19011 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsKurinnaxx:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath" )
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")
	started = nil
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "PeriodicEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "PeriodicEvent")
end

------------------------------
--      Events              --
------------------------------

function BigWigsKurinnaxx:BigWigs_RecvSync(sync, rest)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		if self.db.profile.sand then
			self:ScheduleEvent("BigWigs_Message", 25, L["sand_warn"], "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, L["sand_bar"], 30, "Interface\\Icons\\INV_Misc_Dust_02")
		end
	end
end


function BigWigsKurinnaxx:PeriodicEvent( msg )
	if self.db.profile.sand and string.find(msg, L["sand_trigger"]) then
		self:ScheduleEvent("BigWigs_Message", 25, L["sand_warn"], "Attention")
		self:TriggerEvent("BigWigs_StartBar", self, L["sand_bar"], 30, "Interface\\Icons\\INV_Misc_Dust_02")
		
	elseif self.db.profile.mortal and string.find(msg, L["mortal_trigger"]) then
		local _,_,wplayer,wtype = string.find(msg, L["mortal_trigger"])
		local _,_,wnum = string.find(msg, L["mortal_trigger_num"])
		
		if wplayer and wtype and wnum then
			if wplayer == L["you"] and wtype == L["are"] then
				wplayer = UnitName("player")
			end
			
			self:TriggerEvent("BigWigs_StopBar", self, string.format(L["mortal_bar_num"],wnum-1, wplayer))
			self:TriggerEvent("BigWigs_StopBar", self, string.format(L["mortal_bar"], wplayer, wplayer))
			
			self:TriggerEvent("BigWigs_Message", string.format(L["mortal_warn_num"],wnum, wplayer), "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["mortal_bar_num"],wnum, wplayer), 15, "Interface\\Icons\\INV_Misc_Dust_02")
		elseif wplayer and wtype then
			if wplayer == L["you"] and wtype == L["are"] then
				wplayer = UnitName("player")
			end
			self:TriggerEvent("BigWigs_Message", string.format(L["mortal_warn"], wplayer), "Attention")
			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["mortal_bar"], wplayer), 15, "Interface\\Icons\\INV_Misc_Dust_02")
		end
	end
end


