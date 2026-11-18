--[[
	EffectsManager.lua — post-processing effects (blur, color grading, bloom, depth).
	Creates effects inside Lighting and removes them on cleanup.
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
	return self
end

function EffectsManager:_add(instance)
	instance.Parent = Lighting
	table.insert(self.created, instance)
	return instance
end

function EffectsManager:start()
	local settings = self.config.Effects

	if settings.ColorCorrectionEnabled then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "IntroColorCorrection"
		cc.Brightness = 0
		cc.Contrast = 0
		cc.Saturation = 0
		cc.TintColor = settings.Tint
		self.colorCorrection = self:_add(cc)
		TweenService:Create(cc, TweenInfo.new(1.4, Enum.EasingStyle.Sine), {
			Brightness = settings.Brightness,
			Contrast = settings.Contrast,
			Saturation = settings.Saturation,
		}):Play()
	end

	if settings.BlurEnabled then
		local blur = Instance.new("BlurEffect")
		blur.Name = "IntroBlur"
		blur.Size = 0
		self.blur = self:_add(blur)
		TweenService:Create(blur, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {
			Size = settings.BlurAmount,
		}):Play()
	end

	if settings.BloomEnabled then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "IntroBloom"
		bloom.Intensity = 0
		bloom.Size = settings.BloomSize
		bloom.Threshold = settings.BloomThreshold
		self.bloom = self:_add(bloom)
		TweenService:Create(bloom, TweenInfo.new(1.6, Enum.EasingStyle.Sine), {
			Intensity = settings.BloomIntensity,
		}):Play()
	end

	if settings.DepthOfFieldEnabled then
		local dof = Instance.new("DepthOfFieldEffect")
		dof.Name = "IntroDepthOfField"
		dof.FocusDistance = settings.FocusDistance
		dof.InFocusRadius = settings.InFocusRadius
		dof.FarIntensity = 0
		dof.NearIntensity = 0
		self.depthOfField = self:_add(dof)
		TweenService:Create(dof, TweenInfo.new(1.6, Enum.EasingStyle.Sine), {
			FarIntensity = settings.FarIntensity,
		}):Play()
	end
end

function EffectsManager:setBlur(size, duration)
	if not self.blur then
		return
	end
	TweenService:Create(self.blur, TweenInfo.new(duration or 0.6, Enum.EasingStyle.Sine), {
		Size = math.clamp(size, 0, 56),
	}):Play()
end

function EffectsManager:punch(strength, duration)
	if not self.colorCorrection then
		return
	end
	local cc = self.colorCorrection
	local base = self.config.Effects
	local half = (duration or 0.5) * 0.35
	TweenService:Create(cc, TweenInfo.new(half, Enum.EasingStyle.Quad), {
		Brightness = base.Brightness + (strength or 0.2),
		Contrast = base.Contrast + 0.1,
	}):Play()
	task.delay(half, function()
		if cc.Parent then
			TweenService:Create(cc, TweenInfo.new((duration or 0.5) - half, Enum.EasingStyle.Sine), {
				Brightness = base.Brightness,
				Contrast = base.Contrast,
			}):Play()
		end
	end)
end

function EffectsManager:stop(fadeTime)
	fadeTime = fadeTime or 0.8
	local created = self.created
	self.created = {}
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
			end
			local tween = TweenService:Create(effect, TweenInfo.new(fadeTime, Enum.EasingStyle.Sine), goal)
			tween:Play()
			tween.Completed:Once(function()
				effect:Destroy()
			end)
		end
	end
	self.blur = nil
	self.colorCorrection = nil
	self.bloom = nil
	self.depthOfField = nil
end

return EffectsManager
