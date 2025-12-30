--// Secure C-Function Initializer
local C_Success, C = pcall(function()
    return C(C)
end)

if not C_Success then
    C = {
        pairs = pairs,
        ipairs = ipairs,
        type = type,
        tostring = tostring,
        getmetatable = getmetatable,
        setmetatable = setmetatable,
        cloneref = function(i) return i end,
        secure_call = function(f, ...) return pcall(f, ...) end
    }
end



--// Services & Caches
local cloneref_func = typeof(C["cloneref"]) == "function" and C["cloneref"] or function(i) return i end
local Players = cloneref_func(game):GetService("Players")
local Workspace = cloneref_func(game):GetService("Workspace")
local RunService = cloneref_func(game):GetService("RunService")
local ReplicatedStorage = cloneref_func(game):GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

--// Pretty Print Utility
local function prettyPrint(printType, ...)
    if not (getgenv().Grow_a_Garden and getgenv().Grow_a_Garden.Script_Debug) then return end

    local prefixes = {
        info = "💡 [Info]",
        success = "✅ [Success]",
        warning = "⚠️ [Warning]",
        error = "❌ [Error]",
        purchase = "💰 [Purchase]",
        action = "⚙️ [Action]",
        harvest = "🌾 [Harvest]",
        plant = "🌱 [Plant]",
        feed = "🍖 [Feed]",
        cook = "🍳 [Cook]",
        sell = "💲 [Sell]",
        move = "🐾 [Move]",
        remote = "📡 [Remote]",
        optimize = "🚀 [Optimize]"
    }
    
    local prefix = prefixes[printType] or "❓ [Log]"
    local message = table.concat({...}, " ")
    local formattedMessage = string.format("Debugger | %s: %s", prefix, message)
    
    if C_Success then
        C.print(formattedMessage)
    else
        print(formattedMessage)
    end
end

--// Remote Caching Function
local function initializeRemotes()
    prettyPrint("info", "Caching remote events...")
    local remoteContainer = ReplicatedStorage:WaitForChild("GameEvents", 20)
    if not remoteContainer then
        prettyPrint("error", "Could not find GameEvents container. Most features will fail.")
        return {}
    end

    task.spawn(function()
        prettyPrint("info", "Loading screen skipper initialized.")

        local finishLoadingRemote = remoteContainer:WaitForChild("Finish_Loading", 30) 
        local loadScreenEvent = remoteContainer:WaitForChild("LoadScreenEvent", 5)
        local targetPlayer = LocalPlayer

        if finishLoadingRemote and loadScreenEvent and targetPlayer then
        task.wait(30)
            prettyPrint("success", "All remotes found. Running skipper with fake key + click...")

            pcall(function()
                finishLoadingRemote:FireServer()
                loadScreenEvent:FireServer(targetPlayer)

                mouse1click()    -- also simulate mouse click

                task.wait(0.5)
                keypress(0x45)   -- simulate "E"
                task.wait(0.1)
                keyrelease(0x45)
            end)

            prettyPrint("success", "Skipper sequence complete.")
        else
            prettyPrint("warning", "Skipper failed. Diagnosing issue...")
            if not finishLoadingRemote then 
                prettyPrint("warning", "Could not find Finish_Loading remote.") 
            end
            if not loadScreenEvent then 
                prettyPrint("warning", "Could not find LoadScreenEvent.") 
            end
        end
    end)

    local remotes = {
        BuySeed = remoteContainer:FindFirstChild("BuySeedStock"),
        BuyEgg = remoteContainer:FindFirstChild("BuyPetEgg"),
        BuyGear = remoteContainer:FindFirstChild("BuyGearStock"),
        SellInventory = remoteContainer:FindFirstChild("Sell_Inventory"),
        Plant_RE = remoteContainer:FindFirstChild("Plant_RE"),
        ActivePetService = remoteContainer:FindFirstChild("ActivePetService"),
        CookingPotService_RE = remoteContainer:FindFirstChild("CookingPotService_RE"),
        SubmitFoodService_RE = remoteContainer:FindFirstChild("SubmitFoodService_RE")
    }

    local cropsContainer = remoteContainer:FindFirstChild("Crops")
    if cropsContainer then
        remotes.CollectCrops = cropsContainer:FindFirstChild("Collect")
    end

    for name, remote in pairs(remotes) do
        if not remote then
            prettyPrint("warning", "Failed to cache remote -> " .. name)
        end
    end
    
    prettyPrint("success", "Remote caching complete.")
    return remotes
end

local Remotes = initializeRemotes()

--// Secure Remote Firing Utility
local function secureFire(remote, ...)
    if remote then
        local args = {...}
        local secure_call_func = typeof(C["secure_call"]) == "function" and C["secure_call"] or function(f, ...) f(...) end
        secure_call_func(function()
            local safeArgs = {}
            for _, v in ipairs(args) do
                if type(v) == "table" then
                    table.insert(safeArgs, "{table}")
                else
                    table.insert(safeArgs, tostring(v))
                end
            end
            prettyPrint("remote", "Firing:", remote.Name, "with args:", table.concat(safeArgs, ", "))
            remote:FireServer(table.unpack(args))
        end, table.unpack(args))
    end
end

--// Module Caches
local DataService, MutationHandler, InventoryService, ActivePetsService, PetRegistry, SeedData, PetEggData, GearData

pcall(function() DataService = require(ReplicatedStorage.Modules.DataService) end)
pcall(function() MutationHandler = require(ReplicatedStorage.Modules.MutationHandler) end)
pcall(function() InventoryService = require(ReplicatedStorage.Modules.InventoryService) end)
pcall(function() ActivePetsService = require(ReplicatedStorage.Modules.PetServices.ActivePetsService) end)
pcall(function() PetRegistry = require(ReplicatedStorage.Data.PetRegistry) end)
pcall(function() SeedData = require(ReplicatedStorage.Data.SeedData) end)
pcall(function() PetEggData = require(ReplicatedStorage.Data.PetEggData) end)
pcall(function() GearData = require(ReplicatedStorage.Data.GearData) end)

if not DataService then prettyPrint("error", "Failed to load DataService.") end
if not MutationHandler then prettyPrint("warning", "Failed to load MutationHandler.") end
if not InventoryService then prettyPrint("warning", "Failed to load InventoryService.") end
if not ActivePetsService then prettyPrint("warning", "Failed to load ActivePetsService.") end
if not PetRegistry then prettyPrint("warning", "Failed to load PetRegistry.") end
if not SeedData then prettyPrint("warning", "Failed to load SeedData.") end
if not PetEggData then prettyPrint("warning", "Failed to load PetEggData.") end
if not GearData then prettyPrint("warning", "Failed to load GearData.") end
--//----------------------------------------------------------------------------------\\--

--// --- Utility Functions ---
local myFarmPlot -- To be populated by the finder function

local function findMyFarmPlot()
    local FarmFolder = Workspace:WaitForChild("Farm", 20)
    if not FarmFolder then
        prettyPrint("error", "Could not find 'Farm' folder in Workspace.")
        return nil
    end

    local foundPlot
    prettyPrint("info", "Searching for your farm plot...")
    repeat
        if not getgenv().Grow_a_Garden.Enabled then return nil end
        for _, plot in ipairs(FarmFolder:GetChildren()) do
            local importantFolder = plot:FindFirstChild("Important")
            local dataFolder = importantFolder and importantFolder:FindFirstChild("Data")
            local ownerObject = dataFolder and dataFolder:FindFirstChild("Owner")
            
            if ownerObject and ownerObject.Value == LocalPlayer.Name then
                foundPlot = plot
                break
            end
        end
        if not foundPlot then task.wait(3) end
    until foundPlot
    
    prettyPrint("success", "Farm plot found!")
    return foundPlot
end

local function checkItemMutation(toolName, mutationConfig, mutationMethod)
    local hasMutationPrefix = toolName:match("^%[")
    if table.find(mutationConfig, "All_Mutations") then return true end
    if table.find(mutationConfig, "Unmutated") then return not hasMutationPrefix end

    if #mutationConfig > 0 then
        if not hasMutationPrefix then return false end
        local mutationString = toolName:match("^%[([^%]]+)%]")
        if not mutationString then return false end

        local actualMutations = {}
        for mut in mutationString:gmatch("([^, ]+)") do
            table.insert(actualMutations, mut)
        end

        if mutationMethod == "Exact Match" then
            if #actualMutations ~= #mutationConfig then return false end
        end
        
        for _, requiredMutation in ipairs(mutationConfig) do
            if not table.find(actualMutations, requiredMutation) then
                return false
            end
        end
        return true
    end
    return #mutationConfig == 0
end

local function getMyPetUUIDs()
    local equippedPetUUIDs = {}
    local playerData = DataService:GetData()
    if playerData and playerData.PetsData and playerData.PetsData.EquippedPets then
        for _, uuid in ipairs(playerData.PetsData.EquippedPets) do
            -- Store the UUIDs in a format that's easy to look up
            equippedPetUUIDs[string.lower(tostring(uuid):gsub("[{}]", ""))] = true
        end
    end
    return equippedPetUUIDs
end

getgenv().PlayerDataCache = {}
task.spawn(function()
    local Sheckles = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Sheckles")
    while task.wait(1) do
        if getgenv().Grow_a_Garden.Enabled then
            getgenv().PlayerDataCache.Data = DataService:GetData()
            getgenv().PlayerDataCache.Money = tonumber(Sheckles.Value) or 0
        end
    end
end)

-- This list is used by the reward submitter to identify finished food.
local cookedFoodNames = {
    "Burger", "Soup", "HotDog", "Sandwich", "Salad", "Pie",
    "Waffle", "Pizza", "Sushi", "Donut", "IceCream", "Cake",
    "Smoothie", "Porridge", "Spaghetti", "CandyApple", "SweetTea"
}
--//----------------------------------------------------------------------------------\\--

--// --- Optimizations Functions ---
local function optimizeFarms()
    local config = getgenv().Grow_a_Garden
    if not (config.Enabled and config.Optimizations and config.Optimizations.Delete_Other_Farms) then
        return
    end

    if not myFarmPlot then
        prettyPrint("warning", "Optimization: Cannot delete other farms until yours is found.")
        return
    end

    local farmFolder = Workspace:FindFirstChild("Farm")
    if not farmFolder then
        prettyPrint("warning", "Optimization: Farm folder not found.")
        return
    end

    prettyPrint("optimize", "Removing other players' farms to improve performance...")
    local deletedCount = 0
    for _, plot in ipairs(farmFolder:GetChildren()) do
        if plot ~= myFarmPlot then
            pcall(function() plot:Destroy() end)
            deletedCount = deletedCount + 1
        end
    end
    prettyPrint("success", "Optimization complete. Removed", deletedCount, "other farms.")
end

local function optimizePets()
    local config = getgenv().Grow_a_Garden
    if not (config.Enabled and config.Optimizations and config.Optimizations.Delete_Others_Pets) then
        return
    end

    local petsFolder = Workspace:FindFirstChild("PetsPhysical")
    if not petsFolder then return end

    prettyPrint("optimize", "Running hybrid pet cleanup...")
    local myPetUUIDs = getMyPetUUIDs()
    local deletedCount = 0

    for _, petContainer in ipairs(petsFolder:GetChildren()) do
        local shouldDelete = false
        
        local ownerAttribute = petContainer:GetAttribute("OWNER")
        if ownerAttribute then
            if ownerAttribute ~= LocalPlayer.Name then
                shouldDelete = true
            end
        else
            local petUUID = string.lower(petContainer.Name:gsub("[{}]", ""))
            if not myPetUUIDs[petUUID] then
                shouldDelete = true
            end
        end

        if shouldDelete then
            pcall(function() petContainer:Destroy() end)
            deletedCount = deletedCount + 1
        end
    end
    prettyPrint("success", "Optimization complete. Removed", deletedCount, "other pets.")
end

local function createFarmListener()
    local farmFolder = Workspace:FindFirstChild("Farm")
    if not farmFolder then return end

    farmFolder.ChildAdded:Connect(function(newPlot)
        local config = getgenv().Grow_a_Garden
        if config.Enabled and config.Optimizations and config.Optimizations.Delete_Other_Farms then
            if newPlot ~= myFarmPlot then
                prettyPrint("optimize", "Detected and removed a new farm.")
                task.wait() -- Allow game to process before destroying
                pcall(function() newPlot:Destroy() end)
            end
        end
    end)
end

local function createPetListener()
    local petsFolder = Workspace:FindFirstChild("PetsPhysical")
    if not petsFolder then return end

    petsFolder.ChildAdded:Connect(function(petContainer)
        local config = getgenv().Grow_a_Garden
        if not (config.Enabled and config.Optimizations and config.Optimizations.Delete_Others_Pets) then
            return
        end
        
        task.wait() -- Allow the pet's full model to load in
        local shouldDelete = false
        local myPetUUIDs = getMyPetUUIDs() -- Re-fetch in case we equipped a new pet

        local ownerAttribute = petContainer:GetAttribute("OWNER")
        if ownerAttribute then
            if ownerAttribute ~= LocalPlayer.Name then
                shouldDelete = true
            end
        else
            local petUUID = string.lower(petContainer.Name:gsub("[{}]", ""))
            if not myPetUUIDs[petUUID] then
                shouldDelete = true
            end
        end

        if shouldDelete then
            prettyPrint("optimize", "Detected and removed a new pet.")
            pcall(function() petContainer:Destroy() end)
        end
    end)
end
--//----------------------------------------------------------------------------------\\--

--// --- Automation Threads ---
local function createBuyThread(options)
    if not options.dataModule then return end
    task.spawn(function()
        while task.wait(getgenv().Grow_a_Garden[options.intervalKey]) do
            local config = getgenv().Grow_a_Garden
            if config.Enabled and config[options.enabledKey] then
                local playerData = getgenv().PlayerDataCache.Data
                local currentMoney = getgenv().PlayerDataCache.Money

                if playerData and options.getStockTable(playerData) and config[options.listKey] and currentMoney then
                    local function purchase(itemKey, stockInfo)
                        local price = options.getPrice(itemKey)
                        if stockInfo.Stock > 0 and price and currentMoney >= price then
                            secureFire(options.remote, itemKey)
                            prettyPrint("purchase", string.format("Purchasing %s for %d.", itemKey, price))
                            task.wait()
                            currentMoney = getgenv().PlayerDataCache.Money or 0
                        end
                    end

                    if table.find(config[options.listKey], options.allString) then
                        for itemKey, stockInfo in options.iterator(options.getStockTable(playerData)) do
                            purchase(options.getKey(itemKey, stockInfo), stockInfo)
                        end
                    else
                        for _, itemToBuy in ipairs(config[options.listKey]) do
                            local stockInfo = options.getStockInfo(options.getStockTable(playerData), itemToBuy)
                            if stockInfo then
                                purchase(itemToBuy, stockInfo)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function initializeAutomation()
    prettyPrint("info", "Initializing all automation threads...")

    --// --- Auto-Buy Threads ---
    createBuyThread({
        enabledKey = "Auto_Buy_Seeds", listKey = "Seeds_To_Buy", intervalKey = "Seeds_Interval",
        dataModule = SeedData, remote = Remotes.BuySeed, allString = "All_Seeds",
        getStockTable = function(data) return data and data.SeedStock and data.SeedStock.Stocks end,
        iterator = pairs,
        getKey = function(key, _) return key end,
        getStockInfo = function(stock, key) return stock and stock[key] end,
        getPrice = function(key) return SeedData[key] and SeedData[key].Price end
    })

    createBuyThread({
        enabledKey = "Auto_Buy_Eggs", listKey = "Eggs_To_Buy", intervalKey = "Eggs_Interval",
        dataModule = PetEggData, remote = Remotes.BuyEgg, allString = "All_Eggs",
        getStockTable = function(data) return data and data.PetEggStock and data.PetEggStock.Stocks end,
        iterator = ipairs,
        getKey = function(_, stockInfo) return stockInfo.EggName end,
        getStockInfo = function(stock, key) 
            for _, v in ipairs(stock) do if v.EggName == key then return v end end
            return nil
        end,
        getPrice = function(key) return PetEggData[key] and PetEggData[key].Price end
    })

    createBuyThread({
        enabledKey = "Auto_Buy_Gears", listKey = "Gears_To_Buy", intervalKey = "Gears_Interval",
        dataModule = GearData, remote = Remotes.BuyGear, allString = "All_Gears",
        getStockTable = function(data) return data and data.GearStock and data.GearStock.Stocks end,
        iterator = pairs,
        getKey = function(key, _) return key end,
        getStockInfo = function(stock, key) return stock and stock[key] end,
        getPrice = function(key) return GearData[key] and GearData[key].Price end
    })

    --// --- Auto-Harvest Thread ---
    if DataService and MutationHandler then
        task.spawn(function()
            if not myFarmPlot then return prettyPrint("error", "Auto-Harvest: Could not start, farm plot not found.") end
            
            while task.wait(getgenv().Grow_a_Garden.Harvest_Interval) do
                local config = getgenv().Grow_a_Garden
                if config.Enabled and config.Auto_Harvest_Plants then
                    local plantsToCollect = {}
                    
                    for _, prompt in ipairs(myFarmPlot:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt:HasTag("CollectPrompt") then
                            local plantModel = prompt.Parent and prompt.Parent.Parent
                            if plantModel and plantModel:IsA("Model") then
                                local plantName = plantModel.Name
                                local mutationString = MutationHandler:GetMutationsAsString(plantModel) or ""
                                
                                local nameMatch = table.find(config.Plants_To_Harvest, "All_Plants") or table.find(config.Plants_To_Harvest, plantName)
                                
                                local mutationMatch = false
                                if table.find(config.Harvest_Mutations, "All_Mutations") then
                                    mutationMatch = true
                                elseif table.find(config.Harvest_Mutations, "Unmutated") and mutationString == "" then
                                    mutationMatch = true
                                elseif #config.Harvest_Mutations > 0 then
                                    local allMutsFound = true
                                    for _, requiredMut in ipairs(config.Harvest_Mutations) do
                                        if not string.find(mutationString, requiredMut) then
                                            allMutsFound = false
                                            break
                                        end
                                    end
                                    mutationMatch = allMutsFound
                                end
                                
                                if nameMatch and mutationMatch then
                                    table.insert(plantsToCollect, plantModel)
                                end
                            end
                        end
                    end
                    
                    if #plantsToCollect > 0 then
                        prettyPrint("harvest", "Found", #plantsToCollect, "plants to harvest.")
                        secureFire(Remotes.CollectCrops, plantsToCollect)
                    end
                end
            end
        end)
    end

    --// --- Auto-Plant Seeds Thread ---
    if DataService then
        task.spawn(function()
            if not myFarmPlot then return prettyPrint("error", "Auto-Plant: Could not start, farm plot not found.") end
            
            local plantLocationsFolder = myFarmPlot:FindFirstChild("Important"):FindFirstChild("Plant_Locations")
            if not plantLocationsFolder then return prettyPrint("error", "Auto-Plant: Could not find Plant_Locations folder.") end

            local canPlantZones = {}
            for _, part in ipairs(plantLocationsFolder:GetChildren()) do
                if part.Name == "Can_Plant" and part:IsA("BasePart") then
                    table.insert(canPlantZones, part)
                end
            end
            if #canPlantZones == 0 then return prettyPrint("warning", "Auto-Plant: No 'Can_Plant' zones found in plot.") end
            prettyPrint("info", "Auto-Plant: Found " .. #canPlantZones .. " valid planting zones.")

            local originalPosition, lastPlantActionTime, wasTeleportedForPlanting = nil, 0, false

            local centerPoint = myFarmPlot:FindFirstChild("Center_Point")
            if not centerPoint then return prettyPrint("error", "Auto-Plant: Could not find 'Center_Point' in your farm plot.") end
            
            local groundRayParams = RaycastParams.new()
            groundRayParams.FilterDescendantsInstances = {myFarmPlot}
            groundRayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local groundRayResult = Workspace:Raycast(centerPoint.Position, Vector3.new(0, -50, 0), groundRayParams)
            local groundY = groundRayResult and groundRayResult.Position.Y or centerPoint.Position.Y
            local groundCenterCFrame = CFrame.new(centerPoint.Position.X, groundY, centerPoint.Position.Z)

            while task.wait(getgenv().Grow_a_Garden.Planting_Interval) do
                local config = getgenv().Grow_a_Garden
                if config.Enabled and config.Auto_Plant_Seeds then
                    
                    local seedPriority = {}
                    if table.find(config.Seeds_To_Plant, "All_Seeds") then
                        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Seed") then
                                local seedName = tool.Name:match("^(.-)%s*Seed")
                                if seedName and not table.find(seedPriority, seedName) then
                                   table.insert(seedPriority, seedName)
                                end
                            end
                        end
                    else
                        seedPriority = config.Seeds_To_Plant
                    end
                    
                    if #seedPriority > 0 and #canPlantZones > 0 then
                        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local distance = (rootPart.Position - groundCenterCFrame.Position).Magnitude
                            if distance > 75 then
                                if not wasTeleportedForPlanting then
                                    originalPosition = rootPart.CFrame
                                    wasTeleportedForPlanting = true
                                    prettyPrint("action", "Player is too far. Teleporting to farm for planting.")
                                end
                                rootPart.CFrame = groundCenterCFrame * CFrame.new(0, 3, 0)
                            end
                        end

                        prettyPrint("plant", "Starting planting cycle.")
                        for _, zone in ipairs(canPlantZones) do
                            local planted = false
                            for _, seedName in ipairs(seedPriority) do
                                local seedTool
                                local searchPattern = "^" .. seedName .. " Seed"
                                for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") and tool.Name:match(searchPattern) then
                                        seedTool = tool
                                        break
                                    end
                                end

                                if seedTool then
                                    lastPlantActionTime = tick()
                                    LocalPlayer.Character.Humanoid:EquipTool(seedTool)
                                    task.wait()
                                    
                                    local zoneCFrame = zone.CFrame
                                    local zoneSize = zone.Size
                                    local randomPos = zoneCFrame * CFrame.new(
                                        (math.random() - 0.5) * zoneSize.X, 0, (math.random() - 0.5) * zoneSize.Z
                                    )
                                    
                                    secureFire(Remotes.Plant_RE, randomPos.Position, seedName)
                                    task.wait()
                                    planted = true
                                    break
                                end
                            end
                            if not planted then
                                prettyPrint("info", "No available seeds from priority list found in backpack. Ending cycle.")
                                break
                            end
                        end
                        LocalPlayer.Character.Humanoid:UnequipTools()
                        prettyPrint("success", "Planting cycle finished.")
                    end
                    
                    if wasTeleportedForPlanting and (tick() - lastPlantActionTime) > 10 then
                        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and originalPosition then
                            prettyPrint("action", "Planting inactive. Teleporting back to original position.")
                            rootPart.CFrame = originalPosition
                        end
                        wasTeleportedForPlanting, originalPosition = false, nil
                    end
                else
                    if wasTeleportedForPlanting then
                        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and originalPosition then
                             prettyPrint("action", "Auto-Plant disabled. Teleporting back to original position.")
                            rootPart.CFrame = originalPosition
                        end
                        wasTeleportedForPlanting, originalPosition = false, nil
                    end
                end
            end
        end)
    end

    --// --- Auto-Feed Pets Thread ---
    if DataService and PetRegistry and ActivePetsService then
        task.spawn(function()
            prettyPrint("info", "Auto-Feed thread initialized.")
            while task.wait(getgenv().Grow_a_Garden.Feed_Interval) do
                local config = getgenv().Grow_a_Garden
                if config.Enabled and config.Auto_Feed_Pets then
                    local playerData = getgenv().PlayerDataCache.Data
                    if not (playerData and playerData.PetsData and playerData.PetsData.PetInventory and playerData.PetsData.PetInventory.Data) then
                        prettyPrint("warning", "Could not retrieve pet data from cache. Skipping feed cycle.")
                        continue
                    end

                    for uuid, petData in pairs(playerData.PetsData.PetInventory.Data) do
                        local petInfo = PetRegistry.PetList[petData.PetType]
                        if petData.PetData.Hunger and petInfo and petInfo.DefaultHunger and petInfo.DefaultHunger > 0 then
                            local hungerPercent = (petData.PetData.Hunger / petInfo.DefaultHunger) * 100
                            if hungerPercent < config.Feed_Hunger_Threshold then
                                prettyPrint("feed", string.format("Pet %s is hungry (%.1f%%). Finding food.", petData.PetType, hungerPercent))
                                
                                local foodToUse = nil
                                local foodSearchList = table.find(config.Food_To_Feed, "All_Foods") and {".*"} or config.Food_To_Feed

                                for _, foodNamePattern in ipairs(foodSearchList) do
                                    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                                        if tool:IsA("Tool") and not tool.Name:find("Seed") and tool.Name:find("kg") and tool.Name:find(foodNamePattern) then
                                            if checkItemMutation(tool.Name, config.Food_Mutations, config.Food_Mutations_Method) then
                                                foodToUse = tool
                                                break
                                            end
                                        end
                                    end
                                    if foodToUse then break end
                                end

                                if foodToUse then
                                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                                    if humanoid then
                                        prettyPrint("action", "Equipping " .. foodToUse.Name .. " to feed " .. petData.PetType)
                                        humanoid:EquipTool(foodToUse)
                                        task.wait(0.5)
                                        secureFire(Remotes.ActivePetService, "Feed", uuid)
                                        task.wait(0.5)
                                        humanoid:UnequipTools()
                                        prettyPrint("success", "Feed action complete for " .. petData.PetType)
                                        getgenv().PlayerDataCache.Data = DataService:GetData() -- Refresh data
                                        task.wait(1)
                                    end
                                else
                                    prettyPrint("info", "No suitable food found in backpack matching criteria.")
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    --// --- Auto-Sell Thread ---
    if InventoryService then
        task.spawn(function()
            local SellStands = Workspace:WaitForChild("NPCS"):WaitForChild("Sell Stands")
            while task.wait(2) do
                local config = getgenv().Grow_a_Garden
                if config.Enabled and config.Auto_Sell_OnMaxInventory then
                    if InventoryService:IsMaxInventory() then
                        prettyPrint("sell", "Max inventory reached. Selling items...")
                        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and SellStands then
                            local originalCFrame = rootPart.CFrame
                            local sellCFrame = SellStands:GetBoundingBox()
                            rootPart.CFrame = sellCFrame * CFrame.new(0, 5, 5)
                            task.wait(0.5)
                            secureFire(Remotes.SellInventory)
                            task.wait(1)
                            rootPart.CFrame = originalCFrame
                            prettyPrint("success", "Items sold. Returning to original position.")
                        end
                    end
                end
            end
        end)
    end

    --// --- Auto-Move Pets Thread ---
    if DataService then
        task.spawn(function()
            if not myFarmPlot then return prettyPrint("error", "Auto-Move-Pets: Could not start, farm plot not found.") end
            if getgenv().PetMoverArtifacts then
                prettyPrint("info", "Pet Mover: Cleaning up artifacts from previous run...")
                for _, v in ipairs(getgenv().PetMoverArtifacts.Instances or {}) do pcall(function() v:Destroy() end) end
                for _, v in ipairs(getgenv().PetMoverArtifacts.Connections or {}) do pcall(function() v:Disconnect() end) end
            end
            getgenv().PetMoverArtifacts = { Instances = {}, Connections = {} }

            if not getgenv().Grow_a_Garden.Auto_Move_Pets_Into_Middle then return end
            prettyPrint("move", "Auto-Move-Pets thread initializing...")

            local centerPoint = myFarmPlot:FindFirstChild("Center_Point")
            if not centerPoint then return prettyPrint("error", "Pet Mover: Could not find 'Center_Point' in your farm plot.") end

            local groundRayParams = RaycastParams.new()
            groundRayParams.FilterDescendantsInstances = {myFarmPlot}
            groundRayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local groundRayResult = Workspace:Raycast(centerPoint.Position, Vector3.new(0, -50, 0), groundRayParams)
            local groundY = groundRayResult and groundRayResult.Position.Y or centerPoint.Position.Y
            local groundCenterCFrame = CFrame.new(centerPoint.Position.X, groundY, centerPoint.Position.Z)

            local function createLeash(petRoot, leashCenterCFrame)
                task.spawn(function()
                    if not (petRoot and petRoot.Parent) then return end
                    local leashCenterPosition = leashCenterCFrame.Position
                    local connection
                    connection = RunService.Heartbeat:Connect(function()
                        local currentConfig = getgenv().Grow_a_Garden
                        if not (petRoot and petRoot.Parent and currentConfig.Enabled and currentConfig.Auto_Move_Pets_Into_Middle) then
                            pcall(function() connection:Disconnect() end)
                            return
                        end
                        local leashRadiusX = 30
                        local leashRadiusZ = 30
                        local relativePosition = petRoot.Position - leashCenterPosition
                        if math.abs(relativePosition.X) > leashRadiusX or math.abs(relativePosition.Z) > leashRadiusZ then
                            local clampedX = math.clamp(relativePosition.X, -leashRadiusX, leashRadiusX)
                            local clampedZ = math.clamp(relativePosition.Z, -leashRadiusZ, leashRadiusZ)
                            local clampedPosition = leashCenterPosition + Vector3.new(clampedX, relativePosition.Y, clampedZ)
                            petRoot.CFrame = CFrame.new(clampedPosition) * (petRoot.CFrame - petRoot.CFrame.Position)
                        end
                    end)
                    table.insert(getgenv().PetMoverArtifacts.Connections, connection)
                end)
            end

            local playerData = DataService:GetData()
            if not (playerData and playerData.PetsData and playerData.PetsData.EquippedPets) then
                return prettyPrint("warning", "Pet Mover: Could not find equipped pet data.")
            end

            local equippedList = playerData.PetsData.EquippedPets
            if #equippedList == 0 then return prettyPrint("info", "Pet Mover: No pets are currently equipped.") end
            
            local equippedPetUUIDs = {}
            for _, uuid in ipairs(equippedList) do equippedPetUUIDs[string.lower(tostring(uuid):gsub("[{}]", ""))] = true end
            prettyPrint("info", "Pet Mover: Found " .. #equippedList .. " equipped pets. Scanning for spawned models...")

            local petsFolder = Workspace:WaitForChild("PetsPhysical")
            local activePets = {}
            for _, petMoverModel in ipairs(petsFolder:GetChildren()) do
                local childModel = petMoverModel:FindFirstChildOfClass("Model")
                if childModel then
                    local cleanedModelName = string.lower(childModel.Name:gsub("[{}]", ""))
                    if equippedPetUUIDs[cleanedModelName] then
                        local petRoot = childModel:FindFirstChild("RootPart")
                        if petRoot then table.insert(activePets, petRoot) end
                    end
                end
            end

            if #activePets == 0 then return prettyPrint("warning", "Pet Mover: Found equipped pets in data, but none are spawned in the workspace.") end

            prettyPrint("action", "Moving pets to farm center and creating leashes.")
            for i, petRoot in ipairs(activePets) do
                local leashX = 30
                local leashZ = 30
                local angle = i * (2 * math.pi / #activePets)
                local offsetX = math.cos(angle) * (leashX * 0.9)
                local offsetZ = math.sin(angle) * (leashZ * 0.9)
                local targetCFrame = groundCenterCFrame * CFrame.new(offsetX, 0, offsetZ)
                
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {petRoot.Parent.Parent}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local raycastResult = Workspace:Raycast(targetCFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), rayParams)
                local groundPosition = raycastResult and raycastResult.Position or targetCFrame.Position
                
                petRoot.CFrame = CFrame.new(groundPosition)
                createLeash(petRoot, groundCenterCFrame)
            end
            prettyPrint("success", "Finished moving and leashing " .. #activePets .. " pets.")
        end)
    end
end
--//----------------------------------------------------------------------------------\\--

--// --- Script Entry Point ---
prettyPrint("info", "Waiting for game to load...")
repeat task.wait() until game:IsLoaded()
prettyPrint("success", "Game loaded. Waiting for character...")
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

myFarmPlot = findMyFarmPlot()

optimizeFarms()
optimizePets()
createFarmListener()
createPetListener()

initializeAutomation()
--//----------------------------------------------------------------------------------\\--
