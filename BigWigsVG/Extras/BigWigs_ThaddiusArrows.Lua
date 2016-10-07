--[[
--
-- BigWigs Strategy Module for Thaddius in Naxxramas.
--
-- Adds graphical, textual and sound warnings for what direction
-- you should move in when you get a polarity debuff in phase 2.
--
-- See readme.txt for more info
-- Many thanks to rabbit for all the help.
--
-- TODO
--  - Fix strategy broadcasting across multiple locales.
--
--]]

------------------------------
--      Are you local?      --
------------------------------

local myname = "Thaddius Arrows"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..myname)
local BZ = AceLibrary("Babble-Zone-2.2")
local boss = AceLibrary("Babble-Boss-2.2")["Thaddius"]
local TL = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local feugen = AceLibrary("Babble-Boss-2.2")["Feugen"]
local stalagg = AceLibrary("Babble-Boss-2.2")["Stalagg"]

-- Known strategies, values are the index in the L["strat_validate"] table.
-- Make sure to update the error checks in OnEnable if adding/removing
-- strategies.
local stratCircularLR, stratCircularRL, stratThrough, fourStates

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "ThaddiusArrows",

	graphic_cmd = "garrows",
	graphic_name = "Graphical Arrows",
	graphic_desc = "Display Graphical Arrows",

	text_cmd = "tarrows",
	text_name = "Text Arrows",
	text_desc = "Display Text Arrows",

	sound_cmd = "sarrows",
	sound_name = "Sound Effects",
	sound_desc = "Play Direction Sound Effects",

	strat_cmd = "strat",
	strat_name = "Strategy",
	strat_desc = "Pick the strategy to use for moving",
	strat_validate = { "Run Through", "Circular, L/R", "Circular, R/L", "Four States" },

	setstrategy_cmd = "bwtabc",
	setstrategy_name = "Broadcast strategy",
	setstrategy_desc = "Broadcasts your current strategy to the raid",
	["Crystal Charge"] = true,

	["Thaddius strategy is set to "] = true,
	["Make sure everyone in the raid has the same strategy set!"] = true,
	["Invalid Thaddius strategy, resetting to default."] = true,
	["You can run the command /bwtabc to broadcast your strategy and force your raid to use it."] = true,
	["You can't broadcast the strategy if you are not the leader or promoted in the raid group."] = true,
	["Broadcasting strategy ..."] = true,
	["Strategy broadcast detected from %s. Strategy set to %s."] = true,
	["Invalid Thaddius strategy received from %s."] = true,

	soundleft = "Interface\\AddOns\\BigWigs\\sounds\\GoLeft.wav",
	soundright = "Interface\\AddOns\\BigWigs\\sounds\\GoRight.wav",
	soundacross = "Interface\\AddOns\\BigWigs\\sounds\\SwitchSides.wav",

	warnleft = "<----  GO LEFT  <---- GO LEFT <----",
	warnright = "---->  GO RIGHT  ----> GO RIGHT ---->",
	warnacross = "^^^^ SWITCH SIDES ^^^^ SWITCH SIDES ^^^^",
	
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsThaddiusArrows = BigWigs:NewModule(myname, "AceConsole-2.0")
BigWigsThaddiusArrows.synctoken = myname
BigWigsThaddiusArrows.zonename = BZ["Naxxramas"]
BigWigsThaddiusArrows.enabletrigger = { boss, feugen, stalagg }
BigWigsThaddiusArrows.toggleoptions = { "strat", -1, "graphic", "text", "sound" }
BigWigsThaddiusArrows.revision = tonumber(string.sub("$Revision: 23229 $", 12, -3))
BigWigsThaddiusArrows.external = true

BigWigsThaddiusArrows.strat_four_states =
{
	[1] = {
		change = { direction = "Right", state = 3 },
		nochange = { direction = "Left", state = 2 },
	},
	[2] = {
		change = { direction = "Left", state = 4 },
		nochange = { direction = "Right", state = 1 },
	},
	[3] = {
		change = { direction = "Left", state = 1 },
		nochange = { direction = "Right", state = 4 },
	},
	[4] = {
		change = { direction = "Right", state = 2 },
		nochange = { direction = "Left", state = 3 },
	},
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsThaddiusArrows:OnRegister()
	self.frameArrow = CreateFrame("Frame", nil, UIParent)
	self.texArrow = self.frameArrow:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameArrow:SetFrameStrata("MEDIUM")
	self.frameArrow:SetWidth(200)  -- Set These to whatever height/width is needed 
	self.frameArrow:SetHeight(200) -- for your Texture
	-- Apply Texture
	self.texArrow:SetTexture("Interface\\AddOns\\BigWigs\\textures\\arrow")	
	self.texArrow:SetAllPoints(self.frameArrow)
	self.frameArrow:SetAlpha(0.6)
	self.frameArrow:Hide()

	self.framestraightArrow = CreateFrame("Frame", nil, UIParent)
	self.texstraightArrow = self.framestraightArrow:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.framestraightArrow:SetFrameStrata("MEDIUM")
	self.framestraightArrow:SetWidth(150)  -- Set These to whatever height/width is needed 
	self.framestraightArrow:SetHeight(150) -- for your Texture
	-- Apply Texture
	self.texstraightArrow:SetTexture("Interface\\AddOns\\BigWigs\\textures\\straightArrow")	
	self.texstraightArrow:SetAllPoints(self.framestraightArrow)
	self.framestraightArrow:SetAlpha(0.6)
	self.framestraightArrow:Hide()

	self.frameBlizzard = CreateFrame("Frame", nil, UIParent)
	self.texBlizzard = self.frameBlizzard:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameBlizzard:SetFrameStrata("MEDIUM")
	self.frameBlizzard:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameBlizzard:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texBlizzard:SetTexture("Interface\\Icons\\Spell_Frost_Icestorm")	
	self.texBlizzard:SetAllPoints(self.frameBlizzard)
	self.frameBlizzard:SetAlpha(0.6)
	self.frameBlizzard:Hide()

	self.frameGeddon = CreateFrame("Frame", nil, UIParent)
	self.texGeddon = self.frameGeddon:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameGeddon:SetFrameStrata("MEDIUM")
	self.frameGeddon:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameGeddon:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texGeddon:SetTexture("Interface\\Icons\\Spell_Shadow_MindBomb")	
	self.texGeddon:SetAllPoints(self.frameGeddon)
	self.frameGeddon:SetAlpha(0.6)
	self.frameGeddon:Hide()

	self.frameRun = CreateFrame("Frame", nil, UIParent)
	self.texRun = self.frameRun:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameRun:SetFrameStrata("MEDIUM")
	self.frameRun:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameRun:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texRun:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")	
	self.texRun:SetAllPoints(self.frameRun)
	self.frameRun:SetAlpha(0.6)
	self.frameRun:Hide()

	self.frameHakkar = CreateFrame("Frame", nil, UIParent)
	self.texHakkar = self.frameHakkar:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameHakkar:SetFrameStrata("MEDIUM")
	self.frameHakkar:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameHakkar:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texHakkar:SetTexture("Interface\\Icons\\Ability_Hunter_Pet_windSerpent")	
	self.texHakkar:SetAllPoints(self.frameHakkar)
	self.frameHakkar:SetAlpha(0.6)
	self.frameHakkar:Hide()

	self.frameShield = CreateFrame("Frame", nil, UIParent)
	self.texShield = self.frameShield:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameShield:SetFrameStrata("MEDIUM")
	self.frameShield:SetWidth(350)  -- Set These to whatever height/width is needed 
	self.frameShield:SetHeight(350) -- for your Texture
	-- Apply Texture
	self.texShield:SetTexture("Interface\\AddOns\\BigWigs\\Textures\\sporefung")	
	self.texShield:SetAllPoints(self.frameShield)
	self.frameShield:SetAlpha(0.7)
	self.frameShield:Hide()

	self.frameTranq = CreateFrame("Frame", nil, UIParent)
	self.texTranq = self.frameTranq:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameTranq:SetFrameStrata("MEDIUM")
	self.frameTranq:SetWidth(150)  -- Set These to whatever height/width is needed 
	self.frameTranq:SetHeight(150) -- for your Texture
	-- Apply Texture
	self.texTranq:SetTexture("Interface\\Icons\\Spell_Nature_Drowsy")	
	self.texTranq:SetAllPoints(self.frameTranq)
	self.frameTranq:SetAlpha(0.6)
	self.frameTranq:Hide()

	self.frameFire = CreateFrame("Frame", nil, UIParent)
	self.texFire = self.frameFire:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameFire:SetFrameStrata("MEDIUM")
	self.frameFire:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameFire:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texFire:SetTexture("Interface\\Icons\\Spell_Shadow_Rainoffire")	
	self.texFire:SetAllPoints(self.frameFire)
	self.frameFire:SetAlpha(0.6)
	self.frameFire:Hide()

	self.frameCthunglare = CreateFrame("Frame", nil, UIParent)
	self.texCthunglare = self.frameCthunglare:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCthunglare:SetFrameStrata("MEDIUM")
	self.frameCthunglare:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCthunglare:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCthunglare:SetTexture("Interface\\AddOns\\BigWigs\\Textures\\darkglare")	
	self.texCthunglare:SetAllPoints(self.frameCthunglare)
	self.frameCthunglare:SetAlpha(0.4)
	self.frameCthunglare:Hide()

	self.frameCthuneyes = CreateFrame("Frame", nil, UIParent)
	self.texCthuneyes = self.frameCthuneyes:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCthuneyes:SetFrameStrata("MEDIUM")
	self.frameCthuneyes:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCthuneyes:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCthuneyes:SetTexture("Interface\\Icons\\Spell_Shadow_Evileye")	
	self.texCthuneyes:SetAllPoints(self.frameCthuneyes)
	self.frameCthuneyes:SetAlpha(0.4)
	self.frameCthuneyes:Hide()

	self.frameCthungeyes = CreateFrame("Frame", nil, UIParent)
	self.texCthungeyes = self.frameCthungeyes:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCthungeyes:SetFrameStrata("MEDIUM")
	self.frameCthungeyes:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCthungeyes:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCthungeyes:SetTexture("Interface\\Icons\\Inv_Misc_Gem_Pearl_06")
	self.texCthungeyes:SetAllPoints(self.frameCthungeyes)
	self.frameCthungeyes:SetAlpha(0.4)
	self.frameCthungeyes:Hide()

	self.frameCthungeyesactive = CreateFrame("Frame", nil, UIParent)
	self.texCthungeyesactive = self.frameCthungeyesactive:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCthungeyesactive:SetFrameStrata("MEDIUM")
	self.frameCthungeyesactive:SetWidth(150)  -- Set These to whatever height/width is needed 
	self.frameCthungeyesactive:SetHeight(150) -- for your Texture
	-- Apply Texture
	self.texCthungeyesactive:SetTexture("Interface\\AddOns\\BigWigs\\Textures\\Eye_Stalk")	
	self.texCthungeyesactive:SetAllPoints(self.frameCthungeyesactive)
	self.frameCthungeyesactive:SetAlpha(0.9)
	self.frameCthungeyesactive:Hide()

	self.frameCthungclaw = CreateFrame("Frame", nil, UIParent)
	self.texCthungclaw = self.frameCthungclaw:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCthungclaw:SetFrameStrata("MEDIUM")
	self.frameCthungclaw:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCthungclaw:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCthungclaw:SetTexture("Interface\\Icons\\Inv_Misc_AhnqirajTrinket_05")	
	self.texCthungclaw:SetAllPoints(self.frameCthungclaw)
	self.frameCthungclaw:SetAlpha(0.4)
	self.frameCthungclaw:Hide()

	self.frameNoth = CreateFrame("Frame", nil, UIParent)
	self.texNoth = self.frameNoth:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameNoth:SetFrameStrata("MEDIUM")
	self.frameNoth:SetWidth(150)  -- Set These to whatever height/width is needed 
	self.frameNoth:SetHeight(150) -- for your Texture
	-- Apply Texture
	self.texNoth:SetTexture("Interface\\Icons\\Spell_Arcane_Blink")	
	self.texNoth:SetAllPoints(self.frameNoth)
	self.frameNoth:SetAlpha(0.6)
	self.frameNoth:Hide()

	self.frameSpore = CreateFrame("Frame", nil, UIParent)
	self.texSpore = self.frameSpore:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameSpore:SetFrameStrata("MEDIUM")
	self.frameSpore:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameSpore:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texSpore:SetTexture("Interface\\Icons\\Inv_Mushroom_02")	
	self.texSpore:SetAllPoints(self.frameSpore)
	self.frameSpore:SetAlpha(0.6)
	self.frameSpore:Hide()

	self.frameGFPP = CreateFrame("Frame", nil, UIParent)
	self.texGFPP = self.frameGFPP:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameGFPP:SetFrameStrata("MEDIUM")
	self.frameGFPP:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameGFPP:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texGFPP:SetTexture("Interface\\Icons\\Inv_Potion_24")	
	self.texGFPP:SetAllPoints(self.frameGFPP)
	self.frameGFPP:SetAlpha(0.6)
	self.frameGFPP:Hide()

	self.frameGNPP = CreateFrame("Frame", nil, UIParent)
	self.texGNPP = self.frameGNPP:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameGNPP:SetFrameStrata("MEDIUM")
	self.frameGNPP:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameGNPP:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texGNPP:SetTexture("Interface\\Icons\\Inv_Potion_22")	
	self.texGNPP:SetAllPoints(self.frameGNPP)
	self.frameGNPP:SetAlpha(0.6)
	self.frameGNPP:Hide()

	self.frameGSPP = CreateFrame("Frame", nil, UIParent)
	self.texGSPP = self.frameGSPP:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameGSPP:SetFrameStrata("MEDIUM")
	self.frameGSPP:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameGSPP:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texGSPP:SetTexture("Interface\\Icons\\Inv_Potion_23")	
	self.texGSPP:SetAllPoints(self.frameGSPP)
	self.frameGSPP:SetAlpha(0.6)
	self.frameGSPP:Hide()

	self.frameSunder = CreateFrame("Frame", nil, UIParent)
	self.texSunder = self.frameSunder:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameSunder:SetFrameStrata("MEDIUM")
	self.frameSunder:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameSunder:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texSunder:SetTexture("Interface\\Icons\\Ability_Warrior_Sunder")	
	self.texSunder:SetAllPoints(self.frameSunder)
	self.frameSunder:SetAlpha(0.6)
	self.frameSunder:Hide()

	self.frameCoE = CreateFrame("Frame", nil, UIParent)
	self.texCoE = self.frameCoE:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCoE:SetFrameStrata("MEDIUM")
	self.frameCoE:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCoE:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCoE:SetTexture("Interface\\Icons\\Spell_Shadow_Chilltouch")	
	self.texCoE:SetAllPoints(self.frameCoE)
	self.frameCoE:SetAlpha(0.6)
	self.frameCoE:Hide()

	self.frameCoS = CreateFrame("Frame", nil, UIParent)
	self.texCoS = self.frameCoS:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCoS:SetFrameStrata("MEDIUM")
	self.frameCoS:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCoS:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCoS:SetTexture("Interface\\Icons\\Spell_Shadow_Curseofachimonde")	
	self.texCoS:SetAllPoints(self.frameCoS)
	self.frameCoS:SetAlpha(0.6)
	self.frameCoS:Hide()

	self.frameCoR = CreateFrame("Frame", nil, UIParent)
	self.texCoR = self.frameCoR:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameCoR:SetFrameStrata("MEDIUM")
	self.frameCoR:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameCoR:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texCoR:SetTexture("Interface\\Icons\\Spell_Shadow_Unholystrength")	
	self.texCoR:SetAllPoints(self.frameCoR)
	self.frameCoR:SetAlpha(0.6)
	self.frameCoR:Hide()

	self.frameFroasty = CreateFrame("Frame", nil, UIParent)
	self.texFroasty = self.frameFroasty:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameFroasty:SetFrameStrata("MEDIUM")
	self.frameFroasty:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameFroasty:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texFroasty:SetTexture("Interface\\AddOns\\BigWigs\\Textures\\froasty")	
	self.texFroasty:SetAllPoints(self.frameFroasty)
	self.frameFroasty:SetAlpha(1.0)
	self.frameFroasty:Hide()

	self.frameFirevuln = CreateFrame("Frame", nil, UIParent)
	self.texFirevuln = self.frameFirevuln:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameFirevuln:SetFrameStrata("MEDIUM")
	self.frameFirevuln:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameFirevuln:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texFirevuln:SetTexture("Interface\\Icons\\Spell_Fire_Soulburn")	
	self.texFirevuln:SetAllPoints(self.frameFirevuln)
	self.frameFirevuln:SetAlpha(0.6)
	self.frameFirevuln:Hide()

	self.frameFFire = CreateFrame("Frame", nil, UIParent)
	self.texFFire = self.frameFFire:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameFFire:SetFrameStrata("MEDIUM")
	self.frameFFire:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameFFire:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texFFire:SetTexture("Interface\\Icons\\Spell_Nature_Faeriefire")	
	self.texFFire:SetAllPoints(self.frameFFire)
	self.frameFFire:SetAlpha(0.6)
	self.frameFFire:Hide()

	self.frameResistpot = CreateFrame("Frame", nil, UIParent)
	self.texResistpot = self.frameResistpot:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameResistpot:SetFrameStrata("MEDIUM")
	self.frameResistpot:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameResistpot:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texResistpot:SetTexture("Interface\\Icons\\Inv_Potion_16")	
	self.texResistpot:SetAllPoints(self.frameResistpot)
	self.frameResistpot:SetAlpha(0.6)
	self.frameResistpot:Hide()

	self.frameStoneshield = CreateFrame("Frame", nil, UIParent)
	self.texStoneshield = self.frameStoneshield:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameStoneshield:SetFrameStrata("MEDIUM")
	self.frameStoneshield:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameStoneshield:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texStoneshield:SetTexture("Interface\\Icons\\Inv_Potion_69")	
	self.texStoneshield:SetAllPoints(self.frameStoneshield)
	self.frameStoneshield:SetAlpha(0.6)
	self.frameStoneshield:Hide()

	self.frameLight = CreateFrame("Frame", nil, UIParent)
	self.texLight = self.frameLight:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameLight:SetFrameStrata("MEDIUM")
	self.frameLight:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameLight:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texLight:SetTexture("Interface\\Icons\\Spell_Holy_Healingaura")	
	self.texLight:SetAllPoints(self.frameLight)
	self.frameLight:SetAlpha(0.6)
	self.frameLight:Hide()

	self.frameWisdom = CreateFrame("Frame", nil, UIParent)
	self.texWisdom = self.frameWisdom:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameWisdom:SetFrameStrata("MEDIUM")
	self.frameWisdom:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameWisdom:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texWisdom:SetTexture("Interface\\Icons\\Spell_Holy_Righteousnessaura")	
	self.texWisdom:SetAllPoints(self.frameWisdom)
	self.frameWisdom:SetAlpha(0.6)
	self.frameWisdom:Hide()
	
	self.frameVoidZone = CreateFrame("Frame", nil, UIParent)
	self.texVoidZone = self.frameVoidZone:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameVoidZone:SetFrameStrata("MEDIUM")
	self.frameVoidZone:SetWidth(100)  -- Set These to whatever height/width is needed 
	self.frameVoidZone:SetHeight(100) -- for your Texture
	-- Apply Texture
	self.texVoidZone:SetTexture("Interface\\Icons\\Spell_Shadow_DeadofNight")	
	self.texVoidZone:SetAllPoints(self.frameVoidZone)
	self.frameVoidZone:SetAlpha(0.6)
	self.frameVoidZone:Hide()
	
	self:RegisterChatCommand({ "/"..L["setstrategy_cmd"] }, {
		type = "execute",
		name = L["setstrategy_name"],
		desc = L["setstrategy_desc"],
		func = function() self:BroadCastStrategy() end,
	})
end

function BigWigsThaddiusArrows:OnEnable()
	self.previousCharge = nil
	self.strat_four_current = 1

	local strategies = L["strat_validate"]
	if not strategies or not type(strategies) == "table" then
		error("Strategy table is not a table in BigWigs_ThaddiusArrows.")
		return
	end
	local count = 0
	for k in pairs(strategies) do
		count = count + 1
	end
	if count ~= 4 then
		error("Strategy table is invalid in BigWigs_ThaddiusArrows.")
		return
	end

	stratThrough = strategies[1]
	stratCircularLR = strategies[2]
	stratCircularRL = strategies[3]
	fourStates = strategies[4]

	local found = false
	for k, v in pairs(strategies) do
		if v == self.db.profile.strat then
			found = true
			break
		end
	end
	if not found or not self.db.profile.strat or type(self.db.profile.strat) ~= "string" then
		self:Print(L["Invalid Thaddius strategy, resetting to default."])
		self.db.profile.strat = stratThrough
	end

	self:Print(L["Thaddius strategy is set to "]..self.db.profile.strat)
	self:Print(L["Make sure everyone in the raid has the same strategy set!"])
	if IsRaidLeader() or IsRaidOfficer() then
		self:Print(L["You can run the command /bwtabc to broadcast your strategy and force your raid to use it."])
	end

	-- Events
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("BigWigs_Message")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "ThaddiusArrowsStrategy", 2)
end

function BigWigsThaddiusArrows:OnDisable()
	if self.frameArrow then self.frameArrow:Hide() end
	if self.framestraightArrow then self.framestraightArrow:Hide() end
	if self.frameBlizzard then self.frameBlizzard:Hide() end
	if self.frameGeddon then self.frameGeddon:Hide() end
	if self.frameRun then self.frameRun:Hide() end
	if self.frameHakkar then self.frameHakkar:Hide() end
	if self.frameShield then self.frameShield:Hide() end
	if self.frameTranq then self.frameTranq:Hide() end
	if self.frameFire then self.frameFire:Hide() end
	if self.frameCthunglare then self.frameCthunglare:Hide() end
	if self.frameCthuneyes then self.frameCthuneyes:Hide() end
	if self.frameCthungeyes then self.frameCthungeyes:Hide() end
	if self.frameCthungeyesactive then self.frameCthungeyesactive:Hide() end
	if self.frameCthungclaw then self.frameCthungclaw:Hide() end
	if self.frameNoth then self.frameNoth:Hide() end
	if self.frameSpore then self.frameSpore:Hide() end
	if self.frameGFPP then self.frameGFPP:Hide() end
	if self.frameGNPP then self.frameGNPP:Hide() end
	if self.frameGSPP then self.frameGSPP:Hide() end
	if self.frameSunder then self.frameSunder:Hide() end
	if self.frameCoE then self.frameCoE:Hide() end
	if self.frameCoS then self.frameCoS:Hide() end
	if self.frameCoR then self.frameCoR:Hide() end
	if self.frameFroasty then self.frameFroasty:Hide() end
	if self.frameFirevuln then self.frameFirevuln:Hide() end
	if self.frameFFire then self.frameFFire:Hide() end
	if self.frameResistpot then self.frameResistpot:Hide() end
	if self.frameStoneshield then self.frameStoneshield:Hide() end
	if self.frameLight then self.frameLight:Hide() end
	if self.frameWisdom then self.frameWisdom:Hide() end
	if self.frameVoidZone then self.frameVoidZone:Hide() end
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsThaddiusArrows:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, boss) then
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsThaddiusArrows:BroadCastStrategy()
	if not IsRaidLeader() and not IsRaidOfficer() then
		self:Print(L["You can't broadcast the strategy if you are not the leader or promoted in the raid group."])
		return
	end

	-- Find our strategy
	local found = nil
	for i, v in ipairs(L["strat_validate"]) do
		if v == self.db.profile.strat then
			found = i
			break
		end
	end
	if found == nil then return end

	self:Print(L["Broadcasting strategy ..."])
	self:TriggerEvent("BigWigs_SendSync", "ThaddiusArrowsStrategy "..found)
end

function BigWigsThaddiusArrows:BigWigs_RecvSync( sync, rest, nick )
	if sync ~= "ThaddiusArrowsStrategy" or not rest or not nick then return end
	if self.db.profile.strat == rest then return end

	-- Old style broadcast with name of strategy.
	if tonumber(rest) == nil then
		local found = nil
		for i, v in ipairs(L["strat_validate"]) do
			if v == rest then
				found = true
				break
			end
		end
		if found then
			self.db.profile.strat = rest
			self:Print(string.format(L["Strategy broadcast detected from %s. Strategy set to %s."], nick, rest))
			return
		else
			self:Print(string.format(L["Invalid Thaddius strategy received from %s."], nick))
			return
		end
	else
		rest = tonumber(rest)
		local count = 0
		for i, v in ipairs(L["strat_validate"]) do
			count = count + 1
		end
		if rest > count or rest < 1 then
			self:Print(string.format(L["Invalid Thaddius strategy received from %s."], nick))
			return
		else
			self.db.profile.strat = L["strat_validate"][rest]
			self:Print(string.format(L["Strategy broadcast detected from %s. Strategy set to %s."], nick, L["strat_validate"][rest]))
			return
		end
	end
end

function BigWigsThaddiusArrows:PLAYER_REGEN_ENABLED()
	local go = BigWigsThaddius:Scan()
	local running = self:IsEventScheduled("ThaddiusArrows_CheckWipe")
	if not go then
		self:TriggerEvent("BigWigs_RebootModule", self)
	elseif not running then
		self:ScheduleRepeatingEvent("ThaddiusArrows_CheckWipe", self.PLAYER_REGEN_ENABLED, 2, self)
	end
end

function BigWigsThaddiusArrows:Direction( direction )
	if direction == "Left" then -- Left Arrow
		if self.db.profile.graphic then
			self.frameArrow.texture = self.texArrow
			self.texArrow:SetTexCoord(0, 1, 0, 1)
			self.frameArrow:SetPoint("CENTER", -250, 100)
			self.frameArrow:Show()
			self:ScheduleEvent(function() self.frameArrow:Hide() end, 4)
		end
		if self.db.profile.sound then
			PlaySoundFile(L["soundleft"])
		end
		if self.db.profile.text then
			self:TriggerEvent("BigWigs_Message", L["warnleft"], "Red", true)
		end
	elseif direction == "Right" then -- Right Arrow
		if self.db.profile.graphic then
			self.frameArrow.texture = self.texArrow
			self.texArrow:SetTexCoord(1, 0, 0, 1)
			self.frameArrow:SetPoint("CENTER", 250, 100)
			self.frameArrow:Show()
			self:ScheduleEvent(function() self.frameArrow:Hide() end, 4)
		end
		if self.db.profile.sound then
			PlaySoundFile(L["soundright"])
		end
		if self.db.profile.text then
			self:TriggerEvent("BigWigs_Message", L["warnright"], "Red", true)
		end
	elseif direction == "Across" then -- Switch Sides
		if self.db.profile.graphic then
			self.framestraightArrow.texture = self.texstraightArrow
			self.texstraightArrow:SetTexCoord(0, 1, 0, 1)
			self.framestraightArrow:SetPoint("CENTER", 0, 200)
			self.framestraightArrow:Show()
			self:ScheduleEvent(function() self.framestraightArrow:Hide() end, 4)
		end
		if self.db.profile.sound then
			PlaySoundFile(L["soundacross"])
		end
		if self.db.profile.text then
			self:TriggerEvent("BigWigs_Message", L["warnacross"], "Red", true)
		end
	elseif direction == "Blizzard" then -- Blizzard warning
		if self.db.profile.graphic then
			self.frameBlizzard.texture = self.texBlizzard
			self.texBlizzard:SetTexCoord(0, 1, 0, 1)
			self.frameBlizzard:SetPoint("CENTER", 0, 250)
			self.frameBlizzard:Show()
		end
	elseif direction == "Geddon" then -- Geddon Bomb
		if self.db.profile.graphic then
			self.frameGeddon.texture = self.texGeddon
			self.texGeddon:SetTexCoord(0, 1, 0, 1)
			self.frameGeddon:SetPoint("CENTER", 0, 250)
			self.frameGeddon:Show()
			self:ScheduleEvent(function() self.frameGeddon:Hide() end, 10)
		end
	elseif direction == "Run" then -- Knockback
		if self.db.profile.graphic then
			self.frameRun.texture = self.texRun
			self.texRun:SetTexCoord(0, 1, 0, 1)
			self.frameRun:SetPoint("CENTER", 0, 250)
			self.frameRun:Show()
			self:ScheduleEvent(function() self.frameRun:Hide() end, 5)
		end
	elseif direction == "RunZG" then -- Mandokir
		if self.db.profile.graphic then
			self.frameRun.texture = self.texRun
			self.texRun:SetTexCoord(0, 1, 0, 1)
			self.frameRun:SetPoint("CENTER", 0, 250)
			self.frameRun:Show()
			self:ScheduleEvent(function() self.frameRun:Hide() end, 10)
		end
	elseif direction == "Hakkar" then -- Hakkar Sons
		if self.db.profile.graphic then
			self.frameHakkar.texture = self.texHakkar
			self.texHakkar:SetTexCoord(0, 1, 0, 1)
			self.frameHakkar:SetPoint("CENTER", 0, 250)
			self.frameHakkar:Show()
			self:ScheduleEvent(function() self.frameHakkar:Hide() end, 5)
		end
	elseif direction == "Shield" then -- Power Word: Shield
		if self.db.profile.graphic then
			self.frameShield.texture = self.texShield
			self.texShield:SetTexCoord(0, 1, 0, 1)
			self.frameShield:SetPoint("CENTER", 0, 25)
			self.frameShield:Show()
			self:ScheduleEvent(function() self.frameShield:Hide() end, 2)
		end
	elseif direction == "Tranq" then -- Tranqil helper
		if self.db.profile.graphic then
			self.frameTranq.texture = self.texTranq
			self.texTranq:SetTexCoord(0, 1, 0, 1)
			self.frameTranq:SetPoint("CENTER", 0, 100)
			self.frameTranq:Show()
			self:ScheduleEvent(function() self.frameTranq:Hide() end, 8)
		end
	elseif direction == "Fire" then -- Rain of Fire
		if self.db.profile.graphic then
			self.frameFire.texture = self.texFire
			self.texFire:SetTexCoord(0, 1, 0, 1)
			self.frameFire:SetPoint("CENTER", 0, 250)
			self.frameFire:Show()
		end
	elseif direction == "Cthunglare" then -- AQ40 C'Thun dark glare
		if self.db.profile.graphic then
			self.frameCthunglare.texture = self.texCthunglare
			self.texCthunglare:SetTexCoord(0, 1, 0, 1)
			self.frameCthunglare:SetPoint("CENTER", 0, 250)
			self.frameCthunglare:Show()
			self:ScheduleEvent(function() self.frameCthunglare:Hide() end, 5)
		end
	elseif direction == "Cthuneyes" then -- AQ40 C'Thun eyes
		if self.db.profile.graphic then
			self.frameCthuneyes.texture = self.texCthuneyes
			self.texCthuneyes:SetTexCoord(0, 1, 0, 1)
			self.frameCthuneyes:SetPoint("CENTER", 0, 250)
			self.frameCthuneyes:Show()
			self:ScheduleEvent(function() self.frameCthuneyes:Hide() end, 5)
		end
	elseif direction == "Cthungeyes" then -- AQ40 C'Thun giant eyes
		if self.db.profile.graphic then
			self.frameCthungeyes.texture = self.texCthungeyes
			self.texCthungeyes:SetTexCoord(0, 1, 0, 1)
			self.frameCthungeyes:SetPoint("CENTER", 0, 250)
			self.frameCthungeyes:Show()
			self:ScheduleEvent(function() self.frameCthungeyes:Hide() end, 5)
		end
	elseif direction == "Cthungeyesactive" then -- AQ40 C'Thun giant eyes
		if self.db.profile.graphic then
			self.frameCthungeyesactive.texture = self.texCthungeyesactive
			self.texCthungeyesactive:SetTexCoord(0, 1, 0, 1)
			self.frameCthungeyesactive:SetPoint("CENTER", -150, -20)
			self.frameCthungeyesactive:Show()
			self:ScheduleEvent(function() self.frameCthungeyesactive:Hide() end, 59)
		end
	elseif direction == "Cthungclaw" then -- AQ40 C'Thun giant claws
		if self.db.profile.graphic then
			self.frameCthungclaw.texture = self.texCthungclaw
			self.texCthungclaw:SetTexCoord(0, 1, 0, 1)
			self.frameCthungclaw:SetPoint("CENTER", 0, 250)
			self.frameCthungclaw:Show()
			self:ScheduleEvent(function() self.frameCthungclaw:Hide() end, 5)
		end
	elseif direction == "Noth" then -- Noth's blink
		if self.db.profile.graphic then
			self.frameNoth.texture = self.texNoth
			self.texNoth:SetTexCoord(0, 1, 0, 1)
			self.frameNoth:SetPoint("CENTER", 0, 250)
			self.frameNoth:Show()
			self:ScheduleEvent(function() self.frameNoth:Hide() end, 5)
		end
	elseif direction == "Spore" then -- Loatheb's spore
		if self.db.profile.graphic then
			self.frameSpore.texture = self.texSpore
			self.texSpore:SetTexCoord(0, 1, 0, 1)
			self.frameSpore:SetPoint("CENTER", 0, 250)
			self.frameSpore:Show()
			self:ScheduleEvent(function() self.frameSpore:Hide() end, 6)
		end
	elseif direction == "GFPP" then -- Fire Prot
		if self.db.profile.graphic then
			self.frameGFPP.texture = self.texGFPP
			self.texGFPP:SetTexCoord(0, 1, 0, 1)
			self.frameGFPP:SetPoint("CENTER", 175, 0)
			self.frameGFPP:Show()
			self:ScheduleEvent(function() self.frameGFPP:Hide() end, 5)
		end
	elseif direction == "GNPP" then -- Nature Prot
		if self.db.profile.graphic then
			self.frameGNPP.texture = self.texGNPP
			self.texGNPP:SetTexCoord(0, 1, 0, 1)
			self.frameGNPP:SetPoint("CENTER", 175, 0)
			self.frameGNPP:Show()
			self:ScheduleEvent(function() self.frameGNPP:Hide() end, 5)
		end
	elseif direction == "GSPP" then -- Shadow Prot
		if self.db.profile.graphic then
			self.frameGSPP.texture = self.texGSPP
			self.texGSPP:SetTexCoord(0, 1, 0, 1)
			self.frameGSPP:SetPoint("CENTER", 175, 0)
			self.frameGSPP:Show()
			self:ScheduleEvent(function() self.frameGSPP:Hide() end, 5)
		end
	elseif direction == "Sunder" then -- Sunder Armor
		if self.db.profile.graphic then
			self.frameSunder.texture = self.texSunder
			self.texSunder:SetTexCoord(0, 1, 0, 1)
			self.frameSunder:SetPoint("CENTER", -175, 100)
			self.frameSunder:Show()
			self:ScheduleEvent(function() self.frameSunder:Hide() end, 20)
		end
	elseif direction == "CoE" then -- Curse of Elements
		if self.db.profile.graphic then
			self.frameCoE.texture = self.texCoE
			self.texCoE:SetTexCoord(0, 1, 0, 1)
			self.frameCoE:SetPoint("CENTER", -175, 100)
			self.frameCoE:Show()
			self:ScheduleEvent(function() self.frameCoE:Hide() end, 20)
		end
	elseif direction == "CoS" then -- Curse of Shadow
		if self.db.profile.graphic then
			self.frameCoS.texture = self.texCoS
			self.texCoS:SetTexCoord(0, 1, 0, 1)
			self.frameCoS:SetPoint("CENTER", 175, 100)
			self.frameCoS:Show()
			self:ScheduleEvent(function() self.frameCoS:Hide() end, 20)
		end
	elseif direction == "CoR" then -- Curse of Recklessness
		if self.db.profile.graphic then
			self.frameCoR.texture = self.texCoR
			self.texCoR:SetTexCoord(0, 1, 0, 1)
			self.frameCoR:SetPoint("CENTER", -175, 200)
			self.frameCoR:Show()
			self:ScheduleEvent(function() self.frameCoR:Hide() end, 20)
		end
	elseif direction == "Froasty" then -- Froasty!
		if self.db.profile.graphic then
			self.frameFroasty.texture = self.texFroasty
			self.texFroasty:SetTexCoord(0, 1, 0, 1)
			self.frameFroasty:SetPoint("CENTER", 350, -200)
			self.frameFroasty:Show()
			self:ScheduleEvent(function() self.frameFroasty:Hide() end, 1)
		end
	elseif direction == "Firevuln" then -- Fire vulnerability
		if self.db.profile.graphic then
			self.frameFirevuln.texture = self.texFirevuln
			self.texFirevuln:SetTexCoord(0, 1, 0, 1)
			self.frameFirevuln:SetPoint("CENTER", -175, 100)
			self.frameFirevuln:Show()
			self:ScheduleEvent(function() self.frameFirevuln:Hide() end, 20)
		end
	elseif direction == "FFire" then -- Faerie Fire
		if self.db.profile.graphic then
			self.frameFFire.texture = self.texFFire
			self.texFFire:SetTexCoord(0, 1, 0, 1)
			self.frameFFire:SetPoint("CENTER", -175, 100)
			self.frameFFire:Show()
			self:ScheduleEvent(function() self.frameFFire:Hide() end, 20)
		end
	elseif direction == "Resistpot" then -- Magic Resistance Potion
		if self.db.profile.graphic then
			self.frameResistpot.texture = self.texResistpot
			self.texResistpot:SetTexCoord(0, 1, 0, 1)
			self.frameResistpot:SetPoint("CENTER", 175, 0)
			self.frameResistpot:Show()
			self:ScheduleEvent(function() self.frameResistpot:Hide() end, 7)
		end
	elseif direction == "Stoneshield" then -- Greater Stoneshield Potion
		if self.db.profile.graphic then
			self.frameStoneshield.texture = self.texStoneshield
			self.texStoneshield:SetTexCoord(0, 1, 0, 1)
			self.frameStoneshield:SetPoint("CENTER", 175, 0)
			self.frameStoneshield:Show()
			self:ScheduleEvent(function() self.frameStoneshield:Hide() end, 7)
		end
	elseif direction == "Light" then -- Seal of Light
		if self.db.profile.graphic then
			self.frameLight.texture = self.texLight
			self.texLight:SetTexCoord(0, 1, 0, 1)
			self.frameLight:SetPoint("CENTER", 175, 100)
			self.frameLight:Show()
			self:ScheduleEvent(function() self.frameLight:Hide() end, 15)
		end
	elseif direction == "Wisdom" then -- Seal of Wisdom
		if self.db.profile.graphic then
			self.frameWisdom.texture = self.texWisdom
			self.texWisdom:SetTexCoord(0, 1, 0, 1)
			self.frameWisdom:SetPoint("CENTER", -175, 100)
			self.frameWisdom:Show()
			self:ScheduleEvent(function() self.frameWisdom:Hide() end, 15)
		end
	elseif direction == "VoidZone" then -- Void Zone
		if self.db.profile.graphic then
			self.frameVoidZone.texture = self.texVoidZone
			self.texVoidZone:SetTexCoord(0, 1, 0, 1)
			self.frameVoidZone:SetPoint("CENTER", -175, 100)
			self.frameVoidZone:Show()
			self:ScheduleEvent(function() self.frameVoidZone:Hide() end, 15)
		end
	end
end

function BigWigsThaddiusArrows:BigWigs_Message( msg )
	local strat = self.db.profile.strat
	if msg == TL["nochange"] then
		if strat == stratCircularLR then
			self:Direction("Left")
		elseif strat == stratCircularRL then
			self:Direction("Right")
		elseif strat == fourStates then
			self:Direction(self.strat_four_states[self.strat_four_current].nochange.direction)
			self.strat_four_current = self.strat_four_states[self.strat_four_current].nochange.state
		end
		self.previousCharge = msg
	elseif msg == TL["poswarn"] or msg == TL["negwarn"] then
		if self.previousCharge then
			if strat == stratCircularLR then
				self:Direction("Right")
			elseif strat == stratThrough then
				self:Direction("Across")
			elseif strat == stratCircularRL then
				self:Direction("Left")
			elseif strat == fourStates then
				self:Direction(self.strat_four_states[self.strat_four_current].change.direction)
				self.strat_four_current = self.strat_four_states[self.strat_four_current].change.state
			end
		else
			-- First charge
			if msg == TL["poswarn"] then
				if strat == stratCircularLR then
					self:Direction("Left")
				elseif strat == stratCircularRL then
					self:Direction("Right")
				elseif strat == fourStates then
					self:Direction("Right")
					self.strat_four_current = 3
				end
			elseif msg == TL["negwarn"] then
				if strat == stratCircularLR then
					self:Direction("Right")
				elseif strat == stratCircularRL then
					self:Direction("Left")
				elseif strat == stratThrough then
					self:Direction("Across")
				elseif strat == fourStates then
					self:Direction("Left")
					self.strat_four_current = 2
				end
			end
		end
		self.previousCharge = msg
	end
end

function BigWigsThaddiusArrows:Tranqstop()
	self.frameTranq:Hide()
end

function BigWigsThaddiusArrows:Firestop()
	self.frameFire:Hide()
end

function BigWigsThaddiusArrows:Blizzardstop()
	self.frameBlizzard:Hide()
end

function BigWigsThaddiusArrows:GEyestop()
	self.frameCthungeyesactive:Hide()
end

function BigWigsThaddiusArrows:GFPPstop()
	self.frameGFPP:Hide()
end

function BigWigsThaddiusArrows:GNPPstop()
	self.frameGNPP:Hide()
end

function BigWigsThaddiusArrows:GSPPstop()
	self.frameGSPP:Hide()
end

function BigWigsThaddiusArrows:Sunderstop()
	self.frameSunder:Hide()
end

function BigWigsThaddiusArrows:CoEstop()
	self.frameCoE:Hide()
end

function BigWigsThaddiusArrows:CoSstop()
	self.frameCoS:Hide()
end

function BigWigsThaddiusArrows:CoRstop()
	self.frameCoR:Hide()
end

function BigWigsThaddiusArrows:Firevulnstop()
	self.frameFirevuln:Hide()
end

function BigWigsThaddiusArrows:FFirestop()
	self.frameFFire:Hide()
end

function BigWigsThaddiusArrows:Resistpotstop()
	self.frameResistpot:Hide()
end

function BigWigsThaddiusArrows:Stoneshieldstop()
	self.frameStoneshield:Hide()
end

function BigWigsThaddiusArrows:Lightstop()
	self.frameLight:Hide()
end

function BigWigsThaddiusArrows:Wisdomstop()
	self.frameWisdom:Hide()
end

function BigWigsThaddiusArrows:VoidZonestop()
	self.frameVoidZone:Hide()
end

function BigWigsThaddiusArrows:CrystalCharge()
	self:TriggerEvent("BigWigs_StartBar", self, L["Crystal Charge"], 120, "Interface\\Icons\\Inv_Misc_Gem_Amethyst_01")
end

