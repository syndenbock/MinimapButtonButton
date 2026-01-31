local _, addon = ...;

local format = _G.format;
local strlower = _G.strlower;
local wipe = _G.wipe;

local Utils = addon.import('Core/Utils');
local Main = addon.import('Logic/Main');
local options = addon.import('Logic/Options').getAll();

local module = addon.export('Logic/Blacklist', {});

local function findButtonNameInBlacklist (buttonName)
  buttonName = strlower(buttonName);

  for key in pairs(options.blacklist) do
    if (strlower(key) == buttonName) then
      return key;
    end
  end

  return nil;
end

function module.isButtonBlacklisted (frame)
  local frameName = Utils.getFrameName(frame);

  return (frameName ~= nil and options.blacklist[frameName] ~= nil);
end

function module.addToBlacklist (buttonName)
  options.blacklist[buttonName] = true;
  Utils.printReloadMessage(format('Button "%s" is now being ignored.', buttonName));
end

function module.removeFromBlacklist (buttonName)
  if (options.blacklist[buttonName] == nil) then
    Utils.printAddonMessage(format('Button "%s" is not currently being ignored.', buttonName));
    return;
  end

  options.blacklist[buttonName] = nil;
  Main.collectMinimapButtonsAndUpdateLayout();

  Utils.printAddonMessage(format('Button "%s" is no longer being ignored.', buttonName));
end

function module.removeFromBlackListCaseInsensitive (buttonName)
  local matchingButtonName = findButtonNameInBlacklist(buttonName);

  if (matchingButtonName == nil) then
    Utils.printAddonMessage(format('Button "%s" is not currently being ignored.', buttonName));
    return;
  end

  options.blacklist[matchingButtonName] = nil;
  Main.collectMinimapButtonsAndUpdateLayout();

  Utils.printAddonMessage(format('Button "%s" is no longer being ignored.', buttonName));
end

function module.clearBlacklist ()
  if (next(options.blacklist) == nil) then
    Utils.printAddonMessage('No buttons are currently being ignored.');
    return;
  end

  wipe(options.blacklist);
  Main.collectMinimapButtonsAndUpdateLayout();
  Utils.printAddonMessage('No more buttons are being ignored.');
end
