local Util = require(script.Parent.Parent.Util);

local function Lerp(A, B, X)
    return (1 - X) * A + B * X;
end

local function Explode(Player)
    local Size = 15 * 1.4; --// Idk why they set it to this, just what it is.

    local Primary = Player.Character and Player.Character.PrimaryPart;

    if (not Primary) then return end; --// da frick

    local RayOrigin = Primary.CFrame;
    local RayDirection = Vector3.new(0, -100000, 0);

    local _, Position = Util.FireRay(RayOrigin.Position, RayDirection, {workspace.Entities}, 1);

    if (not Position) then return end;

    if ((Position - RayOrigin.Position).Magnitude >= 10) then
        Position = RayOrigin.Position + Vector3.new(0, -3, 0);
    end

    local P1 = CFrame.new(Position);
    Position = nil;

    Util.AOEAttack(Player, P1, Size, {}, {MaxHits = 1}, function(Humanoid: Humanoid, Model: Model, TargetPlayer: Player?)
        Humanoid:TakeDamage(20)

        local PrimaryPart = Model.PrimaryPart;
        if (PrimaryPart) then
            local ExtraForce = Vector3.new(25, 30, 25)

            local Distance = (P1.Position - PrimaryPart.Position);
            local InverseDistance = 1 - (Distance.Magnitude / (Size / 2));

            local AppliedForce = Lerp(ExtraForce * .8, ExtraForce, InverseDistance);

            local Direction = (Distance.Unit * AppliedForce) * 90

            if (TargetPlayer) then
                Util.ApplyForce(TargetPlayer, -Direction)
            else --// NPC
                PrimaryPart:SetNetworkOwner(Player)

                Util.ApplyForce(Player, -Direction, PrimaryPart) --// Player controls their physics.

                task.delay(4, function()
                    PrimaryPart:SetNetworkOwnershipAuto();
                end)
            end
        end
    end)
end

return {
    Move = 'InstantaneousLightningBolt';

    Enabled = function(self, Data, Player)
        Util.PlayEffectFromPlayer(Player, self.Move, 'Enabled');

        task.delay(Data.TIME_FOR_BOLT, Explode, Player);
    end;
}