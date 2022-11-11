local _, addon = ...;


local floor = _G.floor;

local handlers = {};
local module = {};

addon['Logic/Settings'] = module;

local function defaultGetter (setting)
  return addon.options[setting];
end

handlers.direction = {
  set = function (value)
    if (not addon.applyLayout(value)) then
      return false;
    end

    addon.options.direction = value;
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
    addon.options.buttonsPerRow = numberValue;
    addon.updateLayout();
    return true;
  end,
  get = function ()
    return addon.options.buttonsPerRow;
  end
};

handlers.scale = {
  set = function (value)
    local numberValue = tonumber(value);

    if (numberValue == nil or numberValue <= 0) then
      return false;
    end

    addon.options.scale = numberValue;
    addon.applyScale();
    return true;
  end
};

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
    return defaultGetter(setting);
  end
end

function module.setSetting (setting, value)
  return handlers[setting].set(value);
end
