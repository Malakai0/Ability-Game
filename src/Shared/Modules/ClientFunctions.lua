local ClientFunctions = {}

local ReplicatedStorage = game:GetService'ReplicatedStorage'
local Modules = ReplicatedStorage:WaitForChild'Modules';
local GUIHandler = ReplicatedStorage:WaitForChild('GUIHandler')

local Effects = require(Modules:WaitForChild('Effects'));
local GUIModule = require(GUIHandler:WaitForChild('GUI'));

function ClientFunctions.GUI(...)
    GUIModule.CreateGuiComponent(...);
end

function ClientFunctions.Effect(EffectName, State, Caller)
    local Effect = Effects.Functions[EffectName]
    if (Effect) then
        Effect[State == 1 and 'Enabled' or 'Disabled'](Caller)
    end
end

function ClientFunctions.Force(Force, Target)
    local Character = game:GetService('Players').LocalPlayer.Character;

    local Part = Target or (Character and Character.PrimaryPart);

    if (not Part) then return end;

    Part:ApplyImpulse(Force * (Target and 2 or 1));
end

return ClientFunctions