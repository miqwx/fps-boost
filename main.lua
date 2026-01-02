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

-- 🔹 FUNÇÃO PARA REMOVER DECORAÇÕES/ÁRVORES PEQUENAS
local nomes={"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function decor(o)
    for _,n in ipairs(nomes) do
        if o.Name:lower():find(n) then return true end
    end
    -- remove apenas partes pequenas ou plantas decorativas
    if o:IsA("BasePart") and o.Size.Magnitude < 15 then
        return true
    end
end

-- 🔹 OTIMIZAÇÃO DE OBJETOS (PROTEGE SEU PERSONAGEM)
local function opt(o)
    if o:IsDescendantOf(LP.Character) then return end -- protege você
    if o:IsA("BasePart") then
        o.Material = Enum.Material.Plastic
        o.Reflectance = 0
        o.CastShadow = false
        if decor(o) then o:Destroy() end
    elseif o:IsA("Decal") or o:IsA("Texture") then
        o.Transparency = 1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") 
        or o:IsA("Smoke") or o:IsA("Sparkles") then
        o.Enabled = false
    elseif (o:IsA("Model") or o:IsA("Folder")) then
        for _,c in ipairs(o:GetChildren()) do
            opt(c)
        end
    end
end

-- Limpa tudo que já existe
for _,v in ipairs(Workspace:GetDescendants()) do opt(v) end
-- Limpa objetos que nascerem depois
Workspace.DescendantAdded:Connect(function(v) task.wait() opt(v) end)

-- 🔹 REMOVE ACESSÓRIOS/ROUPAS DOS OUTROS PLAYERS
local function char(c)
    if c == LP.Character then return end
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

-- 🔹 REMOVE RENDER DESNECESSÁRIO
RunService:Set3dRenderingEnabled(true)
end
