
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Refs = {
    LeafSim = nil,
    LeafFolder = nil,
    CollectMany = nil,
    EmptyBackpack = nil,
    Dumpsters = nil,
    UserIntent = false,
    AutoSell = false,
    AutoFarm = false,
    AntiOutOfBounds = false,
    AccelEnabled = true,
    AccelIntervalSpeed = 0.001,
    AccelDuration = 1,
    AccelRestTime = 0.09,
    AccelCycleStart = tick(),
    PausedByBag = false,
    ScanRadius = 20,
    MaxBatch = 100,
    CollectInterval = 0.02,
    SellDelay = 0.2,
    SellTpCooldown = 0.15,
    TpStayDuration = 4,
    LastTpTime = 0,
    LastSafeCFrame = nil,
    MaxTpDistance = 200,
    WalkEnabled = false,
    WalkValue = 24,
    FlyEnabled = false,
    FlySpeed = 60,
    NoClip = false,
    UiBody = nil,
    UiScreen = nil,
    StatusPara = nil,
    OriginCFrame = nil,
    IsTeleporting = false,
}

local leafQueryParams = OverlapParams.new()
leafQueryParams.FilterType = Enum.RaycastFilterType.Include
leafQueryParams.MaxParts = 200

local function Notify(tt, tx)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = tt, Text = tx, Duration = 5})
    end)
end

local Window = WindUI:CreateWindow({
Title = "清理所有枫叶",
Author = "XJW",
})

Window:EditOpenButton({
    Title = "清理所有枫叶",
    Icon = "leaf",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

local TimeTag = Window:Tag({
    Title = "00:00",
    Color = Color3.fromRGB(255, 255, 255),
})

task.spawn(function()
    local hue = 0
    while true do
        local now = os.date("*t")
        hue = (hue + 0.01) % 1
        TimeTag:SetTitle(string.format("%02d:%02d", now.hour, now.min))
        TimeTag:SetColor(Color3.fromHSV(hue, 1, 1))
        task.wait(1)
    end
end)

Window:Tag({
    Title = "清理所有枫叶🍁",
    Color = Color3.fromHex("#7FDBFF"),
})

local Tab = Window:Tab({
    Title = "主功能",
    Icon = "leaf",
})

Tab:Section({ Title = "状态", TextXAlignment = "Left", TextSize = 17 })
local StatusPara = Tab:Paragraph({
    Title = "运行状态",
    Desc = "状态：加载中...",
})
Refs.StatusPara = StatusPara

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function findNearestUnlockedLeaf(pos, radius)
    if not Refs.LeafSim or not Refs.LeafFolder then return nil end
    leafQueryParams.FilterDescendantsInstances = { Refs.LeafFolder }
    local parts = workspace:GetPartBoundsInRadius(pos, radius, leafQueryParams)
    local canUseLeaf = Refs.LeafSim.canUseLeaf
    local nearest, minDist = nil, math.huge
    for _, part in ipairs(parts) do
        if part.Parent == Refs.LeafFolder and part:IsA("BasePart") then
            local d = (part.Position - pos).Magnitude
            if d < minDist then
                local ok, usable = pcall(canUseLeaf, part)
                if ok and usable then
                    minDist = d
                    nearest = part
                end
            end
        end
    end
    return nearest
end

local function isPositionSafe(pos)
    return findNearestUnlockedLeaf(pos, 30) ~= nil
end

local function countUnlockedLeavesNear(pos, radius)
    if not Refs.LeafSim or not Refs.LeafFolder then return 0 end
    leafQueryParams.FilterDescendantsInstances = { Refs.LeafFolder }
    local parts = workspace:GetPartBoundsInRadius(pos, radius, leafQueryParams)
    local count = 0
    local canUseLeaf = Refs.LeafSim.canUseLeaf
    for _, part in ipairs(parts) do
        if part.Parent == Refs.LeafFolder then
            local ok, usable = pcall(canUseLeaf, part)
            if ok and usable then
                count = count + 1
            end
        end
    end
    return count
end

local function isDumpsterUnlocked(dumpster)
    local LeafSim = Refs.LeafSim
    if not LeafSim then return false end
    if not LeafSim.ranked or not LeafSim.ranked.canUse then return false end
    local ok, result = pcall(function() return LeafSim.ranked.canUse(LocalPlayer, dumpster) end)
    if ok then return result end
    return false
end

local function getDumpsterPos(dumpster)
    local leaves = dumpster:FindFirstChild("Leaves")
    if leaves and leaves:IsA("BasePart") then
        return leaves.Position
    end
    local ok, bb = pcall(function() return dumpster:GetBoundingBox() end)
    if ok then return bb.Position end
    return nil
end

local function strictIsDumpsterUnlocked(dumpster)
    if not isDumpsterUnlocked(dumpster) then return false end
    local pos = getDumpsterPos(dumpster)
    if not pos then return false end
    return findNearestUnlockedLeaf(pos, 30) ~= nil
end

local function safeTeleport(targetPos)
    local hrp = getRoot()
    if not hrp then return false end
    local originalCFrame = hrp.CFrame
    local targetCFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    pcall(function() hrp.CFrame = targetCFrame end)
    task.wait(0.15)
    local hrp2 = getRoot()
    if not hrp2 then return false end
    local actualPos = hrp2.Position
    local deviation = (actualPos - targetPos).Magnitude
    if deviation > 6 then
        pcall(function() hrp2.CFrame = originalCFrame end)
        task.wait(0.05)
        return false
    end
    return true
end

local function getDumpsterValue(dumpster)
    local attrNames = {"Price", "Value", "Multiplier", "Tier", "Level", "SellPrice", "CashPerLeaf", "Rate", "Bonus", "SellMult", "SellMultiplier", "Payout", "PayRate", "CashMult"}
    local best = 0
    for _, name in ipairs(attrNames) do
        local ok, val = pcall(function() return dumpster:GetAttribute(name) end)
        if ok and type(val) == "number" and val > best then
            best = val
        end
    end
    local ok2, descendants = pcall(function() return dumpster:GetDescendants() end)
    if ok2 and descendants then
        for _, child in ipairs(descendants) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local lower = child.Name:lower()
                if lower:find("price") or lower:find("value") or lower:find("mult") or lower:find("tier") or lower:find("level") or lower:find("rate") or lower:find("payout") then
                    if child.Value > best then
                        best = child.Value
                    end
                end
            end
        end
    end
    return best
end

local function getBestDumpsterPos()
    if not Refs.Dumpsters then return nil end
    local hrp = getRoot()
    if not hrp then return nil end
    local origin = hrp.Position
    local bestPos, bestValue, bestDist = nil, -1, math.huge
    for _, obj in ipairs(Refs.Dumpsters:GetChildren()) do
        if obj:IsA("Model") and strictIsDumpsterUnlocked(obj) then
            local pos = getDumpsterPos(obj)
            if pos and countUnlockedLeavesNear(pos, 30) >= 3 then
                local value = getDumpsterValue(obj)
                local dist = (pos - origin).Magnitude
                if value > bestValue or (value == bestValue and dist < bestDist) then
                    bestValue = value
                    bestDist = dist
                    bestPos = pos
                end
            end
        end
    end
    if not bestPos then
        for _, obj in ipairs(Refs.Dumpsters:GetChildren()) do
            if obj:IsA("Model") and strictIsDumpsterUnlocked(obj) then
                local pos = getDumpsterPos(obj)
                if pos and countUnlockedLeavesNear(pos, 40) >= 1 then
                    local dist = (pos - origin).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPos = pos
                    end
                end
            end
        end
    end
    return bestPos
end

local FixedDumpsterPath = { "Map", "Dumpsters", "Dumpster" }

local function resolveFixedDumpster()
    local node = workspace:FindFirstChild(FixedDumpsterPath[1])
    if not node then return nil end
    node = node:FindFirstChild(FixedDumpsterPath[2])
    if not node then return nil end
    local target = node:FindFirstChild(FixedDumpsterPath[3])
    if target and target:IsA("Model") then return target end
    for _, obj in ipairs(node:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():find("dumpster", 1, true) then return obj end
    end
    return nil
end

local function getFixedDumpsterPos()
    local target = resolveFixedDumpster()
    if not target then
        return nil
    end
    local pos = getDumpsterPos(target)
    if not pos then
        return nil
    end
    return pos
end

local function canTpNow()
    return tick() - (Refs.LastTpTime or 0) >= Refs.TpStayDuration
end

local function getSafeLeafPos()
    if not canTpNow() then return nil end
    if not Refs.LeafFolder or not Refs.LeafSim then return nil end
    local hrp = getRoot()
    if not hrp then return nil end
    local origin = hrp.Position
    local canUseLeaf = Refs.LeafSim.canUseLeaf
    local candidates = {}
    for _, leaf in ipairs(Refs.LeafFolder:GetChildren()) do
        if leaf:IsA("BasePart") then
            local pos = leaf.Position
            local d = (pos - origin).Magnitude
            if d <= Refs.MaxTpDistance and d >= 5 then
                local ok, usable = pcall(canUseLeaf, leaf)
                if ok and usable then
                    table.insert(candidates, {pos = pos, dist = d})
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    for _, c in ipairs(candidates) do
        if countUnlockedLeavesNear(c.pos, 6) >= 2 then
            return c.pos
        end
    end
    return nil
end

local function GetCurrentInterval()
    if not Refs.AccelEnabled then
        return Refs.CollectInterval
    end
    local cycle = Refs.AccelDuration + Refs.AccelRestTime
    if cycle <= 0 then return Refs.CollectInterval end
    local pos = (tick() - Refs.AccelCycleStart) % cycle
    if pos < Refs.AccelDuration then
        return Refs.AccelIntervalSpeed
    end
    return Refs.CollectInterval
end

local function RefreshStatus()
    local function setStatus(txt, col)
        Refs.StatusText = txt
        local para = Refs.StatusPara
        if para and para.SetDesc then
            pcall(function() para:SetDesc(txt) end)
        end
    end
    if not Refs.LeafSim then
        setStatus("状态：模块加载失败，请重新执行", Color3.fromRGB(255, 100, 100))
        return
    end
    local leaves = LocalPlayer:GetAttribute("Leaves") or 0
    local capacity = LocalPlayer:GetAttribute("LeafCapacity") or 25
    if Refs.UserIntent then
        if Refs.PausedByBag then
            if Refs.AutoSell then
                setStatus("状态：自动出售中...", Color3.fromRGB(255, 200, 100))
            else
                setStatus("状态：背包已满，请出售", Color3.fromRGB(255, 100, 100))
            end
        else
            local accelTag = ""
            if Refs.AccelEnabled then
                local cycle = Refs.AccelDuration + Refs.AccelRestTime
                if cycle > 0 then
                    local pos = (tick() - Refs.AccelCycleStart) % cycle
                    if pos < Refs.AccelDuration then
                        accelTag = " [加速中]"
                    end
                end
            end
            setStatus("状态：自动收集中 (" .. leaves .. "/" .. capacity .. ")" .. accelTag, Color3.fromRGB(100, 255, 100))
        end
    else
        setStatus("状态：准备就绪 (" .. leaves .. "/" .. capacity .. ")", Color3.fromRGB(200, 200, 200))
    end
end

local function OnLeavesChanged()
    local leaves = LocalPlayer:GetAttribute("Leaves") or 0
    local capacity = LocalPlayer:GetAttribute("LeafCapacity") or 25
    if leaves >= capacity then
        if Refs.UserIntent and not Refs.PausedByBag then
            Refs.PausedByBag = true
            if not Refs.AutoSell then
                Notify("自动捡树叶", "背包已满，自动暂停。请出售。")
            end
        end
    else
        if Refs.PausedByBag then
            Refs.PausedByBag = false
        end
    end
    RefreshStatus()
end
LocalPlayer:GetAttributeChangedSignal("Leaves"):Connect(OnLeavesChanged)

Tab:Section({ Title = "拾取设置" })

Tab:Toggle({
    Title = "自动拾取",
    Default = false,
    Callback = function(state)
        if not Refs.LeafSim then
            Notify("自动捡树叶", "模块未加载")
            return
        end
        Refs.UserIntent = state == true
        if Refs.UserIntent then
            local hrp = getRoot()
            if hrp then Refs.OriginCFrame = hrp.CFrame end
        else
            Refs.PausedByBag = false
        end
        RefreshStatus()
    end,
})

Tab:Toggle({
    Title = "自动出售",
    Default = false,
    Callback = function(state) Refs.AutoSell = state == true end,
})

Tab:Toggle({
    Title = "自动寻叶",
    Default = false,
    Callback = function(state) Refs.AutoFarm = state == true end,
})

Tab:Toggle({
    Title = "只在解锁区域拾取",
    Default = false,
    Callback = function(state) Refs.AntiOutOfBounds = state == true end,
})

Tab:Button({
    Title = "一键出售（需靠近垃圾桶）",
    Callback = function()
        if not Refs.EmptyBackpack then
            Notify("自动捡树叶", "未找到出售事件")
            return
        end
        local leaves = LocalPlayer:GetAttribute("Leaves") or 0
        if leaves <= 0 then
            Notify("自动捡树叶", "背包已经是空的了")
            return
        end
        pcall(function() Refs.EmptyBackpack:FireServer() end)
    end,
})

local function SetNoClip(on)
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function() d.CanCollide = not on end)
        end
    end
end

local Tab2 = Window:Tab({
    Title = "人物修改",
    Icon = "user",
})

Tab2:Section({ Title = "移动", TextXAlignment = "Left", TextSize = 17 })

Tab2:Toggle({
    Title = "移速修改",
    Default = false,
    Callback = function(state)
        Refs.WalkEnabled = state == true
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Refs.WalkEnabled and Refs.WalkValue or 16
        end
    end,
})

Tab2:Slider({
    Title = "移速数值",
    Value = { Min = 16, Max = 300, Default = 24 },
    Increment = 1,
    Callback = function(val)
        if type(val) == "number" and val > 0 then
            Refs.WalkValue = val
            if Refs.WalkEnabled then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
    end,
})

Tab2:Toggle({
    Title = "飞行",
    Default = false,
    Callback = function(state)
        Refs.FlyEnabled = state == true
        local hrp = getRoot()
        if hrp and not Refs.FlyEnabled then
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
        end
    end,
})

Tab2:Input({
    Title = "飞行速度",
    Placeholder = "60",
    Callback = function(text)
        local v = tonumber(text)
        if v and v > 0 then Refs.FlySpeed = v end
    end,
})

Tab2:Toggle({
    Title = "穿墙",
    Default = false,
    Callback = function(state)
        Refs.NoClip = state == true
        SetNoClip(Refs.NoClip)
    end,
})

local UISMove = game:GetService("UserInputService")
local RSChar = game:GetService("RunService")

RSChar.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if Refs.WalkEnabled and hum and hum.WalkSpeed ~= Refs.WalkValue then
        hum.WalkSpeed = Refs.WalkValue
    end
    if Refs.NoClip then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local v = hrp.AssemblyLinearVelocity
            if v.Y < 0 then
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z) end)
            end
        end
    end
end)

RSChar.RenderStepped:Connect(function()
    if not Refs.FlyEnabled then return end
    local hrp = getRoot()
    if not hrp then return end
    local move = UISMove:GetMoveVector()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local dir = cam.CFrame.LookVector * (-move.Z) + cam.CFrame.RightVector * move.X
    if dir.Magnitude > 0 then dir = dir.Unit end
    pcall(function() hrp.AssemblyLinearVelocity = dir * Refs.FlySpeed end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and Refs.WalkEnabled then hum.WalkSpeed = Refs.WalkValue end
    if Refs.NoClip then SetNoClip(true) end
end)

task.spawn(function()
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        local ok, res = pcall(function()
            return require(ps:WaitForChild("LeafSim", 10))
        end)
        if ok and res then
            Refs.LeafSim = res
            Refs.LeafFolder = res.folder
            Refs.CollectMany = res.collectMany
        end
    end
    if not Refs.LeafSim then
        local rs = ReplicatedStorage:FindFirstChild("LeafSim")
        if rs then
            local ok, res = pcall(require, rs)
            if ok and res then
                Refs.LeafSim = res
                Refs.LeafFolder = res.folder
                Refs.CollectMany = res.collectMany
            end
        end
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        Refs.EmptyBackpack = remotes:FindFirstChild("EmptyBackpack")
    end
    local mapRegistry = ReplicatedStorage:FindFirstChild("MapRegistry")
    if mapRegistry then
        local ok, mr = pcall(require, mapRegistry)
        if ok and mr and mr.get then
            local ok2, dumpsters = pcall(function() return mr.get("Dumpsters") end)
            if ok2 then Refs.Dumpsters = dumpsters end
        end
    end
    if not Refs.Dumpsters then
        Refs.Dumpsters = workspace:FindFirstChild("Dumpsters")
    end
    RefreshStatus()
end)

local sharedOverlapParams = OverlapParams.new()
sharedOverlapParams.FilterType = Enum.RaycastFilterType.Include
local overlapFilterSet = false

task.spawn(function()
    while true do
        task.wait(GetCurrentInterval())

        if Refs.UserIntent and Refs.LeafSim then
            if Refs.PausedByBag and Refs.AutoSell and not Refs.IsTeleporting then
                Refs.IsTeleporting = true

                local dumpPos = getFixedDumpsterPos() or getBestDumpsterPos()
                local hrp = getRoot()
                if dumpPos and hrp then
                    local savedCFrame = hrp.CFrame
                    local ok = safeTeleport(dumpPos)
                    if ok then
                        task.wait(Refs.SellDelay)
                        pcall(function() Refs.EmptyBackpack:FireServer() end)
                        task.wait(Refs.SellDelay)
                        pcall(function()
                            local hrp2 = getRoot()
                            if hrp2 then hrp2.CFrame = savedCFrame end
                        end)
                    end
                end
                task.wait(Refs.SellTpCooldown)
                Refs.IsTeleporting = false
            elseif not Refs.PausedByBag then
                local hrp = getRoot()
                if hrp then
                    if not Refs.IsTeleporting then
                        Refs.OriginCFrame = hrp.CFrame
                        if isPositionSafe(hrp.Position) then
                            Refs.LastSafeCFrame = hrp.CFrame
                        end
                    end

                    if not overlapFilterSet and Refs.LeafFolder then
                        sharedOverlapParams.FilterDescendantsInstances = { Refs.LeafFolder }
                        overlapFilterSet = true
                    end

                    local current = LocalPlayer:GetAttribute("Leaves") or 0
                    local capacity = LocalPlayer:GetAttribute("LeafCapacity") or 25
                    local space = capacity - current
                    if space > 0 then
                        local parts = workspace:GetPartBoundsInRadius(hrp.Position, Refs.ScanRadius, sharedOverlapParams)
                        local batch = {}
                        local maxCount = math.min(space, Refs.MaxBatch)
                        local canUseLeaf = Refs.LeafSim.canUseLeaf

                        for _, part in ipairs(parts) do
                            if #batch >= maxCount then break end
                            if part:IsA("BasePart") then
                                local ok, usable = pcall(canUseLeaf, part)
                                if ok and usable then
                                    table.insert(batch, part)
                                end
                            end
                        end

                        if #batch > 0 then
                            pcall(function() Refs.CollectMany(batch) end)
                        elseif Refs.AutoFarm then
                            local leafPos = getSafeLeafPos()
                            if leafPos then
                                Refs.IsTeleporting = true
                                local ok = safeTeleport(leafPos)
                                if ok then
                                    Refs.LastTpTime = tick()
                                end
                                task.wait(0.15)
                                Refs.IsTeleporting = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Refs.AntiOutOfBounds and Refs.UserIntent and not Refs.IsTeleporting and not Refs.PausedByBag then
            local hrp = getRoot()
            if hrp then
                if isPositionSafe(hrp.Position) then
                    Refs.LastSafeCFrame = hrp.CFrame
                else
                    Refs.IsTeleporting = true
                    local dumpPos = getBestDumpsterPos()
                    if dumpPos then
                        local ok = safeTeleport(dumpPos)
                        if ok then
                            Refs.LastTpTime = tick()
                        end
                    elseif Refs.LastSafeCFrame then
                        local ok = safeTeleport(Refs.LastSafeCFrame.Position)
                        if ok then
                            Refs.LastTpTime = tick()
                        end
                    end
                    task.wait(0.15)
                    Refs.IsTeleporting = false
                end
            end
        end
    end
end)

OnLeavesChanged()
RefreshStatus()
