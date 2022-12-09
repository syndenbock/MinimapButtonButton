local addonName, addon = ...;

local strconcat = _G.strconcat;
local strjoin = _G.strjoin;

local IS_RETAIL = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE);

local function isRetail ()
  return IS_RETAIL;
end

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

addon.export('Core/Utils', {
  printAddonMessage = printAddonMessage,
  printReloadMessage = printReloadMessage,
  getFrameName = getFrameName,
  concatButtonName = concatButtonName,
  getUnitColor = getUnitColor,
  isRetail = isRetail,
});
