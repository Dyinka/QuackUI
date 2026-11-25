-- коч
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local SoundService     = game:GetService("SoundService")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")
local LocalPlayer      = Players.LocalPlayer

local Library = {}

local function _rand(n)
	n = n or 10
	local t = {}
	for i = 1, n do t[i] = string.char(97 + math.random(0, 25)) end
	return table.concat(t)
end
local function stealthName(prefix)
	return (prefix or "x") .. _rand(10) .. tostring(math.random(100, 999))
end

local _owned = setmetatable({}, { __mode = "k" })
function Library._mark(gui) if gui then _owned[gui] = true end return gui end
function Library._isOurs(gui) return gui and _owned[gui] == true end

local OWN_ATTR = "a" .. _rand(8)
_G.__QX_ATTR = _G.__QX_ATTR or OWN_ATTR
OWN_ATTR = _G.__QX_ATTR

do
	local pg = LocalPlayer:WaitForChild("PlayerGui")
	for _, g in ipairs(pg:GetChildren()) do
		if g:GetAttribute(OWN_ATTR) == true then pcall(function() g:Destroy() end) end
	end
end
task.wait()

local FontMain = Font.fromEnum(Enum.Font.GothamBold)
local DUCK_ID = "rbxassetid://71109437053861"
local Z_TOP = 2147483647

local Themes = {
	Charcoal = {
		Background = Color3.fromRGB(20,18,24),
		TitleBar = Color3.fromRGB(28,26,34),
		Sidebar = Color3.fromRGB(24,22,30),
		Panel = Color3.fromRGB(33,31,38),
		PanelAlt = Color3.fromRGB(43,40,49),
		Text = Color3.fromRGB(230,225,229),
		TextDim = Color3.fromRGB(202,196,208),
		TextMuted = Color3.fromRGB(147,143,153),
		Accent = Color3.fromRGB(208,188,255),
		AccentSoft = Color3.fromRGB(79,55,139),
		Button = Color3.fromRGB(74,68,88),
		ButtonHover = Color3.fromRGB(91,84,107),
		Stroke = Color3.fromRGB(73,69,79),
		StrokeSoft = Color3.fromRGB(54,50,59),
		Track = Color3.fromRGB(73,69,79),
		Fill = Color3.fromRGB(208,188,255),
		Knob = Color3.fromRGB(56,30,114),
		KnobOff = Color3.fromRGB(147,143,153),
		Close = Color3.fromRGB(242,184,181),
		Good = Color3.fromRGB(180,220,170),
		Bad = Color3.fromRGB(242,184,181),
		Line = Color3.fromRGB(208,188,255),
		OnAccent = Color3.fromRGB(56,30,114),
		Surface = Color3.fromRGB(33,31,38),
		SurfaceHigh = Color3.fromRGB(43,40,49),
	},
	Obsidian = {
		Background = Color3.fromRGB(17,16,20),
		TitleBar = Color3.fromRGB(24,22,28),
		Sidebar = Color3.fromRGB(21,19,25),
		Panel = Color3.fromRGB(29,27,32),
		PanelAlt = Color3.fromRGB(38,35,43),
		Text = Color3.fromRGB(230,225,229),
		TextDim = Color3.fromRGB(196,190,202),
		TextMuted = Color3.fromRGB(140,136,146),
		Accent = Color3.fromRGB(203,194,255),
		AccentSoft = Color3.fromRGB(72,60,120),
		Button = Color3.fromRGB(66,61,78),
		ButtonHover = Color3.fromRGB(82,76,96),
		Stroke = Color3.fromRGB(70,66,76),
		StrokeSoft = Color3.fromRGB(50,47,56),
		Track = Color3.fromRGB(70,66,76),
		Fill = Color3.fromRGB(203,194,255),
		Knob = Color3.fromRGB(52,40,94),
		KnobOff = Color3.fromRGB(140,136,146),
		Close = Color3.fromRGB(242,184,181),
		Good = Color3.fromRGB(170,210,160),
		Bad = Color3.fromRGB(242,184,181),
		Line = Color3.fromRGB(203,194,255),
		OnAccent = Color3.fromRGB(52,40,94),
		Surface = Color3.fromRGB(29,27,32),
		SurfaceHigh = Color3.fromRGB(38,35,43),
	},
}

local DefaultTw = {
	snap=TweenInfo.new(0.14,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
	soft=TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
	press=TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
	bounce=TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
	open=TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
	close=TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
	list=TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
	listIn=TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
	modal=TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
	notif=TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
	group=TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
}

local function mk(c,p)
	local o = Instance.new(c)
	for k,v in pairs(p or {}) do
		if k=="FontFace" and typeof(v)=="EnumItem" then
			o.FontFace = Font.fromEnum(v)
		else
			o[k]=v
		end
	end
	return o
end
local function corner(p,r) return mk("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
local function stroke(p,col,th,tr,mode)
	return mk("UIStroke",{
		Color=col or Color3.fromRGB(58,58,66),
		Thickness=th or 1,
		Transparency=tr or 0,
		ApplyStrokeMode=mode or Enum.ApplyStrokeMode.Border,
		LineJoinMode=Enum.LineJoinMode.Round,
		Parent=p
	})
end
local function pad(p,t,b,l,r)
	return mk("UIPadding",{
		PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or t or 0),
		PaddingLeft=UDim.new(0,l or t or 0),PaddingRight=UDim.new(0,r or l or t or 0),Parent=p
	})
end
local function safeName(name)
	name=tostring(name or "default"):gsub("[^%w%-%_ ]","_"):gsub("^%s+",""):gsub("%s+$","")
	if name=="" then name="default" end
	return name
end

function Library:CreateLoader(opts)
	opts=opts or {}
	local ThemeName=opts.Theme or "Charcoal"
	local C={} for k,v in pairs(Themes[ThemeName] or Themes.Charcoal) do C[k]=v end
	if opts.Colors then for k,v in pairs(opts.Colors) do C[k]=v end end
	local Title=opts.Title or "QuackHub"
	local Subtitle=opts.Subtitle or "Initializing"
	local Texts=opts.Texts or {{Text="Loading...",Duration=0.8}}
	local OnFinish=opts.OnFinish
	local FadeTime=opts.FadeTime or 0.35
	local W,H=opts.Width or 380,opts.Height or 210
	local FloatId=opts.FloatImage or DUCK_ID

	local gui=mk("ScreenGui",{Name=stealthName("ld"),ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=Z_TOP,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=LocalPlayer:WaitForChild("PlayerGui")})
	gui:SetAttribute(OWN_ATTR,true) Library._mark(gui)

	local bg=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(6,6,8),BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})

	-- floating sparkles
	for i=1,10 do
		local dot=mk("Frame",{
			AnchorPoint=Vector2.new(0.5,0.5),
			Position=UDim2.fromScale(0.5 + math.random(-18,18)/100, 0.5 + math.random(-20,20)/100),
			Size=UDim2.fromOffset(math.random(2,5), math.random(2,5)),
			BackgroundColor3=C.Line,
			BackgroundTransparency=1,
			BorderSizePixel=0,
			ZIndex=2,
			Parent=gui
		})
		corner(dot,99)
		task.spawn(function()
			local base=dot.Position
			local t=math.random()*10
			local sp=0.4+math.random()*0.6
			local amp=math.random(8,22)
			while dot.Parent do
				t+=task.wait()
				dot.Position=UDim2.new(base.X.Scale, math.sin(t*sp)*amp, base.Y.Scale, math.cos(t*sp*1.3)*amp)
				dot.BackgroundTransparency=0.55 + (math.sin(t*1.7+i)*0.25)
			end
		end)
	end

	local duck=mk("ImageLabel",{
		AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.5,-120),
		Size=UDim2.fromOffset(110,110),
		BackgroundTransparency=1,
		Image=FloatId,
		ImageTransparency=1,
		ScaleType=Enum.ScaleType.Fit,
		ZIndex=3,
		Parent=gui
	})
	local duckSc=mk("UIScale",{Scale=0.9,Parent=duck})
	task.spawn(function()
		local t=0
		while duck.Parent do
			t+=task.wait()
			duck.Position=UDim2.new(0.5, math.sin(t*0.8)*10, 0.5, -120 + math.sin(t*1.4)*8)
			duck.Rotation=math.sin(t*1.1)*8
			duckSc.Scale=1 + math.sin(t*1.6)*0.04
		end
	end)

	local glow=mk("ImageLabel",{
		AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0.5,0,0.5,-120),
		Size=UDim2.fromOffset(160,160),
		BackgroundTransparency=1,
		Image="rbxassetid://5028857084",
		ImageColor3=C.Accent,
		ImageTransparency=1,
		ZIndex=1,
		Parent=gui
	})
	task.spawn(function()
		local t=0
		while glow.Parent do
			t+=task.wait()
			glow.Position=duck.Position
			glow.ImageTransparency=0.88 + math.sin(t*1.2)*0.04
			local s=1+math.sin(t*1.2)*0.06
			glow.Size=UDim2.fromOffset(160*s,160*s)
		end
	end)

	local card=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,30),Size=UDim2.fromOffset(W,H),BackgroundColor3=C.Background,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,Parent=gui})
	corner(card,14) stroke(card,C.Stroke,1,0.15)
	local sc=mk("UIScale",{Scale=0.95,Parent=card})

	mk("TextLabel",{Position=UDim2.fromOffset(22,20),Size=UDim2.new(1,-44,0,28),BackgroundTransparency=1,Text=Title,FontFace=FontMain,TextSize=24,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=card})
	mk("TextLabel",{Position=UDim2.fromOffset(22,50),Size=UDim2.new(1,-44,0,18),BackgroundTransparency=1,Text=Subtitle,FontFace=FontMain,TextSize=14,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=card})

	local tip=mk("TextLabel",{Position=UDim2.fromOffset(22,76),Size=UDim2.new(1,-44,0,16),BackgroundTransparency=1,Text="quack... loading your stuff",FontFace=FontMain,TextSize=12,TextColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=card})
	local tips={"quack... loading your stuff","polishing buttons...","feeding the duck...","almost there...","making it smooth..."}
	task.spawn(function()
		local i=1
		while tip.Parent do
			tip.Text=tips[i]
			i=i%#tips+1
			task.wait(0.9)
		end
	end)

	local status=mk("TextLabel",{Position=UDim2.fromOffset(22,132),Size=UDim2.new(1,-44,0,18),BackgroundTransparency=1,Text="",FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=card})
	local pct=mk("TextLabel",{Position=UDim2.new(1,-72,0,132),Size=UDim2.fromOffset(50,18),BackgroundTransparency=1,Text="0%",FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5,Parent=card})

	local barBg=mk("Frame",{Position=UDim2.fromOffset(22,156),Size=UDim2.new(1,-44,0,8),BackgroundColor3=C.Track,BackgroundTransparency=0.15,BorderSizePixel=0,ZIndex=5,Parent=card})
	corner(barBg,4) stroke(barBg,C.StrokeSoft,1,0.2)
	local fill=mk("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.Accent,BorderSizePixel=0,ZIndex=6,Parent=barBg})
	corner(fill,4)
	local fillGlow=mk("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.Line,BackgroundTransparency=0.75,BorderSizePixel=0,ZIndex=7,Parent=fill})
	corner(fillGlow,99)

	TweenService:Create(bg,TweenInfo.new(FadeTime),{BackgroundTransparency=0.35}):Play()
	TweenService:Create(card,TweenInfo.new(FadeTime),{BackgroundTransparency=0.12}):Play()
	TweenService:Create(sc,DefaultTw.bounce,{Scale=1}):Play()
	TweenService:Create(duck,TweenInfo.new(FadeTime),{ImageTransparency=0}):Play()
	TweenService:Create(glow,TweenInfo.new(FadeTime),{ImageTransparency=0.88}):Play()

	task.spawn(function()
		local total=math.max(#Texts,1)
		for i,e in ipairs(Texts) do
			status.Text=e.Text or ("Step "..i)
			local prog=i/total
			pct.Text=tostring(math.floor(prog*100)).."%"
			TweenService:Create(fill,TweenInfo.new((e.Duration or 0.8)*0.85,Enum.EasingStyle.Quad),{Size=UDim2.fromScale(prog,1)}):Play()
			if typeof(e.Callback)=="function" then task.spawn(e.Callback,i,e.Text,e) end
			task.wait(e.Duration or 0.8)
		end
		TweenService:Create(fill,TweenInfo.new(0.2),{Size=UDim2.fromScale(1,1)}):Play()
		pct.Text="100%"
		status.Text=opts.FinishText or "Ready"
		task.wait(0.3)
		local t1=TweenService:Create(card,TweenInfo.new(FadeTime),{BackgroundTransparency=1})
		TweenService:Create(bg,TweenInfo.new(FadeTime),{BackgroundTransparency=1}):Play()
		TweenService:Create(sc,DefaultTw.soft,{Scale=0.97}):Play()
		TweenService:Create(duck,TweenInfo.new(FadeTime),{ImageTransparency=1}):Play()
		TweenService:Create(glow,TweenInfo.new(FadeTime),{ImageTransparency=1}):Play()
		t1:Play()
		t1.Completed:Connect(function() gui:Destroy() if typeof(OnFinish)=="function" then OnFinish() end end)
	end)

	return {Destroy=function() if gui then gui:Destroy() end end, Gui=gui}
end


function Library:CreateWindow(opts)
	opts=opts or {}
	local Title=opts.Title or "QuackHub"
	local MAIN_W=opts.Width or 820
	local MAIN_H=opts.Height or 560
	local TITLE_H=opts.TitleHeight or 56
	local SIDEBAR_W=opts.SidebarWidth or 176
	local ThemeName=opts.Theme or "Charcoal"
	local ToggleKey=opts.ToggleKey or Enum.KeyCode.K
	local ConfigFolder=opts.ConfigFolder or "QuackHubConfigs"
	local MainTrans=opts.MainTransparency or 0.18
	local CornerR=opts.CornerRadius or 20
	local SoundEnabled=opts.SoundEnabled ~= false
	local ShowDropBtn=opts.ShowDropButton ~= false
	local HeaderImage=opts.HeaderImage or DUCK_ID
	local FloatImage=opts.FloatImage or DUCK_ID
	local ROW_H,BTN_H,FIELD_H,PAD=40,34,30,12

	local C={} for k,v in pairs(Themes[ThemeName] or Themes.Charcoal) do C[k]=v end
	if opts.Colors then for k,v in pairs(opts.Colors) do C[k]=v end end
	local Tw={} for k,v in pairs(DefaultTw) do Tw[k]=v end
	if opts.Tween then for k,v in pairs(opts.Tween) do Tw[k]=v end end

	local Sounds,LastHover,LastSlider={},0,0
	if SoundEnabled then
		local function makeSound(n,id,v) local s=Instance.new("Sound") s.SoundId=id s.Volume=v s.Parent=SoundService Sounds[n]=s end
		local ids=opts.SoundIds or {}
		makeSound("click",ids.click or "rbxassetid://6895079853",0.28)
		makeSound("hover",ids.hover or "rbxassetid://107511012621133",0.12)
		makeSound("close",ids.close or "rbxassetid://97375206361343",0.25)
		makeSound("notify",ids.notify or "rbxassetid://71730540025978",0.3)
		makeSound("toggle",ids.toggle or "rbxassetid://128389255905279",0.28)
		makeSound("slider",ids.slider or "rbxassetid://121370732132760",0.35)
	end
	local function play(n) if SoundEnabled and Sounds[n] then Sounds[n]:Stop() Sounds[n]:Play() end end
	local function playHover() local t=os.clock() if t-LastHover<0.06 then return end LastHover=t play("hover") end
	local function playSlider() local t=os.clock() if t-LastSlider<0.05 then return end LastSlider=t play("slider") end

	local ScreenGui=mk("ScreenGui",{Name=stealthName("ui"),ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=Z_TOP,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=LocalPlayer:WaitForChild("PlayerGui")})
	ScreenGui:SetAttribute(OWN_ATTR,true) Library._mark(ScreenGui)
	local PopupLayer=mk("Frame",{Name="PopupLayer",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=900,Active=false,Selectable=false,Parent=ScreenGui})

	local OpenPops,ConfigEls={},{ }
	local closeAll,closeOne
	local lastPos=UDim2.fromScale(0.5,0.5)

	local NotifBox=mk("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-18),Size=UDim2.fromOffset(320,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10000,Parent=ScreenGui})
	mk("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Parent=NotifBox})
	local nOrder=0
	local function Notify(title,text,dur)
		dur=dur or 3 nOrder+=1 play("notify")
		local n=mk("Frame",{Size=UDim2.fromOffset(300,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.Panel,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=nOrder,Parent=NotifBox})
		corner(n,16) local ns=stroke(n,C.StrokeSoft,1,1) local nsc=mk("UIScale",{Scale=0.95,Parent=n})
		pad(n,10,10,12,12)
		mk("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=n})
		mk("TextLabel",{Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=text,FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=n})
		TweenService:Create(n,Tw.notif,{BackgroundTransparency=0.12}):Play()
		TweenService:Create(ns,Tw.notif,{Transparency=0.1}):Play()
		TweenService:Create(nsc,Tw.bounce,{Scale=1}):Play()
		task.delay(dur,function()
			local a=TweenService:Create(n,Tw.notif,{BackgroundTransparency=1})
			TweenService:Create(ns,Tw.notif,{Transparency=1}):Play()
			TweenService:Create(nsc,Tw.soft,{Scale=0.96}):Play()
			a:Play() a.Completed:Connect(function() n:Destroy() end)
		end)
	end

	local DropBtn
	if ShowDropBtn then
		DropBtn=mk("TextButton",{Name="DropButton",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,12),Size=UDim2.fromOffset(52,52),BackgroundColor3=C.AccentSoft,BackgroundTransparency=0.15,Text="",AutoButtonColor=false,BorderSizePixel=0,ZIndex=20000,Parent=ScreenGui})
		corner(DropBtn,18) stroke(DropBtn,C.Accent,1,0.25)
		local duck=mk("ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(32,32),BackgroundTransparency=1,Image=FloatImage,ScaleType=Enum.ScaleType.Fit,ZIndex=20001,Parent=DropBtn})
		local dsc=mk("UIScale",{Scale=1,Parent=duck})
		task.spawn(function()
			local t=0
			while duck.Parent do t+=task.wait() if not DropBtn:GetAttribute("H") then duck.Rotation=math.sin(t*1.6)*6 dsc.Scale=1+math.sin(t*2.2)*0.04 end end
		end)
		DropBtn.MouseEnter:Connect(function() playHover() DropBtn:SetAttribute("H",true) TweenService:Create(DropBtn,Tw.snap,{BackgroundColor3=C.ButtonHover,BackgroundTransparency=0.05}):Play() TweenService:Create(dsc,Tw.bounce,{Scale=1.15}):Play() end)
		DropBtn.MouseLeave:Connect(function() DropBtn:SetAttribute("H",false) TweenService:Create(DropBtn,Tw.soft,{BackgroundColor3=C.Panel,BackgroundTransparency=0.12}):Play() TweenService:Create(dsc,Tw.soft,{Scale=1}):Play() TweenService:Create(duck,Tw.soft,{Rotation=0}):Play() end)
	end

	local Main=mk("CanvasGroup",{Name="MainFrame",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(MAIN_W,MAIN_H),BackgroundColor3=C.Background,BackgroundTransparency=MainTrans,BorderSizePixel=0,ClipsDescendants=true,GroupTransparency=0,Visible=false,Parent=ScreenGui})
	corner(Main,CornerR) stroke(Main,C.StrokeSoft,1,0.12)

	local TitleBar=mk("Frame",{Name="TitleBar",Size=UDim2.new(1,0,0,TITLE_H),BackgroundColor3=C.TitleBar,BackgroundTransparency=0.12,BorderSizePixel=0,Active=true,ZIndex=5,Parent=Main})
	mk("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.StrokeSoft,BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=6,Parent=TitleBar})
	local headerIcon=mk("ImageLabel",{Position=UDim2.fromOffset(14,11),Size=UDim2.fromOffset(34,34),BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.15,BorderSizePixel=0,Image=HeaderImage,ScaleType=Enum.ScaleType.Fit,ZIndex=7,Parent=TitleBar})
	corner(headerIcon,12) stroke(headerIcon,C.StrokeSoft,1,0.15)
	mk("TextLabel",{Position=UDim2.fromOffset(58,8),Size=UDim2.new(1,-170,0,20),BackgroundTransparency=1,Text=Title,FontFace=FontMain,TextSize=20,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,Parent=TitleBar})
	mk("TextLabel",{Position=UDim2.fromOffset(58,30),Size=UDim2.new(1,-170,0,14),BackgroundTransparency=1,Text="clean interface",FontFace=FontMain,TextSize=12,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,Parent=TitleBar})

	local function ctrlBtn(glyph,x,col,fn)
		local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,x,0.5,0),Size=UDim2.fromOffset(32,32),BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.15,BorderSizePixel=0,Text=glyph,FontFace=FontMain,TextSize=18,TextColor3=col,AutoButtonColor=false,ZIndex=8,Parent=TitleBar})
		corner(b,16) local st=stroke(b,C.StrokeSoft,1,0.12)
		b.MouseEnter:Connect(function() playHover() TweenService:Create(b,Tw.snap,{BackgroundColor3=C.ButtonHover,BackgroundTransparency=0.05}):Play() TweenService:Create(st,Tw.snap,{Color=C.Stroke,Transparency=0}):Play() end)
		b.MouseLeave:Connect(function() TweenService:Create(b,Tw.soft,{BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.2}):Play() TweenService:Create(st,Tw.soft,{Color=C.StrokeSoft,Transparency=0.15}):Play() end)
		b.MouseButton1Click:Connect(fn) return b
	end

	local Sidebar=mk("Frame",{Name="Sidebar",Position=UDim2.fromOffset(0,TITLE_H),Size=UDim2.new(0,SIDEBAR_W,1,-TITLE_H),BackgroundColor3=C.Sidebar,BackgroundTransparency=0.15,BorderSizePixel=0,ZIndex=2,Parent=Main})
	mk("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.StrokeSoft,BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=3,Parent=Sidebar})
	local TabScroll=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Stroke,ScrollBarImageTransparency=0.35,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=Sidebar})
	mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=TabScroll})
	pad(TabScroll,10,10,10,10)

	local Content=mk("Frame",{Name="ContentArea",Position=UDim2.fromOffset(SIDEBAR_W,TITLE_H),Size=UDim2.new(1,-SIDEBAR_W,1,-TITLE_H),BackgroundTransparency=1,BorderSizePixel=0,Parent=Main})

	local Overlay=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=1005,Parent=ScreenGui})
	local Box=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(300,150),BackgroundColor3=C.Panel,BackgroundTransparency=0.05,BorderSizePixel=0,ZIndex=1006,Parent=Overlay})
	corner(Box,20) stroke(Box,C.StrokeSoft,1,0.1) local bSc=mk("UIScale",{Scale=1,Parent=Box})
	mk("TextLabel",{Size=UDim2.new(1,0,0,56),BackgroundTransparency=1,Text="Close UI?",FontFace=FontMain,TextSize=20,TextColor3=C.Text,ZIndex=1007,Parent=Box})
	local Yes=mk("TextButton",{Position=UDim2.fromOffset(20,90),Size=UDim2.fromOffset(120,36),BackgroundColor3=C.Button,BackgroundTransparency=0.1,BorderSizePixel=0,Text="Yes",FontFace=FontMain,TextSize=14,TextColor3=C.Text,AutoButtonColor=false,ZIndex=1007,Parent=Box})
	corner(Yes,16) stroke(Yes,C.StrokeSoft,1,0.12)
	local No=mk("TextButton",{Position=UDim2.new(1,-140,0,90),Size=UDim2.fromOffset(120,36),BackgroundColor3=C.Button,BackgroundTransparency=0.1,BorderSizePixel=0,Text="Cancel",FontFace=FontMain,TextSize=14,TextColor3=C.Text,AutoButtonColor=false,ZIndex=1007,Parent=Box})
	corner(No,16) stroke(No,C.StrokeSoft,1,0.12)
	Yes.MouseButton1Click:Connect(function() play("close") ScreenGui:Destroy() end)
	No.MouseButton1Click:Connect(function() play("click") Overlay.Visible=false end)


	ctrlBtn("-", -50, C.TextDim, function()
		play("click") closeAll(true)
		local min=Main.Size.Y.Offset<=TITLE_H
		local vp=workspace.CurrentCamera.ViewportSize
		if min then
			local ts=Vector2.new(MAIN_W,MAIN_H)
			local tlX=math.clamp(Main.Position.X.Offset-ts.X/2,0,math.max(0,vp.X-ts.X))
			local tlY=math.clamp(Main.Position.Y.Offset-ts.Y/2,0,math.max(0,vp.Y-ts.Y))
			lastPos=UDim2.fromOffset(tlX+ts.X/2,tlY+ts.Y/2)
			TweenService:Create(Main,Tw.soft,{Size=UDim2.fromOffset(MAIN_W,MAIN_H),Position=lastPos}):Play()
			Sidebar.Visible=true Content.Visible=true
		else
			lastPos=Main.Position
			local ts=Vector2.new(MAIN_W,TITLE_H)
			local tlX=math.clamp(Main.Position.X.Offset-ts.X/2,0,math.max(0,vp.X-ts.X))
			local tlY=math.clamp(Main.Position.Y.Offset-ts.Y/2,0,math.max(0,vp.Y-ts.Y))
			TweenService:Create(Main,Tw.soft,{Size=UDim2.fromOffset(MAIN_W,TITLE_H),Position=UDim2.fromOffset(tlX+ts.X/2,tlY+ts.Y/2)}):Play()
			Sidebar.Visible=false Content.Visible=false
		end
	end)
	ctrlBtn("×", -14, C.Close, function()
		play("click") closeAll(true) Overlay.Visible=true Overlay.BackgroundTransparency=0.45 bSc.Scale=0.96
		TweenService:Create(bSc,Tw.modal,{Scale=1}):Play()
	end)

	local function inRect(px,py,pos,size) return px>=pos.X and px<=pos.X+size.X and py>=pos.Y and py<=pos.Y+size.Y end
	local function rem(e) for i=#OpenPops,1,-1 do if OpenPops[i]==e then table.remove(OpenPops,i) end end end
	closeOne=function(e,instant)
		if e.closing or not e.isOpen then return end
		e.closing=true e.isOpen=false rem(e)
		if e.closeFn then e.closeFn(instant) end
	end
	closeAll=function(instant)
		local copy={} for i,e in ipairs(OpenPops) do copy[i]=e end
		for _,e in ipairs(copy) do closeOne(e,instant) end
	end
	UserInputService.InputBegan:Connect(function(inp)
		if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
		if #OpenPops==0 then return end
		local px,py=inp.Position.X,inp.Position.Y
		for _,e in ipairs(OpenPops) do
			local inside=e.panel and inRect(px,py,e.panel.AbsolutePosition,e.panel.AbsoluteSize)
			if not inside and e.triggers then
				for _,t in ipairs(e.triggers) do
					if t and t.Visible and inRect(px,py,t.AbsolutePosition,t.AbsoluteSize) then inside=true break end
				end
			end
			if inside then return end
		end
		closeAll(false)
	end)

	local isOpen,anim=false,false
	local function Toggle()
		if anim then return end anim=true play("toggle") closeAll(true) Overlay.Visible=false
		if isOpen then
			lastPos=Main.Position
			local c=(DropBtn and (DropBtn.AbsolutePosition+DropBtn.AbsoluteSize*0.5)) or Vector2.new(MAIN_W/2,MAIN_H/2)
			local t=TweenService:Create(Main,Tw.close,{Position=UDim2.fromOffset(c.X,c.Y),Size=UDim2.fromOffset(8,8),GroupTransparency=1})
			t:Play() t.Completed:Connect(function() Main.Visible=false isOpen=false anim=false end)
		else
			Main.Visible=true Main.GroupTransparency=1 Sidebar.Visible=true Content.Visible=true
			Main.Size=UDim2.fromOffset(8,8)
			local c=(DropBtn and (DropBtn.AbsolutePosition+DropBtn.AbsoluteSize*0.5)) or Vector2.new(MAIN_W/2,MAIN_H/2)
			Main.Position=UDim2.fromOffset(c.X,c.Y)
			local vp=workspace.CurrentCamera.ViewportSize
			local fp
			if lastPos.X.Scale==0.5 and lastPos.Y.Scale==0.5 and lastPos.X.Offset==0 and lastPos.Y.Offset==0 then
				fp=UDim2.fromOffset(vp.X/2,vp.Y/2)
			else
				local ts=Vector2.new(MAIN_W,MAIN_H)
				local tlX=math.clamp(lastPos.X.Offset-ts.X/2,0,math.max(0,vp.X-ts.X))
				local tlY=math.clamp(lastPos.Y.Offset-ts.Y/2,0,math.max(0,vp.Y-ts.Y))
				fp=UDim2.fromOffset(tlX+ts.X/2,tlY+ts.Y/2)
			end
			local t=TweenService:Create(Main,Tw.open,{Position=fp,Size=UDim2.fromOffset(MAIN_W,MAIN_H),GroupTransparency=0})
			t:Play() t.Completed:Connect(function() isOpen=true anim=false lastPos=Main.Position end)
		end
	end
	if DropBtn then DropBtn.MouseButton1Click:Connect(Toggle) end

	local drag,dStart,sPos=false,nil,nil
	TitleBar.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
			closeAll(true) drag=true dStart=inp.Position sPos=Main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
			local d=inp.Position-dStart local vp=workspace.CurrentCamera.ViewportSize local sz=Main.AbsoluteSize
			local tlX=math.clamp(sPos.X.Offset+d.X-sz.X/2,0,math.max(0,vp.X-sz.X))
			local tlY=math.clamp(sPos.Y.Offset+d.Y-sz.Y/2,0,math.max(0,vp.Y-sz.Y))
			Main.Position=UDim2.fromOffset(tlX+sz.X/2,tlY+sz.Y/2)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false lastPos=Main.Position end
	end)
	UserInputService.InputBegan:Connect(function(inp,g) if not g and inp.KeyCode==ToggleKey then Toggle() end end)

	-- ============ COMPONENTS ============
	local function section(par,title,ord)
		local s=mk("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=string.upper(title),FontFace=FontMain,TextSize=11,TextColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,Parent=s})
	end

	local function label(par,text,ord)
		local l=mk("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=text,FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LayoutOrder=ord or 0,Parent=par})
		pad(l,2,2,0,0)
		return {Set=function(v) l.Text=tostring(v or "") end, Get=function() return l.Text end}
	end

	local function toggle(par,title,desc,def,ord,cb)
		local hasDesc=desc and desc~=""
		local h=hasDesc and 52 or 42
		local row=mk("Frame",{Size=UDim2.new(1,0,0,h),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Position=hasDesc and UDim2.fromOffset(0,6) or UDim2.fromOffset(0,0),Size=hasDesc and UDim2.new(1,-66,0,18) or UDim2.new(1,-66,1,0),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
		if hasDesc then mk("TextLabel",{Position=UDim2.fromOffset(0,26),Size=UDim2.new(1,-66,0,16),BackgroundTransparency=1,Text=desc,FontFace=FontMain,TextSize=12,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,Parent=row}) end
		local track=mk("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(52,32),BackgroundColor3=def and C.Accent or C.PanelAlt,BackgroundTransparency=def and 0 or 0.1,BorderSizePixel=0,Parent=row})
		corner(track,16) local tst=stroke(track,def and C.Accent or C.Stroke,2,def and 0 or 0.15)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=def and UDim2.new(1,-16,0.5,0) or UDim2.new(0,16,0.5,0),Size=def and UDim2.fromOffset(24,24) or UDim2.fromOffset(16,16),BackgroundColor3=def and C.OnAccent or C.TextMuted,BorderSizePixel=0,Parent=track})
		corner(knob,99)
		local state=def or false
		local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=row})
		hit.MouseEnter:Connect(function() playHover() TweenService:Create(track,Tw.snap,{BackgroundTransparency=state and 0 or 0.05}):Play() end)
		hit.MouseLeave:Connect(function() TweenService:Create(track,Tw.soft,{BackgroundTransparency=state and 0 or 0.1}):Play() end)
		hit.MouseButton1Click:Connect(function()
			play("click") state=not state
			TweenService:Create(track,Tw.soft,{BackgroundColor3=state and C.Accent or C.PanelAlt,BackgroundTransparency=state and 0 or 0.1}):Play()
			TweenService:Create(tst,Tw.soft,{Color=state and C.Accent or C.Stroke,Transparency=state and 0 or 0.15}):Play()
			TweenService:Create(knob,Tw.bounce,{Position=state and UDim2.new(1,-16,0.5,0) or UDim2.new(0,16,0.5,0),Size=state and UDim2.fromOffset(24,24) or UDim2.fromOffset(16,16),BackgroundColor3=state and C.OnAccent or C.TextMuted}):Play()
			if cb then cb(state) end
		end)
		return {
			Set=function(v) state=v track.BackgroundColor3=state and C.Accent or C.PanelAlt track.BackgroundTransparency=state and 0 or 0.1 tst.Color=state and C.Accent or C.Stroke tst.Transparency=state and 0 or 0.15 knob.Position=state and UDim2.new(1,-16,0.5,0) or UDim2.new(0,16,0.5,0) knob.Size=state and UDim2.fromOffset(24,24) or UDim2.fromOffset(16,16) knob.BackgroundColor3=state and C.OnAccent or C.TextMuted if cb then cb(state) end end,
			Get=function() return state end
		}
	end


	local function slider(par,title,min,max,def,ord,cb)
		local range=math.max(max-min,1e-6)
		local row=mk("Frame",{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Position=UDim2.fromOffset(0,2),Size=UDim2.new(1,-50,0,16),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
		local vl=mk("TextLabel",{Position=UDim2.new(1,-50,0,2),Size=UDim2.fromOffset(50,16),BackgroundTransparency=1,Text=tostring(def),FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Right,Parent=row})
		local track=mk("Frame",{Position=UDim2.new(0,0,0,26),Size=UDim2.new(1,0,0,6),BackgroundColor3=C.Track,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=row})
		corner(track,99)
		local rx0=math.clamp((def-min)/range,0,1)
		local fill=mk("Frame",{Size=UDim2.fromScale(rx0,1),BackgroundColor3=C.Fill,BorderSizePixel=0,Parent=track}) corner(fill,4)
		local knob=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(rx0,0.5),Size=UDim2.fromOffset(20,20),BackgroundColor3=C.Accent,BorderSizePixel=0,Parent=track})
		corner(knob,99) stroke(knob,C.OnAccent,2,0.2)
		local dragging=false
		local hit=mk("TextButton",{Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="",Parent=row})
		local function upd(inp)
			local rx=math.clamp((inp.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
			local v=math.floor(min+(max-min)*rx+0.5)
			fill.Size=UDim2.fromScale(rx,1) knob.Position=UDim2.fromScale(rx,0.5) vl.Text=tostring(v)
			playSlider() if cb then cb(v) end
		end
		hit.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true upd(inp) end end)
		UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then upd(inp) end end)
		UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
		return {
			Set=function(v) local rx=math.clamp((v-min)/range,0,1) fill.Size=UDim2.fromScale(rx,1) knob.Position=UDim2.fromScale(rx,0.5) vl.Text=tostring(v) if cb then cb(v) end end,
			Get=function() return tonumber(vl.Text) end
		}
	end

	local function button(par,title,ord,cb)
		local b=mk("TextButton",{Size=UDim2.new(1,0,0,BTN_H),BackgroundColor3=C.Button,BackgroundTransparency=0.05,BorderSizePixel=0,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,AutoButtonColor=false,LayoutOrder=ord or 0,Parent=par})
		corner(b,18) local st=stroke(b,C.StrokeSoft,1,0.1)
		b.MouseEnter:Connect(function() playHover() TweenService:Create(b,Tw.snap,{BackgroundColor3=C.ButtonHover,BackgroundTransparency=0}):Play() TweenService:Create(st,Tw.snap,{Color=C.Accent,Transparency=0.3}):Play() end)
		b.MouseLeave:Connect(function() TweenService:Create(b,Tw.soft,{BackgroundColor3=C.Button,BackgroundTransparency=0.05}):Play() TweenService:Create(st,Tw.soft,{Color=C.StrokeSoft,Transparency=0.1}):Play() end)
		b.MouseButton1Click:Connect(function() play("click") if cb then cb() end end)
	end

	local function textbox(par,title,def,ord,cb)
		local row=mk("Frame",{Size=UDim2.new(1,0,0,ROW_H),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
		local field=mk("Frame",{Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,0,0,FIELD_H),BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=row})
		corner(field,12) local st=stroke(field,C.Stroke,1,0.15)
		local box=mk("TextBox",{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-20,1,0),BackgroundTransparency=1,Text=def or "",PlaceholderText="Enter text...",PlaceholderColor3=C.TextMuted,TextColor3=C.Text,FontFace=FontMain,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=field})
		box.Focused:Connect(function() TweenService:Create(st,Tw.snap,{Color=C.Accent,Transparency=0}):Play() TweenService:Create(field,Tw.snap,{BackgroundTransparency=0.1}):Play() end)
		box.FocusLost:Connect(function() play("click") TweenService:Create(st,Tw.soft,{Color=C.Stroke,Transparency=0.15}):Play() TweenService:Create(field,Tw.soft,{BackgroundTransparency=0.2}):Play() if cb then cb(box.Text) end end)
		return {Set=function(v) box.Text=tostring(v or "") end, Get=function() return box.Text end}
	end

	local function keybind(par,title,def,ord,cb)
		local row=mk("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Size=UDim2.new(1,-90,1,0),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
		local kb=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(88,30),BackgroundColor3=C.Button,BackgroundTransparency=0.05,BorderSizePixel=0,Text=def and def.Name or "None",FontFace=FontMain,TextSize=12,TextColor3=C.Text,AutoButtonColor=false,Parent=row})
		corner(kb,15) local st=stroke(kb,C.StrokeSoft,1,0.1)
		local listen,cur=false,def
		kb.MouseButton1Click:Connect(function() play("click") listen=true kb.Text="..." TweenService:Create(st,Tw.snap,{Color=C.Accent,Transparency=0}):Play() end)
		UserInputService.InputBegan:Connect(function(inp,g)
			if g or not listen or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
			listen=false cur=inp.KeyCode kb.Text=inp.KeyCode.Name TweenService:Create(st,Tw.soft,{Color=C.StrokeSoft,Transparency=0.15}):Play() if cb then cb(inp.KeyCode) end
		end)
		return {Set=function(k) cur=k kb.Text=k and k.Name or "None" end, Get=function() return cur end}
	end

	local function dropdown(par,title,options,def,ord,cb)
		options=options or {}
		local selected=def or options[1] or ""
		local row=mk("Frame",{Size=UDim2.new(1,0,0,ROW_H),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
		local trig=mk("TextButton",{Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,0,0,FIELD_H),BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.2,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=row})
		corner(trig,12) local st=stroke(trig,C.Stroke,1,0.15)
		local tl=mk("TextLabel",{Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-30,1,0),BackgroundTransparency=1,Text=tostring(selected),FontFace=FontMain,TextSize=13,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=trig})
		mk("TextLabel",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,Text="▾",FontFace=FontMain,TextSize=12,TextColor3=C.TextDim,Parent=trig})
		local panel=mk("ScrollingFrame",{Size=UDim2.fromOffset(200,0),BackgroundColor3=C.Panel,BackgroundTransparency=0.06,BorderSizePixel=0,Visible=false,ScrollBarThickness=2,ScrollBarImageColor3=C.Stroke,ScrollBarImageTransparency=0.3,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=950,Parent=PopupLayer})
		corner(panel,14) stroke(panel,C.StrokeSoft,1,0.1)
		mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=panel}) pad(panel,4,4,4,4)
		local ph=math.min(#options*28+8,170)
		local entry={panel=panel,isOpen=false,closing=false,width=0,triggers={trig}}
		entry.closeFn=function(instant)
			TweenService:Create(st,Tw.soft,{Color=C.Stroke,Transparency=0.15}):Play()
			if instant then panel.Visible=false panel.Size=UDim2.fromOffset(entry.width or 200,0) entry.closing=false
			else local t=TweenService:Create(panel,Tw.listIn,{Size=UDim2.fromOffset(entry.width or 200,0),BackgroundTransparency=1}) t:Play() t.Completed:Connect(function() if entry.closing then panel.Visible=false panel.BackgroundTransparency=0.06 entry.closing=false end end) end
		end
		local function openDrop()
			closeAll(true)
			local abs,sz=trig.AbsolutePosition,trig.AbsoluteSize entry.width=sz.X
			panel.Position=UDim2.fromOffset(abs.X,abs.Y+sz.Y+4) panel.Size=UDim2.fromOffset(sz.X,0) panel.Visible=true panel.BackgroundTransparency=1
			entry.isOpen=true entry.closing=false table.insert(OpenPops,entry)
			TweenService:Create(st,Tw.snap,{Color=C.Accent,Transparency=0}):Play()
			TweenService:Create(panel,Tw.list,{Size=UDim2.fromOffset(sz.X,ph),BackgroundTransparency=0.06}):Play()
		end
		for i,opt in ipairs(options) do
			local it=mk("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,Text=tostring(opt),FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,AutoButtonColor=false,LayoutOrder=i,Parent=panel})
			corner(it,6)
			it.MouseEnter:Connect(function() TweenService:Create(it,Tw.snap,{BackgroundTransparency=0.15,BackgroundColor3=C.ButtonHover,TextColor3=C.Text}):Play() end)
			it.MouseLeave:Connect(function() TweenService:Create(it,Tw.soft,{BackgroundTransparency=1,TextColor3=C.TextDim}):Play() end)
			it.MouseButton1Click:Connect(function() play("click") selected=opt tl.Text=tostring(opt) closeOne(entry,false) if cb then cb(opt) end end)
		end
		trig.MouseButton1Click:Connect(function() play("click") if entry.isOpen then closeOne(entry,false) else openDrop() end end)
		return {Set=function(v) selected=v tl.Text=tostring(v) if cb then cb(v) end end, Get=function() return selected end}
	end


	local function colorpicker(par,title,def,ord,cb)
		def=def or Color3.fromRGB(160,160,170)
		local row=mk("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=ord or 0,Parent=par})
		mk("TextLabel",{Size=UDim2.new(1,-42,1,0),BackgroundTransparency=1,Text=title,FontFace=FontMain,TextSize=14,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
		local prev=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(28,28),BackgroundColor3=def,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=row})
		corner(prev,7) stroke(prev,C.StrokeSoft,1,0.15)
		local r,g,b=def.R,def.G,def.B
		local function apply() local c=Color3.new(r,g,b) prev.BackgroundColor3=c if cb then cb(c) end end
		local panel=mk("Frame",{Size=UDim2.fromOffset(220,0),BackgroundColor3=C.Panel,BackgroundTransparency=0.06,BorderSizePixel=0,Visible=false,ZIndex=950,Parent=PopupLayer})
		corner(panel,10) stroke(panel,C.Stroke,1,0.08)
		local big=mk("Frame",{Position=UDim2.fromOffset(10,10),Size=UDim2.fromOffset(200,30),BackgroundColor3=def,BorderSizePixel=0,Parent=panel}) corner(big,6) stroke(big,C.StrokeSoft,1,0.15)
		local function chan(lbl,y,init,setFn)
			mk("TextLabel",{Position=UDim2.fromOffset(10,y),Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,Text=lbl,FontFace=FontMain,TextSize=12,TextColor3=C.TextDim,Parent=panel})
			local tr=mk("Frame",{Position=UDim2.fromOffset(28,y+2),Size=UDim2.fromOffset(150,10),BackgroundColor3=C.Track,BackgroundTransparency=0.1,BorderSizePixel=0,Parent=panel}) corner(tr,5) stroke(tr,C.StrokeSoft,1,0.15)
			local fl=mk("Frame",{Size=UDim2.fromScale(init,1),BackgroundColor3=C.Fill,BorderSizePixel=0,Parent=tr}) corner(fl,5)
			local kn=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(init,0.5),Size=UDim2.fromOffset(12,12),BackgroundColor3=C.Knob,BorderSizePixel=0,Parent=tr}) corner(kn,6)
			local vl=mk("TextLabel",{Position=UDim2.fromOffset(184,y),Size=UDim2.fromOffset(26,14),BackgroundTransparency=1,Text=tostring(math.floor(init*255)),FontFace=FontMain,TextSize=11,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Right,Parent=panel})
			local dr=false local hit=mk("TextButton",{Position=UDim2.fromOffset(28,y-2),Size=UDim2.fromOffset(150,16),BackgroundTransparency=1,Text="",Parent=panel})
			local function upd(inp) local rx=math.clamp((inp.Position.X-tr.AbsolutePosition.X)/math.max(tr.AbsoluteSize.X,1),0,1) fl.Size=UDim2.fromScale(rx,1) kn.Position=UDim2.fromScale(rx,0.5) vl.Text=tostring(math.floor(rx*255)) setFn(rx) big.BackgroundColor3=Color3.new(r,g,b) end
			hit.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dr=true upd(inp) end end)
			UserInputService.InputChanged:Connect(function(inp) if dr and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then upd(inp) end end)
			UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dr=false end end)
			return function(rx) fl.Size=UDim2.fromScale(rx,1) kn.Position=UDim2.fromScale(rx,0.5) vl.Text=tostring(math.floor(rx*255)) end
		end
		local setR=chan("R",50,r,function(v) r=v apply() end)
		local setG=chan("G",72,g,function(v) g=v apply() end)
		local setB=chan("B",94,b,function(v) b=v apply() end)
		local entry={panel=panel,isOpen=false,closing=false,width=220,triggers={prev}}
		entry.closeFn=function(instant)
			if instant then panel.Visible=false panel.Size=UDim2.fromOffset(220,0) entry.closing=false
			else local t=TweenService:Create(panel,Tw.listIn,{Size=UDim2.fromOffset(220,0),BackgroundTransparency=1}) t:Play() t.Completed:Connect(function() if entry.closing then panel.Visible=false panel.BackgroundTransparency=0.06 entry.closing=false end end) end
		end
		prev.MouseButton1Click:Connect(function()
			play("click")
			if entry.isOpen then closeOne(entry,false) return end
			closeAll(true)
			local abs,sz=prev.AbsolutePosition,prev.AbsoluteSize
			panel.Position=UDim2.fromOffset(math.max(8,abs.X+sz.X-220),abs.Y+sz.Y+4) panel.Size=UDim2.fromOffset(220,0) panel.Visible=true panel.BackgroundTransparency=1
			entry.isOpen=true entry.closing=false table.insert(OpenPops,entry)
			TweenService:Create(panel,Tw.list,{Size=UDim2.fromOffset(220,120),BackgroundTransparency=0.06}):Play()
		end)
		return {Set=function(c) r,g,b=c.R,c.G,c.B setR(r) setG(g) setB(b) prev.BackgroundColor3=c big.BackgroundColor3=c if cb then cb(c) end end, Get=function() return Color3.new(r,g,b) end}
	end

	local function register(el,flag) if flag then table.insert(ConfigEls,{flag=flag,obj=el}) end end
	local function configPath(name) return ConfigFolder.."/"..safeName(name)..".json" end
	local function SaveCfg(name)
		name=safeName(name or "default")
		local d={}
		for _,e in ipairs(ConfigEls) do
			local v=e.obj.Get()
			if typeof(v)=="Color3" then d[e.flag]={R=v.R,G=v.G,B=v.B,__color=true}
			elseif typeof(v)=="EnumItem" then d[e.flag]={EnumType=tostring(v.EnumType),Name=v.Name,__enum=true}
			else d[e.flag]=v end
		end
		if writefile then
			pcall(function() if makefolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end end)
			writefile(configPath(name),HttpService:JSONEncode(d))
			Notify("Config","Saved \""..name.."\".",2.2) return true
		end
		Notify("Config","writefile missing.",2.5) return false
	end
	local function LoadCfg(name)
		name=safeName(name or "default")
		local path=configPath(name)
		if isfile and isfile(path) then
			local ok,d=pcall(function() return HttpService:JSONDecode(readfile(path)) end)
			if ok and type(d)=="table" then
				for _,e in ipairs(ConfigEls) do
					local v=d[e.flag]
					if v~=nil then
						if type(v)=="table" and v.__color then e.obj.Set(Color3.new(v.R,v.G,v.B))
						elseif type(v)=="table" and v.__enum then local et=Enum[v.EnumType]; if et and et[v.Name] then e.obj.Set(et[v.Name]) end
						else e.obj.Set(v) end
					end
				end
				Notify("Config","Loaded \""..name.."\".",2.2) return true
			end
		end
		Notify("Config","Not found \""..name.."\".",2.5) return false
	end
	local function ListConfigs()
		local list={}
		pcall(function()
			if not listfiles or not isfolder or not isfolder(ConfigFolder) then return end
			for _,path in ipairs(listfiles(ConfigFolder)) do
				local n=path:match("([^/\\]+)%.json$")
				if n then table.insert(list,n) end
			end
		end)
		table.sort(list) return list
	end
	local function DeleteCfg(name)
		name=safeName(name) local path=configPath(name)
		if isfile and isfile(path) and delfile then delfile(path) Notify("Config","Deleted \""..name.."\".",2.2) return true end
		Notify("Config","Could not delete \""..name.."\".",2.5) return false
	end


	local Window={}
	local TabBtns,TabFrms,CurTab={}, {}, nil
	local nextTab=0

	function Window:CreateTab(name,icon)
		nextTab+=1 local id=name:lower():gsub("%s+","_")
		local btn=mk("TextButton",{Name=name.."Btn",Size=UDim2.new(1,0,0,40),BackgroundColor3=C.AccentSoft,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=nextTab,ZIndex=3,Parent=TabScroll})
		corner(btn,20) local bst=stroke(btn,C.StrokeSoft,1,1)
		local ic=mk("ImageLabel",{Position=UDim2.fromOffset(10,9),Size=UDim2.fromOffset(20,20),BackgroundTransparency=1,Image=icon or "rbxassetid://10709751939",ImageColor3=C.TextDim,Parent=btn})
		local lbl=mk("TextLabel",{Position=UDim2.fromOffset(36,0),Size=UDim2.new(1,-44,1,0),BackgroundTransparency=1,Text=name,FontFace=FontMain,TextSize=14,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,Parent=btn})
		local under=mk("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,36,1,-4),Size=UDim2.fromOffset(0,2),BackgroundColor3=C.Line,BorderSizePixel=0,ZIndex=4,Parent=btn})
		corner(under,1)

		local function textW()
			local ok,sz=pcall(function() return TextService:GetTextSize(name,14,Enum.Font.GothamBold,Vector2.new(1000,40)) end)
			local w=(ok and sz.X or 40)+2
			local maxw=math.max(0,btn.AbsoluteSize.X-46)
			if maxw>0 then w=math.min(w,maxw) end
			return w
		end
		local function showUnder() TweenService:Create(under,Tw.soft,{Size=UDim2.fromOffset(textW(),2)}):Play() end
		local function hideUnder() if CurTab~=id then TweenService:Create(under,Tw.snap,{Size=UDim2.fromOffset(0,2)}):Play() end end

		btn.MouseEnter:Connect(function()
			if CurTab~=id then
				playHover()
				TweenService:Create(btn,Tw.snap,{BackgroundTransparency=0.75,BackgroundColor3=C.AccentSoft}):Play()
				TweenService:Create(bst,Tw.snap,{Transparency=0.25}):Play()
				TweenService:Create(lbl,Tw.snap,{TextColor3=C.Text}):Play()
				TweenService:Create(ic,Tw.snap,{ImageColor3=C.Text}):Play()
				showUnder()
			end
		end)
		btn.MouseLeave:Connect(function()
			if CurTab~=id then
				TweenService:Create(btn,Tw.soft,{BackgroundTransparency=1}):Play()
				TweenService:Create(bst,Tw.soft,{Transparency=1}):Play()
				TweenService:Create(lbl,Tw.soft,{TextColor3=C.TextDim}):Play()
				TweenService:Create(ic,Tw.soft,{ImageColor3=C.TextDim}):Play()
				hideUnder()
			end
		end)
		btn.MouseButton1Click:Connect(function()
			if CurTab==id then return end play("click")
			if CurTab then
				local p=TabBtns[CurTab]
				TweenService:Create(p.Btn,Tw.soft,{BackgroundTransparency=1}):Play()
				TweenService:Create(p.St,Tw.soft,{Transparency=1}):Play()
				TweenService:Create(p.Lbl,Tw.soft,{TextColor3=C.TextDim}):Play()
				TweenService:Create(p.Ic,Tw.soft,{ImageColor3=C.TextDim}):Play()
				TweenService:Create(p.Under,Tw.snap,{Size=UDim2.fromOffset(0,2)}):Play()
				TabFrms[CurTab].Visible=false
			end
			CurTab=id
			TweenService:Create(btn,Tw.soft,{BackgroundTransparency=0.15,BackgroundColor3=C.AccentSoft}):Play()
			TweenService:Create(bst,Tw.soft,{Transparency=0.2,Color=C.Accent}):Play()
			TweenService:Create(lbl,Tw.soft,{TextColor3=C.Accent}):Play()
			TweenService:Create(ic,Tw.soft,{ImageColor3=C.Accent}):Play()
			showUnder()
			TabFrms[id].Visible=true
		end)
		TabBtns[id]={Btn=btn,Lbl=lbl,Ic=ic,St=bst,Under=under}

		local frame=mk("ScrollingFrame",{Name=name.."Frame",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Stroke,ScrollBarImageTransparency=0.35,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false,ZIndex=1,Parent=Content})
		mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10),Parent=frame})
		pad(frame,PAD,PAD,PAD,PAD)
		TabFrms[id]=frame

		if nextTab==1 then
			task.defer(function()
				CurTab=id btn.BackgroundTransparency=0.2 bst.Transparency=0.1 bst.Color=C.Stroke lbl.TextColor3=C.Text ic.ImageColor3=C.Line frame.Visible=true showUnder()
			end)
		end

		local function buildContainer(container, host)
			local nextO=0
			function host:CreateSection(t) nextO+=1 section(container,t,nextO) return host end
			function host:CreateLabel(t) nextO+=1 local el=label(container,t,nextO) return el end
			function host:CreateToggle(o) o=o or {} nextO+=1 local el=toggle(container,o.Title or "Toggle",o.Description or "",o.Default or false,nextO,o.Callback) register(el,o.Flag) return el end
			function host:CreateSlider(o) o=o or {} nextO+=1 local el=slider(container,o.Title or "Slider",o.Min or 0,o.Max or 100,o.Default or 0,nextO,o.Callback) register(el,o.Flag) return el end
			function host:CreateButton(o) o=o or {} nextO+=1 button(container,o.Title or "Button",nextO,o.Callback) return host end
			function host:CreateTextbox(o) o=o or {} nextO+=1 local el=textbox(container,o.Title or "Textbox",o.Default or "",nextO,o.Callback) register(el,o.Flag) return el end
			function host:CreateKeybind(o) o=o or {} nextO+=1 local el=keybind(container,o.Title or "Keybind",o.Default or Enum.KeyCode.P,nextO,o.Callback) register(el,o.Flag) return el end
			function host:CreateDropdown(o) o=o or {} nextO+=1 local el=dropdown(container,o.Title or "Dropdown",o.Options or {},o.Default,nextO,o.Callback) register(el,o.Flag) return el end
			function host:CreateColorPicker(o) o=o or {} nextO+=1 local el=colorpicker(container,o.Title or "Color",o.Default or Color3.fromRGB(160,160,170),nextO,o.Callback) register(el,o.Flag) return el end
		end

		local Tab={}
		buildContainer(frame,Tab)

		function Tab:CreateGroup(o)
			o=o or {}
			local g=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.Panel,BackgroundTransparency=0.14,BorderSizePixel=0,LayoutOrder=#frame:GetChildren()+1,Parent=frame})
			corner(g,18) stroke(g,C.StrokeSoft,1,0.1)

			local headBtn=mk("TextButton",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=1,Parent=g})
			pad(headBtn,12,12,12,12)

			local headLeft=mk("Frame",{Size=UDim2.new(1,-28,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=headBtn})
			mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4),Parent=headLeft})
			mk("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=o.Title or "Group",FontFace=FontMain,TextSize=16,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,Parent=headLeft})
			if o.Description and o.Description~="" then
				mk("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=o.Description,FontFace=FontMain,TextSize=12,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LayoutOrder=2,Parent=headLeft})
			end

			local chev=mk("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(20,20),BackgroundTransparency=1,Parent=headBtn})
			local ch1=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.35,0,0.5,0),Size=UDim2.fromOffset(8,2),Rotation=45,BackgroundColor3=C.TextDim,BorderSizePixel=0,Parent=chev})
			local ch2=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.65,0,0.5,0),Size=UDim2.fromOffset(8,2),Rotation=-45,BackgroundColor3=C.TextDim,BorderSizePixel=0,Parent=chev})
			corner(ch1,1) corner(ch2,1)

			local sep=mk("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.fromOffset(12,0),BackgroundColor3=C.StrokeSoft,BackgroundTransparency=0.25,BorderSizePixel=0,LayoutOrder=2,Parent=g})

			local bodyWrap=mk("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,ClipsDescendants=true,LayoutOrder=3,Parent=g})
			local body=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=bodyWrap})
			pad(body,12,12,12,12)
			mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),Parent=body})

			local gLayout=mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0),Parent=g})

			local open = o.DefaultOpen ~= false
			local animating=false

			local function getBodyH()
				local h=0
				for _,ch in ipairs(body:GetChildren()) do
					if ch:IsA("GuiObject") and ch.Visible then
						h = math.max(h, ch.AbsolutePosition.Y - body.AbsolutePosition.Y + ch.AbsoluteSize.Y)
					end
				end
				return math.max(0,h+12)
			end

			local function applyState(inst)
				if open then
					sep.BackgroundTransparency=0.25
					chev.Rotation=0
					bodyWrap.Size=UDim2.new(1,0,0,getBodyH())
				else
					sep.BackgroundTransparency=1
					chev.Rotation=-90
					bodyWrap.Size=UDim2.new(1,0,0,0)
				end
				animating=false
			end

			local function setOpen(v,instant)
				open=v
				if instant then applyState() return end
				animating=true
				local target=open and getBodyH() or 0
				TweenService:Create(chev,Tw.group,{Rotation=open and 0 or -90}):Play() TweenService:Create(ch1,Tw.group,{BackgroundColor3=open and C.TextDim or C.TextMuted}):Play() TweenService:Create(ch2,Tw.group,{BackgroundColor3=open and C.TextDim or C.TextMuted}):Play()
				TweenService:Create(sep,Tw.group,{BackgroundTransparency=open and 0.25 or 1}):Play()
				local tw=TweenService:Create(bodyWrap,Tw.group,{Size=UDim2.new(1,0,0,target)})
				tw:Play()
				tw.Completed:Connect(function() animating=false if open then bodyWrap.Size=UDim2.new(1,0,0,getBodyH()) end end)
			end

			body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if open and not animating then
					bodyWrap.Size=UDim2.new(1,0,0,getBodyH())
				end
			end)

			headBtn.MouseEnter:Connect(function() playHover() TweenService:Create(g,Tw.snap,{BackgroundTransparency=0.12}):Play() end)
			headBtn.MouseLeave:Connect(function() TweenService:Create(g,Tw.soft,{BackgroundTransparency=0.18}):Play() end)
			headBtn.MouseButton1Click:Connect(function() play("click") setOpen(not open,false) end)

			task.defer(function() applyState(true) end)

			local Group={}
			buildContainer(body,Group)
			function Group:SetOpen(v) setOpen(v,false) end
			function Group:GetOpen() return open end
			return Group
		end


		function Tab:CreateConfigManager(o)
			o=o or {}
			local outer=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.Panel,BackgroundTransparency=0.14,BorderSizePixel=0,Parent=frame})
			corner(outer,18) stroke(outer,C.StrokeSoft,1,0.1)
			local body=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=outer})
			pad(body,14,14,14,14)
			mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10),Parent=body})

			local head=mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=0,Parent=body})
			mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2),Parent=head})
			mk("TextLabel",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=o.Title or "Config Manager",FontFace=FontMain,TextSize=17,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,Parent=head})
			mk("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=o.Description or "Сохраняй, загружай и управляй конфигами без боли.",FontFace=FontMain,TextSize=12,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LayoutOrder=2,Parent=head})

			mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.StrokeSoft,BackgroundTransparency=0.25,BorderSizePixel=0,LayoutOrder=1,Parent=body})

			local nameRow=mk("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,LayoutOrder=2,Parent=body})
			mk("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text="Config name",FontFace=FontMain,TextSize=13,TextColor3=C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,Parent=nameRow})
			local nf=mk("Frame",{Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,32),BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.2,BorderSizePixel=0,Parent=nameRow})
			corner(nf,12) local nfst=stroke(nf,C.Stroke,1,0.15)
			local nameBox=mk("TextBox",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text=safeName(o.Default or "Main"),PlaceholderText="Type config name...",PlaceholderColor3=C.TextMuted,TextColor3=C.Text,FontFace=FontMain,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=nf})
			nameBox.Focused:Connect(function() TweenService:Create(nfst,Tw.snap,{Color=C.Accent,Transparency=0}):Play() end)
			nameBox.FocusLost:Connect(function() TweenService:Create(nfst,Tw.soft,{Color=C.StrokeSoft,Transparency=0.15}):Play() end)

			local actions=mk("Frame",{Size=UDim2.new(1,0,0,78),BackgroundTransparency=1,LayoutOrder=3,Parent=body})
			mk("UIGridLayout",{CellSize=UDim2.new(0.5,-5,0,34),CellPadding=UDim2.fromOffset(10,10),SortOrder=Enum.SortOrder.LayoutOrder,Parent=actions})

			local function mkAct(txt,ord,col)
				local b=mk("TextButton",{BackgroundColor3=C.Button,BackgroundTransparency=0.05,BorderSizePixel=0,Text=txt,FontFace=FontMain,TextSize=13,TextColor3=col or C.Text,AutoButtonColor=false,LayoutOrder=ord,Parent=actions})
				corner(b,16) local st=stroke(b,C.StrokeSoft,1,0.1)
				b.MouseEnter:Connect(function() playHover() TweenService:Create(b,Tw.snap,{BackgroundColor3=C.ButtonHover,BackgroundTransparency=0.04}):Play() TweenService:Create(st,Tw.snap,{Color=C.Stroke,Transparency=0}):Play() end)
				b.MouseLeave:Connect(function() TweenService:Create(b,Tw.soft,{BackgroundColor3=C.Button,BackgroundTransparency=0.12}):Play() TweenService:Create(st,Tw.soft,{Color=C.StrokeSoft,Transparency=0.15}):Play() end)
				return b
			end
			local saveB=mkAct("Save",1,C.Good)
			local loadB=mkAct("Load",2,C.Text)
			local delB=mkAct("Delete",3,C.Bad)
			local refB=mkAct("Refresh",4,C.TextDim)

			local listWrap=mk("Frame",{Size=UDim2.new(1,0,0,180),BackgroundColor3=C.PanelAlt,BackgroundTransparency=0.18,BorderSizePixel=0,LayoutOrder=4,Parent=body})
			corner(listWrap,14) stroke(listWrap,C.StrokeSoft,1,0.12)
			local listHdr=mk("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,Parent=listWrap})
			mk("TextLabel",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,Text="Saved configs",FontFace=FontMain,TextSize=12,TextColor3=C.TextMuted,TextXAlignment=Enum.TextXAlignment.Left,Parent=listHdr})
			mk("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,0),Size=UDim2.new(1,-20,0,1),BackgroundColor3=C.StrokeSoft,BackgroundTransparency=0.3,BorderSizePixel=0,Parent=listHdr})

			local list=mk("ScrollingFrame",{Position=UDim2.fromOffset(8,40),Size=UDim2.new(1,-16,1,-48),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=C.Stroke,ScrollBarImageTransparency=0.35,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,Parent=listWrap})
			mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),Parent=list})

			local selected=safeName(nameBox.Text)
			local function refresh()
				for _,c in ipairs(list:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
				local names=ListConfigs()
				if #names==0 then
					local empty=mk("Frame",{Size=UDim2.new(1,-2,0,52),BackgroundColor3=C.Button,BackgroundTransparency=0.25,BorderSizePixel=0,Parent=list})
					corner(empty,12) stroke(empty,C.StrokeSoft,1,0.2)
					mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="No configs yet",FontFace=FontMain,TextSize=12,TextColor3=C.TextMuted,Parent=empty})
					return
				end
				for i,n in ipairs(names) do
					local active=(n==selected)
					local it=mk("TextButton",{Size=UDim2.new(1,-2,0,40),BackgroundColor3=active and C.AccentSoft or C.Button,BackgroundTransparency=active and 0.15 or 0.2,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=i,Parent=list})
					corner(it,12) local st=stroke(it,active and C.Accent or C.StrokeSoft,1,active and 0.15 or 0.18)
					local dot=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),Size=UDim2.fromOffset(6,6),BackgroundColor3=active and C.Good or C.TextMuted,BackgroundTransparency=active and 0 or 0.4,BorderSizePixel=0,Parent=it})
					corner(dot,99)
					mk("TextLabel",{Position=UDim2.fromOffset(24,0),Size=UDim2.new(1,-34,1,0),BackgroundTransparency=1,Text=n,FontFace=FontMain,TextSize=13,TextColor3=active and C.Text or C.TextDim,TextXAlignment=Enum.TextXAlignment.Left,Parent=it})
					it.MouseEnter:Connect(function() if selected~=n then TweenService:Create(it,Tw.snap,{BackgroundTransparency=0.1,BackgroundColor3=C.ButtonHover}):Play() TweenService:Create(st,Tw.snap,{Color=C.Stroke,Transparency=0.08}):Play() end end)
					it.MouseLeave:Connect(function() if selected~=n then TweenService:Create(it,Tw.soft,{BackgroundTransparency=0.2,BackgroundColor3=C.Button}):Play() TweenService:Create(st,Tw.soft,{Color=C.StrokeSoft,Transparency=0.2}):Play() end end)
					it.MouseButton1Click:Connect(function() play("click") selected=n nameBox.Text=n refresh() end)
				end
			end

			saveB.MouseButton1Click:Connect(function() play("click") local n=safeName(nameBox.Text) if n=="" then n="default" end selected=n SaveCfg(n) refresh() end)
			loadB.MouseButton1Click:Connect(function() play("click") local n=safeName(nameBox.Text) if n=="" then n=selected end if n~="" then LoadCfg(n) end end)
			delB.MouseButton1Click:Connect(function() play("click") local n=safeName(nameBox.Text) if n=="" then n=selected end if n~="" then DeleteCfg(n) if selected==n then selected="" end refresh() end end)
			refB.MouseButton1Click:Connect(function() play("click") refresh() Notify("Config","List refreshed.",1.5) end)

			refresh()
			return {Refresh=refresh, GetName=function() return nameBox.Text end, SetName=function(v) nameBox.Text=tostring(v or "") selected=safeName(nameBox.Text) refresh() end}
		end

		function Tab:CreateConfigList(o) return self:CreateConfigManager(o) end

		return Tab
	end

	function Window:Notify(t,txt,d) Notify(t,txt,d) end
	function Window:SaveConfig(name) SaveCfg(name) end
	function Window:LoadConfig(name) return LoadCfg(name) end
	function Window:ListConfigs() return ListConfigs() end
	function Window:DeleteConfig(name) return DeleteCfg(name) end
	function Window:Toggle() Toggle() end
	function Window:Destroy() ScreenGui:Destroy() end

	return Window
end

return Library
