local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Pet Simulator 99 Script",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Dark",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = RayfieldGUIconfig,
       FileName = "Pet Simulator 99"
    },
    Discord = {
       Enabled = false,
       Invite = "",
       RememberJoins = true
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local OtherTab = Window:CreateTab("Other", 4483362458)
local ItemsTab = Window:CreateTab("Items", 4483362458)
local GardenTab = Window:CreateTab("Garden", 15555104643)

local orb = require(game:GetService("ReplicatedStorage").Library.Client.OrbCmds.Orb)
orb.CollectDistance = math.huge

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

local Save = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save"))

local gardenCycleEnabled = false

local function getAmount(section, id)
    local inventory = Save.Get().Inventory
    for _, v in pairs(inventory[section]) do
        if v.id == id then
            return v._am or 0
        end
    end
    return 0
end

local function gardenCycle() 
    while gardenCycleEnabled do
        local diamondCount = getAmount("Seed", "Diamond")
        local instaCount = getAmount("Misc", "Insta Plant Capsule")

        if diamondCount >= 10 and instaCount >= 10 then
            for i = 1, 10 do
                task.spawn(function()
                    local args = {"FlowerGarden", "PlantSeed", i, "Diamond"}
                    game:GetService("ReplicatedStorage").Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(args))
                end)
                Wait(2)
            end

            for i = 1, 10 do
                task.spawn(function()
                    local args = {"FlowerGarden", "InstaGrowSeed", i}
                    game:GetService("ReplicatedStorage").Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(args))
                end)
                Wait(2)
            end

            for i = 1, 10 do
                task.spawn(function()
                    local args = {"FlowerGarden", "ClaimPlant", i}
                    game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                end)
                Wait(2)
            end
        else
            task.wait() 
        end
    end
end

local GardenCycleToggle = GardenTab:CreateToggle({
    Name = "Enable Garden Farming",
    CurrentValue = false,
    Flag = "GardenCycleToggle",
    Callback = function(Value)
        gardenCycleEnabled = Value
        if gardenCycleEnabled then
            for i = 1, 10 do
                task.spawn(function()
                    local args1 = {"FlowerGarden", "ClaimPlant", i}
                    game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(args1))
                end)
                task.wait()
            end
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

local CharmToggleEnabled = false

local charmIDs = {
    ["9e0a0e96c54f429fb0690a5fbc3de0f9"] = true,
    ["7d4572b565c74b84b443dd917a6cbe09"] = true,
    ["bb45969a0da34d3cac910ff615c57f4f"] = true,
    ["126d8cebb2484ce8bf5a7a8e91e8a1bc"] = true,
    ["b875cb62f17b445b802b22ac3e60458a"] = true,
    ["b664e4ab4e2744bc9bf60c08f37e63ac"] = true,
    ["df4e5e5b83634497a9552676126c1a0a"] = true,
    ["1a69cc2eda5845059002642190d1a504"] = true
}

local function getCharmAmounts()
    local inventory = Save.Get().Inventory
    local filtered = {}
    local total = 0

    for _, item in pairs(inventory["Charm"] or {}) do
        if item.id and charmIDs[item.id] and item._am and item._am >= 1 then
            filtered[item.id] = item._am
            total += item._am
        end
    end

    return total, filtered
end

local CharmtoConvertToggle = ItemsTab:CreateToggle({
    Name = "Convert Charms to Charm Stone",
    CurrentValue = false,
    Flag = "CharmToggle",
    Callback = function(Value)
        CharmToggleEnabled = Value
        if CharmToggleEnabled then
            task.spawn(function()
                while CharmToggleEnabled do
                    local total, filtered = getCharmAmounts()
                    if total >= 100 then
                        print("Wysyłam:", filtered)
                        local args = {
                            [1] = "Charm Stone",
                            [2] = filtered
                        }
                        game:GetService("ReplicatedStorage").Network.ForgeMachine_Activate:InvokeServer(unpack(args))
                    else
                        print("Za mało Charmów, tylko:", total)
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

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

                    if amount >= 1 then                        game:GetService("ReplicatedStorage").Network.GiftBag_Open:InvokeServer("Charm Stone")
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

local UltimateCmds = require(game:GetService("ReplicatedStorage").Library.Client.UltimateCmds)
local MapCmds = require(game:GetService("ReplicatedStorage").Library.Client.MapCmds)

local toggleEnabled = false

local UltimateToggle = MainTab:CreateToggle({
    Name = "Auto Ultimate",
    CurrentValue = false,
    Callback = function(Value)
        toggleEnabled = Value

        task.spawn(function()
            while toggleEnabled do
                if MapCmds.IsInDottedBox() then
                    local equipped = UltimateCmds.GetEquippedItem()

                    if equipped and UltimateCmds.IsCharged(equipped:GetId()) then
                        local success = UltimateCmds.Activate(equipped:GetId())
                        if success then
                            warn("Ultimate activated!")
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

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
            local Save = require(ReplicatedStorage.Library.Client.Save)

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

                    -- Jeśli są gotowe do odebrania LUB nie ma żadnych w Daycare
                    if readyToClaim or next(active) == nil then
                        Network["Daycare: Claim"]:InvokeServer()
                        task.wait(1)

                        local maxSlots = DaycareCmds.GetMaxSlots()

                        local args = {
                            [1] = {
                                ["1512825f06e94d76b169f4abace033f4"] = maxSlots
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

-- Zmienna sterująca Auto Fuse
local autoFuseEnabled = false
local autoFuseRunning = false  

-- Przełącznik Auto Fuse
local FuseToggle = MainTab:CreateToggle({
    Name = "Włącz Auto Fuse",
    CurrentValue = false,
    Flag = "AutoFuseToggle",
    Callback = function(Value)
        autoFuseEnabled = Value
        if autoFuseEnabled then
            autoFuseRunning = true  -- Rozpocznij pętlę
        else
            autoFuseRunning = false  -- Zatrzymaj pętlę
        end
    end
})

-- Zamiast loadstring, załaduj dane bezpośrednio
local petData = {
    [1] = {["c20cde7f3c1c4bab9ca538485e433bde"] = 100},
    [2] = {["7997b1421a5745dcae4e88cfd36b082a"] = 100},
    [3] = {["94b2999bccf94acd81dd9fbdf31cfa6b"] = 100},
    [4] = {["20bd2e4cf55f42a89cd8b22be26d6a54"] = 100},
    [5] = {["03ac4b9426814d02ae7639d76a3d83f6"] = 100},
    [6] = {["43b8de0025954eb9875902cf864cf29d"] = 100},
    [7] = {["3e6adacbda8d4e2db8f383151635ff6b"] = 100},
    [8] = {["1131a05c6f1c45c3a735de27775f69a8"] = 100}
}

-- Funkcja Auto Fuse
task.spawn(function()
    while true do
        if autoFuseRunning then
            if petData then
                -- Iterujemy po danych petów
                for _, petSet in ipairs(petData) do
                    local args = {}

                    -- Przygotowanie argumentów dla FuseMachine_Activate
                    for petId, quantity in pairs(petSet) do
                        table.insert(args, { [petId] = quantity })
                    end

                    -- Wywołanie FuseMachine_Activate z odpowiednimi petami
                    local successFuse, errorMessage = pcall(function()
                        game:GetService("ReplicatedStorage").Network.FuseMachine_Activate:InvokeServer(unpack(args))
                    end)

                    if successFuse then
                        print("Pomyślnie wysłano fuzję dla:", args)
                    else
                        warn("Błąd przy wysyłaniu fuzji:", errorMessage)
                    end

                    Wait(2)  -- Czas oczekiwania dla stabilności
                end
            else
                warn("Dane o petach nie zostały załadowane poprawnie.")
            end
        end
        task.wait()  -- Czekaj przed ponownym sprawdzeniem
    end
end)

-- Przycisk uruchamiający RemoteSpy (dla mobilnych urządzeń)
local RemoteSpyButton = OtherTab:CreateButton({
    Name = "RemoteSpy (For Mobile)",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Simple-Spy-32021"))()
    end
})

local scriptPath = game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"]
scriptPath:Destroy()

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end)