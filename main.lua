do
local P=game:GetService("Players")
local L=game:GetService("Lighting")
local R=game:GetService("RunService")
local LP=P.LocalPlayer

-- CONFIGURAÇÃO RÁPIDA DE GRÁFICOS
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)

-- LIGHTING ULTRA LEVE
L.GlobalShadows=false
L.FogEnd=9e9
L.Brightness=0
L.EnvironmentDiffuseScale=0
L.EnvironmentSpecularScale=0
L.OutdoorAmbient=Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
end

-- FUNÇÃO PARA REMOVER CÉU E ÁGUA
local function removeSkyWater()
    -- CÉU
    for _,v in ipairs(L:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
    for _,v in ipairs(workspace:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
    -- ÁGUA DO TERRAIN
    local Terrain=workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize=0
        Terrain.WaterWaveSpeed=0
        Terrain.WaterReflectance=0
        Terrain.WaterTransparency=1
    end
    -- ÁGUA COMO PARTS
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local c=v.Color
            if c.B>c.R and c.B>c.G and v.Size.Y<20 and v.Name:lower():find("water") then
                v:Destroy()
            end
        end
    end
end

-- REMOVE CÉU E ÁGUA IMEDIATAMENTE
removeSkyWater()
-- MONITORA O JOGO CONTINUAMENTE
R.RenderStepped:Connect(removeSkyWater)

-- FUNÇÃO PARA REMOVER DECORAÇÕES/ÁRVORES
local nomes={"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function decor(o)
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

local function opt(o)
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

-- REMOVE ACESSÓRIOS E ROUPAS DOS PLAYERS
local function char(c)
    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency=1
        elseif v:IsA("Clothing") then v:Destroy() end
    end
end
for _,p in ipairs(P:GetPlayers()) do if p.Character then char(p.Character) end end
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(char) end)

-- PAINEL DE FPS
local g=Instance.new("ScreenGui",LP.PlayerGui)
g.ResetOnSpawn=false
local f=Instance.new("Frame",g)
f.Size=UDim2.new(0,140,0,40)
f.Position=UDim2.new(0,10,0,10)
f.BackgroundTransparency=0.6
f.BackgroundColor3=Color3.new(0,0,0)
Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)

local t=Instance.new("TextLabel",f)
t.Size=UDim2.fromScale(1,1)
t.BackgroundTransparency=1
t.TextColor3=Color3.fromRGB(0,255,0)
t.Font=Enum.Font.SourceSansBold
t.TextSize=18

local c,lt=0,tick()
R.RenderStepped:Connect(function()
    c+=1
    if tick()-lt>=1 then t.Text="FPS: "..c c=0 lt=tick() end
end)
end
