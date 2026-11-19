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
	self.currentTab = "home"
	self:_build()
	return self
end

local function createTabButton(gui, name, position, isActive)
	local button = Instance.new("TextButton")
	button.Name = name .. "Button"
	button.Size = UDim2.fromScale(0, 0.1)
	button.Position = position
	button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
	button.BackgroundTransparency = isActive and 0 or 0.5
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.BorderSizePixel = 0
	button.ZIndex = 5
	button.Parent = gui
	return button
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

	-- ==========================================
	-- TOP BAR + TAB BAR
	-- ==========================================
	self.topBar = Instance.new("Frame")
	self.topBar.Name = "TopBar"
	self.topBar.Size = UDim2.fromScale(1, 0.08)
	self.topBar.Position = UDim2.fromScale(0, 0)
	self.topBar.BackgroundColor3 = colors.Background
	self.topBar.BackgroundTransparency = 0.2
	self.topBar.BorderSizePixel = 0
	self.topBar.ZIndex = 1
	self.topBar.Parent = gui

	-- Tab buttons container
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.fromScale(1, 1)
	tabBar.Position = UDim2.fromScale(0, 0)
	tabBar.BackgroundTransparency = 1
	tabBar.BorderSizePixel = 0
	tabBar.ZIndex = 2
	tabBar.Parent = self.topBar

	-- Define tabs
	self.tabs = {
		["home"] = { title = "الرئيسية", icon = "🏠" },
		["sky"] = { title = "السماء", icon = "🌌" },
		["graphics"] = { title = "تعزيز الرسوم", icon = "✨" },
		["settings"] = { title = "الإعدادات", icon = "⚙️" },
	}

	-- Create tab buttons
	self.tabButtons = {}
	local buttonWidth = 1 / #self.tabs
	local tabNames = {"home", "sky", "graphics", "settings"}
	for i, tabName in ipairs(tabNames) do
		local btn = createTabButton(tabBar, tabName, UDim2.fromScale((i - 1) * buttonWidth, 0), false)
		btn.Size = UDim2.fromScale(buttonWidth, 1)
		btn.Text = self.tabs[tabName].icon .. " " .. self.tabs[tabName].title
		btn.Parent = tabBar
		self.tabButtons[tabName] = btn

		-- Click handler
		local finalTab = tabName
		table.insert(self.connections, btn.MouseButton1Click:Connect(function()
			self:switchTab(finalTab)
		end))
	end

	-- Activate first tab
	self:switchTab("home")

	-- ==========================================
	-- MAIN CONTENT AREA (below tab bar)
	-- ==========================================
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.fromScale(1, 0.92)
	contentArea.Position = UDim2.fromScale(0, 0.08)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ZIndex = 1
	contentArea.Parent = gui
	self.contentArea = contentArea

	-- Home tab content
	self:_buildHomeTab(contentArea)
	-- Sky tab content
	self:_buildSkyTab(contentArea)
	-- Graphics tab content
	self:_buildGraphicsTab(contentArea)
	-- Settings tab content
	self:_buildSettingsTab(contentArea)

	-- Initially show home tab
	self:switchTab("home")
end

function UIManager:_buildHomeTab(parent)
	local frame = Instance.new("Frame")
	frame.Name = "HomeTab"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = true
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0.3, 0)
	label.Position = UDim2.fromScale(0, 0.2)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = "أهلاً بك في CinematicIntro"
	label.TextColor3 = colors.Accent
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = frame
end

function UIManager:_buildSkyTab(parent)
	local frame = Instance.new("Frame")
	frame.Name = "SkyTab"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = parent

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.fromScale(0, 0.1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "🌌 نظام السماء"
	title.TextColor3 = colors.Accent
	title.TextScaled = true
	title.Parent = frame

	-- Preset selector instructions
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -20, 0, 80)
	info.Position = UDim2.fromScale(0, 0.2)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.GothamMedium
	info.Text = "حدد مسبقاً لسماء:\n1. شimmering Stars - سماء ليلية متوهجة\n2. Sunset Glow - غروب دائم\n3. Midday Bright - ضوء نهاري\n4. Neon Night - ليلية نيون\n5. Custom Color - لون مخصص"
	info.TextColor3 = Color3.new(1, 1, 1)
	info.TextScaled = true
	info.TextWrapped = true
	info.Parent = frame

	-- Apply button
	local applyBtn = Instance.new("TextButton")
	applyBtn.Name = "ApplySkyBtn"
	applyBtn.Size = UDim2.new(0.4, 0, 0, 30)
	applyBtn.Position = UDim2.fromScale(0.3, 0.6)
	applyBtn.BackgroundColor3 = colors.Accent
	applyBtn.BackgroundTransparency = 0
	applyBtn.TextColor3 = Color3.new(1, 1, 1)
	applyBtn.Font = Enum.Font.GothamBold
	applyBtn.TextSize = 12
	applyBtn.BorderSizePixel = 0
	applyBtn.Text = "تطبيق"
	applyBtn.Parent = frame
	table.insert(self.connections, applyBtn.MouseButton1Click:Connect(function()
		local success = require(script.Parent.Parent .. ".SkyManager"):applyPreset("Shimmering Stars", true, 1.5)
		if success then
			info.Text = "✅ تم تطبيق السماء: Shimmering Stars"
		else
			info.Text = "❌ فشل تطبيق السماء"
		end
	end))

	-- Restore button
	local restoreBtn = Instance.new("TextButton")
	restoreBtn.Name = "RestoreSkyBtn"
	restoreBtn.Size = UDim2.new(0.4, 0, 0, 30)
	restoreBtn.Position = UDim2.fromScale(0.3, 0.7)
	restoreBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	restoreBtn.BackgroundTransparency = 0
	restoreBtn.TextColor3 = Color3.new(1, 1, 1)
	restoreBtn.Font = Enum.Font.GothamBold
	restoreBtn.TextSize = 12
	restoreBtn.BorderSizePixel = 0
	restoreBtn.Text = "استعادة الأصلية"
	restoreBtn.Parent = frame
	table.insert(self.connections, restoreBtn.MouseButton1Click:Connect(function()
		require(script.Parent.Parent .. ".SkyManager"):restoreOriginal()
		info.Text = "🔄 تم استعادة إعدادات السماء الأصلية"
	end))
end

function UIManager:_buildGraphicsTab(parent)
	local frame = Instance.new("Frame")
	frame.Name = "GraphicsTab"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = parent

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.fromScale(0, 0.1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "✨ تعزيز الرسوم"
	title.TextColor3 = colors.Accent
	title.TextScaled = true
	title.Parent = frame

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -20, 0, 80)
	info.Position = UDim2.fromScale(0, 0.2)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.GothamMedium
	info.Text = "حدد جودة الرسوم:\n1. Ultra Quality - جودة عالية (تتطلب جهاز جيد)\n2. High Performance - أداء عالي\n3. Cinematic - مظهر سينمائي\n4. Mobile Safe - متوافق مع جميع الأجهزة"
	info.TextColor3 = Color3.new(1, 1, 1)
	info.TextScaled = true
	info.TextWrapped = true
	info.Parent = frame

	-- Apply button for each preset
	local function createApplyBtn(presetName, presetDesc)
		local btn = Instance.new("TextButton")
		btn.Name = presetName .. "Btn"
		btn.Size = UDim2.new(0.8, 0, 0, 30)
		btn.Position = UDim2.fromScale(0.1, 0.4 + 0.15 * (presetName == "Ultra Quality" and 0 or presetName == "High Performance" and 1 or presetName == "Cinematic" and 2 or 3))
		btn.BackgroundColor3 = colors.Accent
		btn.BackgroundTransparency = 0
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 11
		btn.BorderSizePixel = 0
		btn.Text = presetDesc
		btn.Parent = frame
		table.insert(self.connections, btn.MouseButton1Click:Connect(function()
			local success = require(script.Parent.Parent .. ".GraphicsEnhancer"):applyPreset(presetName)
			info.Text = "✅ تم تطبيق: " .. presetDesc
		end))
	end

	createApplyBtn("Ultra Quality", "Ultra Quality")
	createApplyBtn("High Performance", "High Performance")
	createApplyBtn("Cinematic", "Cinematic")
	createApplyBtn("Mobile Safe", "Mobile Safe")

	-- Restore button
	local restoreBtn = Instance.new("TextButton")
	restoreBtn.Name = "RestoreGraphicsBtn"
	restoreBtn.Size = UDim2.new(0.8, 0, 0, 30)
	restoreBtn.Position = UDim2.fromScale(0.1, 0.9)
	restoreBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	restoreBtn.BackgroundTransparency = 0
	restoreBtn.TextColor3 = Color3.new(1, 1, 1)
	restoreBtn.Font = Enum.Font.GothamBold
	restoreBtn.TextSize = 11
	restoreBtn.BorderSizePixel = 0
	restoreBtn.Text = "استعادة الأصلية"
	restoreBtn.Parent = frame
	table.insert(self.connections, restoreBtn.MouseButton1Click:Connect(function()
		require(script.Parent.Parent .. ".GraphicsEnhancer"):restoreOriginal()
		info.Text = "🔄 تم استعادة إعدادات الرسوم الأصلية"
	end))
end

function UIManager:_buildSettingsTab(parent)
	local frame = Instance.new("Frame")
	frame.Name = "SettingsTab"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = parent

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.fromScale(0, 0.1)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "⚙️ الإعدادات"
	title.TextColor3 = colors.Accent
	title.TextScaled = true
	title.Parent = frame

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -20, 0, 80)
	info.Position = UDim2.fromScale(0, 0.2)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.GothamMedium
	info.Text = "خيارات إضافية:\n- تعطيل جميع الميزات\n- إعادة تعيين كل شيء للأصلي\n- معلومات عن النظام"
	info.TextColor3 = Color3.new(1, 1, 1)
	info.TextScaled = true
	info.TextWrapped = true
	info.Parent = frame

	local disableAllBtn = Instance.new("TextButton")
	disableAllBtn.Name = "DisableAllBtn"
	disableAllBtn.Size = UDim2.new(0.8, 0, 0, 30)
	disableAllBtn.Position = UDim2.fromScale(0.1, 0.5)
	disableAllBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	disableAllBtn.BackgroundTransparency = 0
	disableAllBtn.TextColor3 = Color3.new(1, 1, 1)
	disableAllBtn.Font = Enum.Font.GothamBold
	disableAllBtn.TextSize = 12
	disableAllBtn.BorderSizePixel = 0
	disableAllBtn.Text = "تعطيل جميع الميزات"
	disableAllBtn.Parent = frame
	table.insert(self.connections, disableAllBtn.MouseButton1Click:Connect(function()
		require(script.Parent.Parent .. ".SkyManager"):restoreOriginal()
		require(script.Parent.Parent .. ".GraphicsEnhancer"):restoreOriginal()
		info.Text = "🛑 تم تعطيل جميع الميزات"
	end))

	local resetAllBtn = Instance.new("TextButton")
	resetAllBtn.Name = "ResetAllBtn"
	resetAllBtn.Size = UDim2.new(0.8, 0, 0, 30)
	resetAllBtn.Position = UDim2.fromScale(0.1, 0.6)
	resetAllBtn.BackgroundColor3 = colors.Accent
	resetAllBtn.BackgroundTransparency = 0
	resetAllBtn.TextColor3 = Color3.new(1, 1, 1)
	resetAllBtn.Font = Enum.Font.GothamBold
	resetAllBtn.TextSize = 12
	resetAllBtn.BorderSizePixel = 0
	resetAllBtn.Text = "إعادة التعيين الكاملة"
	resetAllBtn.Parent = frame
	table.insert(self.connections, resetAllBtn.MouseButton1Click:Connect(function()
		require(script.Parent.Parent .. ".SkyManager"):restoreOriginal()
		require(script.Parent.Parent .. ".GraphicsEnhancer"):restoreOriginal()
		info.Text = "↺ تم إعادة التعيين الكامل"
	end))
end

function UIManager:switchTab(tabName)
	if self.destroyed then
		return
	end
	self.currentTab = tabName

	-- Update tab button appearances
	local tabNames = {"home", "sky", "graphics", "settings"}
	for i, name in ipairs(tabNames) do
		local btn = self.tabButtons[name]
		if name == tabName then
			btn.BackgroundTransparency = 0
			btn.TextColor3 = colors.Accent
		else
			btn.BackgroundTransparency = 0.5
			btn.TextColor3 = Color3.new(1, 1, 1)
		end
	end

	-- Hide all tab contents
	for _, name in ipairs(tabNames) do
		if self:findTabContent(name) then
			self:findTabContent(name).Visible = false
		end
	end

	-- Show the selected tab content
local selectedContent = self:findTabContent(tabName)
	if selectedContent then
		selectedContent.Visible = true
	end
end

function UIManager:findTabContent(tabName)
	local tabContents = {
		home = self.gui:FindFirstChild("HomeTab"),
		sky = self.gui:FindFirstChild("SkyTab"),
		graphics = self.gui:FindFirstChild("GraphicsTab"),
		settings = self.gui:FindFirstChild("SettingsTab"),
	}
	return tabContents[tabName]
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

function UIManager:disable()
	if self.destroyed then
		return
	end
	-- Switch to home tab and hide effects
	self:switchTab("home")
	-- Restore original graphics and sky
	pcall(function()
		require(script.Parent.Parent .. ".SkyManager"):restoreOriginal()
	end)
	pcall(function()
		require(script.Parent.Parent .. ".GraphicsEnhancer"):restoreOriginal()
	end)
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