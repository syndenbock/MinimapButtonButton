local addonName, addon = ...;

local ADDON_MESSAGE_PREFIX = '|cff00ffff' .. addonName .. '|r' .. ': ';

local function printAddonMessage (message)
  print(ADDON_MESSAGE_PREFIX .. message);
end

local function printReloadMessage (message)
  printAddonMessage(message);
  print('This requires a /reload to take effect.');
end

local function getFrameName (frame)
  return frame.GetName and frame:GetName();
end

addon.printAddonMessage = printAddonMessage;
addon.printReloadMessage = printReloadMessage;
addon.getFrameName = getFrameName;
