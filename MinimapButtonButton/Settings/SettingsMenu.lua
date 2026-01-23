local addonName, addon = ...;

local Settings = _G.Settings;
local MinimalSliderWithSteppersMixin = _G.MinimalSliderWithSteppersMixin;

local category = Settings.RegisterVerticalLayoutCategory(addonName);

local Options = addon.import('Logic/Options');
local Layout = addon.import("Layouts/Main");

local addonOptions = Options.getAll();

local function registerDropdown (key, defaultValue, optionsGetter, options)
  local name = options.name or key;
  local variable = addonName .. '_' .. key;
  local setValue = options.setValue;
  local setting = Settings.RegisterAddOnSetting(category, variable, key, addonOptions, type(defaultValue), name, defaultValue);

  setting:SetValueChangedCallback(function (self, value)
    if (setValue ~= nil) then
      setValue(value);
    end
  end);

  Settings.CreateDropdown(category, setting, optionsGetter, options.tooltip);
end

local function registerSlider(key, defaultValue, options)
  local name = options.name or key;
  local variable = addonName .. '_' .. key;
  local sliderOptions = Settings.CreateSliderOptions(options.min or 1,
      options.max or 100, options.step or 1);
  local setValue = options.setValue;
  local setting = Settings.RegisterAddOnSetting(category, variable, key, addonOptions, type(defaultValue), name, defaultValue);

  setting:SetValueChangedCallback(function (_, value)
    if (setValue ~= nil) then
      setValue(value);
    end
  end);

  sliderOptions:SetLabelFormatter(options.label or MinimalSliderWithSteppersMixin.Label.Left);
  Settings.CreateSlider(category, setting, sliderOptions, options.tooltip)
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

  Settings.RegisterAddOnCategory(category);
end

registerSettingsMenu();
