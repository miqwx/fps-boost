do
local P = game:GetService("Players")
local R = game:GetService("RunService")
local LP = P.LocalPlayer
local UIS = game:GetService("UserInputService")

-- GUI
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.ResetOnSpawn = false

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0,280,0,200)
panel.Position = UDim2.new(0,50,0,50)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0) -- fundo preto
panel.BackgroundTransparency = 0.4
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

-- Barra de título
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "PAINEL FPS"
title.TextColor3 = Color3.fromRGB(255,0,0) -- letras vermelhas
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Center

-- Botão abrir/fechar
local closeBtn = Instance.new("TextButton", panel)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,5)

-- Começa fechado
local isOpen = false
for _,v in ipairs(panel:GetChildren()) do
    if v ~= title and v ~= closeBtn then
        v.Visible = false
    end
end

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

-- ARRASTAR PAINEL
local dragging=false
local dragStart=Vector2.new()
local startPos=UDim2.new()

title.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=input.Position
        startPos=panel.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then
                dragging=false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
end
