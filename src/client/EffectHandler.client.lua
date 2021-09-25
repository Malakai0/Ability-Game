local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = game:GetService'ReplicatedStorage':WaitForChild('Effect')
local ForceRemote = game:GetService'ReplicatedStorage':WaitForChild'Force';

local Common = ReplicatedStorage:WaitForChild('Common');

local Effects = require(Common:WaitForChild('Effects'));

Remote.OnClientEvent:Connect(function(EffectName, Caller)
    local Effect = Effects.Functions[EffectName]
    if (Effect) then
        Effect(Caller)
    end
end)

ForceRemote.OnClientEvent:Connect(function(Force, Target)
    local Character = game:GetService('Players').LocalPlayer.Character;

    local Part = Target or (Character and Character.PrimaryPart);

    if (not Part) then return end;

    Part:ApplyImpulse(Force * (Target and 2 or 1));
end)