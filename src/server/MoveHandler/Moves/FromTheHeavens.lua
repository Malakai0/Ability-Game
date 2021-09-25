local EffectHandler = require(script.Parent.Parent.EffectHandler);

local function Lerp(A, B, X)
    return (1 - X) * A + B * X;
end

local function Explode(Player)
    local Size = 15 * 1.4; --// Idk why they set it to this, just what it is.

    local Params = OverlapParams.new()
    Params.FilterDescendantsInstances = {workspace.Entities}
    Params.FilterType = Enum.RaycastFilterType.Whitelist;

    local Primary = Player.Character and Player.Character.PrimaryPart;
    local P1 = Primary and Primary.CFrame * CFrame.new(0, -3, 0);

    if (not Primary) then return end; --// da frick
    
    local Parts = workspace:GetPartBoundsInBox(P1, Vector3.new(Size, Size, Size), Params);

    local AffectedModels = setmetatable({}, {__mode = 'k'});

    for _, Part: BasePart in next, Parts do
        local Model = Part:FindFirstAncestorOfClass('Model')
        local Humanoid = Model and Model:FindFirstChild('Humanoid')
        if ((Model and AffectedModels[Model]) or (not Model) or (not Humanoid)) then
            continue
        end

        local TargetPlayer = game:GetService('Players'):GetPlayerFromCharacter(Model)

        if (TargetPlayer and TargetPlayer == Player) then
            continue
        end

        AffectedModels[Model] = true;
        Humanoid:TakeDamage(20)

        local PrimaryPart = Model.PrimaryPart;
        if (PrimaryPart) then
            local ExtraForce = Vector3.new(25, 30, 25)

            local Distance = (P1.Position - PrimaryPart.Position);
            local InverseDistance = 1 - (Distance.Magnitude / (Size / 2));

            local AppliedForce = Lerp(ExtraForce * .5, ExtraForce, InverseDistance);

            local Direction = (Distance.Unit * AppliedForce) * 100

            if (TargetPlayer) then
                EffectHandler.ApplyForce(TargetPlayer, -Direction)
            else
                PrimaryPart:SetNetworkOwner(Player)

                EffectHandler.ApplyForce(Player, -Direction, PrimaryPart)

                task.delay(4, function()
                    PrimaryPart:SetNetworkOwnershipAuto();
                end)
            end
        end
    end

    AffectedModels = nil;
end

return {
    Move = 'InstantaneousLightningBolt';

    Enabled = function(self, Data, Player)
        EffectHandler.PlayEffectFromPlayer(Player, self.Move, 'Enabled');

        task.delay(Data.TIME_FOR_BOLT, Explode, Player);

        task.wait(Data.MOVE_LENGTH);
    end;
}