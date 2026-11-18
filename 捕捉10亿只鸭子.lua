
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

local WindUI = XJWCompat(Library)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")


_G.AutoAttack = false
_G.AutoGrab = false
_G.AutoSell = false
_G.AutoUpgrade = false
_G.AutoFly = false
_G.AntiAfk = false
_G.InfJump = false
_G.DuckESP = false
local AttackInterval = 0.2
local MaxDistance = 1000
local SellMode = 1
local UpgradeInterval = 10
local WalkSpeedValue = 16
local FlySpeedValue = 50
local UUID = "ca49cb12-5ea1-4df3-b30f-56f08d22feac"

local Cap = { shoot = nil, seq = nil, interact = nil, sell = nil, upgrade = nil, crate = nil }
local Recording = false
local RecLog = {}
local CurrentSequence = 1

local function Notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "鸭子脚本", Text = msg, Duration = 3 })
    end)
end

local rawNamecall
rawNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if method == "FireServer" or method == "fireServer" then

        if #args == 1 and type(args[1]) == "number" then
            Cap.seq = self
        end

        if #args == 5 and args[5] == "Shoot" then
            Cap.shoot = self
        end
    elseif method == "InvokeServer" or method == "invokeServer" then

        if #args == 1 and type(args[1]) == "userdata" and not Cap.interact then
            Cap.interact = self
        end

        if #args == 0 and not Cap.sell then
            Cap.sell = self
        end

        if #args == 3 and type(args[1]) == "string" and type(args[2]) == "string" then
            Cap.upgrade = self
        end

        for i = 1, #args do
            if type(args[i]) == "string" and string.find(args[i], "Crate") then
                Cap.crate = self
                break
            end
        end
    end
    return rawNamecall(self, ...)
end)

local function GetClosestTarget()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local myPos = myChar.HumanoidRootPart.Position
    local closestPos, targetName, shortestDist = nil, "", MaxDistance
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name, "DuckController_Client") or string.find(obj.Name, "BossController_Client") then
            local targetPos = nil
            if obj:IsA("BasePart") then
                targetPos = obj.Position
            elseif obj:IsA("Model") then
                targetPos = obj.PrimaryPart and obj.PrimaryPart.Position or nil
                if not targetPos then
                    local cp = obj:FindFirstChildWhichIsA("BasePart", true)
                    if cp then targetPos = cp.Position end
                end
            end
            if targetPos then
                local dist = (targetPos - myPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPos = targetPos
                    targetName = obj.Name
                end
            end
        end
    end
    return closestPos, targetName
end

local function ExecuteAttack()
    if not Cap.seq or not Cap.shoot then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local targetPos, targetName = GetClosestTarget()
    if not targetPos then return end
    local myPos = myChar.HumanoidRootPart.Position
    local direction = (targetPos - myPos).Unit
    local timestamp = workspace:GetServerTimeNow()
    CurrentSequence = CurrentSequence + 1
    pcall(function()
        Cap.seq:FireServer(CurrentSequence)
        Cap.shoot:FireServer(myPos, direction, CurrentSequence, timestamp, "Shoot")
    end)
end

task.spawn(function()
    while true do
        if _G.AutoAttack and not _G.PickingUp then
            ExecuteAttack()
        end
        task.wait(AttackInterval)
    end
end)

local function GetHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function GetHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

task.spawn(function()
    while true do
        if _G.AutoAttack or true then
            local hum = GetHum()
            if hum then
                hum.WalkSpeed = WalkSpeedValue
            end
        end
        task.wait(1)
    end
end)

local FlyConn = nil
task.spawn(function()
    while true do
        if _G.AutoFly then
            local hrp = GetHRP()
            if hrp then
                local vel = Instance.new("Vector3Velocity")
                vel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                vel.Velocity = Vector3.new(0, FlySpeedValue, 0)
                vel.Parent = hrp
                task.wait(1)
                vel:Destroy()
            end
        end
        task.wait(0.5)
    end
end)

local Jumping = false
task.spawn(function()
    while true do
        if _G.InfJump then
            local hum = GetHum()
            if hum and not Jumping then
                Jumping = true
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.05)
                Jumping = false
            end
        end
        task.wait(0.05)
    end
end)

local LastPos = nil
task.spawn(function()
    while true do
        if _G.AntiAfk then
            local hrp = GetHRP()
            if hrp then
                if LastPos and (hrp.Position - LastPos).Magnitude < 1 then
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.5, 0)
                end
                LastPos = hrp.Position
            end
        end
        task.wait(120)
    end
end)

local ESPObjs = {}
local function ClearESP()
    for _, obj in ipairs(ESPObjs) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjs = {}
end

task.spawn(function()
    while true do
        if _G.DuckESP then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (string.find(obj.Name, "DuckController_Client") or string.find(obj.Name, "BossController_Client"))
                    and not obj:FindFirstChild("DuckESP_Tag") then
                    local tag = Instance.new("BillboardGui")
                    tag.Name = "DuckESP_Tag"
                    tag.Size = UDim2.new(0, 120, 0, 24)
                    tag.AlwaysOnTop = true
                    tag.Adornee = obj
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.BackgroundTransparency = 0.3
                    lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
                    lbl.Text = "鸭子"
                    lbl.Parent = tag
                    tag.Parent = obj
                    table.insert(ESPObjs, tag)
                end
            end
            task.wait(1)
        else
            ClearESP()
            task.wait(1)
        end
    end
end)

local function CopyText(text)
    if setclipboard then
        local ok2 = pcall(function() setclipboard(text) end)
        if ok2 then return true end
    end
    if toclipboard then
        local ok2 = pcall(function() toclipboard(text) end)
        if ok2 then return true end
    end
    if writefile then
        local ok2 = pcall(writefile, "CatchDucks_rec.txt", text)
        if ok2 then Notify("已存 CatchDucks_rec.txt"); return true end
    end
    return false
end

local Window = WindUI:CreateWindow({
Title = "捕捉10亿只鸭子",
Author = "XJW",
})

Window:EditOpenButton({
    Title = "XJW",
    Icon = "duck",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

if Window then
    pcall(function() Window.IsPC = false end)
end

local TabAtk = Window:Tab({ Title = "攻击", Icon = "sword", Locked = false })
TabAtk:Section({ Title = "自动射击", TextXAlignment = "Left", TextSize = 17 })
TabAtk:Toggle({
    Title = "自动攻击",
    Default = false,
    Callback = function(v)
        _G.AutoAttack = v
        Notify(v and "自动攻击已开启" or "自动攻击已关闭")
    end,
})

local TabMove = Window:Tab({ Title = "移动", Icon = "run", Locked = false })
TabMove:Section({ Title = "移动辅助", TextXAlignment = "Left", TextSize = 17 })
TabMove:Slider({
    Title = "移速",
    Value = { Min = 16, Max = 120, Default = 16 },
    Increment = 1,
    Callback = function(v) WalkSpeedValue = v end,
})
TabMove:Toggle({
    Title = "飞行",
    Default = false,
    Callback = function(v)
        _G.AutoFly = v
        Notify(v and "飞行已开启(上升)" or "飞行已关闭")
    end,
})
TabMove:Slider({
    Title = "飞行上升速度",
    Value = { Min = 20, Max = 300, Default = 50 },
    Increment = 10,
    Callback = function(v) FlySpeedValue = v end,
})
TabMove:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(v)
        _G.InfJump = v
        Notify(v and "无限跳已开启" or "无限跳已关闭")
    end,
})
TabMove:Toggle({
    Title = "防挂机",
    Default = false,
    Callback = function(v)
        _G.AntiAfk = v
        Notify(v and "防挂机已开启" or "防挂机已关闭")
    end,
})
TabMove:Section({ Title = "移动辅助", TextXAlignment = "Left", TextSize = 17 })
local TabAdv = Window:Tab({ Title = "进阶", Icon = "star", Locked = false })
TabAdv:Toggle({
    Title = "鸭子/Boss ESP",
    Default = false,
    Callback = function(v)
        _G.DuckESP = v
        Notify(v and "ESP已开启" or "ESP已关闭")
    end,
})

WindUI:Notify({
    Title = "捕捉10亿只鸭子加载成功",
    Content = "脚本已就绪",
    Duration = 3,
})
