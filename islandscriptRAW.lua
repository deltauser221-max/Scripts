-- auto0.16 – Refactored variable management
-- Local variables grouped into tables to stay well below Roblox's 200-local limit.
-- Logic identical to original.

-- ============================================================
-- USERNAME WHITELIST – Kicks if not in the list
-- ============================================================

-- AUTH
if not (function()
    local p = game:GetService("Players").LocalPlayer
    local function f()
        local s, r = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/deltauser221-max/Scripts/refs/heads/main/whitelist.txt")
        end)
        if not s then return false end
        local w = {}
        for l in r:gmatch("[^\r\n]+") do
            local n = l:gsub("^%s*(.-)%s*$", "%1")
            if n ~= "" then table.insert(w, n) end
        end
        for _, n in pairs(w) do
            if p.Name == n then return true end
        end
        return false
    end
    if not f() then
        p:Kick("🛡️Last Exploiting Warning🛡️\nWe will ban you for 10 years")
        return false
    end
    return true
end)() then return end

-- ── Load Fluent UI library (bulletproof multi‑URL loader) ────────
local Fluent = loadstring(game:HttpGet(
    --"https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
    -- "https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"
    "https://github.com/StyearX/Fluent-modded/releases/download/1.5.1/FluentPro"
))()

-- ── Services ─────────────────────────────────────────────────
local Services = {
    RunService           = game:GetService("RunService"),
    UserInputService     = game:GetService("UserInputService"),
    ProximityPrompt      = game:GetService("ProximityPromptService")
}

-- ── Remote events ────────────────────────────────────────────
local Remotes = {}
Remotes.meleeHit         = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("meleeHitRemote")
Remotes.attackMob        = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("attackMobRemote")
Remotes.useTool          = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("useToolRemote")
Remotes.collect          = game:GetService("ReplicatedStorage"):WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("ItemCollect"):WaitForChild("collectRemote")
Remotes.dropItem         = game:GetService("ReplicatedStorage"):WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerInventory"):WaitForChild("dropItemRemote")
Remotes.escape           = game:GetService("ReplicatedStorage"):WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("GameResult"):WaitForChild("escapeRemote")
Remotes.LobbyTeleport    = game:GetService("ReplicatedStorage"):WaitForChild("Module"):WaitForChild("ActiveService"):WaitForChild("LobbyTeleport"):WaitForChild("RemoteEvent")
Remotes.RequestOpenChest = game:GetService("ReplicatedStorage"):WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("ChestService"):WaitForChild("RequestOpenEvent")
-- addWoodRemote & matchmaking remotes are set later in their respective sections.

-- ── Collectable item name lists ──────────────────────────────
local Names = {
    Wood        = { "Log", "Wood", "Madeira", "Trunk" },
    Coco        = { "Coconut", "Coco" },
    Egg         = { "Egg", "Ovo" },
    CookedEgg   = { "Cooked Egg" },
    Meat        = { "Meat", "Carne" },
    CookedMeat  = { "Cooked Meat" },
    Stone       = { "Stone", "Rock", "Pedra" },
    BearPelt    = { "Bear Pelt" },
    Feather     = { "Chicken Feather" },
    Crab        = { "Crab" },
    CookedCrab  = { "Cooked Crab" },
    IronOre     = { "Iron Ore" },
    RedBerries  = { "Red Berries" },
    SnakeTooth  = { "Snake Tooth" },
    SpiderWeb   = { "Spider Web" },
    IronIngot   = { "Iron Ingot" }
}

-- ── Script state (all booleans & numbers) ─────────────────────
local State = {
    VIPCutAllTrees        = false,
    VIPBreakAllIronStones = false,
    VIPBreakAllStones     = false,
    VIPBreakAllBushes     = false,
    AutoCutTree           = true,
    TreeRange             = 35,

    AutoCollectAll        = false,
    CollectWood           = false,
    CollectCoco           = false,
    CollectEgg            = false,
    CollectCookedEgg      = false,
    CollectMeat           = false,
    CollectCookedMeat     = false,
    CollectStone          = false,
    CollectBearPelt       = false,
    CollectFeather        = false,
    CollectCrab           = false,
    CollectCookedCrab     = false,
    CollectIronOre        = false,
    CollectRedBerries     = false,
    CollectSnakeTooth     = false,
    CollectSpiderWeb      = false,
    CollectIronIngot      = false,

    AutoKill              = true,
    KillRange             = 35,

    AutoOpenCollect       = false,
    AutoQuestEnabled      = false,
    ESPEnabled            = false,

    NoclipEnabled         = false,
    TPWalkEnabled         = false,
    TPWalkSpeed           = 1,
    JumpPowerEnabled      = false,
    JumpPowerValue        = 40,
    FlyEnabled            = false,
    FlySpeed              = 100,
    -- DoNotEscape 
    DoNotEscape           = false,

    -- Collector limits (mutable from sliders)
    CollectToolLimit      = 1,
    CollectResLimit       = 5,
    CollectFoodLimit      = 5,

    KillAuraDelay         = 1,   -- delay before moving to next entity
}

-- ── UI element references (toggles, sliders, paragraphs) ─────
local Toggles = {}
local GUIRefs = {}

-- ── Constant lists for collection / equipping / dropping ─────
local Lists = {
    Tools     = {
        "Wooden Axe", "Stone Axe", "Iron Axe",
        "Wooden Pickaxe", "Stone Pickaxe", "Iron Pickaxe",
        "Wooden Spear", "Stone Spear", "Iron Spear", "Golden Spear",
        "Slingshot", "Pistol", "Shotgun", "Crossbow",
        "Blue Fire Wand", "Red Fire Wand", "Purple Fire Wand",
        "Vampire Sword", "Vampiric Scimitar", "Flame Blade",
        "Torch", "Fishing Rod"
    },
    Resources = { "Stone", "Wood", "Iron Ore", "Iron Ingot", "Bear Pelt", "Chicken Feather", "Grass", "Plastic Bucket", "Snake Tooth", "Spider Web" },
    Food      = { "Bandage", "Coconut", "Cooked Crab", "Cooked Egg", "Cooked Fish", "Cooked Meat", "Crab", "Egg", "Fish", "Meat", "Red Berries" },

    -- Equip priorities
    AxePrior     = {"Iron Axe", "Stone Axe", "Wooden Axe"},
    PickPrior    = {"Iron Pickaxe", "Stone Pickaxe", "Wooden Pickaxe"},
    SpearPrior   = {"Golden Spear", "Iron Spear", "Stone Spear", "Wooden Spear"},
    GunPrior     = {"Shotgun", "Pistol", "Slingshot", "Crossbow"},
    WandPrior    = {"Purple Fire Wand", "Red Fire Wand", "Blue Fire Wand"},
    SwordPrior   = {"Flame Blade", "Vampiric Scimitar", "Vampire Sword"},
    WeaponPrior  = {"Shotgun", "Pistol", "Slingshot", "Crossbow", "Vampiric Scimitar", "Vampire Sword", "Flame Blade", "Golden Spear", "Iron Spear", "Iron Pickaxe", "Iron Axe", "Stone Spear", "Stone Pickaxe", "Stone Axe", "Wooden Spear", "Wooden Axe", "Wooden Pickaxe"}
}

-- ── Collector state (queues, toggle‑tables, running flags) ───
local Collector = {
    Tool = {
        Toggles = {},
        Queue   = {},
        Running = false,
        LimitSlider = nil
    },
    Res = {
        Toggles = {},
        Queue   = {},
        Running = false,
        LimitSlider = nil
    },
    Food = {
        Toggles = {},
        Queue   = {},
        Running = false,
        LimitSlider = nil
    }
}

-- ── Mobile‑UI / Fly globals ───────────────────────────────────
local Mobile = {
    flyKeyDown = nil,
    flyKeyUp   = nil,
    mobileFlyConnection = nil,
    FLYING     = false
}

-- ── Auto‑build state ─────────────────────────────────────────
local Build = {
    AutoBuildEnabled   = false,
    AutoBuildThread    = nil,
    furnacePrepared    = false,
    boatWoodStoneDone  = false,
    treeCuttingDone    = false,
    ironStoneBreakingDone = false,
    autoOpenCollectDone = false,
    autoQuestDone      = false,

    -- Furnace teleport offsets
    TargetFurnacePart  = "SuckArea",
    OFFSET_X = 5,  OFFSET_Y = 0,  OFFSET_Z = 3,
    ROTATE_X = 0,  ROTATE_Y = 0,  ROTATE_Z = 0
}

-- ── VIP farming parameters ────────────────────────────────────
local VIP = {
    FarmTargetAmount = 25,
    FarmAmountSlider = nil,
    TreeNames    = {"Tree", "Coconut Tree", "Cocunut Tree"},
    IronStoneNames = {"Iron Stone"},
    StoneNames   = {"Stone"},
    BushNames    = {"Bush"}
}

-- ── Helpers ──────────────────────────────────────────────────
Services.ProximityPrompt.PromptButtonHoldBegan:Connect(function(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.spawn(function()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end)
    end)
end)
Services.ProximityPrompt.PromptTriggered:Connect(function(prompt)
    print("[PoC] Prompt Triggered (instant):", prompt:GetFullName())
end)

local function tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

local function shouldCollect(itemName)
    if State.AutoCollectAll then return true end
    if State.CollectWood       and tableContains(Names.Wood,       itemName) then return true end
    if State.CollectCoco       and tableContains(Names.Coco,       itemName) then return true end
    if State.CollectEgg        and tableContains(Names.Egg,        itemName) then return true end
    if State.CollectCookedEgg  and tableContains(Names.CookedEgg,  itemName) then return true end
    if State.CollectMeat       and tableContains(Names.Meat,       itemName) then return true end
    if State.CollectCookedMeat and tableContains(Names.CookedMeat, itemName) then return true end
    if State.CollectStone      and tableContains(Names.Stone,      itemName) then return true end
    if State.CollectBearPelt   and tableContains(Names.BearPelt,   itemName) then return true end
    if State.CollectFeather    and tableContains(Names.Feather,    itemName) then return true end
    if State.CollectCrab       and tableContains(Names.Crab,       itemName) then return true end
    if State.CollectCookedCrab and tableContains(Names.CookedCrab, itemName) then return true end
    if State.CollectIronOre    and tableContains(Names.IronOre,    itemName) then return true end
    if State.CollectRedBerries and tableContains(Names.RedBerries, itemName) then return true end
    if State.CollectSnakeTooth and tableContains(Names.SnakeTooth, itemName) then return true end
    if State.CollectSpiderWeb  and tableContains(Names.SpiderWeb,  itemName) then return true end
    if State.CollectIronIngot  and tableContains(Names.IronIngot,  itemName) then return true end
    return false
end

local function getCharacter()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    return nil
end

local function getGameFolder(name)
    local gameFolder = workspace:FindFirstChild("Game")
    if gameFolder then
        return gameFolder:FindFirstChild(name)
    end
    return nil
end

local function isBagFull()
    local success, isFull = pcall(function()
        local label = game:GetService("Players").LocalPlayer.PlayerGui["99Backpack"].bg.BackpackSlot.BagButton.BagCap
        local text = label.Text
        local current, max = text:match("(%d+)%s*/%s*(%d+)")
        if current and max then
            return tonumber(current) >= tonumber(max)
        end
        return false
    end)
    return success and isFull
end

local function notify(title, content, duration)
    Fluent:Notify({
        Title    = title,
        Content  = content,
        Duration = duration or 2,
    })
end

-- ================================================================
-- CREATE WINDOW
-- ================================================================
local Window = Fluent:CreateWindow({
    Title       = "MrBeast Island Escape",
    SubTitle    = "Developed By: The Scripter",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(520, 240),
    Acrylic     = false,
    Theme       = "Neon Purple",
    MinimizeKey = Enum.KeyCode.LeftAlt,
})

local Tabs = {
    VIP            = Window:AddTab({ Title = "Auto Cut/Break",    Icon = "sword"             }),
    Collect        = Window:AddTab({ Title = "Collect",      Icon = "archive"           }),
    Chests         = Window:AddTab({ Title = "Chests",       Icon = "inbox"             }),
    Teleport       = Window:AddTab({ Title = "Teleport",     Icon = "map-pin"           }),
    Player         = Window:AddTab({ Title = "Player",       Icon = "user-cog"          }),
    Farm           = Window:AddTab({ Title = "Farm",         Icon = "axe"               }),
    Combat         = Window:AddTab({ Title = "Combat",       Icon = "sword"             }),
    ESP            = Window:AddTab({ Title = "Esp",          Icon = "eye"               }),
    Settings       = Window:AddTab({ Title = "Settings",     Icon = "settings"          }),
}

-- ================================================================
-- Collect TAB
-- ================================================================
Toggles.CollectWood = Tabs.Collect:AddToggle("CollectWood", {
    Title    = "Collect Wood", Default  = State.CollectWood,
    Callback = function(enabled) State.CollectWood = enabled end,
})

Toggles.CollectStone = Tabs.Collect:AddToggle("CollectStone", {
    Title    = "Collect Stone", Default  = State.CollectStone,
    Callback = function(enabled) State.CollectStone = enabled end,
})

Toggles.CollectIronOre = Tabs.Collect:AddToggle("CollectIronOre", {
    Title    = "Collect Iron Ore", Default  = State.CollectIronOre,
    Callback = function(enabled) State.CollectIronOre = enabled end,
})

Toggles.CollectIronIngot = Tabs.Collect:AddToggle("CollectIronIngot", {
    Title    = "Collect Iron Ingot", Default  = State.CollectIronIngot,
    Callback = function(enabled) State.CollectIronIngot = enabled end,
})

Tabs.Collect:AddToggle("CollectCoco", { Title = "Collect Coconut", Default = State.CollectCoco, Callback = function(e) State.CollectCoco = e end })
Tabs.Collect:AddToggle("CollectEgg", { Title = "Collect Egg", Default = State.CollectEgg, Callback = function(e) State.CollectEgg = e end })
Tabs.Collect:AddToggle("CollectCookedEgg", { Title = "Collect Cooked Egg", Default = State.CollectCookedEgg, Callback = function(e) State.CollectCookedEgg = e end })
Tabs.Collect:AddToggle("CollectMeat", { Title = "Collect Meat", Default = State.CollectMeat, Callback = function(e) State.CollectMeat = e end })
Tabs.Collect:AddToggle("CollectCookedMeat", { Title = "Collect Cooked Meat", Default = State.CollectCookedMeat, Callback = function(e) State.CollectCookedMeat = e end })
Tabs.Collect:AddToggle("CollectBearPelt", { Title = "Collect Bear Pelt", Default = State.CollectBearPelt, Callback = function(e) State.CollectBearPelt = e end })
Tabs.Collect:AddToggle("CollectFeather", { Title = "Collect Chicken Feather", Default = State.CollectFeather, Callback = function(e) State.CollectFeather = e end })
Tabs.Collect:AddToggle("CollectCrab", { Title = "Collect Crab", Default = State.CollectCrab, Callback = function(e) State.CollectCrab = e end })
Tabs.Collect:AddToggle("CollectCookedCrab", { Title = "Collect Cooked Crab", Default = State.CollectCookedCrab, Callback = function(e) State.CollectCookedCrab = e end })
Tabs.Collect:AddToggle("CollectRedBerries", { Title = "Collect Red Berries", Default = State.CollectRedBerries, Callback = function(e) State.CollectRedBerries = e end })
Tabs.Collect:AddToggle("CollectSnakeTooth", { Title = "Collect Snake Tooth", Default = State.CollectSnakeTooth, Callback = function(e) State.CollectSnakeTooth = e end })
Tabs.Collect:AddToggle("CollectSpiderWeb", { Title = "Collect Spider Web", Default = State.CollectSpiderWeb, Callback = function(e) State.CollectSpiderWeb = e end })

Tabs.Collect:AddParagraph({ Title = "All Item Collection", Content = "Disable 'Collect ALL' to use specific filters." })
Tabs.Collect:AddToggle("AutoCollectAll", { Title = "Auto Collect All Items", Default = State.AutoCollectAll, Callback = function(e) State.AutoCollectAll = e end })

task.spawn(function()
    while true do
        task.wait(0.15)
        if (State.AutoCollectAll or State.CollectWood or State.CollectCoco or State.CollectEgg or State.CollectCookedEgg or State.CollectMeat or State.CollectCookedMeat or State.CollectStone
            or State.CollectBearPelt or State.CollectFeather or State.CollectCrab or State.CollectCookedCrab or State.CollectIronOre
            or State.CollectRedBerries or State.CollectSnakeTooth or State.CollectSpiderWeb or State.CollectIronIngot) and not isBagFull() then
            local char = getCharacter()
            local itemFolder = getGameFolder("DroppedItems")
            if char and itemFolder then
                for _, item in pairs(itemFolder:GetChildren()) do
                    if item:IsA("Model") and not isBagFull() then
                        local part = item:FindFirstChildWhichIsA("BasePart", true)
                        if part and shouldCollect(item.Name) then
                            local savedCFrame = char.HumanoidRootPart.CFrame
                            local cam = workspace.CurrentCamera
                            cam.CameraType = Enum.CameraType.Scriptable
                            char.HumanoidRootPart.CFrame = part.CFrame
                            task.wait(0.2)
                            Remotes.collect:FireServer(item)
                            task.wait(0.1)
                            char.HumanoidRootPart.CFrame = savedCFrame
                            cam.CameraType = Enum.CameraType.Custom
                        end
                    end
                    if isBagFull() then task.wait(4) end
                end
            end
        end
    end
end)

-- ================================================================
-- FARM TAB
-- ================================================================
Tabs.Farm:AddToggle("AutoCut", {
    Title = "Auto Cut Trees & Break Stones", Default = State.AutoCutTree,
    Callback = function(enabled)
        State.AutoCutTree = enabled
        task.spawn(function()
            while State.AutoCutTree do
                task.wait(0.001)
                local char = getCharacter()
                local staticFolder = getGameFolder("Static")
                if char and staticFolder then
                    for _, obj in pairs(staticFolder:GetChildren()) do
                        if obj.Name == "Coconut Tree" or obj.Name == "Tree" or obj.Name == "Iron Stone" or obj.Name == "Stone" or obj.Name == "Bush" then
                            local part = obj:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                                if dist <= State.TreeRange + 5 then
                                    Remotes.meleeHit:FireServer({}, {obj})
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
})

-- ================================================================
-- COMBAT TAB
-- ================================================================
Tabs.Combat:AddToggle("AutoKill", {
    Title = "Kill Aura Animals", Default = State.AutoKill,
    Callback = function(enabled)
        State.AutoKill = enabled
        task.spawn(function()
            while State.AutoKill do
                task.wait(0.06)
                local char = getCharacter()
                local entitiesFolder = getGameFolder("Entities")
                if char and entitiesFolder then
                    for _, entity in pairs(entitiesFolder:GetChildren()) do
                        if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") and entity:FindFirstChild("Humanoid") and entity.Humanoid.Health > 0 then
                            local dist = (char.HumanoidRootPart.Position - entity.HumanoidRootPart.Position).Magnitude
                            if dist <= State.KillRange then
                                Remotes.meleeHit:FireServer({entity}, {})
                                Remotes.attackMob:FireServer(entity)
                                -- Remotes.useTool:FireServer()
                            end
                        end
                    end
                end
            end
        end)
    end,
})

-- ================================================================
-- ESP TAB
-- ================================================================
Tabs.ESP:AddToggle("ESPAnimals", {
    Title = "Enable Entity ESP", Default = State.ESPEnabled,
    Callback = function(enabled)
        State.ESPEnabled = enabled
        if not State.ESPEnabled then
            local entitiesFolder = getGameFolder("Entities")
            if entitiesFolder then
                for _, entity in pairs(entitiesFolder:GetChildren()) do
                    local existing = entity:FindFirstChild("ESPHighlight")
                    if existing then existing:Destroy() end
                end
            end
        end
    end,
})

task.spawn(function()
    while true do
        task.wait(1)
        if State.ESPEnabled then
            local entitiesFolder = getGameFolder("Entities")
            if entitiesFolder then
                for _, entity in pairs(entitiesFolder:GetChildren()) do
                    if entity:IsA("Model") and not entity:FindFirstChild("ESPHighlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.FillColor = Color3.fromRGB(255, 0, 135)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Parent = entity
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- TELEPORT TAB
-- ================================================================
Tabs.Teleport:AddButton({
    Title = "🔥 TP to Campfire",
    Callback = function()
        local char = getCharacter()
        if not char then return end
        local campfire = workspace:FindFirstChild("Campfire", true) or workspace:FindFirstChild("Campfire_Construct", true)
        if campfire then
            local part = campfire:FindFirstChildWhichIsA("BasePart", true) or (campfire:IsA("Model") and campfire.PrimaryPart)
            if part then
                char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                notify("Success", "Teleported to the campfire!", 2)
            end
        else
            notify("Error", "Campfire not found on the map.", 2)
        end
    end,
})

local function teleportToNamedObject(objectName)
    local char = getCharacter()
    if not char then return end
    local tilesFolder = getGameFolder("Tiles")
    if not tilesFolder then notify("Error", objectName .. " not found. Wait for the map to generate it.", 4); return end
    local obj = tilesFolder:FindFirstChild(objectName, true)
    if obj and obj:IsA("Model") then
        local part = obj:FindFirstChildWhichIsA("BasePart", true) or obj.PrimaryPart
        if part then
            char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            notify("Success", "Teleported to " .. objectName .. "!", 3)
        end
    else
        notify("Error", objectName .. " not found. Wait for the map to generate it.", 4)
    end
end

Tabs.Teleport:AddButton({ Title = "🥛 TP to Plastic Bucket", Callback = function() teleportToNamedObject("Plastic Bucket") end })
Tabs.Teleport:AddButton({ Title = "📻 TP to Radio", Callback = function() teleportToNamedObject("Radio") end })
Tabs.Teleport:AddButton({ Title = "🧭 TP to Compass", Callback = function() teleportToNamedObject("Compass") end })
Tabs.Teleport:AddButton({ Title = "🗺️ TP to Map", Callback = function() teleportToNamedObject("Map") end })

-- ================================================================
-- PLAYER TAB
-- ================================================================
function applyJumpPower()
    local char = getCharacter()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if State.JumpPowerEnabled then
        pcall(function()
            if humanoid.UseJumpPower then humanoid.JumpPower = State.JumpPowerValue else humanoid.JumpHeight = State.JumpPowerValue end
        end)
    else
        pcall(function() humanoid.JumpPower = 50 end)
        pcall(function() humanoid.JumpHeight = 7.2 end)
    end
end

local function stopFly()
    Mobile.FLYING = false
    if Mobile.flyKeyDown then Mobile.flyKeyDown:Disconnect() Mobile.flyKeyDown = nil end
    if Mobile.flyKeyUp then Mobile.flyKeyUp:Disconnect() Mobile.flyKeyUp = nil end
    if Mobile.mobileFlyConnection then Mobile.mobileFlyConnection:Disconnect() Mobile.mobileFlyConnection = nil end
    local char = getCharacter()
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
            if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        end
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local function startFly()
    stopFly()
    Mobile.FLYING = true
    local char = getCharacter()
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    humanoid.PlatformStand = true
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.Name = "FlyGyro"; BodyGyro.P = 9e4; BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BodyGyro.CFrame = hrp.CFrame; BodyGyro.Parent = hrp
    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Name = "FlyVelocity"; BodyVelocity.Velocity = Vector3.new(0, 0, 0); BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9); BodyVelocity.Parent = hrp
    local isMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
    if isMobile then
        local controlModule = nil
        pcall(function() controlModule = require(game.Players.LocalPlayer.PlayerScripts.PlayerModule:WaitForChild("ControlModule")) end)
        Mobile.mobileFlyConnection = Services.RunService.RenderStepped:Connect(function()
            if not Mobile.FLYING then return end
            char = getCharacter(); if not char then return end
            hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            BodyGyro.CFrame = workspace.CurrentCamera.CFrame; BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            if controlModule then
                local direction = controlModule:GetMoveVector()
                local cam = workspace.CurrentCamera
                if direction.X > 0 then BodyVelocity.Velocity = BodyVelocity.Velocity + cam.CFrame.RightVector * (direction.X * State.FlySpeed) end
                if direction.X < 0 then BodyVelocity.Velocity = BodyVelocity.Velocity + cam.CFrame.RightVector * (direction.X * State.FlySpeed) end
                if direction.Z > 0 then BodyVelocity.Velocity = BodyVelocity.Velocity - cam.CFrame.LookVector * (direction.Z * State.FlySpeed) end
                if direction.Z < 0 then BodyVelocity.Velocity = BodyVelocity.Velocity - cam.CFrame.LookVector * (direction.Z * State.FlySpeed) end
            end
        end)
    else
        local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local SPEED = 0
        Mobile.flyKeyDown = Services.UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
            elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 1
            elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = -1 end
        end)
        Mobile.flyKeyUp = Services.UserInputService.InputEnded:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0 end
        end)
        task.spawn(function()
            repeat task.wait()
                local camera = workspace.CurrentCamera
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then SPEED = State.FlySpeed
                elseif SPEED ~= 0 then SPEED = 0 end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BodyVelocity.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BodyVelocity.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                else
                    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                BodyGyro.CFrame = camera.CFrame
            until not Mobile.FLYING
        end)
    end
end

Tabs.Player:AddToggle("Noclip", { Title = "Noclip", Default = State.NoclipEnabled, Callback = function(e) State.NoclipEnabled = e end })
Tabs.Player:AddToggle("TPWalk", { Title = "TP Walk", Default = State.TPWalkEnabled, Callback = function(e) State.TPWalkEnabled = e end })
Tabs.Player:AddSlider("TPWalkSpeed", { Title = "TP Walk Speed", Default = State.TPWalkSpeed, Min = 0.2, Max = 10, Rounding = 2, Callback = function(v) State.TPWalkSpeed = v end })
Tabs.Player:AddToggle("JumpPowerToggle", { Title = "Enable Jump Power", Default = State.JumpPowerEnabled, Callback = function(e) State.JumpPowerEnabled = e; applyJumpPower() end })
Tabs.Player:AddSlider("JumpPowerSlider", { Title = "Jump Power / Height", Default = State.JumpPowerValue, Min = 0, Max = 300, Rounding = 0, Callback = function(v) State.JumpPowerValue = v; applyJumpPower() end })
Tabs.Player:AddToggle("FlyToggle", { Title = "Fly", Description = "PC: WASD + QE. Mobile: Joystick.", Default = false, Callback = function(e) State.FlyEnabled = e; if e then startFly() else stopFly() end end })
Tabs.Player:AddSlider("FlySpeedSlider", { Title = "Fly Speed", Default = 100, Min = 10, Max = 300, Rounding = 0, Callback = function(v) State.FlySpeed = v end })


game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    local humanoid = newChar:WaitForChild("Humanoid", 5)
    if humanoid and State.JumpPowerEnabled then
        pcall(function()
            if humanoid.UseJumpPower then humanoid.JumpPower = State.JumpPowerValue else humanoid.JumpHeight = State.JumpPowerValue end
        end)
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if State.FlyEnabled then task.wait(1); startFly() end
end)

Services.RunService.Stepped:Connect(function()
    local char = getCharacter()
    if not char then return end
    if State.NoclipEnabled then
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
    if State.TPWalkEnabled then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * State.TPWalkSpeed)
        end
    end
end)

applyJumpPower()

-- ================================================================
-- CHESTS TAB
-- ================================================================
Toggles.AutoOpenCollect = Tabs.Chests:AddToggle("AutoOpenCollect", {
    Title = "Auto Open & Collect Chests", Description = "Teleports to chests, opens them, and collects ALL drops.", Default = false,
    Callback = function(enabled)
        State.AutoOpenCollect = enabled
        if enabled then
            local startPos = getCharacter() and getCharacter().HumanoidRootPart.CFrame
            Toggles.BestWeapon:SetValue(true)
            task.spawn(function()
                local visited = {}
                while State.AutoOpenCollect do
                    task.wait(1)
                    local chestFolder = getGameFolder("Chest")
                    if chestFolder then
                        local children = chestFolder:GetChildren()
                        local totalChests = #children
                        for _, chest in pairs(children) do
                            if not State.AutoOpenCollect then break end
                            if visited[chest] then continue end
                            local promptPart = chest:FindFirstChild("promptPart", true)
                            local part = promptPart or chest:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local char = getCharacter()
                                if char then
                                    char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                                    task.wait(0.5)
                                    Remotes.RequestOpenChest:FireServer(chest)
                                    visited[chest] = true
                                    local dropsFound = false
                                    for _ = 1, 15 do
                                        task.wait(0.2)
                                        local dropFolder = getGameFolder("DroppedItems")
                                        if dropFolder then
                                            for _, item in pairs(dropFolder:GetChildren()) do
                                                if item:IsA("Model") then
                                                    local itemPart = item:FindFirstChildWhichIsA("BasePart", true)
                                                    if itemPart and (itemPart.Position - part.Position).Magnitude < 15 then
                                                        dropsFound = true; break
                                                    end
                                                end
                                            end
                                        end
                                        if dropsFound then break end
                                    end
                                    if dropsFound then
                                        local dropFolder = getGameFolder("DroppedItems")
                                        if dropFolder then
                                            for _, item in pairs(dropFolder:GetChildren()) do
                                                if item:IsA("Model") then
                                                    local itemPart = item:FindFirstChildWhichIsA("BasePart", true)
                                                    if itemPart and (itemPart.Position - part.Position).Magnitude < 15 then
                                                        local savedCFrame = char.HumanoidRootPart.CFrame
                                                        local cam = workspace.CurrentCamera
                                                        cam.CameraType = Enum.CameraType.Scriptable
                                                        char.HumanoidRootPart.CFrame = itemPart.CFrame
                                                        task.wait(0.1)
                                                        Remotes.collect:FireServer(item)
                                                        task.wait(0.1)
                                                        Remotes.collect:FireServer(item)
                                                        task.wait(0.1)
                                                        char.HumanoidRootPart.CFrame = savedCFrame
                                                        cam.CameraType = Enum.CameraType.Custom
                                                        Toggles.BestWeapon:SetValue(true)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    task.wait(1)
                                end
                            end
                        end
                        if #visited >= totalChests and totalChests > 0 then break end
                    end
                end
                if startPos and getCharacter() then getCharacter().HumanoidRootPart.CFrame = startPos end
                Toggles.BestWeapon:SetValue(false)
            end)
        end
    end,
})


-- ============================================================
-- USERNAME WHITELIST – Kicks if not in the list
-- ============================================================

-- AUTH
if not (function()
    local p = game:GetService("Players").LocalPlayer
    local function f()
        local s, r = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/deltauser221-max/Scripts/refs/heads/main/whitelist.txt")
        end)
        if not s then return false end
        local w = {}
        for l in r:gmatch("[^\r\n]+") do
            local n = l:gsub("^%s*(.-)%s*$", "%1")
            if n ~= "" then table.insert(w, n) end
        end
        for _, n in pairs(w) do
            if p.Name == n then return true end
        end
        return false
    end
    if not f() then
        p:Kick("🛡️Last Exploiting Warning🛡️\nWe will ban you for 10 years.")
        return false
    end
    return true
end)() then return end

-- ================================================================
-- VIP TAB
-- ================================================================

VIP.FarmAmountSlider = Tabs.VIP:AddSlider("FarmAmountSlider", {
    Title = "Target Amount", 
    Description = "Auto-stops after cutting/breaking this amount.", 
    Default = 25, Min = 1, Max = 200, Rounding = 0, 
    Callback = function(v) VIP.FarmTargetAmount = v end
})

Tabs.VIP:AddParagraph({ Title = "Farming Controls", Content = "Toggles auto-shutdown when the target is reached or the map is cleared." })

local function isTarget(obj, nameList)
    if not obj or not obj.Name then return false end
    for _, baseName in ipairs(nameList) do
        if obj.Name == baseName or obj.Name == baseName .. " " or obj.Name == baseName .. "  " then
            return true
        end
    end
    return false
end

local function runFarmLoop(nameList, toggleObj, equipToggleObj)
    if not toggleObj or not toggleObj.Value then return end

    local targetAmount = VIP.FarmTargetAmount
    local successCount = 0
    local countedModels = {}   -- prevent double‑counting the same object

    local startPos = nil
    local char = getCharacter()
    if char and char:FindFirstChild("HumanoidRootPart") then
        startPos = char.HumanoidRootPart.CFrame
    end

    if equipToggleObj then pcall(function() equipToggleObj:SetValue(true) end) end

    task.spawn(function()
        while toggleObj.Value do
            if successCount >= targetAmount then break end

            task.wait(0.15)
            local staticFolder = getGameFolder("Static")
            if not staticFolder then continue end

            local targetFound = false

            -- ── ADDED: Gather all valid, uncounted candidates ──
            local candidates = {}
            for _, obj in pairs(staticFolder:GetChildren()) do
                if isTarget(obj, nameList) and not countedModels[obj] then
                    table.insert(candidates, obj)
                end
            end

            if #candidates > 0 then
                -- Determine reference point for distance sorting
                local refPoint = nil
                local spawnLoc = workspace.Game and workspace.Game.Tiles and
                                 workspace.Game.Tiles:FindFirstChild("Basic Block") and
                                 workspace.Game.Tiles["Basic Block"]:FindFirstChild("SpawnLocation")
                if spawnLoc and spawnLoc:IsA("BasePart") then
                    refPoint = spawnLoc.Position
                else
                    -- Fallback: use character's current position (if available)
                    local charNow = getCharacter()
                    if charNow and charNow:FindFirstChild("HumanoidRootPart") then
                        refPoint = charNow.HumanoidRootPart.Position
                    end
                end
                if refPoint then
                    table.sort(candidates, function(a, b)
                        local partA = a:FindFirstChildWhichIsA("BasePart", true)
                        local partB = b:FindFirstChildWhichIsA("BasePart", true)
                        local posA = partA and partA.Position or a:GetPivot().Position
                        local posB = partB and partB.Position or b:GetPivot().Position
                        return (posA - refPoint).Magnitude < (posB - refPoint).Magnitude
                    end)
                end

                -- Pick the nearest (first after sorting) and process exactly ONE object
                local obj = candidates[1]
                if obj and not countedModels[obj] then
                    targetFound = true
                    local part = obj:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        char = getCharacter()
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 5, 0)
                            end)
                            task.wait(0.2)

                            local hpCheckSuccess = false
                            local attempts = 0

                            while toggleObj.Value do
                                if not obj.Parent then break end

                                local currentHP = tonumber(obj:GetAttribute("hp"))
                                if currentHP and currentHP <= 0 then
                                    hpCheckSuccess = true
                                    break
                                end

                                pcall(function() Remotes.meleeHit:FireServer({}, {obj}) end)
                                attempts = attempts + 1

                                if attempts > 120 then break end
                                task.wait(0.05)
                            end

                            if hpCheckSuccess then
                                successCount = successCount + 1
                                countedModels[obj] = true
                            end

                            task.wait(0.05)
                        end
                    end
                end
            end
            -- ── END OF ADDED SORTING LOGIC ──

            if not targetFound then
                task.wait(1)
                local foundAny = false
                for _, obj in pairs(staticFolder:GetChildren()) do
                    if isTarget(obj, nameList) then foundAny = true; break end
                end
                if not foundAny then break end
            end
        end

        char = getCharacter()

        if startPos and char and char:FindFirstChild("HumanoidRootPart") then
            pcall(function() char.HumanoidRootPart.CFrame = startPos end)
        end

        if equipToggleObj then pcall(function() equipToggleObj:SetValue(false) end) end

        if toggleObj.Value then
            pcall(function() toggleObj:SetValue(false) end)
        end
    end)
end


Toggles.VIPCutAllTrees = Tabs.VIP:AddToggle("VIPCutAllTrees", {
    Title = "Cut All Trees", Default = false,
    Callback = function(enabled)
        if enabled then runFarmLoop(VIP.TreeNames, Toggles.VIPCutAllTrees, Toggles.BestAxe) end
    end,
})

Toggles.VIPBreakAllIronStones = Tabs.VIP:AddToggle("VIPBreakAllIronStones", {
    Title = "Break All Iron Stones", Default = false,
    Callback = function(enabled)
        if enabled then runFarmLoop(VIP.IronStoneNames, Toggles.VIPBreakAllIronStones, Toggles.BestPickaxe) end
    end,
})

Toggles.VIPBreakAllStones = Tabs.VIP:AddToggle("VIPBreakAllStones", {
    Title = "Break All Stones", Default = false,
    Callback = function(enabled)
        if enabled then runFarmLoop(VIP.StoneNames, Toggles.VIPBreakAllStones, Toggles.BestPickaxe) end
    end,
})

Toggles.VIPBushes = Tabs.VIP:AddToggle("VIPBreakAllBushes", {
    Title = "Break All Bushes", Default = false,
    Callback = function(enabled)
        if enabled then runFarmLoop(VIP.BushNames, Toggles.VIPBushes, Toggles.BestPickaxe) end
    end,
})

-- ================================================================
-- SETTINGS & MOBILE TOGGLE
-- ================================================================
Tabs.Settings:AddParagraph({ Title = "PC -> Menu Show/Hide Key: Alt\nMobile -> Use the floating 'W' button to Hide/Show." })

local CoreGui = game:GetService("CoreGui")
local existing = CoreGui:FindFirstChild("MobileButtonUI")
if existing then existing:Destroy() end

local mobileGui = Instance.new("ScreenGui"); mobileGui.Name = "MobileButtonUI"; mobileGui.Parent = CoreGui
local toggleBtn = Instance.new("TextButton"); toggleBtn.Name = "Toggle"; toggleBtn.Parent = mobileGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0); toggleBtn.Position = UDim2.new(0.5, -25, 0.1, 0)
toggleBtn.Size = UDim2.new(0, 50, 0, 50); toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.Text = "G"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0); toggleBtn.TextSize = 35; toggleBtn.Active = true; toggleBtn.Draggable = true

local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1, 0); corner.Parent = toggleBtn
local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0, 255, 0); stroke.Thickness = 1.5; stroke.Parent = toggleBtn

local fluentScreenGui
task.spawn(function()
    while not fluentScreenGui do
        task.wait(0.5)
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, descendant in pairs(gui:GetDescendants()) do
                    if descendant:IsA("TextLabel") and string.find(descendant.Text, "MrBeast Island Escape") then
                        fluentScreenGui = gui; break
                    end
                end
            end
            if fluentScreenGui then break end
        end
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if fluentScreenGui then
        for _, child in pairs(fluentScreenGui:GetChildren()) do
            if child:IsA("Frame") or child:IsA("CanvasGroup") then child.Visible = not child.Visible end
        end
    end
end)

-- =============================================================================
--                                   UI Settings
-- =============================================================================
local UISettingsTab = Window:AddTab({ Title = "UI Settings", Icon = "lucide/settings-2" })

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentCustom/Settings")
InterfaceManager:BuildInterfaceSection(UISettingsTab)

notify("Script Loaded", "Enjoy VIP Features", 2)

-- ============================================================
-- USERNAME WHITELIST – Kicks if not in the list
-- ============================================================

-- AUTH
if not (function()
    local p = game:GetService("Players").LocalPlayer
    local function f()
        local s, r = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/deltauser221-max/Scripts/refs/heads/main/whitelist.txt")
        end)
        if not s then return false end
        local w = {}
        for l in r:gmatch("[^\r\n]+") do
            local n = l:gsub("^%s*(.-)%s*$", "%1")
            if n ~= "" then table.insert(w, n) end
        end
        for _, n in pairs(w) do
            if p.Name == n then return true end
        end
        return false
    end
    if not f() then
        p:Kick("🛡️Last Exploiting Warning🛡️\nWe will ban you for 10 years.")
        return false
    end
    return true
end)() then return end
