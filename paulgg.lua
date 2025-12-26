--[[
    ════════════════════════════════════════════════════════════════════════════
    PAULGG - AFK MARKET AUTOMATION
    Version: 17.7.0
    Author: Misthios
    Verified by: iPowfu
    
    NEW: Infinite Trade Submitter + Auto Accept Incoming Trade
    ════════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local Version = "17.7.0"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.62/main.lua"))()
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════
-- THEME DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

local function RegisterThemes()
    WindUI:AddTheme({
        Name = "Cyber Midnight",
        Accent = Color3.fromHex("#7775F2"),
        Background = Color3.fromHex("#050505"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#1A1A1A"),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#444444"),
        Button = Color3.fromHex("#121212"),
        Icon = Color3.fromHex("#7775F2"),
        Hover = Color3.fromHex("#FFFFFF"),
        WindowBackground = Color3.fromHex("#050505"),
        WindowShadow = Color3.fromHex("#000000"),
        TabTitle = Color3.fromHex("#FFFFFF"),
        ElementBackground = Color3.fromHex("#0A0A0A"),
        Toggle = Color3.fromHex("#7775F2"),
        ToggleBar = Color3.fromHex("#FFFFFF"),
    })

    WindUI:AddTheme({
        Name = "Rose Gold",
        Accent = Color3.fromHex("#FF7B9C"),
        Background = Color3.fromHex("#0F0D0E"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#261F22"),
        Text = Color3.fromHex("#FCEFF9"),
        Placeholder = Color3.fromHex("#5E5158"),
        Button = Color3.fromHex("#1C1719"),
        Icon = Color3.fromHex("#FF7B9C"),
        Hover = Color3.fromHex("#FFD1DC"),
        WindowBackground = Color3.fromHex("#0F0D0E"),
        WindowShadow = Color3.fromHex("#000000"),
        TabTitle = Color3.fromHex("#FCEFF9"),
        ElementBackground = Color3.fromHex("#151213"),
        Toggle = Color3.fromHex("#FF7B9C"),
        ToggleBar = Color3.fromHex("#FFFFFF"),
    })

    WindUI:AddTheme({
        Name = "Emerald Forest",
        Accent = Color3.fromHex("#30ff6a"),
        Background = Color3.fromHex("#080D0A"),
        BackgroundTransparency = 0,
        Outline = Color3.fromHex("#141F18"),
        Text = Color3.fromHex("#EFFFF4"),
        Placeholder = Color3.fromHex("#4B5E53"),
        Button = Color3.fromHex("#0F1712"),
        Icon = Color3.fromHex("#30ff6a"),
        Hover = Color3.fromHex("#FFFFFF"),
        WindowBackground = Color3.fromHex("#080D0A"),
        WindowShadow = Color3.fromHex("#000000"),
        TabTitle = Color3.fromHex("#EFFFF4"),
        ElementBackground = Color3.fromHex("#0C120F"),
        Toggle = Color3.fromHex("#30ff6a"),
        ToggleBar = Color3.fromHex("#FFFFFF"),
    })
end

-- ═══════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════

local Config = {
    -- Pet Settings
    TargetName = "",
    MaxWeight = 2.0,
    TargetAmount = 1,
    
    -- Market Settings
    Price = 100,
    MaxBoothItems = 50,
    
    -- Timing Settings
    Delay = 6.0,
    LoopDelay = 10.0,
    
    -- State Management
    IsRunning = false,
    AutoLoop = false,
    
    -- Security
    BlacklistedUUIDs = {},
    PanicOnAdmin = true,
    
    -- Features
    AntiAFK = true,
    WebhookURL = "",
    
    -- Incoming Trade Settings
    AutoAcceptRequest = false,
    
    -- Infinite Trade Submitter
    TradePetName = "",
    TradeMaxWeight = 3.0,
    AutoAccept3Stage = false,
    AutoAddPetLoop = false,
    TradeTargetPlayer = "",
    
    -- Session
    StartTime = os.time()
}

local Stats = {
    Sold = 0,
    Gems = 0,
    CurrentlyListed = 0,
    CurrentTokens = 0,
    Status = "Idle",
    TradesAccepted = 0,
    TradesSent = 0,
    PetsTraded = 0
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UI VISIBILITY MANAGER
-- ═══════════════════════════════════════════════════════════════════════════

local UIManager = {
    IsVisible = true,
    UIInstance = nil,
    ToggleButton = nil
}

function UIManager:Initialize(windowInstance)
    self.UIInstance = windowInstance
    self:CreateToggleButton()
    self:SetupKeybinds()
end

function UIManager:CreateToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PaulGG_Toggle"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(0, 50, 0, 50)
    toggleFrame.Position = UDim2.new(0, 10, 0.5, -25)
    toggleFrame.BackgroundColor3 = Color3.fromHex("#7775F2")
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggleFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "PGG"
    textLabel.TextColor3 = Color3.fromHex("#FFFFFF")
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = toggleFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = toggleFrame
    
    button.MouseEnter:Connect(function()
        toggleFrame.BackgroundColor3 = Color3.fromHex("#9290FF")
    end)
    
    button.MouseLeave:Connect(function()
        if self.IsVisible then
            toggleFrame.BackgroundColor3 = Color3.fromHex("#7775F2")
        else
            toggleFrame.BackgroundColor3 = Color3.fromHex("#444444")
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = toggleFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    toggleFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            toggleFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    self.ToggleButton = screenGui
    
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = CoreGui
    end
end

function UIManager:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert then
            self:Toggle()
        end
    end)
end

function UIManager:Toggle()
    self.IsVisible = not self.IsVisible
    
    if self.UIInstance then
        pcall(function()
            if self.UIInstance.Toggle then
                self.UIInstance:Toggle()
            elseif self.UIInstance.SetVisible then
                self.UIInstance:SetVisible(self.IsVisible)
            elseif self.UIInstance.Visible ~= nil then
                self.UIInstance.Visible = self.IsVisible
            end
        end)
        
        pcall(function()
            local gui = LocalPlayer.PlayerGui:FindFirstChild("WindUI") or 
                       (gethui and gethui():FindFirstChild("WindUI")) or
                       CoreGui:FindFirstChild("WindUI")
            
            if gui then
                gui.Enabled = self.IsVisible
            end
        end)
    end
    
    if self.ToggleButton then
        local frame = self.ToggleButton:FindFirstChild("ToggleFrame")
        if frame then
            if self.IsVisible then
                frame.BackgroundColor3 = Color3.fromHex("#7775F2")
            else
                frame.BackgroundColor3 = Color3.fromHex("#444444")
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UI CREATION
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateWindow()
    local Window = WindUI:CreateWindow({
        Title = "PAULGG MARKET",
        SubTitle = "ipowfu verified",
        Author = "Misthios",
        Theme = "Cyber Midnight",
        Icon = "solar:shield-check-bold",
        Transparent = false,
        Acrylic = false,
        TransparencyValue = 0,
        Topbar = {
            Height = 44,
            ButtonsType = "Windows",
            ButtonsPosition = "Right"
        }
    })

    Window:Tag({
        Title = "iPowfu",
        Icon = "solar:verified-check-bold",
        Color = Color3.fromHex("#30ff6a"),
        Radius = 8,
    })

    Window:Tag({
        Title = "v" .. Version,
        Icon = "github",
        Color = Color3.fromHex("#7775F2"),
        Radius = 8,
    })

    return Window
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DASHBOARD SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

local DashboardButtons = {}

local function CreateDashboard(MonitorTab)
    local DashSec = MonitorTab:Section({ Title = "System Monitor" })
    
    DashboardButtons.Status = DashSec:Button({ Title = "Status: Idle" })
    DashboardButtons.Token = DashSec:Button({ Title = "Wallet: Initializing..." })
    DashboardButtons.Booth = DashSec:Button({ Title = "Booth: 0/50 Items" })
    DashboardButtons.Session = DashSec:Button({ Title = "Session Profit: 0 Tokens" })
    DashboardButtons.Time = DashSec:Button({ Title = "Uptime: 0h 0m" })
    
    local TradeSec = MonitorTab:Section({ Title = "Trade Statistics" })
    DashboardButtons.TradesSent = TradeSec:Button({ Title = "Trades Sent: 0" })
    DashboardButtons.TradesAccepted = TradeSec:Button({ Title = "Incoming Accepted: 0" })
    DashboardButtons.PetsTraded = TradeSec:Button({ Title = "Pets Traded: 0" })
end

local function UpdateTokenDisplay()
    local DataService = require(ReplicatedStorage.Modules.DataService)
    
    local function forceSync()
        local success, data = pcall(function()
            return DataService:GetData()
        end)
        
        if success and data and data.TradeData then
            Stats.CurrentTokens = data.TradeData.Tokens
            DashboardButtons.Token:SetTitle(
                string.format("Wallet: %.0f Tokens", Stats.CurrentTokens)
            )
        end
    end

    DataService:GetPathSignal("TradeData/Tokens"):Connect(forceSync)
    forceSync()
end

local function CountBoothItems()
    local playerGui = LocalPlayer.PlayerGui
    local boothGui = playerGui:FindFirstChild("TradeBooth") or playerGui:FindFirstChild("Booth")
    
    if not boothGui then return 0 end
    
    local listFrame = boothGui:FindFirstChild("List", true) or boothGui:FindFirstChild("ScrollingFrame", true)
    if not listFrame then return 0 end
    
    local count = 0
    for _, child in pairs(listFrame:GetChildren()) do
        local isValidFrame = (child:IsA("Frame") or child:IsA("ImageButton"))
        local isNotAdd = child.Name ~= "Add"
        local isNotUIComponent = not child:IsA("UIComponent")
        local hasItem = child:FindFirstChild("Item", true) or child:FindFirstChild("Price", true)
        
        if isValidFrame and isNotAdd and isNotUIComponent and hasItem then
            count = count + 1
        end
    end
    
    return count
end

local function StartDashboardMonitoring()
    task.spawn(function()
        UpdateTokenDisplay()
        
        while task.wait(1) do
            local diff = os.difftime(os.time(), Config.StartTime)
            local hours = math.floor(diff / 3600)
            local minutes = math.floor((diff % 3600) / 60)
            DashboardButtons.Time:SetTitle(
                string.format("Uptime: %dh %dm", hours, minutes)
            )
            
            DashboardButtons.Status:SetTitle("Status: " .. Stats.Status)
            
            Stats.CurrentlyListed = CountBoothItems()
            DashboardButtons.Booth:SetTitle(
                string.format("Booth: %d/%d Items", Stats.CurrentlyListed, Config.MaxBoothItems)
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCANNING ENGINE
-- ═══════════════════════════════════════════════════════════════════════════

local function ListPetToBooth(item)
    local weight = tonumber(string.match(item.Name, "%d+%.?%d*")) or 0
    local uuid = item:GetAttribute("PET_UUID")
    
    if not uuid then return false end
    if weight > Config.MaxWeight then return false end
    if Config.BlacklistedUUIDs[uuid] then return false end
    
    local success, result = pcall(function()
        return ReplicatedStorage.GameEvents.TradeEvents.Booths.CreateListing:InvokeServer(
            "Pet",
            tostring(uuid),
            Config.Price
        )
    end)
    
    if success and result then
        Config.BlacklistedUUIDs[uuid] = true
        return true
    end
    
    return false
end

local function ScanAndListPets()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack or Config.TargetName == "" then return 0 end
    
    local listedCount = 0
    local targetNameLower = Config.TargetName:lower()
    
    for _, item in pairs(backpack:GetChildren()) do
        if listedCount >= Config.TargetAmount then break end
        if (Stats.CurrentlyListed + listedCount) >= Config.MaxBoothItems then break end
        
        if string.find(item.Name:lower(), targetNameLower) then
            if ListPetToBooth(item) then
                listedCount = listedCount + 1
                task.wait(Config.Delay)
            end
        end
    end
    
    return listedCount
end

function StartRhythmScan()
    Stats.Status = "Scanning"
    
    task.spawn(function()
        while Config.AutoLoop do
            if Stats.CurrentlyListed >= Config.MaxBoothItems then
                Stats.Status = "Booth Full (Waiting)"
                repeat
                    task.wait(5)
                until Stats.CurrentlyListed < Config.MaxBoothItems or not Config.AutoLoop
                
                if not Config.AutoLoop then break end
            end

            Config.IsRunning = true
            Stats.Status = "Listing Items"
            ScanAndListPets()
            
            Stats.Status = "Standby (Delay)"
            Config.IsRunning = false
            task.wait(Config.LoopDelay)
        end
        
        Stats.Status = "Idle"
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INCOMING TRADE AUTO ACCEPT
-- ═══════════════════════════════════════════════════════════════════════════

local IncomingTradeManager = {
    ProcessedRequests = {}
}

function IncomingTradeManager:AutoAccept(data)
    if not Config.AutoAcceptRequest then return end
    
    local requestId = nil
    if type(data) == "string" then
        requestId = data
    elseif type(data) == "table" then
        requestId = data.traderId or data.requestId or data.id
    end
    
    if not requestId or self.ProcessedRequests[requestId] then return end
    
    self.ProcessedRequests[requestId] = true
    
    task.spawn(function()
        task.wait(1)
        
        local success = pcall(function()
            ReplicatedStorage.GameEvents.TradeEvents.RespondRequest:FireServer(requestId, true)
        end)
        
        if success then
            Stats.TradesAccepted = Stats.TradesAccepted + 1
            DashboardButtons.TradesAccepted:SetTitle(
                string.format("Incoming Accepted: %d", Stats.TradesAccepted)
            )
            print("[PAULGG] ✓ Auto-accepted incoming trade: " .. requestId)
        end
    end)
end

function IncomingTradeManager:Start()
    local events = {"RequestReceived", "TradeRequest", "IncomingTrade"}
    
    for _, eventName in pairs(events) do
        pcall(function()
            local event = ReplicatedStorage.GameEvents.TradeEvents:FindFirstChild(eventName)
            if event and event:IsA("RemoteEvent") then
                event.OnClientEvent:Connect(function(data)
                    self:AutoAccept(data)
                end)
            end
        end)
    end
    
    print("[PAULGG] Incoming Trade Auto-Accept initialized")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INFINITE TRADE SUBMITTER
-- ═══════════════════════════════════════════════════════════════════════════

local TradeSubmitter = {
    IsRunning = false,
    CurrentTradeId = nil,
    PetsInTrade = {}
}

function TradeSubmitter:GetPetsByName()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return {} end
    
    local pets = {}
    local targetNameLower = Config.TradePetName:lower()
    
    for _, item in pairs(backpack:GetChildren()) do
        if string.find(item.Name:lower(), targetNameLower) then
            local weight = tonumber(string.match(item.Name, "%d+%.?%d*")) or 0
            local uuid = item:GetAttribute("PET_UUID")
            
            if uuid and weight <= Config.TradeMaxWeight then
                table.insert(pets, {
                    uuid = uuid,
                    name = item.Name,
                    weight = weight
                })
            end
        end
    end
    
    return pets
end

function TradeSubmitter:SendTradeRequest()
    if Config.TradeTargetPlayer == "" then
        print("[PAULGG] ✗ No target player specified")
        return false
    end
    
    local targetPlayer = Players:FindFirstChild(Config.TradeTargetPlayer)
    if not targetPlayer then
        print("[PAULGG] ✗ Target player not found: " .. Config.TradeTargetPlayer)
        return false
    end
    
    local success = pcall(function()
        ReplicatedStorage.GameEvents.TradeEvents.SendRequest:FireServer(targetPlayer)
    end)
    
    if success then
        Stats.TradesSent = Stats.TradesSent + 1
        DashboardButtons.TradesSent:SetTitle(
            string.format("Trades Sent: %d", Stats.TradesSent)
        )
        print("[PAULGG] ✓ Trade request sent to: " .. Config.TradeTargetPlayer)
        return true
    else
        print("[PAULGG] ✗ Failed to send trade request")
        return false
    end
end

function TradeSubmitter:AddPetToTrade(petUUID)
    local success = pcall(function()
        ReplicatedStorage.GameEvents.TradeEvents.AddItem:FireServer("Pet", petUUID)
    end)
    
    if success then
        table.insert(self.PetsInTrade, petUUID)
        Stats.PetsTraded = Stats.PetsTraded + 1
        DashboardButtons.PetsTraded:SetTitle(
            string.format("Pets Traded: %d", Stats.PetsTraded)
        )
        print("[PAULGG] ✓ Pet added to trade: " .. petUUID)
        return true
    else
        print("[PAULGG] ✗ Failed to add pet: " .. petUUID)
        return false
    end
end

function TradeSubmitter:ConfirmTrade()
    local success = pcall(function()
        ReplicatedStorage.GameEvents.TradeEvents.Confirm:FireServer()
    end)
    
    if success then
        print("[PAULGG] ✓ Trade confirmed")
        return true
    else
        print("[PAULGG] ✗ Failed to confirm trade")
        return false
    end
end

function TradeSubmitter:Execute3StageTrade()
    if self.IsRunning then
        print("[PAULGG] Trade already in progress")
        return
    end
    
    self.IsRunning = true
    self.PetsInTrade = {}
    
    task.spawn(function()
        print("[PAULGG] Starting 3-Stage Trade...")
        
        -- Stage 1: Send trade request
        if not self:SendTradeRequest() then
            self.IsRunning = false
            return
        end
        
        task.wait(3)
        
        -- Stage 2: Add pets
        local pets = self:GetPetsByName()
        if #pets == 0 then
            print("[PAULGG] ✗ No pets found matching criteria")
            self.IsRunning = false
            return
        end
        
        print("[PAULGG] Found " .. #pets .. " pets to trade")
        
        for i, pet in ipairs(pets) do
            if self:AddPetToTrade(pet.uuid) then
                print(string.format("[PAULGG] Added pet %d/%d: %s (%.1fkg)", i, #pets, pet.name, pet.weight))
                task.wait(0.5)
            end
        end
        
        task.wait(2)
        
        -- Stage 3: Confirm
        if Config.AutoAccept3Stage then
            self:ConfirmTrade()
        else
            print("[PAULGG] ⚠ Auto-accept disabled. Please confirm manually.")
        end
        
        self.IsRunning = false
        print("[PAULGG] Trade sequence completed")
    end)
end

function TradeSubmitter:StartAutoLoop()
    task.spawn(function()
        while Config.AutoAddPetLoop do
            if not self.IsRunning then
                self:Execute3StageTrade()
            end
            
            task.wait(15) -- Wait 15 seconds between trades
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ANTI-AFK SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

local function StartAntiAFK()
    task.spawn(function()
        while task.wait(10) do
            if Config.AntiAFK then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.Jump = true
                end
                
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SALES TRACKING
-- ═══════════════════════════════════════════════════════════════════════════

local function SetupSalesTracking()
    ReplicatedStorage.GameEvents.TradeEvents.Booths.AddToHistory.OnClientEvent:Connect(function(data)
        if not data or not data.seller then return end
        if data.seller.userId ~= LocalPlayer.UserId then return end
        
        Stats.Sold = Stats.Sold + 1
        Stats.Gems = Stats.Gems + (data.price or 0)
        
        DashboardButtons.Session:SetTitle(
            string.format("Session Profit: %d Tokens", Stats.Gems)
        )
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UI TABS SETUP
-- ═══════════════════════════════════════════════════════════════════════════

local function SetupMainTab(MainTab)
    local TargetSec = MainTab:Section({ Title = "Pet Configuration" })
    
    TargetSec:Input({
        Title = "Nama Pet Target",
        Callback = function(value)
            Config.TargetName = value
        end
    })
    
    TargetSec:Input({
        Title = "Set Harga Jual",
        Callback = function(value)
            Config.Price = tonumber(value) or 100
        end
    })
    
    TargetSec:Input({
        Title = "Jumlah Pet Per Siklus",
        Value = "1",
        Callback = function(value)
            Config.TargetAmount = tonumber(value) or 1
        end
    })
    
    local ExecutionSec = MainTab:Section({ Title = "Execution" })
    ExecutionSec:Toggle({
        Title = "Auto Rhythm Active",
        Value = false,
        Callback = function(state)
            Config.AutoLoop = state
            if state then
                StartRhythmScan()
            end
        end
    })
end

local function SetupTradeTab(TradeTab)
    -- Incoming Trade Section
    local IncomingSec = TradeTab:Section({ Title = "Incoming Trade" })
    
    IncomingSec:Toggle({
        Title = "Auto Accept Request",
        Description = "Automatically accept incoming trade requests",
        Value = false,
        Callback = function(value)
            Config.AutoAcceptRequest = value
            if value then
                print("[PAULGG] Auto Accept Request ENABLED")
            else
                print("[PAULGG] Auto Accept Request DISABLED")
            end
        end
    })
    
    -- Infinite Trade Submitter Section
    local SubmitterSec = TradeTab:Section({ Title = "Infinite Trade Submitter" })
    
    SubmitterSec:Input({
        Title = "Nama Pet (Trade)",
        Placeholder = "Enter Text...",
        Callback = function(value)
            Config.TradePetName = value
            print("[PAULGG] Trade Pet Name: " .. value)
        end
    })
    
    SubmitterSec:Input({
        Title = "Max Weight (Trade)",
        Value = "3.0",
        Callback = function(value)
            local weight = tonumber(value)
            if weight and weight > 0 then
                Config.TradeMaxWeight = weight
                print("[PAULGG] Max Trade Weight: " .. weight)
            end
        end
    })
    
    SubmitterSec:Input({
        Title = "Target Player Name",
        Placeholder = "Enter username...",
        Callback = function(value)
            Config.TradeTargetPlayer = value
            print("[PAULGG] Target Player: " .. value)
        end
    })
    
    SubmitterSec:Toggle({
        Title = "Auto Accept (3-Stage)",
        Description = "Auto confirm trade after adding pets",
        Value = false,
        Callback = function(value)
            Config.AutoAccept3Stage = value
        end
    })
    
    SubmitterSec:Toggle({
        Title = "Auto Add Pet Loop",
        Description = "Continuously send trades with pets",
        Value = false,
        Callback = function(value)
            Config.AutoAddPetLoop = value
            if value then
                TradeSubmitter:StartAutoLoop()
                print("[PAULGG] Auto Trade Loop ENABLED")
            else
                print("[PAULGG] Auto Trade Loop DISABLED")
            end
        end
    })
    
    SubmitterSec:Button({
        Title = "Execute Single Trade",
        Description = "Send one trade with configured pets",
        Callback = function()
            TradeSubmitter:Execute3StageTrade()
        end
    })
end

local function SetupEliteTab(EliteTab)
    local EliteSec = EliteTab:Section({ Title = "Elite AFK Protection" })
    
    EliteSec:Toggle({
        Title = "Anti-AFK Jump",
        Value = true,
        Callback = function(value)
            Config.AntiAFK = value
        end
    })
end

local function SetupSettingsTab(SettingTab)
    local SetSec = SettingTab:Section({ Title = "System Connection" })
    
    SetSec:Input({
        Title = "Webhook URL",
        Callback = function(value)
            Config.WebhookURL = value
        end
    })
    
    local InfoSec = SettingTab:Section({ Title = "Controls" })
    InfoSec:Button({
        Title = "Toggle UI: Right Control / Insert",
        Callback = function()
            UIManager:Toggle()
        end
    })
    
    InfoSec:Button({
        Title = "Clear Trade Cache",
        Callback = function()
            IncomingTradeManager.ProcessedRequests = {}
            TradeSubmitter.PetsInTrade = {}
            print("[PAULGG] Trade cache cleared")
        end
    })
    
    local DebugSec = SettingTab:Section({ Title = "Debug Tools" })
    DebugSec:Button({
        Title = "List Available Pets",
        Callback = function()
            local pets = TradeSubmitter:GetPetsByName()
            print("[PAULGG] Found " .. #pets .. " pets:")
            for i, pet in ipairs(pets) do
                print(string.format("  %d. %s (%.1fkg) - %s", i, pet.name, pet.weight, pet.uuid))
            end
        end
    })
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local function Initialize()
    RegisterThemes()
    
    local Window = CreateWindow()
    
    UIManager:Initialize(Window)
    
    local MonitorTab = Window:Tab({
        Title = "Dashboard",
        Icon = "solar:chart-bold",
        IconColor = Color3.fromHex("#AF52DE")
    })
    
    local MainTab = Window:Tab({
        Title = "Scanner",
        Icon = "solar:scanner-bold",
        IconColor = Color3.fromHex("#007AFF")
    })
    
    local TradeTab = Window:Tab({
        Title = "Trade System",
        Icon = "solar:hand-shake-bold",
        IconColor = Color3.fromHex("#FF9500")
    })
    
    local EliteTab = Window:Tab({
        Title = "AFK Perks",
        Icon = "solar:ghost-bold",
        IconColor = Color3.fromHex("#FF3B30")
    })
    
    local SettingTab = Window:Tab({
        Title = "Settings",
        Icon = "solar:settings-bold",
        IconColor = Color3.fromHex("#8E8E93")
    })
    
    CreateDashboard(MonitorTab)
    SetupMainTab(MainTab)
    SetupTradeTab(TradeTab)
    SetupEliteTab(EliteTab)
    SetupSettingsTab(SettingTab)
    
    StartDashboardMonitoring()
    IncomingTradeManager:Start()
    StartAntiAFK()
    SetupSalesTracking()
    
    print("═══════════════════════════════════════")
    print("PAULGG v" .. Version .. " Loaded!")
    print("Toggle UI: Right Control or Insert Key")
    print("NEW: Trade System with Auto-Accept!")
    print("═══════════════════════════════════════")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXECUTION
-- ═══════════════════════════════════════════════════════════════════════════

Initialize()
