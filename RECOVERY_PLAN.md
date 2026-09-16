# Steal an Egg — Existing-Instance Recovery

## Goal

Recover the server-side behavior around the instances already present in the extracted Roblox place. The project is **not** being rebuilt from scratch.

## What is preserved

- Existing map/terrain and models
- Existing eggs and eggs already sitting in pens
- Existing pets
- Existing plots/pens
- Existing UI and client assets
- Existing ModuleScripts and LocalScripts unless a specific broken dependency is intentionally repaired

## Why a recovery layer is needed

The supplied place is an extracted `.rbxl` whose server-side behavior was not fully preserved. Several server scripts contain extraction placeholders indicating that their original server source could not be saved. That means the visible instances can survive while the runtime systems that normally create ownership, process interactions, and maintain state are absent.

The recovery layer therefore treats the existing hierarchy as the source of truth and adds only missing server plumbing.

## Recovery strategy

1. Scan existing Workspace/ReplicatedStorage/ServerStorage instances.
2. Detect egg, pet, plot, and pen-like objects using existing names and attributes.
3. Adopt existing objects instead of deleting/replacing them.
4. Preserve existing models, positions, and visual assets.
5. Reconstruct missing ownership/state attributes when ownership can be determined safely.
6. Create a small, namespaced RemoteEvent/RemoteFunction bridge only if missing.
7. Validate server-side distance, ownership, action names, and rate limits.
8. Keep the recovery code isolated under `ReplicatedStorage/ExtractionRecovery`.

## Important limitation

This is a reconstruction of missing runtime behavior, not recovery of the original proprietary server source. Exact original algorithms cannot be recovered from a place file when that server source was never included in the extraction.

## Studio installation

Copy `src/ServerScriptService/ExtractionRecovery.server.lua` into `ServerScriptService` in Roblox Studio and run a Play test. Watch **Server Output** for the `[ExtractionRecovery]` messages.

The script is intentionally conservative: it does not mass-delete existing objects or generate a replacement game world.
