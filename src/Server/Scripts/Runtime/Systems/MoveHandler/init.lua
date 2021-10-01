local MoveHandler = {}

local Remote: RemoteEvent = game:GetService'ReplicatedStorage'.Remotes.RemoteEvent;

local Util = require(game:GetService('ServerStorage').ServerModules.Util);

local Modules = game:GetService("ReplicatedStorage").Modules;

local Promise = require(Modules.LogicModules.Promise);
local SharedMoves = require(Modules.DataModules.SharedMoves);

local MoveList = script.Moves:GetChildren()
local Moves = {}

for _, Move in next, MoveList do
    local MoveInfo = require(Move)
    Moves[MoveInfo.Move] = MoveInfo;
end

local EnumItems = {};

for _, Enums in next, {Enum.KeyCode, Enum.UserInputType} do
    for _, Item in next, Enums:GetEnumItems() do
        EnumItems[Item.Value] = Item.Name;
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

function MoveHandler.AddCooldown(Player, MoveKey, Keybind, StartRemoval)
    if (not Player) then return end;

    local Character = Player.Character;
    if (not Character) then
        return;
    end

    local Id = Character:GetAttribute('UID');
    table.insert(MoveHandler.Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))

    local Length = SharedMoves[MoveKey].Cooldown
    Util.ApplyGui(Player, 'Cooldown', SharedMoves[MoveKey].DisplayName, EnumItems[Keybind], Length or 0)

    if (StartRemoval) then
        task.delay(Length or 0, function()
            MoveHandler.RemoveCooldown(Id, MoveKey)
        end)
    end
end

function MoveHandler.RemoveCooldown(Id, MoveKey)
    if (table.find(MoveHandler.Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))) then
        table.remove(MoveHandler.Cooldowns, table.find(MoveHandler.Cooldowns, GenerateCooldownKeyForID(Id, MoveKey)))
    end
end

function MoveHandler.Start(Server)
    MoveHandler.Cooldowns = {};
    MoveHandler.CurrentlyHolding = setmetatable({}, {__mode = "v"});
    MoveHandler.CurrentlyHandling = setmetatable({}, {__mode = "v"});

    Remote.OnServerEvent:Connect(function(Player, Keybind, State)
        if (not EnumItems[Keybind]) then
            return;
        end
    
        if (table.find(MoveHandler.CurrentlyHolding, Player) and State == 1) then
            return
        end
    
        if (table.find(MoveHandler.CurrentlyHandling, Player)) then
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
    
        if (table.find(MoveHandler.Cooldowns, GenerateCooldownKeyForID(Id, MoveKey))) then
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
    
            table.insert(MoveHandler.CurrentlyHandling, Player)
    
            local DisabledFunc = type(Move.Disabled) == 'function'
            local ApplyCooldown = (FuncName == 'Enabled' and (not DisabledFunc)) or (FuncName == 'Disabled');
    
            if (FuncName == 'Enabled' and type(Move.Disabled) == 'function') then
                table.insert(MoveHandler.CurrentlyHolding, Player)
                Player.Character:SetAttribute('ActiveMove', MoveKey);
            end
    
            Promise.new(function(resolve)
                resolve(Move[FuncName](Move, SharedMoves[MoveKey].Environment or {}, Player))
            end):andThen(function(forceCooldown)
                forceCooldown = forceCooldown == true;
    
                task.wait(SharedMoves[MoveKey].MoveLength or 0)

                local Current = Player.Character:GetAttribute('ActiveMove')
                if (Current == MoveKey) then
                    Player.Character:SetAttribute('ActiveMove', nil)
                end
    
                if (Player) then
                    table.remove(MoveHandler.CurrentlyHandling, table.find(MoveHandler.CurrentlyHandling, Player))
                end
    
                if ((FuncName == 'Disabled' or (DisabledFunc and forceCooldown)) and Player) then
                    table.remove(MoveHandler.CurrentlyHolding, table.find(MoveHandler.CurrentlyHolding, Player))
                end
    
                if (forceCooldown or ApplyCooldown) then
                    MoveHandler.AddCooldown(Player, MoveKey, Keybind, true)
                end
            end)
        end
    end)
end

return MoveHandler;