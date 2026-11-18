--[[
	Config.lua — central settings for the cinematic anime intro.
	Edit values here to customize timing, text, colors, camera shots,
	audio IDs, and effect intensity WITHOUT touching the engine code.
	Place as: ReplicatedStorage.CinematicIntro.Config (ModuleScript)
]]

local Config = {}

-- Basic identity
Config.Title = "ECHOES OF DAWN"
Config.Subtitle = "تبدأ الحكاية عند الفجر"
Config.IntroDuration = 22 -- total intended length (seconds)

-- Skip behavior
Config.SkipKeys = { Enum.KeyCode.Space, Enum.KeyCode.Return }
Config.ShowSkipButton = true
Config.SkipButtonText = "تخطي ⏭"

-- Colors
Config.Colors = {
	Background = Color3.fromRGB(8, 10, 18), -- near-black blue
	Accent = Color3.fromRGB(160, 180, 255), -- soft sky blue
	Gold = Color3.fromRGB(240, 210, 150), -- warm highlight
	Title = Color3.fromRGB(235, 240, 255),
	Subtitle = Color3.fromRGB(170, 185, 215),
}

-- Fade / transition settings
Config.Fade = {
	FadeInTime = 1.2,
	FadeOutTime = 1.0,
	FlashAlpha = 0.55, -- peak opacity of the flash overlay
	FlashTime = 0.35,
}

-- Post-processing effects
Config.Effects = {
	BlurEnabled = true,
	BlurAmount = 8, -- 0..24 (BlurEffect.Size)
	ColorCorrectionEnabled = true,
	Brightness = 0.06,
	Contrast = 0.12,
	Saturation = 0.15,
	Tint = Color3.fromRGB(30, 40, 70),
	BloomEnabled = true,
	BloomIntensity = 0.55,
	BloomSize = 24,
	BloomThreshold = 1.05,
	DepthOfFieldEnabled = true,
	FocusDistance = 14,
	InFocusRadius = 20,
	FarIntensity = 0.3,
	ShakeAmplitude = 0.6, -- studs
	ShakeTime = 0.4, -- seconds the shake lasts
}

-- Audio (fill these with your own asset IDs; 0 disables a track)
Config.Audio = {
	AmbienceId = 0, -- e.g. 123456789
	MusicId = 0,
	Volume = 0.6,
	SyncPoints = { -- seconds where beats/events land
		Beat1 = 3.0,
		Beat2 = 7.0,
		Climax = 12.0,
		Title = 17.0,
	},
}

-- Camera shots: each entry is one cinematic segment.
-- If `attachment` names a BasePart/Attachment in Workspace it is used,
-- otherwise the camera is framed around the player character.
-- Durations are aligned with Audio.SyncPoints and sum to IntroDuration.
Config.CameraShots = {
	{
		name = "opening",
		duration = 3.0,
		easingStyle = "Sine",
		easingDirection = "Out",
		attachment = nil,
		offset = Vector3.new(0, 3, -8),
		lookOffset = Vector3.new(0, 1.5, 0),
		fov = 65,
	},
	{
		name = "establish",
		duration = 4.0,
		easingStyle = "Quad",
		easingDirection = "InOut",
		attachment = "IntroCamEstablish", -- optional part/attachment in Studio
		fov = 55,
	},
	{
		name = "hero",
		duration = 5.0,
		easingStyle = "Sine",
		easingDirection = "InOut",
		attachment = nil,
		offset = Vector3.new(2.5, 2.5, -5),
		lookOffset = Vector3.new(0, 1.2, 0),
		fov = 50,
		shake = true, -- trigger shake on this shot
	},
	{
		name = "climax",
		duration = 4.0,
		easingStyle = "Quad",
		easingDirection = "In",
		attachment = nil,
		offset = Vector3.new(0, 4, -12),
		lookOffset = Vector3.new(0, 2, 0),
		fov = 45,
	},
	{
		name = "title",
		duration = 3.5,
		easingStyle = "Sine",
		easingDirection = "Out",
		attachment = nil,
		offset = Vector3.new(0, 3, -10),
		lookOffset = Vector3.new(0, 1.5, 0),
		fov = 60,
	},
	{
		name = "hold",
		duration = 2.5,
		easingStyle = "Sine",
		easingDirection = "Out",
		attachment = nil,
		offset = Vector3.new(0, 2.6, -8.5),
		lookOffset = Vector3.new(0, 1.4, 0),
		fov = 58,
	},
}

return Config
