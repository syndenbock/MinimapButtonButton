local _, addon = ...;

local strjoin = _G.strjoin;
local strlower = _G.strlower;
local format = _G.format;

local Utils = addon.import('Core/Utils');
local SlashCommands = addon.import('Core/SlashCommands');
local HelpCommands = addon.import('Core/HelpCommands');
local Whitelist = addon.import('Logic/Whitelist');
local Blacklist = addon.import('Logic/Blacklist');
local Settings = addon.import('Settings/Settings');

SlashCommands.addCommand('set', function (setting, value)
  if (setting == nil) then
    Utils.printAddonMessage('The available settings are:');
    Settings.printAvailableSettings();
    return;
  end

  local lowerCaseSetting = strlower(setting);

  if (Settings.isSettingUnavailable(setting)) then
    Utils.printAddonMessage(Settings.getSettingUnavailableReason(setting));
    return;
  end

  if (not Settings.doesSettingExist(lowerCaseSetting)) then
    Utils.printAddonMessage('Unknown setting: ', setting);
    return;
  end

  if (value == nil) then
    Utils.printAddonMessage(format('Current value of setting %s is %s', setting, Settings.getSetting(lowerCaseSetting)));
  else
    local status = Settings.setSetting(lowerCaseSetting, value);

    if (status == true) then
      Utils.printAddonMessage(format('setting %s was set to %s', setting, value));
    elseif (status == false) then
      Utils.printAddonMessage(format('%s is not a valid value for setting %s', value, setting));
    else
      error('Invalid getter status: ' .. status);
    end
  end
end);

HelpCommands.addHelper('set', function (setting)
  if (setting == nil) then
    Utils.printAddonMessage(strjoin(' ',
        'This command allows you to change the value of a setting by typing the name of the setting followed by its value.',
        'If you don\'t specify a value, the current value will be printed.',
        'The available settings are:'
    ));
    Settings.printAvailableSettings();
    return;
  end

  local help = Settings.getHelp(setting);

  if (help == nil) then
    Utils.printAddonMessage(format('Unknown setting: %s.\nHelp is available for these settings:', setting));
    Settings.printAvailableSettings();
    return;
  end

  Utils.printAddonMessage(help);
end);

SlashCommands.addCommand({'include', 'unignore'}, function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);
  local button, path = Whitelist.findButton(buttonName);

  Blacklist.removeFromBlacklist(path or buttonName);

  if (button ~= nil) then
    Whitelist.addToWhitelist(path);
  end
end);

HelpCommands.addHelper({'include', 'unignore'}, strjoin(' ',
    'This command adds a button with the name passed to the command to be manually collected.',
    'If the button was previously ignored, it will be removed from the ignore list.'
));

SlashCommands.addCommand({'ignore', 'uninclude'}, function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);
  local button, path = Blacklist.findButton(buttonName);

  Whitelist.removeFromWhitelist(path or buttonName);

  if (button ~= nil) then
    Blacklist.addToBlacklist(buttonName);
  end
end);

HelpCommands.addHelper({'ignore', 'uninclude'}, strjoin(' ',
  'This command stops a button with the name passed to the command from being collected.',
  'This requires a "/reload" to take effect.'
));

SlashCommands.addCommand({'includeall', 'unignoreall'}, Blacklist.clearBlacklist);
HelpCommands.addHelper({'includeall', 'unignoreall'}, 'This command causes all buttons that are being ignored to be collected again.');

SlashCommands.addCommand({'ignoreall', 'unincludeall'}, Whitelist.clearWhitelist);
HelpCommands.addHelper({'ignoreall', 'unincludeall'}, 'This command causes all buttons that have manually been marked for collection to no longer be collected.');
