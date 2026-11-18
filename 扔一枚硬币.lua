
	local OBSIDIAN_REPO = "https://gitlab.com/aristooey/Obsidian/-/raw/main/"

	local OkLoad, Library = pcall(function()
		return loadstring(game:HttpGet(OBSIDIAN_REPO .. "Library.lua"))()
	end)

	if not OkLoad or type(Library) ~= "table" or type(Library.CreateWindow) ~= "function" then
		return
	end

	local ThemeManager = select(2, pcall(function()
		return loadstring(game:HttpGet(OBSIDIAN_REPO .. "addons/ThemeManager.lua"))()
	end))
	local SaveManager = select(2, pcall(function()
		return loadstring(game:HttpGet(OBSIDIAN_REPO .. "addons/SaveManager.lua"))()
	end))

	Library.ThemeManager = ThemeManager
	Library.SaveManager = SaveManager

local function XJWCompat(Lib)
	local Compat = {}
	local seq = 0

	local function nextId(prefix)
		seq = seq + 1
		return "XJW" .. prefix .. seq
	end

	local function call(fn)
		local ok, res = pcall(fn)
		if ok then return res end
		return nil
	end

	local function phantom()
		local t = setmetatable({}, {
			__index = function(self, k)
				local v = phantom()
				rawset(self, k, v)
				return v
			end,
			__newindex = function() end,
		})
		return t
	end

	local function stub()
		local s = setmetatable({}, {
			__index = function(t, k)
				local f = function() return t end
				rawset(t, k, f)
				return f
			end,
		})
		return s
	end

	local function toBool(v)
		if v == true then return true end
		if type(v) == "number" then return v ~= 0 end
		if type(v) == "string" then return v == "true" or v == "1" end
		return false
	end

	local function wrap(ctrl)
		if type(ctrl) ~= "table" then return ctrl end
		if not ctrl.__xjwWrapped then
			ctrl.__xjwWrapped = true
			if type(ctrl.Set) ~= "function" and type(ctrl.SetValue) == "function" then
				ctrl.Set = function(_self, v) return ctrl:SetValue(v) end
			end
			if type(ctrl.SetValues) ~= "function" and type(ctrl.SetValue) == "function" then
				ctrl.SetValues = function(_self, v) return ctrl:SetValue(v) end
			end
			if type(ctrl.Get) ~= "function" then
				ctrl.Get = function() return ctrl.Value end
			end
		end
		return ctrl
	end

	local makeContainer

	makeContainer = function(real, isTab)
		local box = {}
		local implicit = nil
		local activeReal = nil
		local sectionSeq = 0

		local function target()
			if not real then return nil end
			if isTab then
				if activeReal then return activeReal end
				if implicit then return implicit end
				implicit = call(function() return real:AddLeftGroupbox("") end)
				if not implicit then implicit = call(function() return real:AddRightGroupbox("") end) end
				return implicit
			end
			return real
		end

		local function build(method, primary, fallback, idx)
			local function attempt(info)
				if not info then return nil end
				local t = target()
				if not t then return nil end
				local fn = t[method]
				if type(fn) ~= "function" then return nil end
				local key = idx
				if key == nil or key == "" then key = nextId(method) end
				return call(function() return fn(t, key, info) end)
			end
			local ctrl = attempt(primary)
			if not ctrl then ctrl = attempt(fallback) end
			return wrap(ctrl)
		end

		function box:Section(info)
			local title, icon = "", nil
			if type(info) == "table" then
				title = info.Title or info.Name or ""
				icon = info.Icon
			elseif info ~= nil then
				title = tostring(info)
			end
			if not isTab or not real then return box end
			sectionSeq = sectionSeq + 1
			local gb
			if sectionSeq % 2 == 1 then
				gb = call(function() return real:AddLeftGroupbox(tostring(title), icon) end)
				if not gb then gb = call(function() return real:AddRightGroupbox(tostring(title), icon) end) end
			else
				gb = call(function() return real:AddRightGroupbox(tostring(title), icon) end)
				if not gb then gb = call(function() return real:AddLeftGroupbox(tostring(title), icon) end) end
			end
			if not gb then gb = call(function() return real:AddLeftGroupbox(tostring(title)) end) end
			if not gb then return box end
			activeReal = gb
			return makeContainer(gb, false)
		end

		function box:AddLeftGroupbox(name, icon)
			if not isTab or not real then return box end
			local gb = call(function() return real:AddLeftGroupbox(tostring(name or ""), icon) end)
			if not gb then gb = call(function() return real:AddRightGroupbox(tostring(name or ""), icon) end) end
			if not gb then return box end
			activeReal = gb
			return makeContainer(gb, false)
		end

		function box:AddRightGroupbox(name, icon)
			if not isTab or not real then return box end
			local gb = call(function() return real:AddRightGroupbox(tostring(name or ""), icon) end)
			if not gb then gb = call(function() return real:AddLeftGroupbox(tostring(name or ""), icon) end) end
			if not gb then return box end
			activeReal = gb
			return makeContainer(gb, false)
		end

		function box:Toggle(info)
			if type(info) ~= "table" then info = { Title = tostring(info) } end
			local text = tostring(info.Title or info.Text or info.Name or "开关")
			local def = info.Default
			if def == nil then def = info.Value end
			local cb = info.Callback or info.Changed
			local tip = info.Desc or info.Description
			return build("AddToggle",
				{ Text = text, Default = toBool(def), Callback = cb, Tooltip = tip },
				{ Text = text, Default = toBool(def), Callback = cb })
		end

		function box:Slider(info)
			if type(info) ~= "table" then info = { Title = tostring(info) } end
			local min = tonumber(info.Min) or 0
			local max = tonumber(info.Max) or 100
			local def = info.Default
			if def == nil then def = info.Value end
			if type(def) == "table" then
				min = tonumber(def.Min) or min
				max = tonumber(def.Max) or max
				def = def.Default
			end
			if max < min then min, max = max, min end
			def = math.clamp(tonumber(def) or min, min, max)
			local step = tonumber(info.Step)
			local rounding = 0
			if step and step > 0 and step < 1 then
				rounding = math.max(0, math.ceil(-math.log10(step) - 0.0000001))
			end
			local text = tostring(info.Title or info.Text or "滑块")
			local cb = info.Callback or info.Changed
			return build("AddSlider",
				{ Text = text, Default = def, Min = min, Max = max, Rounding = rounding, Suffix = info.Suffix, Prefix = info.Prefix, Callback = cb, Tooltip = info.Desc },
				{ Text = text, Default = def, Min = min, Max = max, Callback = cb })
		end

		function box:Dropdown(info)
			if type(info) ~= "table" then info = { Values = {} } end
			local values = info.Values or info.Options or {}
			local def = info.Default
			if def == nil then def = info.Value end
			local multi = info.Multi == true
			if multi and type(def) ~= "table" then
				def = nil
			end
			local text = tostring(info.Title or info.Text or "选择")
			local cb = info.Callback or info.Changed
			local ctrl = build("AddDropdown",
				{ Text = text, Values = values, Multi = multi, Callback = cb, Tooltip = info.Desc },
				{ Text = text, Values = values, Multi = multi },
				text)
			if ctrl and def ~= nil and type(ctrl.SetValue) == "function" then
				task.defer(function()
					pcall(function() ctrl:SetValue(def) end)
				end)
			end
			return ctrl
		end

		function box:Button(info)
			if type(info) ~= "table" then info = { Title = tostring(info) } end
			local text = tostring(info.Title or info.Text or "按钮")
			local cb = info.Callback or info.Func
			local t = target()
			if not t then return wrap(nil) end

			local ctrl = call(function() return t:AddButton({ Text = text, Func = cb, DoubleClick = info.DoubleClick }) end)
			if not ctrl then
				ctrl = call(function() return t:AddButton(nextId("AddButton"), { Text = text, Func = cb }) end)
			end
			return wrap(ctrl)
		end

		function box:Input(info)
			if type(info) ~= "table" then info = { Title = tostring(info) } end
			local def = info.Default
			if def == nil then def = info.Value end
			local text = tostring(info.Title or info.Text or "输入")
			return build("AddInput",
				{ Text = text, Default = def == nil and "" or tostring(def), Placeholder = info.Placeholder and tostring(info.Placeholder) or "", Callback = info.Callback },
				{ Text = text, Default = def == nil and "" or tostring(def) })
		end

		function box:Paragraph(info)
			local text = ""
			if type(info) == "table" then
				local head = info.Title or info.Text or ""
				local tail = info.Desc or info.Description or ""
				text = tostring(head)
				if tail ~= "" then text = text .. "  " .. tostring(tail) end
			elseif info ~= nil then
				text = tostring(info)
			end
			local t = target()
			if t and type(t.AddLabel) == "function" then
				call(function() return t:AddLabel(text) end)
			end
			return nil
		end

		function box:Label(info)
			return box:Paragraph(info)
		end

		function box:Divider()
			local t = target()
			if t and type(t.AddDivider) == "function" then
				call(function() return t:AddDivider() end)
			end
			return nil
		end

		function box:Keybind(info)
			if type(info) ~= "table" then info = { Title = tostring(info) } end
			local def = info.Default
			if def == nil then def = info.Value end
			return build("AddKeyPicker",
				{ Text = tostring(info.Title or "按键"), Mode = info.Mode, Default = def, Callback = info.Callback, ChangedCallback = info.Changed },
				{ Text = tostring(info.Title or "按键") })
		end

		function box:ColorPicker(info)
			return stub()
		end

		function box:Textbox(info)
			return box:Input(info)
		end

		return box
	end

	function Compat:CreateWindow(opt)
		opt = opt or {}
		local win = call(function()
			return Lib:CreateWindow({
				Title = tostring(opt.Title or "XJW"),
				Footer = tostring(opt.Author or opt.Footer or "XJW"),
			})
		end)

		if not win then
			pcall(function() Lib:Notify("窗口创建失败, 请重新执行脚本", 5) end)
		end

		if win then
			local usedTabs = {}
			local rawAddTab = win.AddTab
			if type(rawAddTab) == "function" then
				pcall(function()
					win.AddTab = function(self, ...)
						local first = select(1, ...)
						local name = first
						if type(first) == "table" then name = first.Name or first.Title end
						if name ~= nil then usedTabs[tostring(name)] = true end
						return rawAddTab(self, ...)
					end
				end)
			end

			task.defer(function()
				pcall(function()
					local SettingsName = "UI设置"
					if usedTabs[SettingsName] then SettingsName = "设置" end
					local SettingsTab = win:AddTab(SettingsName, "settings")
local MenuGroup = SettingsTab:AddLeftGroupbox("菜单")

local LastUnloadAt

MenuGroup:AddButton("卸载脚本", function()
	local function DoUnload()
		task.defer(function()
			pcall(function()
				Lib:Unload()
			end)
		end)
	end

	local OkDialog = pcall(function()
		win:AddDialog("XJWUnloadConfirm", {
			Title = "卸载脚本",
			Description = "确定要卸载脚本吗？所有已启用的功能将被关闭，脚本随即终止。",
			AutoDismiss = false,
			OutsideClickDismiss = false,
			FooterButtons = {
				Cancel = {
					Title = "取消",
					Variant = "Ghost",
					Order = 1,
					Callback = function(Dialog)
						Dialog:Dismiss()
					end,
				},
				Unload = {
					Title = "卸载",
					Variant = "Destructive",
					Order = 2,
					Callback = function(Dialog)
						Dialog:Dismiss()
						DoUnload()
					end,
				},
			},
		})
	end)

	if OkDialog then
		return
	end

	if not LastUnloadAt or (os.clock() - LastUnloadAt) > 5 then
		LastUnloadAt = os.clock()
		pcall(function()
			Lib:Notify("再次点击「卸载脚本」确认卸载，5 秒内有效")
		end)
		return
	end

	LastUnloadAt = nil
	DoUnload()
end)

MenuGroup:AddLabel("菜单快捷键")
MenuGroup:AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	Visible = false,
	Text = "菜单快捷键",
})

Lib.ToggleKeybind = Lib.Options and Lib.Options.MenuKeybind

local ThemeManager = Lib.ThemeManager
local SaveManager = Lib.SaveManager

if type(ThemeManager) == "table" then
	ThemeManager:SetLibrary(Lib)
	ThemeManager:SetFolder("XJWUITheme")
	ThemeManager:ApplyToTab(SettingsTab)
end

if type(SaveManager) == "table" then
	SaveManager:SetLibrary(Lib)
	SaveManager:SetFolder("XJWUIConfig")
	SaveManager:BuildConfigSection(SettingsTab)
end

				end)
			end)
		end


		local proxy = {}
		proxy.IsPC = false
		proxy.Window = win
		proxy.OnClose = opt.OnClose
		proxy.OnOpen = opt.OnOpen

		function proxy:Tab(info)
			local title, icon = "页面", nil
			if type(info) == "table" then
				title = info.Title or info.Name or "页面"
				icon = info.Icon or info.IconName
			elseif info ~= nil then
				title = tostring(info)
			end
			if not win then return makeContainer(nil, false) end
			local tab = call(function() return win:AddTab(tostring(title), icon, "") end)
			if not tab then tab = call(function() return win:AddTab(tostring(title)) end) end
			if not tab then tab = call(function() return win:AddTab({ Name = tostring(title), Icon = icon }) end) end
			return makeContainer(tab, true)
		end

		function proxy:Tag()
			return stub()
		end

		function proxy:EditOpenButton()
			return stub()
		end

		function proxy:Dialog()
			return stub()
		end

		function proxy:SelectTab()
		end

		function proxy:SetTheme()
		end

		function proxy:SetBackground()
		end

		function proxy:SetUIScale(v)
			pcall(function()
				Lib.UIScale = v
				if type(Lib.ApplyUIScale) == "function" then Lib:ApplyUIScale(v) end
			end)
		end

		function proxy:SetScale(v)
			proxy:SetUIScale(v)
		end
	function proxy:AddDialog(idx, info)
		if not win then return stub() end
		local d = call(function() return win:AddDialog(idx, info) end)
		if d == nil then return stub() end
		return d
	end

	function proxy:Toggle(v)
		if not win then return end
		return call(function() return win:Toggle(v) end)
	end

	function proxy:Show()
		return proxy:Toggle(true)
	end

	function proxy:Hide()
		return proxy:Toggle(false)
	end

	function proxy:Destroy()
		if not win then return end
		return call(function() return win:Destroy() end)
	end

	proxy.UIElements = proxy.UIElements or phantom()

	function proxy:Notify(info)
		return Compat:Notify(info)
	end

	function proxy:SetWatermark() end

	function proxy:SetToggleKey() end

	function proxy:SetNotification() end

		function proxy:SetTitle()
		end

		function proxy:Toggle(v)
			if v == false then
				proxy:Close()
			else
				proxy:Open()
			end
		end

		function proxy:Open()
			if win and type(win.Toggle) == "function" then
				call(function() win:Toggle(true) end)
			else
				call(function() Lib:Toggle(true) end)
			end
			if type(proxy.OnOpen) == "function" then pcall(proxy.OnOpen) end
		end

		function proxy:Close()
			if win and type(win.Toggle) == "function" then
				call(function() win:Toggle(false) end)
			else
				call(function() Lib:Toggle(false) end)
			end
			if type(proxy.OnClose) == "function" then pcall(proxy.OnClose) end
		end

		function proxy:Destroy()
			if type(proxy.OnClose) == "function" then pcall(proxy.OnClose) end
			call(function() Lib:Unload() end)
		end

		function proxy:Unload()
			proxy:Destroy()
		end

		return proxy
	end

	function Compat:Notify(info)
		if type(info) ~= "table" then info = { Content = tostring(info) } end
		local title = tostring(info.Title or info.Name or "提示")
		local desc = tostring(info.Content or info.Description or info.Desc or info.Text or "")
		local time = tonumber(info.Duration or info.Time or 4) or 4
		local ok = pcall(function()
			Lib:Notify({ Title = title, Description = desc, Time = time })
		end)
		if not ok then
			pcall(function() Lib:Notify(title .. ": " .. desc) end)
		end
	end

	function Compat:Unload()
		call(function() Lib:Unload() end)
	end

	function Compat:SetTheme()
	end

	function Compat:SetColorScheme()
	end

	function Compat:SetUIScale()
	end

	Compat.Themes = setmetatable({}, { __index = function() return nil end })
	Compat.Scheme = Lib.Scheme
	Compat.Library = Lib
	return Compat
end

local WI = XJWCompat(Library)

local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local C = game:GetService("CoreGui")
local LP = P.LocalPlayer
if not LP then return end

for _, g in ipairs(C:GetChildren()) do
    if g:IsA("ScreenGui") and (g.Name == "A" or g.Name:find("Coin") or g.Name == "WindUI") then
        pcall(function() g:Destroy() end)
    end
end

local Events = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Events")
local CoinLanded = Events and Events:FindFirstChild("CoinLanded")
local RequestUpgrade = Events and Events:FindFirstChild("RequestUpgrade")
local BuyCoin = Events and Events:FindFirstChild("BuyCoin")
local SellAll = Events and Events:FindFirstChild("SellAll")

local S = {
    AutoThrow = false, AutoBuyCoin = false, AutoUpgradeLuck = false,
    AutoUpgradeValue = false, AutoSell = false, Speed = false, Fly = false,
    ThrowMultiplier = 3, SpeedVal = 50, FlySpeed = 50
}

local WN, WN_visible = nil, false
local UI = {}
local toggleKey = Enum.KeyCode.F4
local toggleLock = 0
local coinDebounce, sellDebounce, luckDebounce, valDebounce = 0, 0, 0, 0
local flyBV2, flyGyro2, flyCtrl, flyHeartbeat2 = nil, nil, nil, nil
local coinList = {"Paradox Coin", "Lucky Coin", "Golden Coin", "Obsidian Coin", "Platinum Coin", "Ruby Coin", "Emerald Coin", "Amethyst Coin", "Topaz Coin", "Diamond Coin", "Staff Token", "VIP Token", "Developer Token", "Diamond Token"}

local function flipToggle(flag)
    S[flag] = not S[flag]
    if UI[flag] and type(UI[flag].Set) == "function" then pcall(function() UI[flag]:Set(S[flag]) end) end
    return S[flag]
end

local function getCoinName()
    local pg = LP:FindFirstChild("PlayerGui")
    local n = pg and pg:FindFirstChild("UiFolder") and pg.UiFolder:FindFirstChild("Main")
        and pg.UiFolder.Main:FindFirstChild("HUD") and pg.UiFolder.Main.HUD:FindFirstChild("Coin")
        and pg.UiFolder.Main.HUD.Coin:FindFirstChild("Main") and pg.UiFolder.Main.HUD.Coin.Main:FindFirstChild("CoinName")
    if n and n:IsA("TextLabel") and n.Text ~= "" then return n.Text end
    return nil
end

local function getMultiplier()
    local pg = LP:FindFirstChild("PlayerGui")
    local tb = pg and pg:FindFirstChild("UiFolder") and pg.UiFolder:FindFirstChild("Main")
        and pg.UiFolder.Main:FindFirstChild("HUD") and pg.UiFolder.Main.HUD:FindFirstChild("ThrowBar")
        and pg.UiFolder.Main.HUD.ThrowBar:FindFirstChild("CurrentMulti")
    if tb and tb:IsA("Frame") then return tb.Size.X.Scale * 3 end
    return 0
end

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function formatNum(v)
    if v == math.floor(v) then return tostring(math.floor(v)) end
    return string.format("%.1f", v)
end

local function doThrow()
    if not S.AutoThrow or not CoinLanded then return end
    if getMultiplier() < S.ThrowMultiplier then return end
    local coinName = getCoinName()
    if not coinName then return end
    local hrp = getHRP()
    if not hrp then return end
    local pos = hrp.Position + Vector3.new(0, -0.5, -2)
    CoinLanded:FireServer(S.ThrowMultiplier, pos, coinName, nil, nil)
    task.wait(0.5)
end

local function doBuyCoin()
    if not S.AutoBuyCoin or not BuyCoin then return end
    if tick() - coinDebounce < 3 then return end
    if getCoinName() then return end
    coinDebounce = tick()
    for _, name in ipairs(coinList) do
        pcall(function() BuyCoin:FireServer(name) end)
        task.wait(0.1)
    end
end

local function doUpgradeLuck()
    if not S.AutoUpgradeLuck or not RequestUpgrade then return end
    if tick() - luckDebounce < 1 then return end
    luckDebounce = tick()
    pcall(function() RequestUpgrade:FireServer("Luck Multiplier") end)
end

local function doUpgradeValue()
    if not S.AutoUpgradeValue or not RequestUpgrade then return end
    if tick() - valDebounce < 1 then return end
    valDebounce = tick()
    pcall(function() RequestUpgrade:FireServer("Value Multiplier") end)
end

local function doSell()
    if not S.AutoSell or not SellAll then return end
    if tick() - sellDebounce < 2 then return end
    sellDebounce = tick()
    SellAll:FireServer()
end

local function toggleFly(on)
    if flyHeartbeat2 then flyHeartbeat2:Disconnect(); flyHeartbeat2 = nil end
    if flyBV2 then flyBV2:Destroy(); flyBV2 = nil end
    if flyGyro2 then flyGyro2:Destroy(); flyGyro2 = nil end
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if on then
        h.PlatformStand = true
        flyCtrl = {f = 0, b = 0, l = 0, r = 0}
        local torso = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        if not torso then return end
        flyGyro2 = Instance.new("BodyGyro", torso)
        flyGyro2.P = 9e4
        flyGyro2.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro2.CFrame = workspace.CurrentCamera.CoordinateFrame
        flyBV2 = Instance.new("BodyVelocity", torso)
        flyBV2.Velocity = Vector3.new(0, 0.1, 0)
        flyBV2.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local speed = 0
        flyHeartbeat2 = game:GetService("RunService").RenderStepped:Connect(function()
            if not S.Fly or not LP.Character then return end
            flyCtrl = {f = 0, b = 0, l = 0, r = 0}
            if UIS:IsKeyDown(Enum.KeyCode.W) then flyCtrl.f = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then flyCtrl.b = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then flyCtrl.l = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then flyCtrl.r = 1 end
            local v = (flyCtrl.f + flyCtrl.b)
            local h2 = (flyCtrl.l + flyCtrl.r)
            local ms = S.FlySpeed
            if v ~= 0 or h2 ~= 0 then
                speed = speed + 0.5 + (speed / ms)
                if speed > ms then speed = ms end
            elseif speed ~= 0 then
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end
            local cf = workspace.CurrentCamera.CoordinateFrame
            if v ~= 0 or h2 ~= 0 then
                flyBV2.Velocity = (cf.LookVector * v + ((cf * CFrame.new(h2, v * 0.2, 0).p) - cf.p)) * speed
            elseif speed ~= 0 then
                flyBV2.Velocity = (cf.LookVector * (flyCtrl.f + flyCtrl.b) + ((cf * CFrame.new(flyCtrl.l + flyCtrl.r, (flyCtrl.f + flyCtrl.b) * 0.2, 0).p) - cf.p)) * speed
            else
                flyBV2.Velocity = Vector3.new(0, 0, 0)
            end
            flyGyro2.CFrame = cf * CFrame.Angles(-math.rad(v * 50 * speed / ms), 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                local hr = c:FindFirstChild("HumanoidRootPart")
                if hr then hr.CFrame = hr.CFrame * CFrame.new(0, 1, 0) end
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                local hr = c:FindFirstChild("HumanoidRootPart")
                if hr then hr.CFrame = hr.CFrame * CFrame.new(0, -1, 0) end
            end
        end)
    else
        h.PlatformStand = false
    end
end

local function addToggle(tab, flag, title, onChange)
    local obj
    local ok = pcall(function()
        obj = tab:Toggle({
            Title = title,
            Value = false,
            Callback = function(v)
                local nv
                if type(v) == "boolean" then nv = v else nv = not S[flag] end
                S[flag] = nv
                if onChange then pcall(onChange, nv) end
            end,
        })
    end)
    if ok and obj then
        UI[flag] = obj
        return
    end
    pcall(function()
        obj = tab:Button({
            Title = title,
            Callback = function()
                local nv = flipToggle(flag)
                if onChange then pcall(onChange, nv) end
                pcall(function() WI:Notify({Title = title, Content = (nv and "开" or "关"), Duration = 2}) end)
            end,
        })
    end)
    if obj then UI[flag] = obj end
end

local function addSlider(tab, flag, title, min, max, def, step, onChange)
    local obj
    local ok = pcall(function()
        obj = tab:Slider({Title = title, Min = min, Max = max, Step = step or 1, Value = def, Callback = function(v) S[flag] = v; if onChange then pcall(onChange, v) end end})
    end)
    if ok and obj then UI[flag] = obj; return end
    pcall(function()
        obj = tab:Slider({Title = title, Value = {Min = min, Max = max, Default = def}, Callback = function(v) S[flag] = v; if onChange then pcall(onChange, v) end end})
    end)
    if obj then UI[flag] = obj; return end
    pcall(function()
        obj = tab:Dropdown({Title = title, Values = {tostring(min), tostring(math.floor((min + max) / 2)), tostring(max)}, Value = tostring(def), Callback = function(v) S[flag] = tonumber(v) or def; if onChange then pcall(onChange, S[flag]) end end})
    end)
    if obj then UI[flag] = obj end
end

local function addSection(tab, title)
    pcall(function() tab:Section({Title = title, TextXAlignment = "Left", TextSize = 17}) end)
end

local function mW()
    WN = WI:CreateWindow({
    Title = "扔一枚硬币",
    Author = "扔一枚硬币",
    })
    WN_visible = true

    local t1
    pcall(function() t1 = WN:Tab({Title = "功能", Icon = "solar:slider-vertical-bold"}) end)
    if t1 then
        addSection(t1, "投币")
        addToggle(t1, "AutoThrow", "最佳投币")
        addToggle(t1, "AutoBuyCoin", "自动购买硬币")
        addSection(t1, "升级")
        addToggle(t1, "AutoUpgradeLuck", "升级 (运气)")
        addToggle(t1, "AutoUpgradeValue", "升级 (钱倍率)")
        addSection(t1, "出售")
        addToggle(t1, "AutoSell", "自动出售")
    end
end

task.spawn(function()
    while true do
        if S.Speed then
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = S.SpeedVal end
        end
        if S.AutoThrow then pcall(doThrow) end
        if S.AutoBuyCoin then pcall(doBuyCoin) end
        if S.AutoUpgradeLuck then pcall(doUpgradeLuck) end
        if S.AutoUpgradeValue then pcall(doUpgradeValue) end
        if S.AutoSell then pcall(doSell) end
        task.wait(0.2)
    end
end)

task.spawn(function()
    pcall(mW)
end)

pcall(function() WI:SetTheme("Light") end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode ~= toggleKey then return end
    local now = tick()
    if now - toggleLock < 0.3 then return end
    toggleLock = now
    if not WN then return end
    if WN_visible then
        WN_visible = false; pcall(function() WN:Close() end)
    else
        WN_visible = true; pcall(function() WN:Open() end)
    end
end)

LP.CharacterAdded:Connect(function(nc)
    task.wait(1)
    local h = nc:FindFirstChildOfClass("Humanoid")
    if S.Fly then toggleFly(true) end
    if S.Speed and h then h.WalkSpeed = S.SpeedVal end
end)
