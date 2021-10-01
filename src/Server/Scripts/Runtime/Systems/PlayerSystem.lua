local Players = game:GetService'Players';

local Modules = game:GetService('ReplicatedStorage').Modules;

local DataHandler = require(Modules.DataModules.DataHandler);
local CharacterMoves = require(Modules.DataModules.CharacterMoves);
local SharedMoves = require(Modules.DataModules.SharedMoves);

local Util = require(game:GetService('ServerStorage').ServerModules.Util)

local System = {Data = setmetatable({}, {__mode = "v"})};
local Server;

function System.Start(_Server)
    Server = _Server;
end

local function CharacterAdded(Character: Model)
    repeat task.wait() until Character.Parent == workspace

    local Player = game:GetService('Players'):GetPlayerFromCharacter(Character);

    Character:SetAttribute('UID', game:GetService'HttpService':GenerateGUID())
    Character:SetAttribute('Character', 'Zeus')
    Character.Parent = workspace.Entities

    local Moves = CharacterMoves[Character:GetAttribute('Character')]
    for _, MoveName in next, Moves do
        local MoveData = SharedMoves[MoveName]
        if (MoveData.CooldownOffSpawn) then
            local DefaultKeybind = MoveData.Keybinds[1];
            
            Server.MoveHandler.AddCooldown(Player, MoveData.Name, (DefaultKeybind and DefaultKeybind.Value) or "", true);

            local Id = Character:GetAttribute('UID')
            Util.FireClient(Player, 'ApplyLocalCooldown', Id .. ':' .. MoveData.Name, MoveData.Cooldown)
        end
    end
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