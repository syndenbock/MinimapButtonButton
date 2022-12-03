local _, addon = ...;

local format = _G.format;

local Utils = addon.import('Core/Utils');
local Main = addon.import('Logic/Main');
local SlashCommandHandler = addon.import('Core/SlashCommands');
local options = addon.import('Logic/Options').getAll();

SlashCommandHandler.addCommand('include', function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);
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
end);

SlashCommandHandler.addCommand('uninclude', function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);

  if (options.whitelist[buttonName] == nil) then
    Utils.printAddonMessage(format(
        'No button named "%s" is currently being manually collected.', buttonName));
    return;
  end

  options.whitelist[buttonName] = nil;
  Utils.printReloadMessage(format('Button "%s" is no longer being collected manually.',
      buttonName));
end);

SlashCommandHandler.addCommand('unincludeall', function ()
  if (next(options.whitelist) == nil) then
    Utils.printAddonMessage('No buttons are currently being manually collected.');
    return;
  end

  options.whitelist = {};
  Utils.printReloadMessage('No more buttons are being manually collected.');
end);
