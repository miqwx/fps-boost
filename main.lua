-- FPS BOOST EXTREMO - ROBLOX
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- CONFIGURAÇÕES GRÁFICAS
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)

-- LIGHTING ULTRA LEVE
Lighting.GlobalShadows = false
Lighting.FogEnd = 1e9
Lighting.Brightness = 0
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.OutdoorAmbient = Color3.new(0,0,0)
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- OTIMIZAÇÃO DE OBJETOS
local function otimizar(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        obj.Enabled = false
        obj:Destroy()
    end
end

for _, v in ipairs(workspace:GetDescendants()) do
    otimizar(v)
end
workspace.DescendantAdded:Connect(function(v)
    task.wait()
    otimizar(v)
end)

-- REMOVE ACESSÓRIOS/ROUPAS DE OUTROS PLAYERS
local function char(c)
    if c == LP.Character then return end
    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("Accessory") or v:IsA("Clothing") then
            v:Destroy()
        end
    end
end
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then char(p.Character) end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(char)
end)

-- PAINEL DE FPS
local g = Instance.new("ScreenGui", LP.PlayerGui)
g.ResetOnSpawn = false
local t = Instance.new("TextLabel", g)
t.Size = UDim2.fromScale(0.1,0.05)
t.Position = UDim2.new(0,10,0,10)
t.BackgroundTransparency = 1
t.TextColor3 = Color3.fromRGB(0,255,0)
t.Font = Enum.Font.SourceSansBold
t.TextSize = 18
local c, lt = 0, tick()
RunService.RenderStepped:Connect(function()
    c += 1
    if tick()-lt >= 1 then
        t.Text = "FPS: "..c
        c = 0
        lt = tick()
    end
end)
