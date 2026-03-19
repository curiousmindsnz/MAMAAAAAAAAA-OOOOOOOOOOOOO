-- CoinGameRemotes.lua
-- Creates (server) or retrieves (client) the RemoteEvents and RemoteFunctions
-- used by the Coin Collector mini-game.
-- Place this ModuleScript inside ReplicatedStorage.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("CoinGameConfig"))

local CoinGameRemotes = {}

-- Internal folder that holds all remote instances
local FOLDER_NAME = "CoinGameRemotes"

-- Returns the remotes folder, creating it on the server if it does not exist.
local function getFolder(): Folder
    local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = FOLDER_NAME
        folder.Parent = ReplicatedStorage
    end
    return folder
end

-- Creates a RemoteEvent inside the folder (server-side call only).
local function createRemoteEvent(name: string): RemoteEvent
    local folder = getFolder()
    local existing = folder:FindFirstChild(name)
    if existing then
        return existing :: RemoteEvent
    end
    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = folder
    return remote
end

-- Creates a RemoteFunction inside the folder (server-side call only).
local function createRemoteFunction(name: string): RemoteFunction
    local folder = getFolder()
    local existing = folder:FindFirstChild(name)
    if existing then
        return existing :: RemoteFunction
    end
    local remote = Instance.new("RemoteFunction")
    remote.Name = name
    remote.Parent = folder
    return remote
end

-- Waits for a child inside the folder (client-side call).
local function waitForRemote(name: string): Instance
    local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
    return folder:WaitForChild(name)
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Server: set up all remotes. Client: retrieve them.
function CoinGameRemotes.setup(isServer: boolean)
    if isServer then
        CoinGameRemotes.CoinCollected    = createRemoteEvent(Config.REMOTE_COIN_COLLECTED)
        CoinGameRemotes.RequestCoinPositions = createRemoteFunction(Config.REMOTE_REQUEST_COINS)
    else
        CoinGameRemotes.CoinCollected    = waitForRemote(Config.REMOTE_COIN_COLLECTED) :: RemoteEvent
        CoinGameRemotes.RequestCoinPositions = waitForRemote(Config.REMOTE_REQUEST_COINS) :: RemoteFunction
    end
end

return CoinGameRemotes
