local addonName, addon = ...;

local module = addon.export('Core/Utils', {});

local strconcat = _G.strconcat;
local strjoin = _G.strjoin;

local ADDON_MESSAGE_PREFIX = '|cff00ffff' .. addonName .. '|r ';

local function printAddonMessage (...)
  print(strconcat(ADDON_MESSAGE_PREFIX, ...));
end

local function printReloadMessage (...)
  printAddonMessage(...);
  print('This requires a /reload to take effect.');
end

local function getFrameName (frame)
  return frame.GetName and frame:GetName();
end

local function concatButtonName (...)
  return strjoin(' ', ...);
end

local function getUnitColor (unit)
  -- Do not use C_ClassColor.GetClassColor, it doesn't exist in Classic or BCC
  local color = _G.RAID_CLASS_COLORS[select(2, _G.UnitClass(unit))];

  return color.r, color.g, color.b, 1;
end

module.printAddonMessage = printAddonMessage;
module.printReloadMessage = printReloadMessage;
module.getFrameName = getFrameName;
module.concatButtonName = concatButtonName;
module.getUnitColor = getUnitColor;
