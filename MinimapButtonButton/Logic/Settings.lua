local _, addon = ...;

local floor = _G.floor;

local Main = addon.import('Logic/Main');
local options = addon.import('Logic/Options').getAll();
local Layout = addon.importPending('Layouts/Main');

local module = addon.export('Logic/Settings', {});
local handlers = {};

handlers.direction = {
  set = function (value)
    if (not Layout.applyLayout(value)) then
      return false;
    end

    options.direction = value;
    return true;
  end
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
  end
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
  end
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
  end
}

function module.printAvailableSettings ()
  for setting in pairs(handlers) do
    print(setting);
  end
end

function module.doesSettingExist (setting)
  return (handlers[setting] ~= nil);
end

function module.getSetting (setting)
  if (handlers[setting].get ~= nil) then
    return handlers[setting].get();
  else
    return options[setting];
  end
end

function module.setSetting (setting, value)
  return handlers[setting].set(value);
end
