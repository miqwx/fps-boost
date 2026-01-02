-- FPS BOOST + REMOVE ÁRVORES/DECORAÇÕES
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- CONFIGURAÇÕES GRÁFICAS
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
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

-- FUNÇÃO PARA DETECTAR ÁRVORES/DECORAÇÕES
local nomesDecos = {"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function isDecor(o)
    for _, n in ipairs(nomesDecos) do
        if o.Name:lower():find(n) then return true end
    end
    if o:IsA("BasePart") then
        local c = o.Color
        if c.G > c.R and c.G > c.B and o.Size.Y > 4 then
            return true
        end
    end
end

-- FUNÇÃO PARA OTIMIZAR OBJETOS
local function otimizar(obj)
    if obj:IsDescendantOf(LP.Character) then return end -- protege você
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
        if isDecor(obj) then obj:Destroy() end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        obj.Enabled = false
        obj:Destroy()
    elseif (obj:IsA("Model") or obj:IsA("Folder")) and isDecor(obj) then
        obj:Destroy()
    end
end

-- APLICA EM TODO O MAPA
for _, v in ipairs(Workspace:GetDescendants()) do
    otimizar(v)
end
Workspace.DescendantAdded:Connect(function(v)
    task.wait()
    otimizar(v)
end)

-- REMOVE ACESSÓRIOS/ROUPAS DOS OUTROS PLAYERS
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
