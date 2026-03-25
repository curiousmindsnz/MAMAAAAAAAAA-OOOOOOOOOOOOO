-- CoinGameClient.client.lua
-- Client-side HUD and feedback for the Coin Collector mini-game.
-- Place this LocalScript inside StarterPlayerScripts.
--
-- Features:
--   • On-screen coin counter (bottom-centre HUD)
--   • "Coin collected!" pop-up notification when any player picks up a coin
--   • "+1 coin" floating label when the local player picks one up

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local Config  = require(ReplicatedStorage:WaitForChild("CoinGameConfig"))
local Remotes = require(ReplicatedStorage:WaitForChild("CoinGameRemotes"))

Remotes.setup(false)

local localPlayer = Players.LocalPlayer

-- ── Build the HUD ─────────────────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "CoinGameHUD"
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.Parent          = localPlayer:WaitForChild("PlayerGui")

-- Coin counter frame (bottom-centre)
local counterFrame = Instance.new("Frame")
counterFrame.Name              = "CounterFrame"
counterFrame.Size              = UDim2.new(0, 200, 0, 60)
counterFrame.Position          = UDim2.new(0.5, -100, 1, -80)
counterFrame.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
counterFrame.BackgroundTransparency = 0.3
counterFrame.BorderSizePixel   = 0
counterFrame.Parent            = screenGui

local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 12)
cornerRadius.Parent = counterFrame

local coinIcon = Instance.new("TextLabel")
coinIcon.Name               = "CoinIcon"
coinIcon.Size               = UDim2.new(0, 50, 1, 0)
coinIcon.Position           = UDim2.new(0, 5, 0, 0)
coinIcon.BackgroundTransparency = 1
coinIcon.Text               = "🪙"
coinIcon.TextScaled          = true
coinIcon.Font               = Enum.Font.GothamBold
coinIcon.Parent             = counterFrame

local coinCountLabel = Instance.new("TextLabel")
coinCountLabel.Name               = "CoinCount"
coinCountLabel.Size               = UDim2.new(1, -60, 1, 0)
coinCountLabel.Position           = UDim2.new(0, 55, 0, 0)
coinCountLabel.BackgroundTransparency = 1
coinCountLabel.Text               = "0"
coinCountLabel.TextColor3         = Color3.fromRGB(255, 220, 0)
coinCountLabel.TextStrokeTransparency = 0
coinCountLabel.Font               = Enum.Font.GothamBold
coinCountLabel.TextScaled          = true
coinCountLabel.Parent             = counterFrame

-- Notification label (centre-screen, fades in/out)
local notifLabel = Instance.new("TextLabel")
notifLabel.Name                  = "Notification"
notifLabel.Size                  = UDim2.new(0, 400, 0, 60)
notifLabel.Position              = UDim2.new(0.5, -200, 0.25, 0)
notifLabel.AnchorPoint           = Vector2.new(0, 0)
notifLabel.BackgroundTransparency = 1
notifLabel.Text                  = ""
notifLabel.TextColor3            = Color3.fromRGB(255, 220, 0)
notifLabel.TextStrokeTransparency = 0
notifLabel.TextStrokeColor3      = Color3.fromRGB(0, 0, 0)
notifLabel.Font                  = Enum.Font.GothamBold
notifLabel.TextScaled             = true
notifLabel.TextTransparency       = 1
notifLabel.Parent                = screenGui

-- ── Helper: flash the notification ───────────────────────────────────────────

local notifTween: Tween? = nil

local function showNotification(text: string)
    if notifTween then
        notifTween:Cancel()
    end
    notifLabel.Text = text
    notifLabel.TextTransparency = 0
    notifLabel.Position = UDim2.new(0.5, -200, 0.25, 0)

    -- Slide up and fade out after 1.5 s
    notifTween = TweenService:Create(notifLabel,
        TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            TextTransparency = 1,
            Position = UDim2.new(0.5, -200, 0.18, 0),
        }
    )
    notifTween:Play()
end

-- ── Helper: bounce the counter ────────────────────────────────────────────────

local function bounceCounter()
    local info = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
    local grow = TweenService:Create(counterFrame, info, {Size = UDim2.new(0, 220, 0, 70)})
    local shrink = TweenService:Create(counterFrame, info, {Size = UDim2.new(0, 200, 0, 60)})
    grow:Play()
    grow.Completed:Connect(function()
        shrink:Play()
    end)
end

-- ── Listen for coin collection events ────────────────────────────────────────

Remotes.CoinCollected.OnClientEvent:Connect(function(collector: Player, newTotal: number)
    if collector == localPlayer then
        -- Update local counter
        coinCountLabel.Text = tostring(newTotal)
        bounceCounter()
        local coinWord = Config.COINS_PER_PICKUP == 1 and "coin" or "coins"
        showNotification("🪙 +" .. Config.COINS_PER_PICKUP .. " " .. coinWord .. "!")
    else
        -- Show who else grabbed a coin
        showNotification(collector.Name .. " collected a coin!")
    end
end)

-- ── Sync counter with server leaderstats on spawn ─────────────────────────────

local function syncCounter()
    local leaderstats = localPlayer:WaitForChild("leaderstats", 10)
    if not leaderstats then return end
    local coinStat = leaderstats:WaitForChild(Config.LEADERSTAT_NAME, 10)
    if not coinStat then return end

    -- Reflect initial value (e.g. after respawn)
    coinCountLabel.Text = tostring(coinStat.Value)

    coinStat.Changed:Connect(function(newValue: number)
        coinCountLabel.Text = tostring(newValue)
    end)
end

task.spawn(syncCounter)

print("[CoinGame] Client HUD loaded for", localPlayer.Name)
