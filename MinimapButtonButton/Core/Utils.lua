local addonName, addon = ...;

local strconcat = _G.strconcat;
local strjoin = _G.strjoin;
local sort = _G.sort;
local tinsert = _G.tinsert;

local IS_RETAIL = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE);
local ADDON_MESSAGE_PREFIX = '|cff00ffff' .. addonName .. '|r ';

local function isRetail ()
  return IS_RETAIL;
end

local function printAddonMessage (...)
  print(strconcat(ADDON_MESSAGE_PREFIX, ...));
end

local function getSortedTableKeys(table)
  local keys = {};

  for key, value in pairs(table) do
    tinsert(keys, key);
  end

  sort(keys);

  return keys;
end

local function printTableKeys(table)
  local keys = getSortedTableKeys(table);

  for index, key in ipairs(keys) do
    print(key);
  end
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
  local playerClass = select(2, _G.UnitClass(unit));
  local color;

  if (type(_G.CUSTOM_CLASS_COLORS) == "table") then
    color = _G.CUSTOM_CLASS_COLORS[playerClass];
  else
    color = _G.RAID_CLASS_COLORS[playerClass];
  end

  return color.r, color.g, color.b, 1;
end

local function getPlayerColor ()
  return getUnitColor('player');
end

addon.export('Core/Utils', {
  printAddonMessage = printAddonMessage,
  getSortedTableKeys = getSortedTableKeys,
  printTableKeys = printTableKeys,
  printReloadMessage = printReloadMessage,
  getFrameName = getFrameName,
  concatButtonName = concatButtonName,
  getUnitColor = getUnitColor,
  getPlayerColor = getPlayerColor,
  isRetail = isRetail,
});
