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
  `EffectsManager.lua`, `VFXManager.lua` → ModuleScripts inside `ReplicatedStorage.CinematicIntro`.
- `src/IntroClient.lua` → LocalScript in `StarterPlayerScripts`.
- `src/IntroServer.lua` → optional Script in `ServerScriptService`.
- `default.project.json` (Rojo) maps all of the above; keep paths in sync when renaming.

## Decisions
- Intro runs client-side only; server module is optional coordination.
- No bundled audio/image asset IDs: `Config.Audio` defaults to `0` (disabled) on purpose;
  SFX cues still fire (silent until real IDs are provided).
- VFX is fully procedural (particles, shockwave, rays, speed lines) — no external meshes.
- `Config.Timeline` is the single source of truth for events; `CameraShots` durations
  must sum to `IntroDuration` and stay in sync with `Audio.SyncPoints`.

## Delivery
- Target GitHub repo: `Alaqrabaty-Soveti/Soveti.lua` (public, `main` branch, pushed via `github` remote).
- Push requires a token with **Contents: Read and write**. A read-only token fails with HTTP 403.
- `cinematic-intro-roblox.zip` is a local delivery fallback (git-ignored, never committed).
