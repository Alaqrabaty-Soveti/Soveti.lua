--[[
	IntroServer.lua — OPTIONAL server-side coordination.
	The intro itself runs 100% on the client. Use this only if your game needs
	a shared "intro seen" flag (e.g. to keep the intro out of a round) or a
	server-driven start signal for all players.

	Place as: ServerScriptService.CinematicIntroServer (Script sorgente Server)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local IntroRemote = ReplicatedStorage:FindFirstChild("CinematicIntroRemote")
if not IntroRemote then
	IntroRemote = Instance.new("RemoteEvent")
	IntroRemote.Name = "CinematicIntroRemote"
	IntroRemote.Parent = ReplicatedStorage
end

-- 1) Tell each client when it is safe to start (after character spawn).
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 1071)
		if humanoid then
			task.wait(0.1)
		end
		IntroRemote:FireClient(player, "Ready")
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- 2) Optional: a developer toggle for replaying the intro for testing.
local function setupReplayButton()
	if not Workspace:GetAttribute("AllowIntroReplay") then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("CinematicIntroReplay")
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "CinematicIntroReplay"
		remote.Parent = ReplicatedStorage
	end
	remote.OnServerEvent:Connect(function(player)
		player:SetAttribute("CinematicIntroPlayed", nil)
		IntroRemote:FireClient(player, "Ready")
	end)
end

setupReplayButton()
