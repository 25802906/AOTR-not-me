-- Already Running
if getgenv()["Already Running"] then return else getgenv()["Already Running"] = true end

-- Services
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Vars
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local flags = {Auto_Clicking = true, Mouse_Locked = true, Mouse_Locked_Position = Vector2.new(1162, 846)}  -- Auto-click enabled by default
local TaskWait = task.wait

-- Get Keybind
local getKeycode = function(bind)
    return (pcall(function() return Enum.KeyCode[bind] end) and Enum.KeyCode[bind] or bind)
end

-- Draw
local Draw = function(obj, props)
    local NewObj = Drawing.new(obj)
    for i, v in next, props do
        NewObj[i] = v
    end
    return NewObj
end

-- Create GUI
local Text = Draw("Text", {
    Size = 10,
    Outline = true,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    Color = Color3.fromRGB(0, 0, 0),
    Text = "Auto Clicking : TRUE\nMouse Locked : TRUE\nPosition: (1160, 796)",  -- Auto-click enabled by default
    Visible = true,
})

-- Key Bind
UIS.InputBegan:Connect(function(inputObj, GPE)
    if (not GPE) then
        if (inputObj.KeyCode == getKeycode(Settings["Auto Click Keybind"])) then
            flags.Auto_Clicking = not flags.Auto_Clicking
        end
        
        if (inputObj.KeyCode == getKeycode(Settings["Lock Mouse Position Keybind"])) then
            flags.Mouse_Locked = true  -- Always keep mouse lock enabled
        end

        Text.Text = ("Auto Clicking : %s\nMouse Locked : %s\nPosition: %s"):format(
            tostring(flags.Auto_Clicking):upper(), 
            tostring(flags.Mouse_Locked):upper(), 
            flags.Mouse_Locked and string.format("(%d, %d)", flags.Mouse_Locked_Position.X, flags.Mouse_Locked_Position.Y) or "N/A"
        )
    end
end)

-- Auto Click
while (true) do
    Text.Visible = Settings.GUI
    Text.Position = Vector2.new(Camera.ViewportSize.X - 133, Camera.ViewportSize.Y - 48)

    if (flags.Auto_Clicking) then
        for i = 1, 2 do
            VIM:SendMouseButtonEvent(flags.Mouse_Locked_Position.X, flags.Mouse_Locked_Position.Y, Settings["Right Click"] and 1 or 0, i == 1, nil, 0)
        end
    end

    if (Settings.Delay <= 0) then
        RunService.RenderStepped:Wait()
    else
        TaskWait(Settings.Delay)
    end
end
