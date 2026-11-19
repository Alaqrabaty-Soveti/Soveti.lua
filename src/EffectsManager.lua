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

return EffectsManager
