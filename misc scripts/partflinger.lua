local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local Tool = Instance.new('Tool')
Tool.RequiresHandle = true
Tool.Name = 'PartFlinger'

local targets = {} -- Table to keep track of all targeted parts

local function clearAttachments(part)
    for _, attachment in pairs(part:GetChildren()) do
        if attachment:IsA('Attachment') then
            attachment:Destroy() -- Remove all attachments
        end
    end
end

local function removeTouchTransmitters(model)
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA('BasePart') then
            for _, child in pairs(part:GetChildren()) do
                if child:IsA('TouchTransmitter') then
                    child:Destroy() -- Remove touch transmitters
                end
            end
        end
    end
end

local function onActivated()
    -- Get the player's mouse
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target

    -- Check if the target is a valid unanchored part
    if target and target:IsA('BasePart') and not target.Anchored then
        -- Ensure the target is not already being targeted
        if not targets[target] then
            targets[target] = true -- mark the part as targeted
            target.CanCollide = false

            -- Get the model the part is from
            local model = target.Parent
            if model and model:IsA('Model') then
                local success, err = pcall(function()
                    for _, part in pairs(model:GetChildren()) do
                        if part:IsA('BasePart') then
                            part.CollisionGroupId = 1 -- Set collision group
                        end
                    end
                end)
                if not success then
                    warn('Failed to change collision state of model parts:', err)
                end
                removeTouchTransmitters(model) -- Remove touch transmitters
            end

            clearAttachments(target)
            LocalPlayer.SimulationRadius = 10000
            local inf = math.huge
            local partAtt = Instance.new('Attachment', target)
            target.LocalTransparencyModifier = 0

            local AP = Instance.new('AlignPosition', target)
            AP.MaxAxesForce = Vector3.new(inf, inf, inf)
            AP.MaxForce = inf
            AP.Responsiveness = 200
            AP.ApplyAtCenterOfMass = true
            AP.Attachment0 = partAtt
            AP.Attachment1 = LocalPlayer.Character.HumanoidRootPart.RootAttachment
 local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
        task.wait(1)
        LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos

            -- Keep applying the effect while holding the tool using RenderStepped
               
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
        task.wait(1)
        LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos

        while Tool.Parent do  -- Keep applying the effect while holding the tool
            target.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
            task.wait()
        end
    else
        warn('Clicked part is not a valid unanchored part!')
    end
end
end

local function onUnequipped()
    for target, _ in pairs(targets) do
        if target then
            target.AssemblyAngularVelocity = Vector3.new(0, 0, 0) -- Reset angular velocity
            clearAttachments(target)

            -- Restore original collision group state for the target part
            local model = target.Parent
            if model and model:IsA('Model') then
                local success, err = pcall(function()
                    for _, part in pairs(model:GetChildren()) do
                        if part:IsA('BasePart') then
                            part.CollisionGroupId = 0 -- Restore collision group
                            
                        end
                    end
                end)
                if not success then
                    warn('Failed to restore collision state of model parts:', err)
                end
            end

            target.LocalTransparencyModifier = 0 -- Reset transparency
            targets[target] = nil -- Clear target
        end
    end
end

Tool.Activated:Connect(onActivated)
Tool.Unequipped:Connect(onUnequipped)

-- Set the tool's handle (required for equipping)
local handle = Instance.new('Part')
handle.Size = Vector3.new(1, 1, 1)
handle.CanCollide = false
handle.Name = 'Handle'
handle.Parent = Tool
handle.Transparency = 1

-- Parent the tool to the player’s backpack to give it to the player
Tool.Parent = LocalPlayer.Backpack
