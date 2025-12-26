--[[
    ════════════════════════════════════════════════════════════════════════════
    AFK MARKET AUTOMATION SCRIPT
    Version: 17.6.1
    Author: Misthios
    Verified by: iPowfu
    ════════════════════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local Version = "17.6.1"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.62/main.lua"))()
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

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
    
    -- Session
    StartTime = os.time()
}

local Stats = {
    Sold = 0,
    Gems = 0,
    CurrentlyListed = 0,
    CurrentTokens = 0,
    Status = "Idle"
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UI CREATION
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateWindow()
    local Window = WindUI:CreateWindow({
        Title = "AFK MARKET",
        SubTitle = "ipowfu verified",
        Author = "Misthios",
        Theme = "Cyber Midnight",
        Icon = "solar:shield-check-bold",
        Transparent = false,
        Acrylic = false,
        TransparencyValue = 0,
        Topbar = {
            Height = 44,
            ButtonsType = "Mac",
            ButtonsPosition = "Right"
        }
    })

    -- Add Tags
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

    -- Connect to token updates
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
            -- Update Uptime
            local diff = os.difftime(os.time(), Config.StartTime)
            local hours = math.floor(diff / 3600)
            local minutes = math.floor((diff % 3600) / 60)
            DashboardButtons.Time:SetTitle(
                string.format("Uptime: %dh %dm", hours, minutes)
            )
            
            -- Update Status
            DashboardButtons.Status:SetTitle("Status: " .. Stats.Status)
            
            -- Update Booth Count
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
        -- Check limits
        if listedCount >= Config.TargetAmount then break end
        if (Stats.CurrentlyListed + listedCount) >= Config.MaxBoothItems then break end
        
        -- Check if item matches target
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
            -- Wait if booth is full
            if Stats.CurrentlyListed >= Config.MaxBoothItems then
                Stats.Status = "Booth Full (Waiting)"
                repeat
                    task.wait(5)
                until Stats.CurrentlyListed < Config.MaxBoothItems or not Config.AutoLoop
                
                if not Config.AutoLoop then break end
            end

            -- List items
            Config.IsRunning = true
            Stats.Status = "Listing Items"
            ScanAndListPets()
            
            -- Wait before next cycle
            Stats.Status = "Standby (Delay)"
            Config.IsRunning = false
            task.wait(Config.LoopDelay)
        end
        
        Stats.Status = "Idle"
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
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local function Initialize()
    -- Register themes
    RegisterThemes()
    
    -- Create window
    local Window = CreateWindow()
    
    -- Create tabs
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
    
    -- Setup tabs
    CreateDashboard(MonitorTab)
    SetupMainTab(MainTab)
    SetupEliteTab(EliteTab)
    SetupSettingsTab(SettingTab)
    
    -- Start systems
    StartDashboardMonitoring()
    StartAntiAFK()
    SetupSalesTracking()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXECUTION
-- ═══════════════════════════════════════════════════════════════════════════

Initialize()
