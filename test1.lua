-- [SERVICES]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [PLAYER & CHARACTER]
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- [UI ELEMENTS]
local frame = script.Parent
local danceButton = frame:WaitForChild("DanceButton")
local favButton = frame:WaitForChild("FavButton")
local syncButton = frame:WaitForChild("SyncButton")

-- [REMOTE EVENT]
local syncEvent = ReplicatedStorage:WaitForChild("SyncDanceEvent")

-- [DANCE CONFIGURATION]
-- You can find more free animation IDs in the Roblox creator marketplace
local danceList = {
	"rbxassetid://180435571", -- The Floss
	"rbxassetid://753696300", -- Club Dance
	"rbxassetid://523171384", -- Smooth Move
	"rbxassetid://653213608"  -- Orange Justice
}
-- This is a preset favorite dance. Change the ID to your favorite!
local favoriteDanceId = "rbxassetid://129577983" -- Gangnam Style

local currentDanceIndex = 0
local currentAnimationId = "" -- Tracks the last dance played
local currentTrack = nil      -- Tracks the currently playing animation
local animation = Instance.new("Animation") -- We'll reuse this object

-- [HELPER FUNCTION]
-- This function stops any old dance and plays a new one
local function playDance(animationId)
	-- Stop the previous dance if it's playing
	if currentTrack then
		currentTrack:Stop()
		currentTrack = nil
	end

	-- Get the player's current humanoid (in case they respawned)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	-- Load and play the new dance
	animation.AnimationId = animationId
	currentTrack = hum:LoadAnimation(animation)
	currentTrack.Looped = true -- Make the dance loop
	currentTrack:Play()

	-- Store this as the 'current' dance for the sync button
	currentAnimationId = animationId
end

-- [BUTTON CLICKS]

-- 1. Dance Button (Cycles through the list)
danceButton.MouseButton1Click:Connect(function()
	-- Go to the next dance in the list
	currentDanceIndex = (currentDanceIndex % #danceList) + 1
	playDance(danceList[currentDanceIndex])
end)

-- 2. Favorite Button (Plays your preset favorite)
favButton.MouseButton1Click:Connect(function()
	playDance(favoriteDanceId)
end)

-- 3. Sync Button (Tells the server to sync everyone)
syncButton.MouseButton1Click:Connect(function()
	-- Only sync if we are actually dancing
	if currentAnimationId ~= "" then
		-- Tell the server which dance we want everyone to do
		syncEvent:FireServer(currentAnimationId)
	end
end)

-- [LISTEN FOR SERVER]
-- This runs when the server tells US (and everyone else) to sync
syncEvent.OnClientEvent:Connect(function(danceIdToSync)
	-- The server has commanded a sync. Play the dance.
	playDance(danceIdToSync)
end)