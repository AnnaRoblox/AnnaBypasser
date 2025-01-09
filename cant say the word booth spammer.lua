-- made by anna
-- change text here to your text and no you cant make it faster if you remove the wait itll crash your device
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

_G.spammingEnabled = true  -- Global variable to control spamming
local spamDelay = 0 -- Delay between spam to prevent lag

local function fireRemotes(givenText)
    local booths = {"Booth1", "Booth2", "Booth3", "Booth4", "Booth5", "Booth6"}
    while _G.spammingEnabled do  -- Loop to continue spamming as long as it is enabled
        for _, booth in ipairs(booths) do
            local remotePath = workspace[booth].ClaimBooth.ChangeText.UpdateSign
            remotePath:FireServer(givenText)  -- Fire the remote with the given text
            task.wait(spamDelay)  -- Wait to prevent lag
        end
    end
end

-- Example usage
spawn(function()  -- Start a new thread to call fireRemotes
fireRemotes("text here")
end)
-- Function to stop spamming
local function stopSpamming()  
    _G.spammingEnabled = false
end
