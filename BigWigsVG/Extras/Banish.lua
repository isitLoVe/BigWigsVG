assert(BigWigs, "BigWigs not found!")

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsBanish")

L:RegisterTranslations("enUS", function() return {

	banish_trigger = "(.+) is afflicted by Banish%.$",
	banish_bar = "%s - %s",
	banish_message = "%s's banish on %s ends in 5sec",
	
	mod = "banish",
	cmd = "banish",
	
	opt_name = "Banish",
	opt_desc = "Options for the banish module.",
	opt_bars = "Bars",
	
	arg_bars = "Bars",
	arg_name = "Bars",
	arg_desc = "Toggle banish bars on or off.",
	
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
		[L["arg_bars"]] = {
			type = "toggle",
			name = L["arg_name"],
			desc = L["arg_desc"],
			get = function() return BigWigsBanish.db.profile.bars end,
			set = function(v)
				BigWigsBanish.db.profile.bars = v
			end,
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
		self:TriggerEvent("BigWigs_SendSync", "BanishVG "..UnitName("target"))
	end
end

function BigWigsBanish:BigWigs_RecvSync(sync, target, sender)
	if sync == "BanishVG" then
		if self.db.profile.bars then
			self:CancelScheduledEvent("banishmsg"..sender)

			self:TriggerEvent("BigWigs_StartBar", self, string.format(L["banish_bar"], sender, target), 30, "Interface\\Icons\\Spell_Shadow_Cripple", _, "banishbar"..sender)
			self:ScheduleEvent("banishmsg"..sender, "BigWigs_Message", 25, string.format(L["banish_message"], sender, target), "Positive")
		end
	end
end
