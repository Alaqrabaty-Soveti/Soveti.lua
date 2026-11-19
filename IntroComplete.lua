--[[
	Premium Cinematic Intro for Roblox - Loadable via loadstring
	Executed automatically when loaded with: loadstring(game:HttpGet("https://raw.githubusercontent.com/Alaqrabaty-Soveti/Soveti.lua/main/IntroComplete.lua"))()
]]

-- Services
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Configuration
local Config = {
	Title = "ECHOES OF DAWN",
	Subtitle = "تبدأ الحكاية عند الفجر",
	Tagline = "CHAPTER I",
	IntroDuration = 22,
	ShowSkipButton = true,
	ShowProgressBar = true,
	SkipKeys = {Enum.KeyCode.Space, Enum.KeyCode.Return, Enum.KeyCode.Escape},

	-- Colors (Silver Premium)
	Background = Color3.fromRGB(6, 8, 15),
	Accent = Color3.fromRGB(150, 175, 255),
	Gold = Color3.fromRGB(245, 214, 152),
	TitleColor = Color3.fromRGB(240, 245, 255),
	SubtitleColor = Color3.fromRGB(168, 184, 214),

	-- Visual effects
	Fade = {
		FadeInTime = 1.4,
		FadeOutTime = 1.1,
		FlashAlpha = 0.7,
		FlashTime = 0.45,
		LetterboxAlpha = 0.18,
	},

	Effects = {
		BlurEnabled = true,
		BlurAmount = 10,
		ColorCorrectionEnabled = true,
		Brightness = 0.05,
		Contrast = 0.16,
	},

	-- Camera shots (simplified for loadstring)
	CameraShots = {
		{duration = 2, fov = 70, lookAt = Vector3.new(0, 3, 0)},
		{duration = 3, fov = 70, lookAt = Vector3.new(0, 5, -10), roll = 5},
		{duration = 4, fov = 70, lookAt = Vector3.new(0, 2, 0)},
		{duration = 3, fov = 70, lookAt = Vector3.new(0, 3, 0), shake = 1},
	},

	Audio = {
		Enabled = false,
		SyncPoints = {0, 5, 10, 15, 20},
	},
}

-- State
local state = {
	finished = false,
	gui = nil,
	startTime = 0,
}

-- Create main screen GUI
local function createGui()
	local screen = Instance.new("ScreenGui")
	screen.Name = "SilverPremiumIntro"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = game.CoreGui

	-- Dark background overlay
	local dark = Instance.new("Frame")
	dark.Name = "DarkOverlay"
	dark.Size = UDim2.new(1, 0, 1, 0)
	dark.Position = UDim2.new(0, 0, 0, 0)
	dark.BackgroundColor3 = Config.Background
	dark.BackgroundTransparency = 1
	dark.Parent = screen

	-- Fade in
	local fadeInTween = TweenService:Create(
		dark,
		TweenInfo.new(Config.Fade.FadeInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.18}
	)
	fadeInTween:Play()

	-- Title container
	local titleContainer = Instance.new("Frame")
	titleContainer.Name = "TitleContainer"
	titleContainer.Size = UDim2.new(1, -40, 0, 200)
	titleContainer.Position = UDim2.new(0, 20, 0, 100)
	titleContainer.BackgroundColor3 = Color3.clear
	titleContainer.Parent = screen

	-- UIListLayout for title elements
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 15)
	listLayout.Parent = titleContainer

	-- Title text
	local titleText = Instance.new("TextLabel")
	titleText.Name = "Title"
	titleText.Size = UDim2.new(1, 0, 0, 50)
	titleText.BackgroundColor3 = Color3.clear
	titleText.Text = Config.Title
	titleText.TextColor3 = Config.TitleColor
	titleText.TextSize = 36
	titleText.Font = Enum.Font.GothamBold
	titleText.TextXAlignment = Enum.TextAlignment.Center
	titleText.Parent = titleContainer

	-- Subtitle text
	local subtitleText = Instance.new("TextLabel")
	subtitleText.Name = "Subtitle"
	subtitleText.Size = UDim2.new(1, 0, 0, 40)
	subtitleText.BackgroundColor3 = Color3.clear
	subtitleText.Text = Config.Subtitle
	subtitleText.TextColor3 = Config.SubtitleColor
	subtitleText.TextSize = 24
	subtitleText.Font = Enum.Font.Gotham
	subtitleText.TextXAlignment = Enum.TextAlignment.Center
	subtitleText.Parent = titleContainer

	-- Tagline text
	local taglineText = Instance.new("TextLabel")
	taglineText.Name = "Tagline"
	taglineText.Size = UDim2.new(1, 0, 0, 30)
	taglineText.BackgroundColor3 = Color3.clear
	taglineText.Text = Config.Tagline
	taglineText.TextColor3 = Color3.new(0.6, 0.7, 0.8)
	taglineText.TextSize = 16
	taglineText.Font = Enum.Font.Gotham
	taglineText.TextXAlignment = Enum.TextAlignment.Center
	taglineText.Parent = titleContainer

	-- Skip button
	if Config.ShowSkipButton then
		local skipButton = Instance.new("TextButton")
		skipButton.Name = "SkipButton"
		skipButton.Size = UDim2.new(1, 0, 0, 30)
		skipButton.Position = UDim2.new(0, 0, 1, -50)
		skipButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		skipButton.BackgroundTransparency = 0.2
		skipButton.Text = Config.SkipButtonText
		skipButton.TextColor3 = Color3.new(1, 1, 1)
		skipButton.TextSize = 14
		skipButton.Font = Enum.Font.Gotham
		skipButton.Parent = screen

		-- Skip functionality
		local function skipIntro()
			state.finished = true
			pcall(function() fadeOutAndCleanup() end)
		end

		skipButton.MouseButton1Click:Connect(skipIntro)

		for _, key in ipairs(Config.SkipKeys) do
			UIS.InputBegan:Connect(function(input, processed)
				if not processed and input.KeyCode == key then
					skipIntro()
				end
			end)
		end
	end
end -- <-- Added missing end for createGui

-- Create vignette/letterbox
local function createLetterbox()
	local topLetterbox = Instance.new("Frame")
	topLetterbox.Name = "TopLetterbox"
	topLetterbox.Size = UDim2.new(1, 0, 0, 1)
	topLetterbox.Position = UDim2.new(0, 0, 0, 0)
	topLetterbox.BackgroundColor3 = Config.Accent
	topLetterbox.BackgroundTransparency = 1 - Config.Fade.LetterboxAlpha
	topLetterbox.Parent = screen

	local bottomLetterbox = Instance.new("Frame")
	bottomLetterbox.Name = "BottomLetterbox"
	bottomLetterbox.Size = UDim2.new(1, 0, 0, 1)
	bottomLetterbox.Position = UDim2.new(0, 0, 1, -1)
	bottomLetterbox.BackgroundColor3 = Config.Accent
	bottomLetterbox.BackgroundTransparency = 1 - Config.Fade.LetterboxAlpha
	bottomLetterbox.Parent = screen
end

-- Fade out and cleanup
local function fadeOutAndCleanup()
	state.finished = true

	local dark = screen:FindFirstChild("DarkOverlay")
	if dark then
		local fadeOutTween = TweenService:Create(
			dark,
			TweenInfo.new(Config.Fade.FadeOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		fadeOutTween:Play()
		fadeOutTween.Completed:Connect(function()
			screen:Destroy()
		end)
	end
end

-- Main intro playback function
local function playIntro()
	createGui()
	createLetterbox()

	state.startTime = tick()

	-- Wait for intro duration
	task.wait(Config.IntroDuration)

	-- Check if still running (not skipped)
	if not state.finished then
		fadeOutAndCleanup()
	end
end

-- Handle input for skipping
UIS.InputBegan:Connect(function(input, processed)
	if not processed then
		for _, key in ipairs(Config.SkipKeys) do
			if input.KeyCode == key then
				state.finished = true
				pcall(function() fadeOutAndCleanup() end)
				break
			end
		end
	end
end)

-- Start the intro
playIntro()

-- Watchdog timer
task.delay(Config.IntroDuration + 15, function()
	if not state.finished then
		state.finished = true
		pcall(function() fadeOutAndCleanup() end)
	end
end)

-- Return nothing (this is a script, not a module)
return nil