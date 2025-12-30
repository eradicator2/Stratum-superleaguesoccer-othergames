local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Controllers = ReplicatedStorage:WaitForChild("Controllers")
local PlotController = require(Controllers:WaitForChild("PlotController"))
local PlotClient = require(ReplicatedStorage:WaitForChild("Classes"):WaitForChild("PlotClient"))

local GUIsToRemove = {"FloatGUI", "PlotTimerGUI", "DeliveryFloatGUI"}
for _, guiName in ipairs(GUIsToRemove) do
    local existing = LocalPlayer.PlayerGui:FindFirstChild(guiName)
    if existing then
        existing:Destroy()
    end
end

local FloatSpeed = 50
local FloatActive = false
local FloatYLevel = 0
local GoingToBaseActive = false
local TargetBaseCFrame = nil
local PathfindSpeed = 50
local ObstacleDirection = nil

local function UpdateButtonVisual(button, state)
    button.BackgroundColor3 = state and Color3.fromRGB(120, 0, 200) or Color3.fromRGB(190, 20, 50)
end

local function CreateMainFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(40, 10, 40)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = parent
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(190, 20, 50)
    stroke.Thickness = 3
    stroke.Transparency = 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local glow = Instance.new("ImageLabel", frame)
    glow.Name = "OuterGlow"
    glow.Size = UDim2.new(1, 24, 1, 24)
    glow.Position = UDim2.new(0, -12, 0, -12)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = Color3.fromRGB(190, 20, 50)
    glow.ImageTransparency = 0.6
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    
    return frame
end

local function CreateButton(parent, size, position, text)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(190, 20, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = text
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    return button
end

local function CreateTextBox(parent, size, position, placeholder, defaultText)
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(60, 15, 60)
    box.TextColor3 = Color3.fromRGB(255, 90, 90)
    box.PlaceholderText = placeholder
    box.Text = defaultText or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    
    box.Focused:Connect(function() box.BackgroundColor3 = Color3.fromRGB(90, 30, 90) end)
    box.FocusLost:Connect(function() box.BackgroundColor3 = Color3.fromRGB(60, 15, 60) end)
    
    return box
end

local MainGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
MainGui.Name = "FloatGUI"
MainGui.ResetOnSpawn = false

local MainFrame = CreateMainFrame(MainGui, UDim2.new(0, 320, 0, 240), UDim2.new(0, 150, 0, 100))

task.spawn(function()
    local glow = MainFrame:WaitForChild("OuterGlow")
    while glow and glow.Parent do
        for i = 0.6, 0.2, -0.05 do glow.ImageTransparency = i task.wait(0.05) end
        for i = 0.2, 0.6, 0.05 do glow.ImageTransparency = i task.wait(0.05) end
    end
end)

local FloatToggleBtn = CreateButton(MainFrame, UDim2.new(0, 300, 0, 40), UDim2.new(0, 10, 0, 10), "Speed Boost (Float) - [F]")
local SpeedInput = CreateTextBox(MainFrame, UDim2.new(0, 300, 0, 35), UDim2.new(0, 10, 0, 60), "Speed Boost", tostring(FloatSpeed))
local ResetBtn = CreateButton(MainFrame, UDim2.new(0, 300, 0, 40), UDim2.new(0, 10, 0, 110), "Reset Player [R]")

local StealGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
StealGui.Name = "stealFloatGUI"
StealGui.ResetOnSpawn = false
local StealFrame = CreateMainFrame(StealGui, UDim2.new(0, 300, 0, 70), UDim2.new(0, 160, 0, 260))
local GoToBaseBtn = CreateButton(StealFrame, UDim2.new(0, 280, 0, 50), UDim2.new(0, 10, 0, 10), "Go To Your Base (Steal) - [G]")

local function ToggleFloat(root)
    FloatActive = not FloatActive
    if FloatActive then
        FloatYLevel = root.Position.Y
    end
    FloatToggleBtn.Text = FloatActive and "Floating..." or "Speed Boost (Float) - [F]"
    UpdateButtonVisual(FloatToggleBtn, FloatActive)
end

FloatToggleBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        ToggleFloat(LocalPlayer.Character.HumanoidRootPart)
    end
end)

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text)
    if val and val > 0 then FloatSpeed = val else SpeedInput.Text = tostring(FloatSpeed) end
end)

ResetBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

local function RefreshBaseLocation()
    local myPlot = PlotController:GetMyPlot()
    if myPlot then
        local uid = myPlot:GetUID()
        local plotObj = Workspace:FindFirstChild("Plots"):FindFirstChild(uid)
        if plotObj then
            local hitbox = plotObj:FindFirstChild("DeliveryHitbox")
            if hitbox and hitbox:IsA("BasePart") then
                TargetBaseCFrame = hitbox.CFrame + Vector3.new(0, 5, 0)
            else
                TargetBaseCFrame = nil
            end
        end
    end
end

local function ToggleGoToBase()
    GoingToBaseActive = not GoingToBaseActive
    if GoingToBaseActive then
        RefreshBaseLocation()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            FloatYLevel = LocalPlayer.Character.HumanoidRootPart.Position.Y
        end
    end
    GoToBaseBtn.Text = GoingToBaseActive and "Going To Your Base..." or "Go To Your Base (Steal) - [G]"
    UpdateButtonVisual(GoToBaseBtn, GoingToBaseActive)
end

GoToBaseBtn.MouseButton1Click:Connect(ToggleGoToBase)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        if FloatActive then
            local pos = root.Position
            local look = root.CFrame.LookVector
            root.Velocity = Vector3.new(look.X * FloatSpeed, 0, look.Z * FloatSpeed)
            root.CFrame = CFrame.new(pos.X, FloatYLevel, pos.Z) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)
        end
        
        if GoingToBaseActive and TargetBaseCFrame then
            local diff = Vector3.new(TargetBaseCFrame.Position.X - root.Position.X, 0, TargetBaseCFrame.Position.Z - root.Position.Z)
            if diff.Magnitude > 5 then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                
                local hit = Workspace:Raycast(root.Position, diff.Unit * 4, params)
                if hit and hit.Instance and hit.Instance.CanCollide then
                    if ObstacleDirection ~= nil then
                        if Workspace:Raycast(root.Position, ObstacleDirection * 4, params) then
                            ObstacleDirection = nil
                        end
                    else
                        local right = root.CFrame.RightVector
                        if Workspace:Raycast(root.Position, right * 4, params) then
                            local left = -right
                            if Workspace:Raycast(root.Position, left * 4, params) then
                                ObstacleDirection = -diff.Unit
                            else
                                ObstacleDirection = left
                            end
                        else
                            ObstacleDirection = right
                        end
                    end
                    root.Velocity = Vector3.new(ObstacleDirection.X * PathfindSpeed, 0, ObstacleDirection.Z * PathfindSpeed)
                else
                    ObstacleDirection = nil
                    root.Velocity = Vector3.new(diff.Unit.X * PathfindSpeed, 0, diff.Unit.Z * PathfindSpeed)
                end
            else
                GoingToBaseActive = false
                GoToBaseBtn.Text = "Go To Your Base (Steal) - [G]"
                GoToBaseBtn.TextColor3 = Color3.fromRGB(255, 0, 255)
                root.Velocity = Vector3.zero
                ObstacleDirection = nil
            end
            root.CFrame = CFrame.new(root.Position.X, FloatYLevel, root.Position.Z)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.F then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                ToggleFloat(LocalPlayer.Character.HumanoidRootPart)
            end
        elseif input.KeyCode == Enum.KeyCode.G then
            ToggleGoToBase()
        elseif input.KeyCode == Enum.KeyCode.R then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    UpdateButtonVisual(FloatToggleBtn, FloatActive)
    UpdateButtonVisual(GoToBaseBtn, GoingToBaseActive)
    if FloatActive or GoingToBaseActive then
        task.wait()
        FloatYLevel = char.HumanoidRootPart.Position.Y
    end
end)

local ESPFolder = Instance.new("Folder", Workspace)
ESPFolder.Name = "PlayerESPFolder"

local function CreateESP(player)
    if player == LocalPlayer then return end
    local function onCharAdded(char)
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        if head then
            local old = char:FindFirstChild("ESPBillboard")
            if old then old:Destroy() end
            
            local bb = Instance.new("BillboardGui")
            bb.Name = "ESPBillboard"
            bb.Adornee = head
            bb.Size = UDim2.new(0, 100, 0, 40)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent = char
            
            local frame = Instance.new("Frame", bb)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
            frame.BackgroundTransparency = 0.7
            frame.BorderSizePixel = 2
            frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
            frame.AnchorPoint = Vector2.new(0.5, 0.5)
            frame.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 100, 255)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.Text = player.DisplayName
        end
    end
    player.CharacterAdded:Connect(onCharAdded)
    if player.Character then onCharAdded(player.Character) end
end

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end

local PlotESPLabel = nil
local PlotTimerLabel = nil

local function CreateTimeESP(part)
    local bb = Instance.new("BillboardGui")
    bb.Name = "TimeESP"
    bb.Adornee = part
    bb.Size = UDim2.new(0, 500, 0, 100)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    
    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "Loading..."
    label.TextColor3 = Color3.fromRGB(190, 20, 50)
    return label
end

local function CreateTimerUI()
    local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    gui.Name = "PlotTimerGUI"
    gui.ResetOnSpawn = false
    local frame = CreateMainFrame(gui, UDim2.new(0, 370, 0, 50), UDim2.new(1, -450, 0, 60))
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(190, 20, 50)
    label.Text = "Waiting for plot..."
    return label
end

local function InitializePlotTracking(plot)
    local plotModel = Workspace:FindFirstChild("Plots"):FindFirstChild(plot:GetUID())
    if plotModel then
        local purchases = plotModel:FindFirstChild("Purchases")
        local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
        local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
        local gameTimerLabel = mainPart and mainPart:FindFirstChild("BillboardGui") and mainPart.BillboardGui:FindFirstChild("RemainingTime")
        
        if gameTimerLabel and gameTimerLabel:IsA("TextLabel") and mainPart:IsA("BasePart") then
            PlotESPLabel = CreateTimeESP(mainPart)
            PlotTimerLabel = CreateTimerUI()
            
            task.spawn(function()
                while task.wait() and gameTimerLabel and gameTimerLabel.Parent do
                    local rawTime = gameTimerLabel.Text
                    local seconds = tonumber(rawTime:match("(%d+)s"))
                    
                    if seconds and seconds <= 10 then
                        if not LocalPlayer.PlayerGui:FindFirstChild("BigWarningGUI") then
                            local warnGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
                            warnGui.Name = "BigWarningGUI"
                            local warnLabel = Instance.new("TextLabel", warnGui)
                            warnLabel.Size = UDim2.new(1, 0, 1, 0)
                            warnLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            warnLabel.BackgroundTransparency = 0.8
                            warnLabel.Font = Enum.Font.GothamBlack
                            warnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            warnLabel.TextScaled = true
                            warnLabel.Text = "BASE IS UNLOCKING SOON!"
                            warnLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                            warnLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                            delay(7, function() if warnGui.Parent then warnGui:Destroy() end end)
                        end
                    else
                        local existingWarn = LocalPlayer.PlayerGui:FindFirstChild("BigWarningGUI")
                        if existingWarn then existingWarn:Destroy() end
                    end
                    
                    local statusText = "Your Base Timer: " .. rawTime
                    if rawTime:lower() == "0s" or rawTime:lower() == "your base is unlocked (close it!)" then
                        statusText = "Your Base Is Unlocked (CLOSE IT!)"
                    end
                    PlotESPLabel.Text = statusText
                    PlotTimerLabel.Text = statusText
                end
            end)
        end
    end
end

local initialPlot = PlotController:GetMyPlot()
if initialPlot then InitializePlotTracking(initialPlot) end

PlotClient.PlotChanged:Connect(function(newPlot)
    if PlotESPLabel then PlotESPLabel.Parent:Destroy() PlotESPLabel = nil end
    if PlotTimerLabel then PlotTimerLabel.Parent.Parent:Destroy() PlotTimerLabel = nil end
    if newPlot then InitializePlotTracking(newPlot) end
end)
