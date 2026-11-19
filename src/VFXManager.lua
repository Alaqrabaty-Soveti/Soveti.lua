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

return VFXManager
