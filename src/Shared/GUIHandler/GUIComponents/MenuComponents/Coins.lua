local CollectionService = game:GetService("CollectionService")
local Coins = {}
Coins.__index = Coins;

function Coins.new(Label: TextLabel)
    local self = {
        Label = Label;
    }

    setmetatable(self, Coins)

    return self;
end

function Coins:Update(Data: table)
    self.Label.Text = string.format('Coins: %s', Data.Stats.Coins)
end

return Coins