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

return Config
