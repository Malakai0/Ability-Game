local Remote: RemoteEvent = game:GetService'ReplicatedStorage'.Remotes.RemoteEvent;

local Util = require(script.Util);

local Cooldowns = {};
local CurrentlyHolding = setmetatable({}, {__mode = "v"});
local CurrentlyHandling = setmetatable({}, {__mode = "v"});

local Modules = game:GetService("ReplicatedStorage").Modules;

local Promise = require(Modules.LogicModules.Promise);
local SharedMoves = require(Modules.DataModules.SharedMoves);

local MoveList = script.Moves:GetChildren()
local Moves = {}

for _, Move in next, MoveList do
    local MoveInfo = require(Move)
    Moves[MoveInfo.Move] = MoveInfo;
end

local function GetEnumItemFromIndex(Index: number)
    for _, Enums in next, Enum:GetEnums() do
        for _, Item in next, Enums:GetEnumItems() do
            if (Item.Value == Index) then
                return Item;
            end
        end
    end
end

--// For different abilties.
local function SanityCheck(Move: table)
    return true;
end

local function ContainsKeybind(Keybinds: table, Keybind: number)
    for _, TargetKeybind in next, Keybinds do
        if (TargetKeybind.Value == Keybind) then
            return true;
        end
    end
end

local function GetMoveFromKeybind(Keybind: number)
    for _, V in next, SharedMoves do
        if (ContainsKeybind(V.Keybinds, Keybind) and SanityCheck(V)) then
            return V.Name;
        end
    end
end

local function GenerateCooldownKeyForID(Id, Move)
    return Id .. ':' .. tostring(Move);
end

Remote.OnServerEvent:Connect(function(Player, Keybind, State)

    if (not GetEnumItemFromIndex(Keybind)) then
        return;
    end

    if (table.find(CurrentlyHolding, Player) and State == 1) then
        return
    end

    if (table.find(CurrentlyHandling, Player)) then
        return;
    end
    
    if (not Player.Character) then
        return;
    end

    local MoveKey = GetMoveFromKeybind(Keybind)

    if (not MoveKey) then
        return;
    end

    local Id = Player.Character:GetAttribute('UID');
    local ActiveMove = Player.Character:GetAttribute('ActiveMove');

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
        local IncorrectOrder = FuncName == 'Disabled' and (ActiveMove ~= MoveKey);
        if (IncorrectOrder and type(Move.Enabled) == 'function') then
            return;
        end

        table.insert(CurrentlyHandling, Player)

        local DisabledFunc = type(Move.Disabled) == 'function'
        local ApplyCooldown = (FuncName == 'Enabled' and (not DisabledFunc)) or (FuncName == 'Disabled');

        if (ApplyCooldown) then
            table.insert(Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))
        end

        if (FuncName == 'Enabled' and type(Move.Disabled) == 'function') then
            table.insert(CurrentlyHolding, Player)
            Player.Character:SetAttribute('ActiveMove', MoveKey);
        end

        Promise.new(function(resolve)
            resolve(Move[FuncName](Move, SharedMoves[MoveKey].Environment or {}, Player))
        end):andThen(function(forceCooldown)
            forceCooldown = forceCooldown == true;

            task.wait(SharedMoves[MoveKey].MoveLength or 0)

            if (Player) then
                table.remove(CurrentlyHandling, table.find(CurrentlyHandling, Player))
            end

            if ((FuncName == 'Disabled' or (DisabledFunc and forceCooldown)) and Player) then
                table.remove(CurrentlyHolding, table.find(CurrentlyHolding, Player))
            end

            if (forceCooldown and (not ApplyCooldown)) then
                ApplyCooldown = true;
                table.insert(Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))
            end

            if (ApplyCooldown) then
                local Length = SharedMoves[MoveKey].Cooldown
                Util.ApplyGui(Player, 'Cooldown', SharedMoves[MoveKey].DisplayName, GetEnumItemFromIndex(Keybind).Name, Length)

                task.delay(SharedMoves[MoveKey].Cooldown or 0, function()
                    table.remove(Cooldowns, table.find(Cooldowns, GenerateCooldownKeyForID(Id, MoveKey)))
                end)
            end
        end)
    end
end)

return nil;