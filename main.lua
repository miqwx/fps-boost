do
local P=game:GetService("Players")
local R=game:GetService("RunService")
local LP=P.LocalPlayer

-- CONFIGURAÇÃO GRÁFICA
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)

-- FUNÇÃO PARA REMOVER DECORAÇÕES/ÁRVORES
local nomes={"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function decor(o)
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

local function opt(o)
    if o:IsDescendantOf(LP.Character) then return end
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
    if c==LP.Character then return end
    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency=1
        elseif v:IsA("Clothing") then v:Destroy() end
    end
end
for _,p in ipairs(P:GetPlayers()) do if p.Character then char(p.Character) end end
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(char) end)

-- PAINEL/MENU
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.ResetOnSpawn = false

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 250, 0, 320)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BackgroundTransparency = 0.4
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

-- Título
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FPS BOOST MENU"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- FPS Label
local fpsLabel = Instance.new("TextLabel", panel)
fpsLabel.Size = UDim2.new(1, -20, 0, 30)
fpsLabel.Position = UDim2.new(0, 10, 0, 50)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 18
fpsLabel.Text = "FPS: 0"

-- Contador de FPS
local c, lastTime = 0, tick()
R.RenderStepped:Connect(function()
    c+=1
    if tick()-lastTime>=1 then
        fpsLabel.Text = "FPS: "..c
        c=0
        lastTime = tick()
    end
end)

-- Função de criar botões
local function createButton(name, posY, callback)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- Botões com funções reais
createButton("Ativar FPS Boost", 90, function()
    for _,v in ipairs(workspace:GetDescendants()) do opt(v) end
end)

createButton("Remover Decorações", 140, function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if decor(v) then
            v:Destroy()
        end
    end
end)

createButton("Invisibilizar Players", 190, function()
    for _,p in ipairs(P:GetPlayers()) do
        if p.Character and p~=LP then char(p.Character) end
    end
end)
end
