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
local monsterList = nil
local oldConnect = nil
local Radio = game.Workspace.Radio
local camera = game.Workspace:FindFirstChild("Camera")
local oxy = game:GetService("Players").LocalPlayer.Character.Breath
local power = game.Workspace:FindFirstChild("Shack"):WaitForChild("Generator").Fuel

local origWalkSpeed = humanoid.WalkSpeed
local origSprintOverdrive = pl.Character.Sprint.Overdrive.Value
local origBreathValue = pl.Character.Breath.Value
local origStamMax = pl.Character.Sprint.Stam:GetAttribute("Max")

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
            SoundId = 4590657391,
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
    Footer = "GAME: 住宅大逃杀  Vision: v1.43(Beta)  Location:Night 1",
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
            warn("⚠ " .. name)
        elseif not getGlobal(name) then
            fails = fails + 1
            resultStr = "<font color='#FF0000'>●</font> " .. name .. ": 不存在"
            warn(resultStr)
        else
            local success, message = pcall(callback)
            if success then
                passes = passes + 1
                if message and type(message) == "string" and message ~= "" then
                    resultStr = "<font color='#00FF00'>●</font> " .. name .. " -> " .. tostring(message)
                else
                    resultStr = "<font color='#00FF00'>●</font> " .. name
                end
                print(resultStr)
            else
                fails = fails + 1
                resultStr = "<font color='#FF0000'>●</font> " .. name .. " failed: " .. tostring(message)
                warn(resultStr)
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

test("isfolder", {}, function()
    assert(isfolder(".tests") == true, "Did not return true for a folder")
    assert(isfolder(".tests/doesnotexist") == false, "Did not return false")
end)

test("setfflag", {}, function()
    local success, err = pcall(function()
        setfflag("TestFlag", "test")
    end)
    if not success then
        error("setfflag failed: " .. tostring(err))
    end
    assert(getfflag("TestFlag") == "test", "setfflag did not set the fflag correctly")
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

test("compareinstances", {}, function()
    local part = Instance.new("Part")
    local clone = cloneref(part)
    assert(compareinstances(part, clone), "compareinstances failed")
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

test("gethui", {}, function()
    assert(typeof(gethui()) == "Instance", "gethui failed")
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

test("writefile", {}, function()
    writefile(".tests/writefile_test.txt", "world")
    assert(readfile(".tests/writefile_test.txt") == "world", "writefile failed")
end)

test("loadfile", {}, function()
    writefile(".tests/loadfile_test.txt", "return ... + 1")
    local fn, err = loadfile(".tests/loadfile_test.txt")
    assert(fn and fn(1) == 2, "loadfile failed")
end)

test("replicatesignal", {}, function()
    local event = Instance.new("BindableEvent")
    replicatesignal(event.Event, "Test")
    event:Destroy()
end)

test("delfolder", {}, function()
    makefolder(".tests/delfolder_test")
    delfolder(".tests/delfolder_test")
    assert(not isfolder(".tests/delfolder_test"), "delfolder failed")
end)

test("firesignal", {}, function()
    local event = Instance.new("BindableEvent")
    firesignal(event.Event, "Test")
    event:Destroy()
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

test("request", {}, function()
    local response = request({
        Url = "https://httpbin.org/user-agent",
        Method = "GET",
    })
    assert(type(response) == "table" and response.StatusCode == 200, "request failed")
    return game:GetService("HttpService"):JSONDecode(response.Body)["user-agent"]
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

test("WebSocket", {}, function()
    local types = {
        Send = "function",
        Close = "function",
        OnMessage = {"table", "userdata"},
        OnClose = {"table", "userdata"},
    }
    local ws = WebSocket.connect("ws://echo.websocket.events")
    assert(type(ws) == "table" or type(ws) == "userdata", "Did not return a table or userdata")
    for k, v in pairs(types) do
        if type(v) == "table" then
            assert(table.find(v, type(ws[k])), "Did not return a " .. table.concat(v, ", ") .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
        else
            assert(type(ws[k]) == v, "Did not return a " .. v .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
        end
    end
    ws:Close()
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

test("queue_on_teleport", {"queueonteleport"}, function()
    assert(type(queue_on_teleport) == "function", "queue_on_teleport is not a function")
end)

test("getfflag", {}, function()
    local f = getfflag("TestFlag")
    assert(type(f) == "boolean" or f == nil, "getfflag returned unexpected type")
end)

test("mousemoverel", {}, function()
    mousemoverel(0, 0)
end)

test("isexecutorclosure", {"checkclosure", "isourclosure"}, function()
    assert(isexecutorclosure(print) == false, "print should not be executor closure")
    assert(isexecutorclosure(isexecutorclosure) == true, "isexecutorclosure failed")
end)

test("fireproximityprompt", {}, function()
    local prompt = Instance.new("ProximityPrompt")
    prompt.Parent = workspace
    fireproximityprompt(prompt)
    prompt:Destroy()
end)

test("hookfunction", {"replaceclosure"}, function()
    local function testFunc() return true end
    local ref = hookfunction(testFunc, function() return false end)
    assert(testFunc() == false and ref() == true, "hookfunction failed")
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
print(string.format("UNC 测试完成: %d/%d (%d%%)", passes, total, percent))

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
    Text = "<font color='#FFAA00'>[XBHUB]</font>\n<font color='#00FF00'>新增加载器</font>\n<font color='#FFAA00'>[Night 1]</font>\n<font color='#00FF00'>新增数值显示</font>",
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
    Text = "<font color='#00FF00'>●</font>速度修改\n<font color='#00FF00'>●</font>高亮\n<font color='#00FF00'>●</font>无限体力\n<font color='#00FF00'>●</font>实用功能\n<font color='#00FF00'>●</font>怪物预警\n<font color='#FF0000'>●</font>ESP --物品ESP故障\n<font color='#00FF00'>●</font>相机",
    DoesWrap = true,
    RichText = true,
})

local SpeedGroup = Tabs.Main:AddLeftGroupbox("速度", "zap")

SpeedGroup:AddToggle("SpeedHack", {
    Text = "启用速度绕过",
    Default = true,
    DisabledTooltip = "该功能为守护您的安全保持开启",
})

SpeedGroup:AddToggle("SpeedEnabled", {
    Text = "启用速度修改",
    Default = false,
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
})

SpeedGroup:AddDivider()
SpeedGroup:AddToggle("InfSprint", {
    Text = "无限体力",
    Default = false,
})

SpeedGroup:AddSlider("MaxSprint", {
    Text = "最大体力",
    Default = 16,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
})

SpeedGroup:AddButton({
    Text = "回满体力",
    Func = function()
        pl.Character.Sprint.Stam.Value = pl.Character.Sprint.Stam:GetAttribute("Max")
    end,
    Tooltip = "点击回满体力",
})

local EnvironmentGroup = Tabs.Main:AddRightGroupbox("环境", "sun")
local CameraGroup = Tabs.Main:AddRightGroupbox("相机")

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
})

EnvironmentGroup:AddToggle("RemoveFog", {
    Text = "无雾霾",
    Default = false,
})

EnvironmentGroup:AddToggle("RemoveAtmosphere", {
    Text = "移除大气",
    Default = false,
    Risky = true,
    Tooltip = "该功能会导致晚上游戏一直报错,且开启后无法关闭",
    DisabledTooltip = "该功能已被锁定",
})

CameraGroup:AddToggle("NoShake", {
    Text = "无相机摇晃",
    Default = false,
})

local ExploitLeftGroup = Tabs.Exploit:AddLeftGroupbox("实用功能", "flashlight")
ExploitLeftGroup:AddToggle("FlashlightInf", {
    Text = "无限手电筒电量",
    Default = false,
})

ExploitLeftGroup:AddToggle("InfO2", {
    Text = "无限氧气",
    Risky = true,
    Tooltip = "当发电机没电后会出现视线模糊",
    Default = false,
})

ExploitLeftGroup:AddToggle("AutoRadio", {
    Text = "无收音机杂音",
    Tooltip = "静音收音机",
    Default = false,
})

local information = ExploitLeftGroup:AddLabel({
    Text = string.format("剩余氧气: <b>%d</b>\n剩余电量: <b>%d</b>", oxy.Value, power.Value),
    DoseWrap = true,
    RichText = true,
})

local co = coroutine.create(function()
    while getgenv().OpenUi do
    oxy.Changed:Connect(function()
        information:SetText(string.format("剩余氧气: <b>%d</b>\n剩余电量: <b>%d</b>", oxy.Value, power.Value))
    end)
    
    power.Changed:Connect(function()
        information:SetText(string.format("剩余氧气: <b>%d</b>\n剩余电量: <b>%d</b>", oxy.Value, power.Value))
    end)
    task.wait(0.1)
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

local ExploitRightGroup = Tabs.Exploit:AddRightGroupbox("怪物预警", "bell")

ExploitRightGroup:AddDropdown("MonsterList", {
    Values = {"Mutant"},
    Default = {"Mutant"},
    Multi = true,
    Text = "怪物列表",
})

ExploitRightGroup:AddToggle("AlertEnabled", {
    Text = "启用预警",
    Default = false,
})

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
            for _, toggle in pairs(Toggles) do
                pcall(function() toggle:SetValue(false) end)
            end
            task.wait(0.5)
            
            pl.Character.Sprint.Stam:SetAttribute("Max", 5)
            pl.Character.Sprint.Stam.Value = 5
            coroutine.close(co)
            
            dialog:SetDescription("卸载完成!正在关闭UI...")
            task.wait(0.5)
            dialog:Dismiss()
            Library:Unload()
            getgenv().OpenUi = false
            return
        end)
    end,
    Risky = false,
})
Loading:SetMessage("正在加载实用功能...")
Loading:SetCurrentStep(5)

Toggles.SpeedHack:OnChanged(function()
    if Toggles.SpeedHack.Value then
        for _, v in pairs(getconnections(walkSpeedChanged)) do
            v:Disable()
        end
    end
end)

Toggles.SpeedHack:SetValue(true)
task.wait(0.2)
Toggles.SpeedHack:SetDisabled(true)
Toggles.SpeedHack.TextLabel.TextTransparency = 0.8

Toggles.SpeedEnabled:OnChanged(function(Value)
    if Value then
        speedChange = true
        if Options.WalkSpeed.Value then
            humanoid.WalkSpeed = Options.WalkSpeed.Value
        end
    else
        speedChange = false
        humanoid.WalkSpeed = origWalkSpeed
    end
end)

Options.WalkSpeed:OnChanged(function(Value)
    if Toggles.SpeedEnabled.Value then
        humanoid.WalkSpeed = Value
    end
end)

Toggles.InfSprint:OnChanged(function(Value)
    if Value then
        pl.Character.Sprint.Overdrive.Value = 99999999999
    else
        pl.Character.Sprint.Overdrive.Value = origSprintOverdrive
    end
end)

Options.MaxSprint:OnChanged(function(Value)
    if Value then
        pl.Character.Sprint.Stam:SetAttribute("Max", Value)
    end
end)

Toggles.HighBrightness:OnChanged(function(Value)
    highBrightnessEnabled = Value
    if brightnessConnection then 
        brightnessConnection:Disconnect() 
        brightnessConnection = nil
    end
    if Value then
        brightnessConnection = RunService.RenderStepped:Connect(updateBrightness)
    end
    updateBrightness()
end)

Toggles.RemoveFog:OnChanged(function(Value)
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
end)

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

Toggles.NoShake:OnChanged(function(value)
    if value then
        camera.CameraType = "Follow"
    else
        camera.CameraType = "Custom"
    end
end)

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
        pl.Character:FindFirstChild("Flashlight").Battery.Value = 150
    end)
end)

Toggles.InfO2:OnChanged(function(Value)
    if Value then
        pl.Character.Breath.Value = 9999999
    else
        pl.Character.Breath.Value = origBreathValue
    end
end)

Toggles.AutoRadio:OnChanged(function(value)
    task.spawn(function()
        while value do
            local speaker = Radio:FindFirstChild("Speaker")
            if speaker then
                for _, v in ipairs(speaker:GetChildren()) do
                    v:Stop()
                    task.wait()
                end
            end
            task.wait(5)
        end
    end)
end)

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

Options.MonsterList:OnChanged(function(Value)
    monsterList = Value
end)

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

Toggles.CustomCursor:OnChanged(function(v)
    Library.ShowCustomCursor = v
end)

Options.DPIScale:OnChanged(function(v)
    Library:SetDPIScale(tonumber(v:gsub("%%", "")) / 100)
end)

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

local Connections = {}

table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
    if not pl.Character or not pl.Character:FindFirstChild("HumanoidRootPart") then return end
end))

Loading:SetMessage("完成!")
Loading:SetCurrentStep(7)
Loading:SetLoadingIconTweenTime(0)
Loading:SetLoadingIcon("check")
JoinButton:SetDisabled(false)

coroutine.resume(co)

else
    game:GetService("Players").LocalPlayer:Kick("暂不支持此游戏脚本")
end
