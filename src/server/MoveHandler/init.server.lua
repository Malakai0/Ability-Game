local Remote: RemoteEvent = game:GetService'ReplicatedStorage'.RemoteEvent;

local Cooldowns = {};
local CurrentlyHolding = setmetatable({}, {__mode = "v"});
local CurrentlyHandling = setmetatable({}, {__mode = "v"});

local Common = game:GetService("ReplicatedStorage").Common;

local Promise = require(Common.Modules.Promise);
local SharedMoves = require(Common.Modules.SharedMoves);

local MoveList = script.Moves:GetChildren()
local Moves = {}

for _, Move in next, MoveList do
    local MoveInfo = require(Move)
    Moves[MoveInfo.Move] = MoveInfo;
end

local function GetMoveFromKey(Key)
    for _, Move in next, SharedMoves do
        if (Move.Keybind.Value == Key) then
            return Move.Name;
        end
    end
end

local function GenerateCooldownKeyForID(Id, Move)
    return Id .. ':' .. tostring(Move);
end

Remote.OnServerEvent:Connect(function(Player, Key, State)

    if (table.find(CurrentlyHolding, Player) and State == 1) then
        return
    end

    if (table.find(CurrentlyHandling, Player)) then
        return;
    end
    
    if (not Player.Character) then
        return;
    end

    local MoveKey = GetMoveFromKey(Key)

    if (not MoveKey) then
        return;
    end

    local Id = Player.Character:GetAttribute('UID');

    if (table.find(Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))) then
        return;
    end

    local Move = Moves[MoveKey];
    local Enabled = State == 1;

    if (not Move) then
        return warn('No implementation for move "' .. MoveKey .. '".')
    end

    local FuncName = Enabled and 'Enabled' or 'Disabled';

    if (type(Move[FuncName]) == 'function') then
        table.insert(CurrentlyHandling, Player)

        local DisabledFunc = type(Move.Disabled) == 'function'
        local ApplyCooldown = (FuncName == 'Enabled' and (not DisabledFunc)) or (FuncName == 'Disabled');

        if (ApplyCooldown) then
            table.insert(Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))
        end

        if (FuncName == 'Enabled' and type(Move.Disabled) == 'function') then
            table.insert(CurrentlyHolding, Player)
        end

        Promise.new(function(resolve)
            resolve(Move[FuncName](Move, SharedMoves[MoveKey].Environment or {}, Player))
        end):andThen(function()
            task.wait(SharedMoves[MoveKey].MoveLength or 0)

            if (Player) then
                table.remove(CurrentlyHandling, table.find(CurrentlyHandling, Player))
            end

            if (FuncName == 'Disabled' and Player) then
                table.remove(CurrentlyHolding, table.find(CurrentlyHolding, Player))
            end

            if (ApplyCooldown) then
                task.delay(SharedMoves[MoveKey].Cooldown or 0, function()
                    table.remove(Cooldowns, table.find(Cooldowns, GenerateCooldownKeyForID(Id, MoveKey)))
                end)
            end
        end)
    end
end)