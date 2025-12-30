--[[
    STRATUM HUB - FULL RECONSTRUCTION (1:1)
    Game: Super League Soccer
]]

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/eradicator2/Stratum-superleaguesoccer-othergames/refs/heads/main/LunaUI_Loader_Source.lua", true))()

local Window = Luna:CreateWindow({
    Name = "Stratum Hub - Super League Soccer!",
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
        Note = "Best Key System Ever!",
        SaveInRoot = false,
        SaveKey = true,
        Key = {"Example Key"},
        SecondAction = { Enabled = true, Type = "Link", Parameter = "" }
    }
})

Window:CreateHomeTab({
    SupportedExecutors = {
        "Velocity",
        "Volcano",
        "Swift",
        "Wave",
        "Zenith",
        "awp",
        "Potassium",
        "Codex",
        "Delta",
        "Ronix",
        "Hydrogen",
        "Macsploit"
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

local MainTab = Window:CreateTab({ Name = "Main Tab", Icon = "dashboard", ImageSource = "Material", ShowTitle = true })
local TeamTab = Window:CreateTab({ Name = "Team Tab", Icon = "group", ImageSource = "Material", ShowTitle = true })
local ShopTab = Window:CreateTab({ Name = "Shop Tab", Icon = "shopping_cart", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc Tab", Icon = "source", ImageSource = "Material", ShowTitle = true })
local SettTab = Window:CreateTab({ Name = "Settings Tab", Icon = "settings", ImageSource = "Material", ShowTitle = true })

local StaminaMod = nil
local OldConsume = nil
local StaminaData = {}
local StaminaKey = nil
local InfStaminaActive = false

local function InitStamina()
    local success, err = pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        StaminaMod = require(lp.PlayerScripts.Client.Controllers.Stamina)
        OldConsume = StaminaMod.Consume
        
        local k, v, i = pairs(StaminaMod)
        while true do
            local nextVal
            i, nextVal = k(v, i)
            if i == nil then break end
            if type(nextVal) == "number" and nextVal <= 100 then
                StaminaKey = i
                break
            end
        end
    end)
    if not success then warn("Stamina system initialization failed:", err) end
end

local function ToggleInfiniteStamina(state)
    if state ~= InfStaminaActive then
        InfStaminaActive = state
        if not StaminaMod then InitStamina() end
        if not StaminaMod then return end

        if state then
            if StaminaMod.Amount then StaminaData.Amount = StaminaMod.Amount:get() end
            if StaminaKey then StaminaData.staminaValue = StaminaMod[StaminaKey] end
            
            StaminaMod.Consume = function() return true end -- Хук потребления
            
            task.spawn(function()
                while InfStaminaActive and task.wait(0.3) do
                    if StaminaMod.Amount then StaminaMod.Amount:set(100) end
                    if StaminaKey then StaminaMod[StaminaKey] = 100 end
                end
            end)
        else
            StaminaMod.Consume = OldConsume
            if StaminaMod.Amount and StaminaData.Amount then StaminaMod.Amount:set(StaminaData.Amount) end
            if StaminaKey and StaminaData.staminaValue then StaminaMod[StaminaKey] = StaminaData.staminaValue end
        end
    end
end

local LP = game:GetService("Players").LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HitboxPart = Char:WaitForChild("Hitbox")
local TacklePart = Char:WaitForChild("TackleHitbox")

local OrigHitbox = {
    Hitbox = {
        Size = HitboxPart.Size,
        OriginalSize = HitboxPart:FindFirstChild("OriginalSize") and HitboxPart.OriginalSize.Value or HitboxPart.Size,
        Transparency = HitboxPart.Transparency
    },
    TackleHitbox = {
        Size = TacklePart.Size,
        OriginalSize = TacklePart:FindFirstChild("OriginalSize") and TacklePart.OriginalSize.Value or TacklePart.Size,
        Transparency = TacklePart.Transparency
    }
}

local HitboxScales = { Hitbox = Vector3.new(1, 1, 1), TackleHitbox = Vector3.new(1, 1, 1) }
local HitboxTransps = { Hitbox = OrigHitbox.Hitbox.Transparency, TackleHitbox = OrigHitbox.TackleHitbox.Transparency }
local HBE_State = false
local TackleHBE_State = false

function updateHitbox()
    HitboxPart.Size = Vector3.new(OrigHitbox.Hitbox.Size.X + (HitboxScales.Hitbox.X - 1), OrigHitbox.Hitbox.Size.Y + (HitboxScales.Hitbox.Y - 1), OrigHitbox.Hitbox.Size.Z + (HitboxScales.Hitbox.Z - 1))
    if HitboxPart:FindFirstChild("OriginalSize") then
        HitboxPart.OriginalSize.Value = Vector3.new(OrigHitbox.Hitbox.OriginalSize.X + (HitboxScales.Hitbox.X - 1), OrigHitbox.Hitbox.OriginalSize.Y + (HitboxScales.Hitbox.Y - 1), OrigHitbox.Hitbox.OriginalSize.Z + (HitboxScales.Hitbox.Z - 1))
    end
    HitboxPart.Transparency = HitboxTransps.Hitbox
end

function updateTackleHitbox()
    TacklePart.Size = Vector3.new(OrigHitbox.TackleHitbox.Size.X + (HitboxScales.TackleHitbox.X - 1), OrigHitbox.TackleHitbox.Size.Y + (HitboxScales.TackleHitbox.Y - 1), OrigHitbox.TackleHitbox.Size.Z + (HitboxScales.TackleHitbox.Z - 1))
    if TacklePart:FindFirstChild("OriginalSize") then
        TacklePart.OriginalSize.Value = Vector3.new(OrigHitbox.TackleHitbox.OriginalSize.X + (HitboxScales.TackleHitbox.X - 1), OrigHitbox.TackleHitbox.OriginalSize.Y + (HitboxScales.TackleHitbox.Y - 1), OrigHitbox.TackleHitbox.OriginalSize.Z + (HitboxScales.TackleHitbox.Z - 1))
    end
    TacklePart.Transparency = HitboxTransps.TackleHitbox
end

local AutoJoinData = {}
local AutoJoinActive = false

local function AutoJoinLogic(teams, positions)
    AutoJoinData = {}
    local k1, v1, i1 = pairs(teams)
    while true do
        local teamName
        i1, teamName = k1(v1, i1)
        if i1 == nil then break end
        AutoJoinData[teamName] = {}
        local k2, v2, i2 = pairs(positions)
        while true do
            local posName
            i2, posName = k2(v2, i2)
            if i2 == nil then break end
            table.insert(AutoJoinData[teamName], posName)
        end
    end
    
    task.spawn(function()
        while AutoJoinActive do
            local k3, v3, i3 = pairs(AutoJoinData)
            while true do
                local tName
                i3, tName = k3(v3, i3)
                if i3 == nil then break end
                local teamObj = game:GetService("Teams"):FindFirstChild(tName)
                if teamObj then
                    local k4, v4, i4 = pairs(v3[tName])
                    while true do
                        local pos
                        i4, pos = k4(v4, i4)
                        if i4 == nil then break end
                        game:GetService("ReplicatedStorage"):WaitForChild("__GamemodeComm"):WaitForChild("RE"):WaitForChild("_RequestJoin"):FireServer({
                            Team = teamObj,
                            TeamPosition = pos
                        })
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local SpeedActive = false
local SpeedBoostAmt = 0
local SpeedBase = Hum.WalkSpeed
local SpeedFlag = false
local SpeedTarget = SpeedBase

local function SpeedMonitor()
    while SpeedActive and (Hum and Hum.Parent) do
        local vel = Hum.WalkSpeed - SpeedBoostAmt
        if math.abs(vel - SpeedBase) > 1 then
            SpeedFlag = SpeedBase < vel
            SpeedTarget = vel
        end
        task.wait(0.15)
    end
end

local function SpeedApply()
    while SpeedActive and (Hum and Hum.Parent) do
        if SpeedFlag then
            Hum.WalkSpeed = SpeedTarget + SpeedBoostAmt
        else
            Hum.WalkSpeed = SpeedBase + SpeedBoostAmt
        end
        task.wait(0.1)
    end
end

local function ToggleSpeed()
    if Hum then
        if SpeedActive then
            SpeedBase = Hum.WalkSpeed - SpeedBoostAmt
            SpeedTarget = SpeedBase
            SpeedFlag = false
            task.spawn(SpeedMonitor)
            task.spawn(SpeedApply)
        else
            Hum.WalkSpeed = SpeedTarget
        end
    end
end

local function ServerHop()
    local api = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet(api:format(game.PlaceId))).data
    end)
    if success and result then
        for _, s in ipairs(result) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                task.wait(3)
                return
            end
        end
    end
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

local AutoBuyPacks = false
local PackType = "Skill"
local function AutoBuyLoop()
    while AutoBuyPacks do
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("PacksService"):WaitForChild("RF"):WaitForChild("ProcessPurchase"):InvokeServer(PackType, "Coins")
        end)
        task.wait(0.5)
    end
end

MainTab:CreateLabel({ Text = "If u are Changing to GK, Re-Enable The 'Player Hitbox (HBE)'", Style = 3 })
MainTab:CreateSection("Player Modifications")
MainTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Callback = function(v) ToggleInfiniteStamina(v) end
}, "InfiniteStaminaToggle")

MainTab:CreateDivider("Hitbox Settings")
MainTab:CreateToggle({
    Name = "Player Hitbox (HBE)",
    Callback = function(v)
        HBE_State = v
        if v then updateHitbox() else
            HitboxPart.Size = OrigHitbox.Hitbox.Size
            HitboxPart.Transparency = OrigHitbox.Hitbox.Transparency
            if HitboxPart:FindFirstChild("OriginalSize") then HitboxPart.OriginalSize.Value = OrigHitbox.Hitbox.OriginalSize end
        end
    end
}, "HitboxToggle")

MainTab:CreateToggle({
    Name = "Tackle Hitbox (HBE)",
    Callback = function(v)
        TackleHBE_State = v
        if v then updateTackleHitbox() else
            TacklePart.Size = OrigHitbox.TackleHitbox.Size
            TacklePart.Transparency = OrigHitbox.TackleHitbox.Transparency
            if TacklePart:FindFirstChild("OriginalSize") then TacklePart.OriginalSize.Value = OrigHitbox.TackleHitbox.OriginalSize end
        end
    end
}, "TackleHitboxToggle")

MainTab:CreateDivider()
local axes = {"X", "Y", "Z"}
for _, axis in pairs(axes) do
    MainTab:CreateSlider({
        Name = "Hitbox " .. axis .. " Scale",
        Range = {0.1, 10}, Increment = 0.1, CurrentValue = 1,
        Callback = function(v)
            if axis == "X" then HitboxScales.Hitbox = Vector3.new(v, HitboxScales.Hitbox.Y, HitboxScales.Hitbox.Z)
            elseif axis == "Y" then HitboxScales.Hitbox = Vector3.new(HitboxScales.Hitbox.X, v, HitboxScales.Hitbox.Z)
            elseif axis == "Z" then HitboxScales.Hitbox = Vector3.new(HitboxScales.Hitbox.X, HitboxScales.Hitbox.Y, v) end
            if HBE_State then updateHitbox() end
        end
    })
end

MainTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1}, Increment = 0.05, CurrentValue = OrigHitbox.Hitbox.Transparency,
    Callback = function(v) HitboxTransps.Hitbox = v; if HBE_State then HitboxPart.Transparency = v end end
})

MainTab:CreateDivider()
for _, axis in pairs(axes) do
    MainTab:CreateSlider({
        Name = "Tackle " .. axis .. " Scale",
        Range = {0.1, 5}, Increment = 0.1, CurrentValue = 1,
        Callback = function(v)
            if axis == "X" then HitboxScales.TackleHitbox = Vector3.new(v, HitboxScales.TackleHitbox.Y, HitboxScales.TackleHitbox.Z)
            elseif axis == "Y" then HitboxScales.TackleHitbox = Vector3.new(HitboxScales.TackleHitbox.X, v, HitboxScales.TackleHitbox.Z)
            elseif axis == "Z" then HitboxScales.TackleHitbox = Vector3.new(HitboxScales.TackleHitbox.X, HitboxScales.TackleHitbox.Y, v) end
            if TackleHBE_State then updateTackleHitbox() end
        end
    })
end

MainTab:CreateSlider({
    Name = "Tackle Transparency",
    Range = {0, 1}, Increment = 0.05, CurrentValue = OrigHitbox.TackleHitbox.Transparency,
    Callback = function(v) HitboxTransps.TackleHitbox = v; if TackleHBE_State then TacklePart.Transparency = v end end
})

TeamTab:CreateSection("Auto Team")
local TeamDrop = TeamTab:CreateDropdown({
    Name = "Select Teams",
    Options = {"Home", "Away"},
    MultipleOptions = true,
    CurrentOption = {"Home", "Away"}
})
local PosDrop = TeamTab:CreateDropdown({
    Name = "Select Positions",
    Options = {"CF", "RF", "LF", "CM", "RB", "LB", "GK"},
    MultipleOptions = true,
    CurrentOption = {"CF"}
})
TeamTab:CreateToggle({
    Name = "Auto Join Team & Positions",
    Callback = function(v)
        AutoJoinActive = v
        if v then AutoJoinLogic(TeamDrop.CurrentOption, PosDrop.CurrentOption) end
    end
})

MiscTab:CreateSection("Player Misc")
MiscTab:CreateToggle({ Name = "Anti-AFK", CurrentValue = true, Callback = function(v) end })
MiscTab:CreateToggle({ Name = "Auto Rejoin", CurrentValue = true, Callback = function(v) end })
MiscTab:CreateButton({ Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end })
MiscTab:CreateButton({ Name = "Server Hop", Callback = ServerHop })
MiscTab:CreateToggle({ Name = "Speed Boost", Callback = function(v) SpeedActive = v; ToggleSpeed() end })
MiscTab:CreateSlider({ Name = "Boost Amount", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) SpeedBoostAmt = v; if SpeedActive then ToggleSpeed() end end })

ShopTab:CreateSection("Auto Buy Packs")
ShopTab:CreateDropdown({
    Name = "Pack Type",
    Options = {"Skill", "Emote", "Goal", "Card", "Ball", "Accessory"},
    CurrentOption = "Skill",
    Callback = function(v) PackType = v end
})
ShopTab:CreateToggle({
    Name = "Auto Buy Packs",
    Callback = function(v) AutoBuyPacks = v; if v then task.spawn(AutoBuyLoop) end end
})

SettTab:CreateLabel({ Text = "Setting Configuration Is BROKEN Sometimes!", Style = 3 })
SettTab:BuildConfigSection()
SettTab:BuildThemeSection()
SettTab:CreateBind({
    Name = "Stratum UI/Interface Keybind",
    CurrentBind = "K",
    Callback = function() end,
    OnChangedCallback = function(v) Window.Bind = v end
})

LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
    Hum = newChar:WaitForChild("Humanoid")
    HitboxPart = newChar:WaitForChild("Hitbox")
    TacklePart = newChar:WaitForChild("TackleHitbox")

    OrigHitbox.Hitbox = {
        Size = HitboxPart.Size,
        OriginalSize = HitboxPart:FindFirstChild("OriginalSize") and HitboxPart.OriginalSize.Value or HitboxPart.Size,
        Transparency = HitboxPart.Transparency
    }
    OrigHitbox.TackleHitbox = {
        Size = TacklePart.Size,
        OriginalSize = TacklePart:FindFirstChild("OriginalSize") and TacklePart.OriginalSize.Value or TacklePart.Size,
        Transparency = TacklePart.Transparency
    }

    SpeedBase = Hum.WalkSpeed
    SpeedTarget = SpeedBase
    SpeedFlag = false

    if HBE_State then updateHitbox() end
    if TackleHBE_State then updateTackleHitbox() end
    if SpeedActive then ToggleSpeed() end
end)

task.delay(1, InitStamina)
Luna:LoadAutoloadConfig()
