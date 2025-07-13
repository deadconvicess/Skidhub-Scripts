-- Made by @deadconvicess
-- github repo - https://github.com/deadconvicess/Bladeball-Script
-- This Script is not done at all (BETA)


local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/StepBroFurious/Script/main/HydraHubUi.lua'))()
local Window = UILib.new("Script Hub @deadconvicess", LP.UserId, "deadconvicess")
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local HydraGui = nil
    for _, obj in ipairs(CoreGui:GetChildren()) do
        if obj:IsA("ScreenGui") and obj:FindFirstChildWhichIsA("Frame", true) and tostring(obj):lower():find("hydra") then
            HydraGui = obj
            break
        end
    end
    while not HydraGui do
        task.wait()
        for _, obj in ipairs(CoreGui:GetChildren()) do
            if obj:IsA("ScreenGui") and obj:FindFirstChildWhichIsA("Frame", true) and tostring(obj):lower():find("hydra") then
                HydraGui = obj
                break
            end
        end
    end
    HydraGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    for _, v in ipairs(HydraGui:GetDescendants()) do
        if v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame") then
            v.Active = true
            v.Selectable = false
        end
    end
    HydraGui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
            input:Capture()
        end
    end)
end)
local config = {
    WalkSpeed = defaultWalkSpeed or 45,
    JumpPower = Humanoid.JumpPower,
    AntiAFK = false,
    AntiKick = true,
    acbypass = true,
    AutoParry = false,
    Noclip = false,
    StaffDetection = true,
    AntiFling = false,
    FakeLag = false,
    SpinBot = false,
    FakeLagDelay = 0.15,
    FlyEnabled = false,
}
local debounce = false
local antiKickConnection = nil
local lastIdle = tick()
local heartbeatConnection = nil
local steppedConnection = nil
local noclipConnection = nil
local antiFlingConnection = nil
local fakeLagConnection = nil
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local function GetExecutor()
    local executorName = "Unknown"
    local execChecks = {
        {name = "Synapse X", check = function() return syn and syn.protect_gui and syn.queue_on_teleport end},
        {name = "Krnl", check = function() return KRNL_LOADED or (type(krnl) == "table") end},
        {name = "Fluxus", check = function() return isfluxus or (typeof(fluxus) == "boolean") end},
        {name = "Solara", check = function()
            return (_G.Solara or _G.solara or (type(getgenv) == "function" and getgenv()._SOLARA_LOADED)) ~= nil
        end},
    }
    for _, executor in ipairs(execChecks) do
        local ok, result = pcall(executor.check)
        if ok and result then
            executorName = executor.name
            break
        end
    end
    if executorName == "Unknown" and type(getexecutorname) == "function" then
        local name = getexecutorname()
        if type(name) == "string" and #name > 0 then
            executorName = name
        end
    end
    return executorName
end
local function safeTest(func)
    local ok, res = pcall(func)
    return ok and (res ~= false and res ~= nil)
end
local function testDebugGetInfo()
    return safeTest(function()
        local info = debug.getinfo(1)
        return type(info) == "table"
    end)
end
local function testDebugSetupValue()
    return safeTest(function()
        local function dummy() return 1 end
        local oldVal = debug.getupvalue(dummy, 1)
        debug.setupvalue(dummy, 1, 42)
        local newVal = debug.getupvalue(dummy, 1)
        debug.setupvalue(dummy, 1, oldVal) 
        return newVal == 42
    end)
end
local function testHookFunction()
    if type(hookfunction) ~= "function" then return false end
    return safeTest(function()
        local function dummy() return 1 end
        local hooked = hookfunction(dummy, function() return 2 end)
        local result = dummy()
        hooked()
        return result == 2
    end)
end
local function testMetatableProtection()
    return safeTest(function()
        local mt = getrawmetatable(game)
        if mt then
            local index = mt.__index
            if index then
                local old = mt.__index
                mt.__index = nil
                mt.__index = old
                return true
            end
        end
        return false
    end)
end
local function testRemoteHookProtection()
    if type(hookfunction) ~= "function" then return false end
    return safeTest(function()
        local oldFire = firetouchinterest
        firetouchinterest = function() return false end
        firetouchinterest = oldFire
    end)
end
local function CalculateUncScore()
    local tests = {
        testDebugGetInfo,
        testDebugSetupValue,
        testHookFunction,
        testMetatableProtection,
        testRemoteHookProtection,
    }
    local passed = 0
    local total = #tests
    for _, test in ipairs(tests) do
        if test() then
            passed = passed + 1
        end
    end
    local rawScore = (passed / total) * 100
    local uncScore = math.clamp(100 - rawScore, 0, 100)
    return uncScore
end
local function RunUncTest()
    local executor = GetExecutor()
    local uncScore = CalculateUncScore()
    local msg = string.format("Executor: %s | Unc Protection Quality: %d%%", executor, uncScore)
    print(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "Executor Unc Test",
        Text = msg,
        Duration = 5
    })
end
local function GetDefaultWalkSpeed()
    local character = LP.Character or LP.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    return humanoid.WalkSpeed
end
local defaultWalkSpeed = GetDefaultWalkSpeed()
local function SetupAntiKick(enabled)
    if enabled and not antiKickConnection then
        antiKickConnection = LP.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new())
            task.wait(0.1 + math.random() * 0.1)
            VirtualUser:Button2Up(Vector2.new())
        end)
    elseif not enabled and antiKickConnection then
        antiKickConnection:Disconnect()
        antiKickConnection = nil
    end
end
local flyConn
local function SetupFly(enabled)
    if enabled then
        if flyConn then flyConn:Disconnect() end
        local UIS = UserInputService
        local flying = true
        local speed = 80
        local direction = Vector3.zero
        flyConn = RunService.RenderStepped:Connect(function(dt)
            if not flying or not Char or not HRP then return end
            if Humanoid and Humanoid.Health <= 0 then
                SetupFly(false)
                return
            end
            local moveVec = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + Workspace.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - Workspace.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - Workspace.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + Workspace.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Workspace.CurrentCamera.CFrame.UpVector end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec = moveVec - Workspace.CurrentCamera.CFrame.UpVector end
            if moveVec.Magnitude > 0 then
                direction = moveVec.Unit
            else
                direction = Vector3.zero
            end
            if direction.Magnitude > 0 then
                HRP.Velocity = direction * speed
            else
                HRP.Velocity = Vector3.zero
            end
            HRP.RotVelocity = Vector3.zero
            HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + Workspace.CurrentCamera.CFrame.LookVector)
        end)
    else
        if flyConn then flyConn:Disconnect() end
        flyConn = nil
        if HRP then
            HRP.Velocity = Vector3.zero
        end
    end
end
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local AntiFling = {}
local connection
local lastSafeVelocity = Vector3.new()
local lastSafePosition = Vector3.new()
local lastGroundedTime = 0
local VELOCITY_THRESHOLD = 150
local POSITION_THRESHOLD = 30
local AIRBORNE_DELAY = 0.15
function AntiFling:Enable()
    if connection then return end
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Humanoid then return end
    lastSafeVelocity = HRP.AssemblyLinearVelocity
    lastSafePosition = HRP.Position
    lastGroundedTime = tick()
    connection = RunService.Heartbeat:Connect(function()
        if not Char or not Char.Parent then return end
        local grounded = Humanoid.FloorMaterial ~= Enum.Material.Air
        local velocity = HRP.AssemblyLinearVelocity
        local position = HRP.Position
        local moveDir = Humanoid.MoveDirection
        local userJump = UserInputService:IsKeyDown(Enum.KeyCode.Space)
        if grounded then
            lastSafePosition = position
            lastSafeVelocity = velocity
            lastGroundedTime = tick()
            return
        end
        local airborneTime = tick() - lastGroundedTime
        local velocitySpike = velocity.Magnitude > VELOCITY_THRESHOLD
        local positionSpike = (position - lastSafePosition).Magnitude > POSITION_THRESHOLD
        local noUserControl = moveDir.Magnitude == 0 and not userJump
        if airborneTime > AIRBORNE_DELAY and noUserControl and (velocitySpike or positionSpike) then
            HRP.AssemblyLinearVelocity = lastSafeVelocity:Lerp(Vector3.zero, 0.2)
            HRP.AssemblyAngularVelocity = Vector3.new()
            HRP.CFrame = CFrame.new(HRP.Position:Lerp(lastSafePosition, 0.1), HRP.CFrame.LookVector + HRP.Position)
        else
            lastSafeVelocity = velocity
            lastSafePosition = position
        end
    end)
end
function AntiFling:Disable()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer
local espObjects, espConnection = {}, nil
config.AdvancedPlayerESP = false
local function wts(pos)
	local screen, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2.new(screen.X, screen.Y), onScreen, screen.Z
end
local function createESP(plr)
	if espObjects[plr] then return end

	espObjects[plr] = {
		Box = Drawing.new("Square"),
		Tracer = Drawing.new("Line"),
		Name = Drawing.new("Text"),
		Health = Drawing.new("Square"),
		Distance = Drawing.new("Text"),
	}
	local esp = espObjects[plr]
	esp.Box.Thickness = 1.5
	esp.Box.Filled = false
	esp.Box.Transparency = 1
	esp.Box.Visible = false
	esp.Tracer.Thickness = 1
	esp.Tracer.Transparency = 0.8
	esp.Tracer.Visible = false
	esp.Name.Size = 14
	esp.Name.Center = true
	esp.Name.Outline = true
	esp.Name.Transparency = 1
	esp.Name.Visible = false
	esp.Health.Filled = true
	esp.Health.Thickness = 0
	esp.Health.Transparency = 1
	esp.Health.Visible = false
	esp.Distance.Size = 13
	esp.Distance.Center = true
	esp.Distance.Outline = true
	esp.Distance.Transparency = 1
	esp.Distance.Visible = false
end
local function removeESP(plr)
	local esp = espObjects[plr]
	if esp then
		for _, d in pairs(esp) do d:Remove() end
		espObjects[plr] = nil
	end
end
local function updateESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LP then continue end
		local esp = espObjects[plr]
		if not esp then createESP(plr) esp = espObjects[plr] end
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not (char and hrp and hum and hum.Health > 0) then
			for _, d in pairs(esp) do d.Visible = false end
			continue
		end
		local screenPos, visible = wts(hrp.Position)
		if not visible then
			for _, d in pairs(esp) do d.Visible = false end
			continue
		end
		local top, bottom = hrp.Position + Vector3.new(0, 3, 0), hrp.Position - Vector3.new(0, 3, 0)
		local top2D, vis1 = wts(top)
		local bottom2D, vis2 = wts(bottom)
		if not (vis1 and vis2) then
			for _, d in pairs(esp) do d.Visible = false end
			continue
		end
		local height = math.abs(top2D.Y - bottom2D.Y)
		local width = height / 2
		local x = top2D.X - width / 2
		local y = top2D.Y
		local isEnemy = plr.Team ~= LP.Team
		local color = isEnemy and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 100)
		esp.Box.Position = Vector2.new(x, y)
		esp.Box.Size = Vector2.new(width, height)
		esp.Box.Color = color
		esp.Box.Visible = true
		esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
		esp.Tracer.To = Vector2.new(x + width / 2, y + height)
		esp.Tracer.Color = color
		esp.Tracer.Visible = true
		esp.Name.Text = plr.Name
		esp.Name.Position = Vector2.new(x + width / 2, y - 16)
		esp.Name.Color = color
		esp.Name.Visible = true
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
		local barHeight = height * healthPercent
		esp.Health.Position = Vector2.new(x - 6, y + height - barHeight)
		esp.Health.Size = Vector2.new(4, barHeight)
		esp.Health.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
		esp.Health.Visible = true
		local dist = math.floor((hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
		esp.Distance.Text = tostring(dist) .. "m"
		esp.Distance.Position = Vector2.new(x + width / 2, y + height + 2)
		esp.Distance.Color = color
		esp.Distance.Visible = true
	end
end
local function startESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		createESP(plr)
	end
	espConnection = RunService.RenderStepped:Connect(updateESP)
	Players.PlayerAdded:Connect(createESP)
	Players.PlayerRemoving:Connect(removeESP)
end
local function stopESP()
	if espConnection then espConnection:Disconnect() espConnection = nil end
	for _, v in pairs(espObjects) do
		for _, d in pairs(v) do d:Remove() end
	end
	table.clear(espObjects)
end
local function SetupNoClip(enabled)
    if enabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, part in pairs(LP.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if LP.Character then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end
local spinConn
local function SetupSpinBot(enabled)
    if enabled then
        if spinConn then
            spinConn:Disconnect()
            spinConn = nil
        end
        spinConn = RunService.RenderStepped:Connect(function()
            if HRP and Char and Humanoid and Humanoid.Health > 0 then
                HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(8), 0)
            end
        end)
    else
        if spinConn then
            spinConn:Disconnect()
            spinConn = nil
        end
    end
end
local function DetectStaff()
    for _, plr in pairs(Players:GetPlayers()) do
        local name = plr.Name:lower()
        local display = plr.DisplayName:lower()
        if name:find("admin") or name:find("mod") or display:find("admin") or display:find("mod") then
            print("[StaffDetection] Detected staff player: " .. plr.Name .. ", teleporting out.")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, nil, LP)
            return
        end
    end
end
local fakeLagConnection
local HRP = nil
local delay = 0.1 -- 
local function SetupFakeLag(enabled)
    if enabled then
        if fakeLagConnection then
            fakeLagConnection:Disconnect()
            fakeLagConnection = nil
        end
        local player = game.Players.LocalPlayer
        local char = player and player.Character
        HRP = char and char:FindFirstChild("HumanoidRootPart")
        if not HRP then return end
        local accumulatedTime = 0
        fakeLagConnection = RunService.Heartbeat:Connect(function(dt)
            if not HRP or not HRP.Parent then return end
            accumulatedTime += dt
            if accumulatedTime >= delay then
                HRP.AssemblyLinearVelocity = HRP.AssemblyLinearVelocity
                accumulatedTime = 0
            end
        end)
    else
        if fakeLagConnection then
            fakeLagConnection:Disconnect()
            fakeLagConnection = nil
        end
    end
end
local function randomYawAngle()
    return math.rad(math.random(-8, 8))
end
local function smoothCameraRotate(camera, targetAngle, lerpAlpha)
    local cf = camera.CFrame
    local goal = cf * CFrame.Angles(0, targetAngle, 0)
    camera.CFrame = cf:Lerp(goal, lerpAlpha)
end
local function antiAFKLoop()
    while antiAFKEnabled do
        local playerActive = UserInputService:GetLastInputType() ~= Enum.UserInputType.None
        if playerActive then
            lastIdle = tick()
        end
        if (tick() - lastIdle) > 55 then
            -- Simulate right mouse button hold/release
            VirtualUser:Button2Down(Vector2.new())
            task.wait(0.1 + math.random() * 0.1)
            VirtualUser:Button2Up(Vector2.new())
            local cam = Workspace.CurrentCamera
            if cam then
                local angle = randomYawAngle()
                -- Smooth rotate with lerp to avoid snap
                smoothCameraRotate(cam, angle, 0.3)
            end
            lastIdle = tick()
            task.wait(60 + math.random())
        else
            task.wait(5)
        end
    end
end
local function StartAntiAFK()
    if antiAFKEnabled then return end
    antiAFKEnabled = true
    task.spawn(antiAFKLoop)
end
local function StopAntiAFK()
    antiAFKEnabled = false
end
steppedConnection = RunService.Stepped:Connect(function()
    if config.AutoJump then
        local state = Humanoid:GetState()
        if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Freefall then
            Humanoid.Jump = true
        end
    end

    if config.SneakyACBypass then
        local now = tick()
        if now - lastIdle > math.random(30, 60) then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            lastIdle = now
        end
    end

    if config.StaffDetection then
        pcall(DetectStaff)
    end
end)
local MainCategory = Window:Category("Blade ball", "http://www.roblox.com/asset/?id=8395621517")
local CombatPage = MainCategory:Button("Ball", "http://www.roblox.com/asset/?id=8395747586")
local CombatLeftSection = CombatPage:Section("Ball Options", "Left")
CombatLeftSection:Toggle({
    Title = "Basic Ap",
    Description = "Enable Basic Ap",
    Default = config.AutoParryV2
}, function(value)
    config.AutoParryV2 = value
    config.AutoParry = value
    if value then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/1f0yt/community/main/RedCircleBlock", true))()
    end
end)
local UniversalPage = MainCategory:Button("Visual", "http://www.roblox.com/asset/?id=8395747586")
local UniversalLeftSection = UniversalPage:Section("Esp Options", "Left")
UniversalLeftSection :Toggle({
    Title = "Player ESP",
    Description = "Enable Player Esp",
    Default = config.AdvancedPlayerESP,
}, function(state)
    config.AdvancedPlayerESP = state
    if state then
        startESP()
    else
        stopESP()
    end
end)
local PlayerModsPage = MainCategory:Button("Player", "http://www.roblox.com/asset/?id=8395747586")
local PlayerModsLeftSection = PlayerModsPage:Section("Player Options", "Left")
local PlayerModsRightSection = PlayerModsPage:Section("Anti Options", "Right")
PlayerModsLeftSection:Slider({
    Title = "WalkSpeed",
    Description = "Set Walk Speed",
    Default = config.WalkSpeed,
    Min = 45,
    Max = 800
}, function(value)
    config.WalkSpeed = value
    Humanoid.WalkSpeed = value
end)
PlayerModsLeftSection:Slider({
    Title = "JumpPower",
    Description = "Set Jump power",
    Default = config.JumpPower,
    Min = 50,
    Max = 800
}, function(value)
    config.JumpPower = value
    Humanoid.JumpPower = value
end)
PlayerModsLeftSection:Toggle({
    Title = "Fly",
    Description = "Enable fly",
    Default = config.FlyEnabled
}, function(value)
    config.FlyEnabled = value
    SetupFly(value)
end)
PlayerModsLeftSection:Toggle({
    Title = "NoClip",
    Description = "Enable Noclip",
    Default = config.Noclip
}, function(value)
    config.Noclip = value
    SetupNoClip(value)
end)
PlayerModsLeftSection:Toggle({
    Title = "SpinBot",
    Description = "Enable Spinbot",
    Default = config.SpinBot
}, function(value)
    config.SpinBot = value
    SetupSpinBot(value)
end)
PlayerModsRightSection:Toggle({
    Title = "Anti Fling (NEW)",
    Description = "Enable Anti Fling",
    Default = config.AntiFling,
}, function(state)
    config.AntiFling = state
    if state then
        AntiFling:Enable()
    else
        AntiFling:Disable()
    end
end)
PlayerModsRightSection:Toggle({
    Title = "Anti AFK",
    Description = "Bypass Idle Limit",
    Default = config.AntiAFK
}, function(value)
    config.AntiAFK = value
end)
PlayerModsLeftSection:Toggle({
    Title = "Fake Lag",
    Description = "Enable Fake Lag",
    Default = config.FakeLag
}, function(value)
    config.FakeLag = value
    SetupFakeLag(value)
end) 
local WorldCategory = Window:Category("World", "http://www.roblox.com/asset/?id=8395747586")
local WorldPage = WorldCategory:Button("World Options", "http://www.roblox.com/asset/?id=8395747586")
local WorldLeftSection = WorldPage:Section("World Toggles", "Left")
local WorldRightSection = WorldPage:Section("Performance Tweaks", "Right")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local connections = {}
local function safeDisconnect(connName)
    if connections[connName] then
        connections[connName]:Disconnect()
        connections[connName] = nil
    end
end
WorldLeftSection:Toggle({
    Title = "Zero Lighting",
    Description = "Set Lighting to max brightness, no shadows, no fog",
    Default = false,
}, function(v)
    if v then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.1
    end
end)
WorldLeftSection:Toggle({
    Title = "No Fog",
    Description = "Removes fog completely",
    Default = false,
}, function(v)
    Lighting.FogEnd = v and 1e10 or 1000
    Lighting.FogStart = 0
end)
WorldLeftSection:Toggle({
    Title = "Anti Void",
    Description = "TPs you up if you fall into the void",
    Default = false,
}, function(v)
    safeDisconnect("antiVoid")
    if v then
        connections.antiVoid = RunService.Stepped:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LP.Character.HumanoidRootPart
                if hrp.Position.Y < -25 then
                    hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
                end
            end
        end)
    end
end)
WorldLeftSection:Toggle({
    Title = "Gravity Lock",
    Description = "Locks gravity to 75 (low gravity)",
    Default = false,
}, function(v)
    Workspace.Gravity = v and 75 or 196.2
end)
WorldLeftSection:Toggle({
    Title = "Force Daytime",
    Description = "Locks time of day at 14:00",
    Default = false,
}, function(v)
    safeDisconnect("forceDaytime")
    if v then
        Lighting.ClockTime = 14
        connections.forceDaytime = RunService.Heartbeat:Connect(function()
            Lighting.ClockTime = 14
        end)
    else
        Lighting.ClockTime = 12
    end
end)
WorldLeftSection:Toggle({
    Title = "Disable Terrain Water",
    Description = "Removes all water in terrain",
    Default = false,
}, function(v)
    if v then
        for _, terrain in pairs(workspace:GetDescendants()) do
            if terrain:IsA("Terrain") then
                terrain:FillRegion(terrain.MaxExtents, 4, Enum.Material.Air)
            end
        end
    end
end)
WorldLeftSection:Toggle({
    Title = "Disable Skybox",
    Description = "Removes the skybox",
    Default = false,
}, function(v)
    if v then
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
    else
    end
end)
WorldLeftSection:Toggle({
    Title = "Disable Sound",
    Description = "Mutes all sounds",
    Default = false,
}, function(v)
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = v and 0 or 1
        end
    end
end)
WorldLeftSection:Toggle({
    Title = "Anti Foggy Screens",
    Description = "Removes dark fog overlays",
    Default = false,
}, function(v)
    Lighting.ColorShift_Top = v and Color3.new(1,1,1) or Color3.new(0,0,0)
    Lighting.ColorShift_Bottom = v and Color3.new(1,1,1) or Color3.new(0,0,0)
end)
WorldLeftSection:Toggle({
    Title = "Disable Blur Effects",
    Description = "Removes all blur",
    Default = false,
}, function(v)
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("BloomEffect") then
            effect.Enabled = not v
        end
    end
end)
WorldLeftSection:Toggle({
    Title = "Remove All Decals",
    Description = "Makes all decals invisible",
    Default = false,
}, function(v)
    for _, decal in pairs(workspace:GetDescendants()) do
        if decal:IsA("Decal") or decal:IsA("Texture") then
            decal.Transparency = v and 1 or 0
        end
    end
end)
WorldLeftSection:Toggle({
    Title = "Remove NPCs",
    Description = "Deletes all NPC models for performance",
    Default = false,
}, function(v)
    if v then
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name:lower():find("npc") then
                model:Destroy()
            end
        end
    end
end)
WorldRightSection:Toggle({
    Title = "FPS Boost",
    Description = "Removes textures",
    Default = false,
}, function(v)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic
            obj.Reflectance = v and 0 or 0.05
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = v and 1 or 0
        end
    end
end)
WorldRightSection:Toggle({
    Title = "No Shadows",
    Description = "Disables all shadows",
    Default = false,
}, function(v)
    Lighting.Technology = v and Enum.Technology.Compatibility or Enum.Technology.Future
end)
WorldRightSection:Toggle({
    Title = "Remove Particles",
    Description = "Disables all particle",
    Default = false,
}, function(v)
    for _, effect in pairs(workspace:GetDescendants()) do
        if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
            effect.Enabled = not v
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Delete Decorations",
    Description = "Removes decorative models",
    Default = false,
}, function(v)
    if v then
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model.Name:lower():find("deco") then
                model:Destroy()
            end
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Reduce Draw Distance",
    Description = "Reduce Draw Distance",
    Default = false,
}, function(v)
    if v then
        Workspace.FallenPartsDestroyHeight = 0 
        Workspace.CurrentCamera.FieldOfView = 70
    else
        Workspace.FallenPartsDestroyHeight = -500 
        Workspace.CurrentCamera.FieldOfView = 70
    end
end)
WorldRightSection:Toggle({
    Title = "Low Quality Particles",
    Description = "Reduces particle quality",
    Default = false,
}, function(v)
    local function setQuality(state)
        for _, emitter in pairs(workspace:GetDescendants()) do
            if emitter:IsA("ParticleEmitter") then
                emitter.Lifetime = NumberRange.new(state and 0.1 or 1)
                emitter.Rate = state and 5 or 50
                emitter.Speed = NumberRange.new(state and 1 or 10)
                emitter.Enabled = true
            end
        end
    end
    setQuality(v)
end)
WorldRightSection:Toggle({
    Title = "Disable Water Reflections",
    Description = "Turns off water reflections",
    Default = false,
}, function(v)
    Lighting.GlobalShadows = not v
end)
WorldRightSection:Toggle({
    Title = "Disable Global Shadows",
    Description = "Disables shadows",
    Default = false,
}, function(v)
    Lighting.GlobalShadows = not v
end)
WorldRightSection:Toggle({
    Title = "Remove NPC Sounds",
    Description = "Mutes all NPC sounds",
    Default = false,
}, function(v)
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") and sound.Name:lower():find("npc") then
            sound.Volume = v and 0 or 1
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Disable Sounds",
    Description = "Mutes all sounds",
    Default = false,
}, function(v)
    for _, sound in pairs(Lighting:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = v and 0 or 1
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Delete Text",
    Description = "Removes all Text",
    Default = false,
}, function(v)
    if v then
        for _, gui in pairs(workspace:GetDescendants()) do
            if gui:IsA("BillboardGui") then
                gui:Destroy()
            end
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Disable Water Waves",
    Description = "Disables water waves",
    Default = false,
}, function(v)
    if v then
        for _, terrain in pairs(workspace:GetDescendants()) do
            if terrain:IsA("Terrain") then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
            end
        end
    else
        for _, terrain in pairs(workspace:GetDescendants()) do
            if terrain:IsA("Terrain") then
                terrain.WaterWaveSize = 1
                terrain.WaterWaveSpeed = 1
            end
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Disable Lens Flare",
    Description = "Disables Lens effect",
    Default = false,
}, function(v)
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("LensFlare") then
            effect.Enabled = not v
        end
    end
end)
WorldRightSection:Toggle({
    Title = "Remove Teleporters",
    Description = "Destroys teleport pads",
    Default = false,
}, function(v)
    if v then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("teleport") or obj.Name:lower():find("tp") then
                obj:Destroy()
            end
        end
    end
end)
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ExecutorCategory = Window:Category("Executor Settings", "http://www.roblox.com/asset/?id=8395747586")
local ExecutorPage = ExecutorCategory:Button("Settings", "http://www.roblox.com/asset/?id=8395747586")
local ExecutorLeftSection = ExecutorPage:Section("Executor Settings", "Left")
local ExecutorRightSection = ExecutorPage:Section("Extra Settings", "Right")
ExecutorRightSection:Toggle({
    Title = "Unc Test",
    Description = "Test UNC on your executor",
    Default = false
}, function(enabled)
    if enabled then
        RunUncTest()
    end
end)
ExecutorLeftSection:Toggle({
    Title = "Spoof Executor",
    Description = "Spoof Executor",
    Default = true
}, function(value)
    if value then
        getgenv().syn = {
            protect_gui = function(gui) return gui end,
            queue_on_teleport = function(_) end,
            request = request or http_request or syn.request
        }
    else
        getgenv().syn = nil
    end
end)
ExecutorLeftSection:Toggle({
    Title = "Hide Executor",
    Description = "Hides Your Executor(Anti Cheat)",
    Default = false
}, function(value)
    if value then
        getgenv().identifyexecutor = function() return nil end
        getgenv().getexecutorname = function() return "Unknown" end
        print("[Executor] Detection blockers active.")
    else
        getgenv().identifyexecutor = nil
        getgenv().getexecutorname = nil
        print("[Executor] Detection blockers removed.")
    end
end)
local clearConsoleConn
ExecutorRightSection:Toggle({
    Title = "Auto Clear",
    Description = "Auto Clear Console",
    Default = true
}, function(value)
    if value then
        clearConsoleConn = task.spawn(function()
            while true do
                warn("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
                task.wait(10)
            end
        end)
    else
        if clearConsoleConn then
            task.cancel(clearConsoleConn)
            clearConsoleConn = nil
        end
    end
end)
local PlayerCategory = Window:Category("Protection", "http://www.roblox.com/asset/?id=8395747586")
local PlayerModsPage = PlayerCategory:Button("Anti Options", "http://www.roblox.com/asset/?id=8395747586")
local PlayerModsLeftSection = PlayerModsPage:Section("Anti Options [On by Default]", "Left")
PlayerModsLeftSection:Toggle({
    Title = "Anti Staff",
    Description = "Enable Staff Detection",
    Default = config.StaffDetection,
}, function(value)
    config.StaffDetection = value
end)
PlayerModsLeftSection:Toggle({
    Title = "Anti Staff Kick",
    Description = "Enable Anti Staff Kick ",
    Default = config.AntiKick,
}, function(value)
    config.AntiKick = value
    SetupAntiKick(value)
end)
PlayerModsLeftSection:Toggle({
    Title = "Anti Ban",
    Description = "Avoid Ban Waves (NEW)",
    Default = config.acbypass,
}, function(value)
    config.acbypass = value
end)

local ScriptLoaderCategory = Window:Category("Script Loader", "http://www.roblox.com/asset/?id=8395747586")
local ScriptLoaderPage = ScriptLoaderCategory:Button("Load Scripts", "http://www.roblox.com/asset/?id=8395747586")
local LoaderLeftSection = ScriptLoaderPage:Section("Popular Scripts", "Left")

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local infiniteYield = {
    loaded = false,
    gui = nil,
    inputConn = nil,
}
local function findInfiniteYieldGui()
    return CoreGui:FindFirstChild("InfiniteYield") 
        or CoreGui:FindFirstChild("InfiniteYield_UI")
        or CoreGui:FindFirstChild("InfiniteYieldGui")
end
local function disconnectInput()
    if infiniteYield.inputConn then
        infiniteYield.inputConn:Disconnect()
        infiniteYield.inputConn = nil
    end
end
local function hookInput()
    disconnectInput()
    infiniteYield.inputConn = UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local blockedKeys = {
            [291] = true, 
            [45] = true,  
            [303] = true, 
        }
        if blockedKeys[input.KeyCode.Value] then
        end
    end)
end
local function loadInfiniteYield()
    if infiniteYield.loaded then return end
    local success, err = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
    if not success then
        UILib:Notification("Failed: " .. tostring(err))
        return
    end
    for _ = 1, 20 do
        infiniteYield.gui = findInfiniteYieldGui()
        if infiniteYield.gui then break end
        task.wait(0.25)
    end

    if infiniteYield.gui then
        infiniteYield.gui.Enabled = true
    end

    hookInput()
    infiniteYield.loaded = true
    UILib:Notification("Infinite Yield loaded")
end
local function unloadInfiniteYield()
    if not infiniteYield.loaded then return end
    if infiniteYield.gui then
        infiniteYield.gui:Destroy()
        infiniteYield.gui = nil
    end
    disconnectInput()
    infiniteYield.loaded = false
    UILib:Notification("Infinite Yield disabled")
end
LoaderLeftSection:Toggle({
    Title = "Infinite Yield",
    Description = "Enable Infinite Yield",
    Default = false,
}, function(state)
    if state then
        loadInfiniteYield()
    else
        unloadInfiniteYield()
    end
end)
LoaderLeftSection:Toggle({
    Title = "Soluna Hub",
    Description = "Enable Soluna Hub",
}, function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Soluna-Hub-KEYLESS-43415"))()
    end)
    if not success then
        UILib:Notification("Failed: " .. tostring(err))
    else
        UILib:Notification("Soluna Hub loaded")
    end
end)
UILib:ToggleUI(true)
UILib:Notification("Script Hub @deadconvicess - Loaded")
