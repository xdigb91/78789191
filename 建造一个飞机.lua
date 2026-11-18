
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

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

local SET = {
    ALTITUDE   = 600,
    STALL_TIME = 4,
    LOOP_DELAY = 4,
}

local LaunchEvents = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LaunchEvents")
local LaunchRemote = LaunchEvents:WaitForChild("Launch")
local ReturnRemote = LaunchEvents:WaitForChild("Return")

local cashValue = nil
pcall(function()
    local ls = player:WaitForChild("leaderstats", 5)
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                cashValue = v
                break
            end
        end
    end
end)

local function getCash()
    return cashValue and cashValue.Value or -1
end

local function getRoot()
    local c = player.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart
    end
    return nil
end

local function holdAltitude(root)
    local cf = root.CFrame
    local p = cf.Position
    if p.Y < SET.ALTITUDE then
        root.CFrame = cf + Vector3.new(0, SET.ALTITUDE - p.Y, 0)
    end
end

local function oneRun()
    pcall(function() LaunchRemote:FireServer() end)
    task.wait(1.5)
    local root = getRoot()
    if not root then
        return 0, getCash()
    end
    local lastX = root.Position.X
    local lastMoveAt = os.clock()
    local runStartCash = getCash()
    while getgenv().BuildAPlaneFarmRunning do
        task.wait(0.5)
        root = getRoot()
        if not root then break end
        holdAltitude(root)
        local x = root.Position.X
        if x - lastX < 1 then
            if os.clock() - lastMoveAt > SET.STALL_TIME then
                break
            end
        else
            lastX = x
            lastMoveAt = os.clock()
        end
    end
    pcall(function() ReturnRemote:FireServer() end)
    task.wait(1.2)
    local endCash = getCash()
    local earned = 0
    if cashValue then
        earned = endCash - runStartCash
    end
    return earned, endCash
end

local function farmLoop(statusTag)
    local n = 0
    while getgenv().BuildAPlaneFarmRunning do
        n = n + 1
        local earned, cash = oneRun()
        if statusTag then
            statusTag:SetTitle("现金 " .. tostring(cash) .. "  |  第" .. n .. "轮 +" .. tostring(earned))
        end
        task.wait(SET.LOOP_DELAY)
    end
end

local BuyBlock = nil
pcall(function()
    BuyBlock = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShopEvents"):WaitForChild("BuyBlock")
end)
if not BuyBlock then
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "BuyBlock" then
            BuyBlock = v
            break
        end
    end
end

local KNOWN_PARTS = {
    "block_1", "block_2", "block_3",
    "half_block", "reinforced_block", "glass_block", "metal_block", "titanium_block",
    "wing_1", "wing_2", "wing_3", "better_wing", "delta_wing",
    "tail_1", "better_tail", "titanium_tail",
    "fuel_1", "fuel_2", "fuel_3", "better_fuel", "barrel_fuel", "refined_fuel",
    "propeller_1", "propeller_2", "propeller_3", "better_propeller",
    "op_propeller", "helicopter_propeller",
    "seat_1", "landing_gears",
    "balloon", "balloon_deployer", "boost_1", "rocket_booster", "plasma_booster",
    "missile_1", "futuristic_missile", "shield",
}

local KNOWN_EQUIPS = {
    "paintbrush", "sign", "wrench",
}

local ITEM_CN = {
    block_1 = "方块", block_2 = "方块2", block_3 = "方块3",
    half_block = "半方块", reinforced_block = "强化方块",
    glass_block = "玻璃方块", metal_block = "金属方块", titanium_block = "钛方块",
    wing_1 = "机翼", wing_2 = "机翼2", wing_3 = "机翼3",
    better_wing = "优质机翼", delta_wing = "三角翼",
    tail_1 = "尾翼", better_tail = "优质尾翼", titanium_tail = "钛尾翼",
    fuel_1 = "燃料箱", fuel_2 = "燃料箱2", fuel_3 = "燃料箱3",
    better_fuel = "优质燃料", barrel_fuel = "桶装燃料", refined_fuel = "精炼燃料",
    propeller_1 = "螺旋桨", propeller_2 = "螺旋桨2", propeller_3 = "螺旋桨3",
    better_propeller = "优质螺旋桨", op_propeller = "最强螺旋桨",
    helicopter_propeller = "直升机螺旋桨",
    seat_1 = "座椅", landing_gears = "起落架",
    balloon = "气球", balloon_deployer = "气球部署器",
    boost_1 = "推进器", rocket_booster = "火箭推进器", plasma_booster = "等离子推进器",
    missile_1 = "导弹", futuristic_missile = "未来导弹",
    shield = "能量护盾",
    paintbrush = "油漆刷", sign = "标志", wrench = "扳手",
}

local function displayName(nm)
    return ITEM_CN[nm] or nm
end

local cart = getgenv().BuildAPlaneCart3
if type(cart) ~= "table" then
    cart = {}
    getgenv().BuildAPlaneCart3 = cart
end

local function buyOne(itemName)
    return pcall(function()
        BuyBlock:FireServer(itemName)
    end)
end

local function buyList(list, statusTag, tagPrefix)
    local bought, failed = 0, 0
    for _, nm in ipairs(list) do
        if buyOne(nm) then
            bought = bought + 1
        else
            failed = failed + 1
        end
        task.wait(0.1)
    end
    if statusTag then
        statusTag:SetTitle(tagPrefix .. "本次购买 " .. tostring(bought) .. " 件  |  失败 " .. tostring(failed))
    end
    WindUI:Notify({ Title = "购买完成", Content = "成功 " .. tostring(bought) .. " 件，失败 " .. tostring(failed) .. " 件", Duration = 4 })
end

local function buySelected(statusTag)
    local list = {}
    for nm, on in pairs(cart) do
        if on then table.insert(list, nm) end
    end
    buyList(list, statusTag, "[已选] ")
end

local function autoBuySelectedLoop(statusTag)
    local rounds = 0
    while getgenv().BuildAPlaneAutoCart3 do
        rounds = rounds + 1
        local list = {}
        for nm, on in pairs(cart) do
            if on then table.insert(list, nm) end
        end
        local bought = 0
        for _, nm in ipairs(list) do
            if not getgenv().BuildAPlaneAutoCart3 then break end
            if buyOne(nm) then bought = bought + 1 end
            task.wait(0.1)
        end
        if statusTag then
            statusTag:SetTitle("第" .. tostring(rounds) .. "轮 已购 " .. tostring(bought) .. " / 选中 " .. tostring(#list))
        end
        task.wait(5)
    end
end

local PROPS = { "propeller_0", "propeller_1", "propeller_2", "propeller_3", "propeller_blood" }
local BlockInfo = nil
local origPropForce = nil
pcall(function()
    local mods = ReplicatedStorage:FindFirstChild("Modules")
    if mods and mods:FindFirstChild("Utilities") then
        local mu = mods.Utilities
        if mu:FindFirstChild("BlocksUtil") then
            local BLK = require(mu.BlocksUtil)
            BlockInfo = BLK and BLK.BlockInfo
        end
    end
end)

local boostSpeed = 150
local boostOn = false

local function setPropForce(v)
    if not BlockInfo then return false end
    for _, p in ipairs(PROPS) do
        local bd = BlockInfo[p]
        if bd then
            bd.Force = v
        end
    end
    return true
end

local function storeOrigForce()
    origPropForce = {}
    if not BlockInfo then return end
    for _, p in ipairs(PROPS) do
        local bd = BlockInfo[p]
        if bd then
            origPropForce[p] = bd.Force
        end
    end
end

local function restoreOrigForce()
    if not BlockInfo or not origPropForce then return end
    for p, v in pairs(origPropForce) do
        local bd = BlockInfo[p]
        if bd then bd.Force = v end
    end
    origPropForce = nil
end

local Window = WindUI:CreateWindow({
Title = "建造飞机",
Author = "建造飞机",
})

local StatusTag = Window:Tag({
    Title = "现金 " .. tostring(getCash()),
    Color = Color3.fromRGB(255, 255, 255)
})

Window:Tag({ Title = "建造飞机", Color = Color3.fromHex("#7FDBFF") })

local farmTab = Window:Tab({ Title = "刷钱", Icon = "settings" })
local farmSec = farmTab:Section({ Title = "刷钱控制", TextXAlignment = "Left", TextSize = 17 })

farmSec:Toggle({
    Title = "自动刷钱",
    Default = false,
    Callback = function(state)
        getgenv().BuildAPlaneFarmRunning = state
        if state then
            task.spawn(farmLoop, StatusTag)
            WindUI:Notify({ Title = "已启动", Content = "高空巡航刷钱开始", Duration = 3 })
        else
            WindUI:Notify({ Title = "已停止", Content = "刷钱循环已停止", Duration = 3 })
        end
    end
})

farmSec:Slider({
    Title = "巡航高度",
    Value = { Min = 300, Max = 1500, Default = SET.ALTITUDE },
    Increment = 50,
    Callback = function(v)
        SET.ALTITUDE = v
    end
})

farmSec:Slider({
    Title = "熄火判定(秒)",
    Value = { Min = 1, Max = 10, Default = SET.STALL_TIME },
    Increment = 1,
    Callback = function(v)
        SET.STALL_TIME = v
    end
})

farmSec:Slider({
    Title = "循环间隔(秒)",
    Value = { Min = 1, Max = 10, Default = SET.LOOP_DELAY },
    Increment = 1,
    Callback = function(v)
        SET.LOOP_DELAY = v
    end
})

farmSec:Button({
    Title = "手动结算",
    Callback = function()
        pcall(function() ReturnRemote:FireServer() end)
        WindUI:Notify({ Title = "已结算", Content = "已请求 Return 结算", Duration = 3 })
    end
})

farmSec:Toggle({
    Title = "移速加速",
    Default = false,
    Callback = function(state)
        boostOn = state
        if state then
            if not BlockInfo then
                WindUI:Notify({ Title = "错误", Content = "未找到BlocksUtil，加速不可用", Duration = 4 })
                return
            end
            storeOrigForce()
            setPropForce(boostSpeed)
            WindUI:Notify({ Title = "已启动", Content = "螺旋桨推力已提升，起飞后生效", Duration = 3 })
        else
            restoreOrigForce()
            WindUI:Notify({ Title = "已停止", Content = "螺旋桨推力已恢复", Duration = 3 })
        end
    end
})

farmSec:Slider({
    Title = "移速值",
    Value = { Min = 60, Max = 400, Default = boostSpeed },
    Increment = 10,
    Callback = function(v)
        boostSpeed = v
        if boostOn and BlockInfo then
            setPropForce(v)
        end
    end
})

local shopTab = Window:Tab({ Title = "购物", Icon = "settings" })

local opSection = shopTab:Section({ Title = "操作", TextXAlignment = "Left", TextSize = 17 })

opSection:Toggle({
    Title = "自动购买已选",
    Default = false,
    Callback = function(state)
        getgenv().BuildAPlaneAutoCart3 = state
        if state then
            task.spawn(autoBuySelectedLoop, StatusTag)
            WindUI:Notify({ Title = "已启动", Content = "自动购买已选物品", Duration = 3 })
        else
            WindUI:Notify({ Title = "已停止", Content = "自动购买已停止", Duration = 3 })
        end
    end
})

opSection:Button({
    Title = "购买已选物品",
    Callback = function()
        task.spawn(buySelected, StatusTag)
    end
})

local itemToggles = {}

local function buildListSection(sectionTitle, list)
    local sec = shopTab:Section({ Title = sectionTitle, TextXAlignment = "Left", TextSize = 15 })
    for _, nm in ipairs(list) do
        local tg = sec:Toggle({
            Title = displayName(nm),
            Default = cart[nm] == true,
            Callback = function(state)
                cart[nm] = state
            end
        })
        itemToggles[nm] = tg
    end
    sec:Button({
        Title = "全选本区",
        Callback = function()
            for _, nm in ipairs(list) do
                cart[nm] = true
                local tg = itemToggles[nm]
                if tg then pcall(function() tg:SetValue(true) end) end
            end
            StatusTag:SetTitle("已全选: " .. sectionTitle)
        end
    })
    sec:Button({
        Title = "清空本区",
        Callback = function()
            for _, nm in ipairs(list) do
                cart[nm] = false
                local tg = itemToggles[nm]
                if tg then pcall(function() tg:SetValue(false) end) end
            end
            StatusTag:SetTitle("已清空: " .. sectionTitle)
        end
    })
end

buildListSection("零件（37 种）", KNOWN_PARTS)
buildListSection("装备（3 种）", KNOWN_EQUIPS)

