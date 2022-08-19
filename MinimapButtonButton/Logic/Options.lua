local addonName, addon = ...;

local VERSION_COUNTER = 2;

local function migrateOptions (options)
  if (options.collectCovenantButton ~= nil) then
    if (options.collectCovenantButton == true) then
      options.whitelist['GarrisonLandingPageMinimapButton'] = true;
    end

    options.collectCovenantButton = nil;
  end

  if (options.majorDirection ~= nil and options.minorDirection ~= nil) then
    options.direction = options.majorDirection .. options.minorDirection;
    options.majorDirection = nil;
    options.minorDirection = nil
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
    direction = 'leftdown',
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
  addon.printAddonMessage('has a new scale setting!\n',
      'Type "/mbb set scale <value>" to set the scale of the button.',
      'This will also scale collected buttons.');
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
  addon.options = options;

  if (not addon.applyLayout(options.direction)) then
    addon.applyDefaultLayout();
  end

  checkVersion(options);

  addon.registerEvent('PLAYER_LOGOUT', function ()
    _G.MinimapButtonButtonOptions = options;
  end);

  return true;
end);
