local addonName, addon = ...;

local VERSION_COUNTER = 1;

local function migrateOptions (options)
  if (options.collectCovenantButton ~= nil) then
    if (options.collectCovenantButton == true) then
      options.whitelist['GarrisonLandingPageMinimapButton'] = true;
    end

    options.collectCovenantButton = nil;
  end
end

local function setDefaultValues (options)
  local defaults = {
    blacklist = {},
    whitelist = {
      ZygorGuidesViewerMapIcon = true,
      TrinketMenu_IconFrame = true,
      CodexBrowserIcon = true,
    },
    majorDirection = addon.constants.directions.LEFT,
    minorDirection = addon.constants.directions.DOWN,
    buttonsPerRow = 5,
    scale = 1,
    version = 0,
  };

  if (type(options) ~= type(defaults)) then
    defaults.version = VERSION_COUNTER;
    return defaults;
  end

  for setting, value in pairs(defaults) do
    if (type(options[setting]) ~= type(value)) then
      options[setting] = value;
    end
  end

  return options;
end

local function printVersionMessage ()
  addon.printAddonMessage('has some new settings!\n',
      'Type "/mbb set" to see available settings\n',
      '"/mbb set <setting>" to see the current value of a setting or\n',
      '"/mbb set <setting> <value>" to set a setting');
end

local function checkVersion (options)
  if (options.version >= VERSION_COUNTER) then
    --[[ setting version to handle rollbacks ]]
    options.version = VERSION_COUNTER;
    return;
  end

  options.version = VERSION_COUNTER;
  printVersionMessage();
end

addon.registerEvent('ADDON_LOADED', function (loadedAddon)
  if (loadedAddon ~= addonName) then
    return;
  end

  local options = setDefaultValues(_G.MinimapButtonButtonOptions);

  migrateOptions(options);
  checkVersion(options);

  addon.registerEvent('PLAYER_LOGOUT', function ()
    _G.MinimapButtonButtonOptions = options;
  end);

  addon.options = options;

  return true;
end);
