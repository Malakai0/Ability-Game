local Players = game:GetService('Players');
local ReplicatedStorage = game:GetService('ReplicatedStorage');

local Player = Players.LocalPlayer;
local PlayerGui = Player:WaitForChild('PlayerGui')

local GUI = require(ReplicatedStorage:WaitForChild('GUIHandler'):WaitForChild('GUI'));

local Menu = PlayerGui:WaitForChild('Menu')

GUI.CreateGuiComponent('Menu', Menu)