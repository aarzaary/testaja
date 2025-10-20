-- Triple Jump System for Roblox Studio
-- Place this script in StarterPlayer > StarterCharacterScripts

local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

-- Configuration
local MAX_JUMPS = 3
local JUMP_POWER = 50

-- Variables
local jumpsRemaining = MAX_JUMPS
local isJumping = false

-- Function to check if character is on ground
local function isGrounded()
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end
	
	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -5, 0)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	return rayResult ~= nil
end

-- Reset jumps when touching ground
humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Landed then
		jumpsRemaining = MAX_JUMPS
		isJumping = false
	elseif newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Flying then
		if isGrounded() then
			jumpsRemaining = MAX_JUMPS
		end
	end
end)

-- Handle jump input
UserInputService.JumpRequest:Connect(function()
	if jumpsRemaining > 0 then
		-- Perform the jump
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			-- Apply upward velocity
			rootPart.Velocity = Vector3.new(rootPart.Velocity.X, JUMP_POWER, rootPart.Velocity.Z)
			jumpsRemaining = jumpsRemaining - 1
			isJumping = true
			
			-- Optional: Add visual/audio feedback here
			-- Example: spawn a particle effect or play a sound
		end
	end
end)

-- Initial setup
task.wait(0.1)
if isGrounded() then
	jumpsRemaining = MAX_JUMPS
end
