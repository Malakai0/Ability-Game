local ReplicatedStorage = game:GetService'ReplicatedStorage'
local Remotes = ReplicatedStorage:WaitForChild'Remotes';

local Communicator = Remotes:WaitForChild('ClientCommunication');

local Modules = ReplicatedStorage:WaitForChild'Modules';

local ClientFunctions = require(Modules:WaitForChild'ClientFunctions');

Communicator.OnClientEvent:Connect(function(Name, ...)
    local Function = ClientFunctions[Name]
    if (Function) then
        Function(...);
    end
end)