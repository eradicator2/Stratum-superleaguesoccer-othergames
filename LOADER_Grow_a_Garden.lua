getgenv().Grow_a_Garden = {
    ["Enabled"] = true,
    ["Script_Debug"] = false, -- For Devs | Console messages for debugging.
    ["Optimizations"] = {
        ["Delete_Other_Farms"] = true, -- Removes other players' farms to reduce lag.
        ["Delete_Others_Pets"] = true, -- Removes other players' pets to reduce lag.
    },

    -- Misc Settings
    ["Auto_Sell_OnMaxInventory"] = false,
    ["Auto_Move_Pets_Into_Middle"] = false,

    -- Buying Settings
    ["Auto_Buy_Seeds"] = false,
    ["Seeds_To_Buy"] = {}, -- {"All_Seeds"} or specific like {"Carrot", "Strawberry"}
    ["Seeds_Interval"] = 0,

    ["Auto_Buy_Eggs"] = false,
    ["Eggs_To_Buy"] = {}, -- {"All_Eggs"} or specific like {"Rare Egg", "Bug Egg"}
    ["Eggs_Interval"] = 0,

    ["Auto_Buy_Gears"] = false,
    ["Gears_To_Buy"] = {}, -- {"All_Gears"} or specific like {"Basic Sprinkler", "Watering Can"}
    ["Gears_Interval"] = 0,
        
    -- Farming Settings
    ["Auto_Harvest_Plants"] = false,
    ["Plants_To_Harvest"] = {"Carrot"}, -- {"All_Plants"} or specific like {"Carrot", "Strawberry"}
    ["Harvest_Mutations"] = {}, -- {"Unmutated"}, {"All_Mutations"} or specific like {"Wet", "Frozen"}
    ["Harvest_Interval"] = 0,

    ["Auto_Plant_Seeds"] = false,
    ["Seeds_To_Plant"] = {"Carrot"}, -- {"Carrot", "Strawberry"} or {"All_Seeds"}
    ["Planting_Interval"] = 0,

    -- Pet Settings
    ["Auto_Feed_Pets"] = false,
    ["Food_To_Feed"] = {}, -- {"All_Foods"} or specific like {"Carrot", "Strawberry"}
    ["Food_Mutations"] = {}, -- {"All_Mutations"}, {"Unmutated"}, or specific like {"Wet", "Moonlit"}
    ["Food_Mutations_Method"] = "", -- "Exact Match" or "Any Match"
    ["Feed_Hunger_Threshold"] = 10, -- Feeds pets if hunger is BELOW this percentage.
    ["Feed_Interval"] = 60,
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/eradicator2/Stratum-superleaguesoccer-othergames/refs/heads/main/Grow_a_Garden.lua"))()
