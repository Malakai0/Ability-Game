local Util = {}

local ClientCommunicator: RemoteEvent = game:GetService'ReplicatedStorage'.Remotes.ClientCommunication;

local Players: Players = game:GetService('Players');

--- Applies a GUI to the client, da fuq did you expect?
---@param Player Player
function Util.ApplyGui(Player: Player, ...)
    ClientCommunicator:FireClient(Player, 'GUI', ...);
end

--- Makes an effect (`Effect`) go wooosh to every player, other than the caller; `Player`.
---@param Player Player
---@param Effect string
---@param State string
function Util.PlayEffectFromPlayer(Player: Player, Effect: string, State: string)
    for I,V in next, Players:GetPlayers() do
        if V ~= Player then
            ClientCommunicator:FireClient(V, 'Effect', Effect, tostring(State):lower() == 'enabled' and 1 or 0, Player);
        end
    end
end

--- Applies a force from `Player`'s client, given Force `Force`. `Optional` is the instance you want to force to be applied to.
---@param Player Player
---@param Force Vector3
---@param Optional Instance?|nil
function Util.ApplyForce(Player: Player, Force: Vector3, Optional: Instance?)
    ClientCommunicator:FireClient(Player, 'Force', Force, Optional);
end

--- Fires a ray from `Origin`, towards `Direction`, `List` given as a white/blacklist (depending on `Type`).
---@param Origin Vector3
---@param Direction Vector3
---@param List table|Instance
---@param Type number
function Util.FireRay(Origin: Vector3, Direction: Vector3, List: table|Instance, Type: number)
    local Params = RaycastParams.new()
    Params.FilterType = Type == 0 and Enum.RaycastFilterType.Whitelist or Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = type(List) == 'table' and List or {List};
    
    local Result = workspace:Raycast(Origin, Direction, Params);

    if (Result) then
        return Result.Instance, Result.Position, Result.Normal;
    end
end

--- Creates an AOE attack at CFrame `Origin`, with a radius of `Radius` (cube-hitbox).
---@param Player Player
---@param Origin CFrame
---@param Radius number
---@param Whitelist table|nil
---@param Settings table
function Util.AOEAttack(Player: Player, Origin: CFrame, Radius: number, Whitelist: table?, Settings: table, Callback: (Humanoid, Model, Player?) -> ())
    local Params = OverlapParams.new()
    Params.FilterDescendantsInstances = Whitelist or {};
    Params.FilterType = Enum.RaycastFilterType.Whitelist;

    table.insert(Params.FilterDescendantsInstances, workspace.Entities)

    local Parts: Array<BasePart> = workspace:GetPartBoundsInBox(Origin, Vector3.new(Radius, Radius, Radius), Params);

    local AffectedModels: table = setmetatable({}, {__mode = 'k'});

    local AffectMaxCount: number = Settings.MaxHits or 1;

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

--- Fires the communicator event with custom arguments.
---@param Player Player
function Util.FireClient(Player: Player, ...)
    ClientCommunicator:FireClient(Player, ...);
end

return Util;