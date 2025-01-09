local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local Tool = Instance.new('Tool')
Tool.RequiresHandle = true
Tool.Name = 'PartManipulator'

local target -- Variable to keep track of the target part

local function onActivated()
    -- Get the player's mouse
    local mouse = LocalPlayer:GetMouse()
    target = mouse.Target

    -- Check if the target is a valid unanchored part
    if target and target:IsA('BasePart') and not target.Anchored then
        LocalPlayer.SimulationRadius = 10000
        local inf = math.huge
        local partAtt = Instance.new('Attachment', target)
        target.CanCollide = false
        target.LocalTransparencyModifier = 1
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

        while Tool.Parent do  -- Keep applying the effect while holding the tool
            target.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
            task.wait(0.5)
        end
    else
        warn('Clicked part is not a valid unanchored part!')
    end
end

local function onUnequipped()
    if target then
        target.AssemblyAngularVelocity = Vector3.new(0, 0, 0) -- Reset angular velocity
        target = nil -- Clear the target reference
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

-- Parent the tool to the player’s backpack to give it to the player
Tool.Parent = LocalPlayer.Backpack
