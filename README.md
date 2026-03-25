# 🪙 Coin Collector Mini-Game for Roblox

A ready-to-use mini-game written in **Luau** (Roblox's scripting language) that you can drop straight into any Roblox Studio place.

Players walk around the map collecting spinning, glowing coins. Every coin they grab adds to their score, which is shown both in the Roblox leaderboard and in a custom on-screen HUD.

---

## ✨ Features

| Feature | Details |
|---|---|
| Coin spawning | Up to 20 coins active at once, placed randomly within a configurable area |
| Animations | Coins spin and bob up-and-down using a server-driven `Heartbeat` loop |
| Collection | Server detects proximity (5 studs by default) — no client trust needed |
| Leaderboard | Coin count shown in the native Roblox player list |
| HUD | Bottom-centre coin counter with a bounce animation when you score |
| Notifications | Pop-up message whenever any player collects a coin |
| Respawning | Collected coins reappear after a configurable delay (default 3 s) |
| Easy config | All tuneable values live in one `CoinGameConfig` module |

---

## 📁 Project Layout

```
src/
├── ReplicatedStorage/
│   ├── CoinGameConfig.lua     ← Shared settings (coin count, spawn area, etc.)
│   └── CoinGameRemotes.lua    ← RemoteEvent / RemoteFunction helpers
├── ServerScriptService/
│   └── CoinGame.server.lua    ← Server logic (spawning, detection, leaderboard)
└── StarterPlayerScripts/
    └── CoinGameClient.client.lua ← Client HUD + notifications
```

---

## 🚀 Installation (Roblox Studio)

### Option A — Copy-paste (quickest)

1. Open **Roblox Studio** and load your place.
2. Create the following instances in the Explorer:

   | File | Instance type | Parent |
   |---|---|---|
   | `CoinGameConfig.lua` | `ModuleScript` | `ReplicatedStorage` |
   | `CoinGameRemotes.lua` | `ModuleScript` | `ReplicatedStorage` |
   | `CoinGame.server.lua` | `Script` | `ServerScriptService` |
   | `CoinGameClient.client.lua` | `LocalScript` | `StarterPlayerScripts` |

3. Open each file from this repo and paste its contents into the matching instance in Studio.
4. Press **Play** (or **Playtest** → **Play Here**) and walk over a coin!

### Option B — Rojo (recommended for teams)

If you use [Rojo](https://rojo.space/) to sync a local project into Studio:

1. Add the following to your `default.project.json`:

```json
{
  "name": "MyGame",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "CoinGameConfig": {
        "$path": "src/ReplicatedStorage/CoinGameConfig.lua"
      },
      "CoinGameRemotes": {
        "$path": "src/ReplicatedStorage/CoinGameRemotes.lua"
      }
    },
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "CoinGame": {
        "$path": "src/ServerScriptService/CoinGame.server.lua"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "CoinGameClient": {
          "$path": "src/StarterPlayerScripts/CoinGameClient.client.lua"
        }
      }
    }
  }
}
```

2. Run `rojo serve` and connect Studio via the Rojo plugin.

---

## ⚙️ Configuration

Open `src/ReplicatedStorage/CoinGameConfig.lua` to customise the game:

```lua
CoinGameConfig.MAX_COINS        = 20      -- coins active at once
CoinGameConfig.COINS_PER_PICKUP = 1       -- score per coin
CoinGameConfig.COLLECTION_RADIUS = 5      -- grab distance (studs)
CoinGameConfig.RESPAWN_DELAY    = 3       -- seconds before coin reappears

-- Random spawn area (change to fit your map)
CoinGameConfig.SPAWN_AREA = {
    MinX = -100, MaxX = 100,
    MinZ = -100, MaxZ = 100,
    SpawnY = 5,               -- drop height above ground
}
```

---

## 🗺️ Adjusting the Spawn Area

The coins spawn randomly inside the `SPAWN_AREA` rectangle at height `SpawnY`.  
Change `MinX / MaxX / MinZ / MaxZ` to match the playable area of your map so coins don't fall into the void or spawn inside walls.

---

## 📜 License

MIT — free to use in any Roblox game, commercial or otherwise.
