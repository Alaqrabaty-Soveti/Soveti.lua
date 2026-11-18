--[[
	IntroClient.lua — entry point (LocalScript in StarterPlayerScripts).
	Owns the sequence: camera, UI, effects, audio, skip handling and cleanup.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Load modules from ReplicatedStorage.CinematicIntro
local modules = ReplicatedStorage:WaitForChild("CinematicIntro")
local Config = require(modules:WaitForChild("Config"))
local CameraController = require(modules:WaitForChild("CameraController"))
local UIManager = require(modules:WaitForChild("UIManager"))
local AudioManager = require(modules:WaitForChild("AudioManager"))
local EffectsManager = require(modules:WaitForChild("EffectsManager"))

-- Prevent double playback (e.g. script re-runs / respawns).
local PLAYED_ATTRIBUTE = "CinematicIntroPlayed"
if player:GetAttribute(PLAYED_ATTRIBUTE) then
	return
end
player:SetAttribute(PLAYED_ATTRIBUTE, true)

local state = {
	finished = false,
	skipRequested = false,
	camera = nil,
	ui = nil,
	audio = nil,
	effects = nil,
	controls = nil,
}

local function getControls()
	local playerScripts = player:FindFirstChild("PlayerScripts")
	if not playerScripts then
		return nil
	end
	local ok, playerModule = pcall(function()
		return require(playerScripts:WaitForChild("PlayerModule", 5))
	end)
	if not ok or not playerModule then
		return nil
	end
	local okControls, controls = pcall(function()
		return playerModule:GetControls()
	end)
	if okControls then
		return controls
	end
	return nil
end

local function disableControls()
	state.controls = getControls()
	if state.controls then
		pcall(function()
			state.controls:Disable()
		end)
	end
end

local function enableControls()
	if state.controls then
		pcall(function()
			state.controls:Enable()
		end)
		state.controls = nil
	end
end

-- Idempotent cleanup: safe to call from skip, error, or normal completion.
local function cleanup()
	if state.finished then
		return
	end
	state.finished = true

	local camera = state.camera
	local effects = state.effects
	local audio = state.audio
	local ui = state.ui
	state.camera = nil
	state.effects = nil
	state.audio = nil
	state.ui = nil

	enableControls()
	if camera then
		pcall(function()
			camera:stop()
		end)
	end
	if effects then
		pcall(function()
			effects:stop(0.7)
		end)
	end
	if audio then
		pcall(function()
			audio:stopAll(0.7)
		end)
	end
	if ui then
		pcall(function()
			ui:destroy()
		end)
	end
end

local function requestSkip()
	if state.finished or state.skipRequested then
		return
	end
	state.skipRequested = true
end

-- Wait helper that aborts early when the player skips.
local function waitOrSkip(seconds)
	local elapsed = 0
	local step = 0.05
	while elapsed < seconds do
		if state.skipRequested or state.finished then
			return true
		end
		task.wait(step)
		elapsed = elapsed + step
	end
	return state.skipRequested or state.finished
end

-- Graceful ending: fade the overlay out, then release camera/controls.
local function finishWithFade()
	if state.finished then
		return
	end
	if state.ui then
		pcall(function()
			state.ui:fadeOut(Config.Fade.FadeOutTime)
		end)
	end
	local elapsed = 0
	while elapsed < Config.Fade.FadeOutTime + 0.15 do
		if state.finished then
			return
		end
		task.wait(0.05)
		elapsed = elapsed + 0.05
	end
	cleanup()
end

local function waitForCharacter()
	local character = player.Character
	if not character then
		character = player.CharacterAdded:Wait()
	end
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid and humanoid.Health <= 0 then
		humanoid.HealthChanged:Wait()
	end
	character:WaitForChild("HumanoidRootPart", 5)
	return character
end

local function playIntro()
	waitForCharacter()
	disableControls()

	state.effects = EffectsManager.new(Config)
	state.effects:start()

	-- Hold the screen dark first, then reveal the cinematic frame.
	local playerGui = player:WaitForChild("PlayerGui")
	local dark = Instance.new("Frame")
	dark.Name = "IntroDarkStart"
	dark.Size = UDim2.fromScale(1, 1)
	dark.BackgroundColor3 = Config.Colors.Background
	dark.BackgroundTransparency = 0
	dark.BorderSizePixel = 0
	dark.ZIndex = 20
	dark.Parent = playerGui

	state.ui = UIManager.new(Config, requestSkip)
	state.ui:fadeIn(Config.Fade.FadeInTime)
	dark.Parent = state.ui.gui
	dark.ZIndex = 20
	TweenService:Create(dark, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	}):Play()
	task.delay(1.6, function()
		if dark.Parent then
			dark:Destroy()
		end
	end)

	state.audio = AudioManager.new(Config)
	state.audio:start()

	state.camera = CameraController.new()
	if not state.camera:start(Config) then
		cleanup()
		return
	end

	-- Scene 1: opening — dark screen, light line, small title hint.
	state.ui:pulseTint(0.18, 1.6)
	if waitOrSkip(Config.Audio.SyncPoints.Beat1) then
		finishWithFade()
		return
	end

	-- Scene 2: establish the world, soften blur, cool color grade.
	state.effects:setBlur(Config.Effects.BlurAmount * 0.4, 1.2)
	state.ui:pulseTint(0.12, 1.4)
	if waitOrSkip(Config.Audio.SyncPoints.Beat2 - Config.Audio.SyncPoints.Beat1) then
		finishWithFade()
		return
	end

	-- Scene 3: hero entrance.
	state.effects:setBlur(0, 1.0)
	if waitOrSkip(Config.Audio.SyncPoints.Climax - Config.Audio.SyncPoints.Beat2) then
		finishWithFade()
		return
	end

	-- Scene 4: climax — flash, shake, color punch, brief glitch.
	state.ui:flash()
	state.effects:punch(0.18, 0.8)
	task.spawn(function()
		if state.ui then
			state.ui:glitch(0.3)
		end
	end)
	if waitOrSkip(Config.Audio.SyncPoints.Title - Config.Audio.SyncPoints.Climax) then
		finishWithFade()
		return
	end

	-- Scene 5: title and welcome text.
	state.ui:showTitle()
	task.spawn(function()
		if state.ui then
			state.ui:showSubtitle()
		end
	end)

	local remaining = math.max(Config.IntroDuration - Config.Audio.SyncPoints.Title, 1.5)
	if waitOrSkip(remaining) then
		finishWithFade()
		return
	end

	state.ui:fadeOut(Config.Fade.FadeOutTime)
	waitOrSkip(Config.Fade.FadeOutTime + 0.2)
	cleanup()
end

-- Handle the player leaving / character despawn during the intro.
local leaveConn = player.AncestryChanged:Connect(function()
	if not player:IsDescendantOf(game) then
		cleanup()
	end
end)

-- Watchdog: make sure the camera/controls are never left locked, even if
-- a scene yields unexpectedly. Scheduled BEFORE the sequence starts.
task.delay(Config.IntroDuration + 8, function()
	if not state.finished then
		warn("[CinematicIntro] watchdog released the intro state")
		cleanup()
	end
end)

local ok, err = pcall(playIntro)
if not ok then
	warn("[CinematicIntro] intro failed safely:", err)
	cleanup()
end
leaveConn:Disconnect()
