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
local GardenTab = Window:CreateTab("Garden", 15555104643)

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
                Wait(3)
            end

            for i = 1, 10 do
                task.spawn(function()
                    local args = {"FlowerGarden", "InstaGrowSeed", i}
                    game:GetService("ReplicatedStorage").Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(args))
                end)
                Wait(3)
            end

            for i = 1, 10 do
                task.spawn(function()
                    local args = {"FlowerGarden", "ClaimPlant", i}
                    game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(args))
                end)
                Wait(3)
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
                task.wait(0.1)
            end
            task.spawn(gardenCycle)
        end
    end
})

local function getGift(id)
    local inventory = Save.Get().Inventory
    for i, v in pairs(inventory.Misc) do
        if v.id == id then
            return i, v
        end
    end
end

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
                    local Id, GID = getGift("Seed Bag")
                    if Id and GID then
                        game:GetService("ReplicatedStorage").Network.GiftBag_Open:InvokeServer("Seed Bag")
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

local UltimateCmds = require(game:GetService("ReplicatedStorage").Library.Client.UltimateCmds)

local toggleEnabled = false

local UltimateToggle = MainTab:CreateToggle({
    Name = "Auto Pet Surge Ultimate",
    CurrentValue = false,
    Callback = function(Value)
        toggleEnabled = Value

        task.spawn(function()
            while toggleEnabled do
                local equipped = UltimateCmds.GetEquippedItem()

                if equipped and UltimateCmds.IsCharged(equipped:GetId()) then
                    local success = UltimateCmds.Activate(equipped:GetId())
                    if success then
                        warn("Ultimate activated!")
                    end
                end
                task.wait()
            end
        end)
    end,
})

local DaycareToggle = MainTab:CreateToggle({
    Name = "Auto Daycare",
    CurrentValue = false,
    Flag = "AutoDaycare",
    Callback = function(Value)
        getgenv().AutoDaycare = Value
        task.spawn(function()
            while getgenv().AutoDaycare do
                pcall(function()
                    game:GetService("ReplicatedStorage").Network:FindFirstChild("Daycare: Claim"):InvokeServer()
                    task.wait(1)
                    local args = {
                        [1] = {
                            ["eaeb9f6a690843648d5de16ce151dfe5"] = 55
                        }
                    }
                    game:GetService("ReplicatedStorage").Network:FindFirstChild("Daycare: Enroll"):InvokeServer(unpack(args))
                end)
                task.wait(30) -- przerwa między cyklami, możesz zmienić
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")
local UpdateTimer = Network:WaitForChild("Idle Tracking: Update Timer")
local StopTimer = Network:WaitForChild("Idle Tracking: Stop Timer")

local function sendStopTimer()
    ReplicatedStorage.Network:FindFirstChild("Idle Tracking: Stop Timer"):FireServer()
    print("Wysłano Stop Timer.")
end

task.spawn(function()
    while true do
        local waitTime = math.random(180, 420)
        task.wait(waitTime)  -- Czekaj losowy czas
        sendStopTimer()  -- Wyślij "Stop Timer"
    end
end)
