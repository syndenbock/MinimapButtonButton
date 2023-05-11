local addonName, addon = ...;

local Events = addon.import('Core/Events');
local Utils = addon.import('Core/Utils');

local VERSION_COUNTER = 5;

local module = addon.export('Logic/Options', {});
local options = {};

function module.get (name)
  return options[name];
end

function module.set (name, value)
  options[name] = value;
end

function module.getAll ()
  return options;
end

local function migrateOptions ()
  if (options.collectCovenantButton ~= nil) then
    if (options.collectCovenantButton == true) then
      options.whitelist['GarrisonLandingPageMinimapButton'] = true;
    end

    options.collectCovenantButton = nil;
  end

  if (options.majorDirection ~= nil and options.minorDirection ~= nil) then
    options.direction = options.majorDirection .. options.minorDirection;
    options.majorDirection = nil;
    options.minorDirection = nil;
  end
end

local function checkValues (loadedValues, defaults)
  for setting, defaultValue in pairs(defaults) do
    if (type(loadedValues[setting]) ~= type(defaultValue)) then
      loadedValues[setting] = defaultValue;
    end
  end
end

local function readValues (loadedValues)
  local defaults = {
    blacklist = {},
    whitelist = {
      ZygorGuidesViewerMapIcon = true,
      TrinketMenu_IconFrame = true,
      CodexBrowserIcon = true,
    },
    direction = 'leftdown',
    autohide = 0,
    buttonsPerRow = 5,
    scale = 1,
    hidecompartment = false,
    buttonScale = 1,
    version = 0,
  };

  if (type(loadedValues) ~= type(defaults)) then
    defaults.version = VERSION_COUNTER;
    loadedValues = defaults;
  else
    checkValues(loadedValues, defaults);
  end

  for setting, value in pairs(loadedValues) do
    options[setting] = value;
  end
end

local function printVersionMessage ()
  Utils.printAddonMessage('can now hide the addon compartment button!\n',
      'Type "/mbb set hidecompartment <true/false>" to set if the button shall be hidden.');
end

local function checkVersion ()
  if (options.version < VERSION_COUNTER) then
    printVersionMessage();
  end

  --[[ alawys set version to handle rollbacks ]]
  options.version = VERSION_COUNTER;
end

Events.registerEvent('ADDON_LOADED', function (loadedAddon)
  if (loadedAddon ~= addonName) then
    return;
  end

  local Layout = addon.import('Layouts/Main');

  readValues(_G.MinimapButtonButtonOptions);

  migrateOptions();

  if (not Layout.applyLayout(options.direction)) then
    Layout.applyDefaultLayout();
  end

  if (Utils.isRetail() and options.hidecompartment == true) then
    addon.import('Features/Enhancements').hideCompartmentFrame();
  end

  checkVersion();

  Events.registerEvent('PLAYER_LOGOUT', function ()
    _G.MinimapButtonButtonOptions = options;
  end);

  return true;
end);
