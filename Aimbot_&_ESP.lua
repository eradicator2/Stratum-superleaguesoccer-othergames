--// C-Function Library Initialization
local success, result = pcall(function()
    _G.C = C(C)
end)
if not success then
    getgenv().C = { pairs = pairs, ipairs = ipairs }
    warn("C-Function Library failed to initialize. Using standard Lua functions.")
end




--// Services & Caching
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local frameCounter = 0
local drawings = {}
local trackedCharacters = {} -- Tracks character models directly
local currentTarget = nil
local isAiming = false
local lastScanTime = 0 -- For periodic workspace scans


--// Helper Functions
local function clearDrawings()
    for _, drawing in C.pairs(drawings) do
        if typeof(drawing) == "Drawing" and drawing.Visible then
            drawing.Visible = false
            drawing:Remove()
        end
    end
    table.clear(drawings)
end

local function createOrUpdateDrawing(id, type, properties)
    if not drawings[id] then
        drawings[id] = Drawing.new(type)
    end
    local drawing = drawings[id]
    for prop, value in C.pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

local function worldToScreen(worldPoint)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPoint)
    if onScreen then
        return Vector2.new(screenPos.X, screenPos.Y)
    end
    return nil
end

local function isCharacterVisible(character)
    local head = character and character:FindFirstChild("Head")
    if not head then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

    local origin = Camera.CFrame.Position
    local direction = (head.Position - origin).Unit * 2000

    local rayResult = Workspace:Raycast(origin, direction, raycastParams)

    return not rayResult or (rayResult.Instance and rayResult.Instance:IsDescendantOf(character))
end


--// ESP Drawing Modules
local function drawBox(character, screenPos, size, color)
    local uniqueId = "Box_" .. character.Name
    if ESP_Aimbot.BoxStyle == "Corner" then
        local cornerSize = math.min(size.X, size.Y) / 4
        createOrUpdateDrawing(uniqueId .. "_TL1", "Line", { From = screenPos, To = screenPos + Vector2.new(cornerSize, 0), Color = color, Thickness = 2, Visible = true })
        createOrUpdateDrawing(uniqueId .. "_TL2", "Line", { From = screenPos, To = screenPos + Vector2.new(0, cornerSize), Color = color, Thickness = 2, Visible = true })
        local tr = screenPos + Vector2.new(size.X, 0)
        createOrUpdateDrawing(uniqueId .. "_TR1", "Line", { From = tr, To = tr - Vector2.new(cornerSize, 0), Color = color, Thickness = 2, Visible = true })
        createOrUpdateDrawing(uniqueId .. "_TR2", "Line", { From = tr, To = tr + Vector2.new(0, cornerSize), Color = color, Thickness = 2, Visible = true })
        local bl = screenPos + Vector2.new(0, size.Y)
        createOrUpdateDrawing(uniqueId .. "_BL1", "Line", { From = bl, To = bl + Vector2.new(cornerSize, 0), Color = color, Thickness = 2, Visible = true })
        createOrUpdateDrawing(uniqueId .. "_BL2", "Line", { From = bl, To = bl - Vector2.new(0, cornerSize), Color = color, Thickness = 2, Visible = true })
        local br = screenPos + Vector2.new(size.X, size.Y)
        createOrUpdateDrawing(uniqueId .. "_BR1", "Line", { From = br, To = br - Vector2.new(cornerSize, 0), Color = color, Thickness = 2, Visible = true })
        createOrUpdateDrawing(uniqueId .. "_BR2", "Line", { From = br, To = br - Vector2.new(0, cornerSize), Color = color, Thickness = 2, Visible = true })
    else
        createOrUpdateDrawing(uniqueId, "Square", { Position = screenPos, Size = size, Color = color, Thickness = 1, Filled = false, Visible = true })
    end
end

local function drawInfoText(player, character, screenPos, distance, color)
    local text = ""
    if ESP_Aimbot.Names then text = player and player.DisplayName or character.Name end
    if ESP_Aimbot.Distance then text = text .. " [" .. math.floor(distance) .. "m]" end
    if text ~= "" then
        createOrUpdateDrawing("Info_" .. character.Name, "Text", { Text = text, Position = screenPos - Vector2.new(0, 12), Size = 12, Color = color, Center = true, Outline = true, Visible = true })
    end
end

local function drawHealthBar(character, screenPos, size)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    local barPos = screenPos - Vector2.new(6, 0)
    local healthColor = Color3.fromHSV(0.33 * healthPercent, 1, 1)
    createOrUpdateDrawing("HealthBG_" .. character.Name, "Line", { From = barPos, To = barPos + Vector2.new(0, size.Y), Color = Color3.new(0, 0, 0), Thickness = 6, Visible = true })
    local healthBarHeight = size.Y * healthPercent
    createOrUpdateDrawing("HealthFG_" .. character.Name, "Line", { From = barPos + Vector2.new(0, size.Y - healthBarHeight), To = barPos + Vector2.new(0, size.Y), Color = healthColor, Thickness = 4, Visible = true })
end

local function drawTracer(character, rootPartPos, color)
    local startPos = (ESP_Aimbot.TracerStartPoint == "Mouse") and Vector2.new(Mouse.X, Mouse.Y) or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local screenPos = worldToScreen(rootPartPos)
    if screenPos then
        createOrUpdateDrawing("Tracer_" .. character.Name, "Line", { From = startPos, To = screenPos, Color = color, Thickness = 1, Visible = true })
    end
end

local function drawHeadDot(character, color)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local screenPos = worldToScreen(head.Position)
    if screenPos then
        createOrUpdateDrawing("HeadDot_" .. character.Name, "Circle", { Position = screenPos, Radius = 4, Color = color, Filled = true, Visible = true })
    end
end

local function drawSkeleton(character, color)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then return end
    local bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}}
    for i, pair in C.ipairs(bones) do
        local part1, part2 = character:FindFirstChild(pair[1]), character:FindFirstChild(pair[2])
        if part1 and part2 then
            local pos1, pos2 = worldToScreen(part1.Position), worldToScreen(part2.Position)
            if pos1 and pos2 then
                createOrUpdateDrawing("Skeleton_" .. character.Name .. "_" .. i, "Line", { From = pos1, To = pos2, Color = color, Thickness = 1, Visible = true })
            end
        end
    end
end

local function drawTool(character, screenPos, size, color)
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        createOrUpdateDrawing("Tool_" .. character.Name, "Text", { Text = tool.Name, Position = screenPos + Vector2.new(size.X / 2, size.Y + 4), Size = 12, Color = color, Center = true, Outline = true, Visible = true })
    end
end

local function drawOffViewArrow(character, color)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if onScreen then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local angle = math.atan2(screenPos.Y - center.Y, screenPos.X - center.X)
    local x, y = center.X + (Camera.ViewportSize.X / 2.2) * math.cos(angle), center.Y + (Camera.ViewportSize.Y / 2.2) * math.sin(angle)
    createOrUpdateDrawing("Arrow_" .. character.Name, "Triangle", { PointA = Vector2.new(x + 10 * math.cos(angle), y + 10 * math.sin(angle)), PointB = Vector2.new(x - 5 * math.cos(angle + 1.57), y - 5 * math.sin(angle + 1.57)), PointC = Vector2.new(x - 5 * math.cos(angle - 1.57), y - 5 * math.sin(angle - 1.57)), Color = color, Filled = true, Visible = true })
end

local function drawFOVCircle()
    if ESP_Aimbot.FOVCircle then
        createOrUpdateDrawing("FOVCircle", "Circle", { Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2), Radius = ESP_Aimbot.FOVCircleRadius, Color = ESP_Aimbot.Colors.FOVCircle, Thickness = 1, Filled = false, Visible = true, NumSides = 64 })
    elseif drawings["FOVCircle"] then drawings["FOVCircle"].Visible = false end
end


--// Player Tracking & Event Handling
local function setupCharacter(character)
    if not character or character == LocalPlayer.Character or trackedCharacters[character] or table.find(ESP_Aimbot.BlacklistedNames, character.Name) then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not character:FindFirstChild("HumanoidRootPart") then return end

    local player = Players:GetPlayerFromCharacter(character)
    
    local data = {
        Player = player,
        IsAlive = humanoid.Health > 0,
        DiedConnection = humanoid.Died:Connect(function()
            if trackedCharacters[character] then
                trackedCharacters[character].IsAlive = false
            end
        end)
    }
    trackedCharacters[character] = data
    
    character.Destroying:Connect(function()
        if data.DiedConnection then data.DiedConnection:Disconnect() end
        trackedCharacters[character] = nil
    end)
end

local function scanForCharacters()
    for _, player in C.pairs(Players:GetPlayers()) do
        if player.Character and player ~= LocalPlayer then
            setupCharacter(player.Character)
        end
    end
    for _, model in C.pairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model ~= LocalPlayer.Character then
            setupCharacter(model)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupCharacter)
end)

scanForCharacters() -- Initial scan


--// Aimbot Logic
local function findClosestTarget()
    local closestTarget = nil
    local shortestDistance = ESP_Aimbot.FOVCircleRadius
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local guiInset = GuiService:GetGuiInset()

    for character, data in C.pairs(trackedCharacters) do
        if data and data.IsAlive and isCharacterVisible(character) and character ~= LocalPlayer.Character then
            local aimPart = character:FindFirstChild(ESP_Aimbot.AimPart)
            if aimPart then
                local screenPos = worldToScreen(aimPart.Position)
                if screenPos then
                    local adjustedScreenPos = screenPos - guiInset
                    local distance = (mousePos - adjustedScreenPos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = aimPart
                    end
                end
            end
        end
    end
    return closestTarget
end

UserInputService.InputBegan:Connect(function(input) if input.UserInputType == ESP_Aimbot.AimKey then isAiming = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == ESP_Aimbot.AimKey then isAiming = false; currentTarget = nil end end)

--// Main Loop
RunService.RenderStepped:Connect(function()
    if not ESP_Aimbot.Enabled then
        clearDrawings()
        return
    end

    frameCounter = frameCounter + 1
    if frameCounter <= ESP_Aimbot.UpdateRate then return end
    frameCounter = 0

    if os.clock() - lastScanTime > 5 then
        scanForCharacters()
        lastScanTime = os.clock()
    end

    for id, drawing in C.pairs(drawings) do
        if id ~= "FOVCircle" then drawing.Visible = false end
    end

    drawFOVCircle()
    local localPlayerTeam = LocalPlayer.Team

    for character, data in C.pairs(trackedCharacters) do
        if not (data and data.IsAlive and character ~= LocalPlayer.Character) then continue end
        
        local success, err = pcall(function()
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            if distance > ESP_Aimbot.MaxDistance then return end
            
            local player = data.Player
            local isVisible = isCharacterVisible(character)
            local color = isVisible and ESP_Aimbot.Colors.Visible or ESP_Aimbot.Colors.Occluded
            
            if player then
                if player:IsFriendsWith(LocalPlayer.UserId) then color = ESP_Aimbot.Colors.Friend
                elseif player.Team == localPlayerTeam and player.Team ~= nil then color = ESP_Aimbot.Colors.Team end
            end

            local cframe, size = character:GetBoundingBox()
            local screenPosVec, onScreen = Camera:WorldToViewportPoint(cframe.Position - Vector3.new(0, size.Y / 2, 0))
            
            if onScreen then
                local screenPosTop, _ = Camera:WorldToViewportPoint(cframe.Position + Vector3.new(0, size.Y / 2, 0))
                local screenHeight = (screenPosVec.Y - screenPosTop.Y)
                local screenWidth = screenHeight / 2
                local screenPosition = Vector2.new(screenPosVec.X - screenWidth / 2, screenPosTop.Y)
                local screenSize = Vector2.new(screenWidth, screenHeight)

                if ESP_Aimbot.Boxes then drawBox(character, screenPosition, screenSize, color) end
                if ESP_Aimbot.Names or ESP_Aimbot.Distance then drawInfoText(player, character, screenPosition, distance, color) end
                if ESP_Aimbot.HealthBars then drawHealthBar(character, screenPosition, screenSize) end
                if ESP_Aimbot.Tool then drawTool(character, screenPosition, screenSize, color) end
                if ESP_Aimbot.Skeleton then drawSkeleton(character, color) end
            else
                if ESP_Aimbot.OffViewArrows then drawOffViewArrow(character, color) end
            end

            if ESP_Aimbot.Tracers then drawTracer(character, rootPart.Position, color) end
            if ESP_Aimbot.HeadDots then drawHeadDot(character, color) end
            
            if ESP_Aimbot.ShowAimbotTarget and currentTarget and currentTarget.Parent == character then
                local aimPartPos = worldToScreen(currentTarget.Position)
                if aimPartPos then
                    createOrUpdateDrawing("AimbotTargetCircle", "Circle", { Position = aimPartPos, Radius = 5, Color = ESP_Aimbot.Colors.AimbotTarget, Thickness = 2, Filled = false, Visible = true })
                end
            end
        end)
        if not success then warn("ESP Error for character " .. character.Name .. ": " .. tostring(err)) end
    end
end)

--// STABLE AIMBOT THREAD (CRASH & LAG FIX)
task.spawn(function()
    while task.wait() do
        if ESP_Aimbot.AimbotEnabled and isAiming then
            currentTarget = findClosestTarget()
            
            if currentTarget then
                local success, err = pcall(function()
                    local targetPos = worldToScreen(currentTarget.Position)
                    if targetPos then
                        local guiInset = GuiService:GetGuiInset()
                        local adjustedTargetPos = targetPos - guiInset
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local moveVector

                        if ESP_Aimbot.AimbotSmoothness <= 1 then
                            moveVector = adjustedTargetPos - mousePos
                        else
                            moveVector = (adjustedTargetPos - mousePos) / ESP_Aimbot.AimbotSmoothness
                        end
                        
                        if secure_call then
                            secure_call(mousemoverel, moveVector.X, moveVector.Y)
                        else
                            mousemoverel(moveVector.X, moveVector.Y)
                        end
                    end
                end)
                
                if not success then
                    warn("Aimbot tracking error:", err)
                    currentTarget = nil
                end
            end
        end
    end
end)
