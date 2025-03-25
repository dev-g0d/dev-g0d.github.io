-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

-- Player Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = game.Workspace.CurrentCamera
local mouse = player:GetMouse()

-- Remove existing GUI if any
if playerGui:FindFirstChild("CheatMenu") then
    playerGui:FindFirstChild("CheatMenu"):Destroy()
end

-- Variables
local Atmosphere = Lighting.Atmosphere
local ColorCorrection = Lighting.ColorCorrection
local defaultDensity = Atmosphere.Density
local defaultBrightness = ColorCorrection.Brightness
local defaultContrast = ColorCorrection.Contrast
local defaultShadows = Lighting.GlobalShadows
local defaultClockTime = Lighting.ClockTime
local shadowsEnabled = defaultShadows
local SelectedPlayer = nil
local isAuraEnabled = false
local currentHighlights = {}
local flyEnabled = false
local speedEnabled = false
local flySpeed = 50
local customSpeed = 50
local defaultSpeed = 16
local bodyVelocity = nil
local bodyGyro = nil
local isHoverEnabled = true
local isESPEnabled = false
local espInstances = {}
local isInvisible = false
local keybindsEnabled = true
local isCollapsed = false
local invisChair = nil
local ghostGui = nil
local safeZonePos = Vector3.new(0, 1000, 0)
local invisDebounce = false
local noclipEnabled = false
local noclipConnection = nil
local guiEnabled = true

-- Main GUI Setup
local Gui = Instance.new("ScreenGui")
Gui.Parent = playerGui
Gui.ResetOnSpawn = false
Gui.Name = "CheatMenu"
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 1000

local BackGround = Instance.new("Frame")
BackGround.Parent = Gui
BackGround.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
BackGround.Size = UDim2.new(0, 300, 0, 300)
BackGround.Position = UDim2.new(0.5, -150, 0.5, -150)
BackGround.Active = true
BackGround.Draggable = true
BackGround.BorderSizePixel = 0
BackGround.ZIndex = 1000

local BackGroundCorner = Instance.new("UICorner")
BackGroundCorner.CornerRadius = UDim.new(0, 16)
BackGroundCorner.Parent = BackGround

local TitleBar = Instance.new("Frame")
TitleBar.Parent = BackGround
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 1001

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.Text = "🌟 สคริปต์โดย g0d 🌟"
TitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.ZIndex = 1002

local CollapseButton = Instance.new("TextButton")
CollapseButton.Parent = TitleBar
CollapseButton.Size = UDim2.new(0, 30, 0, 30)
CollapseButton.Position = UDim2.new(1, -80, 0, 0)
CollapseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CollapseButton.Text = "-"
CollapseButton.TextColor3 = Color3.fromRGB(255, 215, 0)
CollapseButton.Font = Enum.Font.SourceSansBold
CollapseButton.TextSize = 18
CollapseButton.BorderSizePixel = 0
CollapseButton.ZIndex = 1002

local CollapseButtonCorner = Instance.new("UICorner")
CollapseButtonCorner.CornerRadius = UDim.new(0, 8)
CollapseButtonCorner.Parent = CollapseButton

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 1002

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 8)
CloseButtonCorner.Parent = CloseButton

-- Content ScrollingFrame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = BackGround
ContentFrame.BackgroundTransparency = 1
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
ContentFrame.ScrollBarThickness = 8
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
ContentFrame.ZIndex = 1001

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Teleport Section
local TeleportLabel = Instance.new("TextLabel")
TeleportLabel.Parent = ContentFrame
TeleportLabel.Size = UDim2.new(0, 260, 0, 20)
TeleportLabel.BackgroundTransparency = 1
TeleportLabel.Text = "------ เทเลพอร์ต ------"
TeleportLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TeleportLabel.Font = Enum.Font.SourceSansSemibold
TeleportLabel.TextSize = 14
TeleportLabel.ZIndex = 1002

local OpenSelectionButton = Instance.new("TextButton")
OpenSelectionButton.Parent = ContentFrame
OpenSelectionButton.Size = UDim2.new(0, 260, 0, 40)
OpenSelectionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenSelectionButton.TextColor3 = Color3.fromRGB(255, 215, 0)
OpenSelectionButton.Font = Enum.Font.SourceSansSemibold
OpenSelectionButton.Text = "เลือกผู้เล่น"
OpenSelectionButton.TextSize = 18
OpenSelectionButton.BorderSizePixel = 0
OpenSelectionButton.ZIndex = 1002

local OpenSelectionButtonCorner = Instance.new("UICorner")
OpenSelectionButtonCorner.CornerRadius = UDim.new(0, 12)
OpenSelectionButtonCorner.Parent = OpenSelectionButton

local DropdownButton = Instance.new("TextButton")
DropdownButton.Parent = ContentFrame
DropdownButton.Size = UDim2.new(0, 260, 0, 40)
DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DropdownButton.Text = "ค่าเริ่มต้น"
DropdownButton.TextColor3 = Color3.fromRGB(255, 215, 0)
DropdownButton.Font = Enum.Font.SourceSansSemibold
DropdownButton.TextSize = 18
DropdownButton.BorderSizePixel = 0
DropdownButton.ZIndex = 1002

local DropdownButtonCorner = Instance.new("UICorner")
DropdownButtonCorner.CornerRadius = UDim.new(0, 12)
DropdownButtonCorner.Parent = DropdownButton

local DropdownFrame = Instance.new("Frame")
DropdownFrame.Parent = ContentFrame
DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DropdownFrame.Size = UDim2.new(0, 260, 0, 100)
DropdownFrame.Position = UDim2.new(0.5, -130, 0, 110)
DropdownFrame.Visible = false
DropdownFrame.BorderSizePixel = 0
DropdownFrame.ZIndex = 1003

local positions = {"ค่าเริ่มต้น", "ซ้าย", "ขวา", "หน้า", "หลัง"}
for i, pos in ipairs(positions) do
    local OptionButton = Instance.new("TextButton")
    OptionButton.Parent = DropdownFrame
    OptionButton.Size = UDim2.new(1, 0, 0, 20)
    OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 20)
    OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    OptionButton.Text = pos
    OptionButton.TextColor3 = Color3.fromRGB(255, 215, 0)
    OptionButton.Font = Enum.Font.SourceSansSemibold
    OptionButton.TextSize = 14
    OptionButton.BorderSizePixel = 0
    OptionButton.ZIndex = 1004

    OptionButton.MouseButton1Click:Connect(function()
        DropdownButton.Text = pos
        DropdownFrame.Visible = false
    end)
end

local TeleportButton = Instance.new("TextButton")
TeleportButton.Parent = ContentFrame
TeleportButton.Size = UDim2.new(0, 260, 0, 40)
TeleportButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
TeleportButton.Text = "เทเลพอร์ต"
TeleportButton.TextColor3 = Color3.fromRGB(255, 215, 0)
TeleportButton.Font = Enum.Font.SourceSansSemibold
TeleportButton.TextSize = 18
TeleportButton.BorderSizePixel = 0
TeleportButton.ZIndex = 1002

local TeleportButtonCorner = Instance.new("UICorner")
TeleportButtonCorner.CornerRadius = UDim.new(0, 12)
TeleportButtonCorner.Parent = TeleportButton

-- Item Finder Section
local ItemFinderLabel = Instance.new("TextLabel")
ItemFinderLabel.Parent = ContentFrame
ItemFinderLabel.Size = UDim2.new(0, 260, 0, 20)
ItemFinderLabel.BackgroundTransparency = 1
ItemFinderLabel.Text = "------ ค้นหาไอเทม ------"
ItemFinderLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ItemFinderLabel.Font = Enum.Font.SourceSansSemibold
ItemFinderLabel.TextSize = 14
ItemFinderLabel.ZIndex = 1002

local OpenItemFinderButton = Instance.new("TextButton")
OpenItemFinderButton.Parent = ContentFrame
OpenItemFinderButton.Size = UDim2.new(0, 260, 0, 40)
OpenItemFinderButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenItemFinderButton.Text = "เปิดหน้าต่างค้นหาไอเทม"
OpenItemFinderButton.TextColor3 = Color3.fromRGB(255, 215, 0)
OpenItemFinderButton.Font = Enum.Font.SourceSansSemibold
OpenItemFinderButton.TextSize = 18
OpenItemFinderButton.BorderSizePixel = 0
OpenItemFinderButton.ZIndex = 1002

local OpenItemFinderButtonCorner = Instance.new("UICorner")
OpenItemFinderButtonCorner.CornerRadius = UDim.new(0, 12)
OpenItemFinderButtonCorner.Parent = OpenItemFinderButton

-- Lighting Control Section
local LightingControlLabel = Instance.new("TextLabel")
LightingControlLabel.Parent = ContentFrame
LightingControlLabel.Size = UDim2.new(0, 260, 0, 20)
LightingControlLabel.BackgroundTransparency = 1
LightingControlLabel.Text = "------ ควบคุมแสง ------"
LightingControlLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
LightingControlLabel.Font = Enum.Font.SourceSansSemibold
LightingControlLabel.TextSize = 14
LightingControlLabel.ZIndex = 1002

local OpenLightingControlButton = Instance.new("TextButton")
OpenLightingControlButton.Parent = ContentFrame
OpenLightingControlButton.Size = UDim2.new(0, 260, 0, 40)
OpenLightingControlButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenLightingControlButton.Text = "ควบคุม"
OpenLightingControlButton.TextColor3 = Color3.fromRGB(255, 215, 0)
OpenLightingControlButton.Font = Enum.Font.SourceSansSemibold
OpenLightingControlButton.TextSize = 18
OpenLightingControlButton.BorderSizePixel = 0
OpenLightingControlButton.ZIndex = 1002

local OpenLightingControlButtonCorner = Instance.new("UICorner")
OpenLightingControlButtonCorner.CornerRadius = UDim.new(0, 12)
OpenLightingControlButtonCorner.Parent = OpenLightingControlButton

-- General Section
local GeneralLabel = Instance.new("TextLabel")
GeneralLabel.Parent = ContentFrame
GeneralLabel.Size = UDim2.new(0, 260, 0, 20)
GeneralLabel.BackgroundTransparency = 1
GeneralLabel.Text = "------ ทั่วไป ------"
GeneralLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
GeneralLabel.Font = Enum.Font.SourceSansSemibold
GeneralLabel.TextSize = 14
GeneralLabel.ZIndex = 1002

local FlyButton = Instance.new("TextButton")
FlyButton.Parent = ContentFrame
FlyButton.Size = UDim2.new(0, 260, 0, 40)
FlyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyButton.Text = "บิน (F)"
FlyButton.TextColor3 = Color3.fromRGB(255, 215, 0)
FlyButton.Font = Enum.Font.SourceSansSemibold
FlyButton.TextSize = 18
FlyButton.BorderSizePixel = 0
FlyButton.ZIndex = 1002

local FlyButtonCorner = Instance.new("UICorner")
FlyButtonCorner.CornerRadius = UDim.new(0, 12)
FlyButtonCorner.Parent = FlyButton

local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = ContentFrame
SpeedFrame.Size = UDim2.new(0, 260, 0, 40)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.ZIndex = 1002

local SpeedButton = Instance.new("TextButton")
SpeedButton.Parent = SpeedFrame
SpeedButton.Size = UDim2.new(0, 180, 0, 40)
SpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedButton.Text = "วิ่งเร็ว (Z)"
SpeedButton.TextColor3 = Color3.fromRGB(255, 215, 0)
SpeedButton.Font = Enum.Font.SourceSansSemibold
SpeedButton.TextSize = 18
SpeedButton.BorderSizePixel = 0
SpeedButton.ZIndex = 1002

local SpeedButtonCorner = Instance.new("UICorner")
SpeedButtonCorner.CornerRadius = UDim.new(0, 12)
SpeedButtonCorner.Parent = SpeedButton

local SpeedInput = Instance.new("TextBox")
SpeedInput.Parent = SpeedFrame
SpeedInput.Size = UDim2.new(0, 70, 0, 40)
SpeedInput.Position = UDim2.new(0, 190, 0, 0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedInput.Text = "50"
SpeedInput.TextColor3 = Color3.fromRGB(255, 215, 0)
SpeedInput.Font = Enum.Font.SourceSansSemibold
SpeedInput.TextSize = 18
SpeedInput.BorderSizePixel = 0
SpeedInput.ZIndex = 1002

local SpeedInputCorner = Instance.new("UICorner")
SpeedInputCorner.CornerRadius = UDim.new(0, 12)
SpeedInputCorner.Parent = SpeedInput

local ESPButton = Instance.new("TextButton")
ESPButton.Parent = ContentFrame
ESPButton.Size = UDim2.new(0, 260, 0, 40)
ESPButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ESPButton.Text = "ESP: ปิด"
ESPButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ESPButton.Font = Enum.Font.SourceSansSemibold
ESPButton.TextSize = 18
ESPButton.BorderSizePixel = 0
ESPButton.ZIndex = 1002

local ESPButtonCorner = Instance.new("UICorner")
ESPButtonCorner.CornerRadius = UDim.new(0, 12)
ESPButtonCorner.Parent = ESPButton

local InvisibleButton = Instance.new("TextButton")
InvisibleButton.Parent = ContentFrame
InvisibleButton.Size = UDim2.new(0, 260, 0, 40)
InvisibleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InvisibleButton.Text = "ล่องหน (X)"
InvisibleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
InvisibleButton.Font = Enum.Font.SourceSansSemibold
InvisibleButton.TextSize = 18
InvisibleButton.BorderSizePixel = 0
InvisibleButton.ZIndex = 1002

local InvisibleButtonCorner = Instance.new("UICorner")
InvisibleButtonCorner.CornerRadius = UDim.new(0, 12)
InvisibleButtonCorner.Parent = InvisibleButton

local NoclipButton = Instance.new("TextButton")
NoclipButton.Parent = ContentFrame
NoclipButton.Size = UDim2.new(0, 260, 0, 40)
NoclipButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NoclipButton.Text = "No-Clip (N)"
NoclipButton.TextColor3 = Color3.fromRGB(255, 215, 0)
NoclipButton.Font = Enum.Font.SourceSansSemibold
NoclipButton.TextSize = 18
NoclipButton.BorderSizePixel = 0
NoclipButton.ZIndex = 1002

local NoclipButtonCorner = Instance.new("UICorner")
NoclipButtonCorner.CornerRadius = UDim.new(0, 12)
NoclipButtonCorner.Parent = NoclipButton

local RejoinFrame = Instance.new("Frame")
RejoinFrame.Parent = ContentFrame
RejoinFrame.Size = UDim2.new(0, 260, 0, 40)
RejoinFrame.BackgroundTransparency = 1
RejoinFrame.ZIndex = 1002

local RejoinButton = Instance.new("TextButton")
RejoinButton.Parent = RejoinFrame
RejoinButton.Size = UDim2.new(0, 180, 0, 40)
RejoinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
RejoinButton.Text = "รีจอย"
RejoinButton.TextColor3 = Color3.fromRGB(255, 215, 0)
RejoinButton.Font = Enum.Font.SourceSansSemibold
RejoinButton.TextSize = 18
RejoinButton.BorderSizePixel = 0
RejoinButton.ZIndex = 1002

local RejoinButtonCorner = Instance.new("UICorner")
RejoinButtonCorner.CornerRadius = UDim.new(0, 12)
RejoinButtonCorner.Parent = RejoinButton

local KeybindButton = Instance.new("TextButton")
KeybindButton.Parent = RejoinFrame
KeybindButton.Size = UDim2.new(0, 70, 0, 40)
KeybindButton.Position = UDim2.new(0, 190, 0, 0)
KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeybindButton.Text = "Keys: เปิด"
KeybindButton.TextColor3 = Color3.fromRGB(255, 215, 0)
KeybindButton.Font = Enum.Font.SourceSansSemibold
KeybindButton.TextSize = 18
KeybindButton.BorderSizePixel = 0
KeybindButton.ZIndex = 1002

local KeybindButtonCorner = Instance.new("UICorner")
KeybindButtonCorner.CornerRadius = UDim.new(0, 12)
KeybindButtonCorner.Parent = KeybindButton

-- Player Selection Frame
local SelectionFrame = Instance.new("Frame")
SelectionFrame.Parent = Gui
SelectionFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
SelectionFrame.Size = UDim2.new(0, 720, 0, 450)
SelectionFrame.Position = UDim2.new(0.5, -360, 0.5, -225)
SelectionFrame.Visible = false
SelectionFrame.Active = true
SelectionFrame.Draggable = true
SelectionFrame.BorderSizePixel = 0
SelectionFrame.ZIndex = 1000

local SelectionFrameCorner = Instance.new("UICorner")
SelectionFrameCorner.CornerRadius = UDim.new(0, 16)
SelectionFrameCorner.Parent = SelectionFrame

local SelectionTitleBar = Instance.new("Frame")
SelectionTitleBar.Parent = SelectionFrame
SelectionTitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SelectionTitleBar.Size = UDim2.new(1, 0, 0, 40)
SelectionTitleBar.BorderSizePixel = 0
SelectionTitleBar.ZIndex = 1001

local SelectionTitleBarCorner = Instance.new("UICorner")
SelectionTitleBarCorner.CornerRadius = UDim.new(0, 16)
SelectionTitleBarCorner.Parent = SelectionTitleBar

local SelectionTitleLabel = Instance.new("TextLabel")
SelectionTitleLabel.Parent = SelectionTitleBar
SelectionTitleLabel.BackgroundTransparency = 1
SelectionTitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
SelectionTitleLabel.Position = UDim2.new(0, 10, 0, 0)
SelectionTitleLabel.Text = "เลือกผู้เล่นเพื่อเทเลพอร์ต"
SelectionTitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
SelectionTitleLabel.Font = Enum.Font.SourceSansBold
SelectionTitleLabel.TextSize = 18
SelectionTitleLabel.ZIndex = 1002

local CloseSelectionButton = Instance.new("TextButton")
CloseSelectionButton.Parent = SelectionTitleBar
CloseSelectionButton.Size = UDim2.new(0, 30, 0, 30)
CloseSelectionButton.Position = UDim2.new(1, -40, 0, 5)
CloseSelectionButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseSelectionButton.Text = "X"
CloseSelectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseSelectionButton.Font = Enum.Font.SourceSansBold
CloseSelectionButton.TextSize = 18
CloseSelectionButton.BorderSizePixel = 0
CloseSelectionButton.ZIndex = 1002

local CloseSelectionButtonCorner = Instance.new("UICorner")
CloseSelectionButtonCorner.CornerRadius = UDim.new(0, 8)
CloseSelectionButtonCorner.Parent = CloseSelectionButton

local SelectionContent = Instance.new("ScrollingFrame")
SelectionContent.Parent = SelectionFrame
SelectionContent.BackgroundTransparency = 1
SelectionContent.Size = UDim2.new(1, 0, 1, -50)
SelectionContent.Position = UDim2.new(0, 0, 0, 40)
SelectionContent.CanvasSize = UDim2.new(0, 0, 0, 0)
SelectionContent.ScrollBarThickness = 8
SelectionContent.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
SelectionContent.ZIndex = 1001

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.Parent = SelectionContent
UIGridLayout.CellSize = UDim2.new(0, 130, 0, 150)
UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
UIGridLayout.FillDirectionMaxCells = 5

-- Item Finder Window Setup
local ItemFinderFrame = Instance.new("Frame")
ItemFinderFrame.Parent = Gui
ItemFinderFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ItemFinderFrame.Size = UDim2.new(0, 300, 0, 300)
ItemFinderFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
ItemFinderFrame.Visible = false
ItemFinderFrame.Active = true
ItemFinderFrame.Draggable = true
ItemFinderFrame.BorderSizePixel = 0
ItemFinderFrame.ZIndex = 1000

local ItemFinderFrameCorner = Instance.new("UICorner")
ItemFinderFrameCorner.CornerRadius = UDim.new(0, 16)
ItemFinderFrameCorner.Parent = ItemFinderFrame

local ItemFinderTitleBar = Instance.new("Frame")
ItemFinderTitleBar.Parent = ItemFinderFrame
ItemFinderTitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ItemFinderTitleBar.Size = UDim2.new(1, 0, 0, 30)
ItemFinderTitleBar.BorderSizePixel = 0
ItemFinderTitleBar.ZIndex = 1001

local ItemFinderTitleBarCorner = Instance.new("UICorner")
ItemFinderTitleBarCorner.CornerRadius = UDim.new(0, 16)
ItemFinderTitleBarCorner.Parent = ItemFinderTitleBar

local ItemFinderTitleLabel = Instance.new("TextLabel")
ItemFinderTitleLabel.Parent = ItemFinderTitleBar
ItemFinderTitleLabel.BackgroundTransparency = 1
ItemFinderTitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
ItemFinderTitleLabel.Position = UDim2.new(0, 10, 0, 0)
ItemFinderTitleLabel.Text = "ค้นหาไอเทม"
ItemFinderTitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
ItemFinderTitleLabel.Font = Enum.Font.SourceSansBold
ItemFinderTitleLabel.TextSize = 18
ItemFinderTitleLabel.ZIndex = 1002

local ItemFinderCloseButton = Instance.new("TextButton")
ItemFinderCloseButton.Parent = ItemFinderTitleBar
ItemFinderCloseButton.Size = UDim2.new(0, 30, 0, 30)
ItemFinderCloseButton.Position = UDim2.new(1, -40, 0, 0)
ItemFinderCloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ItemFinderCloseButton.Text = "X"
ItemFinderCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ItemFinderCloseButton.Font = Enum.Font.SourceSansBold
ItemFinderCloseButton.TextSize = 18
ItemFinderCloseButton.BorderSizePixel = 0
ItemFinderCloseButton.ZIndex = 1002

local ItemFinderCloseButtonCorner = Instance.new("UICorner")
ItemFinderCloseButtonCorner.CornerRadius = UDim.new(0, 8)
ItemFinderCloseButtonCorner.Parent = ItemFinderCloseButton

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = ItemFinderFrame
NameLabel.Size = UDim2.new(0, 280, 0, 40)
NameLabel.Position = UDim2.new(0, 10, 0, 40)
NameLabel.BackgroundTransparency = 0.5
NameLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
NameLabel.TextScaled = true
NameLabel.Text = "เล็งไปที่ไอเทม"
NameLabel.Font = Enum.Font.SourceSansSemibold
NameLabel.TextSize = 18
NameLabel.ZIndex = 1002

local NameLabelCorner = Instance.new("UICorner")
NameLabelCorner.CornerRadius = UDim.new(0, 12)
NameLabelCorner.Parent = NameLabel

local InputFrame = Instance.new("Frame")
InputFrame.Parent = ItemFinderFrame
InputFrame.Size = UDim2.new(0, 280, 0, 40)
InputFrame.Position = UDim2.new(0, 10, 0, 90)
InputFrame.BackgroundTransparency = 1
InputFrame.ZIndex = 1002

local TextBox = Instance.new("TextBox")
TextBox.Parent = InputFrame
TextBox.Size = UDim2.new(0, 240, 0, 40)
TextBox.Position = UDim2.new(0, 0, 0, 0)
TextBox.BackgroundTransparency = 0.5
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TextBox.TextColor3 = Color3.fromRGB(255, 215, 0)
TextBox.TextScaled = true
TextBox.PlaceholderText = "พิมพ์ชื่อไอเทม คั่นด้วยคอมมา (เช่น ATM, Coal)"
TextBox.Font = Enum.Font.SourceSansSemibold
TextBox.TextSize = 18
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.ZIndex = 1002

local TextBoxCorner = Instance.new("UICorner")
TextBoxCorner.CornerRadius = UDim.new(0, 12)
TextBoxCorner.Parent = TextBox

local ExpandButton = Instance.new("TextButton")
ExpandButton.Parent = InputFrame
ExpandButton.Size = UDim2.new(0, 30, 0, 30)
ExpandButton.Position = UDim2.new(0, 245, 0, 5)
ExpandButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ExpandButton.Text = "+"
ExpandButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ExpandButton.Font = Enum.Font.SourceSansBold
ExpandButton.TextSize = 18
ExpandButton.BorderSizePixel = 0
ExpandButton.ZIndex = 1002

local ExpandButtonCorner = Instance.new("UICorner")
ExpandButtonCorner.CornerRadius = UDim.new(0, 8)
ExpandButtonCorner.Parent = ExpandButton

local ItemTeleportButton = Instance.new("TextButton")
ItemTeleportButton.Parent = ItemFinderFrame
ItemTeleportButton.Size = UDim2.new(0, 280, 0, 40)
ItemTeleportButton.Position = UDim2.new(0, 10, 0, 140)
ItemTeleportButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ItemTeleportButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ItemTeleportButton.TextScaled = true
ItemTeleportButton.Text = "เทเลพอร์ตไปที่ไอเทม"
ItemTeleportButton.Font = Enum.Font.SourceSansSemibold
ItemTeleportButton.TextSize = 18
ItemTeleportButton.ZIndex = 1002

local ItemTeleportButtonCorner = Instance.new("UICorner")
ItemTeleportButtonCorner.CornerRadius = UDim.new(0, 12)
ItemTeleportButtonCorner.Parent = ItemTeleportButton

local AuraButton = Instance.new("TextButton")
AuraButton.Parent = ItemFinderFrame
AuraButton.Size = UDim2.new(0, 280, 0, 40)
AuraButton.Position = UDim2.new(0, 10, 0, 190)
AuraButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
AuraButton.TextColor3 = Color3.fromRGB(255, 215, 0)
AuraButton.TextScaled = true
AuraButton.Text = "ออร่า: ปิด"
AuraButton.Font = Enum.Font.SourceSansSemibold
AuraButton.TextSize = 18
AuraButton.ZIndex = 1002

local AuraButtonCorner = Instance.new("UICorner")
AuraButtonCorner.CornerRadius = UDim.new(0, 12)
AuraButtonCorner.Parent = AuraButton

-- Large TextBox Window for Item Finder
local LargeTextFrame = Instance.new("Frame")
LargeTextFrame.Parent = Gui
LargeTextFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LargeTextFrame.Size = UDim2.new(0, 400, 0, 300)
LargeTextFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
LargeTextFrame.Visible = false
LargeTextFrame.Active = true
LargeTextFrame.Draggable = true
LargeTextFrame.BorderSizePixel = 0
LargeTextFrame.ZIndex = 1005

local LargeTextFrameCorner = Instance.new("UICorner")
LargeTextFrameCorner.CornerRadius = UDim.new(0, 16)
LargeTextFrameCorner.Parent = LargeTextFrame

local LargeTextTitleBar = Instance.new("Frame")
LargeTextTitleBar.Parent = LargeTextFrame
LargeTextTitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LargeTextTitleBar.Size = UDim2.new(1, 0, 0, 30)
LargeTextTitleBar.BorderSizePixel = 0
LargeTextTitleBar.ZIndex = 1006

local LargeTextTitleBarCorner = Instance.new("UICorner")
LargeTextTitleBarCorner.CornerRadius = UDim.new(0, 16)
LargeTextTitleBarCorner.Parent = LargeTextTitleBar

local LargeTextTitleLabel = Instance.new("TextLabel")
LargeTextTitleLabel.Parent = LargeTextTitleBar
LargeTextTitleLabel.BackgroundTransparency = 1
LargeTextTitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
LargeTextTitleLabel.Position = UDim2.new(0, 10, 0, 0)
LargeTextTitleLabel.Text = "แก้ไขรายชื่อไอเทม"
LargeTextTitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
LargeTextTitleLabel.Font = Enum.Font.SourceSansBold
LargeTextTitleLabel.TextSize = 18
LargeTextTitleLabel.ZIndex = 1007

local LargeTextCloseButton = Instance.new("TextButton")
LargeTextCloseButton.Parent = LargeTextTitleBar
LargeTextCloseButton.Size = UDim2.new(0, 30, 0, 30)
LargeTextCloseButton.Position = UDim2.new(1, -40, 0, 0)
LargeTextCloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LargeTextCloseButton.Text = "X"
LargeTextCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LargeTextCloseButton.Font = Enum.Font.SourceSansBold
LargeTextCloseButton.TextSize = 18
LargeTextCloseButton.BorderSizePixel = 0
LargeTextCloseButton.ZIndex = 1007

local LargeTextCloseButtonCorner = Instance.new("UICorner")
LargeTextCloseButtonCorner.CornerRadius = UDim.new(0, 8)
LargeTextCloseButtonCorner.Parent = LargeTextCloseButton

local LargeTextBox = Instance.new("TextBox")
LargeTextBox.Parent = LargeTextFrame
LargeTextBox.Size = UDim2.new(0, 380, 0, 250)
LargeTextBox.Position = UDim2.new(0, 10, 0, 40)
LargeTextBox.BackgroundTransparency = 0.5
LargeTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LargeTextBox.TextColor3 = Color3.fromRGB(255, 215, 0)
LargeTextBox.TextSize = 18
LargeTextBox.Font = Enum.Font.SourceSansSemibold
LargeTextBox.Text = ""
LargeTextBox.MultiLine = true
LargeTextBox.ClearTextOnFocus = false
LargeTextBox.TextWrapped = true
LargeTextBox.ZIndex = 1006

local LargeTextBoxCorner = Instance.new("UICorner")
LargeTextBoxCorner.CornerRadius = UDim.new(0, 12)
LargeTextBoxCorner.Parent = LargeTextBox

-- Lighting Control Window Setup
local LightingControlFrame = Instance.new("Frame")
LightingControlFrame.Parent = Gui
LightingControlFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
LightingControlFrame.Size = UDim2.new(0, 350, 0, 380)
LightingControlFrame.Position = UDim2.new(0.5, -175, 0.5, -190)
LightingControlFrame.Visible = false
LightingControlFrame.Active = true
LightingControlFrame.Draggable = false
LightingControlFrame.BorderSizePixel = 0
LightingControlFrame.ZIndex = 1000

local LightingControlFrameCorner = Instance.new("UICorner")
LightingControlFrameCorner.CornerRadius = UDim.new(0, 16)
LightingControlFrameCorner.Parent = LightingControlFrame

local LightingControlTitleBar = Instance.new("Frame")
LightingControlTitleBar.Parent = LightingControlFrame
LightingControlTitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LightingControlTitleBar.Size = UDim2.new(1, 0, 0, 40)
LightingControlTitleBar.BorderSizePixel = 0
LightingControlTitleBar.ZIndex = 1001

local LightingControlTitleBarCorner = Instance.new("UICorner")
LightingControlTitleBarCorner.CornerRadius = UDim.new(0, 16)
LightingControlTitleBarCorner.Parent = LightingControlTitleBar

local LightingControlTitleLabel = Instance.new("TextLabel")
LightingControlTitleLabel.Parent = LightingControlTitleBar
LightingControlTitleLabel.BackgroundTransparency = 1
LightingControlTitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
LightingControlTitleLabel.Position = UDim2.new(0, 10, 0, 0)
LightingControlTitleLabel.Text = "🌟 Visual Control 🌟"
LightingControlTitleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
LightingControlTitleLabel.Font = Enum.Font.SourceSansBold
LightingControlTitleLabel.TextSize = 20
LightingControlTitleLabel.ZIndex = 1002

local LightingControlMinimizeButton = Instance.new("TextButton")
LightingControlMinimizeButton.Parent = LightingControlTitleBar
LightingControlMinimizeButton.Size = UDim2.new(0, 30, 0, 30)
LightingControlMinimizeButton.Position = UDim2.new(1, -60, 0, 5)
LightingControlMinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LightingControlMinimizeButton.Text = "-"
LightingControlMinimizeButton.TextColor3 = Color3.fromRGB(255, 215, 0)
LightingControlMinimizeButton.TextSize = 18
LightingControlMinimizeButton.BorderSizePixel = 0
LightingControlMinimizeButton.ZIndex = 1002

local LightingControlMinimizeButtonCorner = Instance.new("UICorner")
LightingControlMinimizeButtonCorner.CornerRadius = UDim.new(0, 8)
LightingControlMinimizeButtonCorner.Parent = LightingControlMinimizeButton

local LightingControlCloseButton = Instance.new("TextButton")
LightingControlCloseButton.Parent = LightingControlTitleBar
LightingControlCloseButton.Size = UDim2.new(0, 30, 0, 30)
LightingControlCloseButton.Position = UDim2.new(1, -30, 0, 5)
LightingControlCloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LightingControlCloseButton.Text = "X"
LightingControlCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LightingControlCloseButton.TextSize = 18
LightingControlCloseButton.BorderSizePixel = 0
LightingControlCloseButton.ZIndex = 1002

local LightingControlCloseButtonCorner = Instance.new("UICorner")
LightingControlCloseButtonCorner.CornerRadius = UDim.new(0, 8)
LightingControlCloseButtonCorner.Parent = LightingControlCloseButton

local LightingControlContentFrame = Instance.new("Frame")
LightingControlContentFrame.Parent = LightingControlFrame
LightingControlContentFrame.Size = UDim2.new(1, 0, 1, -40)
LightingControlContentFrame.Position = UDim2.new(0, 0, 0, 40)
LightingControlContentFrame.BackgroundTransparency = 1
LightingControlContentFrame.ZIndex = 1001

-- Lighting Control Functions
local function createSlider(name, min, max, default, yPos, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 40)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = LightingControlContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = name
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.6, 0, 0.3, 0)
    slider.Position = UDim2.new(0.4, 0, 0.35, 0)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    slider.Parent = sliderFrame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = slider

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Parent = slider

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 8)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.Parent = slider

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function updateValue(ratio)
        local value = min + (max - min) * ratio
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        local knobPos = math.clamp(ratio, 0, 1)
        knob.Position = UDim2.new(knobPos, -8, 0.5, -8)
        callback(value)
        return value
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not lightingDragging then
            dragging = true
            local sliderPos = input.Position.X - slider.AbsolutePosition.X
            local ratio = math.clamp(sliderPos / slider.AbsoluteSize.X, 0, 1)
            updateValue(ratio)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderPos = input.Position.X - slider.AbsolutePosition.X
            local ratio = math.clamp(sliderPos / slider.AbsoluteSize.X, 0, 1)
            updateValue(ratio)
        end
    end)

    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local function setValue(value)
        local ratio = (value - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        local knobPos = math.clamp(ratio, 0, 1)
        knob.Position = UDim2.new(knobPos, -8, 0.5, -8)
    end

    return sliderFrame, setValue, updateValue
end

local densitySlider, setDensityValue, updateDensityValue
local brightnessSlider, setBrightnessValue, updateBrightnessValue
local contrastSlider, setContrastValue, updateContrastValue
local clockTimeSlider, setClockTimeValue, updateClockTimeValue

densitySlider, setDensityValue, updateDensityValue = createSlider("ความหนาแน่น", 0, 1, defaultDensity, 10, function(value)
    Atmosphere.Density = value
end)

brightnessSlider, setBrightnessValue, updateBrightnessValue = createSlider("ความสว่าง", -1, 1, defaultBrightness, 60, function(value)
    ColorCorrection.Brightness = value
end)

contrastSlider, setContrastValue, updateContrastValue = createSlider("ความคมชัด", -1, 1, defaultContrast, 110, function(value)
    ColorCorrection.Contrast = value
end)

clockTimeSlider, setClockTimeValue, updateClockTimeValue = createSlider("เวลาในเกม", 0, 24, defaultClockTime, 160, function(value)
    Lighting.ClockTime = value
end)

local shadowToggleButton = Instance.new("TextButton")
shadowToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
shadowToggleButton.Position = UDim2.new(0.05, 0, 0, 210)
shadowToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shadowToggleButton.Text = shadowsEnabled and "เงา: เปิด" or "เงา: ปิด"
shadowToggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
shadowToggleButton.TextSize = 16
shadowToggleButton.Font = Enum.Font.SourceSansSemibold
shadowToggleButton.Parent = LightingControlContentFrame

local shadowToggleCorner = Instance.new("UICorner")
shadowToggleCorner.CornerRadius = UDim.new(0, 12)
shadowToggleCorner.Parent = shadowToggleButton

shadowToggleButton.MouseButton1Click:Connect(function()
    shadowsEnabled = not shadowsEnabled
    Lighting.GlobalShadows = shadowsEnabled
    shadowToggleButton.Text = shadowsEnabled and "เงา: เปิด" or "เงา: ปิด"
    shadowToggleButton.BackgroundColor3 = shadowsEnabled and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(60, 60, 60)
end)

local restoreButton = Instance.new("TextButton")
restoreButton.Size = UDim2.new(1, 0, 0, 35)
restoreButton.Position = UDim2.new(0, 0, 1, -50)
restoreButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
restoreButton.Text = "คืนค่าเริ่มต้น"
restoreButton.TextColor3 = Color3.fromRGB(255, 215, 0)
restoreButton.TextSize = 16
restoreButton.Parent = LightingControlContentFrame

local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(0, 12)
restoreCorner.Parent = restoreButton

local function restoreDefaults()
    Atmosphere.Density = defaultDensity
    ColorCorrection.Brightness = defaultBrightness
    ColorCorrection.Contrast = defaultContrast
    Lighting.ClockTime = defaultClockTime
    Lighting.GlobalShadows = defaultShadows
    shadowsEnabled = defaultShadows
    shadowToggleButton.Text = shadowsEnabled and "เงา: เปิด" or "เงา: ปิด"
    shadowToggleButton.BackgroundColor3 = shadowsEnabled and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(60, 60, 60)
    setDensityValue(defaultDensity)
    setBrightnessValue(defaultBrightness)
    setContrastValue(defaultContrast)
    setClockTimeValue(defaultClockTime)
end

restoreButton.MouseButton1Click:Connect(restoreDefaults)

local isLightingControlMinimized = false
LightingControlMinimizeButton.MouseButton1Click:Connect(function()
    isLightingControlMinimized = not isLightingControlMinimized
    if isLightingControlMinimized then
        LightingControlFrame.Size = UDim2.new(0, 350, 0, 40)
        LightingControlContentFrame.Visible = false
        LightingControlMinimizeButton.Text = "+"
    else
        LightingControlFrame.Size = UDim2.new(0, 350, 0, 380)
        LightingControlContentFrame.Visible = true
        LightingControlMinimizeButton.Text = "-"
    end
end)

LightingControlCloseButton.MouseButton1Click:Connect(function()
    restoreDefaults()
    LightingControlFrame.Visible = false
end)

local lightingDragging = false
local lightingDragStart = nil
local lightingStartPos = nil

LightingControlTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        lightingDragging = true
        lightingDragStart = input.Position
        lightingStartPos = LightingControlFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if lightingDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - lightingDragStart
        local newPos = UDim2.new(
            lightingStartPos.X.Scale,
            lightingStartPos.X.Offset + delta.X,
            lightingStartPos.Y.Scale,
            lightingStartPos.Y.Offset + delta.Y
        )
        LightingControlFrame.Position = newPos
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        lightingDragging = false
    end
end)

-- Functions
local function UpdatePlayerList()
    for _, v in pairs(SelectionContent:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    
    local playerCount = #Players:GetPlayers()
    SelectionContent.CanvasSize = UDim2.new(0, 0, 0, math.ceil(playerCount / 5) * 165)
    
    for _, plr in pairs(Players:GetPlayers()) do
        local PlayerFrame = Instance.new("Frame")
        PlayerFrame.Parent = SelectionContent
        PlayerFrame.Size = UDim2.new(0, 130, 0, 150)
        PlayerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        PlayerFrame.BorderSizePixel = 0
        PlayerFrame.ZIndex = 1002
        
        local PlayerFrameCorner = Instance.new("UICorner")
        PlayerFrameCorner.CornerRadius = UDim.new(0, 12)
        PlayerFrameCorner.Parent = PlayerFrame
        
        local Thumbnail = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        local PlayerImage = Instance.new("ImageLabel")
        PlayerImage.Parent = PlayerFrame
        PlayerImage.Size = UDim2.new(0, 110, 0, 110)
        PlayerImage.Position = UDim2.new(0.5, -55, 0, 5)
        PlayerImage.BackgroundTransparency = 1
        PlayerImage.Image = Thumbnail
        PlayerImage.BorderSizePixel = 0
        PlayerImage.ZIndex = 1002
        
        local PlayerButton = Instance.new("TextButton")
        PlayerButton.Parent = PlayerFrame
        PlayerButton.Size = UDim2.new(0, 110, 0, 30)
        PlayerButton.Position = UDim2.new(0.5, -55, 1, -35)
        PlayerButton.Text = plr.Name
        PlayerButton.TextSize = 16
        PlayerButton.TextColor3 = Color3.fromRGB(255, 215, 0)
        PlayerButton.Font = Enum.Font.SourceSansSemibold
        PlayerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        PlayerButton.BorderSizePixel = 0
        PlayerButton.ZIndex = 1002
        
        local PlayerButtonCorner = Instance.new("UICorner")
        PlayerButtonCorner.CornerRadius = UDim.new(0, 12)
        PlayerButtonCorner.Parent = PlayerButton
        
        PlayerButton.MouseButton1Click:Connect(function()
            OpenSelectionButton.Text = plr.Name
            SelectedPlayer = plr
            SelectionFrame.Visible = false
        end)
    end
end

local function clearHighlights()
    for _, highlight in pairs(currentHighlights) do
        if highlight then highlight:Destroy() end
    end
    currentHighlights = {}
end

local function clearESP()
    for _, esp in pairs(espInstances) do
        if esp then esp:Destroy() end
    end
    espInstances = {}
end

local function resetAllExploits()
    if flyEnabled then toggleFly() end
    if speedEnabled then toggleSpeed() end
    if isESPEnabled then toggleESP() end
    if isInvisible then toggleInvisible() end
    if isAuraEnabled then
        isAuraEnabled = false
        AuraButton.Text = "ออร่า: ปิด"
        clearHighlights()
    end
    if noclipEnabled then toggleNoclip() end
    restoreDefaults()
    LightingControlFrame.Visible = false
end

local function toggleCollapse()
    isCollapsed = not isCollapsed
    if isCollapsed then
        BackGround.Size = UDim2.new(0, 300, 0, 30)
        ContentFrame.Visible = false
        CollapseButton.Text = "+"
    else
        BackGround.Size = UDim2.new(0, 300, 0, 300)
        ContentFrame.Visible = true
        CollapseButton.Text = "-"
    end
end

local function toggleFly()
    flyEnabled = not flyEnabled
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if flyEnabled then
        humanoid.PlatformStand = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = humanoidRootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = humanoidRootPart.CFrame
        bodyGyro.Parent = humanoidRootPart

        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local moveDirection = Vector3.new(0, 0, 0)
            local cameraCFrame = camera.CFrame

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cameraCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cameraCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cameraCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cameraCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end

            bodyVelocity.Velocity = moveDirection * flySpeed
            bodyGyro.CFrame = cameraCFrame
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        humanoid.PlatformStand = false
        FlyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

local function toggleSpeed()
    speedEnabled = not speedEnabled
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if speedEnabled then
        local speedValue = tonumber(SpeedInput.Text)
        if speedValue and speedValue > 0 then
            customSpeed = speedValue
            humanoid.WalkSpeed = customSpeed
            SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        else
            speedEnabled = false
            humanoid.WalkSpeed = defaultSpeed
            SpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    else
        humanoid.WalkSpeed = defaultSpeed
        SpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

local function updateESP()
    clearESP()
    if not isESPEnabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.8
            highlight.OutlineTransparency = 0.2
            highlight.Adornee = plr.Character
            highlight.Parent = plr.Character
            table.insert(espInstances, highlight)

            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = plr.Character:FindFirstChild("Head")
            billboard.Parent = plr.Character

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0, 20)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Text = plr.Name
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = billboard

            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, 0, 0, 20)
            distanceLabel.Position = UDim2.new(0, 0, 0, 20)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            distanceLabel.TextScaled = true
            distanceLabel.Font = Enum.Font.SourceSansSemibold
            distanceLabel.Parent = billboard

            table.insert(espInstances, billboard)

            RunService.RenderStepped:Connect(function()
                if not isESPEnabled or not plr.Character or not plr.Character:FindFirstChild("Head") or not player.Character then
                    distanceLabel.Text = ""
                    return
                end
                local distance = (player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                distanceLabel.Text = math.floor(distance) .. " studs"
            end)
        end
    end
end

local function toggleESP()
    isESPEnabled = not isESPEnabled
    ESPButton.Text = "ESP: " .. (isESPEnabled and "เปิด" or "ปิด")
    if isESPEnabled then
        ESPButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        updateESP()
    else
        ESPButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        clearESP()
    end
end

local function createGhostGui()
    ghostGui = Instance.new("BillboardGui")
    ghostGui.Size = UDim2.new(0, 100, 0, 50)
    ghostGui.StudsOffset = Vector3.new(0, 3, 0)
    ghostGui.Adornee = character:FindFirstChild("Head")
    ghostGui.AlwaysOnTop = true
    ghostGui.Parent = character:FindFirstChild("Head")

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = "[GHOST]"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    textLabel.Parent = ghostGui

    coroutine.wrap(function()
        local hue = 0
        while ghostGui do
            hue = (hue + 0.005) % 1
            textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end)()
end

local function removeGhostGui()
    if ghostGui then
        ghostGui:Destroy()
        ghostGui = nil
    end
end

local function updateGhostGuiSize()
    if ghostGui and camera and character:FindFirstChild("Head") then
        local distance = (camera.CFrame.Position - character.Head.Position).Magnitude
        local size = math.clamp(1000 / distance, 50, 200)
        ghostGui.Size = UDim2.new(0, size, 0, size / 2)
    end
end

local function toggleInvisible()
    if invisDebounce then return end
    invisDebounce = true

    isInvisible = not isInvisible
    if isInvisible then
        local savedPos = humanoidRootPart.CFrame
        humanoidRootPart.CFrame = CFrame.new(safeZonePos)
        task.wait(0.1)

        invisChair = Instance.new("Seat")
        invisChair.Anchored = false
        invisChair.CanCollide = false
        invisChair.Transparency = 1
        invisChair.Name = "invischair"
        invisChair.Position = safeZonePos
        invisChair.Parent = game.Workspace

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = invisChair
        weld.Part1 = humanoidRootPart
        weld.Parent = invisChair

        task.wait(0.1)
        invisChair.CFrame = savedPos

        if not isInvisible then return end
        InvisibleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        createGhostGui()
    else
        if invisChair then
            invisChair:Destroy()
            invisChair = nil
        end
        if isInvisible then return end
        InvisibleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        removeGhostGui()
    end

    task.wait(0.2)
    invisDebounce = false
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if noclipEnabled then
        NoclipButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        NoclipButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

local function toggleKeybinds()
    keybindsEnabled = not keybindsEnabled
    KeybindButton.Text = "Keys: " .. (keybindsEnabled and "เปิด" or "ปิด")
    KeybindButton.BackgroundColor3 = keybindsEnabled and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(255, 0, 0)
end

-- Item Finder Functions
RunService.RenderStepped:Connect(function()
    if not isHoverEnabled or not ItemFinderFrame.Visible then return end
    local target = mouse.Target
    if target and target:IsA("BasePart") and target.Parent then
        local model = target.Parent
        if model:IsA("Model") then
            NameLabel.Text = model.Name
        else
            NameLabel.Text = target.Name
        end
    else
        NameLabel.Text = "เล็งไปที่ไอเทม"
    end
end)

-- Link TextBox and LargeTextBox
TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    LargeTextBox.Text = TextBox.Text
end)

LargeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    TextBox.Text = LargeTextBox.Text
end)

ExpandButton.MouseButton1Click:Connect(function()
    LargeTextFrame.Visible = true
    LargeTextBox.Text = TextBox.Text
end)

LargeTextCloseButton.MouseButton1Click:Connect(function()
    LargeTextFrame.Visible = false
    TextBox.Text = LargeTextBox.Text
end)

ItemFinderCloseButton.MouseButton1Click:Connect(function()
    clearHighlights()
    ItemFinderFrame.Visible = false
    LargeTextFrame.Visible = false
end)

ItemTeleportButton.MouseButton1Click:Connect(function()
    local itemNames = TextBox.Text
    if itemNames == "" then
        NameLabel.Text = "กรุณาพิมพ์ชื่อไอเทม!"
        return
    end

    -- Split item names by comma
    local itemList = {}
    for item in string.gmatch(itemNames, "[^,]+") do
        table.insert(itemList, item:match("^%s*(.-)%s*$")) -- Trim whitespace
    end

    if #itemList == 0 then
        NameLabel.Text = "กรุณาพิมพ์ชื่อไอเทม!"
        return
    end

    local function findItem(itemName)
        for _, child in pairs(game.Workspace:GetChildren()) do
            if child.Name:lower():find(itemName:lower()) and (child:IsA("Model") or child:IsA("BasePart")) then
                return child
            end
            local found = findItemRecursive(child, itemName)
            if found then return found end
        end
    end

    local function findItemRecursive(parent, itemName)
        for _, child in pairs(parent:GetChildren()) do
            if child.Name:lower():find(itemName:lower()) and (child:IsA("Model") or child:IsA("BasePart")) then
                return child
            end
            local found = findItemRecursive(child, itemName)
            if found then return found end
        end
    end

    -- Find the first matching item from the list
    local targetItem = nil
    local foundItemName = nil
    for _, itemName in ipairs(itemList) do
        local found = findItem(itemName)
        if found then
            targetItem = found
            foundItemName = itemName
            break
        end
    end

    if targetItem then
        local targetPos = targetItem:IsA("Model") and targetItem:GetPivot().Position or targetItem.Position
        humanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        NameLabel.Text = "เทเลพอร์ตไปที่: " .. targetItem.Name
    else
        NameLabel.Text = "ไม่พบไอเทมในรายการ: " .. table.concat(itemList, ", ")
    end
end)

AuraButton.MouseButton1Click:Connect(function()
    isAuraEnabled = not isAuraEnabled
    AuraButton.Text = "ออร่า: " .. (isAuraEnabled and "เปิด" or "ปิด")
    clearHighlights()

    if isAuraEnabled then
        local itemNames = TextBox.Text
        if itemNames == "" then
            NameLabel.Text = "กรุณาพิมพ์ชื่อไอเทม!"
            return
        end

        -- Split item names by comma
        local itemList = {}
        for item in string.gmatch(itemNames, "[^,]+") do
            table.insert(itemList, item:match("^%s*(.-)%s*$")) -- Trim whitespace
        end

        if #itemList == 0 then
            NameLabel.Text = "กรุณาพิมพ์ชื่อไอเทม!"
            return
        end

        local function findAllItems(parent, itemName, items)
            for _, child in pairs(parent:GetChildren()) do
                if child.Name:lower():find(itemName:lower()) and (child:IsA("Model") or child:IsA("BasePart")) then
                    table.insert(items, child)
                end
                findAllItems(child, itemName, items)
            end
        end

        local foundItems = {}
        -- Find all items matching any name in the list
        for _, itemName in ipairs(itemList) do
            findAllItems(game.Workspace, itemName, foundItems)
        end

        if #foundItems == 0 then
            NameLabel.Text = "ไม่พบไอเทมสำหรับออร่า!"
            return
        end

        for _, targetItem in pairs(foundItems) do
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.new(1, 1, 0)
            highlight.OutlineColor = Color3.new(1, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = targetItem
            highlight.Parent = targetItem
            table.insert(currentHighlights, highlight)
        end
        NameLabel.Text = "พบ " .. #foundItems .. " ไอเทมสำหรับออร่า"
    end
end)

-- Event Connections
CollapseButton.MouseButton1Click:Connect(toggleCollapse)

CloseButton.MouseButton1Click:Connect(function()
    resetAllExploits()
    Gui.Enabled = false
    guiEnabled = false
end)

OpenSelectionButton.MouseButton1Click:Connect(function()
    UpdatePlayerList()
    SelectionFrame.Visible = true
end)

CloseSelectionButton.MouseButton1Click:Connect(function()
    SelectionFrame.Visible = false
end)

DropdownButton.MouseButton1Click:Connect(function()
    DropdownFrame.Visible = not DropdownFrame.Visible
end)

TeleportButton.MouseButton1Click:Connect(function()
    if not SelectedPlayer or not SelectedPlayer.Character or not SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        OpenSelectionButton.Text = "เลือกผู้เล่น"
        SelectedPlayer = nil
        return
    end

    local targetPos = SelectedPlayer.Character.HumanoidRootPart.Position
    local offset = Vector3.new(0, 0, 0)
    local selectedOption = DropdownButton.Text

    if selectedOption == "ซ้าย" then
        offset = SelectedPlayer.Character.HumanoidRootPart.CFrame.RightVector * -5
    elseif selectedOption == "ขวา" then
        offset = SelectedPlayer.Character.HumanoidRootPart.CFrame.RightVector * 5
    elseif selectedOption == "หน้า" then
        offset = SelectedPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5
    elseif selectedOption == "หลัง" then
        offset = SelectedPlayer.Character.HumanoidRootPart.CFrame.LookVector * -5
    end

    humanoidRootPart.CFrame = CFrame.new(targetPos + offset + Vector3.new(0, 3, 0))
end)

OpenItemFinderButton.MouseButton1Click:Connect(function()
    ItemFinderFrame.Visible = true
end)

OpenLightingControlButton.MouseButton1Click:Connect(function()
    LightingControlFrame.Visible = true
end)

FlyButton.MouseButton1Click:Connect(toggleFly)

SpeedButton.MouseButton1Click:Connect(toggleSpeed)

ESPButton.MouseButton1Click:Connect(toggleESP)

InvisibleButton.MouseButton1Click:Connect(toggleInvisible)

NoclipButton.MouseButton1Click:Connect(toggleNoclip)

RejoinButton.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)

KeybindButton.MouseButton1Click:Connect(toggleKeybinds)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not keybindsEnabled or gameProcessedEvent or not guiEnabled then return end

    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.Z then
        toggleSpeed()
    elseif input.KeyCode == Enum.KeyCode.X then
        toggleInvisible()
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    end
end)

-- Player Added/Removed Events
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Character Added Event
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    resetAllExploits()
end)

-- Update Ghost GUI Size
RunService.RenderStepped:Connect(function()
    updateGhostGuiSize()
end)

-- Initial Setup
UpdatePlayerList()
