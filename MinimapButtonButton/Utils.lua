local addonName, addon = ...;

local function printAddonMessage (message)
  print(addonName .. ': ' .. message);
end

local function printReloadMessage (message)
  printAddonMessage(message .. '\nThis requires a /reload to take effect.');
end

local function getFrameName (frame)
  return frame.GetName and frame:GetName();
end

addon.printAddonMessage = printAddonMessage;
addon.printReloadMessage = printReloadMessage;
addon.getFrameName = getFrameName;
