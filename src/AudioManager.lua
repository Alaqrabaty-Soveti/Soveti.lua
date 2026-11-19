--[[
	AudioManager.lua — music, ambience and named one-shot SFX cues.
	All ids come from Config.Audio; 0 or nil disables a track silently.

	Place as: ReplicatedStorage.CinematicIntro.AudioManager (ModuleScript)
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local AudioManager = {}
AudioManager.__index = AudioManager

function AudioManager.new(config)
	local self = setmetatable({}, AudioManager)
	self.config = config
	self.sounds = {}
	self.cues = {}
	return self
end

function AudioManager:_make(name, assetId, looped, volume, pitch)
	if not assetId or assetId == 0 then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. tostring(assetId)
	sound.Looped = looped
	sound.Volume = volume or 0.5
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	table.insert(self.sounds, sound)
	return sound
end

function AudioManager:start()
	local audio = self.config.Audio

	self.ambience = self:_make("IntroAmbience", audio.AmbienceId, true, audio.Volume * 0.55)
	self.music = self:_make("IntroMusic", audio.MusicId, false, audio.Volume)

	for _, sound in ipairs({ self.ambience, self.music }) do
		if sound then
			sound.Volume = 0
			sound:Play()
			TweenService:Create(
				sound,
				TweenInfo.new(audio.FadeIn or 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ Volume = (sound == self.music) and audio.Volume or audio.Volume * 0.55 }
			):Play()
		end
	end
end

-- Play a named cue from Config.Audio.Cues. Unknown names are ignored.
function AudioManager:playCue(name, volumeScale)
	local audio = self.config.Audio
	if name == "Ambience" then
		return self.ambience
	elseif name == "Music" then
		return self.music
	end

	local def = audio.Cues and audio.Cues[name]
	if not def or not def.id or def.id == 0 then
		return nil
	end

	local sound = self:_make("IntroCue_" .. name, def.id, false, (def.volume or 0.5) * (volumeScale or 1), def.pitch)
	if sound then
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
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
