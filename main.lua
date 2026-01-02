--[[
📌 LocalScript completo:
FPS Boost + FOV + ESP + Lock-on
O alvo travado muda a cor do ESP
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local FireEvent = ReplicatedStorage:WaitForChild("Fire")

-- ===== FPS BOOST LEVE =====
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
local L = game:GetService("Lighting")
L.GlobalShadows=false
L.FogEnd=9e9
L.Brightness=0
L.EnvironmentDiffuseScale=0
L.EnvironmentSpecularScale=0
L.OutdoorAmbient=Color3.new(0,0,0)
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
local FOV=80
local FOV_MIN,FOV_MAX=20,200
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.ResetOnSpawn=false

local fovCircle = Instance.new("Frame", screenGui)
fovCircle.Size = UDim2.new(0,FOV*2,0,FOV*2)
fovCircle.Position = UDim2.new(0.5,-FOV,0.5,-FOV)
fovCircle.BackgroundTransparency=1
fovCircle.BorderSizePixel=2
fovCircle.BorderColor3=Color3.new(1,0,0)
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)

local function updateFOVCircle()
    fovCircle.Size = UDim2.new(0,FOV*2,0,FOV*2)
    fovCircle.Position = UDim2.new(0.5,-FOV,0.5,-FOV)
end

-- ===== ESP =====
local ESPFolder = Instance.new("Folder", screenGui)
ESPFolder.Name="ESP"

local ESPColorDefault = Color3.new(0,1,0) -- Cor padrão
local ESPColorLocked = Color3.new(1,0,0) -- Cor do alvo travado

local function updateESP(locked)
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local box = ESPFolder:FindFirstChild(p.Name)
            if not box then
                box = Instance.new("Frame", ESPFolder)
                box.Name = p.Name
                box.BorderSizePixel = 0
                box.Size = UDim2.new(0,50,0,50)
                box.AnchorPoint = Vector2.new(0.5,0.5)
            end
            box.BackgroundColor3 = (locked==hrp) and ESPColorLocked or ESPColorDefault
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            box.Position = UDim2.new(0,pos.X,0,pos.Y)
            box.Visible = onScreen
        end
    end
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
    return (target.Position-myHrp.Position).Magnitude<=MAX_RANGE
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
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
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

-- ===== INPUT =====
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode.Q then
        FOV = math.clamp(FOV-5,FOV_MIN,FOV_MAX)
        updateFOVCircle()
    elseif input.KeyCode==Enum.KeyCode.E then
        FOV = math.clamp(FOV+5,FOV_MIN,FOV_MAX)
        updateFOVCircle()
    elseif input.UserInputType==Enum.UserInputType.MouseButton1 then
        FireEvent:FireServer(FOV)
    end
end)

-- ===== RENDER UPDATE =====
RunService.RenderStepped:Connect(function()
    local locked = getLockedTarget(LocalPlayer,FOV)
    updateESP(locked)
end)
