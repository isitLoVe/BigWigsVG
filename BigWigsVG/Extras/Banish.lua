assert(BigWigs, "BigWigs not found!")

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsBanish")
local t
local rank
local target

L:RegisterTranslations("enUS", function() return {

	banish_trigger = "(.+) is afflicted by Banish%.$",
	banish_bar = "%s - %s",
	banish_message = "%s's banish on %s ends in 5sec",
	
	mod = "banish",
	cmd = "banish",
	
	opt_name = "Banish",
	opt_desc = "Options for the banish module.",
	opt_bars = "Bars",
	
	bars = "Bars",
	bar_name = "Bars",
	bar_desc = "Toggle banish bars on or off.",
	
	macro = "macro",
	macro_name = "Create Macros",
	macro_desc = "Create Banish rank 1 and 2 macroes.",
	
	macros_created = "Macros created",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBanish = BigWigs:NewModule(L["mod"])
BigWigsBanish.revision = tonumber(string.sub("$Revision: 19012 $", 12, -3))
BigWigsBanish.defaults = {
	bars = true,
}
BigWigsBanish.defaultDB = {
	bars = true,
}
BigWigsBanish.external = true
BigWigsBanish.consoleCmd = L["cmd"]
BigWigsBanish.consoleOptions = {
	type = "group",
	name = L["opt_name"],
	desc = L["opt_desc"],
	args = {
		[L["bars"]] = {
			type = "toggle",
			name = L["bar_name"],
			desc = L["bar_desc"],
			get = function() return BigWigsBanish.db.profile.bars end,
			set = function(v)
				BigWigsBanish.db.profile.bars = v
			end,
		},
		[L["macro"]] = {
			type = "execute",
			name = L["macro_name"],
			desc = L["macro_desc"],
			func = function() BigWigsBanish:BigWigs_CreateMacros() end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsBanish:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

	self:RegisterEvent("BigWigs_RecvSync")


end


------------------------------
--      Event Handlers      --
------------------------------


function BigWigsBanish:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if not msg then
		--DEFAULT_CHAT_FRAME:AddMessage("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE: msg is nil")
	elseif string.find(msg, L["banish_trigger"]) then
				DEFAULT_CHAT_FRAME:AddMessage("string found")
		if t == nil then
		
		else
			if (t < GetTime() - 1.3) and (t > GetTime() - 1.7) then
					DEFAULT_CHAT_FRAME:AddMessage("time ok")
				if rank == 1 then
					DEFAULT_CHAT_FRAME:AddMessage("rank1")
					self:TriggerEvent("BigWigs_SendSync", "BanishVG1 "..target)
					rank = nil
					target = nil
				elseif rank == 2 then
					DEFAULT_CHAT_FRAME:AddMessage("rank2")
					self:TriggerEvent("BigWigs_SendSync", "BanishVG2 "..target)
					rank = nil
					target = nil
				end
			end
		end
	end
end

function BigWigsBanish:Banish1()
	if UnitName("target") then
		CastSpellByName("Banish(Rank 1)")
		t = GetTime()
		rank = 1
		target = UnitName("target")
	end	
end

function BigWigsBanish:Banish2()
	if UnitName("target") then
		CastSpellByName("Banish(Rank 2)")
		t = GetTime()
		rank = 2
		target = UnitName("target")
	end
end


function BigWigsBanish:BigWigs_RecvSync(sync, target, sender)
	if sync == "BanishVG2" then
		if self.db.profile.bars then
			self:CancelScheduledEvent("banishmsg"..sender)

			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["banish_bar"], sender, target), 30, "Interface\\Icons\\Spell_Shadow_Cripple", _, "banishbar"..sender)
			self:ScheduleEvent("banishmsg"..sender, "BigWigs_Message", 25, string.format(L["banish_message"], sender, target), "Positive")
		end
	elseif sync == "BanishVG1" then
		if self.db.profile.bars then
			self:CancelScheduledEvent("banishmsg"..sender)

			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["banish_bar"], sender, target), 20, "Interface\\Icons\\Spell_Shadow_Cripple", _, "banishbar"..sender)
			self:ScheduleEvent("banishmsg"..sender, "BigWigs_Message", 15, string.format(L["banish_message"], sender, target), "Positive")
		end
	end
end

function BigWigsBanish:BigWigs_CreateMacros()
	if UnitClass("player") == "Warlock" then
		CreateMacro("Banish R1", 450, "/script BigWigsBanish:Banish1()", nil, 1)
		CreateMacro("Banish R2", 450, "/script BigWigsBanish:Banish2()", nil, 1)
		self:TriggerEvent("BigWigs_Message", L["macros_created"], "Positive", true, "Alert")
	end	
end
