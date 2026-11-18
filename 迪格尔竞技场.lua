
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

local State = {
    AutoAttack = false,
    ESP = false,
    AimBot = false,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.KillAllSettings = {
    FireRateDelay = 0.04,
    TargetPart = "Head",
    PanicHealthThreshold = 40
}

local CurrentShotTargets = {}
local DeagleController = nil

pcall(function()
    local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    DeagleController = require(PlayerScripts:WaitForChild("ModuleLoader"):WaitForChild("DeagleController"))
end)

local function IsAliveAndValid(model)
    if not model or not model:IsA("Model") or model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildWhichIsA("Humanoid")
    if not hum or hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return false end

    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    if not rootPart then return false end

    if model:FindFirstChild("Dead") or model:GetAttribute("IsDead") == true then return false end
    return true
end

local function GetAllPotentialTargets()
    local targets = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsAliveAndValid(player.Character) then
            if not (player.Team and player.Team == LocalPlayer.Team) then
                table.insert(targets, player.Character)
            end
        end
    end

    local queue = {workspace}
    while #queue > 0 do
        local current = table.remove(queue, 1)
        for _, child in ipairs(current:GetChildren()) do
            if child:IsA("Model") and IsAliveAndValid(child) then
                if not table.find(targets, child) then
                    local p = Players:GetPlayerFromCharacter(child)
                    if not p then
                        table.insert(targets, child)
                    end
                end
            elseif child:IsA("Folder") or child.Name:lower():find("bot") or child.Name:lower():find("npc") then
                table.insert(queue, child)
            end
        end
    end

    return targets
end

local function IsTargetVisible(targetPart, myRootPart)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.IgnoreWater = true

    local origin = myRootPart.Position
    local direction = targetPart.Position - origin

    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetPredictedPosition(targetPart)
    local character = targetPart.Parent
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

    if rootPart and rootPart:IsA("BasePart") then
        local velocity = rootPart.AssemblyLinearVelocity
        local ping = LocalPlayer:GetNetworkPing() or 0.03

        local predictionCompensation = velocity * (ping * 1.85)

        return targetPart.Position + predictionCompensation
    end

    return targetPart.Position
end

local function ExecuteAutomatedSweep()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    local myHum = myChar and myChar:FindFirstChildWhichIsA("Humanoid")
    if not myChar or not myRoot or not myHum or not DeagleController then return end

    local isVulnerable = (myHum.Health / myHum.MaxHealth * 100) <= _G.KillAllSettings.PanicHealthThreshold

    if typeof(DeagleController) == "table" then
        DeagleController.ShootCooldownUntil = 0
        DeagleController.CanShoot = true
        DeagleController.CurrentSpread = 0
        if DeagleController.WeaponStats then
            DeagleController.WeaponStats.Spread = 0
        end
    end

    table.clear(CurrentShotTargets)
    local activePool = GetAllPotentialTargets()

    table.sort(activePool, function(a, b)
        local rootA = a:FindFirstChild("HumanoidRootPart") or a:FindFirstChild("Torso")
        local rootB = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChild("Torso")
        if rootA and rootB then
            return (myRoot.Position - rootA.Position).Magnitude < (myRoot.Position - rootB.Position).Magnitude
        end
        return false
    end)

    if isVulnerable then
        local targetFound = false
        for _, child in ipairs(activePool) do
            local targetPart = child:FindFirstChild(_G.KillAllSettings.TargetPart) or child:FindFirstChild("Head")
            if targetPart and IsTargetVisible(targetPart, myRoot) then
                CurrentShotTargets[targetPart] = true

                local aimPosition = GetPredictedPosition(targetPart)

                pcall(function()
                    if typeof(DeagleController.Shoot) == "function" then
                        DeagleController.Shoot(aimPosition)
                    elseif typeof(DeagleController.Fire) == "function" then
                        DeagleController.Fire(aimPosition)
                    end
                end)
                targetFound = true
                break
            end
        end

        if not targetFound then
            for _, child in ipairs(activePool) do
                local targetPart = child:FindFirstChild(_G.KillAllSettings.TargetPart) or child:FindFirstChild("Head")
                if targetPart then
                    CurrentShotTargets[targetPart] = true

                    local aimPosition = GetPredictedPosition(targetPart)

                    pcall(function()
                        if typeof(DeagleController.Shoot) == "function" then
                            DeagleController.Shoot(aimPosition)
                        elseif typeof(DeagleController.Fire) == "function" then
                            DeagleController.Fire(aimPosition)
                        end
                    end)
                    break
                end
            end
        end
    else
        for _, child in ipairs(activePool) do
            local targetPart = child:FindFirstChild(_G.KillAllSettings.TargetPart) or child:FindFirstChild("Head")
            if targetPart then
                CurrentShotTargets[targetPart] = true

                local aimPosition = GetPredictedPosition(targetPart)

                pcall(function()
                    if typeof(DeagleController.Shoot) == "function" then
                        DeagleController.Shoot(aimPosition)
                    elseif typeof(DeagleController.Fire) == "function" then
                        DeagleController.Fire(aimPosition)
                    end
                end)
            end
        end
    end
end

local success, DeagleShared = pcall(function()
    return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("DeagleShared"))
end)

if success and DeagleShared and DeagleShared.Raycast then
    local oldRaycast = DeagleShared.Raycast
    DeagleShared.Raycast = function(p1, p2, p3, ...)
        for targetPart, _ in pairs(CurrentShotTargets) do
            if targetPart and targetPart.Parent and IsAliveAndValid(targetPart.Parent) then
                return {
                    Instance = targetPart,
                    Position = GetPredictedPosition(targetPart),
                    Normal = Vector3.new(0, 1, 0),
                    Material = Enum.Material.Plastic
                }
            end
        end
        return oldRaycast(p1, p2, p3, ...)
    end
end

task.spawn(function()
    while true do
        task.wait(_G.KillAllSettings.FireRateDelay)
        if State.AutoAttack then
            pcall(ExecuteAutomatedSweep)
        end
    end
end)

local espCache = {}

local function updateESP()
    local alive = {}
    for _, model in ipairs(GetAllPotentialTargets()) do
        alive[model] = true
        local hl = espCache[model]
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight")
            hl.Name = "DGR_ESP"
            hl.FillColor = Color3.fromHex("#22C55E")
            hl.OutlineColor = Color3.fromHex("#86EFAC")
            hl.FillTransparency = 0.6
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = model
            espCache[model] = hl
        end
    end
    for model, hl in pairs(espCache) do
        if not alive[model] or not model.Parent then
            pcall(function()
                hl:Destroy()
            end)
            espCache[model] = nil
        end
    end
end

local function clearESP()
    for _, hl in pairs(espCache) do
        pcall(function()
            hl:Destroy()
        end)
    end
    espCache = {}
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if State.ESP then
            pcall(updateESP)
        elseif next(espCache) then
            clearESP()
        end
    end
end)

task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if State.AimBot then
            pcall(function()
                local cam = workspace.CurrentCamera
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not cam or not myRoot then
                    return
                end
                local best, bestDist = nil, math.huge
                for _, model in ipairs(GetAllPotentialTargets()) do
                    local part = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                    if part then
                        local d = (part.Position - myRoot.Position).Magnitude
                        if d < bestDist then
                            bestDist = d
                            best = part
                        end
                    end
                end
                if best then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, GetPredictedPosition(best))
                end
            end)
        end
    end
end)

local Window = WindUI:CreateWindow({
Title = "迪格尔竞技场",
Author = "XJW",
})

Window:Tag({
    Title = "迪格尔竞技场",
    Color = Color3.fromHex("#22C55E"),
})

Window:EditOpenButton({
    Title = "迪格尔竞技场",
    Icon = "crosshair",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("22C55E")),
    Draggable = true,
})

local TabAttack = Window:Tab({ Title = "自动攻击", Icon = "sword", Locked = false })
local TabESP = Window:Tab({ Title = "全图透视", Icon = "eye", Locked = false })
local TabAim = Window:Tab({ Title = "自瞄", Icon = "crosshair", Locked = false })

TabAttack:Section({ Title = "自动攻击", TextXAlignment = "Left", TextSize = 17 })
TabAttack:Toggle({ Title = "自动攻击", Default = false, Callback = function(v) State.AutoAttack = v end })
TabAttack:Slider({
    Title = "射速间隔",
    Value = { Min = 0.02, Max = 0.5, Default = 0.04 },
    Increment = 0.01,
    Callback = function(v) _G.KillAllSettings.FireRateDelay = math.max(0.01, tonumber(v) or 0.04) end,
})

TabESP:Section({ Title = "全图透视", TextXAlignment = "Left", TextSize = 17 })
TabESP:Toggle({ Title = "全图透视", Default = false, Callback = function(v) State.ESP = v end })

TabAim:Section({ Title = "自瞄", TextXAlignment = "Left", TextSize = 17 })
TabAim:Toggle({ Title = "自瞄", Default = false, Callback = function(v) State.AimBot = v end })

WindUI:Notify({
    Title = "迪格尔竞技场",
    Content = "脚本已就绪",
    Duration = 3,
})
