--[[
	CameraController.lua — cinematic camera rig.
	Features: per-shot tweening, dutch roll, handheld sway, noise shake,
	dolly FOV punches, attachment framing, safe restore on stop.

	Place as: ReplicatedStorage.CinematicIntro.CameraController (ModuleScript)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CameraController = {}
CameraController.__index = CameraController

local function noise(t, seed)
	-- Cheap deterministic pseudo-noise in [-1, 1].
	return math.noise(t, seed, seed * 0.37) * 2
end

function CameraController.new()
	return setmetatable({}, CameraController)
end

function CameraController:start(config)
	local player = Players.LocalPlayer
	local camera = Workspace.CurrentCamera
	if not player or not camera then
		return false
	end

	self.player = player
	self.config = config
	self.camera = camera
	self.running = true
	self.shakeStrength = 0
	self.shakeEndsAt = 0
	self.tweens = {}
	self.clock = 0
	self.dolly = 0

	self.savedState = {
		camType = camera.CameraType,
		cframe = camera.CFrame,
		focus = camera.Focus,
		fov = camera.FieldOfView,
		roll = camera.CFrame:ToOrientation(),
	}

	self:_refreshRoot(true)

	self.base = Instance.new("CFrameValue")
	self.base.Name = "IntroCamBase"
	self.base.Value = camera.CFrame
	self.base.Parent = Workspace

	camera.CameraType = Enum.CameraType.Scriptable

	self.conn = RunService.RenderStepped:Connect(function(dt)
		if not self.running then
			return
		end
		self.clock = self.clock + dt
		self:_render(dt)
	end)

	task.spawn(function()
		self:_runShots()
	end)

	return true
end

function CameraController:_refreshRoot(waitForIt)
	local player = self.player
	if not player then
		return nil
	end
	local character = player.Character
	if not character and waitForIt then
		local ok, result = pcall(function()
			return player.CharacterAdded:Wait()
		end)
		if ok then
			character = result
		end
	end
	if character then
		self.character = character
		self.root = character:FindFirstChild("HumanoidRootPart")
			or character:WaitForChild("HumanoidRootPart", 4)
	else
		self.root = nil
	end
	return self.root
end

function CameraController:_render(dt)
	local camera = self.camera
	if not camera or not self.base then
		return
	end

	local base = self.base.Value
	local effects = self.config.Effects
	local shot = self.currentShot or {}
	local swayAmount = (shot.sway or 0.5) * (effects.HandheldSway or 0)
	local t = self.clock

	-- Handheld sway: slow drift that never fights the tween.
	if swayAmount > 0 then
		local sx = noise(t * 0.55, 11) * swayAmount
		local sy = noise(t * 0.47, 23) * swayAmount * 0.8
		local sr = noise(t * 0.33, 37) * swayAmount * 0.35
		base = base * CFrame.new(sx, sy, 0) * CFrame.Angles(0, 0, math.rad(sr))
	end

	-- Shake: high frequency, decays over ShakeTime.
	if self.shakeStrength > 0 then
		if t >= self.shakeEndsAt then
			self.shakeStrength = 0
		else
			local falloff = (self.shakeEndsAt - t) / math.max(effects.ShakeTime or 0.5, 0.01)
			local amp = (effects.ShakeAmplitude or 0.6) * self.shakeStrength * falloff
			local f = effects.ShakeFrequency or 26
			base = base
				* CFrame.new(noise(t * f, 3) * amp, noise(t * f, 7) * amp, noise(t * f, 13) * amp * 0.5)
				* CFrame.Angles(
					math.rad(noise(t * f * 0.8, 19) * amp * 0.5),
					math.rad(noise(t * f * 0.8, 29) * amp * 0.5),
					0
				)
		end
	end

	camera.CFrame = base
end

function CameraController:_runShots()
	local shots = self.config.CameraShots
	for _, shot in ipairs(shots) do
		if not self.running then
			break
		end

		if not self.root or not self.root.Parent then
			self:_refreshRoot(false)
		end

		self.currentShot = shot
		local targetCF, targetFov = self:_resolveShot(shot)
		local dur = shot.duration or 2
		local style = Enum.EasingStyle[shot.easingStyle] or Enum.EasingStyle.Sine
		local dir = Enum.EasingDirection[shot.easingDirection] or Enum.EasingDirection.InOut
		local info = TweenInfo.new(dur, style, dir)

		if self.base then
			local cfTween = TweenService:Create(self.base, info, { Value = targetCF })
			table.insert(self.tweens, cfTween)
			cfTween:Play()
		end

		if targetFov and self.camera then
			local fovTween = TweenService:Create(self.camera, info, { FieldOfView = targetFov })
			table.insert(self.tweens, fovTween)
			fovTween:Play()
		end

		if shot.shake and shot.shake > 0 then
			self:shake(shot.shake)
		end

		task.wait(dur)
	end
end

function CameraController:_resolveShot(shot)
	local targetCF

	if shot.attachment then
		local obj = Workspace:FindFirstChild(shot.attachment, true)
		if obj then
			if obj:IsA("Attachment") then
				targetCF = obj.WorldCFrame
			elseif obj:IsA("BasePart") then
				targetCF = obj.CFrame
			end
		end
	end

	if not targetCF then
		local origin = (self.root and self.root.Position) or Vector3.zero
		local offset = shot.offset or Vector3.new(0, 3, -10)
		local look = origin + (shot.lookOffset or Vector3.new(0, 1.5, 0))
		local eye = origin + offset
		targetCF = CFrame.lookAt(eye, look)
	end

	if shot.roll and shot.roll ~= 0 then
		targetCF = targetCF * CFrame.Angles(0, 0, math.rad(shot.roll))
	end

	return targetCF, shot.fov
end

function CameraController:shake(strength)
	local effects = self.config.Effects
	self.shakeStrength = math.max(self.shakeStrength, math.clamp(strength or 1, 0, 3))
	self.shakeEndsAt = self.clock + (effects.ShakeTime or 0.5)
end

function CameraController:setFov(fov, duration)
	if not self.camera then
		return
	end
	TweenService:Create(
		self.camera,
		TweenInfo.new(duration or 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ FieldOfView = fov }
	):Play()
end

function CameraController:stop()
	self.running = false

	if self.conn then
		self.conn:Disconnect()
		self.conn = nil
	end
	for _, tween in ipairs(self.tweens or {}) do
		pcall(function()
			tween:Cancel()
		end)
	end
	self.tweens = {}

	if self.base then
		self.base:Destroy()
		self.base = nil
	end

	if self.savedState and self.camera then
		local s = self.savedState
		pcall(function()
			self.camera.CameraType = s.camType
			self.camera.CFrame = s.cframe
			self.camera.Focus = s.focus
			self.camera.FieldOfView = s.fov
		end)
	end

	self.savedState = nil
	self.currentShot = nil
	self.root = nil
	self.character = nil
end

return CameraController
