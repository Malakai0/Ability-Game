return {
    Move = 'Barrage';

    Enabled = function(self, Data, Player)
        Player.Character.Humanoid.WalkSpeed = 9;
    end;

    Disabled = function(self, Data, Player)
        Player.Character.Humanoid.WalkSpeed = 16;
    end;
}