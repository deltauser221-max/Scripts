-- claude v2
-- ================================================================
-- Escape from Mr. Beast Island  –  Clean Deobfuscated Script
-- All encrypted strings decoded, dead code removed,
-- variables renamed, loops rewritten idiomatically.
-- Behaviour is identical to the original obfuscated version.
-- ================================================================

-- ── Load Fluent UI library ───────────────────────────────────────
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
-- Game services --------------------------------------------------------
local RunService = game:GetService("RunService")

-- ── Remote Events ────────────────────────────────────────────────
local meleeHitRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Events")
    :WaitForChild("meleeHitRemote")

local collectRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Engine")
    :WaitForChild("Service")
    :WaitForChild("ItemCollect")
    :WaitForChild("collectRemote")

-- ── Collectable item name lists ──────────────────────────────────
local WOOD_NAMES          = { "Log", "Wood", "Madeira", "Trunk" }
local COCO_NAMES          = { "Coconut", "Coco" }
local EGG_NAMES           = { "Egg", "Ovo" }
local COOKEDEGG_NAMES     = { "Cooked Egg" }
local MEAT_NAMES          = { "Meat", "Carne",  }
local COOKEDMEAT_NAMES    = { "Cooked Meat"  }
local STONE_NAMES         = { "Stone", "Rock", "Pedra" }
local BEARPELT_NAMES      = { "Bear Pelt" }
local FEATHER_NAMES       = { "Chicken Feather" }
local CRAB_NAMES          = { "Crab" }
local COOKEDCRAB_NAMES    = { "Cooked Crab" }
local IRONORE_NAMES       = { "Iron Ore" }
local REDBERRIES_NAMES    = { "Red Berries" }
local SNAKETOOTH_NAMES    = { "Snake Tooth" }
local SPIDERWEB_NAMES     = { "Spider Web" }
local IRONIGNOT_NAMES     = { "Iron Ignot" }



-- ── Script state ─────────────────────────────────────────────────
local AutoCutTree    = false
local TreeRange      = 15

local AutoCollectAll      = false
local CollectWood         = false
local CollectCoco         = false
local CollectEgg          = false
local CollectCookedEgg    = false
local CollectMeat         = false
local CollectCookedMeat   = false
local CollectStone        = false
local CollectBearPelt     = false
local CollectFeather      = false
local CollectCrab         = false
local CollectCookedCrab   = false
local CollectIronOre      = false
local CollectRedBerries   = false
local CollectSnakeTooth   = false
local CollectSpiderWeb    = false
local CollectIronIgnot    = false


local AutoKill       = false
local KillRange      = 15

local AutoFarmChests = false
local ChestWaitTime  = 3

local ESPEnabled     = false

local NoclipEnabled    = false
local TPWalkEnabled    = false
local TPWalkSpeed      = 3
local JumpPowerEnabled = false
local JumpPowerValue   = 40

-- ── Helpers ──────────────────────────────────────────────────────
local function tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

local function shouldCollect(itemName)
    if AutoCollectAll then return true end
    if CollectWood       and tableContains(WOOD_NAMES,       itemName) then return true end
    if CollectCoco       and tableContains(COCO_NAMES,       itemName) then return true end
    if CollectEgg        and tableContains(EGG_NAMES,        itemName) then return true end
    if CollectCookedEgg  and tableContains(COOKEDEGG_NAMES,  itemName) then return true end
    if CollectMeat       and tableContains(MEAT_NAMES,       itemName) then return true end
    if CollectCookedMeat and tableContains(COOKEDMEAT_NAMES, itemName) then return true end
    if CollectStone      and tableContains(STONE_NAMES,      itemName) then return true end
    if CollectBearPelt   and tableContains(BEARPELT_NAMES,   itemName) then return true end
    if CollectFeather    and tableContains(FEATHER_NAMES,    itemName) then return true end
    if CollectCrab       and tableContains(CRAB_NAMES,       itemName) then return true end
    if CollectCookedCrab and tableContains(COOKEDCRAB_NAMES, itemName) then return true end
    if CollectIronOre    and tableContains(IRONORE_NAMES,    itemName) then return true end
    if CollectRedBerries and tableContains(REDBERRIES_NAMES, itemName) then return true end
    if CollectSnakeTooth and tableContains(SNAKETOOTH_NAMES, itemName) then return true end
    if CollectSpiderWeb  and tableContains(SPIDERWEB_NAMES,  itemName) then return true end
    if CollectIronIgnot  and tableContains(IRONIGNOT_NAMES,  itemName) then return true end
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

-- ── Notification shortcut ────────────────────────────────────────
local function notify(title, content, duration)
    Fluent:Notify({
        Title    = title,
        Content  = content,
        Duration = duration or 3,
    })
end

-- ================================================================
-- CREATE WINDOW
-- ================================================================
local Window = Fluent:CreateWindow({
    Title       = "Escape from Mr. Island Beast",
    SubTitle    = "By GAMER",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(550, 460),
    Acrylic     = false,
    Theme       = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftAlt,
})

local Tabs = {
    Farm     = Window:AddTab({ Title = "Farm",     Icon = "axe"       }),
    Combat   = Window:AddTab({ Title = "Combat",   Icon = "sword"     }),
    Quests   = Window:AddTab({ Title = "Quests",   Icon = "clipboard" }),
    Chests   = Window:AddTab({ Title = "Chests",   Icon = "package"   }),
    ESP      = Window:AddTab({ Title = "Esp",      Icon = "eye"       }),
    Player   = Window:AddTab({ Title = "Player",   Icon = "user"      }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings"  }),
}

-- ================================================================
-- FARM TAB
-- ================================================================
Tabs.Farm:AddParagraph({
    Title   = "Tree Chopping/ Stone Breaking",
    Content = "Stand near trees/stones to chop/break them.",
})

Tabs.Farm:AddToggle("AutoCut", {
    Title       = "Auto Cut/Hit Trees/Stones",
    Description = "Automatically hits nearby trees/stones/bush.",
    Default     = false,
    Callback    = function(enabled)
        AutoCutTree = enabled
        task.spawn(function()
            while AutoCutTree do
                task.wait(0.001)
                local char = getCharacter()
                local staticFolder = getGameFolder("Static")
                if char and staticFolder then
                    for _, obj in pairs(staticFolder:GetChildren()) do
                        if obj.Name == "Coconut Tree" or obj.Name == "Tree" or obj.Name == "Iron Stone" or obj.Name == "Stone" or obj.Name == "Bush" then
                            local part = obj:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                                if dist <= TreeRange + 5 then--------------------------------------------------------------------------------
                                    meleeHitRemote:FireServer({}, {obj})
                                end
                            end

                        end
                    end
                end
            end
        end)
    end,
})

Tabs.Farm:AddSlider("TreeRange", {
    Title    = "Axe Range",
    Default  = 15,
    Min      = 5,
    Max      = 35,
    Rounding = 0,
    Callback = function(value)
        TreeRange = value
    end,
})

Tabs.Farm:AddParagraph({
    Title   = "Item Collection",
    Content = "Disable 'Collect ALL' to use specific filters.",
})

Tabs.Farm:AddToggle("AutoCollectAll", {
    Title       = "Auto Collect All Items",
    Description = "Collects every item on the ground automatically.",
    Default     = false,
    Callback    = function(enabled)
        AutoCollectAll = enabled
    end,
})

Tabs.Farm:AddParagraph({
    Title   = "Filters",
    Content = "Disable 'Collect ALL' to use specific filters.",
})

Tabs.Farm:AddToggle("CollectWood", {
    Title    = "Collect Wood",
    Default  = false,
    Callback = function(enabled)
        CollectWood = enabled
    end,
})

Tabs.Farm:AddToggle("CollectCoco", {
    Title    = "Collect Coconut",
    Default  = false,
    Callback = function(enabled)
        CollectCoco = enabled
    end,
})

Tabs.Farm:AddToggle("CollectEgg", {
    Title    = "Collect Egg",
    Default  = false,
    Callback = function(enabled)
        CollectEgg = enabled
    end,
})

Tabs.Farm:AddToggle("CollectCookedEgg", {
    Title    = "Collect Cooked Egg",
    Default  = false,
    Callback = function(enabled)
        CollectCookedEgg = enabled
    end,
})

Tabs.Farm:AddToggle("CollectMeat", {
    Title    = "Collect Meat",
    Default  = false,
    Callback = function(enabled)
        CollectMeat = enabled
    end,
})

Tabs.Farm:AddToggle("CollectCookedMeat", {
    Title    = "Collect Cooked Meat",
    Default  = false,
    Callback = function(enabled)
        CollectCookedMeat = enabled
    end,
})

Tabs.Farm:AddToggle("CollectStone", {
    Title    = "Collect Stone",
    Default  = false,
    Callback = function(enabled)
        CollectStone = enabled
    end,
})

Tabs.Farm:AddToggle("CollectBearPelt", {
    Title    = "Collect Bear Pelt",
    Default  = false,
    Callback = function(enabled) CollectBearPelt = enabled end,
})
Tabs.Farm:AddToggle("CollectFeather", {
    Title    = "Collect Chicken Feather",
    Default  = false,
    Callback = function(enabled) CollectFeather = enabled end,
})
Tabs.Farm:AddToggle("CollectCrab", {
    Title    = "Collect Crab",
    Default  = false,
    Callback = function(enabled) CollectCrab = enabled end,
})
Tabs.Farm:AddToggle("CollectCookedCrab", {
    Title    = "Collect Cooked Crab",
    Default  = false,
    Callback = function(enabled) CollectCookedCrab = enabled end,
})
Tabs.Farm:AddToggle("CollectIronOre", {
    Title    = "Collect Iron Ore",
    Default  = false,
    Callback = function(enabled) CollectIronOre = enabled end,
})
Tabs.Farm:AddToggle("CollectRedBerries", {
    Title    = "Collect Red Berries",
    Default  = false,
    Callback = function(enabled) CollectRedBerries = enabled end,
})
Tabs.Farm:AddToggle("CollectSnakeTooth", {
    Title    = "Collect Snake Tooth",
    Default  = false,
    Callback = function(enabled) CollectSnakeTooth = enabled end,
})
Tabs.Farm:AddToggle("CollectSpiderWeb", {
    Title    = "Collect Spider Web",
    Default  = false,
    Callback = function(enabled) CollectSpiderWeb = enabled end,
})
Tabs.Farm:AddToggle("CollectIronIgnot", {
    Title    = "Collect Iron Ignot",
    Default  = false,
    Callback = function(enabled) CollectIronIgnot = enabled end,
})


-- Auto-collect background loop
task.spawn(function()
    while true do
        task.wait(0.3)
        if AutoCollectAll or CollectWood or CollectCoco or CollectEgg or CollectCookedEgg or CollectMeat or CollectCookedMeat or CollectStone
            or CollectBearPelt or CollectFeather or CollectCrab or CollectCookedCrab or CollectIronOre
             or CollectRedBerries or CollectSnakeTooth or CollectSpiderWeb or CollectIronIgnot then
            local char         = getCharacter()
            local itemFolder   = getGameFolder("DroppedItems")
            if char and itemFolder then
                for _, item in pairs(itemFolder:GetChildren()) do
                    if item:IsA("Model") then
                        local part = item:FindFirstChildWhichIsA("BasePart", true)
                        if part and shouldCollect(item.Name) then
                            local savedCFrame    = char.HumanoidRootPart.CFrame
                            local cam            = workspace.CurrentCamera
                            cam.CameraType       = Enum.CameraType.Scriptable
                            char.HumanoidRootPart.CFrame = part.CFrame
                            task.wait(0.2)
                            collectRemote:FireServer(item)
                            task.wait(0.2)
                            char.HumanoidRootPart.CFrame = savedCFrame
                            cam.CameraType       = Enum.CameraType.Custom
                        end
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- COMBAT TAB
-- ================================================================
Tabs.Combat:AddToggle("AutoKill", {
    Title       = "Kill Aura Animals",
    Description = "Automatically attacks nearby animals.",
    Default     = false,
    Callback    = function(enabled)
        AutoKill = enabled
        task.spawn(function()
            while AutoKill do
                task.wait(0)
                local char            = getCharacter()
                local entitiesFolder  = getGameFolder("Entities")
                if char and entitiesFolder then
                    for _, entity in pairs(entitiesFolder:GetChildren()) do
                        if entity:IsA("Model")
                            and entity:FindFirstChild("HumanoidRootPart")
                            and entity:FindFirstChild("Humanoid")
                            and entity.Humanoid.Health > 0
                        then
                            local dist = (char.HumanoidRootPart.Position - entity.HumanoidRootPart.Position).Magnitude
                            if dist <= KillRange then
                                meleeHitRemote:FireServer({entity}, {})
                            end
                        end
                    end
                end
            end
        end)
    end,
})

Tabs.Combat:AddSlider("KillRange", {
    Title    = "Weapon Range",
    Default  = 15,
    Min      = 5,
    Max      = 35,
    Rounding = 0,
    Callback = function(value)
        KillRange = value
    end,
})

-- ================================================================
-- CHESTS TAB
-- ================================================================
Tabs.Chests:AddToggle("AutoFarmChests", {
    Title       = "Auto Farm All Chests",
    Description = "Teleports to chests one by one.",
    Default     = false,
    Callback    = function(enabled)
        AutoFarmChests = enabled
        if AutoFarmChests then
            task.spawn(function()
                local visited = {}
                while AutoFarmChests do
                    task.wait(1)
                    local tilesFolder = getGameFolder("Chest")
                    if tilesFolder then
                        local children = tilesFolder:GetChildren()
                        -- Reset visited list when map resets (no children)
                        if #children == 0 then
                            visited = {}
                        end
                        for _, chest in pairs(children) do
                            if not AutoFarmChests then break end
                            if visited[chest] then continue end
                            local part = chest:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local char = getCharacter()
                                if char then
                                    char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                                    visited[chest] = true
                                    task.wait(ChestWaitTime)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end,
})

Tabs.Chests:AddSlider("ChestDelay", {
    Title    = "Delay per Chest(sec)",
    Default  = 3,
    Min      = 1,
    Max      = 15,
    Rounding = 0,
    Callback = function(value)
        ChestWaitTime = value
    end,
})

Tabs.Chests:AddParagraph({
    Title   = "Chest List",
    Content = "Loot Box Gold, Loot Box House, Loot Box Wild, Loot box 02, Loot box 03",
})

-- ================================================================
-- ESP TAB
-- ================================================================
Tabs.ESP:AddToggle("ESPAnimals", {
    Title       = "Enable Entity ESP",
    Description = "Shows a highlight around animals.",
    Default     = false,
    Callback    = function(enabled)
        ESPEnabled = enabled
        -- Remove existing highlights when toggled off
        if not ESPEnabled then
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

-- ESP background loop
task.spawn(function()
    while true do
        task.wait(1)
        if ESPEnabled then
            local entitiesFolder = getGameFolder("Entities")
            if entitiesFolder then
                for _, entity in pairs(entitiesFolder:GetChildren()) do
                    if entity:IsA("Model") and not entity:FindFirstChild("ESPHighlight") then
                        local highlight               = Instance.new("Highlight")
                        highlight.Name               = "ESPHighlight"
                        highlight.FillTransparency   = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.FillColor          = Color3.fromRGB(255, 0, 135)
                        highlight.OutlineColor       = Color3.fromRGB(255, 255, 255)
                        highlight.Parent             = entity
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- QUESTS TAB
-- ================================================================
Tabs.Quests:AddParagraph({
    Title   = "Teleports",
    Content = "Quick shortcuts to locations and quest items.",
})

-- TP to Campfire (searches by multiple possible names)
Tabs.Quests:AddButton({
    Title       = "🔥 TP to Campfire",
    Description = "Teleports you to the nearest campfire.",
    Callback    = function()
        local char = getCharacter()
        if not char then return end

        -- The campfire can have any of these names depending on server language
        local campfire = workspace:FindFirstChild("Campfire", true)
                      or workspace:FindFirstChild("Camp Fire", true)
                      or workspace:FindFirstChild("Fogueira",  true)

        if campfire then
            local part = campfire:FindFirstChildWhichIsA("BasePart", true)
                      or (campfire:IsA("Model") and campfire.PrimaryPart)
            if part then
                char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                notify("Success", "Teleported to the campfire!", 3)
            end
        else
            notify("Error", "Campfire not found on the map.", 4)
        end
    end,
})

-- Generic teleport function used by the quest buttons below
local function teleportToNamedObject(objectName)
    local char        = getCharacter()
    if not char then return end

    local tilesFolder = getGameFolder("Tiles")
    if not tilesFolder then
        notify("Error", objectName .. " not found. Wait for the map to generate it.", 4)
        return
    end

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

Tabs.Quests:AddButton({
    Title    = "🪣 TP to Plastic Bucket",
    Callback = function() teleportToNamedObject("Plastic Bucket") end,
})

Tabs.Quests:AddButton({
    Title    = "📻 TP to Radio",
    Callback = function() teleportToNamedObject("Radio") end,
})

Tabs.Quests:AddButton({
    Title    = "🧭 TP to Compass",
    Callback = function() teleportToNamedObject("Compass") end,
})

Tabs.Quests:AddButton({
    Title    = "🗺️ TP to Map",
    Callback = function() teleportToNamedObject("Map") end,
})

-- ================================================================
-- PLAYER TAB (Noclip, TP Walk, Jump Power)
-- ================================================================
local RunService = game:GetService("RunService")

-- 1. DEFINE FUNCTIONS FIRST (Prevents "attempt to call nil" errors)
function applyJumpPower()
    local char = getCharacter()
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Use pcall to prevent errors if the game uses a custom/broken Humanoid
    if JumpPowerEnabled then
        pcall(function()
            if humanoid.UseJumpPower then
                humanoid.JumpPower = JumpPowerValue
            else
                humanoid.JumpHeight = JumpPowerValue
            end
        end)
    else
        -- Reset to defaults
        pcall(function() humanoid.JumpPower = 50 end)
        pcall(function() humanoid.JumpHeight = 7.2 end)
    end
end

-- 2. UI Elements
Tabs.Player:AddToggle("Noclip", {
    Title       = "Noclip",
    Description = "Walk through walls and objects.",
    Default     = false,
    Callback    = function(enabled) 
        NoclipEnabled = enabled 
    end,
})

Tabs.Player:AddToggle("TPWalk", {
    Title       = "TP Walk",
    Description = "Teleport walk in the direction you are moving.",
    Default     = false,
    Callback    = function(enabled) 
        TPWalkEnabled = enabled 
    end,
})

Tabs.Player:AddSlider("TPWalkSpeed", {
    Title    = "TP Walk Speed",
    Default  = TPWalkSpeed,
    Min      = 1,
    Max      = 10,
    Rounding = 0,
    Callback = function(value) 
        TPWalkSpeed = value 
    end,
})

Tabs.Player:AddToggle("JumpPowerToggle", {
    Title       = "Enable Jump Power",
    Description = "Toggles the custom jump power on and off.",
    Default     = false,
    Callback    = function(enabled)
        JumpPowerEnabled = enabled
        applyJumpPower()
    end,
})

Tabs.Player:AddSlider("JumpPowerSlider", {
    Title    = "Jump Power / Height",
    Default  = JumpPowerValue,
    Min      = 0,
    Max      = 150,
    Rounding = 0,
    Callback = function(value)
        JumpPowerValue = value
        applyJumpPower()
    end,
})

-- 3. Respawn Handler for Jump Power
game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    local humanoid = newChar:WaitForChild("Humanoid", 5)
    if humanoid and JumpPowerEnabled then
        pcall(function()
            if humanoid.UseJumpPower then
                humanoid.JumpPower = JumpPowerValue
            else
                humanoid.JumpHeight = JumpPowerValue
            end
        end)
    end
end)

-- 4. Main Loop for Noclip & TP Walk
RunService.Stepped:Connect(function()
    local char = getCharacter()
    if not char then return end
    
    -- Noclip (Only disables collision on the player's body)
    if NoclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- TP Walk (Teleports based on WASD movement)
    if TPWalkEnabled then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * TPWalkSpeed)
        end
    end
end)

-- Apply Jump Power on initial script load
applyJumpPower()


-- ================================================================
-- SETTINGS TAB
-- ================================================================
Tabs.Settings:AddParagraph({
    Title   = "Configuration",
    Content = "Menu Key: Alt\nMobile users can use the floating 'W' button to toggle the menu.",
})

-- ================================================================
-- MOBILE TOGGLE BUTTON  (floating "W" on screen)
-- ================================================================
local CoreGui = game:GetService("CoreGui")

-- Remove any leftover button from a previous load
local existing = CoreGui:FindFirstChild("MobileButtonUI")
if existing then existing:Destroy() end

local mobileGui        = Instance.new("ScreenGui")
mobileGui.Name         = "MobileButtonUI"
mobileGui.Parent       = CoreGui

local toggleBtn                  = Instance.new("TextButton")
toggleBtn.Name                   = "Toggle"
toggleBtn.Parent                 = mobileGui
toggleBtn.BackgroundColor3       = Color3.fromRGB(25, 25, 25)
toggleBtn.Position               = UDim2.new(0.5, -25, 0.1, 0)
toggleBtn.Size                   = UDim2.new(0, 50, 0, 50)
toggleBtn.Font                   = Enum.Font.GothamBold
toggleBtn.Text                   = "W"
toggleBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize               = 20
toggleBtn.Active                 = true
toggleBtn.Draggable              = true

local corner          = Instance.new("UICorner")
corner.CornerRadius   = UDim.new(1, 0)   -- fully round
corner.Parent         = toggleBtn

local stroke          = Instance.new("UIStroke")
stroke.Color          = Color3.fromRGB(150, 150, 150)
stroke.Thickness      = 1.5
stroke.Parent         = toggleBtn

-- Find the Fluent window ScreenGui by searching for a TextLabel
-- that contains the window title, then toggle its children.
local fluentScreenGui

task.spawn(function()
    while not fluentScreenGui do
        task.wait(0.5)
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, descendant in pairs(gui:GetDescendants()) do
                    if descendant:IsA("TextLabel")
                        and string.find(descendant.Text, "Escape from Mr. Island Beast")
                    then
                        fluentScreenGui = gui
                        break
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
            if child:IsA("Frame") or child:IsA("CanvasGroup") then
                child.Visible = not child.Visible
            end
        end
    end
end)

-- ================================================================
-- STARTUP NOTIFICATION
-- ================================================================
notify("Script Loaded", "Mobile UI loaded! Movement is now free.", 5)
--------------------------------------------------------------------
-- proximity
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.spawn(function()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end)
    end)
end)
ProximityPromptService.PromptTriggered:Connect(function(prompt)
    print("[PoC] Prompt Triggered (instant):", prompt:GetFullName())
end)