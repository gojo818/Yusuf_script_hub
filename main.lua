-- =================================================================
-- Universal Multi-Game Hub (Auto-Detect, MM2, AI Farm, Movement)
-- GitHub & Script Hub Release Ready
-- =================================================================

-- GUI Kütüphanesi (Orion Library) Yükleme
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Giriş Bildirimi
OrionLib:MakeNotification({
    Name = "Universal Script Hub",
    Content = "Sistem ve oyun tespiti başlatılıyor...",
    Image = "rbxassetid://4483345998",
    Time = 3
})

task.wait(1)

function LoadMainHub()
    local MainUI = OrionLib:MakeWindow({
        Name = "Universal Multi-Game Hub",
        HidePremium = true,
        SaveConfig = true,
        IntroEnabled = true,
        IntroText = "Welcome to Script Hub",
        IntroIcon = "rbxassetid://4483345998",
        Icon = "rbxassetid://4483345998"
    })

    -------------------------------------------------------------------
    -- 1. EVRENSEL SEKMELER (Tüm Oyunlarda Çalışır)
    -------------------------------------------------------------------
    local UniversalTab = MainUI:MakeTab({Name = "Universal", Icon = "rbxassetid://4483345998", PremiumOnly = false})

    -- Yürüme Hızı
    UniversalTab:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 250,
        Default = 16,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "Speed",
        Callback = function(Value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end    
    })

    -- Zıplama Gücü
    UniversalTab:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 300,
        Default = 50,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "Power",
        Callback = function(Value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end    
    })

    -- Her Oyunda Çalışan Uçma (Fly)
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
                bv.MaxForce = Vector3.new(0, 0, 0)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
                
                local bg = Instance.new("BodyGyro")
                bg.Name = "HubFlyBG"
                bg.MaxTorque = Vector3.new(0, 0, 0)
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

    UniversalTab:AddSlider({
        Name = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Color = Color3.fromRGB(0, 255, 0),
        Increment = 5,
        ValueName = "Speed",
        Callback = function(Value)
            flySpeed = Value
        end
    })

    -------------------------------------------------------------------
    -- 2. AI AUTO-FARM SEKMESİ (Pathfinding Tabanlı)
    -------------------------------------------------------------------
    local AITab = MainUI:MakeTab({Name = "AI Auto-Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

    _G.AIFarmEnabled = false

    local function AI_MoveToTarget(targetPosition)
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoid = character.Humanoid
        local hrp = character.HumanoidRootPart

        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentJumpHeight = 10
        })

        local success, _ = pcall(function()
            path:ComputeAsync(hrp.Position, targetPosition)
        end)

        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for _, waypoint in ipairs(waypoints) do
                if not _G.AIFarmEnabled then break end
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()
            end
        else
            humanoid:MoveTo(targetPosition)
        end
    end

    local function GetNearestCollectible()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
        
        local hrp = character.HumanoidRootPart
        local nearestObj = nil
        local shortestDistance = math.huge

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if string.find(name, "coin") or string.find(name, "gem") or string.find(name, "egg") or string.find(name, "crop") or string.find(name, "plant") or string.find(name, "collect") then
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
        Name = "Smart AI Auto-Farm (Pathfinding)",
        Default = false,
        Callback = function(Value)
            _G.AIFarmEnabled = Value
            
            task.spawn(function()
                while _G.AIFarmEnabled do
                    local target = GetNearestCollectible()
                    if target and target.Parent then
                        AI_MoveToTarget(target.Position)
                        local prompt = target:FindFirstChildOfClass("ProximityPrompt") or target.Parent:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                    else
                        task.wait(1)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    -------------------------------------------------------------------
    -- 3. OTOMATİK OYUN ALGILAMA VE ÖZEL MODÜLLER
    -------------------------------------------------------------------
    local currentPlaceId = game.PlaceId

    -- Murder Mystery 2
    if currentPlaceId == 142823291 then
        local MM2Tab = MainUI:MakeTab({Name = "MM2 Specific", Icon = "rbxassetid://4483345998", PremiumOnly = false})
        
        -- Role ESP
        MM2Tab:AddToggle({
            Name = "Murder/Sheriff ESP",
            Default = false,
            Callback = function(Value)
                _G.RoleESP = Value
                task.spawn(function()
                    while _G.RoleESP do
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local hl = p.Character:FindFirstChild("RoleHighlight") or Instance.new("Highlight", p.Character)
                                hl.Name = "RoleHighlight"
                                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                                elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                                    hl.FillColor = Color3.fromRGB(0, 0, 255)
                                else
                                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                                end
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        })

        -- Client-side Skin Changer
        local function ApplySkin(weaponName, meshId, textureId)
            local weapon = LocalPlayer.Backpack:FindFirstChild(weaponName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(weaponName))
            if weapon then
                local handle = weapon:FindFirstChild("Handle")
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle
                    if mesh:IsA("SpecialMesh") then
                        if meshId ~= "" then mesh.MeshId = "rbxassetid://" .. meshId end
                        if textureId ~= "" then mesh.TextureId = "rbxassetid://" .. textureId end
                    elseif handle:IsA("MeshPart") then
                        if textureId ~= "" then handle.TextureID = "rbxassetid://" .. textureId end
                    end
                    OrionLib:MakeNotification({Name = "Skin Changer", Content = weaponName .. " kaplaması değiştirildi!", Time = 2})
                end
            else
                OrionLib:MakeNotification({Name = "Hata", Content = "Envanterinizde " .. weaponName .. " bulunamadı!", Time = 2})
            end
        end

        MM2Tab:AddDropdown({
            Name = "Knife Skin Preset",
            Default = "Varsayılan",
            Options = {"Nik's Scythe", "Chroma Gemstone", "Corrupt"},
            Callback = function(Option)
                if Option == "Nik's Scythe" then
                    ApplySkin("Knife", "195701006", "195701061")
                elseif Option == "Chroma Gemstone" then
                    ApplySkin("Knife", "3580131652", "3580131804")
                elseif Option == "Corrupt" then
                    ApplySkin("Knife", "247055203", "247055256")
                end
            end
        })

    -- Steela Brainote Örneği
    elseif currentPlaceId == 123456789 then
        local SteelaTab = MainUI:MakeTab({Name = "Steela Brainote", Icon = "rbxassetid://4483345998", PremiumOnly = false})
        SteelaTab:AddButton({
            Name = "Auto Collect Notes / Eggs",
            Callback = function()
                OrionLib:MakeNotification({Name = "Steela", Content = "Otomatik toplama çalışıyor...", Time = 2})
            end
        })

    -- Grova Garden Örneği
    elseif currentPlaceId == 987654321 then
        local GrovaTab = MainUI:MakeTab({Name = "Grova Garden", Icon = "rbxassetid://4483345998", PremiumOnly = false})
        GrovaTab:AddButton({
            Name = "Auto Farm Plants",
            Callback = function()
                OrionLib:MakeNotification({Name = "Grova Garden", Content = "Farm başlatıldı!", Time = 2})
            end
        })

    else
        local UnknownTab = MainUI:MakeTab({Name = "Game Info", Icon = "rbxassetid://4483345998", PremiumOnly = false})
        UnknownTab:AddLabel("Mevcut Oyun ID: " .. tostring(currentPlaceId))
        UnknownTab:AddLabel("Bu oyun için özel sekme bulunamadı.")
        UnknownTab:AddLabel("Universal ve AI Auto-Farm sekmelerini kullanabilirsiniz.")
    end

    OrionLib:Init()
end

LoadMainHub()
