local _, addon = ...;

if (not C_EventUtils or
    not C_EventUtils.IsEventValid("PET_BATTLE_OPENING_START") or
    not C_EventUtils.IsEventValid("PET_BATTLE_CLOSE")) then
  return;
end

local Events = addon.import('Core/Events');
local mainButton = addon.import('Logic/Main').mainButton;

Events.registerEvent('PET_BATTLE_OPENING_START', function ()
  mainButton:Hide();
end);

Events.registerEvent('PET_BATTLE_CLOSE', function ()
  mainButton:Show();
end);
