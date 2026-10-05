-- =================================================================
-- Yusuf Script Hub (Moondiety Inspired UI & Auto-Game Detection)
-- Blox Fruits Auto Chest Farm Added
-- Works smoothly on Mobile & PC Executors (Delta, Xeno, Wave)
-- =================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Eski GUI temizliği
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
UIStroke.Color = Color3.fromRGB(138, 43, 226)
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
        PercentText.Text = "%" .. i
        task.wait(0.015)
    end
    SubTitle.Text = "Başarıyla Yüklendi!"
    task.wait(0.4)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.4)
    LoaderScreen:Destroy()
    
    LoadMoondietyHub()
end)

-------------------------------------------------------------------
-- 2. MOONDIETY HUB ARAYÜZÜ (MAIN SCRIPT)
-------------------------------------------------------------------
function LoadMoondietyHub()
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

    local MainUI = OrionLib:MakeWindow({
        Name = "Yusuf Hub | Moondiety Edition",
        HidePremium = true,
        SaveConfig = false,
        IntroEnabled = false,
        Icon = "rbxassetid://4483345998"
    })

    -- 1. EVRENSEL HAREKET SEKMESİ
    local UniversalTab = MainUI:MakeTab({Name = "Universal", Icon = "rbxassetid://4483345998", PremiumOnly = false})

    UniversalTab:AddSlider({
        Name = "WalkSpeed (Yürüme Hızı)",
        Min = 16,
        Max = 250,
        Default = 16,
        Color = Color3.fromRGB(138, 43, 226),
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end    
    })

    UniversalTab:AddSlider({
        Name = "JumpPower (Zıplama Gücü)",
        Min = 50,
        Max = 300,
        Default = 50,
        Color = Color3.fromRGB(138, 43, 226),
        Increment = 1,
        ValueName = "Power",
        Callback = function(Value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end    
    })

    local flying = false
    local flySpeed = 50
    UniversalTab:AddToggle({
        Name = "Fly (Uçma)",
        Default = false,
        Callback = function(Value)
            flying = Value
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if flying and hrp then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "HubFlyBV"
                bv.MaxForce = Vector3.new(0,0,0)
                bv.Velocity = Vector3.new(0,0,0)
                bv.Parent = hrp
                
                local bg = Instance.new("BodyGyro")
                bg.Name = "HubFlyBG"
                bg.MaxTorque = Vector3.new(0,0,0)
                bg.CFrame = hrp.CFrame
                bg.Parent = hrp
                
                task.spawn(function()
                    while flying and hrp and hrp:FindFirstChild("HubFlyBV") do
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                        bg.CFrame = workspace.CurrentCamera.CFrame
                        bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
                        task.wait()
                    end
                    if hrp:FindFirstChild("HubFlyBV") then hrp.HubFlyBV:Destroy() end
                    if hrp:FindFirstChild("HubFlyBG") then hrp.HubFlyBG:Destroy() end
                end)
            else
                if hrp and hrp:FindFirstChild("HubFlyBV") then hrp.HubFlyBV:Destroy() end
                if hrp and hrp:FindFirstChild("HubFlyBG") then hrp.HubFlyBG:Destroy() end
            end
        end
    })

    -- 2. AI FARM SEKMESİ
    local AITab = MainUI:MakeTab({Name = "AI Auto-Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
    _G.AIFarmEnabled = false

    local function GetNearestCollectible()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
        
        local hrp = character.HumanoidRootPart
        local nearestObj = nil
        local shortestDistance = math.huge

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if string.find(name, "coin") or string.find(name, "gem") or string.find(name, "egg") or string.find(name, "crop") or string.find(name, "collect") then
                    local distance = (hrp.Position - obj.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestObj = obj
                    end
                end
            end
        end
        return nearestObj
    end

    AITab:AddToggle({
        Name = "Smart Pathfinding Auto-Farm",
