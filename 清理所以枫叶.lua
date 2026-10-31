local __XJW_LIB_CACHE = "xjw_windui_lib.lua"
local __XJW_LIB_URLS = {
    "https://cdn.jsdelivr.net/gh/finendss/VowLibrary@main/WINDUI.lua",
    "https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua",
}
local __XJW_ICON_SRC = [==[
-- This is a new version

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local function IsExploit()
	return request and true or false
end

local function Get(url)
	if IsExploit() then
		return game:HttpGet(url)
	else
		local Success, Result = pcall(function()
			return HttpService:GetAsync(url)
		end)
		if Success then
			return Result
		else
			return ReplicatedStorage:WaitForChild("Request", 9999):InvokeServer({ Url = url })
		end
	end
end

local function Loadstring(src)
	if not IsExploit() and ReplicatedStorage:WaitForChild("Loadstring", 9999) then
		return function()
			return ReplicatedStorage:WaitForChild("Loadstring", 9999):InvokeServer(src)
		end
	else
		return loadstring(src)
	end
end

local IconModule = {
	IconsType = "lucide",

	New = nil,
	IconThemeTag = nil,

	Icons = {
		lucide = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua")
		)() or require("./lucide/dist/Icons"),
		solar = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua")
		)() or require("./solar/dist/Icons"),
		craft = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
		)() or require("./craft/dist/Icons"),
		geist = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
		)() or require("./geist/dist/Icons"),
		sfsymbols = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")
		)() or require("./sfsymbols/dist/Icons"),
		gravity = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua")
		)() or require("./gravity/dist/Icons"),
	},
}

local function parseIconString(iconString)
	if type(iconString) == "string" then
		local splitIndex = iconString:find(":")
		if splitIndex then
			local iconType = iconString:sub(1, splitIndex - 1)
			local iconName = iconString:sub(splitIndex + 1)
			return iconType, iconName
		end
	end
	return nil, iconString
end

function IconModule.AddIcons(packName, iconsData)
	if type(packName) ~= "string" or type(iconsData) ~= "table" then
		error("AddIcons: packName must be string, iconsData must be table")
		return
	end

	if not IconModule.Icons[packName] then
		IconModule.Icons[packName] = {
			Icons = {},
			Spritesheets = {},
		}
	end

	for iconName, iconValue in pairs(iconsData) do
		if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
			local imageId = iconValue
			if type(iconValue) == "number" then
				imageId = "rbxassetid://" .. tostring(iconValue)
			end

			IconModule.Icons[packName].Icons[iconName] = {
				Image = imageId,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectPosition = Vector2.new(0, 0),
				Parts = nil,
			}
			IconModule.Icons[packName].Spritesheets[imageId] = imageId
		elseif type(iconValue) == "table" then
			if iconValue.Image and iconValue.ImageRectSize and iconValue.ImageRectPosition then
				local imageId = iconValue.Image
				if type(imageId) == "number" then
					imageId = "rbxassetid://" .. tostring(imageId)
				end

				IconModule.Icons[packName].Icons[iconName] = {
					Image = imageId,
					ImageRectSize = iconValue.ImageRectSize,
					ImageRectPosition = iconValue.ImageRectPosition,
					Parts = iconValue.Parts,
				}

				if not IconModule.Icons[packName].Spritesheets[imageId] then
					IconModule.Icons[packName].Spritesheets[imageId] = imageId
				end
			else
				warn("AddIcons: Invalid spritesheet data format for icon '" .. iconName .. "'")
			end
		else
			warn("AddIcons: Unsupported data type for icon '" .. iconName .. "': " .. type(iconValue))
		end
	end
end

function IconModule.SetIconsType(iconType)
	IconModule.IconsType = iconType
end

function IconModule.Init(New, IconThemeTag)
	IconModule.New = New
	IconModule.IconThemeTag = IconThemeTag

	return IconModule
end

function IconModule.Icon(Icon, Type, DefaultFormat)
	DefaultFormat = DefaultFormat ~= false
	local iconType, iconName = parseIconString(Icon)

	local targetType = iconType or Type or IconModule.IconsType
	local targetName = iconName

	local iconSet = IconModule.Icons[targetType]

	if iconSet and iconSet.Icons and iconSet.Icons[targetName] then
		return {
			iconSet.Spritesheets[tostring(iconSet.Icons[targetName].Image)],
			iconSet.Icons[targetName],
		}
	elseif iconSet and iconSet[targetName] and string.find(iconSet[targetName], "rbxassetid://") then
		return DefaultFormat
				and {
					iconSet[targetName],
					{ ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) },
				}
			or iconSet[targetName]
	end
	return nil
end

function IconModule.GetIcon(Icon, Type)
	return IconModule.Icon(Icon, Type, false)
end

function IconModule.Icon2(Icon, Type, DefaultFormat)
	return IconModule.Icon(Icon, Type, true)
end

function IconModule.Image(IconConfig)
	local Icon = {
		Icon = IconConfig.Icon or nil,
		Type = IconConfig.Type,
		Colors = IconConfig.Colors or { (IconModule.IconThemeTag or Color3.new(1, 1, 1)), Color3.new(1, 1, 1) },
		Size = IconConfig.Size or UDim2.new(0, 24, 0, 24),

		IconFrame = nil,
	}

	local Colors = {}

	for _, color in next, Icon.Colors do
		Colors[_] = {
			ThemeTag = typeof(color) == "string" and color,
			Color = typeof(color) == "Color3" and color,
		}
	end

	local IconLabel = IconModule.Icon2(Icon.Icon, Icon.Type)
	local isrbxassetid = typeof(IconLabel) == "string" and string.find(IconLabel, "rbxassetid://")

	if IconModule.New then
		local New = IconModule.New

		local IconFrame = New("ImageLabel", {
			Size = Icon.Size,
			BackgroundTransparency = 1,
			ImageColor3 = Colors[1].Color or nil,
			ThemeTag = Colors[1].ThemeTag and {
				ImageColor3 = Colors[1].ThemeTag,
			},
			Image = isrbxassetid and IconLabel or IconLabel[1],
			ImageRectSize = isrbxassetid and nil or IconLabel[2].ImageRectSize,
			ImageRectOffset = isrbxassetid and nil or IconLabel[2].ImageRectPosition,
		})

		if not isrbxassetid and IconLabel[2].Parts then
			for _, part in next, IconLabel[2].Parts do
				local IconPartLabel = IconModule.Icon(part, Icon.Type)

				local IconPart = New("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ImageColor3 = Colors[1 + _].Color or nil,
					ThemeTag = Colors[1 + _].ThemeTag and {
						ImageColor3 = Colors[1 + _].ThemeTag,
					},
					Image = IconPartLabel[1],
					ImageRectSize = IconPartLabel[2].ImageRectSize,
					ImageRectOffset = IconPartLabel[2].ImageRectPosition,
					Parent = IconFrame,
				})
			end
		end

		Icon.IconFrame = IconFrame
	else
		local IconFrame = Instance.new("ImageLabel")
		IconFrame.Size = Icon.Size
		IconFrame.BackgroundTransparency = 1
		IconFrame.ImageColor3 = Colors[1].Color
		IconFrame.Image = isrbxassetid and IconLabel or IconLabel[1]
		IconFrame.ImageRectSize = isrbxassetid and nil or IconLabel[2].ImageRectSize
		IconFrame.ImageRectOffset = isrbxassetid and nil or IconLabel[2].ImageRectPosition

		if not isrbxassetid and IconLabel[2].Parts then
			for _, part in next, IconLabel[2].Parts do
				local IconPartLabel = IconModule.Icon(part, Icon.Type)

				local IconPart = Instance.New("ImageLabel")
				IconPart.Size = UDim2.new(1, 0, 1, 0)
				IconPart.BackgroundTransparency = 1
				IconPart.ImageColor3 = Colors[1 + _].Color
				IconPart.Image = IconPartLabel[1]
				IconPart.ImageRectSize = IconPartLabel[2].ImageRectSize
				IconPart.ImageRectOffset = IconPartLabel[2].ImageRectPosition
				IconPart.Parent = IconFrame
			end
		end

		Icon.IconFrame = IconFrame
	end

	return Icon
end

return IconModule

]==]

local __XJW_PG = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
local __XJW_TipLabel = nil
if __XJW_PG then
    local __XJW_Gui = Instance.new("ScreenGui")
    __XJW_Gui.Name = "XJW_LoadTip"
    __XJW_Gui.ResetOnSpawn = false
    __XJW_Gui.IgnoreGuiInset = true
    local __XJW_Lbl = Instance.new("TextLabel")
    __XJW_Lbl.Size = UDim2.new(0, 430, 0, 0)
    __XJW_Lbl.AutomaticSize = Enum.AutomaticSize.Y
    __XJW_Lbl.Position = UDim2.new(0, 20, 0, 90)
    __XJW_Lbl.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    __XJW_Lbl.BackgroundTransparency = 0.15
    __XJW_Lbl.TextColor3 = Color3.fromRGB(255, 220, 120)
    __XJW_Lbl.TextSize = 16
    __XJW_Lbl.TextWrapped = true
    __XJW_Lbl.Text = "清理所有枫叶：正在加载界面库..."
    __XJW_Lbl.Parent = __XJW_Gui
    __XJW_Gui.Parent = __XJW_PG
    __XJW_TipLabel = __XJW_Lbl
end

local function __XJW_SetTip(txt)
    if __XJW_TipLabel then
        __XJW_TipLabel.Text = "清理所有枫叶：" .. tostring(txt)
    end
end

local __XJW_SRC = nil
if isfile and isfile(__XJW_LIB_CACHE) then
    local __ok, __data = pcall(function() return readfile(__XJW_LIB_CACHE) end)
    if __ok and type(__data) == "string" and #__data > 50000 then
        __XJW_SRC = __data
    end
end

if not __XJW_SRC then
    for __i = 1, #__XJW_LIB_URLS do
        __XJW_SetTip("正在联网取界面库 " .. tostring(__i) .. "/" .. tostring(#__XJW_LIB_URLS) .. "（约 270KB，请稍候）...")
        local __ok, __data = pcall(function() return game:HttpGet(__XJW_LIB_URLS[__i]) end)
        if __ok and type(__data) == "string" and #__data > 50000 then
            __XJW_SRC = __data
            if writefile then
                pcall(function() writefile(__XJW_LIB_CACHE, __data) end)
            end
            break
        end
    end
    if not __XJW_SRC then
        __XJW_SetTip("界面库取回失败，请检查网络后重新执行一次")
        return
    end
end

local __XJW_MARK = "loadstring(\ngame.HttpGetAsync and game:HttpGetAsync(l)or h:GetAsync(l)\n)()"
local __XJW_A, __XJW_B = __XJW_SRC:find(__XJW_MARK, 1, true)
if __XJW_A and #__XJW_ICON_SRC > 1000 then
    __XJW_SRC = __XJW_SRC:sub(1, __XJW_A - 1) .. "loadstring([==[\n" .. __XJW_ICON_SRC .. "\n]==])()" .. __XJW_SRC:sub(__XJW_B + 1)
end

local __XJW_LIBOK, WindUI = pcall(function() return loadstring(__XJW_SRC)() end)
if not __XJW_LIBOK or type(WindUI) ~= "table" then
    __XJW_SetTip("界面库加载失败：" .. tostring(WindUI))
    return
end
__XJW_SetTip("界面库加载成功")
task.delay(4, function()
    if __XJW_TipLabel and __XJW_TipLabel.Parent then
        __XJW_TipLabel.Parent:Destroy()
    end
end)


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
    Icon = "leaf",
    Author = "XJW",
    Folder = "LeafAutoFarm",
    Size = UDim2.fromOffset(430, 480),
    Theme = "Pink",
    HideSearchBar = false,
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
        warn("[树叶自动拾取] 未找到 workspace.Map.Dumpsters.Dumpster，已回退为原动态选择逻辑。")
        return nil
    end
    local pos = getDumpsterPos(target)
    if not pos then
        warn("[树叶自动拾取] workspace.Map.Dumpsters.Dumpster 无有效位置，已回退为原动态选择逻辑。")
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
