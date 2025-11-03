local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService('UserInputService')
local VirtualInput = game:GetService('VirtualInputManager')
local VirtualUser = game:GetService('VirtualUser')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Stats = game:GetService('Stats')
local TweenService = game:GetService('TweenService')
local Debris = game:GetService('Debris')

local LocalPlayer = Players.LocalPlayer

local WindUILib = loadstring(
    game:HttpGet(
        'https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'
    )
)()

local Window = WindUILib:CreateWindow({
    Title = 'Visual.cc',
    Author = 'by skidhub',
    Folder = 'Visual.cc',
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = false,
    Theme = 'Dark',
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = true,

    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print('User clicked profile')
        end,
    },

    KeySystem = {
        Key = { '1' },

        Note = 'Visual.cc Key System.',
        Thumbnail = {
            Image = 'rbxassetid://',
            Title = 'Visual.cc',
        },
        URL = 'YOUR LINK TO GET KEY (Discord, Linkvertise, Pastebin, etc.)',
        SaveKey = true,
    },
})

Window:Tag({
    Title = 'beta',
    Color = Color3.fromHex('#7A00FF'),
    Radius = 13,
})

WindUI:Notify({
    Title = 'Visual.cc',
    Content = 'Please enjoy our beta:)',
    Duration = 4,
    Icon = 'eye',
})

local CombatTab = Window:Tab({ Title = 'Combat', Icon = 'swords' })
local ParrySection =
    CombatTab:Section({ Title = 'Combat Options', Opened = true })

local ShopTab = Window:Tab({
    Title = 'Shop',
    Icon = 'shopping-bag',
})

local sSection = ShopTab:Section({
    Title = 'Shop',
    Opened = true,
})

local lSection = ShopTab:Section({
    Title = 'Lobby',
    Opened = true,
})

local UITab = Window:Tab({ Title = 'Settings', Icon = 'settings' })
local APSection = UITab:Section({ Title = 'AI Play', Opened = true })
local UISection = UITab:Section({ Title = 'Other Options', Opened = true })

local currentFPSCap = 240
local fpsUnlockerEnabled = false

local function setFPSUnlocker(state)
    fpsUnlockerEnabled = state
    if state then
        currentFPSCap = 1000
        setfpscap(currentFPSCap)
    else
        currentFPSCap = 240
        setfpscap(currentFPSCap)
    end
end

local spotlightPart
local spotlightEnabled = false

local function createSpotlight()
    if spotlightPart then
        spotlightPart:Destroy()
    end

    spotlightPart = Instance.new('Part')
    spotlightPart.Anchored = true
    spotlightPart.CanCollide = false
    spotlightPart.Material = Enum.Material.SmoothPlastic
    spotlightPart.Transparency = 0.45
    spotlightPart.Shape = Enum.PartType.Ball
    spotlightPart.Size = Vector3.new(0, 0, 0)
    spotlightPart.Color = Color3.fromRGB(0, 200, 255)
    spotlightPart.CastShadow = false
    spotlightPart.Name = 'BB_Spotlight'
    spotlightPart.Parent = Workspace
end

local function getActiveBall()
    local ballsFolder = Workspace:FindFirstChild('Balls')
    if not ballsFolder then
        return nil
    end
    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:IsA('BasePart') and not ball.Anchored then
            return ball
        end
    end
end

local function computeSpotlightRadius(ball)
    local speed = ball.Velocity.Magnitude
    local baseRadius = math.clamp(speed / 3 + 8, 12, 40)
    return baseRadius
end

RunService.RenderStepped:Connect(function()
    if not spotlightEnabled then
        if spotlightPart then
            spotlightPart.Size = Vector3.new(0, 0, 0)
        end
        return
    end

    local ball = getActiveBall()
    if ball and spotlightPart then
        local rad = computeSpotlightRadius(ball)
        local targetSize = Vector3.new(rad, rad, rad)
        local tweenInfo =
            TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        TweenService:Create(spotlightPart, tweenInfo, {
            Size = targetSize,
            CFrame = ball.CFrame,
        }):Play()
        local t = tick() * 0.8
        local r = (math.sin(t) * 0.5 + 0.5) * 150
        local g = (math.sin(t + 2) * 0.5 + 0.5) * 200
        local b = (math.sin(t + 4) * 0.5 + 0.5) * 255
        spotlightPart.Color = Color3.fromRGB(r, g, b)
    elseif spotlightPart then
        spotlightPart.Size = Vector3.new(0, 0, 0)
    end
end)
createSpotlight()

local antiAFK = false
local antiAFKConn, antiAFKActivity
local function enableAntiAFK()
    if antiAFK then
        return
    end
    antiAFK = true
    antiAFKConn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
    antiAFKActivity = RunService.Heartbeat:Connect(function()
        if math.random() < 0.01 then
            local char = LocalPlayer.Character
            if char then
                pcall(function()
                    char:TranslateBy(
                        Vector3.new(
                            (math.random() - 0.5) * 0.1,
                            0,
                            (math.random() - 0.5) * 0.1
                        )
                    )
                end)
            end
        end
    end)
end
local function disableAntiAFK()
    if not antiAFK then
        return
    end
    antiAFK = false
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
    if antiAFKActivity then
        antiAFKActivity:Disconnect()
        antiAFKActivity = nil
    end
end

local CONFIG = {
    BallFollowDistance = 12,
    BallFollowY = 6,
    BallSpawnGrace = 0.1,
}

local ballFollowConn

local function setFollowBall(enabled)
    if enabled then
        if ballFollowConn then
            ballFollowConn:Disconnect()
        end

        ballFollowConn = RunService.Heartbeat:Connect(function()
            local ball = getFastestBall()
            local char = LocalPlayer.Character
            local hrp = char
                and (
                    char:FindFirstChild('HumanoidRootPart')
                    or char:FindFirstChild('Torso')
                )
            if not ball or not hrp then
                return
            end

            if tick() - lastBallSpawn < CONFIG.BallSpawnGrace then
                return
            end

            local vel = ball.AssemblyLinearVelocity or Vector3.zero
            local dir = (vel.Magnitude > 0.1) and vel.Unit
                or ball.CFrame.LookVector
            local targetPos = ball.Position
                - dir * CONFIG.BallFollowDistance
                + Vector3.new(0, CONFIG.BallFollowY, 0)

            local groundY = Workspace:FindPartOnRayWithIgnoreList(
                Ray.new(targetPos, Vector3.new(0, -50, 0)),
                { char }
            )

            if groundY then
                local hitPos = select(
                    2,
                    Workspace:FindPartOnRayWithIgnoreList(
                        Ray.new(targetPos, Vector3.new(0, -50, 0)),
                        { char }
                    )
                )
                targetPos = Vector3.new(
                    targetPos.X,
                    math.max(hitPos.Y + 3, targetPos.Y),
                    targetPos.Z
                )
            else
                targetPos =
                    Vector3.new(targetPos.X, targetPos.Y + 2, targetPos.Z)
            end

            pcall(function()
                hrp.CFrame = CFrame.new(targetPos, ball.Position)
                local humanoid = char:FindFirstChildOfClass('Humanoid')
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end)
        end)
    else
        if ballFollowConn then
            ballFollowConn:Disconnect()
            ballFollowConn = nil
        end

        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass('Humanoid')
        if humanoid then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end
end

local antiClashConn
local ballLockConn

local CONFIG = {
    AntiClashDistance = 46,
    AntiClashPredictionTime = 0.1,
    AntiClashSpeed = 60,
    BallSpawnGrace = 0.2,
}

local function willCollide(origin, vel, target, radius, t)
    local pred = origin + (vel or Vector3.new()) * (t or 0)
    return (pred - target).Magnitude <= (radius or 0)
end

local function setAntiClash(enabled)
    if enabled then
        if antiClashConn then
            antiClashConn:Disconnect()
        end
        antiClashConn = RunService.Heartbeat:Connect(function(dt)
            local char = LocalPlayer.Character
            if not char then
                return
            end
            local hrp = char:FindFirstChild('HumanoidRootPart')
            if not hrp then
                return
            end

            local move, threat = Vector3.new(), false
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local c = p.Character
                    local other = c
                        and (
                            c:FindFirstChild('HumanoidRootPart')
                            or c:FindFirstChild('Torso')
                        )
                    if other then
                        local v = other.AssemblyLinearVelocity or Vector3.new()
                        if
                            willCollide(
                                other.Position,
                                v,
                                hrp.Position,
                                CONFIG.AntiClashDistance,
                                CONFIG.AntiClashPredictionTime
                            )
                        then
                            local away = hrp.Position - other.Position
                            if away.Magnitude > 0 then
                                move += away.Unit
                                threat = true
                            end
                        end
                    end
                end
            end
            if threat and move.Magnitude > 0 then
                local speed = math.clamp(
                    CONFIG.AntiClashSpeed * (dt or 1),
                    1,
                    CONFIG.AntiClashSpeed
                )
                local newPos = hrp.Position + move.Unit * speed
                pcall(function()
                    hrp.CFrame =
                        CFrame.new(newPos, newPos + hrp.CFrame.LookVector)
                end)
            end
        end)
    else
        if antiClashConn then
            antiClashConn:Disconnect()
            antiClashConn = nil
        end
    end
end

local antiFlingConn
local antiFling = false
local function enableAntiFling()
    if antiFling then
        return
    end
    antiFling = true
    if antiFlingConn then
        antiFlingConn:Disconnect()
        antiFlingConn = nil
    end
    antiFlingConn = RunService.Stepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild('HumanoidRootPart')
                if hrp then
                    pcall(function()
                        hrp.Velocity = Vector3.new()
                        hrp.RotVelocity = Vector3.new()
                        hrp.AssemblyLinearVelocity = Vector3.new()
                        hrp.AssemblyAngularVelocity = Vector3.new()
                    end)
                end
            end
        end
    end)
end
local function disableAntiFling()
    if not antiFling then
        return
    end
    antiFling = false
    if antiFlingConn then
        antiFlingConn:Disconnect()
        antiFlingConn = nil
    end
end

local AggressiveAI = {
    BALL_SEARCH_RADIUS = 80,
    SAFE_DISTANCE = 10,
    STRAFE_RADIUS = 12,
    BALL_TRACK_PREDICTION = 0.25,
    aiConnection = nil,
    respawnConn = nil,
    humanoid = nil,
    hrp = nil,
    enabled = false,
}

function AggressiveAI:waitForCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    self.humanoid = char:WaitForChild('Humanoid')
    self.hrp = char:WaitForChild('HumanoidRootPart')
end

function AggressiveAI:getClosestBall()
    local bf = Workspace:FindFirstChild('Balls')
    if not bf then
        return nil
    end
    local closest, closestDist
    for _, ball in pairs(bf:GetChildren()) do
        if ball:IsA('BasePart') then
            local dist = (ball.Position - self.hrp.Position).Magnitude
            if
                dist <= self.BALL_SEARCH_RADIUS
                and (not closest or dist < closestDist)
            then
                closest = ball
                closestDist = dist
            end
        end
    end
    return closest
end

function AggressiveAI:predictBallPosition(ball)
    if not ball or not ball:IsA('BasePart') then
        return nil
    end
    local vel = ball.AssemblyLinearVelocity or Vector3.new()

    local pred = ball.Position + vel * self.BALL_TRACK_PREDICTION
    return pred
end

function AggressiveAI:aiStep(dt)
    if not self.humanoid or not self.hrp then
        return
    end
    local ball = self:getClosestBall()
    if not ball then
        return
    end
    local targetPos = self:predictBallPosition(ball) or ball.Position
    local dist = (targetPos - self.hrp.Position).Magnitude

    if dist > self.SAFE_DISTANCE then
        pcall(function()
            self.humanoid:MoveTo(targetPos)
        end)
    else
        local dir = (targetPos - self.hrp.Position)
        local right = Vector3.new(-dir.Z, 0, dir.X).Unit
        if right.Magnitude ~= right.Magnitude then
            right = Vector3.new(1, 0, 0)
        end
        local angle = (tick() % (math.pi * 2))
        local offset = right * math.cos(angle) * self.STRAFE_RADIUS
            + Vector3.new(0, 0, math.sin(angle))
                * (self.STRAFE_RADIUS * 0.25)
        pcall(function()
            self.humanoid:MoveTo(targetPos + offset)
        end)
    end

    local ok, lookDir = pcall(function()
        return (ball.Position - self.hrp.Position).Unit
    end)
    if ok and lookDir and lookDir.Magnitude > 0 then
        pcall(function()
            self.hrp.CFrame =
                CFrame.lookAt(self.hrp.Position, self.hrp.Position + lookDir)
        end)
    end
end

function AggressiveAI:enable(state)
    if state and not self.enabled then
        self:waitForCharacter()
        if self.aiConnection then
            self.aiConnection:Disconnect()
        end
        self.aiConnection = RunService.Heartbeat:Connect(function(dt)
            self:aiStep(dt)
        end)
        if self.respawnConn then
            self.respawnConn:Disconnect()
        end
        self.respawnConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.1)
            self:waitForCharacter()
        end)
        self.enabled = true
    elseif not state and self.enabled then
        if self.aiConnection then
            self.aiConnection:Disconnect()
            self.aiConnection = nil
        end
        if self.respawnConn then
            self.respawnConn:Disconnect()
            self.respawnConn = nil
        end
        if self.humanoid then
            pcall(function()
                self.humanoid:Move(Vector3.zero, false)
            end)
        end
        self.enabled = false
    end
end

local PassiveAI = {
    WANDER_RADIUS = 80,
    MIN_MOVE_DISTANCE = 18,
    TARGET_REACH_THRESHOLD = 10,
    TARGET_CHANGE_TIME = { 5, 12 },
    WALL_CHECK_DISTANCE = 28,
    aiConnection = nil,
    respawnConn = nil,
    humanoid = nil,
    hrp = nil,
    spawnPos = nil,
    currentTarget = nil,
    timeUntilNextTarget = 0,
    enabled = false,
}

function PassiveAI:waitForCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    self.humanoid = char:WaitForChild('Humanoid')
    self.hrp = char:WaitForChild('HumanoidRootPart')
    self.spawnPos = self.hrp.Position
    self.currentTarget = nil
    self.timeUntilNextTarget = 0
end

function PassiveAI:getRandomTarget()
    local angle = math.random() * math.pi * 2
    local distance = math.random(self.MIN_MOVE_DISTANCE, self.WANDER_RADIUS)
    local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * distance
    return self.spawnPos + offset
end

function PassiveAI:isPathClear(targetPos)
    if not self.hrp then
        return false
    end
    local direction = (targetPos - self.hrp.Position)
    if direction.Magnitude == 0 then
        return true
    end
    local dir = direction.Unit * self.WALL_CHECK_DISTANCE
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local hit = Workspace:Raycast(self.hrp.Position, dir, params)
    return not hit
end

function PassiveAI:aiStep(dt)
    if not self.humanoid or not self.hrp then
        return
    end
    self.timeUntilNextTarget = math.max(0, self.timeUntilNextTarget - dt)

    if
        not self.currentTarget
        or (self.hrp.Position - self.currentTarget).Magnitude <= self.TARGET_REACH_THRESHOLD
        or self.timeUntilNextTarget <= 0
    then
        local attempts = 0
        repeat
            self.currentTarget = self:getRandomTarget()
            attempts = attempts + 1
        until self:isPathClear(self.currentTarget) or attempts >= 10
        self.timeUntilNextTarget =
            math.random(self.TARGET_CHANGE_TIME[1], self.TARGET_CHANGE_TIME[2])
    end

    if self.currentTarget then
        pcall(function()
            self.humanoid:MoveTo(self.currentTarget)
        end)
        local dir = (self.currentTarget - self.hrp.Position)
        if dir.Magnitude > 0 then
            local lookDir = dir.Unit
            pcall(function()
                self.hrp.CFrame = CFrame.lookAt(
                    self.hrp.Position,
                    self.hrp.Position + lookDir
                )
            end)
        end
    end
end

function PassiveAI:enable(state)
    if state and not self.enabled then
        self:waitForCharacter()
        if self.aiConnection then
            self.aiConnection:Disconnect()
        end
        self.aiConnection = RunService.Heartbeat:Connect(function(dt)
            self:aiStep(dt)
        end)
        if self.respawnConn then
            self.respawnConn:Disconnect()
        end
        self.respawnConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.1)
            self:waitForCharacter()
        end)
        self.enabled = true
    elseif not state and self.enabled then
        if self.aiConnection then
            self.aiConnection:Disconnect()
            self.aiConnection = nil
        end
        if self.respawnConn then
            self.respawnConn:Disconnect()
            self.respawnConn = nil
        end
        if self.humanoid then
            pcall(function()
                self.humanoid:Move(Vector3.zero, false)
            end)
        end
        self.enabled = false
    end
end

local noRenderEnabled = false
local noRenderHighlights = {}
local noRenderConn

local function setNoRender(state)
    noRenderEnabled = state

    local function clearHighlights()
        for _, hl in ipairs(noRenderHighlights) do
            if hl and hl.Destroy then
                pcall(function()
                    hl:Destroy()
                end)
            end
        end
        table.clear(noRenderHighlights)
    end

    local function disconnectConn()
        if noRenderConn then
            noRenderConn:Disconnect()
            noRenderConn = nil
        end
    end

    clearHighlights()
    disconnectConn()

    if not state then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if
                obj:IsA('ParticleEmitter')
                or obj:IsA('Smoke')
                or obj:IsA('Fire')
                or obj:IsA('Beam')
                or obj:IsA('Trail')
                or obj:IsA('Explosion')
                or obj:IsA('Sparkles')
            then
                pcall(function()
                    obj.Enabled = true
                end)
            end
        end
        return
    end

    task.wait(0.2)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char then
        return
    end

    local function makeHighlight(target)
        local hl = Instance.new('Highlight')
        hl.FillColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = target
        table.insert(noRenderHighlights, hl)
    end

    makeHighlight(char)
    local head = char:FindFirstChild('Head')
    if head then
        makeHighlight(head)
    end

    local removeClasses = {
        'ParticleEmitter',
        'Smoke',
        'Fire',
        'Beam',
        'Trail',
        'Explosion',
        'Sparkles',
    }

    local function disableVisual(obj)
        if table.find(removeClasses, obj.ClassName) then
            pcall(function()
                obj.Enabled = false
            end)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        disableVisual(obj)
    end

    noRenderConn = workspace.DescendantAdded:Connect(disableVisual)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if not noRenderEnabled then
            return
        end
        task.wait(0.5)
        clearHighlights()
        makeHighlight(newChar)
        local newHead = newChar:FindFirstChild('Head')
        if newHead then
            makeHighlight(newHead)
        end
    end)
end

local clientCharacter = LocalPlayer.Character
    or LocalPlayer.CharacterAdded:Wait()
local clientHumanoid = clientCharacter:FindFirstChildOfClass('Humanoid')
local AliveGroup = Workspace:FindFirstChild('Alive')

local lastInputType = UserInputService:GetLastInputType()
local currentMousePos = nil
local parryAnimation = nil
local remoteEvents = {}
local parryKey = nil

local parryCounter = 0
local spamThreshold = 0.45
local parryDelay = 0.020

local smoothRadians = 0
local lastStableTime = tick()
local recentVels = {}

local revertedRemotes = {}
local originalMetatables = {}

local AnimStorage = { list = {}, current = nil, track = nil }
for _, anim in pairs(ReplicatedStorage.Misc.Emotes:GetChildren()) do
    if anim:IsA('Animation') and anim:GetAttribute('EmoteName') then
        AnimStorage.list[anim:GetAttribute('EmoteName')] = anim
    end
end

local AutoParry = {}
local activeMethod = 'Remote'
local FirstParryDone = false

function AutoParry.playParryAnimation()
    local baseParryAnim =
        ReplicatedStorage.Shared.SwordAPI.Collection.Default:FindFirstChild(
            'GrabParry'
        )
    local currSword =
        LocalPlayer.Character:GetAttribute('CurrentlyEquippedSword')
    if not currSword or not baseParryAnim then
        return
    end

    local swordInfo =
        ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(
            currSword
        )
    if not swordInfo or not swordInfo.AnimationType then
        return
    end

    for _, folder in
        pairs(ReplicatedStorage.Shared.SwordAPI.Collection:GetChildren())
    do
        if folder.Name == swordInfo.AnimationType then
            local selName = folder:FindFirstChild('Grab') and 'Grab'
                or 'GrabParry'
            if folder:FindFirstChild(selName) then
                baseParryAnim = folder[selName]
            end
        end
    end

    parryAnimation =
        LocalPlayer.Character.Humanoid.Animator:LoadAnimation(baseParryAnim)
    parryAnimation:Play()
end

function AutoParry.fetchBalls()
    local balls = {}
    for _, b in pairs(Workspace.Balls:GetChildren()) do
        if b:GetAttribute('realBall') then
            b.CanCollide = false
            table.insert(balls, b)
        end
    end
    return balls
end

function AutoParry.fetchBall()
    for _, b in pairs(Workspace.Balls:GetChildren()) do
        if b:GetAttribute('realBall') then
            b.CanCollide = false
            return b
        end
    end
end

function AutoParry.computeParryData(mode)
    local eventTable = {}
    local cam = Workspace.CurrentCamera
    if
        lastInputType == Enum.UserInputType.MouseButton1
        or lastInputType == Enum.UserInputType.MouseButton2
        or lastInputType == Enum.UserInputType.Keyboard
    then
        local mPos = UserInputService:GetMouseLocation()
        currentMousePos = { mPos.X, mPos.Y }
    else
        currentMousePos = { cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2 }
    end

    for _, ent in ipairs(AliveGroup:GetChildren()) do
        eventTable[tostring(ent)] =
            cam:WorldToScreenPoint(ent.PrimaryPart.Position)
    end

    local camPos = cam.CFrame.Position
    if mode == 'Custom' then
        return { 0, cam.CFrame, eventTable, currentMousePos }
    elseif mode == 'Backwards' then
        return {
            0,
            CFrame.new(camPos, camPos - (cam.CFrame.LookVector * 1000)),
            eventTable,
            currentMousePos,
        }
    elseif mode == 'Random' then
        return {
            0,
            CFrame.new(
                camPos,
                Vector3.new(
                    math.random(-3000, 3000),
                    math.random(-3000, 3000),
                    math.random(-3000, 3000)
                )
            ),
            eventTable,
            currentMousePos,
        }
    elseif mode == 'Straight' then
        return {
            0,
            CFrame.new(camPos, camPos + (cam.CFrame.LookVector * 1000)),
            eventTable,
            currentMousePos,
        }
    elseif mode == 'Up' then
        return {
            0,
            CFrame.new(camPos, camPos + (cam.CFrame.UpVector * 1000)),
            eventTable,
            currentMousePos,
        }
    elseif mode == 'Right' then
        return {
            0,
            CFrame.new(camPos, camPos + (cam.CFrame.RightVector * 1000)),
            eventTable,
            currentMousePos,
        }
    elseif mode == 'Left' then
        return {
            0,
            CFrame.new(camPos, camPos - (cam.CFrame.RightVector * 1000)),
            eventTable,
            currentMousePos,
        }
    elseif mode == 'Dot' then
        local ball = AutoParry.fetchBall()
        if ball then
            return {
                0,
                CFrame.new(camPos, ball.Position),
                eventTable,
                currentMousePos,
            }
        else
            return { 0, cam.CFrame, eventTable, currentMousePos }
        end
    else
        return mode
    end
end

local function canProcessParry()
    local Character = LocalPlayer and LocalPlayer.Character
    if not Character then
        return false
    end

    local hrp = Character:FindFirstChild('HumanoidRootPart')
    if not hrp then
        return false
    end

    local blockedAbilities = {
        'SingularityCape',
        'Infinity',
        'Freeze',
        'Telekinesis',
        'AerodynamicSlash',
        'SlashesOfFury',
        'Duality',
        'TimeHole',
        'PlrDribbled',
        'PlrPulled',
        'Martyrdom',
        'PlrCalmingDeflection',
        'DeathSlash',
        'ContinuityPortal',
    }

    for _, ability in ipairs(blockedAbilities) do
        if hrp:FindFirstChild(ability) then
            return false
        end
    end

    return true
end

function AutoParry.triggerParry(mode)
    if not canProcessParry() then
        return
    end
    local pData = AutoParry.computeParryData(mode)

    if activeMethod == 'Remote' then
        if not FirstParryDone then
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.1)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            FirstParryDone = true
        else
            for remote, args in pairs(revertedRemotes) do
                if remote:IsA('RemoteEvent') then
                    remote:FireServer(unpack(args))
                elseif remote:IsA('RemoteFunction') then
                    remote:InvokeServer(unpack(args))
                end
            end
        end
    elseif activeMethod == 'Keypress' then
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(parryDelay)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end

    if parryCounter > 7 then
        return false
    end
    parryCounter = parryCounter + 1
    task.delay(spamThreshold, function()
        if parryCounter > 0 then
            parryCounter = parryCounter - 1
        end
    end)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

function AutoParry.detectCurve()
    local ball = AutoParry.fetchBall()
    if not ball then
        return false
    end
    local zoom = ball:FindFirstChild('zoomies')
    if not zoom then
        return false
    end

    local currentVel = zoom.VectorVelocity
    table.insert(recentVels, currentVel)
    if #recentVels > 4 then
        table.remove(recentVels, 1)
    end

    local avgVel = currentVel
    if #recentVels > 1 then
        local sum = Vector3.new(0, 0, 0)
        for _, vel in ipairs(recentVels) do
            sum = sum + vel
        end
        avgVel = sum / #recentVels
    end

    local ballDir = avgVel.Unit
    local toBall = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit
    local dotVal = toBall:Dot(ballDir)

    if dotVal >= 0.95 then
        return false
    end

    local similarity = toBall:Dot((ballDir - avgVel).Unit)
    local deltaDot = dotVal - similarity

    local thresh = 0.12
    if avgVel.Magnitude > 150 then
        thresh = thresh - 0.02
    end

    if deltaDot < thresh then
        lastStableTime = tick()
        return true
    end

    local radians = math.rad(math.asin(dotVal))
    smoothRadians = lerp(smoothRadians, radians, 0.85)
    if smoothRadians < 0.015 then
        lastStableTime = tick()
    end

    if (tick() - lastStableTime) < 0.07 then
        return true
    end

    if #recentVels == 4 then
        local intendedDiff1 = (ballDir - recentVels[1].Unit).Unit
        local diff1 = dotVal - toBall:Dot(intendedDiff1)
        local intendedDiff2 = (ballDir - recentVels[2].Unit).Unit
        local diff2 = dotVal - toBall:Dot(intendedDiff2)
        if diff1 < thresh or diff2 < thresh then
            return true
        end
    end

    return dotVal < thresh
end

local closestEntity = nil
function AutoParry.findNearestEntity()
    local minDist = math.huge
    for _, ent in ipairs(AliveGroup:GetChildren()) do
        if tostring(ent) ~= tostring(LocalPlayer) then
            local d =
                LocalPlayer:DistanceFromCharacter(ent.PrimaryPart.Position)
            if d < minDist then
                minDist = d
                closestEntity = ent
            end
        end
    end
    return closestEntity
end

function AutoParry.getEntityProperties()
    AutoParry.findNearestEntity()
    if not closestEntity then
        return false
    end
    local vel = closestEntity.PrimaryPart.Velocity
    local dir = (
        LocalPlayer.Character.PrimaryPart.Position
        - closestEntity.PrimaryPart.Position
    ).Unit
    local dist = (
        LocalPlayer.Character.PrimaryPart.Position
        - closestEntity.PrimaryPart.Position
    ).Magnitude
    return {
        Velocity = vel,
        Direction = dir,
        Distance = dist,
    }
end

function AutoParry.getBallProperties()
    local ball = AutoParry.fetchBall()
    if not ball then
        return nil
    end
    local ballVel = ball.AssemblyLinearVelocity
    local sum = Vector3.new(0, 0, 0)
    local cnt = 0
    for _, vel in ipairs(recentVels) do
        sum = sum + vel
        cnt = cnt + 1
    end
    if cnt > 0 then
        ballVel = sum / cnt
    end
    local ballDir = ballVel.Unit
    local bDist = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Magnitude
    local ballDot = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit:Dot(
        ballDir
    )
    return {
        Velocity = ballVel,
        Direction = ballDir,
        Distance = bDist,
        Dot = ballDot,
    }
end

function AutoParry.computeSpamAccuracy(params)
    local ball = AutoParry.fetchBall()
    if not ball then
        return 0
    end
    AutoParry.findNearestEntity()
    local accuracy = 0
    local vel = ball.AssemblyLinearVelocity
    local spd = vel.Magnitude
    local toBall = (LocalPlayer.Character.PrimaryPart.Position - ball.Position).Unit
    local ballDir = vel.Unit
    local dot = toBall:Dot(ballDir)
    local targetPos = closestEntity and closestEntity.PrimaryPart.Position
        or Vector3.new()
    local targetDist = LocalPlayer:DistanceFromCharacter(targetPos)
    local maxSpamRange = params.Ping + math.min(spd / 6.5, 95)
    if params.EntityProps.Distance > maxSpamRange then
        return accuracy
    end
    if params.BallProps.Distance > maxSpamRange then
        return accuracy
    end
    if targetDist > maxSpamRange then
        return accuracy
    end
    local maxSpeed = 5 - math.min(spd / 5, 5)
    local adjDot = math.clamp(dot, -1, 0) * maxSpeed
    accuracy = maxSpamRange - adjDot
    return accuracy
end

local function isValidRemoteArgs(args)
    return #args == 7
        and type(args[2]) == 'string'
        and type(args[3]) == 'number'
        and typeof(args[4]) == 'CFrame'
        and type(args[5]) == 'table'
        and type(args[6]) == 'table'
        and type(args[7]) == 'boolean'
end

local function hookRemote(remote)
    if not revertedRemotes[remote] then
        if not originalMetatables[getmetatable(remote)] then
            originalMetatables[getmetatable(remote)] = true

            local meta = getrawmetatable(remote)
            setreadonly(meta, false)

            local oldIndex = meta.__index
            meta.__index = function(self, key)
                if
                    (key == 'FireServer' and self:IsA('RemoteEvent'))
                    or (key == 'InvokeServer' and self:IsA('RemoteFunction'))
                then
                    return function(_, ...)
                        local args = { ... }
                        if isValidRemoteArgs(args) then
                            if not revertedRemotes[self] then
                                revertedRemotes[self] = args
                            end
                        end
                        return oldIndex(self, key)(_, unpack(args))
                    end
                end
                return oldIndex(self, key)
            end

            setreadonly(meta, true)
        end
    end
end

for _, remote in pairs(ReplicatedStorage:GetChildren()) do
    if remote:IsA('RemoteEvent') or remote:IsA('RemoteFunction') then
        hookRemote(remote)
    end
end
ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA('RemoteEvent') or child:IsA('RemoteFunction') then
        hookRemote(child)
    end
end)

local autoParryEnabled = true
local autoParryConnection
ParrySection:Toggle({
    Title = 'Auto Parry',
    Desc = 'Automatically blocks incoming balls',
    Def = true,
    Callback = function(state)
        autoParryEnabled = state
        if state then
            autoParryConnection = RunService.PreSimulation:Connect(function()
                local ball = AutoParry.fetchBall()
                local ballList = AutoParry.fetchBalls()
                for _, b in ipairs(ballList) do
                    if not b then
                        repeat
                            task.wait()
                        until b
                    end
                    local zoom = b:FindFirstChild('zoomies')
                    if not zoom then
                        return
                    end

                    local ballTarget = b:GetAttribute('target')
                    local primaryTarget = ball and ball:GetAttribute('target')
                    local vel = zoom.VectorVelocity
                    local dist = (
                        LocalPlayer.Character.PrimaryPart.Position - b.Position
                    ).Magnitude
                    local spd = vel.Magnitude
                    local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()
                        / 10
                    local parryThresh = (spd / 3.25) + ping
                    local curved = AutoParry.detectCurve()

                    if
                        ballTarget == tostring(LocalPlayer)
                        and dist <= parryThresh
                    then
                        AutoParry.triggerParry(selectedParryMode)
                    end
                end
            end)
        else
            if autoParryConnection then
                autoParryConnection:Disconnect()
                autoParryConnection = nil
            end
        end
    end,
})

local autoSpamEnabled = false
local autoSpamConnection
ParrySection:Toggle({
    Title = 'Auto Spam',
    Desc = 'Automatically spams when conditions are met',
    Def = false,
    Callback = function(state)
        autoSpamEnabled = state
        if state then
            autoSpamConnection = RunService.PreSimulation:Connect(function()
                local b = AutoParry.fetchBall()
                if not b then
                    return
                end
                local zoom = b:FindFirstChild('zoomies')
                if not zoom then
                    return
                end
                AutoParry.findNearestEntity()
                local pingVal =
                    Stats.Network.ServerStatsItem['Data Ping']:GetValue()
                local pThreshold = math.clamp(pingVal / 10, 10, 16)
                local ballProps = AutoParry.getBallProperties()
                local entityProps = AutoParry.getEntityProperties()
                local spamAcc = AutoParry.computeSpamAccuracy({
                    BallProps = ballProps,
                    EntityProps = entityProps,
                    Ping = pThreshold,
                })
                local d = LocalPlayer:DistanceFromCharacter(b.Position)
                if d <= spamAcc and parryCounter > 1 then
                    AutoParry.triggerParry(selectedParryMode)
                end
            end)
        else
            if autoSpamConnection then
                autoSpamConnection:Disconnect()
                autoSpamConnection = nil
            end
        end
    end,
})

local tSection = CombatTab:Section({ Title = 'Parry Options', Opened = true })

tSection:Slider({
    Title = 'Parry Accuracy',
    Desc = 'Adjust parry Accuracy',
    Step = 1,
    Value = { Min = 0, Max = 100, Default = 100 },
    Callback = function(val)
        local adjusted = val / 5.5
        getgenv().Parry_Accuracy = adjusted
    end,
})

tSection:Slider({
    Title = 'Spam Threshold',
    Desc = 'Adjust parry spam timing',
    Step = 0.01,
    Value = { Min = 0.05, Max = 1.0, Default = spamThreshold },
    Callback = function(val)
        spamThreshold = val
    end,
})

tSection:Slider({
    Title = 'Parry Delay',
    Desc = 'Adjust key press delay during parry',
    Step = 0.001,
    Value = { Min = 0.01, Max = 0.2, Default = parryDelay },
    Callback = function(val)
        parryDelay = val
    end,
})

local VisualSection = CombatTab:Section({ Title = 'Visuals', Opened = true })

local visualEnabled = false
local visPart = Instance.new('Part')
visPart.Shape = Enum.PartType.Ball
visPart.Anchored = true
visPart.CanCollide = false
visPart.Material = Enum.Material.ForceField
visPart.Transparency = 0.5
visPart.Parent = Workspace
visPart.Size = Vector3.new(0, 0, 0)

local function toggleVisualizer(state)
    visualEnabled = state
    if not state then
        visPart.Size = Vector3.new(0, 0, 0)
    end
end

VisualSection:Toggle({
    Title = 'Parry Visualizer',
    Desc = 'Displays Parry Visualizer',
    Def = false,
    Callback = function(state)
        toggleVisualizer(state)
    end,
})

VisualSection:Toggle({
    Title = 'Ball Visualizer',
    Desc = 'Displays Ball Visualizer ',
    Def = false,
    Callback = function(state)
        spotlightEnabled = state
        if state then
            createSpotlight()
        else
            if spotlightPart then
                spotlightPart:Destroy()
                spotlightPart = nil
            end
        end
    end,
})

local decSection = CombatTab:Section({
    Title = 'Detections',
    Opened = true,
})

decSection:Toggle({
    Title = 'Singularity',
    Desc = 'Detect Singularity',
    Def = true,
    Callback = function(state)
        abilityToggles.SingularityCape = state
    end,
})

decSection:Toggle({
    Title = 'Infinity',
    Desc = 'Detect Infinity ',
    Def = true,
    Callback = function(state)
        abilityToggles.Infinity = state
    end,
})

decSection:Toggle({
    Title = 'SlashesOfFury',
    Desc = 'Detect SlashesOfFury',
    Def = true,
    Callback = function(state)
        abilityToggles.SlashesOfFury = state
    end,
})

decSection:Toggle({
    Title = 'TimeHole',
    Desc = 'Detect TimeHole',
    Def = true,
    Callback = function(state)
        abilityToggles.TimeHole = state
    end,
})



local RageSection = CombatTab:Section({
    Title = 'Blatant',
    Opened = true,
})

RageSection:Toggle({
    Title = 'Anti Clash',
    Desc = 'Avoids clashing with other players',
    Def = false,
    Callback = function(state)
        setAntiClash(state)
    end,
})

sSection:Button({
    Title = 'Buy Sword Crate',
    Desc = 'Purchases Sword Crate',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local Workspace = game:GetService('Workspace')

        local crate = Workspace:FindFirstChild('Spawn')
            and Workspace.Spawn:FindFirstChild('Crates')
            and Workspace.Spawn.Crates:FindFirstChild('NormalSwordCrate')
        if not crate then
            return
        end

        local remote = ReplicatedStorage:WaitForChild('Remote')
            :WaitForChild('RemoteFunction')
        pcall(function()
            remote:InvokeServer('PromptPurchaseCrate', crate)
        end)
    end,
})

sSection:Button({
    Title = 'Buy Explosion Crate',
    Desc = 'Purchases Explosion Crate.',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local Workspace = game:GetService('Workspace')

        local crate = Workspace:FindFirstChild('Spawn')
            and Workspace.Spawn:FindFirstChild('Crates')
            and Workspace.Spawn.Crates:FindFirstChild('NormalExplosionCrate')
        if not crate then
            return
        end

        local remoteFolder = ReplicatedStorage:WaitForChild('Remote')
        local remoteFunction = remoteFolder:WaitForChild('RemoteFunction')
        local remoteEvent = remoteFolder:WaitForChild('RemoteEvent')

        pcall(function()
            remoteFunction:InvokeServer('PromptPurchaseCrate', crate)
            remoteEvent:FireServer('OpeningCase', true)
        end)
    end,
})

lSection:Button({
    Title = 'Claim Daily Login',
    Desc = 'Claim your daily login.',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local remoteEvent = ReplicatedStorage:WaitForChild('Remote')
            :WaitForChild('RemoteEvent')
        pcall(function()
            remoteEvent:FireServer('ClaimLoginReward')
        end)
    end,
})

lSection:Button({
    Title = 'Spin Ability Wheel',
    Desc = 'Spins the Ability Wheel',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local remoteFunction = ReplicatedStorage:WaitForChild('Remote')
            :WaitForChild('RemoteFunction')
        pcall(function()
            remoteFunction:InvokeServer('GachaSpin', false)
        end)
    end,
})

lSection:Button({
    Title = 'Spin Lobby Wheel',
    Desc = 'Spins lobby Wheel',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local remoteFunction = ReplicatedStorage:WaitForChild('Remote')
            :WaitForChild('RemoteFunction')
        pcall(function()
            remoteFunction:InvokeServer('SpinWheel')
        end)
    end,
})

lSection:Button({
    Title = 'Claim Free Rewards',
    Desc = 'Claims Other Rewards',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local seasonRemote =
            ReplicatedStorage:FindFirstChild('SeasonRewardRemote')
        if not seasonRemote then
            return
        end
        for i = 1, 4 do
            pcall(function()
                seasonRemote:InvokeServer(i)
            end)
            task.wait(0.5)
        end
    end,
})

lSection:Button({
    Title = 'Claim Daily Quest',
    Desc = 'Redeems daily quests',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local net = ReplicatedStorage:WaitForChild('Packages')
            :WaitForChild('_Index')
            :WaitForChild('sleitnick_net@0.1.0')
            :WaitForChild('net')
        pcall(function()
            net['RF/RedeemQuestsType']:InvokeServer('Battlepass', 'Daily')
        end)
    end,
})

lSection:Button({
    Title = 'Claim Weekly Quest',
    Desc = 'Redeems weekly quests',
    Callback = function()
        local ReplicatedStorage = game:GetService('ReplicatedStorage')
        local net = ReplicatedStorage:WaitForChild('Packages')
            :WaitForChild('_Index')
            :WaitForChild('sleitnick_net@0.1.0')
            :WaitForChild('net')
        pcall(function()
            net['RF/RedeemQuestsType']:InvokeServer('Battlepass', 'Weekly')
        end)
    end,
})

APSection:Toggle({
    Title = 'Aggressive AI',
    Desc = 'Auto Play (Aggressive)',
    Def = false,
    Callback = function(state)
        AggressiveAI:enable(state)
        if state then
        else
        end
    end,
})

APSection:Toggle({
    Title = 'Passive AI',
    Desc = 'Auto Play (passive)',
    Def = false,
    Callback = function(state)
        PassiveAI:enable(state)
        if state then
        else
        end
    end,
})

UISection:Dropdown({
    Title = 'Mod Detection',
    Desc = 'Choose Detection Method',
    Values = { 'Notify', 'Kick' },
    Value = { 'Notify' },
    Multi = true,
    AllowNone = true,
    Callback = function(option)
        modActionMode = option
        local list = table.concat(option, ', ')
        Notify('Mod Detection', 'Actions set to: ' .. list, 2)
    end,
})

UISection:Toggle({
    Title = 'Anti Afk',
    Desc = 'Prevents Roblox from kicking you',
    Def = false,
    Callback = function(state)
        if state then
            enableAntiAFK()
            Notify(
                'Anti-AFK',
                'Protection enabled — you will not go idle.',
                2
            )
        else
            disableAntiAFK()
            Notify('Anti-AFK', 'Protection disabled — AFK kicks possible.', 2)
        end
    end,
})

UISection:Toggle({
    Title = 'Anti Fling',
    Desc = 'Avoids Fling',
    Def = false,
    Callback = function(state)
        if state then
            enableAntiFling()
            WindUI:Notify({
                Title = 'Anti Fling',
                Content = 'Enabled',
                Duration = 0,
            })
        else
            disableAntiFling()
            WindUI:Notify({
                Title = 'Anti Fling',
                Content = 'Disabled.',
                Duration = 0,
            })
        end
    end,
})

local kSection = UITab:Section({ Title = 'Performence Options', Opened = true })

kSection:Toggle({
    Title = 'FPS Unlocker',
    Desc = 'Bypass roblox fps cap',
    Def = false,
    Callback = function(state)
        setFPSUnlocker(state)
    end,
})

kSection:Toggle({
    Title = 'No Render',
    Desc = 'Boost FPS [Wont affect graphics]',
    Def = false,
    Callback = function(state)
        setNoRender(state)
        Notify('No Render', state and 'Enabled' or 'Disableb', 2)
    end,
})

RunService.RenderStepped:Connect(function()
    if not visualEnabled then
        return
    end
    local prim = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
    local b = AutoParry.fetchBall()
    if prim and b then
        local vel = b.AssemblyLinearVelocity.Magnitude
        local rad = math.clamp(vel / 2.4 + 10, 15, 200)
        visPart.Size = Vector3.new(rad, rad, rad)
        visPart.CFrame = prim.CFrame
        visPart.Color = Color3.fromRGB(255, 255, 255)
    else
        visPart.Size = Vector3.new(0, 0, 0)
    end
end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(
    function(_, root)
        if root.Parent and root.Parent ~= LocalPlayer.Character then
            if root.Parent.Parent ~= AliveGroup then
                return
            end
        end
        AutoParry.findNearestEntity()
        local b = AutoParry.fetchBall()
        if not b then
            return
        end
        if not parryAnimation then
            return
        end
        parryAnimation:Stop()
    end
)

local modDetectionEnabled = true
local modActionMode = { 'Notify Only' }
local function isAdminLike(plr)
    local name = string.lower(plr.Name)
    return name:find('mod')
        or name:find('admin')
        or name:find('owner')
        or name:find('staff')
end
local function handleModDetected(plr)
    for _, action in ipairs(modActionMode) do
        if action == 'Notify Only' then
            Notify('Mod Detected', plr.Name .. ' may be a moderator!', 4)
        elseif action == 'Kick' then
            Notify('Mod Detected', 'Leaving due to ' .. plr.Name, 2)
            task.wait(2)
            game:Shutdown()
        elseif action == 'Rejoin Server' then
            Notify('Mod Detected', 'Rejoining after detecting ' .. plr.Name, 2)
            task.wait(1)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(
                    PlaceId,
                    game.JobId,
                    LocalPlayer
                )
            end)
        end
    end
end

local function scanForMods()
    if not modDetectionEnabled then
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if isAdminLike(plr) then
            handleModDetected(plr)
        end
    end
end

task.spawn(function()
    while task.wait(5) do
        if modDetectionEnabled then
            pcall(scanForMods)
        end
    end
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if LocalPlayer.Character.Parent ~= AliveGroup then
        return
    end
    if not parryAnimation then
        return
    end
    parryAnimation:Stop()
end)

Workspace.Balls.ChildAdded:Connect(function()
    parryFlag = false
end)

Workspace.Balls.ChildRemoved:Connect(function()
    parryCounter = 0
    parryFlag = false
end)

Workspace.Runtime.ChildAdded:Connect(function(child)
    if child.Name == 'Tornado' then
        getgenv().AerodynamicTime = tick()
        getgenv().Aerodynamic = true
    end
end)

game.OnClose = function()
    if setfpscap and oldFpsCap then
        setfpscap(oldFpsCap)
    end
    if visPart then
        visPart:Destroy()
    end
    if autoParryConnection then
        autoParryConnection:Disconnect()
    end
    if autoSpamConnection then
        autoSpamConnection:Disconnect()
    end
end
