local Cooldown = {Name = 'Cooldown'};

local Player = game:GetService'Players'.LocalPlayer;

local Prefab = game:GetService'ReplicatedStorage':WaitForChild('GUIPrefabs'):WaitForChild('Cooldown');

function Cooldown.Create(Move: string, Key: string, Length: number?)
    local PlayerGui = Player:WaitForChild'PlayerGui';
    local CooldownScreen = PlayerGui:WaitForChild'Cooldown';

    local CooldownGui = Prefab:Clone();
    CooldownGui.Name = Move;
    CooldownGui.MoveName.Text = Move;
    CooldownGui.Key.Text = tostring(Key);

    CooldownGui.Parent = CooldownScreen.List;

    CooldownGui.Bar.Size = UDim2.new(1, 0, 1, 0)
    CooldownGui.Bar:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, Length)

    game:GetService('Debris'):AddItem(CooldownGui, Length);
end

return Cooldown;