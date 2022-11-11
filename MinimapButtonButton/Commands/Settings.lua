local _, addon = ...;

local Settings = addon['Logic/Settings'];

local strlower = _G.strlower;
local format = _G.format;

local function printSettingValue (setting, value)
  addon.printAddonMessage(format('Current value of setting %s is %s', setting, value));
end

local function printSettingWasSet (setting, value)
  addon.printAddonMessage(format('setting %s was set to %s', setting, value));
end

local function printInvalidSettingValue (setting, value)
  addon.printAddonMessage(format('%s is not a valid value for setting %s', value, setting));
end

addon.slash('set', function (setting, value)
  if (setting == nil) then
    addon.printAddonMessage('Available settings:');
    Settings.printAvailableSettings();
    return;
  end

  local lowerCaseSetting = strlower(setting);

  if (not Settings.doesSettingExist(lowerCaseSetting)) then
    addon.printAddonMessage('unknown setting: ', setting);
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
