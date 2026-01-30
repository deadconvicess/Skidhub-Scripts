--// MADE BY @DEADCONVICESS //--


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local CoreStats = LocalPlayer:FindFirstChild("CoreStats")
local ToolCollect = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("ToolCollect")
local ClaimHive = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("ClaimHive")
local PlayerHiveCommand = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("PlayerHiveCommand")
local HiddenStickerEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("HiddenStickerEvent")
local Hives = Workspace:FindFirstChild("Honeycombs")

if not ToolCollect or not ClaimHive or not PlayerHiveCommand or not HiddenStickerEvent then warn("") end
if not Hives then warn("") end
if not CoreStats then warn("") end

local FlowerFields = {}
local AutoFarmEnabled, AutoTool = false, false
local AutoFarmRadius, SelectedField = 25, "Dandelion Field"
local ShowFarmRadius = false
local FarmVisualizer = nil
local VisualizerHeightOffset = 2

local function UpdateFarmVisualizer()
    if not ShowFarmRadius then
        if FarmVisualizer then
            FarmVisualizer:Destroy()
            FarmVisualizer = nil
        end
        return
    end
    local zones = Workspace:FindFirstChild("FlowerZones")
    local field = zones and zones:FindFirstChild(SelectedField)
    if not field or not field:IsA("BasePart") then return end
    local fieldPos = field.Position
    local fieldSize = field.Size
    local topY = fieldPos.Y + (fieldSize.Y / 2) + VisualizerHeightOffset
    local overlaySize = Vector3.new(
        math.clamp(AutoFarmRadius * 2, 10, fieldSize.X),
        0.1,
        math.clamp(AutoFarmRadius * 2, 10, fieldSize.Z)
    )
    if not FarmVisualizer then
        local part = Instance.new("Part")
        part.Name = "FarmRadiusVisualizer"
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 0, 0)
        part.Transparency = 0.65
        part.Size = overlaySize
        part.CFrame = CFrame.new(fieldPos.X, topY, fieldPos.Z)
        part.Parent = Workspace
        FarmVisualizer = part
    else
        FarmVisualizer.Size = overlaySize
        FarmVisualizer.CFrame = CFrame.new(fieldPos.X, topY, fieldPos.Z)
    end
end

RunService.RenderStepped:Connect(function()
    if ShowFarmRadius then
        UpdateFarmVisualizer()
    elseif FarmVisualizer then
        FarmVisualizer:Destroy()
        FarmVisualizer = nil
    end
end)

local PlayerHive = false
local antiAFK = true
local antiAFKConn, farmConnection, digLoop

local ok, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not ok or not Fluent then
    warn("Fluent UI failed to load.")
    return
end

local Window = Fluent:CreateWindow({
    Title = "SkidHub | Bee Swarm",
    SubTitle = "v2.4.9",
    Theme = "Darker",
    Size = UDim2.fromOffset(600, 400),
    TabWidth = 155,
    Acrylic = false,
    MinimizeKey = Enum.KeyCode.G,
})

task.spawn(function()
    local root = Window.Root or Window.MainContainer or Window.Frame
    if root then
        for _, child in ipairs(root:GetDescendants()) do
            if child:IsA("GuiObject") then
                if child.BackgroundTransparency then child.BackgroundTransparency = 0 end
                if child.ImageTransparency then child.ImageTransparency = 0 end
            end
        end
    end
end)

local ESP = {
    Enabled = false,
    Tracers = false,
    HealthBar = false,
    BoxType = "Box",
    ColorMode = "Rainbow",
    MaxDistance = 10000,
    Instances = {},
}

local function RainbowColor()
    local t = tick() * 0.75
    return Color3.fromHSV(t % 1, 1, 1)
end

local function getColor()
    return ESP.ColorMode == "Rainbow" and RainbowColor() or Color3.fromRGB(0, 255, 255)
end

local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function clearPlayerESP(plr)
    local data = ESP.Instances[plr]
    if not data then return end
    for _, obj in pairs(data) do
        if typeof(obj) == "table" then
            for _, sub in pairs(obj) do
                pcall(function() sub.Visible = false sub:Remove() end)
            end
        else
            pcall(function() obj.Visible = false obj:Remove() end)
        end
    end
    ESP.Instances[plr] = nil
end

local function createPlayerESP(plr)
    if plr == LocalPlayer or ESP.Instances[plr] then return end
    ESP.Instances[plr] = {
        Box = createDrawing("Square", { Thickness = 2.5, Filled = false, Visible = false }),
        Tracer = createDrawing("Line", { Thickness = 2, Visible = false }),
        NameTag = createDrawing("Text", { Size = 14, Center = true, Outline = true, Visible = false, Font = 2, Text = plr.DisplayName or plr.Name }),
        Corners = nil,
    }
end

Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(clearPlayerESP)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then createPlayerESP(plr) end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then
        for _, set in pairs(ESP.Instances) do
            for _, obj in pairs(set) do
                if typeof(obj) == "table" then
                    for _, sub in pairs(obj) do sub.Visible = false end
                else obj.Visible = false end
            end
        end
        return
    end
    local color = getColor()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not (char and char:FindFirstChild("HumanoidRootPart")) then clearPlayerESP(plr) continue end
        local hrp = char.HumanoidRootPart
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if not onScreen or dist > ESP.MaxDistance then clearPlayerESP(plr) continue end
        local draw = ESP.Instances[plr]
        if not draw then createPlayerESP(plr) draw = ESP.Instances[plr] end
        local scale = math.clamp(1 / (dist / 40), 0.35, 3)
        local width, height = 55 * scale, 85 * scale
        local x, y = pos.X - width / 2, pos.Y - height / 2
        draw.NameTag.Visible = true
        draw.NameTag.Text = plr.DisplayName or plr.Name
        draw.NameTag.Color = color
        draw.NameTag.Position = Vector2.new(pos.X, y - 18)
        if ESP.BoxType == "Box" then
            draw.Box.Visible = true
            draw.Box.Color = color
            draw.Box.Position = Vector2.new(x, y)
            draw.Box.Size = Vector2.new(width, height)
            if draw.Corners then for _, c in pairs(draw.Corners) do c.Visible = false end end
        elseif ESP.BoxType == "Corner" then
            if not draw.Corners then
                draw.Corners = {}
                for _, n in ipairs({ "TL1", "TL2", "TR1", "TR2", "BL1", "BL2", "BR1", "BR2" }) do
                    draw.Corners[n] = createDrawing("Line", { Thickness = 2.5, Visible = false })
                end
            end
            draw.Box.Visible = false
            local c = draw.Corners
            local cs = 7 * scale
            for _, v in pairs(c) do v.Visible = true v.Color = color end
            c.TL1.From, c.TL1.To = Vector2.new(x, y), Vector2.new(x + cs, y)
            c.TL2.From, c.TL2.To = Vector2.new(x, y), Vector2.new(x, y + cs)
            c.TR1.From, c.TR1.To = Vector2.new(x + width - cs, y), Vector2.new(x + width, y)
            c.TR2.From, c.TR2.To = Vector2.new(x + width, y), Vector2.new(x + width, y + cs)
            c.BL1.From, c.BL1.To = Vector2.new(x, y + height), Vector2.new(x + cs, y + height)
            c.BL2.From, c.BL2.To = Vector2.new(x, y + height), Vector2.new(x, y + height - cs)
            c.BR1.From, c.BR1.To = Vector2.new(x + width - cs, y + height), Vector2.new(x + width, y + height)
            c.BR2.From, c.BR2.To = Vector2.new(x + width, y + height), Vector2.new(x + width, y + height - cs)
        end
        if ESP.Tracers then
            draw.Tracer.Visible = true
            draw.Tracer.Color = color
            draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            draw.Tracer.To = Vector2.new(pos.X, pos.Y)
        else draw.Tracer.Visible = false end
    end
end)

local antiAFKConn, antiAFKActivity
local function enableAntiAFK()
    if antiAFK then return end
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
                    char:TranslateBy(Vector3.new((math.random() - 0.5) * 0.1, 0, (math.random() - 0.5) * 0.1))
                end)
            end
        end
    end)
end

local function disableAntiAFK()
    if not antiAFK then return end
    antiAFK = false
    if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
    if antiAFKActivity then antiAFKActivity:Disconnect() antiAFKActivity = nil end
end

local AdvancedGateBypass = { Enabled = false, Checked = {}, RefreshRate = 5, Active = true }
local KnownGateFolders = { "BeeLocks", "BeeGates", "Locks", "Barriers", "ForceFields" }
local GateKeywords = { "gate", "lock", "barrier", "door", "fence", "forcefield", "shield", "beelock", "honeylock", "pollenlock", "ticket", "quest", "hqdoor", "mountain", "pineapple", "clover", "sunflower", "strawberry", "spider", "bamboo", "pumpkin" }

local function isGate(part)
    if not part:IsA("BasePart") then return false end
    local name = part.Name:lower()
    for _, keyword in ipairs(GateKeywords) do if name:find(keyword) then return true end end
    return false
end

local function bypassPart(part)
    if not part:IsA("BasePart") then return end
    if AdvancedGateBypass.Checked[part] then return end
    AdvancedGateBypass.Checked[part] = true
    pcall(function()
        part.CanCollide = false
        part.Anchored = true
        part.Transparency = part.Transparency
        if part:FindFirstChildOfClass("TouchTransmitter") then part:FindFirstChildOfClass("TouchTransmitter"):Destroy() end
    end)
end

local function scanFolder(folder) for _, obj in ipairs(folder:GetDescendants()) do if isGate(obj) then bypassPart(obj) end end end
local function performScan()
    for _, folderName in ipairs(KnownGateFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then scanFolder(folder) end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do if obj:IsA("BasePart") and isGate(obj) then bypassPart(obj) end end
end

function AdvancedGateBypass:Start()
    if self.Enabled then return end
    self.Enabled = true
    performScan()
    task.spawn(function()
        while self.Enabled do
            task.wait(self.RefreshRate)
            performScan()
        end
    end)
    Workspace.DescendantAdded:Connect(function(desc) if isGate(desc) then bypassPart(desc) end end)
end
task.defer(function() task.wait(1) AdvancedGateBypass:Start() end)

local function LoadFlowerFields()
    FlowerFields = {}
    local FlowerZones = Workspace:FindFirstChild("FlowerZones")
    if FlowerZones then
        for _, zone in pairs(FlowerZones:GetChildren()) do
            if zone:IsA("Part") then table.insert(FlowerFields, zone.Name) end
        end
    end
    if #FlowerFields == 0 then table.insert(FlowerFields, "Sunflower Field") end
end
LoadFlowerFields()

local function GetRandomPoint(radius, cframe)
    local pos = cframe.Position
    return Vector3.new(math.random(pos.X - radius, pos.X + radius), pos.Y + 3, math.random(pos.Z - radius, pos.Z + radius))
end

local function ClaimHiveSpot()
    if not Hives or not ClaimHive or not HRP then return nil end
    local availableHives = {}
    local hiveList = Hives:GetChildren()
    for _, hive in ipairs(hiveList) do
        local owner = hive:FindFirstChild("Owner")
        local spawnPos = hive:FindFirstChild("SpawnPos")
        local hiveID = hive:FindFirstChild("HiveID")
        if owner and spawnPos and hiveID and owner.Value == nil then
            table.insert(availableHives, {
                instance = hive,
                id = hiveID.Value,
                spawn = spawnPos.Value,
                index = tonumber(hive.Name:match("%d+")) or 0,
            })
        end
    end
    if #availableHives == 0 then return nil end
    table.sort(availableHives, function(a, b)
        if a.index == 1 then return false elseif b.index == 1 then return true else return a.index < b.index end
    end)
    local targetHive = availableHives[1]
    if not targetHive then return nil end
    pcall(function()
        HRP.CFrame = targetHive.spawn + Vector3.new(0, 3, 0)
        task.wait(1)
        ClaimHive:FireServer(targetHive.id)
    end)
    return targetHive.instance
end

local function GetHive()
    if not Hives then return nil end
    for _, h in pairs(Hives:GetChildren()) do
        local owner = h:FindFirstChild("Owner")
        if owner and tostring(owner.Value) == tostring(LocalPlayer.Name) then return h end
    end
    local newHive = ClaimHiveSpot()
    if newHive then task.wait(1) return newHive end
    return nil
end

PlayerHive = GetHive()

local function TeleportToHive()
    if PlayerHive then
        local spawnPos = PlayerHive:FindFirstChild("SpawnPos")
        if spawnPos then pcall(function() HRP.CFrame = spawnPos.Value + Vector3.new(0, 3, 0) end) return true end
    end
    return false
end

local function IsAtHive()
    if not PlayerHive then return false end
    local spawnPos = PlayerHive:FindFirstChild("SpawnPos")
    if not spawnPos then return false end
    local distance = (HRP.Position - spawnPos.Value.Position).Magnitude
    return distance < 10
end

function AutoFarm(fieldName, radius)
    if not AutoFarmEnabled or not fieldName then
        if farmConnection then farmConnection:Disconnect() farmConnection = nil end
        return
    end
    Field = Workspace.FlowerZones:FindFirstChild(fieldName)
    if not Field then
        Fluent:Notify({ Title = "Auto Farm Error", Content = "Field not found: " .. tostring(fieldName), Duration = 0 })
        return
    end
    AutoTool = true
    pcall(function() HRP.CFrame = CFrame.new(GetRandomPoint(radius, Field.CFrame)) end)
    if farmConnection then farmConnection:Disconnect() end
    lastMoveTime = 0
    moveCooldown = 3
    isConvertingHoney = false
    farmConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled or not CoreStats then return end
        Capacity = CoreStats:FindFirstChild("Capacity")
        Pollen = CoreStats:FindFirstChild("Pollen")
        if not Capacity or not Pollen then return end
        if Pollen.Value >= Capacity.Value and not isConvertingHoney then
            isConvertingHoney = true
            AutoTool = false
            if not IsAtHive() then
                TeleportToHive()
                task.wait(1)
            end
            pcall(function() PlayerHiveCommand:FireServer("ToggleHoneyMaking") end)
            repeat task.wait(0.5) until not AutoFarmEnabled or not Pollen or Pollen.Value <= 0
            pcall(function() PlayerHiveCommand:FireServer("ToggleHoneyMaking") end)
            if AutoFarmEnabled then
                pcall(function() HRP.CFrame = CFrame.new(GetRandomPoint(radius, Field.CFrame)) end)
                AutoTool = true
            end
            isConvertingHoney = false
        elseif Pollen.Value < Capacity.Value and not isConvertingHoney then
            currentTime = tick()
            if currentTime - lastMoveTime >= moveCooldown then
                point = GetRandomPoint(radius, Field.CFrame)
                Humanoid:MoveTo(point)
                lastMoveTime = currentTime
            end
        end
    end)
end

task.spawn(function()
    while task.wait(0.25) do
        if AutoTool and ToolCollect then pcall(function() ToolCollect:FireServer() end) end
    end
end)

local function CollectAllCollectibles()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local Collectibles = Workspace:WaitForChild("Collectibles")
    local count = 0
    if not Collectibles then
        Fluent:Notify({ Title = "Error", Content = "Collectibles folder not found", Duration = 3 })
        return
    end
    for _, c in ipairs(Collectibles:GetChildren()) do
        if c:IsA("BasePart") and c.Transparency < 1 then
            pcall(function() hrp.CFrame = c.CFrame + Vector3.new(0, 3, 0) end)
            task.wait(0.1)
            count += 1
        end
    end
    if PlayerHive and PlayerHive:FindFirstChild("SpawnPos") then
        task.wait(1)
        pcall(function() hrp.CFrame = PlayerHive.SpawnPos.Value + Vector3.new(0, 3, 0) end)
    end
    Fluent:Notify({ Title = "Collectibles", Content = "Collected " .. count .. " items", Duration = 3 })
end

autoDig = false
digLoop = nil

local function startAutoDig()
    if digLoop then task.cancel(digLoop) end
    digLoop = task.spawn(function()
        while autoDig do
            if ToolCollect then pcall(function() ToolCollect:FireServer() end) end
            task.wait(0.05)
        end
    end)
end

local function stopAutoDig() autoDig = false end

local savedSettings = {}
local function onCharacterAdded(char)
    Character = char
    task.wait(1)
    HRP = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    if savedSettings then
        pcall(function()
            Humanoid.WalkSpeed = savedSettings.WalkSpeed or 16
            Humanoid.JumpPower = savedSettings.JumpPower or 50
        end)
    end
    if AutoFarmEnabled then
        task.wait(1)
        AutoFarm(SelectedField, AutoFarmRadius)
    end
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

FarmTab = Window:AddTab({ Title = "Main", Icon = "sprout" })
TaskTab = Window:AddTab({ Title = "Tasks", Icon = "clipboard-list" })
PlayerTab = Window:AddTab({ Title = "Player", Icon = "user" })
VisualTab = Window:AddTab({ Title = "Visuals", Icon = "eye" })
UITab = Window:AddTab({ Title = "Settings", Icon = "cog" })

fSection = FarmTab:AddSection("Farming Methods")
tSection = FarmTab:AddSection("Farming Settings")
hSection = FarmTab:AddSection("Auto Methods")

fSection:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Automatically collects pollen",
    Default = false,
    Callback = function(s)
        AutoFarmEnabled = s
        if s then
            AutoFarm(SelectedField, AutoFarmRadius)
            Fluent:Notify({ Title = "Auto Farm", Content = "Started farming in " .. SelectedField, Duration = 0 })
        else
            AutoTool = false
            if farmConnection then farmConnection:Disconnect() farmConnection = nil end
            Fluent:Notify({ Title = "Auto Farm", Content = "Stopped farming", Duration = 0 })
        end
    end,
})

fSection:AddToggle("AutoDig", {
    Title = "Auto Dig",
    Description = "Auto digs for pollen",
    Default = false,
    Callback = function(s)
        autoDig = s
        if s then
            startAutoDig()
            Fluent:Notify({ Title = "Auto Dig", Content = "Started auto digging", Duration = 0 })
        else
            stopAutoDig()
            Fluent:Notify({ Title = "Auto Dig", Content = "Stopped auto digging", Duration = 0 })
        end
    end,
})

tSection:AddToggle("ShowFarmRadius", {
    Title = "Show Radius",
    Description = "Shows farm radius",
    Default = false,
    Callback = function(v) ShowFarmRadius = v UpdateFarmVisualizer() end,
})

tSection:AddSlider("FarmRadius", {
    Title = "Farm Radius",
    Description = "Adjust movement radius in field",
    Default = AutoFarmRadius,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        AutoFarmRadius = v
        if AutoFarmEnabled then
            if farmConnection then farmConnection:Disconnect() farmConnection = nil end
            task.wait(0.5)
            AutoFarm(SelectedField, AutoFarmRadius)
        end
        UpdateFarmVisualizer()
    end,
})

tSection:AddDropdown("SelectField", {
    Title = "Select Field",
    Values = FlowerFields,
    Default = SelectedField,
    Multi = false,
    Callback = function(v)
        SelectedField = v
        if AutoFarmEnabled then
            if farmConnection then farmConnection:Disconnect() farmConnection = nil end
            task.wait(0.5)
            AutoFarm(v, AutoFarmRadius)
            Fluent:Notify({ Title = "Field Changed", Content = "Now farming in " .. v, Duration = 3 })
        end
        UpdateFarmVisualizer()
    end,
})

HiveSection = TaskTab:AddSection("Hive Options")
CollectiblesSection = TaskTab:AddSection("Collectibles")

HiveSection:AddButton({
    Title = "Tp Hive",
    Description = "Teleport to hive",
    Callback = function()
        if TeleportToHive() then
            task.wait(1)
            pcall(function() PlayerHiveCommand:FireServer("ToggleHoneyMaking") end)
            Fluent:Notify({ Title = "Hive", Content = "Started honey conversion", Duration = 0 })
        else
            Fluent:Notify({ Title = "Hive Error", Content = "Could not find your hive", Duration = 0 })
        end
    end,
})

HiveSection:AddButton({
    Title = "Purchase Bee",
    Description = "Buys Bee Egg from the shop",
    Callback = function()
        local success, err = pcall(function()
            local args = { "Purchase", { Type = "Basic", Category = "Eggs", Amount = 1 } }
            local event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ItemPackageEvent")
            event:InvokeServer(unpack(args))
        end)
        if success then
            Fluent:Notify({ Title = "Shop", Content = "Successfully purchased Bee Egg", Duration = 3 })
        else
            Fluent:Notify({ Title = "Shop Error", Content = "Failed to purchase " .. tostring(err), Duration = 3 })
        end
    end,
})

LocalPlayer.CharacterAdded:Connect(function(c)
    Character = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Humanoid = c:WaitForChild("Humanoid")
end)

AutoUse = false
SelectedUseType = "Tokens"
UseDelay = 2

local function CollectBubbles()
    local debris = Workspace:FindFirstChild("Debris")
    if not (debris and debris:FindFirstChild("Misc")) then return end
    for _, v in ipairs(debris.Misc:GetChildren()) do
        if v:IsA("BasePart") and string.find(string.lower(v.Name), "bubble") then
            if (v.Position - HRP.Position).Magnitude < 75 then
                pcall(function()
                    firetouchinterest(v, HRP, 0)
                    task.wait()
                    firetouchinterest(v, HRP, 1)
                end)
            end
        end
    end
end

local UseItemEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("UseItem")

local function GetFieldBelow()
    local ray = Ray.new(HRP.Position, Vector3.new(0, -50, 0))
    local part = Workspace:FindPartOnRay(ray, Character)
    if part and string.find(string.lower(part.Name), "field") then return part end
    return nil
end

local function DropSprout()
    if UseItemEvent and GetFieldBelow() then pcall(function() UseItemEvent:FireServer("Magic Bean") end) end
end

local PlayerActivesCommand = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerActivesCommand")
local function UseItem(name) pcall(function() PlayerActivesCommand:FireServer({ Name = name }) end) end

AutoTokens = false
TokenMethod = "Walk"
TokenRadius = 45

local function GetCurrentField()
    local rayOrigin = HRP.Position
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result and result.Instance then return result.Instance end
    return nil
end

local function IsTokenCollectible(token, currentField)
    if not token or not token.Parent then return false end
    if token.Transparency >= 0.9 or not token:IsDescendantOf(workspace.Collectibles) then return false end
    if currentField and token.Position.Y < currentField.Position.Y - 10 then return false end
    return true
end

local function WalkTo(targetPos) if HRP and Humanoid then Humanoid:MoveTo(targetPos) end end

local function CollectNearbyTokens(radius)
    local currentField = GetCurrentField()
    if not currentField then return end
    for _, token in ipairs(workspace.Collectibles:GetChildren()) do
        if token:IsA("BasePart") and IsTokenCollectible(token, currentField) then
            local dist = (HRP.Position - token.Position).Magnitude
            if dist <= radius then
                if TokenMethod == "Teleport" then
                    HRP.CFrame = CFrame.new(token.Position + Vector3.new(0, 3, 0))
                elseif TokenMethod == "Walk" then
                    WalkTo(token.Position)
                    repeat task.wait(0.05) until not token.Parent or (HRP.Position - token.Position).Magnitude < 5
                end
            end
        end
    end
end

AutoUseToggle = hSection:AddToggle("AutoUse", { Title = "Use Items", Default = false, Callback = function(v) AutoUse = v end })
AutoUseDropdown = hSection:AddDropdown("AutoUseSelect", {
    Title = "Auto Use items",
    Description = "Select an item ",
    Values = { "Bubbles", "Sprout", "Gumdrops", "Glue", "Stinger", "MicroConverter", "Oil", "Blue Extract", "Glitter" },
    Default = "Bubbles",
    Callback = function(value) SelectedUseType = value end,
})

task.spawn(function()
    while task.wait(UseDelay) do
        if AutoUse then
            if SelectedUseType == "Tokens" then pcall(function() CollectNearbyTokens(TokenRadius) end)
            elseif SelectedUseType == "Bubbles" then pcall(CollectBubbles)
            elseif SelectedUseType == "Sprout" then pcall(DropSprout)
            elseif SelectedUseType == "Gumdrops" then UseItem("Gumdrops")
            elseif SelectedUseType == "Glue" then UseItem("Glue")
            elseif SelectedUseType == "Stinger" then UseItem("Stinger")
            elseif SelectedUseType == "MicroConverter" then UseItem("Micro-Converter")
            elseif SelectedUseType == "Oil" then UseItem("Oil")
            elseif SelectedUseType == "Blue Extract" then UseItem("Blue Extract")
            elseif SelectedUseType == "Glitter" then UseItem("Glitter") end
        end
    end
end)

hSection:AddToggle("AutoTokens", {
    Title = "Auto Tokens",
    Description = "Automatically collects nearby tokens",
    Default = false,
    Callback = function(v) AutoTokens = v end,
})

hSection:AddDropdown("TokenMethod", {
    Title = "Collection Method",
    Description = "Choose how to collect tokens",
    Values = { "Walk", "Teleport" },
    Default = "Walk",
    Multi = false,
    Callback = function(v) TokenMethod = v end,
})

RunService.Heartbeat:Connect(function() if AutoTokens then pcall(function() CollectNearbyTokens(TokenRadius) end) end end)

CollectiblesSection:AddButton({ Title = "Collect Collectibles", Description = "Collects all collectibles", Callback = CollectAllCollectibles })

local function CollectHiddenStickers()
    local event = HiddenStickerEvent or (ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("HiddenStickerEvent"))
    if not event then warn("") return end
    if _G._StickerCollecting then return end
    _G._StickerCollecting = true
    task.spawn(function()
        for i = 1, 100 do
            local success, err = pcall(function() event:FireServer(i) end)
            if not success then warn((""):format(i, err or "Unknown error")) end
            task.wait(0.04)
        end
        _G._StickerCollecting = false
    end)
end

CollectiblesSection:AddButton({ Title = "Collect Stickers", Description = "Collects all hidden stickers", Callback = CollectHiddenStickers })

local defaultWalkSpeed, defaultJumpPower, defaultGravity, defaultFOV = 16, 50, 196.2, 70
savedSettings = { WalkSpeed = defaultWalkSpeed, JumpPower = defaultJumpPower, Gravity = defaultGravity, FOV = defaultFOV }
pcall(function()
    savedSettings.WalkSpeed = Humanoid.WalkSpeed
    savedSettings.JumpPower = Humanoid.JumpPower
    savedSettings.Gravity = Workspace.Gravity
    savedSettings.FOV = Camera.FieldOfView
end)

spinBotEnabled = false
spinSpeed = 5
spinConnection = nil

local function toggleSpinBot(state)
    spinBotEnabled = state
    if spinBotEnabled then
        if spinConnection then spinConnection:Disconnect() end
        spinConnection = game:GetService("RunService").RenderStepped:Connect(function(delta)
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame *= CFrame.Angles(0, math.rad(spinSpeed * 5 * delta * 60), 0) end
        end)
    else
        if spinConnection then spinConnection:Disconnect() spinConnection = nil end
    end
end

local flyEnabled = false
local flySpeed = 150
local flyConn, BodyGyro, BodyVelocity

local function startFly()
    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
    if flyConn then flyConn:Disconnect() flyConn = nil end
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.CFrame = HRP.CFrame
    BodyGyro.Parent = HRP
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = HRP
    local uis = game:GetService("UserInputService")
    local cam = Camera
    Humanoid.PlatformStand = true
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        local moveDir = Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        BodyGyro.CFrame = cam.CFrame
        BodyVelocity.Velocity = moveDir * flySpeed
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if HRP then HRP.Velocity = Vector3.zero end
    Humanoid.PlatformStand = false
end

local function toggleFly(state)
    flyEnabled = state
    if state then
        startFly()
        Fluent:Notify({ Title = "Fly", Content = "Fly enabled", Duration = 0 })
    else
        stopFly()
        Fluent:Notify({ Title = "Fly", Content = "Fly disabled", Duration = 0 })
    end
end

local fhjdfdjufiSection = PlayerTab:AddSection("Player Options")
local gggSection = PlayerTab:AddSection("Player Settings")

savedSettings = savedSettings or { WalkSpeed = 16, JumpPower = 50, Gravity = Workspace.Gravity, FOV = Camera.FieldOfView }
flySpeed = 100
spinSpeed = 20

local function enableAntiFling()
    if getgenv().antiFlingEnabled then return end
    getgenv().antiFlingEnabled = true
    getgenv().antiFlingConn = RunService.Stepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
            end
        end
    end)
end

local function disableAntiFling()
    getgenv().antiFlingEnabled = false
    if getgenv().antiFlingConn then getgenv().antiFlingConn:Disconnect() getgenv().antiFlingConn = nil end
end

gggSection:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Change your walk speed",
    Default = savedSettings.WalkSpeed,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        savedSettings.WalkSpeed = v
        pcall(function() Humanoid.WalkSpeed = v end)
    end,
})

gggSection:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Change your jump power",
    Default = savedSettings.JumpPower,
    Min = 30,
    Max = 300,
    Rounding = 0,
    Callback = function(v)
        savedSettings.JumpPower = v
        pcall(function() Humanoid.JumpPower = v end)
    end,
})

gggSection:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Change your gravity",
    Default = savedSettings.Gravity,
    Min = 0,
    Max = 200,
    Rounding = 1,
    Callback = function(v)
        savedSettings.Gravity = v
        pcall(function() Workspace.Gravity = v end)
    end,
})

fhjdfdjufiSection:AddToggle("AntiFling", {
    Title = "Anti Fling",
    Description = "Prevents you from being flung",
    Default = false,
    Callback = function(state) if state then enableAntiFling() else disableAntiFling() end end,
})

fhjdfdjufiSection:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Description = "Bypass afk limit",
    Default = false,
    Callback = function(state)
        if state then
            if antiAFK then return end
            antiAFK = true
            antiAFKConn = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            Fluent:Notify({ Title = "Anti AFK", Content = "Anti AFK enabled", Duration = 0 })
        else
            if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
            antiAFK = false
            Fluent:Notify({ Title = "Anti AFK", Content = "Anti AFK disabled", Duration = 0 })
        end
    end,
})

gggSection:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust how fast you fly",
    Default = flySpeed,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v) flySpeed = v end,
})

gggSection:AddSlider("SpinBotSpeed", {
    Title = "Spin Bot Speed",
    Description = "Adjust how fast you spin",
    Default = spinSpeed,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(v) spinSpeed = v end,
})

fhjdfdjufiSection:AddToggle("Fly", { Title = "Fly", Description = "Allows you to fly", Default = false, Callback = function(v) toggleFly(v) end })
fhjdfdjufiSection:AddToggle("SpinBot", { Title = "Spin Bot", Description = "Enable spinbot", Default = false, Callback = function(v) toggleSpinBot(v) end })

gggSection:AddSlider("FOV", {
    Title = "FOV Changer",
    Description = "Change your field of view",
    Default = savedSettings.FOV,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(v)
        savedSettings.FOV = v
        pcall(function() Camera.FieldOfView = v end)
    end,
})

local section = VisualTab:AddSection("Player ESP")

section:AddToggle("EnableESP", { Title = "Enable ESP", Description = "Toggles player ESP", Default = false, Callback = function(v) ESP.Enabled = v end })
section:AddToggle("Tracers", { Title = "Tracers", Description = "Enable tracer lines to players", Default = false, Callback = function(v) ESP.Tracers = v end })
section:AddSlider("Distance", {
    Title = "Max Distance",
    Description = "Change range for ESP",
    Min = 500,
    Max = 10000,
    Default = 2000,
    Rounding = 0,
    Callback = function(v) ESP.MaxDistance = v end,
})

hfghgtgSection = UITab:AddSection("Server Options")
fdfydhfwSection = UITab:AddSection("UI Options")

hfghgtgSection:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local LocalPlayer = game:GetService("Players").LocalPlayer
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        Fluent:Notify({ Title = "SkidHub", Content = "Rejoining server...", Duration = 2 })
    end,
})

hfghgtgSection:AddButton({
    Title = "Copy Server ID",
    Callback = function()
        local jobId = game.JobId
        if setclipboard then
            setclipboard(jobId)
            Fluent:Notify({ Title = "SkidHub", Content = "Copied Server ID", Duration = 2 })
        else
            Fluent:Notify({ Title = "SkidHub", Content = "Your executor does not support this", Duration = 3 })
        end
    end,
})

hfghgtgSection:AddInput("TeleportBox", {
    Title = "Teleport To Player",
    Placeholder = "Enter Username...",
    Numeric = false,
    Finished = true,
    Callback = function(inputText)
        if not inputText or inputText == "" then
            Fluent:Notify({ Title = "SkidHub", Content = "Please enter a player name.", Duration = 1 })
            return
        end
        local target
        for _, plr in ipairs(Players:GetPlayers()) do
            if string.find(string.lower(plr.Name), string.lower(inputText)) or string.find(string.lower(plr.DisplayName), string.lower(inputText)) then
                target = plr
                break
            end
        end
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            pcall(function() HRP.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0)) end)
            Fluent:Notify({ Title = "SkidHub", Content = "Teleported to " .. target.DisplayName, Duration = 2 })
        else
            Fluent:Notify({ Title = "SkidHub", Content = "Player not found or invalid Player", Duration = 1 })
        end
    end,
})

local themePresets = { "Amethyst", "Darker", "Rose", "Dark", "Aqua", "Light" }
local defaultTheme = "Darker"

fdfydhfwSection:AddDropdown("ThemeDropdown", {
    Title = "UI Theme",
    Values = themePresets,
    Default = defaultTheme,
    Multi = false,
    Callback = function(v)
        pcall(function()
            if Window.ChangeTheme then Window:ChangeTheme(v) end
            if Fluent.ChangeTheme then Fluent:ChangeTheme(v) end
            if Fluent.SetTheme then Fluent:SetTheme(v) end
        end)
        Fluent:Notify({ Title = "Theme Applied", Content = v, Duration = 0 })
    end,
})

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
    autoDig = false
    AutoTool = false
end)

Window:SelectTab(FarmTab)
