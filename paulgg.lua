--[[
    ════════════════════════════════════════════════════════════════════════════
    PAULGG - AFK MARKET AUTOMATION
    Version: 17.6.2
    Author: Misthios
    Verified by: iPowfu
    
    NEW: Auto Trade Ticket System
    ════════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local Version = "17.6.2"
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
    -- Cyber Midnight Theme
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

    -- Rose Gold Theme
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

    -- Emerald Forest Theme
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
    
    -- Auto Trade Ticket
    AutoTradeTicket = false,
    TradeTicketDelay = 5,
    
    -- Session
    StartTime = os.time()
}

local Stats = {
    Sold = 0,
    Gems = 0,
    CurrentlyListed = 0,
    CurrentTokens = 0,
    Status = "Idle",
    TradesAccepted = 0
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
    DashboardButtons.Trades = DashSec:Button({ Title = "Trades Accepted: 0" })
    DashboardButtons.Time = DashSec:Button({ Title = "Uptime: 0h 0m" })
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
-- AUTO TRADE TICKET SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

local TradeTicketManager = {
    IsProcessing = false,
    LastTradeId = nil,
    TradeQueue = {},
    ProcessedTrades = {}
}

function TradeTicketManager:ProcessTrade(tradeId)
    if self.ProcessedTrades[tradeId] then
        print("[PAULGG] Trade already processed: " .. tradeId)
        return
    end
    
    if self.IsProcessing then
        table.insert(self.TradeQueue, tradeId)
        print("[PAULGG] Trade queued: " .. tradeId)
        return
    end
    
    self.IsProcessing = true
    self.LastTradeId = tradeId
    self.ProcessedTrades[tradeId] = true
    
    task.spawn(function()
        print("[PAULGG] Processing trade: " .. tradeId)
        
        -- Step 1: Wait 5 seconds
        task.wait(Config.TradeTicketDelay)
        
        -- Step 2: Accept trade request
        local success1 = pcall(function()
            ReplicatedStorage.GameEvents.TradeEvents.RespondRequest:FireServer(tradeId, true)
        end)
        
        if success1 then
            print("[PAULGG] ✓ Trade request accepted")
            
            -- Wait for UI to appear
            task.wait(2)
            
            -- Step 3: Click "Yes" button in confirmation GUI
            local clickedYes = false
            pcall(function()
                local playerGui = LocalPlayer.PlayerGui
                
                for _, gui in pairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local yesButton = gui:FindFirstChild("Yes", true) or
                                         gui:FindFirstChild("Accept", true) or
                                         gui:FindFirstChild("Confirm", true) or
                                         gui:FindFirstChild("OK", true)
                        
                        if yesButton then
                            if yesButton:IsA("TextButton") or yesButton:IsA("ImageButton") then
                                pcall(function()
                                    for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                                        connection:Fire()
                                    end
                                end)
                                
                                pcall(function()
                                    for _, connection in pairs(getconnections(yesButton.Activated)) do
                                        connection:Fire()
                                    end
                                end)
                                
                                clickedYes = true
                                print("[PAULGG] ✓ Confirmation clicked")
                                break
                            end
                        end
                    end
                end
            end)
            
            if not clickedYes then
                print("[PAULGG] ⚠ Could not find confirmation button")
            end
            
            -- Step 4: Wait 5 seconds again
            task.wait(Config.TradeTicketDelay)
            
            -- Step 5: Final accept
            local success3 = pcall(function()
                ReplicatedStorage.GameEvents.TradeEvents.RespondRequest:FireServer(tradeId, true)
            end)
            
            if success3 then
                Stats.TradesAccepted = Stats.TradesAccepted + 1
                DashboardButtons.Trades:SetTitle(
                    string.format("Trades Accepted: %d", Stats.TradesAccepted)
                )
                print("[PAULGG] ✓ Trade completed successfully! Total: " .. Stats.TradesAccepted)
            end
        else
            print("[PAULGG] ✗ Failed to accept trade request")
        end
        
        self.IsProcessing = false
        
        if #self.TradeQueue > 0 then
            local nextTrade = table.remove(self.TradeQueue, 1)
            task.wait(1)
            self:ProcessTrade(nextTrade)
        end
    end)
end

function TradeTicketManager:Start()
    local events = {
        "RequestReceived",
        "TradeRequest",
        "IncomingTrade",
        "NewTradeRequest"
    }
    
    for _, eventName in pairs(events) do
        pcall(function()
            local event = ReplicatedStorage.GameEvents.TradeEvents:FindFirstChild(eventName)
            if event and event:IsA("RemoteEvent") then
                event.OnClientEvent:Connect(function(data)
                    if not Config.AutoTradeTicket then return end
                    
                    local tradeId = nil
                    if type(data) == "string" then
                        tradeId = data
                    elseif type(data) == "table" then
                        tradeId = data.traderId or data.tradeId or data.id or data.uuid
                    end
                    
                    if tradeId then
                        print("[PAULGG] Trade request received via " .. eventName .. ": " .. tostring(tradeId))
                        self:ProcessTrade(tostring(tradeId))
                    end
                end)
                print("[PAULGG] Listening to event: " .. eventName)
            end
        end)
    end
    
    print("[PAULGG] Auto Trade Ticket system initialized")
end

local function StartAutoTradeTicket()
    TradeTicketManager:Start()
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

local function SetupEliteTab(EliteTab)
    local EliteSec = EliteTab:Section({ Title = "Elite AFK Protection" })
    
    EliteSec:Toggle({
        Title = "Anti-AFK Jump",
        Value = true,
        Callback = function(value)
            Config.AntiAFK = value
        end
    })
    
    local TradeSec = EliteTab:Section({ Title = "Auto Trade Ticket" })
    
    TradeSec:Toggle({
        Title = "Enable Auto Trade Accept",
        Description = "Sequence: 5s > Accept > Yes > 5s > Accept",
        Value = false,
        Callback = function(value)
            Config.AutoTradeTicket = value
            if value then
                print("[PAULGG] Auto Trade Ticket ENABLED")
                print("[PAULGG] Sequence: Wait 5s > Accept > Click Yes > Wait 5s > Accept")
            else
                print("[PAULGG] Auto Trade Ticket DISABLED")
            end
        end
    })
    
    TradeSec:Input({
        Title = "Delay Between Actions (seconds)",
        Value = "5",
        Callback = function(value)
            local delay = tonumber(value)
            if delay and delay > 0 and delay <= 60 then
                Config.TradeTicketDelay = delay
                print("[PAULGG] Trade delay set to: " .. delay .. "s")
            else
                print("[PAULGG] Invalid delay. Use 1-60 seconds.")
            end
        end
    })
    
    TradeSec:Button({
        Title = "Test Manual Trade Accept",
        Description = "Click to manually test trade acceptance",
        Callback = function()
            print("[PAULGG] Testing manual trade accept...")
            print("[PAULGG] Send a trade request to test the system")
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
        Title = "Clear Processed Trades Cache",
        Callback = function()
            TradeTicketManager.ProcessedTrades = {}
            print("[PAULGG] Trade cache cleared")
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
    SetupEliteTab(EliteTab)
    SetupSettingsTab(SettingTab)
    
    StartDashboardMonitoring()
    StartAutoTradeTicket()
    StartAntiAFK()
    SetupSalesTracking()
    
    print("═══════════════════════════════════════")
    print("PAULGG v" .. Version .. " Loaded!")
    print("Toggle UI: Right Control or Insert Key")
    print("Draggable Button: Left Side of Screen")
    print("NEW: Auto Trade Ticket System Added!")
    print("═══════════════════════════════════════")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXECUTION
-- ═══════════════════════════════════════════════════════════════════════════

Initialize()
