local _, addon = ...;

local format = _G.format;

local Utils = addon.import('Core/Utils');
local SlashCommandHandler = addon.import('Core/SlashCommands');
local Main = addon.import('Logic/Main');
local options = addon.import('Logic/Options').getAll();

local module = addon.export('Logic/Blacklist', {});

function module.isButtonBlacklisted (frame)
  local frameName = Utils.getFrameName(frame);

  return (frameName ~= nil and
      options.blacklist[frameName] == true);
end

SlashCommandHandler.addCommand('ignore', function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);

  if (_G[buttonName] == nil) then
    Utils.printAddonMessage(format('No frame named "%s" was found.', buttonName));
    return;
  end

  options.blacklist[buttonName] = true;
  Utils.printReloadMessage(format('Button "%s" is now being ignored.', buttonName));
end);

SlashCommandHandler.addCommand('unignore', function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);

  if (options.blacklist[buttonName] == nil) then
    Utils.printAddonMessage(format('Button "%s" is not being ignored.', buttonName));
    return;
  end

  options.blacklist[buttonName] = nil;
  Main.collectMinimapButtonsAndUpdateLayout();

  Utils.printAddonMessage(format('Button "%s" is no longer being ignored.',
      buttonName));
end);

SlashCommandHandler.addCommand('unignoreall', function ()
  if (next(options.blacklist) == nil) then
    Utils.printAddonMessage('No buttons are currently being ignored.');
    return;
  end

  options.blacklist = {};
  Utils.printReloadMessage('No more buttons are being ignored.');
end);
