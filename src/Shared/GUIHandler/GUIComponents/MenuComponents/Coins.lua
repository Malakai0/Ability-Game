local CollectionService = game:GetService("CollectionService")
local Coins = {}
Coins.__index = Coins;

function Coins.new(Label: TextLabel)
    local self = {
        GUIObject = Label;
    }

    setmetatable(self, Coins)

    return self;
end

function Coins:Update(Data: table, Elements: table)
    self.GUIObject.Text = string.format('Coins: %s', Data.Stats.Coins)
end

return Coins