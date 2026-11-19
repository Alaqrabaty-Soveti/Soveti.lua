--[[
	GraphicsEnhancer.lua
	Manages graphics enhancement presets for the CinematicIntro system.
	Provides visual quality presets using Roblox PostEffects and Lighting.
	Supports mobile optimization and high-quality modes.
]]

local GraphicsEnhancer = {}

local lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

--[[
	Store original graphics properties at initialization.
	Called automatically when module is loaded, but can be called explicitly.
]]
local originalGraphicsProps = {}

-- PostEffects storage for cleanup
local activeEffects = {}

-- Graphics presets definitions
-- Each preset modifies Lighting and/or PostEffects properties.
local GraphicsPresets = {
	["Ultra Quality"] = {
		-- Bloom settings
		["BloomIntensity"] = 0.8,
		["BloomSize"] = 85,
		["BloomThreshold"] = 0.5,

		-- Color Correction
		["ColorCorrectionEnabled"] = true,
		["ColorCorrectionHue"] = 0.02,
		["ColorCorrectionSat"] = 0.01,
		["ColorCorrectionBright"] = 0.01,

		-- Shadows
		["GlobalShadows"] = true,
		["ShadowDensity"] = 0.5,

		-- Atmosphere
		["AtmosphereDensity"] = 0.3,
		["AtmosphereColor"] = Color3.fromRGB(135, 206, 250), -- light blue

		-- Brightness
		["Brightness"] = 1.0,
	},

	["High Performance"] = {
		["BloomIntensity"] = 0.0,
		["BloomSize"] = 0,
		["BloomThreshold"] = 0.0,

		["ColorCorrectionEnabled"] = false,
		["ColorCorrectionHue"] = 0.0,
		["ColorCorrectionSat"] = 0.0,
		["ColorCorrectionBright"] = 0.0,

		["GlobalShadows"] = false,
		["ShadowDensity"] = 0.0,

		["AtmosphereDensity"] = 0.01,
		["AtmosphereColor"] = Color3.fromRGB(0, 0, 0),

		["Brightness"] = 0.5,
	},

	["Cinematic"] = {
		["BloomIntensity"] = 0.5,
		["BloomSize"] = 50,
		["BloomThreshold"] = 0.6,

		["ColorCorrectionEnabled"] = true,
		["ColorCorrectionHue"] = -0.01,
		["ColorCorrectionSat"] = -0.02,
		["ColorCorrectionBright"] = -0.01,

		["GlobalShadows"] = true,
		["ShadowDensity"] = 0.7,

		["AtmosphereDensity"] = 0.2,
		["AtmosphereColor"] = Color3.fromRGB(100, 80, 150), -- purple-ish

		["Brightness"] = 0.8,
	},

	["Mobile Safe"] = {
		["BloomIntensity"] = 0.0,
		["BloomSize"] = 0,
		["BloomThreshold"] = 0.0,

		["ColorCorrectionEnabled"] = false,
		["ColorCorrectionHue"] = 0.0,
		["ColorCorrectionSat"] = 0.0,
		["ColorCorrectionBright"] = 0.0,

		["GlobalShadows"] = false,
		["ShadowDensity"] = 0.0,

		["AtmosphereDensity"] = 0.0,
		["AtmosphereColor"] = Color3.fromRGB(0, 0, 0),

		["Brightness"] = 0.3,
	},
}

--[[
	Initialize GraphicsEnhancer: save original lighting properties.
	Call this once before applying presets.
]]
function GraphicsEnhancer.init()
	originalGraphicsProps.BloomIntensity = 0
	originalGraphicsProps.BloomSize = 0
	originalGraphicsProps.BloomThreshold = 0
	originalGraphicsProps.GlobalShadows = lighting.GlobalShadows
	originalGraphicsProps.Ambient = lighting.Ambient
	originalGraphicsProps.OutdoorAmbient = lighting.OutdoorAmbient
	originalGraphicsProps.Brightness = lighting.Brightness
	originalGraphicsProps.FogEnd = lighting.FogEnd
	originalGraphicsProps.FogColor = lighting.FogColor

	-- Clean up any existing effects from previous runs
	GraphicsEnhancer.cleanupEffects()
end

--[[
	Apply a graphics preset by name.
	Handles creation/updating of PostEffects (Bloom, ColorCorrection, etc.)

	@param presetName string - key in GraphicsPresets table
	@param useTween boolean - whether to animate changes (default false)
]]
function GraphicsEnhancer.applyPreset(presetName, useTween)
	useTween = useTween or false

	local preset = GraphicsPresets[presetName]
	if not preset then
		warn("[GraphicsEnhancer] Unknown preset: " .. tostring(presetName))
		return false
	end

	-- Save current state if this is the first application
	if next(originalGraphicsProps) == nil then
		-- Already saved in init, but ensure defaults
		if originalGraphicsProps.BloomIntensity == 0 then
			GraphicsEnhancer.init()
		end
	end

	-- Apply Bloom effect
	local bloomEffect = lighting:FindFirstChildWhichIsA("BloomEffect")
	local bloomConfig = preset

	if preset["BloomIntensity"] and preset["BloomIntensity"] > 0 then
		-- Ensure Bloom effect exists
		if not bloomEffect then
			bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Name = "CinematicIntro_Bloom"
			bloomEffect.Parent = lighting
		end
		activeEffects.Bloom = bloomEffect
		bloomEffect.Intensity = preset["BloomIntensity"]
		bloomEffect.Size = preset["BloomSize"] or 85
		bloomEffect.Threshold = preset["BloomThreshold"] or 0.5
	else
		-- Disable/remove bloom if intensity is 0
		if bloomEffect then
			if activeEffects.Bloom == bloomEffect then
				activeEffects.Bloom:Destroy()
				activeEffects.Bloom = nil
			else
				bloomEffect:Destroy()
			end
		end
	end

	-- Apply Color Correction
	local colorCorrectionEffect = lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")
	local ccConfig = preset

	if preset["ColorCorrectionEnabled"] then
		if not colorCorrectionEffect then
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Name = "CinematicIntro_ColorCorrection"
			colorCorrectionEffect.Parent = lighting
		end
		activeEffects.ColorCorrection = colorCorrectionEffect
		colorCorrectionEffect.Enabled = true
		if preset["ColorCorrectionHue"] then
			colorCorrectionEffect.Hue = preset["ColorCorrectionHue"]
		end
		if preset["ColorCorrectionSat"] then
			colorCorrectionEffect.Saturation = preset["ColorCorrectionSat"]
		end
		if preset["ColorCorrectionBright"] then
			colorCorrectionEffect.Brightness = preset["ColorCorrectionBright"]
		end
	else
		if colorCorrectionEffect then
			if activeEffects.ColorCorrection == colorCorrectionEffect then
				colorCorrectionEffect:Destroy()
				activeEffects.ColorCorrection = nil
			else
				colorCorrectionEffect.Enabled = false
			end
		end
	end

	-- Apply Shadow settings
	if preset["GlobalShadows"] ~= nil then
		lighting.GlobalShadows = preset["GlobalShadows"]
	end

	-- Apply Atmosphere settings
	local atmosphere = lighting:FindFirstChild("Atmosphere")
	local atmConfig = preset

	if preset["AtmosphereDensity"] and preset["AtmosphereDensity"] > 0 then
		if not atmosphere then
			atmosphere = Instance.new("Atmosphere")
			atmosphere.Name = "CinematicIntro_Atmosphere"
			atmosphere.Parent = lighting
		end
		activeEffects.Atmosphere = atmosphere
		atmosphere.Density = preset["AtmosphereDensity"]
		if preset["AtmosphereColor"] then
			atmosphere.Color = preset["AtmosphereColor"]
		end
	else
		if atmosphere then
			if activeEffects.Atmosphere == atmosphere then
				atmosphere:Destroy()
				activeEffects.Atmosphere = nil
			else
				atmosphere:Destroy()
			end
		end
	end

	-- Apply Brightness
	if preset["Brightness"] ~= nil then
		lighting.Brightness = preset["Brightness"]
	end

	-- Update original props tracking for restore
	originalGraphicsProps.BloomIntensity = preset["BloomIntensity"] or 0
	originalGraphicsProps.BloomSize = preset["BloomSize"] or 0
	originalGraphicsProps.BloomThreshold = preset["BloomThreshold"] or 0
	originalGraphicsProps.GlobalShadows = lighting.GlobalShadows
	originalGraphicsProps.Ambient = lighting.Ambient
	originalGraphicsProps.OutdoorAmbient = lighting.OutdoorAmbient
	originalGraphicsProps.Brightness = lighting.Brightness

	return true
end

--[[
	Restore the original graphics properties and clean up all PostEffects.
	Useful when disabling graphics enhancements.
]]
function GraphicsEnhancer.restoreOriginal()
	-- Restore lighting properties
	for prop, value in pairs(originalGraphicsProps) do
		lighting[prop] = value
	end

	-- Clean up all effects
	GraphicsEnhancer.cleanupEffects()

	-- Reset tracking
	originalGraphicsProps = {}
end

--[[
	Remove and destroy all managed PostEffects from lighting.
	Call this when switching presets or shutting down.
]]
function GraphicsEnhancer.cleanupEffects()
	for effectName, effect in pairs(activeEffects) do
		if effect and effect.Parent then
			effect:Destroy()
		end
	end
	table.clear(activeEffects)
end

--[[
	Get the list of available graphics preset names.
	@return table of preset name strings
]]
function GraphicsEnhancer.getPresetNames()
	local names = {}
	for name in pairs(GraphicsPresets) do
		table.insert(names, name)
	end
	return names
end

return GraphicsEnhancer