# Roblox Studio Project — Existing-Instance Recovery

This repository is the workspace for repairing the supplied **Steal an Egg** Roblox place without replacing its existing game content.

## Current recovery layer

- `src/ServerScriptService/ExtractionRecovery.server.lua`
  - Adopts existing eggs, pets, plots, and pens.
  - Preserves existing instances and their placement.
  - Reconstructs missing ownership/state where it can be inferred safely.
  - Provides a namespaced server interaction bridge.
  - Adds server-side validation and rate limiting.

## Workflow

1. Open the supplied `.rbxl` in Roblox Studio.
2. Insert the recovery script into `ServerScriptService`.
3. Start **Play** (not just Run) so player-dependent behavior is exercised.
4. Check **Server Output** for `[ExtractionRecovery]`.
5. Test the existing egg/pen/pet interactions.
6. Record any concrete Output errors and repair the affected existing module/script rather than replacing the whole system.

## Scope

The recovery work is intentionally incremental. The target is to reconnect behavior to the existing instances and existing modules. It is not intended to reproduce unavailable original server source code.
