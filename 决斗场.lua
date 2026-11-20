local Env = getfenv()

local LogService = game:GetService("LogService")
local getconnections = Env.getconnections
local MessageOut = "MessageOut"
local cons = getconnections(LogService[MessageOut])
if cons then
    for _, v in pairs(cons) do
        pcall(function() v:Disable() end)
    end
end

local function cleanupConnections()
    pcall(function()
        for _, conn in ipairs(getconnections(LogService.MessageOut) or {}) do
            pcall(function() conn:Disable() end)
        end
    end)
end
cleanupConnections()

print("环境净化完成，LogService 干扰已禁用")

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/xdigb91/theme/refs/heads/main/XJWuicore.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/xdigb91/theme/refs/heads/main/XJWuitheme.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/xdigb91/theme/refs/heads/main/XJWuideploy.lua'))()

local Window = Library:CreateWindow({
    Title = "<font color='#FF69B4'>X</font><font color='#87CEEB'>J</font><font color='#4169E1'>W</font>",
    Footer = "<font color='#FF69B4'>X</font><font color='#87CEEB'>J</font><font color='#4169E1'>W</font> | 决斗场 | 作者：i",
    ShowCustomCursor = true,
})

local Tabs = {
    Combat = Window:AddTab('战斗'),
    Settings = Window:AddTab('设置'),
}

local cfg = {
    rng = 18,
    atk = false,
    blk = false,
    pry = false,
    ddg = false,
    ult = false,
    dashAtk = false,
    crit = false,
    win = 0.25,
    autoCollect = false,
    autoStrength = false,
    autoSteal = false,
    autoSpeed = false,
    autoRebirth = false,
    dodgeKey = false,
    fullBright = false,
    orbit = false,
    blind = false,
    annoy = false,
    flingAll = false,
    fakeLag = false,
    chatSpam = false,
    clone = false,
}

local CombatGroup = Tabs.Combat:AddLeftGroupbox('自动战斗')
CombatGroup:AddToggle('AutoAttack', {
    Text = '自动攻击',
    Default = false,
    Callback = function(v) cfg.atk = v end
})
CombatGroup:AddToggle('AutoBlock', {
    Text = '自动格挡',
    Default = false,
    Callback = function(v) cfg.blk = v end
})
CombatGroup:AddToggle('AutoParry', {
    Text = '自动招架',
    Default = false,
    Callback = function(v) cfg.pry = v end
})
CombatGroup:AddToggle('AutoDodge', {
    Text = '自动闪避',
    Default = false,
    Callback = function(v) cfg.ddg = v end
})
CombatGroup:AddToggle('AutoUltimate', {
    Text = '自动大招',
    Default = false,
    Callback = function(v) cfg.ult = v end
})
CombatGroup:AddToggle('DashAttack', {
    Text = '冲刺攻击',
    Default = false,
    Callback = function(v) cfg.dashAtk = v end
})
CombatGroup:AddToggle('CriticalStrike', {
    Text = '自动暴击',
    Default = false,
    Callback = function(v) cfg.crit = v end
})
CombatGroup:AddSlider('AttackRange', {
    Text = '攻击距离',
    Min = 5,
    Max = 30,
    Default = 18,
    Callback = function(v) cfg.rng = v end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox('配置管理')
SettingsGroup:AddDivider()
SettingsGroup:AddButton('保存配置', function()
    SaveManager:Save()
    Library:Notify('配置已保存', 2)
end)
SettingsGroup:AddButton('加载配置', function()
    SaveManager:Load()
    Library:Notify('配置已加载', 2)
end)
SettingsGroup:AddButton('卸载界面', function()
    Library:Unload()
end)

local InfoGroup = Tabs.Settings:AddRightGroupbox('信息')
InfoGroup:AddLabel('=== XJW ===')
InfoGroup:AddLabel('版本:  1.0.0')
InfoGroup:AddLabel('作者: i')
InfoGroup:AddDivider()
InfoGroup:AddLabel('菜单快捷键: RightShift')

pcall(function() Library.ToggleKeybind = 'RightShift' end)
pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({}) end)
pcall(function() ThemeManager:SetFolder('XJWUI_Demo') end)
pcall(function() SaveManager:SetFolder('XJWUI_Demo/config') end)
pcall(function() SaveManager:SetSubFolder('DemoVersion') end)
pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end)
pcall(function() ThemeManager:ApplyToTab(Tabs.Settings) end)
pcall(function() SaveManager:LoadAutoloadConfig() end)

pcall(function() Library:SetWatermarkVisibility(true) end)

local RunService = game:GetService('RunService')
local frameTimer = tick()
local frameCounter = 0
local fps = 60
RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1
    if (tick() - frameTimer) >= 1 then
        fps = frameCounter
        frameTimer = tick()
        frameCounter = 0
    end
    pcall(function() Library:SetWatermark(('XJW 示例 | %d fps'):format(math.floor(fps))) end)
end)

if not game:IsLoaded() then game.Loaded:Wait() end

pcall(function() Library:Notify('XJW决斗场加载完成', 3) end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local GM = require(ReplicatedStorage.GameManager)
local TLC = GM:GetController("TargetLockController")
local CC = GM:GetController("CharacterController")
local Rem = ReplicatedStorage.Remotes.PlayerCharacter

local QueueBasicAttackRemote = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("PlayerCharacter", 5) and ReplicatedStorage.Remotes.PlayerCharacter:WaitForChild("Request", 5) and ReplicatedStorage.Remotes.PlayerCharacter.Request:WaitForChild("QueueBasicAttack", 5)

local ok, BCC = pcall(function()
    return require(ReplicatedStorage.Controllers.CharacterController.BaseCharacterClient)
end)

if ok and BCC then
    BCC._setupWeaponReplication = function(self)
        self.WeaponToHandler = self.WeaponToHandler or {}
        local jan = self._janitor
        local function onWeaponAdded(w)
            if not self or not self.WeaponToHandler then return end
            local name = w.Name
            local existingHandler = self.WeaponToHandler[name]
            if existingHandler then
                existingHandler:Destroy()
                self.WeaponToHandler[name] = nil
            end
            local weaponModule = ReplicatedStorage.WeaponModulesShared:FindFirstChild(name)
            if not weaponModule then return end
            local ok2, mod = pcall(require, weaponModule)
            if not ok2 or not mod then return end
            local handlerInstance = jan:Add(mod.new(self, w))
            local function updateCosmetic()
                if handlerInstance and handlerInstance.SetCosmetic then
                    handlerInstance:SetCosmetic(w:GetAttribute("CurrentCosmetic") or "Default")
                end
            end
            local cosmeticConn = w:GetAttributeChangedSignal("CurrentCosmetic"):Connect(updateCosmetic)
            updateCosmetic()
            local ancestryConn
            ancestryConn = w.AncestryChanged:Connect(function(_, parent)
                if parent then return end
                if cosmeticConn then cosmeticConn:Disconnect() end
                if ancestryConn then ancestryConn:Disconnect() end
                if self.WeaponToHandler and self.WeaponToHandler[name] == handlerInstance then
                    self.WeaponToHandler[name] = nil
                end
                if handlerInstance and handlerInstance.Destroy then
                    handlerInstance:Destroy()
                end
            end)
            self.WeaponToHandler[name] = handlerInstance
        end
        local jan2 = self._janitor
        jan2:Add(task.spawn(function()
            if not self or not self.RigHandler then return end
            if not self.RigHandler.IsRigLoaded then self.RigHandler.RigLoaded:Wait() end
            if not self or not self.OriginalModel then return end
            local mw = self.OriginalModel:WaitForChild("MountedWeapons", 5)
            if mw then
                jan2:Add(mw.ChildAdded:Connect(onWeaponAdded))
                for _, w in ipairs(mw:GetChildren()) do
                    task.spawn(onWeaponAdded, w)
                end
            end
            if self._setupEquippedWeaponReplication then
                self:_setupEquippedWeaponReplication()
            end
        end))
    end
end

local nearbyEnemies = {}
task.spawn(function()
    while true do
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local myPos = root.Position
            local temp = {}
            for _, o in ipairs(CollectionService:GetTagged("CustomCharacter")) do
                if o ~= char then
                    local orr = o:FindFirstChild("HumanoidRootPart")
                    if orr then
                        local dist = (myPos - orr.Position).Magnitude
                        table.insert(temp, {char = o, root = orr, dist = dist})
                    end
                end
            end
            nearbyEnemies = temp
        else
            nearbyEnemies = {}
        end
        task.wait(0.1)
    end
end)

local function getHandler()
    local h = CC:GetLocalCharacterHandler()
    return (h and h.Root and h.ActionManager and h.WeaponToHandler) and h or nil
end

local function getActionManager()
    local h = getHandler()
    return h and h.ActionManager
end

local hookedAM = nil
local function hookActionManager(am)
    if not am or hookedAM == am then return end
    hookedAM = am
    local orig = am._resolveImpact
    if orig then
        am._resolveImpact = function(self, p2, p3)
            local h = self.CharacterHandler
            if not h or not h.WeaponToHandler or not h.EquippedWeapon then
                return orig(self, p2, p3)
            end
            local wp, wb = h.IsParrying, h.IsBlocking
            if cfg.pry then
                h.IsParrying = true
            elseif cfg.blk then
                h.IsBlocking = true
            end
            local v6, v4, v18, t2 = orig(self, p2, p3)
            h.IsParrying, h.IsBlocking = wp, wb
            return v6, v4, v18, t2
        end
    end
end

local function doBlock(handler, am, hasTarget, targetDistValid)
    if not cfg.blk or not handler or not am then return end
    if not targetDistValid then return end
    if not handler.EquippedWeapon or not hasTarget then
        if handler.IsBlocking or handler.IsParrying then
            local q = handler._blockInputQueue
            if q then
                for i = #q, 1, -1 do
                    if q[i].state == true then q[i].state = 0.133 end
                end
                local ba = am.BlockAction
                if ba then ba._wantsToRelease = true end
            end
        end
        return
    end
    local incoming = false
    if am.UnresolvedImpacts then
        for _ in pairs(am.UnresolvedImpacts) do
            incoming = true
            break
        end
    end
    local act = am.CurrentAction
    local stg = act and (act.ActionType == "Stagger" or act.ActionType == "GetHit")
    local isCloseRange = false
    for _, enemy in ipairs(nearbyEnemies) do
        if enemy.dist < 12 then
            isCloseRange = true
            break
        end
    end
    if incoming or stg or isCloseRange then
        if not handler.IsBlocking and not handler.IsParrying then
            local q = handler._blockInputQueue
            if q and #q < 2 then
                table.insert(q, {state = true})
            end
        end
    else
        if handler.IsBlocking or handler.IsParrying then
            local q = handler._blockInputQueue
            if q then
                for i = #q, 1, -1 do
                    if q[i].state == true then q[i].state = 0.133 end
                end
                local ba = am.BlockAction
                if ba then ba._wantsToRelease = true end
            end
        end
    end
end

local weaponCache = {}
local function getWeaponCaps(wepName)
    if not wepName then return false, false, false end
    if weaponCache[wepName] ~= nil then
        local cache = weaponCache[wepName]
        return cache.hasDashLight, cache.hasDashHeavy, cache.hasLight04
    end
    local hasDashLight, hasDashHeavy, hasLight04 = false, false, false
    local wepPath = ReplicatedStorage.WeaponModulesShared:FindFirstChild(wepName)
    if wepPath then
        local basicAttackTypes = wepPath:FindFirstChild("BasicAttackTypes")
        if basicAttackTypes then
            hasDashLight = basicAttackTypes:FindFirstChild("DashLight") ~= nil
            hasDashHeavy = basicAttackTypes:FindFirstChild("DashHeavy") ~= nil
            hasLight04 = basicAttackTypes:FindFirstChild("Light04") ~= nil
        end
    end
    weaponCache[wepName] = {
        hasDashLight = hasDashLight,
        hasDashHeavy = hasDashHeavy,
        hasLight04 = hasLight04
    }
    return hasDashLight, hasDashHeavy, hasLight04
end

local function doAttack(handler, am, target, targetDist, targetDistValid)
    if not targetDistValid then return end
    if not cfg.atk or not handler or not target or not am then return end
    if handler.OriginalModel:GetAttribute("IsDead") or handler:GetIgnoreInput() then return end
    local equipWep = handler.EquippedWeapon
    local wepName = equipWep and equipWep.Name or nil
    if not equipWep then
        Rem.Request.SetEquippedWeapon:FireServer(true)
        return
    end
    local act = am.CurrentAction
    local canQueue = not act or act.CanQueueActions or act.CanCancel
    local hasDashLight, hasDashHeavy, hasLight04 = getWeaponCaps(wepName)
    if canQueue and not am._queuedActionType and equipWep then
        if cfg.crit then
            local isTargetStaggered = target:GetAttribute("IsStaggered") or target:GetAttribute("PostureBroken")
            if not isTargetStaggered and target:FindFirstChild("Action") then
                local actVal = target.Action:GetAttribute("CurrentAction")
                if actVal == "Stagger" or actVal == "GetHit" then
                    isTargetStaggered = true
                end
            end
            if isTargetStaggered then
                handler._desiredQueuedAction = "CriticalStrike"
                handler._desiredQueuedActionDuration = nil
                return
            end
        end
        if cfg.ult and targetDist <= 10 then
            local energy = handler.OriginalModel:GetAttribute("UltimateEnergy") or 0
            if energy >= 100 then
                handler._desiredQueuedAction = "Ultimate"
                handler._desiredQueuedActionDuration = nil
                return
            end
        end
        local rand = math.random()
        if cfg.dashAtk and hasDashLight and hasDashHeavy and QueueBasicAttackRemote then
            if rand < 0.12 then
                QueueBasicAttackRemote:FireServer("25", wepName, "DashLight")
                return
            elseif rand < 0.24 then
                QueueBasicAttackRemote:FireServer("20", wepName, "DashHeavy")
                return
            end
        end
        if wepName == "Kusarigama" and hasLight04 then
            if rand < 0.70 then
                handler._desiredQueuedAction = "LightAttack"
            else
                handler._desiredQueuedAction = "HeavyAttack"
            end
        elseif wepName == "Gauntlets" then
            if rand < 0.80 then
                handler._desiredQueuedAction = "LightAttack"
            else
                handler._desiredQueuedAction = "HeavyAttack"
            end
        elseif wepName == "Warhammer" or wepName == "Naginata" then
            if rand < 0.50 then
                handler._desiredQueuedAction = "HeavyAttack"
            else
                handler._desiredQueuedAction = "LightAttack"
            end
        else
            if rand < 0.60 then
                handler._desiredQueuedAction = "LightAttack"
            else
                handler._desiredQueuedAction = "HeavyAttack"
            end
        end
        handler._desiredQueuedActionDuration = nil
    end
end

local function doDodge(handler, am, targetDistValid)
    if not cfg.ddg or not handler or not am then return end
    if not targetDistValid then return end
    local act = am.CurrentAction
    if act and act.ActionType == "Stagger" then
        handler._desiredDodge = 0.266
    end
end

RunService.RenderStepped:Connect(function()
    local handler = getHandler()
    local am = getActionManager()
    if not handler or not am then return end
    hookActionManager(am)
    local targetPart = handler.TargetLock or (TLC and TLC.Target)
    local hasTarget = false
    local target = nil
    local targetDist = math.huge
    local targetDistValid = false
    if targetPart and targetPart:IsA("BasePart") then
        target = targetPart.Parent
        local rootSelf = handler.Root
        local rootTar = target and target:FindFirstChild("HumanoidRootPart")
        if target and rootTar and rootSelf then
            hasTarget = true
            targetDist = (rootSelf.Position - rootTar.Position).Magnitude
            targetDistValid = targetDist <= cfg.rng
        end
    end
    if hasTarget and target then
        if targetDistValid then
            doAttack(handler, am, target, targetDist, targetDistValid)
            doDodge(handler, am, targetDistValid)
            local r = handler.Root
            if r and targetPart then
                local dir = (targetPart.Position - r.Position).Unit
                handler.DesiredLookDirection = Vector3.new(dir.X, 0, dir.Z)
                handler.DesiredLookResponsiveness = 100
            end
        else
            handler.DesiredMoveDirection = Vector3.new(0,0,0)
        end
    else
        handler.DesiredMoveDirection = Vector3.new(0,0,0)
    end
    doBlock(handler, am, hasTarget, targetDistValid)
end)

task.spawn(function()
    while true do
        if cfg.autoCollect then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v:GetAttribute("CanCollect") then
                        local char = LP.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            if (hrp.Position - v.Position).Magnitude < 10 then
                                firetouchinterest(hrp, v, 0)
                                firetouchinterest(hrp, v, 1)
                            end
                        end
                    end
                end
            end)
        end
        if cfg.autoStrength then
            pcall(function()
                local char = LP.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    local animTrack = hum:LoadAnimation(Instance.new("Animation"))
                    if not animTrack.IsPlaying then
                        animTrack:Play()
                        task.wait(1)
                        animTrack:Stop()
                    end
                end
            end)
        end
        if cfg.autoSteal then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Tool") and v.Parent and v.Parent:IsA("Model") and v.Parent:FindFirstChild("Humanoid") and v.Parent ~= LP.Character then
                        local char = LP.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            if (hrp.Position - v.Position).Magnitude < 8 then
                                firetouchinterest(hrp, v, 0)
                                firetouchinterest(hrp, v, 1)
                            end
                        end
                    end
                end
            end)
        end
        if cfg.autoSpeed then
            pcall(function()
                local stats = LP:FindFirstChild("leaderstats")
                if stats and stats:FindFirstChild("SpeedTokens") then
                    local token = stats.SpeedTokens.Value
                    if token > 0 then
                        local upgrade = workspace:FindFirstChild("SpeedUpgrade")
                        if upgrade then
                            firetouchinterest(LP.Character.HumanoidRootPart, upgrade, 0)
                            firetouchinterest(LP.Character.HumanoidRootPart, upgrade, 1)
                        end
                    end
                end
            end)
        end
        if cfg.autoRebirth then
            pcall(function()
                local stats = LP:FindFirstChild("leaderstats")
                if stats and stats:FindFirstChild("Level") and stats.Level.Value >= 100 then
                    local rebirth = workspace:FindFirstChild("RebirthStone")
                    if rebirth then
                        firetouchinterest(LP.Character.HumanoidRootPart, rebirth, 0)
                        firetouchinterest(LP.Character.HumanoidRootPart, rebirth, 1)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    local originalJumpPower = nil
    while true do
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if cfg.infJump and hum then
            if originalJumpPower == nil then
                originalJumpPower = hum.JumpPower
            end
            hum.JumpPower = 50
            local con
            con = hum:GetPropertyChangedSignal("Jump"):Connect(function()
                if hum.Jump then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            task.wait(0.5)
            if con then con:Disconnect() end
        elseif hum and originalJumpPower then
            hum.JumpPower = originalJumpPower
            originalJumpPower = nil
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if cfg.float and hrp then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = Vector3.new(0, 5, 0)
            bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVel.Parent = hrp
            task.wait(0.1)
            bodyVel:Destroy()
        end
        if cfg.noclip and char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        elseif char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    local originalBrightness = Lighting.Brightness
    local originalClockTime = Lighting.ClockTime
    while true do
        if cfg.fullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = originalBrightness
            Lighting.ClockTime = originalClockTime
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
        task.wait(1)
    end
end)

local function createOrbit(target)
    if not cfg.orbit then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPos.D = 1000
    bodyPos.P = 5000
    local angle = 0
    local radius = 5
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not cfg.orbit or not char or not target or not target.Parent then
            bodyPos:Destroy()
            if connection then connection:Disconnect() end
            return
        end
        angle = angle + 0.05
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        bodyPos.Position = targetHrp.Position + offset
        bodyPos.Parent = hrp
    end)
end

task.spawn(function()
    while true do
        if cfg.blind then
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "BlindGui"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,0,1,0)
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BackgroundTransparency = 0.8
            frame.Parent = screenGui
            screenGui.Parent = LP.PlayerGui
            task.wait(0.5)
            screenGui:Destroy()
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if cfg.annoy then
            local target = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP then
                    target = plr.Character
                    if target then break end
                end
            end
            if target and target:FindFirstChild("HumanoidRootPart") then
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0,0,2)
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if cfg.flingAll then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = Instance.new("BodyVelocity")
                        vel.Velocity = Vector3.new(0, 200, 0)
                        vel.MaxForce = Vector3.new(0, math.huge, 0)
                        vel.Parent = hrp
                        task.wait(0.1)
                        vel:Destroy()
                    end
                end
            end
            cfg.flingAll = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if cfg.fakeLag then
            task.wait(0.5)
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if cfg.chatSpam then
            local text = "XJW 最牛脚本！"
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if cfg.clone then
            local char = LP.Character
            if char then
                local clone = char:Clone()
                clone.Parent = workspace
                clone:BreakJoints()
                for _, v in ipairs(clone:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
                local humanoid = clone:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
                task.wait(5)
                clone:Destroy()
            end
            cfg.clone = false
        end
        task.wait(0.5)
    end
end)

local speedActive = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q and cfg.dodgeKey then
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if not speedActive then
                speedActive = true
                hum.WalkSpeed = hum.WalkSpeed * 2
                task.wait(1)
                hum.WalkSpeed = hum.WalkSpeed / 2
                speedActive = false
            end
        end
    end
end)
