local Players = game:GetService("Players")
local DataHandler = {Server = {}, Shared = {}}

export type PlayerData = {
    GamemodeData: {[string]: {[any]: any}},
    
    Stats: {
        Coins: number,
        Kills: number,
        Deaths: number
    },

    Cosmetics: {
        Skins: {[number]: string},
        EquippedSkins: {[string]: string}
    }
}

local DefaultProfile: PlayerData = {
    GamemodeData = {};

    Stats = {
        Coins = 0;

        Kills = 0;
        Deaths = 0;
    };

    Cosmetics = {
        Skins = {};
        EquippedSkins = {};
    };
}

if (game:GetService('RunService'):IsServer()) then
    local ProfileService = require(script.Parent.ProfileService);

    DataHandler.DataStructure = ProfileService.GetProfileStore("PlayerData", DefaultProfile);
end

--- Loads and reutrns a profile given `Player`.
---@param Player Player
function DataHandler.Server.LoadProfile(Player: Player)
    local Profile = DataHandler.DataStructure:LoadProfileAsync("Player:"..Player.UserId);

    if (Profile) then
        Profile:AddUserId(Player.UserId)
        Profile:Reconcile();

        if (not Player:IsDescendantOf(game:GetService'Players')) then
            Profile:Release();
            Player:Kick();
        end

        Player:SetAttribute('Data', game:GetService('HttpService'):JSONEncode(Profile.Data));

        return Profile;
    else
        Player:Kick("Error loading data. Rejoin please!");
    end
end

--- Encodes and sets the data for player, given `Data` and `Player`.
---@param Player Player
---@param Data table
function DataHandler.Server.SetDataForPlayer(Player: Player, Data: PlayerData)
    local CurrentData = DataHandler.Shared.GetDataForPlayer(Player)

    for I,V in next, Data do
        CurrentData[I] = V;
    end;

    Player:SetAttribute('Data', game:GetService('HttpService'):JSONEncode(CurrentData));
end

--- Decodes and returns the data that is attached to the Player's instance, given `Player`.
---@param Player Player
function DataHandler.Shared.GetDataForPlayer(Player: Player): PlayerData
    if (not Player:GetAttribute('Data')) then
        repeat Player.AttributeChanged:Wait() until Player:GetAttribute('Data');
    end

    return game:GetService('HttpService'):JSONDecode(Player:GetAttribute('Data'));
end

return DataHandler;