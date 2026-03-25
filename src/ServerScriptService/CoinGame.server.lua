-- CoinGame.server.lua
-- Server-side logic for the Coin Collector mini-game.
-- Place this Script inside ServerScriptService.
--
-- Features:
--   • Spawns spinning, bobbing coin Parts in the world
--   • Detects when a player walks near a coin and awards them a point
--   • Respawns collected coins after a configurable delay
--   • Maintains a leaderboard stat ("Coins") visible in the player list
--   • Exposes a RemoteFunction so the client can request current coin positions

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config  = require(ReplicatedStorage:WaitForChild("CoinGameConfig"))
local Remotes = require(ReplicatedStorage:WaitForChild("CoinGameRemotes"))

-- Set up RemoteEvents / RemoteFunctions (server side)
Remotes.setup(true)

-- ── Leaderboard ───────────────────────────────────────────────────────────────

local function setupLeaderboard(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name  = Config.LEADERSTAT_NAME
    coins.Value = 0
    coins.Parent = leaderstats
end

Players.PlayerAdded:Connect(setupLeaderboard)

-- Initialise leaderboard for any players already in the server
for _, player in ipairs(Players:GetPlayers()) do
    setupLeaderboard(player)
end

-- ── Coin management ───────────────────────────────────────────────────────────

-- Table of active coin Parts
local activeCoins: {Part} = {}

-- Spawn a single coin at a random location within the configured area
local function spawnCoin(): Part
    local area = Config.SPAWN_AREA
    local x    = math.random(area.MinX, area.MaxX)
    local z    = math.random(area.MinZ, area.MaxZ)
    local pos  = Vector3.new(x, area.SpawnY, z)

    local coin = Instance.new("Part")
    coin.Name      = "Coin"
    coin.Size      = Config.COIN_SIZE
    coin.BrickColor = Config.COIN_COLOR
    coin.Material  = Config.COIN_MATERIAL
    coin.Shape     = Enum.PartType.Cylinder
    coin.Anchored  = true
    coin.CanCollide = false
    coin.CastShadow = false
    coin.CFrame    = CFrame.new(pos)

    -- Gold sparkle effect
    local sparkle = Instance.new("Sparkles")
    sparkle.SparkleColor = Color3.fromRGB(255, 220, 0)
    sparkle.Parent = coin

    -- Billboard label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 50, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = false
    billboard.Parent = coin

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🪙 +" .. Config.COINS_PER_PICKUP
    label.TextColor3 = Color3.fromRGB(255, 220, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard

    coin.Parent = workspace
    return coin
end

-- Spawn all coins up to MAX_COINS
local function populateCoins()
    for i = 1, Config.MAX_COINS do
        activeCoins[i] = spawnCoin()
    end
end

populateCoins()

-- ── Coin animation (spin + bob) ───────────────────────────────────────────────

-- Base Y position for each coin (to drive bobbing offset from)
local coinBaseY: {number} = {}
for i, coin in ipairs(activeCoins) do
    coinBaseY[i] = coin.Position.Y
end

local elapsed = 0
RunService.Heartbeat:Connect(function(dt: number)
    elapsed += dt
    for i, coin in ipairs(activeCoins) do
        if coin and coin.Parent then
            local baseY = coinBaseY[i] or coin.Position.Y
            local bobOffset = math.sin(elapsed * Config.BOB_SPEED * math.pi * 2) * Config.BOB_HEIGHT
            local spinAngle = math.rad(elapsed * Config.SPIN_SPEED)
            coin.CFrame = CFrame.new(coin.Position.X, baseY + bobOffset, coin.Position.Z)
                        * CFrame.Angles(0, spinAngle, math.pi / 2)
        end
    end
end)

-- ── Collection detection ──────────────────────────────────────────────────────

local function awardCoin(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    local coinStat = leaderstats:FindFirstChild(Config.LEADERSTAT_NAME)
    if not coinStat then return end
    coinStat.Value += Config.COINS_PER_PICKUP

    -- Notify all clients so they can show a local effect
    Remotes.CoinCollected:FireAllClients(player, coinStat.Value)
end

local function respawnCoin(index: number)
    task.delay(Config.RESPAWN_DELAY, function()
        local newCoin = spawnCoin()
        activeCoins[index] = newCoin
        coinBaseY[index]   = newCoin.Position.Y
    end)
end

-- Poll every frame for nearby players
RunService.Heartbeat:Connect(function()
    for index, coin in ipairs(activeCoins) do
        if not (coin and coin.Parent) then continue end

        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if not character then continue end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local dist = (hrp.Position - coin.Position).Magnitude
            if dist <= Config.COLLECTION_RADIUS then
                -- Remove coin immediately to prevent double-collection
                coin:Destroy()
                activeCoins[index] = nil
                coinBaseY[index]   = nil

                awardCoin(player)
                respawnCoin(index)
                break
            end
        end
    end
end)

-- ── RemoteFunction: give clients the current coin positions ───────────────────

Remotes.RequestCoinPositions.OnServerInvoke = function(_player: Player): {{number}}
    local positions = {}
    for _, coin in ipairs(activeCoins) do
        if coin and coin.Parent then
            local p = coin.Position
            table.insert(positions, {p.X, p.Y, p.Z})
        end
    end
    return positions
end

-- ── Clean up when a player leaves ────────────────────────────────────────────

Players.PlayerRemoving:Connect(function(player: Player)
    -- leaderstats are parented to the player and will be destroyed automatically
    -- Nothing extra needed for this simple implementation
    print("[CoinGame] Player left:", player.Name)
end)

print("[CoinGame] Server script loaded. Spawned", Config.MAX_COINS, "coins.")
