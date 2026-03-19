-- CoinGameConfig.lua
-- Shared configuration for the Coin Collector mini-game.
-- Place this ModuleScript inside ReplicatedStorage.

local CoinGameConfig = {}

-- How many coins exist in the world at any one time
CoinGameConfig.MAX_COINS = 20

-- Value awarded to the player for each coin collected
CoinGameConfig.COINS_PER_PICKUP = 1

-- Radius (in studs) within which a coin can be collected
CoinGameConfig.COLLECTION_RADIUS = 5

-- Time (seconds) before a collected coin respawns at a new location
CoinGameConfig.RESPAWN_DELAY = 3

-- Coin appearance
CoinGameConfig.COIN_SIZE = Vector3.new(1.5, 1.5, 0.3)
CoinGameConfig.COIN_COLOR = BrickColor.new("Bright yellow")
CoinGameConfig.COIN_MATERIAL = Enum.Material.Neon

-- Spin speed (degrees per second)
CoinGameConfig.SPIN_SPEED = 120

-- Bobbing height (studs) and speed (cycles per second)
CoinGameConfig.BOB_HEIGHT = 0.5
CoinGameConfig.BOB_SPEED  = 1.5

-- Map boundaries for random coin spawning (edit to match your map)
CoinGameConfig.SPAWN_AREA = {
    MinX = -100,
    MaxX =  100,
    MinZ = -100,
    MaxZ =  100,
    SpawnY =   5,   -- height above the ground
}

-- Leaderboard stat name shown in the Roblox player list
CoinGameConfig.LEADERSTAT_NAME = "Coins"

-- Remote event / function names (must match CoinGameRemotes.lua)
CoinGameConfig.REMOTE_COIN_COLLECTED = "CoinCollected"
CoinGameConfig.REMOTE_REQUEST_COINS  = "RequestCoinPositions"

return CoinGameConfig
