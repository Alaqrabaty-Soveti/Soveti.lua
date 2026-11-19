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

return UIManager
