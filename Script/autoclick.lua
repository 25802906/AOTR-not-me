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
local flags = {Auto_Clicking = true, Mouse_Locked = true} -- Auto_Clicking and Mouse_Locked are true by default
local TaskWait = task.wait
local LockedPosition = Vector2.new(1160, 796) -- Locked position

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
    Size = 13,
    Outline = true,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    Color = Color3.fromRGB(0, 0, 0),
    Text = "Auto Clicking : TRUE\nMouse Locked : TRUE\nPosition: (kagari1314)", -- Auto Clicking and Mouse Locked are TRUE by default
    Visible = true,
})

-- Key Bind
UIS.InputBegan:Connect(function(inputObj, GPE)
    if (not GPE) then
        if (inputObj.KeyCode == getKeycode(Settings["Auto Click Keybind"])) then
            flags.Auto_Clicking = not flags.Auto_Clicking
        end
        
        if (inputObj.KeyCode == getKeycode(Settings["Lock Mouse Position Keybind"])) then
            flags.Mouse_Locked = not flags.Mouse_Locked
        end

        Text.Text = ("Auto Clicking : %s\nMouse Locked : %s\nPosition: %s"):format(
            tostring(flags.Auto_Clicking):upper(), 
            tostring(flags.Mouse_Locked):upper(), 
            flags.Mouse_Locked and string.format("(%d, %d)", LockedPosition.X, LockedPosition.Y) or "N/A"
        )
    end
end)

-- Auto Click
while (true) do
    Text.Visible = Settings.GUI
    Text.Position = Vector2.new(Camera.ViewportSize.X - 133, Camera.ViewportSize.Y - 48)

    if (flags.Auto_Clicking) then
        for i = 1, 2 do
            if (flags.Mouse_Locked) then
                VIM:SendMouseButtonEvent(LockedPosition.X, LockedPosition.Y, Settings["Right Click"] and 1 or 0, i == 1, nil, 0)
            else
                local Mouse = UIS:GetMouseLocation()
                VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, Settings["Right Click"] and 1 or 0, i == 1, nil, 0)
            end
        end
    end

    if (Settings.Delay <= 0) then
        RunService.RenderStepped:Wait()
    else
        TaskWait(Settings.Delay)
    end
end
