local addonName, addon = ...;

local tconcat = _G.table.concat;

local ADDON_MESSAGE_PREFIX = '|cff00ffff' .. addonName .. '|r';

local function printAddonMessage (...)
  print(ADDON_MESSAGE_PREFIX, ...);
end

local function printReloadMessage (...)
  printAddonMessage(...);
  print('This requires a /reload to take effect.');
end

local function getFrameName (frame)
  return frame.GetName and frame:GetName();
end

local function concatButtonName (...)
  return tconcat({...}, ' ');
end

addon.printAddonMessage = printAddonMessage;
addon.printReloadMessage = printReloadMessage;
addon.getFrameName = getFrameName;
addon.concatButtonName = concatButtonName;
