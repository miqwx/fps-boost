do
-- SERVIÇOS
local P = game:GetService("Players")
local L = game:GetService("Lighting")
local R = game:GetService("RunService")
local W = workspace
local Cam = W.CurrentCamera
local LP = P.LocalPlayer

--------------------------------------------------
-- FPS BOOST
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

L.GlobalShadows = false
L.FogEnd = 9e9
L.Brightness = 0
L.EnvironmentDiffuseScale = 0
L.EnvironmentSpecularScale = 0
L.OutdoorAmbient = Color3.new(0,0,0)

for _,v in ipairs(L:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

--------------------------------------------------
-- REMOVE ÁRVORES / DECORAÇÕES
local treeNames = {"tree","arvore","palm","leaf","folha","bush","plant"}

local function isTree(o)
    for _,n in ipairs(treeNames) do
        if o.Name:lower():find(n) then
            return true
        end
    end
end

local function optimize(o)
    for _,plr in ipairs(P:GetPlayers()) do
        if plr.Character and o:IsDescendantOf(plr.Character) then
            return
        end
    end

    if o:IsA("BasePart") then
        o.Material = Enum.Material.Plastic
        o.CastShadow = false
        if isTree(o) then
            o:Destroy()
        end
    elseif o:IsA("ParticleEmitter")
        or o:IsA("Trail")
        or o:IsA("Fire")
        or o:IsA("Smoke") then
        o.Enabled = false
    end
end

for _,v in ipairs(W:GetDescendants()) do
    optimize(v)
end
W.DescendantAdded:Connect(function(v)
    task.wait()
    optimize(v)
end)

--------------------------------------------------
-- ESP AVANÇADO
local ESPFolder = Instance.new("Folder", LP.PlayerGui)
ESPFolder.Name = "ESP"

local ESP = {}

local function createESP(player)
    if player == LP then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = player.Character.HumanoidRootPart

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = hrp
    box.Size = Vector3.new(2,5,1)
    box.Color3 = Color3.fromRGB(255,0,0)
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = ESPFolder

    local gui = Instance.new("BillboardGui")
    gui.Adornee = player.Character:FindFirstChild("Head") or hrp
    gui.Size = UDim2.new(0,120,0,40)
    gui.AlwaysOnTop = true
    gui.Parent = ESPFolder

    local txt = Instance.new("TextLabel", gui)
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255,0,0)
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 14
    txt.TextStrokeTransparency = 0.5

    ESP[player] = {box = box, txt = txt, gui = gui}
end

for _,p in ipairs(P:GetPlayers()) do
    createESP(p)
end

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.2)
        createESP(p)
    end)
end)

--------------------------------------------------
-- AIM ASSIST ULTRA-GRUDENTO
local SMOOTH = 0.01   -- praticamente cola na mira
local MAX_DIST = 350
local FOV = 130        -- mira ampla

local function getTarget()
    local best, closest = nil, math.huge
    for _,p in ipairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - Cam.CFrame.Position).Magnitude
            if dist <= MAX_DIST then
                local pos, onScreen = Cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local diff = (Vector2.new(pos.X,pos.Y)
                        - Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)).Magnitude
                    if diff < FOV and diff < closest then
                        closest = diff
                        best = hrp
                    end
                end
            end
        end
    end
    return best
end

R.RenderStepped:Connect(function()
    local t = getTarget()
    if t then
        local cf = CFrame.new(Cam.CFrame.Position, t.Position)
        Cam.CFrame = Cam.CFrame:Lerp(cf, SMOOTH)
    end

    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        for p,d in pairs(ESP) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor(
                    (LP.Character.HumanoidRootPart.Position -
                    p.Character.HumanoidRootPart.Position).Magnitude
                )
                d.txt.Text = p.Name.." ["..dist.."m]"
            end
        end
    end
end)

--------------------------------------------------
-- REMOVE RENDER DESNECESSÁRIO
R:Set3dRenderingEnabled(true)
end
