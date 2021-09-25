local Players = game:GetService'Players'

local function CharacterAdded(Character: Model)
    repeat task.wait() until Character.Parent == workspace
    
    Character.Parent = workspace.Entities
end

local function PlayerAdded(Player: Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    CharacterAdded(Character)
    Player.CharacterAdded:Connect(CharacterAdded)
end

for _, Player in next, Players:GetPlayers() do
    PlayerAdded(Player)
end

Players.PlayerAdded:Connect(PlayerAdded)