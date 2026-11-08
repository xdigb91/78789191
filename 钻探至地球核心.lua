local repo = "https://raw.githubusercontent.com/ATLASTEAM01/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({ Title = "钻探至地球核心", Footer = "XJW", Center = true, AutoShow = true })

local Tabs = {
    Main = Window:AddTab("主页", "user"),
    Drill = Window:AddTab("钻头修改(仅供娱乐)", "hammer"),
    Teleport = Window:AddTab("传送", "map"),
    FlyTab = Window:AddTab("玩家", "rocket"),
    ["UI Settings"] = Window:AddTab("UI设置", "settings"),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer



local function ClearArray(t)
    for i = #t, 1, -1 do
        t[i] = nil
    end
end

local GodMode = {
    Active = false,
    Connections = {},
    RenderSteps = {},
    OldCF = CFrame.new(),
    StepName1 = "",
    StepName2 = "",
    WantActive = false,
}

local function RandomString()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local t = {}
    for i = 1, 24 do
        t[i] = chars:sub(math.random(1, 62), math.random(1, 62))
    end
    return table.concat(t)
end

GodMode.StepName1 = RandomString()
GodMode.StepName2 = GodMode.StepName1:reverse()

local function GetCharParts()
    local char = Player.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    return char, hum, root
end

local function GetRootPos()
    local _, _, root = GetCharParts()
    return root and root.Position or nil
end

local function CleanGodMode()
    for _, conn in ipairs(GodMode.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    ClearArray(GodMode.Connections)
    for _, step in ipairs(GodMode.RenderSteps) do
        pcall(function() RunService:UnbindFromRenderStep(step) end)
    end
    ClearArray(GodMode.RenderSteps)
end

function GodMode.Update(enabled)
    if not enabled then
        CleanGodMode()
        GodMode.Active = false
        local _, _, root = GetCharParts()
        if root then pcall(function() root.CFrame = GodMode.OldCF end) end
        return
    end

    local _, _, root = GetCharParts()
    if not root then return end

    GodMode.OldCF = root.CFrame
    GodMode.Active = true
    CleanGodMode()

    local rot = CFrame.Angles(math.rad(90), 0, 0)

    table.insert(GodMode.RenderSteps, GodMode.StepName1)
    RunService:BindToRenderStep(GodMode.StepName1, Enum.RenderPriority.Camera.Value - 1, function()
        local _, _, part = GetCharParts()
        if part then part.CFrame = GodMode.OldCF end
    end)
    table.insert(GodMode.Connections, RunService.PostSimulation:Connect(function()
        local _, _, part = GetCharParts()
        if part then
            local depth = GodMode.Depth or 20
            GodMode.OldCF = part.CFrame
            part.CFrame = CFrame.new(part.Position - Vector3.yAxis * depth) * rot
        end
    end))
end

local NoClip = {
    Active = false,
    Conn = nil,
}
function NoClip.Update(on)
    if on == NoClip.Active then return end
    if NoClip.Conn then
        pcall(function() NoClip.Conn:Disconnect() end)
        NoClip.Conn = nil
    end
    NoClip.Active = on
    if on then
        local function Apply()
            local char = Player.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if root then root.CanCollide = false end
        end
        Apply()
        NoClip.Conn = RunService.Stepped:Connect(function()
            Apply()
        end)
    end
end

local function GetToolUpdateEvent()
    local ok, ev = pcall(function()
        return ReplicatedStorage.Packages._Index["sleitnick_knit@1.4.6"].knit.Services.ToolService.RE.Update
    end)
    if ok and ev then
        return ev
    end
    return nil
end

local function GetTargetPos(target)
    if not target then return nil end
    if target:IsA("BasePart") then
        return target.Position
    end
    local hrp = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso") or target:FindFirstChild("UpperTorso")
    if hrp then return hrp.Position end
    local ok, box = pcall(function()
        local cf = target:GetBoundingBox()
        return cf.Position
    end)
    if ok and box then return box end
    local part = target:FindFirstChildWhichIsA("BasePart")
    if part then return part.Position end
    return nil
end

local function GetTargetTopPos(target)
    local pos = GetTargetPos(target)
    if not pos then return nil end
    if target:IsA("BasePart") then
        return pos + Vector3.new(0, 5, 0)
    end
    local topY = pos.Y
    local bestX, bestZ = pos.X, pos.Z
    local ok, box, size = pcall(function()
        local cf, s = target:GetBoundingBox()
        return cf, s
    end)
    if ok and box and size then
        topY = box.Position.Y + size.Y / 2
        bestX, bestZ = box.Position.X, box.Position.Z
    end
    for _, c in ipairs(target:GetDescendants()) do
        if c:IsA("BasePart") then
            local y = c.Position.Y + c.Size.Y / 2
            if y > topY then
                topY = y
            end
        end
    end
    return Vector3.new(bestX, topY + 5, bestZ)
end

local function IsValidTarget(target)
    if not target then return false end
    if not target.Parent then return false end
    local hum = target:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

local function FaceTarget(target)
    local _, _, root = GetCharParts()
    if not root or not target then return end
    local targetPos = GetTargetPos(target)
    if not targetPos then return end
    pcall(function()
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
    end)
end

local function SwingTarget(target)
    if not IsValidTarget(target) then return end
    local ev = GetToolUpdateEvent()
    if not ev then return end
    pcall(function()
        ev:FireServer({ "Swing", { target } })
    end)
end

local RockNameKeys = { "diamond", "emerald", "gold", "coal", "iron", "amethyst", "ruby", "sapphire", "copper", "crystal", "gem", "heartgem", "stone", "rock", "ore" }
local RockChineseMap = {
    diamond = "钻石",
    emerald = "绿宝石",
    gold = "金矿",
    coal = "煤矿",
    iron = "铁矿",
    amethyst = "紫水晶",
    ruby = "红宝石",
    sapphire = "蓝宝石",
    copper = "铜矿",
    crystal = "水晶",
    gem = "宝石",
    heartgem = "心石",
    stone = "挖掘地",
    rock = "岩石",
    ore = "矿石",
}
local RockChineseColor = {
    ["钻石"] = Color3.fromRGB(80, 180, 255),
    ["绿宝石"] = Color3.fromRGB(80, 255, 120),
    ["金矿"] = Color3.fromRGB(255, 200, 0),
    ["煤矿"] = Color3.fromRGB(130, 130, 130),
    ["铁矿"] = Color3.fromRGB(185, 185, 195),
    ["紫水晶"] = Color3.fromRGB(200, 100, 255),
    ["红宝石"] = Color3.fromRGB(255, 80, 80),
    ["蓝宝石"] = Color3.fromRGB(100, 120, 255),
    ["铜矿"] = Color3.fromRGB(220, 140, 80),
    ["水晶"] = Color3.fromRGB(160, 240, 255),
    ["宝石"] = Color3.fromRGB(255, 120, 200),
    ["心石"] = Color3.fromRGB(255, 80, 120),
    ["挖掘地"] = Color3.fromRGB(255, 60, 60),
    ["岩石"] = Color3.fromRGB(255, 170, 0),
    ["矿石"] = Color3.fromRGB(255, 170, 0),
}
local RockChineseOrder = {}
for k in pairs(RockChineseMap) do
    RockChineseOrder[#RockChineseOrder + 1] = k
end
table.sort(RockChineseOrder, function(a, b) return #a > #b end)
local function RockNameToChinese(name)
    local low = name:lower()
    for _, k in ipairs(RockChineseOrder) do
        if low:find(k, 1, true) then return RockChineseMap[k] end
    end
    if low:sub(1, 1) == "d" then return "挖掘地" end
    return name
end

local function OreKindOf(obj)
    if not obj then return "矿石" end
    local function ExactRockName(name)
        local s = tostring(name):lower()
        for _, k in ipairs(RockChineseOrder) do
            if s == k then return RockChineseMap[k] end
        end
        for _, k in ipairs(RockChineseOrder) do
            if #k >= 4 and s:find(k, 1, true) then return RockChineseMap[k] end
        end
        if s:sub(1, 1) == "d" then return "挖掘地" end
        return nil
    end
    local attrKeys = { "SessionOreType", "OreType", "OreName", "Type", "OreKind", "OreId", "TypeId", "ResourceId", "Resource", "Mineral", "Kind", "Tier", "Ore_Model", "SessionOreModel" }
    for _, attr in ipairs(attrKeys) do
        local ok, val = pcall(function() return obj:GetAttribute(attr) end)
        if ok and val then
            local hit = ExactRockName(val)
            if hit then return hit end
        end
    end
    local okA, allAttrs = pcall(function() return obj:GetAttributes() end)
    if okA and allAttrs then
        for _, val in pairs(allAttrs) do
            local hit = ExactRockName(val)
            if hit then return hit end
        end
    end
    local function ScanNames(o)
        local found = RockNameToChinese(o.Name)
        if found ~= o.Name then return found end
        local function WalkChildren(x, depth)
            if depth > 4 then return nil end
            for _, child in ipairs(x:GetChildren()) do
                local f2 = RockNameToChinese(child.Name)
                if f2 ~= child.Name then return f2 end
                local deeper = WalkChildren(child, depth + 1)
                if deeper then return deeper end
            end
            return nil
        end
        local deep = WalkChildren(o, 1)
        if deep then return deep end
        for _, tag in ipairs(CollectionService:GetTags(o)) do
            local f4 = RockNameToChinese(tag)
            if f4 ~= tag then return f4 end
        end
        local p = o.Parent
        for _ = 1, 3 do
            if not p then break end
            local f6 = RockNameToChinese(p.Name)
            if f6 ~= p.Name then return f6 end
            p = p.Parent
        end
        return nil
    end
    local res = ScanNames(obj)
    if res then return res end
    return "矿石"
end
local function IsRockNode(node)
    local first = node.Name:sub(1, 1)
    if first == "E" or first == "e" then return false end
    
    if first == "D" or first == "d" then return true end
    if node:HasTag("Ore") then return true end
    local ok, v = pcall(function() return node:GetAttribute("OreLoaded") end)
    if ok and v ~= nil then return true end
    if node:FindFirstChild("Health") then return true end
    local hpOk, hp = pcall(function() return node:GetAttribute("Health") end)
    if hpOk and hp ~= nil then return true end
    local low = node.Name:lower()
    for _, k in ipairs(RockNameKeys) do
        if low:find(k, 1, true) then return true end
    end
    return false
end

local function CollectOreNodes(folder, list, depth)
    if not folder or depth <= 0 then return end
    local nodes = folder:FindFirstChild("Nodes")
    if nodes then
        for _, node in ipairs(nodes:GetChildren()) do
            if (node:IsA("Model") or node:IsA("BasePart")) and IsRockNode(node) then
                list[#list + 1] = node
            end
        end
    end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            CollectOreNodes(child, list, depth - 1)
        end
    end
end

local function GetChunkOres()
    local list = {}
    local chunks = workspace:FindFirstChild("Chunks")
    if chunks then
        local layers = chunks:FindFirstChild("Layers")
        if layers then
            for _, path in ipairs(layers:GetChildren()) do
                if path:IsA("Folder") or path:IsA("Model") then
                    CollectOreNodes(path, list, 1)
                end
            end
        end
    end
    
    local mineshaft = workspace:FindFirstChild("Mineshaft")
    if mineshaft then
        CollectOreNodes(mineshaft, list, 2)
    end
    return list
end

local OreBad = {}
local function IsOreReady(ore)
    local ok, v = pcall(function() return ore:GetAttribute("OreLoaded") end)
    if ok and v == false then return false end
    local hp = nil
    pcall(function()
        local h = ore:FindFirstChild("Health")
        if h then hp = h.Value end
        if hp == nil then hp = ore:GetAttribute("Health") end
    end)
    if type(hp) == "number" and hp <= 0 then return false end
    return true
end
local function GetNearestOre()
    local rootPos = GetRootPos()
    if not rootPos then return nil end
    local now = tick()
    local best, bestDist = nil, math.huge
    for _, ore in ipairs(GetChunkOres()) do
        if OreBad[ore] and now < OreBad[ore] then continue end
        if IsOreReady(ore) then
            local pos = GetTargetPos(ore)
            if pos then
                local d = (rootPos - pos).Magnitude
                if d < bestDist then
                    best, bestDist = ore, d
                end
            end
        end
    end
    return best
end

local function ScanOreKinds()
    local kinds = {}
    for _, ore in ipairs(GetChunkOres()) do
        if not IsOreReady(ore) then continue end
        local k = OreKindOf(ore)
        if k and k ~= "矿石" then kinds[k] = true end
    end
    local arr = { "所有岩石" }
    for k in pairs(kinds) do arr[#arr + 1] = k end
    table.sort(arr)
    return arr
end
local OreKindSelectedSet = {}
local function OreKindMatch(ore)
    if OreKindSelectedSet["所有岩石"] then return true end
    if next(OreKindSelectedSet) == nil then return false end
    return OreKindSelectedSet[OreKindOf(ore)] == true
end
local function GetNearestOreKind()
    local rootPos = GetRootPos()
    if not rootPos then return nil end
    local now = tick()
    local best, bestDist = nil, math.huge
    for _, ore in ipairs(GetChunkOres()) do
        if OreBad[ore] and now < OreBad[ore] then continue end
        if OreKindMatch(ore) and IsOreReady(ore) then
            local pos = GetTargetPos(ore)
            if pos then
                local d = (rootPos - pos).Magnitude
                if d < bestDist then
                    best, bestDist = ore, d
                end
            end
        end
    end
    return best
end

local function GetNearestNpc()
    local folder = workspace:FindFirstChild("Npc")
    if not folder then return nil end
    local rootPos = GetRootPos()
    if not rootPos then return nil end
    local best, bestDist = nil, math.huge
    for _, npc in ipairs(folder:GetChildren()) do
        if IsValidTarget(npc) then
            local pos = GetTargetPos(npc)
            if pos then
                local d = (rootPos - pos).Magnitude
                if d < bestDist then
                    best, bestDist = npc, d
                end
            end
        end
    end
    return best
end

local GodBox = Tabs.Main:AddLeftGroupbox("无敌", "shield")
Toggles.GodMode = GodBox:AddToggle("GodMode", { Text = "<font color=\"#ff0000\">启用无敌</font>", Default = false }):AddKeyPicker("GodModeBind", { Default = "F", SyncToggleState = true, Mode = "Toggle" })
Toggles.GodMode:OnChanged(function(Value)
    GodMode.WantActive = Value
    GodMode.Update(Value)
    UpdateQuickBtn()
end)
Toggles.GodModeQuickBar = GodBox:AddToggle("GodModeQuickBar", { Text = "显示无敌快捷栏", Default = false })
Toggles.GodModeQuickBar:OnChanged(function(Value)
    if QuickGui then QuickGui.Enabled = Value end
end)
GodMode.Depth = 20

local AttackBox = Tabs.Main:AddLeftGroupbox("自动攻击", "sword")
Toggles.AutoOre = AttackBox:AddToggle("AutoOre", { Text = "自动攻击岩石", Default = false })
Toggles.AutoNpc = AttackBox:AddToggle("AutoNpc", { Text = "自动攻击NPC（需要靠近NPC）", Default = false })
AttackBox:AddSlider("AttackInterval", { Text = "攻击间隔(秒)", Min = 0.1, Max = 2, Default = 0.5, Rounding = 1, Compact = false })

local OreKindList = { "所有岩石", "挖掘地", "煤矿", "铜矿", "铁矿", "金矿", "水晶", "紫水晶", "红宝石", "蓝宝石", "绿宝石", "钻石", "宝石", "心石" }
local OreKindSelect = AttackBox:AddDropdown("OreKindSelect", { Text = "选择矿种（可多选，只攻击选中矿种的岩石）", Values = OreKindList, Default = 0, Multi = true })
OreKindSelect:OnChanged(function(v)
    OreKindSelectedSet = {}
    if type(v) == "table" then
        for k, val in pairs(v) do
            if type(k) == "number" then
                local name = OreKindList[k]
                if name and val then OreKindSelectedSet[name] = true end
            elseif type(k) == "string" and val then
                OreKindSelectedSet[k] = true
            end
        end
    elseif type(v) == "string" and v ~= "" then
        OreKindSelectedSet[v] = true
    end
end)
local PickBox = Tabs.Main:AddLeftGroupbox("自动拾取", "gem")
Toggles.AutoPick = PickBox:AddToggle("AutoPick", { Text = "自动拾取", Default = false })

local PickaxeNames = {
    "Wooden Pickaxe", "Stone Pickaxe", "Iron Pickaxe", "Gold Pickaxe", "Diamond Pickaxe",
    "Rainbow Pickaxe", "Crystal Pickaxe", "Future Pickaxe", "Ice Pickaxe", "Lava Pickaxe",
    "Nuke Pickaxe", "Thunder Pickaxe", "Toy Pickaxe", "Unicorn Pickaxe", "Void Pickaxe",
    "Anime Pickaxe", "Glitch Pickaxe", "Neon Pickaxe", "Pinata Pickaxe", "Angel Pickaxe",
    "Admin Pickaxe", "Plushie Pickaxe", "Emoji Pickaxe", "Firework Pickaxe",
}
local function IsPickaxeName(name)
    local low = tostring(name):lower()
    if low:find("pickaxe", 1, true) then return true end
    for _, k in ipairs(PickaxeNames) do
        if low == k:lower() then return true end
    end
    return false
end



local function IsPickaxeTool(t)
    if not t then return false end
    if t:IsA("Tool") and (IsPickaxeName(t.Name) or (t.Name:match("^Pickaxe"))) then return true end
    local ok, cls = pcall(function() return t:GetAttribute("Class") end)
    if ok and cls == "Pickaxe" then return true end
    return false
end
local function GetBackpackPickaxe()
    local bp = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end
    for _, t in ipairs(bp:GetChildren()) do
        
        if t:IsA("Tool") and IsPickaxeTool(t) then
            return t
        end
    end
    return nil
end

local function IsPickaxeInHand()
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character
    if not char then return false end
    for _, t in ipairs(char:GetChildren()) do
        if IsPickaxeTool(t) then return true end
    end
    return false
end
local function EquipPickaxe(tool)
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character
    if not tool or not char then return false end
    
    if tool.Parent == char then return true end
    
    
    local ok, rf = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local packages = rs:WaitForChild("Packages")
        local idx = packages:WaitForChild("_Index")
        local knitSvc = idx:WaitForChild("sleitnick_knit@1.4.6"):WaitForChild("knit"):WaitForChild("Services")
        local ts = knitSvc:WaitForChild("ToolService")
        local rf2 = ts:WaitForChild("RF")
        return rf2:WaitForChild("EquipTool")
    end)
    if ok and rf then
        pcall(function()
            rf:InvokeServer(tool)
        end)
        local t0 = tick()
        while tick() - t0 < 1 and tool.Parent ~= char do
            task.wait(0.05)
        end
        return tool.Parent == char
    end
    
    local h = char:FindFirstChildWhichIsA("Humanoid")
    if h then pcall(function() h:EquipTool(tool) end) end
    local t0 = tick()
    while tick() - t0 < 1 and tool.Parent ~= char do
        task.wait(0.05)
    end
    return tool.Parent == char
end
local function PickupPickaxe()
    local lp = game:GetService("Players").LocalPlayer
    
    if IsPickaxeInHand() then return true end
    
    local t = GetBackpackPickaxe()
    if t then
        print("[PickupPickaxe] 背包找到镐子:", t.Name, "Class=", tostring(t:GetAttribute("Class")))
        local ok = EquipPickaxe(t)
        print("[PickupPickaxe] EquipTool 装备结果:", ok)
        return ok
    end
    print("[PickupPickaxe] 背包未找到镐子")
    return false
end


local function GetDrill()
    return workspace:FindFirstChild("Drill")
end

local function GetDrillProp(name, fallback)
    local drill = GetDrill()
    if not drill then return fallback end
    local ok, val = pcall(function() return drill:GetAttribute(name) end)
    if ok and val ~= nil then return val end
    local child = drill:FindFirstChild(name)
    if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
        return child.Value
    end
    return fallback
end

local function SetDrillProp(name, value)
    local drill = GetDrill()
    if not drill then
                return
    end
    local setOk = pcall(function() drill:SetAttribute(name, value) end)
    if setOk then
        local _, check = pcall(function() return drill:GetAttribute(name) end)
        if check ~= nil then return end
    end
    local child = drill:FindFirstChild(name)
    if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
        pcall(function() child.Value = value end)
    end
end

local DrillBox = Tabs.Drill:AddLeftGroupbox("钻头属性", "drill")
local drillProps = {
    { Key = "DrillDamage", Name = "Damage", Text = "伤害", Min = 1, Max = 1000, Default = 1, Rounding = 0 },
    { Key = "DrillDamageRate", Name = "DamageRate", Text = "伤害频率", Min = 0.1, Max = 10, Default = 1, Rounding = 1 },
    { Key = "DrillSpeed", Name = "Speed", Text = "钻速", Min = 1, Max = 500, Default = 25, Rounding = 0 },
    { Key = "DrillMaxFuel", Name = "MaxFuel", Text = "最大燃料", Min = 10, Max = 100000, Default = 100, Rounding = 0 },
    { Key = "DrillFuel", Name = "Fuel", Text = "燃料", Min = 0, Max = 100000, Default = 25, Rounding = 0 },
    { Key = "DrillThrottle", Name = "DriverThrottle", Text = "油门", Min = 0, Max = 100, Default = 0, Rounding = 0 },
    { Key = "DrillAutoPilot", Name = "AutoPilotEfficiency", Text = "自动驾驶效率", Min = 0, Max = 100, Default = 0, Rounding = 0 },
    { Key = "DrillAutoModule", Name = "AutoPilotModuleCount", Text = "自动驾驶模块数", Min = 0, Max = 100, Default = 0, Rounding = 0 },
    { Key = "DrillLeech", Name = "FuelLeechCount", Text = "燃料汲取数", Min = 0, Max = 100, Default = 0, Rounding = 0 },
}
for _, p in ipairs(drillProps) do
    DrillBox:AddSlider(p.Key, { Text = p.Text, Min = p.Min, Max = p.Max, Default = GetDrillProp(p.Name, p.Default), Rounding = p.Rounding, Compact = false }):OnChanged(function(Value)
        SetDrillProp(p.Name, Value)
    end)
end

local TeleportPoints = {
    { "0-10万米 | 市场兑换", { 13965, 3, -847 } },
    { "0-10万米 | 商店1", { 376, 4, -690 } },
    { "0-10万米 | 商店2", { 2776, 4, -690 } },
    { "0-10万米 | 商店3", { 5176, 4, -690 } },
    { "0-10万米 | 商店4", { 7576, 4, -690 } },
    { "0-10万米 | 商店5", { 9976, 4, -690 } },
    { "0-10万米 | 商店6", { 16776, 4, -690 } },
    { "0-10万米 | 商店7", { 20176, 4, -690 } },
    { "0-10万米 | 商店8", { 27976, 4, -690 } },
    { "0-10万米 | 商店9", { 33376, 4, -690 } },
    { "10万米+ | 商店1", { -536, 3, -690 } },
    { "10万米+ | 商店2", { 2866, 3, -690 } },
    { "10万米+ | 商店3", { 6266, 3, -690 } },
    { "10万米+ | 商店4", { 9666, 3, -690 } },
    { "10万米+ | 商店5", { 13066, 3, -690 } },
    { "10万米+ | 商店6", { 16466, 3, -690 } },
    { "10万米+ | 商店7", { 19866, 3, -690 } },
    { "10万米+ | 商店8", { 23266, 3, -690 } },
    { "10万米+ | 商店9", { 26666, 3, -690 } },
    { "折扣 | 最大改造器", { 13965, 3, -847 } },
}

local function TeleportTo(coord, name)
    local _, _, root = GetCharParts()
    if not root then
                return
    end
    local pos = Vector3.new(coord[1], coord[2] + 3, coord[3])
    pcall(function()
        root.CFrame = CFrame.new(pos)
    end)
    pcall(function()
        workspace:RequestStreamAroundAsync(pos)
    end)
    end

local TeleportBox = Tabs.Teleport:AddLeftGroupbox("传送点（开了无敌无法传送）", "map-pin")
local tpNames = {}
for _, p in ipairs(TeleportPoints) do
    tpNames[#tpNames + 1] = p[1]
end
TeleportBox:AddDropdown("TeleportSelect", { Text = "选择传送点", Values = tpNames, Default = 1, Multi = false }):OnChanged(function(Value)
    if type(Value) ~= "string" then return end
    for _, p in ipairs(TeleportPoints) do
        if p[1] == Value then
            TeleportTo(p[2], p[1])
            break
        end
    end
end)
local function TeleportToTarget(target, label, instant)
    local _, _, root = GetCharParts()
    if not target then
                return false
    end
    if not root then
                return false
    end
    local pos = GetTargetPos(target)
    if not pos then
                return false
    end
    local dest = pos + Vector3.new(0, 2, 0)
    pcall(function()
        workspace:RequestStreamAroundAsync(pos)
    end)
    if instant then
        
        local _, _, r = GetCharParts()
        if r then
            pcall(function() r.CFrame = CFrame.new(dest) end)
        end
        return true
    end
    
    local spd = 1000
    local t0 = os.clock()
    local lastT = t0
    local limit = (dest - root.Position).Magnitude / math.max(spd, 1) * 0.06 + 2
    local last = root.Position
    local stall = 0
    while true do
        if os.clock() - t0 > limit then break end
        local _, _, r = GetCharParts()
        if not r then break end
        local nowT = os.clock()
        local dt = nowT - lastT
        lastT = nowT
        if dt < 0.01 then dt = 0.01 end
        if dt > 0.1 then dt = 0.1 end
        local move = spd * dt
        local diff = dest - r.Position
        local dist = diff.Magnitude
        if dist <= 1 then break end
        if (r.Position - last).Magnitude < 0.05 then
            stall = stall + 1
            if stall >= 15 then break end
        else
            stall = 0
        end
        last = r.Position
        r.CFrame = CFrame.new(r.Position + diff.Unit * math.min(move, dist))
        task.wait(0.03)
    end
    return true
    end
local OreDropdown, NpcDropdown, ChestDropdown
local function RefreshTargetLists()
    local ores, npcs = {}, {}
    local seenO, seenN = {}, {}
    for _, o in ipairs(GetChunkOres()) do
        if not seenO[o.Name] then
            seenO[o.Name] = true
            ores[#ores + 1] = o.Name
        end
    end
    local nf = workspace:FindFirstChild("Npc")
    if nf then
        for _, n in ipairs(nf:GetChildren()) do
            if (n:IsA("Model") or n:IsA("BasePart")) and not seenN[n.Name] then
                seenN[n.Name] = true
                npcs[#npcs + 1] = n.Name
            end
        end
    end
    pcall(function()
        if OreDropdown then OreDropdown:SetValues(ores) end
        if NpcDropdown then NpcDropdown:SetValues(npcs) end
    end)
end
TeleportBox:AddButton({ Text = "传送钻头", Func = function()
    local drillRoot = workspace:FindFirstChild("Drill")
    local drill = drillRoot and drillRoot:FindFirstChild("Rails") or nil
    if not drill then return end
    TeleportToTarget(drill, "钻头", true)
end })
OreDropdown = TeleportBox:AddDropdown("OreTpSelect", { Text = "传送岩石", Values = {}, Default = 1, Multi = false })
OreDropdown:OnChanged(function(Value)
    if type(Value) ~= "string" then return end
    local ore = nil
    for _, o in ipairs(GetChunkOres()) do
        if o.Name == Value then
            ore = o
            break
        end
    end
    if ore then TeleportToTarget(ore, "岩石:" .. (Value or ""), true) end
end)
NpcDropdown = TeleportBox:AddDropdown("NpcTpSelect", { Text = "传送NPC", Values = {}, Default = 1, Multi = false })
NpcDropdown:OnChanged(function(Value)
    if type(Value) ~= "string" then return end
    local nf = workspace:FindFirstChild("Npc")
    if not nf then return end
    local npc = nf:FindFirstChild(Value)
    if npc then TeleportToTarget(npc, "NPC:" .. (Value or ""), true) end
end)


local ChestState = {
    Cache = {}, LastScan = 0, FbAt = 0, Map = {},
}
local function IsChestObj(t)
    if not t then return false end
    if not (t:IsA("BasePart") or t:IsA("Model")) then return false end
    if t:GetAttribute("SessionChestId") ~= nil then return true end
    if t:GetAttribute("SessionChestSelectedModel") ~= nil then return true end
    if tostring(t.Name):find("Chest", 1, true) then return true end
    return false
end

local function ChestUsable(k)
    if not k or not k.Parent then return false end
    if not k:IsDescendantOf(workspace) then return false end
    local st = k:GetAttribute("ChestOpenState")
    if st ~= nil and st ~= "Idle" then return false end
    local t = k.Parent
    local p = 0
    while t and t ~= workspace and p < 20 do
        p = p + 1
        if t:GetAttribute("WaveCompleted") == false then return false end
        if t:GetAttribute("EncounterActive") == true then return false end
        t = t.Parent
    end
    return true
end


local function ScanChests(force)
    if not force and tick() - ChestState.LastScan < 2.5 then
        local h = {}
        for _, g in ipairs(ChestState.Cache) do
            if g.Parent then h[#h + 1] = g end
        end
        return h
    end
    local list, seen = {}, {}
    local function Add(t)
        if seen[t] then return end
        if not IsChestObj(t) then return end
        if not ChestUsable(t) then return end
        seen[t] = true
        list[#list + 1] = t
    end
    for _, w in ipairs(workspace:GetChildren()) do
        if w.Name:find("DungeonGate", 1, true) then
            local wave = w:FindFirstChild("Wave")
            local nodes = wave and wave:FindFirstChild("ChestNodes")
            if nodes then
                for _, d in ipairs(nodes:GetChildren()) do Add(d) end
            end
        end
    end
    if #list == 0 and tick() - (ChestState.FbAt or 0) > 30 then
        ChestState.FbAt = tick()
        for _, m in ipairs(workspace:GetDescendants()) do
            local okA, okB = pcall(function()
                return m:GetAttribute("SessionChestSelectedModel") and m:GetAttribute("SessionChestId")
            end)
            if okA and okB then Add(m) end
        end
    end
    ChestState.Cache = list
    ChestState.LastScan = tick()
    return list
end

local function BuildChestNames()
    ChestState.Map = {}
    local names = {}
    for _, r in ipairs(ScanChests(true)) do
        if IsChestObj(r) then
            local base = tostring(r:GetAttribute("SessionChestSelectedModel") or r.Name)
            local nm = base
            local p = 1
            while ChestState.Map[nm] do
                p = p + 1
                nm = base .. " #" .. p
            end
            ChestState.Map[nm] = r
            names[#names + 1] = nm
        end
    end
    return names
end

local function ChestPos(c)
    if not c then return nil end
    local sel = c:GetAttribute("SessionChestSelectedModel")
    if sel then
        local child = c:FindFirstChild(sel)
        if child and child:IsA("Model") then
            local ok, pivot = pcall(function() return child:GetPivot() end)
            if ok and pivot then return pivot.Position end
        end
    end
    if c:IsA("BasePart") then return c.Position end
    if c:IsA("Model") then
        local ok, pivot = pcall(function() return c:GetPivot() end)
        if ok and pivot then return pivot.Position end
    end
    local part = c:FindFirstChildWhichIsA("BasePart")
    return part and part.Position or nil
end
local chestNamesInit = {}
pcall(function() chestNamesInit = BuildChestNames() end)
if #chestNamesInit == 0 then chestNamesInit = { "None" } end

ChestDropdown = TeleportBox:AddDropdown("ChestDropdown", { Text = "传送宝箱", Searchable = true, MaxVisibleDropdownItems = 12, Values = chestNamesInit, Default = 0, Multi = false })
ChestDropdown:OnChanged(function(Value)
    if type(Value) ~= "string" or Value == "None" then return end
    local c = ChestState.Map[Value]
    if not c then return end
    local pos = ChestPos(c)
    if pos then
        local _, _, root = GetCharParts()
        if root then
            pcall(function() root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end)
            pcall(function() workspace:RequestStreamAroundAsync(pos) end)
        end
    end
end)

TeleportBox:AddButton({ Text = "刷新宝箱列表", Func = function()
    ChestState.FbAt = 0
    local oo = BuildChestNames()
    if ChestDropdown then
        if #oo == 0 then oo = { "None" } end
        pcall(function() ChestDropdown:SetValues(oo) end)
    end
end })
TeleportBox:AddButton({ Text = "刷新列表", Func = RefreshTargetLists })
Toggles.AutoRefresh = TeleportBox:AddToggle("AutoRefresh", { Text = "自动刷新列表", Default = false })
Toggles.AutoRefresh:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while Toggles.AutoRefresh.Value do
                task.wait(3)
                RefreshTargetLists()
            end
        end)
    end
end)
RefreshTargetLists()

local function GetEspPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        local direct = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso") or obj:FindFirstChildWhichIsA("BasePart")
        if direct then return direct end
        local ok, pp = pcall(function() return obj.PrimaryPart end)
        if ok and pp then return pp end
    end
    for _, child in ipairs(obj:GetChildren()) do
        local p = GetEspPart(child)
        if p then return p end
    end
    return nil
end

local function GetHighlightTarget(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then return obj end
    local first = obj:FindFirstChildOfClass("BasePart") or obj:FindFirstChildOfClass("Model")
    if first then return first end
    for _, child in ipairs(obj:GetChildren()) do
        local t = GetHighlightTarget(child)
        if t then return t end
    end
    return nil
end

local function GetParts(obj)
    local parts = {}
    if not obj then return parts end
    if obj:IsA("BasePart") then
        parts[1] = obj
        return parts
    end
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("BasePart") then parts[#parts + 1] = c end
    end
    return parts
end


local function TracerEdgePoint(sp, vs)
    local w, h = vs.X, vs.Y
    local cx, cy = w / 2, h / 2
    local dx = sp.X - cx
    local dy = sp.Y - cy
    if sp.Z < 0 then
        dx = -dx
        dy = -dy
    end
    local s = math.huge
    local halfX = w / 2 - 1
    local halfY = h / 2 - 1
    if math.abs(dx) > 0.0001 then
        s = math.min(s, math.abs(halfX / dx))
    end
    if math.abs(dy) > 0.0001 then
        s = math.min(s, math.abs(halfY / dy))
    end
    if s == math.huge then s = 1 end
    return Vector2.new(cx + dx * s, cy + dy * s)
end

local function NewEspSystem(prefix, folderName, color, extraHl)
    local self = {
        Prefix = prefix,
        FolderName = folderName,
        Color = color,
        NameColor = nil,
        HlColor = nil,
        LineColor = nil,
        ExtraHl = extraHl,
        HlOn = false,
        NameOn = false,
        LineOn = false,
        Started = false,
        Connections = {},
        Tracers = {},
    }
    function self:GetFolder()
        return workspace:FindFirstChild(self.FolderName)
    end
    function self:GetObjColor(obj)
        return self.Color
    end
    function self:ForEach(fn, onlyHl)
        if self.FolderName == "ChunkOres" then
            for _, obj in ipairs(GetChunkOres()) do
                fn(obj)
            end
            return
        end
        local folder = self:GetFolder()
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if self.FolderName == "Npc" and not IsValidTarget(obj) then
                    
                    self:ClearHighlight(obj)
                    self:ClearName(obj)
                    self:RemoveLine(obj)
                else
                    fn(obj)
                end
            end
        end
        if onlyHl then
            local rw = workspace:FindFirstChild("RockWalls")
            if rw then
                for _, obj in ipairs(rw:GetChildren()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then fn(obj) end
                end
            end
            for _, tag in ipairs({ "Ore", "RockWall" }) do
                for _, obj in ipairs(CollectionService:GetTagged(tag)) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then fn(obj) end
                end
            end
            local OreKeys = { "ore", "rock", "stone", "node", "mineral", "amethyst", "coal", "iron", "gold", "skull", "bone", "diamond", "copper", "crystal", "gem", "wall", "block" }
            for _, obj in ipairs(workspace:GetChildren()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and not (obj == workspace:FindFirstChild("Ores") or obj == workspace:FindFirstChild("RockWalls") or obj == workspace:FindFirstChild("Npc")) then
                    local low = obj.Name:lower()
                    for _, k in ipairs(OreKeys) do
                        if low:find(k, 1, true) then
                            fn(obj)
                            break
                        end
                    end
                end
            end
        end
    end
    function self:ApplyHighlight(obj)
        if not obj then return end
        local target = GetHighlightTarget(obj)
        if not target then return end
        local parts = GetParts(target or obj)
        local col = self.HlColor or self:GetObjColor(obj)
        local mounted = 0
        for _, base in ipairs(parts) do
            if not base:FindFirstChild(self.Prefix .. "Highlight") then
                pcall(function()
                    local hl = Instance.new("Highlight")
                    hl.Name = self.Prefix .. "Highlight"
                    hl.Adornee = base
                    hl.FillTransparency = 0
                    hl.FillColor = col
                    hl.OutlineTransparency = 0
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = base
                end)
                mounted = mounted + 1
            end
            pcall(function()
                if not base:GetAttribute(self.Prefix .. "OldColor") then
                    base:SetAttribute(self.Prefix .. "OldColor", base.Color)
                end
                base.Color = col
            end)
        end
        if self.Prefix == "OreEsp" and mounted > 0 then
            warn("[OreEsp] mount obj=" .. tostring(obj.Name) .. " type=" .. obj.ClassName .. " parts=" .. #parts)
        end
    end
    function self:ApplyName(obj)
        if not obj then return end
        local target = GetHighlightTarget(obj)
        local part = GetEspPart(target or obj)
        if not part then return end
        if obj:FindFirstChild(self.Prefix .. "NameTag") then return end
        pcall(function()
            local bg = Instance.new("BillboardGui")
            bg.Name = self.Prefix .. "NameTag"
            bg.Size = UDim2.new(0, 120, 0, 24)
            bg.AlwaysOnTop = true
            bg.Adornee = part
            bg.StudsOffset = Vector3.new(0, 3, 0)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            if self.TranslateName then
                lbl.Text = self:TranslateName(obj)
            else
                lbl.Text = tostring(obj.Name)
            end
            lbl.TextColor3 = self.NameColor or self:GetObjColor(obj)
            lbl.TextStrokeTransparency = 0
            lbl.TextScaled = false
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamBold
            lbl.Parent = bg
            bg.Parent = target or obj
        end)
    end
    function self:EnsureLine(obj)
        if not obj then return end
        if self.Tracers[obj] then return end
        local target = GetHighlightTarget(obj)
        local part = GetEspPart(target or obj)
        if not part then return end
        pcall(function()
            
            local line = Drawing.new("Line")
            line.Thickness = 2
            line.Color = self.LineColor or self:GetObjColor(obj)
            line.Visible = false
            self.Tracers[obj] = line
            self:EnsureTracerRender()
        end)
    end
    function self:RemoveLine(obj)
        if not obj then return end
        local line = self.Tracers[obj]
        if line then
            pcall(function() line:Remove() end)
            self.Tracers[obj] = nil
        end
    end
    function self:SetLine(on)
        if self.LineOn == on then return end
        self.LineOn = on
        if on then
            self:Start()
            self:ForEach(function(obj) self:EnsureLine(obj) end)
        else
            self:StopTracerRender()
            self:ForEach(function(obj) self:RemoveLine(obj) end)
            
            for obj, line in pairs(self.Tracers) do
                if line then pcall(function() line:Remove() end) end
                self.Tracers[obj] = nil
            end
        end
    end
    function self:SetColor(c)
        self.NameColor = c
        self.HlColor = c
        self.LineColor = c
        self.Color = c
        for obj, line in pairs(self.Tracers) do
            if line then line.Color = c end
            if obj then
                local target = GetHighlightTarget(obj) or obj
                local bg = target:FindFirstChild(self.Prefix .. "NameTag")
                if bg then
                    local lbl = bg:FindFirstChildOfClass("TextLabel")
                    if lbl then lbl.TextColor3 = c end
                end
                for _, base in ipairs(GetParts(target or obj)) do
                    local hl = base:FindFirstChild(self.Prefix .. "Highlight")
                    if hl then pcall(function() hl.FillColor = c end) end
                end
            end
        end
    end
    function self:SetNameColor(c)
        self.NameColor = c
        self:ForEach(function(obj)
            local target = GetHighlightTarget(obj) or obj
            local bg = target:FindFirstChild(self.Prefix .. "NameTag")
            if bg then
                local lbl = bg:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.TextColor3 = c end
            end
        end)
    end
    function self:SetHlColor(c)
        self.HlColor = c
        self:ForEach(function(obj)
            local target = GetHighlightTarget(obj) or obj
            for _, base in ipairs(GetParts(target or obj)) do
                local hl = base:FindFirstChild(self.Prefix .. "Highlight")
                if hl then pcall(function() hl.FillColor = c end) end
            end
        end)
    end
    function self:SetLineColor(c)
        self.LineColor = c
        for obj, line in pairs(self.Tracers) do
            if line then line.Color = c end
        end
    end
    function self:EnsureTracerRender()
        if self.TracerRenderConn then return end
        local cam = workspace.CurrentCamera
        self.TracerRenderConn = RunService.RenderStepped:Connect(function()
            local vs = cam.ViewportSize
            local origin = Vector2.new(vs.X / 2, 0)
            for obj, line in pairs(self.Tracers) do
                if line and obj then
                    local target = GetHighlightTarget(obj) or obj
                    local part = GetEspPart(target)
                    if part and part.Parent then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        line.Visible = true
                        line.From = origin
                        if onScreen and sp.Z > 0 then
                            line.To = Vector2.new(sp.X, sp.Y)
                        else
                            
                            line.To = TracerEdgePoint(sp, vs)
                        end
                    else
                        line.Visible = false
                    end
                end
            end
        end)
    end
    function self:StopTracerRender()
        if self.TracerRenderConn then
            self.TracerRenderConn:Disconnect()
            self.TracerRenderConn = nil
        end
    end
    function self:ClearHighlight(obj)
        if not obj then return end
        local target = GetHighlightTarget(obj)
        local parts = GetParts(target or obj)
        for _, base in ipairs(parts) do
            local hl = base:FindFirstChild(self.Prefix .. "Highlight")
            if hl then pcall(function() hl:Destroy() end) end
            local old = base:GetAttribute(self.Prefix .. "OldColor")
            if old then
                pcall(function() base.Color = old end)
                base:SetAttribute(self.Prefix .. "OldColor", nil)
            end
        end
        local hl3 = obj:FindFirstChild(self.Prefix .. "Highlight")
        if hl3 then pcall(function() hl3:Destroy() end) end
    end
    function self:ClearName(obj)
        if not obj then return end
        local target = GetHighlightTarget(obj)
        if target then
            local bg = target:FindFirstChild(self.Prefix .. "NameTag")
            if bg then pcall(function() bg:Destroy() end) end
        end
        local bg2 = obj:FindFirstChild(self.Prefix .. "NameTag")
        if bg2 then pcall(function() bg2:Destroy() end) end
    end
    function self:Begin()
        if self.FolderName == "ChunkOres" then
            task.spawn(function()
                while true do
                    task.wait(1)
                    self:ForEach(function(obj) self:Apply(obj) end)
                end
            end)
            return
        end
        local folder = self:GetFolder()
        if not folder then
            task.spawn(function()
                while true do
                    task.wait(0.5)
                    if self:GetFolder() then
                        self:Begin()
                        return
                    end
                end
            end)
            return
        end
        self:ForEach(function(obj) self:Apply(obj) end)
        self.Connections[#self.Connections + 1] = folder.ChildAdded:Connect(function(obj)
            if obj then
                task.wait(0.1)
                self:Apply(obj)
            end
        end)
        if self.ExtraHl then
            local rw = workspace:FindFirstChild("RockWalls")
            if rw then
                self.Connections[#self.Connections + 1] = rw.DescendantAdded:Connect(function(obj)
                    if obj and self.HlOn and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        task.wait(0.1)
                        self:ApplyHighlight(obj)
                    end
                end)
            end
        end
    end
    function self:Start()
        if self.Started then return end
        self.Started = true
        self:Begin()
    end
    function self:Apply(obj, onlyHl)
        if self.HlOn then self:ApplyHighlight(obj) end
        if not onlyHl and self.NameOn then self:ApplyName(obj) end
        if not onlyHl and self.LineOn then self:EnsureLine(obj) end
    end
    function self:SetHl(on)
        if self.HlOn == on then return end
        self.HlOn = on
        if on then
            self:Start()
            self:ForEach(function(obj) self:ApplyHighlight(obj) end, true)
            if self.Prefix == "OreEsp" then
                local of = workspace:FindFirstChild("Ores")
                local rw = workspace:FindFirstChild("RockWalls")
                local wslist = {}
                for i, obj in ipairs(workspace:GetChildren()) do
                    if i > 30 then break end
                    wslist[#wslist + 1] = obj.Name .. ":" .. obj.ClassName
                end
                warn("[OreEsp] ON ores=" .. (of and #of:GetChildren() or 0) .. " rw=" .. (rw and #rw:GetChildren() or 0) .. " tagOre=" .. #CollectionService:GetTagged("Ore") .. " tagWall=" .. #CollectionService:GetTagged("RockWall"))
                warn("[OreEsp] workspace=" .. table.concat(wslist, ", "))
            end
        else
            self:ForEach(function(obj) self:ClearHighlight(obj) end, true)
            self:ClearWorkspaceResidue()
        end
    end
    function self:SetName(on)
        if self.NameOn == on then return end
        self.NameOn = on
        if on then
            self:Start()
            self:ForEach(function(obj) self:ApplyName(obj) end)
        else
            self:ForEach(function(obj) self:ClearName(obj) end)
            self:ClearWorkspaceResidue()
        end
    end
    
    
    
    function self:ClearWorkspaceResidue()
        local tagName = self.Prefix .. "NameTag"
        local tagHl = self.Prefix .. "Highlight"
        for _, desc in ipairs(workspace:GetDescendants()) do
            local n = desc.Name
            if n == tagName or n == tagHl then
                pcall(function() desc:Destroy() end)
            end
        end
    end
    return self
end

local OreEsp = NewEspSystem("OreEsp", "Ores", Color3.fromRGB(255, 200, 0), true)
local ChunkOreEsp = NewEspSystem("ChunkOreEsp", "ChunkOres", Color3.fromRGB(255, 170, 0))
function ChunkOreEsp:GetObjColor(obj)
    local c = RockChineseColor[self:TranslateName(obj)]
    if c then return c end
    return self.Color
end
function ChunkOreEsp:TranslateName(obj)
    if not obj then return "矿石" end
    local function ExactRockName(name)
        local s = tostring(name):lower()
        for _, k in ipairs(RockChineseOrder) do
            if s == k then return RockChineseMap[k] end
        end
        for _, k in ipairs(RockChineseOrder) do
            if #k >= 4 and s:find(k, 1, true) then return RockChineseMap[k] end
        end
        if s:sub(1, 1) == "d" then return "挖掘地" end
        return nil
    end
    local attrKeys = { "SessionOreType", "OreType", "OreName", "Type", "OreKind", "OreId", "TypeId", "ResourceId", "Resource", "Mineral", "Kind", "Tier", "Ore_Model", "SessionOreModel" }
    for _, attr in ipairs(attrKeys) do
        local ok, val = pcall(function() return obj:GetAttribute(attr) end)
        if ok and val then
            local hit = ExactRockName(val)
            if hit then return hit end
        end
    end
    local okA, allAttrs = pcall(function() return obj:GetAttributes() end)
    if okA and allAttrs then
        for _, val in pairs(allAttrs) do
            local hit = ExactRockName(val)
            if hit then return hit end
        end
    end
    local function ScanNames(o)
        local found = RockNameToChinese(o.Name)
        if found ~= o.Name then return found end
        local function WalkChildren(x, depth)
            if depth > 4 then return nil end
            for _, child in ipairs(x:GetChildren()) do
                local f2 = RockNameToChinese(child.Name)
                if f2 ~= child.Name then return f2 end
                local deeper = WalkChildren(child, depth + 1)
                if deeper then return deeper end
            end
            return nil
        end
        local deep = WalkChildren(o, 1)
        if deep then return deep end
        for _, tag in ipairs(CollectionService:GetTags(o)) do
            local f4 = RockNameToChinese(tag)
            if f4 ~= tag then return f4 end
        end
        local p = o.Parent
        for _ = 1, 3 do
            if not p then break end
            local f6 = RockNameToChinese(p.Name)
            if f6 ~= p.Name then return f6 end
            p = p.Parent
        end
        return nil
    end
    local res = ScanNames(obj)
    if res then return res end
    return "矿石"
end
local NpcEsp = NewEspSystem("NpcEsp", "Npc", Color3.fromRGB(255, 80, 80))

task.spawn(function()
    while true do
        task.wait(0.5)
        local folder = workspace:FindFirstChild("Npc")
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if not IsValidTarget(obj) then
                    NpcEsp:ClearHighlight(obj)
                    NpcEsp:ClearName(obj)
                    NpcEsp:RemoveLine(obj)
                end
            end
        end
        for obj in pairs(NpcEsp.Tracers) do
            if not obj or not obj.Parent or not IsValidTarget(obj) then
                NpcEsp:RemoveLine(obj)
            end
        end
    end
end)

local OreEspBox = Tabs.Main:AddRightGroupbox("岩石透视", "eye")
Toggles.OreName = OreEspBox:AddToggle("OreName", { Text = "显示名字", Default = false, Callback = function(Value)
    ChunkOreEsp:SetName(Value)
end })
local ChunkLineToggle = OreEspBox:AddToggle("ChunkLine", { Text = "天线", Default = false, Callback = function(Value)
    ChunkOreEsp:SetLine(Value)
end })
Toggles.ChunkLine = ChunkLineToggle

local NpcEspBox = Tabs.Main:AddRightGroupbox("NPC透视", "users")
Toggles.NpcHl = NpcEspBox:AddToggle("NpcHl", { Text = "高亮", Default = false })
Toggles.NpcHl:OnChanged(function(Value)
    NpcEsp:SetHl(Value)
end)
Toggles.NpcHl:AddColorPicker("NpcHlColor", {
    Default = Color3.fromRGB(255, 80, 80), Title = "高亮颜色", Callback = function(Value)
        NpcEsp:SetHlColor(Value)
    end
})
Toggles.NpcName = NpcEspBox:AddToggle("NpcName", { Text = "显示名字", Default = false, Callback = function(Value)
    NpcEsp:SetName(Value)
end })
Toggles.NpcName:AddColorPicker("NpcNameColor", {
    Default = Color3.fromRGB(255, 255, 255), Title = "名字颜色", Callback = function(Value)
        NpcEsp:SetNameColor(Value)
    end
})
local NpcLineToggle = NpcEspBox:AddToggle("NpcLine", { Text = "天线", Default = false, Callback = function(Value)
    NpcEsp:SetLine(Value)
end })
Toggles.NpcLine = NpcLineToggle
NpcLineToggle:AddColorPicker("NpcLineColor", {
    Default = Color3.fromRGB(255, 80, 80), Title = "天线颜色", Callback = function(Value)
        NpcEsp:SetLineColor(Value)
    end
})
local WallBox = Tabs.Main:AddRightGroupbox("墙壁", "brick-wall")
WallBox:AddButton({ Text = "删除所有墙壁", Func = function()
    local rw = workspace:FindFirstChild("RockWalls")
    if not rw then
                return
    end
    pcall(function() rw:Destroy() end)
    end })


Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if GodMode.Active then
        GodMode.Update(false)
        task.wait(0.1)
        GodMode.Update(true)
    end
end)



local function FireTargetPrompt(target)
    if not target then return false end
    local function Try(p)
        if not p or not p:IsA("ProximityPrompt") then return false end
        local ok = pcall(function()
            local d = p.HoldDuration
            p.HoldDuration = 0
            fireproximityprompt(p, 0)
            p.HoldDuration = d
        end)
        if not ok then
            ok = pcall(function() fireproximityprompt(p, p.HoldDuration) end)
        end
        return ok
    end
    if Try(target) then return true end
    for _, d in ipairs(target:GetDescendants()) do
        if Try(d) then return true end
    end
    return false
end

task.spawn(function()
    local OreLock = nil
    local lastPick = 0
    local noClipOn = false
    while true do
        task.wait(0.05)
        if Toggles.AutoOre.Value then
            
            local hasOre = #GetChunkOres() > 0
            if hasOre and not noClipOn then
                NoClip.Update(true)
                noClipOn = true
            elseif not hasOre and noClipOn then
                NoClip.Update(false)
                noClipOn = false
            end
            
            if tick() - lastPick > 3 then
                lastPick = tick()
                PickupPickaxe()
            end
            local selEmpty = next(OreKindSelectedSet) == nil
            if not selEmpty then
                
                local target = OreLock
                if not (target and target.Parent ~= nil and IsOreReady(target) and OreKindMatch(target)) then
                    target = GetNearestOreKind()
                end
                if target then
                    if OreLock ~= target then
                        local ok = TeleportToTarget(target, "自动攻击岩石")
                        if ok then OreLock = target end
                    end
                    if OreLock == target then
                        SwingTarget(OreLock)
                    end
                else
                    OreLock = nil
                end
            else
                OreLock = nil
            end
            
            if OreLock and OreLock.Parent ~= nil and OreKindOf(OreLock) == "挖掘地" then
                FireTargetPrompt(OreLock)
            end
        else
            OreLock = nil
            if noClipOn then
                NoClip.Update(false)
                noClipOn = false
            end
        end
        if Toggles.AutoNpc.Value then
            SwingTarget(GetNearestNpc())
        end
    end
end)


local CarryRF = nil
local function GetCarryRF()
    if CarryRF then return CarryRF end
    local ok, rf = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local packages = rs:FindFirstChild("Packages")
        if packages then
            local idx = packages:FindFirstChild("_Index")
            if idx then
                for _, kid in ipairs(idx:GetChildren()) do
                    if kid.Name:find("^sleitnick_knit", 1) then
                        local kn = kid:FindFirstChild("knit")
                        if kn then
                            local sv = kn:FindFirstChild("Services")
                            if sv then
                                local cs = sv:FindFirstChild("CarryInventoryService")
                                if cs then
                                    local rf2 = cs:FindFirstChild("RF")
                                    if rf2 then
                                        local p = rf2:FindFirstChild("Pickup")
                                        if p then return p end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end)
    if ok and rf then CarryRF = rf end
    return CarryRF
end
local PickHandled = setmetatable({}, { __mode = "k" })
local function CollectItems(items)
    local list = {}
    local function Walk(folder)
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("BasePart") or v:IsA("Model") then
                list[#list + 1] = v
            else
                Walk(v)
            end
        end
    end
    Walk(items)
    return list
end

local function LockTeleportTo(root, pos, dur)
    local deadline = tick() + dur
    while tick() < deadline do
        pcall(function()
            if root:IsA("BasePart") then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            root.CFrame = CFrame.new(pos)
        end)
        task.wait(0.03)
    end
end

local function AutoPickTick()
    local _, _, root = GetCharParts()
    if not root then return end
    local items = workspace:FindFirstChild("Items")
    if not items then return end
    local rf = GetCarryRF()
    if not rf then return end
    
    local homePos = root.Position
    local collected = CollectItems(items)
    for _, item in ipairs(collected) do
        
        if not Toggles.AutoPick.Value then break end
        if PickHandled[item] then continue end
        
        if item:HasTag("ShopItem") or item:GetAttribute("ShopItem") == true then continue end
        local pos = GetTargetPos(item)
        if not pos then continue end
        local parent = item.Parent
        
        LockTeleportTo(root, pos + Vector3.new(0, 1.2, 0), 0.5)
        
        local ok2 = pcall(function()
            local args = { Instance.new("MeshPart", nil) }
            rf:InvokeServer(unpack(args))
        end)
        task.wait(0.3)
        if ok2 and item.Parent ~= parent then
            PickHandled[item] = true
        elseif ok2 then
            
            local ok3 = pcall(function() rf:InvokeServer(item) end)
            task.wait(0.3)
            if ok3 and item.Parent ~= parent then
                PickHandled[item] = true
            end
        end
        
        task.wait(0.5)
    end
    
    LockTeleportTo(root, homePos, 0.5)
end
task.spawn(function()
    while true do
        task.wait(0.4)
        if Toggles.AutoPick.Value then
            AutoPickTick()
        end
    end
end)





local SpeedBox = Tabs.FlyTab:AddLeftGroupbox("移速", "gauge")
Toggles.SpeedMod = SpeedBox:AddToggle("SpeedMod", { Text = "修改移速", Default = false })
local SpeedVal = 16
local function ApplySpeed()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    hum.WalkSpeed = Toggles.SpeedMod.Value and SpeedVal or 16
end
SpeedBox:AddSlider("SpeedVal", { Text = "移速", Min = 16, Max = 250, Default = 16, Rounding = 0, Callback = function(v)
    SpeedVal = v
    if Toggles.SpeedMod.Value then ApplySpeed() end
end })
Toggles.SpeedMod:OnChanged(function()
    ApplySpeed()
end)
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed()
end)


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("GodModeAttack/Configs_v182")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

QuickGui = Instance.new("ScreenGui")
QuickGui.Name = "GodModeQuickBar"
QuickGui.ResetOnSpawn = false
QuickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
QuickGui.Enabled = Toggles.GodModeQuickBar.Value
local okParent = pcall(function() QuickGui.Parent = game:GetService("CoreGui") end)
if not okParent then QuickGui.Parent = Player.PlayerGui end

QuickFrame = Instance.new("Frame")
QuickFrame.Name = "GodModeQuickBarFrame"
QuickFrame.Size = UDim2.fromOffset(120, 72)
QuickFrame.Position = UDim2.new(0.5, -320, 0.5, -75)
QuickFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
QuickFrame.BackgroundTransparency = 0.3
QuickFrame.BorderSizePixel = 0
QuickFrame.Active = true
local quickCorner = Instance.new("UICorner")
quickCorner.CornerRadius = UDim.new(0, 14)
quickCorner.Parent = QuickFrame
QuickFrame.Parent = QuickGui

QuickBtn = Instance.new("TextButton")
QuickBtn.Name = "GodModeQuickBtn"
QuickBtn.Size = UDim2.new(1, -8, 1, -8)
QuickBtn.Position = UDim2.new(0, 4, 0, 4)
QuickBtn.BackgroundColor3 = Color3.fromRGB(150, 55, 55)
QuickBtn.BorderSizePixel = 0
QuickBtn.Text = "无敌"
QuickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
QuickBtn.TextSize = 20
QuickBtn.Font = Enum.Font.GothamBold
QuickBtn.AutoButtonColor = true
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = QuickBtn
local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 2
btnStroke.Color = Color3.fromRGB(220, 90, 90)
btnStroke.Parent = QuickBtn
QuickBtn.Parent = QuickFrame

function UpdateQuickBtn()
    if not QuickBtn then return end
    local on = GodMode.WantActive
    QuickBtn.Text = on and "无敌 开" or "无敌 关"
    QuickBtn.BackgroundColor3 = on and Color3.fromRGB(46, 125, 70) or Color3.fromRGB(150, 55, 55)
    if btnStroke then btnStroke.Color = on and Color3.fromRGB(90, 200, 120) or Color3.fromRGB(220, 90, 90) end
end

local quickDragging = false
local quickDownPos = nil
local quickOffset = nil
local quickDragged = false

QuickBtn.MouseButton1Down:Connect(function(x, y)
    quickDragging = true
    quickDownPos = Vector2.new(x, y)
    quickDragged = false
    local fr = QuickFrame.AbsolutePosition
    quickOffset = Vector2.new(x - fr.X, y - fr.Y)
end)

QuickBtn.MouseMoved:Connect(function(x, y)
    if not quickDragging then return end
    local pos = Vector2.new(x, y)
    if not quickDragged and quickDownPos and (pos - quickDownPos).Magnitude > 10 then
        quickDragged = true
    end
    if quickDragged and quickOffset then
        QuickFrame.Position = UDim2.fromOffset(pos.X - quickOffset.X, pos.Y - quickOffset.Y)
    end
end)

QuickBtn.MouseButton1Up:Connect(function()
    quickDragging = false
    quickDownPos = nil
    quickOffset = nil
end)

QuickBtn.MouseButton1Click:Connect(function()
    if quickDragged then return end
    Toggles.GodMode:SetValue(not Toggles.GodMode.Value)
    UpdateQuickBtn()
end)

