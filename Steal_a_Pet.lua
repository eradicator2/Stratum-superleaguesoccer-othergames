-- ts file was generated at discord.gg/25ms

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sub2BK/Stratum/refs/heads/Scripts/LunaUI_Loader_Source.lua", true))()
local Window = Luna:CreateWindow({
    Name = "Stratum Hub - Steal a Pet!",
    Subtitle = "Wheres my Meow >:(",
    LogoID = "124012573184930",
    LoadingEnabled = true,
    LoadingTitle = "Loading",
    LoadingSubtitle = "by Sub2BK",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "Stratum"
    },
    KeySystem = false,
    KeySettings = {
        Title = "Luna Example Key",
        Subtitle = "Key System",
        Note = "Best Key System Ever! Also, Please Use A HWID Keysystem like Pelican, Luarmor etc. that provide key strings based on your HWID since putting a simple string is very easy to bypass",
        SaveInRoot = false,
        SaveKey = true,
        Key = {
            "Example Key"
        },
        SecondAction = {
            Enabled = true,
            Type = "Link",
            Parameter = ""
        }
    }
})

Window:CreateHomeTab({
    SupportedExecutors = {
        "Volcano", "Swift", "Wave", "Zenith", "awp", "Potassium", "Codex", "Delta", "Ronix", "Hydrogen", "Macsploit"
    },
    DiscordInvite = "XKxQwBd2zT",
    Icon = 1
})

Luna:Notification({
    Title = "Stratum Notification",
    Icon = "notifications_active",
    ImageSource = "Material",
    Content = "This is a whole work for y'all, I hope y'all love it and accept it. Made By Love <3 (Sub2BK)"
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network", 9000000000)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

loadstring(game:HttpGet("https://raw.githubusercontent.com/Sub2BK/Stratum/refs/heads/Scripts/Remotes_Reverted.lua"))()

local ClientPlot = require(ReplicatedStorage.Library.Client.PlotCmds.ClientPlot)
local ItemHolding = require(ReplicatedStorage.Library.Client.ItemHoldingCmds)
local ClientPetEntity = require(ReplicatedStorage.Library.Client.PetEntityCmds.ClientPetEntity)

-- Anti-Idle
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while true do
        repeat
            task.wait(300)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Jump = true end
        until false
    end
end)

-- Auto Place Stolen Pet
task.spawn(function()
    local plotsInvoke = ReplicatedStorage.Network.Plots_Invoke
    while true do
        local success, plot = pcall(function()
            return ClientPlot.GetByPlayer(LocalPlayer)
        end)
        if success and plot then
            local idSuccess, plotId = pcall(function() return plot:GetId() end)
            if idSuccess and plotId then
                pcall(function()
                    plotsInvoke:InvokeServer(plotId, "PlaceStolenPet")
                end)
            end
        end
        task.wait()
    end
end)

_G.Config = {
    HeadSize = 125,
    HitboxColor = BrickColor.new("Really black"),
    HitboxEnabled = true,
    NameESPEnabled = true,
    PlayerTrackers = {},
    OriginalProperties = {},
    OriginalDurations = {},
    AutoLockDoor = true,
    AutoStealPet = false,
    FastProximity = true,
    AutoClaimCoins = true,
    AutoBuyEnabled = true,
    AutoHatchRetention = true,
    ToolNames = {
        "Bat", "Slap", "Noob Slap", "Steel Slap", "Gold Slap", "Diamond Slap", 
        "Rainbow Slap", "Void Slap", "Galaxy Slap", "Hacker Slap", "Dark Matter Slap", 
        "Godly Slap", "Double Slap", "Ban Hammer"
    },
    SelectedTool = "Bat",
    HitboxRange = 20,
    AutoHitEnabled = false,
    PlayerESPEnabled = false,
    LockDoorTimersEnabled = true,
    LockDoorTimerTags = {},
    NoclipEnabled = false,
    WalkSpeedEnabled = true,
    WalkSpeedValue = 42,
    FlyEnabled = false,
    FlySpeed = 40,
    PetNames = {
        "Dog", "Kangaroo", "Cat", "Monkey", "Dragon", "Griffin", "Bunny", "Rave Crab", 
        "Pop Cat", "Ice Cream Cone", "Googly Shark", "Doge", "Clout Cat", "Red Fluffy", 
        "Grim Reaper", "Phoneix", "Flex Tiger", "Chad Gorilla", "Basketball Cat", 
        "Nightmare Cat", "Mortuus", "Kitsune Fox", "Inferno Cat", "Hacked Cat", 
        "Guard Raccoon", "Dominus Darkwing", "Wicked Angelus", "Storm Axolotl", 
        "Snuggle Beast", "Rave Meebo in a Spaceship", "Ghostly Dragon", 
        "Fragmented Dominus Ball", "Balloon Corgi", "Yin-Yang Grim Reaper", 
        "Wild Galaxy Agony", "Wicked Empyrean Dragon", "Divinus", "Arcane Dominus", 
        "Anime Scorpion", "Toilet Cat", "Hubert", "Hot Dooooog", "Hippomelon", 
        "Corn Cat", "Banana", "Lovemelon", "Sad Cat", "Beans Ballon", "Noob", 
        "Crowned Pegasus", "Robber Goblin", "Centipede", "Huge Pufferfish", 
        "Huge M-6 PROTOTYPE", "Huge Hell Rock", "Huge Black Hole Angelus", 
        "Huge Angry Yeti", "Huge Elemental Phoenix", "Huge Egg", "Titanic Hippomelon"
    },
    SelectedPets = {},
    TraitOptions = {
        "Normal", "Golden", "Rainbow", "Shiny", "Shiny Golden", "Shiny Rainbow"
    },
    SelectedTraits = {},
    ServerHopModes = { "Lowest Players", "Most Players" },
    SelectedHopMode = "Lowest Players"
}

local AutoLockTask, AutoStealTask, FastProxTask, AutoClaimTask, AutoBuyTask, LockTimerTask, NoclipTask, SpeedTask, FlyTask, AutoHatchTask

local function ApplyHitbox(character, player)
    if player == LocalPlayer or not _G.Config.HitboxEnabled then return end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 3)
    if hrp then
        if not _G.Config.OriginalProperties[hrp] then
            _G.Config.OriginalProperties[hrp] = {
                Size = hrp.Size,
                Transparency = hrp.Transparency,
                Color = hrp.BrickColor,
                Material = hrp.Material,
                CanCollide = hrp.CanCollide
            }
        end
        hrp.Size = Vector3.new(_G.Config.HeadSize, _G.Config.HeadSize, _G.Config.HeadSize)
        hrp.Transparency = 1
        hrp.BrickColor = _G.Config.HitboxColor
        hrp.Material = "Neon"
        hrp.CanCollide = false
    end
end

local function RemoveHitbox(character)
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp and _G.Config.OriginalProperties[hrp] then
            local props = _G.Config.OriginalProperties[hrp]
            hrp.Size = props.Size
            hrp.Transparency = props.Transparency
            hrp.BrickColor = props.Color
            hrp.Material = props.Material
            hrp.CanCollide = props.CanCollide
            _G.Config.OriginalProperties[hrp] = nil
        end
    end
end

local function TrackPlayer(player)
    if not _G.Config.PlayerTrackers[player] and player ~= LocalPlayer then
        local tracker = { Connections = {}, LastCharacter = nil }
        local function onCharAdded(char)
            if tracker.LastCharacter ~= char then
                tracker.LastCharacter = char
                task.defer(function()
                    if char and char.Parent then
                        if _G.Config.HitboxEnabled then ApplyHitbox(char, player) else RemoveHitbox(char) end
                    end
                end)
            end
        end
        if player.Character then onCharAdded(player.Character) end
        tracker.Connections.characterAdded = player.CharacterAdded:Connect(onCharAdded)
        tracker.Connections.humanoid = player.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 2)
            if hum then
                hum.Died:Connect(function()
                    task.delay(0.5, function() if player.Character then onCharAdded(player.Character) end end)
                end)
            end
        end)
        tracker.Connections.playerRemoving = player.AncestryChanged:Connect(function(_, parent)
            if not parent then
                RemoveHitbox(player.Character)
                for _, conn in pairs(tracker.Connections) do conn:Disconnect() end
                _G.Config.PlayerTrackers[player] = nil
            end
        end)
        _G.Config.PlayerTrackers[player] = tracker
    end
end

for _, p in ipairs(Players:GetPlayers()) do TrackPlayer(p) end
Players.PlayerAdded:Connect(TrackPlayer)

local function LockDoor()
    local plot = ClientPlot.GetByPlayer(LocalPlayer)
    if plot then
        local id = plot:GetId()
        if id then
            pcall(function() Network.Plots_Invoke:InvokeServer(id, "LockDoor") end)
        end
    end
end

local function FastProximityLogic()
    local standPets = workspace.__THINGS:FindFirstChild("StandPets")
    if standPets then
        for _, pet in ipairs(standPets:GetChildren()) do
            local root = pet:FindFirstChild("RootPart")
            if root then
                local prompt = root:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    local dId = pet:GetDebugId()
                    if _G.Config.FastProximity then
                        if not _G.Config.OriginalDurations[dId] then _G.Config.OriginalDurations[dId] = prompt.HoldDuration end
                        prompt.HoldDuration = 0
                    elseif _G.Config.OriginalDurations[dId] then
                        prompt.HoldDuration = _G.Config.OriginalDurations[dId]
                    end
                end
            end
        end
    end
end

local function ClaimCoins()
    local plot = ClientPlot.GetByPlayer(LocalPlayer)
    if plot then
        local id = plot:GetId()
        local pets = plot:GetAllPets()
        for slot, _ in pairs(pets) do
            local slotNum = tonumber(slot)
            if slotNum then
                pcall(function() Network.Plots_Invoke:InvokeServer(id, "ClaimCoins", slotNum) end)
            end
        end
    end
end

local function BuyPet(id)
    pcall(function() Network.PetEntity_Invoke:InvokeServer(id, "Claim") end)
end

local function EquipTool(name)
    local char = LocalPlayer.Character
    if not char then return end
    local current = char:FindFirstChildOfClass("Tool")
    if current and current.Name == name then return current end
    local tool = LocalPlayer.Backpack:FindFirstChild(name)
    if tool then
        char.Humanoid:EquipTool(tool)
        return tool
    end
end

local function AutoHitLogic()
    if not _G.Config.AutoHitEnabled or _G.Config.SelectedTool == "" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tool = EquipTool(_G.Config.SelectedTool)
    if not tool then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = p.Character.HumanoidRootPart
            if (hrp.Position - targetHrp.Position).Magnitude <= _G.Config.HitboxRange then
                if char:FindFirstChildOfClass("Tool") == tool then
                    tool:Activate()
                    task.wait(0.1)
                    break
                end
            end
        end
    end
end

local ESPGlowFolder = Instance.new("Folder", game.CoreGui)
ESPGlowFolder.Name = "PlayerGlowESP"

local function ApplyGlow(player)
    if player == LocalPlayer or ESPGlowFolder:FindFirstChild(player.Name) then return end
    local char = player.Character or player.CharacterAdded:Wait()
    if char then
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(255, 45, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.25
        highlight.Parent = ESPGlowFolder
    end
end

local ESPNameFolder = Instance.new("Folder", game.CoreGui)
ESPNameFolder.Name = "PlayerNameESP"

local function ApplyNameTag(player)
    if player == LocalPlayer or ESPNameFolder:FindFirstChild(player.Name) then return end
    local char = player.Character or player.CharacterAdded:Wait()
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = player.Name
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 100, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = ESPNameFolder
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Text = player.Name
            label.TextColor3 = Color3.fromRGB(255, 45, 0)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold
            label.Parent = billboard
        end
    end
end

local function UpdateDoorTimers()
    for plot, label in pairs(_G.Config.LockDoorTimerTags) do
        if plot and plot.Parent then
            local button = plot:FindFirstChild("LockButton")
            if button then
                local billboard = button:FindFirstChild("Billboard")
                local frame = billboard and billboard:FindFirstChild("Frame")
                if frame then
                    local title = frame:FindFirstChild("Title")
                    local rate = frame:FindFirstChild("Rate")
                    local titleTxt = title and title.Text or ""
                    local timerTxt = rate and rate.Text or ""
                    local isMine = false
                    pcall(function()
                        local myPlot = ClientPlot.GetByPlayer(LocalPlayer)
                        if myPlot and tostring(myPlot:GetId()) == plot.Name then isMine = true end
                    end)
                    if isMine then
                        label.TextColor3 = Color3.fromRGB(0, 255, 0)
                        label.Text = titleTxt .. (timerTxt ~= "" and " | Timer: " .. timerTxt or "")
                    else
                        local display = (titleTxt == "Lock Door" or titleTxt == "") and "Door Unlocked" or titleTxt
                        label.TextColor3 = (display == "Door Unlocked" and timerTxt == "") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 128, 0)
                        label.Text = display .. (timerTxt ~= "" and " | Timer: " .. timerTxt or "")
                    end
                end
            end
        end
    end
end

local function SetDoorTimerESP(plot)
    if not plot then return end
    local button = plot:FindFirstChild("LockButton")
    if button then
        if button:FindFirstChild("LockDoorTimerESP") then
            button.LockDoorTimerESP.Enabled = _G.Config.LockDoorTimersEnabled
        else
            local gui = Instance.new("BillboardGui")
            gui.Name = "LockDoorTimerESP"
            gui.Adornee = button
            gui.Size = UDim2.new(0, 150, 0, 40)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            gui.AlwaysOnTop = true
            gui.Parent = button
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.Parent = gui
            local isMine = false
            pcall(function()
                local myPlot = ClientPlot.GetByPlayer(LocalPlayer)
                if myPlot and tostring(myPlot:GetId()) == plot.Name then isMine = true end
            end)
            label.TextColor3 = isMine and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 102, 0)
            _G.Config.LockDoorTimerTags[plot] = label
        end
    end
end

local function ToggleDoorTimers(state)
    _G.Config.LockDoorTimersEnabled = state
    if state then
        local plotContainer = workspace.__THINGS:FindFirstChild("Plots")
        if plotContainer then
            for _, plot in pairs(plotContainer:GetChildren()) do SetDoorTimerESP(plot) end
        end
        LockTimerTask = task.spawn(function()
            while _G.Config.LockDoorTimersEnabled do UpdateDoorTimers() task.wait(0.5) end
        end)
    else
        if LockTimerTask then task.cancel(LockTimerTask) LockTimerTask = nil end
        for _, label in pairs(_G.Config.LockDoorTimerTags) do if label.Parent then label.Parent:Destroy() end end
        _G.Config.LockDoorTimerTags = {}
    end
end

workspace.__THINGS.Plots.ChildAdded:Connect(function(child)
    if _G.Config.LockDoorTimersEnabled then task.wait(1) SetDoorTimerESP(child) end
end)

local function SetNoclip(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = not state end
        end
    end
end

local function SetWalkSpeed(val)
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = val
    end
end

local function CreateFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp:FindFirstChild("FlyBodyVelocity") then hrp.FlyBodyVelocity:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBodyVelocity"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    return bv
end

local MainTab = Window:CreateTab({ Name = "Main Tab", Icon = "dashboard", ImageSource = "Material", ShowTitle = true })
local ESPTab = Window:CreateTab({ Name = "ESP Tab", Icon = "remove_red_eye", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc Tab", Icon = "source", ImageSource = "Material", ShowTitle = true })
local SettingsTab = Window:CreateTab({ Name = "Settings Tab", Icon = "settings", ImageSource = "Material", ShowTitle = true })

MainTab:CreateSection("Tool Stuffs :D")
MainTab:CreateDropdown({
    Name = "Select Tool",
    Description = "Sorry if not all the tools here.",
    Options = _G.Config.ToolNames,
    CurrentOption = _G.Config.SelectedTool,
    MultipleOptions = false,
    Callback = function(val) _G.Config.SelectedTool = val end
})

MainTab:CreateSlider({
    Name = "Auto Hit Range",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = _G.Config.HitboxRange,
    Callback = function(val) _G.Config.HitboxRange = val end
})

MainTab:CreateToggle({
    Name = "Auto Hit (via Selected Tool)",
    CurrentValue = _G.Config.AutoHitEnabled,
    Callback = function(state)
        _G.Config.AutoHitEnabled = state
        if state then
            task.spawn(function()
                while _G.Config.AutoHitEnabled do AutoHitLogic() task.wait() end
            end)
        end
    end
})

MainTab:CreateLabel({ Text = "Works With ANY Item/Tool u Want LOL, Even a Banana.", Style = 2 })
MainTab:CreateLabel({ Text = "The (Tool Hitbox - HBE) Working. U MUST SPAM SOMETIMES TO REGISTRY THE HIT!", Style = 3 })

MainTab:CreateSlider({
    Name = "Hitbox Size (HBE)",
    Range = {1, 125},
    Increment = 1,
    CurrentValue = _G.Config.HeadSize,
    Callback = function(val)
        _G.Config.HeadSize = val
        if _G.Config.HitboxEnabled then
            for player, _ in pairs(_G.Config.PlayerTrackers) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Size = Vector3.new(val, val, val)
                end
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "Tool Hitbox (HBE)",
    CurrentValue = _G.Config.HitboxEnabled,
    Callback = function(state)
        _G.Config.HitboxEnabled = state
        for player, _ in pairs(_G.Config.PlayerTrackers) do
            if player.Character then
                if state then ApplyHitbox(player.Character, player) else RemoveHitbox(player.Character) end
            end
        end
    end
})

MainTab:CreateSection("Base Stuffs :D")
MainTab:CreateLabel({ Text = "YOU MUST BE INSIDE THE BASE - The Added a Checkers, so RIP..", Style = 3 })

MainTab:CreateToggle({
    Name = "Auto Lock Door",
    CurrentValue = _G.Config.AutoLockDoor,
    Callback = function(state)
        _G.Config.AutoLockDoor = state
        if state then
            AutoLockTask = task.spawn(function()
                while _G.Config.AutoLockDoor do LockDoor() task.wait() end
            end)
        elseif AutoLockTask then
            task.cancel(AutoLockTask) AutoLockTask = nil
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Claim Pet Coins",
    CurrentValue = _G.Config.AutoClaimCoins,
    Callback = function(state)
        _G.Config.AutoClaimCoins = state
        if state then
            AutoClaimTask = task.spawn(function()
                while _G.Config.AutoClaimCoins do ClaimCoins() task.wait(1) end
            end)
        elseif AutoClaimTask then
            task.cancel(AutoClaimTask) AutoClaimTask = nil
        end
    end
})

MainTab:CreateSection("Steal Stuffs :D")
MainTab:CreateLabel({ Text = "YOU MUST BE OUTSIDE THE BASE - Like in the grass. Also use (Method 1) for best performance", Style = 3 })

MainTab:CreateToggle({
    Name = "[PATCHED] Auto Steal Pet (Method 1)",
    CurrentValue = _G.Config.AutoStealPet,
    Callback = function(state)
        _G.Config.AutoStealPet = state
        if state then
            AutoStealTask = task.spawn(function()
                while _G.Config.AutoStealPet do
                    if ItemHolding.IsHolding(LocalPlayer) then
                        local plot = ClientPlot.GetByPlayer(LocalPlayer)
                        if plot then
                            local id = plot:GetId()
                            local plotObj = workspace.__THINGS.Plots:FindFirstChild(tostring(id))
                            if plotObj and plotObj:FindFirstChild("CollectPart") then
                                local hum = LocalPlayer.Character.Humanoid
                                local hrp = LocalPlayer.Character.HumanoidRootPart
                                local oldSpeed = hum.WalkSpeed
                                hum.WalkSpeed = 0
                                hum.AutoRotate = false
                                local startPos = hrp.CFrame
                                local startTime = tick()
                                while (hrp.Position - startPos.Position).Magnitude < 15 and tick() - startTime < 1 do
                                    hrp.CFrame = hrp.CFrame * CFrame.new(0, -1.5, 0)
                                    task.wait()
                                end
                                hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
                                hum.WalkSpeed = oldSpeed
                                hum.AutoRotate = true
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        elseif AutoStealTask then
            task.cancel(AutoStealTask) AutoStealTask = nil
        end
    end
})

MainTab:CreateButton({
    Name = "[PATCHED] Steal Pet (Method 2)",
    Callback = function()
        if ItemHolding.IsHolding(LocalPlayer) then
            local plot = ClientPlot.GetByPlayer(LocalPlayer)
            if plot then
                local id = plot:GetId()
                local plotObj = workspace.__THINGS.Plots:FindFirstChild(tostring(id))
                if plotObj and plotObj:FindFirstChild("CollectPart") then
                    local hum = LocalPlayer.Character.Humanoid
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local oldSpeed = hum.WalkSpeed
                    hum.WalkSpeed = 0
                    hum.AutoRotate = false
                    local startPos = hrp.CFrame
                    local startTime = tick()
                    while (hrp.Position - startPos.Position).Magnitude < 15 and tick() - startTime < 1 do
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, -1.5, 0)
                        task.wait()
                    end
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
                    hum.WalkSpeed = oldSpeed
                    hum.AutoRotate = true
                end
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "No Button Cooldown | Instant Proximity Prompt (Base Pets)",
    CurrentValue = _G.Config.FastProximity,
    Callback = function(state)
        _G.Config.FastProximity = state
        if state then
            FastProxTask = task.spawn(function()
                while _G.Config.FastProximity do FastProximityLogic() task.wait(1) end
            end)
        else
            if FastProxTask then task.cancel(FastProxTask) FastProxTask = nil end
            FastProximityLogic()
            _G.Config.OriginalDurations = {}
        end
    end
})

MainTab:CreateSection("Pets Stuffs :D")
MainTab:CreateLabel({ Text = "YOU MUST INSIDE THE LINE/PETS PLACE TO BUY!", Style = 3 })

MainTab:CreateDropdown({
    Name = "Select Pets To Auto Buy",
    Options = _G.Config.PetNames,
    MultipleOptions = true,
    CurrentOption = _G.Config.SelectedPets,
    Callback = function(val) _G.Config.SelectedPets = val end
})

MainTab:CreateDropdown({
    Name = "Select Pet Variants",
    Options = _G.Config.TraitOptions,
    MultipleOptions = true,
    CurrentOption = _G.Config.SelectedTraits,
    Callback = function(val) _G.Config.SelectedTraits = val end
})

MainTab:CreateToggle({
    Name = "Auto Buy Selected Pets",
    CurrentValue = _G.Config.AutoBuyEnabled,
    Callback = function(state)
        _G.Config.AutoBuyEnabled = state
        if state then
            AutoBuyTask = task.spawn(function()
                while _G.Config.AutoBuyEnabled do
                    if #_G.Config.SelectedPets > 0 and #_G.Config.SelectedTraits > 0 then
                        local all = ClientPetEntity.All()
                        for _, pet in ipairs(all) do
                            local name = pet:GetDirectory().Name
                            local item = pet:GetItem()
                            local trait = item:IsShiny() and (item:IsRainbow() and "Shiny Rainbow" or (item:IsGolden() and "Shiny Golden" or "Shiny")) or (item:IsRainbow() and "Rainbow" or (item:IsGolden() and "Golden" or "Normal"))
                            if table.find(_G.Config.SelectedPets, name) and table.find(_G.Config.SelectedTraits, trait) then
                                BuyPet(pet:GetId())
                            end
                        end
                    end
                    task.wait()
                end
            end)
        elseif AutoBuyTask then
            task.cancel(AutoBuyTask) AutoBuyTask = nil
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Hatch Free Egg",
    CurrentValue = _G.Config.AutoHatchRetention,
    Callback = function(state)
        _G.Config.AutoHatchRetention = state
        if state then
            AutoHatchTask = task.spawn(function()
                while _G.Config.AutoHatchRetention do
                    pcall(function() ReplicatedStorage.Network.RetentionEgg_Hatch:InvokeServer() end)
                    task.wait(1)
                end
            end)
        elseif AutoHatchTask then
            task.cancel(AutoHatchTask) AutoHatchTask = nil
        end
    end
})

ESPTab:CreateSection("ESP Stuffs :D")
ESPTab:CreateToggle({
    Name = "Player Glow ESP",
    CurrentValue = _G.Config.PlayerESPEnabled,
    Callback = function(state)
        _G.Config.PlayerESPEnabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyGlow(p) end end
            task.spawn(function()
                while _G.Config.PlayerESPEnabled do
                    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and not ESPGlowFolder:FindFirstChild(p.Name) then ApplyGlow(p) end end
                    task.wait(1.5)
                end
            end)
        else
            ESPGlowFolder:ClearAllChildren()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Player Name ESP",
    CurrentValue = _G.Config.NameESPEnabled,
    Callback = function(state)
        _G.Config.NameESPEnabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyNameTag(p) end end
            task.spawn(function()
                while _G.Config.NameESPEnabled do
                    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and not ESPNameFolder:FindFirstChild(p.Name) then ApplyNameTag(p) end end
                    task.wait(1.5)
                end
            end)
        else
            ESPNameFolder:ClearAllChildren()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Show Lock Door Timers",
    CurrentValue = _G.Config.LockDoorTimersEnabled,
    Callback = function(state) ToggleDoorTimers(state) end
})

MiscTab:CreateSection("Player Stuffs :D")
MiscTab:CreateToggle({
    Name = "[PATCHED] Noclip",
    CurrentValue = false,
    Callback = function(state)
        _G.Config.NoclipEnabled = state
        if state then
            NoclipTask = task.spawn(function()
                while _G.Config.NoclipEnabled do SetNoclip(true) task.wait(0.1) end
                SetNoclip(false)
            end)
        else
            if NoclipTask then task.cancel(NoclipTask) NoclipTask = nil end
            SetNoclip(false)
        end
    end
})

MiscTab:CreateInput({
    Name = "WalkSpeed Value [43 IS THE WORKING ONLY]",
    CurrentValue = tostring(_G.Config.WalkSpeedValue),
    Numeric = true,
    Callback = function(val)
        local n = tonumber(val)
        if n then _G.Config.WalkSpeedValue = n if _G.Config.WalkSpeedEnabled then SetWalkSpeed(n) end end
    end
})

MiscTab:CreateToggle({
    Name = "Set The WalkSpeed",
    CurrentValue = false,
    Callback = function(state)
        _G.Config.WalkSpeedEnabled = state
        if state then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local old = hum and hum.WalkSpeed or 16
            SpeedTask = task.spawn(function()
                while _G.Config.WalkSpeedEnabled do SetWalkSpeed(_G.Config.WalkSpeedValue) task.wait(0.1) end
                SetWalkSpeed(old)
            end)
        elseif SpeedTask then
            task.cancel(SpeedTask) SpeedTask = nil
        end
    end
})

MiscTab:CreateToggle({
    Name = "[PATCHED] Set Fly",
    CurrentValue = false,
    Callback = function(state)
        _G.Config.FlyEnabled = state
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum then
            if state then
                hum.PlatformStand = true
                local bv = CreateFly()
                FlyTask = task.spawn(function()
                    local UIS = game:GetService("UserInputService")
                    while _G.Config.FlyEnabled do
                        local dir = Vector3.zero
                        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
                        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
                        bv.Velocity = (dir.Unit == dir.Unit and dir.Unit or Vector3.zero) * _G.Config.FlySpeed
                        task.wait()
                    end
                end)
            else
                if FlyTask then task.cancel(FlyTask) FlyTask = nil end
                local bv = char.HumanoidRootPart:FindFirstChild("FlyBodyVelocity")
                if bv then bv:Destroy() end
                hum.PlatformStand = false
            end
        end
    end
})

MiscTab:CreateSection("Server Stuffs :D")
MiscTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
})

MiscTab:CreateDropdown({
    Name = "Server Hop Mode",
    Options = _G.Config.ServerHopModes,
    CurrentOption = _G.Config.SelectedHopMode,
    Callback = function(val) _G.Config.SelectedHopMode = val end
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local cursor = ""
        while true do
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(game.PlaceId, cursor ~= "" and "&cursor=" .. cursor or "")
            local success, res = pcall(function() return game:HttpGet(url) end)
            if not success then break end
            local data = HttpService:JSONDecode(res)
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing > 0 then table.insert(servers, s) end
            end
            cursor = data.nextPageCursor
            if not cursor then break end
        end
        if #servers > 0 then
            if _G.Config.SelectedHopMode == "Most Players" then
                table.sort(servers, function(a, b) return a.playing > b.playing end)
            else
                table.sort(servers, function(a, b) return a.playing < b.playing end)
            end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer)
        end
    end
})

SettingsTab:CreateLabel({ Text = "Setting Configuration Is BROKEN Sometimes!", Style = 3 })
SettingsTab:BuildConfigSection()
SettingsTab:BuildThemeSection()
SettingsTab:CreateBind({
    Name = "Stratum UI/Interface Keybind",
    CurrentBind = "K",
    Callback = function() end,
    OnChangedCallback = function(val) Window.Bind = val end
})

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    if _G.Config.WalkSpeedEnabled then task.spawn(function() while _G.Config.WalkSpeedEnabled do SetWalkSpeed(_G.Config.WalkSpeedValue) task.wait(0.1) end end) end
end)

Luna:LoadAutoloadConfig()
