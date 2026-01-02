-- FPS BOOST EXTREMO – REMOVE TUDO
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES GRÁFICAS
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
Lighting.GlobalShadows = false
Lighting.FogEnd = 1e9
Lighting.Brightness = 0
Lighting.ClockTime = 14
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.OutdoorAmbient = Color3.new(0,0,0)

-- REMOVE EFEITOS VISUAIS
for _,v in ipairs(Lighting:GetChildren()) do
    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") 
    or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- FUNÇÃO DE LIMPEZA EXTREMA
local function limpar(obj)
    if obj:IsDescendantOf(Players.LocalPlayer.Character) then return end
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
        obj.Transparency = 1 -- deixa invisível
    elseif obj:IsA("Decal") or obj:IsA("Texture") then obj:Destroy()
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") 
        or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj:Destroy()
    elseif obj:IsA("Model") or obj:IsA("Folder") then
        for _,c in ipairs(obj:GetChildren()) do limpar(c) end
    end
end

-- Limpa tudo que existe
for _,v in ipairs(Workspace:GetDescendants()) do
    limpar(v)
end

-- Limpa tudo que nascer depois
Workspace.DescendantAdded:Connect(function(v)
    task.wait()
    limpar(v)
end)

-- Remove roupas e acessórios de todos
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
        task.wait(0.5)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Clothing") then
                v:Destroy()
            end
        end
    end)
end)

-- FORÇA 3D RENDERING ATIVADO
RunService:Set3dRenderingEnabled(true)
