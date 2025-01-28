-- Only useful for tools with collision
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService('UserInputService')

-- Create GUI
local ScreenGui = Instance.new('ScreenGui')
local MainFrame = Instance.new('Frame')
local DropButton = Instance.new('TextButton')
local PickUpButton = Instance.new('TextButton')
local CloseButton = Instance.new('TextButton')

ScreenGui.Parent = game.CoreGui

-- Frame properties
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

-- Drop Button properties
DropButton.Size = UDim2.new(0, 200, 0, 50)
DropButton.Position = UDim2.new(0.5, -100, 0, 20)
DropButton.Text = 'Drop Tool'
DropButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
DropButton.TextColor3 = Color3.new(1, 1, 1)
DropButton.Parent = MainFrame

-- Pick Up Button properties
PickUpButton.Size = UDim2.new(0, 200, 0, 50)
PickUpButton.Position = UDim2.new(0.5, -100, 0, 80)
PickUpButton.Text = 'Pick Up Tool'
PickUpButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
PickUpButton.TextColor3 = Color3.new(1, 1, 1)
PickUpButton.Parent = MainFrame

-- Close Button properties
CloseButton.Size = UDim2.new(0, 50, 0, 25)
CloseButton.Position = UDim2.new(1, -55, 0, 5)
CloseButton.Text = 'X'
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = MainFrame

-- Dragging functionality
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Store handles and tools
local storedTools = {}

-- Store equipped tools temporarily
local equippedTools = {}

-- Drop tools one at a time and re-equip them
local function dropTool()
    local character = LocalPlayer.Character
    character.HumanoidRootPart.Anchored = true
    if character then
        equippedTools = {} -- Reset equipped tools list
        local tools = {}

        -- Collect all equipped tools
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA('Tool') then
                table.insert(tools, tool)
                table.insert(equippedTools, tool) -- Keep track of equipped tools
            end
        end

        -- Drop tools sequentially
        for _, tool in ipairs(tools) do
            task.spawn(function()
                local handle = tool:FindFirstChild('Handle')
                if handle then
                    storedTools[tool] = handle

                    -- Drop the tool
                    handle.Parent = character
                    handle.Anchored = true
                    handle.Anchored = false
                    tool.Parent = LocalPlayer.Backpack
                end
            end)
            task.wait(0) -- Add a delay before processing the next tool
        end

        -- Re-equip tools after dropping
        
            for _, tool in ipairs(equippedTools) do
                if tool.Parent == LocalPlayer.Backpack then
                    task.wait(0)
                    tool.Parent = character -- Re-equip tool
                    
                    character.HumanoidRootPart.Anchored = false
                end
            end
        end
        end
   

-- Pick up tools
local function pickUpTool()
    local character = LocalPlayer.Character
    if character then
        for tool, handle in pairs(storedTools) do
            if handle and handle.Parent == character then
                if (handle.Position - character.HumanoidRootPart.Position).magnitude <= 50 then
                    handle.Parent = tool
                    tool.Parent = character

                    -- Remove the tool from the stored table
                    storedTools[tool] = nil
                end
            end
        end
    end
end

DropButton.MouseButton1Click:Connect(dropTool)
PickUpButton.MouseButton1Click:Connect(pickUpTool)

print('Drop Tool GUI Loaded!')
