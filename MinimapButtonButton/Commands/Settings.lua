local _, addon = ...;

local Utils = addon.import('Core/Utils');
local Settings = addon.import('Logic/Settings');
local Whitelist = addon.import('Logic/Whitelist');
local Blacklist = addon.import('Logic/Blacklist');
local SlashCommands = addon.import('Core/SlashCommands');

local strlower = _G.strlower;
local format = _G.format;
local tostring = _G.tostring;

local function printSettingValue (setting, value)
  Utils.printAddonMessage(format('Current value of setting %s is %s', setting, value));
end

local function printSettingWasSet (setting, value)
  Utils.printAddonMessage(format('setting %s was set to %s', setting, value));
end

local function printInvalidSettingValue (setting, value)
  Utils.printAddonMessage(format('%s is not a valid value for setting %s', value, setting));
end

SlashCommands.addCommand('set', function (setting, value)
  if (setting == nil) then
    Utils.printAddonMessage('Available settings:');
    Settings.printAvailableSettings();
    return;
  end

  local lowerCaseSetting = strlower(setting);

  if (not Settings.doesSettingExist(lowerCaseSetting)) then
    Utils.printAddonMessage('unknown setting: ', setting);
    return;
  end

  if (value == nil) then
    printSettingValue(setting, tostring(Settings.getSetting(lowerCaseSetting)));
  else
    if (Settings.setSetting(lowerCaseSetting, value)) then
      printSettingWasSet(setting, value);
    else
      printInvalidSettingValue(setting, value);
    end
  end
end);

SlashCommands.addCommand({'include', 'unignore'}, function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);

  Blacklist.removeFromBlacklist(buttonName);
  Whitelist.addToWhitelist(buttonName);
end);

SlashCommands.addCommand({'ignore', 'uninclude'}, function (...)
  if (... == nil) then
    Utils.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = Utils.concatButtonName(...);

  Whitelist.removeFromWhitelist(buttonName);
  Blacklist.addToBlacklist(buttonName);
end);

SlashCommands.addCommand({'includeall', 'unignoreall'}, Blacklist.clearBlacklist);
SlashCommands.addCommand({'ignoreall', 'unincludeall'}, Whitelist.clearWhitelist);
