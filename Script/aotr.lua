local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local nape
local isTeleportEnabled = false
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

UserInputService.InputEnded:Connect(function(input)
    if (input.KeyCode == Enum.KeyCode.Z) then
        toggleTeleportation()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isTeleportEnabled then
        performConsecutiveTeleports()
    end
end)
