--[[
	UIManager.lua — responsive cinematic UI and transitions.
	All elements are built in code (no binary assets required).
	Import this file into a ModuleScript named "UIManager".
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UIManager = {}
UIManager.__index = UIManager

local function playTween(self, instance, info, goal)
	local tween = TweenService:Create(instance, info, goal)
	tween:Play()
	table.insert(self.tweens, tween)
	return tween
end

function UIManager.new(config, onSkip)
	local self = setmetatable({}, UIManager)
	self.config = config
	self.onSkip = onSkip
	self.tweens = {}
	self.connections = {}
	self.destroyed = false
	self.typing = false
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

	-- Fade / backdrop layer
	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = colors.Background
	backdrop.BackgroundTransparency = 0
	backdrop.BorderSizePixel = 0
	backdrop.ZIndex = 1
	backdrop.Parent = gui
	self.backdrop = backdrop

	-- Color tint layer
	local tint = Instance.new("Frame")
	tint.Name = "Tint"
	tint.Size = UDim2.fromScale(1, 1)
	tint.BackgroundColor3 = colors.Accent
	tint.BackgroundTransparency = 1
	tint.BorderSizePixel = 0
	tint.ZIndex = 2
	tint.Parent = gui
	self.tint = tint

	-- Cinematic letterbox bars
	local function makeBar(name, position)
		local bar = Instance.new("Frame")
		bar.Name = name
		bar.Size = UDim2.fromScale(1, 0.09)
		bar.Position = position
		bar.BackgroundColor3 = Color3.new(0, 0, 0)
		bar.BackgroundTransparency = 1
		bar.BorderSizePixel = 0
		bar.ZIndex = 3
		bar.Parent = gui
		return bar
	end
	self.topBar = makeBar("TopBar", UDim2.fromScale(0, 0))
	self.bottomBar = makeBar("BottomBar", UDim2.fromScale(0, 0.91))

	-- Title container
	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "TitleFrame"
	titleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	titleFrame.Position = UDim2.fromScale(0.5, 0.5)
	titleFrame.Size = UDim2.fromScale(0.92, 0.36)
	titleFrame.BackgroundTransparency = 1
	titleFrame.ZIndex = 4
	titleFrame.Parent = gui
	self.titleFrame = titleFrame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = titleFrame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0.55, 0)
	title.Font = Enum.Font.GothamBlack
	title.Text = self.config.Title
	title.TextColor3 = colors.Title
	title.TextScaled = true
	title.TextTransparency = 1
	title.TextWrapped = true
	title.ZIndex = 4
	title.Parent = titleFrame
	self.title = title

	local titleSize = Instance.new("UITextSizeConstraint")
	titleSize.MaxTextSize = 72
	titleSize.MinTextSize = 16
	titleSize.Parent = title

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, 0, 0.2, 0)
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.Text = self.config.Subtitle
	subtitle.TextColor3 = colors.Subtitle
	subtitle.TextScaled = true
	subtitle.TextTransparency = 1
	subtitle.TextWrapped = true
	subtitle.ZIndex = 4
	subtitle.Parent = titleFrame
	self.subtitle = subtitle

	local subtitleSize = Instance.new("UITextSizeConstraint")
	subtitleSize.MaxTextSize = 26
	subtitleSize.MinTextSize = 10
	subtitleSize.Parent = subtitle

	-- Accent line under the title
	local accentLine = Instance.new("Frame")
	accentLine.Name = "AccentLine"
	accentLine.Size = UDim2.fromScale(0, 0.01)
	accentLine.BackgroundColor3 = colors.Gold
	accentLine.BackgroundTransparency = 1
	accentLine.BorderSizePixel = 0
	accentLine.ZIndex = 4
	accentLine.Parent = titleFrame
	self.accentLine = accentLine

	-- Skip button (bottom-right, touch friendly)
	local skip = Instance.new("TextButton")
	skip.Name = "SkipButton"
	skip.AnchorPoint = Vector2.new(1, 1)
	skip.Position = UDim2.new(1, -24, 1, -24)
	skip.Size = UDim2.fromOffset(132, 44)
	skip.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
	skip.BackgroundTransparency = 0.3
	skip.BorderSizePixel = 0
	skip.Font = Enum.Font.GothamMedium
	skip.Text = self.config.SkipButtonText
	skip.TextColor3 = colors.Title
	skip.TextSize = 18
	skip.TextTransparency = 0
	skip.AutoButtonColor = true
	skip.Visible = self.config.ShowSkipButton
	skip.ZIndex = 6
	skip.Parent = gui
	self.skipButton = skip

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = skip

	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.Accent
	stroke.Transparency = 0.55
	stroke.Thickness = 1
	stroke.Parent = skip

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

	-- Keyboard skip support (mouse/touch handled by the button)
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

function UIManager:fadeIn(duration)
	duration = duration or self.config.Fade.FadeInTime
	local easing = Enum.EasingStyle.Quad
	self.backdrop.BackgroundTransparency = 0
	playTween(self, self.backdrop, TweenInfo.new(duration, easing, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	})
	playTween(self, self.topBar, TweenInfo.new(duration, easing, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.15,
	})
	playTween(self, self.bottomBar, TweenInfo.new(duration, easing, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.15,
	})
end

function UIManager:fadeOut(duration)
	duration = duration or self.config.Fade.FadeOutTime
	local easing = Enum.EasingStyle.Quad
	playTween(self, self.backdrop, TweenInfo.new(duration, easing, Enum.EasingDirection.In), {
		BackgroundTransparency = 0,
	})
	playTween(self, self.topBar, TweenInfo.new(duration, easing, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	})
	playTween(self, self.bottomBar, TweenInfo.new(duration, easing, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	})
	playTween(self, self.titleFrame, TweenInfo.new(duration, easing, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0.5, 0.46),
	})
end

function UIManager:flash()
	if self.destroyed then
		return
	end
	local peak = 1 - math.clamp(self.config.Fade.FlashAlpha, 0, 0.95)
	self.flash.BackgroundTransparency = peak
	playTween(self, self.flash, TweenInfo.new(self.config.Fade.FlashTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	})
end

function UIManager:pulseTint(alpha, duration)
	if self.destroyed then
		return
	end
	self.tint.BackgroundTransparency = 1 - math.clamp(alpha or 0.25, 0, 0.9)
	playTween(self, self.tint, TweenInfo.new(duration or 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	})
end

function UIManager:glitch(duration)
	duration = duration or 0.35
	local deadline = os.clock() + duration
	while os.clock() < deadline and not self.destroyed do
		local dx = math.random(-8, 8)
		local dy = math.random(-3, 3)
		self.titleFrame.Position = UDim2.new(0.5, dx, 0.5, dy)
		self.title.TextColor3 = (math.random() > 0.5) and self.config.Colors.Accent or self.config.Colors.Gold
		task.wait(0.03)
	end
	if not self.destroyed then
		self.titleFrame.Position = UDim2.fromScale(0.5, 0.5)
		self.title.TextColor3 = self.config.Colors.Title
	end
end

function UIManager:showTitle()
	if self.destroyed then
		return
	end
	local easing = Enum.EasingStyle.Quint
	self.titleFrame.Position = UDim2.new(0.5, 0, 0.5, 26)
	playTween(self, self.titleFrame, TweenInfo.new(0.9, easing, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
	})
	playTween(self, self.title, TweenInfo.new(0.9, easing, Enum.EasingDirection.Out), {
		TextTransparency = 0,
	})
	playTween(self, self.accentLine, TweenInfo.new(1.1, easing, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.1,
		Size = UDim2.fromScale(0.42, 0.01),
	})
end

function UIManager:showSubtitle()
	if self.destroyed then
		return
	end
	self.typing = true
	local text = self.config.Subtitle
	local total = utf8.len(text) or #text
	self.subtitle.Text = ""
	self.subtitle.TextTransparency = 0
	for i = 1, total do
		if self.destroyed or not self.typing then
			break
		end
		local nextOffset = utf8.offset(text, i + 1)
		self.subtitle.Text = string.sub(text, 1, (nextOffset or (#text + 1)) - 1)
		task.wait(0.035)
	end
	if not self.destroyed then
		self.subtitle.Text = text
	end
	self.typing = false
end

function UIManager:setSkipVisible(visible)
	if self.skipButton and not self.destroyed then
		self.skipButton.Visible = visible
	end
end

function UIManager:destroy()
	if self.destroyed then
		return
	end
	self.destroyed = true
	self.typing = false
	for _, tween in ipairs(self.tweens) do
		pcall(function()
			tween:Cancel()
		end)
	end
	self.tweens = {}
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.connections = {}
	if self.gui then
		self.gui:Destroy()
		self.gui = nil
	end
end

return UIManager
