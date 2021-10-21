local Util = require(game:GetService('ServerStorage').ServerModules.Util);

local function Lerp(A: number, B: number, X: number): number
    return (1 - X) * A + B * X;
end

local function Explode(Player: Player, Data: table): nil
    local Size = 15 * 1.4; --// Idk why they set it to this, just what it is.

    local Primary: BasePart = Player.Character and Player.Character.PrimaryPart;

    if (not Primary) then return end; --// da frick

    local RayOrigin: CFrame = Primary.CFrame;
    local RayDirection: Vector3 = Vector3.new(0, -100000, 0);

    local _, Position: Vector3 = Util.FireRay(RayOrigin.Position, RayDirection, {workspace.Entities}, 1);

    if (not Position) then return end;

    if (math.abs((Position.Y - RayOrigin.Position.Y)) >= 30) then
        Position = RayOrigin.Position + Vector3.new(0, -3, 0);
    end

    local HitCFrame = CFrame.new(Position);
    Position = nil;

    task.wait(Data.TIME_FOR_BOLT)

    Util.AOEAttack(Player, HitCFrame, Size, {}, {MaxHits = 1}, function(Humanoid: Humanoid, Model: Model, TargetPlayer: Player?)
        Humanoid:TakeDamage(20)

        local Recipient: BasePart = Model.PrimaryPart;
        if (Recipient) then
            local ExtraForce: Vector3 = Vector3.new(25, 30, 25)
            local Distance: Vector3 = (HitCFrame.Position - Recipient.Position);

            local InverseDistance: number = 1 - (Distance.Magnitude / (Size / 2));
            local AppliedForce: number = Lerp(ExtraForce * .8, ExtraForce, InverseDistance);

            local Direction: Vector3 = (Distance.Unit * AppliedForce) * 90

            if (TargetPlayer) then
                Util.ApplyForce(TargetPlayer, -Direction)
            else --// NPC
                Recipient:SetNetworkOwner(Player)

                Util.ApplyForce(Player, -Direction, Recipient) --// Player controls their physics.

                task.delay(4, function()
                    Recipient:SetNetworkOwnershipAuto();
                end)
            end
        end
    end)
end

return {
    Move = 'LightningStrike';

    Enabled = function(self, Data, Player)
        Util.PlayEffectFromPlayer(Player, self.Move, 'Enabled');
        task.spawn(Explode, Player, Data);
    end;
}