--[[
	SkyManager.lua
	Manages custom sky presets for the CinematicIntro system.
	Provides preset sky environments with smooth transitions.
	Compatible with Roblox Lighting and TweenService.
]]

local SkyManager = {}

local lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

--[[
	Store original lighting properties upon initialization
	so we can restore them later.
]]
local originalLightingProps = {}

-- Sky presets definitions
-- Each preset is a table of Lighting properties to modify.
-- Supported properties: TopSky, BottomSky, StarCount, 
-- MoonTextureId, SunTextureId, Azimuth, Altitude, 
-- OutdoorAmbient, FogEnd, FogStart, Brightness
local SkyPresets = {
	["Shimmering Stars"] = {
		TopSky = "rbxassetid://1314888932", -- night sky top
		BottomSky = "rbxassetid://1314888891", -- night sky bottom
		StarCount = 1500,
		OutdoorAmbient = Color3.fromRGB(10, 10, 30),
		Brightness = 0.5,
		GlobalShadows = false,
	},
	["Sunset Glow"] = {
		TopSky = "rbxassetid://1314456216", -- sunset top
		BottomSky = "rbxassetid://1314456185", -- sunset bottom
		StarCount = 0,
		OutdoorAmbient = Color3.fromRGB(255, 100, 50),
		Brightness = 1.0,
		GlobalShadows = true,
		ShadowDensity = 0.5,
	},
	["Midday Bright"] = {
		TopSky = "rbxassetid://1314446120", -- bright blue top
		BottomSky = "rbxassetid://1314446095", -- bright blue bottom
		StarCount = 0,
		OutdoorAmbient = Color3.fromRGB(170, 170, 170),
		Brightness = 2.0,
		GlobalShadows = true,
		ShadowDensity = 0.3,
	},
	["Neon Night"] = {
		TopSky = "rbxassetid://1314467706", -- neon dark top
		BottomSky = "rbxassetid://1314467680", -- neon dark bottom
		StarCount = 500,
		OutdoorAmbient = Color3.fromRGB(0, 0, 20),
		Brightness = 0.2,
		GlobalShadows = false,
	},
	["Custom Color"] = {
		-- User can set custom TopSky/BottomSky IDs
		-- This preset just applies default Roblox sky
		TopSky = "rbxassetid://61604747", -- default Roblox sky top
		BottomSky = "rbxassetid://61604746", -- default Roblox sky bottom
		StarCount = 0,
		OutdoorAmbient = Color3.fromRGB(128, 128, 128),
		Brightness = 1.0,
		GlobalShadows = true,
	},
}

--[[
	Initialize the SkyManager: save original lighting properties.
	Must be called once before applying presets.
]]
function SkyManager.init()
	originalLightingProps.TopSky = lighting.TopSky
	originalLightingProps.BottomSky = lighting.BottomSky
	originalLightingProps.StarCount = lighting.StarCount
	originalLightingProps.OutdoorAmbient = lighting.OutdoorAmbient
	originalLightingProps.Brightness = lighting.Brightness
	originalLightingProps.GlobalShadows = lighting.GlobalShadows
	-- Note: ShadowDensity is not a direct Lighting property; 
	-- it's handled via the Sky object if present.
end

--[[
	Apply a sky preset by name.
	Optionally use TweenService for smooth transition.

	@param presetName string - key in SkyPresets table
	@param useTween boolean - whether to animate the changes
	@param tweenTime number - time in seconds for the tween (default 1.0)
]]
function SkyManager.applyPreset(presetName, useTween, tweenTime)
	useTween = useTween or false
	tweenTime = tweenTime or 1.0

	local preset = SkyPresets[presetName]
	if not preset then
		warn("[SkyManager] Unknown preset: " .. tostring(presetName))
		return false
	end

	-- If using tween, we need to tween individual properties
	-- Since Lighting properties don't all support tweening directly,
	-- we'll apply them instantly but can tween the most visible ones.
	if useTween then
		local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local goals = {}

		-- Only tween properties that make sense to animate
		if preset.TopSky and lighting.TopSky ~= preset.TopSky then
			goals.TopSky = preset.TopSky
		end
		if preset.BottomSky and lighting.BottomSky ~= preset.BottomSky then
			goals.BottomSky = preset.BottomSky
		end
		if preset.OutdoorAmbient then
			goals.OutdoorAmbient = preset.OutdoorAmbient
		end
		if preset.Brightness ~= nil then
			goals.Brightness = preset.Brightness
		end

		if next(goals) > 0 then
			TweenService:Create(lighting, tweenInfo, goals):Play()
		end
	end

	-- Apply non-tweened properties instantly
	if preset.TopSky then
		lighting.TopSky = preset.TopSky
	end
	if preset.BottomSky then
		lighting.BottomSky = preset.BottomSky
	end
	if preset.StarCount ~= nil then
		lighting.StarCount = preset.StarCount
	end
	if preset.OutdoorAmbient then
		lighting.OutdoorAmbient = preset.OutdoorAmbient
	end
	if preset.Brightness ~= nil then
		lighting.Brightness = preset.Brightness
	end
	if preset.GlobalShadows ~= nil then
		lighting.GlobalShadows = preset.GlobalShadows
	end

	-- Update internal tracking
	originalLightingProps.TopSky = lighting.TopSky
	originalLightingProps.BottomSky = lighting.BottomSky
	originalLightingProps.StarCount = lighting.StarCount
	originalLightingProps.OutdoorAmbient = lighting.OutdoorAmbient
	originalLightingProps.Brightness = lighting.Brightness
	originalLightingProps.GlobalShadows = lighting.GlobalShadows

	return true
end

--[[
	Restore the original lighting properties that were saved at init.
	Useful when disabling custom sky features.
]]
function SkyManager.restoreOriginal()
	for prop, value in pairs(originalLightingProps) do
		lighting[prop] = value
	end
	-- Reset tracking
	originalLightingProps.TopSky = lighting.TopSky
	originalLightingProps.BottomSky = lighting.BottomSky
	originalLightingProps.StarCount = lighting.StarCount
	originalLightingProps.OutdoorAmbient = lighting.OutdoorAmbient
	originalLightingProps.Brightness = lighting.Brightness
	originalLightingProps.GlobalShadows = lighting.GlobalShadows
end

--[[
	Get the list of available sky preset names.
	@return table of preset name strings
]]
function SkyManager.getPresetNames()
	local names = {}
	for name in pairs(SkyPresets) do
		table.insert(names, name)
	end
	return names
end

return SkyManager