assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsOnScreenIcons")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	mod = "OnScreenIcons",
	cmd = "OnScreenIcons",

	opt_name = "OnScreenIcons",
	opt_desc = "Options for the on screen icons.",
	
	icons = "Icons",
	graphic_name = "Graphical Icons",
	graphic_desc = "Display Graphical Icons",

} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsOnScreenIcons = BigWigs:NewModule(L["mod"])
BigWigsOnScreenIcons.revision = tonumber(string.sub("$Revision: 19012 $", 12, -3))
BigWigsOnScreenIcons.defaults = {
	icons = true,
}
BigWigsOnScreenIcons.defaultDB = {
	icons = true,
}
BigWigsOnScreenIcons.external = true
BigWigsOnScreenIcons.consoleCmd = L["cmd"]
BigWigsOnScreenIcons.consoleOptions = {
	type = "group",
	name = L["opt_name"],
	desc = L["opt_desc"],
	args = {
		[L["icons"]] = {
			type = "toggle",
			name = L["graphic_name"],
			desc = L["graphic_desc"],
			get = function() return BigWigsOnScreenIcons.db.profile.icons end,
			set = function(v)
				BigWigsOnScreenIcons.db.profile.icons = v
			end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsOnScreenIcons:OnRegister()
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
	self.texShield:SetTexture("Interface\\AddOns\\BigWigsVG\\Textures\\sporefung")	
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
	self.texCthunglare:SetTexture("Interface\\AddOns\\BigWigsVG\\Textures\\darkglare")	
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
	self.texCthungeyesactive:SetTexture("Interface\\AddOns\\BigWigsVG\\Textures\\Eye_Stalk")	
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
	
end

function BigWigsOnScreenIcons:OnDisable()
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

function BigWigsOnScreenIcons:Direction( direction )
	if direction == "Blizzard" then -- Blizzard warning
		if self.db.profile.icons then
			self.frameBlizzard.texture = self.texBlizzard
			self.texBlizzard:SetTexCoord(0, 1, 0, 1)
			self.frameBlizzard:SetPoint("CENTER", 0, 250)
			self.frameBlizzard:Show()
		end
	elseif direction == "Geddon" then -- Geddon Bomb
		if self.db.profile.icons then
			self.frameGeddon.texture = self.texGeddon
			self.texGeddon:SetTexCoord(0, 1, 0, 1)
			self.frameGeddon:SetPoint("CENTER", 0, 250)
			self.frameGeddon:Show()
			self:ScheduleEvent(function() self.frameGeddon:Hide() end, 10)
		end
	elseif direction == "Run" then -- Knockback
		if self.db.profile.icons then
			self.frameRun.texture = self.texRun
			self.texRun:SetTexCoord(0, 1, 0, 1)
			self.frameRun:SetPoint("CENTER", 0, 250)
			self.frameRun:Show()
			self:ScheduleEvent(function() self.frameRun:Hide() end, 5)
		end
	elseif direction == "RunZG" then -- Mandokir
		if self.db.profile.icons then
			self.frameRun.texture = self.texRun
			self.texRun:SetTexCoord(0, 1, 0, 1)
			self.frameRun:SetPoint("CENTER", 0, 250)
			self.frameRun:Show()
			self:ScheduleEvent(function() self.frameRun:Hide() end, 10)
		end
	elseif direction == "Hakkar" then -- Hakkar Sons
		if self.db.profile.icons then
			self.frameHakkar.texture = self.texHakkar
			self.texHakkar:SetTexCoord(0, 1, 0, 1)
			self.frameHakkar:SetPoint("CENTER", 0, 250)
			self.frameHakkar:Show()
			self:ScheduleEvent(function() self.frameHakkar:Hide() end, 5)
		end
	elseif direction == "Shield" then -- Power Word: Shield
		if self.db.profile.icons then
			self.frameShield.texture = self.texShield
			self.texShield:SetTexCoord(0, 1, 0, 1)
			self.frameShield:SetPoint("CENTER", 0, 25)
			self.frameShield:Show()
			self:ScheduleEvent(function() self.frameShield:Hide() end, 2)
		end
	elseif direction == "Tranq" then -- Tranqil helper
		if self.db.profile.icons then
			self.frameTranq.texture = self.texTranq
			self.texTranq:SetTexCoord(0, 1, 0, 1)
			self.frameTranq:SetPoint("CENTER", 0, 100)
			self.frameTranq:Show()
			self:ScheduleEvent(function() self.frameTranq:Hide() end, 8)
		end
	elseif direction == "Fire" then -- Rain of Fire
		if self.db.profile.icons then
			self.frameFire.texture = self.texFire
			self.texFire:SetTexCoord(0, 1, 0, 1)
			self.frameFire:SetPoint("CENTER", 0, 250)
			self.frameFire:Show()
		end
	elseif direction == "Cthunglare" then -- AQ40 C'Thun dark glare
		if self.db.profile.icons then
			self.frameCthunglare.texture = self.texCthunglare
			self.texCthunglare:SetTexCoord(0, 1, 0, 1)
			self.frameCthunglare:SetPoint("CENTER", 0, 250)
			self.frameCthunglare:Show()
			self:ScheduleEvent(function() self.frameCthunglare:Hide() end, 5)
		end
	elseif direction == "Cthuneyes" then -- AQ40 C'Thun eyes
		if self.db.profile.icons then
			self.frameCthuneyes.texture = self.texCthuneyes
			self.texCthuneyes:SetTexCoord(0, 1, 0, 1)
			self.frameCthuneyes:SetPoint("CENTER", 0, 250)
			self.frameCthuneyes:Show()
			self:ScheduleEvent(function() self.frameCthuneyes:Hide() end, 5)
		end
	elseif direction == "Cthungeyes" then -- AQ40 C'Thun giant eyes
		if self.db.profile.icons then
			self.frameCthungeyes.texture = self.texCthungeyes
			self.texCthungeyes:SetTexCoord(0, 1, 0, 1)
			self.frameCthungeyes:SetPoint("CENTER", 0, 250)
			self.frameCthungeyes:Show()
			self:ScheduleEvent(function() self.frameCthungeyes:Hide() end, 5)
		end
	elseif direction == "Cthungeyesactive" then -- AQ40 C'Thun giant eyes
		if self.db.profile.icons then
			self.frameCthungeyesactive.texture = self.texCthungeyesactive
			self.texCthungeyesactive:SetTexCoord(0, 1, 0, 1)
			self.frameCthungeyesactive:SetPoint("CENTER", -150, -20)
			self.frameCthungeyesactive:Show()
			self:ScheduleEvent(function() self.frameCthungeyesactive:Hide() end, 59)
		end
	elseif direction == "Cthungclaw" then -- AQ40 C'Thun giant claws
		if self.db.profile.icons then
			self.frameCthungclaw.texture = self.texCthungclaw
			self.texCthungclaw:SetTexCoord(0, 1, 0, 1)
			self.frameCthungclaw:SetPoint("CENTER", 0, 250)
			self.frameCthungclaw:Show()
			self:ScheduleEvent(function() self.frameCthungclaw:Hide() end, 5)
		end
	elseif direction == "Noth" then -- Noth's blink
		if self.db.profile.icons then
			self.frameNoth.texture = self.texNoth
			self.texNoth:SetTexCoord(0, 1, 0, 1)
			self.frameNoth:SetPoint("CENTER", 0, 250)
			self.frameNoth:Show()
			self:ScheduleEvent(function() self.frameNoth:Hide() end, 5)
		end
	elseif direction == "Spore" then -- Loatheb's spore
		if self.db.profile.icons then
			self.frameSpore.texture = self.texSpore
			self.texSpore:SetTexCoord(0, 1, 0, 1)
			self.frameSpore:SetPoint("CENTER", 0, 250)
			self.frameSpore:Show()
			self:ScheduleEvent(function() self.frameSpore:Hide() end, 6)
		end
	elseif direction == "GFPP" then -- Fire Prot
		if self.db.profile.icons then
			self.frameGFPP.texture = self.texGFPP
			self.texGFPP:SetTexCoord(0, 1, 0, 1)
			self.frameGFPP:SetPoint("CENTER", 175, 0)
			self.frameGFPP:Show()
			self:ScheduleEvent(function() self.frameGFPP:Hide() end, 5)
		end
	elseif direction == "GNPP" then -- Nature Prot
		if self.db.profile.icons then
			self.frameGNPP.texture = self.texGNPP
			self.texGNPP:SetTexCoord(0, 1, 0, 1)
			self.frameGNPP:SetPoint("CENTER", 175, 0)
			self.frameGNPP:Show()
			self:ScheduleEvent(function() self.frameGNPP:Hide() end, 5)
		end
	elseif direction == "GSPP" then -- Shadow Prot
		if self.db.profile.icons then
			self.frameGSPP.texture = self.texGSPP
			self.texGSPP:SetTexCoord(0, 1, 0, 1)
			self.frameGSPP:SetPoint("CENTER", 175, 0)
			self.frameGSPP:Show()
			self:ScheduleEvent(function() self.frameGSPP:Hide() end, 5)
		end
	elseif direction == "Sunder" then -- Sunder Armor
		if self.db.profile.icons then
			self.frameSunder.texture = self.texSunder
			self.texSunder:SetTexCoord(0, 1, 0, 1)
			self.frameSunder:SetPoint("CENTER", -175, 100)
			self.frameSunder:Show()
			self:ScheduleEvent(function() self.frameSunder:Hide() end, 20)
		end
	elseif direction == "CoE" then -- Curse of Elements
		if self.db.profile.icons then
			self.frameCoE.texture = self.texCoE
			self.texCoE:SetTexCoord(0, 1, 0, 1)
			self.frameCoE:SetPoint("CENTER", -175, 100)
			self.frameCoE:Show()
			self:ScheduleEvent(function() self.frameCoE:Hide() end, 20)
		end
	elseif direction == "CoS" then -- Curse of Shadow
		if self.db.profile.icons then
			self.frameCoS.texture = self.texCoS
			self.texCoS:SetTexCoord(0, 1, 0, 1)
			self.frameCoS:SetPoint("CENTER", 175, 100)
			self.frameCoS:Show()
			self:ScheduleEvent(function() self.frameCoS:Hide() end, 20)
		end
	elseif direction == "CoR" then -- Curse of Recklessness
		if self.db.profile.icons then
			self.frameCoR.texture = self.texCoR
			self.texCoR:SetTexCoord(0, 1, 0, 1)
			self.frameCoR:SetPoint("CENTER", -175, 200)
			self.frameCoR:Show()
			self:ScheduleEvent(function() self.frameCoR:Hide() end, 20)
		end
	elseif direction == "Firevuln" then -- Fire vulnerability
		if self.db.profile.icons then
			self.frameFirevuln.texture = self.texFirevuln
			self.texFirevuln:SetTexCoord(0, 1, 0, 1)
			self.frameFirevuln:SetPoint("CENTER", -175, 100)
			self.frameFirevuln:Show()
			self:ScheduleEvent(function() self.frameFirevuln:Hide() end, 20)
		end
	elseif direction == "FFire" then -- Faerie Fire
		if self.db.profile.icons then
			self.frameFFire.texture = self.texFFire
			self.texFFire:SetTexCoord(0, 1, 0, 1)
			self.frameFFire:SetPoint("CENTER", -175, 100)
			self.frameFFire:Show()
			self:ScheduleEvent(function() self.frameFFire:Hide() end, 20)
		end
	elseif direction == "Resistpot" then -- Magic Resistance Potion
		if self.db.profile.icons then
			self.frameResistpot.texture = self.texResistpot
			self.texResistpot:SetTexCoord(0, 1, 0, 1)
			self.frameResistpot:SetPoint("CENTER", 175, 0)
			self.frameResistpot:Show()
			self:ScheduleEvent(function() self.frameResistpot:Hide() end, 7)
		end
	elseif direction == "Stoneshield" then -- Greater Stoneshield Potion
		if self.db.profile.icons then
			self.frameStoneshield.texture = self.texStoneshield
			self.texStoneshield:SetTexCoord(0, 1, 0, 1)
			self.frameStoneshield:SetPoint("CENTER", 175, 0)
			self.frameStoneshield:Show()
			self:ScheduleEvent(function() self.frameStoneshield:Hide() end, 7)
		end
	elseif direction == "Light" then -- Seal of Light
		if self.db.profile.icons then
			self.frameLight.texture = self.texLight
			self.texLight:SetTexCoord(0, 1, 0, 1)
			self.frameLight:SetPoint("CENTER", 175, 100)
			self.frameLight:Show()
			self:ScheduleEvent(function() self.frameLight:Hide() end, 15)
		end
	elseif direction == "Wisdom" then -- Seal of Wisdom
		if self.db.profile.icons then
			self.frameWisdom.texture = self.texWisdom
			self.texWisdom:SetTexCoord(0, 1, 0, 1)
			self.frameWisdom:SetPoint("CENTER", -175, 100)
			self.frameWisdom:Show()
			self:ScheduleEvent(function() self.frameWisdom:Hide() end, 15)
		end
	elseif direction == "VoidZone" then -- Void Zone
		if self.db.profile.icons then
			self.frameVoidZone.texture = self.texVoidZone
			self.texVoidZone:SetTexCoord(0, 1, 0, 1)
			self.frameVoidZone:SetPoint("CENTER", -175, 100)
			self.frameVoidZone:Show()
			self:ScheduleEvent(function() self.frameVoidZone:Hide() end, 15)
		end
	end
end


function BigWigsOnScreenIcons:Tranqstop()
	self.frameTranq:Hide()
end

function BigWigsOnScreenIcons:Firestop()
	self.frameFire:Hide()
end

function BigWigsOnScreenIcons:Blizzardstop()
	self.frameBlizzard:Hide()
end

function BigWigsOnScreenIcons:GEyestop()
	self.frameCthungeyesactive:Hide()
end

function BigWigsOnScreenIcons:GFPPstop()
	self.frameGFPP:Hide()
end

function BigWigsOnScreenIcons:GNPPstop()
	self.frameGNPP:Hide()
end

function BigWigsOnScreenIcons:GSPPstop()
	self.frameGSPP:Hide()
end

function BigWigsOnScreenIcons:Sunderstop()
	self.frameSunder:Hide()
end

function BigWigsOnScreenIcons:CoEstop()
	self.frameCoE:Hide()
end

function BigWigsOnScreenIcons:CoSstop()
	self.frameCoS:Hide()
end

function BigWigsOnScreenIcons:CoRstop()
	self.frameCoR:Hide()
end

function BigWigsOnScreenIcons:Firevulnstop()
	self.frameFirevuln:Hide()
end

function BigWigsOnScreenIcons:FFirestop()
	self.frameFFire:Hide()
end

function BigWigsOnScreenIcons:Resistpotstop()
	self.frameResistpot:Hide()
end

function BigWigsOnScreenIcons:Stoneshieldstop()
	self.frameStoneshield:Hide()
end

function BigWigsOnScreenIcons:Lightstop()
	self.frameLight:Hide()
end

function BigWigsOnScreenIcons:Wisdomstop()
	self.frameWisdom:Hide()
end

function BigWigsOnScreenIcons:VoidZonestop()
	self.frameVoidZone:Hide()
end
