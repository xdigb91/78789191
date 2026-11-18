
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

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

local bytenetrel = ReplicatedStorage:WaitForChild("ByteNetReliable", 10)
local ok1, wpnpkts = pcall(require, ReplicatedStorage.Common.Packets.WeaponPackets)
local ok2, wpnclnt = pcall(require, lp.PlayerScripts.Start.Game.WeaponClient)
local ok3, wpnmng = pcall(require, ReplicatedStorage.Common.Managers.WeaponManager)
local ok4, vwmdlclnt = pcall(require, lp.PlayerScripts.Start.Game.ViewmodelClient)
local ok5, mngmpkts = pcall(require, ReplicatedStorage.Common.Packets.MainGamePackets)
local ok6, qstpkts = pcall(require, ReplicatedStorage.Common.Packets.QuestPackets)
local ok7, lvlrewpkts = pcall(require, ReplicatedStorage.Common.Packets.LevelRewardPackets)
local ok8, battlepasspkts = pcall(require, ReplicatedStorage.Common.Packets.BattlepassPackets)
local ok9, dataclnt = pcall(require, lp.PlayerScripts.Start.Backend.DataClient)
if not bytenetrel or not ok1 or not ok2 then
    WindUI:Notify({ Title = "错误", Content = "未获取武器接口，请进入对局后重试", Duration = 4 })
    return
end

local S = {
    killOn = false, fireInterval = 0.03, killRange = 0, infFire = false,
    killAura = false, auraRange = 50, hitboxOn = false, hitboxSize = 8,
    aimOn = false, aimSmooth = 0.15, fovVis = false, fovRadius = 150,
    silentOn = false, hitChance = 100, wallbang = false, infDist = false,
    triggerOn = false, autoShoot = false, autoShootDelay = 0.05,
    espOn = false, boxStyle = 2, nameEsp = false, distEsp = false,
    hpEsp = false, skelEsp = false, tracerOn = false, chamsOn = false,
    dangerOn = false,
    noRecoil = false, instReload = false, infAmmo = false, maxXp = false,
    noKnifeCd = false, ffBy = false,
    speedOn = false, speedVal = 50, jumpOn = false, jumpVal = 50,
    noclipOn = false, spinOn = false, spinSpeed = 180, thirdPerson = false,
    antiAfk = false, autoDeploy = false, instRespawn = false,
    autoQuests = false, autoLvl = false, autoBp = false,
    hitNotifs = false, killFeed = false, killFeedText = "你击杀了",
}
local curTarget = nil
local targetCount = 0
local ws_en = false
local jp_en = false

local function getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getTargs()
    local t = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            if hum and hrp and head and hum.Health > 0 then
                table.insert(t, { char = plr.Character, head = head, hrp = hrp, name = plr.DisplayName or plr.Name })
            end
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local head = obj:FindFirstChild("Head")
            if not Players:GetPlayerFromCharacter(obj) and hum and hrp and head and hum.Health > 0 then
                table.insert(t, { char = obj, head = head, hrp = hrp, name = obj.Name })
            end
        end
    end
    return t
end

local function getTargsByRange()
    local myRoot = getRoot()
    local t = getTargs()
    if S.killRange > 0 and myRoot then
        local out = {}
        for _, tg in ipairs(t) do
            if (tg.hrp.Position - myRoot.Position).Magnitude <= S.killRange then
                table.insert(out, tg)
            end
        end
        return out
    end
    return t
end

local wpnData = {}
local origConstants = {}
if ok3 and wpnmng then
    pcall(function()
        local list = wpnmng.getWeapons()
        for name, data in pairs(list) do
            data._firerate = data.firerate
            data._reloadTime = data.reloadTime
            data._magazine = data.magazine
            wpnData[name] = data
        end
        origConstants.DEFAULT_FIRERATE = wpnmng.Constants.DEFAULT_FIRERATE
        origConstants.DEFAULT_PISTOL_FIRERATE = wpnmng.Constants.DEFAULT_PISTOL_FIRERATE
        origConstants.DEFAULT_RELOAD_TIME = wpnmng.Constants.DEFAULT_RELOAD_TIME
        origConstants.DEFAULT_PISTOL_RELOAD_TIME = wpnmng.Constants.DEFAULT_PISTOL_RELOAD_TIME
        origConstants.DEFAULT_MAGAZINE = wpnmng.Constants.DEFAULT_MAGAZINE
    end)
end

local function applyWpnMods()
    if not ok3 then return end
    for _, data in pairs(wpnData) do
        data.firerate = S.infFire and 9999 or (data._firerate or data.firerate)
        data.reloadTime = S.instReload and 0 or (data._reloadTime or data.reloadTime)
        data.magazine = S.infAmmo and 999 or (data._magazine or data.magazine)
    end
    pcall(function()
        wpnmng.Constants.DEFAULT_FIRERATE = S.infFire and 9999 or (origConstants.DEFAULT_FIRERATE or 2)
        wpnmng.Constants.DEFAULT_PISTOL_FIRERATE = S.infFire and 9999 or (origConstants.DEFAULT_PISTOL_FIRERATE or 4)
        wpnmng.Constants.DEFAULT_RELOAD_TIME = S.instReload and 0 or (origConstants.DEFAULT_RELOAD_TIME or 0.75)
        wpnmng.Constants.DEFAULT_PISTOL_RELOAD_TIME = S.instReload and 0 or (origConstants.DEFAULT_PISTOL_RELOAD_TIME or 0.5)
        wpnmng.Constants.DEFAULT_MAGAZINE = S.infAmmo and 999 or (origConstants.DEFAULT_MAGAZINE or 1)
    end)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and self == bytenetrel then
        if S.killOn and curTarget then
            local args = {...}
            if typeof(args[2]) == "table" and typeof(args[2][1]) == "Instance" then
                args[2][1] = curTarget.char
                args[2][2] = curTarget.head
            end
        elseif S.silentOn and silentTarg then
            local args = {...}
            if typeof(args[2]) == "table" and typeof(args[2][1]) == "Instance" then
                if math.random(1, 100) <= (S.hitChance or 100) then
                    args[2][1] = silentTarg.char
                    args[2][2] = silentTarg.head
                end
            end
        end
    elseif method == "FindFirstChild" and S.ffBy then
        local args = {...}
        if args[1] == "ForceField" then return nil end
    end
    return oldNamecall(self, ...)
end))

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if key == "WalkSpeed" and ws_en and self:IsA("Humanoid") then return S.speedVal end
        if key == "JumpPower" and jp_en and self:IsA("Humanoid") then return S.jumpVal end
    end
    return oldIndex(self, key)
end))
local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
    if not checkcaller() and key == "AssemblyLinearVelocity" and typeof(value) == "Vector3" then
        if self:IsA("BasePart") and self.Name == "HumanoidRootPart" then
            local char = self:FindFirstAncestorOfClass("Model")
            if char and char == lp.Character then
                if ws_en and value.X == 0 and value.Z == 0 then return end
                if jp_en and value.Y < -40 then return end
            end
        end
    end
    return oldNewIndex(self, key, value)
end))

local origVmShoot
if ok4 and vwmdlclnt and vwmdlclnt.shoot then
    origVmShoot = vwmdlclnt.shoot
end

if ok1 and wpnpkts and wpnpkts.hitResult and wpnpkts.hitResult.listen then
    pcall(function()
        wpnpkts.hitResult.listen(function(data)
            if S.hitNotifs then
                task.spawn(function()
                    pcall(function()
                        local tname = (typeof(data.target) == "Instance" and data.target.Name) or "敌人"
                        local msg = "命中 " .. tname
                        WindUI:Notify({ Title = "命中反馈", Content = msg, Duration = 2 })
                    end)
                end)
            end
        end)
    end)
end

local loopConn = nil
local function startKillLoop()
    if loopConn then loopConn:Disconnect() end
    loopConn = RunService.Heartbeat:Connect(function()
        if not S.killOn then return end
        local targets = getTargsByRange()
        targetCount = #targets
        for _, t in ipairs(targets) do
            if not S.killOn then break end
            curTarget = t
            pcall(function() wpnclnt.fire() end)
            task.wait(S.fireInterval)
        end
    end)
end

local auraConn = nil
local function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.Heartbeat:Connect(function()
        if not S.killAura then return end
        local myRoot = getRoot()
        if not myRoot then return end
        for _, t in ipairs(getTargs()) do
            if (t.hrp.Position - myRoot.Position).Magnitude <= S.auraRange then
                curTarget = t
                pcall(function() wpnclnt.fire() end)
            end
        end
    end)
end

local hbPoints = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg" }
local hbConn = nil
local function startHbLoop()
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not S.hitboxOn then return end
        for _, t in ipairs(getTargs()) do
            for _, n in ipairs(hbPoints) do
                local p = t.char:FindFirstChild(n)
                if p and p:IsA("BasePart") then
                    pcall(function() p.Size = Vector3.new(S.hitboxSize, S.hitboxSize, S.hitboxSize) end)
                end
            end
        end
    end)
end

local function pickAimTarget()
    local mouse = UserInputService:GetMouseLocation()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local myRoot = getRoot()
    local best, bestScore = nil, math.huge
    for _, t in ipairs(getTargs()) do
        local sp, onScreen = cam:WorldToViewportPoint(t.head.Position)
        if onScreen then
            local sd = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
            if sd < bestScore then best = t bestScore = sd end
        end
    end
    return best
end

local silentTarg = nil
local espDraws = {}
local function getEsp(char)
    if not espDraws[char] then
        espDraws[char] = {
            box = Drawing.new("Square"), cbox = { Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line") },
            name = Drawing.new("Text"), dist = Drawing.new("Text"),
            hpbg = Drawing.new("Square"), hp = Drawing.new("Square"),
            trac = Drawing.new("Line"), skel = Drawing.new("Line"),
        }
        for i = 1, 4 do
            espDraws[char].cbox[i].Thickness = 1
        end
    end
    return espDraws[char]
end
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Radius = S.fovRadius
fovCircle.Color = Color3.fromRGB(100, 100, 255)
fovCircle.Visible = false

RunService.RenderStepped:Connect(function(dt)
    local cam = Workspace.CurrentCamera
    local mp = UserInputService:GetMouseLocation()
    local myRoot = getRoot()

    if S.silentOn then
        silentTarg = pickAimTarget()
    else
        silentTarg = nil
    end

    if S.aimOn then
        local t = pickAimTarget()
        if t and cam then
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, t.head.Position), S.aimSmooth)
        end
    end

    if S.fovVis and cam then
        fovCircle.Visible = true
        fovCircle.Position = mp
        fovCircle.Radius = S.fovRadius
    else
        fovCircle.Visible = false
    end

    if S.triggerOn and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local t = pickAimTarget()
        if t then
            pcall(function() wpnclnt.fire() end)
        end
    end

    if S.autoShoot then
        local t = pickAimTarget()
        if t then
            pcall(function() wpnclnt.fire() end)
        end
    end

    if S.spinOn and myRoot then
        myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(S.spinSpeed * dt), 0)
    end

    if S.killFeed and lp.Character then
        pcall(function()
            local t = lp.PlayerGui:FindFirstChild("Gameplay") and lp.PlayerGui.Gameplay:FindFirstChild("Kill")
            if t and t.Visible then
                local tn = t:FindFirstChild("Tabs") and t.Tabs:FindFirstChild("TargetName")
                if tn then tn.Text = S.killFeedText end
            end
        end)
    end

    if S.espOn and cam then
        for _, t in ipairs(getTargs()) do
            local d = getEsp(t.char)
            local sp, onScreen = cam:WorldToViewportPoint(t.hrp.Position)
            if onScreen then
                local topSP = cam:WorldToViewportPoint(t.hrp.Position + Vector3.new(0, 2.8, 0))
                local botSP = cam:WorldToViewportPoint(t.hrp.Position - Vector3.new(0, 2.8, 0))
                local h = math.abs(botSP.Y - topSP.Y)
                local w = h * 0.55
                local bx, by = sp.X - w / 2, topSP.Y
                local col = Color3.fromRGB(100, 255, 255)

                if S.boxStyle == 1 then
                    d.box.Visible = true d.box.Color = col d.box.Thickness = 1 d.box.Filled = false
                    d.box.Size = Vector2.new(w, h) d.box.Position = Vector2.new(bx, by)
                    for i = 1, 4 do d.cbox[i].Visible = false end
                elseif S.boxStyle == 2 then
                    d.box.Visible = false
                    local lw = math.max(4, w * 0.25)
                    local o = math.max(2, h * 0.1)
                    local P = {
                        { Vector2.new(bx, by), Vector2.new(bx + lw, by), Vector2.new(bx + lw, by + o), Vector2.new(bx, by + o) },
                        { Vector2.new(bx + w, by), Vector2.new(bx + w - lw, by), Vector2.new(bx + w - lw, by + o), Vector2.new(bx + w, by + o) },
                        { Vector2.new(bx, by + h), Vector2.new(bx + lw, by + h), Vector2.new(bx + lw, by + h - o), Vector2.new(bx, by + h - o) },
                        { Vector2.new(bx + w, by + h), Vector2.new(bx + w - lw, by + h), Vector2.new(bx + w - lw, by + h - o), Vector2.new(bx + w, by + h - o) },
                    }
                    for i = 1, 4 do
                        local ln = d.cbox[i]
                        ln.Visible = true ln.Color = col ln.Thickness = 1
                        ln.From = P[i][1] ln.To = P[i][2]
                    end
                else
                    d.box.Visible = false
                    for i = 1, 4 do d.cbox[i].Visible = false end
                end

                if S.nameEsp then
                    d.name.Visible = true d.name.Text = t.name d.name.Color = Color3.new(1, 1, 1)
                    d.name.Position = Vector2.new(sp.X, by - 16) d.name.Size = 13 d.name.Center = true d.name.Outline = true
                else d.name.Visible = false end

                if S.distEsp and myRoot then
                    d.dist.Visible = true d.dist.Text = math.floor((t.hrp.Position - myRoot.Position).Magnitude) .. "m"
                    d.dist.Color = Color3.fromRGB(180, 180, 180) d.dist.Position = Vector2.new(sp.X, by + h + 4)
                    d.dist.Size = 11 d.dist.Center = true d.dist.Outline = true
                else d.dist.Visible = false end

                if S.hpEsp then
                    d.hpbg.Visible = true d.hp.Visible = true
                    d.hpbg.Color = Color3.new(0, 0, 0) d.hpbg.Size = Vector2.new(3, h) d.hpbg.Position = Vector2.new(bx - 5, by)
                    d.hp.Color = Color3.fromRGB(0, 255, 0) d.hp.Size = Vector2.new(3, h) d.hp.Position = Vector2.new(bx - 5, by)
                else d.hpbg.Visible = false d.hp.Visible = false end

                if S.tracerOn then
                    d.trac.Visible = true d.trac.Color = Color3.fromRGB(100, 100, 255) d.trac.Thickness = 1
                    d.trac.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    d.trac.To = Vector2.new(sp.X, sp.Y)
                else d.trac.Visible = false end

                if S.skelEsp then
                    d.skel.Visible = true d.skel.Color = Color3.fromRGB(255, 100, 255) d.skel.Thickness = 1
                    local hd, ut = t.char:FindFirstChild("Head"), t.char:FindFirstChild("UpperTorso")
                    local lt = t.char:FindFirstChild("LowerTorso")
                    if hd and ut and lt then
                        local p1 = cam:WorldToViewportPoint(hd.Position)
                        local p2 = cam:WorldToViewportPoint(ut.Position)
                        local p3 = cam:WorldToViewportPoint(lt.Position)
                        d.skel.From = Vector2.new(p1.X, p1.Y) d.skel.To = Vector2.new(p2.X, p2.Y)
                    end
                else d.skel.Visible = false end
            else
                local d = espDraws[t.char]
                if d then
                    d.box.Visible = false
                    for i = 1, 4 do d.cbox[i].Visible = false end
                    d.name.Visible = false d.dist.Visible = false d.hpbg.Visible = false d.hp.Visible = false
                    d.trac.Visible = false d.skel.Visible = false
                end
            end
        end
    else
        for char, d in pairs(espDraws) do
            d.box.Visible = false
            for i = 1, 4 do d.cbox[i].Visible = false end
            d.name.Visible = false d.dist.Visible = false d.hpbg.Visible = false d.hp.Visible = false
            d.trac.Visible = false d.skel.Visible = false
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        if S.speedOn and hum.WalkSpeed ~= S.speedVal then
            ws_en = true
            hum.WalkSpeed = S.speedVal
        elseif not S.speedOn and ws_en then
            ws_en = false
            hum.WalkSpeed = 16
        end
        if S.jumpOn and hum.JumpPower ~= S.jumpVal then
            jp_en = true
            hum.JumpPower = S.jumpVal
        elseif not S.jumpOn and jp_en then
            jp_en = false
            hum.JumpPower = 50
        end
    end
end)
RunService.Stepped:Connect(function()
    if S.noclipOn then
        local c = lp.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end
    if S.infFire then
        pcall(function() wpnclnt.resetBullets(true) end)
    end
end)

local tpConn = nil
local function setThirdPerson(on)
    if on then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 128
        if ok2 and wpnclnt and wpnclnt.scope then wpnclnt.scope = function() end end
        if not tpConn then
            tpConn = lp:GetPropertyChangedSignal("CameraMode"):Connect(function()
                if lp.CameraMode ~= Enum.CameraMode.Classic then lp.CameraMode = Enum.CameraMode.Classic end
            end)
        end
    else
        if tpConn then tpConn:Disconnect() tpConn = nil end
        if ok2 and wpnclnt and wpnclnt.scope and origScope then wpnclnt.scope = origScope end
    end
end
local origScope = ok2 and wpnclnt and wpnclnt.scope

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.antiAfk then
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end
        if S.autoDeploy and ok5 and mngmpkts and mngmpkts.deploy then
            pcall(function() mngmpkts.deploy.send() end)
        end
        if S.instRespawn and ok5 and mngmpkts and mngmpkts.respawn then
            pcall(function()
                local gi = lp.PlayerGui:FindFirstChild("Game Interface")
                if gi and gi:FindFirstChild("Deathscreen") and gi.Deathscreen.Visible then
                    mngmpkts.respawn.send(true)
                end
            end)
        end
        if S.autoQuests then
            if ok6 and qstpkts then
                for i = 1, 3 do pcall(function() qstpkts.claimDailyQuest.send(i) end) end
                for i = 1, 3 do pcall(function() qstpkts.claimHourlyQuest.send(i) end) end
            end
        end
        if S.autoBp and ok8 and battlepasspkts then
            for i = 1, 30 do
                pcall(function() battlepasspkts.claimItem.send({ tierIndex = i, isPremiumTier = false }) end)
                pcall(function() battlepasspkts.claimItem.send({ tierIndex = i, isPremiumTier = true }) end)
            end
        end
        if S.autoLvl and ok7 and lvlrewpkts and ok9 and dataclnt then
            pcall(function()
                local level = dataclnt.getData().Data.level or 1
                for i = 1, level do
                    pcall(function() lvlrewpkts.claimLevelReward.send(i) end)
                end
                S.autoLvl = false
            end)
        end
    end
end)

local Window = WindUI:CreateWindow({
Title = "[FPS]一键点击",
Author = "XJW",
})

if Window then
    pcall(function() Window.IsPC = false end)
end

local StatusTag = Window:Tag({ Title = "待开启 | 0 目标", Color = Color3.fromRGB(255, 255, 255) })
Window:Tag({ Title = "[FPS]一键点击", Color = Color3.fromHex("#FF6B6B") })

local killTab = Window:Tab({ Title = "击杀", Icon = "settings" })
local killSec = killTab:Section({ Title = "击杀控制", TextXAlignment = "Left", TextSize = 17 })

killSec:Toggle({
    Title = "全图击杀",
    Default = false,
    Callback = function(state)
        S.killOn = state
        if state then
            curTarget = nil
            startKillLoop()
            StatusTag:SetTitle("运行中 | " .. targetCount .. " 目标")
            WindUI:Notify({ Title = "已启动", Content = "全图击杀开始", Duration = 3 })
        else
            curTarget = nil
            if loopConn then loopConn:Disconnect() loopConn = nil end
            StatusTag:SetTitle("已停止")
            WindUI:Notify({ Title = "已停止", Content = "全图击杀已停止", Duration = 3 })
        end
    end
})
killSec:Toggle({
    Title = "无限射速",
    Default = false,
    Callback = function(state)
        S.infFire = state
        applyWpnMods()
        WindUI:Notify({ Title = state and "已开启" or "已关闭", Content = "无限射速（解除射速上限）", Duration = 3 })
    end
})
killSec:Slider({
    Title = "开火间隔(秒)",
    Value = { Min = 0.005, Max = 0.2, Default = 0.03 },
    Increment = 0.005,
    Callback = function(v) S.fireInterval = v end
})
killSec:Slider({
    Title = "击杀范围",
    Value = { Min = 0, Max = 500, Default = 0 },
    Increment = 10,
    Callback = function(v) S.killRange = v end
})
killSec:Toggle({
    Title = "击杀光环",
    Default = false,
    Callback = function(state)
        S.killAura = state
        if state then startAuraLoop() else if auraConn then auraConn:Disconnect() auraConn = nil end end
    end
})
killSec:Slider({
    Title = "光环范围",
    Value = { Min = 10, Max = 200, Default = 50 },
    Increment = 10,
    Callback = function(v) S.auraRange = v end
})
killSec:Toggle({
    Title = "命中框扩大",
    Default = false,
    Callback = function(state)
        S.hitboxOn = state
        if state then startHbLoop() else if hbConn then hbConn:Disconnect() hbConn = nil end end
    end
})
killSec:Slider({
    Title = "命中框大小",
    Value = { Min = 1, Max = 30, Default = 8 },
    Increment = 1,
    Callback = function(v) S.hitboxSize = v end
})
killSec:Button({
    Title = "刷新目标统计",
    Callback = function()
        targetCount = #getTargsByRange()
        StatusTag:SetTitle((S.killOn and "运行中" or "待开启") .. " | " .. targetCount .. " 目标")
    end
})

local aimTab = Window:Tab({ Title = "瞄准", Icon = "crosshair" })
local aimSec = aimTab:Section({ Title = "瞄准控制", TextXAlignment = "Left", TextSize = 17 })

aimSec:Toggle({
    Title = "自动瞄准",
    Default = false,
    Callback = function(state) S.aimOn = state end
})
aimSec:Slider({
    Title = "瞄准平滑度",
    Value = { Min = 0.01, Max = 1, Default = 0.15 },
    Increment = 0.01,
    Callback = function(v) S.aimSmooth = v end
})
aimSec:Toggle({
    Title = "显示FOV圈",
    Default = false,
    Callback = function(state) S.fovVis = state end
})
aimSec:Slider({
    Title = "FOV半径",
    Value = { Min = 20, Max = 600, Default = 150 },
    Increment = 10,
    Callback = function(v) S.fovRadius = v end
})
aimSec:Toggle({
    Title = "静默瞄准",
    Default = false,
    Callback = function(state) S.silentOn = state end
})
aimSec:Slider({
    Title = "命中率(%)",
    Value = { Min = 1, Max = 100, Default = 100 },
    Increment = 1,
    Callback = function(v) S.hitChance = v end
})
aimSec:Toggle({
    Title = "无限距离",
    Default = false,
    Callback = function(state) S.infDist = state end
})
aimSec:Toggle({
    Title = "触发扳机",
    Default = false,
    Callback = function(state) S.triggerOn = state end
})
aimSec:Toggle({
    Title = "自动开火",
    Default = false,
    Callback = function(state) S.autoShoot = state end
})
aimSec:Slider({
    Title = "自动开火间隔",
    Value = { Min = 0.01, Max = 0.5, Default = 0.05 },
    Increment = 0.01,
    Callback = function(v) S.autoShootDelay = v end
})

local espTab = Window:Tab({ Title = "透视", Icon = "eye" })
local espSec = espTab:Section({ Title = "透视控制", TextXAlignment = "Left", TextSize = 17 })

espSec:Toggle({
    Title = "透视开关",
    Default = false,
    Callback = function(state) S.espOn = state end
})
espSec:Slider({
    Title = "方框样式 (0无 1全框 2角框)",
    Value = { Min = 0, Max = 2, Default = 2 },
    Increment = 1,
    Callback = function(v) S.boxStyle = v end
})
espSec:Toggle({
    Title = "显示名字",
    Default = false,
    Callback = function(state) S.nameEsp = state end
})
espSec:Toggle({
    Title = "显示距离",
    Default = false,
    Callback = function(state) S.distEsp = state end
})
espSec:Toggle({
    Title = "显示血条",
    Default = false,
    Callback = function(state) S.hpEsp = state end
})
espSec:Toggle({
    Title = "显示骨架",
    Default = false,
    Callback = function(state) S.skelEsp = state end
})
espSec:Toggle({
    Title = "射线透视",
    Default = false,
    Callback = function(state) S.tracerOn = state end
})
espSec:Toggle({
    Title = "发光透视",
    Default = false,
    Callback = function(state) S.chamsOn = state end
})
espSec:Toggle({
    Title = "危险指示器",
    Default = false,
    Callback = function(state) S.dangerOn = state end
})

local wpnTab = Window:Tab({ Title = "武器", Icon = "sword" })
local wpnSec = wpnTab:Section({ Title = "武器修改", TextXAlignment = "Left", TextSize = 17 })

wpnSec:Toggle({
    Title = "无后坐力",
    Default = false,
    Callback = function(state)
        S.noRecoil = state
        if ok4 and vwmdlclnt then
            if state then vwmdlclnt.shoot = function() end
            else vwmdlclnt.shoot = origVmShoot end
        end
    end
})
wpnSec:Toggle({
    Title = "秒换弹",
    Default = false,
    Callback = function(state)
        S.instReload = state
        applyWpnMods()
    end
})
wpnSec:Toggle({
    Title = "无限弹药",
    Default = false,
    Callback = function(state)
        S.infAmmo = state
        applyWpnMods()
    end
})
wpnSec:Toggle({
    Title = "最大经验",
    Default = false,
    Callback = function(state)
        S.maxXp = state
        if ok1 and wpnpkts and wpnpkts.useWeapon and wpnpkts.useWeapon.send then
            if state then
                local origS = wpnpkts.useWeapon.send
                wpnpkts.useWeapon.send = function(data)
                    data = data or {}
                    data.was360 = true data.quickscope = true data.scoped = true
                    return origS(data)
                end
            end
        end
    end
})
wpnSec:Toggle({
    Title = "刀无冷却",
    Default = false,
    Callback = function(state) S.noKnifeCd = state end
})
wpnSec:Toggle({
    Title = "力场绕过",
    Default = false,
    Callback = function(state) S.ffBy = state end
})

local movTab = Window:Tab({ Title = "移动", Icon = "person" })
local movSec = movTab:Section({ Title = "移动控制", TextXAlignment = "Left", TextSize = 17 })

movSec:Toggle({
    Title = "加速",
    Default = false,
    Callback = function(state) S.speedOn = state end
})
movSec:Slider({
    Title = "移速",
    Value = { Min = 16, Max = 500, Default = 50 },
    Increment = 1,
    Callback = function(v) S.speedVal = v end
})
movSec:Toggle({
    Title = "高跳",
    Default = false,
    Callback = function(state) S.jumpOn = state end
})
movSec:Slider({
    Title = "跳跃高度",
    Value = { Min = 50, Max = 500, Default = 50 },
    Increment = 1,
    Callback = function(v) S.jumpVal = v end
})
movSec:Toggle({
    Title = "穿墙",
    Default = false,
    Callback = function(state) S.noclipOn = state end
})
movSec:Toggle({
    Title = "旋转",
    Default = false,
    Callback = function(state) S.spinOn = state end
})
movSec:Slider({
    Title = "旋转速度",
    Value = { Min = 10, Max = 1000, Default = 180 },
    Increment = 10,
    Callback = function(v) S.spinSpeed = v end
})
movSec:Toggle({
    Title = "第三人称",
    Default = false,
    Callback = function(state)
        S.thirdPerson = state
        setThirdPerson(state)
    end
})

local funTab = Window:Tab({ Title = "功能", Icon = "wrench" })
local funSec = funTab:Section({ Title = "实用功能", TextXAlignment = "Left", TextSize = 17 })

funSec:Toggle({ Title = "反挂机", Default = false, Callback = function(s) S.antiAfk = s end })
funSec:Toggle({ Title = "自动部署", Default = false, Callback = function(s) S.autoDeploy = s end })
funSec:Toggle({ Title = "立即重生", Default = false, Callback = function(s) S.instRespawn = s end })
funSec:Toggle({ Title = "自动领任务", Default = false, Callback = function(s) S.autoQuests = s end })
funSec:Toggle({ Title = "自动领等级奖励", Default = false, Callback = function(s) S.autoLvl = s end })
funSec:Toggle({ Title = "自动领通行证", Default = false, Callback = function(s) S.autoBp = s end })
funSec:Toggle({ Title = "命中通知", Default = false, Callback = function(s) S.hitNotifs = s end })
funSec:Toggle({
    Title = "击杀播报改写",
    Default = false,
    Callback = function(s) S.killFeed = s end
})
funSec:Button({
    Title = "复制房号",
    Callback = function()
        pcall(function() setclipboard(game.JobId) end)
        WindUI:Notify({ Title = "已复制", Content = tostring(game.JobId), Duration = 3 })
    end
})
funSec:Button({
    Title = "换服",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
        end)
    end
})

RunService.Heartbeat:Connect(function()
    if S.killOn then
        StatusTag:SetTitle("运行中 | " .. targetCount .. " 目标")
    end
end)

applyWpnMods()

