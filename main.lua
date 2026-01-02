do
local P = game:GetService("Players")
local L = game:GetService("Lighting")
local R = game:GetService("RunService")
local LP = P.LocalPlayer

-- 🔹 REMOVE LIMITADOR DE FPS
pcall(function()
    settings().Rendering.PhysicsFPS = 0
    settings().Rendering.FramesPerSecond = 0
end)

-- CONFIGURAÇÃO GRÁFICA
pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)

-- LIGHTING ULTRA LEVE
L.GlobalShadows = false
L.FogEnd = 9e9
L.Brightness = 0
L.EnvironmentDiffuseScale = 0
L.EnvironmentSpecularScale = 0
L.OutdoorAmbient = Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end end

-- FUNÇÃO PARA REMOVER DECORAÇÕES/ÁRVORES
local nomes={"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function decor(o)
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

-- OTIMIZAÇÃO DE OBJETOS (PROTEGE SEU PERSONAGEM)
local function opt(o)
    if o:IsDescendantOf(LP.Character) then return end -- protege você
    if o:IsA("BasePart") then
        o.Material=Enum.Material.Plastic
        o.Reflectance=0
        o.CastShadow=false
        if decor(o) then o:Destroy() end
    elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then o.Enabled=false
    elseif (o:IsA("Model") or o:IsA("Folder")) and decor(o) then o:Destroy() end
end

for _,v in ipairs(workspace:GetDescendants()) do opt(v) end
workspace.DescendantAdded:Connect(function(v) task.wait() opt(v) end)

-- REMOVE ACESSÓRIOS/ROUPAS DOS OUTROS PLAYERS
local function char(c)
    if c==LP.Character then return end -- protege você
    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency=1
        elseif v:IsA("Clothing") then v:Destroy() end
    end
end
for _,p in ipairs(P:GetPlayers()) do if p.Character then char(p.Character) end end
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(char) end)

-- PAINEL DE FPS COM IMAGEM DE FUNDO
local g=Instance.new("ScreenGui",LP.PlayerGui)
g.ResetOnSpawn=false

local f=Instance.new("ImageLabel",g)
f.Size=UDim2.new(0,180,0,50)
f.Position=UDim2.new(0,10,0,10)
f.BackgroundTransparency=1
f.Image="rbxassetid://0" -- substitua 0 pelo ID da sua imagem
f.ScaleType=Enum.ScaleType.Stretch
Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)

local t=Instance.new("TextLabel",f)
t.Size=UDim2.fromScale(1,1)
t.BackgroundTransparency=1
t.TextColor3=Color3.fromRGB(0,255,0)
t.Font=Enum.Font.SourceSansBold
t.TextSize=18
t.TextStrokeTransparency=0.5

local c,lt=0,tick()
R.RenderStepped:Connect(function()
    c+=1
    if tick()-lt>=1 then t.Text="FPS: "..c c=0 lt=tick() end
end)
end
