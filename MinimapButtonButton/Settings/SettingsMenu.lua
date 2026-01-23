local addonName, addon = ...;

local Settings = _G.Settings;
local category = Settings.RegisterVerticalLayoutCategory(addonName);

local Options = addon.import('Logic/Options');
local Layout = addon.import("Layouts/Main");

local options = Options.getAll();

local function registerSettingsMenu()
  local name = "Direction";
  local key = "direction";
  local variable = addonName .. '_' .. key;
	local defaultValue = "leftdown";

  local function GetOptions ()
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

	local function GetValue()
		return options[key] or defaultValue;
	end

	local function SetValue(value)
    if (Layout.applyLayout(value)) then
		  options[key] = value;
    end
	end

	local setting = Settings.RegisterProxySetting(category, variable, type(defaultValue), name, defaultValue, GetValue, SetValue)
  Settings.CreateDropdown(category, setting, GetOptions);

  Settings.RegisterAddOnCategory(category);
end

registerSettingsMenu();
