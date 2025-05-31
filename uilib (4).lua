local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local MAX_HEIGHT = 10
local MAX_AIR_TIME = 4.5
local COOLDOWN_TIME = 10
local FLIGHT_KEY = Enum.KeyCode.X
local ASCENT_SPEED = 18
local RECHARGE_RATE = 0.45 -- Air time added per second when grounded
local COOLDOWN_RECHARGE_RATE = 1.5 -- Cooldown reduction per second when not flying

-- State variables
local isFlying = false
local airTimeRemaining = MAX_AIR_TIME
local cooldownRemaining = 0
local baseHeight = 0
local flightEnabled = true
local rechargeHandle = nil
local cooldownRechargeHandle = nil

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 120)
mainFrame.Position = UDim2.new(0.5, -120, 1, -130)
mainFrame.AnchorPoint = Vector2.new(0.5, 1)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Resize handle
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = "↘"
resizeHandle.TextColor3 = Color3.fromRGB(200, 200, 200)
resizeHandle.TextSize = 14
resizeHandle.Parent = mainFrame

local isResizing = false
resizeHandle.MouseButton1Down:Connect(function()
    isResizing = true
    local startPos = UserInputService:GetMouseLocation()
    local startSize = mainFrame.AbsoluteSize
    
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isResizing then
            local currentPos = UserInputService:GetMouseLocation()
            local newSize = startSize + (currentPos - startPos)
            mainFrame.Size = UDim2.new(0, math.max(240, newSize.X), 0, math.max(120, newSize.Y))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = false
            connection:Disconnect()
        end
    end)
end)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Height display
local heightFrame = Instance.new("Frame")
heightFrame.Size = UDim2.new(1, -10, 0.25, -5)
heightFrame.Position = UDim2.new(0, 5, 0, 5)
heightFrame.BackgroundTransparency = 1
heightFrame.Parent = mainFrame

local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(0.7, 0, 1, 0)
heightLabel.Position = UDim2.new(0, 0, 0, 0)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "Height: 0.0 studs"
heightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
heightLabel.TextSize = 16
heightLabel.Font = Enum.Font.SourceSansSemibold
heightLabel.Parent = heightFrame

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0.3, -5, 1, 0)
resetButton.Position = UDim2.new(0.7, 0, 0, 0)
resetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetButton.BackgroundTransparency = 0.3
resetButton.Text = "Reset Stud"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextSize = 14
resetButton.Font = Enum.Font.SourceSansSemibold
resetButton.Parent = heightFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetButton

-- Timer display
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -10, 0.25, -5)
timerLabel.Position = UDim2.new(0, 5, 0.25, 5)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Air Time: 4.5s"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 16
timerLabel.Font = Enum.Font.SourceSansSemibold
timerLabel.Parent = mainFrame

-- Status display
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0.2, -5)
statusLabel.Position = UDim2.new(0, 5, 0.5, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainFrame

-- Cooldown display
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Size = UDim2.new(1, -10, 0.2, -5)
cooldownLabel.Position = UDim2.new(0, 5, 0.7, 5)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.Text = "Cooldown: 0.0s"
cooldownLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
cooldownLabel.TextSize = 14
cooldownLabel.Font = Enum.Font.SourceSans
cooldownLabel.Parent = mainFrame

-- Cooldown progress bar
local cooldownBar = Instance.new("Frame")
cooldownBar.Size = UDim2.new(1, -10, 0.1, 0)
cooldownBar.Position = UDim2.new(0, 5, 0.9, 5)
cooldownBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
cooldownBar.BorderSizePixel = 0
cooldownBar.Parent = mainFrame

local cooldownProgress = Instance.new("Frame")
cooldownProgress.Size = UDim2.new(0, 0, 1, 0)
cooldownProgress.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
cooldownProgress.BorderSizePixel = 0
cooldownProgress.Parent = cooldownBar

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 4)
barCorner.Parent = cooldownBar

-- Reset button functionality
resetButton.MouseButton1Click:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        baseHeight = character.HumanoidRootPart.Position.Y
        print("Base height reset to current position")
    end
end)

-- Recharge systems
local function manageRecharge()
    while true do
        local dt = RunService.Heartbeat:Wait()
        local character = LocalPlayer.Character
        local isGrounded = character and character:FindFirstChild("HumanoidRootPart") and (character.HumanoidRootPart.Position.Y - baseHeight) < MAX_HEIGHT * 0.5
        
        -- Air time recharge
        if not isFlying and flightEnabled and airTimeRemaining < MAX_AIR_TIME and isGrounded then
            airTimeRemaining = math.min(MAX_AIR_TIME, airTimeRemaining + (RECHARGE_RATE * dt))
            timerLabel.Text = string.format("Air Time: %.1fs", airTimeRemaining)
            timerLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
        end
        
        -- Cooldown recharge (active even while flying)
        if cooldownRemaining > 0 then
            local rechargeAmount = COOLDOWN_RECHARGE_RATE * dt
            cooldownRemaining = math.max(0, cooldownRemaining - rechargeAmount)
            
            -- If cooldown completes during flight
            if cooldownRemaining <= 0 and not flightEnabled then
                flightEnabled = true
                airTimeRemaining = MAX_AIR_TIME
                statusLabel.Text = "Flying" -- Will update to "Ready" when flight ends
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                cooldownLabel.Text = "Cooldown: 0.0s"
            end
            
            -- Update cooldown display
            cooldownLabel.Text = string.format("Cooldown: %.1fs", cooldownRemaining)
            cooldownProgress.Size = UDim2.new(1 - (cooldownRemaining/COOLDOWN_TIME), 0, 1, 0)
        end
    end
end

-- Flight control function
local function controlFlight()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local currentHeight = hrp.Position.Y - baseHeight
    
    -- Update height display
    heightLabel.Text = string.format("Height: %.1f studs", currentHeight)
    
    -- Visual height warnings
    if currentHeight >= MAX_HEIGHT - 1 then
        heightLabel.TextColor3 = currentHeight >= MAX_HEIGHT and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 200, 150)
    else
        heightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    -- Flight logic
    if isFlying and flightEnabled then
        -- Apply upward force if below max height
        if currentHeight < MAX_HEIGHT then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, ASCENT_SPEED, hrp.Velocity.Z)
        else
            hrp.Velocity = Vector3.new(hrp.Velocity.X, math.min(0, hrp.Velocity.Y), hrp.Velocity.Z)
        end
        
        -- Update air time
        airTimeRemaining = math.max(0, airTimeRemaining - RunService.Heartbeat:Wait())
        timerLabel.Text = string.format("Air Time: %.1fs", airTimeRemaining)
        
        -- Handle air time expiration
        if airTimeRemaining <= 0 then
            isFlying = false
            flightEnabled = false
            cooldownRemaining = COOLDOWN_TIME
            statusLabel.Text = "Cooldown"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        -- Air time warnings
        timerLabel.TextColor3 = airTimeRemaining < 1 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
    elseif not isFlying and flightEnabled then
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= FLIGHT_KEY then return end
    
    if flightEnabled then
        isFlying = true
        statusLabel.Text = "Flying"
        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == FLIGHT_KEY then
        isFlying = false
    end
end)

-- Initialize systems
spawn(manageRecharge)
RunService.Heartbeat:Connect(controlFlight)

-- Handle screen resizing
game:GetService("GuiService"):GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    mainFrame.Position = UDim2.new(0.5, -120, 1, -130)
end)
