
assert( BigWigs, "BigWigs not found!")


------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsBars")
local paint = AceLibrary("PaintChips-2.0")
local candybar = AceLibrary("CandyBar-2.0")

local minscale, maxscale = 0.25, 2


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["Bars"] = true,

	["bars"] = true,
	["anchor"] = true,
	["scale"] = true,
	["up"] = true,
	["textsize"] = true,
	["width"] = true,
	["height"] = true,

	["Options for the timer bars."] = true,
	["Show the bar anchor frame."] = true,
	["Set the bar scale."] = true,
	["Bar text size"] = true,
	["Set the bar text size."] = true,
	["Group upwards"] = true,
	["Toggle bars grow upwards/downwards from anchor."] = true,

	["Timer bars"] = true,
	["Show anchor"] = true,
	["Grow bars upwards"] = true,
	["Scale"] = true,
	["Bar scale"] = true,
	["Bar width"] = true,
	["Set the bar width."] = true,
	["Bar height"] = true,
	["Set the bar height."] = true,
	
	["Bars now grow %2$s"] = true,
	["Scale is set to %2$s"] = true,

	["Up"] = true,
	["Down"] = true,
	
	["Test"] = true,
	["Close"] = true,

	["Texture"] = true,
	["Set the texture for the timerbars."] = true,

	["default"] = true,
	["smooth"] = true,
	["otravi"] = true,
	["Charcoal"] = true,
	["glaze"] = true,
    ["HP Bars"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Bars"] = "바",

	["Options for the timer bars."] = "Timer 바 옵션 조정.",
	["Show the bar anchor frame."] = "바 위치 조정 프레임 보이기.",
	["Set the bar scale."] = "바 크기 조절.",
	["Group upwards"] = "바 위로 생성",
	["Toggle bars grow upwards/downwards from anchor."] = "바 표시 순서를 위/아래로 조정.",

	["Timer bars"] = "타이머 바",
	["Show anchor"] = "앵커 보이기",
	["Grow bars upwards"] = "바 위로 생성",
	["Scale"]= "크기",
	["Bar scale"] = "바 크기",
	["Bars now grow %2$s"] = "바 생성 방향 : %2$s",
	["Scale is set to %2$s"] = "크기 설정 : %2$s",
  
	["Up"] = "위",
	["Down"] = "아래",

	["Test"] = "테스트",

	["default"] = "Default",
	["smooth"] = "Smooth",
	["otravi"] = "Otravi",
	["Charcoal"] = "Charcoal",
	["glaze"] = "glaze",
} end)

L:RegisterTranslations("zhCN", function() return {
	["Bars"] = "计时条",

	["bars"] = "计时条",
	["anchor"] = "锚点",
	["scale"] = "大小",
	["up"] = "上",

	["Options for the timer bars."] = "计时条设置/",
	["Show the bar anchor frame."] = "显示计时条框体锚点。",
	["Set the bar scale."] = "设置计时条缩放比例。",
	["Group upwards"] = "向上排列",
	["Toggle bars grow upwards/downwards from anchor."] = "切换计时条从锚点向下/向上排列。",

	["Timer bars"] = "计时条",
	["Show anchor"] = "显示锚点",
	["Grow bars upwards"] = "向上延展",
	["Scale"] = "缩放",
	["Bar scale"] = "计时条缩放",

	["Bars now grow %2$s"] = "计时条设置为向%2$s延展。",
	["Scale is set to %2$s"] = "缩放比例设置为%2$s",

	["Up"] = "上",
	["Down"] = "下",

	["Test"] = "测试",
	["Close"] = "关闭",

	["Texture"] = "材质",
	["Set the texture for the timerbars."] = "为计时条设定材质。",

	["default"] = "默认",
	["smooth"] = "圆滑",
	["otravi"] = "平整",
	["Charcoal"] = "炭条纹",
	["glaze"] = "釉纹",
} end)


L:RegisterTranslations("zhTW", function() return {
	["Bars"] = "計時條",

	["bars"] = "計時條",
	["anchor"] = "錨點",
	["scale"] = "大小",
	["up"] = "上",

	["Options for the timer bars."] = "計時條設置",
	["Show the bar anchor frame."] = "顯示計時條框架錨點。",
	["Set the bar scale."] = "設置計時條縮放比例。",
	["Group upwards"] = "向上排列",
	["Toggle bars grow upwards/downwards from anchor."] = "切換計時條從錨點向下/向上排列。",

	["Timer bars"] = "計時條",
	["Show anchor"] = "顯示錨點",
	["Grow bars upwards"] = "向上延展",
	["Scale"] = "縮放",
	["Bar scale"] = "計時條縮放",

	["Bars now grow %2$s"] = "計時條設置為向%2$s延展。",
	["Scale is set to %2$s"] = "縮放比例設置為%2$s",

	["Up"] = "上",
	["Down"] = "下",

	["Test"] = "測試",
	["Close"] = "關閉",

	["Texture"] = "材質",
	["Set the texture for the timerbars."] = "設定計時條的材質花紋",

	["default"] = "預設",
	["smooth"] = "平滑",
	["otravi"] = "otravi",
	["Charcoal"] = "木炭",
	["glaze"] = "glaze",
} end)


L:RegisterTranslations("deDE", function() return {
	["Bars"] = "Anzeigebalken",

	["bars"] = "balken",
	["anchor"] = "verankerung",
	["scale"] = "skalierung",
	["up"] = "oben",

	["Options for the timer bars."] = "Optionen f\195\188r die Timer Anzeigebalken.",
	["Show the bar anchor frame."] = "Verankerung der Anzeigebalken anzeigen.",
	["Set the bar scale."] = "Skalierung der Anzeigebalken w\195\164hlen.",
	["Group upwards"] = "Nach oben fortsetzen",
	["Toggle bars grow upwards/downwards from anchor."] = "Anzeigebalken von der Verankerung aus nach oben/unten fortsetzen.",

	["Timer bars"] = "Timer Anzeigebalken",
	["Show anchor"] = "Verankerung anzeigen",
	["Grow bars upwards"] = "Anzeigebalken nach oben fortsetzen",
	["Scale"] = "Skalierung",
	["Bar scale"] = "Anzeigebalken Skalierung",

	["Bars now grow %2$s"] = "Anzeigebalken werden nun fortgesetzt nach: %2$s",
	["Scale is set to %2$s"] = "Skalierung jetzt: %2$s",

	["Up"] = "oben",
	["Down"] = "unten",
	
	["Test"] = "Test",
	["Close"] = "Schlie\195\159en",

	["default"] = "Default",
	["smooth"] = "Smooth",
	["otravi"] = "Otravi",
	["Charcoal"] = "Charcoal",
	["Texture"] = "Textur",
	["Set the texture for the timerbars."] = "Textur der Anzeigebalken w\195\164hlen.",

	["default"] = "vorgabe",
	["smooth"] = "glatt",
	["otravi"] = "otravi",
	["Charcoal"] = "Charcoa",
	["glaze"] = "glaze",
} end)

L:RegisterTranslations("frFR", function() return {
	["Bars"] = "Barres",

	["Options for the timer bars."] = "Options concernant les barres temporelles.",
	["Show the bar anchor frame."] = "Affiche l'ancre du cadre des barres.",
	["Set the bar scale."] = "Détermine la taille des barres.",
	["Group upwards"] = "Ajouter vers le haut",
	["Toggle bars grow upwards/downwards from anchor."] = "Ajoute les nouvelles barres soit en haut de l'ancre, soit en bas de l'ancre.",

	["Timer bars"] = "Barres temporelles",
	["Show anchor"] = "Afficher l'ancre",
	["Grow bars upwards"] = "Ajouter barres vers le haut",
	["Scale"] = "Taille",
	["Bar scale"] = "Taille des barres",

	["Bars now grow %2$s"] = "Les barres s'ajoutent désormais vers le %2$s.",
	["Scale is set to %2$s"] = "La taille est désormais définie à %2$s.",

	["Up"] = "haut",
	["Down"] = "bas",
	
	["Test"] = "Test",
	["Close"] = "Fermer",

	["Texture"] = "Texture",
	["Set the texture for the timerbars."] = "Détermine la texture des barres temporelles.",

	["default"] = "défaut",
	["smooth"] = "smooth",
	["otravi"] = "otravi",
	["Charcoal"] = "Charcoal",	
	["glaze"] = "glaze",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsBars = BigWigs:NewModule(L["Bars"])
BigWigsBars.revision = tonumber(string.sub("$Revision: 19014 $", 12, -3))
BigWigsBars.defaultDB = {
	growup = false,
	scale = 1.0,
	textsize = 11,
	height = 16,
	width = 200,
	texture = L["default"],
}
BigWigsBars.consoleCmd = L["bars"]
BigWigsBars.consoleOptions = {
	type = "group",
	name = L["Bars"],
	desc = L["Options for the timer bars."],
	args   = {
		[L["anchor"]] = {
			type = "execute",
			name = L["Show anchor"],
			desc = L["Show the bar anchor frame."],
			func = function() BigWigsBars:BigWigs_ShowAnchors() end,
		},
		[L["up"]] = {
			type = "toggle",
			name = L["Group upwards"],
			desc = L["Toggle bars grow upwards/downwards from anchor."],
			get = function() return BigWigsBars.db.profile.growup end,
			set = function(v) BigWigsBars.db.profile.growup = v end,
			message = L["Bars now grow %2$s"],
			current = L["Bars now grow %2$s"],
			map = {[true] = L["Up"], [false] = L["Down"]},
		},
		[L["scale"]] = {
			type = "range",
			name = L["Bar scale"],
			desc = L["Set the bar scale."],
			min = 0.2,
			max = 2.0,
			step = 0.1,
			get = function() return BigWigsBars.db.profile.scale end,
			set = function(v) BigWigsBars.db.profile.scale = v end,
		},
		[L["textsize"]] = {
			type = "range",
			name = L["Bar text size"],
			desc = L["Set the bar text size."],
			min = 6,
			max = 50,
			step = 1,
			get = function() return BigWigsBars.db.profile.textsize end,
			set = function(v) BigWigsBars.db.profile.textsize = v end,
		},
		[L["width"]] = {
			type = "range",
			name = L["Bar width"],
			desc = L["Set the bar width."],
			min = 160,
			max = 800,
			step = 10,
			get = function() return BigWigsBars.db.profile.width end,
			set = function(v) BigWigsBars.db.profile.width = v end,
		},
		[L["height"]] = {
			type = "range",
			name = L["Bar height"],
			desc = L["Set the bar height."],
			min = 8,
			max = 40,
			step = 2,
			get = function() return BigWigsBars.db.profile.height end,
			set = function(v) BigWigsBars.db.profile.height = v end,
		},
		[L["Texture"]] = {
			type = "text",
			name = L["Texture"],
			desc = L["Set the texture for the timerbars."],
			get = function() return BigWigsBars.db.profile.texture end,
			set = function(v) BigWigsBars.db.profile.texture = v end,
			validate = { L["default"], L["otravi"], L["smooth"], L["Charcoal"], L["glaze"] },
		}
	},
}


------------------------------
--      Initialization      --
------------------------------

function BigWigsBars:OnEnable()
	if not self.db.profile.texture then self.db.profile.texture = L["default"] end
	self:SetupFrames()
	self:RegisterEvent("BigWigs_ShowAnchors")
	self:RegisterEvent("BigWigs_HideAnchors")
	self:RegisterEvent("BigWigs_StartBar")
	self:RegisterEvent("BigWigs_StopBar")
	self:RegisterEvent("BigWigs_StartHPBar")
	self:RegisterEvent("BigWigs_StopHPBar")
	self:RegisterEvent("BigWigs_SetHPBar")
end


------------------------------
--      Event Handlers      --
------------------------------

function BigWigsBars:BigWigs_ShowAnchors()
	if not self.frames.anchor then self:SetupFrames() end
	self.frames.anchor:Show()
	if not self.frames.hpAnchor then self:SetupHPBarFrame() end
    self.frames.hpAnchor:Show()
end


function BigWigsBars:BigWigs_HideAnchors()
	self.frames.anchor:Hide()
    self.frames.hpAnchor:Hide()
end

function BigWigsBars:BigWigs_StartBar(module, text, time, icon, otherc, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
	if not text or not time then return end
	local id = "BigWigsBar "..text
	
	--needed for banish bar to remove old bar when new banish is casted
	if c1 then 
		id = tostring(c1)
	end
	
	local u = self.db.profile.growup

	-- yes we try and register every time, we also set the point every time since people can change their mind midbar.
	module:RegisterCandyBarGroup("BigWigsGroup")
	module:SetCandyBarGroupPoint("BigWigsGroup", u and "BOTTOM" or "TOP", self.frames.anchor, u and "TOP" or "BOTTOM", 0, 0)
	module:SetCandyBarGroupGrowth("BigWigsGroup", u)

	local bc, balpha, txtc
	if BigWigsColors and type(BigWigsColors) == "table" then
		if type(otherc) ~= "boolean" or not otherc then c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 = BigWigsColors:BarColor(time) end
		bc, balpha, txtc = BigWigsColors.db.profile.bgc, BigWigsColors.db.profile.bga, BigWigsColors.db.profile.txtc
	end

 	module:RegisterCandyBar(id, time, text, icon, c1, c2, c3, c4, c5, c6, c8, c9, c10)
 	module:RegisterCandyBarWithGroup(id, "BigWigsGroup")
	local texture = "Interface\\AddOns\\BigWigsVG\\Textures\\" .. (L:HasReverseTranslation(self.db.profile.texture) and L:GetReverseTranslation( self.db.profile.texture ) or "default")
	module:SetCandyBarTexture( id, texture )
	if bc then module:SetCandyBarBackgroundColor(id, bc, balpha) end
	if txtc then module:SetCandyBarTextColor(id, txtc) end

	module:SetCandyBarScale(id, self.db.profile.scale or 1)
	module:SetCandyBarFontSize(id, self.db.profile.textsize or 12)
	module:SetCandyBarWidth(id, self.db.profile.width or 200)
	module:SetCandyBarHeight(id, self.db.profile.height or 16)
	module:SetCandyBarFade(id, .5)
	module:StartCandyBar(id, true)
end

function BigWigsBars:BigWigs_StopBar(module, text)
	if not text then return end
	module:UnregisterCandyBar("BigWigsBar "..text)
end

function BigWigsBars:BigWigs_StartHPBar(module, text, max, bar, icon, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10)
    if not text or not max then return end
	local id = "BigWigsBar "..text
    if not self.frames.hpAnchor then self:SetupHPBarFrame() end
            
	local bc, balpha, txtc
	if BigWigsColors and type(BigWigsColors) == "table" then
		if type(otherc) ~= "boolean" or not otherc then c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 = BigWigsColors:BarColor(max) end
		bc, balpha, txtc = BigWigsColors.db.profile.bgc, BigWigsColors.db.profile.bga, BigWigsColors.db.profile.txtc
	end

    local groupId = self.frames.hpAnchor.candyBarGroupId
	local scale = self.db.profile.scale or 1
    
	if groupId == self.frames.hpAnchor.candyBarGroupId and type(module.GetBarGroupId) == "function" then
		groupId = module:GetBarGroupId(text)
	end
    
    self:RegisterCandyBar(id, max, text, icon, c1, c2, c3, c4, c5, c6, c8, c9, c10)
	self:RegisterCandyBarWithGroup(id, groupId)
	
	
	local texture = "Interface\\AddOns\\BigWigsVG\\Textures\\" .. (L:HasReverseTranslation(self.db.profile.texture) and L:GetReverseTranslation( self.db.profile.texture ) or "default")
	module:SetCandyBarTexture( id, texture )

	if type(colorModule) == "table" then
		local bg = colorModule.db.profile.barBackground
		self:SetCandyBarBackgroundColor(id, bg.r, bg.g, bg.b, bg.a)
		local txt = colorModule.db.profile.barTextColor
		self:SetCandyBarTextColor(id, txt.r, txt.g, txt.b, txt.a)
	end

	if type(self.db.profile.width) == "number" then
		self:SetCandyBarWidth(id, self.db.profile.width)
	end
	if type(self.db.profile.height) == "number" then
		self:SetCandyBarHeight(id, self.db.profile.height)
	end

	self:SetCandyBarFade(id, .5)
	if self.db.profile.reverse then
		self:SetCandyBarReversed(id, self.db.profile.reverse)
	end

    self:SetCandyBarScale(id, scale)
    
	self:StartCandyBar(id, true)
	self:PauseCandyBar(id)
	self:SetCandyBarTimeFormat(id, function(t) local timetext if t == 100 then timetext = "100" elseif t == 0 then timetext = "0%%" else timetext = string.format("%d%%", t) end return timetext end)
	
	--[[
	local function OnBarClick(id)
		local exists, time, elapsed, running, paused = self:CandyBarStatus(id)
		if exists then
			BigWigs:TriggerEvent("BigWigs_Message", id .. " in " .. time .. "s", "Urgent", false, nil, true)
		end
	end
	
	self:SetCandyBarOnClick(id, OnBarClick, id)
	]]
    
    return id
end

function BigWigsBars:BigWigs_StopHPBar(module, text)
	if not text then return end
	BigWigsBars:BigWigs_StopBar(module, text)
end


function BigWigsBars:BigWigs_SetHPBar(module, text, value)
	if (not text) or (value == nil) or (value < 0) then return end
	local id = "BigWigsBar "..text
	local bar = candybar.var.handlers[id]
	if not bar then return end
	bar.elapsed = value
	candybar:Update(id)
	if bar.time <= value then
		BigWigsBars:BigWigs_StopBar(module, text)
	end
end

------------------------------
--      Slash Handlers      --
------------------------------

function BigWigsBars:SetScale(msg, supressreport)
	local scale = tonumber(msg)
	if scale and scale >= minscale and scale <= maxscale then
		self.db.profile.scale = scale
		if not supressreport then self.core:Print(L["Scale is set to %s"], scale) end
	end
end

function BigWigsBars:ToggleUp(supressreport)
	self.db.profile.growup = not self.db.profile.growup
	local t = self.db.profile.growup
	if not supressreport then self.core:Print(L["Bars now grow %s"], (t and L["Up"] or L["Down"])) end
end


------------------------------
--    Create the Anchor     --
------------------------------

function BigWigsBars:SetupFrames()
	local f, t	

	f, _, _ = GameFontNormal:GetFont()

	self.frames = {}
	self.frames.anchor = CreateFrame("Frame", "BigWigsBarAnchor", UIParent)
	self.frames.anchor.owner = self
	self.frames.anchor:Hide()

	self.frames.anchor:SetWidth(175)
	self.frames.anchor:SetHeight(75)
	self.frames.anchor:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
	self.frames.anchor:SetBackdropBorderColor(.5, .5, .5)
	self.frames.anchor:SetBackdropColor(0,0,0)
	self.frames.anchor:ClearAllPoints()
	self.frames.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self.frames.anchor:EnableMouse(true)
	self.frames.anchor:RegisterForDrag("LeftButton")
	self.frames.anchor:SetMovable(true)
	self.frames.anchor:SetScript("OnDragStart", function() this:StartMoving() end)
	self.frames.anchor:SetScript("OnDragStop", function() this:StopMovingOrSizing() this.owner:SavePosition() end)


	self.frames.cfade = self.frames.anchor:CreateTexture(nil, "BORDER")
	self.frames.cfade:SetWidth(169)
	self.frames.cfade:SetHeight(25)
	self.frames.cfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	self.frames.cfade:SetPoint("TOP", self.frames.anchor, "TOP", 0, -4)
	self.frames.cfade:SetBlendMode("ADD")
	self.frames.cfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .25, 1)
	self.frames.anchor.Fade = self.frames.fade

	self.frames.cheader = self.frames.anchor:CreateFontString(nil,"OVERLAY")
	self.frames.cheader:SetFont(f, 14)
	self.frames.cheader:SetWidth(150)
	self.frames.cheader:SetText(L["Bars"])
	self.frames.cheader:SetTextColor(1, .8, 0)
	self.frames.cheader:ClearAllPoints()
	self.frames.cheader:SetPoint("TOP", self.frames.anchor, "TOP", 0, -10)
	
	self.frames.leftbutton = CreateFrame("Button", nil, self.frames.anchor)
	self.frames.leftbutton.owner = self
	self.frames.leftbutton:SetWidth(40)
	self.frames.leftbutton:SetHeight(25)
	self.frames.leftbutton:SetPoint("RIGHT", self.frames.anchor, "CENTER", -10, -15)
	self.frames.leftbutton:SetScript( "OnClick", function()  self:TriggerEvent("BigWigs_Test") end )

	
	t = self.frames.leftbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", self.frames.leftbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	self.frames.leftbutton:SetNormalTexture(t)

	t = self.frames.leftbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.leftbutton)
	self.frames.leftbutton:SetPushedTexture(t)
	
	t = self.frames.leftbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.leftbutton)
	t:SetBlendMode("ADD")
	self.frames.leftbutton:SetHighlightTexture(t)
	self.frames.leftbuttontext = self.frames.leftbutton:CreateFontString(nil,"OVERLAY")
	self.frames.leftbuttontext:SetFontObject(GameFontHighlight)
	self.frames.leftbuttontext:SetText(L["Test"])
	self.frames.leftbuttontext:SetAllPoints(self.frames.leftbutton)

	self.frames.rightbutton = CreateFrame("Button", nil, self.frames.anchor)
	self.frames.rightbutton.owner = self
	self.frames.rightbutton:SetWidth(40)
	self.frames.rightbutton:SetHeight(25)
	self.frames.rightbutton:SetPoint("LEFT", self.frames.anchor, "CENTER", 10, -15)
	self.frames.rightbutton:SetScript( "OnClick", function() self:BigWigs_HideAnchors() end )

	
	t = self.frames.rightbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", self.frames.rightbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	self.frames.rightbutton:SetNormalTexture(t)

	t = self.frames.rightbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.rightbutton)
	self.frames.rightbutton:SetPushedTexture(t)
	
	t = self.frames.rightbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(self.frames.rightbutton)
	t:SetBlendMode("ADD")
	self.frames.rightbutton:SetHighlightTexture(t)
	self.frames.rightbuttontext = self.frames.rightbutton:CreateFontString(nil,"OVERLAY")
	self.frames.rightbuttontext:SetFontObject(GameFontHighlight)
	self.frames.rightbuttontext:SetText(L["Close"])
	self.frames.rightbuttontext:SetAllPoints(self.frames.rightbutton)

	self:RestorePosition()
end

function BigWigsBars:SetupHPBarFrame()
	if self.frames.hpAnchor then return end
    
    local f, t	

	f, _, _ = GameFontNormal:GetFont()

	--self.frames = {}
    
	local frame = CreateFrame("Frame", "BigWigsHPBarAnchor", UIParent)
    
	frame.owner = self
	frame:Hide()

	frame:SetWidth(175)
	frame:SetHeight(75)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
	frame:SetBackdropBorderColor(.5, .5, .5)
	frame:SetBackdropColor(0,0,0)
	frame:ClearAllPoints()
	frame:SetPoint("TOP", UIParent, "TOP", 500, 0)
	frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)
	frame:SetScript("OnDragStart", function() this:StartMoving() end)
	frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() this.owner:SavePosition() end)


	local cfade = frame:CreateTexture(nil, "BORDER")
	cfade:SetWidth(169)
	cfade:SetHeight(25)
	cfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	cfade:SetPoint("TOP", frame, "TOP", 0, -4)
	cfade:SetBlendMode("ADD")
	cfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .25, 1)
	frame.cfade = cfade

	local cheader = frame:CreateFontString(nil,"OVERLAY")
	cheader:SetFont(f, 14)
	cheader:SetWidth(150)
	cheader:SetText(L["HP Bars"])
	cheader:SetTextColor(1, .8, 0)
	cheader:ClearAllPoints()
	cheader:SetPoint("TOP", frame, "TOP", 0, -10)
    
    frame.cheader = cheader
	
	local leftbutton = CreateFrame("Button", nil, frame)
	leftbutton.owner = self
	leftbutton:SetWidth(40)
	leftbutton:SetHeight(25)
	leftbutton:SetText("asdfasdf")
	leftbutton:SetPoint("RIGHT", frame, "CENTER", -10, -15)
	leftbutton:SetScript("OnClick", function()  self:TriggerEvent("BigWigs_TestHP") end )

	
	t = leftbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", leftbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	leftbutton:SetNormalTexture(t)

	t = leftbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(leftbutton)
	leftbutton:SetPushedTexture(t)
	
	t = leftbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(leftbutton)
	t:SetBlendMode("ADD")
	leftbutton:SetHighlightTexture(t)
	leftbuttontext = leftbutton:CreateFontString(nil,"OVERLAY")
	leftbuttontext:SetFontObject(GameFontHighlight)
	leftbuttontext:SetText(L["Test"])
	leftbuttontext:SetAllPoints(leftbutton)
    
    frame.leftbutton = leftbutton

	local rightbutton = CreateFrame("Button", nil, frame)
	rightbutton.owner = self
	rightbutton:SetWidth(40)
	rightbutton:SetHeight(25)
	rightbutton:SetPoint("LEFT", frame, "CENTER", 10, -15)
	rightbutton:SetScript( "OnClick", function() self:BigWigs_HideAnchors() end )

	
	t = rightbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", rightbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	rightbutton:SetNormalTexture(t)

	t = rightbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(rightbutton)
	rightbutton:SetPushedTexture(t)
	
	t = rightbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(rightbutton)
	t:SetBlendMode("ADD")
	rightbutton:SetHighlightTexture(t)
	rightbuttontext = rightbutton:CreateFontString(nil,"OVERLAY")
	rightbuttontext:SetFontObject(GameFontHighlight)
	rightbuttontext:SetText(L["Close"])
	rightbuttontext:SetAllPoints(rightbutton)

    frame.rightbutton = rightbutton

    self.frames.hpAnchor = frame

    local value = self.db.profile.growup
    self.frames.hpAnchor.candyBarGroupId = "BigWigsBarHPGroup"
    self:RegisterCandyBarGroup(self.frames.hpAnchor.candyBarGroupId)
    self:SetCandyBarGroupPoint(self.frames.hpAnchor.candyBarGroupId, value and "BOTTOM" or "TOP", self.frames.hpAnchor, value and "TOP" or "BOTTOM", 0, 0)
    self:SetCandyBarGroupGrowth(self.frames.hpAnchor.candyBarGroupId, value)  
    
    self:RestorePositionHP()
end

function BigWigsBars:ResetAnchor(specific)
	if not specific or specific == "reset" or specific == "normal" then
		if not self.frames.anchor then self:SetupFrames() end
		self.frames.anchor:ClearAllPoints()
		if self.db.profile.emphasize and self.db.profile.emphasizeMove then
			self.frames.anchor:SetPoint("TOP", UIParent, "TOP", 0, 0)
		else
			self.frames.anchor:SetPoint("CENTER", UIParent, "CENTER")
		end
		self.db.profile.posx = nil
		self.db.profile.posy = nil
	end
    
    if not self.frames.hpAnchor then self:SetupHPBarFrame() end
    self.frames.hpAnchor:ClearAllPoints()
    self.frames.hpAnchor:SetPoint("TOP", UIParent, "TOP", 250, 0)
    self.db.profile.hpPosx = nil
    self.db.profile.hpPosy = nil
end




function BigWigsBars:SavePosition()
    if not self.frames.anchor then self:SetupFrames() end
    if not self.frames.hpAnchor then self:SetupHPBarFrame() end

	local f = self.frames.anchor
	local s = f:GetEffectiveScale()
		
	self.db.profile.posx = f:GetLeft() * s
	self.db.profile.posy = f:GetTop() * s	
    
    -- hp anchor
	local fhp = self.frames.hpAnchor
	local shp = fhp:GetEffectiveScale()

	self.db.profile.hpPosx = fhp:GetLeft() * shp
	self.db.profile.hpPosy = fhp:GetTop() * shp
    
end


function BigWigsBars:RestorePosition()
	local x = self.db.profile.posx
	local y = self.db.profile.posy
		
	if not x or not y then return end
				
	local f = self.frames.anchor
	local s = f:GetEffectiveScale()

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
end

function BigWigsBars:RestorePositionHP()
	local x = self.db.profile.hpPosx
	local y = self.db.profile.hpPosy
		
	if not x or not y then return end
				
	local f = self.frames.hpAnchor
	local s = f:GetEffectiveScale()

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
end

