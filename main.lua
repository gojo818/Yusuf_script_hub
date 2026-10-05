-- =================================================================
-- Yusuf Script Hub (Moondiety Inspired UI & Auto-Game Detection)
-- Works smoothly on Mobile Executors (Delta, Hydrogen, Wave)
-- No Key System / Direct Load
-- =================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Eski GUI temizliği (Üst üste açılmayı önler)
if CoreGui:FindFirstChild("YusufHubLoader") then CoreGui.YusufHubLoader:Destroy() end
if CoreGui:FindFirstChild("YusufHubUI") then CoreGui.YusufHubUI:Destroy() end

-------------------------------------------------------------------
-- 1. MOONDIETY TARZI YÜKLEME EKRANI (LOADING SCREEN)
-------------------------------------------------------------------
local LoaderScreen = Instance.new("ScreenGui")
LoaderScreen.Name = "YusufHubLoader"
LoaderScreen.ResetOnSpawn = false
LoaderScreen.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 180)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = LoaderScreen

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(138, 43, 226) -- Neon Mor Moondiety Teması
UIStroke.Thickness = 1.5

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "YUSUF SCRIPT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 50)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Oyun Algılanıyor & Modüller Yükleniyor..."
SubTitle.TextColor3 = Color3.fromRGB(160, 160, 180)
SubTitle.TextSize = 13
SubTitle.Font = Enum.Font.Gotham
SubTitle.Parent = MainFrame

local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Size = UDim2.new(0.85, 0, 0, 8)
ProgressBarBG.Position = UDim2.new(0.075, 0, 0.65, 0)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.Parent = MainFrame

local BarCorner = Instance.new("UICorner", ProgressBarBG)
BarCorner.CornerRadius = UDim.new(1, 0)

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBarBG

local FillCorner = Instance.new("UICorner", ProgressBar)
FillCorner.CornerRadius = UDim.new(1, 0)

local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(1, 0, 0, 20)
PercentText.Position = UDim2.new(0, 0, 0.78, 0)
PercentText.BackgroundTransparency = 1
PercentText.Text = "0%"
PercentText.TextColor3 = Color3.fromRGB(200, 200, 200)
PercentText.TextSize = 12
PercentText.Font = Enum.Font.GothamMedium
PercentText.Parent = MainFrame

-- Yükleme Animasyonu
TweenService:Create(ProgressBar, TweenInfo.new(1.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

task.spawn(function()
    for i = 1, 100 do
        PercentText.Text =
