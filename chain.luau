if game.PlaceId == 13977939077 then
  --这是个开源脚本
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local pl = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local humanoid = pl.Character.Humanoid
local lighting = game:GetService("Lighting")
local lTime = 0

local loadingTime = coroutine.create(function()
    while true do
     lTime = lTime + 0.1
     task.wait(0.1)
     end
end)

local origWalkSpeed = humanoid.WalkSpeed

local ESPLib = getgenv().mstudio45_ESP or loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
getgenv().mstudio45_ESP = ESPLib
local activeESP = {}
local itemScanRunning = false

local PlayersESPConnections = {}

local function manageESP(toggle, name, model, colorPicker)
    if toggle then
        if activeESP[name] then activeESP[name]:Destroy() end
        local esp = ESPLib:Add({
            Name = name,
            Model = model,
            ESPType = "Highlight",
            Color = colorPicker.Value,
            FillColor = colorPicker.Value,
            FillTransparency = 0.5,
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

local Toggles = Library.Toggles
local Options = Library.Options
local speedHack = false
local speedChange = false

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "XBHUB",
    Footer = "GAME: Chain  Vision: v0.01(Beta)",
    Icon = nil,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Center = true,
    AutoShow = false,
    Resizable = false,
})

local Loading = Library:CreateLoading({
    Title = "XBHUB",
    LoadingIcon = 97544096941083,
    TotalSteps = 7,
    AutoResizeHeight = true,
    WindowWidth = 600,
    WindowHeight = 380,
})

local function errorLibrary()
    Loading:SetMessage("遇到了一些小错误")
    Loading:SetLoadingIcon("x")
    Loading:SetLoadingIconTweenTime(0)
end

coroutine.resume(loadingTime)

task.spawn(function()
    while lTime do
        if lTime >= 5 then
            Library:Notify({
                Title = "加载器 ",
                Description = "好像遇到了一些错误,请卸载脚本后重试\n错误码:005",
                Time = 5,
                SoundId = 4590657391,
            })
            
            errorLibrary()
            
            lTime = nil
        end
    task.wait()
    end
end)

Library:Notify({
    Title = "XBHUB",
    Description = "欢迎您使用本脚本,已为您开启加载器",
    Time = 2,
    SoundId = 4590657391,
})

Library:Notify({
    Title = "XBHUB",
    Description = "此脚本永久开源!!!支持原作者sjsksjsk219(我)",
    Time = 5,
    SoundId = 4590657391,
})

Loading:ShowSidebarPage(true)
Loading:SetSidebarWidth(320)

Loading:SetMessage("正在检测是否开启多个UI...")
Loading:SetCurrentStep(1)

task.wait(0.2)

if getgenv().OpenUi then
    Loading:SetMessage("您已打开过一个UI!UI已卸载")
    Loading:SetLoadingIcon("x")
    Loading:SetLoadingIconTweenTime(0)
    task.wait(0.5)
    Loading:Destroy()
    Library:Unload()
    return
end

getgenv().OpenUi = true

Loading:SetMessage("正在等待游戏加载完成...")
Loading:SetCurrentStep(2)

repeat task.wait() until game:IsLoaded()

Loading:SetMessage("正在测试注入器UNC...")
Loading:SetCurrentStep(3)

local Sidebar = Loading.Sidebar
Sidebar:AddLabel("加载器版本:v0.0.4.3")
local JoinButton = Sidebar:AddButton({
    Text = "进入脚本",
    Func = function()
        Loading:Destroy()
        Library:Notify({
            Title = "XBHUB",
            Description = "成功进入脚本!",
            Time = 5,
            SoundId = 4590657391,
        })
    end,
    DisabledTooltip = "请等待加载完成",
})

Sidebar:AddButton({
    Text = "卸载脚本",
    Func = function()
        Loading:Destroy()
        Library:Unload()
        getgenv().OpenUi = false
        return
    end,
})

JoinButton:SetDisabled(true)

Sidebar:AddLabel("<font color='#00FF00'>●</font> 通过  <font color='#FF0000'>●</font> 失败  <font color='#FFAA00'>⚠</font> 未测试")

local passes, fails = 0, 0
local running = 0
local testResults = {}

local function getGlobal(path)
    local value = getfenv(0)
    while value ~= nil and path ~= "" do
        local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
        value = value[name]
        path = nextValue
    end
    return value
end

local function test(name, aliases, callback)
    running = running + 1
    task.spawn(function()
        local resultStr
        if not callback then
            resultStr = "<font color='#FFAA00'>⚠</font> " .. name
            Library:Notify({
                Title = "UNC",
                Description = resultStr,
                Time = 2,
            })
        elseif not getGlobal(name) then
            fails = fails + 1
            resultStr = "<font color='#FF0000'>●</font> " .. name .. ": 不存在"
            Library:Notify({
                Title = "UNC",
                Description = resultStr,
                Time = 2,
            })
        else
            local success, message = pcall(callback)
            if success then
                passes = passes + 1
                if message and type(message) == "string" and message ~= "" then
                    resultStr = "<font color='#00FF00'>●</font> " .. name .. " -> " .. tostring(message)
                else
                    resultStr = "<font color='#00FF00'>●</font> " .. name
                end
                Library:Notify({
                    Title = "UNC",
                    Description = resultStr,
                    Time = 2,
                })
            else
                fails = fails + 1
                resultStr = "<font color='#FF0000'>●</font> " .. name .. " failed: " .. tostring(message)
                Library:Notify({
                    Title = "UNC",
                    Description = resultStr,
                    Time = 2,
                })
            end
        end
        table.insert(testResults, resultStr)
        running = running - 1
    end)
end

if isfolder and makefolder and delfolder then
    if isfolder(".tests") then delfolder(".tests") end
    makefolder(".tests")
end

test("cloneref", {}, function()
    local part = Instance.new("Part")
    local clone = cloneref(part)
    assert(part ~= clone, "Clone should not be equal to original")
    clone.Name = "Test"
    assert(part.Name == "Test", "Clone should have updated the original")
end)

test("setupvalue", {}, function()
    local function upvalue()
        return "fail"
    end
    local function test()
        return upvalue()
    end
    debug.setupvalue(test, 1, function()
        return "success"
    end)
    assert(test() == "success", "setupvalue did not set the first upvalue")
end)

test("getupvalues", {}, function()
    local upvalue = function() end
    local function testFunc() print(upvalue) end
    local upvalues = debug.getupvalues(testFunc)
    assert(upvalues[1] == upvalue, "Unexpected value")
end)

test("getcallingscript", {}, function()
    local s = getcallingscript()
    assert(s == nil or typeof(s) == "Instance", "getcallingscript unexpected return type")
end)

test("firetouchinterest", {}, function()
    local a = Instance.new("Part")
    local b = Instance.new("Part")
    a.Parent = workspace
    b.Parent = workspace
    firetouchinterest(a, b, 0)
    firetouchinterest(a, b, 1)
    a:Destroy()
    b:Destroy()
end)

test("appendfile", {}, function()
    writefile(".tests/appendfile_test.txt", "su")
    appendfile(".tests/appendfile_test.txt", "cce")
    appendfile(".tests/appendfile_test.txt", "ss")
    assert(readfile(".tests/appendfile_test.txt") == "success", "Did not append the file")
end)

test("getscriptbytecode", {"dumpstring"}, function()
    local animate = game:GetService("Players").LocalPlayer.Character.Animate
    local bytecode = getscriptbytecode(animate)
    assert(type(bytecode) == "string", "Did not return a string")
end)

test("listfiles", {}, function()
    writefile(".tests/listfiles_test.txt", "test")
    local files = listfiles(".tests")
    assert(#files > 0, "No files found")
end)

test("restorefunction", {}, function()
    local function f() return "original" end
    local ref = hookfunction(f, function() return "hooked" end)
    restorefunction(f)
    assert(f() == "original", "restorefunction did not restore")
end)

test("getgc", {}, function()
    local gc = getgc()
    assert(type(gc) == "table" and #gc > 0, "getgc failed")
end)

test("Drawing", {}, function()
    local d = Drawing.new("Square")
    d.Visible = false
    d:Destroy()
end)

test("hookmetamethod", {}, nil)

test("delfile", {}, function()
    writefile(".tests/delfile_test.txt", "")
    delfile(".tests/delfile_test.txt")
    assert(not isfile(".tests/delfile_test.txt"), "File not deleted")
end)

test("clonefunction", {}, function()
    local function testFunc() return "success" end
    local copy = clonefunction(testFunc)
    assert(testFunc() == copy() and testFunc ~= copy, "clonefunction failed")
end)

test("getconnections", {}, function()
    local bindable = Instance.new("BindableEvent")
    bindable.Event:Connect(function() end)
    local conn = getconnections(bindable.Event)[1]
    assert(type(conn.Function) == "function", "getconnections failed")
end)

test("isfunctionhooked", {}, function()
    local function f() end
    local ref = hookfunction(f, function() end)
    assert(isfunctionhooked(f) == true, "isfunctionhooked failed")
    restorefunction(f)
end)

test("getrenv", {}, function()
    assert(_G ~= getrenv()._G, "getrenv failed")
end)

test("fireclickdetector", {}, function()
    local cd = Instance.new("ClickDetector")
    cd.Parent = workspace
    fireclickdetector(cd, 50, "MouseHoverEnter")
    cd:Destroy()
end)

test("filtergc", {}, function()
    local t = filtergc("table", {})
    assert(type(t) == "table", "filtergc did not return a table")
end)

test("decompile", {}, function()
    local scriptInstance = game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("LocalScript")
    if scriptInstance then
        local source = decompile(scriptInstance)
        assert(type(source) == "string", "decompile did not return a string")
    else
        assert(true, "no script found to decompile")
    end
end)

test("getreg", {}, function()
    local reg = getreg()
    assert(type(reg) == "table", "getreg did not return a table")
end)

test("readfile", {}, function()
    writefile(".tests/readfile_test.txt", "hello")
    assert(readfile(".tests/readfile_test.txt") == "hello", "readfile failed")
end)

test("getinfo", {}, function()
    local info = debug.getinfo(1)
    assert(type(info) == "table" and info.what ~= nil, "debug.getinfo failed")
end)

test("getcallbackvalue", {}, function()
    local bf = Instance.new("BindableFunction")
    local function testFunc() end
    bf.OnInvoke = testFunc
    assert(getcallbackvalue(bf, "OnInvoke") == testFunc, "getcallbackvalue failed")
end)

test("makefolder", {}, function()
    makefolder(".tests/makefolder_test")
    assert(isfolder(".tests/makefolder_test"), "makefolder failed")
end)

test("getrawmetatable", {}, function()
    local mt = { __metatable = "Locked!" }
    local obj = setmetatable({}, mt)
    assert(getrawmetatable(obj) == mt, "getrawmetatable failed")
end)

test("getnamecallmethod", {}, nil)

test("isfile", {}, function()
    writefile(".tests/isfile_test.txt", "")
    assert(isfile(".tests/isfile_test.txt"), "Not recognized as file")
    assert(not isfile(".tests"), "Folder recognized as file")
end)

test("getsenv", {}, function()
    local animate = game:GetService("Players").LocalPlayer.Character.Animate
    local env = getsenv(animate)
    assert(type(env) == "table" and env.script == animate, "getsenv failed")
end)

test("getrunningscripts", {}, function()
    local scripts = getrunningscripts()
    assert(#scripts > 0 and (scripts[1]:IsA("LocalScript") or scripts[1]:IsA("ModuleScript")), "getrunningscripts failed")
end)

test("checkcaller", {}, function()
    assert(checkcaller() == true, "checkcaller failed")
end)

test("require", {}, function()
    local s, r = pcall(require, 123)
    assert(s or not s, "require exists")
end)

test("getupvalue", {}, function()
    local upvalue = function() end
    local function testFunc() print(upvalue) end
    assert(debug.getupvalue(testFunc, 1) == upvalue, "getupvalue failed")
end)

test("newcclosure", {}, function()
    local function testFunc() return true end
    local c = newcclosure(testFunc)
    assert(testFunc() == c() and testFunc ~= c and iscclosure(c), "newcclosure failed")
end)

repeat task.wait() until running == 0

for _, v in ipairs(testResults) do
    Sidebar:AddLabel({
        Text = v,
        RichText = true,
    })
end

local total = passes + fails
local percent = total > 0 and math.floor(passes / total * 100) or 0
Sidebar:AddLabel("")
Sidebar:AddLabel(string.format("<font color='#00FF00'>✔ 成功: %d/%d</font>", passes, total))
Sidebar:AddLabel(string.format("你的注入器有: %d%%", percent))

Library:Notify({
    Title = "UNC",
    Description = string.format("您的注入器 UNC: %d%%", percent),
    Time = 3,
})

Loading:SetMessage("正在加载选项...")
Loading:SetCurrentStep(4)

local Tabs = {
    User = Window:AddTab("首页", "house"),
    Main = Window:AddTab("基本功能", "user"),
    Exploit = Window:AddTab("漏洞利用", "bug"),
}

Tabs.User:UpdateWarningBox({
    Visible = true,
    Title = "更新功能公告",
    Text = "暂无",
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
    Text = "暂无",
    DoesWrap = true,
    RichText = true,
})

-- ============================================================
-- 新增：Main Tab 的移动与状态组
-- ============================================================
local MoveGroup = Tabs.Main:AddLeftGroupbox("移动与状态", "user")

-- 存储原始速度、亮度等
local originalSpeed = humanoid.WalkSpeed
local originalBrightness = lighting.Brightness
local originalAmbient = lighting.Ambient
local originalOutdoorAmbient = lighting.OutdoorAmbient

-- 禁用惯性 Toggle（Risky 红色提醒）
local InertiaToggle = MoveGroup:AddToggle("DisableInertia", {
    Text = "禁用惯性 (奔跑不可用)",
    Default = false,
    Risky = true,
    Tooltip = "开启后角色将无法奔跑，移动组件会被强制禁用",
    Callback = function(val)
        -- 功能将在 OnChanged 中处理
    end
})

-- 速度修改 Toggle + Slider
local SpeedToggle = MoveGroup:AddToggle("SpeedMod", {
    Text = "启用速度修改",
    Default = false,
    Tooltip = "开启后可调整移动速度"
})
local SpeedSlider = MoveGroup:AddSlider("SpeedValue", {
    Text = "速度值",
    Default = originalSpeed,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Suffix = "",
    Disabled = true,  -- 默认禁用，直到 SpeedToggle 开启
    Tooltip = "修改当前角色的移动速度"
})

-- 无限体力 Toggle
local StaminaToggle = MoveGroup:AddToggle("InfiniteStamina", {
    Text = "无限体力",
    Default = false,
    Tooltip = "体力值始终保持在 100"
})

-- 高亮 Toggle + Slider
local BrightnessToggle = MoveGroup:AddToggle("HighBrightness", {
    Text = "高亮",
    Default = false,
    Tooltip = "提高环境亮度"
})
local BrightnessSlider = MoveGroup:AddSlider("BrightnessLevel", {
    Text = "亮度级别",
    Default = 8,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Disabled = true,
    Tooltip = "亮度值，仅在开启高亮时生效"
})

-- ============================================================
-- 功能逻辑实现（使用 OnChanged 监测变化）
-- ============================================================

-- 获取当前角色的 Movement 组件（如果有）
local function getMovement()
    local char = pl.Character
    if not char then return nil end
    return char:FindFirstChild("Movement")
end

-- 禁用惯性循环控制
local inertiaRunning = false
local inertiaThread = nil

local function startInertiaLoop()
    if inertiaRunning then return end
    inertiaRunning = true
    inertiaThread = task.spawn(function()
        while inertiaRunning do
            local move = getMovement()
            if move and move.Enabled then
                move.Disabled = true
            end
            task.wait()
        end
    end)
end

local function stopInertiaLoop()
    inertiaRunning = false
    if inertiaThread then
        task.cancel(inertiaThread)
        inertiaThread = nil
    end
    -- 恢复 Movement 的 Disabled 状态
    local move = getMovement()
    if move then
        move.Disabled = false
    end
end

-- 速度修改相关
local speedModActive = false

local function applySpeed()
    if speedModActive then
        local char = pl.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = SpeedSlider.Value
                -- 可选：设置 Running 状态
                -- local stats = char:FindFirstChild("Stats")
                -- if stats then stats.Running = true end
            end
        end
    end
end

local function resetSpeed()
    local char = pl.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = originalSpeed
        end
    end
end

-- 无限体力循环控制
local staminaRunning = false
local staminaThread = nil

local function startStaminaLoop()
    if staminaRunning then return end
    staminaRunning = true
    staminaThread = task.spawn(function()
        while staminaRunning do
            local char = pl.Character
            if char then
                local stats = char:FindFirstChild("Stats")
                if stats then
                    local sta = stats:FindFirstChild("Stamina")
                    if sta then
                        sta.Value = 100
                    end
                end
            end
            task.wait()
        end
    end)
end

local function stopStaminaLoop()
    staminaRunning = false
    if staminaThread then
        task.cancel(staminaThread)
        staminaThread = nil
    end
end

-- 高亮应用
local function applyBrightness()
    if BrightnessToggle.Value then
        local level = BrightnessSlider.Value
        lighting.Brightness = level
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        lighting.Brightness = originalBrightness
        lighting.Ambient = originalAmbient
        lighting.OutdoorAmbient = originalOutdoorAmbient
    end
end

-- ---- 绑定 OnChanged ----

-- 禁用惯性
InertiaToggle:OnChanged(function(val)
    if val then
        startInertiaLoop()
    else
        stopInertiaLoop()
    end
end)

-- 启用速度修改
SpeedToggle:OnChanged(function(val)
    speedModActive = val
    SpeedSlider:SetDisabled(not val)
    if val then
        applySpeed()
    else
        resetSpeed()
    end
end)

-- 速度值变化（仅当速度修改启用时生效）
SpeedSlider:OnChanged(function(val)
    if speedModActive then
        applySpeed()
    end
end)

-- 无限体力
StaminaToggle:OnChanged(function(val)
    if val then
        startStaminaLoop()
    else
        stopStaminaLoop()
    end
end)

-- 高亮
BrightnessToggle:OnChanged(function(val)
    BrightnessSlider:SetDisabled(not val)
    applyBrightness()
end)

BrightnessSlider:OnChanged(function(val)
    if BrightnessToggle.Value then
        applyBrightness()
    end
end)

-- 角色重生时重新应用状态
pl.CharacterAdded:Connect(function(char)
    task.wait(0.5)  -- 等待角色稳定
    if InertiaToggle.Value then
        startInertiaLoop()
    end
    if speedModActive then
        applySpeed()
    end
    if StaminaToggle.Value then
        startStaminaLoop()
    end
    if BrightnessToggle.Value then
        applyBrightness()
    end
end)

-- ============================================================
-- 原有 UI 设置部分（保持不变）
-- ============================================================
local EnvironmentGroup = Tabs.Main:AddRightGroupbox("环境", "sun")
local CameraGroup = Tabs.Main:AddRightGroupbox("相机")

local highBrightnessEnabled = false
local brightnessLevel = 1
local brightnessConnection
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local UISettingsTab = Window:AddTab("UI设置", "settings")
local MenuGroup = UISettingsTab:AddLeftGroupbox("菜单", "wrench")

MenuGroup:AddToggle("CustomCursor", { Text = "自定义光标", Default = true })
MenuGroup:AddDropdown("DPIScale", { Values = { "50%", "75%", "100%", "125%", "150%" }, Default = "100%", Text = "UI缩放" })
MenuGroup:AddLabel("菜单快捷键"):AddKeyPicker("MenuToggleKey", { Default = "RightShift", NoUI = true, Text = "快捷键", Mode = "Toggle" })

MenuGroup:AddDivider()
MenuGroup:AddButton({
    Text = "卸载脚本",
    Func = function()
        local dialog = Window:AddDialog({
            Title = "XBHUB",
            Description = "正在卸载所有功能...",
            AutoDismiss = false,
            OutsideClickDismiss = false,
        })
        dialog:SetTitle("XBHUB")
        dialog:SetDescription("正在卸载所有功能,这可能会需要点时间...")
        task.spawn(function()
            -- 关闭所有开关
            for _, toggle in pairs(Toggles) do
                pcall(function() toggle:SetValue(false) end)
            end
            task.wait(0.5)
            
            -- 清理ESP
            for _, esp in pairs(activeESP) do
                pcall(function() esp:Destroy() end)
            end
            table.clear(activeESP)
            
            -- 清理玩家ESP连接
            for _, conns in pairs(PlayersESPConnections) do
                for _, c in ipairs(conns) do c:Disconnect() end
            end
            table.clear(PlayersESPConnections)
            dialog:SetDescription("卸载完成!正在关闭UI...")
            task.wait(0.5)
            dialog:Dismiss()
            Library:Unload()
            getgenv().OpenUi = false
        end)
    end,
    Risky = false,
})

Loading:SetMessage("正在加载实用功能...")
Loading:SetCurrentStep(5)

Loading:SetMessage("正在加载设置界面...")
Loading:SetCurrentStep(6)

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

coroutine.close(loadingTime)
Loading:SetMessage("完成!")
Loading:SetCurrentStep(7)
Loading:SetLoadingIconTweenTime(0)
Loading:SetLoadingIcon("check")
JoinButton:SetDisabled(false)

Library:Notify({
    Title = "加载器 ",
    Description = "脚本已加载完毕!",
    Time = 3,
    SoundId = 4590657391,
})

Library:Notify({
    Title = "加载器 ",
    Description = "耗时" .. tostring(lTime) .. "s",
    Time = 5,
    SoundId = 4590657391,
})

else
    game:GetService("Players").LocalPlayer:Kick("暂不支持此游戏脚本")
end
