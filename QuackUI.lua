local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local SoundService     = game:GetService("SoundService")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")
local LocalPlayer      = Players.LocalPlayer

local Library = {}

-- ═══════════════════════════════════════════════════════════
-- STEALTH helpers — random names, high DisplayOrder 67
-- ═══════════════════════════════════════════════════════════
local function _rand(n)
	n = n or 10
	local t = {}
	for i = 1, n do
		t[i] = string.char(97 + math.random(0, 25))
	end
	return table.concat(t)
end

local function stealthName(prefix)
	return (prefix or "x") .. _rand(10) .. tostring(math.random(100, 999))
end

-- Track our guis without distinctive names
local _owned = setmetatable({}, { __mode = "k" })
function Library._mark(gui)
	if gui then _owned[gui] = true end
	return gui
end
function Library._isOurs(gui)
	return gui and _owned[gui] == true
end

-- Session tag for our GUIs (random each inject — not a fixed "Quack" string)
local OWN_ATTR = "a" .. _rand(8)
_G.__QX_ATTR = _G.__QX_ATTR or OWN_ATTR
OWN_ATTR = _G.__QX_ATTR

do
	local pg = LocalPlayer:WaitForChild("PlayerGui")
	for _, g in ipairs(pg:GetChildren()) do
		if g:GetAttribute(OWN_ATTR) == true then
			pcall(function() g:Destroy() end)
		end
	end
end
task.wait()

-- Default font: Font datatype (FontFace expects Font, not EnumItem)
local FingerPaint = Font.fromEnum(Enum.Font.GothamBold)
local LINE = Color3.fromRGB(235, 235, 240)
local DUCK_ID = "rbxassetid://71109437053861"
-- Z order above almost all game UI
local Z_TOP = 2147483647

local Themes = {
	Charcoal = {
		Background    = Color3.fromRGB(14, 14, 16),
		TitleBar      = Color3.fromRGB(18, 18, 20),
		Sidebar       = Color3.fromRGB(16, 16, 18),
		Text          = Color3.fromRGB(210, 210, 215),
		TextDim       = Color3.fromRGB(120, 120, 128),
		TextHighlight = Color3.fromRGB(245, 245, 248),
		Accent        = Color3.fromRGB(160, 160, 170),
		AccentOff     = Color3.fromRGB(40, 40, 44),
		Knob          = Color3.fromRGB(235, 235, 240),
		KnobOff       = Color3.fromRGB(120, 120, 128),
		Button        = Color3.fromRGB(30, 30, 34),
		ButtonStroke  = Color3.fromRGB(55, 55, 62),
		RowStroke     = Color3.fromRGB(50, 50, 56),
		SliderTrack   = Color3.fromRGB(28, 28, 32),
		SliderFill    = Color3.fromRGB(160, 160, 170),
		Close         = Color3.fromRGB(200, 100, 110),
	},
	Obsidian = {
		Background    = Color3.fromRGB(10, 10, 12),
		TitleBar      = Color3.fromRGB(14, 14, 16),
		Sidebar       = Color3.fromRGB(12, 12, 14),
		Text          = Color3.fromRGB(200, 200, 205),
		TextDim       = Color3.fromRGB(110, 110, 118),
		TextHighlight = Color3.fromRGB(240, 240, 245),
		Accent        = Color3.fromRGB(140, 140, 150),
		AccentOff     = Color3.fromRGB(32, 32, 36),
		Knob          = Color3.fromRGB(230, 230, 235),
		KnobOff       = Color3.fromRGB(110, 110, 118),
		Button        = Color3.fromRGB(24, 24, 28),
		ButtonStroke  = Color3.fromRGB(48, 48, 54),
		RowStroke     = Color3.fromRGB(42, 42, 48),
		SliderTrack   = Color3.fromRGB(22, 22, 26),
		SliderFill    = Color3.fromRGB(140, 140, 150),
		Close         = Color3.fromRGB(190, 90, 100),
	},
}

local DefaultTw = {
	snap   = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	soft   = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	press  = TweenInfo.new(0.08, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out),
	bounce = TweenInfo.new(0.32, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	open   = TweenInfo.new(0.48, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	close  = TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
	list   = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	listIn = TweenInfo.new(0.16, Enum.EasingStyle.Quad,  Enum.EasingDirection.In),
	modal  = TweenInfo.new(0.32, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	notif  = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local function mk(c, p)
	local o = Instance.new(c)
	for k, v in pairs(p or {}) do
		if k == "FontFace" and typeof(v) == "EnumItem" then
			o.FontFace = Font.fromEnum(v)
		else
			o[k] = v
		end
	end
	return o
end
local function corner(p, r)
	return mk("UICorner", {CornerRadius = UDim.new(0, r or 10), Parent = p})
end
local function stroke(p, col, th, tr)
	return mk("UIStroke", {
		Color = col or Color3.fromRGB(55, 55, 62),
		Thickness = th or 1,
		Transparency = tr or 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
		Parent = p,
	})
end
local function safeName(name)
	name = tostring(name or "default"):gsub("[^%w%-%_]", "_")
	if name == "" then name = "default" end
	return name
end

-- ═══════════════════════════════════════════════════════════
-- LOADER
-- ═══════════════════════════════════════════════════════════
function Library:CreateLoader(opts)
	opts = opts or {}
	local Title     = opts.Title or "QuackHub"
	local Subtitle  = opts.Subtitle or "Initializing"
	local ThemeName = opts.Theme or "Charcoal"
	local Colors    = {}
	for k, v in pairs(Themes[ThemeName] or Themes.Charcoal) do Colors[k] = v end
	if opts.Colors then for k, v in pairs(opts.Colors) do Colors[k] = v end end

	local Texts    = opts.Texts or {
		{ Text = "Loading core...", Duration = 0.8 },
		{ Text = "Almost ready...", Duration = 0.7 },
	}
	local OnFinish = opts.OnFinish
	local FadeTime = opts.FadeTime or 0.4
	local BarColor = opts.BarColor or Colors.Accent
	local ShowBar  = opts.ShowBar ~= false
	local Width    = opts.Width or 360
	local Height   = opts.Height or 170
	local FloatId  = opts.FloatImage or DUCK_ID

	local gui = mk("ScreenGui", {
		Name = stealthName("ld"), ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = Z_TOP,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})
	gui:SetAttribute(OWN_ATTR, true)
	Library._mark(gui)

	local bg = mk("Frame", {
		Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(8,8,10),
		BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = gui,
	})

	local floatImg = mk("ImageLabel", {
		AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromOffset(220,220), BackgroundTransparency = 1, BorderSizePixel = 0,
		Image = FloatId, ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Fit,
		ZIndex = 1, Parent = gui,
	})
	local floatSc = mk("UIScale", {Scale = 1, Parent = floatImg})
	task.spawn(function()
		local t = 0
		while floatImg.Parent do
			t += task.wait()
			floatImg.Position = UDim2.new(0.5, math.cos(t*0.45)*12, 0.5, math.sin(t*0.7)*18)
			floatSc.Scale = 1 + math.sin(t*0.5)*0.06
		end
	end)

	local card = mk("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromOffset(Width, Height),
		BackgroundColor3 = Colors.Background, BackgroundTransparency = 0.2,
		BorderSizePixel = 0, ZIndex = 2, Parent = gui,
	})
	corner(card, 14) stroke(card, Colors.ButtonStroke, 1.2, 0.4)
	local cardSc = mk("UIScale", {Scale = 0.94, Parent = card})

	mk("TextLabel", {
		Position = UDim2.fromOffset(0,24), Size = UDim2.new(1,0,0,28),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = Title, FontFace = FingerPaint,
		TextSize = 24, TextColor3 = Colors.Text, ZIndex = 3, Parent = card,
	})
	mk("TextLabel", {
		Position = UDim2.fromOffset(0,54), Size = UDim2.new(1,0,0,20),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = Subtitle, FontFace = FingerPaint,
		TextSize = 14, TextColor3 = Colors.TextDim, ZIndex = 3, Parent = card,
	})
	local status = mk("TextLabel", {
		Position = UDim2.fromOffset(20,95), Size = UDim2.new(1,-40,0,20),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", FontFace = FingerPaint,
		TextSize = 14, TextColor3 = Colors.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3, Parent = card,
	})

	local barFill
	if ShowBar then
		local barBg = mk("Frame", {
			Position = UDim2.fromOffset(20,128), Size = UDim2.new(1,-40,0,6),
			BackgroundColor3 = Colors.AccentOff, BorderSizePixel = 0, ZIndex = 3, Parent = card,
		})
		corner(barBg, 3)
		barFill = mk("Frame", {Size = UDim2.fromScale(0,1), BackgroundColor3 = BarColor, BorderSizePixel = 0, Parent = barBg})
		corner(barFill, 3)
	end

	card.BackgroundTransparency = 1
	bg.BackgroundTransparency = 1
	floatImg.ImageTransparency = 1
	TweenService:Create(bg, TweenInfo.new(FadeTime), {BackgroundTransparency = 0.15}):Play()
	TweenService:Create(card, TweenInfo.new(FadeTime), {BackgroundTransparency = 0.2}):Play()
	TweenService:Create(cardSc, DefaultTw.bounce, {Scale = 1}):Play()
	TweenService:Create(floatImg, TweenInfo.new(FadeTime), {ImageTransparency = 0.55}):Play()

	task.spawn(function()
		local total = #Texts
		for i, entry in ipairs(Texts) do
			status.Text = entry.Text or ("Step "..i)
			status.TextTransparency = 1
			TweenService:Create(status, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
			if ShowBar and barFill then
				TweenService:Create(barFill, TweenInfo.new((entry.Duration or 0.9)*0.85, Enum.EasingStyle.Quad), {
					Size = UDim2.fromScale(i/total, 1)
				}):Play()
			end
			if typeof(entry.Callback) == "function" then task.spawn(entry.Callback, i, entry.Text, entry) end
			task.wait(entry.Duration or 0.9)
		end
		if ShowBar and barFill then
			TweenService:Create(barFill, TweenInfo.new(0.15), {Size = UDim2.fromScale(1,1)}):Play()
		end
		status.Text = opts.FinishText or "Ready"
		task.wait(0.35)
		TweenService:Create(cardSc, DefaultTw.soft, {Scale = 0.96}):Play()
		local t1 = TweenService:Create(card, TweenInfo.new(FadeTime), {BackgroundTransparency = 1})
		local t2 = TweenService:Create(bg, TweenInfo.new(FadeTime), {BackgroundTransparency = 1})
		local t3 = TweenService:Create(floatImg, TweenInfo.new(FadeTime), {ImageTransparency = 1})
		t1:Play() t2:Play() t3:Play()
		t1.Completed:Connect(function()
			gui:Destroy()
			if typeof(OnFinish) == "function" then OnFinish() end
		end)
	end)

	return { Destroy = function() if gui then gui:Destroy() end end, Gui = gui }
end

-- ═══════════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════════
function Library:CreateWindow(opts)
	opts = opts or {}

	local Title         = opts.Title or "QuackHub"
	local MAIN_W        = opts.Width or 800
	local MAIN_H        = opts.Height or 560
	local TITLE_H       = opts.TitleHeight or 58
	local SIDEBAR_W     = opts.SidebarWidth or 170
	local ThemeName     = opts.Theme or "Charcoal"
	local ToggleKey     = opts.ToggleKey or Enum.KeyCode.K
	local WMText        = opts.Watermark or "QuackHub"
	local ConfigFolder  = opts.ConfigFolder or "QuackHubConfigs"
	local MainTrans     = opts.MainTransparency or 0.22
	local TitleTrans    = 0.08
	local SidebarTrans  = opts.SidebarTransparency or 0.28
	local CornerR       = opts.CornerRadius or 14
	local SoundEnabled  = opts.SoundEnabled ~= false
	-- Stealth = random names + top DisplayOrder only (mascot/UI stay)
	local StealthMode   = opts.Stealth ~= false  -- default ON
	local ShowWatermark = opts.ShowWatermark == true  -- watermark still off by default
	local ShowDropBtn   = opts.ShowDropButton ~= false  -- floating duck button ON
	local HeaderImage   = opts.HeaderImage or DUCK_ID   -- header duck ON
	local FloatImage    = opts.FloatImage or DUCK_ID    -- loader/float duck ON
	-- optional custom font
	if opts.UseCustomFont == true then
		local ok, res = pcall(function() return Font.fromId(12187375716) end)
		if ok and typeof(res) == "Font" then FingerPaint = res end
	end

	-- dense layout
	local ROW_H   = 44
	local BTN_H   = 36
	local FIELD_H = 30
	local PAD     = 10

	local Colors = {}
	for k, v in pairs(Themes[ThemeName] or Themes.Charcoal) do Colors[k] = v end
	if opts.Colors then for k, v in pairs(opts.Colors) do Colors[k] = v end end

	local Tw = {}
	for k, v in pairs(DefaultTw) do Tw[k] = v end
	if opts.Tween then for k, v in pairs(opts.Tween) do Tw[k] = v end end

	local Sounds, LastHover, LastSlider = {}, 0, 0
	if SoundEnabled then
		local function makeSound(n, id, v)
			local s = Instance.new("Sound")
			s.SoundId, s.Volume, s.Parent = id, v, SoundService
			Sounds[n] = s
		end
		local ids = opts.SoundIds or {}
		makeSound("click",  ids.click  or "rbxassetid://6895079853", 0.35)
		makeSound("hover",  ids.hover  or "rbxassetid://107511012621133", 0.2)
		makeSound("close",  ids.close  or "rbxassetid://97375206361343", 0.3)
		makeSound("notify", ids.notify or "rbxassetid://71730540025978", 0.35)
		makeSound("toggle", ids.toggle or "rbxassetid://128389255905279", 0.35)
		makeSound("slider", ids.slider or "rbxassetid://121370732132760", 0.5)
	end
	local function play(n)
		if not SoundEnabled then return end
		local s = Sounds[n]
		if s then s:Stop() s:Play() end
	end
	local function playHover()
		if not SoundEnabled then return end
		local t = os.clock()
		if t - LastHover < 0.06 then return end
		LastHover = t
		play("hover")
	end
	local function playSlider()
		if not SoundEnabled then return end
		local t = os.clock()
		if t - LastSlider < 0.04 then return end
		LastSlider = t
		play("slider")
	end

	local ScreenGui = mk("ScreenGui", {
		Name = stealthName("ui"), ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = Z_TOP,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = LocalPlayer:WaitForChild("PlayerGui"),
	})
	ScreenGui:SetAttribute(OWN_ATTR, true)
	Library._mark(ScreenGui)


	-- keep above game UI (some scripts lower foreign DisplayOrder)
	task.spawn(function()
		while ScreenGui and ScreenGui.Parent do
			if ScreenGui.DisplayOrder < Z_TOP - 10 then
				ScreenGui.DisplayOrder = Z_TOP
			end
			if not ScreenGui.Enabled then
				ScreenGui.Enabled = true
			end
			task.wait(0.5)
		end
	end)

	local PopupLayer = mk("Frame", {
		Name = "PopupLayer", Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 900, Parent = ScreenGui,
	})

	local OpenPops, ConfigEls = {}, {}
	local closeAll, closeOne
	local lastPos = UDim2.fromScale(0.5, 0.5)

	local NotifBox = mk("Frame", {
		AnchorPoint = Vector2.new(1,1), Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(320, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
		ZIndex = 10000, Parent = ScreenGui,
	})
	mk("UIListLayout", {
		Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = NotifBox,
	})

	local nOrder = 0
	local function Notify(title, text, dur)
		dur = dur or 4
		nOrder += 1
		play("notify")
		local n = mk("Frame", {
			Size = UDim2.fromOffset(300,0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Colors.Background, BackgroundTransparency = 1,
			BorderSizePixel = 0, LayoutOrder = nOrder, Parent = NotifBox,
		})
		corner(n, 10)
		local ns = stroke(n, LINE, 1.2, 1)
		local nSc = mk("UIScale", {Scale = 0.88, Parent = n})
		mk("UIPadding", {
			PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10),
			PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), Parent = n,
		})
		mk("ImageLabel", {
			Position = UDim2.fromOffset(0,2), Size = UDim2.fromOffset(20,20),
			BackgroundTransparency = 1, BorderSizePixel = 0, Image = "rbxassetid://10709775704",
			ImageColor3 = LINE, Parent = n,
		})
		mk("TextLabel", {
			Position = UDim2.fromOffset(28,0), Size = UDim2.new(1,-28,0,18),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = title, FontFace = FingerPaint,
			TextSize = 16, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = n,
		})
		mk("TextLabel", {
			Position = UDim2.fromOffset(28,20), Size = UDim2.new(1,-28,0,0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Text = text,
			FontFace = FingerPaint, TextSize = 13, TextColor3 = Colors.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = n,
		})
		n.Position = UDim2.fromOffset(340, 0)
		TweenService:Create(n, Tw.notif, {Position = UDim2.fromOffset(0,0), BackgroundTransparency = 0.25}):Play()
		TweenService:Create(nSc, Tw.bounce, {Scale = 1}):Play()
		TweenService:Create(ns, Tw.notif, {Transparency = 0.5}):Play()
		task.delay(dur, function()
			local t1 = TweenService:Create(n, Tw.notif, {Position = UDim2.fromOffset(340,0), BackgroundTransparency = 1})
			local t2 = TweenService:Create(nSc, Tw.soft, {Scale = 0.9})
			local t3 = TweenService:Create(ns, Tw.notif, {Transparency = 1})
			t1:Play() t2:Play() t3:Play()
			t1.Completed:Connect(function() n:Destroy() end)
		end)
	end

	if ShowWatermark then
		local WM = mk("Frame", {
			AnchorPoint = Vector2.new(0,0), Position = UDim2.new(0,12,0,72),
			Size = UDim2.fromOffset(170,26), BackgroundColor3 = Colors.TitleBar,
			BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 1000, Parent = ScreenGui,
		})
		corner(WM, 8) stroke(WM, LINE, 1, 0.5)
		local WMLabel = mk("TextLabel", {
			Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = WMText.." | FPS: 60", FontFace = FingerPaint, TextSize = 13, TextColor3 = Colors.Text, Parent = WM,
		})
		task.spawn(function()
			local fps, fr, el = 60, 0, 0
			RunService.RenderStepped:Connect(function(dt)
				fr += 1 el += dt
				if el >= 1 then
					fps = math.floor(fr/el) fr, el = 0, 0
					WMLabel.Text = string.format("%s | FPS: %d", WMText, fps)
				end
			end)
		end)
	end

	local DropBtn
	if ShowDropBtn then
		DropBtn = mk("TextButton", {
			Name = "DropButton", AnchorPoint = Vector2.new(0.5,0),
			Position = UDim2.new(0.5,0,0,12), Size = UDim2.fromOffset(52,52),
			BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.15,
			Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10, Parent = ScreenGui,
		})
		corner(DropBtn, 14) stroke(DropBtn, Colors.ButtonStroke, 1.4, 0.3)

		local duck = mk("ImageLabel", {
			AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
			Size = UDim2.fromOffset(32,32), BackgroundTransparency = 1, BorderSizePixel = 0,
			Image = FloatImage, ImageTransparency = 0, ScaleType = Enum.ScaleType.Fit,
			ZIndex = 12, Parent = DropBtn,
		})
		local duckSc = mk("UIScale", {Scale = 1, Parent = duck})

		task.spawn(function()
			local t = 0
			while duck.Parent do
				t += task.wait()
				if not DropBtn:GetAttribute("Hovering") then
					duck.Rotation = math.sin(t * 1.6) * 6
					duckSc.Scale = 1 + math.sin(t * 2.2) * 0.04
				end
			end
		end)

		DropBtn.MouseEnter:Connect(function()
			playHover()
			DropBtn:SetAttribute("Hovering", true)
			TweenService:Create(DropBtn, Tw.snap, {BackgroundColor3 = Colors.AccentOff}):Play()
			TweenService:Create(duckSc, Tw.bounce, {Scale = 1.18}):Play()
			TweenService:Create(duck, Tw.soft, {Rotation = -12}):Play()
		end)
		DropBtn.MouseLeave:Connect(function()
			DropBtn:SetAttribute("Hovering", false)
			TweenService:Create(DropBtn, Tw.snap, {BackgroundColor3 = Colors.Button}):Play()
			TweenService:Create(duckSc, Tw.soft, {Scale = 1}):Play()
			TweenService:Create(duck, Tw.soft, {Rotation = 0}):Play()
		end)
		DropBtn.MouseButton1Down:Connect(function()
			TweenService:Create(duckSc, Tw.press, {Scale = 0.9}):Play()
			TweenService:Create(duck, Tw.press, {Rotation = 15}):Play()
		end)
		DropBtn.MouseButton1Up:Connect(function()
			TweenService:Create(duckSc, Tw.bounce, {Scale = 1.12}):Play()
			TweenService:Create(duck, Tw.bounce, {Rotation = -8}):Play()
		end)
	end

	local Main = mk("CanvasGroup", {
		Name = "MainFrame", AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(MAIN_W, MAIN_H),
		BackgroundColor3 = Colors.Background, BackgroundTransparency = MainTrans,
		BorderSizePixel = 0, ClipsDescendants = true, GroupTransparency = 0,
		Visible = false, Parent = ScreenGui,
	})
	corner(Main, CornerR) stroke(Main, LINE, 1.2, 0.65)

	local TitleBar = mk("Frame", {
		Name = "TitleBar", Size = UDim2.new(1,0,0,TITLE_H),
		BackgroundColor3 = Colors.TitleBar, BackgroundTransparency = TitleTrans,
		BorderSizePixel = 0, Active = true, ZIndex = 5, Parent = Main,
	})

	local headerIcon = mk("ImageLabel", {
		Position = UDim2.fromOffset(14, 13), Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Colors.AccentOff, BackgroundTransparency = 0.35, BorderSizePixel = 0,
		Image = HeaderImage, ImageTransparency = 0, ScaleType = Enum.ScaleType.Fit,
		ZIndex = 7, Parent = TitleBar,
	})
	corner(headerIcon, 8)

	mk("TextLabel", {
		Position = UDim2.fromOffset(56,0), Size = UDim2.new(1,-140,1,0),
		BackgroundTransparency = 1, BorderSizePixel = 0, Text = Title, FontFace = FingerPaint,
		TextSize = 23, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7, Parent = TitleBar,
	})

	mk("Frame", {
		Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,0),
		BackgroundColor3 = LINE, BackgroundTransparency = 0.55,
		BorderSizePixel = 0, ZIndex = 6, Parent = TitleBar,
	})

	local function ctrlBtn(glyph, x, col, fn)
		local b = mk("TextButton", {
			AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,x,0.5,0),
			Size = UDim2.fromOffset(30,30), BackgroundTransparency = 1, BorderSizePixel = 0, Text = glyph,
			FontFace = FingerPaint, TextSize = 22, TextColor3 = col, AutoButtonColor = false, ZIndex = 8, Parent = TitleBar,
		})
		b.MouseEnter:Connect(function()
			playHover()
			TweenService:Create(b, Tw.snap, {TextColor3 = Colors.TextHighlight}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(b, Tw.soft, {TextColor3 = col}):Play()
		end)
		b.MouseButton1Click:Connect(fn)
		return b
	end

	local Sidebar = mk("Frame", {
		Name = "Sidebar", Position = UDim2.fromOffset(0, TITLE_H + 1),
		Size = UDim2.new(0, SIDEBAR_W, 1, -(TITLE_H + 1)),
		BackgroundColor3 = Colors.Sidebar, BackgroundTransparency = SidebarTrans,
		BorderSizePixel = 0, ZIndex = 2, Parent = Main,
	})
	local TabScroll = mk("ScrollingFrame", {
		Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 2, ScrollBarImageColor3 = LINE,
		ScrollBarImageTransparency = 0.55, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Sidebar,
	})
	mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4), Parent = TabScroll})
	mk("UIPadding", {
		PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,8),
		PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,10), Parent = TabScroll,
	})

	local Content = mk("Frame", {
		Name = "ContentArea", Position = UDim2.fromOffset(SIDEBAR_W, TITLE_H + 1),
		Size = UDim2.new(1, -SIDEBAR_W, 1, -(TITLE_H + 1)), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = Main,
	})

	local Overlay = mk("Frame", {
		Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 1005, Parent = ScreenGui,
	})
	local Box = mk("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromOffset(300,150), BackgroundColor3 = Colors.TitleBar,
		BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 1006, Parent = Overlay,
	})
	corner(Box, 12) stroke(Box, Colors.ButtonStroke, 1.4, 0.35)
	local bSc = mk("UIScale", {Scale = 1, Parent = Box})
	mk("TextLabel", {
		Size = UDim2.new(1,0,0,56), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "Close UI?",
		FontFace = FingerPaint, TextSize = 22, TextColor3 = Colors.Text, ZIndex = 1007, Parent = Box,
	})
	local Yes = mk("TextButton", {
		Position = UDim2.fromOffset(20,88), Size = UDim2.fromOffset(120,38),
		BackgroundColor3 = Colors.Button, BorderSizePixel = 0, Text = "Yes", FontFace = FingerPaint,
		TextSize = 16, TextColor3 = Colors.Text, AutoButtonColor = false, ZIndex = 1007, Parent = Box,
	})
	corner(Yes, 9)
	local No = mk("TextButton", {
		Position = UDim2.new(1,-140,0,88), Size = UDim2.fromOffset(120,38),
		BackgroundColor3 = Colors.Button, BorderSizePixel = 0, Text = "Cancel", FontFace = FingerPaint,
		TextSize = 16, TextColor3 = Colors.Text, AutoButtonColor = false, ZIndex = 1007, Parent = Box,
	})
	corner(No, 9)
	Yes.MouseButton1Click:Connect(function() play("close") ScreenGui:Destroy() end)
	No.MouseButton1Click:Connect(function()
		play("click")
		TweenService:Create(Overlay, Tw.snap, {BackgroundTransparency = 1}):Play()
		TweenService:Create(bSc, Tw.soft, {Scale = 0.9}):Play()
		TweenService:Create(Yes, Tw.snap, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		TweenService:Create(No, Tw.snap, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		task.delay(0.18, function() Overlay.Visible = false end)
	end)

	ctrlBtn("−", -50, Colors.TextDim, function()
		play("click")
		closeAll(true)
		local min = Main.Size.Y.Offset <= TITLE_H
		local vp = workspace.CurrentCamera.ViewportSize
		if min then
			local ts = Vector2.new(MAIN_W, MAIN_H)
			local tlX = math.clamp(Main.Position.X.Offset - ts.X/2, 0, math.max(0, vp.X - ts.X))
			local tlY = math.clamp(Main.Position.Y.Offset - ts.Y/2, 0, math.max(0, vp.Y - ts.Y))
			lastPos = UDim2.fromOffset(tlX + ts.X/2, tlY + ts.Y/2)
			TweenService:Create(Main, Tw.soft, {Size = UDim2.fromOffset(MAIN_W, MAIN_H), Position = lastPos}):Play()
			Sidebar.Visible = true Content.Visible = true
		else
			lastPos = Main.Position
			local ts = Vector2.new(MAIN_W, TITLE_H)
			local tlX = math.clamp(Main.Position.X.Offset - ts.X/2, 0, math.max(0, vp.X - ts.X))
			local tlY = math.clamp(Main.Position.Y.Offset - ts.Y/2, 0, math.max(0, vp.Y - ts.Y))
			TweenService:Create(Main, Tw.soft, {
				Size = UDim2.fromOffset(MAIN_W, TITLE_H),
				Position = UDim2.fromOffset(tlX + ts.X/2, tlY + ts.Y/2)
			}):Play()
			Sidebar.Visible = false Content.Visible = false
		end
	end)

	ctrlBtn("×", -14, Colors.Close, function()
		play("click")
		closeAll(true)
		Overlay.Visible = true
		Overlay.BackgroundTransparency = 1
		bSc.Scale = 0.9
		Yes.BackgroundTransparency = 1 Yes.TextTransparency = 1
		No.BackgroundTransparency = 1 No.TextTransparency = 1
		TweenService:Create(Overlay, Tw.snap, {BackgroundTransparency = 0.55}):Play()
		TweenService:Create(bSc, Tw.modal, {Scale = 1}):Play()
		task.delay(0.08, function()
			TweenService:Create(Yes, Tw.snap, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(No, Tw.snap, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
		end)
	end)

	local function inRect(px, py, pos, size)
		return px >= pos.X and px <= pos.X + size.X and py >= pos.Y and py <= pos.Y + size.Y
	end
	local function rem(e)
		for i = #OpenPops, 1, -1 do if OpenPops[i] == e then table.remove(OpenPops, i) end end
	end

	closeOne = function(e, instant)
		if e.closing or not e.isOpen then return end
		e.closing = true e.isOpen = false rem(e)
		if e.closeFn then e.closeFn(instant) end
	end
	closeAll = function(instant)
		local copy = {}
		for i, e in ipairs(OpenPops) do copy[i] = e end
		for _, e in ipairs(copy) do closeOne(e, instant) end
	end

	UserInputService.InputBegan:Connect(function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
		if #OpenPops == 0 then return end
		local px, py = inp.Position.X, inp.Position.Y
		for _, e in ipairs(OpenPops) do
			local inside = e.panel and inRect(px, py, e.panel.AbsolutePosition, e.panel.AbsoluteSize)
			if not inside and e.triggers then
				for _, t in ipairs(e.triggers) do
					if t and t.Visible and inRect(px, py, t.AbsolutePosition, t.AbsoluteSize) then inside = true break end
				end
			end
			if inside then return end
		end
		closeAll(false)
	end)

	local isOpen, anim = false, false
	local function Toggle()
		if anim then return end
		anim = true
		play("toggle")
		closeAll(true)
		Overlay.Visible = false
		if isOpen then
			lastPos = Main.Position
			local c = (DropBtn and (DropBtn.AbsolutePosition + DropBtn.AbsoluteSize * 0.5)) or Vector2.new(MAIN_W/2, MAIN_H/2)
			local t = TweenService:Create(Main, Tw.close, {
				Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(8,8), GroupTransparency = 1
			})
			t:Play()
			t.Completed:Connect(function() Main.Visible = false isOpen = false anim = false end)
		else
			Main.Visible = true Main.GroupTransparency = 1
			Sidebar.Visible = true Content.Visible = true
			Main.Size = UDim2.fromOffset(8,8)
			local c = (DropBtn and (DropBtn.AbsolutePosition + DropBtn.AbsoluteSize * 0.5)) or Vector2.new(MAIN_W/2, MAIN_H/2)
			Main.Position = UDim2.fromOffset(c.X, c.Y)
			local vp = workspace.CurrentCamera.ViewportSize
			local fp
			if lastPos.X.Scale == 0.5 and lastPos.Y.Scale == 0.5 and lastPos.X.Offset == 0 and lastPos.Y.Offset == 0 then
				fp = UDim2.fromOffset(vp.X/2, vp.Y/2)
			else
				local ts = Vector2.new(MAIN_W, MAIN_H)
				local tlX = math.clamp(lastPos.X.Offset - ts.X/2, 0, math.max(0, vp.X - ts.X))
				local tlY = math.clamp(lastPos.Y.Offset - ts.Y/2, 0, math.max(0, vp.Y - ts.Y))
				fp = UDim2.fromOffset(tlX + ts.X/2, tlY + ts.Y/2)
			end
			local t = TweenService:Create(Main, Tw.open, {
				Position = fp, Size = UDim2.fromOffset(MAIN_W, MAIN_H), GroupTransparency = 0
			})
			t:Play()
			t.Completed:Connect(function()
				isOpen = true anim = false
				lastPos = Main.Position
			end)
		end
	end
	if DropBtn then DropBtn.MouseButton1Click:Connect(Toggle) end

	local drag, dStart, sPos = false, nil, nil
	TitleBar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			closeAll(true)
			drag = true dStart = inp.Position sPos = Main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - dStart
			local vp = workspace.CurrentCamera.ViewportSize
			local sz = Main.AbsoluteSize
			local tlX = math.clamp(sPos.X.Offset + d.X - sz.X/2, 0, math.max(0, vp.X - sz.X))
			local tlY = math.clamp(sPos.Y.Offset + d.Y - sz.Y/2, 0, math.max(0, vp.Y - sz.Y))
			Main.Position = UDim2.fromOffset(tlX + sz.X/2, tlY + sz.Y/2)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			drag = false lastPos = Main.Position
		end
	end)
	UserInputService.InputBegan:Connect(function(inp, g)
		if g then return end
		if inp.KeyCode == ToggleKey then Toggle() end
	end)

	-- ── components ──────────────────────────────────────────
	local function section(par, title, ord)
		local s = mk("Frame", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = ord or 0, Parent = par})
		mk("TextLabel", {
			Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = title:upper(),
			FontFace = FingerPaint, TextSize = 12, TextColor3 = Colors.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = s,
		})
	end

	local function toggle(par, title, desc, def, ord, cb)
		local hasDesc = desc and desc ~= ""
		local rowH = hasDesc and 46 or 36
		local row = mk("Frame", {Size = UDim2.new(1,0,0,rowH), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = ord or 0, Parent = par})
		mk("TextLabel", {
			Position = hasDesc and UDim2.fromOffset(0, 3) or UDim2.fromOffset(0, 0),
			Size = hasDesc and UDim2.new(1,-64,0,18) or UDim2.new(1,-64,1,0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		if hasDesc then
			mk("TextLabel", {
				Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1,-64,0,16),
				BackgroundTransparency = 1, BorderSizePixel = 0,
				Text = desc, FontFace = FingerPaint, TextSize = 12, TextColor3 = Colors.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
			})
		end
		local track = mk("Frame", {
			AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,0,0.5,0),
			Size = UDim2.fromOffset(44,24), BackgroundColor3 = def and Colors.Accent or Colors.AccentOff,
			BorderSizePixel = 0, Parent = row,
		})
		corner(track, 12)
		local tStroke = stroke(track, LINE, 1.2, 1)
		local knob = mk("Frame", {
			AnchorPoint = Vector2.new(0,0.5),
			Position = def and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0),
			Size = UDim2.fromOffset(18,18), BackgroundColor3 = def and Colors.Knob or Colors.KnobOff,
			BorderSizePixel = 0, Parent = track,
		})
		corner(knob, 9)
		local state = def or false
		local hit = mk("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Parent = row})
		hit.MouseEnter:Connect(function()
			playHover()
			TweenService:Create(tStroke, Tw.snap, {Transparency = 0.35}):Play()
		end)
		hit.MouseLeave:Connect(function()
			TweenService:Create(tStroke, Tw.snap, {Transparency = 1}):Play()
		end)
		hit.MouseButton1Click:Connect(function()
			play("click")
			state = not state
			if state then
				TweenService:Create(track, Tw.soft, {BackgroundColor3 = Colors.Accent}):Play()
				TweenService:Create(knob, Tw.bounce, {Position = UDim2.new(1,-21,0.5,0), BackgroundColor3 = Colors.Knob}):Play()
			else
				TweenService:Create(track, Tw.soft, {BackgroundColor3 = Colors.AccentOff}):Play()
				TweenService:Create(knob, Tw.bounce, {Position = UDim2.new(0,3,0.5,0), BackgroundColor3 = Colors.KnobOff}):Play()
			end
			if cb then cb(state) end
		end)
		return {
			Set = function(v)
				state = v
				track.BackgroundColor3 = state and Colors.Accent or Colors.AccentOff
				knob.Position = state and UDim2.new(1,-21,0.5,0) or UDim2.new(0,3,0.5,0)
				knob.BackgroundColor3 = state and Colors.Knob or Colors.KnobOff
				if cb then cb(state) end
			end,
			Get = function() return state end,
		}
	end

	local function slider(par, title, min, max, def, ord, cb)
		local range = math.max(max - min, 1e-6)
		local row = mk("Frame", {Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = ord or 0, Parent = par})
		mk("TextLabel", {
			Position = UDim2.fromOffset(0,2), Size = UDim2.new(1,-48,0,16), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local vl = mk("TextLabel", {
			Position = UDim2.new(1,-48,0,2), Size = UDim2.fromOffset(48,16), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = tostring(def), FontFace = FingerPaint, TextSize = 14, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
		})
		local track = mk("Frame", {
			Position = UDim2.new(0,0,0,26), Size = UDim2.new(1,0,0,8),
			BackgroundColor3 = Colors.SliderTrack, BorderSizePixel = 0, Parent = row,
		})
		corner(track, 4)
		local tStroke = stroke(track, LINE, 1, 1)
		local initRx = math.clamp((def - min) / range, 0, 1)
		local fill = mk("Frame", {
			Size = UDim2.fromScale(initRx,1), BackgroundColor3 = Colors.SliderFill,
			BorderSizePixel = 0, Parent = track,
		})
		corner(fill, 4)
		local knob = mk("Frame", {
			AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(initRx,0.5),
			Size = UDim2.fromOffset(14,14), BackgroundColor3 = Colors.Text, BorderSizePixel = 0, Parent = track,
		})
		corner(knob, 7) stroke(knob, Colors.TitleBar, 1, 0.2)
		local dragging = false
		local hit = mk("TextButton", {
			Position = UDim2.new(0,0,0,20), Size = UDim2.new(1,0,0,22),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Parent = row,
		})
		hit.MouseEnter:Connect(function()
			playHover()
			TweenService:Create(tStroke, Tw.snap, {Transparency = 0.4}):Play()
		end)
		hit.MouseLeave:Connect(function()
			if dragging then return end
			TweenService:Create(tStroke, Tw.snap, {Transparency = 1}):Play()
		end)
		local function upd(inp)
			local rx = math.clamp((inp.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
			local v = math.floor(min + (max - min) * rx + 0.5)
			fill.Size = UDim2.fromScale(rx,1)
			knob.Position = UDim2.fromScale(rx,0.5)
			vl.Text = tostring(v)
			playSlider()
			if cb then cb(v) end
		end
		hit.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				upd(inp)
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				upd(inp)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					dragging = false
					TweenService:Create(tStroke, Tw.snap, {Transparency = 1}):Play()
				end
			end
		end)
		return {
			Set = function(v)
				local rx = math.clamp((v - min) / range, 0, 1)
				fill.Size = UDim2.fromScale(rx,1)
				knob.Position = UDim2.fromScale(rx,0.5)
				vl.Text = tostring(v)
				if cb then cb(v) end
			end,
			Get = function() return tonumber(vl.Text) end,
		}
	end

	local function button(par, title, ord, cb)
		local b = mk("TextButton", {
			Size = UDim2.new(1, 0, 0, BTN_H),
			BackgroundColor3 = Colors.Button,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = ord or 0,
			ClipsDescendants = true,
			Parent = par,
		})
		corner(b, 9)
		local st = stroke(b, Colors.RowStroke, 1, 0.35)

		local lbl = mk("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = title,
			FontFace = FingerPaint,
			TextSize = 15,
			TextColor3 = Colors.Text,
			ZIndex = 2,
			Parent = b,
		})

		local line = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(0, 0, 0, 2),
			BackgroundColor3 = LINE,
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = b,
		})
		corner(line, 1)

		b.MouseEnter:Connect(function()
			playHover()
			TweenService:Create(b, Tw.soft, {
				BackgroundColor3 = Color3.fromRGB(48, 48, 54),
				BackgroundTransparency = 0.04,
			}):Play()
			TweenService:Create(st, Tw.soft, { Transparency = 0.2, Color = LINE }):Play()
			TweenService:Create(lbl, Tw.soft, { TextColor3 = Colors.TextHighlight }):Play()
			TweenService:Create(line, Tw.soft, { Size = UDim2.new(0.5, 0, 0, 2) }):Play()
		end)

		b.MouseLeave:Connect(function()
			TweenService:Create(b, Tw.soft, {
				BackgroundColor3 = Colors.Button,
				BackgroundTransparency = 0.12,
			}):Play()
			TweenService:Create(st, Tw.soft, { Transparency = 0.35, Color = Colors.RowStroke }):Play()
			TweenService:Create(lbl, Tw.soft, { TextColor3 = Colors.Text }):Play()
			TweenService:Create(line, Tw.soft, { Size = UDim2.new(0, 0, 0, 2) }):Play()
		end)

		b.MouseButton1Down:Connect(function()
			TweenService:Create(b, Tw.press, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(55, 55, 62),
			}):Play()
			TweenService:Create(line, Tw.press, { Size = UDim2.new(0.65, 0, 0, 2) }):Play()
		end)

		b.MouseButton1Up:Connect(function()
			TweenService:Create(b, Tw.soft, {
				BackgroundTransparency = 0.04,
				BackgroundColor3 = Color3.fromRGB(48, 48, 54),
			}):Play()
			TweenService:Create(line, Tw.soft, { Size = UDim2.new(0.5, 0, 0, 2) }):Play()
		end)

		b.MouseButton1Click:Connect(function()
			play("click")
			TweenService:Create(line, Tw.press, { BackgroundTransparency = 0.4 }):Play()
			task.delay(0.1, function()
				TweenService:Create(line, Tw.soft, { BackgroundTransparency = 0 }):Play()
			end)
			if cb then cb() end
		end)
	end

	local function textbox(par, title, def, ord, cb)
		local row = mk("Frame", {Size = UDim2.new(1,0,0,ROW_H), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = ord or 0, Parent = par})
		mk("TextLabel", {
			Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,-8,0,16), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local field = mk("Frame", {
			Position = UDim2.fromOffset(0,18), Size = UDim2.new(1,0,0,FIELD_H),
			BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.12, BorderSizePixel = 0, Parent = row,
		})
		corner(field, 8)
		local fst = stroke(field, Colors.RowStroke, 1, 0.4)
		local box = mk("TextBox", {
			Position = UDim2.fromOffset(12,0), Size = UDim2.new(1,-24,1,0),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = def or "", PlaceholderText = "Enter text...",
			PlaceholderColor3 = Colors.TextDim, TextColor3 = Colors.Text,
			FontFace = FingerPaint, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false, Parent = field,
		})
		box.Focused:Connect(function()
			TweenService:Create(fst, Tw.snap, {Transparency = 0.15, Color = LINE}):Play()
		end)
		box.FocusLost:Connect(function()
			play("click")
			TweenService:Create(fst, Tw.soft, {Transparency = 0.4, Color = Colors.RowStroke}):Play()
			if cb then cb(box.Text) end
		end)
		return {Set = function(v) box.Text = tostring(v or "") end, Get = function() return box.Text end}
	end

	local function keybind(par, title, def, ord, cb)
		local row = mk("Frame", {Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = ord or 0, Parent = par})
		mk("TextLabel", {
			Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,-90,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local kb = mk("TextButton", {
			AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,0,0.5,0),
			Size = UDim2.fromOffset(84,28), BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.12,
			BorderSizePixel = 0, Text = def and def.Name or "None", FontFace = FingerPaint, TextSize = 13,
			TextColor3 = Colors.Text, AutoButtonColor = false, Parent = row,
		})
		corner(kb, 7)
		local kst = stroke(kb, Colors.RowStroke, 1, 0.4)
		local listen, cur = false, def
		kb.MouseEnter:Connect(function()
			playHover()
			TweenService:Create(kst, Tw.snap, {Transparency = 0.2}):Play()
		end)
		kb.MouseLeave:Connect(function()
			if not listen then TweenService:Create(kst, Tw.soft, {Transparency = 0.4}):Play() end
		end)
		kb.MouseButton1Click:Connect(function()
			play("click")
			listen = true
			kb.Text = "..."
			TweenService:Create(kst, Tw.snap, {Transparency = 0.1, Color = LINE}):Play()
		end)
		UserInputService.InputBegan:Connect(function(inp, g)
			if g or not listen then return end
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				play("click")
				listen = false
				cur = inp.KeyCode
				kb.Text = inp.KeyCode.Name
				TweenService:Create(kst, Tw.soft, {Transparency = 0.4, Color = Colors.RowStroke}):Play()
				if cb then cb(inp.KeyCode) end
			end
		end)
		return {
			Set = function(k) cur = k kb.Text = k and k.Name or "None" end,
			Get = function() return cur end,
		}
	end

	local function dropdown(par, title, options, def, ord, cb)
		options = options or {}
		local selected = def or options[1] or ""
		local row = mk("Frame", {
			Size = UDim2.new(1,0,0,ROW_H), BackgroundTransparency = 1, BorderSizePixel = 0,
			LayoutOrder = ord or 0, Parent = par,
		})
		mk("TextLabel", {
			Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,-8,0,16), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local trigger = mk("TextButton", {
			Position = UDim2.fromOffset(0,18), Size = UDim2.new(1,0,0,FIELD_H),
			BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.12,
			BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row,
		})
		corner(trigger, 8)
		local trSt = stroke(trigger, Colors.RowStroke, 1, 0.4)
		local triggerLbl = mk("TextLabel", {
			Position = UDim2.fromOffset(12,0), Size = UDim2.new(1,-36,1,0),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = tostring(selected), FontFace = FingerPaint,
			TextSize = 14, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = trigger,
		})
		local chev = mk("TextLabel", {
			AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-10,0.5,0),
			Size = UDim2.fromOffset(16,16), BackgroundTransparency = 1, BorderSizePixel = 0, Text = "▾",
			FontFace = FingerPaint, TextSize = 12, TextColor3 = Colors.TextDim, Parent = trigger,
		})

		local panelH = math.min(#options * 30 + 8, 170)
		local panel = mk("ScrollingFrame", {
			Size = UDim2.fromOffset(200, 0), BackgroundColor3 = Colors.TitleBar,
			BackgroundTransparency = 0.05, BorderSizePixel = 0, Visible = false,
			ScrollBarThickness = 2, ScrollBarImageColor3 = LINE,
			ScrollBarImageTransparency = 0.55,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 950, Parent = PopupLayer,
		})
		corner(panel, 9)
		stroke(panel, Colors.RowStroke, 1, 0.3)
		mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2), Parent = panel})
		mk("UIPadding", {PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), Parent = panel})

		local entry = { panel = panel, isOpen = false, closing = false, width = 0, triggers = {trigger} }

		entry.closeFn = function(instant)
			TweenService:Create(chev, Tw.soft, {Rotation = 0}):Play()
			TweenService:Create(trSt, Tw.soft, {Transparency = 0.4, Color = Colors.RowStroke}):Play()
			if instant then
				panel.Visible = false
				panel.Size = UDim2.fromOffset(entry.width or 200, 0)
				entry.closing = false
			else
				local t = TweenService:Create(panel, Tw.listIn, {
					Size = UDim2.fromOffset(entry.width or 200, 0), BackgroundTransparency = 1
				})
				t:Play()
				t.Completed:Connect(function()
					if entry.closing then
						panel.Visible = false
						panel.BackgroundTransparency = 0.05
						entry.closing = false
					end
				end)
			end
		end

		local function openDrop()
			closeAll(true)
			local abs = trigger.AbsolutePosition
			local sz = trigger.AbsoluteSize
			entry.width = sz.X
			panel.Size = UDim2.fromOffset(sz.X, 0)
			panel.Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 4)
			panel.Visible = true
			panel.BackgroundTransparency = 1
			entry.isOpen = true entry.closing = false
			table.insert(OpenPops, entry)
			TweenService:Create(chev, Tw.soft, {Rotation = 180}):Play()
			TweenService:Create(trSt, Tw.snap, {Transparency = 0.15, Color = LINE}):Play()
			TweenService:Create(panel, Tw.list, {
				Size = UDim2.fromOffset(sz.X, panelH), BackgroundTransparency = 0.05
			}):Play()
		end

		for i, opt in ipairs(options) do
			local item = mk("TextButton", {
				Size = UDim2.new(1,-8,0,28),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = panel,
			})
			local itemLbl = mk("TextLabel", {
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(1, -24, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = tostring(opt),
				FontFace = FingerPaint,
				TextSize = 13,
				TextColor3 = Colors.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = item,
			})
			local under = mk("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 12, 1, -2),
				Size = UDim2.fromOffset(0, 2),
				BackgroundColor3 = LINE,
				BorderSizePixel = 0,
				Parent = item,
			})
			corner(under, 1)

			local function textW()
				local b = TextService:GetTextSize(tostring(opt), 13, Enum.Font.GothamBold, Vector2.new(1000, 40))
				return math.min(b.X + 2, item.AbsoluteSize.X - 28)
			end

			item.MouseEnter:Connect(function()
				TweenService:Create(itemLbl, Tw.snap, { TextColor3 = Colors.TextHighlight }):Play()
				TweenService:Create(under, Tw.soft, { Size = UDim2.fromOffset(textW(), 2) }):Play()
			end)
			item.MouseLeave:Connect(function()
				if selected ~= opt then
					TweenService:Create(itemLbl, Tw.soft, { TextColor3 = Colors.TextDim }):Play()
					TweenService:Create(under, Tw.snap, { Size = UDim2.fromOffset(0, 2) }):Play()
				end
			end)
			item.MouseButton1Click:Connect(function()
				play("click")
				selected = opt
				triggerLbl.Text = tostring(opt)
				closeOne(entry, false)
				if cb then cb(opt) end
			end)
		end

		trigger.MouseButton1Click:Connect(function()
			play("click")
			if entry.isOpen then closeOne(entry, false) else openDrop() end
		end)

		return {
			Set = function(v) selected = v triggerLbl.Text = tostring(v) if cb then cb(v) end end,
			Get = function() return selected end,
		}
	end
		
	local function multiDropdown(par, title, options, defaults, ord, cb)
	options = options or {}
	local selected = {}
	for k, v in pairs(defaults or {}) do
		if v then selected[k] = true end
	end

	local function summaryText()
		local picked = {}
		for _, opt in ipairs(options) do
			if selected[opt] then picked[#picked + 1] = opt end
		end
		local n = #picked
		if n == 0 then return "(none)" end
		if n == #options then return "All (" .. n .. ")" end
		if n <= 2 then return table.concat(picked, ", ") end
		return picked[1] .. ", " .. picked[2] .. " +" .. (n - 2) .. " more"
	end

	-- row + trigger
	local row = mk("Frame", {
		Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, BorderSizePixel = 0,
		LayoutOrder = ord or 0, Parent = par,
	})
	mk("TextLabel", {
		Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -8, 0, 16),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
	})
	local trigger = mk("TextButton", {
		Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, FIELD_H),
		BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.12,
		BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row,
	})
	corner(trigger, 8)
	local trSt = stroke(trigger, Colors.RowStroke, 1, 0.4)
	local triggerLbl = mk("TextLabel", {
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -36, 1, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Text = summaryText(), FontFace = FingerPaint,
		TextSize = 14, TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = trigger,
	})
	local chev = mk("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, BorderSizePixel = 0,
		Text = "\u{25BE}", FontFace = FingerPaint, TextSize = 12,
		TextColor3 = Colors.TextDim, Parent = trigger,
	})

	-- floating panel
	local itemH = 28
	local itemGap = 2
	local actionsH = 34
	local contentH = #options * (itemH + itemGap) + actionsH + 8
	local panelH = math.min(contentH, 300)

	local panel = mk("ScrollingFrame", {
		Size = UDim2.fromOffset(200, 0),
		BackgroundColor3 = Colors.TitleBar,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = LINE,
		ScrollBarImageTransparency = 0.55,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 950, Parent = PopupLayer,
	})
	corner(panel, 9)
	stroke(panel, Colors.RowStroke, 1, 0.3)
	mk("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, itemGap),
		Parent = panel,
	})
	mk("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent = panel,
	})

	local entry = {
		panel = panel, isOpen = false, closing = false,
		width = 0, flipUp = false, triggers = { trigger },
	}

	entry.closeFn = function(instant)
		TweenService:Create(chev, Tw.soft, { Rotation = 0 }):Play()
		TweenService:Create(trSt, Tw.soft, { Transparency = 0.4, Color = Colors.RowStroke }):Play()
		if instant then
			panel.Visible = false
			panel.Size = UDim2.fromOffset(entry.width or 200, 0)
			panel.BackgroundTransparency = 0.05
			entry.closing = false
		else
			local t = TweenService:Create(panel, Tw.listIn, {
				Size = UDim2.fromOffset(entry.width or 200, 0),
				BackgroundTransparency = 1,
			})
			t:Play()
			t.Completed:Connect(function()
				if entry.closing then
					panel.Visible = false
					panel.BackgroundTransparency = 0.05
					entry.closing = false
				end
			end)
		end
	end

	-- bounds: PopupLayer if it's a sized GuiObject, else camera viewport
	local function getBounds()
		local top, bottom = 0, 1080
		pcall(function()
			local cam = workspace.CurrentCamera
			if cam then bottom = cam.ViewportSize.Y end
			local pl = PopupLayer
			if pl then
				local okS, sz = pcall(function() return pl.AbsoluteSize end)
				local okP, pos = pcall(function() return pl.AbsolutePosition end)
				if okS and okP and sz and pos and sz.Y > 100 then
					top = pos.Y
					bottom = pos.Y + sz.Y
				end
			end
		end)
		return top, bottom
	end

	local function openDrop()
		closeAll(true)
		local abs = trigger.AbsolutePosition
		local sz = trigger.AbsoluteSize
		entry.width = sz.X

		local yBelow = abs.Y + sz.Y + 4
		local yAbove = abs.Y - 4

		local boundsTop, boundsBottom = getBounds()
		local needsFlip = (yBelow + panelH) > boundsBottom
		local canFlip = (yAbove - panelH) >= boundsTop
		local flipUp = needsFlip and canFlip

		panel.Size = UDim2.fromOffset(sz.X, 0)
		panel.CanvasPosition = Vector2.new(0, 0)
		if flipUp then
			panel.AnchorPoint = Vector2.new(0, 1)
			panel.Position = UDim2.fromOffset(abs.X, yAbove)
		else
			panel.AnchorPoint = Vector2.new(0, 0)
			panel.Position = UDim2.fromOffset(abs.X, yBelow)
		end
		panel.Visible = true
		panel.BackgroundTransparency = 1
		entry.isOpen = true
		entry.closing = false
		entry.flipUp = flipUp
		table.insert(OpenPops, entry)

		TweenService:Create(chev, Tw.soft, { Rotation = 180 }):Play()
		TweenService:Create(trSt, Tw.snap, { Transparency = 0.15, Color = LINE }):Play()
		TweenService:Create(panel, Tw.list, {
			Size = UDim2.fromOffset(sz.X, panelH),
			BackgroundTransparency = 0.05,
		}):Play()
	end

	-- items
	local itemRefs = {}
	local function refreshItem(opt)
		local r = itemRefs[opt]
		if not r then return end
		r.mark.Visible = selected[opt] == true
		TweenService:Create(r.lbl, Tw.snap, {
			TextColor3 = selected[opt] and Colors.Text or Colors.TextDim,
		}):Play()
	end

	for i, opt in ipairs(options) do
		local item = mk("TextButton", {
			Size = UDim2.new(1, -8, 0, itemH),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = "", AutoButtonColor = false,
			LayoutOrder = i, Parent = panel,
		})
		local chk = mk("Frame", {
			Position = UDim2.fromOffset(8, math.floor((itemH - 14) / 2)),
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.2,
			BorderSizePixel = 0, Parent = item,
		})
		corner(chk, 3)
		stroke(chk, Colors.RowStroke, 1, 0.4)
		local mark = mk("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = "\u{2713}", FontFace = FingerPaint, TextSize = 11,
			TextColor3 = LINE, Visible = selected[opt] == true, Parent = chk,
		})
		local lbl = mk("TextLabel", {
			Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -38, 1, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = tostring(opt), FontFace = FingerPaint, TextSize = 13,
			TextColor3 = selected[opt] and Colors.Text or Colors.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = item,
		})
		itemRefs[opt] = { item = item, mark = mark, lbl = lbl }

		item.MouseEnter:Connect(function()
			TweenService:Create(lbl, Tw.snap, { TextColor3 = Colors.TextHighlight }):Play()
		end)
		item.MouseLeave:Connect(function()
			TweenService:Create(lbl, Tw.soft, {
				TextColor3 = selected[opt] and Colors.Text or Colors.TextDim,
			}):Play()
		end)
		item.MouseButton1Click:Connect(function()
			play("click")
			selected[opt] = not selected[opt]
			refreshItem(opt)
			triggerLbl.Text = summaryText()
			if cb then cb(selected) end
		end)
	end

	-- actions row
	local actions = mk("Frame", {
		Size = UDim2.new(1, -8, 0, actionsH - 6),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		LayoutOrder = #options + 1, Parent = panel,
	})
	local function actionBtn(txt, pos)
		local b = mk("TextButton", {
			Position = pos, Size = UDim2.new(0.5, -3, 1, 0),
			BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.2,
			BorderSizePixel = 0, Text = txt, FontFace = FingerPaint,
			TextSize = 12, TextColor3 = Colors.Text, AutoButtonColor = false,
			Parent = actions,
		})
		corner(b, 6)
		stroke(b, Colors.RowStroke, 1, 0.5)
		return b
	end
	local allBtn = actionBtn("Select All", UDim2.new(0, 0, 0, 0))
	local clearBtn = actionBtn("Clear", UDim2.new(0.5, 3, 0, 0))

	allBtn.MouseButton1Click:Connect(function()
		play("click")
		for _, opt in ipairs(options) do selected[opt] = true end
		for opt in pairs(itemRefs) do refreshItem(opt) end
		triggerLbl.Text = summaryText()
		if cb then cb(selected) end
	end)
	clearBtn.MouseButton1Click:Connect(function()
		play("click")
		for _, opt in ipairs(options) do selected[opt] = false end
		for opt in pairs(itemRefs) do refreshItem(opt) end
		triggerLbl.Text = summaryText()
		if cb then cb(selected) end
	end)

	trigger.MouseButton1Click:Connect(function()
		play("click")
		if entry.isOpen then closeOne(entry, false) else openDrop() end
	end)

	return {
		Set = function(t)
			selected = {}
			for k, v in pairs(t or {}) do
				if v then selected[k] = true end
			end
			for opt in pairs(itemRefs) do refreshItem(opt) end
			triggerLbl.Text = summaryText()
			if cb then cb(selected) end
		end,
		Get = function() return selected end,
	}
end

function Tab:CreateMultiDropdown(o)
	o = o or {} nextO += 1
	local el = multiDropdown(frame, o.Title or "Multi", o.Options or {}, o.Default, nextO, o.Callback)
	register(el, o.Flag) return el
end

]==]

	local function colorpicker(par, title, def, ord, cb)
		def = def or Color3.fromRGB(160,160,170)
		local row = mk("Frame", {
			Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, BorderSizePixel = 0,
			LayoutOrder = ord or 0, Parent = par,
		})
		mk("TextLabel", {
			Position = UDim2.fromOffset(0,0), Size = UDim2.new(1,-44,1,0), BackgroundTransparency = 1, BorderSizePixel = 0,
			Text = title, FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local preview = mk("TextButton", {
			AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,0,0.5,0),
			Size = UDim2.fromOffset(28,28), BackgroundColor3 = def, BorderSizePixel = 0,
			Text = "", AutoButtonColor = false, Parent = row,
		})
		corner(preview, 7)
		local pSt = stroke(preview, Colors.RowStroke, 1, 0.3)

		local r, g, b = def.R, def.G, def.B
		local function apply()
			local c = Color3.new(r, g, b)
			preview.BackgroundColor3 = c
			if cb then cb(c) end
		end

		local panel = mk("Frame", {
			Size = UDim2.fromOffset(220, 0), BackgroundColor3 = Colors.TitleBar,
			BackgroundTransparency = 0.05, BorderSizePixel = 0, Visible = false,
			ZIndex = 950, Parent = PopupLayer,
		})
		corner(panel, 9)
		stroke(panel, Colors.RowStroke, 1, 0.3)

		local bigPrev = mk("Frame", {
			Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(200, 36),
			BackgroundColor3 = def, BorderSizePixel = 0, Parent = panel,
		})
		corner(bigPrev, 7)

		local function makeChan(label, y, init, setFn)
			mk("TextLabel", {
				Position = UDim2.fromOffset(10, y), Size = UDim2.fromOffset(14, 16),
				BackgroundTransparency = 1, BorderSizePixel = 0, Text = label, FontFace = FingerPaint,
				TextSize = 12, TextColor3 = Colors.TextDim, Parent = panel,
			})
			local track = mk("Frame", {
				Position = UDim2.fromOffset(30, y+3), Size = UDim2.fromOffset(140, 10),
				BackgroundColor3 = Colors.SliderTrack, BorderSizePixel = 0, Parent = panel,
			})
			corner(track, 5)
			local fill = mk("Frame", {
				Size = UDim2.fromScale(init,1), BackgroundColor3 = Colors.SliderFill,
				BorderSizePixel = 0, Parent = track,
			})
			corner(fill, 5)
			local kn = mk("Frame", {
				AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(init,0.5),
				Size = UDim2.fromOffset(12,12), BackgroundColor3 = Colors.Text, BorderSizePixel = 0, Parent = track,
			})
			corner(kn, 6)
			local valLbl = mk("TextLabel", {
				Position = UDim2.fromOffset(178, y), Size = UDim2.fromOffset(32, 16),
				BackgroundTransparency = 1, BorderSizePixel = 0,
				Text = tostring(math.floor(init*255)), FontFace = FingerPaint,
				TextSize = 12, TextColor3 = Colors.Text, TextXAlignment = Enum.TextXAlignment.Right, Parent = panel,
			})
			local dragging = false
			local hit = mk("TextButton", {
				Position = UDim2.fromOffset(30, y), Size = UDim2.fromOffset(140, 16),
				BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", Parent = panel,
			})
			local function upd(inp)
				local rx = math.clamp((inp.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X,1), 0, 1)
				fill.Size = UDim2.fromScale(rx,1)
				kn.Position = UDim2.fromScale(rx,0.5)
				valLbl.Text = tostring(math.floor(rx*255))
				setFn(rx)
				bigPrev.BackgroundColor3 = Color3.new(r, g, b)
			end
			hit.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					dragging = true upd(inp)
				end
			end)
			UserInputService.InputChanged:Connect(function(inp)
				if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
					upd(inp)
				end
			end)
			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			return function(rx)
				fill.Size = UDim2.fromScale(rx,1)
				kn.Position = UDim2.fromScale(rx,0.5)
				valLbl.Text = tostring(math.floor(rx*255))
			end
		end

		local setR = makeChan("R", 56, r, function(v) r = v apply() end)
		local setG = makeChan("G", 80, g, function(v) g = v apply() end)
		local setB = makeChan("B", 104, b, function(v) b = v apply() end)

		local entry = { panel = panel, isOpen = false, closing = false, width = 220, triggers = {preview} }
		entry.closeFn = function(instant)
			TweenService:Create(pSt, Tw.soft, {Transparency = 0.3, Color = Colors.RowStroke}):Play()
			if instant then
				panel.Visible = false
				panel.Size = UDim2.fromOffset(220, 0)
				entry.closing = false
			else
				local t = TweenService:Create(panel, Tw.listIn, {
					Size = UDim2.fromOffset(220, 0), BackgroundTransparency = 1
				})
				t:Play()
				t.Completed:Connect(function()
					if entry.closing then
						panel.Visible = false
						panel.BackgroundTransparency = 0.05
						entry.closing = false
					end
				end)
			end
		end

		preview.MouseButton1Click:Connect(function()
			play("click")
			if entry.isOpen then
				closeOne(entry, false)
			else
				closeAll(true)
				local abs = preview.AbsolutePosition
				local sz = preview.AbsoluteSize
				panel.Size = UDim2.fromOffset(220, 0)
				panel.Position = UDim2.fromOffset(math.max(8, abs.X + sz.X - 220), abs.Y + sz.Y + 4)
				panel.Visible = true
				panel.BackgroundTransparency = 1
				entry.isOpen = true entry.closing = false
				table.insert(OpenPops, entry)
				TweenService:Create(pSt, Tw.snap, {Transparency = 0.1, Color = LINE}):Play()
				TweenService:Create(panel, Tw.list, {
					Size = UDim2.fromOffset(220, 138), BackgroundTransparency = 0.05
				}):Play()
			end
		end)

		return {
			Set = function(c)
				r, g, b = c.R, c.G, c.B
				setR(r) setG(g) setB(b)
				preview.BackgroundColor3 = c
				bigPrev.BackgroundColor3 = c
				if cb then cb(c) end
			end,
			Get = function() return Color3.new(r, g, b) end,
		}
	end

	local function register(el, flag)
		if flag then table.insert(ConfigEls, {flag = flag, obj = el}) end
	end

	local function configPath(name)
		return ConfigFolder .. "/" .. safeName(name) .. ".json"
	end

	local function SaveCfg(name)
		name = name or "default"
		local d = {}
		for _, e in ipairs(ConfigEls) do
			local v = e.obj.Get()
			if typeof(v) == "Color3" then
				d[e.flag] = {R = v.R, G = v.G, B = v.B, __color = true}
			elseif typeof(v) == "EnumItem" then
				d[e.flag] = {EnumType = tostring(v.EnumType), Name = v.Name, __enum = true}
			else
				d[e.flag] = v
			end
		end
		if writefile then
			pcall(function()
				if makefolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
			end)
			writefile(configPath(name), HttpService:JSONEncode(d))
			Notify("Saved", "Config \""..safeName(name).."\" written.", 2.5)
		else
			Notify("Error", "writefile missing.", 2.5)
		end
	end

	local function LoadCfg(name)
		name = name or "default"
		local path = configPath(name)
		if isfile and isfile(path) then
			local ok, d = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
			if ok and type(d) == "table" then
				for _, e in ipairs(ConfigEls) do
					local v = d[e.flag]
					if v ~= nil then
						if type(v) == "table" and v.__color then
							e.obj.Set(Color3.new(v.R, v.G, v.B))
						elseif type(v) == "table" and v.__enum then
							local et = Enum[v.EnumType]
							if et then e.obj.Set(et[v.Name]) end
						else
							e.obj.Set(v)
						end
					end
				end
				Notify("Loaded", "Config \""..safeName(name).."\" applied.", 2.5)
				return true
			end
		end
		Notify("Error", "No config \""..safeName(name).."\".", 2.5)
		return false
	end

	local function ListConfigs()
		local list = {}
		pcall(function()
			if not listfiles or not isfolder or not isfolder(ConfigFolder) then return end
			for _, path in ipairs(listfiles(ConfigFolder)) do
				local n = path:match("([^/\\]+)%.json$")
				if n then table.insert(list, n) end
			end
		end)
		table.sort(list)
		return list
	end

	local function DeleteCfg(name)
		name = safeName(name)
		local path = configPath(name)
		if isfile and isfile(path) and delfile then
			delfile(path)
			Notify("Deleted", "Config \""..name.."\" removed.", 2.5)
			return true
		end
		Notify("Error", "Could not delete \""..name.."\".", 2.5)
		return false
	end

	local Window = {}
	local TabBtns, TabFrms, CurTab = {}, {}, nil
	local nextTab = 0

	function Window:CreateTab(name, icon)
		nextTab += 1
		local id = name:lower():gsub("%s+", "_")

		local btn = mk("TextButton", {
			Name = name.."Btn", Size = UDim2.new(1,0,0,38),
			BackgroundColor3 = Colors.Button, BackgroundTransparency = 1,
			BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = nextTab, ZIndex = 3, Parent = TabScroll,
		})
		corner(btn, 9)
		local ic = mk("ImageLabel", {
			Position = UDim2.fromOffset(8,8), Size = UDim2.fromOffset(20,20),
			BackgroundTransparency = 1, BorderSizePixel = 0, Image = icon or "rbxassetid://10709751939",
			ImageColor3 = Colors.TextDim, Parent = btn,
		})
		local lbl = mk("TextLabel", {
			Position = UDim2.fromOffset(34,0), Size = UDim2.new(1,-42,1,0),
			BackgroundTransparency = 1, BorderSizePixel = 0, Text = name, FontFace = FingerPaint,
			TextSize = 15, TextColor3 = Colors.TextDim, ZIndex = 4,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
		})
		local under = mk("Frame", {
			Name = "Underline", AnchorPoint = Vector2.new(0,1),
			Position = UDim2.new(0,34,1,-3), Size = UDim2.fromOffset(0,2),
			BackgroundColor3 = LINE, BorderSizePixel = 0, ZIndex = 5, Parent = btn,
		})
		corner(under, 1)

		local function textW()
			local b = TextService:GetTextSize(name, 15, Enum.Font.GothamBold, Vector2.new(1000,40))
			return math.min(b.X + 2, btn.AbsoluteSize.X - 46)
		end
		local function showUnder()
			TweenService:Create(under, Tw.soft, {Size = UDim2.fromOffset(textW(), 2)}):Play()
		end
		local function hideUnder()
			if CurTab == id then return end
			TweenService:Create(under, Tw.snap, {Size = UDim2.fromOffset(0,2)}):Play()
		end

		btn.MouseEnter:Connect(function()
			if CurTab ~= id then
				playHover()
				TweenService:Create(btn, Tw.snap, {BackgroundTransparency = 0.45}):Play()
				TweenService:Create(ic, Tw.snap, {ImageColor3 = Colors.Text}):Play()
				showUnder()
			end
		end)
		btn.MouseLeave:Connect(function()
			if CurTab ~= id then
				TweenService:Create(btn, Tw.soft, {BackgroundTransparency = 1}):Play()
				TweenService:Create(ic, Tw.soft, {ImageColor3 = Colors.TextDim}):Play()
				hideUnder()
			end
		end)
		btn.MouseButton1Click:Connect(function()
			if CurTab == id then return end
			play("click")
			if CurTab then
				local p = TabBtns[CurTab]
				TweenService:Create(p.Label, Tw.soft, {TextColor3 = Colors.TextDim}):Play()
				TweenService:Create(p.Icon, Tw.soft, {ImageColor3 = Colors.TextDim}):Play()
				TweenService:Create(p.Btn, Tw.soft, {BackgroundTransparency = 1}):Play()
				TweenService:Create(p.Under, Tw.snap, {Size = UDim2.fromOffset(0,2)}):Play()
				TabFrms[CurTab].Visible = false
			end
			CurTab = id
			TweenService:Create(lbl, Tw.soft, {TextColor3 = Colors.TextHighlight}):Play()
			TweenService:Create(ic, Tw.soft, {ImageColor3 = LINE}):Play()
			TweenService:Create(btn, Tw.soft, {BackgroundTransparency = 0.15}):Play()
			showUnder()
			TabFrms[id].Visible = true
		end)

		TabBtns[id] = {Btn = btn, Label = lbl, Icon = ic, Under = under}

		local frame = mk("ScrollingFrame", {
			Name = name.."Frame", Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = LINE,
			ScrollBarImageTransparency = 0.55,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, ZIndex = 1, Parent = Content,
		})
		mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = frame})
		mk("UIPadding", {
			PaddingTop = UDim.new(0,PAD), PaddingLeft = UDim.new(0,PAD),
			PaddingRight = UDim.new(0,PAD), PaddingBottom = UDim.new(0,PAD), Parent = frame,
		})
		TabFrms[id] = frame

		if nextTab == 1 then
			task.defer(function()
				CurTab = id
				lbl.TextColor3 = Colors.TextHighlight
				ic.ImageColor3 = LINE
				btn.BackgroundTransparency = 0.15
				showUnder()
				frame.Visible = true
			end)
		end

		local Tab = {}
		local nextO = 0

		function Tab:CreateSection(t) nextO += 1 section(frame, t, nextO) return Tab end
		function Tab:CreateToggle(o)
			o = o or {} nextO += 1
			local el = toggle(frame, o.Title or "Toggle", o.Description or "", o.Default or false, nextO, o.Callback)
			register(el, o.Flag) return el
		end
		function Tab:CreateSlider(o)
			o = o or {} nextO += 1
			local el = slider(frame, o.Title or "Slider", o.Min or 0, o.Max or 100, o.Default or 0, nextO, o.Callback)
			register(el, o.Flag) return el
		end
		function Tab:CreateButton(o)
			o = o or {} nextO += 1
			button(frame, o.Title or "Button", nextO, o.Callback)
		end
		function Tab:CreateTextbox(o)
			o = o or {} nextO += 1
			local el = textbox(frame, o.Title or "Textbox", o.Default or "", nextO, o.Callback)
			register(el, o.Flag) return el
		end
		function Tab:CreateKeybind(o)
			o = o or {} nextO += 1
			local el = keybind(frame, o.Title or "Keybind", o.Default or Enum.KeyCode.P, nextO, o.Callback)
			register(el, o.Flag) return el
		end
		function Tab:CreateDropdown(o)
			o = o or {} nextO += 1
			local el = dropdown(frame, o.Title or "Dropdown", o.Options or {}, o.Default, nextO, o.Callback)
			register(el, o.Flag) return el
		end
		function Tab:CreateMultiDropdown(o)
	o = o or {} nextO += 1
	local el = multiDropdown(frame, o.Title or "Multi", o.Options or {}, o.Default, nextO, o.Callback)
	register(el, o.Flag) return el
end
		function Tab:CreateColorPicker(o)
			o = o or {} nextO += 1
			local el = colorpicker(frame, o.Title or "Color", o.Default or Color3.fromRGB(160,160,170), nextO, o.Callback)
			register(el, o.Flag) return el
		end

		function Tab:CreateConfigList(o)
			o = o or {}
			nextO += 1

			local row = mk("Frame", {
				Size = UDim2.new(1, 0, 0, 200),
				BackgroundTransparency = 1, BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = nextO, Parent = frame,
			})

			mk("TextLabel", {
				Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1, BorderSizePixel = 0, Text = o.Title or "Config Name",
				FontFace = FingerPaint, TextSize = 15, TextColor3 = Colors.Text,
				TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
			})

			local field = mk("Frame", {
				Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, FIELD_H),
				BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.12, BorderSizePixel = 0, Parent = row,
			})
			corner(field, 8)
			local fSt = stroke(field, Colors.RowStroke, 1, 0.4)

			local box = mk("TextBox", {
				Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0),
				BackgroundTransparency = 1, BorderSizePixel = 0, Text = o.Default or "Main",
				PlaceholderText = "Type to filter configs...", PlaceholderColor3 = Colors.TextDim,
				TextColor3 = Colors.Text, FontFace = FingerPaint, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = field,
			})
			box.Focused:Connect(function()
				TweenService:Create(fSt, Tw.snap, {Transparency = 0.12, Color = LINE}):Play()
			end)
			box.FocusLost:Connect(function()
				TweenService:Create(fSt, Tw.soft, {Transparency = 0.4, Color = Colors.RowStroke}):Play()
			end)

			local btnY = 56
			local function smallBtn(text, xScale, cb)
				local b = mk("TextButton", {
					Position = UDim2.new(xScale, 0, 0, btnY),
					Size = UDim2.new(0.32, -4, 0, 28),
					BackgroundColor3 = Colors.Button, BackgroundTransparency = 0.1,
					BorderSizePixel = 0, Text = text, FontFace = FingerPaint, TextSize = 12, TextColor3 = Colors.Text,
					AutoButtonColor = false, Parent = row,
				})
				corner(b, 7)
				local st = stroke(b, Colors.RowStroke, 1, 0.4)
				b.MouseEnter:Connect(function()
					playHover()
					TweenService:Create(st, Tw.snap, {Transparency = 0.15}):Play()
				end)
				b.MouseLeave:Connect(function()
					TweenService:Create(st, Tw.soft, {Transparency = 0.4}):Play()
				end)
				b.MouseButton1Click:Connect(function()
					play("click")
					if cb then cb() end
				end)
			end

			local listBg = mk("Frame", {
				Position = UDim2.fromOffset(0, 90), Size = UDim2.new(1, 0, 0, 100),
				BackgroundColor3 = Colors.TitleBar, BackgroundTransparency = 0.12,
				BorderSizePixel = 0, ClipsDescendants = true, Parent = row,
			})
			corner(listBg, 8) stroke(listBg, Colors.RowStroke, 1, 0.4)

			local list = mk("ScrollingFrame", {
				Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4),
				BackgroundTransparency = 1, BorderSizePixel = 0,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = LINE,
				ScrollBarImageTransparency = 0.55,
				CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y, Parent = listBg,
			})
			mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = list})
			mk("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = list})

			local selectedName = box.Text
			local itemBtns = {}
			local filterText = ""

			local function clearItems()
				for _, b in ipairs(itemBtns) do
					if b and b.Parent then b:Destroy() end
				end
				table.clear(itemBtns)
			end

			local function refresh()
				clearItems()
				local names = ListConfigs()
				local q = filterText:lower()
				local shown = {}
				for _, name in ipairs(names) do
					if q == "" or name:lower():find(q, 1, true) then
						table.insert(shown, name)
					end
				end
				if #shown == 0 then
					local empty = mk("TextLabel", {
						Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, BorderSizePixel = 0,
						Text = (#names == 0) and "No configs saved" or "No matches",
						FontFace = FingerPaint, TextSize = 12,
						TextColor3 = Colors.TextDim, Parent = list,
					})
					table.insert(itemBtns, empty)
					return
				end
				for i, name in ipairs(shown) do
					local item = mk("TextButton", {
						Size = UDim2.new(1, -4, 0, 26),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Text = "",
						AutoButtonColor = false,
						LayoutOrder = i,
						Parent = list,
					})
					local itemLbl = mk("TextLabel", {
						Position = UDim2.fromOffset(10, 0),
						Size = UDim2.new(1, -20, 1, 0),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Text = name,
						FontFace = FingerPaint,
						TextSize = 13,
						TextColor3 = (name == selectedName) and Colors.TextHighlight or Colors.TextDim,
						TextXAlignment = Enum.TextXAlignment.Left,
						Parent = item,
					})
					local under = mk("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, 10, 1, -2),
						Size = UDim2.fromOffset(name == selectedName and 36 or 0, 2),
						BackgroundColor3 = LINE,
						BorderSizePixel = 0,
						Parent = item,
					})
					corner(under, 1)

					local function tw()
						local b = TextService:GetTextSize(name, 13, Enum.Font.GothamBold, Vector2.new(1000,40))
						return math.min(b.X + 2, item.AbsoluteSize.X - 20)
					end

					item.MouseEnter:Connect(function()
						if name ~= selectedName then
							TweenService:Create(itemLbl, Tw.snap, {TextColor3 = Colors.TextHighlight}):Play()
							TweenService:Create(under, Tw.soft, {Size = UDim2.fromOffset(tw(), 2)}):Play()
						end
					end)
					item.MouseLeave:Connect(function()
						if name ~= selectedName then
							TweenService:Create(itemLbl, Tw.soft, {TextColor3 = Colors.TextDim}):Play()
							TweenService:Create(under, Tw.snap, {Size = UDim2.fromOffset(0, 2)}):Play()
						end
					end)
					item.MouseButton1Click:Connect(function()
						play("click")
						selectedName = name
						box.Text = name
						filterText = name
						refresh()
					end)
					table.insert(itemBtns, item)
				end
			end

			box:GetPropertyChangedSignal("Text"):Connect(function()
				filterText = box.Text
				refresh()
			end)

			smallBtn("Save", 0, function()
				local n = box.Text
				if n == "" then n = "Main" end
				SaveCfg(n)
				selectedName = n
				filterText = n
				refresh()
			end)
			smallBtn("Load", 0.34, function()
				local n = box.Text
				if n == "" then n = selectedName end
				if n == "" then return end
				LoadCfg(n)
			end)
			smallBtn("Delete", 0.68, function()
				local n = box.Text
				if n == "" then n = selectedName end
				if n == "" then return end
				DeleteCfg(n)
				if selectedName == n then selectedName = "" box.Text = "" filterText = "" end
				refresh()
			end)

			refresh()

			return {
				Refresh = refresh,
				GetName = function() return box.Text end,
				SetName = function(v) box.Text = tostring(v or "") filterText = box.Text refresh() end,
			}
		end

		return Tab
	end

	function Window:Notify(t, txt, d) Notify(t, txt, d) end
	function Window:SaveConfig(name) SaveCfg(name) end
	function Window:LoadConfig(name) return LoadCfg(name) end
	function Window:ListConfigs() return ListConfigs() end
	function Window:DeleteConfig(name) return DeleteCfg(name) end
	function Window:Toggle() Toggle() end
	function Window:Destroy() ScreenGui:Destroy() end

	return Window
end

return Library
