--[[
	Config.lua — single source of truth for the cinematic intro.
	Edit ONLY this file to retime scenes, recolor, retune effects and swap audio.

	Place as: ReplicatedStorage.CinematicIntro.Config (ModuleScript)

	RULES OF THE HOUSE
	- sum(CameraShots[].duration) MUST equal Config.IntroDuration.
	- Every Timeline entry must sit inside [0, IntroDuration].
	- Audio ids default to 0 (= disabled). Paste your own ids to enable sound.
]]

local Config = {}

-- ── Identity ────────────────────────────────────────────────────────────────
Config.Title = "ECHOES OF DAWN"
Config.Subtitle = "تبدأ الحكاية عند الفجر"
Config.Tagline = "CHAPTER I"
Config.IntroDuration = 22

-- ── Skip ────────────────────────────────────────────────────────────────────
Config.SkipKeys = { Enum.KeyCode.Space, Enum.KeyCode.Return, Enum.KeyCode.Escape }
Config.ShowSkipButton = true
Config.SkipButtonText = "تخطي ⏭"
Config.ShowProgressBar = true

-- ── Palette ─────────────────────────────────────────────────────────────────
Config.Colors = {
	Background = Color3.fromRGB(6, 8, 15),
	Accent = Color3.fromRGB(150, 175, 255),
	Gold = Color3.fromRGB(245, 214, 152),
	Title = Color3.fromRGB(240, 245, 255),
	Subtitle = Color3.fromRGB(168, 184, 214),
	VfxCore = Color3.fromRGB(190, 215, 255),
	VfxWarm = Color3.fromRGB(255, 214, 160),
}

-- ── Fades / flashes ─────────────────────────────────────────────────────────
Config.Fade = {
	FadeInTime = 1.4,
	FadeOutTime = 1.1,
	FlashAlpha = 0.7,
	FlashTime = 0.45,
	LetterboxAlpha = 0.18,
}

-- ── Post processing ─────────────────────────────────────────────────────────
Config.Effects = {
	BlurEnabled = true,
	BlurAmount = 10,
	ColorCorrectionEnabled = true,
	Brightness = 0.05,
	Contrast = 0.16,
	Saturation = 0.18,
	Tint = Color3.fromRGB(34, 44, 78),
	BloomEnabled = true,
	BloomIntensity = 0.7,
	BloomSize = 26,
	BloomThreshold = 0.95,
	DepthOfFieldEnabled = true,
	FocusDistance = 16,
	InFocusRadius = 22,
	FarIntensity = 0.32,
	SunRaysEnabled = true,
	SunRaysIntensity = 0.08,
	SunRaysSpread = 0.85,
	ShakeAmplitude = 0.7,
	ShakeTime = 0.5,
	ShakeFrequency = 26,
	HandheldSway = 0.12,
	RollAmount = 1.4,
}

-- ── Audio / SFX ─────────────────────────────────────────────────────────────
-- 0 = disabled. Drop your own rbxasset ids here; nothing breaks when empty.
Config.Audio = {
	AmbienceId = 0,
	MusicId = 0,
	Volume = 0.6,
	FadeIn = 1.2,
	FadeOut = 0.9,
	-- Named one-shot cues used by the Timeline ("sfx" actions).
	Cues = {
		Whoosh = { id = 0, volume = 0.55, pitch = 1.0 },
		Riser = { id = 0, volume = 0.5, pitch = 1.0 },
		Impact = { id = 0, volume = 0.85, pitch = 1.0 },
		Heartbeat = { id = 0, volume = 0.5, pitch = 1.0 },
		Shimmer = { id = 0, volume = 0.4, pitch = 1.15 },
		Title = { id = 0, volume = 0.8, pitch = 1.0 },
	},
	-- Seconds where the score is expected to land.
	SyncPoints = {
		Beat1 = 2.5,
		Beat2 = 6.5,
		Climax = 14.5,
		Title = 18.5,
	},
}

-- ── Camera shots ────────────────────────────────────────────────────────────
-- attachment: name of a BasePart/Attachment in Workspace (optional).
-- Otherwise the shot is framed around the character root using offset/lookOffset.
-- roll: degrees of dutch angle. dolly: extra FOV punch. shake: 0..1 intensity.
Config.CameraShots = {
	{
		name = "void",
		duration = 2.5,
		easingStyle = "Sine",
		easingDirection = "Out",
		offset = Vector3.new(0, 2.4, -7.5),
		lookOffset = Vector3.new(0, 1.6, 0),
		fov = 72,
		roll = 0,
		sway = 0.6,
	},
	{
		name = "establish",
		duration = 4.0,
		easingStyle = "Quad",
		easingDirection = "Out",
		attachment = "IntroCamEstablish",
		offset = Vector3.new(-9, 7, -16),
		lookOffset = Vector3.new(0, 2.0, 0),
		fov = 58,
		roll = -1.2,
		sway = 0.8,
	},
	{
		name = "approach",
		duration = 3.5,
		easingStyle = "Sine",
		easingDirection = "InOut",
		offset = Vector3.new(-3.2, 3.0, -9.0),
		lookOffset = Vector3.new(0, 1.5, 0),
		fov = 52,
		roll = 1.0,
		sway = 0.7,
	},
	{
		name = "hero",
		duration = 4.5,
		easingStyle = "Sine",
		easingDirection = "InOut",
		offset = Vector3.new(2.6, 1.1, -5.2),
		lookOffset = Vector3.new(0, 1.35, 0),
		fov = 46,
		roll = -2.0,
		sway = 0.5,
	},
	{
		name = "climax",
		duration = 4.0,
		easingStyle = "Quint",
		easingDirection = "In",
		offset = Vector3.new(0, 3.4, -11.5),
		lookOffset = Vector3.new(0, 1.8, 0),
		fov = 40,
		roll = 2.4,
		sway = 0.3,
		shake = 0.9,
	},
	{
		name = "title",
		duration = 3.5,
		easingStyle = "Sine",
		easingDirection = "Out",
		offset = Vector3.new(0, 2.2, -8.2),
		lookOffset = Vector3.new(0, 1.45, 0),
		fov = 56,
		roll = 0,
		sway = 0.9,
	},
}

-- ── Director timeline ───────────────────────────────────────────────────────
-- Executed in order by IntroClient. `t` is seconds from the first frame.
-- action: fadeIn | fadeOut | flash | glitch | tint | blur | punch | ring |
--         burst | speedLines | embers | beams | sfx | title | subtitle |
--         tagline | shake | vignette | letterbox
Config.Timeline = {
	{ t = 0.00, action = "fadeIn" },
	{ t = 0.20, action = "embers", args = { intensity = 0.35 } },
	{ t = 0.35, action = "letterbox", args = { true } },
	{ t = 0.60, action = "tint", args = { 0.16, 1.8 } },
	{ t = 1.20, action = "sfx", args = { "Ambience" } },

	{ t = 2.50, action = "whoosh" },
	{ t = 2.50, action = "blur", args = { 4 } },
	{ t = 2.60, action = "tagline" },

	{ t = 4.60, action = "beams", args = { 1.2 } },
	{ t = 6.50, action = "whoosh" },
	{ t = 6.50, action = "blur", args = { 0 } },
	{ t = 6.60, action = "ring", args = { 0.55 } },

	{ t = 9.20, action = "sfx", args = { "Heartbeat" } },
	{ t = 10.00, action = "speedLines", args = { 0.7 } },
	{ t = 11.40, action = "sfx", args = { "Riser" } },

	{ t = 14.50, action = "impact" },
	{ t = 14.50, action = "flash" },
	{ t = 14.50, action = "punch", args = { 0.22, 0.9 } },
	{ t = 14.50, action = "burst", args = { 1.0 } },
	{ t = 14.55, action = "glitch", args = { 0.32 } },
	{ t = 14.60, action = "shake", args = { 0.9 } },

	{ t = 16.20, action = "sfx", args = { "Shimmer" } },
	{ t = 18.50, action = "title" },
	{ t = 19.10, action = "sfx", args = { "Title" } },
	{ t = 19.60, action = "subtitle" },
	{ t = 20.60, action = "vignette", args = { 0.55 } },

	{ t = 21.10, action = "fadeOut" },
}

--return Config
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

--return CameraController
--[[
	VFXManager.lua — procedural visual effects, zero external assets.
	Everything is built from ParticleEmitters, Beams and Parts parented to a
	rig that follows the camera, so effects always read on screen.

	Place as: ReplicatedStorage.CinematicIntro.VFXManager (ModuleScript)
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

local VFXManager = {}
VFXManager.__index = VFXManager

function VFXManager.new(config)
	local self = setmetatable({}, VFXManager)
	self.config = config
	self.emitters = {}
	self.live = {}
	self.running = false
	return self
end

function VFXManager:_rig(camera)
	local rig = Instance.new("Part")
	rig.Name = "IntroVfxRig"
	rig.Size = Vector3.new(0.1, 0.1, 0.1)
	rig.Transparency = 1
	rig.Anchored = true
	rig.CanCollide = false
	rig.CanQuery = false
	rig.CanTouch = false
	rig.CastShadow = false
	rig.Massless = true
	rig.Parent = Workspace
	self.rig = rig

	self.conn = RunService.RenderStepped:Connect(function()
		if not self.running or not self.rig then
			return
		end
		local cam = camera or Workspace.CurrentCamera
		if cam then
			-- Sit 6 studs in front of the lens so particles fill the frame.
			self.rig.CFrame = cam.CFrame * CFrame.new(0, 0, -6)
		end
	end)
end

function VFXManager:_attachment(name, position)
	local att = Instance.new("Attachment")
	att.Name = name
	att.Position = position or Vector3.zero
	att.Parent = self.rig
	return att
end

function VFXManager:_emitter(att, props)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = props.texture or SPARKLE
	emitter.Color = props.color or ColorSequence.new(self.config.Colors.VfxCore)
	emitter.LightEmission = props.lightEmission or 0.85
	emitter.LightInfluence = 0
	emitter.Size = props.size or NumberSequence.new(0.6, 0)
	emitter.Transparency = props.transparency
		or NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.15, 0.1),
			NumberSequenceKeypoint.new(1, 1),
		})
	emitter.Lifetime = props.lifetime or NumberRange.new(0.6, 1.4)
	emitter.Rate = 0
	emitter.Speed = props.speed or NumberRange.new(4, 10)
	emitter.SpreadAngle = props.spread or Vector2.new(180, 180)
	emitter.Rotation = props.rotation or NumberRange.new(0, 360)
	emitter.RotSpeed = props.rotSpeed or NumberRange.new(-90, 90)
	emitter.Acceleration = props.acceleration or Vector3.zero
	emitter.Drag = props.drag or 2
	emitter.ZOffset = props.zOffset or 2
	emitter.Parent = att
	self.emitters[att.Name] = emitter
	return emitter
end

function VFXManager:start(camera)
	self.running = true
	self:_rig(camera)

	local core = self:_attachment("Core", Vector3.zero)
	local ring = self:_attachment("Ring", Vector3.zero)
	local ember = self:_attachment("Ember", Vector3.new(0, -2.2, 0))

	-- Ambient dust: always alive, very subtle.
	self:_emitter(ember, {
		texture = SPARKLE,
		color = ColorSequence.new(self.config.Colors.VfxCore, self.config.Colors.Accent),
		size = NumberSequence.new(0.28, 0),
		lifetime = NumberRange.new(2.5, 4.5),
		speed = NumberRange.new(0.6, 1.8),
		spread = Vector2.new(50, 50),
		acceleration = Vector3.new(0, 0.6, 0),
		drag = 0.4,
		lightEmission = 0.6,
	})
	self.emitters.Ember.Rate = 14

	-- Burst emitter: fired on impacts.
	self:_emitter(core, {
		texture = SPARKLE,
		color = ColorSequence.new(self.config.Colors.VfxCore, self.config.Colors.VfxWarm),
		size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 1.6),
			NumberSequenceKeypoint.new(1, 0),
		}),
		lifetime = NumberRange.new(0.5, 1.1),
		speed = NumberRange.new(26, 52),
		spread = Vector2.new(180, 180),
		drag = 3.5,
		lightEmission = 1,
	})

	-- Ring emitter: radial shockwave particles.
	self:_emitter(ring, {
		texture = SPARKLE,
		color = ColorSequence.new(self.config.Colors.VfxCore),
		size = NumberSequence.new(0.5, 0),
		lifetime = NumberRange.new(0.7, 1.0),
		speed = NumberRange.new(30, 34),
		spread = Vector2.new(0, 180),
		drag = 4,
		lightEmission = 1,
	})
	self.emitters.Ring.SpreadAngle = Vector2.new(0, 180)
	self.emitters.Ring.Rotation = NumberRange.new(0, 360)
end

-- ── Effects ─────────────────────────────────────────────────────────────────

function VFXManager:burst(intensity)
	local emitter = self.emitters.Core
	if not emitter then
		return
	end
	emitter.Rate = 0
	emitter:Emit(math.floor(160 * (intensity or 1)))
end

function VFXManager:ring(intensity)
	local emitter = self.emitters.Ring
	if not emitter then
		return
	end
	emitter:Emit(math.floor(90 * (intensity or 1)))
	self:_shockwave(intensity or 1)
end

function VFXManager:_shockwave(intensity)
	if not self.rig then
		return
	end
	local wave = Instance.new("Part")
	wave.Name = "IntroShockwave"
	wave.Shape = Enum.PartType.Ball
	wave.Size = Vector3.new(1, 1, 1)
	wave.Anchored = true
	wave.CanCollide = false
	wave.CanQuery = false
	wave.CanTouch = false
	wave.CastShadow = false
	wave.Material = Enum.Material.Neon
	wave.Color = self.config.Colors.VfxCore
	wave.Transparency = 0.25
	wave.CFrame = self.rig.CFrame
	wave.Parent = Workspace

	local target = 1 + 26 * (intensity or 1)
	local tween = TweenService:Create(
		wave,
		TweenInfo.new(0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Size = Vector3.new(target, target, target), Transparency = 1 }
	)
	tween:Play()
	tween.Completed:Once(function()
		wave:Destroy()
	end)
end

function VFXManager:beams(intensity)
	if not self.rig then
		return
	end
	local count = 6
	for i = 1, count do
		local beamPart = Instance.new("Part")
		beamPart.Name = "IntroBeam"
		beamPart.Anchored = true
		beamPart.CanCollide = false
		beamPart.CanQuery = false
		beamPart.CanTouch = false
		beamPart.CastShadow = false
		beamPart.Material = Enum.Material.Neon
		beamPart.Color = (i % 2 == 0) and self.config.Colors.VfxWarm or self.config.Colors.VfxCore
		beamPart.Size = Vector3.new(0.12, 0.12, 40)
		beamPart.Transparency = 1
		beamPart.CFrame = self.rig.CFrame
			* CFrame.Angles(0, 0, math.rad((i / count) * 360))
			* CFrame.new(0, 0, -18)
		beamPart.Parent = Workspace

		local fadeIn = TweenService:Create(
			beamPart,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Transparency = 0.35 }
		)
		fadeIn:Play()
		task.delay(0.5 + i * 0.04, function()
			if beamPart.Parent then
				local fadeOut = TweenService:Create(
					beamPart,
					TweenInfo.new(0.9 * (intensity or 1), Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{ Transparency = 1 }
				)
				fadeOut:Play()
				fadeOut.Completed:Once(function()
					beamPart:Destroy()
				end)
			end
		end)
	end
end

function VFXManager:speedLines(intensity)
	if not self.rig then
		return
	end
	local amount = math.floor(26 * (intensity or 1))
	for i = 1, amount do
		local line = Instance.new("Part")
		line.Name = "IntroSpeedLine"
		line.Anchored = true
		line.CanCollide = false
		line.CanQuery = false
		line.CanTouch = false
		line.CastShadow = false
		line.Material = Enum.Material.Neon
		line.Color = Color3.new(1, 1, 1)
		line.Size = Vector3.new(0.06, 0.06, 8 + math.random() * 16)
		line.Transparency = 0.15

		local angle = math.random() * math.pi * 2
		local radius = 3 + math.random() * 9
		local startCF = self.rig.CFrame
			* CFrame.Angles(0, 0, angle)
			* CFrame.new(0, radius, -6)
			* CFrame.Angles(math.rad(90), 0, 0)
		line.CFrame = startCF
		line.Parent = Workspace

		local tween = TweenService:Create(
			line,
			TweenInfo.new(0.45 + math.random() * 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ CFrame = startCF * CFrame.new(0, 0, -26), Transparency = 1 }
		)
		tween:Play()
		tween.Completed:Once(function()
			line:Destroy()
		end)
	end
end

function VFXManager:embers(intensity)
	local emitter = self.emitters.Ember
	if not emitter then
		return
	end
	emitter.Rate = math.max(6, math.floor(40 * (intensity or 1)))
end

function VFXManager:setDust(rate)
	local emitter = self.emitters.Ember
	if emitter then
		emitter.Rate = math.max(0, rate)
	end
end

function VFXManager:stop()
	self.running = false
	if self.conn then
		self.conn:Disconnect()
		self.conn = nil
	end
	if self.rig then
		self.rig:Destroy()
		self.rig = nil
	end
	self.emitters = {}
end

--return VFXManager
--[[
	UIManager.lua — cinematic overlay: letterbox, vignette, title reveal,
	tagline, progress bar, glitch and flash transitions. Built 100% in code.

	Place as: ReplicatedStorage.CinematicIntro.UIManager (ModuleScript)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UIManager = {}
UIManager.__index = UIManager

local function tween(self, instance, info, goal)
	local t = TweenService:Create(instance, info, goal)
	t:Play()
	table.insert(self.tweens, t)
	return t
end

local function ease(style, dir, time)
	return TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
end

function UIManager.new(config, onSkip)
	local self = setmetatable({}, UIManager)
	self.config = config
	self.onSkip = onSkip
	self.tweens = {}
	self.connections = {}
	self.destroyed = false
	self:_build()
	return self
end

function UIManager:_build()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local colors = self.config.Colors

	local gui = Instance.new("ScreenGui")
	gui.Name = "CinematicIntroGui"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui
	self.gui = gui

	-- Backdrop (fade layer)
	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = colors.Background
	backdrop.BackgroundTransparency = 0
	backdrop.BorderSizePixel = 0
	backdrop.ZIndex = 1
	backdrop.Parent = gui
	self.backdrop = backdrop

	-- Colour tint
	local tint = Instance.new("Frame")
	tint.Name = "Tint"
	tint.Size = UDim2.fromScale(1, 1)
	tint.BackgroundColor3 = colors.Accent
	tint.BackgroundTransparency = 1
	tint.BorderSizePixel = 0
	tint.ZIndex = 2
	tint.Parent = gui
	self.tint = tint

	-- Vignette (radial darkening via gradient)
	local vignette = Instance.new("Frame")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.fromScale(1, 1)
	vignette.BackgroundColor3 = Color3.new(0, 0, 0)
	vignette.BackgroundTransparency = 1
	vignette.BorderSizePixel = 0
	vignette.ZIndex = 3
	vignette.Parent = gui
	local vigGradient = Instance.new("UIGradient")
	vigGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.55, 0.85),
		NumberSequenceKeypoint.new(1, 0),
	})
	vigGradient.Parent = vignette
	self.vignette = vignette

	-- Letterbox bars
	local function makeBar(name, anchorPos)
		local bar = Instance.new("Frame")
		bar.Name = name
		bar.Size = UDim2.fromScale(1, 0.11)
		bar.Position = anchorPos
		bar.BackgroundColor3 = Color3.new(0, 0, 0)
		bar.BackgroundTransparency = 1
		bar.BorderSizePixel = 0
		bar.ZIndex = 4
		bar.Parent = gui
		return bar
	end
	self.topBar = makeBar("TopBar", UDim2.fromScale(0, 0))
	self.bottomBar = makeBar("BottomBar", UDim2.fromScale(0, 0.89))

	-- Title block
	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TitleFrame"
	titleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	titleFrame.Position = UDim2.fromScale(0.5, 0.5)
	titleFrame.Size = UDim2.fromScale(0.9, 0.42)
	titleFrame.BackgroundTransparency = 1
	titleFrame.ZIndex = 5
	titleFrame.Parent = gui
	self.titleFrame = titleFrame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = titleFrame

	-- Tagline (small caps above title)
	local tagline = Instance.new("TextLabel")
	tagline.Name = "Tagline"
	tagline.BackgroundTransparency = 1
	tagline.Size = UDim2.new(1, 0, 0.1, 0)
	tagline.Font = Enum.Font.GothamMedium
	tagline.Text = self.config.Tagline
	tagline.TextColor3 = colors.Gold
	tagline.TextSize = 13
	tagline.TextTransparency = 1
	tagline.ZIndex = 5
	tagline.Parent = titleFrame
	self.tagline = tagline

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0.5, 0)
	title.Font = Enum.Font.GothamBlack
	title.Text = self.config.Title
	title.TextColor3 = colors.Title
	title.TextScaled = true
	title.TextTransparency = 1
	title.TextWrapped = true
	title.ZIndex = 5
	title.Parent = titleFrame
	self.title = title

	local titleSize = Instance.new("UITextSizeConstraint")
	titleSize.MaxTextSize = 78
	titleSize.MinTextSize = 18
	titleSize.Parent = title

	local titleStroke = Instance.new("UIStroke")
	titleStroke.Color = colors.Accent
	titleStroke.Thickness = 1.5
	titleStroke.Transparency = 1
	titleStroke.Parent = title
	self.titleStroke = titleStroke

	-- Accent rule
	local accentLine = Instance.new("Frame")
	accentLine.Name = "AccentLine"
	accentLine.Size = UDim2.new(0, 0, 0, 2)
	accentLine.BackgroundColor3 = colors.Gold
	accentLine.BackgroundTransparency = 1
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 5
	accentLine.Parent = titleFrame
	self.accentLine = accentLine

	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, 0, 0.18, 0)
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.Text = self.config.Subtitle
	subtitle.TextColor3 = colors.Subtitle
	subtitle.TextScaled = true
	subtitle.TextTransparency = 1
	subtitle.TextWrapped = true
	subtitle.ZIndex = 5
	subtitle.Parent = titleFrame
	self.subtitle = subtitle

	local subtitleSize = Instance.new("UITextSizeConstraint")
	subtitleSize.MaxTextSize = 26
	subtitleSize.MinTextSize = 11
	subtitleSize.Parent = subtitle

	-- Progress bar (bottom, thin)
	local progressTrack = Instance.new("Frame")
	progressTrack.Name = "ProgressTrack"
	progressTrack.AnchorPoint = Vector2.new(0.5, 1)
	progressTrack.Position = UDim2.new(0.5, 0, 1, -18)
	progressTrack.Size = UDim2.new(0.32, 0, 0, 2)
	progressTrack.BackgroundColor3 = colors.Accent
	progressTrack.BackgroundTransparency = 1
	progressTrack.BorderSizePixel = 0
	progressTrack.ZIndex = 6
	progressTrack.Visible = self.config.ShowProgressBar
	progressTrack.Parent = gui
	self.progressTrack = progressTrack

	local progressFill = Instance.new("Frame")
	progressFill.Name = "Fill"
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = colors.Gold
	progressFill.BackgroundTransparency = 0.15
	progressFill.BorderSizePixel = 0
	progressFill.ZIndex = 6
	progressFill.Parent = progressTrack
	self.progressFill = progressFill

	-- Skip button
	local skip = Instance.new("TextButton")
	skip.Name = "SkipButton"
	skip.AnchorPoint = Vector2.new(1, 1)
	skip.Position = UDim2.new(1, -22, 1, -22)
	skip.Size = UDim2.fromOffset(128, 42)
	skip.BackgroundColor3 = Color3.fromRGB(10, 14, 26)
	skip.BackgroundTransparency = 0.35
	skip.BorderSizePixel = 0
	skip.Font = Enum.Font.GothamMedium
	skip.Text = self.config.SkipButtonText
	skip.TextColor3 = colors.Title
	skip.TextSize = 17
	skip.TextTransparency = 1
	skip.BackgroundTransparency = 1
	skip.AutoButtonColor = true
	skip.Visible = self.config.ShowSkipButton
	skip.ZIndex = 7
	skip.Parent = gui
	self.skipButton = skip

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = skip

	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.Accent
	stroke.Transparency = 1
	stroke.Thickness = 1
	stroke.Parent = skip
	self.skipStroke = stroke

	table.insert(self.connections, skip.MouseButton1Click:Connect(function()
		if self.onSkip then
			self.onSkip("button")
		end
	end))

	-- Flash overlay
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 10
	flash.Parent = gui
	self.flash = flash

	-- Glitch overlay (scanlines)
	local glitch = Instance.new("Frame")
	glitch.Name = "Glitch"
	glitch.Size = UDim2.fromScale(1, 1)
	glitch.BackgroundColor3 = colors.Accent
	glitch.BackgroundTransparency = 1
	glitch.BorderSizePixel = 0
	glitch.ZIndex = 9
	glitch.Parent = gui
	self.glitchFrame = glitch

	table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, processed)
		if processed or self.destroyed then
			return
		end
		for _, key in ipairs(self.config.SkipKeys) do
			if input.KeyCode == key then
				if self.onSkip then
					self.onSkip("key")
				end
				return
			end
		end
	end))
end

-- ── Transitions ─────────────────────────────────────────────────────────────

function UIManager:fadeIn(duration)
	duration = duration or self.config.Fade.FadeInTime
	self.backdrop.BackgroundTransparency = 0
	tween(self, self.backdrop, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration), {
		BackgroundTransparency = 1,
	})
	tween(self, self.topBar, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration), {
		BackgroundTransparency = 0.1,
	})
	tween(self, self.bottomBar, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration), {
		BackgroundTransparency = 0.1,
	})
	tween(self, self.skipButton, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration), {
		BackgroundTransparency = 0.35,
		TextTransparency = 0,
	})
	tween(self, self.skipStroke, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration), {
		Transparency = 0.6,
	})
	tween(self, self.progressTrack, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration), {
		BackgroundTransparency = 0.6,
	})
end

function UIManager:fadeOut(duration)
	duration = duration or self.config.Fade.FadeOutTime
	tween(self, self.backdrop, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.In, duration), {
		BackgroundTransparency = 0,
	})
	for _, bar in ipairs({ self.topBar, self.bottomBar }) do
		tween(self, bar, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.In, duration), {
			BackgroundTransparency = 1,
		})
	end
	tween(self, self.titleFrame, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.In, duration), {
		Position = UDim2.fromScale(0.5, 0.44),
	})
	tween(self, self.skipButton, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.In, duration), {
		BackgroundTransparency = 1,
		TextTransparency = 1,
	})
	tween(self, self.progressTrack, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.In, duration), {
		BackgroundTransparency = 1,
	})
end

function UIManager:flash()
	if self.destroyed then
		return
	end
	local peak = 1 - math.clamp(self.config.Fade.FlashAlpha, 0, 0.95)
	self.flash.BackgroundTransparency = peak
	tween(self, self.flash, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, self.config.Fade.FlashTime), {
		BackgroundTransparency = 1,
	})
end

function UIManager:pulseTint(alpha, duration)
	if self.destroyed then
		return
	end
	self.tint.BackgroundTransparency = 1 - math.clamp(alpha or 0.25, 0, 0.9)
	tween(self, self.tint, ease(Enum.EasingStyle.Sine, Enum.EasingDirection.Out, duration or 1.2), {
		BackgroundTransparency = 1,
	})
end

function UIManager:letterbox(on)
	local goal = on and 0.1 or 1
	tween(self, self.topBar, ease(Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 1.1), {
		BackgroundTransparency = goal,
	})
	tween(self, self.bottomBar, ease(Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 1.1), {
		BackgroundTransparency = goal,
	})
end

function UIManager:vignette(alpha)
	if self.destroyed then
		return
	end
	self.vignette.BackgroundTransparency = 1 - math.clamp(alpha or 0.5, 0, 0.95)
end

function UIManager:glitch(duration)
	if self.destroyed then
		return
	end
	duration = duration or 0.3
	local frame = self.glitchFrame
	local deadline = os.clock() + duration
	task.spawn(function()
		while os.clock() < deadline and not self.destroyed do
			frame.BackgroundTransparency = 0.75 + math.random() * 0.2
			frame.Position = UDim2.fromOffset(math.random(-14, 14), math.random(-8, 8))
			task.wait(0.035)
		end
		if not self.destroyed then
			frame.BackgroundTransparency = 1
			frame.Position = UDim2.fromOffset(0, 0)
		end
	end)
end

function UIManager:showTagline()
	local label = self.tagline
	tween(self, label, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.9), { TextTransparency = 0.15 })
	task.delay(2.2, function()
		if not self.destroyed and label.Parent then
			tween(self, label, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0.8), { TextTransparency = 1 })
		end
	end)
end

function UIManager:showTitle()
	if self.destroyed then
		return
	end
	local title = self.title
	title.TextTransparency = 1
	title.Size = UDim2.new(1, 0, 0.5, 0)
	tween(self, title, ease(Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 1.0), { TextTransparency = 0 })
	tween(self, self.titleStroke, ease(Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 1.2), {
		Transparency = 0.45,
	})
	tween(self, self.accentLine, ease(Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 1.1), {
		Size = UDim2.new(0.42, 0, 0, 2),
		BackgroundTransparency = 0.1,
	})
end

function UIManager:showSubtitle()
	if self.destroyed then
		return
	end
	tween(self, self.subtitle, ease(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.9), { TextTransparency = 0.1 })
end

function UIManager:setProgress(ratio)
	if self.destroyed or not self.progressFill then
		return
	end
	self.progressFill.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
end

function UIManager:destroy()
	if self.destroyed then
		return
	end
	self.destroyed = true
	for _, conn in ipairs(self.connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	self.connections = {}
	for _, t in ipairs(self.tweens) do
		pcall(function()
			t:Cancel()
		end)
	end
	self.tweens = {}
	if self.gui then
		self.gui:Destroy()
		self.gui = nil
	end
end

--return UIManager
--[[
	AudioManager.lua — music, ambience and named one-shot SFX cues.
	All ids come from Config.Audio; 0 or nil disables a track silently.

	Place as: ReplicatedStorage.CinematicIntro.AudioManager (ModuleScript)
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local AudioManager = {}
AudioManager.__index = AudioManager

function AudioManager.new(config)
	local self = setmetatable({}, AudioManager)
	self.config = config
	self.sounds = {}
	self.cues = {}
	return self
end

function AudioManager:_make(name, assetId, looped, volume, pitch)
	if not assetId or assetId == 0 then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. tostring(assetId)
	sound.Looped = looped
	sound.Volume = volume or 0.5
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	table.insert(self.sounds, sound)
	return sound
end

function AudioManager:start()
	local audio = self.config.Audio

	self.ambience = self:_make("IntroAmbience", audio.AmbienceId, true, audio.Volume * 0.55)
	self.music = self:_make("IntroMusic", audio.MusicId, false, audio.Volume)

	for _, sound in ipairs({ self.ambience, self.music }) do
		if sound then
			sound.Volume = 0
			sound:Play()
			TweenService:Create(
				sound,
				TweenInfo.new(audio.FadeIn or 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ Volume = (sound == self.music) and audio.Volume or audio.Volume * 0.55 }
			):Play()
		end
	end
end

-- Play a named cue from Config.Audio.Cues. Unknown names are ignored.
function AudioManager:playCue(name, volumeScale)
	local audio = self.config.Audio
	if name == "Ambience" then
		return self.ambience
	elseif name == "Music" then
		return self.music
	end

	local def = audio.Cues and audio.Cues[name]
	if not def or not def.id or def.id == 0 then
		return nil
	end

	local sound = self:_make("IntroCue_" .. name, def.id, false, (def.volume or 0.5) * (volumeScale or 1), def.pitch)
	if sound then
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
	end
	return sound
end

function AudioManager:stopAll(fadeTime)
	fadeTime = fadeTime or 0.8
	local sounds = self.sounds
	self.sounds = {}
	for _, sound in ipairs(sounds) do
		task.spawn(function()
			if not sound.Parent then
				return
			end
			local startVolume = sound.Volume
			local started = os.clock()
			while sound.Parent and (os.clock() - started) < fadeTime do
				local ratio = 1 - ((os.clock() - started) / fadeTime)
				sound.Volume = math.max(startVolume * ratio, 0)
				task.wait(0.05)
			end
			sound:Stop()
			sound:Destroy()
		end)
	end
end

--return AudioManager
--[[
	EffectsManager.lua — post-processing grade (blur, colour, bloom, DOF, rays).
	Creates its instances inside Lighting and always removes exactly what it made,
	restoring any pre-existing values it touched.

	Place as: ReplicatedStorage.CinematicIntro.EffectsManager (ModuleScript)
]]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local EffectsManager = {}
EffectsManager.__index = EffectsManager

function EffectsManager.new(config)
	local self = setmetatable({}, EffectsManager)
	self.config = config
	self.created = {}
	self.tweens = {}
	return self
end

function EffectsManager:_add(instance)
	instance.Parent = Lighting
	table.insert(self.created, instance)
	return instance
end

function EffectsManager:_tween(instance, time, goal, style)
	local t = TweenService:Create(
		instance,
		TweenInfo.new(time or 1.2, style or Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		goal
	)
	t:Play()
	table.insert(self.tweens, t)
	return t
end

function EffectsManager:start()
	local s = self.config.Effects

	if s.ColorCorrectionEnabled then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "IntroColorCorrection"
		cc.Brightness = 0
		cc.Contrast = 0
		cc.Saturation = 0
		cc.TintColor = s.Tint
		self.colorCorrection = self:_add(cc)
		self:_tween(cc, 1.6, {
			Brightness = s.Brightness,
			Contrast = s.Contrast,
			Saturation = s.Saturation,
		})
	end

	if s.BlurEnabled then
		local blur = Instance.new("BlurEffect")
		blur.Name = "IntroBlur"
		blur.Size = 18
		self.blur = self:_add(blur)
		self:_tween(blur, 1.2, { Size = s.BlurAmount }, Enum.EasingStyle.Quad)
	end

	if s.BloomEnabled then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "IntroBloom"
		bloom.Intensity = 0
		bloom.Size = s.BloomSize
		bloom.Threshold = s.BloomThreshold
		self.bloom = self:_add(bloom)
		self:_tween(bloom, 1.8, { Intensity = s.BloomIntensity })
	end

	if s.DepthOfFieldEnabled then
		local dof = Instance.new("DepthOfFieldEffect")
		dof.Name = "IntroDepthOfField"
		dof.FocusDistance = s.FocusDistance
		dof.InFocusRadius = s.InFocusRadius
		dof.FarIntensity = 0
		dof.NearIntensity = 0
		self.depthOfField = self:_add(dof)
		self:_tween(dof, 1.8, { FarIntensity = s.FarIntensity })
	end

	if s.SunRaysEnabled then
		local rays = Instance.new("SunRaysEffect")
		rays.Name = "IntroSunRays"
		rays.Intensity = 0
		rays.Spread = s.SunRaysSpread
		self.sunRays = self:_add(rays)
		self:_tween(rays, 2.0, { Intensity = s.SunRaysIntensity })
	end
end

function EffectsManager:setBlur(size, duration)
	if not self.blur then
		return
	end
	self:_tween(self.blur, duration or 0.6, { Size = math.clamp(size, 0, 56) })
end

function EffectsManager:setDof(far, duration)
	if not self.depthOfField then
		return
	end
	self:_tween(self.depthOfField, duration or 0.8, { FarIntensity = math.clamp(far, 0, 1) })
end

function EffectsManager:punch(strength, duration)
	if not self.colorCorrection then
		return
	end
	local cc = self.colorCorrection
	local base = self.config.Effects
	local half = (duration or 0.5) * 0.35
	self:_tween(cc, half, {
		Brightness = base.Brightness + (strength or 0.2),
		Contrast = base.Contrast + 0.12,
		Saturation = base.Saturation + 0.15,
	}, Enum.EasingStyle.Quad)
	task.delay(half, function()
		if cc.Parent then
			self:_tween(cc, (duration or 0.5) - half, {
				Brightness = base.Brightness,
				Contrast = base.Contrast,
				Saturation = base.Saturation,
			})
		end
	end)
end

function EffectsManager:stop(fadeTime)
	fadeTime = fadeTime or 0.8
	local created = self.created
	self.created = {}

	for _, t in ipairs(self.tweens) do
		pcall(function()
			t:Cancel()
		end)
	end
	self.tweens = {}

	for _, effect in ipairs(created) do
		if effect.Parent then
			local goal = {}
			if effect:IsA("BlurEffect") then
				goal.Size = 0
			elseif effect:IsA("ColorCorrectionEffect") then
				goal.Brightness = 0
				goal.Contrast = 0
				goal.Saturation = 0
			elseif effect:IsA("BloomEffect") then
				goal.Intensity = 0
			elseif effect:IsA("DepthOfFieldEffect") then
				goal.FarIntensity = 0
				goal.NearIntensity = 0
			elseif effect:IsA("SunRaysEffect") then
				goal.Intensity = 0
			end
			local tween = TweenService:Create(
				effect,
				TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				goal
			)
			tween:Play()
			tween.Completed:Once(function()
				effect:Destroy()
			end)
			task.delay(fadeTime + 0.5, function()
				if effect.Parent then
					effect:Destroy()
				end
			end)
		end
	end

	self.blur = nil
	self.colorCorrection = nil
	self.bloom = nil
	self.depthOfField = nil
	self.sunRays = nil
end

--return EffectsManager
--[[
	IntroClient.lua — the director (LocalScript in StarterPlayerScripts).
	Owns the whole sequence: camera rig, UI, VFX, post FX, audio, timeline,
	skip handling, progress bar, watchdog and guaranteed cleanup.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
