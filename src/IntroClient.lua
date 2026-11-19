--[[
	IntroClient.lua — the director (LocalScript in StarterPlayerScripts).
	Owns the whole sequence: camera rig, UI, VFX, post FX, audio, timeline,
	skip handling, progress bar, watchdog and guaranteed cleanup.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local modules = ReplicatedStorage:WaitForChild("CinematicIntro")
local Config = require(modules:WaitForChild("Config"))
local CameraController = require(modules:WaitForChild("CameraController"))
local UIManager = require(modules:WaitForChild("UIManager"))
local AudioManager = require(modules:WaitForChild("AudioManager"))
local EffectsManager = require(modules:WaitForChild("EffectsManager"))
local VFXManager = require(modules:WaitForChild("VFXManager"))

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
	vfx = nil,
	controls = nil,
	startedAt = os.clock(),
}

-- ── Controls lock ───────────────────────────────────────────────────────────
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
	return okControls and controls or nil
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

-- ── Cleanup (idempotent) ────────────────────────────────────────────────────
local function cleanup()
	if state.finished then
		return
	end
	state.finished = true

	local camera, effects, audio, ui, vfx =
		state.camera, state.effects, state.audio, state.ui, state.vfx
	state.camera, state.effects, state.audio, state.ui, state.vfx =
		nil, nil, nil, nil, nil

	enableControls()
	if camera then
		pcall(function()
			camera:stop()
		end)
	end
	if vfx then
		pcall(function()
			vfx:stop()
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

-- ── Timeline action dispatch ────────────────────────────────────────────────
local actions = {}

function actions.fadeIn(_, args)
	if state.ui then
		state.ui:fadeIn()
	end
end

function actions.fadeOut()
	if state.ui then
		state.ui:fadeOut()
	end
end

function actions.flash()
	if state.ui then
		state.ui:flash()
	end
end

function actions.glitch(_, args)
	if state.ui then
		state.ui:glitch(args and args[1] or 0.3)
	end
end

function actions.tint(_, args)
	if state.ui then
		state.ui:pulseTint(args and args[1] or 0.2, args and args[2] or 1.4)
	end
end

function actions.vignette(_, args)
	if state.ui then
		state.ui:vignette(args and args[1] or 0.5)
	end
end

function actions.letterbox(_, args)
	if state.ui then
		state.ui:letterbox(args and args[1] ~= false)
	end
end

function actions.title()
	if state.ui then
		state.ui:showTitle()
	end
end

function actions.subtitle()
	if state.ui then
		state.ui:showSubtitle()
	end
end

function actions.tagline()
	if state.ui then
		state.ui:showTagline()
	end
end

function actions.blur(_, args)
	if state.effects then
		state.effects:setBlur(args and args[1] or 0, 1.0)
	end
end

function actions.punch(_, args)
	if state.effects then
		state.effects:punch(args and args[1] or 0.2, args and args[2] or 0.8)
	end
end

function actions.shake(_, args)
	if state.camera then
		state.camera:shake(args and args[1] or 0.8)
	end
end

function actions.sfx(_, args)
	local name = args and args[1]
	if name and state.audio then
		state.audio:playCue(name)
	end
end

function actions.whoosh()
	if state.audio then
		state.audio:playCue("Whoosh")
	end
end

function actions.impact()
	if state.audio then
		state.audio:playCue("Impact")
	end
end

function actions.burst(_, args)
	if state.vfx then
		state.vfx:burst(args and args[1] or 1)
	end
end

function actions.ring(_, args)
	if state.vfx then
		state.vfx:ring(args and args[1] or 1)
	end
end

function actions.beams(_, args)
	if state.vfx then
		state.vfx:beams(args and args[1] or 1)
	end
end

function actions.speedLines(_, args)
	if state.vfx then
		state.vfx:speedLines(args and args[1] or 1)
	end
end

function actions.embers(_, args)
	if state.vfx then
		state.vfx:embers(args and args[1] or 1)
	end
end

-- ── Sequence ────────────────────────────────────────────────────────────────
local function waitForCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid and humanoid.Health <= 0 then
		humanoid.HealthChanged:Wait()
	end
	character:WaitForChild("HumanoidRootPart", 5)
	return character
end

local function runTimeline()
	local timeline = Config.Timeline
	local index = 1
	local elapsed = 0
	local duration = Config.IntroDuration
	local step = 1 / 30

	while elapsed < duration do
		if state.skipRequested or state.finished then
			return true
		end

		while index <= #timeline and timeline[index].t <= elapsed do
			local event = timeline[index]
			local handler = actions[event.action]
			if handler then
				local ok, err = pcall(handler, nil, event.args)
				if not ok then
					warn("[CinematicIntro] action failed:", event.action, err)
				end
			end
			index = index + 1
		end

		if state.ui then
			state.ui:setProgress(elapsed / duration)
		end

		task.wait(step)
		elapsed = elapsed + step
	end

	-- Flush any events scheduled at/after the final tick.
	while index <= #timeline do
		local event = timeline[index]
		local handler = actions[event.action]
		if handler then
			pcall(handler, nil, event.args)
		end
		index = index + 1
	end

	return state.skipRequested or state.finished
end

local function playIntro()
	waitForCharacter()
	disableControls()

	state.effects = EffectsManager.new(Config)
	state.effects:start()

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
	dark.Parent = state.ui.gui
	local TweenService = game:GetService("TweenService")
	TweenService:Create(
		dark,
		TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	):Play()

	state.vfx = VFXManager.new(Config)
	state.vfx:start()

	state.audio = AudioManager.new(Config)
	state.audio:start()

	state.camera = CameraController.new()
	if not state.camera:start(Config) then
		cleanup()
		return
	end

	task.delay(1.5, function()
		if dark.Parent then
			dark:Destroy()
		end
	end)

	state.startedAt = os.clock()
	local skipped = runTimeline()

	if skipped then
		if state.ui then
			pcall(function()
				state.ui:fadeOut(0.5)
			end)
		end
		task.wait(0.5)
		cleanup()
		return
	end

	-- Graceful ending.
	if state.ui then
		pcall(function()
			state.ui:fadeOut(Config.Fade.FadeOutTime)
		end)
	end
	local elapsed = 0
	while elapsed < Config.Fade.FadeOutTime + 0.2 do
		if state.finished then
			return
		end
		task.wait(0.05)
		elapsed = elapsed + 0.05
	end
	cleanup()
end

local leaveConn = player.AncestryChanged:Connect(function()
	if not player:IsDescendantOf(game) then
		cleanup()
	end
end)

-- Watchdog: never leave the camera or controls locked.
task.delay(Config.IntroDuration + 10, function()
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

return nil
