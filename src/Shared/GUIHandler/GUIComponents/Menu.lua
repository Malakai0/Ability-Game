local Menu = {Name = 'Menu'};

local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Player = game:GetService('Players').LocalPlayer;

local DataHandler = require(ReplicatedStorage:WaitForChild('Modules'):WaitForChild('DataModules'):WaitForChild('DataHandler'));

local MenuComponents = script.Parent.MenuComponents;

function Menu.Create(MenuScreen: ScreenGui)
    local Elements = {
        Coins = require(MenuComponents.Coins).new(MenuScreen.Coins);
    }

    local Updater; do
        local LastUpdated = 0;
        Updater = game:GetService('RunService').Heartbeat:Connect(function()
            if (tick() - LastUpdated <= 0.2) then
                return;
            end
            LastUpdated = tick();

            local Data: DataHandler.PlayerData = DataHandler.Shared.GetDataForPlayer(Player);

            for Name, Component in next, Elements do
                local Success, Error = pcall(function()
                    Component:Update(Data, Elements)
                end)

                if (not Success) then
                    warn(Name .. ' errored.')
                    warn(Error);
                end
            end
        end)
    end

    return Updater;
end

return Menu