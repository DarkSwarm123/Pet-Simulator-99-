repeat task.wait() until game:IsLoaded()
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Pet Simulator 99 Script",
   Icon = 0, 
   LoadingTitle = "Pet Simulator 99",
   LoadingSubtitle = "by Dark",
   ShowText = "Rayfield",
   Theme = "DarkBlue", 
   ToggleUIKeybind = "R",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RayfieldGUIconfig", 
      FileName = "Pet Simulator 99"
   },

   Discord = {
      Enabled = false, 
      Invite = "noinvitelink",
      RememberJoins = true 
   },

   KeySystem = false, 
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", 
      FileName = "Key",
      SaveKey = true, 
      GrabKeyFromSite = false,
      Key = {"Hello"} 
   }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local OtherTab = Window:CreateTab("Other", 4483362458)
local ItemsTab = Window:CreateTab("Items", 4483362458)
local GardenTab = Window:CreateTab("Garden", 15555104643)
local MinigamesTab = Window:CreateTab("Minigames", 4483362458)

local orb = require(game:GetService("ReplicatedStorage").Library.Client.OrbCmds.Orb)
orb.DefaultPickupDistance = math.huge
orb.CollectDistance = math.huge
orb.CombineDistance = math.huge
orb.CombineDelay = 0
orb.SoundDistance = 0
orb.BillboardDistance = 0

local function Wait(x)
    local startTick = tick()  -- Czas rzeczywisty
    local startClock = os.clock()  -- Czas CPU

    for i = 1, x do
        task.wait()
    end

    local logTime = false  -- Ustaw true, by włączyć logowanie

    if logTime then
        local totalTick = tick() - startTick
        local totalClock = os.clock() - startClock
        print("Wait(" .. x .. ") trwało około " .. totalTick .. " sekund (czas rzeczywisty).")
        print("Czas używanego CPU: " .. totalClock .. " sekund.")
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RenderToggleGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.ZIndex = 10
background.Visible = false
background.Parent = screenGui

local function setRendering(state)  game:GetService("RunService"):Set3dRenderingEnabled(state)
    background.Visible = not state
end

OtherTab:CreateToggle({
    Name = "No Rendering",
    CurrentValue = false,
    Callback = function(Value)
        setRendering(not Value)
    end,
})

local function toggleDiamondsGui(Value)
    if Value then
        -- Tworzymy GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DiamondsGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 100)
        frame.Position = UDim2.new(0.5, -100, 0.1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0.8, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = "Diamonds: ..."
        label.Parent = frame

        local function formatNumber(n)
            local formatted = tostring(n)
            while true do
                formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
                if k == 0 then break end
            end
            return formatted
        end

        local player = game.Players.LocalPlayer
        local leaderstats = player:WaitForChild("leaderstats")
        local diamonds = leaderstats:FindFirstChild("💎 Diamonds") or leaderstats:FindFirstChild("\240\159\146\142 Diamonds")

        if diamonds and diamonds:IsA("IntValue") then
            local startTime = tick()
            local startValue = diamonds.Value
         diamonds:GetPropertyChangedSignal("Value"):Connect(function()
                local currentValue = diamonds.Value
                local now = tick()
                local minutes = (now - startTime) / 60
                local gain = currentValue - startValue
                local perMinute = math.floor(gain / minutes + 0.5)

                label.Text = "Diamonds: " .. formatNumber(currentValue) ..
                    "\nChange: " .. (perMinute >= 0 and "+" or "") .. formatNumber(perMinute) .. " / min"
            end)
        else
            label.Text = "Diamonds not found"
        end
    else
        local existingGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("DiamondsGui")
        if existingGui then
            existingGui:Destroy()
        end
    end
end

OtherTab:CreateToggle({
    Name = "Diamonds Tracker",
    CurrentValue = false,
    Callback = function(Value)
        toggleDiamondsGui(Value)
    end,
})

local AutoBreak = false
MainTab:CreateToggle({
    Name = "Auto Tap Breakables",
    CurrentValue = false,
    Flag = "AutoBreakToggle",
    Callback = function(Value)
        AutoBreak = Value
        if Value then
            task.spawn(function()
                local Workspace = game:GetService("Workspace")
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Network = ReplicatedStorage:WaitForChild("Network")
                local Breakables = Workspace.__THINGS:WaitForChild("Breakables")
                local MapCmds = require(ReplicatedStorage.Library.Client.MapCmds)

                while AutoBreak do
                    local zone = MapCmds.GetCurrentZone()
                    for _, b in pairs(Breakables:GetChildren()) do
                        if not AutoBreak then break end
                        if b:IsA("Model") and b:GetAttribute("ParentID") == zone then
                            repeat
                                if not AutoBreak then break end
                                Network.Breakables_PlayerDealDamage:FireServer(b.Name)
                                task.wait(.5)
                            until not b.Parent
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

local Save = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save"))

local gardenCycleEnabled = false

local function getAmount(section, id)
    local inventory = Save.Get().Inventory
    for _, v in pairs(inventory[section]) do
        if v.id == id then
            return v._am or 1
        end
    end
    return 0
end

local function gardenCycle()
    while gardenCycleEnabled do
        local container = workspace:FindFirstChild("__THINGS")
            and workspace.__THINGS:FindFirstChild("__INSTANCE_CONTAINER")
            and workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("FlowerGarden")

        if not gardenCycleEnabled then
            break
        end

        local diamondCount = getAmount("Seed", "Diamond")
        local instaCount = getAmount("Misc", "Insta Plant Capsule")

        if diamondCount >= 10 and instaCount >= 10 and container then
    
            for i = 1, 10 do
                local args = {"FlowerGarden", "PlantSeed", i, "Diamond"}
                game.ReplicatedStorage.Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(args))
            end

            task.wait()

            for i = 1, 10 do
                local args = {"FlowerGarden", "InstaGrowSeed", i}
                game.ReplicatedStorage.Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(args))
            end

            task.wait()

            for i = 1, 10 do
                local args = {"FlowerGarden", "ClaimPlant", i}
                game.ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
            end
        end

        task.wait()
    end
end

local GardenCycleToggle = GardenTab:CreateToggle({
    Name = "Enable Garden Farming",
    CurrentValue = false,
    Flag = "GardenCycleToggle",
    Callback = function(Value)
        gardenCycleEnabled = Value
        if gardenCycleEnabled and game.PlaceId == 8737899170 then
            task.spawn(gardenCycle)
        end
    end
})

local SeedBagEnabled = false
local SeedBagToggle = GardenTab:CreateToggle({
    Name = "Open Seed Bag",
    CurrentValue = false,
    Flag = "SeedBagToggle",
    Callback = function(Value)
        SeedBagEnabled = Value
        if SeedBagEnabled then
            task.spawn(function()
                while SeedBagEnabled do
                    local amount = getAmount("Misc", "Seed Bag")
                    if amount >= 1 then
                        game:GetService("ReplicatedStorage").Network.GiftBag_Open:InvokeServer("Seed Bag")
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

local Section = ItemsTab:CreateSection("Forge Machine")

local targetNames = {
    ["Diamonds"] = true,
    ["Coins"] = true,
    ["Bonus"] = true,
    ["Criticals"] = true,
    ["Agility"] = true,
    ["Lightning"] = true,
    ["Strength"] = true,
    ["TNT"] = true
}

local AutoForge = false

ItemsTab:CreateToggle({
    Name = "Auto Forge Charm Stones",
    CurrentValue = false,
    Flag = "AutoForgeToggle",
    Callback = function(Value)
        AutoForge = Value

        task.spawn(function()
            while AutoForge do
                local inventory = Save.Get().Inventory
                local charmSection = inventory.Charm
                local charmArgs = {}
                local totalCharms = 0  

                for id, charm in pairs(charmSection) do
                    if charm and targetNames[charm.id] then
                        local charmValue = charm._am or 1
                        charmArgs[id] = charmValue
                        totalCharms = totalCharms + charmValue
                    end
                end

                if totalCharms >= 100 then  
                    local args = {
                        [1] = "Charm Stone",
                        [2] = charmArgs
                    }
                    game:GetService("ReplicatedStorage").Network.ForgeMachine_Activate:InvokeServer(unpack(args))
                    warn("Total amount of charms sent: " .. totalCharms)
                end
                task.wait(1) 
            end
        end)
    end
})

local AutoForgeGifts = false

ItemsTab:CreateToggle({
    Name = "Auto Forge Large Gift Bags",
    CurrentValue = false,
    Flag = "AutoForgeGiftsToggle",
    Callback = function(Value)
        AutoForgeGifts = Value

        task.spawn(function()
            while AutoForgeGifts do
                local inventory = Save.Get().Inventory.Misc
                for id, giftbag in pairs(inventory) do
                    if giftbag.id == "Gift Bag" and (giftbag._am or 1) >= 4 then
                        local amountToUse = math.floor(giftbag._am / 4) * 4
                        local args = {
                            [1] = "Large Gift Bag",
                            [2] = {
                                [id] = amountToUse
                            }
                        }

                        game:GetService("ReplicatedStorage").Network.ForgeMachine_Activate:InvokeServer(unpack(args))
                        print("✅ Wysłano " .. amountToUse .. " Gift Bag do przetopu")
                        break
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local Section = ItemsTab:CreateSection("Lootboxes")

local CharmStoneOpen = false
local OpenCharmStoneToggle = ItemsTab:CreateToggle({
    Name = "Auto Open Charm Stone",
    CurrentValue = false,
    Flag = "OpenCharmStoneToggle",
    Callback = function(Value)
CharmStoneOpen = Value
        if CharmStoneOpen then
            task.spawn(function()
                while CharmStoneOpen do
                    local amount = getAmount("Misc", "Charm Stone")
                    if amount >= 1 then
                        game:GetService("ReplicatedStorage").Network.GiftBag_Open:InvokeServer("Charm Stone")
                    else
                        task.wait()
                    end
                end
            end)
        end
    end
})

local openStates = {}
local openToggles = {}
local openSizes = {100, 50, 25, 10, 5, 1}

local bagNames = {
    "Gift Bag", "Large Gift Bag", "Toy Bundle", "Fruit Bundle", "Flag Bundle",
    "Enchant Bundle", "Large Enchant Bundle", "Potion Bundle", "Large Potion Bundle"
}

for _, name in ipairs(bagNames) do
    local varName = name:gsub(" ", "")
    openStates[varName] = false

    openToggles[varName] = ItemsTab:CreateToggle({
        Name = "Auto Open " .. name,
        CurrentValue = false,
        Flag = "Open" .. varName .. "Toggle",
        Callback = function(Value)
            openStates[varName] = Value
            if Value then
                task.spawn(function()
                    while openStates[varName] do
                        for _, size in ipairs(openSizes) do
                            local amount = getAmount("Misc", name)
                            while amount >= size and openStates[varName] do
                                local args = {
                                    [1] = name,
                                    [2] = size
                                }
                                game:GetService("ReplicatedStorage").Network.GiftBag_Open:InvokeServer(unpack(args))
                                amount = getAmount("Misc", name)
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })
end

local UltimateCmds = require(game:GetService("ReplicatedStorage").Library.Client.UltimateCmds)
local MapCmds = require(game:GetService("ReplicatedStorage").Library.Client.MapCmds)

local toggleEnabled = false

local UltimateToggle = MainTab:CreateToggle({
    Name = "Auto Ultimate",
    CurrentValue = false,
    Flag = "AutoUltimateToggle",
    Callback = function(Value)
        toggleEnabled = Value

        task.spawn(function()
            while toggleEnabled do
                if MapCmds.IsInDottedBox() then
                    local equipped = UltimateCmds.GetEquippedItem()

                    if equipped and UltimateCmds.IsCharged(equipped:GetId()) then
                        local success = UltimateCmds.Activate(equipped:GetId())
                        if success then
                            warn("✅ Ultimate activated!")
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

local function GetPetTypeString(pt)
    if pt == 1 then return "GOLD"
    elseif pt == 2 then return "RAINBOW"
    else return "NORMAL" end
end

local AutoDaycare = false

local DaycareToggle = MainTab:CreateToggle({
    Name = "Auto Daycare",
    CurrentValue = false,
    Flag = "AutoDaycare",
    Callback = function(Value)
        AutoDaycare = Value
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Network = ReplicatedStorage.Network
            local DaycareCmds = require(ReplicatedStorage.Library.Client.DaycareCmds)            
            while AutoDaycare do
                pcall(function()
                    local active = Save.Get().DaycareActive or {}
                    local readyToClaim = false

                    for uuid, _ in pairs(active) do
                        if DaycareCmds.ComputeRemainingTime(uuid) <= 0 then
                            readyToClaim = true
                            break
                        end
                    end

                    if readyToClaim or next(active) == nil then
                        Network["Daycare: Claim"]:InvokeServer()
                        task.wait(1)
                        local maxSlots = DaycareCmds.GetMaxSlots()
                        local selectedPet = "73a201f76aa34d6ab46e2c3372fd108c"
                        local petData = Save.Get().Inventory.Pet[selectedPet]
                        local name = petData and petData.id or "?"
                        local typeStr = petData and GetPetTypeString(petData.pt or 0) or "?"

                        print("📤 Wysłano do Daycare:", maxSlots .. "x", name, "(" .. typeStr .. ")")

                        local args = {
                            [1] = {
                                [selectedPet] = maxSlots
                            }
                        }

                        Network["Daycare: Enroll"]:InvokeServer(unpack(args))
                    end
                end)
                task.wait(1)
            end
        end)
    end,
})

local autoFuseEnabled = false 

local FuseToggle = MainTab:CreateToggle({
    Name = "Auto Fuse",
    CurrentValue = false,
    Flag = "AutoFuseToggle",
    Callback = function(Value)
        autoFuseEnabled = Value
    end
})

local AMOUNT_TO_USE = 100

task.spawn(function()
    while true do
        if autoFuseEnabled then
            local pets = Save.Get().Inventory.Pet
            if pets then
                local bestPetId, bestAmount, bestType, petName = nil, 0, 0, ""

                for uniqueId, pet in pairs(pets) do
                    if pet._am and pet._am >= AMOUNT_TO_USE then
                        if pet._am > bestAmount then
                            bestPetId = uniqueId
                            bestAmount = pet._am
                            bestType = pet.pt or 0
                            petName = pet.id or "Unknown"
                        end
                    end
                end

                if bestPetId then
                    local args = { [bestPetId] = AMOUNT_TO_USE }
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Network.FuseMachine_Activate:InvokeServer(args)
                    end)

                    if success then
                        print(string.format("✅ Fuzja wysłana: %dx %s (%s)", AMOUNT_TO_USE, petName, GetPetTypeString(bestType)))
                    else
                        warn("❌ Błąd fuzji:", err)
                    end
                else
                    print(string.format("ℹ️ Brak peta z ilością ≥ %d", AMOUNT_TO_USE))
                end
            end
        end
        task.wait(2)
    end
end)

local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")

local Section = MainTab:CreateSection("Keys")

local Keys = {
    {Name = "Crystal", Upper = "Crystal Key Upper Half", Lower = "Crystal Key Lower Half"},
    {Name = "Tech", Upper = "Tech Key Upper Half", Lower = "Tech Key Lower Half"},
    {Name = "Secret", Upper = "Secret Key Upper Half", Lower = "Secret Key Lower Half"},
    {Name = "Void", Upper = "Void Key Upper Half", Lower = "Void Key Lower Half"},
    {Name = "Fantasy", Upper = "Fantasy Key Upper Half", Lower = "Fantasy Key Lower Half"},
}

for _, keyData in pairs(Keys) do
    local enabled = false

    local function CraftKey()
        while enabled do
            local part1 = getAmount("Misc", keyData.Upper)
            local part2 = getAmount("Misc", keyData.Lower)

            if part1 > 0 and part2 > 0 then
                local amount = math.min(part1, part2)
                Network[keyData.Name .. "Key_Combine"]:InvokeServer(amount)
            end

            task.wait(1)
        end
    end

    MainTab:CreateToggle({
    Name = "Craft " .. keyData.Name .. " Keys",
    CurrentValue = false,
    Flag = "CraftKey_" .. keyData.Name,
    Callback = function(value)
        enabled = value
        if enabled then
            task.spawn(CraftKey)
        end
    end
})
end

local advancedFishingEnabled = false

MinigamesTab:CreateToggle({
    Name = "Auto Advanced Fishing",
    CurrentValue = false,
    Callback = function(state)
        advancedFishingEnabled = state

        if not advancedFishingEnabled then return end

        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Workspace = game:GetService("Workspace")
            local Network = ReplicatedStorage:WaitForChild("Network")
            local Player = game.Players.LocalPlayer

            while advancedFishingEnabled do
                local container = Workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing")

                if container then
                    local interactable = container:FindFirstChild("Interactable")
                    local deepPool = interactable and interactable:FindFirstChild("DeepPool")

                    local castVector
                    if deepPool then
                        castVector = deepPool.Position + Vector3.new(
                            Random.new():NextNumber(-4.75, 4.75),
                            0,
                            Random.new():NextNumber(-4.75, 4.75)
                        )
                    else
                        castVector = Vector3.new(1459.0086669921875, 61.62493896484375, -4451.37548828125)
                    end

                    -- 🎣 Rzut wędką
                    Network.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", castVector)

                    -- 🔍 Szukanie bobbera
                    local bobbers = container:FindFirstChild("Bobbers")
                    local playerBobber

                    repeat
                        for _, v in pairs(bobbers:GetChildren()) do
                            if v:FindFirstChild("Bobber") and (v.Bobber.Position - castVector).Magnitude < 3 then
                                playerBobber = v.Bobber
                                break
                            end
                        end
                        task.wait()
                    until not advancedFishingEnabled or playerBobber

                    if not playerBobber then
                        task.wait(1)
                        continue
                    end

                    -- ⏳ Czekanie aż bobber spadnie do wody
                    local previousY
                    repeat
                        local y = playerBobber.Position.Y
                        if previousY == y then break end
                        previousY = y
                        task.wait()
                    until not advancedFishingEnabled

                    local fallY = playerBobber.Position.Y
                    repeat task.wait() until not advancedFishingEnabled or playerBobber.Position.Y < fallY

                    -- 🧲 Zwijanie wędki
                    Network.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestReel")

                    -- 🎯 Klikanie w minigrze
                    while Player.Character:FindFirstChild("Model")
                        and Player.Character.Model:FindFirstChild("Rod")
                        and Player.Character.Model.Rod:FindFirstChild("FishingLine")
                        and advancedFishingEnabled do

                        Network.Instancing_InvokeCustomFromClient:InvokeServer("AdvancedFishing", "Clicked")
                        task.wait(0.75)
                    end
                end

                -- 🕐 czeka sekundę przed kolejnym sprawdzeniem czy instancja istnieje
                task.wait(1)
            end
        end)
    end
})

local autoDigsite = false

MinigamesTab:CreateToggle({
    Name = "Auto Digsite",
    CurrentValue = false,
    Callback = function(Value)
        autoDigsite = Value
        if not autoDigsite then return end

        if game.PlaceId ~= 8737899170 then
            Rayfield:Notify({
                Title = "Auto Digsite",
                Content = "You are not in Spawn World!",
                Duration = 3,
                Image = 4483362458,
            })
            return
        end

        task.spawn(function()
            if not workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("Digsite") then  
    local tpCFrame = workspace.__THINGS.Instances.Digsite.Teleports.Enter.CFrame  
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
    if hrp then  
        hrp.CFrame = tpCFrame  
        repeat
            task.wait(0.5)
        until workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("Digsite") or not autoDigsite
    end  
end
            while autoDigsite do
                local function findBlock()
                    local dist = math.huge
                    local block = nil
                    for _, v in pairs(workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite.Important.ActiveBlocks:GetChildren()) do
                        if v:IsA("BasePart") then
                            local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                            if mag < dist then
                                dist = mag
                                block = v
                            end
                        end
                    end
                    return block
                end

                local function findChest()
                    local dist = math.huge
                    local chest = nil
                    for _, v in pairs(workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite.Important.ActiveChests:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("Top") then
                            local mag = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Top.Position).Magnitude
                            if mag < dist then
                                dist = mag
                                chest = v
                            end
                        end
                    end
                    return chest
                end

                local chest = findChest()
                local block = findBlock()

                if chest then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = chest.Top.CFrame
                    game.ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer("Digsite", "DigChest", chest:GetAttribute("Coord"))
                elseif block then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = block.CFrame
                    game.ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer("Digsite", "DigBlock", block:GetAttribute("Coord"))
                end

                task.wait(0.3)
            end
        end)
    end,
})

local RemoteSpyButton = OtherTab:CreateButton({
    Name = "RemoteSpy (For Mobile)",
    Callback = function()        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Simple-Spy-32021"))()
    end
})

local scriptPath = game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"]
scriptPath.Enabled = false

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end)

Rayfield:LoadConfiguration()