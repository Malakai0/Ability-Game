local Players = game:GetService'Players';

local DataHandler = require(game:GetService('ReplicatedStorage').Modules.DataModules.DataHandler);

local System = {Data = setmetatable({}, {__mode = "v"})};

local function CharacterAdded(Character: Model)
    repeat task.wait() until Character.Parent == workspace

    Character:SetAttribute('UID', game:GetService'HttpService':GenerateGUID())
    Character.Parent = workspace.Entities
end

local function PlayerAdded(Player: Player)
    local Profile = DataHandler.Server.LoadProfile(Player);

    Profile:ListenToRelease(function()
        if (System.Data[Player.UserId]) then
            System.Data[Player.UserId] = nil
        end

        Player:Kick()
    end)

    Player:GetAttributeChangedSignal('Data'):Connect(function()
        if (not System.Data[Player.UserId]) then
            return;
        end
        
        System.Data[Player.UserId].Data = DataHandler.Shared.GetDataForPlayer(Player);
    end)

    System.Data[Player.UserId] = Profile

    local Character = Player.Character or Player.CharacterAdded:Wait()
    CharacterAdded(Character)
    Player.CharacterAdded:Connect(CharacterAdded)
end

local function PlayerRemoving(Player: Player)
    local Id = Player.UserId;
    local Data = System.Data[Id];

    if (Data) then
        Data:Release()

        System.Data[Id] = nil;
    end
end

for _, Player in next, Players:GetPlayers() do
    PlayerAdded(Player)
end

Players.PlayerRemoving:Connect(PlayerRemoving)
Players.PlayerAdded:Connect(PlayerAdded)

return System;