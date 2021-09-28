local Util = {}

local ClientCommunicator: RemoteEvent = game:GetService'ReplicatedStorage'.Remotes.ClientCommunication;

local Players = game:GetService('Players');

function Util.ApplyGui(Player: Player, ...)
    ClientCommunicator:FireClient(Player, 'GUI', ...);
end

function Util.PlayEffectFromPlayer(Player: Player, Effect: string, State: string)
    for I,V in next, Players:GetPlayers() do
        if V ~= Player then
            ClientCommunicator:FireClient(V, 'Effect', Effect, tostring(State):lower() == 'enabled' and 1 or 0, Player);
        end
    end
end

function Util.ApplyForce(Player: Player, Force: Vector3, Optional: Instance?)
    ClientCommunicator:FireClient(Player, 'Force', Force, Optional);
end

function Util.FireRay(Origin: Vector3, Direction: Vector3, List: table|Instance, Type: number)
    local Params = RaycastParams.new()
    Params.FilterType = Type == 0 and Enum.RaycastFilterType.Whitelist or Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = type(List) == 'table' and List or {List};
    
    local Result = workspace:Raycast(Origin, Direction, Params);

    if (Result) then
        return Result.Instance, Result.Position, Result.Normal;
    end
end

function Util.AOEAttack(Player: Player, Origin: CFrame, Radius: number, Whitelist: table?, Settings: table, Callback: (BasePart) -> ())
    local Params = OverlapParams.new()
    Params.FilterDescendantsInstances = {workspace.Entities}
    Params.FilterType = Enum.RaycastFilterType.Whitelist;

    table.foreach(Whitelist or {}, function(_, value)
        table.insert(Params.FilterDescendantsInstances, value)
    end);

    local Parts: Array<BasePart> = workspace:GetPartBoundsInBox(Origin, Vector3.new(Radius, Radius, Radius), Params);

    local AffectedModels: table = setmetatable({}, {__mode = 'k'});

    local AffectMaxCount = Settings.MaxHits or 1;

    for _, Part: BasePart in next, Parts do
        local Model = Part:FindFirstAncestorOfClass('Model')
        local Humanoid = Model and Model:FindFirstChild('Humanoid')
        local TargetPlayer = Model and game:GetService('Players'):GetPlayerFromCharacter(Model)

        local InvalidInstances = (not Model) or (not Humanoid);
        local MaxAffections = Model and (AffectedModels[Model] and (AffectedModels[Model] >= AffectMaxCount or AffectMaxCount == 0));

        if (MaxAffections or InvalidInstances) then
            continue
        end

        if (TargetPlayer == Player and (not Settings.AffectPlayer)) then
            continue
        end

        AffectedModels[Model] = (AffectedModels[Model] or 0) + 1;
        task.spawn(Callback, Humanoid, Model, TargetPlayer);
    end

    AffectedModels = nil;
end

return Util;