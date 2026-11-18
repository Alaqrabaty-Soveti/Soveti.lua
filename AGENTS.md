# AGENTS.md — project notes

## Stack
Roblox Luau intro system. Source lives in `src/` as plain `.lua` files.
No npm/package.json: there is no build step and no dev server for this repo.

## Verify
- Syntax check: `apk add --no-cache luau`, then `luau-analyze src/<file>.lua`.
- `luau-analyze` does NOT know Roblox types, so `Unknown global 'game'/'Enum'/'Instance'/'task'`
  warnings are expected noise. Only `syntax` / `expected` / `unexpected` / `unclosed` / `malformed`
  lines are real problems.
- Real runtime testing must happen in Roblox Studio (not available in this sandbox).

## Layout contract
- `src/Config.lua`, `CameraController.lua`, `UIManager.lua`, `AudioManager.lua`,
  `EffectsManager.lua` → ModuleScripts inside `ReplicatedStorage.CinematicIntro`.
- `src/IntroClient.lua` → LocalScript in `StarterPlayerScripts`.
- `src/IntroServer.lua` → optional Script in `ServerScriptService`.
- `default.project.json` (Rojo) maps all of the above; keep paths in sync when renaming.

## Decisions
- Intro runs client-side only; server module is optional coordination.
- No bundled audio/image asset IDs: `Config.Audio` defaults to `0` (disabled) on purpose.
- `Config.CameraShots` durations must sum to `Config.IntroDuration` and match `Config.Audio.SyncPoints`.
