local addonName, addon = ...;

local Events = addon.import('Core/Events');
local Utils = addon.import('Core/Utils');

local VERSION_COUNTER = 6;

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

  if (options.whitelist['GarrisonLandingPageMinimapButton'] == true) then
    options.whitelist['ExpansionLandingPageMinimapButton'] = true;
    options.whitelist['GarrisonLandingPageMinimapButton'] = nil;
  end

  if (options.version > 0 and options.version <= 5) then
    options.direction = _G.strlower(options.direction);
    options.scale = _G.floor(options.scale * 10 + 0.5);
    options.buttonScale = _G.floor(options.buttonScale * 10 + 0.5);
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
    scale = 10,
    hidecompartment = false,
    buttonScale = 10,
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
  Utils.printAddonMessage('now has a settings UI! Check it out in the games options menu.');
end

local function checkVersion ()
  if (options.version < VERSION_COUNTER) then
    printVersionMessage();
  end

  --[[ always set version to handle rollbacks ]]
  options.version = VERSION_COUNTER;
end

Events.registerEvent('ADDON_LOADED', function (loadedAddon)
  if (loadedAddon ~= addonName) then
    return;
  end

  local Layout = addon.import('Layouts/Main');
  local Enhancements = addon.import('Features/Enhancements');

  readValues(_G.MinimapButtonButtonOptions);

  migrateOptions();

  if (not Layout.applyLayout(options.direction)) then
    Layout.applyDefaultLayout();
  end

  if (Enhancements.compartment and options.hidecompartment == true) then
    Enhancements.hideCompartmentFrame();
  end

  checkVersion();

  Events.registerEvent('PLAYER_LOGOUT', function ()
    _G.MinimapButtonButtonOptions = options;
  end);

  return true;
end);
