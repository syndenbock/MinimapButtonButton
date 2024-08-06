local _, addon = ...;

local floor = _G.floor;

local Main = addon.import('Logic/Main');
local Utils = addon.import('Core/Utils');
local options = addon.import('Logic/Options').getAll();
local Enhancements = addon.import('Features/Enhancements');
local Layout = addon.import('Layouts/Main');

local module = addon.export('Settings/Settings', {});
local handlers = {};
local unavailableHandlers = {}

handlers.direction = {
  set = function (value)
    if (not Layout.applyLayout(value)) then
      return false;
    end

    options.direction = value;
    return true;
  end,
};

handlers.buttonsperrow = {
  set = function (value)
    local numberValue = tonumber(value);

    if (numberValue == nil or numberValue <= 0) then
      return false;
    end

    numberValue = floor(numberValue);
    options.buttonsPerRow = numberValue;
    Layout.updateLayout();
    return true;
  end,
  get = function ()
    return options.buttonsPerRow;
  end,
};

handlers.scale = {
  set = function (value)
    local numberValue = tonumber(value);

    if (numberValue == nil or numberValue <= 0) then
      return false;
    end

    options.scale = numberValue;
    Main.applyScale();
    return true;
  end,
};

handlers.buttonscale = {
  set = function (value)
    local numberValue = tonumber(value);

    if (numberValue == nil or numberValue <= 0) then
      return false;
    end

    options.buttonScale = numberValue;
    Main.applyButtonScale();
    return true;
  end,
  get = function ()
    return options.buttonScale;
  end,
};

handlers.autohide = {
  set = function (value)
    local numberValue = tonumber(value);

    if (numberValue == nil) then
      return false;
    end

    options.autohide = numberValue;

    if (numberValue > 0) then
      Main.hideButtons();
    end

    return true;
  end,
};

if (Enhancements.compartment) then
  handlers.hidecompartment = {
    set = function (value)
      if (value == 'true') then
        options.hidecompartment = true;
        Enhancements.hideCompartmentFrame();
      elseif (value == 'false') then
        options.hidecompartment = false;
        Enhancements.showCompartmentFrame();
      else
        return false;
      end

      return true;
    end,
  };
else
  unavailableHandlers.hidecompartment = function ()
      return 'This setting is unavailable because the compartment frame only exists on Retail.';
  end
end

function module.printAvailableSettings ()
  for setting in pairs(handlers) do
    print(setting);
  end
end

function module.doesSettingExist (setting)
  return (handlers[setting] ~= nil);
end

function module.isSettingUnavailable (setting)
  return (unavailableHandlers[setting] ~= nil);
end

function module.getSettingUnavailableReason (setting)
  return unavailableHandlers[setting]()
end

function module.getSetting (setting)
  local handler = handlers[setting];

  if (handler.get ~= nil) then
    return handler.get();
  else
    return options[setting];
  end
end

function module.setSetting (setting, value)
  return handlers[setting].set(value);
end
