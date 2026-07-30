if game.PlaceId == 13977939077 then
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Loading = Library:CreateLoading({
    Title = "XBHUB",
    LoadingIcon = 97544096941083,
    TotalSteps = 7,
    AutoResizeHeight = true,
    WindowWidth = 600,
    WindowHeight = 380,
})

Loading:SetMessage("正在等待角色加载...")
Loading:SetCurrentStep(1)

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

local pl = game:GetService("Players").LocalPlayer
local humanoid = pl.Character.Humanoid
if humanoid == nil then
    while true do
        pl.CharacterAdded:Connect(function(char)
            humanoid = char:WaitForChild("Humanoid")
        end)
        if humanoid then
            break
        end
        task.wait()
    end
end

local Players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local lTime = 0
local rain = lighting.Rainy

local loadingTime = coroutine.create(function()
    while true do
     lTime = lTime + 0.1
     task.wait(0.1)
     end
end)

local origWalkSpeed = humanoid.WalkSpeed

-- ESP 高亮库
local ESPLib = getgenv().mstudio45_ESP or loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
getgenv().mstudio45_ESP = ESPLib
local activeESP = {}
local PlayersESPConnections = {}

-- 高亮管理
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

-- ========== Toggles & Options ==========
local Toggles = Library.Toggles
local Options = Library.Options
local speedHack = false
local speedChange = false

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "XBHUB",
    Footer = "GAME: Chain  Vision: v0.03(Beta)",
    Icon = nil,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Center = true,
    AutoShow = false,
    Resizable = false,
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
Loading:SetCurrentStep(2)
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
Loading:SetCurrentStep(3)
repeat task.wait() until game:IsLoaded()

Loading:SetMessage("正在测试注入器UNC...")
Loading:SetCurrentStep(4)

Sidebar:AddLabel("<font color='#00FF00'>●</font> 通过  <font color='#FF0000'>●</font> 失败  <font color='#FFAA00'>⚠</font> 未测试")

-- ==================== UNC 测试 ====================
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

test("isfolder", {}, function()
    assert(isfolder(".tests") == true, "Did not return true for a folder")
    assert(isfolder(".tests/doesnotexist") == false, "Did not return false")
end)
--[[
test("setfflag", {}, function()
    local success, err = pcall(function()
        setfflag("TestFlag", "test")
    end)
    if not success then
        error("setfflag failed: " .. tostring(err))
    end
    assert(getfflag("TestFlag") == "test", "setfflag did not set the fflag correctly")
end)
--]]
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
--[[
test("request", {}, function()
    local response = request({
        Url = "https://httpbin.org/user-agent",
        Method = "GET",
    })
    assert(type(response) == "table" and response.StatusCode == 200, "request failed")
    return game:GetService("HttpService"):JSONDecode(response.Body)["user-agent"]
end)
--]]
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

Library:Notify({
    Title = "UNC",
    Description = string.format("您的注入器 UNC: %d%%", percent),
    Time = 3,
})

Loading:SetMessage("正在加载选项...")
Loading:SetCurrentStep(5)

-- ========== 创建选项卡 ==========
local Tabs = {
    User = Window:AddTab("首页", "house"),
    Main = Window:AddTab("基本功能", "user"),
    ESP = Window:AddTab("ESP", "eye"),
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
        pcall(function() PlayerImage:SetImage(content) end)
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

-- ========== Main 标签页 - 移动与状态 ==========
local MoveGroup = Tabs.Main:AddLeftGroupbox("移动与状态", "user")

local originalSpeed = humanoid.WalkSpeed
local speedLoopRunning = false
local speedLoopConnection = nil

local InertiaToggle = MoveGroup:AddToggle("DisableInertia", {
    Text = "禁用惯性 (奔跑不可用)",
    Default = false,
    Risky = true,
    Tooltip = "开启后角色将无法奔跑，移动组件会被强制禁用",
})

local SpeedToggle = MoveGroup:AddToggle("SpeedMod", {
    Text = "启用速度修改",
    Default = false,
    Tooltip = "开启后可调整移动速度（上限50）"
})
local SpeedSlider = MoveGroup:AddSlider("SpeedValue", {
    Text = "速度值",
    Default = originalSpeed,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Suffix = "",
    Disabled = true,
    Tooltip = "修改当前角色的移动速度（上限50）"
})

local StaminaToggle = MoveGroup:AddToggle("InfiniteStamina", {
    Text = "无限体力",
    Default = false,
    Tooltip = "体力值始终保持在 100"
})

-- ========== Main 标签页 - 环境 ==========
local EnvironmentGroup = Tabs.Main:AddRightGroupbox("环境", "sun")

local originalBrightness = lighting.Brightness
local originalAmbient = lighting.Ambient
local originalOutdoorAmbient = lighting.OutdoorAmbient
local originalFogEnd = lighting.FogEnd

local BrightnessToggle = EnvironmentGroup:AddToggle("HighBrightness", {
    Text = "高亮",
    Default = false,
    Tooltip = "提高环境亮度"
})
local BrightnessSlider = EnvironmentGroup:AddSlider("BrightnessLevel", {
    Text = "亮度级别",
    Default = 8,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Disabled = true,
    Tooltip = "亮度值，仅在开启高亮时生效"
})

local NoFogToggle = EnvironmentGroup:AddToggle("NoFog", {
    Text = "无雾霾",
    Default = false,
    Tooltip = "移除游戏中的雾效"
})

-- ========== ESP 选项卡 ==========
local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP 设置", "eye")

local PlayerESPToggle = ESPGroup:AddToggle("PlayerESP", {
    Text = "玩家 ESP",
    Default = false,
    Tooltip = "显示所有玩家的高亮"
}):AddColorPicker("PlayerESPColor", {
    Default = Color3.new(0, 1, 0),
    Title = "玩家颜色",
    Transparency = 0.3,
})

local ChainESPToggle = ESPGroup:AddToggle("ChainESP", {
    Text = "Chain ESP",
    Default = false,
    Tooltip = "显示 Chain 的高亮（仅在夜晚出现）"
}):AddColorPicker("ChainESPColor", {
    Default = Color3.new(1, 0, 0),
    Title = "Chain颜色",
    Transparency = 0.3,
})

Loading:SetMessage("正在加载实用功能...")
Loading:SetCurrentStep(6)

-- ========== ESP 功能逻辑 ==========

local function getChain()
    local misc = workspace:FindFirstChild("Misc")
    if not misc then return nil end
    local ai = misc:FindFirstChild("AI")
    if not ai then return nil end
    return ai:FindFirstChild("CHAIN")
end

local chainESPActive = false
local chainMonitorThread = nil

local function updateChainESP(enable)
    if enable then
        chainMonitorThread = task.spawn(function()
            while Toggles.ChainESP.Value do
                local chain = getChain()
                if chain then
                    manageESP(true, "Chain", chain, Options.ChainESPColor)
                    updateESPColor("Chain", Options.ChainESPColor)
                    chainESPActive = true
                    break
                end
                task.wait(0.5)
            end
        end)
    else
        if chainMonitorThread then
            task.cancel(chainMonitorThread)
            chainMonitorThread = nil
        end
        manageESP(false, "Chain", nil, nil)
        chainESPActive = false
    end
end

local playerESPCreated = {}

local function updatePlayerESP(enable)
    if enable then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= pl and player.Character then
                manageESP(true, player.Name, player.Character, Options.PlayerESPColor)
                playerESPCreated[player] = true
            end
        end
        local function onPlayerAdded(player)
            if player == pl then return end
            local conn = player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if not Toggles.PlayerESP.Value then return end
                manageESP(true, player.Name, char, Options.PlayerESPColor)
                playerESPCreated[player] = true
            end)
            if not PlayersESPConnections[player] then PlayersESPConnections[player] = {} end
            table.insert(PlayersESPConnections[player], conn)
            if player.Character then
                manageESP(true, player.Name, player.Character, Options.PlayerESPColor)
                playerESPCreated[player] = true
            end
        end
        local function onPlayerRemoving(player)
            manageESP(false, player.Name, nil, nil)
            playerESPCreated[player] = nil
            if PlayersESPConnections[player] then
                for _, c in ipairs(PlayersESPConnections[player]) do c:Disconnect() end
                PlayersESPConnections[player] = nil
            end
        end
        local conn1 = Players.PlayerAdded:Connect(onPlayerAdded)
        local conn2 = Players.PlayerRemoving:Connect(onPlayerRemoving)
        table.insert(PlayersESPConnections, conn1)
        table.insert(PlayersESPConnections, conn2)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= pl then onPlayerAdded(player) end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            manageESP(false, player.Name, nil, nil)
            playerESPCreated[player] = nil
        end
        for _, conn in ipairs(PlayersESPConnections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        table.clear(PlayersESPConnections)
    end
end

-- 绑定事件
PlayerESPToggle:OnChanged(function(val)
    updatePlayerESP(val)
end)

Options.PlayerESPColor:OnChanged(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= pl and player.Character then
            updateESPColor(player.Name, Options.PlayerESPColor)
        end
    end
end)

ChainESPToggle:OnChanged(function(val)
    updateChainESP(val)
end)

Options.ChainESPColor:OnChanged(function()
    if Toggles.ChainESP.Value then
        updateESPColor("Chain", Options.ChainESPColor)
    end
end)

-- ========== 原有移动/环境功能 ==========

local inertiaRunning = false
local inertiaThread = nil
local function startInertiaLoop()
    if inertiaRunning then return end
    inertiaRunning = true
    inertiaThread = task.spawn(function()
        while inertiaRunning do
            local move = pl.Character:FindFirstChild("Movement")
            if move.Enabled then move.Disabled = true end
            task.wait()
        end
    end)
end
local function stopInertiaLoop()
    inertiaRunning = false
    if inertiaThread then task.cancel(inertiaThread); inertiaThread = nil end
    local move = pl.Character:FindFirstChild("Movement")
    if move then move.Disabled = false end
end

local function startSpeedLoop()
    if speedLoopRunning then return end
    speedLoopRunning = true
    speedLoopConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if speedLoopRunning and SpeedToggle.Value then
            local char = pl.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = SpeedSlider.Value end
            end
        end
    end)
end
local function stopSpeedLoop()
    speedLoopRunning = false
    if speedLoopConnection then speedLoopConnection:Disconnect(); speedLoopConnection = nil end
    local char = pl.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalSpeed end
    end
end

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
                    if sta then sta.Value = 100 end
                end
            end
            task.wait()
        end
    end)
end
local function stopStaminaLoop()
    staminaRunning = false
    if staminaThread then task.cancel(staminaThread); staminaThread = nil end
end

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

local function applyNoFog()
    if NoFogToggle.Value then
        lighting.FogEnd = 9e9
        if rain then
            rain.Parent = nil
        end
    else
        lighting.FogEnd = originalFogEnd
        rain.Parent = lighting
    end
end

InertiaToggle:OnChanged(function(val)
    if val then startInertiaLoop() else stopInertiaLoop() end
end)
SpeedToggle:OnChanged(function(val)
    SpeedSlider:SetDisabled(not val)
    if val then startSpeedLoop() else stopSpeedLoop() end
end)
SpeedSlider:OnChanged(function(val) end)
StaminaToggle:OnChanged(function(val)
    if val then startStaminaLoop() else stopStaminaLoop() end
end)
BrightnessToggle:OnChanged(function(val)
    BrightnessSlider:SetDisabled(not val)
    applyBrightness()
end)
BrightnessSlider:OnChanged(function(val)
    if BrightnessToggle.Value then applyBrightness() end
end)
NoFogToggle:OnChanged(function(val) applyNoFog() end)

pl.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if InertiaToggle.Value then startInertiaLoop() end
    if SpeedToggle.Value then startSpeedLoop() end
    if StaminaToggle.Value then startStaminaLoop() end
    if BrightnessToggle.Value then applyBrightness() end
    if NoFogToggle.Value then applyNoFog() end
end)

-- ========== 其他（Exploit 和 UI 设置） ==========
local CameraGroup = Tabs.Main:AddRightGroupbox("相机")

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
            for _, esp in pairs(activeESP) do
                pcall(function() esp:Destroy() end)
            end
            table.clear(activeESP)
            for _, conns in pairs(PlayersESPConnections) do
                for _, c in ipairs(conns) do c:Disconnect() end
            end
            table.clear(PlayersESPConnections)
            stopSpeedLoop()
            stopInertiaLoop()
            stopStaminaLoop()
            if chainMonitorThread then task.cancel(chainMonitorThread); chainMonitorThread = nil end
            dialog:SetDescription("卸载完成!正在关闭UI...")
            task.wait(0.5)
            dialog:Dismiss()
            Library:Unload()
            getgenv().OpenUi = false
        end)
    end,
    Risky = false,
})

Loading:SetMessage("正在加载设置界面...")
Loading:SetCurrentStep(7)

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
Loading:SetCurrentStep(8)
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
