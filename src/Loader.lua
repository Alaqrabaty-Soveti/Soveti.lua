--[[
	Silver Premium Cinematic Intro - Loader Script
	Project: Silver Premium Anime Graphics & Environment Script for Roblox
	Author: Omar
	Version: 1.0
]]

local Loader = {}
Loader.__index = Loader

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local ASSET_IDS = {
	["Background"] = "rbxassetid://9441876122", -- Silver gradient background
	["Logo"] = "rbxassetid://9441875432", -- Project logo
}

-- Premium color palette
local COLORS = {
	["Silver"] = Color3.fromRGB(195, 195, 195),
	["DarkSilver"] = Color3.fromRGB(120, 120, 120),
	["Black"] = Color3.fromRGB(15, 15, 15),
	["Gold"] = Color3.fromRGB(255, 215, 0),
	["White"] = Color3.fromRGB(255, 255, 255),
}

-- Module references (loaded lazily)
local modules = {
	["Config"] = nil,
	["Camera"] = nil,
	["VFX"] = nil,
	["UI"] = nil,
	["Audio"] = nil,
	["Effects"] = nil,
	["Sky"] = nil,
	["Graphics"] = nil,
}

-- Feature list for display
local FEATURES = {
	{id = "1", title = "🏠 intro cinematic", description = "مشروع انترو سينمائي فخم"},
	{id = "2", title = "🌌 sky system", description = "نظام cielo المخصص بـ 5 presets"},
	{id = "3", title = "✨ graphics enhancer", description = "نظام تعزيز الرسوم بـ 4 مستويات"},
	{id = "4", title = "🎨 anime interface", description = "واجهة أنمي فاخرة بأسلوب الفضة"},
	{id = "5", title = "📦 vfx particles", description = "جزيئات fumée، shocks, rays, speed lines"},
	{id = "6", title = "🔊 audio manager", description = "6 قوائم SFX للمؤثرات الصوتية"},
	{id = "7", title = "📐 camera control", description = "Dutch Roll, Sway, Shake, Dolly FOV"},
	{id = "8", title = "⚙️ settings", description = "خيارات التعديل والحفظ"},
}

-- Create the main screen GUI
function Loader:createScreen()
	local screen = Instance.new("ScreenGui")
	screen.Name = "SilverPremiumLoader"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Make it visible only in Roblox Studio/Playtest for now
	-- In production, this would load the actual intro
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 400, 0, 600)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
	mainFrame.BackgroundColor3 = COLORS["DarkSilver"]
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screen
	
	-- Corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame
	
-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	titleBar.BackgroundColor3 = COLORS["Silver"]
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = titleBar
	
	local titleText = Instance.new("TextLabel")
	titleText.Name = "TitleText"
	titleText.Size = UDim2.new(1, -20, 1, 0)
	titleText.Position = UDim2.new(0, 10, 0, 0)
	titleText.BackgroundColor3 = Color3.clear
	titleText.Text = "Silver Premium Intro"
	titleText.TextColor3 = COLORS["Black"]
	titleText.Font = Enum.Font.GothamBold
	titleText.TextSize = 20
	titleText.Parent = titleBar
	
-- Version info
	local versionText = Instance.new("TextLabel")
	versionText.Name = "Version"
	versionText.Size = UDim2.new(1, -20, 0, 20)
	versionText.Position = UDim2.new(0, 10, 0, 30)
	versionText.BackgroundColor3 = Color3.clear
	versionText.Text = "Version 1.0 | Luau | Roblox"
	versionText.TextColor3 = Color3.fromRGB(180, 180, 180)
	versionText.Font = Enum.Font.Gotham
	versionText.TextSize = 12
	versionText.Parent = titleBar
	
-- Features list container
	local featuresContainer = Instance.new("ScrollingFrame")
	featuresContainer.Name = "FeaturesContainer"
	featuresContainer.Size = UDim2.new(1, -20, 1, -80)
	featuresContainer.Position = UDim2.new(0, 10, 0, 70)
	featuresContainer.BackgroundColor3 = Color3.clear
	featuresContainer.ScrollBarThickness = 6
	featuresContainer.Parent = mainFrame
	
-- Create feature buttons
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = featuresContainer
	
	for _, feature in ipairs(FEATURES) do
		local button = Instance.new("TextButton")
		button.Name = "Feature_" .. feature.id
		button.Size = UDim2.new(1, 0, 0, 45)
		button.BackgroundColor3 = COLORS["Black"]
		button.BorderSizePixel = 0
		button.Text = ""
		button.Parent = featuresContainer
		
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = button
		
		-- Feature icon area
		local iconArea = Instance.new("Frame")
		iconArea.Name = "IconArea"
		iconArea.Size = UDim2.new(0, 35, 0, 35)
		iconArea.Position = UDim2.new(0, 10, 0, 5)
		iconArea.BackgroundColor3 = COLORS["Silver"]
		iconArea.Parent = button
		
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 6)
		iconCorner.Parent = iconArea
		
		local iconText = Instance.new("TextLabel")
		iconText.Name = "Icon"
		iconText.Size = UDim2.new(1, 0, 1, 0)
		iconText.BackgroundColor3 = Color3.clear
		iconText.Text = feature.id == "1" and "▶" or feature.id == "2" and "🌌" or feature.id == "3" and "✨" or feature.id == "4" and "🎨" or feature.id == "5" and "📦" or feature.id == "6" and "🔊" or feature.id == "7" and "📐" or "⚙️"
		iconText.TextColor3 = COLORS["Gold"]
		iconText.Font = Enum.Font.GothamBold
		iconText.TextSize = 18
		iconText.Parent = iconArea
		
		-- Feature text
		local featureText = Instance.new("TextLabel")
		featureText.Name = "FeatureText"
		featureText.Size = UDim2.new(1, -55, 0.6, 0)
		featureText.Position = UDim2.new(0, 55, 0, 5)
		featureText.BackgroundColor3 = Color3.clear
		featureText.Text = feature.title
		featureText.TextColor3 = COLORS["White"]
		featureText.Font = Enum.Font.Gotham
		featureText.TextSize = 14
		featureText.TextXAlignment = Enum.TextXAlignment.Left
		featureText.Parent = button
		
		local featureDesc = Instance.new("TextLabel")
		featureDesc.Name = "FeatureDesc"
		featureDesc.Size = UDim2.new(1, -55, 0.4, 0)
		featureDesc.Position = UDim2.new(0, 55, 0.5, 0)
		featureDesc.BackgroundColor3 = Color3.clear
		featureDesc.Text = feature.description
		featureDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
		featureDesc.Font = Enum.Font.Gotham
		featureDesc.TextSize = 11
		featureDesc.TextXAlignment = Enum.TextXAlignment.Left
		featureDesc.Parent = button
		
	-- Click handler
	button.MouseButton1Click:Connect(function()
		self:loadModule(feature.id)
	end)
	
-- Load button
	local loadButton = Instance.new("TextButton")
	loadButton.Name = "LoadButton"
	loadButton.Size = UDim2.new(1, -20, 0, 50)
	loadButton.Position = UDim2.new(0, 10, 1, -70)
	loadButton.BackgroundColor3 = COLORS["Gold"]
	loadButton.BorderSizePixel = 0
	loadButton.Font = Enum.Font.GothamBold
	loadButton.Text = "Launch Cinematic Intro"
	loadButton.TextColor3 = COLORS["Black"]
	loadButton.TextSize = 18
	loadButton.Parent = mainFrame
	
	local loadCorner = Instance.new("UICorner")
	loadCorner.CornerRadius = UDim.new(0, 25)
	loadCorner.Parent = loadButton
	
-- Load button handler
	loadButton.MouseButton1Click:Connect(function()
		self:startIntro()
	end)
	
-- Input handling
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape then
			screen:Destroy()
		end
	end)
	
	screen.Parent = game.CoreGui
	return screen
end

-- Load module by ID
function Loader:loadModule(id)
	local moduleMap = {
		["1"] = "IntroClient",
		["2"] = "SkyManager",
		["3"] = "GraphicsEnhancer",
		["4"] = "UIManager",
		["5"] = "VFXManager",
		["6"] = "AudioManager",
		["7"] = "CameraController",
		["8"] = "Config",
	}
	
	local moduleName = moduleMap[id]
	if moduleName then
		local success, err = pcall(function()
			local module = require(game.ReplicatedStorage:WaitForChild(moduleName))
			print("[Loader] Module loaded: " .. moduleName)
		end)
		if not success then
			warn("[Loader] Failed to load module: " .. tostring(err))
		end
	end
end

-- Start the actual intro
function Loader:startIntro()
	-- Hide loader, show actual intro
-- In a real implementation, this would transition to the cinematic intro
	print("[Loader] Starting cinematic intro...")
	
	-- Example: Load the main intro script
	local success, err = pcall(function()
		local intro = game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("IntroComplete")
		if intro then
			intro.Enabled = true
		end
	end)
	
	if not success then
		warn("[Loader] Intro not found, creating placeholder...")
		-- Create a placeholder intro
		self:createPlaceholderIntro()
	end
end

-- Create placeholder intro if main intro not found
function Loader:createPlaceholderIntro()
	local placeholder = Instance.new("ScreenGui")
	placeholder.Name = "PlaceholderIntro"
	placeholder.ResetOnSpawn = false
	
	local frame = Instance.new("Frame")
	placeholder.Size = UDim2.new(1, 0, 1, 0)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = COLORS["DarkSilver"]
	frame.Parent = placeholder
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundColor3 = Color3.clear
	text.Text = "Silver Premium Cinematic Intro\n\nLoading modules...\n\nFeatures:\n- Anime Cinematic Intro\n- Custom Sky System\n- Graphics Enhancement\n- VFX Particles\n- Audio Management\n- Camera Controls\n\nMade with ❤️ by Omar"
	text.TextColor3 = COLORS["White"]
	text.Font = Enum.Font.GothamBold
	text.TextSize = 18
	text.Parent = frame
	
	placeholder.Parent = game.CoreGui
end

-- Initialize
function Loader:init()
	local screen = self:createScreen()
	print("[Loader] Silver Premium Loader initialized")
	return screen
end

-- Return the Loader object
return Loader