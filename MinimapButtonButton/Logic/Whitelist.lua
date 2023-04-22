local _, addon = ...;

local format = _G.format;
local wipe = _G.wipe;

local Utils = addon.import('Core/Utils');
local Main = addon.import('Logic/Main');
local options = addon.import('Logic/Options').getAll();

local module = addon.export('Logic/Whitelist', {});

function module.addToWhitelist (buttonName)
  local button = Main.findButtonByName(buttonName);

  if (button == nil) then
    Utils.printAddonMessage(format('No frame named "%s" was found.', buttonName));
    return;
  end

  if (not Main.isValidFrame(button)) then
    Utils.printAddonMessage(format('"%s" is not a valid frame.', buttonName));
    return;
  end

  options.whitelist[buttonName] = true;
  Main.collectMinimapButtonsAndUpdateLayout();
  Utils.printAddonMessage(format('Button "%s" is now manually being collected.',
      buttonName));
end

function module.removeFromWhitelist (buttonName)
  if (options.whitelist[buttonName] == nil) then
    Utils.printAddonMessage(format('Button "%s" is not currently being manually collected.', buttonName));
    return;
  end

  options.whitelist[buttonName] = nil;
  Utils.printReloadMessage(format('Button "%s" is no longer being collected manually.',
      buttonName));
end

function module.clearWhitelist ()
  if (next(options.whitelist) == nil) then
    Utils.printAddonMessage('No buttons are currently being manually collected.');
    return;
  end

  wipe(options.whitelist);
  Utils.printReloadMessage('No more buttons are being manually collected.');
end
