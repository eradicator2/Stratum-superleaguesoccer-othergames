if ({
    [13127800756] = "Arm Wrestle Simulator"
})[game.PlaceId] then
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    local Window = Rayfield:CreateWindow({
        Name = "Arm Wrestling Simulator",
        Icon = "scroll-text",
        LoadingTitle = "Era Era..",
        LoadingSubtitle = "by Sub2BK",
        Theme = "Amethyst",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "StratumHub",
            FileName = "AWSconfig"
        },
        Discord = {
            Enabled = false,
            Invite = "noinvitelink",
            RememberJoins = true
        },
        KeySystem = false,
        KeySettings = {
            Title = "AWS - Keysystem",
            Subtitle = "Made By Sub2BK",
            Note = "Ask me to the key. ;-;",
            FileName = "Stratum-Keysystem",
            SaveKey = true,
            GrabKeyFromSite = false,
            Key = {
                "BKOnTop!"
            }
        }
    })

    Rayfield:Notify({
        Title = "Script Has Been Loaded!",
        Content = "Enjoy it",
        Duration = 5,
        Image = "monitor-up"
    })

    local CreditsTab = Window:CreateTab("Credits", "circle-user")
    local DuckyTab = Window:CreateTab("Ducky Event", "calendar-clock")
    local RewindTab = Window:CreateTab("Rewind Event", "calendar-clock")
    local TeleportTab = Window:CreateTab("Teleport", "map")
    local ExtraTab = Window:CreateTab("Extra", "package-plus")

    local Player = game.Players.LocalPlayer
    local RootPart = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
    local RewindUndergroundCFrame = CFrame.new(-2037.90869140625, -35.191184997558594, -1459.566162109375)
    
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local KnitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")

    CreditsTab:CreateLabel("Made By Sub2BK - (bkmd_ytt)", "circle-user", Color3.fromRGB(73, 17, 124), false)
    CreditsTab:CreateLabel("Discord: .gg/XKxQwBd2zT", "message-circle-code", Color3.fromRGB(73, 17, 124), false)
    CreditsTab:CreateDivider()

    -- // --- DUCKY EVENT ---
    DuckyTab:CreateSection("Teleport Ducky Event Worlds")
    DuckyTab:CreateButton({
        Name = "Teleport To Ducky Event (World 1)",
        Callback = function()
            local spawn = workspace:WaitForChild("Zones"):WaitForChild("DuckEvent"):WaitForChild("Interactables"):WaitForChild("Teleports"):WaitForChild("Locations"):WaitForChild("Spawn")
            KnitServices:WaitForChild("ZoneService"):WaitForChild("RE"):WaitForChild("teleport"):FireServer(spawn)
        end
    })

    DuckyTab:CreateSection("Auto Fight Bosses")
    local DuckyBossData = {
        {Display = "Duck Nerd", Internal = "DuckNerd"},
        {Display = "Ducky", Internal = "Ducky"},
        {Display = "Waddles", Internal = "Waddles"},
        {Display = "Captain Quacks", Internal = "CaptainQuacks"},
        {Display = "Evil Duck", Internal = "EvilDuck"},
        {Display = "Destroyer Ducky", Internal = "DestroyerDucky"}
    }
    local DuckyBossOptions = {}
    local DuckyBossMapping = {}
    for _, v in ipairs(DuckyBossData) do
        table.insert(DuckyBossOptions, v.Display)
        DuckyBossMapping[v.Display] = v.Internal
    end

    local SelectedDuckyBoss = nil
    local AutoFightDuckyEnabled = false
    local DuckyFightThreads = {}
    local DuckyIconBackup = nil
    local AutoFightClickDucky = false
    local DuckyClickThreads = {}

    local function GetDuckyBossZone(boss)
        if table.find({"DuckNerd","Ducky","Waddles","CaptainQuacks","EvilDuck","DestroyerDucky"}, boss) then return "DuckEvent" end
        return "DuckyBank"
    end

    DuckyTab:CreateDropdown({
        Name = "Select Boss",
        Options = DuckyBossOptions,
        Callback = function(val) SelectedDuckyBoss = DuckyBossMapping[val[1]] end
    })

    DuckyTab:CreateToggle({
        Name = "Auto Fight Boss",
        CurrentValue = false,
        Callback = function(val)
            AutoFightDuckyEnabled = val
            local fightGui = Player:WaitForChild("PlayerGui"):WaitForChild("Fighting"):WaitForChild("Wrestle")
            if val then
                if fightGui:FindFirstChild("PlayerIcon") then
                    DuckyIconBackup = fightGui.PlayerIcon:Clone()
                    fightGui.PlayerIcon:Destroy()
                end
                task.spawn(function()
                    for _ = 1, 10 do
                        local thread = {active = true}
                        table.insert(DuckyFightThreads, thread)
                        task.spawn(function()
                            while thread.active and AutoFightDuckyEnabled and SelectedDuckyBoss do
                                local zone = GetDuckyBossZone(SelectedDuckyBoss)
                                pcall(function()
                                    local npc = workspace:WaitForChild("GameObjects"):WaitForChild("ArmWrestling"):WaitForChild(zone):WaitForChild("NPC"):WaitForChild(SelectedDuckyBoss)
                                    KnitServices:WaitForChild("ArmWrestleService"):WaitForChild("RF"):WaitForChild("RequestStartFight"):InvokeServer(npc)
                                end)
                                task.wait()
                            end
                        end)
                        task.wait()
                    end
                end)
            else
                for _, t in pairs(DuckyFightThreads) do t.active = false end
                DuckyFightThreads = {}
                task.delay(3, function()
                    if DuckyIconBackup and not fightGui:FindFirstChild("PlayerIcon") then
                        DuckyIconBackup.Parent = fightGui
                        DuckyIconBackup = nil
                    end
                end)
            end
        end
    })

    DuckyTab:CreateToggle({
        Name = "Auto Fight Click",
        CurrentValue = false,
        Callback = function(val)
            AutoFightClickDucky = val
            if val then
                task.spawn(function()
                    for _ = 1, 100 do
                        local thread = {active = true}
                        table.insert(DuckyClickThreads, thread)
                        task.spawn(function()
                            while thread.active and AutoFightClickDucky do
                                pcall(function()
                                    local rf = KnitServices:WaitForChild("ArmWrestleService"):WaitForChild("RF")
                                    rf:WaitForChild("RequestClick"):InvokeServer()
                                    rf:WaitForChild("RequestCritHit"):InvokeServer()
                                end)
                                task.wait()
                            end
                        end)
                        task.wait()
                    end
                end)
            else
                for _, t in pairs(DuckyClickThreads) do t.active = false end
                DuckyClickThreads = {}
            end
        end
    })

    DuckyTab:CreateDivider()
    DuckyTab:CreateLabel("-[ This Method Is Faster 100x Than The Normal Game Speed With VIP, and U DONT NEED VIP! ]-", "triangle-alert", Color3.fromRGB(73, 17, 124), false)
    DuckyTab:CreateLabel("-[ If The HUD (Buttons UI) Game Not Showing, TP To Other World and Return Back ]-", "triangle-alert", Color3.fromRGB(73, 17, 124), false)

    DuckyTab:CreateSection("Merchant Sell Duck")
    local DuckList = {"Astronaut Ducky", "Candy Ducky", "Cactus Ducky", "Cash Ducky", "Chocolate Ducky", "Cowboy Ducky", "Crystal Ducky", "Diamond Ducky", "Evil Ducky", "Knight Ducky", "Pirate Ducky", "Regular Ducky", "Robot Ducky", "Slime Ducky", "Santa Ducky", "Swag Ducky", "Unicorn Ducky", "Viking Ducky", "Wizard Ducky"}
    local SelectedSellDucks = {}
    local AutoSellDucksEnabled = false

    DuckyTab:CreateDropdown({
        Name = "Select Duckies to Sell",
        Options = {"All Ducks", unpack(DuckList)},
        MultipleOptions = true,
        Callback = function(val)
            SelectedSellDucks = {}
            if table.find(val, "All Ducks") then SelectedSellDucks = DuckList else SelectedSellDucks = val end
        end
    })

    DuckyTab:CreateToggle({
        Name = "Auto Sell Selected Duckies",
        CurrentValue = false,
        Callback = function(val)
            AutoSellDucksEnabled = val
            if val then
                task.spawn(function()
                    while AutoSellDucksEnabled do
                        for _, duck in ipairs(SelectedSellDucks) do
                            pcall(function()
                                KnitServices:WaitForChild("DuckService"):WaitForChild("RF"):WaitForChild("Sell"):InvokeServer(duck, "ALL")
                            end)
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    DuckyTab:CreateSection("Biceps Trains")
    local DuckyBicepsWeight = 1
    local DuckyBicepsIsW2 = false
    local AutoTrainDuckyBiceps = false

    DuckyTab:CreateDropdown({
        Name = "Choose Your Biceps Weight (World 1)",
        Options = {"1 (World 1)","2 (World 1)","3 (World 1)","4 (World 1)","5 (World 1)","6 (World 1)","7 (World 1)","8 (World 1)","9 (World 1)","10 (World 1)","11 (World 1)","12 (World 1)"},
        Callback = function(val)
            DuckyBicepsWeight = tonumber(val[1]:match("%d+"))
            DuckyBicepsIsW2 = val[1]:find("World 2") ~= nil
        end
    })

    DuckyTab:CreateToggle({
        Name = "Start Auto Train - Biceps",
        CurrentValue = false,
        Callback = function(val)
            AutoTrainDuckyBiceps = val
            if val then
                task.spawn(function()
                    while AutoTrainDuckyBiceps do
                        KnitServices:WaitForChild("IdleTeleportService"):WaitForChild("RF"):WaitForChild("SetLatestTeleportData"):InvokeServer({Value = "Biceps", AutoType = "AutoTrain"})
                        local tool = DuckyBicepsIsW2 and "DuckyBank"..DuckyBicepsWeight or "Ducky"..DuckyBicepsWeight
                        KnitServices:WaitForChild("ToolService"):WaitForChild("RE"):WaitForChild("onEquipRequest"):FireServer(DuckyBicepsIsW2 and "DuckyBank" or "DuckEvent", "Dumbells", tool)
                        KnitServices:WaitForChild("AutoService"):WaitForChild("RF"):WaitForChild("SetRejoin"):InvokeServer("AutoTraining", {TrainingType = "Biceps"})
                        task.wait()
                    end
                end)
            end
        end
    })

    DuckyTab:CreateSection("Grips Trains")
    local DuckyGripsWeight = "1Kg"
    local DuckyGripsIsW2 = false
    local AutoTrainDuckyGrips = false

    DuckyTab:CreateDropdown({
        Name = "Choose Your Grips Weight (World 1)",
        Options = {"1Kg (World 1)","2Kg (World 1)","3Kg (World 1)","4Kg (World 1)","5Kg (World 1)","10Kg (World 1)","15Kg (World 1)","20Kg (World 1)","25Kg (World 1)","50Kg (World 1)","100Kg (World 1)","250Kg (World 1)"},
        Callback = function(val)
            DuckyGripsWeight = val[1]:match("(%d+Kg)")
            DuckyGripsIsW2 = val[1]:find("World 2") ~= nil
        end
    })

    DuckyTab:CreateToggle({
        Name = "Start Auto Train - Grips",
        CurrentValue = false,
        Callback = function(val)
            AutoTrainDuckyGrips = val
            if val then
                task.spawn(function()
                    while AutoTrainDuckyGrips do
                        KnitServices:WaitForChild("IdleTeleportService"):WaitForChild("RF"):WaitForChild("SetLatestTeleportData"):InvokeServer({Value = "Grips", AutoType = "AutoTrain"})
                        KnitServices:WaitForChild("ToolService"):WaitForChild("RE"):WaitForChild("onEquipRequest"):FireServer(DuckyGripsIsW2 and "DuckyBank" or "DuckEvent", "Grips", DuckyGripsWeight)
                        KnitServices:WaitForChild("AutoService"):WaitForChild("RF"):WaitForChild("SetRejoin"):InvokeServer("AutoTraining", {TrainingType = "Grips"})
                        task.wait()
                    end
                end)
            end
        end
    })

    DuckyTab:CreateSection("Auto Click")
    local DuckyAutoClickTrain = false
    DuckyTab:CreateToggle({
        Name = "Auto Click Train",
        CurrentValue = false,
        Callback = function(val)
            DuckyAutoClickTrain = val
            if val then
                task.spawn(function()
                    local remote = KnitServices:WaitForChild("ToolService"):WaitForChild("RE"):WaitForChild("onClick")
                    while DuckyAutoClickTrain do remote:FireServer(); task.wait() end
                end)
            end
        end
    })

    DuckyTab:CreateSection("Knuckles Train")
    local DuckyKnucklePositions = {
        ["Tier1 (World 1)"] = CFrame.new(-746.276, 39.856, 9.850),
        ["Tier2 (World 1)"] = CFrame.new(-750.145, 39.856, -0.654),
        ["Tier3 (World 1)"] = CFrame.new(-753.985, 39.856, -11.412),
        ["Tier4 (World 1)"] = CFrame.new(-758.216, 39.856, -22.508),
        ["Tier5 (World 1)"] = CFrame.new(-761.773, 39.856, -33.021),
        ["Tier6 VIP (World 1)"] = CFrame.new(-765.489, 39.856, -43.992)
    }
    local SelectedDuckyKnuckle = nil
    local AutoDuckyKnuckle = false

    DuckyTab:CreateDropdown({
        Name = "Select Tier/Bag",
        Options = {"Tier1 (World 1)","Tier2 (World 1)","Tier3 (World 1)","Tier4 (World 1)","Tier5 (World 1)","Tier6 VIP (World 1)"},
        Callback = function(val) SelectedDuckyKnuckle = val[1] end
    })

    DuckyTab:CreateToggle({
        Name = "Auto Knuckle",
        CurrentValue = false,
        Callback = function(val)
            AutoDuckyKnuckle = val
            if val then
                task.spawn(function()
                    while AutoDuckyKnuckle do
                        if SelectedDuckyKnuckle then
                            local cf = DuckyKnucklePositions[SelectedDuckyKnuckle]
                            local char = Player.Character or Player.CharacterAdded:Wait()
                            if cf and char:FindFirstChild("HumanoidRootPart") then char:SetPrimaryPartCFrame(cf) end
                            local tier = "Tier" .. (SelectedDuckyKnuckle:match("Tier(%d+)") or "1")
                            KnitServices:WaitForChild("PunchBagService"):WaitForChild("RE"):WaitForChild("onGiveStats"):FireServer(SelectedDuckyKnuckle:find("World 2") and "DuckyBank" or "DuckEvent", tier)
                        end
                        task.wait()
                    end
                end)
            end
        end
    })

    DuckyTab:CreateSection("Event Eggs")
    local SelectedDuckyEgg = ""
    local AutoHatchDuckyEnabled = false
    DuckyTab:CreateDropdown({
        Name = "Select Egg To Hatch",
        Options = {"Ducky", "EvilDucky"},
        Callback = function(val) SelectedDuckyEgg = val[1] end
    })
    DuckyTab:CreateToggle({
        Name = "Auto Hatch Egg",
        CurrentValue = false,
        Callback = function(val)
            AutoHatchDuckyEnabled = val
            if val then
                while AutoHatchDuckyEnabled do
                    if SelectedDuckyEgg ~= "" then
                        KnitServices:WaitForChild("EggService"):WaitForChild("RF"):WaitForChild("purchaseEgg"):InvokeServer(SelectedDuckyEgg, nil, nil, false, nil, true)
                    end
                    task.wait()
                end
            end
        end
    })

    DuckyTab:CreateSection("Ducky (Spin Wheel)")
    local DuckySpinAmt = "10x"
    local AutoSpinDucky = false
    DuckyTab:CreateDropdown({
        Name = "Ducky Spin Wheel",
        Options = {"1x", "3x", "10x"},
        Callback = function(val) DuckySpinAmt = val[1] end
    })
    DuckyTab:CreateToggle({
        Name = "Auto Spin (Selected Amount)",
        CurrentValue = false,
        Callback = function(val)
            AutoSpinDucky = val
            while AutoSpinDucky do
                local args = {"Ducky"}
                if DuckySpinAmt == "3x" then table.insert(args, 2, "x10") elseif DuckySpinAmt == "10x" then table.insert(args, 2, "x25") end
                KnitServices:WaitForChild("SpinnerService"):WaitForChild("RF"):WaitForChild("Spin"):InvokeServer(unpack(args))
                task.wait()
            end
        end
    })

    DuckyTab:CreateSection("Extra Stuff")
    local AutoClaimDuckyPass = false
    DuckyTab:CreateToggle({
        Name = "Auto Claim (Playtime Pass)",
        CurrentValue = false,
        Callback = function(val)
            AutoClaimDuckyPass = val
            if val then
                while AutoClaimDuckyPass do
                    for i = 1, 12 do
                        KnitServices:WaitForChild("EventPassService"):WaitForChild("RF"):WaitForChild("ClaimReward"):InvokeServer("Free", i)
                        task.wait(0.5)
                        if not AutoClaimDuckyPass then break end
                    end
                end
            end
        end
    })

    -- // --- REWIND EVENT ---
    RewindTab:CreateSection("Teleport Rewind Event Worlds")
    RewindTab:CreateButton({
        Name = "Teleport To Rewind Event (World 1)",
        Callback = function()
            local spawn = workspace:WaitForChild("Zones"):WaitForChild("RewindEvent"):WaitForChild("Interactables"):WaitForChild("Teleports"):WaitForChild("Locations"):WaitForChild("Spawn")
            KnitServices:WaitForChild("ZoneService"):WaitForChild("RE"):WaitForChild("teleport"):FireServer(spawn)
        end
    })
    RewindTab:CreateButton({Name = "Teleport To Underground Rewind Event (World 1)", Callback = function() RootPart.CFrame = RewindUndergroundCFrame end})
    RewindTab:CreateButton({
        Name = "Teleport To Rewind Event (World 2)",
        Callback = function()
            local spawn = workspace:WaitForChild("Zones"):WaitForChild("RewindBank"):WaitForChild("Interactables"):WaitForChild("Teleports"):WaitForChild("Locations"):WaitForChild("Spawn")
            KnitServices:WaitForChild("ZoneService"):WaitForChild("RE"):WaitForChild("teleport"):FireServer(spawn)
        end
    })

    RewindTab:CreateSection("Auto Fight Bosses")
    local RewindBossData = {
        {Display = "Detective Dave", Internal = "DetectiveDave"}, {Display = "Copper Chris", Internal = "CopperChris"},
        {Display = "Genius Calzone", Internal = "GeniusCalzone"}, {Display = "Midnight Moretti", Internal = "MidnightMoretti"},
        {Display = "Rose Falcone", Internal = "RoseFalcone"}, {Display = "Toxic Calzone", Internal = "ToxicCalzone"},
        {Display = "Nuclear Champ", Internal = "NuclearChamp"}, {Display = "Hazmat Mafia", Internal = "HazmatMafia"},
        {Display = "Golden Mafia", Internal = "GoldenMafia"}, {Display = "Sewer Capybara", Internal = "SewerCapybara"},
        {Display = "Intern Jan", Internal = "InternJan"}, {Display = "Junior Jake", Internal = "JuniorJake"},
        {Display = "Shades McBoss", Internal = "ShadesMcBoss"}, {Display = "Sir Richington", Internal = "SirRichington"},
        {Display = "Tycoon Tony", Internal = "TycoonTony"}, {Display = "Evil Tony", Internal = "EvilTony"}
    }
    local RewindBossOptions = {}
    local RewindBossMapping = {}
    for _, v in ipairs(RewindBossData) do table.insert(RewindBossOptions, v.Display); RewindBossMapping[v.Display] = v.Internal end

    local SelectedRewindBoss = nil
    local AutoFightRewindEnabled = false
    local RewindFightThreads = {}
    local RewindIconBackup = nil
    local AutoFightClickRewind = false
    local RewindClickThreads = {}

    local function GetRewindBossZone(boss)
        local bank = {"InternJan","JuniorJake","ShadesMcBoss","SirRichington","TycoonTony","EvilTony"}
        if table.find(bank, boss) then return "RewindBank" end
        return "RewindEvent"
    end

    RewindTab:CreateDropdown({
        Name = "Select Boss",
        Options = RewindBossOptions,
        Callback = function(val) SelectedRewindBoss = RewindBossMapping[val[1]] end
    })

    RewindTab:CreateToggle({
        Name = "Auto Fight Boss",
        CurrentValue = false,
        Callback = function(val)
            AutoFightRewindEnabled = val
            local fightGui = Player:WaitForChild("PlayerGui"):WaitForChild("Fighting"):WaitForChild("Wrestle")
            if val then
                if fightGui:FindFirstChild("PlayerIcon") then RewindIconBackup = fightGui.PlayerIcon:Clone(); fightGui.PlayerIcon:Destroy() end
                task.spawn(function()
                    for _ = 1, 10 do
                        local thread = {active = true}
                        table.insert(RewindFightThreads, thread)
                        task.spawn(function()
                            while thread.active and AutoFightRewindEnabled and SelectedRewindBoss do
                                local zone = GetRewindBossZone(SelectedRewindBoss)
                                pcall(function()
                                    local npc = workspace:WaitForChild("GameObjects"):WaitForChild("ArmWrestling"):WaitForChild(zone):WaitForChild("NPC"):WaitForChild(SelectedRewindBoss)
                                    KnitServices:WaitForChild("ArmWrestleService"):WaitForChild("RF"):WaitForChild("RequestStartFight"):InvokeServer(npc)
                                end)
                                task.wait()
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
            else
                for _, t in pairs(RewindFightThreads) do t.active = false end
                RewindFightThreads = {}
                task.delay(3, function() if RewindIconBackup and not fightGui:FindFirstChild("PlayerIcon") then RewindIconBackup.Parent = fightGui; RewindIconBackup = nil end end)
            end
        end
    })

    RewindTab:CreateToggle({
        Name = "Auto Fight Click",
        CurrentValue = false,
        Callback = function(val)
            AutoFightClickRewind = val
            if val then
                task.spawn(function()
                    for _ = 1, 150 do
                        local thread = {active = true}
                        table.insert(RewindClickThreads, thread)
                        task.spawn(function()
                            while thread.active and AutoFightClickRewind do
                                pcall(function()
                                    local rf = KnitServices:WaitForChild("ArmWrestleService"):WaitForChild("RF")
                                    rf:WaitForChild("RequestClick"):InvokeServer()
                                    rf:WaitForChild("RequestCritHit"):InvokeServer()
                                end)
                                task.wait()
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
            else
                for _, t in pairs(RewindClickThreads) do t.active = false end
                RewindClickThreads = {}
            end
        end
    })

    RewindTab:CreateSection("Biceps Trains")
    local RewindBicepsWeight = 1
    local RewindBicepsIsW2 = false
    local AutoTrainRewindBiceps = false
    RewindTab:CreateDropdown({
        Name = "Choose Your Biceps Weight (World 1 - 2)",
        Options = {"1 (World 1)","2 (World 1)","3 (World 1)","4 (World 1)","5 (World 1)","6 (World 1)","7 (World 1)","8 (World 1)","9 (World 1)","10 (World 1)","11 (World 1)","12 (World 1)","1 (World 2)","2 (World 2)","3 (World 2)","4 (World 2)","5 (World 2)","6 (World 2)","7 (World 2)","8 (World 2)","9 (World 2)","10 (World 2)","11 (World 2)","12 (World 2)"},
        Callback = function(val)
            RewindBicepsWeight = tonumber(val[1]:match("%d+"))
            RewindBicepsIsW2 = val[1]:find("World 2") ~= nil
        end
    })
    RewindTab:CreateToggle({
        Name = "Start Auto Train - Biceps",
        CurrentValue = false,
        Callback = function(val)
            AutoTrainRewindBiceps = val
            if val then
                task.spawn(function()
                    while AutoTrainRewindBiceps do
                        KnitServices:WaitForChild("IdleTeleportService"):WaitForChild("RF"):WaitForChild("SetLatestTeleportData"):InvokeServer({Value = "Biceps", AutoType = "AutoTrain"})
                        local tool = RewindBicepsIsW2 and "RewindBank"..RewindBicepsWeight or "Rewind"..RewindBicepsWeight
                        KnitServices:WaitForChild("ToolService"):WaitForChild("RE"):WaitForChild("onEquipRequest"):FireServer(RewindBicepsIsW2 and "RewindBank" or "RewindEvent", "Dumbells", tool)
                        KnitServices:WaitForChild("AutoService"):WaitForChild("RF"):WaitForChild("SetRejoin"):InvokeServer("AutoTraining", {TrainingType = "Biceps"})
                        task.wait()
                    end
                end)
            end
        end
    })

    RewindTab:CreateSection("Auto Click")
    local RewindAutoClick = false
    RewindTab:CreateToggle({
        Name = "Auto Click Train",
        CurrentValue = false,
        Callback = function(val)
            RewindAutoClick = val
            if val then
                task.spawn(function()
                    local remote = KnitServices:WaitForChild("ToolService"):WaitForChild("RE"):WaitForChild("onClick")
                    while RewindAutoClick do remote:FireServer(); task.wait() end
                end)
            end
        end
    })

    RewindTab:CreateSection("Knuckles Train")
    local RewindKnucklePositions = {
        ["Tier1 (World 1)"] = CFrame.new(-2062.441, 5.298, -1677.127),
        ["Tier2 (World 1)"] = CFrame.new(-2074.966, 5.298, -1678.569),
        ["Tier3 (World 1)"] = CFrame.new(-2086.051, 5.298, -1678.253),
        ["Tier4 (World 1)"] = CFrame.new(-2098.837, 5.298, -1678.985),
        ["Tier5 (World 1)"] = CFrame.new(-2110.011, 5.298, -1678.181),
        ["Tier6 VIP (World 1)"] = CFrame.new(-2122.829, 5.298, -1678.178),
        ["Tier1 (World 2)"] = CFrame.new(-938.793, 37.158, -1237.064),
        ["Tier2 (World 2)"] = CFrame.new(-938.793, 37.158, -1248.339),
        ["Tier3 (World 2)"] = CFrame.new(-938.793, 37.158, -1259.199),
        ["Tier4 (World 2)"] = CFrame.new(-938.793, 37.158, -1270.605),
        ["Tier5 (World 2)"] = CFrame.new(-938.793, 37.158, -1281.091),
        ["Tier6 VIP (World 2)"] = CFrame.new(-938.793, 37.158, -1292.54)
    }
    local SelectedRewindKnuckle = nil
    local AutoRewindKnuckle = false
    RewindTab:CreateDropdown({
        Name = "Select Tier/Bag",
        Options = {"Tier1 (World 1)","Tier2 (World 1)","Tier3 (World 1)","Tier4 (World 1)","Tier5 (World 1)","Tier6 VIP (World 1)","Tier1 (World 2)","Tier2 (World 2)","Tier3 (World 2)","Tier4 (World 2)","Tier5 (World 2)","Tier6 VIP (World 2)"},
        Callback = function(val) SelectedRewindKnuckle = val[1] end
    })
    RewindTab:CreateToggle({
        Name = "Auto Knuckle",
        CurrentValue = false,
        Callback = function(val)
            AutoRewindKnuckle = val
            if val then
                task.spawn(function()
                    while AutoRewindKnuckle do
                        if SelectedRewindKnuckle then
                            local cf = RewindKnucklePositions[SelectedRewindKnuckle]
                            local char = Player.Character or Player.CharacterAdded:Wait()
                            if cf and char:FindFirstChild("HumanoidRootPart") then char:SetPrimaryPartCFrame(cf) end
                            local tier = "Tier" .. (SelectedRewindKnuckle:match("Tier(%d+)") or "1")
                            KnitServices:WaitForChild("PunchBagService"):WaitForChild("RE"):WaitForChild("onGiveStats"):FireServer(SelectedRewindKnuckle:find("World 2") and "RewindBank" or "RewindEvent", tier)
                        end
                        task.wait()
                    end
                end)
            end
        end
    })

    RewindTab:CreateSection("Merchant Stuff")
    local MerchantMapping = {["Hidden 1"]=1,["Hidden 2"]=2,["Hidden 3"]=3,["Hidden 4"]=4,["Hidden 5"]=5,["Bank 1"]=1,["Bank 2"]=2,["Bank 3"]=3,["Bank 4"]=4,["Bank 5"]=5}
    local HiddenItems = {}
    local BankItems = {}
    local AutoBuyMerchant = false
    RewindTab:CreateDropdown({Name="Hidden Merchant Items",Options={"Hidden 1","Hidden 2","Hidden 3","Hidden 4","Hidden 5"},MultipleOptions=true,Callback=function(val) HiddenItems = val end})
    RewindTab:CreateDropdown({Name="Bank Merchant Items",Options={"Bank 1","Bank 2","Bank 3","Bank 4","Bank 5"},MultipleOptions=true,Callback=function(val) BankItems = val end})
    RewindTab:CreateToggle({
        Name = "Auto Buy Selected Items",
        CurrentValue = false,
        Callback = function(val)
            AutoBuyMerchant = val
            task.spawn(function()
                while AutoBuyMerchant do
                    for _, item in ipairs(HiddenItems) do
                        local idx = MerchantMapping[item]
                        if idx then KnitServices:WaitForChild("LimitedMerchantService"):WaitForChild("RF"):WaitForChild("BuyItem"):InvokeServer("Hidden Merchant", idx); task.wait(0.5) end
                    end
                    for _, item in ipairs(BankItems) do
                        local idx = MerchantMapping[item]
                        if idx then KnitServices:WaitForChild("LimitedMerchantService"):WaitForChild("RF"):WaitForChild("BuyItem"):InvokeServer("Bank Merchant", idx); task.wait(0.5) end
                    end
                    task.wait(1)
                end
            end)
        end
    })

    -- // --- TELEPORT ---
    local TeleportData = {
        {Name = "Garden", Key = "Garden"}, {Name = "Spawn | World 1", Key = "1"}, {Name = "Space Gym | World 2", Key = "2"},
        {Name = "Beach | World 3", Key = "3"}, {Name = "Bunker | World 4", Key = "4"}, {Name = "Dino | World 5", Key = "5"},
        {Name = "Void | World 6", Key = "6"}, {Name = "Space Center | World 7", Key = "7"}, {Name = "Roman Empire | World 8", Key = "8"},
        {Name = "Underworld | World 9", Key = "9"}, {Name = "Magic Forest | World 10", Key = "10"}, {Name = "Snowy Peaks | World 11", Key = "11"},
        {Name = "Dusty Tavern | World 12", Key = "12"}, {Name = "Lost Kingdom | World 13", Key = "13"}, {Name = "Orc Paradise | World 14", Key = "14"},
        {Name = "Heavenly Island | World 15", Key = "15"}, {Name = "The Rift | World 16", Key = "16"}, {Name = "Matrix | World 17", Key = "17"}
    }
    local TeleportOptions = {}
    for _, v in ipairs(TeleportData) do table.insert(TeleportOptions, v.Name) end
    local SelectedTeleportZone = "Spawn | World 1"

    TeleportTab:CreateDropdown({
        Name = "Teleport to Zone",
        Options = TeleportOptions,
        CurrentOption = {SelectedTeleportZone},
        Callback = function(val) SelectedTeleportZone = val[1] or "Spawn | World 1" end
    })
    TeleportTab:CreateButton({
        Name = "TP To Selected World",
        Callback = function()
            local key = nil
            for _, v in ipairs(TeleportData) do if v.Name == SelectedTeleportZone then key = v.Key; break end end
            if key then
                pcall(function()
                    local loc = workspace.Zones[key].Interactables.Teleports.Locations.Spawn
                    KnitServices:WaitForChild("ZoneService"):WaitForChild("RE"):WaitForChild("teleport"):FireServer(loc)
                end)
            end
        end
    })

    -- // --- EXTRA ---
    ExtraTab:CreateToggle({
        Name = "Auto Roll Aura",
        CurrentValue = false,
        Callback = function(val)
            local roll = val
            if roll then
                task.spawn(function()
                    while roll do task.wait(0.001); KnitServices:WaitForChild("AuraService"):WaitForChild("RF"):WaitForChild("Roll"):InvokeServer() end
                end)
            end
        end
    })

    ExtraTab:CreateButton({
        Name = "Enable Auto Rejoin",
        Callback = function()
            game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
                if msg and msg ~= "" then task.wait(); TeleportService:Teleport(game.PlaceId, Player) end
            end)
        end
    })

    ExtraTab:CreateButton({
        Name = "Rejoin Current Server",
        Callback = function() Player:Kick("Rejoining..."); task.wait(2); TeleportService:Teleport(game.PlaceId, Player) end
    })

    loadstring(game:HttpGet("https://raw.githubusercontent.com/juywvm/-Roblox-Projects-/main/____Anti_Afk_Remastered_______"))()
    Rayfield:Notify({Title = "Anti-AFK Loaded", Content = "Enjoy With Anti-Afk", Duration = 5, Image = "wallet-cards"})
    Rayfield:LoadConfiguration()
else
    warn("GAME/PLACE NOT SUPPORTED")
end
