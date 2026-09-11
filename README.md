# Egg Miner Simulator

MS2-inspired Roblox simulator MVP with original gameplay implementation.

## Phase 2 included

- Server-authoritative mining
- Mining distance validation
- Remote-event rate limiting
- Pickaxe upgrades
- Backpack capacity
- Sell area validation
- Server-authoritative egg hatching
- Pet multipliers
- Automatic starter world/eggs
- Mobile touch + desktop mouse input
- Persistent DataStore saving
- Autosave and BindToClose saving
- Leaderboard Coins value
- Rojo project structure

## Studio setup

1. Install/open Roblox Studio.
2. Install Rojo if you want GitHub files synchronized into Studio.
3. Open `default.project.json` with Rojo.
4. Start the Rojo sync server and connect the Roblox Studio Rojo plugin.
5. Publish the experience to your Roblox account.
6. In Studio, enable **Game Settings → Security → Enable Studio Access to API Services** for DataStore testing in Studio.
7. Test using **Play**.

For a published experience, DataStore access is handled by Roblox. Never put API keys or secrets in this repository.

## Architecture

`src/ReplicatedStorage/Shared` contains configuration only.

`src/ServerScriptService/Services` contains trusted game logic.

`src/StarterPlayer/StarterPlayerScripts` contains client input/UI. The client never decides coins, pet rarity, damage, or upgrade eligibility.

## Current gameplay

Mine one of the generated eggs, fill the backpack, stand near the Sell area and press SELL, upgrade your pickaxe, then press HATCH near the Basic Egg.

## Next phase

Pet inventory/equip management, egg health UI, animations, multiple zones, quests, rebirths, trading, stronger anti-exploit telemetry, and polished original assets/UI.
