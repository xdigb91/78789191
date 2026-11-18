
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
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Settings = {
    Follow = false,
    Attack = false,
    Dist = 3,
    AtkInterval = 0.1,
    RefreshInterval = 2,
    BuyInterval = 1000,
    Buy = {
        basic = false,
        iron = false,
        house = false,
        Paint = false,
        Save = false,
        Speed = false,
    },
}

local FollowThread = nil
local AtkThread = nil
local BuyThreads = {}

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local BuyCrate = Remotes and Remotes:FindFirstChild("BuyCrate")
local BuyTool = Remotes and Remotes:FindFirstChild("BuyTool")

local FakeZombie = Workspace:FindFirstChild("Zombie")
local tracked = {}

local function IsPlayerModel(model)
    if model == LP.Character then return true end
    if Players:GetPlayerFromCharacter(model) then return true end
    if model:IsDescendantOf(Players) then return true end
    return false
end

local function IsFake(model)
    if model == FakeZombie then return true end
    if model.Parent == Workspace and model.Name == "Zombie" then return true end
    return false
end

local ZombieCache = {}

local function RemoveFromCache(z)
    for i = #ZombieCache, 1, -1 do
        if ZombieCache[i] == z then
            table.remove(ZombieCache, i)
        end
    end
end

local function ScanEnemiesFolder()
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return false end
    local list = {}
    local function collect(root)
        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("Model") and not IsPlayerModel(v) and not IsFake(v) then
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum then
                    table.insert(list, v)
                    if not tracked[v] then
                        tracked[v] = true
                        hum.Died:Connect(function()
                            RemoveFromCache(v)
                        end)
                    end
                end
            end
            if v:IsA("Folder") or v:IsA("Model") then
                collect(v)
            end
        end
    end
    collect(enemies)
    ZombieCache = list
    return true
end

local function CleanupCache()
    for i = #ZombieCache, 1, -1 do
        local z = ZombieCache[i]
        if not z or not z.Parent then
            table.remove(ZombieCache, i)
        else
            local hum = z:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then
                table.remove(ZombieCache, i)
            end
        end
    end
end

task.spawn(function()
    task.wait(1)
    ScanEnemiesFolder()
end)

local function GetPlayerRoot()
    local ch = LP.Character
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
end

local function GetWeapon()
    local ch = LP.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    end
    for _, t in ipairs(LP.Backpack:GetChildren()) do
        if t:IsA("Tool") then
            if ch then
                pcall(function() t.Parent = ch end)
            end
            return t
        end
    end
    return nil
end

local function teleportTo(position)
    local root = GetPlayerRoot()
    if root then
        root.CFrame = CFrame.new(position)
    end
end

local function teleportToPart(part)
    if not part then return false end
    local pos
    if part:IsA("BasePart") then
        pos = part.Position
    else
        local rootPart = part:FindFirstChild("HumanoidRootPart") or part.PrimaryPart or part:FindFirstChild("Torso") or part:FindFirstChild("UpperTorso")
        if rootPart then
            pos = rootPart.Position
        else
            local ok, cf = pcall(function() return part:GetBoundingBox() end)
            if ok then
                pos = cf.Position
            end
        end
    end
    if pos then
        teleportTo(pos + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

local function FindNearestZombie()
    local root = GetPlayerRoot()
    if not root then return nil end
    local best, bd = nil, math.huge
    for _, z in ipairs(ZombieCache) do
        local zrp = z:FindFirstChild("HumanoidRootPart") or z.PrimaryPart
        if zrp then
            local d = (zrp.Position - root.Position).Magnitude
            if d < bd then
                bd = d
                best = zrp
            end
        end
    end
    return best, bd
end

local function teleportBehind(part, dist)
    if not part then return end
    local root = GetPlayerRoot()
    if not root then return end
    local enemyCF = part.CFrame
    local behindPos = enemyCF.Position - enemyCF.LookVector * dist
    behindPos = behindPos + Vector3.new(0, 0.5, 0)
    root.CFrame = CFrame.new(behindPos)
end

local function lockCharacterBehind(targetRoot)
    if not targetRoot then return end
    local root = GetPlayerRoot()
    if not root then return end
    local direction = (targetRoot.Position - root.Position).Unit
    root.CFrame = CFrame.new(root.Position, root.Position + direction)
end

local function StartFollow()
    Settings.Follow = true
    FollowThread = task.spawn(function()
        local lastScan = 0
        while Settings.Follow do
            CleanupCache()

            if tick() - lastScan >= Settings.RefreshInterval then
                lastScan = tick()
                ScanEnemiesFolder()
            end

            local root = GetPlayerRoot()
            if root then
                local zrp, dist = FindNearestZombie()
                if zrp then
                    teleportBehind(zrp, Settings.Dist)
                    lockCharacterBehind(zrp)
                    task.wait(0.02)
                else
                    ScanEnemiesFolder()
                    task.wait(0.1)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

local function StartAttack()
    Settings.Attack = true
    AtkThread = task.spawn(function()
        while Settings.Attack do
            local tool = GetWeapon()
            if tool then
                pcall(function()
                    tool:Activate()
                    tool:Activate()
                end)
            end
            task.wait(Settings.AtkInterval)
        end
    end)
end

local function BuyOne(item)
    pcall(function()
        if item.Kind == "Crate" then
            BuyCrate:FireServer(item.Name, 1)
        else
            BuyTool:FireServer(item.Name)
        end
    end)
end

local function StartBuy(item)
    Settings.Buy[item.Name] = true
    local t = task.spawn(function()
        while Settings.Buy[item.Name] do
            BuyOne(item)
            task.wait(Settings.BuyInterval / 1000)
        end
    end)
    BuyThreads[item.Name] = t
end

local function StopBuy(name)
    Settings.Buy[name] = false
    if BuyThreads[name] then
        task.cancel(BuyThreads[name])
        BuyThreads[name] = nil
    end
end

local Window = WindUI:CreateWindow({
Title = "建造躲藏的生存僵尸",
Author = "XJW",
})

local Tab = Window:Tab({Title = "功能", Icon = "swords"})

Tab:Section({Title = "传送点", TextXAlignment = "Left", TextSize = 17})

Tab:Button({
    Title = "传送安全点",
    Callback = function()
        local mdl = Workspace:FindFirstChild("Model")
        local part = mdl and mdl:FindFirstChild("Part", true)
        if part and teleportToPart(part) then
            WindUI:Notify({Title = "传送成功", Content = "已传送到安全点", Duration = 2})
        else
            WindUI:Notify({Title = "传送失败", Content = "未找到 Model.Part", Duration = 2})
        end
    end
})

Tab:Button({
    Title = "传送复活点",
    Callback = function()
        local folder = Workspace:FindFirstChild("DirthPath")
        local sp = folder and folder:FindFirstChild("SpawnLocation", true)
        if not sp then
            sp = Workspace:FindFirstChild("SpawnLocation", true)
        end
        if not sp then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("SpawnLocation") then
                    sp = v
                    break
                end
            end
        end
        if sp and teleportToPart(sp) then
            WindUI:Notify({Title = "传送成功", Content = "已传送到复活点", Duration = 2})
        else
            WindUI:Notify({Title = "传送失败", Content = "未找到复活点，请把场景里出生点的路径发我", Duration = 3})
        end
    end
})

Tab:Section({Title = "打僵尸", TextXAlignment = "Left", TextSize = 17})

Tab:Toggle({
    Title = "循环传送僵尸",
    Default = false,
    Callback = function(v)
        if v then
            StartFollow()
        else
            Settings.Follow = false
            if FollowThread then task.cancel(FollowThread) FollowThread = nil end
        end
    end
})

Tab:Toggle({
    Title = "自动攻击",
    Default = false,
    Callback = function(v)
        if v then
            StartAttack()
        else
            Settings.Attack = false
            if AtkThread then task.cancel(AtkThread) AtkThread = nil end
        end
    end
})

Tab:Slider({
    Title = "攻击间隔(毫秒)",
    Value = {Min = 10, Max = 1000, Default = 100},
    Increment = 10,
    Callback = function(v)
        Settings.AtkInterval = (v or 100) / 1000
    end
})

Tab:Slider({
    Title = "背后距离(格)",
    Value = {Min = 1, Max = 8, Default = 3},
    Increment = 1,
    Callback = function(v) Settings.Dist = v or 3 end
})

Tab:Section({Title = "自动购买", TextXAlignment = "Left", TextSize = 17})

local BuyToggleList = {
    {Key = "basic", Title = "自动购买 基础箱", Kind = "Crate"},
    {Key = "iron", Title = "自动购买 铁箱", Kind = "Crate"},
    {Key = "house", Title = "自动购买 房屋箱", Kind = "Crate"},
    {Key = "Paint", Title = "自动购买 油漆", Kind = "Tool"},
    {Key = "Save", Title = "自动购买 存档", Kind = "Tool"},
    {Key = "Speed", Title = "自动购买 加速", Kind = "Tool"},
}

for _, def in ipairs(BuyToggleList) do
    Tab:Toggle({
        Title = def.Title,
        Default = false,
        Callback = function(v)
            if v then
                StartBuy({Name = def.Key, Kind = def.Kind})
            else
                StopBuy(def.Key)
            end
        end
    })
end

Tab:Slider({
    Title = "购买间隔(毫秒)",
    Value = {Min = 100, Max = 10000, Default = 1000},
    Increment = 100,
    Callback = function(v)
        Settings.BuyInterval = v or 1000
    end
})
