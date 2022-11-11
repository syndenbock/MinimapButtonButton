local _, addon = ...;

local Utils = addon.import('Core/Utils');
local Settings = addon.import('Logic/Settings');

local strlower = _G.strlower;
local format = _G.format;

local function printSettingValue (setting, value)
  Utils.printAddonMessage(format('Current value of setting %s is %s', setting, value));
end

local function printSettingWasSet (setting, value)
  Utils.printAddonMessage(format('setting %s was set to %s', setting, value));
end

local function printInvalidSettingValue (setting, value)
  Utils.printAddonMessage(format('%s is not a valid value for setting %s', value, setting));
end

addon.import('Core/SlashCommands').addCommand('set', function (setting, value)
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
    printSettingValue(setting, Settings.getSetting(lowerCaseSetting));
  else
    if (Settings.setSetting(lowerCaseSetting, value)) then
      printSettingWasSet(setting, value);
    else
      printInvalidSettingValue(setting, value);
    end
  end
end);
