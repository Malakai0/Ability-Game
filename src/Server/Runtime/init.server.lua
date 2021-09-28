local Server = {};

for I,V in next, script.Systems:GetChildren() do
    if (not V:IsA('ModuleScript')) then continue end;

    local Value = require(V);

    if (type(Value) == 'table' and rawget(Value, 'Init')) then
        Value.Init();
    end

    Server[V.Name] = Value;
end

for I,V in next, Server do
    if (type(V) == 'table' and rawget(V, 'Start')) then
        V.Start();
    end
end