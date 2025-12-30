local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/eradicator2/Stratum-superleaguesoccer-othergames/refs/heads/main/LunaUI_Loader_Source.lua", true))()
local Window = Luna:CreateWindow({
    Name = "Stratum Hub - Tap Infinity!",
    Subtitle = "Wheres my Meow >:(",
    LogoID = "124012573184930",
    LoadingEnabled = true,
    LoadingTitle = "Loading",
    LoadingSubtitle = "by Sub2BK",
    ConfigSettings = {
        RootFolder = "Stratum",
        ConfigFolder = "Tap Infinity"
    },
    KeySystem = false
})

Luna:Notification({
    Title = "Stratum Notification",
    Icon = "notifications_active",
    ImageSource = "Material",
    Content = "This Is a Whole Work For Y'all, I Hope Y'all Love it and Accept it. Made By Love <3 (Sub2BK)"
})

Window:CreateHomeTab({
    SupportedExecutors = {
        "Swift", "Volcano", "Wave", "Zenith", "Codex", "Delta", "Ronix", "Hydrogen", "MacSploit", "Velocity"
    },
    DiscordInvite = "XKxQwBd2zT",
    Icon = 2
})

local MainTab = Window:CreateTab({ Name = "Main Tab", Icon = "house" })
local EggTab = Window:CreateTab({ Name = "Egg Tab", Icon = "pets" })
local UpgradesTab = Window:CreateTab({ Name = "Upgrades Tab", Icon = "shopping_cart" })
local MiscTab = Window:CreateTab({ Name = "Misc Tab", Icon = "source" })
local SettingsTab = Window:CreateTab({ Name = "Settings Tab", Icon = "settings" })

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerData = LocalPlayer:WaitForChild("Data")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RebirthData = require(ReplicatedStorage.Data.Rebirths)
local TapRemote = ReplicatedStorage.Remotes.TapEvent
local RebirthRemote = ReplicatedStorage.Remotes.RebirthEvent
local EggRemote = ReplicatedStorage.Remotes.EggFunction
local PetRemote = ReplicatedStorage.Remotes.PetEvent
local UpgradesRemote = ReplicatedStorage.Remotes.UpgradesEvent

-- Configuration & States
local NoclipConnection = nil
local AutoClickConnection = nil
local JumpConnection = nil
local AntiAfkConnection = nil

local UpgradeMachines = {
    { Name = "Upgrade Machine 1", Value = "1" },
    { Name = "Upgrade Machine 2", Value = "2" },
    { Name = "Upgrade Machine 3", Value = "3" },
    { Name = "Upgrade Machine 4", Value = "4" },
    { Name = "Upgrade Machine 5", Value = "5" }
}

local RebirthDelay = 1
local UpgradeDelay = 1
local AutoTapEnabled = false
local AutoRebirthEnabled = false
local AutoHatchEnabled = false
local SelectedEgg = "Basic Egg"
local HatchAmount = 1
local AutoSellEnabled = false
local AutoBuyUpgradesEnabled = false

local SelectedSellPets = {}
local SelectedSellTypes = {}
local SelectedSellVariants = {}
local SelectedUpgradeTypes = {}
local SelectedUpgradeMachine = "1"

local AutoRejoinEnabled = true
local AntiAfkEnabled = true
local WalkSpeedValue = 40
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local AutoClickerEnabled = false
local ClickInterval = 0.01

-- Functions
local function GetBestRebirth()
    local currentTaps = PlayerData.Taps.Value
    local currentRebirths = PlayerData.Rebirths.Value
    for i = #RebirthData, 1, -1 do
        local data = RebirthData[i]
        if i ~= #RebirthData then
            if (currentRebirths + 1) * 75 * data.reward <= currentTaps then
                return i
            end
        elseif data.reward == -1 then
            if currentTaps * 100 <= currentTaps then
                return i
            end
        end
    end
    return nil
end

local function HandleAutoClicker()
    if AutoClickerEnabled then
        task.wait(1)
        if AutoClickConnection then AutoClickConnection:Disconnect() end
        AutoClickConnection = RunService.Heartbeat:Connect(function()
            mouse1click()
            task.wait(ClickInterval)
        end)
    elseif AutoClickConnection then
        AutoClickConnection:Disconnect()
        AutoClickConnection = nil
    end
end

local function FormatPetList()
    local list = {}
    for _, petName in ipairs(SelectedSellPets) do
        for _, variant in ipairs(SelectedSellVariants) do
            for _, typeName in ipairs(SelectedSellTypes) do
                if variant == "Normal" and typeName == "Normal" then
                    table.insert(list, petName)
                else
                    local parts = {}
                    if variant ~= "Normal" then table.insert(parts, variant) end
                    if typeName == "Golden" then table.insert(parts, "Golden") end
                    table.insert(parts, petName)
                    table.insert(list, table.concat(parts, " "))
                end
            end
        end
    end
    return list
end

local function SetNoclip(state)
    NoclipEnabled = state
    if NoclipEnabled then
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

local function SetInfiniteJump(state)
    InfiniteJumpEnabled = state
    if InfiniteJumpEnabled then
        if JumpConnection then JumpConnection:Disconnect() end
        JumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    elseif JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
end

local function SetupAutoRejoin()
    GuiService.ErrorMessageChanged:Connect(function(msg)
        if AutoRejoinEnabled and (msg and msg ~= "") then
            task.wait(20)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end)
end

-- Main Tab
MainTab:CreateSection("Main Stuff")
local AutoTapThread = nil
MainTab:CreateToggle({
    Name = "Auto Tap",
    Description = "Auto Taps Using Honeycomb World (No Needed To Unlock It :D)",
    CurrentValue = AutoTapEnabled,
    Callback = function(state)
        AutoTapEnabled = state
        if AutoTapThread then task.cancel(AutoTapThread) end
        if state then
            AutoTapThread = task.spawn(function()
                while AutoTapEnabled do
                    TapRemote:FireServer(LocalPlayer, "Toxic")
                    task.wait()
                end
            end)
        end
    end
})

local AutoRebirthThread = nil
MainTab:CreateToggle({
    Name = "Auto Rebirth",
    Description = "Auto Rebirth The Best Option :D",
    CurrentValue = AutoRebirthEnabled,
    Callback = function(state)
        AutoRebirthEnabled = state
        if AutoRebirthThread then task.cancel(AutoRebirthThread) end
        if state then
            AutoRebirthThread = task.spawn(function()
                while AutoRebirthEnabled do
                    local best = GetBestRebirth()
                    if best then RebirthRemote:FireServer(best) end
                    task.wait(RebirthDelay)
                end
            end)
        end
    end
})

MainTab:CreateSlider({
    Name = "Rebirth Delay",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = RebirthDelay,
    Callback = function(val) RebirthDelay = val end
})

MainTab:CreateLabel({
    Text = "Yes, You Dont Need To Have ANY Rebirth Upgrade To Use That :D (Hella OP)",
    Style = 2
})

MainTab:CreateDivider()
MainTab:CreateSection("Breakables Stuff")

MainTab:CreateToggle({
    Name = "Auto Clicker",
    CurrentValue = AutoClickerEnabled,
    Callback = function(state)
        AutoClickerEnabled = state
        HandleAutoClicker()
    end
})

MainTab:CreateSlider({
    Name = "Click Interval",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = ClickInterval,
    Callback = function(val) ClickInterval = val end
})

MainTab:CreateLabel({
    Text = "Enable (Auto Break) From The Game Itself & Enable (Auto Clicker)",
    Style = 3
})

-- Egg Tab
EggTab:CreateSection("Eggs Stuff")
EggTab:CreateDropdown({
    Name = "Select Egg",
    Options = {
        "Basic Egg", "Golden Basic Egg", "Jungle Egg", "Golden Jungle Egg",
        "Yeti Egg", "Golden Yeti Egg", "Farm Egg", "Golden Farm Egg",
        "Beach Egg", "Golden Beach Egg", "Desert Egg", "Golden Desert Egg",
        "Lava Egg", "Golden Lava Egg", "Future Egg", "Golden Future Egg",
        "Bee Egg", "Golden Bee Egg", "Toxic Egg", "Golden Toxic Egg"
    },
    CurrentOption = SelectedEgg,
    Callback = function(val) SelectedEgg = val end
})

EggTab:CreateDropdown({
    Name = "Hatch Amount",
    Options = {"1", "3", "8"},
    CurrentOption = tostring(HatchAmount),
    Callback = function(val) HatchAmount = tonumber(val) end
})

local AutoHatchThread = nil
EggTab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = AutoHatchEnabled,
    Callback = function(state)
        AutoHatchEnabled = state
        if AutoHatchThread then task.cancel(AutoHatchThread) end
        if state then
            AutoHatchThread = task.spawn(function()
                while AutoHatchEnabled do
                    EggRemote:InvokeServer("Buy", SelectedEgg, HatchAmount, {})
                    task.wait()
                end
            end)
        end
    end
})

local EggGuiBackup = nil
local EggGuiConnection = nil
EggTab:CreateToggle({
    Name = "Disable Egg Animations",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local eggUI = PlayerGui:FindFirstChild("Egg")
            if eggUI then
                EggGuiBackup = eggUI:Clone()
                eggUI:Destroy()
            end
            EggGuiConnection = PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "Egg" then
                    EggGuiBackup = child:Clone()
                    child:Destroy()
                end
            end)
        elseif EggGuiConnection then
            EggGuiConnection:Disconnect()
            EggGuiConnection = nil
            if EggGuiBackup then
                EggGuiBackup:Clone().Parent = PlayerGui
                EggGuiBackup = nil
            end
        end
    end
})

EggTab:CreateLabel({
    Text = "Yes, You Dont Need To Be Near From The Egg Atall :D",
    Style = 2
})

EggTab:CreateDivider()
EggTab:CreateSection("Pets Stuff")

EggTab:CreateDropdown({
    Name = "Select Pets",
    Options = {"Dog","Cat","Flower Dog","Frost Wolf","Inferno Bunny","Thunder Dragon","Elemental Split","Charged Shard","Bunny","Bee","Green Dragon","Rich Dog","Boom-Box Pyramid","Koala","Elephant","Parrot","Panda","Tiger","Jungle Overseer","Eternal Clover","Polar Bear","Reindeer","Penguin","Snowman","Yeti","Frozen Gumdrop","Frozen Heart","Farmer Bunny","Pig","Sheep","Cow","Chicken","Radiant Leaf","Lemon Head","Green Fish","Flamingo","Shark","Pirate Parrot","Kraken","Bubble Guardian","Aqua Shard","Camel","Cactus","Taco Cat","Lion","Dancing Elephant","Desert T.V.","Desert Guardian","Magma Dog","Magma Cat","Hell Cow","Lava Dragon","Hell Cerberus","Demonic Bunny","Inferno Serpent","Robot Dog","Alien","Cyborg","Steampunk Cat","Cyborg Alien","Steampunk Overlord","Steampunk Serpent","Baby Bee","Honey Bee","Inverted Bee","Worker Bee","Robo Bee","Angelic Bee","King Bee","Tap Doggy","Tap Kitty","Tap Bunny","Tap Dragon","Cursed TV","Release Rocket","Release Dragon","Tsunami Phoenix","Rocket Mouse","Firework Cat","Sparkler Octopus","Liberty Elephant","Freedom Snake","4th of July Demon","Freedom Sentinel","Bell Dog","Liberty Bunny","Sheriff Racoon","Bald Eagle","Freedom Dragon","Patriotic Griffin","Firework Overlord","100k Dog","100k Cat","100k Mouse","100k Dolphin","100k Bat","100k Cyclops","Lucid Clockwork","Hostlord","Midnight Fest","UniKnight","Tornado Overseer","Frusky Darn Bird","100k Trophy","Toxic Dog","Toxic Cat","Toxic Bird","Toxic Slime","Toxic Abomination","Toxic Gaurd","Radioactive Protector","Skull Mutant","Golden Toxic Dog","Golden Toxic Cat","Golden Toxic Bird","Golden Toxic Slime","Golden Toxic Gaurd","Golden Toxic Abomination","Golden Radioactive Protector","Golden Skull Mutant"},
    CurrentOption = SelectedSellPets,
    MultipleOptions = true,
    Callback = function(val) SelectedSellPets = val end
})

EggTab:CreateDropdown({
    Name = "Types",
    Options = {"Normal", "Golden"},
    CurrentOption = SelectedSellTypes,
    MultipleOptions = true,
    Callback = function(val) SelectedSellTypes = val end
})

EggTab:CreateDropdown({
    Name = "Variants",
    Options = {"Normal", "Shiny", "Ruby", "Mutated"},
    CurrentOption = SelectedSellVariants,
    MultipleOptions = true,
    Callback = function(val) SelectedSellVariants = val end
})

local AutoSellThread = nil
EggTab:CreateToggle({
    Name = "Auto Sell Pets",
    CurrentValue = AutoSellEnabled,
    Callback = function(state)
        AutoSellEnabled = state
        if AutoSellThread then task.cancel(AutoSellThread) end
        if state then
            AutoSellThread = task.spawn(function()
                while AutoSellEnabled do
                    local petsToDelete = FormatPetList()
                    if #petsToDelete > 0 then
                        PetRemote:FireServer("Delete", petsToDelete)
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- Upgrades Tab
UpgradesTab:CreateSection("Upgrades Stuff")
UpgradesTab:CreateDropdown({
    Name = "Upgrade Types",
    Options = {"Taps", "Rebirths", "Gems", "HatchSpeed", "Luck"},
    CurrentOption = SelectedUpgradeTypes,
    MultipleOptions = true,
    Callback = function(val) SelectedUpgradeTypes = val end
})

UpgradesTab:CreateDropdown({
    Name = "Upgrade Machine",
    Options = {"Upgrade Machine 1", "Upgrade Machine 2", "Upgrade Machine 3", "Upgrade Machine 4", "Upgrade Machine 5"},
    CurrentOption = "Upgrade Machine 1",
    Callback = function(val)
        for _, machine in pairs(UpgradeMachines) do
            if machine.Name == val then
                SelectedUpgradeMachine = machine.Value
                break
            end
        end
    end
})

UpgradesTab:CreateSlider({
    Name = "Upgrade Delay",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = UpgradeDelay,
    Callback = function(val) UpgradeDelay = val end
})

local AutoBuyUpgradesThread = nil
UpgradesTab:CreateToggle({
    Name = "Auto Buy Upgrades",
    CurrentValue = AutoBuyUpgradesEnabled,
    Callback = function(state)
        AutoBuyUpgradesEnabled = state
        if AutoBuyUpgradesThread then task.cancel(AutoBuyUpgradesThread) end
        if state then
            AutoBuyUpgradesThread = task.spawn(function()
                while AutoBuyUpgradesEnabled do
                    for _, upgradeType in ipairs(SelectedUpgradeTypes) do
                        UpgradesRemote:FireServer(SelectedUpgradeMachine, upgradeType)
                        task.wait(0.05)
                    end
                    task.wait(UpgradeDelay)
                end
            end)
        end
    end
})

-- Misc Tab
MiscTab:CreateSection("Utility Features")
MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = AntiAfkEnabled,
    Callback = function(state)
        AntiAfkEnabled = state
        if state then
            AntiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        elseif AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
    end
})

MiscTab:CreateToggle({
    Name = "Auto Rejoin",
    CurrentValue = AutoRejoinEnabled,
    Callback = function(state) AutoRejoinEnabled = state end
})

MiscTab:CreateDivider()

MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = NoclipEnabled,
    Callback = function(state) SetNoclip(state) end
})

MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = WalkSpeedValue,
    Callback = function(val)
        WalkSpeedValue = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
        end
    end
})

MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = InfiniteJumpEnabled,
    Callback = function(state) SetInfiniteJump(state) end
})

-- Event Connections
LocalPlayer.CharacterAdded:Connect(function(char)
    if WalkSpeedValue ~= 16 then
        char:WaitForChild("Humanoid").WalkSpeed = WalkSpeedValue
    end
    if NoclipEnabled then SetNoclip(true) end
end)

SetupAutoRejoin()

-- Settings
SettingsTab:CreateLabel({
    Text = "Setting Configuration Is BROKEN Sometimes! (The problem not from me, its from the ui itself.)",
    Style = 3
})
SettingsTab:BuildConfigSection()
SettingsTab:CreateDivider()
SettingsTab:BuildThemeSection()
SettingsTab:CreateDivider()
SettingsTab:CreateBind({
    Name = "Stratum UI/Interface Keybind",
    CurrentBind = "K",
    Callback = function() end,
    OnChangedCallback = function(val) Window.Bind = val end
})

Luna:LoadAutoloadConfig()
