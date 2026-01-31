local _, addon = ...;

local format = _G.format;
local strlower = _G.strlower;
local wipe = _G.wipe;

local Utils = addon.import('Core/Utils');
local Main = addon.import('Logic/Main');
local options = addon.import('Logic/Options').getAll();

local module = addon.export('Logic/Whitelist', {});

local function findButtonPathInWhitelist (path)
  path = strlower(path);

  for key in pairs(options.whitelist) do
    if (strlower(key) == path) then
      return key;
    end
  end

  return nil;
end

function module.isButtonWhitelisted (path)
  return (findButtonPathInWhitelist(path) ~= nil);
end

function module.addToWhitelist (path)
  options.whitelist[path] = true;
  Main.collectMinimapButtonsAndUpdateLayout();
  Utils.printAddonMessage(format('Button "%s" is now manually being collected.', path));
end

function module.removeFromWhitelist (path)
  if (options.whitelist[path] == nil) then
    Utils.printAddonMessage(format('Button "%s" is not currently being manually collected.', path));
    return;
  end

  options.whitelist[path] = nil;
  Utils.printReloadMessage(format('Button "%s" is no longer being collected manually.', path));
end

function module.removeFromWhitelistCaseInsensitive (path)
  local matchingPath = findButtonPathInWhitelist(path);

  if (matchingPath == nil) then
    Utils.printAddonMessage(format('Button "%s" is not currently being manually collected.', path));
    return;
  end

  options.whitelist[matchingPath] = nil;
  Utils.printReloadMessage(format('Button "%s" is no longer being collected manually.', path));
end

function module.clearWhitelist ()
  if (next(options.whitelist) == nil) then
    Utils.printAddonMessage('No buttons are currently being manually collected.');
    return;
  end

  wipe(options.whitelist);
  Utils.printReloadMessage('No more buttons are being manually collected.');
end
