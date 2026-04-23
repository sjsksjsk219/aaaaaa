if game.PlaceId == 14896802601 then
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local pl = game:GetService("Players").LocalPlayer
local humanoid = pl.Character.Humanoid
local walkSpeedChanged = humanoid:GetPropertyChangedSignal("WalkSpeed")
local lighting = game:GetService("Lighting")
local oFogStart = nil
local oFogEnd = nil
local Flashlight = nil
local monsterList
local oldConnect = nil

local ESPLib = getgenv().mstudio45_ESP or loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
getgenv().mstudio45_ESP = ESPLib
local activeESP = {}
local itemScanRunning = false

local function manageESP(toggle, name, model, colorPicker)
    if toggle then
        if activeESP[name] then activeESP[name]:Destroy() end
        local esp = ESPLib:Add({
            Name = name,
            Model = model,
            ESPType = "Highlight",
            Color = colorPicker.Value,
            FillColor = colorPicker.Value,
            FillTransparency = colorPicker.Transparency,
            OutlineColor = Color3.new(1, 1, 1),
            OutlineTransparency = 0.5,
            Visible = true,
        })
        activeESP[name] = esp
    else
        if activeESP[name] then
            activeESP[name]:Destroy()
            activeESP[name] = nil
        end
    end
end

local function updateESPColor(name, colorPicker)
    if activeESP[name] then
        activeESP[name].CurrentSettings.Color = colorPicker.Value
        activeESP[name].CurrentSettings.FillColor = colorPicker.Value
        activeESP[name].CurrentSettings.FillTransparency = colorPicker.Transparency
    end
end

local monsterWarn = {
    Mutant = function() 
        Library:Notify({
            Title = "警告!  ",
            Description = "Mutant刷新!",
            Time = 4,
            SoundId = 9120383625,
        })
    end
}

local Toggles = Library.Toggles
local Options = Library.Options
local speedHack = false
local speedChange = false

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "XBHUB",
    Footer = "GAME: 住宅大逃杀  Vision: 0.9(Beta)  Location:Night 1",
    Icon = nil,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Center = true,
    AutoShow = true,
    Resizable = false,
})

local Tabs = {
    User = Window:AddTab("首页", "house"),
    Main = Window:AddTab("基本功能", "user"),
    Exploit = Window:AddTab("漏洞利用", "bug"),
}

Tabs.User:UpdateWarningBox({
    Visible = true,
    Title = "更新功能公告",
    Text = "<font color='#FFAA00'>[Night 1]</font>\n<font color='#00FF00'>增加ESP功能</font>",
    IsNormal = true,
})

local LeftUserGroup = Tabs.User:AddLeftGroupbox("玩家信息", "user")
local RightUserGroup = Tabs.User:AddRightGroupbox("脚本信息", "info")

local playerName = pl.Name

local defaultAvatarUrl = "rbxasset://textures/ui/GuiImagePlaceholder.png"
local PlayerImage = LeftUserGroup:AddImage("PlayerAvatar", {
    Image = defaultAvatarUrl,
    Height = 200,
    ScaleType = Enum.ScaleType.Fit,
    Visible = true,
})

local function updateAvatar()
    local userId = pl.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local success, content = pcall(function()
        return game:GetService("Players"):GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    if success and content then
        pcall(function()
            PlayerImage:SetImage(content)
        end)
    end
end

updateAvatar()

LeftUserGroup:AddLabel({
    Text = string.format("您好 <b>%s</b>~，欢迎您使用 XBHUB！", playerName),
    DoesWrap = true,
    RichText = true,
})

RightUserGroup:AddLabel({
    Text = "<font color='#00FF00'>●</font>速度修改\n<font color='#00FF00'>●</font>高亮\n<font color='#00FF00'>●</font>无限体力\n<font color='#00FF00'>●</font>实用功能\n<font color='#00FF00'>●</font>怪物预警\n<font color='#FF0000'>●</font>ESP --物品ESP故障",
    DoesWrap = true,
    RichText = true,
})

local SpeedGroup = Tabs.Main:AddLeftGroupbox("速度", "zap")

SpeedGroup:AddToggle("SpeedHack", {
    Text = "启用速度绕过",
    Default = false,
    DisabledTooltip = "该功能为守护您的安全保持开启",
})

task.spawn(function()
    Toggles.SpeedHack:OnChanged(function()
        if Toggles.SpeedHack.Value then
            for _, v in pairs(getconnections(walkSpeedChanged)) do
                v:Disable()
            end
        end
    end)
end)

Toggles.SpeedHack:SetValue(true)
task.wait(0.2)
Toggles.SpeedHack:SetDisabled(true)
Toggles.SpeedHack.TextLabel.TextTransparency = 0.8

SpeedGroup:AddToggle("SpeedEnabled", {
    Text = "启用速度修改",
    Default = false,
    Callback = function(Value)
        if Value then
            speedChange = true
            if Options.WalkSpeed.Value then
                humanoid.WalkSpeed = Options.WalkSpeed.Value
            end
        else
            speedChange = false
            humanoid.WalkSpeed = 12
        end
    end,
})

SpeedGroup:AddSlider("WalkSpeed", {
    Text = "移动速度",
    Default = 12,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Suffix = "studs/s",
    HideMax = true,
    Compact = false,
    Callback = function(Value)
        if Toggles.SpeedEnabled.Value then
            humanoid.WalkSpeed = Value
        end
    end,
})

SpeedGroup:AddDivider()
SpeedGroup:AddToggle("InfSprint", {
    Text = "无限体力",
    Default = false,
    Callback = function(Value)
        if Value then
            pl.Character.Sprint.Overdrive.Value = 99999999999
        else
            pl.Character.Sprint.Overdrive.Value = 0
        end
    end,
})

SpeedGroup:AddSlider("MaxSprint", {
    Text = "最大体力",
    Default = 16,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        pl.Character.Sprint.Stam:SetAttribute("Max",Value)
    end,
})

SpeedGroup:AddButton({
    Text = "回满体力",
    Func = function()
        pl.Character.Sprint.Stam.Value = pl.Character.Sprint.Stam:GetAttribute("Max")
    end,
    Tooltip = "点击回满体力",
})

local EnvironmentGroup = Tabs.Main:AddRightGroupbox("环境", "sun")

local highBrightnessEnabled = false
local brightnessLevel = 1
local brightnessConnection
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local function updateBrightness()
    if highBrightnessEnabled then
        Lighting.Brightness = brightnessLevel
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end
end

EnvironmentGroup:AddToggle('HighBrightness', {
    Text = '高亮',
    Default = false,
    Tooltip = '全局高亮',
    Callback = function(Value)
        highBrightnessEnabled = Value
        if brightnessConnection then 
            brightnessConnection:Disconnect() 
            brightnessConnection = nil
        end
        if Value then
            brightnessConnection = RunService.RenderStepped:Connect(updateBrightness)
        end
        updateBrightness()
    end
})

EnvironmentGroup:AddToggle("RemoveFog", {
    Text = "无雾霾",
    Default = false,
    Callback = function(Value)
        if Value then
            oFogStart = lighting.FogStart
            oFogEnd = lighting.FogEnd
            
            lighting.FogStart = 100000
            lighting.FogEnd = 100000
        else
            if oFogStart then
                lighting.FogStart = oFogStart
                lighting.FogEnd = oFogEnd
            else
                lighting.FogStart = 0
                lighting.FogEnd = 1000
            end
        end
    end,
})

EnvironmentGroup:AddToggle("RemoveAtmosphere", {
    Text = "移除大气",
    Default = false,
    Risky = true,
    Tooltip = "该功能会导致晚上游戏一直报错,且开启后无法关闭",
    DisabledTooltip = "该功能已被锁定",
})

Toggles.RemoveAtmosphere:OnChanged(function(value)
    if value then
        if lighting:FindFirstChildWhichIsA("Atmosphere") then
            lighting:FindFirstChildWhichIsA("Atmosphere"):Destroy()
        end
        Toggles.RemoveAtmosphere:SetDisabled(true)
        local label = Toggles.RemoveAtmosphere.TextLabel
        label.TextTransparency = 0.8
        
        label:GetPropertyChangedSignal("TextTransparency"):Connect(function()
            if Toggles.RemoveAtmosphere.Disabled then
                label.TextTransparency = 0.8
            end
        end)
    end
end)

local ExploitLeftGroup = Tabs.Exploit:AddLeftGroupbox("实用功能", "flashlight")
ExploitLeftGroup:AddToggle("FlashlightInf", {
    Text = "无限手电筒电量",
    Default = false,
})

Toggles.FlashlightInf:OnChanged(function(Value)
    task.spawn(function()
        while Value and Flashlight == nil do
            Flashlight = pl.Character:FindFirstChild("Flashlight")
            if Flashlight ~= nil then
                Flashlight.Battery.Value = 9999999999
                break
            end
            task.wait(0.1)
        end
    end)
end)

ExploitLeftGroup:AddToggle("InfO2", {
    Text = "无限氧气",
    Risky = true,
    Tooltip = "当发电机没电后会出现视线模糊",
    Default = false,
})

Toggles.InfO2:OnChanged(function(Value)
    if Value then
        pl.Character.Breath.Value = 9999999
    else
        pl.Character.Breath.Value = 20
    end
end)

local ESPGroup = Tabs.Exploit:AddLeftGroupbox("ESP", "eye")

ESPGroup:AddToggle("MutantESP", {
    Text = "Mutant",
    Default = false,
}):AddColorPicker("MutantColor", {
    Default = Color3.new(1, 0, 0),
    Title = "Mutant颜色",
    Transparency = 0.8,
})

--[[
ESPGroup:AddToggle("ItemESP", {
    Text = "物品",
    Default = false,
}):AddColorPicker("ItemColor", {
    Default = Color3.new(0, 1, 0),
    Title = "物品颜色",
    Transparency = 0.8,
})
]]--

Toggles.MutantESP:OnChanged(function(value)
    if value then
        local existing = workspace:FindFirstChild("Mutant")
        if existing and existing:IsA("Model") then
            manageESP(true, "Mutant", existing, Options.MutantColor)
        end
    else
        manageESP(false, "Mutant", nil, nil)
    end
end)

Options.MutantColor:OnChanged(function()
    if activeESP["Mutant"] then
        updateESPColor("Mutant", Options.MutantColor)
    end
end)

--[[
Toggles.ItemESP:OnChanged(function(value)
    if value then
        itemScanRunning = true
        task.spawn(function()
            while itemScanRunning and Toggles.ItemESP.Value do
                for name, esp in pairs(activeESP) do
                    if name:match("^Item_") then
                        esp:Destroy()
                        activeESP[name] = nil
                    end
                end
                local itemSpots = workspace:FindFirstChild("ItemSpots")
                if itemSpots then
                    local itemIndex = 1
                    for _, spot in ipairs(itemSpots:GetChildren()) do
                        local children = spot:GetChildren()
                        if #children >= 3 then
                            for _, child in ipairs(children) do
                                if child.Name == "Equip" or child.Name == "Weld" then return end
                                local handle = child:FindFirstChild("Handle")
                                if handle then
                                    local espName = "Item_" .. itemIndex
                                    manageESP(true, espName, handle, Options.ItemColor)
                                    itemIndex = itemIndex + 1
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
            for name, esp in pairs(activeESP) do
                if name:match("^Item_") then
                    esp:Destroy()
                    activeESP[name] = nil
                end
            end
        end)
    else
        itemScanRunning = false
        for name, esp in pairs(activeESP) do
            if name:match("^Item_") then
                esp:Destroy()
                activeESP[name] = nil
            end
        end
    end
end)
]]--

Options.ItemColor:OnChanged(function()
    for name, esp in pairs(activeESP) do
        if name:match("^Item_") then
            esp.CurrentSettings.Color = Options.ItemColor.Value
            esp.CurrentSettings.FillColor = Options.ItemColor.Value
            esp.CurrentSettings.FillTransparency = Options.ItemColor.Transparency
        end
    end
end)

local ExploitRightGroup = Tabs.Exploit:AddRightGroupbox("怪物预警", "bell")

ExploitRightGroup:AddDropdown("MonsterList", {
    Values = {"Mutant"},
    Default = {"Mutant"},
    Multi = true,
    Text = "怪物列表",
    Callback = function(Value)
        monsterList = Value
    end,
})

ExploitRightGroup:AddToggle("AlertEnabled", {
    Text = "启用预警",
    Default = false,
})

Toggles.AlertEnabled:OnChanged(function(value)
    task.spawn(function()
        if oldConnect then
            oldConnect:Disconnect()
            oldConnect = nil
        end
        
        if monsterList == nil then
            monsterList = Options.MonsterList.Value
        end
        
        oldConnect = workspace.ChildAdded:Connect(function(newPart)
            if value and newPart:IsA("Model") then
                for name, _ in pairs(monsterList) do
                    if newPart.Name == name then
                        local warn = monsterWarn[newPart.Name]
                        warn()
                        if name == "Mutant" and Toggles.MutantESP.Value then
                            manageESP(true, "Mutant", newPart, Options.MutantColor)
                        end
                        break
                    end
                end
            end
        end)
    end)
end)

local UISettingsTab = Window:AddTab("UI设置", "settings")
local MenuGroup = UISettingsTab:AddLeftGroupbox("菜单", "wrench")

MenuGroup:AddToggle("CustomCursor", { Text = "自定义光标", Default = true, Callback = function(v) Library.ShowCustomCursor = v end })
MenuGroup:AddDropdown("DPIScale", { Values = { "50%", "75%", "100%", "125%", "150%" }, Default = "100%", Text = "UI缩放", Callback = function(v) Library:SetDPIScale(tonumber(v:gsub("%%", "")) / 100) end })
MenuGroup:AddLabel("菜单快捷键"):AddKeyPicker("MenuToggleKey", { Default = "RightShift", NoUI = true, Text = "快捷键", Mode = "Toggle" })

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuToggleKey" })
ThemeManager:SetFolder("XBHub/Themes")
SaveManager:SetFolder("XBHub/Config")
SaveManager:BuildConfigSection(UISettingsTab)
ThemeManager:ApplyToTab(UISettingsTab)
SaveManager:LoadAutoloadConfig()

Library.ToggleKeybind = Options.MenuToggleKey

Library:OnUnload(function()
    itemScanRunning = false
    if brightnessConnection then
        brightnessConnection:Disconnect()
    end
    if oldConnect then
        oldConnect:Disconnect()
    end
    highBrightnessEnabled = false
    updateBrightness()
end)

else
    game:GetService("Players").LocalPlayer:Kick("暂不支持此游戏脚本")
end
