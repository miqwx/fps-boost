do
local P = game:GetService("Players")
local L = game:GetService("Lighting")
local R = game:GetService("RunService")
local LP = P.LocalPlayer
local Workspace = game:GetService("Workspace")

-- 🔹 CONFIGURAÇÃO GRÁFICA
pcall(function() 
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.PhysicsFPS = 0
    settings().Rendering.FramesPerSecond = 0
end)

-- 🔹 LIGHTING ULTRA LEVE
L.GlobalShadows = false
L.FogEnd = 9e9
L.Brightness = 0
L.EnvironmentDiffuseScale = 0
L.EnvironmentSpecularScale = 0
L.OutdoorAmbient = Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
end

-- 🔹 FUNÇÃO PARA DETECTAR ÁRVORES
local nomes_arvores = {"tree","arvore","palm","leaf"}
local function isTree(o)
    for _,n in ipairs(nomes_arvores) do
        if o.Name:lower():find(n) then return true end
    end
    return false
end

-- 🔹 OTIMIZAÇÃO DE OBJETOS (PROTEGE PERSONAGENS)
local function opt(o)
    -- Protege todos os personagens
    for _,player in ipairs(P:GetPlayers()) do
        if player.Character and o:IsDescendantOf(player.Character) then return end
    end

    if o:IsA("BasePart") then
        o.Material = Enum.Material.Plastic
        o.Reflectance = 0
        o.CastShadow = false
        if isTree(o) then o:Destroy() end
    elseif o:IsA("Model") or o:IsA("Folder") then
        if isTree(o) then
            o:Destroy()
        else
            for _,c in ipairs(o:GetChildren()) do
                opt(c)
            end
        end
    elseif o:IsA("Decal") or o:IsA("Texture") then
        o.Transparency = 1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") 
        or o:IsA("Smoke") or o:IsA("Sparkles") then
        o.Enabled = false
    end
end

-- Limpa tudo que já existe
for _,v in ipairs(Workspace:GetDescendants()) do opt(v) end
-- Limpa objetos que nascerem depois
Workspace.DescendantAdded:Connect(function(v) task.wait() opt(v) end)

-- 🔹 REMOVE ACESSÓRIOS/ROUPAS DOS OUTROS PLAYERS (mantém corpo visível)
local function char(c)
    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("Accessory") and v:FindFirstChild("Handle") then
            v.Handle.Transparency = 1
        elseif v:IsA("Clothing") then
            v:Destroy()
        end
    end
end

for _,p in ipairs(P:GetPlayers()) do
    if p.Character then char(p.Character) end
end
P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(char)
end)

-- 🔹 AUMENTA HITBOX DE TODOS OS PLAYERS
local function aumentarHitbox(player, scale)
    scale = scale or 1.5
    if player.Character then
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = part.Size * scale
                part.CanCollide = true
            end
        end
    end
end

-- Hitbox de todos já no jogo
for _, player in ipairs(P:GetPlayers()) do
    aumentarHitbox(player, 1.5)
end

-- Hitbox de novos players
P.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        aumentarHitbox(player, 1.5)
    end)
end)

-- Hitbox do seu próprio personagem
if LP.Character then
    aumentarHitbox(LP, 1.5)
end
LP.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    aumentarHitbox(LP, 1.5)
end)

-- 🔹 REMOVE RENDER DESNECESSÁRIO
R:Set3dRenderingEnabled(true)
end
