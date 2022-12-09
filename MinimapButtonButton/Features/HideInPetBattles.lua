local _, addon = ...;

if (not addon.import('Core/Utils').isRetail()) then return end

local Events = addon.import('Core/Events');
local mainButton = addon.import('Logic/Main').mainButton;

Events.registerEvent('PET_BATTLE_OPENING_START', function ()
  mainButton:Hide();
end);

Events.registerEvent('PET_BATTLE_CLOSE', function ()
  mainButton:Show();
end);
