local _, addon = ...;

local floor = _G.floor;
local strjoin = _G.strjoin;

local Main = addon.import('Logic/Main');
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
  help = strjoin('\n',
      'This setting allows you to set the direction the collected buttons attach to the frame. Available values are:',
      'leftdown leftup', 'rightup rightdown', 'upleft upright', 'downleft downright'
  )
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
  help = "This setting specifies how many buttons will be placed in one row at max."
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
  help = "This setting specifies the scale of the addon button."
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
  help = "This setting specifies the scale of the collected buttons."
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
  help = "This setting specifies the time in seconds after which the button should close automatically. Setting it to 0 disables automatic closing."
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
    help = "This setting specifies if the Blizzard addon compartment button should be hidden."
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

function module.printAvailableHelpers()
  for setting, handler in pairs(handlers) do
    if (handler.help ~= null) then
      print(setting);
    end
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

function module.getHelp (setting)
  return handlers[setting] and handlers[setting].help;
end
