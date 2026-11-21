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

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/xdigb91/theme/refs/heads/main/XJWuicore.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/xdigb91/theme/refs/heads/main/XJWuitheme.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/xdigb91/theme/refs/heads/main/XJWuideploy.lua'))()

local Window = Library:CreateWindow({
    Title = "<font color='#FF69B4'>X</font><font color='#87CEEB'>J</font><font color='#4169E1'>W</font>",
    Footer = "<font color='#FF69B4'>X</font><font color='#87CEEB'>J</font><font color='#4169E1'>W</font> | 肌肉联合 | 作者：i",
    ShowCustomCursor = true,
})

local Tabs = {}

local keySeq = 0
local function newKey(tag)
    keySeq = keySeq + 1
    return tag .. tostring(keySeq)
end

local function labelSet(label, text)
    if label == nil then return end
    if pcall(function() label:Set(text) end) then return end
    pcall(function() label:SetText(text) end)
end

local function createTabProxy(title)
    local tabName = tostring(title or '功能')
    local tab = Window:AddTab(tabName)
    local left = tab:AddLeftGroupbox(tabName)
    local right
    local function getRight()
        if not right then right = tab:AddRightGroupbox('信息') end
        return right
    end

    local proxy = {}

    function proxy:Toggle(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddToggle(newKey('TG'), {
                Text = tostring(opt.Title or '开关'),
                Default = opt.Value == true,
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Slider(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddSlider(newKey('SL'), {
                Text = tostring(opt.Title or '滑块'),
                Min = opt.Min or 0,
                Max = opt.Max or 100,
                Default = opt.Value or opt.Default or 0,
                Rounding = 0,
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Input(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddInput(newKey('IN'), {
                Text = tostring(opt.Title or '输入'),
                Default = tostring(opt.Value or opt.Default or ''),
                Placeholder = tostring(opt.Placeholder or ''),
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Dropdown(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddDropdown(newKey('DD'), {
                Text = tostring(opt.Title or '选择'),
                Values = opt.Values or {},
                Default = opt.Default,
                Multi = false,
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Button(opt)
        opt = opt or {}
        pcall(function()
            left:AddButton(tostring(opt.Title or '按钮'), function()
                if opt.Callback then opt.Callback() end
            end)
        end)
    end

    function proxy:Paragraph(opt)
        opt = opt or {}
        local prefix = tostring(opt.Title or '')
        local label
        pcall(function()
            label = getRight():AddLabel(prefix ~= '' and (prefix .. ': ' .. tostring(opt.Desc or '')) or tostring(opt.Desc or ''))
        end)
        local obj = {}
        function obj:SetDesc(text)
            labelSet(label, prefix ~= '' and (prefix .. ': ' .. tostring(text)) or tostring(text))
        end
        function obj:Set(text)
            labelSet(label, tostring(text))
        end
        return obj
    end

    return proxy
end

local XJWShadow = {}

function XJWShadow:AddTheme()

end

function XJWShadow:Notify(opt)
    opt = opt or {}
    local txt
    if opt.Content ~= nil and opt.Title ~= nil then
        txt = tostring(opt.Title) .. ': ' .. tostring(opt.Content)
    else
        txt = tostring(opt.Title or opt.Content or '通知')
    end
    pcall(function() Library:Notify(txt, opt.Duration or 3) end)
end

function XJWShadow:CreateWindow()
    local win = {}
    function win:Tab(opt)
        return createTabProxy(opt and opt.Title)
    end
    function win:Tag() end
    function win:Destroy()
        pcall(function() Library:Unload() end)
    end
    return win
end

local loadMainScript
loadMainScript = function(WindUI)
    local P=game:GetService("Players") local L=P.LocalPlayer local U=game:GetService("UserInputService") local R=game:GetService("ReplicatedStorage") local W=game:GetService("Workspace") local V=game:GetService("VirtualInputManager") local G=game:GetService("Lighting")
    local R0=true local a1,a2,a3,a4,a5,a6,a8,a9,a10=false,false,false,false,false,false,false,false,false
    local rbCount=10000
    local M=L:WaitForChild("muscleEvent",15) local RE=R:WaitForChild("rEvents",10)
    local RB=RE and RE:WaitForChild("rebirthRemote",10) local OC=RE and RE:WaitForChild("openCrystalRemote",10) local MF=W:WaitForChild("machinesFolder",10) local TP=Vector3.new(-655,23,-967)

    local crystalArgs = {"openCrystal", "Blaze Crystal", {"Golden Pheonix"}}

    for _,v in pairs(W:GetChildren()) do if string.find(string.lower(v.Name),"windui") then v:Destroy() end end

    WindUI:AddTheme({Name="DarkRed",Text=Color3.fromHex("#FFFFFF"),Accent=Color3.fromHex("#FF0000"),Background=Color3.fromHex("#000000"),Button=Color3.fromHex("#1A0000"),Icon=Color3.fromHex("#FF0000"),Outline=Color3.fromHex("#8B0000"),Placeholder=Color3.fromHex("#FF6666")})
    local Win=WindUI:CreateWindow({Title="XJW 肌肉联合",Author="XJW",Folder="XJW",HideSearchBar=true,Icon="dumbbell",KeySystem=false,MaxSize=Vector2.new(520,420),MinSize=Vector2.new(520,420),NoResize=true,OpenButton={Title="XJW 肌肉联合",Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("000000")),ColorSequenceKeypoint.new(1,Color3.fromHex("FF0000"))}),CornerRadius=UDim.new(0,16),Draggable=true,Enabled=true,Icon="dumbbell"},Resizable=false,ScrollBarEnabled=true,Size=UDim2.fromOffset(520,420),Theme="DarkRed",Transparent=false})

    Win:Tag({Title="XJW",Color=Color3.fromHex("#FF0000")})

    pcall(function()
        WindUI:Notify({
            Title = "XJW 加载成功",
            Content = "XJW 肌肉联合已就绪",
            Duration = 3
        })
    end)

    local oD=Win.Destroy
    Win.Destroy=function(s,...)R0=false;a1,a2,a3,a4,a5,a6,a8,a9,a10=false,false,false,false,false,false,false,false,false;return oD(s,...)end
    L.Idled:Connect(function()V:SendKeyEvent(true,Enum.KeyCode.Y,false,game);task.wait(0.05);V:SendKeyEvent(false,Enum.KeyCode.Y,false,game)end)

    local T1=Win:Tab({Title="主要挂机",Icon="zap"})
    T1:Input({Title="自定义重生数量",Placeholder="输入数值后按回车生效",Value="10000",Callback=function(t)local num=tonumber(t) if num and num>0 then rbCount=num end end})
    T1:Toggle({Title="智能循环重生",Value=false,Callback=function(s)a1=s;if s then task.spawn(function()while a1 and R0 do local success=false pcall(function()local ls=L:FindFirstChild("leaderstats") local beforeReb=ls and ls:FindFirstChild("Rebirths") and ls.Rebirths.Value if RB and beforeReb then RB:InvokeServer("massRebirthRequest", rbCount) task.wait(0.1) local afterReb=ls.Rebirths.Value if afterReb>beforeReb then success=true end end end) if success then task.wait(0.1) else task.wait(1) end end end)end end})
    T1:Toggle({Title="自定义重生+俯卧撑",Value=false,Callback=function(s)a2=s;if s then task.spawn(function()while a2 and R0 do pcall(function()if RB then RB:InvokeServer("massRebirthRequest",rbCount)end;local c=L.Character;local b=L:FindFirstChild("Backpack");if c and c:FindFirstChild("Humanoid") and b then local p=b:FindFirstChild("Pushups");if p then c.Humanoid:EquipTool(p)end;for i=1,50 do M:FireServer("rep")end end end);task.wait(0.1)end end)end end})

    T1:Toggle({Title="卡宠(无视攻击)",Value=false,Callback=function(s)a8=s;if s then task.spawn(function()
        while a8 and R0 do
            pcall(function()
                local c=L.Character
                local h=c and c:FindFirstChild("HumanoidRootPart")
                local r=MF and MF:FindFirstChild("Glitch Rock")
                if not r and MF then
                    local sc,ch=pcall(function()return MF:GetChildren()[161]end)
                    if sc and ch then r=ch end
                end
                if h and M then
                    if r and r:FindFirstChild("Rock") then
                        h.CFrame=CFrame.lookAt(TP,r.Rock.Position)
                    else
                        h.CFrame=CFrame.new(TP)
                    end
                    local b=L:FindFirstChild("Backpack")
                    if c and b then
                        local p=b:FindFirstChild("Punch") or c:FindFirstChild("Punch")
                        if p and p.Parent==b then c.Humanoid:EquipTool(p) end
                        if p then p:Activate() end
                    end
                    M:FireServer("punch","rightHand")
                    M:FireServer("punch","leftHand")
                end
            end)
            task.wait()
        end
    end)end end})

    T1:Button({Title="【强制结束】",Color=Color3.fromHex("#FF0000"),Callback=function()R0=false;a1,a2,a3,a4,a5,a6,a8,a9,a10=false,false,false,false,false,false,false,false,false;Win:Destroy()end})

    local IP=T1:Paragraph({Title="玩家信息",Desc="加载中..."})
    task.spawn(function()while R0 do task.wait(1);local ls=L:FindFirstChild("leaderstats");local st=ls and ls:FindFirstChild("Strength");local rb=ls and ls:FindFirstChild("Rebirths");if st and rb then local sv=st.Value;if type(sv)=="number" and sv>1000000 then sv=string.format("%.2fM",sv/1000000)end;IP:SetDesc(string.format("玩家: %s\n力量: %s\n重生: %s",L.Name,tostring(sv),tostring(rb.Value)))end end end)

    local T2=Win:Tab({Title="自动锻炼",Icon="activity"})
    local sel="哑铃"
    T2:Dropdown({Title="选择类型",Default="哑铃",Values={"哑铃","倒立","仰卧起坐","俯卧撑"},Callback=function(v)sel=v end})
    T2:Toggle({Title="开启自动锻炼",Value=false,Callback=function(s)a5=s;if s then task.spawn(function()while a5 and R0 do pcall(function()local c=L.Character;local b=L:FindFirstChild("Backpack");if c and b then M:FireServer("rep");local tn="";if sel=="哑铃" then tn="Weight"elseif sel=="倒立" then tn="Handstands"elseif sel=="仰卧起坐" then tn="Situps"elseif sel=="俯卧撑" then tn="Pushups"end;if tn~="" then local t=b:FindFirstChild(tn);if t then c.Humanoid:EquipTool(t)end end end end);task.wait(0.1)end end)end end})
    T2:Toggle({Title="快速锻炼",Value=false,Callback=function(s)a6=s;if s then task.spawn(function()while a6 and R0 do pcall(function()local c=L.Character;local b=L:FindFirstChild("Backpack");if c and b then for i=1,120 do M:FireServer("rep")end;local tn="";if sel=="哑铃" then tn="Weight"elseif sel=="倒立" then tn="Handstands"elseif sel=="仰卧起坐" then tn="Situps"elseif sel=="俯卧撑" then tn="Pushups"end;if tn~="" and b:FindFirstChild(tn) then c.Humanoid:EquipTool(b[tn])end end end);task.wait()end end)end end})

    local T3=Win:Tab({Title="高级战斗",Icon="sword"})
    T3:Toggle({Title="传送秒杀全部玩家",Value=false,Callback=function(s)a9=s;if s then task.spawn(function()while a9 and R0 do for _, p in ipairs(P:GetPlayers()) do if p ~= L and p.Character then local char=p.Character local head=char:FindFirstChild("Head") local targetHRP=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChild("Humanoid") local myChar=L.Character local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart") if head and targetHRP and hum and hum.Health > 0 and myHRP then pcall(function()myHRP.CFrame=targetHRP.CFrame * CFrame.new(0, 0, 2)task.wait(0.01)if myChar:FindFirstChild("Humanoid") then local bp=L:FindFirstChild("Backpack") local punch=bp and bp:FindFirstChild("Punch") or myChar:FindFirstChild("Punch") if punch then myChar.Humanoid:EquipTool(punch)punch:Activate()end local lh=myChar:FindFirstChild("LeftHand") if lh then firetouchinterest(head, lh, 0)task.wait(0.01)firetouchinterest(head, lh, 1)M:FireServer("punch", "leftHand")M:FireServer("punch", "rightHand")end end end)end end end task.wait(0.15)end end)end end})

    local T4=Win:Tab({Title="传送",Icon="map-pin"})
    local tps={{"大厅",Vector3.new(-0.75,90.61,242.78)},{"小岛",Vector3.new(-32.13,8.51,1904.41)},{"冰霜",Vector3.new(-2623.4,6.99,-409.3)},{"神话",Vector3.new(2250.3,6.99,1072.7)},{"永恒",Vector3.new(-6758.3,6.99,-1284.4)},{"传奇",Vector3.new(4603.3,990.9,-3897.4)},{"肌肉之王",Vector3.new(-8625.4,16.9,-5730.4)},{"丛林",Vector3.new(-8685.0,5.9,2392.0)},{"无转盘岛",Vector3.new(1952.0,1,6179.9)},{"熔岩",Vector3.new(4472.5,118.9,-8848.5)},{"沙漠",Vector3.new(973.6,15.9,-7277.0)},{"海滩",Vector3.new(-1880.8,15.8,-6137.7)},{"故障岩",TP}}
    for _,tp in ipairs(tps) do T4:Button({Title=tp[1],Callback=function()local c=L.Character;if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame=CFrame.new(tp[2])end end})end

    local T5=Win:Tab({Title="宠物/其他",Icon="cat"})

    T5:Dropdown({
        Title = "选择水晶",
        Default = "伏特水晶",
        Values = {"蓝色水晶", "绿色水晶", "冰霜水晶", "神话水晶", "伏特水晶", "传奇水晶", "地狱水晶", "肌肉之王", "丛林水晶", "水上健身房", "红绿龙抽奖"},
        Callback = function(v)
            if v == "蓝色水晶" then crystalArgs = {"openCrystal", "Blue Crystal", {}}
            elseif v == "绿色水晶" then crystalArgs = {"openCrystal", "Green Crystal", {}}
            elseif v == "冰霜水晶" then crystalArgs = {"openCrystal", "Frost Crystal", {}}
            elseif v == "神话水晶" then crystalArgs = {"openCrystal", "Mythical Crystal", {"Golden Pheonix"}}
            elseif v == "伏特水晶" then crystalArgs = {"openCrystal", "Blaze Crystal", {"Golden Pheonix"}}
            elseif v == "传奇水晶" then crystalArgs = {"openCrystal", "Muscle Elite Crystal", {"Golden Pheonix"}}
            elseif v == "地狱水晶" then crystalArgs = {"openCrystal", "Inferno Crystal", {}}
            elseif v == "肌肉之王" then crystalArgs = {"openCrystal", "Galaxy Oracle Crystal", {}}
            elseif v == "丛林水晶" then crystalArgs = {"openCrystal", "Jungle Crystal", {}}
            elseif v == "水上健身房" then crystalArgs = {"openCrystal", "Water Crystal", {}}
            elseif v == "红绿龙抽奖" then crystalArgs = {"openCrystal", "Inner Peace Crystal", {}}
            end
        end
    })

    T5:Toggle({Title="极速抽水晶",Value=false,Callback=function(s)local isFastDraw=s;if s then local function fastDrawLoop()while isFastDraw and R0 do pcall(function()if OC then OC:InvokeServer(unpack(crystalArgs))end end)task.wait(0.01)end end for i=1,5 do task.spawn(fastDrawLoop)end end end})

    T5:Paragraph({Title="提示", Desc="抽奖需要站在水晶旁边"})

    local wheelRunning = false
    T5:Toggle({Title="自动抽幸运轮盘",Value=false,Callback=function(s)
        wheelRunning = s
        if s then
            task.spawn(function()
                local WRemote = RE and RE:WaitForChild("openFortuneWheelRemote", 10)
                local WChances = R and R:FindFirstChild("fortuneWheelChances")
                if not WRemote or not WChances then
                    WindUI:Notify({Title="错误",Content="找不到轮盘事件或参数!",Duration=3})
                    wheelRunning = false
                    return
                end
                while wheelRunning and R0 do
                    pcall(function()
                        WRemote:InvokeServer("openFortuneWheel", WChances["Fortune Wheel"])
                    end)
                    task.wait(0.01)
                end
            end)
        end
    end})

    T5:Button({Title="清空特效",Callback=function()G.Brightness=0 G.GlobalShadows=false for _,v in ipairs(W:GetDescendants())do if v:IsA("ParticleEmitter")or v:IsA("Fire")or v:IsA("Smoke")then v:Destroy()end end WindUI:Notify({Title="清空",Content="已清理",Duration=2})end})
end

if not game:IsLoaded() then game.Loaded:Wait() end

local okStart, errStart = pcall(function()
    loadMainScript(XJWShadow)
end)

Tabs.Settings = Window:AddTab('设置')

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
    pcall(function() Library:Unload() end)
end)

local InfoGroup = Tabs.Settings:AddRightGroupbox('信息')
InfoGroup:AddLabel('=== XJW ===')
InfoGroup:AddLabel('版本: 1.0.0')
InfoGroup:AddLabel('作者: i')
InfoGroup:AddDivider()
InfoGroup:AddLabel('菜单快捷键: RightShift')

pcall(function() Library.ToggleKeybind = 'RightShift' end)
pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({}) end)
pcall(function() ThemeManager:SetFolder('XJWUI_Muscle') end)
pcall(function() SaveManager:SetFolder('XJWUI_Muscle/config') end)
pcall(function() SaveManager:SetSubFolder('GMVersion') end)
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
    pcall(function() Library:SetWatermark(('XJW | %d fps'):format(math.floor(fps))) end)
end)

if okStart then
    pcall(function() Library:Notify('XJW 界面加载完成', 3) end)
else
    pcall(function() Library:Notify('脚本初始化失败: ' .. tostring(errStart), 5) end)
    warn('[GM-XJW] 初始化失败: ' .. tostring(errStart))
end

local env = (getgenv and getgenv()) or _G
env.XJWUI_GM = {
    Library = Library,
    Unload = function()
        pcall(function() Library:Unload() end)
    end,
}
