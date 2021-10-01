local Server = {};

for _, Component in next, script.Systems:GetChildren() do
    if (not Component:IsA('ModuleScript')) then continue end;

    local Value = require(Component);

    if (type(Value) == 'table' and rawget(Value, 'Init')) then
        Value.Init(Server);
    end

    Server[Component.Name] = Value;
end

for _, Component in next, Server do
    if (type(Component) == 'table' and rawget(Component, 'Start')) then
        Component.Start(Server);
    end
end