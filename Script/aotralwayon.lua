local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local nape
local isTeleportEnabled = true -- Enable teleportation by default
local MAX_TELEPORT_DISTANCE = math.huge

-- Function to get the LocalPlayer's HumanoidRootPart location
local function getLocalPlayerHumanoidRootPartLocation()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
        local humanoidRootPartLocation = humanoidRootPart.Position
        print("HumanoidRootPart Location:", humanoidRootPartLocation)
        return humanoidRootPartLocation
    else
        warn("HumanoidRootPart not found for LocalPlayer.")
        return nil
    end
end

-- Function to find the closest Nape location within the maximum teleport distance
local function findClosestNapeLocation()
    local titansFolder = Workspace:FindFirstChild("Titans")
    local closestNapeLocation = nil
    local shortestDistance = math.huge

    if titansFolder then
        local playerPosition = getLocalPlayerHumanoidRootPartLocation()
        for _, model in ipairs(titansFolder:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
                local hitBoxes = model:FindFirstChild("Hitboxes")
                if hitBoxes then
                    local hit = hitBoxes:FindFirstChild("Hit")
                    if hit then
                        local napePart = hit:FindFirstChild("Nape")
                        if napePart then
                            local distance = (napePart.Position - playerPosition).Magnitude
                            if distance < shortestDistance and distance <= MAX_TELEPORT_DISTANCE then
                                shortestDistance = distance
                                closestNapeLocation = napePart
                            end
                        end
                    end
                end
            end
        end
    else
        warn("Titans folder not found in Workspace.")
    end

    if closestNapeLocation then
        nape = closestNapeLocation
        print("Closest NapeLocation set to:", nape.Position)
    else
        warn("No Nape part found within maximum teleport distance.")
    end

    return nape
end

-- Function to start hovering above the Nape
local function startHoveringAboveNape()
    if nape then
        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyPosition.Position = nape.Position + Vector3.new(0, 450, 0)
            bodyPosition.Parent = humanoidRootPart

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.CFrame = humanoidRootPart.CFrame
            bodyGyro.Parent = humanoidRootPart

            return bodyPosition, bodyGyro
        end
    else
        warn("Nape not found.")
        return nil, nil
    end
end

-- Function to stop hovering
local function stopHovering(bodyPosition, bodyGyro)
    if bodyPosition then
        bodyPosition:Destroy()
    end
    if bodyGyro then
        bodyGyro:Destroy()
    end
end

-- Function to perform consecutive teleports upon releasing the left mouse button
local function performConsecutiveTeleports()
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local originalPosition = humanoidRootPart.Position

        local function teleportTo(position)
            humanoidRootPart.CFrame = CFrame.new(position)
        end

        local function teleport()
            findClosestNapeLocation() -- Update NapeLocation
            if nape then
                local napePosition = nape.Position
                local quarterDistance = (napePosition - originalPosition) / 4
                local threeQuarterDistance = quarterDistance * 3

                for i = 1, 2 do
                    teleportTo(originalPosition + threeQuarterDistance)
                    wait(0.001)
                    teleportTo(napePosition)
                    teleportTo(napePosition)
                    teleportTo(napePosition)
                end
            end
        end

        teleport()
    end
end

-- Function to handle toggling teleportation
local function toggleTeleportation()
    isTeleportEnabled = not isTeleportEnabled

    if isTeleportEnabled then
        print("Teleportation Enabled")
        findClosestNapeLocation()
        local bodyPosition, bodyGyro = startHoveringAboveNape()

        -- Keep hovering while teleportation is enabled
        spawn(function()
            while isTeleportEnabled do
                wait(1) -- Cooldown
                findClosestNapeLocation()
                if bodyPosition and bodyGyro then
                    bodyPosition.Position = nape.Position + Vector3.new(0, 300, 0)
                    bodyGyro.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
            stopHovering(bodyPosition, bodyGyro)
        end)
    else
        print("Teleportation Disabled")
    end
end

-- Function to teleport to the refill tank
local function teleportToTank()
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tank = Workspace.Unclimbable.Reloads.GasTanks:FindFirstChild("GasTank"):FindFirstChild("GasTank")
    if tank and humanoidRootPart then
        humanoidRootPart.CFrame = tank.CFrame + Vector3.new(-3, 0, -3)
    end
end

-- Create a GUI to toggle teleportation and teleport to refill
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 50) -- Adjust button size
toggleButton.Position = UDim2.new(0.5, -100, 0, 0) -- Adjust button position to center horizontally
toggleButton.Text = "Teleport Enabled (Z=On/Off)"
toggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Parent = screenGui


-- Nút để teleport tới refill
local teleportRefillButton = Instance.new("TextButton")
teleportRefillButton.Size = UDim2.new(0, 200, 0, 50)
teleportRefillButton.Position = UDim2.new(0.5, -100, 0, 60) -- Place below the Discord button
teleportRefillButton.Text = "Teleport to Refill"
teleportRefillButton.BackgroundColor3 = Color3.new(0, 1, 0)
teleportRefillButton.TextColor3 = Color3.new(1, 1, 1)
teleportRefillButton.Parent = screenGui

-- Toggle teleportation when button is clicked
toggleButton.MouseButton1Click:Connect(function()
    toggleTeleportation()
    toggleButton.Text = isTeleportEnabled and "Teleport Enabled (Z=On/Off)" or "Teleport Disabled (Z=On/Off)"
    toggleButton.BackgroundColor3 = isTeleportEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)


-- Teleport to refill when button is clicked
teleportRefillButton.MouseButton1Click:Connect(function()
    teleportToTank()
end)

-- Teleport to refill when X key is pressed
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        teleportToTank()
    end
end)

-- Connect the function to the UserInputService's InputEnded event
UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isTeleportEnabled then
        performConsecutiveTeleports()
    elseif input.KeyCode == Enum.KeyCode.Z then
        toggleTeleportation()
        toggleButton.Text = isTeleportEnabled and "Teleport Enabled (Z=On/Off)" or "Teleport Disabled (Z=On/Off)"
        toggleButton.BackgroundColor3 = isTeleportEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end
end)

-- Start hovering above the nape if teleportation is enabled
if isTeleportEnabled then
    findClosestNapeLocation()
    local bodyPosition, bodyGyro = startHoveringAboveNape()

    -- Keep hovering while teleportation is enabled
    spawn(function()
        while isTeleportEnabled do
            wait(1) -- Cooldown
            findClosestNapeLocation()
            if bodyPosition and bodyGyro then
                bodyPosition.Position = nape.Position + Vector3.new(0, 300, 0)
                bodyGyro.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
        stopHovering(bodyPosition, bodyGyro)
    end)
end
