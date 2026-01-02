-- FPS BOOST EXTREMO + CÉU VERMELHO
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- CONFIGURAÇÕES GRÁFICAS
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
Lighting.GlobalShadows = false
Lighting.FogEnd = 1e9
Lighting.Brightness = 1
Lighting.ClockTime = 14
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.OutdoorAmbient = Color3.fromRGB(20,0,0) -- detalhe preto escuro

-- CÉU VERMELHO COM DETALHES PRETOS
Lighting:ClearAllChildren()
local sky = Instance.new("Sky", Lighting)
sky.SkyboxBk = ""
sky.SkyboxDn = ""
sky.SkyboxFt = ""
sky.SkyboxLf = ""
sky.SkyboxRt = ""
sky.SkyboxUp = ""
sky.SkyboxTintColor = Color3.fromRGB(150,0,0) -- vermelho
sky.StarCount = 0
sky.SkyboxSunAngularSize = 0

-- REMOVE EFEITOS VISUAIS
for _,v in ipairs(Lighting:GetChildren()) do
    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") 
    or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- FUNÇÃO DE OTIMIZAÇÃO
local function decor(o)
    local nomes = {"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

local function otimizar(obj)
    if obj:IsDescendantOf(Players.LocalPlayer.Character) then return end
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
        if decor(obj) then obj:Destroy() end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy()
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") 
        or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled=false; obj:Destroy()
    end
end

-- Otimiza tudo que já existe
for _,v in ipairs(Workspace:GetDescendants()) do
    otimizar(v)
end

-- Otimiza tudo que nascer depois
Workspace.DescendantAdded:Connect(function(v)
    task.wait()
    otimizar(v)
end)

-- REMOVE ROUPAS E ACESSÓRIOS
for _,player in ipairs(Players:GetPlayers()) do
    if player.Character then
        for _,v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Clothing") then
                v:Destroy()
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Clothing") then
                v:Destroy()
            end
        end
    end)
end)

-- REMOVE RENDER DESNECESSÁRIO
RunService:Set3dRenderingEnabled(true)
