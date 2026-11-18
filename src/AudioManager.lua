--[[
	AudioManager.lua — optional music / ambience with safe cleanup.
	Asset IDs come from Config.Audio; 0 or nil disables a track.
	Import this file into a ModuleScript named "AudioManager".
]]

local SoundService = game:GetService("SoundService")

local AudioManager = {}
AudioManager.__index = AudioManager

function AudioManager.new(config)
	local self = setmetatable({}, AudioManager)
	self.config = config
	self.sounds = {}
	return self
end

function AudioManager:_create(name, assetId, looped, volume)
	if not assetId or assetId == 0 then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. tostring(assetId)
	sound.Looped = looped
	sound.Volume = volume
	sound.Parent = SoundService
	table.insert(self.sounds, sound)
	return sound
end

function AudioManager:start()
	local audio = self.config.Audio
	self.ambience = self:_create("IntroAmbience", audio.AmbienceId, true, audio.Volume * 0.6)
	self.music = self:_create("IntroMusic", audio.MusicId, false, audio.Volume)
	if self.ambience then
		self.ambience:Play()
	end
	if self.music then
		self.music:Play()
	end
end

function AudioManager:playCue(assetId, volume)
	local sound = self:_create("IntroCue", assetId, false, volume or self.config.Audio.Volume)
	if sound then
		sound:Play()
	end
	return sound
end

function AudioManager:stopAll(fadeTime)
	fadeTime = fadeTime or 0.8
	local sounds = self.sounds
	self.sounds = {}
	for _, sound in ipairs(sounds) do
		task.spawn(function()
			if not sound.Parent then
				return
			end
			local startVolume = sound.Volume
			local started = os.clock()
			while sound.Parent and (os.clock() - started) < fadeTime do
				local ratio = 1 - ((os.clock() - started) / fadeTime)
				sound.Volume = math.max(startVolume * ratio, 0)
				task.wait(0.05)
			end
			sound:Stop()
			sound:Destroy()
		end)
	end
end

return AudioManager
