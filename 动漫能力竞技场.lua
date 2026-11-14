local env = (getgenv and getgenv()) or _G

for _, name in ipairs({ "AA_DashM1", "AA_M1Spam", "AA_InfiniteDash", "AA_M1BurstHitAll", "AA_Obsidian", "AA_Field", "AA_Arena", "AA_DashM1_UI" }) do
    local old = env[name]
    if type(old) == "table" and type(old.Stop) == "function" then
        pcall(old.Stop)
    end
    if type(old) == "table" and type(old.Destroy) == "function" then
        pcall(old.Destroy)
    end
    env[name] = nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local repo = "https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local okTheme, ThemeManager = pcall(function()
    return loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
end)
if not okTheme then
    ThemeManager = nil
end

local okSave, SaveManager = pcall(function()
    return loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
end)
if not okSave then
    SaveManager = nil
end

local Options = Library.Options or {}

local Window = Library:CreateWindow({
    Title = "动漫能力竞技场",
    Footer = "XJW",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Combat = Window:AddTab("战斗", "crosshair"),
    Teleport = Window:AddTab("传送", "move"),
    Target = Window:AddTab("目标", "user"),
    Settings = Window:AddTab("设置", "settings"),
}

local ComboBox = Tabs.Combat:AddLeftGroupbox("自动连击", "swords")
local DashBox = Tabs.Combat:AddRightGroupbox("无限冲刺", "zap")
local TpBox = Tabs.Teleport:AddLeftGroupbox("贴身连打", "locate-fixed")
local TargetBox = Tabs.Target:AddLeftGroupbox("指定玩家", "users")
local EspBox = Tabs.Target:AddRightGroupbox("视觉透视", "eye")
local MenuBox = Tabs.Settings:AddLeftGroupbox("菜单", "menu")
local AboutBox = Tabs.Settings:AddRightGroupbox("说明", "info")

local DrawingAPI = _G.Drawing
if not DrawingAPI and type(getgenv) == "function" then
    DrawingAPI = getgenv().Drawing
end

local State = {
    M1 = false,
    Dash = false,
    Tp = false,
    Wakeup = false,
    AutoAim = false,
    Esp = false,
    Burst = 4,
    Interval = 0.035,
    DashInterval = 0.5,
    HitInterval = 0.06,
    Scan = 2000,
    Combo = 0,
    ComboField = 0,
    LastPunch = 0,
    LastDash = 0,
    LastHit = 0,
    LastApply = 0,
    Target = "优先打残血",
    Enemy = nil,
    Moveset = nil,
    OrigDashes = nil,
    OrigRefill = nil,
    Saved = false,
    DashCooldown = nil,
    DashCharges = nil,
    AttackCooldown = nil,
    AttackMinCooldown = nil,
}

local Modules = nil
local ModuleFailed = false
local ByteNetPath = nil

local function Notify(text)
    pcall(function()
        Library:Notify(text, 3)
    end)
end

local function Load()
    if Modules then
        return Modules
    end
    if ModuleFailed then
        return nil
    end
    local ok, result = pcall(function()
        local Shared = ReplicatedStorage:WaitForChild("Shared", 15)
        if not Shared then
            error("缺少 Shared")
        end
        local Network = require(Shared.Network)
        return {
            Network = Network,
            Registry = require(Shared.Abilities.Registry),
            CombatUtil = require(Shared.Util.CombatUtil),
            HitboxUtil = require(Shared.Util.HitboxUtil),
            Config = require(Shared.Config),
            AttackConfig = require(Shared.Abilities.Config.Attack),
            Packet = Network.Combat.packets.AbilityActivated,
        }
    end)
    if not ok or not result then
        ModuleFailed = true
        return nil
    end
    Modules = result
    pcall(function()
        local Packages = ReplicatedStorage:FindFirstChild("Packages")
        local Index = Packages and Packages:FindFirstChild("_Index")
        local Net = Index and Index:FindFirstChild("elitriare_bytenet-max@0.2.7")
        local Bn = Net and Net:FindFirstChild("bytenet-max")
        local Sys = Bn and Bn:FindFirstChild("system")
        ByteNetPath = Sys and Sys:FindFirstChild("ByteNetReliable")
    end)
    return Modules
end

local function Root(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function Hum(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function PlayerNames()
    local list = { "优先打残血" }
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function FindEnemy(character, root)
    local m = Modules
    if not m then
        return nil, nil
    end

    if State.Target ~= "优先打残血" then
        local p = Players:FindFirstChild(State.Target)
        local pc = p and p.Character
        local pcRoot = Root(pc)
        local pcHum = Hum(pc)
        if pcRoot and pcHum and pcHum.Health > 0 then
            return pc, pcRoot
        end
        return nil, nil
    end

    local best, bestRoot, bestDistance, lowestHealth = nil, nil, State.Scan, math.huge

    for _, enemy in m.CombatUtil.Enemies(character) do
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        local eHum = enemy:FindFirstChildOfClass("Humanoid")
        if eRoot and eHum and eHum.Health > 0
            and eHum:GetState() ~= Enum.HumanoidStateType.Dead
            and m.HitboxUtil.IsTarget(enemy)
            and not m.HitboxUtil.IsUntouchable(enemy) then
            local distance = (eRoot.Position - root.Position).Magnitude
            if distance <= State.Scan then
                if eHum.Health < lowestHealth then
                    lowestHealth = eHum.Health
                    best, bestRoot = enemy, eRoot
                end
                if distance < bestDistance then
                    bestDistance = distance
                end
            end
        end
    end

    return best, bestRoot
end

local ESP = { Objects = {} }

local function CreateESP(p)
    if not DrawingAPI then
        return
    end
    local ok, objs = pcall(function()
        local name = DrawingAPI.new("Text")
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.Color = Color3.fromRGB(255, 255, 255)
        name.Visible = false

        local box = DrawingAPI.new("Square")
        box.Thickness = 1
        box.Color = Color3.fromRGB(0, 191, 255)
        box.Filled = false
        box.Visible = false

        local health = DrawingAPI.new("Text")
        health.Size = 12
        health.Center = true
        health.Outline = true
        health.Color = Color3.fromRGB(255, 50, 50)
        health.Visible = false

        return { Name = name, Box = box, Health = health }
    end)
    if ok and objs then
        ESP.Objects[p] = objs
    end
end

local function RemoveESP(p)
    local objs = ESP.Objects[p]
    if objs then
        for _, obj in pairs(objs) do
            pcall(function()
                obj:Remove()
            end)
        end
        ESP.Objects[p] = nil
    end
end

local function ClearESP()
    for p in pairs(ESP.Objects) do
        RemoveESP(p)
    end
end

local function HideESP(objs)
    objs.Name.Visible = false
    objs.Box.Visible = false
    objs.Health.Visible = false
end

local function UpdateESP()
    if not DrawingAPI then
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if not ESP.Objects[p] and State.Esp then
                CreateESP(p)
            end

            local objs = ESP.Objects[p]
            if objs then
                if not State.Esp then
                    HideESP(objs)
                else
                    local char = p.Character
                    local head = char and char:FindFirstChild("Head")
                    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and Hum(char)

                    if head and rootPart and humanoid and humanoid.Health > 0 then
                        local headPos, onScreen = cam:WorldToViewportPoint(head.Position)
                        local rootPos = cam:WorldToViewportPoint(rootPart.Position)

                        if onScreen then
                            local height = math.abs(headPos.Y - rootPos.Y) * 2.2
                            local width = height / 2

                            objs.Name.Visible = true
                            objs.Name.Text = p.Name
                            objs.Name.Position = Vector2.new(headPos.X, headPos.Y - 25)

                            objs.Box.Visible = true
                            objs.Box.Size = Vector2.new(width, height)
                            objs.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y - height / 2 - 5)

                            objs.Health.Visible = true
                            objs.Health.Text = "HP: " .. math.floor(humanoid.Health)
                            objs.Health.Position = Vector2.new(headPos.X, headPos.Y + height / 2 + 2)
                        else
                            HideESP(objs)
                        end
                    else
                        HideESP(objs)
                    end
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(RemoveESP)

local function Punch()
    local m = Modules
    if not m then
        return
    end
    if player:GetAttribute("InGame") ~= true then
        return
    end

    local character = player.Character
    local root = Root(character)
    local humanoid = Hum(character)
    if not (root and humanoid and humanoid.Health > 0) then
        return
    end

    local moveset = m.Registry.GetMoveset(player:GetAttribute("Moveset"))
    local attack = moveset and moveset.Abilities and moveset.Abilities[1]
    if not attack then
        return
    end

    local target, targetRoot, bestDistance = nil, nil, 4.5

    for _, enemy in m.CombatUtil.Enemies(character) do
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")

        if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0
            and m.HitboxUtil.IsTarget(enemy)
            and not m.HitboxUtil.IsUntouchable(enemy) then
            local distance = (enemyRoot.Position - root.Position).Magnitude
            if distance < bestDistance then
                target, targetRoot, bestDistance = enemy, enemyRoot, distance
            end
        end
    end

    if not target then
        return
    end

    local direction = targetRoot.Position - root.Position
    local flat = Vector3.new(direction.X, 0, direction.Z)
    local look = flat.Magnitude > 0.01 and flat.Unit or root.CFrame.LookVector

    for _ = 1, State.Burst do
        State.Combo = State.Combo % 4 + 1
        pcall(m.Packet.send, {
            AbilityId = attack.Id,
            ClientTime = workspace:GetServerTimeNow(),
            Victim = target,
            Position = root.Position,
            Look = look,
            VictimPosition = targetRoot.Position,
            Combo = State.Combo,
        })
    end
end

local function RestoreMoveset()
    if State.Moveset then
        pcall(function()
            State.Moveset.Dashes = State.OrigDashes
            State.Moveset.DashRefill = State.OrigRefill
        end)
    end
    State.Moveset = nil
    State.OrigDashes = nil
    State.OrigRefill = nil
end

local function SaveConfig()
    local m = Load()
    if not m or State.Saved then
        return m ~= nil
    end
    State.DashCooldown = m.Config.Dash.Cooldown
    State.DashCharges = m.Config.Dash.Charges
    State.AttackCooldown = m.AttackConfig.Cooldown
    State.AttackMinCooldown = m.AttackConfig.MinCooldown
    m.AttackConfig.Cooldown = 0.05
    m.AttackConfig.MinCooldown = 0.01
    State.Saved = true
    return true
end

local function RestoreConfig()
    local m = Modules
    if not m or not State.Saved then
        return
    end
    if State.DashCooldown ~= nil then
        m.Config.Dash.Cooldown = State.DashCooldown
    end
    if State.DashCharges ~= nil then
        m.Config.Dash.Charges = State.DashCharges
    end
    if State.AttackCooldown ~= nil then
        m.AttackConfig.Cooldown = State.AttackCooldown
    end
    if State.AttackMinCooldown ~= nil then
        m.AttackConfig.MinCooldown = State.AttackMinCooldown
    end
    State.Saved = false
    RestoreMoveset()
end

local function ApplyDash()
    local m = Load()
    if not m then
        return
    end
    m.Config.Dash.Cooldown = 0.02
    m.Config.Dash.Charges = 1000

    local moveset = m.Registry.GetMoveset(player:GetAttribute("Moveset"))
    if moveset ~= State.Moveset then
        RestoreMoveset()
        if moveset then
            State.Moveset = moveset
            State.OrigDashes = moveset.Dashes
            State.OrigRefill = moveset.DashRefill
        end
    end

    if moveset then
        moveset.Dashes = 1000
        moveset.DashRefill = nil
    end
end

local function StartGame()
    task.spawn(function()
        Load()
        for _ = 1, 3 do
            pcall(function()
                if ByteNetPath then
                    ByteNetPath:FireServer("\195\001")
                end
            end)
        end
    end)
end

local function TeleportTick()
    local m = Modules
    if not m then
        return
    end
    if player:GetAttribute("InGame") ~= true then
        return
    end

    local character = player.Character
    local root = Root(character)
    local humanoid = Hum(character)
    if not (root and humanoid and humanoid.Health > 0) then
        return
    end

    local moveset = m.Registry.GetMoveset(player:GetAttribute("Moveset"))
    local attack = moveset and moveset.Abilities and moveset.Abilities[1]
    if not attack then
        return
    end

    local now = os.clock()
    if now - State.LastApply >= 0.5 then
        State.LastApply = now
        pcall(ApplyDash)
    end

    local target = State.Enemy
    local targetRoot = Root(target)
    local targetHumanoid = Hum(target)

    if not (target and target.Parent and targetRoot and targetHumanoid
        and targetHumanoid.Health > 0
        and targetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead
        and not m.HitboxUtil.IsUntouchable(target)) then
        State.Enemy = nil
        target, targetRoot = FindEnemy(character, root)
        if not target then
            return
        end
        State.Enemy = target
        targetHumanoid = Hum(target)
        if not targetHumanoid then
            return
        end
    end

    local direction = root.Position - targetRoot.Position
    direction = direction.Magnitude > 0.1 and direction.Unit or Vector3.new(1, 0, 0)
    local followPos = targetRoot.Position + direction * 1.5

    pcall(function()
        root.CFrame = CFrame.lookAt(
            Vector3.new(followPos.X, targetRoot.Position.Y, followPos.Z),
            targetRoot.Position
        )
    end)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
    end)

    local targetState = targetHumanoid:GetState()
    local gettingUp = targetState == Enum.HumanoidStateType.GettingUp
        or targetState == Enum.HumanoidStateType.FallingDown

    if (now - State.LastHit >= State.HitInterval) or (State.Wakeup and gettingUp) then
        State.LastHit = now

        if State.AutoAim and not State.Tp then
            pcall(function()
                root.CFrame = CFrame.lookAt(
                    root.Position,
                    Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z)
                )
            end)
        end

        State.ComboField = State.ComboField % 4 + 1

        local lv = targetRoot.CFrame.LookVector
        local flat = Vector3.new(lv.X, 0, lv.Z)

        pcall(m.Packet.send, {
            AbilityId = attack.Id,
            ClientTime = workspace:GetServerTimeNow(),
            Victim = target,
            Position = root.Position,
            Look = flat.Magnitude > 0.01 and flat.Unit or root.CFrame.LookVector,
            VictimPosition = targetRoot.Position,
            Combo = State.ComboField,
        })
    end
end

player:GetAttributeChangedSignal("Moveset"):Connect(function()
    if State.Dash or State.M1 then
        pcall(ApplyDash)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(2)
    if State.Tp then
        StartGame()
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

RunService.Heartbeat:Connect(function()
    if State.Tp then
        pcall(TeleportTick)
    end

    if not (State.Dash or State.M1) then
        return
    end
    if not Modules then
        return
    end

    local now = os.clock()

    if State.Dash and now - State.LastDash >= State.DashInterval then
        State.LastDash = now
        pcall(ApplyDash)
    end

    if State.M1 and now - State.LastPunch >= State.Interval then
        State.LastPunch = now
        pcall(Punch)
    end
end)

local M1Toggle, DashToggle, TpToggle, WakeToggle, AimToggle, EspToggle, TargetDropdown

local function SetToggle(toggle, value)
    if not toggle then
        return
    end
    if toggle.SetValue then
        pcall(function()
            toggle:SetValue(value)
        end)
    elseif toggle.Set then
        pcall(function()
            toggle:Set(value)
        end)
    end
end

local function StopAll()
    State.M1 = false
    State.Dash = false
    State.Tp = false
    State.Esp = false
    SetToggle(M1Toggle, false)
    SetToggle(DashToggle, false)
    SetToggle(TpToggle, false)
    SetToggle(EspToggle, false)
    ClearESP()
    State.Enemy = nil
    RestoreConfig()
    Notify("已全部关闭并还原数据")
end

local function Unload()
    StopAll()
    if Library and Library.Unload then
        pcall(function()
            Library:Unload()
        end)
    end
    env.AA_Obsidian = nil
end

env.AA_Obsidian = {
    Stop = Unload,
    StopAll = StopAll,
}

TpToggle = TpBox:AddToggle("tp_attack", {
    Text = "传送连打",
    Default = false,
    Tooltip = "贴身站到目标身边 1.5 格并持续出拳",
    Callback = function(on)
        if on then
            if not Load() then
                Notify("未找到游戏模块，请进入对局后再开启")
                State.Tp = false
                SetToggle(TpToggle, false)
                return
            end
            State.Tp = true
            State.Enemy = nil
            State.LastHit = 0
            State.LastApply = 0
            StartGame()
            Notify("传送连打已开启")
        else
            State.Tp = false
            State.Enemy = nil
            Notify("传送连打已关闭")
        end
    end,
})

TpBox:AddSlider("tp_interval", {
    Text = "连打间隔",
    Default = 0.06,
    Min = 0.03,
    Max = 0.3,
    Rounding = 2,
    Suffix = "秒",
    Callback = function(value)
        State.HitInterval = value
    end,
})

WakeToggle = TpBox:AddToggle("tp_wakeup", {
    Text = "压起身",
    Default = false,
    Tooltip = "目标倒地或爬起时立刻补拳，不等间隔",
    Callback = function(on)
        State.Wakeup = on
    end,
})

AimToggle = TpBox:AddToggle("tp_aim", {
    Text = "原地自动转向",
    Default = false,
    Tooltip = "不贴身时把角色朝向目标，传送连打开启时由贴身逻辑接管",
    Callback = function(on)
        State.AutoAim = on
    end,
})


TargetDropdown = TargetBox:AddDropdown("target_pick", {
    Values = PlayerNames(),
    Default = 1,
    Multi = false,
    Text = "指定目标",
    Tooltip = "优先打残血或锁定某个玩家",
    Callback = function(value)
        State.Target = value
        State.Enemy = nil
    end,
})

TargetBox:AddButton("target_refresh", {
    Text = "刷新玩家列表",
    Func = function()
        if TargetDropdown and TargetDropdown.SetValues then
            TargetDropdown:SetValues(PlayerNames())
            Notify("玩家列表已刷新")
        else
            Notify("请重新执行脚本刷新列表")
        end
    end,
})

EspToggle = EspBox:AddToggle("esp_players", {
    Text = "玩家透视",
    Default = false,
    Tooltip = "敌人名字、方框与血量",
    Callback = function(on)
        if on and not DrawingAPI then
            Notify("当前执行器不支持绘图，透视不可用")
            State.Esp = false
            SetToggle(EspToggle, false)
            return
        end
        State.Esp = on
        if not on then
            ClearESP()
        end
        Notify(on and "透视已开启" or "透视已关闭")
    end,
})

M1Toggle = ComboBox:AddToggle("m1_combo", {
    Text = "自动连击",
    Default = false,
    Tooltip = "自动锁定最近敌人连续出拳",
    Callback = function(on)
        if on then
            if not Load() then
                Notify("未找到游戏模块，请进入对局后再开启")
                State.M1 = false
                SetToggle(M1Toggle, false)
                return
            end
            SaveConfig()
            State.M1 = true
            State.LastPunch = 0
            Notify("自动连击已开启")
        else
            State.M1 = false
            if not State.Dash then
                RestoreConfig()
            end
            Notify("自动连击已关闭")
        end
    end,
})

ComboBox:AddSlider("m1_rate", {
    Text = "出拳间隔",
    Default = 0.035,
    Min = 0.01,
    Max = 0.2,
    Rounding = 3,
    Suffix = "秒",
    Callback = function(value)
        State.Interval = value
    end,
})

ComboBox:AddSlider("m1_burst", {
    Text = "每击段数",
    Default = 4,
    Min = 1,
    Max = 16,
    Rounding = 0,
    Callback = function(value)
        State.Burst = value
    end,
})

DashToggle = DashBox:AddToggle("dash_inf", {
    Text = "无限冲刺",
    Default = false,
    Tooltip = "冲刺次数锁定为满并持续补充",
    Callback = function(on)
        if on then
            if not Load() then
                Notify("未找到游戏模块，请进入对局后再开启")
                State.Dash = false
                SetToggle(DashToggle, false)
                return
            end
            SaveConfig()
            State.Dash = true
            State.LastDash = 0
            pcall(ApplyDash)
            Notify("无限冲刺已开启")
        else
            State.Dash = false
            if not State.M1 then
                RestoreConfig()
            end
            Notify("无限冲刺已关闭")
        end
    end,
})

DashBox:AddSlider("dash_redo", {
    Text = "冲刺刷新速率",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Rounding = 2,
    Suffix = "秒",
    Callback = function(value)
        State.DashInterval = value
    end,
})

DashBox:AddButton("all_off", {
    Text = "全部关闭并还原",
    Func = function()
        StopAll()
    end,
    Tooltip = "关闭所有功能并恢复原始冷却与冲刺数据",
})

MenuBox:AddLabel("菜单快捷键"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "菜单开关",
})

MenuBox:AddButton("unload_btn", {
    Text = "卸载脚本",
    Func = function()
        Unload()
    end,
})

AboutBox:AddLabel("右 Shift 收起或展开面板")
AboutBox:AddLabel("开关默认关闭，退出前建议点全部关闭并还原")
AboutBox:AddLabel("传送连打会持续改写角色位置，注意对局风险")

Library.ToggleKeybind = Options.MenuKeybind

if ThemeManager then
    pcall(function()
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("AnimeArenaTheme")
        ThemeManager:ApplyToTab(Tabs.Settings)
    end)
end

if SaveManager then
    pcall(function()
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetFolder("AnimeArenaConfig")
        SaveManager:BuildConfigSection(Tabs.Settings)
    end)
end
