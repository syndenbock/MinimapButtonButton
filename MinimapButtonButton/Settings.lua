local _, addon = ...;

local strlower = _G.strlower;
local format = _G.format;

local handlers = {};

local function printSettingValue (setting, value)
  addon.printAddonMessage(format('Current value of setting %s is %s', setting, value));
end

local function printInvalidSettingValue (setting, value)
  addon.printAddonMessage(format('%s is no valid value for setting %s', value, setting));
end

local function printSettingWasSet (setting, value)
  addon.printAddonMessage(format('setting %s was set to %s', setting, value));
end

local function getValidDirections ()
  local directions = addon.constants.directions;

  return {
    leftdown = {
      major = directions.LEFT,
      minor = directions.DOWN,
    },
    leftup = {
        major = directions.LEFT,
        minor = directions.UP,
    },
    rightdown = {
      major = directions.RIGHT,
      minor = directions.DOWN,
    },
    rightup = {
      major = directions.RIGHT,
      minor = directions.UP,
    },
    upleft = {
      major = directions.UP,
      minor = directions.LEFT,
    },
    upright = {
      major = directions.UP,
      minor = directions.RIGHT,
    },
    downleft = {
      major = directions.DOWN,
      minor = directions.LEFT,
    },
    downright = {
      major = directions.DOWN,
      minor = directions.RIGHT,
    },
  };
end

function handlers.direction (setting, value)
  if (value == nil) then
    return printSettingValue(setting,
        addon.options.majorDirection .. addon.options.minorDirection);
  end

  local direction = strlower(value);
  local directions = getValidDirections()[direction];

  if (directions == nil) then
    return printInvalidSettingValue(setting, value);
  end

  addon.options.majorDirection = directions.major;
  addon.options.minorDirection = directions.minor;

  if (addon.shared.buttonContainer:IsShown()) then
    addon.updateLayout();
  end

  printSettingWasSet(setting, value);
end

local function printAvailableSettings ()
  addon.printAddonMessage('Available settings:');

  for setting in pairs(handlers) do
    print(setting);
  end
end

addon.slash('set', function (setting, ...)
  if (setting == nil) then
    return printAvailableSettings();
  end

  local lowerCaseSetting = strlower(setting);

  if (handlers[lowerCaseSetting] == nil) then
    addon.printAddonMessage('unkown setting:', setting);
    return;
  end

  handlers[setting](setting, ...);
end);
