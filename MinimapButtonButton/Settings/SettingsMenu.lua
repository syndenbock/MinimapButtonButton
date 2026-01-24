local addonName, addon = ...;

local Settings = _G.Settings;
local SliderLabels = _G.MinimalSliderWithSteppersMixin.Label;
local CreateSettingsButtonInitializer = _G.CreateSettingsButtonInitializer;

local category, layout = Settings.RegisterVerticalLayoutCategory(addonName);

local Main = addon.import('Logic/Main');
local Options = addon.import('Logic/Options');
local Enhancements = addon.import('Features/Enhancements');
local Layout = addon.import('Layouts/Main');

local addonOptions = Options.getAll();

local function registerDropdown (key, defaultValue, optionsGetter, options)
  options = options or {};

  local name = options.name or key;
  local variable = addonName .. '_' .. key;
  local setValue = options.setValue;
  local setting = Settings.RegisterAddOnSetting(category, variable, key, addonOptions, type(defaultValue), name, defaultValue);

  if (setValue ~= nil) then
    setting:SetValueChangedCallback(function (_, value)
      setValue(value);
    end);
  end

  Settings.CreateDropdown(category, setting, optionsGetter, options.tooltip);
end

local function registerSlider(key, defaultValue, options)
  options = options or {};

  local name = options.name or key;
  local variable = addonName .. '_' .. key;
  local sliderOptions = Settings.CreateSliderOptions(options.min or 1,
      options.max or 100, options.step or 1);
  local setValue = options.setValue;
  local setting = Settings.RegisterAddOnSetting(category, variable, key, addonOptions, type(defaultValue), name, defaultValue);

  if (setValue ~= nil) then
    setting:SetValueChangedCallback(function (_, value)
      setValue(value);
    end);
  end

  if (options.labels ~= nil) then
    for label, formatter in pairs(options.labels) do
      sliderOptions:SetLabelFormatter(label, formatter);
    end
  else
    sliderOptions:SetLabelFormatter(options.label or SliderLabels.Right);
  end

  Settings.CreateSlider(category, setting, sliderOptions, options.tooltip)
end

local function registerCheckbox (key, defaultValue, options)
  options = options or {};

  local name = options.name or key;
  local variable = addonName .. '_' .. key;
  local setValue = options.setValue;
  local setting = Settings.RegisterAddOnSetting(category, variable, key, addonOptions, type(defaultValue), name, defaultValue);

  if (setValue ~= nil) then
    setting:SetValueChangedCallback(function (_, value)
      setValue(value);
    end);
  end

  Settings.CreateCheckbox(category, setting, options.tooltip);
end

local function registerButton (name, onclick, options)
  options = options or {};

  local buttonInitializer = CreateSettingsButtonInitializer(name, name, onclick, options.tooltip, true);

  layout:AddInitializer(buttonInitializer);
end


local function registerSettingsMenu()
  local function getOptions ()
    local container = Settings.CreateControlTextContainer();

    container:Add("leftdown", "Left > Down");
    container:Add("leftup", "Left > Up");
    container:Add("downleft", "Down > Left");
    container:Add("downright", "Down > Right");
    container:Add("rightdown", "Right > Down");
    container:Add("rightup", "Right > Up");
    container:Add("upleft", "Up > Left");
    container:Add("upright", "Up > Right");

    return container:GetData();
  end

  registerDropdown("direction", "leftdown", getOptions, {
    name = "Growth Layout",
    setValue = Layout.applyLayout,
  });

  registerSlider("buttonsPerRow", 5, {
    name = "Buttons per row",
    min = 1,
    max = 50,
    setValue = Layout.updateLayout,
  });

  registerSlider("scale", 10, {
    name = "Scale of the main button",
    min = 1,
    max = 50,
    setValue = Main.applyScale,
    labels = {
      [SliderLabels.Right] = function (value)
        return value / 10;
      end,
    },
  });

  registerSlider("buttonScale", 10, {
    name = "Scale of the collected buttons",
    min = 1,
    max = 50,
    setValue = Main.applyButtonScale,
    labels = {
      [SliderLabels.Right] = function (value)
        return value / 10;
      end,
    },
  });

  registerSlider("autohide", 0, {
    name = "Hide buttons after x seconds",
    min = 0,
    max = 50,
    setValue = function (value)
      if (value > 0) then
        Main.hideButtons();
      end
    end
  });

  if (Enhancements.compartment ~= nil) then
    registerCheckbox("hidecompartment", false, {
      name = "Hide addon compartment frame",
      setValue = function (value)
        if (value == true) then
          Enhancements.hideCompartmentFrame();
        else
          Enhancements.showCompartmentFrame();
        end
      end
    });
  end

  registerButton("Reset position", Main.resetPosition);

  Settings.RegisterAddOnCategory(category);
end

registerSettingsMenu();
