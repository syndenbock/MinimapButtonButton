local addonName, addon = ...;

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
    buttonsPerRow = 10,
  };

  if (type(options) ~= type(defaults)) then
    return defaults;
  end

  for setting, value in pairs(defaults) do
    if (type(options[setting]) ~= type(value)) then
      options[setting] = value;
    end
  end

  return options;
end

addon.registerEvent('ADDON_LOADED', function (loadedAddon)
  if (loadedAddon ~= addonName) then
    return;
  end

  local options = setDefaultValues(_G.MinimapButtonButtonOptions);

  migrateOptions(options);

  addon.registerEvent('PLAYER_LOGOUT', function ()
    _G.MinimapButtonButtonOptions = options;
  end);

  addon.options = options;

  return true;
end);
