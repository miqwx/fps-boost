do
local P=game:GetService("Players")
local L=game:GetService("Lighting")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local LP=P.LocalPlayer

pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
if U.TouchEnabled then pcall(function() settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01 end) end

-- LIGHTING ULTRA LEVE
L.GlobalShadows=false
L.FogEnd=9e9
L.Brightness=0
L.EnvironmentDiffuseScale=0
L.EnvironmentSpecularScale=0
L.OutdoorAmbient=Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end end

-- REMOVE CÉU
for _,v in ipairs(L:GetChildren()) do
    if v:IsA("Sky") then v:Destroy() end
end

-- REMOVE ÁGUA
local Terrain=workspace:FindFirstChildOfClass("Terrain")
if Terrain then
    Terrain.WaterWaveSize=0
    Terrain.WaterWaveSpeed=0
    Terrain.WaterReflectance=0
    Terrain.WaterTransparency=1
end

-- Nomes de objetos de decoração/árvores
local nomes={"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function decor(o)
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

-- FUNÇÃO DE OTIMIZAÇÃO
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

-- REMOVE ACESSÓRIOS/ROUPAS DE OUTROS PLAYERS
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
