
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
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local islands = {
    {name = "附魔岛",       x = 58.837700,   y = 765.956055,   z = -132.327103},
    {name = "星界岛",       x = 240.192764,  y = 2013.809326,  z = 262.970642},
    {name = "神秘岛",       x = 157.453369,  y = 4047.156494,  z = 67.575119},
    {name = "太空岛",       x = 132.636856,  y = 5656.780273,  z = 84.043762},
    {name = "冻土岛",       x = 142.583878,  y = 9284.960938,  z = 81.353737},
    {name = "永恒岛",       x = 139.663177,  y = 13679.814453, z = 74.364204},
    {name = "沙暴岛",       x = 137.602142,  y = 17686.107422, z = 79.762215},
    {name = "雷暴岛",       x = 144.681763,  y = 24069.800781, z = 70.535057},
    {name = "远古试炼岛",   x = 135.091003,  y = 28256.072266, z = 72.206032},
    {name = "午夜暗影岛",   x = 133.933136,  y = 33206.757812, z = 61.787067},
    {name = "神秘灵魂岛",   x = 136.757950,  y = 39317.351562, z = 66.125198},
    {name = "冬季奇迹岛",   x = 137.700027,  y = 46010.332031, z = 67.936378},
    {name = "黄金大师岛",   x = 133.667450,  y = 52607.546875, z = 59.298328},
    {name = "龙传奇岛",     x = 136.343185,  y = 59594.460938, z = 62.818188},
    {name = "赛博传奇岛",   x = 134.897095,  y = 66668.953125, z = 59.924160},
    {name = "天梵超能岛",   x = 135.759415,  y = 70270.945312, z = 65.471672},
    {name = "混沌传奇岛",   x = 136.380219,  y = 74442.640625, z = 59.650558},
    {name = "灵魂融合岛",   x = 131.545914,  y = 79746.773438, z = 56.678509},
    {name = "黑暗元素岛",   x = 134.228622,  y = 83198.773438, z = 56.734966},
    {name = "禅心岛",       x = 132.658081,  y = 87050.859375, z = 61.767765},
    {name = "炽热旋涡之岛", x = 135.727097,  y = 91245.859375, z = 60.028637},
}


local function tp(island)
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = CFrame.new(island.x, island.y, island.z)
    pcall(function()
        WindUI:Notify({Title = "传送成功", Content = island.name, Duration = 2})
    end)
    return true
end

local unlocking = false

local function unlockAll()
    if unlocking then return end
    unlocking = true

    pcall(function()
        WindUI:Notify({Title = "开始解锁", Content = "共 " .. #islands .. " 个岛屿", Duration = 3})
    end)

    task.spawn(function()
        local count = 0
        for i, island in ipairs(islands) do
            if not unlocking then break end
            local char = LocalPlayer.Character
            if not char then break end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then break end
            root.CFrame = CFrame.new(island.x, island.y, island.z)
            count = count + 1
            task.wait(0.8)
        end

        if unlocking and #islands > 0 then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(islands[1].x, islands[1].y, islands[1].z)
                end
            end
        end

        pcall(function()
            WindUI:Notify({Title = "完成", Content = "已解锁 " .. count .. " 个岛", Duration = 4})
        end)

        unlocking = false
    end)
end

local function teleportToCF(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

local function ninjaFire(...)
    local args = {...}
    pcall(function()
        LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
    end)
end

local RANKS = {
    "Grasshopper","Apprentice","Samurai","Assassin","Shadow",
    "Ninja","Master Ninja","Sensei","Master Sensei","Ninja Legend",
    "Master Of Shadows","Immortal Assassin","Eternity Hunter","Shadow Legend","Dragon Warrior",
    "Dragon Master","Chaos Sensei","Chaos Legend","Master Of Elements","Elemental Legend",
    "Ancient Battle Master","Ancient Battle Legend","Legendary Shadow Duelist","Master Legend Assassin","Mythic Shadowmaster",
    "Legendary Shadowmaster","Awakened Scythemaster","Awakened Scythe Legend","Master Legend Zephyr","Golden Sun Shuriken Master",
    "Golden Sun Shuriken Legend","Dark Sun Samurai Legend","Dragon Evolution Form I","Dragon Evolution Form II","Dragon Evolution Form III",
    "Dragon Evolution Form IV","Dragon Evolution Form V","Cybernetic Electro Master","Cybernetic Electro Legend","Shadow Chaos Assassin",
    "Shadow Chaos Legend","Infinity Legend","Aether Genesis Master Ninja","Master Legend Sensei Hunter",
    "Skystorm Series Samurai Legend","Master Elemental Hero","Eclipse Series Soul Master","Starstrike Master Sensei","Evolved Series Master Ninja",
    "Dark Elements Guardian","Elite Series Master Legend","Infinity Shadows Master","Lighting Storm Sensei",
    "Dark Elements Blademaster","Rising Shadow Eternal Ninja","Skyblade Ninja Master","Shadow Storm Sensei","Comet Strike Lion",
    "Cybernetic Azure Sensei","Ultra Genesis Shadow"
}

local function doSell()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    local area = Workspace:FindFirstChild("sellAreaCircles")
    if not area then return end
    local circle = area:FindFirstChild("sellAreaCircle16")
    if not circle then return end
    local inner = circle:FindFirstChild("circleInner")
    if not inner then return end
    for _, v in ipairs(inner:GetDescendants()) do
        if v.Name == "TouchInterest" and v.Parent then
            pcall(function()
                firetouchinterest(head, v.Parent, 0)
                task.wait(0.1)
                firetouchinterest(head, v.Parent, 1)
            end)
            break
        end
    end
end

local function doHoops()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local folder = Workspace:FindFirstChild("Hoops")
        if folder then
            for _, hoop in ipairs(folder:GetChildren()) do
                if hoop.Name == "Hoop" then
                    hoop.CFrame = char.HumanoidRootPart.CFrame
                end
            end
        end
    end
end

local function doChi()
    local chiFolder = Workspace:FindFirstChild("spawnedCoins")
    if not chiFolder then return end
    local valley = chiFolder:FindFirstChild("Valley")
    if not valley then return end
    local list = {
        valley:FindFirstChild("Pink Chi Crate"),
        valley:FindFirstChild("Blue Chi Crate"),
        valley:FindFirstChild("Chi Crate"),
    }
    for _, crate in ipairs(list) do
        if crate then
            teleportToCF(crate.CFrame)
            task.wait(0.1)
        end
    end
end

local function doElementAll()
    local ev = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("elementMasteryEvent")
    local elems = ReplicatedStorage:FindFirstChild("Elements")
    if not ev or not elems then return end
    for _, v in ipairs(elems:GetChildren()) do
        pcall(function() ev:FireServer(v.Name) end)
        task.wait()
    end
end

local function doBoss(name)
    local folder = Workspace:FindFirstChild("bossFolder")
    if not folder then return end
    local target = folder:FindFirstChild(name)
    if target and target:FindFirstChild("UpperTorso") then
        teleportToCF(target.UpperTorso.CFrame)
        ninjaFire("swingKatana")
    end
end

local function unlockAllPasses()
    local ids = ReplicatedStorage:FindFirstChild("gamepassIds")
    if not ids then return end
    local count = 0
    for _, v in ipairs(ids:GetChildren()) do
        pcall(function() v.Parent = LocalPlayer.ownedGamepasses end)
        count = count + 1
    end
    return count
end

local Auto = {
    swing = false, sell = false, rank = false, belt = false, sword = false,
    hoop = false, chi = false, bossNormal = false, bossEternal = false, bossMagma = false,
}

task.spawn(function()
    while true do
        if Auto.swing then ninjaFire("swingKatana") end
        if Auto.sell then pcall(doSell) end
        if Auto.hoop then pcall(doHoops) end
        if Auto.chi then pcall(doChi) end
        if Auto.bossNormal then pcall(doBoss, "RobotBoss") end
        if Auto.bossEternal then pcall(doBoss, "EternalBoss") end
        if Auto.bossMagma then pcall(doBoss, "AncientMagmaBoss") end
        if Auto.rank then
            for i = 1, #RANKS, 5 do
                for j = i, math.min(i + 4, #RANKS) do ninjaFire("buyRank", RANKS[j]) end
                task.wait()
            end
        end
        if Auto.belt then ninjaFire("buyAllBelts", "Blazing Vortex Island") end
        if Auto.sword then ninjaFire("buyAllSwords", "Blazing Vortex Island") end
        task.wait(0.2)
    end
end)


local windowOk, Window = pcall(function()
    return WindUI:CreateWindow({
    Title = "忍者传奇",
    Author = "忍者传奇",
    })
end)

if not windowOk then
    return
end


pcall(function()
    Window:EditOpenButton({
        Title = "XJW",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 16),
        Draggable = true,
    })
end)


local tabOk, Tab = pcall(function()
    return Window:Tab({
        Title = "岛屿",
        Icon = "settings",
        Locked = false,
    })
end)

if not tabOk then
else

    pcall(function() Tab:Section({Title = "快速传送", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function() Tab:Button({Title = "回到附魔岛", Callback = function() tp(islands[1]) end}) end)
    pcall(function() Tab:Button({Title = "前往最高岛", Callback = function() tp(islands[#islands]) end}) end)

    pcall(function() Tab:Section({Title = "解锁全部岛屿", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function() Tab:Paragraph({Title = "说明", Desc = "点击按钮自动传送所有岛屿触发解锁，约15-20秒完成。完成后自动返回附魔岛。"}) end)
    pcall(function() Tab:Button({Title = "一键解锁全部岛屿", Callback = function() unlockAll() end}) end)

    pcall(function() Tab:Section({Title = "单岛传送", TextXAlignment = "Left", TextSize = 14}) end)
    local names = {}
    for _, v in ipairs(islands) do table.insert(names, v.name) end
    local selected = islands[1].name
    pcall(function()
        Tab:Dropdown({
            Title = "选择岛屿",
            Values = names,
            Value = names[1],
            Callback = function(val) selected = val end
        })
    end)
    pcall(function()
        Tab:Button({
            Title = "传送选中岛屿",
            Callback = function()
                for _, island in ipairs(islands) do
                    if island.name == selected then
                        tp(island)
                        break
                    end
                end
            end
        })
    end)
end

local tabAutoOk, TabAuto = pcall(function()
    return Window:Tab({Title = "自动", Icon = "settings", Locked = false})
end)

if tabAutoOk then
    pcall(function() TabAuto:Section({Title = "刷金币", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabAuto:Toggle({Title = "自动挥刀", Default = false,
            Callback = function(state) Auto.swing = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动出售", Default = false,
            Callback = function(state) Auto.sell = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动吸气", Default = false,
            Callback = function(state) Auto.chi = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "吸环拉圈", Default = false,
            Callback = function(state) Auto.hoop = state end})
    end)

    pcall(function() TabAuto:Section({Title = "自动购买", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabAuto:Toggle({Title = "自动买称号", Default = false,
            Callback = function(state) Auto.belt = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动买刀", Default = false,
            Callback = function(state) Auto.sword = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动重生职位", Default = false,
            Callback = function(state) Auto.rank = state end})
    end)

    pcall(function() TabAuto:Section({Title = "自动刷Boss", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabAuto:Toggle({Title = "普通Boss", Default = false,
            Callback = function(state) Auto.bossNormal = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "永恒Boss", Default = false,
            Callback = function(state) Auto.bossEternal = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "岩浆Boss", Default = false,
            Callback = function(state) Auto.bossMagma = state end})
    end)

    pcall(function()
        TabAuto:Button({Title = "获取所有元素(永久)",
            Callback = function() pcall(doElementAll) end})
    end)
end

local tabFunOk, TabFun = pcall(function()
    return Window:Tab({Title = "功能", Icon = "settings", Locked = false})
end)

if tabFunOk then
    pcall(function() TabFun:Section({Title = "通行证", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabFun:Button({Title = "解锁全部通行证",
            Callback = function()
                local n = unlockAllPasses()
                pcall(function() WindUI:Notify({Title = "完成", Content = "已解锁 " .. tostring(n) .. " 个通行证", Duration = 3}) end)
            end})
    end)
end

LocalPlayer.Chatted:Connect(function(msg)
    local lower = msg:lower()
    if lower:sub(1, 3) == "!tp" then
        for _, island in ipairs(islands) do
            if lower:find(island.name:lower()) then
                tp(island)
                break
            end
        end
    end
    if lower == "!unlockall" or lower == "!解锁全岛" then
        unlockAll()
    end
end)

