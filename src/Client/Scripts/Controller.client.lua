local Player = game:GetService('Players').LocalPlayer;

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild('Modules');

local Effects = require(Modules:WaitForChild('VisualModules'):WaitForChild('Effects'));
local SharedMoves = require(Modules:WaitForChild('DataModules'):WaitForChild('SharedMoves'));

local Handler = ReplicatedStorage:WaitForChild('Remotes'):WaitForChild('RemoteEvent');

local Cooldown = {}; --// For FX.
local EnumItems = {};

--// For different abilties.
local function SanityCheck(Move: table)
    return true;
end

local function GetMoveFromKeybind(Keybind: EnumItem)
    for _, V in next, SharedMoves do
        if (table.find(V.Keybinds, Keybind) and SanityCheck(V)) then
            return V;
        end
    end
end

local function GenerateCooldownKeyForID(Id, Move)
    return Id .. ':' .. Move;
end

local function CallMove(Keybind, State)
    if (not Player.Character) then
        return
    end

    local Id = Player.Character:GetAttribute('UID')

    Handler:FireServer(Keybind.Value, State)

    local Shared = GetMoveFromKeybind(Keybind);
    local Effect = Shared and Effects.Functions[Shared.Name]
    local Key = Shared and GenerateCooldownKeyForID(Id, Shared.Name .. State);

    if (Effect and (not table.find(Cooldown, Key))) then
        table.insert(Cooldown, Key)
        
        Effect[State == 1 and 'Enabled' or 'Disabled'](Player)

        task.delay((Shared.Cooldown or 0) + (Shared.MoveLength or 0), function()
            table.remove(Cooldown, table.find(Cooldown, Key));
        end)
    end
end

local function HandleConnection(Connection, CorrespondingState)
    Connection:Connect(function(Key, Typing)
        if (Typing) then return end;
    
        if Key.UserInputType == Enum.UserInputType.Keyboard then
            CallMove(Key.KeyCode, CorrespondingState);
        else
            CallMove(Key.UserInputType, CorrespondingState);
        end
    end)
end

HandleConnection(game:GetService('UserInputService').InputBegan, 1);
HandleConnection(game:GetService('UserInputService').InputEnded, 0);