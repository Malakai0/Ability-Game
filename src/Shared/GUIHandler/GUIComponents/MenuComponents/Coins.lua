local DataHandler = require(game:GetService('ReplicatedStorage'):WaitForChild('Modules'):WaitForChild('DataModules'):WaitForChild('DataHandler'));

local Coins = {}
Coins.__index = Coins;

function Coins.new(Label: TextLabel)
    local self = {
        GUIObject = Label;
    }

    setmetatable(self, Coins)

    return self;
end

function Coins:Update(Data: DataHandler.PlayerData, Elements: table)
    self.GUIObject.Text = string.format('Coins: %s', Data.Stats.Coins)
end

return Coins