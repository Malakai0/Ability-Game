local GuiService = game:GetService("GuiService")
local GUI = {Components = {}}

local ComponentFolder: Folder = script.Parent.GUIComponents;

for _,V in next, ComponentFolder:GetChildren() do
    if (not V:IsA('ModuleScript')) then
        warn('Invalid GUI component "' .. V.Name .. '".')
        continue
    end

    local Component = require(V)

    if (not Component.Name) then
        warn('GUI component missing "' .. V.Name .. '" missing name property.')
        continue;
    end

    if (type(Component.Create) ~= 'function') then
        warn('GUI component "' .. Component.Name .. '" missing Create function.')
        continue;
    end

    GUI.Components[Component.Name] = Component;
end

function GUI.CreateGuiComponent(Name, ...)
    if (not GUI.Components[Name]) then
        return error('Tried to create GUI component "' .. Name .. '", but it does not exist.', 2)
    end

    return GUI.Components[Name].Create(...);
end

return GUI;