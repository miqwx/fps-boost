do
local P = game:GetService("Players")
local R = game:GetService("RunService")
local LP = P.LocalPlayer
local UIS = game:GetService("UserInputService")

-- 🔹 Remover limite de FPS
pcall(function()
    settings().Rendering.PhysicsFPS = 0
    settings().Rendering.FramesPerSecond = 0
end)

-- FUNÇÕES DE OTIMIZAÇÃO
local nomes = {"tree","arvore","plant","bush","grass","folha","leaf","palm","rock","pedra","decor","prop"}
local function decor(o)
    for _,n in ipairs(nomes) do if o.Name:lower():find(n) then return true end end
    if o:IsA("BasePart") then local c=o.Color if c.G>c.R and c.G>c.B and o.Size.Y>4 then return true end end
end

local function opt(o)
    if o:IsDescendantOf(LP.Character) then return end
    if o:IsA("BasePart") then
        o.Material = Enum.Material.Plastic
        o.Reflectance = 0
        o.CastShadow = false
        if decor(o) then o:Destroy() end
    elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency = 1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then o.Enabled = false
    elseif (o:IsA("Model") or o:IsA("Folder")) and decor(o) then o:Destroy() end
end

local function applyGraphics()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

local function fpsBoost()
    applyGraphics()
    for _,v in ipairs(workspace:GetDescendants()) do opt(v) end
end

local function removeDecor()
    for _,v in ipairs(workspace:GetDescendants()) do if decor(v) then v:Destroy() end end
end

local function char(c)
    if c == LP.Character then return end
    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = 1
        elseif v:IsA("Clothing") then v:Destroy() end
    end
end

local function invisPlayers()
    for _,p in ipairs(P:GetPlayers()) do if p.Character and p ~= LP then char(p.Character) end end
end

-- GUI
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.ResetOnSpawn = false

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 280, 0, 360)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.4
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

-- Barra de título
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "FPS BOOST MENU EXTREME"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Center

-- Botão fechar
local closeBtn = Instance.new("TextButton", panel)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,10)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,5)

local isOpen = true
closeBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    for _,v in ipairs(panel:GetChildren()) do
        if v ~= title and v ~= closeBtn then
            v.Visible = isOpen
        end
    end
end)

-- FPS Label
local fpsLabel = Instance.new("TextLabel", panel)
fpsLabel.Size = UDim2.new(1,-20,0,30)
fpsLabel.Position = UDim2.new(0,10,0,60)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(255,0,0)
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 18
fpsLabel.Text = "FPS: 0"

local c,lastTime=0,tick()
R.RenderStepped:Connect(function()
    c+=1
    if tick()-lastTime>=1 then
        fpsLabel.Text="FPS: "..c
        c=0
        lastTime=tick()
    end
end)

-- Função criar botões toggle
local function createToggleButton(name,posY,func)
    local state=false
    local btn=Instance.new("TextButton",panel)
    btn.Size=UDim2.new(1,-20,0,45)
    btn.Position=UDim2.new(0,10,0,posY)
    btn.Text=name.." [OFF]"
    btn.BackgroundColor3=Color3.fromRGB(0,0,0)
    btn.TextColor3=Color3.fromRGB(255,0,0)
    btn.Font=Enum.Font.SourceSansBold
    btn.TextSize=16
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        state=not state
        btn.Text=name.." ["..(state and "ON" or "OFF").."]"
        if state then func() end
    end)

    btn.MouseEnter:Connect(function() btn.BackgroundColor3=Color3.fromRGB(30,30,30) end)
    btn.MouseLeave:Connect(function() btn.Background
