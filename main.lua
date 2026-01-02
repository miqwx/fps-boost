--[[
📌 LocalScript final: FPS Boost + ESP + FOV Circle + Lock-on + Painel Mobile
Coloque em StarterPlayerScripts
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===== FPS BOOST LEVE =====
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
local L = game:GetService("Lighting")
L.GlobalShadows = false
L.FogEnd = 9e9
L.Brightness = 0
L.EnvironmentDiffuseScale = 0
L.EnvironmentSpecularScale = 0
L.OutdoorAmbient = Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end end

local function decor(o)
    local nomes={"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

local function opt(o)
    if o:IsDescendantOf(LocalPlayer.Character) then return end
    if o:IsA("BasePart") then
        o.Material=Enum.Material.Plastic
        o.Reflectance=0
        o.CastShadow=false
        if decor(o) then o:Destroy() end
    elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then o.Enabled=false
    elseif (o:IsA("Model") or o:IsA("Folder")) and decor(o) then o:Destroy() end
end

for _,v in ipairs(Workspace:GetDescendants()) do opt(v) end
Workspace.DescendantAdded:Connect(function(v) task.wait() opt(v) end)

-- ===== FOV CIRCLE =====
local FOV = 80
local FOV_MIN, FOV_MAX = 20, 200

local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.ResetOnSpawn = false

local fovCircle = Instance.new("Frame", screenGui)
fovCircle.Size = UDim2.new(0,FOV*2,0,FOV*2)
fovCircle.Position = UDim2.new(0.5,-FOV,0.5,-FOV)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = Color3.new(1,0,0)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0,FOV*2,0,FOV*2)
    fovCircle.Position = UDim2.new(0.5,-FOV,0.5,-FOV)
end

-- ===== ESP =====
local ESPFolder = Instance.new("Folder", screenGui)
ESPFolder.Name = "ESP"
local ESPColorDefault = Color3.new(0,1,0)
local ESPColorLocked = Color3.new(1,0,0)

local function createESP(player)
    if ESPFolder:FindFirstChild(player.Name) then return end
    local billboard = Instance.new("BillboardGui", ESPFolder)
    billboard.Name = player.Name
    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0,50,0,50)
    billboard.AlwaysOnTop = true
    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = ESPColorDefault
    frame.BorderSizePixel = 0
end

-- ===== LOCK-ON =====
local MAX_RANGE = 500
local HIT_PART = "HumanoidRootPart"
local lockedTarget = {}

local function targetIsValid(player,target)
    if not player.Character or not target then return false end
    local hum = target.Parent:FindFirstChildOfClass("Humanoid")
    local myHrp = player.Character:FindFirstChild(HIT_PART)
    if not hum or hum.Health<=0 or not myHrp then return false end
    return (target.Position-myHrp.Position).Magnitude <= MAX_RANGE
end

local function findNewTarget(player,fovAngle)
    local char = player.Character
    local myHrp = char and char:FindFirstChild(HIT_PART)
    if not myHrp then return nil end
    local closest,minDist = nil,MAX_RANGE
    local camLook = workspace.CurrentCamera.CFrame.LookVector
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild(HIT_PART) then
            local hrp = p.Character.HumanoidRootPart
            local dir = (hrp.Position-myHrp.Position).Unit
            local angle = math.acos(camLook:Dot(dir))
            local dist = (hrp.Position-myHrp.Position).Magnitude
            if dist < minDist and angle <= math.rad(fovAngle/2) then
                minDist = dist
                closest = hrp
            end
        end
    end
    return closest
end

local function getLockedTarget(player,fovAngle)
    local cur = lockedTarget[player]
    if cur and targetIsValid(player,cur) then return cur end
    local newT=findNewTarget(player,fovAngle)
    lockedTarget[player]=newT
    return newT
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() lockedTarget[p]=nil end)
end)

-- ===== MOBILE FOV PAINEL =====
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0,150,0,80)
panel.Position = UDim2.new(0.1,0,0.7,0)
panel.BackgroundColor3 = Color3.new(0,0,0)
panel.BackgroundTransparency = 0.5
panel.Active = true
panel.Draggable = true

local plusBtn = Instance.new("TextButton", panel)
plusBtn.Size = UDim2.new(0,60,0,30)
plusBtn.Position = UDim2.new(0,10,0,10)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.MouseButton1Click:Connect(function()
    FOV = math.clamp(FOV + 5, FOV_MIN, FOV_MAX)
    updateFOVCircle()
end)

local minusBtn = Instance.new("TextButton", panel)
minusBtn.Size = UDim2.new(0,60,0,30)
minusBtn.Position = UDim2.new(0,80,0,10)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.MouseButton1Click:Connect(function()
    FOV = math.clamp(FOV - 5, FOV_MIN, FOV_MAX)
    updateFOVCircle()
end)

-- ===== UPDATE ESP E LOCK-ON =====
RunService.RenderStepped:Connect(function()
    local locked = getLockedTarget(LocalPlayer,FOV)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild(HIT_PART) then
            createESP(p)
            local billboard = ESPFolder:FindFirstChild(p.Name)
            local frame = billboard:FindFirstChildWhichIsA("Frame")
            if frame then
                frame.BackgroundColor3 = (locked==p.Character[HIT_PART]) and ESPColorLocked or ESPColorDefault
            end
        end
    end
    updateFOVCircle()
end)
