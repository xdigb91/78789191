local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local function SendDrive()
    local ok, err = pcall(function()
        local args = {
            buffer.fromstring("\016")
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Packets"):WaitForChild("Packet"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end)
end

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

Library.Toggles = Library.Toggles or {}
Library.Options = Library.Options or {}


local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager


local Window = Library:CreateWindow({ Title = "建造并击杀僵尸", Footer = "XJW" })
local Tabs = { Main = Window:AddTab("主页", "user"), Mod = Window:AddTab("修改车", "wrench"), UI = Window:AddTab("UI设置", "settings") }
local MenuGroup = Tabs.UI:AddLeftGroupbox("菜单")

local LastUnloadAt

MenuGroup:AddButton("卸载脚本", function()
	local function DoUnload()
		task.defer(function()
			pcall(function()
				Library:Unload()
			end)
		end)
	end

	local OkDialog = pcall(function()
		Window:AddDialog("XJWUnloadConfirm", {
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
			Library:Notify("再次点击「卸载脚本」确认卸载，5 秒内有效")
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

Library.ToggleKeybind = Library.Options and Library.Options.MenuKeybind

local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager

if type(ThemeManager) == "table" then
	ThemeManager:SetLibrary(Library)
	ThemeManager:SetFolder("XJWUITheme")
	ThemeManager:ApplyToTab(Tabs.UI)
end

if type(SaveManager) == "table" then
	SaveManager:SetLibrary(Library)
	SaveManager:SetFolder("XJWUIConfig")
	SaveManager:BuildConfigSection(Tabs.UI)
end
local function GetCharPart()
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            return hrp
        end
        return char:FindFirstChild("Head")
    end
    return nil
end
local function IsDriving()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    local seat = hum.SeatPart
    if seat then
        local cars = workspace:FindFirstChild("Cars")
        if cars then
            local anc = seat:FindFirstAncestorWhichIsA("Model")
            if anc and anc:IsDescendantOf(cars) then
                return true
            end
        end
    end
    return false
end
local function FindPromptPart(v)
    local p = v.Parent
    if not p then return nil end
    if p:IsA("BasePart") then
        return p
    end
    if p:IsA("Attachment") and p.Parent and p.Parent:IsA("BasePart") then
        return p.Parent
    end
    local found = p:FindFirstChildWhichIsA("BasePart", true)
    if found then
        return found
    end
    local gp = p.Parent
    if gp then
        found = gp:FindFirstChildWhichIsA("BasePart", true)
        if found then
            return found
        end
    end
    return nil
end
local HomeBox = Tabs.Main:AddLeftGroupbox("自动互动(用于点击摇杆购买物品)")
local AutoI = HomeBox:AddToggle("AutoI", { Text = "自动互动", Default = false })
local RangeS = HomeBox:AddSlider("RangeS", { Text = "互动范围", Min = 5, Max = 100, Default = 12, Suffix = "", Compact = false })
task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoI.Value then
            local cp = GetCharPart()
            if cp then
                local cpos = cp.Position
                local range = RangeS.Value or 12
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.ClassName == "ProximityPrompt" and v.Parent then
                        local part = FindPromptPart(v)
                        if part and (part.Position - cpos).Magnitude <= range then
                            pcall(function() fireproximityprompt(v, v.HoldDuration) end)
                        end
                    end
                end
            end
        end
    end
end)
local DriveBox = Tabs.Main:AddLeftGroupbox("驾驶")
local AutoD = DriveBox:AddToggle("AutoD", { Text = "自动驾驶循环(配合自动刷钱使用)", Default = false })
DriveBox:AddButton({ Text = "点击驾驶一次", Func = function()
    SendDrive()
end })
task.spawn(function()
    while true do
        task.wait(1)
        if AutoD.Value then
            SendDrive()
        end
    end
end)
local FlyBox = Tabs.Main:AddLeftGroupbox("自动刷钱")
local AutoF = FlyBox:AddToggle("AutoF", { Text = "自动刷钱(需要上车)", Default = false })
local FlyS = FlyBox:AddSlider("FlyS", { Text = "速度(调快的话会被拉回)", Min = 16, Max = 200, Default = 16, Suffix = "", Compact = false })
local function Clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end
local function GroundHeight(hrp)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = { LP.Character }
    local cars = workspace:FindFirstChild("Cars")
    if cars then
        exclude[#exclude + 1] = cars
    end
    params.FilterDescendantsInstances = exclude
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -300, 0), params)
    if hit and hit.Position then
        return hit.Position.Y
    end
    return nil
end
task.spawn(function()
    local bv = nil
    local targetY = 0
    local warned = false
    while true do
        task.wait(0.1)
        if AutoF.Value then
            if IsDriving() then
                local hrp = GetCharPart()
                if hrp then
                    warned = false
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(9e5, 9e5, 9e5)
                        bv.Parent = hrp
                    end
                    local g = GroundHeight(hrp)
                    if g then
                        targetY = g + 4
                    end
                    local speed = FlyS.Value or 16
                    local look = hrp.CFrame.LookVector
                    local dy = Clamp((targetY - hrp.Position.Y) * 3, -30, 30)
                    bv.Velocity = Vector3.new(look.X * speed, dy, look.Z * speed)
                else
                    if bv then
                        bv:Destroy()
                        bv = nil
                    end
                    if not warned then
                        warned = true
                    end
                end
            else
                if bv then
                    bv:Destroy()
                    bv = nil
                end
                if not warned then
                    warned = true
                end
            end
        else
            if bv then
                bv:Destroy()
                bv = nil
            end
        end
    end
end)
local Box = Tabs.Mod:AddLeftGroupbox("车辆属性修改")
local Defaults = {}
local Target = {}
local attrs = { "TopSpeed", "Accel", "EnginePower", "Fuel", "CarHealth", "TotalHealthExtra", "TotalDamageExtra", "TurboMult", "TurboCount", "NitroFuel", "SupportRatio", "TotalMass", "Turn", "BodyLift", "FuelTime" }
local attrNames = { "最高速度", "加速", "引擎功率", "燃料", "车血量", "额外血量", "额外伤害", "涡轮倍率", "涡轮次数", "氮气燃料", "支撑比", "总质量", "转向", "车身抬升", "燃料时间" }
local boolAttrs = { "TurboActive", "NitroBlocked" }
local boolNames = { "涡轮激活", "氮气封锁" }
local function FindCar()
    local cars = workspace:FindFirstChild("Cars")
    if not cars then return nil end
    for _, car in ipairs(cars:GetChildren()) do
        if car:IsA("Model") and car:GetAttribute("DriverUserId") == LP.UserId then
            return car
        end
    end
    for _, car in ipairs(cars:GetChildren()) do
        if car:IsA("Model") and car:GetAttribute("OwnerUserId") == LP.UserId then
            return car
        end
    end
    return nil
end
local function Snapshot(car)
    if Defaults.snapped then return end
    for i, attr in ipairs(attrs) do
        Defaults[attr] = car:GetAttribute(attr)
    end
    for i, attr in ipairs(boolAttrs) do
        Defaults[attr] = car:GetAttribute(attr)
    end
    Defaults.snapped = true
end
local function ApplyAll(car)
    for i, attr in ipairs(attrs) do
        local v = Target[attr]
        if v ~= nil then car:SetAttribute(attr, v) end
    end
    for i, attr in ipairs(boolAttrs) do
        local v = Target[attr]
        if v ~= nil then car:SetAttribute(attr, v >= 0.5) end
    end
end
local function RestoreAll(car)
    if not Defaults.snapped then
        return
    end
    for i, attr in ipairs(attrs) do
        if Defaults[attr] ~= nil then car:SetAttribute(attr, Defaults[attr]) end
    end
    for i, attr in ipairs(boolAttrs) do
        if Defaults[attr] ~= nil then car:SetAttribute(attr, Defaults[attr]) end
    end
end
Box:AddButton({ Text = "应用修改", Func = function()
    local car = FindCar()
    if not car then
        return
    end
    Snapshot(car)
    ApplyAll(car)
end })
Box:AddButton({ Text = "恢复默认", Func = function()
    local car = FindCar()
    if not car then
        return
    end
    RestoreAll(car)
end })
for i, attr in ipairs(attrs) do
    local s = Box:AddSlider(attr, { Text = attrNames[i], Min = 1, Max = 1000, Default = 100, Suffix = "", Compact = false, Callback = function(v)
        Target[attr] = v
    end })
end
for i, attr in ipairs(boolAttrs) do
    local s = Box:AddSlider(attr, { Text = boolNames[i], Min = 0, Max = 1, Default = 0, Suffix = "", Compact = false, Callback = function(v)
        Target[attr] = v
    end })
end
