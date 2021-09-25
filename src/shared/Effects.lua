local Effects = {Functions = {}}

local Player = game:GetService('Players').LocalPlayer;

local Common = game:GetService("ReplicatedStorage"):WaitForChild("Common");

local CameraShaker = require(Common:WaitForChild('CameraShaker'))
local SharedMoves = require(Common:WaitForChild('SharedMoves'));

local LightningBoltModule = Common:WaitForChild("LightningBolt")
local LightningBolt = require(LightningBoltModule)
local LightningExplosion = require(LightningBoltModule:WaitForChild('LightningExplosion'));

local ShakerInstance = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
    workspace.CurrentCamera.CFrame *= shakeCFrame
end);ShakerInstance:Start()

local function Lerp(A, B, X)
    return (1 - X) * A + B * X;
end

local function FireRay(Origin, Direction, List, Type)
    local Params = RaycastParams.new()
    Params.FilterType = Type == 0 and Enum.RaycastFilterType.Whitelist or Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = type(List) == 'table' and List or {List};
    
    local Result = workspace:Raycast(Origin, Direction, Params);

    if (Result) then
        return Result.Instance, Result.Position, Result.Normal;
    end
end

local function DoNTimes(N: number, Function)
    for _ = 1, N do
        task.spawn(Function);
    end
end

local EMPTY_FUNCTION = function() end; --// One reference to an empty function, saves memory.

local function CreateFX(Name, Enabled, Disabled)
    Effects.Functions[Name] = {Enabled = Enabled or EMPTY_FUNCTION; Disabled = Disabled or EMPTY_FUNCTION}
end

CreateFX('InstantaneousLightningBolt', function(TargetPlayer)
    local Color = Color3.new(1,1,1);

    local Character = TargetPlayer.Character;
    local PrimaryPart = Character and Character.PrimaryPart;
    
    if (not PrimaryPart) then return end;

    local RayOrigin = PrimaryPart.Position;
    local RayDirection = Vector3.new(0, -100, 0);

    local _, Position = FireRay(RayOrigin, RayDirection, {workspace.Entities}, 1); --// 0: whitelist, 1: blacklist

    if (not Position) then return end;

    local A0, A1 = {}, {};

    local P0, P1 = RayOrigin + Vector3.new(0, 100, 0), Position;

    local A0Look = (P1 - P0).Unit;

    A0.WorldPosition, A1.WorldPosition = P0, P1;
    A0.WorldAxis, A1.WorldAxis = A0Look, -A0Look;

    local TIME_TO_HIT_GROUND = SharedMoves.InstantaneousLightningBolt.Environment.TIME_FOR_BOLT;

    DoNTimes(3, function()
        local Bolt = LightningBolt.new(A0, A1, 30)

        Bolt.Color = Color;
        Bolt.MaxRadius = 10
        Bolt.Frequency = 2
        Bolt.PulseSpeed = 1 / (TIME_TO_HIT_GROUND)

        Bolt.Enabled = true;

        task.delay(.3, function()
            Bolt:DestroyDissipate(.1, .1)
            task.wait(.15)
            Bolt = nil;

            A0, A1 = nil, nil;
        end)
    end)

    task.delay(TIME_TO_HIT_GROUND, function()
        LightningExplosion.new(A1.WorldPosition, .5, 14, Color, Color)
        
        if (Player:DistanceFromCharacter(P1) <= 30) then
            ShakerInstance:ShakeOnce(10, 100, 0, .5)
        end
    end)
end)

return Effects