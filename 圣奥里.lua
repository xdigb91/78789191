

if getgenv().XJWScriptLoaded then
    pcall(function()
        if getgenv().XJWScript and getgenv().XJWScript.Unload then
            getgenv().XJWScript.Unload()
        end
    end)
end
getgenv().XJWScriptLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local PlayerControls = nil
task.spawn(function()
    pcall(function()
        local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 15)
        local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 10)
        if playerModule then
            PlayerControls = require(playerModule):GetControls()
        end
    end)
end)

local newcclosure = newcclosure or function(f)
    return f
end
local gethuiFn = gethui or function()
    return nil
end
local hookfunctionFn = hookfunction
local hookmetamethodFn = hookmetamethod
local getnamecallmethodFn = getnamecallmethod
local getrawmetatableFn = getrawmetatable
local setreadonlyFn = setreadonly
local firepromptFn = fireproximityprompt

local Connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end
local function clearConnections()
    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    table.clear(Connections)
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local Theme = {
    bg = Color3.fromRGB(7, 4, 14),
    panel = Color3.fromRGB(12, 8, 22),
    surface = Color3.fromRGB(19, 13, 34),
    surface2 = Color3.fromRGB(27, 19, 48),
    stroke = Color3.fromRGB(66, 44, 108),
    text = Color3.fromRGB(241, 233, 255),
    subtext = Color3.fromRGB(164, 148, 192),
    accent = Color3.fromRGB(168, 85, 247),
    accent2 = Color3.fromRGB(124, 58, 237),
    accent3 = Color3.fromRGB(232, 196, 255),
    green = Color3.fromRGB(74, 222, 128),
    red = Color3.fromRGB(248, 113, 113),
    amber = Color3.fromRGB(251, 191, 36),
}

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or Theme.accent, c2 or Theme.accent2)
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

function XJWMetal(parent, dark, light, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, dark),
        ColorSequenceKeypoint.new(0.16, light),
        ColorSequenceKeypoint.new(0.48, dark),
        ColorSequenceKeypoint.new(0.72, light),
        ColorSequenceKeypoint.new(1, dark),
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color or Theme.stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.3,
    }, parent)
end

local function text(parent, str, size, color, font, xAlign)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = str,
        TextSize = size or 12,
        TextColor3 = color or Theme.text,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = xAlign or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end


local REPOS = {
    "https://cdn.jsdelivr.net/gh/finendss/VowLibrary@refs/heads/main/",
    "https://ghproxy.net/https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/",
    "https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/",
}
local function fetchWindUI()
    local content = nil
    for _, repo in ipairs(REPOS) do
        local ok, c = pcall(function()
            return game:HttpGet(repo .. "WINDUI.lua")
        end)
        if ok and c and #c > 0 then
            content = c
            break
        end
    end
    if content then
        content = content:gsub(
            "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua",
            "https://cdn.jsdelivr.net/gh/Footagesus/Icons@main/Main-v2.lua"
        )
        local fn = loadstring(content)
        if fn then
            local okChunk, result = pcall(fn)
            if okChunk then
                return result
            end
        end
    end
end

local WindUI = fetchWindUI()
if not WindUI then
    local deadline = tick() + 15
    while not WindUI and tick() < deadline do
        WindUI = fetchWindUI()
        task.wait(1)
    end
end
if not WindUI then
    getgenv().XJWScriptLoaded = false
    return nil
end

local function Notify(title, body, kind)
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify({
                Title = title or "",
                Content = body or "",
                Duration = 3,
            })
        end)
    end
end

local guiParent
pcall(function()
    guiParent = gethuiFn()
end)
if not guiParent then
    local ok, core = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok then
        guiParent = core
    end
end
if not guiParent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end



local Settings = {
    
    stamina = false,
    hunger = false,
    infiniteAmmo = false,
    rapidFire = false,
    autoMoney = false,
    instantPrompt = false,
    noRagdoll = false,
    noFallDamage = false,
    antiPull = false,
    ghost = false,
    ghostHud = false,
    ghostLock = false,
    ghostExposeTime = 4,
    ghostExposeKey = Enum.KeyCode.G,
    combatBlock = false,
    autoHack = false,
    autoAtm = false,
    
    autoMission = false,
    missionPriority = false,
    missionInterval = 2,
    taxi = false,
    taxiSafe = false,
    taxiMode = "随机时间",
    bus = false,
    farmer = false,
    golf = false,
    
    aura = false,
    auraRange = 50,
    auraDamage = 5,
    auraInterval = 0.05,
    auraPolice = false,
    auraCivilian = false,
    auraCombat = false,
    ragebot = false,
    rageRange = 150,
    rageInterval = 0.05,
    ragePart = "Head",
    rageJob = false,
    rageWall = false,
    rageCombat = false,
    ragePolice = false,
    rageCivilian = false,
    rageBeam = false,
    rangeEnabled = false,
    rangeSize = 50,
    rangeTransparency = 0.75,
    rangeColor = "紫色",
    rangeMaterial = "Neon",
    rangeOutline = false,
    rangeCollision = false,
    rangeGlow = false,
    rangePulse = false,
    
    aim = false,
    aimHold = true,
    aimFov = 140,
    aimSmooth = 25,
    aimPart = "头部",
    aimTeam = true,
    aimFriend = true,
    aimWall = true,
    aimPredict = false,
    aimMode = "准心最近",
    aimPolice = false,
    aimCivilian = false,
    aimCombat = false,
    aimVehicles = false,
    aimVehiclesKey = Enum.KeyCode.T,
    aimShowFov = true,
    aimFovThickness = 1.5,
    aimTracer = true,
    aimCrosshair = true,
    aimColor = "紫色",
    
    silent = false,
    silentFov = 140,
    silentDistance = 300,
    silentPart = "头部",
    silentTeam = true,
    silentFriend = true,
    silentCombat = false,
    silentPolice = false,
    silentCivilian = false,
    silentShowFov = false,
    
    hitbox = false,
    hitboxSize = 10,
    hitboxTransparency = 0.65,
    hitboxTeam = true,
    hitboxOutline = true,
    hitboxGlow = true,
    hitboxPulse = false,
    hitboxColor = "紫色",
    
    esp = false,
    espName = true,
    espDistance = true,
    espHealth = true,
    espBox = true,
    espHighlight = true,
    espTracer = false,
    espTracerOrigin = "屏幕底部",
    espFugitive = true,
    autoRefill = false,
    espTeams = {
        Chef = true, Civilian = true, Delivery = true, Farmer = true,
        Fire = true, Police = true, Medical = true, Prisoner = true,
        ["Road Service"] = true, Transit = true,
    },
    
    walkEnabled = false,
    walkSpeed = 200,
    jumpEnabled = false,
    jumpPower = 50,
    jumpMultiplier = 1,
    infJump = false,
    fly = false,
    flySpeed = 35,
    flyMode = "传送",
    noclip = false,
    blink = false,
    blinkDistance = 120,
    blinkKey = Enum.KeyCode.Eight,
    
    vehicleBoost = false,
    vehicleSpeed = 120,
    cruise = false,
    vehicleFly = false,
    vehicleFlySpeed = 80,
    vehicleFlyKey = Enum.KeyCode.F,
    vehicleEsp = false,
    vehicleEspName = true,
    vehicleEspDistance = true,
    vehicleEspHighlight = true,
    bringDistance = 12,
    bringVehicleKey = Enum.KeyCode.B,
    
    policeCuff = false,
    policeTp = false,
    policeRange = 200,
    policeInterval = 0.5,
    policeCombat = false,
    
    menuKey = Enum.KeyCode.RightShift,
    uiScale = 1,
    quickHud = UserInputService.TouchEnabled,
    quickButtonX = 12,
    quickButtonY = 250,
    quickPanelX = 12,
    quickPanelY = 74,
}

local AimParts = {
    ["头部"] = "Head",
    ["胸部"] = "UpperTorso",
    ["躯干"] = "Torso",
    ["左臂"] = "LeftArm",
    ["右臂"] = "RightArm",
    ["左腿"] = "LeftLeg",
    ["右腿"] = "RightLeg",
}

local Colors = {
    ["红色"] = Color3.fromRGB(255, 60, 60),
    ["紫色"] = Color3.fromRGB(180, 110, 255),
    ["粉色"] = Color3.fromRGB(255, 120, 220),
    ["蓝色"] = Color3.fromRGB(80, 150, 255),
    ["青色"] = Color3.fromRGB(80, 240, 255),
    ["绿色"] = Color3.fromRGB(90, 240, 130),
    ["黄色"] = Color3.fromRGB(255, 220, 90),
    ["白色"] = Color3.fromRGB(245, 245, 255),
}

local TeamColors = {
    Chef = Color3.fromRGB(255, 205, 60),
    Civilian = Color3.fromRGB(110, 200, 255),
    Delivery = Color3.fromRGB(255, 155, 60),
    Farmer = Color3.fromRGB(90, 220, 110),
    Fire = Color3.fromRGB(255, 70, 70),
    Police = Color3.fromRGB(80, 130, 255),
    Medical = Color3.fromRGB(255, 110, 230),
    Prisoner = Color3.fromRGB(255, 160, 160),
    ["Road Service"] = Color3.fromRGB(255, 240, 110),
    Transit = Color3.fromRGB(110, 240, 245),
}

local TeamNames = {
    Chef = "厨师",
    Civilian = "平民",
    Delivery = "配送员",
    Farmer = "农民",
    Fire = "消防员",
    Police = "警察",
    Medical = "医护人员",
    Prisoner = "囚犯",
    ["Road Service"] = "道路服务",
    Transit = "交通",
}



local function getChar(player)
    player = player or LocalPlayer
    local seen = {}
    local list = {}

    local function add(model)
        if model and typeof(model) == "Instance" and model:IsA("Model") and not seen[model] then
            seen[model] = true
            table.insert(list, model)
        end
    end
    pcall(function()
        add(player.Character)
    end)
    pcall(function()
        local folder = Workspace:FindFirstChild("Characters")
        if folder then
            add(folder:FindFirstChild(player.Name))
        end
    end)

    for _, char in ipairs(list) do
        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid", true)
        local root = char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or (humanoid and humanoid.RootPart)
            or char.PrimaryPart
            or char:FindFirstChildWhichIsA("BasePart")
        if root then
            return char, humanoid, root
        end
    end
    return nil
end

local function getRoot(player)
    local _, _, root = getChar(player)
    return root
end

local function isAlive(player)
    local _, humanoid = getChar(player)
    return humanoid ~= nil and humanoid.Health > 0
end

local function teamOf(player)
    return player and player.Team and player.Team.Name or "Civilian"
end

local function wantedOf(player)
    local value = player:GetAttribute("WantedLevel")
    if value == nil then
        local char = player.Character
        value = char and char:GetAttribute("WantedLevel")
    end
    return tonumber(value) or 0
end

local function inCombat(player)
    return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end

local function isFugitive(player)
    return teamOf(player) == "Civilian" and wantedOf(player) > 0
end

local function isFriend(player)
    local ok, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    return ok and result
end

local function colorOf(name)
    if name == "彩虹色" then
        return Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
    return Colors[name] or Theme.accent
end

local function passesFilter(player, onlyPolice, onlyCivilian)
    if not player or player == LocalPlayer then
        return false
    end
    if onlyPolice then
        return teamOf(player) == "Police"
    end
    if onlyCivilian then
        return teamOf(player) == "Civilian"
    end
    return true
end

local function isVisible(part)
    if not Settings.aimWall and not Settings.rageWall and not Settings.silent then
        return true
    end
    local cam = Workspace.CurrentCamera
    if not cam or not part then
        return false
    end
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    table.insert(filter, cam)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function getAimPart(char)
    if not char then
        return nil
    end
    local name = AimParts[Settings.aimPart] or "Head"
    local part = char:FindFirstChild(name)
    if part then
        return part
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function getRagePart(char, partName)
    if not char then
        return nil
    end
    return char:FindFirstChild(partName or Settings.ragePart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
end

local function screenPosition(worldPos)
    local cam = Workspace.CurrentCamera
    if not cam then
        return nil, false
    end
    local pos, onScreen = cam:WorldToViewportPoint(worldPos)
    return Vector2.new(pos.X, pos.Y), onScreen and pos.Z > 0, pos.Z
end



local Remote, PlayerEvent, PlayerFunc
pcall(function()
    Remote = ReplicatedStorage:FindFirstChild("Remote") or ReplicatedStorage:WaitForChild("Remote", 10)
    if Remote then
        PlayerEvent = Remote:FindFirstChild("PlayerEvent") or Remote:WaitForChild("PlayerEvent", 10)
        PlayerFunc = Remote:FindFirstChild("PlayerFunc") or Remote:WaitForChild("PlayerFunc", 10)
    end
end)

local Framework, Core, CharacterModule, InventoryModule
task.spawn(function()
    pcall(function()
        local scripts = LocalPlayer:WaitForChild("PlayerScripts", 15)
        local fw = scripts and scripts:WaitForChild("Framework", 15)
        if not fw then
            return
        end
        Framework = fw
        local characterModule = fw:FindFirstChild("Character")
        if characterModule then
            CharacterModule = require(characterModule)
            local inv = characterModule:FindFirstChild("Inventory")
            if inv then
                InventoryModule = require(inv)
            end
        end
        local coreModule = fw:FindFirstChild("Core")
        if coreModule then
            Core = require(coreModule)
        end
    end)
end)

local LogSink = nil
local function log(message, kind)
    kind = kind or "info"
    pcall(function()
        print("[圣奥里] " .. tostring(message))
    end)
    if LogSink then
        pcall(LogSink, tostring(message), kind)
    end
end



local namecallInstalled = false
local function installNamecall()
    if namecallInstalled then
        return
    end
    if not (getrawmetatableFn and setreadonlyFn and hookmetamethodFn and getnamecallmethodFn) then
        return
    end
    local ok = pcall(function()
        local mt = getrawmetatableFn(game)
        local original = mt.__namecall
        setreadonlyFn(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethodFn()
            if method == "FireServer" then
                local args = table.pack(...)
                if Settings.noFallDamage and tostring(self) == "PlayerEvent" and args[1] == "takeDamage" then
                    return nil
                end
                if Settings.combatBlock and args[1] == "combatMode" then
                    return nil
                end
            end
            return original(self, ...)
        end)
        setreadonlyFn(mt, true)
        namecallInstalled = true
    end)
    if ok then
        log("Namecall 钩子已挂载", "success")
    end
end
installNamecall()

local raycastHooked = false
local silentTargetRef = nil

local function installRaycast()
    if raycastHooked or not hookfunctionFn then
        return
    end
    local original = Workspace.Raycast
    if not original then
        return
    end
    local ok = pcall(function()
        hookfunctionFn(original, function(a, b, c, d)
            local self, origin, direction, params
            if typeof(a) == "Instance" then
                self, origin, direction, params = a, b, c, d
            else
                self, origin, direction, params = nil, a, b, c
            end
            if Settings.silent and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and silentTargetRef then
                local _, _, root = getChar(LocalPlayer)
                if root and (origin - root.Position).Magnitude < 15 then
                    direction = (silentTargetRef - origin).Unit * direction.Magnitude
                end
            end
            if self then
                return original(self, origin, direction, params)
            end
            return original(origin, direction, params)
        end)
    end)
    if ok then
        raycastHooked = true
        log("Silent Aim 射线钩子已挂载", "success")
    end
end
installRaycast()


local ragdollHooked = false
local function installRagdollHook()
    if ragdollHooked then
        return
    end
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local ragdollModule = modules and modules:FindFirstChild("Ragdoll")
        if not ragdollModule then
            return
        end
        local ragdoll = require(ragdollModule)
        if ragdoll and ragdoll.activate then
            local original = ragdoll.activate
            ragdoll.activate = function(a, b, c, ...)
                if Settings.noRagdoll and b then
                    return
                end
                return original(a, b, c, ...)
            end
            if ragdoll.activateServer then
                local originalServer = ragdoll.activateServer
                ragdoll.activateServer = function(a, b, c, ...)
                    if Settings.noRagdoll and b then
                        return
                    end
                    return originalServer(a, b, c, ...)
                end
            end
            ragdollHooked = true
        end
    end)
end
installRagdollHook()

local algorithmsRef = nil
local algorithmsOriginal = nil
local function setAntiPull(on)
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local algorithmsModule = modules and modules:FindFirstChild("Algorithms")
        if not algorithmsModule then
            return
        end
        local algorithms = require(algorithmsModule)
        algorithmsRef = algorithms
        if on and not algorithmsOriginal then
            algorithmsOriginal = algorithms.charPivotTo
            algorithms.charPivotTo = function()
                return nil
            end
        elseif not on and algorithmsOriginal then
            algorithms.charPivotTo = algorithmsOriginal
            algorithmsOriginal = nil
        end
    end)
end

local function firePrompt(prompt)
    if not prompt then
        return
    end
    pcall(function()
        if firepromptFn then
            firepromptFn(prompt, 0)
        else
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait(0.08)
            prompt:InputHoldEnd()
        end
    end)
end

XJWPromptDebounce = setmetatable({}, { __mode = "k" })
pcall(function()
    local promptService = game:GetService("ProximityPromptService")
    local promptEvent = promptService and promptService.PromptButtonHoldBegan
    if not promptEvent then
        return
    end
    promptEvent:Connect(function(prompt)
        if not Settings.instantPrompt or not prompt then
            return
        end
        local now = tick()
        local last = XJWPromptDebounce[prompt]
        if last and now - last < 0.25 then
            return
        end
        XJWPromptDebounce[prompt] = now
        pcall(firePrompt, prompt)
    end)
end)

local function objectPosition(instance)
    if not instance or not instance.Parent then
        return nil
    end
    local parent = instance.Parent
    if parent:IsA("BasePart") then
        return parent.Position
    end
    if parent:IsA("Attachment") then
        return parent.WorldPosition
    end
    if parent:IsA("Model") then
        local primary = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
        return primary and primary.Position or nil
    end
    return nil
end

local function teleportTo(position)
    if not position then
        return
    end
    local char = LocalPlayer.Character
    if not char then
        return
    end
    local cframe = CFrame.new(position + Vector3.new(0, 3, 0))
    pcall(function()
        char:PivotTo(cframe)
    end)
    if PlayerEvent then
        pcall(function()
            local id = (tonumber(char:GetAttribute("CharPivotToId")) or 0) + 1
            id = id % 100
            char:SetAttribute("CharPivotToId", id)
            PlayerEvent:FireServer("charPivotTo", cframe, char, id)
        end)
    end
end

local BlinkState = { last = 0 }

function XJWBlink()
    if not Settings.blink then
        Notify("Blink", "请先开启 Blink", "warn")
        return
    end
    local now = tick()
    if now - BlinkState.last < 0.25 then
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local mouse = UserInputService:GetMouseLocation()
    if UserInputService.TouchEnabled then
        mouse = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
    if mouse.X == 0 and mouse.Y == 0 then
        mouse = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    local distance = math.clamp(Settings.blinkDistance or 120, 10, 1000)
    local result = Workspace:Raycast(ray.Origin, ray.Direction * (distance * 4), params)
    local target
    if result then
        target = result.Position + result.Normal * 3
    else
        target = ray.Origin + ray.Direction * distance
    end
    BlinkState.last = now
    teleportTo(target)
    log(string.format("Blink %.0f studs", (target - ray.Origin).Magnitude), "info")
end



local ghostGui = nil
local ghostButton = nil
local ghostParent = guiParent
local ghostBtnPos = UDim2.new(0, 100, 0.5, -25)

local function applyGhostBody(char, on)
    if not char then
        return
    end
    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
            descendant.LocalTransparencyModifier = on and 0.55 or 0
            descendant.Material = on and Enum.Material.ForceField or Enum.Material.SmoothPlastic
        elseif descendant:IsA("Decal") and descendant.Name == "face" then
            descendant.Transparency = on and 0.55 or 0
        end
    end
end

local GhostState = { exposedUntil = 0 }

function XJWGhostHide()
    local char = LocalPlayer.Character
    if not char then
        return
    end
    pcall(function()
        char:SetAttribute("Invisible", true)
    end)
    applyGhostBody(char, true)
    pcall(function()
        local stuff = ReplicatedStorage:FindFirstChild("Stuff")
        local locations = stuff and stuff:FindFirstChild("Locations")
        local location = locations and locations:GetChildren()[1]
        if PlayerFunc and location then
            PlayerFunc:InvokeServer("hideCharacterLocation", location)
        end
    end)
    if ghostButton then
        ghostButton.Text = "隐身  开"
        ghostButton.TextColor3 = Theme.accent3
    end
end

function XJWGhostShow()
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            char:SetAttribute("Invisible", nil)
        end)
        applyGhostBody(char, false)
    end
    pcall(function()
        if PlayerFunc then
            PlayerFunc:InvokeServer("hideCharacterLocation", false)
        end
    end)
    if ghostButton then
        if Settings.ghost then
            ghostButton.Text = "现身中"
            ghostButton.TextColor3 = Theme.amber
        else
            ghostButton.Text = "隐身  关"
            ghostButton.TextColor3 = Theme.red
        end
    end
end

function XJWGhostExpose(seconds)
    if not Settings.ghost then
        Notify("Ghost", "请先开启隐身", "warn")
        return
    end
    local duration = tonumber(seconds) or Settings.ghostExposeTime or 4
    GhostState.exposedUntil = tick() + duration
    XJWGhostShow()
    Notify("Ghost", string.format("短暂现身 %.1f 秒", duration), "warn")
end

function XJWGhostResume()
    GhostState.exposedUntil = 0
    if Settings.ghost then
        XJWGhostHide()
    end
end

local function setGhost(on)
    Settings.ghost = on
    local char = LocalPlayer.Character
    if not char then
        return
    end
    GhostState.exposedUntil = 0

    if on then
        XJWGhostHide()
        pcall(function()
            if InventoryModule and InventoryModule.canEquipSlot then
                InventoryModule.canEquipSlot(true)
            end
        end)
        pcall(function()
            if CharacterModule and CharacterModule.lockHumanoidState then
                CharacterModule.lockHumanoidState("ghostMode", nil)
            end
        end)
        pcall(function()
            GuiService.TouchControlsEnabled = true
            ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
            ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
        end)
        log("隐身已开启", "success")
    else
        XJWGhostShow()
        log("隐身已关闭", "info")
    end
end

local function buildGhostHud()
    if ghostGui then
        ghostGui:Destroy()
    end
    ghostGui = make("ScreenGui", {
        Name = "XJWGhostHud",
        ResetOnSpawn = false,
        DisplayOrder = 998,
    })
    local ghostParentOk = pcall(function()
        ghostGui.Parent = ghostParent
    end)
    if not ghostParentOk then
        ghostGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    ghostButton = make("TextButton", {
        Size = UDim2.fromOffset(92, 34),
        Position = ghostBtnPos,
        BackgroundColor3 = Color3.fromRGB(14, 9, 26),
        BackgroundTransparency = 0.2,
        Text = Settings.ghost and "隐身  开" or "隐身  关",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Settings.ghost and Theme.accent3 or Theme.red,
        AutoButtonColor = false,
    }, ghostGui)
    corner(ghostButton, 9)
    local s = stroke(ghostButton, Theme.accent, 1.4, 0.3)
    gradient(s, Theme.accent, Theme.accent2, 20)

    ghostButton.Active = not Settings.ghostLock
    ghostButton.Draggable = not Settings.ghostLock
    ghostButton.MouseButton1Click:Connect(function()
        setGhost(not Settings.ghost)
    end)
    ghostButton:GetPropertyChangedSignal("Position"):Connect(function()
        if not Settings.ghostLock then
            ghostBtnPos = ghostButton.Position
        end
    end)
end

local function setGhostHud(on)
    Settings.ghostHud = on
    if on then
        buildGhostHud()
    elseif ghostGui then
        ghostGui:Destroy()
        ghostGui = nil
        ghostButton = nil
    end
end

local function setGhostLock(on)
    Settings.ghostLock = on
    if ghostButton then
        ghostButton.Active = not on
        ghostButton.Draggable = not on
    end
end



local hitboxCache = {}

local function clearHitbox(root)
    local cache = hitboxCache[root]
    if cache then
        pcall(function()
            root.Size = cache.Size
            root.Transparency = cache.Transparency
            root.Material = cache.Material
            root.CanCollide = cache.CanCollide
            root.Color = cache.Color
        end)
        hitboxCache[root] = nil
    end
    pcall(function()
        local outline = root:FindFirstChild("XJWHitboxHighlight")
        if outline then
            outline:Destroy()
        end
        local light = root:FindFirstChild("XJWHitboxLight")
        if light then
            light:Destroy()
        end
    end)
end

local function applyHitbox(char)
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    if not hitboxCache[root] then
        hitboxCache[root] = {
            Size = root.Size,
            Transparency = root.Transparency,
            Material = root.Material,
            CanCollide = root.CanCollide,
            Color = root.Color,
        }
    end
    if not Settings.hitbox then
        clearHitbox(root)
        return
    end
    local size = Settings.hitboxSize
    if Settings.hitboxPulse then
        size = size * (1 + math.sin(tick() * 4) * 0.12)
    end
    root.Size = Vector3.new(size, size, size)
    root.Transparency = Settings.hitboxTransparency
    root.Material = Enum.Material.Neon
    root.CanCollide = false
    root.Color = colorOf(Settings.hitboxColor or "紫色")

    local outline = root:FindFirstChild("XJWHitboxHighlight")
    if Settings.hitboxOutline then
        if not outline then
            outline = make("Highlight", { Name = "XJWHitboxHighlight" }, root)
        end
        outline.FillTransparency = 1
        outline.OutlineColor = root.Color
        outline.OutlineTransparency = Settings.hitboxTransparency
    elseif outline then
        outline:Destroy()
    end

    local light = root:FindFirstChild("XJWHitboxLight")
    if Settings.hitboxGlow then
        if not light then
            light = make("PointLight", { Name = "XJWHitboxLight" }, root)
        end
        light.Brightness = 5
        light.Range = 15
        light.Color = root.Color
    elseif light then
        light:Destroy()
    end
end

local function clearAllHitboxes()
    for root in pairs(hitboxCache) do
        if root and root.Parent then
            clearHitbox(root)
        end
    end
    hitboxCache = {}
end



local rangePart = nil

local function updateRangeSphere()
    if not Settings.rangeEnabled then
        if rangePart then
            pcall(function()
                rangePart:Destroy()
            end)
            rangePart = nil
        end
        return
    end
    local _, _, root = getChar(LocalPlayer)
    if not root then
        return
    end
    if not rangePart or not rangePart.Parent then
        rangePart = Instance.new("Part")
        rangePart.Name = "XJWRangeSphere"
        rangePart.Shape = Enum.PartType.Ball
        rangePart.Anchored = true
        rangePart.CanCollide = false
        rangePart.CanQuery = false
        rangePart.CanTouch = false
        rangePart.CastShadow = false
        rangePart.Parent = Workspace
    end
    local size = Settings.rangeSize * 2
    if Settings.rangePulse then
        size = size * (1 + math.sin(tick() * 3) * 0.03)
    end
    local color = colorOf(Settings.rangeColor)
    rangePart.Size = Vector3.new(size, size, size)
    rangePart.Position = root.Position
    rangePart.Transparency = Settings.rangeTransparency
    rangePart.Color = color
    rangePart.Material = Enum.Material[Settings.rangeMaterial] or Enum.Material.Neon
    rangePart.CanCollide = Settings.rangeCollision

    local outline = rangePart:FindFirstChild("XJWRangeHighlight")
    if Settings.rangeOutline then
        if not outline then
            outline = Instance.new("Highlight")
            outline.Name = "XJWRangeHighlight"
            outline.Parent = rangePart
        end
        outline.FillTransparency = 1
        outline.OutlineColor = color
        outline.OutlineTransparency = Settings.rangeTransparency
    elseif outline then
        outline:Destroy()
    end

    local glow = rangePart:FindFirstChild("XJWRangeLight")
    if Settings.rangeGlow then
        if not glow then
            glow = Instance.new("PointLight")
            glow.Name = "XJWRangeLight"
            glow.Parent = rangePart
        end
        glow.Brightness = 3
        glow.Range = math.max(Settings.rangeSize, 20)
        glow.Color = color
    elseif glow then
        glow:Destroy()
    end
end



local FlyState = {
    active = false,
    mode = nil,
    anchored = false,
    root = nil,
    bodyVelocity = nil,
    bodyGyro = nil,
    attachment = nil,
    velocity = nil,
}

local flyWasOn = false

local function clearFlyVelocity()
    if FlyState.bodyVelocity then
        pcall(function()
            FlyState.bodyVelocity:Destroy()
        end)
        FlyState.bodyVelocity = nil
    end
    if FlyState.bodyGyro then
        pcall(function()
            FlyState.bodyGyro:Destroy()
        end)
        FlyState.bodyGyro = nil
    end
    if FlyState.velocity then
        pcall(function()
            FlyState.velocity:Destroy()
        end)
        FlyState.velocity = nil
    end
    if FlyState.attachment then
        pcall(function()
            FlyState.attachment:Destroy()
        end)
        FlyState.attachment = nil
    end
end

local function startFly(root, humanoid, mode)
    clearFlyVelocity()
    FlyState.active = true
    FlyState.mode = mode
    FlyState.root = root
    FlyState.anchored = false
    pcall(function()
        humanoid.AutoRotate = false
    end)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    if mode == "物理" then
        pcall(function()
            humanoid.PlatformStand = true
        end)
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "XJWFlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = root
        FlyState.bodyVelocity = bodyVelocity

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "XJWFlyGyro"
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 90000
        bodyGyro.Parent = root
        FlyState.bodyGyro = bodyGyro
    else
        pcall(function()
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            root.Anchored = false
        end)
    end
    log("飞行已开启 · " .. tostring(mode), "success")
end

local function stopFly()
    clearFlyVelocity()
    local character, humanoid, root = getChar(LocalPlayer)
    if FlyState.root and FlyState.root.Parent then
        root = FlyState.root
        character = root.Parent
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
    end
    if root then
        if FlyState.anchored then
            pcall(function()
                root.Anchored = false
            end)
        end
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if humanoid then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if FlyState.active then
        log("飞行已关闭", "info")
    end
    FlyState.active = false
    FlyState.anchored = false
    FlyState.mode = nil
    FlyState.root = nil
end

local function moveDirection()
    local cam = Workspace.CurrentCamera
    if not cam then
        return Vector3.zero
    end
    local dir = Vector3.zero
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        dir = dir + look
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        dir = dir - look
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        dir = dir + right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        dir = dir - right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        dir = dir + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        dir = dir - Vector3.new(0, 1, 0)
    end
    local moveVector = nil
    if PlayerControls then
        pcall(function()
            moveVector = PlayerControls:GetMoveVector()
        end)
    end
    if not moveVector or moveVector.Magnitude < 0.05 then
        pcall(function()
            moveVector = UserInputService:GetMoveVector()
        end)
    end
    if moveVector and moveVector.Magnitude > 0.05 then
        dir = dir + cam.CFrame.LookVector * (-moveVector.Z) + cam.CFrame.RightVector * moveVector.X
    end
    if dir.Magnitude > 0 then
        dir = dir.Unit
    end
    return dir
end

local function setNoclip(on)
    Settings.noclip = on
    if not on then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end



local VehicleState = {
    attachment = nil,
    velocity = nil,
    part = nil,
    flyAttachment = nil,
    flyVelocity = nil,
    flyPart = nil,
}

local function clearVehicleForce()
    if VehicleState.velocity then
        pcall(function()
            VehicleState.velocity:Destroy()
        end)
    end
    if VehicleState.attachment then
        pcall(function()
            VehicleState.attachment:Destroy()
        end)
    end
    VehicleState.velocity = nil
    VehicleState.attachment = nil
    VehicleState.part = nil
end

local function getVehicleSeat()
    local _, humanoid = getChar(LocalPlayer)
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
        return humanoid.SeatPart
    end
    if humanoid and humanoid.SeatPart then
        return humanoid.SeatPart
    end
    return nil
end

function XJWSeatChassis(seat)
    if not seat then
        return nil
    end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model then
        local chassis = model:FindFirstChild("_Chassis")
        if chassis and chassis:IsA("BasePart") then
            return chassis
        end
    end
    return seat
end

function XJWClearVehicleFly()
    if VehicleState.flyVelocity then
        pcall(function()
            VehicleState.flyVelocity:Destroy()
        end)
    end
    if VehicleState.flyAttachment then
        pcall(function()
            VehicleState.flyAttachment:Destroy()
        end)
    end
    VehicleState.flyVelocity = nil
    VehicleState.flyAttachment = nil
    VehicleState.flyPart = nil
end

function XJWUpdateVehicleFly(dt)
    if not Settings.vehicleFly then
        XJWClearVehicleFly()
        return
    end
    local seat = getVehicleSeat()
    if not seat then
        XJWClearVehicleFly()
        return
    end
    local chassis = XJWSeatChassis(seat) or seat
    if VehicleState.flyPart ~= chassis or not VehicleState.flyVelocity then
        XJWClearVehicleFly()
        local attachment = make("Attachment", { Name = "XJWVehFlyAttachment" }, chassis)
        local velocity = make("LinearVelocity", {
            Name = "XJWVehFlyVelocity",
            Attachment0 = attachment,
            MaxForce = math.huge,
            VectorVelocity = Vector3.zero,
        }, chassis)
        VehicleState.flyAttachment = attachment
        VehicleState.flyVelocity = velocity
        VehicleState.flyPart = chassis
    end
    if VehicleState.flyVelocity then
        VehicleState.flyVelocity.VectorVelocity = moveDirection() * Settings.vehicleFlySpeed
    end
end



local hasDrawing = type(Drawing) == "table" and Drawing.new ~= nil
local Draw = {
    fov = nil,
    tracer = nil,
    cross = {},
    silentFov = nil,
    silentLine = nil,
}

if hasDrawing then
    pcall(function()
        Draw.fov = Drawing.new("Circle")
        Draw.fov.Filled = false
        Draw.fov.NumSides = 64
        Draw.fov.Thickness = 1.5
        Draw.fov.Visible = false

        Draw.tracer = Drawing.new("Line")
        Draw.tracer.Thickness = 1
        Draw.tracer.Visible = false

        for i = 1, 5 do
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Visible = false
            Draw.cross[i] = line
        end

        Draw.silentFov = Drawing.new("Circle")
        Draw.silentFov.Filled = false
        Draw.silentFov.NumSides = 64
        Draw.silentFov.Thickness = 1
        Draw.silentFov.Visible = false

        Draw.silentLine = Drawing.new("Line")
        Draw.silentLine.Thickness = 1
        Draw.silentLine.Visible = false
    end)
end

local function visibleFromCamera(part)
    local cam = Workspace.CurrentCamera
    if not cam or not part then
        return false
    end
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    table.insert(filter, cam)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function findTarget(opts)
    local cam = Workspace.CurrentCamera
    if not cam then
        return nil
    end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best = nil
    local bestScore = math.huge
    local _, _, myRoot = getChar(LocalPlayer)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and passesFilter(player, opts.police, opts.civilian) then
            local skip = false
            if opts.team and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                skip = true
            end
            if not skip and opts.friend and isFriend(player) then
                skip = true
            end
            if not skip and opts.combat and not inCombat(player) then
                skip = true
            end

            if not skip then
                local char = player.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local part = char and (char:FindFirstChild(opts.partName) or char:FindFirstChild("HumanoidRootPart"))
                if part and humanoid and humanoid.Health > 0 then
                    local visible = true
                    if opts.wall then
                        visible = visibleFromCamera(part)
                    end
                    if visible then
                        local screen, onScreen = screenPosition(part.Position)
                        if onScreen then
                            local score = (screen - center).Magnitude
                            if score <= opts.fov then
                                if opts.mode == "距离最近" and myRoot then
                                    score = (myRoot.Position - part.Position).Magnitude
                                elseif opts.mode == "血量最低" then
                                    score = humanoid.Health
                                end
                                if score < bestScore then
                                    bestScore = score
                                    best = {
                                        player = player,
                                        part = part,
                                        humanoid = humanoid,
                                        screen = screen,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local lastAimTarget = nil
local aimAccent = Theme.accent

local function updateAimDrawings(dt)
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    aimAccent = colorOf(Settings.aimColor)

    local holding
    if UserInputService.TouchEnabled then
        holding = true
    else
        holding = not Settings.aimHold or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
    local active = Settings.aim and holding

    if Draw.fov then
        Draw.fov.Position = center
        Draw.fov.Radius = Settings.aimFov
        Draw.fov.Thickness = Settings.aimFovThickness
        Draw.fov.Color = aimAccent
        Draw.fov.Transparency = 0.85
        Draw.fov.Visible = Settings.aimShowFov and (Settings.aim and holding)
    end

    if Draw.cross[1] then
        local gap = 5
        local len = 13
        local lines = {
            { Vector2.new(center.X, center.Y - gap), Vector2.new(center.X, center.Y - gap - len) },
            { Vector2.new(center.X, center.Y + gap), Vector2.new(center.X, center.Y + gap + len) },
            { Vector2.new(center.X - gap, center.Y), Vector2.new(center.X - gap - len, center.Y) },
            { Vector2.new(center.X + gap, center.Y), Vector2.new(center.X + gap + len, center.Y) },
            { Vector2.new(center.X - 2, center.Y), Vector2.new(center.X + 2, center.Y) },
        }
        for i, line in ipairs(Draw.cross) do
            line.From = lines[i][1]
            line.To = lines[i][2]
            line.Color = aimAccent
            line.Transparency = 0.7
            line.Visible = Settings.aimCrosshair and Settings.aim
        end
    end

    lastAimTarget = nil
    if active then
        local target = findTarget({
            partName = AimParts[Settings.aimPart] or "Head",
            fov = Settings.aimFov,
            team = Settings.aimTeam,
            friend = Settings.aimFriend,
            wall = Settings.aimWall,
            combat = Settings.aimCombat,
            police = Settings.aimPolice,
            civilian = Settings.aimCivilian,
            mode = Settings.aimMode,
        })
        local smoothValue = math.clamp(1 - Settings.aimSmooth / 110, 0.05, 1)
        if target then
            lastAimTarget = target
            local aimPosition = target.part.Position
            if Settings.aimPredict then
                aimPosition = aimPosition + target.part.AssemblyLinearVelocity * 0.12
            end
            local goal = CFrame.new(cam.CFrame.Position, aimPosition)
            cam.CFrame = cam.CFrame:Lerp(goal, smoothValue)
        elseif Settings.aimVehicles then
            local vehicle = XJWFindVehicleTarget(Settings.aimFov)
            if vehicle then
                local goal = CFrame.new(cam.CFrame.Position, vehicle.part.Position)
                cam.CFrame = cam.CFrame:Lerp(goal, smoothValue)
                lastAimTarget = { screen = vehicle.screen }
            end
        end
    end

    if Draw.tracer then
        if Settings.aim and Settings.aimTracer and lastAimTarget then
            Draw.tracer.From = center
            Draw.tracer.To = lastAimTarget.screen
            Draw.tracer.Color = aimAccent
            Draw.tracer.Transparency = 0.55
            Draw.tracer.Visible = true
        else
            Draw.tracer.Visible = false
        end
    end
end

local function updateSilent(dt)
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    silentTargetRef = nil

    if Settings.silent then
        local target = findTarget({
            partName = AimParts[Settings.silentPart] or "Head",
            fov = Settings.silentFov,
            team = Settings.silentTeam,
            friend = Settings.silentFriend,
            wall = false,
            combat = Settings.silentCombat,
            police = Settings.silentPolice,
            civilian = Settings.silentCivilian,
            mode = "准心最近",
        })
        if target and target.part then
            local dist = (target.part.Position - cam.CFrame.Position).Magnitude
            if dist <= Settings.silentDistance then
                silentTargetRef = target.part.Position
            end
        end
    end

    if Draw.silentFov then
        Draw.silentFov.Position = center
        Draw.silentFov.Radius = Settings.silentFov
        Draw.silentFov.Color = aimAccent
        Draw.silentFov.Transparency = 0.5
        Draw.silentFov.Visible = Settings.silent and Settings.silentShowFov
    end

    if Draw.silentLine then
        if Settings.silent and silentTargetRef then
            local screen, onScreen = screenPosition(silentTargetRef)
            Draw.silentLine.From = center
            Draw.silentLine.To = screen
            Draw.silentLine.Color = aimAccent
            Draw.silentLine.Transparency = 0.6
            Draw.silentLine.Visible = onScreen
        else
            Draw.silentLine.Visible = false
        end
    end
end



local EspFolder = make("ScreenGui", {
    Name = "XJWESP",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 997,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local espParentOk = pcall(function()
    EspFolder.Parent = guiParent
end)
if not espParentOk then
    EspFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local EspTrackers = {}
local espAccumulator = 0

local function espAllowed(player)
    if not Settings.esp or player == LocalPlayer then
        return false
    end
    if not isAlive(player) then
        return false
    end
    if Settings.espFugitive and isFugitive(player) then
        return true
    end
    local selected = Settings.espTeams
    local count, total = 0, 0
    for _, value in pairs(selected) do
        total = total + 1
        if value then
            count = count + 1
        end
    end
    if count == 0 or count >= total then
        return true
    end
    return selected[teamOf(player)] == true
end

local function destroyTracker(player)
    local t = EspTrackers[player]
    if not t then
        return
    end
    pcall(function()
        if t.billboard then
            t.billboard:Destroy()
        end
        if t.highlight then
            t.highlight:Destroy()
        end
        for _, line in ipairs(t.lines) do
            line:Remove()
        end
        if t.healthBg then
            t.healthBg:Remove()
        end
        if t.healthFill then
            t.healthFill:Remove()
        end
        if t.tracer then
            t.tracer:Remove()
        end
    end)
    EspTrackers[player] = nil
end

local function createTracker(player)
    local char = player.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local billboard = make("BillboardGui", {
        Name = "XJWESP_" .. player.Name,
        AlwaysOnTop = true,
        Size = UDim2.new(9, 0, 2.8, 0),
        StudsOffset = Vector3.new(0, 3.3, 0),
        MaxDistance = 10000,
        Adornee = root,
    }, EspFolder)

    local nameLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextStrokeTransparency = 0.25,
        TextColor3 = Theme.accent3,
        Text = player.Name,
    }, billboard)

    local infoLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0.45, 0),
        Position = UDim2.new(0, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextStrokeTransparency = 0.3,
        TextColor3 = Theme.text,
        Text = "",
    }, billboard)

    local highlight = make("Highlight", {
        Name = "XJWESP_Highlight",
        Adornee = char,
        FillTransparency = 0.85,
        OutlineTransparency = 0.15,
    }, char)
    pcall(function()
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end)

    local lines = {}
    local healthBg = nil
    local healthFill = nil
    if hasDrawing then
        for i = 1, 8 do
            local line = Drawing.new("Line")
            line.Thickness = 1.2
            line.Transparency = 0.2
            line.Visible = false
            lines[i] = line
        end
        healthBg = Drawing.new("Line")
        healthBg.Thickness = 3
        healthBg.Transparency = 0.45
        healthBg.Visible = false
        healthFill = Drawing.new("Line")
        healthFill.Thickness = 3
        healthFill.Transparency = 0.1
        healthFill.Visible = false
    end

    local tracer = nil
    if hasDrawing then
        tracer = Drawing.new("Line")
        tracer.Thickness = 1
        tracer.Transparency = 0.55
        tracer.Visible = false
    end

    EspTrackers[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        infoLabel = infoLabel,
        highlight = highlight,
        lines = lines,
        healthBg = healthBg,
        healthFill = healthFill,
        tracer = tracer,
    }
end

local function updateTracker(player)
    local t = EspTrackers[player]
    if not t then
        return
    end
    local char, humanoid, root = getChar(player)
    if char and (t.billboard.Adornee ~= root or t.highlight.Parent ~= char) then
        destroyTracker(player)
        pcall(createTracker, player)
        return
    end
    if not char or not root or not espAllowed(player) then
        t.billboard.Enabled = false
        t.highlight.Enabled = false
        for _, line in ipairs(t.lines) do
            line.Visible = false
        end
        if t.healthBg then
            t.healthBg.Visible = false
        end
        if t.healthFill then
            t.healthFill.Visible = false
        end
        if t.tracer then
            t.tracer.Visible = false
        end
        return
    end

    local team = teamOf(player)
    local fugitive = isFugitive(player)
    local color = fugitive and Color3.fromRGB(255, 70, 70) or TeamColors[team] or Theme.accent

    t.billboard.Adornee = root
    t.billboard.Enabled = Settings.espName or Settings.espDistance or Settings.espHealth
    t.nameLabel.Visible = Settings.espName
    t.nameLabel.Text = player.Name
    t.nameLabel.TextColor3 = color

    local _, _, myRoot = getChar(LocalPlayer)
    local info = { fugitive and "逃犯" or TeamNames[team] or team }
    if Settings.espDistance and myRoot then
        table.insert(info, string.format("%.0fm", (myRoot.Position - root.Position).Magnitude))
    end
    if Settings.espHealth and humanoid then
        table.insert(info, math.floor(humanoid.Health) .. "HP")
    end
    t.infoLabel.Text = table.concat(info, "  ·  ")
    t.infoLabel.TextColor3 = Color3.fromRGB(232, 222, 248)
    t.infoLabel.Visible = #info > 1

    t.highlight.Adornee = char
    t.highlight.Enabled = Settings.espHighlight
    t.highlight.FillColor = color
    t.highlight.OutlineColor = color

    local cam = Workspace.CurrentCamera
    if cam and hasDrawing then
        local head = char:FindFirstChild("Head") or root
        local topScreen, topOn = screenPosition(head.Position + Vector3.new(0, 0.55, 0))
        local bottomScreen, bottomOn = screenPosition(root.Position - Vector3.new(0, 2.7, 0))
        if topOn and bottomOn and Settings.espBox then
            local height = math.abs(bottomScreen.Y - topScreen.Y)
            local width = height * 0.58
            local x = topScreen.X - width / 2
            local y = topScreen.Y
            local length = math.clamp(math.min(width, height) * 0.22, 6, 18)
            local segments = {
                { Vector2.new(x, y), Vector2.new(x + length, y) },
                { Vector2.new(x, y), Vector2.new(x, y + length) },
                { Vector2.new(x + width, y), Vector2.new(x + width - length, y) },
                { Vector2.new(x + width, y), Vector2.new(x + width, y + length) },
                { Vector2.new(x, y + height), Vector2.new(x + length, y + height) },
                { Vector2.new(x, y + height), Vector2.new(x, y + height - length) },
                { Vector2.new(x + width, y + height), Vector2.new(x + width - length, y + height) },
                { Vector2.new(x + width, y + height), Vector2.new(x + width, y + height - length) },
            }
            for i, line in ipairs(t.lines) do
                line.From = segments[i][1]
                line.To = segments[i][2]
                line.Color = color
                line.Thickness = 1.2
                line.Transparency = 0.15
                line.Visible = true
            end

            local hp = humanoid and math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1) or 1
            if t.healthBg and t.healthFill then
                if Settings.espHealth and humanoid then
                    local barX = x - 7
                    t.healthBg.From = Vector2.new(barX, y)
                    t.healthBg.To = Vector2.new(barX, y + height)
                    t.healthBg.Color = Color3.fromRGB(10, 6, 18)
                    t.healthBg.Visible = true
                    t.healthFill.From = Vector2.new(barX, y + height)
                    t.healthFill.To = Vector2.new(barX, y + height - height * hp)
                    local healthColor = Color3.fromRGB(74, 222, 128)
                    if hp <= 0.55 then
                        healthColor = Color3.fromRGB(251, 191, 36)
                    end
                    if hp <= 0.28 then
                        healthColor = Color3.fromRGB(248, 113, 113)
                    end
                    t.healthFill.Color = healthColor
                    t.healthFill.Visible = true
                else
                    t.healthBg.Visible = false
                    t.healthFill.Visible = false
                end
            end
        else
            for _, line in ipairs(t.lines) do
                line.Visible = false
            end
            if t.healthBg then
                t.healthBg.Visible = false
            end
            if t.healthFill then
                t.healthFill.Visible = false
            end
        end

        if t.tracer then
            if Settings.espTracer and topOn then
                local size = cam.ViewportSize
                local from = Vector2.new(size.X / 2, size.Y)
                if Settings.espTracerOrigin == "屏幕中心" then
                    from = Vector2.new(size.X / 2, size.Y / 2)
                elseif Settings.espTracerOrigin == "屏幕顶部" then
                    from = Vector2.new(size.X / 2, 0)
                end
                t.tracer.From = from
                t.tracer.To = topScreen
                t.tracer.Color = color
                t.tracer.Visible = true
            else
                t.tracer.Visible = false
            end
        end
    end
end

local function refreshEsp()
    for player in pairs(EspTrackers) do
        if not player.Parent or not espAllowed(player) then
            destroyTracker(player)
        end
    end
    if Settings.esp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and espAllowed(player) then
                if not EspTrackers[player] then
                    pcall(createTracker, player)
                end
            end
        end
    end
end

connect(Players.PlayerRemoving, function(player)
    destroyTracker(player)
end)

connect(Players.PlayerAdded, function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.4)
        if Settings.esp then
            destroyTracker(player)
            if espAllowed(player) then
                pcall(createTracker, player)
            end
        end
    end)
end)




XJWVehicle = { trackers = {}, lastRefresh = 0 }

function XJWVehicleFolder()
    local gameplay = Workspace:FindFirstChild("Gameplay")
    if gameplay then
        local folder = gameplay:FindFirstChild("Vehicles")
        if folder then
            return folder
        end
        local entities = gameplay:FindFirstChild("Entities")
        folder = entities and entities:FindFirstChild("Vehicles")
        if folder then
            return folder
        end
    end
    return Workspace:FindFirstChild("Vehicles")
end

function XJWVehicleList()
    local list = {}
    local folder = XJWVehicleFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then
                table.insert(list, child)
            end
        end
        return list
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("_Chassis") then
            table.insert(list, child)
        end
    end
    return list
end

function XJWVehiclePart(model)
    if not model then
        return nil
    end
    local chassis = model:FindFirstChild("_Chassis")
    if chassis and chassis:IsA("BasePart") then
        return chassis
    end
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

function XJWDestroyVehicleTracker(model)
    local tracker = XJWVehicle.trackers[model]
    if not tracker then
        return
    end
    pcall(function()
        if tracker.billboard then
            tracker.billboard:Destroy()
        end
        if tracker.highlight then
            tracker.highlight:Destroy()
        end
    end)
    XJWVehicle.trackers[model] = nil
end

function XJWRefreshVehicleEsp()
    if not Settings.vehicleEsp then
        for model in pairs(XJWVehicle.trackers) do
            XJWDestroyVehicleTracker(model)
        end
        return
    end
    local now = tick()
    if now - (XJWVehicle.lastRefresh or 0) < 0.3 then
        return
    end
    XJWVehicle.lastRefresh = now

    local seen = {}
    local _, _, myRoot = getChar(LocalPlayer)
    for _, model in ipairs(XJWVehicleList()) do
        local part = XJWVehiclePart(model)
        if part and part.Parent then
            seen[model] = true
            local tracker = XJWVehicle.trackers[model]
            if not tracker then
                local billboard = make("BillboardGui", {
                    Name = "XJWVehESP_" .. model.Name,
                    AlwaysOnTop = true,
                    Size = UDim2.new(9, 0, 2.2, 0),
                    StudsOffset = Vector3.new(0, 4.2, 0),
                    MaxDistance = 8000,
                    Adornee = part,
                }, EspFolder)
                local nameLabel = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0.6, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextStrokeTransparency = 0,
                    TextColor3 = Theme.accent3,
                    Text = model.Name,
                }, billboard)
                local infoLabel = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0.4, 0),
                    Position = UDim2.new(0, 0, 0.6, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextStrokeTransparency = 0,
                    TextColor3 = Theme.text,
                    Text = "",
                }, billboard)
                local highlight = make("Highlight", {
                    Name = "XJWVehESP_Highlight",
                    Adornee = model,
                    FillColor = Theme.accent,
                    OutlineColor = Theme.accent3,
                    FillTransparency = 0.82,
                    OutlineTransparency = 0.1,
                }, model)
                pcall(function()
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end)
                tracker = {
                    billboard = billboard,
                    nameLabel = nameLabel,
                    infoLabel = infoLabel,
                    highlight = highlight,
                }
                XJWVehicle.trackers[model] = tracker
            end

            local info = {}
            if Settings.vehicleEspDistance and myRoot then
                table.insert(info, string.format("%.0f m", (myRoot.Position - part.Position).Magnitude))
            end
            tracker.billboard.Adornee = part
            tracker.billboard.Enabled = Settings.vehicleEspName or Settings.vehicleEspDistance
            tracker.nameLabel.Visible = Settings.vehicleEspName
            tracker.nameLabel.Text = model.Name
            tracker.infoLabel.Text = table.concat(info, "  ·  ")
            tracker.infoLabel.Visible = Settings.vehicleEspDistance and #info > 0
            tracker.highlight.Adornee = model
            tracker.highlight.Enabled = Settings.vehicleEspHighlight
        end
    end

    for model in pairs(XJWVehicle.trackers) do
        if not seen[model] or not model.Parent then
            XJWDestroyVehicleTracker(model)
        end
    end
end

function XJWFindVehicleTarget(fov)
    local camera = Workspace.CurrentCamera
    if not camera then
        return nil
    end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best = nil
    local bestScore = math.huge
    for _, model in ipairs(XJWVehicleList()) do
        local part = XJWVehiclePart(model)
        if part and part.Parent then
            local screen, onScreen = screenPosition(part.Position)
            if onScreen then
                local score = (screen - center).Magnitude
                if score <= fov and score < bestScore then
                    bestScore = score
                    best = { part = part, screen = screen, model = model }
                end
            end
        end
    end
    return best
end

function XJWNearestVehicle(origin, skipModel)
    if not origin then
        return nil
    end
    local bestModel = nil
    local bestPart = nil
    local bestDistance = math.huge
    for _, model in ipairs(XJWVehicleList()) do
        if model ~= skipModel then
            local part = XJWVehiclePart(model)
            if part and part.Parent then
                local distance = (part.Position - origin).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestModel = model
                    bestPart = part
                end
            end
        end
    end
    return bestModel, bestPart, bestDistance
end

function XJWCurrentVehicleModel()
    local _, humanoid = getChar(LocalPlayer)
    local seat = humanoid and humanoid.SeatPart
    if seat then
        local model = seat:FindFirstAncestorOfClass("Model")
        if model then
            return model
        end
    end
    return nil
end

function XJWOwnVehicle()
    local attribute = LocalPlayer:GetAttribute("BelongingVehicle")
    if typeof(attribute) == "Instance" and attribute.Parent then
        if attribute:IsA("Model") then
            return attribute
        end
        local ancestor = attribute:FindFirstAncestorOfClass("Model")
        if ancestor then
            return ancestor
        end
    end
    local function belongsToMe(model)
        local config = model and model:FindFirstChild("Config")
        local belongsTo = config and config:FindFirstChild("BelongsTo")
        if belongsTo then
            local ok, value = pcall(function()
                return belongsTo.Value
            end)
            if ok and value == LocalPlayer.UserId then
                return true
            end
        end
        return false
    end
    for _, model in ipairs(XJWVehicleList()) do
        if belongsToMe(model) then
            return model
        end
    end
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and belongsToMe(descendant) then
            return descendant
        end
    end
    return XJWCurrentVehicleModel()
end

function XJWMoveVehicle(model, targetPosition)
    if not model or not targetPosition then
        return false
    end
    local chassis = XJWVehiclePart(model)
    local pivot = model:GetPivot()
    local rotation = pivot - pivot.Position
    local target = CFrame.new(targetPosition) * rotation
    local ok = pcall(function()
        model:PivotTo(target)
    end)
    if not ok and chassis then
        pcall(function()
            chassis.CFrame = target
        end)
    end
    if chassis then
        pcall(function()
            chassis.AssemblyLinearVelocity = Vector3.zero
            chassis.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    return true
end

function XJWBringVehicleToMe(forceNearest)
    local _, humanoid, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end
    local currentModel = XJWCurrentVehicleModel()
    local ownModel = (not forceNearest) and XJWOwnVehicle() or nil
    if ownModel and humanoid and humanoid.SeatPart and currentModel == ownModel then
        Notify("带来载具", "你正在驾驶这辆载具", "warn")
        return
    end
    local model
    local isOwn = false
    if forceNearest then
        model = XJWNearestVehicle(myRoot.Position, currentModel)
    else
        model = ownModel
        isOwn = model ~= nil
        if not model then
            Notify("带来载具", "没有找到属于你的载具", "warn")
            return
        end
    end
    if not model then
        Notify("带来载具", "附近没有找到载具", "warn")
        return
    end
    local distance = isOwn and 4 or math.clamp(Settings.bringDistance or 12, 5, 40)
    local target = myRoot.Position + myRoot.CFrame.LookVector * distance + Vector3.new(0, isOwn and 2.5 or 3, 0)
    if XJWMoveVehicle(model, target) then
        if isOwn then
            Notify("带来载具", "已无视距离把你的 " .. model.Name .. " 传送到脸上", "success")
        else
            Notify("带来载具", "已把 " .. model.Name .. " 带到你面前", "success")
        end
    else
        Notify("带来载具", "载具移动失败", "error")
    end
end

function XJWBringVehicleToPlayer(player, origin, forceNearest)
    if not player then
        return false
    end
    local targetRoot = getRoot(player)
    if not targetRoot then
        Notify("带来载具", "目标玩家不在场景中", "warn")
        return false
    end
    local currentModel = XJWCurrentVehicleModel()
    local source = origin or targetRoot.Position
    local model
    if forceNearest then
        model = XJWNearestVehicle(source, currentModel)
        if not model and source ~= targetRoot.Position then
            model = XJWNearestVehicle(targetRoot.Position, currentModel)
        end
    else
        model = XJWOwnVehicle()
        if model and model == currentModel then
            Notify("带来载具", "你正在驾驶这辆载具", "warn")
            return false
        end
        if not model then
            Notify("带来载具", "没有找到属于你的载具", "warn")
            return false
        end
    end
    if not model then
        Notify("带来载具", "附近没有找到载具", "warn")
        return false
    end
    local target = targetRoot.Position + targetRoot.CFrame.LookVector * 3 + Vector3.new(0, 4, 0)
    if XJWMoveVehicle(model, target) then
        Notify("带来载具", "已把 " .. model.Name .. " 带到 " .. player.Name .. " 附近", "success")
        return true
    end
    Notify("带来载具", "载具移动失败", "error")
    return false
end

function XJWBringVehicleToNearestPlayer(forceNearest)
    local _, _, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end
    local bestPlayer = nil
    local bestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local root = getRoot(player)
            if root then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestPlayer = player
                end
            end
        end
    end
    if not bestPlayer then
        Notify("带来载具", "附近没有其他玩家", "warn")
        return
    end
    XJWBringVehicleToPlayer(bestPlayer, myRoot.Position, forceNearest)
end

function XJWBringVehicleToName(name, forceNearest)
    name = tostring(name or ""):lower()
    if name == "" then
        Notify("带来载具", "请输入玩家名字", "warn")
        return
    end
    local _, _, myRoot = getChar(LocalPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and string.lower(player.Name):find(name, 1, true) then
            XJWBringVehicleToPlayer(player, myRoot and myRoot.Position, forceNearest)
            return
        end
    end
    Notify("带来载具", "未找到该玩家", "error")
end



local function sendDamage(player, partName, factor)
    if not PlayerEvent then
        return false
    end
    local _, _, myRoot = getChar(LocalPlayer)
    local char = player.Character
    local part = char and char:FindFirstChild(partName or "Head")
    if not part then
        part = char and char:FindFirstChild("HumanoidRootPart")
    end
    if not myRoot or not part then
        return false
    end
    pcall(function()
        PlayerEvent:FireServer("damage", {
            bodyParts = { { partName or "Head", 1 } },
            shotCode = { myRoot.Position, (part.Position - myRoot.Position).Unit },
            pos = part.Position,
            target = player,
            damageFactor = factor or 1,
            bulletProofTool = false,
        })
    end)
    return true
end

local function drawBeam(from, to)
    pcall(function()
        local a = Instance.new("Part")
        local b = Instance.new("Part")
        for _, part in ipairs({ a, b }) do
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.Transparency = 1
            part.Size = Vector3.new(0.1, 0.1, 0.1)
            part.Parent = Workspace
        end
        a.Position = from
        b.Position = to
        local att1 = Instance.new("Attachment", a)
        local att2 = Instance.new("Attachment", b)
        local beam = Instance.new("Beam", a)
        beam.Attachment0 = att1
        beam.Attachment1 = att2
        beam.Width0 = 0.14
        beam.Width1 = 0.14
        beam.Color = ColorSequence.new(Theme.accent3, Theme.accent)
        task.delay(0.7, function()
            pcall(function()
                a:Destroy()
                b:Destroy()
            end)
        end)
    end)
end

local lastAura = 0
local function runAura()
    if not Settings.aura or not PlayerEvent then
        return
    end
    local now = tick()
    if now - lastAura < Settings.auraInterval then
        return
    end
    local _, _, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end
    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if passesFilter(player, Settings.auraPolice, Settings.auraCivilian) and isAlive(player) then
            local skip = false
            if Settings.auraCombat and not inCombat(player) then
                skip = true
            end
            if not skip then
                local root = getRoot(player)
                if root then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist <= Settings.auraRange and dist < bestDist then
                        best = player
                        bestDist = dist
                    end
                end
            end
        end
    end
    if best then
        local char = best.Character
        local part = getRagePart(char, "Head")
        if part then
            sendDamage(best, "Head", Settings.auraDamage)
        end
        lastAura = now
    end
end

local lastRage = 0
local function runRagebot()
    if not Settings.ragebot or not PlayerEvent then
        return
    end
    local now = tick()
    if now - lastRage < Settings.rageInterval then
        return
    end
    local _, _, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end

    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if passesFilter(player, Settings.ragePolice, Settings.rageCivilian) and isAlive(player) then
            local skip = false
            if Settings.rageCombat and not inCombat(player) then
                skip = true
            end
            if not skip and Settings.rageJob then
                local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name
                if teamOf(player) == myTeam then
                    skip = true
                end
            end
            if not skip then
                local char = player.Character
                local part = char and char:FindFirstChild(Settings.ragePart)
                if part then
                    if Settings.rageWall and not visibleFromCamera(part) then
                        skip = true
                    end
                    if not skip then
                        local dist = (part.Position - myRoot.Position).Magnitude
                        if dist <= Settings.rageRange and dist < bestDist then
                            best = player
                            bestDist = dist
                        end
                    end
                end
            end
        end
    end

    if best then
        local partName = Settings.ragePart
        local char = best.Character
        local part = char and char:FindFirstChild(partName)
        if part then
            sendDamage(best, partName, 1.5)
            if Settings.rageBeam then
                drawBeam(myRoot.Position, part.Position)
            end
            lastRage = now
        end
    end
end



task.spawn(function()
    while true do
        if Settings.policeCuff or Settings.policeTp then
            local _, humanoid, myRoot = getChar(LocalPlayer)
            if myRoot and humanoid and humanoid.Health > 0 then
                if Settings.policeCuff and PlayerFunc then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and isAlive(player) then
                            local skip = false
                            if Settings.policeCombat and not inCombat(player) then
                                skip = true
                            end
                            if not skip then
                                local root = getRoot(player)
                                if root and (root.Position - myRoot.Position).Magnitude <= Settings.policeRange then
                                    pcall(function()
                                        PlayerFunc:InvokeServer("handcuff", player, false)
                                    end)
                                end
                            end
                        end
                    end
                end

                if Settings.policeTp then
                    local best, bestDist = nil, math.huge
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and isAlive(player) and teamOf(player) == "Civilian" and wantedOf(player) > 0 then
                            local root = getRoot(player)
                            if root then
                                local dist = (root.Position - myRoot.Position).Magnitude
                                if dist <= Settings.policeRange and dist < bestDist then
                                    best = player
                                    bestDist = dist
                                end
                            end
                        end
                    end
                    if best then
                        local root = getRoot(best)
                        if root then
                            teleportTo(root.Position - root.CFrame.LookVector * 3)
                        end
                    end
                end
            end
        end
        task.wait(Settings.policeInterval)
    end
end)



local function matchesMoneyPrompt(prompt)
    local name = string.lower(prompt.Name or "")
    local action = string.lower(prompt.ActionText or "")
    local object = string.lower(prompt.ObjectText or "")
    return name == "cashdrop"
        or name == "getitem"
        or name == "money"
        or action:find("pick", 1, true) ~= nil
        or action:find("cash", 1, true) ~= nil
        or action:find("collect", 1, true) ~= nil
        or action:find("grab", 1, true) ~= nil
        or object:find("cash", 1, true) ~= nil
        or object:find("money", 1, true) ~= nil
end

task.spawn(function()
    while true do
        if Settings.autoMoney then
            local _, _, myRoot = getChar(LocalPlayer)
            if myRoot and myRoot.Parent then
                local bestPrompt, bestDist = nil, nil
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") and matchesMoneyPrompt(descendant) then
                        local pos = objectPosition(descendant)
                        if pos then
                            local dist = (myRoot.Position - pos).Magnitude
                            if dist < 180 and (not bestDist or dist < bestDist) then
                                bestDist = dist
                                bestPrompt = descendant
                            end
                        end
                    end
                end
                if bestPrompt and bestDist then
                    if bestDist > 8 then
                        teleportTo(objectPosition(bestPrompt))
                        task.wait(0.25)
                    end
                    firePrompt(bestPrompt)
                end
            end
        end
        task.wait(0.35)
    end
end)

local function getTeamJobs()
    if not getgc then
        return nil
    end
    for _, value in pairs(getgc(true)) do
        if type(value) == "table" and rawget(value, "teamJobs") then
            return value.teamJobs
        end
    end
    return nil
end

local function hasMission()
    if LocalPlayer:GetAttribute("Mission") then
        return true
    end
    local jobs = getTeamJobs()
    if jobs then
        for _, job in pairs(jobs) do
            if job.joined then
                return true
            end
        end
    end
    return false
end

local function pickMission()
    local jobs = getTeamJobs()
    if not jobs then
        return nil
    end
    local bestKey, bestValue = nil, -math.huge
    for key, job in pairs(jobs) do
        if not job.joined then
            if not Settings.missionPriority then
                return key
            end
            local score = (job.profitability or 1) * 1000000 + (job.reward or 0)
            if score > bestValue then
                bestValue = score
                bestKey = key
            end
        end
    end
    return bestKey
end

task.spawn(function()
    while true do
        if Settings.autoMission and PlayerFunc and not hasMission() then
            local key = pickMission()
            if key then
                pcall(function()
                    PlayerFunc:InvokeServer("talkToMission", tostring(key) .. "join")
                end)
            end
        end
        task.wait(math.max(Settings.missionInterval, 0.5))
    end
end)

task.spawn(function()
    while true do
        if Settings.farmer then
            local _, _, myRoot = getChar(LocalPlayer)
            if myRoot then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    task.wait(0.4)
                end
                local bestPrompt, bestDist = nil, nil
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") and descendant.ActionText == "Pick Up" then
                        local pos = objectPosition(descendant)
                        if pos then
                            local dist = (myRoot.Position - pos).Magnitude
                            if not bestDist or dist < bestDist then
                                bestDist = dist
                                bestPrompt = descendant
                            end
                        end
                    end
                end
                if bestPrompt and bestDist then
                    if bestDist > 8 then
                        teleportTo(objectPosition(bestPrompt))
                        task.wait(0.3)
                    else
                        firePrompt(bestPrompt)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

local taxiOrigin = nil
local lastTaxiPos = nil
task.spawn(function()
    while true do
        if Settings.taxi then
            local gameplay = Workspace:FindFirstChild("Gameplay")
            local entities = gameplay and gameplay:FindFirstChild("Entities")
            local content = entities and entities:FindFirstChild("ClientContent")
            local _, _, myRoot = getChar(LocalPlayer)
            if content and content:IsA("Model") then
                local primary = content.PrimaryPart or content:FindFirstChildWhichIsA("BasePart")
                if primary and myRoot then
                    local position = primary.Position
                    if lastTaxiPos == nil or (position - lastTaxiPos).Magnitude > 5 then
                        if Settings.taxiSafe and taxiOrigin then
                            teleportTo(taxiOrigin)
                            local dist = (taxiOrigin - position).Magnitude
                            local waitTime
                            if Settings.taxiMode == "距离测算" then
                                waitTime = math.clamp(15 + (math.clamp(dist, 2000, 6000) - 2000) / 4000 * 30 + math.random() * 2 - 1, 15, 45)
                            else
                                waitTime = dist > 2000 and math.random(15, 45) or 15
                            end
                            task.wait(waitTime)
                        end
                        teleportTo(position)
                        lastTaxiPos = position
                    end
                end
            end
        else
            lastTaxiPos = nil
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Settings.bus then
            local gameplay = Workspace:FindFirstChild("Gameplay")
            local entities = gameplay and gameplay:FindFirstChild("Entities")
            local content = entities and entities:FindFirstChild("ClientContent")
            local area = content and content:GetChildren()[1] and content:GetChildren()[1]:FindFirstChild("Area")
            local _, humanoid, myRoot = getChar(LocalPlayer)
            if area and humanoid and myRoot then
                local seatPart = humanoid.SeatPart
                if seatPart then
                    local relative = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, math.pi * 1.5, 0)
                    seatPart.CFrame = relative
                    seatPart.AssemblyLinearVelocity = Vector3.zero
                    seatPart.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.1)
                    humanoid.Sit = false
                else
                    myRoot.CFrame = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, math.pi * 1.5, 0)
                end
                task.wait(5)
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if Settings.golf and PlayerFunc then
            pcall(function()
                PlayerFunc:InvokeServer("miniGolf", "createLobby")
                task.wait(0.1)
                PlayerFunc:InvokeServer("miniGolf", "setLobbyBid", { bid = 500 })
                task.wait(0.1)
                PlayerFunc:InvokeServer("miniGolf", "setLobbyReady")
                task.wait(4)
                PlayerFunc:InvokeServer("miniGolf", "shot")
                task.wait(0.5)
                local content = Workspace:FindFirstChild("Gameplay")
                content = content and content:FindFirstChild("Entities")
                content = content and content:FindFirstChild("Content")
                local ball = content and content:FindFirstChild(LocalPlayer.Name)
                local flag = content and content:FindFirstChild("_Flag")
                flag = flag and flag:FindFirstChild("FlagPole")
                local flagPart = flag and flag:FindFirstChild("Part")
                if ball and flagPart and ball:IsA("BasePart") then
                    ball.Position = flagPart.Position
                end
            end)
        end
        task.wait(Settings.golf and 5 or 1)
    end
end)

local autoHackCache = {}



local AtmState = { signature = nil, busy = false, time = 0 }

function XJWAutoAtmStep()
    if not Settings.autoAtm then
        AtmState.signature = nil
        return
    end

    local function findAtm()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return nil
        end
        for _, child in ipairs(playerGui:GetChildren()) do
            local ok, atm = pcall(function()
                return child.Center.Middle.HackingMinigames["ATM Hack"]
            end)
            if ok and atm then
                return atm
            end
        end
        return playerGui:FindFirstChild("ATM Hack", true)
    end

    local function guiVisible(gui)
        local node = gui
        while node do
            if node:IsA("LayerCollector") and not node.Enabled then
                return false
            end
            if node:IsA("GuiObject") and not node.Visible then
                return false
            end
            node = node.Parent
        end
        return true
    end

    local function clickButton(button)
        local position = button.AbsolutePosition
        local size = button.AbsoluteSize
        local x = position.X + size.X / 2
        local y = position.Y + size.Y / 2
        local virtualInput = game:GetService("VirtualInputManager")
        if UserInputService.TouchEnabled then
            pcall(function()
                virtualInput:SendTouchEvent(1, 0, x, y)
                virtualInput:SendTouchEvent(1, 2, x, y)
            end)
        end
        pcall(function()
            virtualInput:SendMouseButtonEvent(x, y, 0, true, game, 0)
            virtualInput:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
    end

    local atm = findAtm()
    if not atm or not (atm:IsA("GuiObject") or atm:IsA("LayerCollector")) or not guiVisible(atm) then
        AtmState.signature = nil
        return
    end

    local sequence = atm:FindFirstChild("Sequence1", true)
    if not sequence or not sequence:IsA("TextLabel") then
        return
    end
    local text = sequence.Text or ""
    if text == "" then
        return
    end
    if AtmState.signature == text then
        if tick() - AtmState.time > 3 then
            AtmState.signature = nil
        else
            return
        end
    end
    if AtmState.busy then
        return
    end

    AtmState.signature = text
    AtmState.time = tick()
    AtmState.busy = true

    local tokens = {}
    for token in string.gmatch(text, "%S+") do
        table.insert(tokens, token)
    end

    task.spawn(function()
        pcall(function()
            for _, token in ipairs(tokens) do
                if not Settings.autoAtm then
                    break
                end
                local target = nil
                for _, descendant in ipairs(atm:GetDescendants()) do
                    if descendant:IsA("ImageButton") or descendant:IsA("TextButton") then
                        if descendant:IsA("TextButton") and descendant.Text == token then
                            target = descendant
                        end
                        for _, label in ipairs(descendant:GetDescendants()) do
                            if label:IsA("TextLabel") and label.Text == token then
                                target = descendant
                                break
                            end
                        end
                    end
                    if target then
                        break
                    end
                end
                if target then
                    clickButton(target)
                    task.wait(0.1)
                end
            end
        end)
        AtmState.busy = false
    end)
end

task.spawn(function()
    while true do
        if Settings.autoAtm then
            pcall(XJWAutoAtmStep)
        else
            AtmState.signature = nil
        end
        task.wait(0.2)
    end
end)

local function setAutoHack(on)
    Settings.autoHack = on
    pcall(function()
        local framework = LocalPlayer.PlayerScripts:FindFirstChild("Framework")
        framework = framework and require(framework:FindFirstChild("Character"))
        local rulesModule = ReplicatedStorage:FindFirstChild("Modules")
        local rules = rulesModule and rulesModule:FindFirstChild("GameRules")
        if rules then
            rules = require(rules)
            rules.disableHacking = on
            rules.disableMinigames = on
        end
        if framework then
            if not autoHackCache.hacking then
                autoHackCache.hacking = framework.hackingMinigame
            end
            if not autoHackCache.start then
                autoHackCache.start = framework.startMinigame
            end
            if on then
                framework.hackingMinigame = function()
                    return true
                end
                framework.startMinigame = function()
                    return true
                end
            else
                if autoHackCache.hacking then
                    framework.hackingMinigame = autoHackCache.hacking
                end
                if autoHackCache.start then
                    framework.startMinigame = autoHackCache.start
                end
            end
        end
    end)
end



local fpsFrames = 0
local fpsClock = 0
local accNoclip = 0
local accHitbox = 0
local accAmmo = 0
local accRapid = 0
local accEsp = 0
local accGhost = 0

local function updateFps(dt)
    fpsFrames = fpsFrames + 1
    fpsClock = fpsClock + dt
    if fpsClock >= 0.5 then
        local fps = math.floor(fpsFrames / fpsClock + 0.5)
        fpsFrames = 0
        fpsClock = 0
    end
end

local function tickAmmo()
    local chars = Workspace:FindFirstChild("Characters")
    local container = chars and chars:FindFirstChild(LocalPlayer.Name)
    if not container then
        XJWAmmoCache = nil
        return
    end
    local now = tick()
    if not XJWAmmoCache or XJWAmmoCache.container ~= container or now - (XJWAmmoCache.lastScan or 0) > 5 then
        local configs = {}
        for _, child in ipairs(container:GetChildren()) do
            local config = child:FindFirstChild("Config")
            if config then
                table.insert(configs, config)
            end
        end
        XJWAmmoCache = {
            container = container,
            configs = configs,
            lastScan = now,
        }
    end
    for _, config in ipairs(XJWAmmoCache.configs) do
        if config.Parent then
            local ammo = config:FindFirstChild("Ammo")
            if ammo and ammo.Value ~= 999999 then
                ammo.Value = 999999
            end
            local total = config:FindFirstChild("TotalAmmo")
            if total and total.Value ~= 999999 then
                total.Value = 999999
            end
        end
    end
end

local function tickRapidFire()
    if not getgc then
        return
    end
    local now = tick()
    if not XJWRapidCache or now - (XJWRapidCache.lastScan or 0) > 10 then
        local tables = {}
        for _, value in pairs(getgc(true)) do
            if type(value) == "table" and (rawget(value, "SHOOT_MODE") ~= nil or rawget(value, "RPM") ~= nil) then
                table.insert(tables, value)
            end
        end
        XJWRapidCache = {
            tables = tables,
            lastScan = now,
        }
    end
    for _, value in pairs(XJWRapidCache.tables) do
        if type(value) == "table" then
            if rawget(value, "SHOOT_MODE") ~= nil and rawget(value, "SHOOT_MODE") ~= 2 then
                rawset(value, "SHOOT_MODE", 2)
            end
            if rawget(value, "RPM") ~= nil and rawget(value, "RPM") ~= math.huge then
                rawset(value, "RPM", math.huge)
            end
        end
    end
end

local function updateFly(dt)
    local _, humanoid, root = getChar(LocalPlayer)

    if not Settings.fly or not root or not humanoid or humanoid.Health <= 0 then
        if FlyState.active then
            stopFly()
        end
        if flyWasOn and not Settings.noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
        flyWasOn = false
        return
    end

    flyWasOn = true
    local mode = Settings.flyMode == "物理" and "物理" or "传送"
    if not FlyState.active or FlyState.root ~= root or FlyState.mode ~= mode then
        if FlyState.active then
            stopFly()
        end
        startFly(root, humanoid, mode)
    end

    local direction = moveDirection()
    local speed = Settings.flySpeed or 35

    if mode == "物理" then
        if FlyState.bodyVelocity then
            FlyState.bodyVelocity.Velocity = direction * speed
        end
        if FlyState.bodyGyro then
            local cam = Workspace.CurrentCamera
            if cam then
                FlyState.bodyGyro.CFrame = cam.CFrame
            end
        end
        return
    end

    pcall(function()
        root.Anchored = false
    end)

    local cam = Workspace.CurrentCamera
    local position = root.Position + direction * speed * dt
    local look = cam and cam.CFrame.LookVector or root.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    local target
    if flat.Magnitude > 0.01 then
        target = CFrame.lookAt(position, position + flat.Unit)
    else
        target = CFrame.new(position) * root.CFrame.Rotation
    end
    root.CFrame = target
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function updateVehicle()
    local seat = getVehicleSeat()
    local chassis = XJWSeatChassis(seat) or seat
    if Settings.vehicleFly then
        if seat then
            pcall(function()
                seat.Throttle = 0
                seat.Steer = 0
            end)
        end
        if VehicleState.velocity then
            clearVehicleForce()
        end
        return
    end
    if Settings.cruise and seat then
        pcall(function()
            seat.Throttle = 1
        end)
    end

    if Settings.vehicleBoost and seat then
        if VehicleState.part ~= chassis then
            clearVehicleForce()
            local attachment = make("Attachment", { Name = "XJWVehicleAttachment" }, chassis)
            local velocity = make("LinearVelocity", {
                Name = "XJWVehicleVelocity",
                Attachment0 = attachment,
                MaxForce = math.huge,
                VectorVelocity = Vector3.zero,
            }, chassis)
            VehicleState.attachment = attachment
            VehicleState.velocity = velocity
            VehicleState.part = chassis
        end
        if VehicleState.velocity then
            VehicleState.velocity.VectorVelocity = seat.CFrame.LookVector * Settings.vehicleSpeed
        end
    elseif not Settings.vehicleBoost and VehicleState.velocity then
        clearVehicleForce()
    end
end

local function updateNoclip()
    local char = LocalPlayer.Character
    if not char then
        return
    end
    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BasePart") then
            if Settings.noclip then
                descendant.CanCollide = false
            end
        end
    end
end

local function updateHitboxes()
    if Settings.hitbox then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not (Settings.hitboxTeam and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team) then
                    local char = player.Character
                    if char then
                        applyHitbox(char)
                    end
                end
            end
        end
    else
        for root in pairs(hitboxCache) do
            if root and root.Parent then
                clearHitbox(root)
            else
                hitboxCache[root] = nil
            end
        end
    end
end

connect(RunService.Heartbeat, function(dt)
    updateFps(dt)

    local _, humanoid, myRoot = getChar(LocalPlayer)

    if humanoid then
        if Settings.walkEnabled then
            humanoid.WalkSpeed = Settings.walkSpeed
        end
        if Settings.jumpEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Settings.jumpPower * Settings.jumpMultiplier
        end
    end

    if Settings.stamina and Core then
        pcall(function()
            Core.stamina = 100
        end)
    end
    if Settings.hunger and Core then
        pcall(function()
            Core.food = 100
        end)
    end
    accAmmo = accAmmo + dt
    if Settings.infiniteAmmo and accAmmo >= 0.75 then
        accAmmo = 0
        pcall(tickAmmo)
    end

    accRapid = accRapid + dt
    if Settings.rapidFire and accRapid >= 1 then
        accRapid = 0
        pcall(tickRapidFire)
    elseif not Settings.rapidFire then
        XJWRapidCache = nil
    end

    accNoclip = accNoclip + dt
    if (Settings.noclip or Settings.fly) and accNoclip >= 0.1 then
        accNoclip = 0
        updateNoclip()
    end

    updateVehicle()
    XJWUpdateVehicleFly(dt)

    accHitbox = accHitbox + dt
    if accHitbox >= 0.2 then
        accHitbox = 0
        updateHitboxes()
        updateRangeSphere()
    end

    runAura()
    runRagebot()

    accEsp = accEsp + dt
    if accEsp >= 0.12 then
        accEsp = 0
        refreshEsp()
        for player in pairs(EspTrackers) do
            updateTracker(player)
        end
        if XJWQuick and XJWQuick.Refresh then
            XJWQuick.Refresh()
        end
        if XJWRefreshVehicleEsp then
            XJWRefreshVehicleEsp()
        end
    end

    accGhost = accGhost + dt
    if Settings.ghost and accGhost >= 0.5 then
        accGhost = 0
        local char = LocalPlayer.Character
        if GhostState.exposedUntil > 0 then
            if tick() >= GhostState.exposedUntil then
                GhostState.exposedUntil = 0
                XJWGhostHide()
            end
        elseif char and not char:GetAttribute("XJWGhostApplied") then
            applyGhostBody(char, true)
            char:SetAttribute("XJWGhostApplied", true)
        end
    elseif not Settings.ghost then
        GhostState.exposedUntil = 0
        local char = LocalPlayer.Character
        if char and char:GetAttribute("XJWGhostApplied") then
            applyGhostBody(char, false)
            char:SetAttribute("XJWGhostApplied", nil)
        end
    end
end)

connect(RunService.RenderStepped, function(dt)
    updateFly(dt)
    updateAimDrawings(dt)
    updateSilent(dt)
end)

connect(UserInputService.JumpRequest, function()
    if Settings.infJump then
        local _, humanoid, root = getChar(LocalPlayer)
        if humanoid and root and humanoid.Health > 0 then
            local state = humanoid:GetState()
            local grounded = state == Enum.HumanoidStateType.Landed
                or state == Enum.HumanoidStateType.Running
                or state == Enum.HumanoidStateType.RunningNoPhysics
                or state == Enum.HumanoidStateType.Seated
            if not grounded or Settings.infJump then
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    Settings.jumpPower * Settings.jumpMultiplier * 0.9,
                    root.AssemblyLinearVelocity.Z
                )
            end
        end
    end
end)

connect(LocalPlayer.CharacterAdded, function(char)
    task.wait(0.6)
    if Settings.ghost then
        setGhost(true)
    end
    if Settings.hitbox then
        task.defer(function()
            applyHitbox(char)
        end)
    end
end)



local function flagSetter(key)
    return function(value)
        Settings[key] = value
    end
end



local ConfigRegistry = {}
local Window = WindUI:CreateWindow({
    Title = "圣奥里",
    Icon = "sparkles",
    Author = "XJW",
    Folder = "XJWScriptSuzume",
    Size = UDim2.fromOffset(420, 520),
    Theme = "Dark",
    HideSearchBar = false,
    MobileButtonsSide = "Left",
})


local Tab = nil
local function Section(name, sub)
    Tab:Section({ Title = name, Desc = sub or "" })
end

local function TG(flag, text, desc, cb)
    local c = Tab:Toggle({
        Title = text,
        Desc = desc or "",
        Default = Settings[flag] == true,
        Callback = function(v)
            Settings[flag] = v
            if cb then
                pcall(cb, v)
            end
        end,
    })
    ConfigRegistry[flag] = c
    return c
end

local function SL(flag, text, min, max, step, default, suffix, rounding, prefix, cb)
    local title = text
    if suffix and #suffix > 0 then
        title = title .. "  " .. suffix
    end
    local c = Tab:Slider({
        Title = title,
        Value = { Min = min, Max = max, Default = Settings[flag] ~= nil and Settings[flag] or default },
        Step = step,
        Callback = function(v)
            Settings[flag] = v
            if cb then
                pcall(cb, v)
            end
        end,
    })
    ConfigRegistry[flag] = c
    return c
end

local function DD(flag, text, options, default, multi, desc, cb)
    local c = Tab:Dropdown({
        Title = text,
        Desc = desc or "",
        Values = options,
        Value = Settings[flag] ~= nil and Settings[flag] or default,
        Multi = multi or false,
        AllowNone = false,
        Callback = function(v)
            Settings[flag] = v
            if cb then
                pcall(cb, v)
            end
        end,
    })
    ConfigRegistry[flag] = c
    return c
end

local function BT(text, cb)
    return Tab:Button({ Title = text, Callback = cb })
end

local function LB(text)
    return Tab:Paragraph({ Title = text or "" })
end

local function IN(flag, text, placeholder)
    local c = Tab:Input({
        Title = text,
        Placeholder = placeholder or "",
        Value = "",
        ClearTextOnFocus = true,
        Callback = function(v)
            if Settings[flag] ~= nil then
                Settings[flag] = v
            end
        end,
    })
    ConfigRegistry[flag] = c
    return c
end

local function KB(flag, text, defaultKey, mode, cb)
    local c = Tab:Keybind({
        Title = text,
        Value = defaultKey,
        Callback = function(k)
            if k and k ~= "None" and k ~= "Unknown" then
                Settings[flag] = Enum.KeyCode[k] or Settings[flag]
            end
            if cb then
                pcall(cb, k)
            end
        end,
    })
    ConfigRegistry[flag] = c
    return c
end

local function saveConfig()
    if not writefile then
        Notify("保存配置", "执行器不支持 writefile", "error")
        return
    end
    pcall(function()
        if makefolder then
            makefolder("XJW")
        end
    end)
    local output = {}
    for key, value in pairs(Settings) do
        local valueType = type(value)
        if typeof(value) == "EnumItem" then
            output[key] = tostring(value):gsub("Enum.KeyCode.", "")
        elseif valueType == "boolean" or valueType == "number" or valueType == "string" then
            output[key] = value
        elseif key == "espTeams" and valueType == "table" then
            local teams = {}
            for team, enabled in pairs(value) do
                teams[team] = enabled
            end
            output[key] = teams
        end
    end
    local ok = pcall(function()
        writefile("XJW/XJWScript.json", HttpService:JSONEncode(output))
    end)
    Notify("保存配置", ok and "已写入 XJW/XJWScript.json" or "写入失败", ok and "success" or "error")
end

local function loadConfig()
    if not (isfile and readfile) then
        Notify("加载配置", "执行器不支持文件读取", "error")
        return
    end
    local ok, data = pcall(function()
        if not isfile("XJW/XJWScript.json") then
            return nil
        end
        return HttpService:JSONDecode(readfile("XJW/XJWScript.json"))
    end)
    if not ok or type(data) ~= "table" then
        Notify("加载配置", "没有找到配置文件", "warn")
        return
    end
    for key, value in pairs(data) do
        if Settings[key] ~= nil then
            if key == "flyMode" and (value == "VX 锚定" or value == "锚定") then
                value = "传送"
            end
            if type(value) == "string" and typeof(Settings[key]) == "EnumItem" then
                value = Enum.KeyCode[value] or Settings[key]
            end
            if key == "espTeams" and type(value) == "table" then
                Settings.espTeams = {}
                for team, enabled in pairs(value) do
                    Settings.espTeams[team] = enabled
                end
            else
                Settings[key] = value
            end
            local control = ConfigRegistry[key]
            if control then
                pcall(function()
                    if control.__type == "Dropdown" then
                        return
                    end
                    local v = Settings[key]
                    if typeof(v) == "EnumItem" then
                        v = tostring(v):gsub("Enum.KeyCode.", "")
                    end
                    if control.SetValue then
                        control:SetValue({ tostring(v):gsub("Enum.KeyCode.", ""), "Always", {} })
                    elseif control.Set then
                        control:Set(v, true)
                    end
                end)
            end
        end
    end
    if QuickButton then
        QuickButton.Position = UDim2.fromOffset(Settings.quickButtonX or 12, Settings.quickButtonY or 250)
    end
    if QuickPanel then
        QuickPanel.Position = UDim2.fromOffset(Settings.quickPanelX or 12, Settings.quickPanelY or 74)
    end
    Notify("加载配置", "配置已应用", "success")
end

local MainPage = Window:Tab({ Title = "常用" })
Tab = MainPage
Section("生存", "ER:LC 基础状态")
TG("stamina", "无限体力", "锁定体力为 100", flagSetter)
TG("hunger", "无限饥饿", "锁定饱食度为 100", flagSetter)
_cb1 = function(value)

        Settings.noRagdoll = value
        if value then
            installRagdollHook()
        end
end
TG("noRagdoll", "防布娃娃", "阻止角色被击倒进入布娃娃", function(v) _cb1(v) end)
TG("noFallDamage", "防摔伤", "拦截 takeDamage 事件", flagSetter)
_cb2 = function(value)

        Settings.antiPull = value
        setAntiPull(value)
end
TG("antiPull", "防越狱拉回", "拦截监狱拉回与提示", function(v) _cb2(v) end)
TG("combatBlock", "战斗拦截", "阻止客户端发送 combatMode", flagSetter)

Section("隐身", "Ghost 模式")
TG("ghost", "隐身", "隐藏位置与角色模型", setGhost)
TG("ghostHud", "隐身悬浮窗", "屏幕上的快捷开关", setGhostHud)
TG("ghostLock", "锁定悬浮窗位置", "禁止拖动悬浮窗", setGhostLock)
_cb3 = function(value)

        XJWGhostExpose(Settings.ghostExposeTime)
end
BT("短暂现身", function(v) _cb3(v) end)
SL("ghostExposeTime", "现身时长", 1, 10, 0.5, 4, "s", 1, "", flagSetter)
KB("ghostExposeKey", "短暂现身按键", "G", "Press", function(v) if v then XJWGhostExpose(Settings.ghostExposeTime) end end)
_cb4 = function(value)

        XJWGhostResume()
end
BT("重新隐藏", function(v) _cb4(v) end)


local MoneyPage = Window:Tab({ Title = "自动化" })
Tab = MoneyPage
Section("拾取与交互", "自动化")
TG("autoMoney", "自动捡钱", "自动寻找并拾取现金掉落", flagSetter)
TG("autoHack", "自动黑客", "跳过黑客与迷你游戏", setAutoHack)
TG("autoAtm", "ATM 自动解谜", "读取 Sequence1 并自动点击 ATM Hack", flagSetter)


TG("instantPrompt", "秒互动", "ProximityPrompt 按住立即完成", flagSetter)

Section("任务", "Mission")
TG("autoMission", "自动接取任务", "自动加入当前可接任务", flagSetter)
TG("missionPriority", "优先高收益任务", "按 profitability / reward 排序", flagSetter)
SL("missionInterval", "接取间隔", 0.5, 10, 0.5, 2, "s", 1, "", flagSetter)

Section("车辆任务", "出租车 / 公交")
_cb5 = function(value)

        Settings.taxi = value
        if value then
            local _, _, root = getChar(LocalPlayer)
            taxiOrigin = root and root.Position or nil
            Notify("出租车刷钱", value and "已开启，正在跟随路线" or "已关闭", "success")
        end
end
TG("taxi", "出租车刷钱", "跟随 ClientContent 路线", function(v) _cb5(v) end)
TG("taxiSafe", "安全模式", "先回到记录点再传送，降低风险", flagSetter)
DD("taxiMode", "延迟模式", {"随机时间", "距离测算"}, "随机时间", false, "出租车传送间隔", flagSetter)
TG("bus", "公交车刷钱", "传送到公交区域并上下车", flagSetter)
TG("farmer", "农民刷钱", "自动寻找 Pick Up 提示", flagSetter)
TG("golf", "高尔夫刷钱", "自动创建房间并击球进洞", flagSetter)


local CombatPage = Window:Tab({ Title = "战斗" })
Tab = CombatPage
Section("武器", "弹药与射速")
TG("infiniteAmmo", "无限子弹", "弹药与备弹设为最大值", flagSetter)
_cb6 = function(value)

        Settings.rapidFire = value
        if not value then
            XJWRapidCache = nil
        end
end
TG("rapidFire", "快速射击", "改写武器 SHOOT_MODE / RPM", function(v) _cb6(v) end)


Section("杀戮光环", "范围伤害")
TG("aura", "杀戮光环", "对范围内目标发送 damage", flagSetter)
SL("auraRange", "攻击范围", 5, 300, 1, 50, " m", 0, "", flagSetter)
SL("auraDamage", "伤害倍率", 1, 50, 0.5, 5, "", 1, "", flagSetter)
SL("auraInterval", "攻击间隔", 0.01, 0.5, 0.01, 0.05, "s", 2, "", flagSetter)
TG("auraPolice", "只攻击警察", "", flagSetter)
TG("auraCivilian", "只攻击平民", "", flagSetter)
TG("auraCombat", "战斗检测", "仅攻击处于战斗 / 追捕状态的目标", flagSetter)

Section("Ragebot", "远程点击")
TG("ragebot", "Ragebot", "按间隔持续造成伤害", flagSetter)
SL("rageRange", "攻击距离", 10, 500, 5, 150, " m", 0, "", flagSetter)
SL("rageInterval", "攻击间隔", 0.01, 0.5, 0.01, 0.05, "s", 2, "", flagSetter)
DD("ragePart", "攻击部位", {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}, "Head", false, "", flagSetter)
TG("rageJob", "职业检测", "跳过与自己同职业的目标", flagSetter)
TG("rageWall", "墙壁检测", "", flagSetter)
TG("rageCombat", "战斗检测", "", flagSetter)
TG("ragePolice", "锁定警察", "", flagSetter)
TG("rageCivilian", "锁定平民", "", flagSetter)
TG("rageBeam", "弹道显示", "显示命中光束", flagSetter)

Section("碰撞箱", "Hitbox Expander")
_cb7 = function(value)

        Settings.hitbox = value
        if not value then
            clearAllHitboxes()
        end
end
TG("hitbox", "碰撞箱扩展", "", function(v) _cb7(v) end)
SL("hitboxSize", "碰撞箱大小", 2, 30, 0.5, 10, "", 0, "", flagSetter)
SL("hitboxTransparency", "透明度", 0, 1, 0.05, 0.65, "", 0, "", flagSetter)
TG("hitboxTeam", "队伍检测", "", flagSetter)
TG("hitboxOutline", "显示轮廓", "", flagSetter)
TG("hitboxGlow", "发光效果", "", flagSetter)
TG("hitboxPulse", "脉动效果", "", flagSetter)
DD("hitboxColor", "碰撞箱颜色", {"紫色", "红色", "粉色", "蓝色", "青色", "绿色", "黄色", "白色"}, "紫色", false, "", flagSetter)



local AimPage = Window:Tab({ Title = "自瞄" })
Tab = AimPage
Section("自瞄", "Camera Aimbot")
TG("aim", "开启自瞄", "按 FOV 锁定目标", flagSetter)
TG("aimHold", "按住右键", "仅在按住鼠标右键时自瞄", flagSetter)
SL("aimFov", "FOV 范围", 20, 600, 5, 140, " px", 0, "", flagSetter)
SL("aimSmooth", "平滑度", 0, 100, 1, 25, "%", 0, "", flagSetter)
DD("aimPart", "瞄准部位", {"头部", "胸部", "躯干", "左臂", "右臂", "左腿", "右腿"}, "头部", false, "", flagSetter)
DD("aimMode", "优先模式", {"准心最近", "距离最近", "血量最低"}, "准心最近", false, "", flagSetter)
TG("aimTeam", "队伍检测", "跳过同队玩家", flagSetter)
TG("aimFriend", "好友检测", "跳过好友", flagSetter)
TG("aimWall", "墙壁检测", "仅锁定可见目标", flagSetter)
TG("aimPredict", "预判自瞄", "根据目标速度提前量", flagSetter)
TG("aimPolice", "只自瞄警察", "", flagSetter)
TG("aimCivilian", "只自瞄平民", "", flagSetter)
TG("aimCombat", "战斗检测", "", flagSetter)
TG("aimVehicles", "载具自瞄", "没有玩家目标时锁定最近载具", flagSetter)
KB("aimVehiclesKey", "载具自瞄按键", "T", "Toggle", function(v) local c = ConfigRegistry.aimVehicles local nv = not Settings.aimVehicles if c then c:Set(nv, true) else Settings.aimVehicles = nv end Notify("载具自瞄", nv and "已开启" or "已关闭", nv and "success" or "info") end)

Section("显示", "准心与颜色")
TG("aimShowFov", "显示 FOV 圈", "", flagSetter)
TG("aimCrosshair", "显示准心", "", flagSetter)
TG("aimTracer", "显示追踪线", "", flagSetter)
SL("aimFovThickness", "FOV 圈厚度", 1, 5, 0.5, 1.5, "", 0, "", flagSetter)
DD("aimColor", "颜色", {"紫色", "红色", "粉色", "蓝色", "青色", "绿色", "黄色", "白色"}, "紫色", false, "", flagSetter)

Section("Silent Aim", "射线重定向")
_cb8 = function(value)

        Settings.silent = value
        if value and not raycastHooked then
            Notify("静默瞄准", "当前执行器不支持 hookfunction，功能不可用", "error")
        end
end
TG("silent", "静默瞄准", "钩住 Workspace.Raycast，不移动视角", function(v) _cb8(v) end)
SL("silentFov", "静默 FOV", 20, 600, 5, 140, "", 0, "", flagSetter)
SL("silentDistance", "最大距离", 50, 800, 10, 300, "", 0, "", flagSetter)
DD("silentPart", "瞄准部位", {"头部", "胸部", "躯干", "左臂", "右臂", "左腿", "右腿"}, "头部", false, "", flagSetter)
TG("silentTeam", "队伍检测", "", flagSetter)
TG("silentFriend", "好友检测", "", flagSetter)
TG("silentPolice", "只瞄准警察", "", flagSetter)
TG("silentCivilian", "只瞄准平民", "", flagSetter)
TG("silentCombat", "战斗检测", "", flagSetter)
TG("silentShowFov", "显示静默圈", "", flagSetter)


local EspPage = Window:Tab({ Title = "视觉" })
Tab = EspPage
Section("范围", "球形可视化")
TG("rangeEnabled", "显示范围球", "以角色为中心的球形指示器", flagSetter)
SL("rangeSize", "范围大小", 5, 200, 5, 50, " m", 0, "", flagSetter)
SL("rangeTransparency", "透明度", 0, 1, 0.05, 0.75, "", 0, "", flagSetter)
DD("rangeColor", "颜色", {"紫色", "红色", "粉色", "蓝色", "青色", "绿色", "黄色", "白色"}, "紫色", false, "", flagSetter)
DD("rangeMaterial", "材质", {"Neon", "ForceField", "Glass", "SmoothPlastic", "Plastic"}, "Neon", false, "", flagSetter)
TG("rangeOutline", "显示轮廓", "", flagSetter)
TG("rangeCollision", "启用碰撞", "", flagSetter)
TG("rangeGlow", "发光效果", "", flagSetter)
TG("rangePulse", "脉动效果", "", flagSetter)


Section("玩家透视", "2D 方框 + 高亮")
_cb9 = function(value)

        Settings.esp = value
        if not value then
            for player in pairs(EspTrackers) do
                destroyTracker(player)
            end
        end
end
TG("esp", "玩家透视", "总开关", function(v) _cb9(v) end)
TG("espName", "显示名字", "", flagSetter)
TG("espDistance", "显示距离", "", flagSetter)
TG("espHealth", "显示血量", "", flagSetter)
TG("espBox", "显示方框", "", flagSetter)
TG("espHighlight", "显示高亮", "", flagSetter)
TG("espTracer", "显示追踪线", "", flagSetter)
DD("espTracerOrigin", "追踪线起点", {"屏幕底部", "屏幕中心", "屏幕顶部"}, "屏幕底部", false, "", flagSetter)
TG("espFugitive", "显示逃犯", "平民且通缉等级 > 0", flagSetter)
_cb10 = function(value)

        for key in pairs(Settings.espTeams) do
            Settings.espTeams[key] = false
        end
        for _, name in ipairs(values) do
            Settings.espTeams[name] = true
        end
end
DD("espTeams", "选择透视队伍", {"Chef", "Civilian", "Delivery", "Farmer", "Fire", "Police", "Medical", "Prisoner", "Road Service", "Transit"}, { "Chef", "Civilian", "Delivery", "Farmer", "Fire", "Police", "Medical", "Prisoner", "Road Service", "Transit" }, true, "多选，全部取消则显示全部", function(v) _cb10(v) end)


local PlayerPage = Window:Tab({ Title = "移动" })
Tab = PlayerPage
Section("位移", "Blink")
TG("blink", "Blink", "传送到准星所指位置", flagSetter)
SL("blinkDistance", "Blink 距离", 20, 500, 10, 120, " m", 0, "", flagSetter)
KB("blinkKey", "Blink 按键", "Eight", "Press", function(v) if v then XJWBlink() end end)
_cb11 = function(value)

        XJWBlink()
end
BT("立即 Blink", function(v) _cb11(v) end)


Section("移动", "速度 / 跳跃 / 飞行")
_cb12 = function(value)

        Settings.walkEnabled = value
        if not value then
            local _, humanoid = getChar(LocalPlayer)
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
end
TG("walkEnabled", "自定义速度", "修改 WalkSpeed", function(v) _cb12(v) end)
SL("walkSpeed", "移动速度", 16, 400, 1, 200, "", 0, "", flagSetter)
_cb13 = function(value)

        Settings.jumpEnabled = value
        if not value then
            local _, humanoid = getChar(LocalPlayer)
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
end
TG("jumpEnabled", "自定义跳跃", "", function(v) _cb13(v) end)
SL("jumpPower", "跳跃高度", 50, 300, 5, 50, "", 0, "", flagSetter)
SL("jumpMultiplier", "跳跃倍数", 1, 5, 0.1, 1, "", 0, "", flagSetter)
TG("infJump", "无限跳跃", "", flagSetter)
TG("fly", "飞行", "", flagSetter)
SL("flySpeed", "飞行速度", 10, 200, 5, 35, "", 0, "", flagSetter)
_cb14 = function(value)

        Settings.flyMode = value
        Notify("飞行模式", "已切换为「" .. tostring(value) .. "」", "info")
end
DD("flyMode", "飞行模式", {"传送", "物理"}, "传送", false, "", function(v) _cb14(v) end)
TG("noclip", "穿墙", "", setNoclip)


local VehiclePage = Window:Tab({ Title = "载具" })
Tab = VehiclePage
Section("飞行", "驾驶座内生效")
TG("vehicleFly", "载具飞行", "WASD + Space / Ctrl 控制载具", flagSetter)
SL("vehicleFlySpeed", "飞行速度", 20, 400, 5, 80, "", 0, "", flagSetter)
KB("vehicleFlyKey", "飞行开关键", "F", "Toggle", function(v) local c = ConfigRegistry.vehicleFly local nv = not Settings.vehicleFly if c then c:Set(nv, true) else Settings.vehicleFly = nv end Notify("载具飞行", nv and "已开启" or "已关闭", nv and "success" or "info") end)
Section("载具 ESP")
_cb15 = function(value)

        Settings.vehicleEsp = value
        if not value then
            for model in pairs(XJWVehicle.trackers) do
                XJWDestroyVehicleTracker(model)
            end
        end
end
TG("vehicleEsp", "载具透视", "高亮附近载具并显示信息", function(v) _cb15(v) end)
TG("vehicleEspName", "显示名字", "", flagSetter)
TG("vehicleEspDistance", "显示距离", "", flagSetter)
TG("vehicleEspHighlight", "显示高亮", "", flagSetter)
_cb16 = function(value)

        local _, _, root = getChar(LocalPlayer)
        if not root then
            return
        end
        local model, part, distance = XJWNearestVehicle(root.Position)
        if part then
            teleportTo(part.Position + Vector3.new(0, 3, 0))
            Notify("载具", string.format("已传送到 %s（%.0f m）", model.Name, distance), "success")
        else
            Notify("载具", "附近没有找到载具", "warn")
        end
end
BT("传送到最近载具", function(v) _cb16(v) end)

Section("带来载具")
_cb17 = function(value)

        XJWBringVehicleToMe()
end
BT("把我的载具传到脸上（无视距离）", function(v) _cb17(v) end)
_cb18 = function(value)

        XJWBringVehicleToNearestPlayer()
end
BT("把我的载具带到最近玩家", function(v) _cb18(v) end)
_cb19 = function(value)

        XJWBringVehicleToMe(true)
end
BT("把最近载具带到我", function(v) _cb19(v) end)
_cb20 = function(value)

        XJWBringVehicleToNearestPlayer(true)
end
BT("把最近载具带到最近玩家", function(v) _cb20(v) end)
local bringPlayerInput = IN("bringPlayerInput", "目标玩家", "输入完整用户名")
_cb21 = function(value)

        XJWBringVehicleToName(bringPlayerInput.Value)
end
BT("把载具带到指定玩家", function(v) _cb21(v) end)
SL("bringDistance", "带来距离", 5, 40, 1, 12, " m", 0, "", flagSetter)
KB("bringVehicleKey", "带来载具按键", "B", "Press", function(v) if v then XJWBringVehicleToMe() end end)

Section("速度", "进入驾驶座后生效")
TG("vehicleBoost", "速度控制器", "给座椅施加 LinearVelocity", flagSetter)
SL("vehicleSpeed", "目标速度", 20, 500, 5, 120, "", 0, "", flagSetter)
TG("cruise", "定速巡航", "持续保持油门", flagSetter)



local PolicePage = Window:Tab({ Title = "警察" })
Tab = PolicePage
Section("执法", "手铐 / 传送")
TG("policeCuff", "自动铐", "对范围内目标调用 handcuff", flagSetter)
TG("policeTp", "自动传送", "传送到最近的通缉平民身后", flagSetter)
TG("policeCombat", "战斗检测", "", flagSetter)
SL("policeRange", "范围", 20, 1000, 10, 200, "", 0, "", flagSetter)
SL("policeInterval", "间隔", 0.1, 3, 0.1, 0.5, "", 0, "", flagSetter)


local TeleportPage = Window:Tab({ Title = "传送" })
Tab = TeleportPage
local savedPosition = nil
Section("玩家", "按名字传送")
local playerInput = IN("playerInput", "玩家名字", "输入完整用户名")
_cb22 = function(value)

        local name = playerInput.Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and string.lower(player.Name):find(string.lower(name), 1, true) then
                local root = getRoot(player)
                if root then
                    teleportTo(root.Position)
                    Notify("传送", "已传送到 " .. player.Name, "success")
                    return
                end
            end
        end
        Notify("传送", "未找到玩家", "error")
end
BT("传送到玩家", function(v) _cb22(v) end)
_cb23 = function(value)

        local cam = Workspace.CurrentCamera
        if not cam then
            return
        end
        local ray = cam:ScreenPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 800)
        if result then
            teleportTo(result.Position + result.Normal * 3)
        else
            teleportTo(ray.Origin + ray.Direction * 60)
        end
end
BT("传送到准星位置", function(v) _cb23(v) end)

Section("坐标", "记录与坐标传送")
_cb24 = function(value)

        local _, _, root = getChar(LocalPlayer)
        if root then
            savedPosition = root.Position
            Notify("传送", "已记录当前位置", "success")
        end
end
BT("记录当前位置", function(v) _cb24(v) end)
_cb25 = function(value)

        if savedPosition then
            teleportTo(savedPosition)
        else
            Notify("传送", "还没有记录位置", "warn")
        end
end
BT("回到记录位置", function(v) _cb25(v) end)
local coordInput = IN("coordInput", "坐标 (X, Y, Z)", "例如 120, 30, -450")
_cb26 = function(value)

        local x, y, z = string.match(coordInput.Value, "([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)")
        if x and y and z then
            teleportTo(Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
        else
            Notify("传送", "坐标格式错误", "error")
        end
end
BT("传送到坐标", function(v) _cb26(v) end)
_cb27 = function(value)

        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            teleportTo(spawn.Position)
        else
            Notify("传送", "没有找到出生点", "warn")
        end
end
BT("传送到出生点", function(v) _cb27(v) end)

function XJWGameCore()
    if XJWGameCoreCache ~= nil then
        return XJWGameCoreCache
    end
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local loaderModule = modules and modules:FindFirstChild("ModuleLoader")
        local coreModule = Framework and Framework:FindFirstChild("Core")
        if loaderModule and coreModule then
            local loader = require(loaderModule)
            local core = require(coreModule)
            if type(loader.assign) == "function" then
                XJWGameCoreCache = loader.assign(core)
            else
                XJWGameCoreCache = core
            end
        end
    end)
    return XJWGameCoreCache
end

function XJWMapMarker()
    local sources = {}
    local gameCore = XJWGameCore()
    if gameCore then
        table.insert(sources, gameCore)
    end
    if Core then
        table.insert(sources, Core)
    end
    for _, source in ipairs(sources) do
        if source then
            local ok, navigation = pcall(function()
                return source.navigationPoint
            end)
            if ok and typeof(navigation) == "Vector3" then
                return navigation
            end
            local ok2, waypoints = pcall(function()
                return source.waypoints
            end)
            if ok2 and type(waypoints) == "table" and type(waypoints.Navigation) == "function" then
                local ok3, result = pcall(waypoints.Navigation)
                if ok3 and typeof(result) == "Vector3" then
                    return result
                end
            end
        end
    end
    return nil
end

function XJWTeleportToMarker()
    local position = XJWMapMarker()
    if not position then
        Notify("传送", "地图没有设置标记，请打开地图点 Navigate", "warn")
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(position, 5)
    end)
    teleportTo(position + Vector3.new(0, 3, 0))
    Notify("传送", "已传送到地图标记", "success")
end

function XJWLocationPart(location)
    if not location then
        return nil
    end
    if location:IsA("BasePart") then
        return location
    end
    local spawn = location:FindFirstChild("SpawnLocation", true)
    if spawn and spawn:IsA("BasePart") then
        return spawn
    end
    for _, descendant in ipairs(location:GetDescendants()) do
        if descendant.Name == "_Interaction" and descendant:IsA("BasePart") and descendant:FindFirstChildWhichIsA("ProximityPrompt", true) then
            return descendant
        end
    end
    return location:FindFirstChildWhichIsA("BasePart", true)
end

function XJWTeleportToLocation(location)
    local part = XJWLocationPart(location)
    if not part then
        Notify("传送", "地点不可用：" .. tostring(location and location.Name or "未知"), "warn")
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(part.Position, 5)
    end)
    local entered = false
    if Core and type(Core.enterLocation) == "function" then
        local ok = pcall(function()
            Core.enterLocation({ spawnPoint = part })
        end)
        entered = ok
    end
    if not entered then
        teleportTo(part.Position + Vector3.new(0, 3, 0))
    end
    Notify("传送", "已传送到 " .. tostring(location.Name), "success")
end

function XJWBuildLocationUI(holder)
    holder.BackgroundTransparency = 0.15
    local search = make("TextBox", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.fromOffset(10, 8),
        BackgroundColor3 = Theme.bg,
        BackgroundTransparency = 0.15,
        Text = "",
        PlaceholderText = "搜索地点…",
        PlaceholderColor3 = Theme.subtext,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 5,
    }, holder)
    corner(search, 7)
    stroke(search, Theme.stroke, 1, 0.5)

    local list = make("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 230),
        Position = UDim2.fromOffset(10, 44),
        BackgroundColor3 = Theme.bg,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.accent,
        ScrollBarImageTransparency = 0.3,
        ZIndex = 5,
    }, holder)
    corner(list, 8)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
    }, list)
    make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    }, list)

    local order = 0
    local function refresh()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        order = 0
        local folder = ReplicatedStorage:FindFirstChild("Stuff")
        folder = folder and folder:FindFirstChild("Locations")
        if not folder then
            return
        end
        local query = string.lower(search.Text or "")
        local locations = folder:GetChildren()
        table.sort(locations, function(a, b)
            return a.Name < b.Name
        end)
        local count = 0
        for _, location in ipairs(locations) do
            if query == "" or string.lower(location.Name):find(query, 1, true) then
                if count >= 80 then
                    break
                end
                count = count + 1
                order = order + 1
                local row = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.surface,
                    BackgroundTransparency = 0.15,
                    Text = "  " .. location.Name,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = order,
                    ZIndex = 6,
                }, list)
                corner(row, 6)
                row.MouseEnter:Connect(function()
                    row.BackgroundTransparency = 0.5
                    row.TextColor3 = Theme.accent3
                end)
                row.MouseLeave:Connect(function()
                    row.BackgroundTransparency = 0.15
                    row.TextColor3 = Theme.text
                end)
                row.MouseButton1Click:Connect(function()
                    XJWTeleportToLocation(location)
                end)
            end
        end
        if count == 0 then
            local empty = make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Text = "没有匹配的地点",
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = Theme.subtext,
                LayoutOrder = 1,
            }, list)
            empty.Name = "EmptyLabel"
        end
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(refresh)
    end)
    refresh()
end

Section("地图标记")
_cb28 = function(value)

        XJWTeleportToMarker()
end
BT("传送到地图标记", function(v) _cb28(v) end)

Section("地点", "Stuff.Locations · 搜索 / 点击传送")
local buildHolder = make("Frame", {
    Size = UDim2.fromOffset(330, 340),
    Position = UDim2.new(0, 16, 1, -16),
    AnchorPoint = Vector2.new(0, 1),
    BackgroundColor3 = Theme.bg,
    BackgroundTransparency = 0.2,
    Visible = false,
    ZIndex = 60,
}, guiParent)
corner(buildHolder, 10)
stroke(buildHolder, Theme.stroke, 1, 0.3)
BT("显示地点面板", function()
    if buildHolder then
        buildHolder.Visible = not buildHolder.Visible
    end
end)
XJWBuildLocationUI(buildHolder)


local ShopPage = Window:Tab({ Title = "商店" })
Tab = ShopPage
Section("快速交互", "黑市 / 补给")
local shopInput = IN("shopInput", "关键字", "Buy / Purchase / Refill")
_cb29 = function(value)

        local _, _, root = getChar(LocalPlayer)
        if not root then
            return
        end
        local keyword = string.lower(shopInput.Value ~= "" and shopInput.Value or "buy")
        local hits = 0
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local combined = string.lower((descendant.Name or "") .. " " .. (descendant.ActionText or "") .. " " .. (descendant.ObjectText or ""))
                if combined:find(keyword, 1, true) then
                    local pos = objectPosition(descendant)
                    if pos and (pos - root.Position).Magnitude <= 45 then
                        firePrompt(descendant)
                        hits = hits + 1
                    end
                end
            end
        end
        Notify("商店", "已交互 " .. hits .. " 个提示", hits > 0 and "success" or "warn")
end
BT("一键购买附近", function(v) _cb29(v) end)
TG("autoRefill", "自动补给", "每 2 秒尝试 Refill / Ammo 提示", flagSetter)

task.spawn(function()
    while true do
        if Settings.autoRefill then
            local _, _, root = getChar(LocalPlayer)
            if root then
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        local combined = string.lower((descendant.Name or "") .. " " .. (descendant.ActionText or "") .. " " .. (descendant.ObjectText or ""))
                        if combined:find("refill", 1, true) or combined:find("ammo", 1, true) then
                            local pos = objectPosition(descendant)
                            if pos and (pos - root.Position).Magnitude <= 60 then
                                firePrompt(descendant)
                            end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)


local ConsolePage = Window:Tab({ Title = "控制台" })
Tab = ConsolePage
Section("运行日志", "圣奥里 输出")
local consoleHolder = make("Frame", {
    Size = UDim2.fromOffset(420, 300),
    Position = UDim2.new(1, -16, 1, -16),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Theme.bg,
    BackgroundTransparency = 0.22,
    Visible = false,
    ZIndex = 60,
}, guiParent)
corner(consoleHolder, 10)
stroke(consoleHolder, Theme.stroke, 1, 0.3)
local consoleRow = consoleHolder
consoleRow.BackgroundTransparency = 0.22
local consoleScroll = make("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -16),
    Position = UDim2.fromOffset(8, 8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.accent,
    ScrollBarImageTransparency = 0.4,
}, consoleRow)
make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
}, consoleScroll)

XJWConsoleOrder = 0
XJWConsoleCount = 0
local function consoleAppend(message, kind)
    XJWConsoleOrder = XJWConsoleOrder + 1
    XJWConsoleCount = XJWConsoleCount + 1
    local color = Theme.subtext
    if kind == "success" then
        color = Theme.green
    elseif kind == "warn" then
        color = Theme.amber
    elseif kind == "error" then
        color = Theme.red
    elseif kind == "info" then
        color = Theme.accent3
    end
    local label = make("TextLabel", {
        Size = UDim2.new(1, -6, 0, 14),
        BackgroundTransparency = 1,
        Text = "[" .. os.date("%H:%M:%S") .. "]  " .. message,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = XJWConsoleOrder,
    }, consoleScroll)
    if XJWConsoleCount > 90 then
        local oldest = consoleScroll:FindFirstChildWhichIsA("TextLabel")
        if oldest then
            oldest:Destroy()
            XJWConsoleCount = XJWConsoleCount - 1
        end
    end
    task.defer(function()
        consoleScroll.CanvasPosition = Vector2.new(0, math.max(consoleScroll.AbsoluteCanvasSize.Y - consoleScroll.AbsoluteSize.Y, 0))
    end)
end
LogSink = consoleAppend

_cb30 = function(value)

        for _, child in ipairs(consoleScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        XJWConsoleCount = 0
end
BT("清空日志", function(v) _cb30(v) end)
BT("显示日志面板", function()
    if consoleHolder then
        consoleHolder.Visible = not consoleHolder.Visible
    end
end)


local SettingsPage = Window:Tab({ Title = "设置" })
Tab = SettingsPage
Section("界面", "XJW 专属样式")
SL("uiScale", "界面缩放", 0.6, 1.2, 0.05, 1, "", 2, "", function(v) Settings.uiScale = v pcall(function() Window:SetUIScale(v) end) end)
KB("menuKey", "菜单按键", "RightShift", "Toggle", function(v) if v then Window:Toggle() end end)
_cb31 = function(value)

        XJWQuickSetEnabled(value)
end
TG("quickHud", "手机快捷面板", "屏幕边缘悬浮快捷开关", function(v) _cb31(v) end)
Section("配置", "保存与加载")
BT("保存配置", saveConfig)
BT("加载配置", loadConfig)
BT("卸载 圣奥里", function() local fn = getgenv().XJWScript and getgenv().XJWScript.Unload if fn then fn() end end)
LB("圣奥里  v1.0 · by XJW  ·  紫黑流光")


XJWQuick = {
    Enabled = false,
    Visible = true,
    Expanded = false,
    Items = {},
    Button = nil,
    Panel = nil,
}
QuickButton = nil
QuickPanel = nil
QuickGrid = nil

local function XJWQuickRefresh()
    if not XJWQuick or not XJWQuick.Items then
        return
    end
    for _, item in ipairs(XJWQuick.Items) do
        local visual = item.Visual
        if visual then
            local active = item.type == "toggle" and Settings[item.key] == true
            if active then
                visual.fill.BackgroundTransparency = 0.75
                visual.stroke.Color = Theme.accent
                visual.stroke.Transparency = 0.15
                visual.glyph.TextColor3 = Theme.accent3
                visual.label.TextColor3 = Theme.text
                visual.dot.BackgroundColor3 = Theme.accent3
                visual.dot.BackgroundTransparency = 0
            else
                visual.fill.BackgroundTransparency = 1
                visual.stroke.Color = Theme.stroke
                visual.stroke.Transparency = 0.45
                visual.glyph.TextColor3 = item.type == "action" and Theme.accent3 or Theme.subtext
                visual.label.TextColor3 = item.type == "action" and Theme.text or Theme.subtext
                visual.dot.BackgroundColor3 = item.type == "action" and Theme.accent or Theme.stroke
                visual.dot.BackgroundTransparency = item.type == "action" and 0.2 or 0.55
            end
        end
    end
end

local function XJWQuickExpand(expand)
    if not XJWQuick or not QuickPanel then
        return
    end
    XJWQuick.Expanded = expand and true or false
    if XJWQuick.Expanded then
        if QuickButton then
            QuickButton.Visible = false
        end
    elseif QuickButton then
        QuickButton.Visible = true
    end
    if not XJWQuick.Enabled or not XJWQuick.Visible then
        if QuickPanel then
            QuickPanel.Visible = false
        end
        if QuickButton then
            QuickButton.Visible = false
        end
        return
    end
    if QuickPanel then
        QuickPanel.Visible = XJWQuick.Expanded
    end
    if QuickButton then
        QuickButton.Visible = not XJWQuick.Expanded
    end
    if XJWQuick.Expanded and QuickPanel then
        local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
        local gridHeight = math.min(374, math.max(180, viewport.Y - 190))
        if QuickGrid then
            QuickGrid.Size = UDim2.fromOffset(186, gridHeight)
        end
        QuickPanel.Size = UDim2.fromOffset(206, gridHeight + 58)
        local absolute = QuickPanel.AbsolutePosition
        local size = QuickPanel.AbsoluteSize
        QuickPanel.Position = UDim2.fromOffset(
            math.clamp(absolute.X, 4, math.max(4, viewport.X - size.X - 4)),
            math.clamp(absolute.Y, 4, math.max(4, viewport.Y - size.Y - 4))
        )
    end
end

local function XJWQuickSetVisible(visible)
    if not XJWQuick or not QuickPanel then
        return
    end
    XJWQuick.Visible = visible and true or false
    local show = XJWQuick.Visible and XJWQuick.Enabled
    if QuickPanel then
        QuickPanel.Visible = show and XJWQuick.Expanded
    end
    if QuickButton then
        QuickButton.Visible = show and not XJWQuick.Expanded
    end
end

local function XJWQuickSetEnabled(enabled)
    if not XJWQuick then
        return
    end
    if not QuickPanel then
        Settings.quickHud = enabled and true or false
        return
    end
    XJWQuick.Enabled = enabled and true or false
    Settings.quickHud = XJWQuick.Enabled
    if not XJWQuick.Enabled then
        XJWQuick.Expanded = false
    end
    if XJWQuick.Enabled and XJWQuick.Visible then
        if QuickPanel then
            QuickPanel.Visible = XJWQuick.Expanded
        end
        if QuickButton then
            QuickButton.Visible = not XJWQuick.Expanded
        end
    else
        if QuickPanel then
            QuickPanel.Visible = false
        end
        if QuickButton then
            QuickButton.Visible = false
        end
    end
end

local function XJWQuickBuild()
    if not guiParent then
        return
    end
    local quickViewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
    local quickGridHeight = math.min(374, math.max(180, quickViewport.Y - 190))
    local quickPanelHeight = quickGridHeight + 58

    QuickButton = make("TextButton", {
        Name = "XJWQuickButton",
        Size = UDim2.fromOffset(54, 54),
        Position = UDim2.fromOffset(Settings.quickButtonX or 12, Settings.quickButtonY or 250),
        BackgroundColor3 = Theme.panel,
        Text = "Q",
        Font = Enum.Font.GothamBlack,
        TextSize = 21,
        TextColor3 = Theme.accent3,
        AutoButtonColor = false,
        ZIndex = 140,
    }, guiParent)
    corner(QuickButton, 27)
    stroke(QuickButton, Theme.accent, 1.6, 0.2)
    make("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(1, -13, 0, 9),
        BackgroundColor3 = Theme.accent3,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, QuickButton)
    corner(QuickButton:FindFirstChildOfClass("Frame"), 4)

    QuickPanel = make("Frame", {
        Name = "XJWQuickPanel",
        Size = UDim2.fromOffset(206, quickPanelHeight),
        Position = UDim2.fromOffset(Settings.quickPanelX or 12, Settings.quickPanelY or 74),
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 141,
    }, guiParent)
    corner(QuickPanel, 16)
    stroke(QuickPanel, Theme.accent, 1.4, 0.2)

    local header = make("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.bg,
        BorderSizePixel = 0,
        ZIndex = 142,
    }, QuickPanel)
    local title = text(header, "YING 快捷", 13, Theme.text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(12, 9)
    title.Size = UDim2.fromOffset(104, 20)

    local menuButton = make("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -56, 0, 8),
        BackgroundTransparency = 1,
        Text = "☰",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.subtext,
        AutoButtonColor = false,
        ZIndex = 144,
    }, header)
    local collapseButton = make("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -30, 0, 8),
        BackgroundTransparency = 1,
        Text = "−",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.subtext,
        AutoButtonColor = false,
        ZIndex = 144,
    }, header)
    make("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.fromOffset(10, 37),
        BackgroundColor3 = Theme.stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 142,
    }, QuickPanel)

    QuickGrid = make("ScrollingFrame", {
        Size = UDim2.fromOffset(186, quickGridHeight),
        Position = UDim2.fromOffset(10, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 374),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.accent,
        ScrollBarImageTransparency = 0.2,
        ClipsDescendants = true,
        ZIndex = 142,
    }, QuickPanel)
    make("UIGridLayout", {
        CellSize = UDim2.fromOffset(90, 56),
        CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, QuickGrid)

    local items = {
        { type = "toggle", key = "ghost", label = "隐身", glyph = "◍" },
        { type = "action", key = "ghostExpose", label = "现身", glyph = "◐", action = function() XJWGhostExpose(Settings.ghostExposeTime) end },
        { type = "action", key = "blink", label = "Blink", glyph = "►", action = function() XJWBlink() end },
        { type = "toggle", key = "vehicleFly", label = "载具飞行", glyph = "✈" },
        { type = "toggle", key = "aura", label = "光环", glyph = "✦" },
        { type = "toggle", key = "aim", label = "自瞄", glyph = "◎" },
        { type = "toggle", key = "silent", label = "静默", glyph = "◇" },
        { type = "toggle", key = "esp", label = "ESP", glyph = "▣" },
        { type = "toggle", key = "fly", label = "飞行", glyph = "▲" },
        { type = "toggle", key = "noclip", label = "穿墙", glyph = "▫" },
        { type = "action", key = "mapMarker", label = "地图标记", glyph = "⌖", action = function() XJWTeleportToMarker() end },
        { type = "action", key = "bringVehicle", label = "召载具", glyph = "▼", action = function() XJWBringVehicleToMe() end },
    }

    for index, item in ipairs(items) do
        local tile = make("Frame", {
            Size = UDim2.fromOffset(90, 56),
            BackgroundColor3 = Theme.surface,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            LayoutOrder = index,
            ZIndex = 143,
        }, QuickGrid)
        corner(tile, 10)
        local tileStroke = stroke(tile, Theme.stroke, 1, 0.45)
        local fill = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Theme.accent2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 1,
        }, tile)
        corner(fill, 10)
        local glyph = text(tile, item.glyph, 16, Theme.subtext, Enum.Font.GothamBold)
        glyph.Position = UDim2.fromOffset(9, 5)
        glyph.Size = UDim2.fromOffset(20, 18)
        glyph.ZIndex = 2
        local label = text(tile, item.label, 11, Theme.subtext, Enum.Font.GothamMedium)
        label.Position = UDim2.fromOffset(9, 27)
        label.Size = UDim2.new(1, -14, 0, 16)
        label.ZIndex = 2
        local dot = make("Frame", {
            Size = UDim2.fromOffset(7, 7),
            Position = UDim2.new(1, -15, 0, 9),
            BackgroundColor3 = Theme.stroke,
            BackgroundTransparency = 0.55,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, tile)
        corner(dot, 4)
        local hit = make("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 4,
        }, tile)
        hit.MouseButton1Click:Connect(function()
            if item.type == "action" then
                if item.action then
                    pcall(item.action)
                end
                TweenService:Create(fill, TweenInfo.new(0.12), { BackgroundTransparency = 0.55 }):Play()
                task.delay(0.18, function()
                    if fill.Parent then
                        XJWQuickRefresh()
                    end
                end)
            else
                local control = ConfigRegistry[item.key]
                local newValue = not (Settings[item.key] == true)
                if control then
                    control:Set(newValue, true)
                else
                    Settings[item.key] = newValue
                end
                XJWQuickRefresh()
            end
        end)
        item.Visual = {
            tile = tile,
            stroke = tileStroke,
            fill = fill,
            glyph = glyph,
            label = label,
            dot = dot,
        }
        table.insert(XJWQuick.Items, item)
    end

    local function bindDrag(frame, handle, onTap, xKey, yKey)
        local dragging = false
        local moved = false
        local startInput = nil
        local startPosition = nil
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                startInput = input.Position
                startPosition = frame.Position
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if connection then
                            connection:Disconnect()
                        end
                        local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
                        local absolute = frame.AbsolutePosition
                        local size = frame.AbsoluteSize
                        local clampedX = math.clamp(absolute.X, 4, math.max(4, viewport.X - size.X - 4))
                        local clampedY = math.clamp(absolute.Y, 4, math.max(4, viewport.Y - size.Y - 4))
                        frame.Position = UDim2.fromOffset(clampedX, clampedY)
                        if xKey then
                            Settings[xKey] = clampedX
                        end
                        if yKey then
                            Settings[yKey] = clampedY
                        end
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startInput
                if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
                    moved = true
                end
                frame.Position = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )
            end
        end)
        if onTap then
            handle.MouseButton1Click:Connect(function()
                if not moved then
                    onTap()
                end
            end)
        end
    end

    bindDrag(QuickButton, QuickButton, function()
        XJWQuickExpand(true)
        XJWQuickRefresh()
    end, "quickButtonX", "quickButtonY")
    bindDrag(QuickPanel, header, nil, "quickPanelX", "quickPanelY")
    collapseButton.MouseButton1Click:Connect(function()
        XJWQuickExpand(false)
    end)
    menuButton.MouseButton1Click:Connect(function()
        XJWQuickExpand(false)
    end)

    XJWQuick.Button = QuickButton
    XJWQuick.Panel = QuickPanel
    XJWQuick.Grid = QuickGrid
    XJWQuickRefresh()
    XJWQuickSetEnabled(Settings.quickHud)
end

XJWQuickBuild()



local function Unload()
    if XJWQuick then
        XJWQuick.Enabled = false
        if QuickPanel then
            QuickPanel.Visible = false
        end
        if QuickButton then
            QuickButton.Visible = false
        end
    end
    Settings.autoMoney = false
    Settings.farmer = false
    Settings.taxi = false
    Settings.bus = false
    Settings.golf = false
    Settings.autoMission = false
    Settings.autoRefill = false
    Settings.autoAtm = false
    Settings.autoHack = false
    Settings.policeCuff = false
    Settings.policeTp = false
    Settings.aura = false
    Settings.ragebot = false
    Settings.vehicleFly = false
    Settings.blink = false
    Settings.fly = false
    pcall(clearConnections)
    pcall(clearAllHitboxes)
    pcall(function()
        if rangePart then
            rangePart:Destroy()
            rangePart = nil
        end
    end)
    pcall(setAutoHack, false)
    pcall(stopFly)
    pcall(clearVehicleForce)
    pcall(XJWClearVehicleFly)
    for player in pairs(EspTrackers) do
        pcall(destroyTracker, player)
    end
    for model in pairs(XJWVehicle.trackers) do
        pcall(XJWDestroyVehicleTracker, model)
    end
    pcall(function()
        Settings.ghost = false
        setGhost(false)
    end)
    pcall(setNoclip, false)
    pcall(function()
        if ghostGui then
            ghostGui:Destroy()
        end
    end)
    pcall(function()
        EspFolder:Destroy()
    end)
    pcall(function()
        for _, line in ipairs(Draw.cross) do
            line:Remove()
        end
        if Draw.fov then
            Draw.fov:Remove()
        end
        if Draw.tracer then
            Draw.tracer:Remove()
        end
        if Draw.silentFov then
            Draw.silentFov:Remove()
        end
        if Draw.silentLine then
            Draw.silentLine:Remove()
        end
    end)
    pcall(function()
        if QuickButton then
            QuickButton:Destroy()
        end
        if QuickPanel then
            QuickPanel:Destroy()
        end
    end)
    pcall(function()
        if consoleHolder then
            consoleHolder:Destroy()
        end
        if buildHolder then
            buildHolder:Destroy()
        end
    end)
    pcall(function()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end)
    getgenv().XJWScriptLoaded = false
    getgenv().XJWScript = nil
end

getgenv().XJWSettings = Settings
getgenv().XJWConfig = ConfigRegistry
getgenv().XJWScript = {
    Version = "1.0",
    Author = "XJW",
    Name = "圣奥里",
    Unload = Unload,
}

task.delay(0.7, function()
    Notify("圣奥里", "加载完成 · 按 RightShift 打开 / 关闭", "success")
end)

return getgenv().XJWScript
