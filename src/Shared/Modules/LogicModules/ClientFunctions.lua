local ClientFunctions = {}

local ReplicatedStorage = game:GetService'ReplicatedStorage'
local Modules = ReplicatedStorage:WaitForChild'Modules';
local GUIHandler = ReplicatedStorage:WaitForChild('GUIHandler')

local Effects = require(Modules:WaitForChild('VisualModules'):WaitForChild('Effects'));
local GUIModule = require(GUIHandler:WaitForChild('GUI'));

local function ApplyLocalCooldown(CooldownKey, Length)
    table.insert(shared.LocalCooldown, CooldownKey)

    task.delay(Length, function()
        table.remove(shared.LocalCooldown, table.find(shared.LocalCooldown, CooldownKey));
    end)
end

function ClientFunctions.ApplyLocalCooldown(CooldownKey, Length)
    task.spawn(ApplyLocalCooldown, CooldownKey .. '1', Length)
    task.spawn(ApplyLocalCooldown, CooldownKey .. '0', Length)
end

function ClientFunctions.GUI(...)
    return GUIModule.CreateGuiComponent(...);
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