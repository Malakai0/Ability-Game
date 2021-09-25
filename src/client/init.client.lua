local Player = game:GetService('Players').LocalPlayer;

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage:WaitForChild('Common');

local Effects = require(Common:WaitForChild('Effects'));
local SharedMoves = require(Common:WaitForChild('SharedMoves'));

local Handler = game:GetService("ReplicatedStorage"):WaitForChild('RemoteEvent');

local Cooldown = {}; --// For FX.

local Moves = {}

for _, Move in next, SharedMoves do
    Moves[Move.Keybind.Value] = Move;
end

local function GenerateCooldownKeyForID(Id, Move)
    return Id .. ':' .. Move;
end

local function CallMove(Value, State)
    if (not Player.Character) then
        return
    end

    local Id = Player.Character:GetAttribute('UID')

    Handler:FireServer(Value, State)

    local Shared = Moves[Value];
    local Effect = Shared and Effects.Functions[Shared.Name]
    local Key = Shared and GenerateCooldownKeyForID(Id, Shared.Name);

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
            CallMove(Key.KeyCode.Value, CorrespondingState);
        else
            CallMove(Key.UserInputType.Value, CorrespondingState);
        end
    end)
end

HandleConnection(game:GetService('UserInputService').InputBegan, 1);
HandleConnection(game:GetService('UserInputService').InputEnded, 0);