local LINK = "https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"
local body = game:HttpGet(LINK)
local fn = loadstring(body)
local lib = fn and fn()
if type(lib) ~= "table" or type(lib.CreateWindow) ~= "function" then return end
local WindUI = lib
local LPlr = game:GetService("Players").LocalPlayer

local function cleanupOldESP()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			local toRemove = {}
			for _, child in pairs(obj:GetChildren()) do
				if
					child.Name == "BaloksxinESP"
					or child.Name == "Baloksxin_Text_ESP"
					or child.Name == "BKUCreator_Highlight_ESP"
					or child.Name == "BKUCreator_Text_ESP"
					or child.Name == "BKU_PlayerName_ESP"
					or child.Name == "Liquid_Highlight_ESP"
					or child.Name == "Liquid_Text_ESP"
				then
					table.insert(toRemove, child)
				end
			end
			for _, child in ipairs(toRemove) do
				child:Destroy()
			end
		end
	end
end

local Players = game:GetService("Players")
local RS, UIS, Light = game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Lighting")
local Cam = workspace.CurrentCamera
local initSpeed = 16
local bodyConnection = nil

if LPlr.Character and LPlr.Character:FindFirstChild("Humanoid") then
	initSpeed = LPlr.Character.Humanoid.WalkSpeed
end

local Config = {
	Speed = initSpeed,
	FOV = Cam.FieldOfView,
	SpeedEn = false,
	FOVEn = false,
	InfJump = false,
	Noclip = false,
	FreezeSelf = false,
	AnchorOnly = false,
	NightVis = false,
	InfStamina = false,
	ThirdPerson = false,
	AutoGold = false,
	ScrapESP = false,
	MonkeyESP = false,
	RecyclerESP = false,
	PlayerESP = false,
	ShowNames = false,
	ShowTracers = false,
	PlayerHighlight = false,
	RainbowESP = false,
	ShowDistance = false,
	TracerFromTop = false,
	CandyRainbow = false,
	CandyShowDistance = false,
	MonsterRainbow = false,
	MonsterShowDistance = false,
	ScrapRainbow = false,
	ScrapShowDistance = false,
	RecyclerRainbow = false,
	RecyclerShowDistance = false,
	LiquidRainbow = false,
	LiquidShowDistance = false,
	ExpandCollision = false,
	DisableGusBlind = false,
	DisableDusAura = false,
	DisableKusBlur = false,
	DisableJohnBlur = false,
	DisableBloodmanRed = false,
	ShowCollisionBox = false,
	CollisionSize = 8,
	AutoAimBloodMan = false,
	InstantInteract = false,
	HideBodies = false,
	DisableJumpscareAnim = false,
	DeathEffectEn = false,
	DisableWalkTo = false,
	LiquidESP = false,
	CandyESP = false,
}

local function updateDamageScriptState()
	local playerScripts = LPlr:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return
	end
	for _, child in pairs(playerScripts:GetChildren()) do
		if child.Name == "Damage" and child:IsA("LocalScript") then
			child.Enabled = not Config.DisableWalkTo
		end
	end
end

local origNamecall
local inNamecall = false
local controlledHumanoids = {}

local function isPlayerCharacter(model)
	if not model then
		return false
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character == model then
			return true
		end
	end
	return false
end

local function updateControlledHumanoids()
	table.clear(controlledHumanoids)
	local charHum = LPlr.Character and LPlr.Character:FindFirstChildOfClass("Humanoid")
	if charHum then
		controlledHumanoids[charHum] = true
	end
	local cam = workspace.CurrentCamera
	local subject = cam and cam.CameraSubject
	if subject then
		local hum
		if subject.ClassName == "Humanoid" then
			hum = subject
		else
			local model = subject:IsA("Model") and subject or subject:FindFirstAncestorWhichIsA("Model")
			hum = model and model:FindFirstChildOfClass("Humanoid")
		end
		if hum and not isPlayerCharacter(hum.Parent) then
			controlledHumanoids[hum] = true
		end
	end
end

local function isControlledHumanoid(h)
	return h and controlledHumanoids[h] == true
end

origNamecall = hookmetamethod(game, "__namecall", function(...)
	if not Config.DisableWalkTo or inNamecall then
		return origNamecall(...)
	end
	inNamecall = true
	local method = getnamecallmethod()
	local self = (...)
	inNamecall = false
	if method == "MoveTo" and isControlledHumanoid(self) then
		return
	end
	return origNamecall(...)
end)

local walkToHooked = {}
local walkToResetting = {}
local function hookWalkTo(humanoid)
	if walkToHooked[humanoid] then
		return
	end
	walkToHooked[humanoid] = true
	walkToResetting[humanoid] = false
	humanoid:GetPropertyChangedSignal("WalkToPoint"):Connect(function()
		if not Config.DisableWalkTo or walkToResetting[humanoid] then
			return
		end
		if not isControlledHumanoid(humanoid) then
			return
		end
		walkToResetting[humanoid] = true
		local root = humanoid.RootPart or (humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart"))
		humanoid.WalkToPoint = root and root.Position or Vector3.new()
		humanoid.WalkToPart = nil
		walkToResetting[humanoid] = false
	end)
	humanoid:GetPropertyChangedSignal("WalkToPart"):Connect(function()
		if not Config.DisableWalkTo or walkToResetting[humanoid] then
			return
		end
		if not isControlledHumanoid(humanoid) then
			return
		end
		walkToResetting[humanoid] = true
		humanoid.WalkToPart = nil
		walkToResetting[humanoid] = false
	end)
end

task.spawn(function()
	while true do
		updateControlledHumanoids()
		for hum in pairs(controlledHumanoids) do
			hookWalkTo(hum)
		end
		task.wait(1)
	end
end)

local Window = WindUI:CreateWindow({
	Title = "致命猴子",
	Author = "XJW",
	Icon = "sparkles",
	Folder = "BKUFatalMonkey",
	Size = UDim2.fromOffset(560, 334),
	Theme = "Dark",
	HideSearchBar = false,
})

local disabledJumpscareScripts = {}

local function toggleJumpscareAnim(disable)
	local playerScripts = LPlr:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return
	end
	for _, v in pairs(playerScripts:GetDescendants()) do
		if v:IsA("LocalScript") then
			local nameLower = string.lower(v.Name)
			if string.find(nameLower, "play") and string.find(nameLower, "jumpscareanim") then
				if disable then
					if v.Disabled == false then
						v.Disabled = true
						disabledJumpscareScripts[v] = true
					end
				else
					if disabledJumpscareScripts[v] then
						v.Disabled = false
						disabledJumpscareScripts[v] = nil
					end
				end
			end
		end
	end
end

local activeBoneBloods = {}
task.spawn(function()
	while true do
		task.wait(0.05)
		for i = #activeBoneBloods, 1, -1 do
			local item = activeBoneBloods[i]
			if item.Part and item.Part.Parent and item.Target and item.Target.Parent then
				if item.IsBone then
					item.Part.CFrame = item.Target.WorldCFrame * item.Offset
				end
			else
				table.remove(activeBoneBloods, i)
			end
		end
	end
end)

local function setupPlayerDeathEffect(player)
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		local rootPart = character:WaitForChild("HumanoidRootPart", 5)
		if not humanoid or not rootPart then
			return
		end

		humanoid.Died:Connect(function()
			if not Config.DeathEffectEn then
				return
			end
			local deathPosition = rootPart.Position

			local explosion = Instance.new("Explosion")
			explosion.Position = deathPosition
			explosion.BlastRadius = 15
			explosion.BlastPressure = 0
			explosion.DestroyJointRadiusPercent = 0
			explosion.Parent = workspace

			task.delay(0.15, function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local filterList = { character }
				for _, desc in ipairs(character:GetDescendants()) do
					table.insert(filterList, desc)
				end

				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Exclude
				overlapParams.FilterDescendantsInstances = filterList

				local nearbyParts = workspace:GetPartBoundsInRadius(deathPosition, 12, overlapParams)
				for _, part in ipairs(nearbyParts) do
					if part.Name == "HumanoidRootPart" or part.Name:lower() == "camera" then
						table.insert(filterList, part)
					end
				end

				raycastParams.FilterDescendantsInstances = filterList
				raycastParams.IgnoreWater = true
				local centerPos = deathPosition + Vector3.new(0, 1, 0)

				for i = 1, 30 do
					local baseAngle = (i / 30) * math.pi * 2
					local angle = baseAngle + (math.random() - 0.5) * 0.3
					local radius = math.random(5, 16)
					local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))

					local startPos = centerPos + direction * 1.0
					local targetPos = centerPos
						+ Vector3.new(direction.X * radius, math.random(-3, 4), direction.Z * radius)

					local rayResult = workspace:Raycast(startPos, targetPos - startPos, raycastParams)
					if rayResult and rayResult.Instance then
						local hitPart = rayResult.Instance
						if
							hitPart:IsA("BasePart")
							and not hitPart:IsDescendantOf(character)
							and hitPart.Name:lower() ~= "camera"
							and hitPart ~= workspace.Terrain
						then
							local hitPos = rayResult.Position
							local hitNormal = rayResult.Normal

							local bloodMark = Instance.new("Part")
							bloodMark.Size = Vector3.new(math.random(6, 18) / 10, 0.04, math.random(6, 18) / 10)
							bloodMark.Color = Color3.fromRGB(120 + math.random(-20, 20), 0, 0)
							bloodMark.Material = Enum.Material.SmoothPlastic
							bloodMark.Anchored = false
							bloodMark.Massless = true
							bloodMark.CanCollide = false
							bloodMark.CastShadow = false

							local mesh = Instance.new("SpecialMesh")
							mesh.MeshType = Enum.MeshType.Sphere
							mesh.Scale = Vector3.new(1 + math.random(-3, 3) / 10, 0.15, 1 + math.random(-3, 3) / 10)
							mesh.Parent = bloodMark

							bloodMark.CFrame = CFrame.new(
								hitPos + hitNormal * 0.02,
								hitPos + hitNormal * 0.02 + hitNormal
							) * CFrame.Angles(math.pi / 2, math.random() * math.pi * 2, math.random() * 0.3)
							bloodMark.Parent = workspace

							local weld = Instance.new("WeldConstraint")
							weld.Part0 = bloodMark
							weld.Part1 = hitPart
							weld.Parent = bloodMark

							task.delay(45, function()
								if bloodMark and bloodMark.Parent then
									bloodMark:Destroy()
								end
							end)
						end
					end
				end
			end)
		end)
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

local RotationConfig = { Enabled = false, Speed = 1, Direction = 1 }
local Orig = {
	FOV = Cam.FieldOfView,
	Bright = Light.Brightness,
	FogEnd = Light.FogEnd,
	FogStart = Light.FogStart,
	Ambient = Light.Ambient,
	Clock = Light.ClockTime,
	Speed = initSpeed,
}

local rotationConnection = nil
local originalNoclipCollisions = {}
local cachedAnimationSpeeds = {}

local espGui = Instance.new("ScreenGui")
espGui.Name = "BKU_PlayerESP_Gui"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true

pcall(function()
	espGui.Parent = game:GetService("CoreGui")
end)
if not espGui.Parent then
	espGui.Parent = LPlr:WaitForChild("PlayerGui")
end

local ESPCache = {}
local MonkeyESPCache = {}
local ScrapESPCache = {}
local RecyclerESPCache = {}
local LiquidESPCache = {}
local CandyESPCache = {}
local noclipPartsCache = {}
local lastNightVis = false
local lastSpeedApplied = nil
local lastFOVApplied = nil
local autoGoldTarget = nil
local autoGoldScanAcc = 0

local function removePlayerESP(player)
	if ESPCache[player] then
		if ESPCache[player].Line then
			ESPCache[player].Line:Destroy()
		end
		if ESPCache[player].Billboard then
			ESPCache[player].Billboard:Destroy()
		end
		ESPCache[player] = nil
	end
end

local function findTargetPart(char)
	return char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("LowerTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("Head")
		or char:FindFirstChildOfClass("BasePart")
end

local function setupPlayerESP(player)
	removePlayerESP(player)
	if player == LPlr then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local targetTorso = findTargetPart(char)
	if not targetTorso then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BKU_PlayerName_ESP"
	billboard.Size = UDim2.new(0, 180, 0, 40)
	billboard.AlwaysOnTop = true
	billboard.Adornee = targetTorso
	billboard.Enabled = false

	local label = Instance.new("TextLabel")
	label.Name = "NameLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = player.DisplayName
	label.TextColor3 = (player.Team and player.TeamColor.Color) or Color3.fromRGB(0, 255, 0)
	label.TextSize = 14
	label.Font = Enum.Font.SourceSansBold
	label.TextStrokeTransparency = 0
	label.Parent = billboard
	billboard.Parent = char

	local line = Instance.new("Frame")
	line.Name = "Tracer_" .. player.Name
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	line.Visible = false
	line.Parent = espGui

	ESPCache[player] = { Billboard = billboard, Label = label, Line = line }
end

local function setupPlayerESPWithRetry(player, maxAttempts)
	maxAttempts = maxAttempts or 5
	task.spawn(function()
		for i = 1, maxAttempts do
			if not player or not player.Parent then
				return
			end
			setupPlayerESP(player)
			if ESPCache[player] then
				return
			end
			task.wait(0.5 + i * 0.2)
		end
	end)
end

local cachedHumanoidModels = {}
local function rebuildHumanoidCache()
	table.clear(cachedHumanoidModels)
	for _, desc in pairs(workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
			table.insert(cachedHumanoidModels, desc)
		end
	end
end
rebuildHumanoidCache()
task.spawn(function()
	while true do
		rebuildHumanoidCache()
		task.wait(3)
	end
end)
workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") then
		table.insert(cachedHumanoidModels, desc)
	elseif desc:IsA("Humanoid") and desc.Parent and desc.Parent:IsA("Model") then
		table.insert(cachedHumanoidModels, desc.Parent)
	end
end)

local cachedBloodMan = nil
task.spawn(function()
	while true do
		cachedBloodMan = nil
		for _, model in ipairs(cachedHumanoidModels) do
			if model.Name == "BloodMan" then
				cachedBloodMan = model
				break
			end
		end
		task.wait(1)
	end
end)

local function ApplyBKUCreatorESP(model)
	if model:IsA("Model") and model.Name == "baloksxin_real" then
		if not model:FindFirstChild("BKUCreator_Highlight_ESP") then
			local hl = Instance.new("Highlight")
			hl.Name = "BKUCreator_Highlight_ESP"
			hl.FillColor = Color3.fromRGB(0, 120, 255)
			hl.FillTransparency = 1
			hl.OutlineColor = Color3.fromRGB(0, 120, 255)
			hl.OutlineTransparency = 0
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = model
		end
		if not model:FindFirstChild("BKUCreator_Text_ESP") then
			local targetPart = model.PrimaryPart
				or model:FindFirstChild("HumanoidRootPart")
				or model:FindFirstChild("Head")
				or model:FindFirstChildOfClass("BasePart")
			if targetPart then
				local billboard = Instance.new("BillboardGui")
				billboard.Name = "BKUCreator_Text_ESP"
				billboard.Size = UDim2.new(0, 180, 0, 50)
				billboard.AlwaysOnTop = true
				billboard.ExtentsOffset = Vector3.new(0, 3.5, 0)
				billboard.Adornee = targetPart
				billboard.Parent = model
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = "BKU创作者"
				label.TextColor3 = Color3.fromRGB(0, 120, 255)
				label.TextSize = 16
				label.Font = Enum.Font.SourceSansBold
				label.TextStrokeTransparency = 0
				label.Parent = billboard
			end
		end
	end
end

local function setCharacterAnimationFrozen(char, frozen)
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			if frozen then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					cachedAnimationSpeeds[track] = track.Speed
					track:AdjustSpeed(0)
				end
			else
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					if cachedAnimationSpeeds[track] then
						track:AdjustSpeed(cachedAnimationSpeeds[track])
					else
						track:AdjustSpeed(1)
					end
				end
				table.clear(cachedAnimationSpeeds)
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end
end

local function startRotation()
	if rotationConnection then
		rotationConnection:Disconnect()
		rotationConnection = nil
	end
	if not RotationConfig.Enabled then
		if LPlr.Character then
			local humanoid = LPlr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.AutoRotate = true
			end
		end
		return
	end
	if LPlr.Character then
		local humanoid = LPlr.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.AutoRotate = false
		end
	end
	rotationConnection = RS.RenderStepped:Connect(function()
		if not RotationConfig.Enabled then
			return
		end
		local char = LPlr.Character
		if not char then
			return
		end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end
		local rotationAngle = math.rad(RotationConfig.Speed * RotationConfig.Direction)
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, rotationAngle, 0)
	end)
end

local antiSlipperyEnabled = false
local antiSlipperyConnection = nil

local function antiSlippery()
	local char = LPlr.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then
		return
	end
	local currentVel = rootPart.AssemblyLinearVelocity
	local moveDir = humanoid.MoveDirection
	local walkSpeed = humanoid.WalkSpeed
	if walkSpeed <= 0 or walkSpeed > 200 then
		return
	end
	if moveDir.Magnitude < 0.05 then
		if math.abs(currentVel.X) > 0.01 or math.abs(currentVel.Z) > 0.01 then
			rootPart.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
		end
	else
		local targetHorizontal = moveDir.Unit * walkSpeed
		rootPart.AssemblyLinearVelocity = Vector3.new(targetHorizontal.X, currentVel.Y, targetHorizontal.Z)
	end
end

local function enableAntiSlippery()
	if antiSlipperyEnabled then
		return
	end
	antiSlipperyConnection = RS.Heartbeat:Connect(antiSlippery)
	antiSlipperyEnabled = true
end

local function disableAntiSlippery()
	if not antiSlipperyEnabled then
		return
	end
	if antiSlipperyConnection then
		antiSlipperyConnection:Disconnect()
		antiSlipperyConnection = nil
	end
	antiSlipperyEnabled = false
end

local _promptListener = nil
local _promptFixConnections = {}
local _promptOriginalDurations = {}

local function applyInstantInteract(state)
	Config.InstantInteract = state

	if _promptListener then
		_promptListener:Disconnect()
		_promptListener = nil
	end
	for _, conn in ipairs(_promptFixConnections) do
		conn:Disconnect()
	end
	table.clear(_promptFixConnections)

	local function fixPrompt(prompt)
		if not prompt:IsA("ProximityPrompt") then
			return
		end

		if state then
			if not _promptOriginalDurations[prompt] then
				_promptOriginalDurations[prompt] = prompt.HoldDuration
			end
			prompt.HoldDuration = 0

			local conn = prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
				if prompt.HoldDuration ~= 0 then
					prompt.HoldDuration = 0
				end
			end)
			table.insert(_promptFixConnections, conn)
		else
			local original = _promptOriginalDurations[prompt]
			if original ~= nil then
				prompt.HoldDuration = original
				_promptOriginalDurations[prompt] = nil
			end
		end
	end

	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			fixPrompt(obj)
		end
	end

	if state then
		_promptListener = game.DescendantAdded:Connect(function(child)
			if child:IsA("ProximityPrompt") then
				fixPrompt(child)
			end
		end)
	end
end

local fovConnection = nil
local function LockFOV()
	if fovConnection then
		fovConnection:Disconnect()
	end
	if Cam then
		fovConnection = Cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			if Config.FOVEn and Cam.FieldOfView ~= Config.FOV then
				Cam.FieldOfView = Config.FOV
			end
		end)
	end
end

local ItemPriority = {
	["Screw"] = 1,
	["Pipe"] = 1,
	["Bucket"] = 1,
	["Baterry"] = 1,
	["Battery"] = 1,
	["Gear"] = 1,
	["Cleaner"] = 1,
	["Emerald"] = 14,
	["Amethyst"] = 10,
	["AmethystCrystal"] = 10,
	["Diamond"] = 7,
	["Gold"] = 2,
	["Copper"] = 1,
	["Meat"] = 3,
}

local function IsValidGroundItem(obj)
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do
		local p = allPlayers[i]
		if p.Character and obj:IsDescendantOf(p.Character) then
			return false
		end
		local bp = p:FindFirstChild("Backpack")
		if bp and obj:IsDescendantOf(bp) then
			return false
		end
	end

	if obj:IsA("BasePart") then
		if obj.Transparency >= 0.99 or obj.Position.Y < -500 then
			return false
		end
	else
		local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
		if targetPart then
			if targetPart.Transparency >= 0.99 or targetPart.Position.Y < -500 then
				return false
			end
		else
			if obj:GetPivot().Position.Y < -500 then
				return false
			end
		end
	end
	return true
end

local scrapsFolder = workspace:FindFirstChild("Scraps")

local function IsScrapItem(v)
	if not (v:IsA("BasePart") or v:IsA("Model")) then
		return false
	end
	if ItemPriority[v.Name] then
		return true
	end
	if scrapsFolder and v:IsDescendantOf(scrapsFolder) then
		return true
	end
	return false
end

local function CreateScrapESP(obj)
	local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
	if not targetPart or not targetPart:IsA("BasePart") then
		return
	end

	if not obj:FindFirstChild("Scrap_Box_ESP") then
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "Scrap_Box_ESP"
		box.Color3 = Color3.fromRGB(0, 255, 100)
		box.Transparency = 0.5
		box.Size = targetPart.Size
		box.Adornee = targetPart
		box.AlwaysOnTop = true
		box.ZIndex = 0
		box.Parent = obj
	end
	if not obj:FindFirstChild("Scrap_Text_ESP") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Scrap_Text_ESP"
		billboard.Size = UDim2.new(0, 150, 0, 40)
		billboard.AlwaysOnTop = true
		billboard.ExtentsOffset = Vector3.new(0, 2, 0)
		billboard.Adornee = targetPart
		billboard.Parent = obj
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = obj.Name
		label.TextColor3 = Color3.fromRGB(0, 255, 100)
		label.TextSize = 14
		label.Font = Enum.Font.SourceSansBold
		label.TextStrokeTransparency = 0
		label.Parent = billboard
	end
	local box = obj:FindFirstChild("Scrap_Box_ESP")
	if box then
		ScrapESPCache[box] = obj
	end
end

local function RemoveScrapESP(obj)
	local box = obj:FindFirstChild("Scrap_Box_ESP")
	local txt = obj:FindFirstChild("Scrap_Text_ESP")
	if box then
		ScrapESPCache[box] = nil
		box:Destroy()
	end
	if txt then
		txt:Destroy()
	end
end

local function OneTimeScrapRefresh()
	for _, v in pairs(workspace:GetDescendants()) do
		if IsScrapItem(v) and IsValidGroundItem(v) then
			CreateScrapESP(v)
		end
	end
end

local function CreateRecyclerESP(obj)
	local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
	if not targetPart then
		return
	end
	if not obj:FindFirstChild("Recycler_Box_ESP") then
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "Recycler_Box_ESP"
		box.Color3 = Color3.fromRGB(170, 85, 255)
		box.Transparency = 0.4
		box.Size = targetPart.Size
		box.Adornee = targetPart
		box.AlwaysOnTop = true
		box.ZIndex = 0
		box.Parent = obj
	end
	if not obj:FindFirstChild("Recycler_Text_ESP") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Recycler_Text_ESP"
		billboard.Size = UDim2.new(0, 160, 0, 40)
		billboard.AlwaysOnTop = true
		billboard.ExtentsOffset = Vector3.new(0, 4, 0)
		billboard.Adornee = targetPart
		billboard.Parent = obj
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "废品回收机"
		label.TextColor3 = Color3.fromRGB(170, 85, 255)
		label.TextSize = 15
		label.Font = Enum.Font.SourceSansBold
		label.TextStrokeTransparency = 0
		label.Parent = billboard
	end
	local box = obj:FindFirstChild("Recycler_Box_ESP")
	if box then
		RecyclerESPCache[box] = obj
	end
end

local LiquidTargets = {
	["Lava"] = true,
	["CrystalizedGoo"] = true,
	["InfectionPart"] = true,
	["Ground"] = true,
}

local function IsLiquid(v)
	if not (v:IsA("BasePart") or v:IsA("Model")) then
		return false
	end
	if LiquidTargets[v.Name] then
		return true
	end
	local lower = string.lower(v.Name)
	return string.find(lower, "infectionpart") ~= nil
		or string.find(lower, "ground") ~= nil
end

local function CreateLiquidESP(obj)
	local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
	if not targetPart or not targetPart:IsA("BasePart") then
		return
	end

	local color
	if obj.Name == "Lava" then
		color = Color3.fromRGB(255, 80, 0)
	elseif string.find(string.lower(obj.Name), "infectionpart") then
		color = Color3.fromRGB(120, 255, 120)
	elseif string.find(string.lower(obj.Name), "ground") then
		color = Color3.fromRGB(139, 69, 19)
	else
		color = Color3.fromRGB(0, 200, 255)
	end

	if not obj:FindFirstChild("Liquid_Highlight_ESP") then
		local hl = Instance.new("Highlight")
		hl.Name = "Liquid_Highlight_ESP"
		hl.FillColor = color
		hl.FillTransparency = 0.55
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = obj
	end

	if not obj:FindFirstChild("Liquid_Text_ESP") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Liquid_Text_ESP"
		billboard.Size = UDim2.new(0, 180, 0, 40)
		billboard.AlwaysOnTop = true
		billboard.ExtentsOffset = Vector3.new(0, 3, 0)
		billboard.Adornee = targetPart
		billboard.Parent = obj

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = obj.Name
		label.TextColor3 = color
		label.TextSize = 15
		label.Font = Enum.Font.SourceSansBold
		label.TextStrokeTransparency = 0
		label.Parent = billboard
	end
	local hl = obj:FindFirstChild("Liquid_Highlight_ESP")
	if hl then
		LiquidESPCache[hl] = obj
	end
end

local TargetMonkeys = {
	["Lurker"] = true,
	["Stalker"] = true,
	["Kus"] = true,
	["Dus"] = true,
	["Gus"] = true,
	["SandMan"] = true,
	["Ashy"] = true,
	["Lost"] = true,
	["Scar"] = true,
	["Billy"] = true,
	["SandGuy"] = true,
	["Meat"] = true,
	["???"] = true,
	["Taller"] = true,
	["Slender"] = true,
	["BloodMan"] = true,
	["Lengthy"] = true,
	["Gooba"] = true,
	["john"] = true,
	["Saw"] = true,
	["Ghost"] = true,
	["BigGuy"] = true,
	["workshop"] = true,
	["Workshop"] = true,
	["Noxar"] = true,
	["Fearful"] = true,
}

local function CreateCandyESP(obj)
	if not obj or not obj.Parent then return end
	if obj:FindFirstChild("Candy_Highlight_ESP") then return end

	local hl = Instance.new("Highlight")
	hl.Name = "Candy_Highlight_ESP"
	hl.FillColor = Color3.fromRGB(255, 100, 200)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.Parent = obj

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Candy_Text_ESP"
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.AlwaysOnTop = true
	billboard.Adornee = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
	billboard.Parent = obj

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "Candy"
	label.TextColor3 = Color3.fromRGB(255, 100, 200)
	label.TextSize = 12
	label.Font = Enum.Font.SourceSansBold
	label.TextStrokeTransparency = 0
	label.Parent = billboard
	CandyESPCache[obj] = label
end

local function CreateMonsterESP(model)
	if not model:FindFirstChild("Monkey_Highlight_ESP") then
		local hl = Instance.new("Highlight")
		hl.Name = "Monkey_Highlight_ESP"
		hl.FillColor = Color3.fromRGB(255, 60, 0)
		hl.FillTransparency = 0.5
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = model
	end
	if not model:FindFirstChild("Monkey_Text_ESP") then
		local targetPart = model:FindFirstChild("HumanoidRootPart")
			or model:FindFirstChild("Head")
			or model:FindFirstChildOfClass("BasePart")
		if targetPart then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "Monkey_Text_ESP"
			billboard.Size = UDim2.new(0, 180, 0, 50)
			billboard.AlwaysOnTop = true
			billboard.ExtentsOffset = Vector3.new(0, 3.5, 0)
			billboard.Adornee = targetPart
			billboard.Parent = model
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = model.Name
			label.TextColor3 = Color3.fromRGB(255, 60, 0)
			label.TextSize = 16
			label.Font = Enum.Font.SourceSansBold
			label.TextStrokeTransparency = 0
			label.Parent = billboard
		end
	end
	local hl = model:FindFirstChild("Monkey_Highlight_ESP")
	if hl then
		MonkeyESPCache[hl] = model
	end
end

local function IsMonster(v)
	if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
		if Players:GetPlayerFromCharacter(v) then
			return false
		end
		return TargetMonkeys[v.Name] == true
	end
	return false
end

local function hideBody(model)
	if model:IsA("Model") or model:IsA("BasePart") then
		local nameLower = model.Name:lower()
		local humanoid = model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") or nil
		local isDeadBody = nameLower == "dead"
			or nameLower:find("dead")
			or nameLower:find("corpse")
			or nameLower:find("ragdoll")
			or nameLower:find("chimpragdoll")
			or (humanoid and humanoid.Health <= 0)
		if isDeadBody then
			task.defer(function()
				if model and model.Parent then
					model.Archivable = true
					model.Parent = nil
				end
			end)
		end
	end
end

local function InteractWithObject(obj)
	local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		fireproximityprompt(prompt)
	else
		game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
		game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
	end
end

local function PlayerHasLootToSell()
	local bp = LPlr:FindFirstChild("Backpack")
	if bp then
		for _, tool in pairs(bp:GetChildren()) do
			if tool:IsA("Tool") and ItemPriority[tool.Name] then
				return true
			end
		end
	end
	local char = LPlr.Character
	if char then
		for _, tool in pairs(char:GetChildren()) do
			if tool:IsA("Tool") and ItemPriority[tool.Name] then
				return true
			end
		end
	end
	return false
end

local function FindBestItem()
	local bestItem = nil
	local bestPriority = 0
	local function consider(v)
		if not v then
			return
		end
		if not (v:IsA("BasePart") or v:IsA("Model") or v:IsA("Tool")) then
			return
		end
		local priority = ItemPriority[v.Name]
		if not priority then
			return
		end
		if not IsValidGroundItem(v) then
			return
		end
		if priority > bestPriority then
			bestPriority = priority
			bestItem = v
		end
	end
	local scraps = workspace:FindFirstChild("Scraps")
	if scraps then
		for _, v in ipairs(scraps:GetChildren()) do
			consider(v)
		end
	end
	for _, v in ipairs(workspace:GetChildren()) do
		if v.Name ~= "Scraps" then
			consider(v)
		end
	end
	return bestItem
end

local _cachedRecycler = nil
local function GetRecycler()
	if _cachedRecycler and _cachedRecycler.Parent then
		return _cachedRecycler
	end
	_cachedRecycler = workspace:FindFirstChild("ScrapRecycler", true)
	return _cachedRecycler
end

local function ApplyObjectESP(v)
	if not v or not v.Parent then
		return
	end
	if v.Name == "ScrapRecycler" and (v:IsA("BasePart") or v:IsA("Model")) then
		if Config.RecyclerESP then
			CreateRecyclerESP(v)
		end
	elseif Config.MonkeyESP and IsMonster(v) then
		CreateMonsterESP(v)
	elseif Config.LiquidESP and IsLiquid(v) then
		CreateLiquidESP(v)
	end
end

local function OneTimeFullRefresh()
	for _, v in pairs(workspace:GetDescendants()) do
		ApplyObjectESP(v)
	end
end

local t1 = Window:Tab({ Title = "信息", Icon = "info" })
t1:Section({ Title = "信息" })
t1:Paragraph({ Title = "使用者: " .. LPlr.DisplayName, Desc = "" })
t1:Paragraph({ Title = "执行器: " .. ((identifyexecutor and identifyexecutor()) or "未知"), Desc = "" })
t1:Paragraph({ Title = "游戏 ID (PlaceId): " .. tostring(game.PlaceId), Desc = "" })
t1:Paragraph({ Title = "服务器 ID (JobId): " .. (game.JobId ~= "" and game.JobId or "单人/私服"), Desc = "" })
t1:Button({
	Title = "点击复制服务器 ID",
	Callback = function()
		setclipboard(game.JobId)
	end,
})

local tVisual = Window:Tab({ Title = "视觉", Icon = "eye" })
tVisual:Section({ Title = "玩家Esp" })
tVisual:Toggle({
	Title = "开启 ESP",
	Callback = function(v)
		Config.PlayerESP = v
		if not v then
			for _, data in pairs(ESPCache) do
				if data.Line then
					data.Line.Visible = false
				end
				if data.Billboard then
					data.Billboard.Enabled = false
				end
			end
			for _, p in pairs(Players:GetPlayers()) do
				if p.Character and p.Character:FindFirstChild("PlayerHighlight") then
					p.Character.PlayerHighlight:Destroy()
				end
			end
		end
	end,
})
tVisual:Toggle({
	Title = "显示名字",
	Callback = function(v)
		Config.ShowNames = v
	end,
})
tVisual:Toggle({
	Title = "显示射线",
	Callback = function(v)
		Config.ShowTracers = v
	end,
})
tVisual:Toggle({
	Title = "显示高亮",
	Callback = function(v)
		Config.PlayerHighlight = v
	end,
})

tVisual:Section({ Title = "游戏类Esp" })
tVisual:Toggle({
	Title = "糖果Esp",
	Callback = function(v)
		Config.CandyESP = v
		if v then
			local candiesFolder = workspace:FindFirstChild("Candies")
			if candiesFolder then
				for _, obj in ipairs(candiesFolder:GetChildren()) do
					if obj.Name == "Candy" then
						CreateCandyESP(obj)
					end
				end
			end
		else
			for obj, _ in pairs(CandyESPCache) do
				local hl = obj:FindFirstChild("Candy_Highlight_ESP")
				local tx = obj:FindFirstChild("Candy_Text_ESP")
				if hl then hl:Destroy() end
				if tx then tx:Destroy() end
			end
			table.clear(CandyESPCache)
			local candiesFolder = workspace:FindFirstChild("Candies")
			if candiesFolder then
				for _, o in ipairs(candiesFolder:GetChildren()) do
					local hl = o:FindFirstChild("Candy_Highlight_ESP")
					local tx = o:FindFirstChild("Candy_Text_ESP")
					if hl then hl:Destroy() end
					if tx then tx:Destroy() end
				end
			end
		end
	end,
})

tVisual:Toggle({
	Title = "开关怪物Esp",
	Callback = function(v)
		Config.MonkeyESP = v
		if v then
			OneTimeFullRefresh()
		else
			for hl, parent in pairs(MonkeyESPCache) do
				if hl and hl.Parent then hl:Destroy() end
				if parent then
					local t = parent:FindFirstChild("Monkey_Text_ESP")
					if t then t:Destroy() end
				end
			end
			table.clear(MonkeyESPCache)
		end
	end,
})

tVisual:Toggle({
	Title = "开关废品Esp",
	Callback = function(v)
		Config.ScrapESP = v
		if v then
			OneTimeScrapRefresh()
		else
			for box, parent in pairs(ScrapESPCache) do
				if box and box.Parent then box:Destroy() end
				if parent then
					local t = parent:FindFirstChild("Scrap_Text_ESP")
					if t then t:Destroy() end
				end
			end
			table.clear(ScrapESPCache)
		end
	end,
})

tVisual:Toggle({
	Title = "开关回收机Esp",
	Callback = function(v)
		Config.RecyclerESP = v
		if v then
			OneTimeFullRefresh()
		else
			for box, parent in pairs(RecyclerESPCache) do
				if box and box.Parent then box:Destroy() end
				if parent then
					local t = parent:FindFirstChild("Recycler_Text_ESP")
					if t then t:Destroy() end
				end
			end
			table.clear(RecyclerESPCache)
		end
	end,
})

tVisual:Toggle({
	Title = "液体Esp",
	Default = false,
	Callback = function(v)
		Config.LiquidESP = v
		if v then
			OneTimeFullRefresh()
		else
			for hl, parent in pairs(LiquidESPCache) do
				if hl and hl.Parent then hl:Destroy() end
				if parent then
					local t = parent:FindFirstChild("Liquid_Text_ESP")
					if t then t:Destroy() end
				end
			end
			table.clear(LiquidESPCache)
		end
	end,
})

tVisual:Toggle({
	Title = "夜视模式",
	Callback = function(v)
		Config.NightVis = v
		lastNightVis = false
		if not v then
			Light.Brightness, Light.Ambient, Light.ClockTime = Orig.Bright, Orig.Ambient, Orig.Clock
			Light.FogEnd = Orig.FogEnd or 100000
			Light.FogStart = Orig.FogStart or 0
		end
	end,
})
tVisual:Toggle({
	Title = "隐藏尸体",
	Default = false,
	Callback = function(v)
		Config.HideBodies = v
		if v then
			for _, model in ipairs(workspace:GetDescendants()) do
				hideBody(model)
			end
			if not bodyConnection then
				bodyConnection = workspace.DescendantAdded:Connect(function(model)
					if Config.HideBodies then
						hideBody(model)
					end
				end)
			end
		else
			if bodyConnection then
				bodyConnection:Disconnect()
				bodyConnection = nil
			end
		end
	end,
})

local tESPSet = Window:Tab({ Title = "ESP设置", Icon = "sliders-horizontal" })
tESPSet:Section({ Title = "玩家" })
tESPSet:Toggle({
	Title = "玩家彩虹色",
	Callback = function(v) Config.RainbowESP = v end,
})
tESPSet:Toggle({
	Title = "玩家显示距离",
	Callback = function(v) Config.ShowDistance = v end,
})
tESPSet:Dropdown({
	Title = "玩家射线位置",
	Value = "从下方",
	Values = {"从下方", "从上方"},
	Callback = function(v) Config.TracerFromTop = (v == "从上方") end,
})

tESPSet:Section({ Title = "糖果" })
tESPSet:Toggle({
	Title = "糖果彩虹色",
	Callback = function(v) Config.CandyRainbow = v end,
})
tESPSet:Toggle({
	Title = "糖果显示距离",
	Callback = function(v) Config.CandyShowDistance = v end,
})

tESPSet:Section({ Title = "怪物" })
tESPSet:Toggle({
	Title = "怪物彩虹色",
	Callback = function(v) Config.MonsterRainbow = v end,
})
tESPSet:Toggle({
	Title = "怪物显示距离",
	Callback = function(v) Config.MonsterShowDistance = v end,
})

tESPSet:Section({ Title = "废品" })
tESPSet:Toggle({
	Title = "废品彩虹色",
	Callback = function(v) Config.ScrapRainbow = v end,
})
tESPSet:Toggle({
	Title = "废品显示距离",
	Callback = function(v) Config.ScrapShowDistance = v end,
})

tESPSet:Section({ Title = "回收机" })
tESPSet:Toggle({
	Title = "回收机彩虹色",
	Callback = function(v) Config.RecyclerRainbow = v end,
})
tESPSet:Toggle({
	Title = "回收机显示距离",
	Callback = function(v) Config.RecyclerShowDistance = v end,
})

tESPSet:Section({ Title = "液体" })
tESPSet:Toggle({
	Title = "液体彩虹色",
	Callback = function(v) Config.LiquidRainbow = v end,
})
tESPSet:Toggle({
	Title = "液体显示距离",
	Callback = function(v) Config.LiquidShowDistance = v end,
})

local tPlayer = Window:Tab({ Title = "玩家", Icon = "user" })
tPlayer:Section({ Title = "属性修改" })
tPlayer:Slider({
	Title = "修改速度值",
	Value = { Min = 0, Max = 500, Default = Orig.Speed },
	Increment = 1,


	Callback = function(v)
		Config.Speed = v
		if Config.SpeedEn and LPlr.Character and LPlr.Character:FindFirstChild("Humanoid") then
			LPlr.Character.Humanoid.WalkSpeed = v
		end
	end,
})
tPlayer:Toggle({
	Title = "开启速度修改",
	Callback = function(v)
		Config.SpeedEn = v
		if LPlr.Character and LPlr.Character:FindFirstChild("Humanoid") then
			LPlr.Character.Humanoid.WalkSpeed = v and Config.Speed or Orig.Speed
		end
	end,
})
tPlayer:Slider({
	Title = "修改FOV值",
	Value = { Min = 1, Max = 120, Default = Orig.FOV },
	Increment = 1,


	Callback = function(v)
		Config.FOV = v
		if Config.FOVEn and Cam then
			Cam.FieldOfView = v
		end
	end,
})
tPlayer:Toggle({
	Title = "开启 FOV 修改",
	Callback = function(v)
		Config.FOVEn = v
		Cam.FieldOfView = v and Config.FOV or Orig.FOV
	end,
})
tPlayer:Section({ Title = "其它类" })
tPlayer:Toggle({
	Title = "防脚滑",
	Default = false,
	Callback = function(v)
		if v then
			enableAntiSlippery()
		else
			disableAntiSlippery()
		end
	end,
})
tPlayer:Toggle({
	Title = "第三人称",
	Callback = function(v)
		Config.ThirdPerson = v
	end,
})
tPlayer:Toggle({
	Title = "无限跳跃",
	Callback = function(v)
		Config.InfJump = v
	end,
})
tPlayer:Toggle({
	Title = "穿墙模式",
	Callback = function(v)
		Config.Noclip = v
		if not v then
			for part, originalState in pairs(originalNoclipCollisions) do
				if part and part.Parent then
					part.CanCollide = originalState
				end
			end
			table.clear(originalNoclipCollisions)
		end
	end,
})
tPlayer:Section({ Title = "固定" })
tPlayer:Toggle({
	Title = "固定自己",
	Callback = function(v)
		Config.FreezeSelf = v
		if LPlr.Character then
			local hrp = LPlr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = v
			end
			setCharacterAnimationFrozen(LPlr.Character, v)
		end
	end,
})
tPlayer:Toggle({
	Title = "固定自己(不固定动画)",
	Callback = function(v)
		Config.AnchorOnly = v
		if LPlr.Character then
			local hrp = LPlr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = v
			end
		end
	end,
})
tPlayer:Section({ Title = "跳跃" })
local defaultJumpPower = 15
local jumpHeightValue = defaultJumpPower
tPlayer:Input({
	Title = "跳跃高度",
	Value = "15",
	Placeholder = "",


	Callback = function(v)
		jumpHeightValue = tonumber(v) or defaultJumpPower
	end,
})
tPlayer:Button({
	Title = "开启跳跃",
	Callback = function()
		loadstring(
			[[local jumph = ]]
				.. tostring(jumpHeightValue)
				.. [[ ]]
				.. game:HttpGet(
					"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/JB.LUA"
				)
		)()
	end,
})
tPlayer:Section({ Title = "游戏的一些功能" })
tPlayer:Toggle({
	Title = "自动朝向BloodMan",
	Default = false,
	Callback = function(v)
		Config.AutoAimBloodMan = v
		if not v and LPlr.Character then
			local humanoid = LPlr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.AutoRotate = true
			end
		end
	end,
})
tPlayer:Toggle({
	Title = "立即互动",
	Callback = function(v)
		applyInstantInteract(v)
	end,
})

local tMisc = Window:Tab({ Title = "杂项", Icon = "wrench" })
tMisc:Section({ Title = "旋转" })
tMisc:Toggle({
	Title = "开启旋转",
	Default = false,
	Callback = function(v)
		RotationConfig.Enabled = v
		if v then
			startRotation()
		else
			if rotationConnection then
				rotationConnection:Disconnect()
				rotationConnection = nil
			end
			if LPlr.Character then
				local humanoid = LPlr.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.AutoRotate = true
				end
			end
		end
	end,
})
tMisc:Slider({
	Title = "旋转速度",
	Value = { Min = 1, Max = 500, Default = 1 },
	Increment = 1,


	Callback = function(v)
		RotationConfig.Speed = v
	end,
})
tMisc:Dropdown({
	Title = "旋转方向",
			Value = "顺时针",
Values = { "顺时针", "逆时针" },

	Callback = function(v)
		RotationConfig.Direction = (v == "顺时针") and 1 or -1
	end,
})

tMisc:Section({ Title = "致命猴子功能" })
tMisc:Toggle({
	Title = "114514",
	Default = false,
	Callback = function(v)
		Config.DeathEffectEn = v
	end,
})
tMisc:Button({
	Title = "监控视角 (要坐到椅子上)",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/SecCamera.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "Bone骨架修改工具",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/6D%E9%AA%A8%E6%9E%B6%E5%8A%A8%E7%94%BB%E8%A6%86%E7%9B%96%E5%B7%A5%E5%85%B7.LUA"
			)
		)()
	end,
})
tMisc:Toggle({
	Title = "开启刷钱",
	Default = false,
	Callback = function(v)
		local wasActive = Config.AutoGold
		Config.AutoGold = v
		if not v and wasActive then
			task.spawn(function()
				task.wait(0.05)
				if LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = LPlr.Character.HumanoidRootPart
					local recycler = GetRecycler()
					if recycler then
						local pos = (recycler:IsA("BasePart") and recycler.CFrame.Position)
							or recycler:GetPivot().Position
						hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
					end
				end
			end)
		end
	end,
})
tMisc:Button({
	Title = "跳杀镜头修改工具",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/CAMERA.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "复活",
	Callback = function()
		game:GetService("ReplicatedStorage").RequestRespawn:FireServer()
	end,
})
tMisc:Button({
	Title = "删除安全阻挡(适合控制怪物时使用)",
	Callback = function()
		for _, obj in ipairs(workspace:GetDescendants()) do
			if (obj:IsA("BasePart") or obj:IsA("MeshPart")) then
				if obj.Name == "safe" or obj.Name == "SafeZone" then
					obj:Destroy()
				end
			elseif obj:IsA("Folder") and (obj.Name == "SafeZone" or obj.Name == "AntiVoid") then
				obj:Destroy()
			end
		end
	end,
})
tMisc:Toggle({
	Title = "禁用跳杀动画",
	Default = false,
	Callback = function(v)
		Config.DisableJumpscareAnim = v
		toggleJumpscareAnim(v)
	end,
})
tMisc:Toggle({
	Title = "控制怪物操控修复",
	Default = false,
	Callback = function(v)
		Config.DisableWalkTo = v
		updateDamageScriptState()
	end,
})
tMisc:Button({
	Title = "成为怪物脚本",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/BTM.LUA"
			)
		)()
	end,
})

tMisc:Section({ Title = "通用工具" })
tMisc:Button({
	Title = "固定在NPC脚下",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/%E8%84%9A%E5%BA%95.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "NPC控制",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty38.lua"))()
	end,
})
tMisc:Button({
	Title = "汉化游戏",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/AUTOTL.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "AnimHubV2",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"
			)
		)()
	end,
})
tMisc:Button({
	Title = "声音修改工具",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/%E5%A3%B0%E9%9F%B3%E4%BF%AE%E6%94%B9.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "手机版Shiftlock",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/MobileShiftlock.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end,
})
tMisc:Button({
	Title = "TP Tool",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/TP%20TOOL.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "飞行 GUI",
	Callback = function()
		loadstring(
			game:HttpGet(
				"https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/Scripts/Fly%20Gui.LUA"
			)
		)()
	end,
})
tMisc:Button({
	Title = "R15动作脚本",
	Callback = function()
		loadstring(
			game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Free-emote/refs/heads/main/Delta%20mad%20stuffs")
		)()
	end,
})

local tFace = Window:Tab({ Title = "面部替换", Icon = "smile" })

local isBTM = false
local function checkBTM()
	if game.PlaceId == 121604956428343 then
		return true
	end
	if game.Name and (game.Name == "BTM" or string.find(string.lower(game.Name), "be the monster")) then
		return true
	end
	return false
end

pcall(function()
	isBTM = checkBTM()
end)

if not isBTM then
	task.delay(3, function()
		if checkBTM() and not isBTM then
			isBTM = true
		end
	end)
end

local function setPlayerLocalScriptEnabled(scriptName, enabled)
	local playerScripts = LPlr:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return
	end
	local sc = playerScripts:FindFirstChild(scriptName)
	if sc and sc:IsA("LocalScript") then
		sc.Enabled = enabled
	end
end

if isBTM then
	local tBTM = Window:Tab({ Title = "BTM", Icon = "code" })
	tBTM:Section({ Title = "功能有点少:{" })

	local clearingSurvivors = false

	tBTM:Toggle({
		Title = "扩大玩家碰撞箱",
		Callback = function(v)
			Config.ExpandCollision = v
		end,
	})

	tBTM:Toggle({
		Title = "显示碰撞箱",
		Callback = function(v)
			Config.ShowCollisionBox = v
		end,
	})

	tBTM:Toggle({
		Title = "关闭Gus眼瞎",
		Callback = function(v)
			Config.DisableGusBlind = v
			setPlayerLocalScriptEnabled("GusBlind", not v)
		end,
	})

	tBTM:Toggle({
		Title = "Dus不模糊",
		Callback = function(v)
			Config.DisableDusAura = v
			setPlayerLocalScriptEnabled("DusAura", not v)
		end,
	})

	tBTM:Toggle({
		Title = "Kus正常视野",
		Callback = function(v)
			Config.DisableKusBlur = v
			setPlayerLocalScriptEnabled("NãoChoraxkus", not v)
		end,
	})

	tBTM:Toggle({
		Title = "约翰正常视野",
		Callback = function(v)
			Config.DisableJohnBlur = v
			setPlayerLocalScriptEnabled("NãoChorax", not v)
		end,
	})

	tBTM:Toggle({
		Title = "Bloodman不眼红",
		Callback = function(v)
			Config.DisableBloodmanRed = v
			setPlayerLocalScriptEnabled("NãoChorax2", not v)
		end,
	})

tBTM:Input({
	Title = "碰撞箱大小",
	Value = tostring(Config.CollisionSize or 8),
	Placeholder = "",


		Callback = function(text)
			local n = tonumber(text)
			if n and n > 0 then
				Config.CollisionSize = n
			else
				WindUI:Notify({
					Title = "BTM",
					Content = "请输入大于0的数字",
					Duration = 2,
				})
			end
		end,
	})

	tBTM:Button({
		Title = "一键清图",
		Callback = function()
			if not LPlr.Team or LPlr.Team.Name ~= "Monsters" then
				WindUI:Notify({
					Title = "BTM",
					Content = "你当前不在 Monsters 队伍",
					Duration = 3,
				})
				return
			end

			if clearingSurvivors then
				return
			end
			clearingSurvivors = true

			WindUI:Notify({
				Title = "BTM",
				Content = "开始清理...",
				Duration = 2,
			})

			task.spawn(function()
				while clearingSurvivors do
					local survivors = {}
					for _, p in ipairs(Players:GetPlayers()) do
						if p ~= LPlr and p.Team and p.Team.Name == "Apes" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
							table.insert(survivors, p)
						end
					end

					if #survivors == 0 then
						WindUI:Notify({
							Title = "BTM",
							Content = "已清除",
							Duration = 3,
						})
						clearingSurvivors = false
						break
					end

					local target = survivors[1]
					local hrp = LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart")
					local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
					if hrp and targetHRP then
						hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
					end

					task.wait(0.3)
				end
			end)
		end,
	})

end

local selectedSource = "玩家"
tFace:Dropdown({
	Title = "被替换的怪物:",
			Value = "玩家",
Values = { "玩家", "Dus", "Gus", "Kus", "Lurker", "Lost", "Billy", "SandGuy", "Fearful", "Noxar", "Scar" },

	Callback = function(v)
		selectedSource = v
	end,
})

local partMapping = {
	["玩家"] = "Face",
	["Dus"] = "RootPart",
	["Gus"] = "RootPart",
	["Kus"] = "body.003",
	["Lurker"] = "body.001",
	["Lost"] = "Body",
	["Billy"] = "Face",
	["SandGuy"] = "Face",
	["Fearful"] = "body.005",
	["Noxar"] = "body.002",
	["Scar"] = "hands.002",
}

local assetMapping = {
	["玩家"] = "rbxassetid://71643158500420",
	["Dus"] = "rbxassetid://88852856555845",
	["Gus"] = nil,
	["Kus"] = "rbxassetid://74281186300854",
	["Lurker"] = "rbxassetid://76034961660325",
	["Lost"] = "rbxassetid://106250773698639",
	["Billy"] = "rbxassetid://98931014974628",
	["SandGuy"] = "rbxassetid://116901141358719",
	["Fearful"] = "rbxassetid://138410978543813",
	["Noxar"] = "rbxassetid://76034961660325",
	["Scar"] = "rbxassetid://109974013717205",
}

local function setSurfaceAppearance(part, assetId)
	if not part then
		return false
	end
	local sa = part:FindFirstChildOfClass("SurfaceAppearance")
	if not sa then
		sa = Instance.new("SurfaceAppearance")
		sa.Parent = part
	end
	pcall(function()
		sa.ColorMap = assetId
		sa.TexturePack = assetId
	end)
	return true
end

local function getTargetPart(model, partName)
	if not model or not model.Parent then
		return nil
	end
	return model:FindFirstChild(partName)
end

local function getSourceModels()
	local models = {}
	if selectedSource == "玩家" then
		local char = LPlr.Character
		if char then
			models = { char }
		end
	else
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v.Name == selectedSource then
				table.insert(models, v)
			end
		end
	end
	return models
end

local function applyToSource(assetId)
	local models = getSourceModels()
	if #models == 0 then
		return
	end
	local partName = partMapping[selectedSource]
	if not partName then
		return
	end
	for _, model in ipairs(models) do
		local part = getTargetPart(model, partName)
		if part then
			setSurfaceAppearance(part, assetId)
		end
	end
end

local targetTypes = { "玩家", "Dus", "Kus", "Lurker", "Lost", "Billy", "SandGuy", "Fearful", "Noxar", "Scar" }
for _, targetType in ipairs(targetTypes) do
	tFace:Button({
		Name = "替换为" .. targetType,
		Callback = function()
			local assetId = assetMapping[targetType]
			if assetId then
				applyToSource(assetId)
			end
		end,
	})
end
tFace:Button({
	Title = "替换为Blud/Dlud",
	Callback = function()
		applyToSource("rbxassetid://104550436314649")
	end,
})
tFace:Button({
	Title = "替换为Gooba",
	Callback = function()
		applyToSource("rbxassetid://119860546697100")
	end,
})
tFace:Button({
	Title = "替换为John",
	Callback = function()
		applyToSource("rbxassetid://112946382920572")
	end,
})
tFace:Button({
	Title = "替换为旧Dus",
	Callback = function()
		applyToSource("rbxassetid://140264211931340")
	end,
})
tFace:Button({
	Title = "替换为Lengthy",
	Callback = function()
		applyToSource("rbxassetid://123532679732291")
	end,
})

local function InitializeScript()
	cleanupOldESP()

	for _, player in ipairs(Players:GetPlayers()) do
		setupPlayerDeathEffect(player)
	end
	Players.PlayerAdded:Connect(setupPlayerDeathEffect)

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LPlr then
			if p.Character then
				setupPlayerESPWithRetry(p)
			end
			p.CharacterAdded:Connect(function()
				setupPlayerESPWithRetry(p)
			end)
			p.CharacterRemoving:Connect(function()
				removePlayerESP(p)
			end)
		end
	end

	Players.PlayerAdded:Connect(function(p)
		if p.Character then
			setupPlayerESPWithRetry(p)
		end
		p.CharacterAdded:Connect(function()
			setupPlayerESPWithRetry(p)
		end)
		p.CharacterRemoving:Connect(function()
			removePlayerESP(p)
		end)
	end)
	Players.PlayerRemoving:Connect(function(p)
		removePlayerESP(p)
	end)

	task.spawn(function()
		while true do
			task.wait(3)
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LPlr and p.Character and not ESPCache[p] then
					setupPlayerESP(p)
				end
			end
		end
	end)

	for _, v in ipairs(workspace:GetDescendants()) do
		ApplyBKUCreatorESP(v)
	end

	LPlr.CharacterAdded:Connect(function(char)
		table.clear(originalNoclipCollisions)
		table.clear(cachedAnimationSpeeds)
		task.wait(0.5)
		if Config.DisableWalkTo then
			updateDamageScriptState()
		end
		if RotationConfig.Enabled then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.AutoRotate = false
			end
			if rotationConnection then
				rotationConnection:Disconnect()
				rotationConnection = nil
			end
			startRotation()
		end
		if antiSlipperyEnabled then
			if antiSlipperyConnection then
				antiSlipperyConnection:Disconnect()
				antiSlipperyConnection = nil
			end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			if humanoid and rootPart then
				antiSlipperyConnection = RS.Heartbeat:Connect(antiSlippery)
			end
		end
	end)

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Cam = workspace.CurrentCamera
		LockFOV()
		if Config.FOVEn and Cam then
			Cam.FieldOfView = Config.FOV
		end
	end)
	LockFOV()

	workspace.DescendantAdded:Connect(function(v)
		ApplyBKUCreatorESP(v)
		ApplyObjectESP(v)
		if Config.ScrapESP and IsScrapItem(v) and IsValidGroundItem(v) then
			CreateScrapESP(v)
		end
		if Config.HideBodies then
			hideBody(v)
		end
	end)

	task.spawn(function()
		while true do
			if Config.DisableWalkTo then
				updateDamageScriptState()
			end
			task.wait(1)
		end
	end)

	task.spawn(function()
		while true do
			if Config.ScrapESP then
				for _, v in pairs(workspace:GetDescendants()) do
					if IsScrapItem(v) then
						if IsValidGroundItem(v) then
							CreateScrapESP(v)
						else
							RemoveScrapESP(v)
						end
					end
				end
			end
			task.wait(4)
		end
	end)

	task.spawn(function()
		while true do
			if Config.AutoGold and LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = LPlr.Character.HumanoidRootPart
				local humanoid = LPlr.Character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					if PlayerHasLootToSell() then
						local recycler = GetRecycler()
						if recycler then
							local pos = (recycler:IsA("BasePart") and recycler.CFrame.Position)
								or recycler:GetPivot().Position
							hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
							InteractWithObject(recycler)
						end
					else
						local targetItem = FindBestItem()
						if targetItem then
							local pos = (targetItem:IsA("BasePart") and targetItem.CFrame.Position)
								or targetItem:GetPivot().Position
							hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
							InteractWithObject(targetItem)
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)

	local aimRaycastParams = RaycastParams.new()
	aimRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	RS.RenderStepped:Connect(function()
		if Config.SpeedEn then
			local hum = LPlr.Character and LPlr.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = Config.Speed
			end
		end
		if Config.NightVis then
			Light.Brightness, Light.Ambient, Light.ClockTime = 2, Color3.new(1, 1, 1), 12
			Light.FogEnd = 100000
			Light.FogStart = 0
		end
		if Config.FOVEn and Cam then
			Cam.FieldOfView = Config.FOV
		end
		if Config.ThirdPerson then
			LPlr.CameraMode = Enum.CameraMode.Classic
		end
		if Config.InfStamina then
			pcall(function()
				local s = LPlr.PlayerGui.Stamina.Handler.Stamina
				if s.Value < 100 then
					s.Value = 100
				end
			end)
		end

		if Config.AutoAimBloodMan then
			local char = LPlr.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if hrp and humanoid then
					local bloodMan = cachedBloodMan
					if bloodMan and bloodMan.Parent then
						local targetPart = bloodMan:FindFirstChild("HumanoidRootPart")
							or bloodMan:FindFirstChild("Head")
							or bloodMan:FindFirstChildWhichIsA("BasePart")
						if targetPart then
							local origin = hrp.Position + Vector3.new(0, 1, 0)
							local destination = targetPart.Position + Vector3.new(0, 1, 0)
							local direction = (destination - origin).Unit
							local distance = (destination - origin).Magnitude

							aimRaycastParams.FilterDescendantsInstances = { char, bloodMan }
							local rawRaycastResult = workspace:Raycast(origin, direction * distance, aimRaycastParams)

							if rawRaycastResult then
								humanoid.AutoRotate = not RotationConfig.Enabled
							else
								humanoid.AutoRotate = false
								hrp.CFrame =
									CFrame.new(hrp.Position, Vector3.new(destination.X, hrp.Position.Y, destination.Z))
							end
						else
							humanoid.AutoRotate = true
						end
					else
						humanoid.AutoRotate = true
					end
				end
			end
		end

		if not Config.PlayerESP then
			for _, data in pairs(ESPCache) do
				if data.Line then
					data.Line.Visible = false
				end
				if data.Billboard then
					data.Billboard.Enabled = false
				end
			end
			return
		end

		local vpSize = Cam.ViewportSize
		local screenMidX = vpSize.X / 2
		local screenMaxY = vpSize.Y

		for player, data in pairs(ESPCache) do
			local char = player.Character
			if not char or not char.Parent then
				if data.Line then
					data.Line.Visible = false
				end
				if data.Billboard then
					data.Billboard.Enabled = false
				end
			else
				local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
				if not targetPart then
					if data.Line then
						data.Line.Visible = false
					end
					if data.Billboard then
						data.Billboard.Enabled = false
					end
				else
					local baseColor = (player.Team and player.TeamColor.Color) or Color3.fromRGB(0, 255, 0)
					local displayColor = baseColor
					if Config.RainbowESP then
						local hue = (tick() % 5) / 5
						displayColor = Color3.fromHSV(hue, 1, 1)
					end

					if Config.PlayerHighlight then
						local hl = char:FindFirstChild("PlayerHighlight")
						if not hl then
							hl = Instance.new("Highlight")
							hl.Name = "PlayerHighlight"
							hl.OutlineColor = Color3.fromRGB(255, 255, 255)
							hl.Parent = char
						end
						hl.FillColor = displayColor
					else
						if char:FindFirstChild("PlayerHighlight") then
							char.PlayerHighlight:Destroy()
						end
					end

					if Config.ShowNames or Config.ShowDistance then
						data.Billboard.Enabled = true
						local text = player.DisplayName
						if Config.ShowDistance then
							local dist = (targetPart.Position - Cam.CFrame.Position).Magnitude
							text = text .. string.format(" [%.0fm]", dist)
						end
						data.Label.Text = text
						data.Label.TextColor3 = displayColor
					else
						data.Billboard.Enabled = false
					end

					if Config.ShowTracers then
						local screenPos, onScreen = Cam:WorldToViewportPoint(targetPart.Position)
						if onScreen then
							local originY = Config.TracerFromTop and 0 or screenMaxY
							local p1 = Vector2.new(screenMidX, originY)
							local p2 = Vector2.new(screenPos.X, screenPos.Y)
							local dist = (p2 - p1).Magnitude
							local center = (p1 + p2) / 2
							local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))

							data.Line.Size = UDim2.new(0, dist, 0, 1)
							data.Line.Position = UDim2.new(0, center.X, 0, center.Y)
							data.Line.Rotation = angle
							data.Line.BackgroundColor3 = displayColor
							data.Line.Visible = true
						else
							data.Line.Visible = false
						end
					else
						data.Line.Visible = false
					end
				end
			end
		end
	end)

	local function rebuildNoclipParts(char)
		table.clear(noclipPartsCache)
		if not char then
			return
		end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				table.insert(noclipPartsCache, v)
			end
		end
	end
	if LPlr.Character then
		rebuildNoclipParts(LPlr.Character)
	end
	LPlr.CharacterAdded:Connect(function(char)
		task.defer(function()
			rebuildNoclipParts(char)
		end)
	end)
	if LPlr.Character then
		LPlr.Character.DescendantAdded:Connect(function(v)
			if v:IsA("BasePart") then
				table.insert(noclipPartsCache, v)
			end
		end)
	end
	LPlr.CharacterAdded:Connect(function(char)
		char.DescendantAdded:Connect(function(v)
			if v:IsA("BasePart") then
				table.insert(noclipPartsCache, v)
			end
		end)
	end)

	RS.Stepped:Connect(function()
		if Config.Noclip then
			for i = #noclipPartsCache, 1, -1 do
				local v = noclipPartsCache[i]
				if not v or not v.Parent then
					table.remove(noclipPartsCache, i)
				else
					if originalNoclipCollisions[v] == nil then
						originalNoclipCollisions[v] = v.CanCollide
					end
					v.CanCollide = false
				end
			end
		end
		if Config.AnchorOnly and LPlr.Character then
			local hrp = LPlr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = true
			end
		end
		if Config.FreezeSelf and LPlr.Character then
			local hrp = LPlr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = true
			end
			local humanoid = LPlr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local animator = humanoid:FindFirstChildOfClass("Animator")
				if animator then
					for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
						if track.Speed ~= 0 then
							cachedAnimationSpeeds[track] = track.Speed
							track:AdjustSpeed(0)
						end
					end
				end
			end
		end
	end)

	UIS.JumpRequest:Connect(function()
		if Config.InfJump and LPlr.Character then
			local h = LPlr.Character:FindFirstChildOfClass("Humanoid")
			if h then
				h:ChangeState("Jumping")
			end
		end
	end)

	local creatorChecked = {}
	task.spawn(function()
		while true do
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and obj.Name == "baloksxin_real" and not creatorChecked[obj] then
					ApplyBKUCreatorESP(obj)
					creatorChecked[obj] = true
				end
			end
			task.wait(15)
		end
	end)
end

task.spawn(function()
	local originalSizes = {}
	while true do
		if Config.ExpandCollision then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LPlr and p.Character then
					local hrp = p.Character:FindFirstChild("HumanoidRootPart")
					if hrp and hrp:IsA("BasePart") then
						if not originalSizes[hrp] then
							originalSizes[hrp] = hrp.Size
						end
						hrp.Size = Vector3.new(Config.CollisionSize, Config.CollisionSize, Config.CollisionSize)
						hrp.CanCollide = true
						local visualBox = hrp:FindFirstChild("CollisionVisual")
						if Config.ShowCollisionBox then
							if not visualBox then
								visualBox = Instance.new("Part")
								visualBox.Name = "CollisionVisual"
								visualBox.Size = Vector3.new(Config.CollisionSize, Config.CollisionSize, Config.CollisionSize)
								visualBox.Anchored = false
								visualBox.CanCollide = false
								visualBox.Transparency = 0.6
								visualBox.Material = Enum.Material.ForceField
								visualBox.Color = Color3.fromRGB(100, 180, 230)
								visualBox.CFrame = hrp.CFrame
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = hrp
								weld.Part1 = visualBox
								weld.Parent = visualBox
								visualBox.Parent = hrp
							end
							visualBox.Size = Vector3.new(Config.CollisionSize, Config.CollisionSize, Config.CollisionSize)
						else
							if visualBox then
								visualBox:Destroy()
							end
						end
					end
				end
			end
		else
			for hrp, size in pairs(originalSizes) do
				if hrp and hrp.Parent then
					hrp.Size = size
					local visualBox = hrp:FindFirstChild("CollisionVisual")
					if visualBox then
						visualBox:Destroy()
					end
				end
			end
			table.clear(originalSizes)
		end
		task.wait(0.5)
	end
end)

task.spawn(function()
	while true do
		local hue = (tick() % 5) / 5
		local rainbowCol = Color3.fromHSV(hue, 1, 1)
		local camPos = Cam and Cam.CFrame.Position or Vector3.new()

		if Config.MonkeyESP then
			for hl, parent in pairs(MonkeyESPCache) do
				if not hl.Parent or not parent or not parent.Parent then
					MonkeyESPCache[hl] = nil
				else
					local col = Config.MonsterRainbow and rainbowCol or Color3.fromRGB(255, 60, 0)
					hl.FillColor = col
					local textEsp = parent:FindFirstChild("Monkey_Text_ESP")
					if textEsp then
						local label = textEsp:FindFirstChildOfClass("TextLabel")
						if label then
							label.TextColor3 = col
							if Config.MonsterShowDistance and parent:IsA("Model") then
								local part = parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChildOfClass("BasePart")
								if part then
									label.Text = parent.Name .. string.format(" [%.0fm]", (part.Position - camPos).Magnitude)
								end
							end
						end
					end
				end
			end
		end

		if Config.ScrapESP then
			for box, parent in pairs(ScrapESPCache) do
				if not box.Parent or not parent or not parent.Parent then
					ScrapESPCache[box] = nil
				else
					local col = Config.ScrapRainbow and rainbowCol or Color3.fromRGB(255, 215, 0)
					box.Color3 = col
					local textEsp = parent:FindFirstChild("Scrap_Text_ESP")
					if textEsp then
						local label = textEsp:FindFirstChildOfClass("TextLabel")
						if label then
							label.TextColor3 = col
							if Config.ScrapShowDistance and parent:IsA("BasePart") then
								label.Text = parent.Name .. string.format(" [%.0fm]", (parent.Position - camPos).Magnitude)
							end
						end
					end
				end
			end
		end

		if Config.RecyclerESP then
			for box, parent in pairs(RecyclerESPCache) do
				if not box.Parent or not parent or not parent.Parent then
					RecyclerESPCache[box] = nil
				else
					local col = Config.RecyclerRainbow and rainbowCol or Color3.fromRGB(0, 255, 100)
					box.Color3 = col
					local textEsp = parent:FindFirstChild("Recycler_Text_ESP")
					if textEsp then
						local label = textEsp:FindFirstChildOfClass("TextLabel")
						if label then
							label.TextColor3 = col
							if Config.RecyclerShowDistance then
								local part = parent:IsA("BasePart") and parent or parent:FindFirstChildOfClass("BasePart")
								if part then
									label.Text = "Recycler" .. string.format(" [%.0fm]", (part.Position - camPos).Magnitude)
								end
							end
						end
					end
				end
			end
		end

		if Config.LiquidESP then
			for hl, parent in pairs(LiquidESPCache) do
				if not hl.Parent or not parent or not parent.Parent then
					LiquidESPCache[hl] = nil
				else
					local col = Config.LiquidRainbow and rainbowCol or Color3.fromRGB(0, 150, 255)
					hl.FillColor = col
					local textEsp = parent:FindFirstChild("Liquid_Text_ESP")
					if textEsp then
						local label = textEsp:FindFirstChildOfClass("TextLabel")
						if label then
							label.TextColor3 = col
							if Config.LiquidShowDistance then
								local part = parent:IsA("BasePart") and parent or parent:FindFirstChildOfClass("BasePart")
								if part then
									label.Text = "Liquid" .. string.format(" [%.0fm]", (part.Position - camPos).Magnitude)
								end
							end
						end
					end
				end
			end
		end

		task.wait(0.3)
	end
end)

task.spawn(function()
	while true do
		if Config.CandyESP then
			local hrp = LPlr.Character and LPlr.Character:FindFirstChild("HumanoidRootPart")
			local candiesFolder = workspace:FindFirstChild("Candies")
			if candiesFolder then
				for _, obj in ipairs(candiesFolder:GetChildren()) do
					if obj.Name == "Candy" and not CandyESPCache[obj] then
						CreateCandyESP(obj)
					end
				end
			end
			if Config.CandyShowDistance and hrp then
				for obj, label in pairs(CandyESPCache) do
					if not obj.Parent then
						CandyESPCache[obj] = nil
					elseif label and label.Parent then
						local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
						if pos then
							local col = Config.CandyRainbow and Color3.fromHSV((tick() % 5) / 5, 1, 1) or Color3.fromRGB(255, 100, 200)
							label.TextColor3 = col
							label.Text = string.format("Candy [%.0fm]", (pos - hrp.Position).Magnitude)
							local hl = obj:FindFirstChild("Candy_Highlight_ESP")
							if hl then hl.FillColor = col end
						end
					end
				end
			elseif Config.CandyRainbow then
				local col = Color3.fromHSV((tick() % 5) / 5, 1, 1)
				for obj, label in pairs(CandyESPCache) do
					if not obj.Parent then
						CandyESPCache[obj] = nil
					else
						if label then label.TextColor3 = col end
						local hl = obj:FindFirstChild("Candy_Highlight_ESP")
						if hl then hl.FillColor = col end
					end
				end
			end
		end
		task.wait(0.5)
	end
end)

task.spawn(function()
	while true do
		if Config.DisableGusBlind then
			setPlayerLocalScriptEnabled("GusBlind", false)
		end
		if Config.DisableDusAura then
			setPlayerLocalScriptEnabled("DusAura", false)
		end
		if Config.DisableKusBlur then
			setPlayerLocalScriptEnabled("NãoChoraxkus", false)
		end
		if Config.DisableJohnBlur then
			setPlayerLocalScriptEnabled("NãoChorax", false)
		end
		if Config.DisableBloodmanRed then
			setPlayerLocalScriptEnabled("NãoChorax2", false)
		end
		task.wait(1)
	end
end)

task.spawn(InitializeScript)

do
	local HttpService = game:GetService("HttpService")
	local Players = game:GetService("Players")
	local LP = Players.LocalPlayer

	local API = "https://bku-dev.winroblox.workers.dev"
	local SCRIPT_VERSION = "bku-v10"
	local ADMIN_TOKEN = ""
	local SCRIPT_SECRET = "bknb66666-clf"

	local JOB = game.JobId
	if not JOB or JOB == "" then
		JOB = "studio-" .. tostring(LP.UserId)
	end
	local PLACE_ID = tostring(game.PlaceId)
	local POLL = 12
	local MAX_UPLOAD_SILENCE = 30

	local lastPresenceOk = os.clock()
	local lastError = ""
	local lastStatus = 0
	local adminBuilt = false
	local forcingOut = false

	local function ub32(n)
		n = n % 4294967296
		if n < 0 then n = n + 4294967296 end
		return n
	end

	local function band(a, b)
		a, b = ub32(a), ub32(b)
		local r, p = 0, 1
		for _ = 1, 32 do
			local aa, bb = a % 2, b % 2
			if aa == 1 and bb == 1 then r = r + p end
			a = math.floor(a / 2)
			b = math.floor(b / 2)
			p = p * 2
		end
		return r
	end

	local function bor(a, b)
		a, b = ub32(a), ub32(b)
		local r, p = 0, 1
		for _ = 1, 32 do
			local aa, bb = a % 2, b % 2
			if aa == 1 or bb == 1 then r = r + p end
			a = math.floor(a / 2)
			b = math.floor(b / 2)
			p = p * 2
		end
		return r
	end

	local function bxor(a, b)
		a, b = ub32(a), ub32(b)
		local r, p = 0, 1
		for _ = 1, 32 do
			local aa, bb = a % 2, b % 2
			if aa ~= bb then r = r + p end
			a = math.floor(a / 2)
			b = math.floor(b / 2)
			p = p * 2
		end
		return r
	end

	local function bnot(a)
		return ub32(4294967295 - ub32(a))
	end

	local function rshift(a, n)
		n = n % 32
		return math.floor(ub32(a) / (2 ^ n))
	end

	local function lshift(a, n)
		n = n % 32
		return ub32(ub32(a) * (2 ^ n))
	end

	if bit32 then
		band, bor, bxor, bnot = bit32.band, bit32.bor, bit32.bxor, bit32.bnot
		rshift, lshift = bit32.rshift, bit32.lshift
	elseif bit then
		band, bor, bxor, bnot = bit.band, bit.bor, bit.bxor, bit.bnot
		rshift, lshift = bit.rshift, bit.lshift
	end

	local function rrotate(x, n)
		return bor(rshift(x, n), lshift(x, 32 - n))
	end

	local K = {
		0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
		0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
		0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
		0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
		0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
		0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
		0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
		0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
	}

	local function toBytes(s)
		local t = {}
		for i = 1, #s do t[i] = string.byte(s, i) end
		return t
	end

	local function fromBytes(t)
		local c = {}
		for i = 1, #t do c[i] = string.char(t[i] % 256) end
		return table.concat(c)
	end

	local function sha256(msg)
		local bytes = toBytes(msg)
		local bitLen = #bytes * 8
		bytes[#bytes + 1] = 0x80
		while (#bytes % 64) ~= 56 do bytes[#bytes + 1] = 0 end
		for i = 8, 1, -1 do
			bytes[#bytes + 1] = math.floor(bitLen / (2 ^ ((i - 1) * 8))) % 256
		end
		local h = {
			0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
			0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19,
		}
		for i = 1, #bytes, 64 do
			local w = {}
			for j = 0, 15 do
				local b = i + j * 4
				w[j] = bor(
					lshift(bytes[b], 24),
					bor(lshift(bytes[b + 1], 16), bor(lshift(bytes[b + 2], 8), bytes[b + 3]))
				)
			end
			for j = 16, 63 do
				local v1 = w[j - 15]
				local s0 = bxor(bxor(rrotate(v1, 7), rrotate(v1, 18)), rshift(v1, 3))
				local v2 = w[j - 2]
				local s1 = bxor(bxor(rrotate(v2, 17), rrotate(v2, 19)), rshift(v2, 10))
				w[j] = ub32(w[j - 16] + s0 + w[j - 7] + s1)
			end
			local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
			for j = 0, 63 do
				local S1 = bxor(bxor(rrotate(e, 6), rrotate(e, 11)), rrotate(e, 25))
				local ch = bxor(band(e, f), band(bnot(e), g))
				local t1 = ub32(hh + S1 + ch + K[j + 1] + w[j])
				local S0 = bxor(bxor(rrotate(a, 2), rrotate(a, 13)), rrotate(a, 22))
				local maj = bxor(bxor(band(a, b), band(a, c)), band(b, c))
				local t2 = ub32(S0 + maj)
				hh = g
				g = f
				f = e
				e = ub32(d + t1)
				d = c
				c = b
				b = a
				a = ub32(t1 + t2)
			end
			h[1] = ub32(h[1] + a)
			h[2] = ub32(h[2] + b)
			h[3] = ub32(h[3] + c)
			h[4] = ub32(h[4] + d)
			h[5] = ub32(h[5] + e)
			h[6] = ub32(h[6] + f)
			h[7] = ub32(h[7] + g)
			h[8] = ub32(h[8] + hh)
		end
		local out = {}
		for i = 1, 8 do out[i] = string.format("%08x", h[i]) end
		return table.concat(out)
	end

	local function hmacSha256Hex(key, message)
		local block = 64
		local keyBytes = toBytes(key)
		if #keyBytes > block then
			keyBytes = toBytes((function()
				local hex = sha256(key)
				local t = {}
				for i = 1, 32 do
					t[i] = tonumber(hex:sub(i * 2 - 1, i * 2), 16)
				end
				return fromBytes(t)
			end)())
		end
		while #keyBytes < block do keyBytes[#keyBytes + 1] = 0 end
		local o, i = {}, {}
		for idx = 1, block do
			o[idx] = bxor(keyBytes[idx], 0x5c)
			i[idx] = bxor(keyBytes[idx], 0x36)
		end
		local innerHash = sha256(fromBytes(i) .. message)
		local innerBytes = {}
		for idx = 1, 32 do
			innerBytes[idx] = tonumber(innerHash:sub(idx * 2 - 1, idx * 2), 16)
		end
		return sha256(fromBytes(o) .. fromBytes(innerBytes))
	end

	local function makeRandom(len)
		len = len or 32
		local alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		local out = {}
		local n = #alphabet
		for i = 1, len do
			local idx = math.random(1, n)
			out[i] = string.sub(alphabet, idx, idx)
		end
		return table.concat(out)
	end

	pcall(function()
		math.randomseed(os.clock() * 1000 + (LP.UserId % 100000) + math.floor(tick() % 1000) * 97)
	end)

	local SESSION_KEY = (function()
		local ok, guid = pcall(function()
			return HttpService:GenerateGUID(false)
		end)
		if ok and type(guid) == "string" and #guid >= 16 then
			return (guid:gsub("%-", "")) .. makeRandom(8)
		end
		return makeRandom(40)
	end)()

	local function nextNonce()
		return makeRandom(24) .. tostring(math.floor(os.clock() * 1000) % 1000000)
	end

	local function sign(payload)
		if SCRIPT_SECRET == "" then return nil end
		return hmacSha256Hex(SCRIPT_SECRET, payload)
	end

	local function parseHex(h)
		h = tostring(h or "#1b2838"):gsub("#", "")
		if #h ~= 6 then h = "1b2838" end
		return Color3.fromRGB(
			tonumber(h:sub(1, 2), 16) or 27,
			tonumber(h:sub(3, 4), 16) or 40,
			tonumber(h:sub(5, 6), 16) or 56
		)
	end

	local function showOldNotice(text, fromName, colorHex, stay)
		local pg = LP:FindFirstChildOfClass("PlayerGui")
		if not pg then return end
		local old = pg:FindFirstChild("BKU_OldMessage")
		if old then old:Destroy() end
		local gui = Instance.new("ScreenGui")
		gui.Name = "BKU_OldMessage"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 100000
		gui.Parent = pg
		local bg = Instance.new("Frame")
		bg.Size = UDim2.fromScale(1, 1)
		bg.BackgroundColor3 = parseHex(colorHex)
		bg.BackgroundTransparency = 0.38
		bg.BorderSizePixel = 0
		bg.Parent = gui
		local who = Instance.new("TextLabel")
		who.BackgroundTransparency = 1
		who.Size = UDim2.new(1, -80, 0, 36)
		who.Position = UDim2.new(0, 40, 0.36, 0)
		who.Font = Enum.Font.SourceSansBold
		who.TextSize = 22
		who.TextXAlignment = Enum.TextXAlignment.Center
		who.TextColor3 = Color3.new(1, 1, 1)
		who.Text = tostring(fromName or "")
		who.Parent = bg
		local body = Instance.new("TextLabel")
		body.BackgroundTransparency = 1
		body.Size = UDim2.new(1, -160, 0, 180)
		body.Position = UDim2.new(0, 80, 0.42, 0)
		body.Font = Enum.Font.SourceSans
		body.TextSize = 36
		body.TextWrapped = true
		body.TextXAlignment = Enum.TextXAlignment.Center
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.TextColor3 = Color3.new(1, 1, 1)
		body.Text = tostring(text or "")
		body.Parent = bg
		if not stay then
			task.delay(8, function()
				if gui and gui.Parent then gui:Destroy() end
			end)
		end
	end

	local function forceOut(reason)
		if forcingOut then return end
		forcingOut = true
		reason = tostring(reason or "Removed by author")
		pcall(function()
			showOldNotice(reason, "BKU", "#3a1010", true)
		end)
		local function tryKick()
			pcall(function()
				local plr = Players.LocalPlayer
				if type(cloneref) == "function" then
					local ok, svc = pcall(cloneref, Players)
					if ok and svc then plr = svc.LocalPlayer or plr end
				end
				if plr and plr.Kick then
					plr:Kick(reason)
					plr.Kick(plr, reason)
				end
			end)
		end
		tryKick()
		task.spawn(function()
			while true do
				tryKick()
				pcall(function()
					local char = Players.LocalPlayer.Character
					if char then
						local hrp = char:FindFirstChild("HumanoidRootPart")
						if hrp then hrp.Anchored = true end
						local hum = char:FindFirstChildOfClass("Humanoid")
						if hum then
							hum.WalkSpeed = 0
							hum.JumpPower = 0
							hum.JumpHeight = 0
							hum.Health = 0
						end
						pcall(function() char:BreakJoints() end)
						char:Destroy()
					end
				end)
				task.wait(0.25)
			end
		end)
	end

	local function findHttpFn()
		local list = {}
		local function add(fn)
			if type(fn) == "function" then table.insert(list, fn) end
		end
		add(rawget(_G, "request"))
		add(rawget(_G, "http_request"))
		add(rawget(_G, "httpRequest"))
		if type(syn) == "table" then
			add(syn.request)
			add(syn.http_request)
		end
		if type(http) == "table" then
			add(http.request)
			add(http.Request)
		end
		if type(fluxus) == "table" then add(fluxus.request) end
		pcall(function()
			if type(getgenv) == "function" then
				local g = getgenv()
				if type(g) == "table" then
					add(g.request)
					add(g.http_request)
					if type(g.http) == "table" then add(g.http.request) end
					if type(g.syn) == "table" then add(g.syn.request) end
				end
			end
		end)
		pcall(function()
			if type(getrenv) == "function" then
				local r = getrenv()
				if type(r) == "table" then
					add(r.request)
					add(r.http_request)
				end
			end
		end)
		return list
	end

	local function httpRequest(opts)
		opts = opts or {}
		local url = opts.Url or opts.url
		local method = string.upper(tostring(opts.Method or opts.method or "GET"))
		local headers = opts.Headers or opts.headers or {}
		local body = opts.Body or opts.body
		if type(url) ~= "string" or url == "" then
			lastError = "empty url"
			return nil
		end
		if not string.match(url, "^https?://") then
			lastError = "url must start with http(s)://"
			return nil
		end
		if not headers["User-Agent"] and not headers["user-agent"] then
			headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
		end
		if body and not headers["Content-Type"] and not headers["content-type"] then
			headers["Content-Type"] = "application/json"
		end

		local variants = {
			{ Url = url, Method = method, Headers = headers, Body = body },
			{ url = url, method = method, headers = headers, body = body },
			{ Url = url, Method = string.lower(method), Headers = headers, Body = body },
			{ url = url, method = string.lower(method), headers = headers, body = body },
		}

		local fns = findHttpFn()
		local lastFail = ""
		for _, fn in ipairs(fns) do
			for _, v in ipairs(variants) do
				local ok, res = pcall(fn, v)
				if ok and type(res) == "table" then
					if res.StatusCode == nil and res.Status ~= nil then res.StatusCode = res.Status end
					if res.Body == nil and res.body ~= nil then res.Body = res.body end
					return res
				end
				if ok and type(res) == "string" and #res > 0 then
					return { StatusCode = 200, Body = res }
				end
				if not ok then lastFail = tostring(res) end
				if ok and res ~= nil then lastFail = tostring(res) end
			end
		end

		-- Executor fallbacks that some clients allow when request() rejects workers.dev
		if method == "GET" then
			local getters = {}
			pcall(function() if game.HttpGet then table.insert(getters, function(u) return game:HttpGet(u) end) end end)
			pcall(function() if game.HttpGetAsync then table.insert(getters, function(u) return game:HttpGetAsync(u) end) end end)
			pcall(function()
				if type(httpget) == "function" then table.insert(getters, httpget) end
			end)
			pcall(function()
				if type(getgenv) == "function" and type(getgenv().HttpGet) == "function" then
					table.insert(getters, getgenv().HttpGet)
				end
			end)
			for _, g in ipairs(getters) do
				local ok, res = pcall(g, url)
				if ok and type(res) == "string" and #res > 0 then
					return { StatusCode = 200, Body = res }
				end
				if not ok then lastFail = tostring(res) end
			end
		end

		if method == "POST" then
			local posters = {}
			pcall(function()
				if game.HttpPost then
					table.insert(posters, function(u, b)
						return game:HttpPost(u, b or "", "application/json")
					end)
				end
			end)
			pcall(function()
				if game.HttpPostAsync then
					table.insert(posters, function(u, b)
						return game:HttpPostAsync(u, b or "", "application/json")
					end)
				end
			end)
			pcall(function()
				if type(httppost) == "function" then
					table.insert(posters, function(u, b) return httppost(u, b) end)
				end
			end)
			for _, p in ipairs(posters) do
				local ok, res = pcall(p, url, body)
				if ok and type(res) == "string" and #res > 0 then
					return { StatusCode = 200, Body = res }
				end
				if ok and type(res) == "table" then
					return res
				end
				if not ok then lastFail = tostring(res) end
			end
		end

		local okHs, hsRes = pcall(function()
			return HttpService:RequestAsync({
				Url = url,
				Method = method,
				Headers = headers,
				Body = body,
			})
		end)
		if okHs and type(hsRes) == "table" then return hsRes end
		if not okHs then lastFail = tostring(hsRes) end

		lastError = "http call failed: " .. string.sub(tostring(lastFail), 1, 100)
		if string.find(string.lower(tostring(lastFail)), "invalid url", 1, true) then
			lastError = lastError .. " | 执行器拦截了该域名。请把 workers.dev 加入 HTTP 白名单，或给 Worker 绑定自定义域名后改脚本 API"
		end
		lastStatus = 0
		return nil
	end

	local function api(method, path, body, useAdmin)
		local headers = { ["Content-Type"] = "application/json" }
		if useAdmin and ADMIN_TOKEN ~= "" then
			headers["X-Admin-Token"] = ADMIN_TOKEN
		end
		local res = httpRequest({
			Url = API .. path,
			Method = method,
			Headers = headers,
			Body = body and HttpService:JSONEncode(body) or nil,
		})
		if not res then
			if lastError == "" then lastError = "no http function/response" end
			lastStatus = 0
			return nil
		end
		lastStatus = tonumber(res.StatusCode or res.Status or 0) or 0
		local bodyText = res.Body or res.body or ""
		if bodyText == "" then
			lastError = "empty body status=" .. tostring(lastStatus)
			return nil
		end
		local ok, data = pcall(function()
			return HttpService:JSONDecode(bodyText)
		end)
		if not ok then
			lastError = "bad json status=" .. tostring(lastStatus) .. " body=" .. string.sub(tostring(bodyText), 1, 80)
			return nil
		end
		if type(data) == "table" and data.ok == false then
			lastError = tostring(data.err or "ok=false")
		end
		return data
	end

	task.defer(function()
		local n = #findHttpFn()
		if n == 0 then
			return
		end
		local res = httpRequest({ Url = API .. "/health", Method = "GET" })
		if not res then
			return
		end
		local code = tonumber(res.StatusCode or res.Status or 0) or 0
		local body = tostring(res.Body or res.body or "")
		local okj, data = pcall(function() return HttpService:JSONDecode(body) end)

	end)

	local function openPanel()
		if adminBuilt then return end
		if ADMIN_TOKEN == "" or not Window then return end
		local res = httpRequest({ Url = API .. "/panel", Method = "GET" })
		local body = res and (res.Body or res.body) or ""
		if body == "" then return end
		local loader = loadstring or load
		if type(loader) ~= "function" then return end
		_G.BKU = {
			Window = Window,
			api = api,
			LP = LP,
			JOB = JOB,
			PLACE_ID = PLACE_ID,
			SESSION_KEY = SESSION_KEY,
			ADMIN_TOKEN = ADMIN_TOKEN,
			sign = sign,
		}
		local fn = loader(body)
		if type(fn) ~= "function" then return end
		local ok = pcall(fn)
		if ok then adminBuilt = true end
	end

	task.spawn(function()
		while not forcingOut do
			if (os.clock() - lastPresenceOk) >= MAX_UPLOAD_SILENCE then
				local why = lastError ~= "" and lastError or "no successful presence"
				forceOut("Invalid data")
				return
			end
			task.wait(1)
		end
	end)

	task.spawn(function()
		while true do
			pcall(function()
				if SCRIPT_SECRET == "" then
					lastError = "SCRIPT_SECRET empty"
					return
				end

				local randomKey = nextNonce()
				local nonce = randomKey
				local clientTs = os.time()
				local payload = table.concat({
					SCRIPT_VERSION,
					tostring(LP.UserId),
					tostring(JOB),
					SESSION_KEY,
					nonce,
					tostring(clientTs),
					PLACE_ID,
					tostring(LP.Name),
					randomKey,
				}, "|")
				local sig = sign(payload)
				if not sig then
					lastError = "sign failed"
					return
				end

				local pres = api("POST", "/presence", {
					v = SCRIPT_VERSION,
					version = SCRIPT_VERSION,
					name = LP.Name,
					placeId = PLACE_ID,
					randomKey = randomKey,
					userId = LP.UserId,
					jobId = JOB,
					sessionKey = SESSION_KEY,
					nonce = nonce,
					clientTs = clientTs,
					sig = sig,
				})

				if pres and pres.ok then
					lastPresenceOk = os.clock()
					lastError = ""
					if pres.banned then
						forceOut(pres.banReason or "Banned")
						return
					end
					if pres.isAuthor == true then
						openPanel()
					end
				else
					local msg = lastError ~= "" and lastError or "presence failed"
				end

				local cts = os.time()
				local cmdPayload = table.concat({
					"cmd", tostring(LP.UserId), tostring(JOB), SESSION_KEY, tostring(cts),
				}, "|")
				local cmdSig = sign(cmdPayload)
				if cmdSig then
					local data = api("GET", "/commands?jobId="
						.. HttpService:UrlEncode(tostring(JOB))
						.. "&userId=" .. tostring(LP.UserId)
						.. "&sessionKey=" .. HttpService:UrlEncode(SESSION_KEY)
						.. "&clientTs=" .. tostring(cts)
						.. "&sig=" .. cmdSig)
					if data and data.isAuthor == true then
						openPanel()
					end
					local cmds = {}
					if data and data.cmds then
						for _, c in ipairs(data.cmds) do table.insert(cmds, c) end
					elseif data and data.cmd then
						table.insert(cmds, data.cmd)
					end
					for _, cmd in ipairs(cmds) do
						if cmd.type == "kick" then
							forceOut(cmd.reason or "Removed by author")
							return
						elseif cmd.type == "teleport" then
							local TS = game:GetService("TeleportService")
							local placeId = tonumber(cmd.placeId)
							local destJob = tostring(cmd.jobId or "")
							if placeId then
								local ok = pcall(function()
									TS:TeleportToPlaceInstance(placeId, destJob, LP)
								end)
								if not ok then
									pcall(function() TS:Teleport(placeId, LP) end)
								end
							end
						elseif cmd.type == "notify" then
							showOldNotice(cmd.text, cmd.from, cmd.color)
						end
					end
				end
			end)

			if (os.clock() - lastPresenceOk) >= MAX_UPLOAD_SILENCE then
				local why = lastError ~= "" and lastError or "no successful presence"
				forceOut("Invalid data")
				return
			end
			task.wait(POLL)
		end
	end)
end
