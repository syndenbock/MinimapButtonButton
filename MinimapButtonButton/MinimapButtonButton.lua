local addonName, addon = ...;

local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;
local tinsert = _G.tinsert;
local tContains = _G.tContains;
local format = _G.format;

local CENTER = 'CENTER';
local TOPRIGHT = 'TOPRIGHT';
local LEFTBUTTON = 'LeftButton';
local MIDDLEBUTTON = 'MiddleButton';

local FRAME_STRATA = 'MEDIUM';
local FRAME_LEVEL = 7;
local BUTTON_EDGE_SIZE = 16;
local BUTTON_HEIGHT = 42;
local BUTTON_WIDTH = 34;
local EDGE_OFFSET = 4;

local BUTTONS_PER_ROW = 10;
local BUTTON_SPACING = 2;

local mainFrame = _G.CreateFrame('Frame', addonName .. 'Frame');
local buttonContainer = _G.CreateFrame('Frame', nil, _G.UIParent,
    _G.BackdropTemplateMixin and 'BackdropTemplate');
local mainButton = _G.CreateFrame('Frame', addonName .. 'Button', _G.UIParent,
    _G.BackdropTemplateMixin and 'BackdropTemplate');
local options;
local collectedButtons = {};

--##############################################################################
-- shared data
--##############################################################################

addon.shared = {
  buttonContainer = buttonContainer,
  mainButton = mainButton,
};

--##############################################################################
-- utility functions
--##############################################################################

local function getUnitColor (unit)
  local color = _G.RAID_CLASS_COLORS[select(2, _G.UnitClass(unit))];

  return color.r, color.g, color.b, 1;
end

--##############################################################################
-- main button setup
--##############################################################################

local function isButtonDisplayed (button)
  return button.IsShown and button:IsShown();
end

local function getShownChildrenCount (parent)
  local count = 0;

  for _, child in ipairs({parent:GetChildren()}) do
    if (isButtonDisplayed(child)) then
      count = count + 1;
    end
  end

  return count;
end

local function calculateXOffset (buttonWidth, columnCount)
  return mainButton:GetWidth() + BUTTON_SPACING +
      (buttonWidth + BUTTON_SPACING) * columnCount;
end

local function calculateYOffset (buttonHeight, rowCount)
  return EDGE_OFFSET + BUTTON_SPACING +
      (buttonHeight + BUTTON_SPACING) * rowCount;
end

local function anchorButton (button, rowIndex, columnIndex, buttonWidth, buttonHeight)
  local xOffset = calculateXOffset(buttonWidth, columnIndex) +
      (buttonWidth - button:GetWidth()) / 2;
  local yOffset = calculateYOffset(buttonHeight, rowIndex) +
      (buttonHeight - button:GetHeight()) / 2;

  button:ClearAllPoints();
  button:SetPoint(TOPRIGHT, buttonContainer, TOPRIGHT, -xOffset, -yOffset);
end

local function reflowCollectedButtons (buttonWidth, buttonHeight)
  local rowIndex = 0;
  local columnIndex = 0;
  local index = 0;

  for _, button in ipairs(collectedButtons) do
    if (isButtonDisplayed(button)) then
      anchorButton(button, rowIndex, columnIndex, buttonWidth, buttonHeight);

      if (mod(index + 1, BUTTONS_PER_ROW) == 0) then
        columnIndex = 0;
        rowIndex = rowIndex + 1;
      else
        columnIndex = columnIndex + 1;
      end

      index = index + 1;
    end
  end
end

local function calculateContainerWidth (buttonWidth, columnCount)
  return max(calculateXOffset(buttonWidth, columnCount) + EDGE_OFFSET,
      BUTTON_WIDTH * 2 - EDGE_OFFSET);
end

local function calculateContainerHeight (buttonHeight, rowCount)
  return max(calculateYOffset(buttonHeight, rowCount) + EDGE_OFFSET / 2,
      BUTTON_HEIGHT);
end

local function setButtonContainerSize (buttonWidth, buttonHeight)
  local buttonCount = getShownChildrenCount(buttonContainer);
  local columnCount = min(buttonCount, BUTTONS_PER_ROW);
  local rowCount = ceil(buttonCount / BUTTONS_PER_ROW);

  buttonContainer:SetSize(calculateContainerWidth(buttonWidth, columnCount),
      calculateContainerHeight(buttonHeight, rowCount));
end

local function getMaximumButtonDimensions ()
  local maxWidth = 0;
  local maxHeight = 0;

  for _, button in ipairs(collectedButtons) do
    if (isButtonDisplayed(button)) then
      maxWidth = max(maxWidth, button:GetWidth());
      maxHeight = max(maxHeight, button:GetHeight());
    end
  end

  return maxWidth, maxHeight;
end

local function hideButtons ()
  buttonContainer:Hide();
end

local function showButtons ()
  local buttonWidth, buttonHeight = getMaximumButtonDimensions();

  setButtonContainerSize(buttonWidth, buttonHeight);
  reflowCollectedButtons(buttonWidth, buttonHeight);
  buttonContainer:Show();
end

local function toggleButtons ()
  if (buttonContainer:IsShown()) then
    options.buttonsShown = false;
    hideButtons();
  else
    options.buttonsShown = true;
    showButtons();
  end
end

local function storeMainFramePosition ()
  options.position = {mainFrame:GetPoint()};
end

local function stopMovingMainFrame ()
  mainFrame:SetMovable(false);
  mainFrame:SetScript('OnMouseUp', nil);
  mainFrame:StopMovingOrSizing();
  storeMainFramePosition();
end

local function moveMainFrame ()
  mainFrame:SetMovable(true);
  mainFrame:StartMoving();

  mainButton:SetScript('OnMouseUp', function (_, button)
    if (button == MIDDLEBUTTON) then
      stopMovingMainFrame();
    end
  end);
end

local function initMainFrame ()
  mainFrame:SetParent(_G.UIParent);
  mainFrame:SetFrameStrata(FRAME_STRATA);
  mainFrame:SetFrameLevel(FRAME_LEVEL);
  mainFrame:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
  mainFrame:SetPoint(CENTER, _G.UIParent, CENTER, 0, 0);
  mainFrame:SetClampedToScreen(true);
end

local function initButtonContainer ()
  buttonContainer:SetParent(mainFrame);
  buttonContainer:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
  buttonContainer:SetPoint(TOPRIGHT, mainFrame, TOPRIGHT, 0, 0);
  buttonContainer:Hide();

  buttonContainer:SetBackdrop({
    bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
    edgeSize = BUTTON_EDGE_SIZE,
    insets = {
      left = EDGE_OFFSET,
      right = EDGE_OFFSET,
      top = EDGE_OFFSET,
      bottom = EDGE_OFFSET
    },
  });
  buttonContainer:SetBackdropColor(0, 0, 0, 1);
end

local function initLogo ()
  local logo = mainButton:CreateTexture(nil, FRAME_STRATA);

  logo:SetTexture('Interface\\AddOns\\' .. addonName ..
      '\\Media\\Logo.blp');
  logo:SetVertexColor(0, 0, 0, 1);
  logo:SetPoint(CENTER, mainButton, CENTER, 0, 0);
  logo:SetSize(16, 16);

  addon.shared.logo = logo;
end

local function initMainButton ()
  mainButton:SetParent(mainFrame);
  mainButton:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
  mainButton:SetPoint(TOPRIGHT, mainFrame, TOPRIGHT, 0, 0);
  mainButton:Show();

  mainButton:SetBackdrop({
    bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
    edgeSize = BUTTON_EDGE_SIZE,
    insets = {
      left = EDGE_OFFSET,
      right = EDGE_OFFSET,
      top = EDGE_OFFSET,
      bottom = EDGE_OFFSET
    },
  });

  mainButton:SetBackdropColor(getUnitColor('player'));

  mainButton:SetScript('OnMouseDown', function (_, button)
    if (button == LEFTBUTTON) then
      toggleButtons();
    elseif (button == MIDDLEBUTTON) then
      moveMainFrame();
    end
  end);
end

local function initFrames ()
  initMainFrame();
  initButtonContainer();
  initMainButton();
  initLogo();
end

initFrames();

--##############################################################################
-- minimap button collecting
--##############################################################################

local function collectMinimapButton (button)
  -- print('collecting button:', button:GetName());

  button:SetParent(buttonContainer);
  button:SetFrameStrata(FRAME_STRATA);
  button:SetScript('OnDragStart', nil);
  button:SetScript('OnDragStop', nil);

  if (not tContains(collectedButtons, button)) then
    tinsert(collectedButtons, button);
  end
end

local function getFrameName (frame)
  return frame.GetName and frame:GetName();
end

local function isMinimapButton (frame)
  local frameName = getFrameName(frame);

  if (not frameName) then
    return false;
  end;

  local patterns = {
    'LibDBIcon10_',
    'MinimapButton',
    'MinimapFrame',
    'MinimapIcon',
    '-Minimap',
  };

  for _, pattern in ipairs(patterns) do
    if (_G.strmatch(frameName, pattern) ~= nil) then
      return true;
    end
  end

  return false;
end

local function isBlacklisted (frame)
  if (options.blacklistedButtonNames == nil) then
    return false;
  end

  local frameName = getFrameName(frame);

  return (frameName ~= nil and
      options.blacklistedButtonNames[frameName] == true);
end

local function scanMinimapChildren ()
  for _, child in ipairs({_G.Minimap:GetChildren()}) do
    if (not isBlacklisted(child) and isMinimapButton(child)) then
      collectMinimapButton(child);
    end
  end
end

local function scanButtonByName (buttonName)
  local button = _G[buttonName];

  if (button ~= nil) then
    collectMinimapButton(button);
  end
end

local function scanSpecificButtons ()
  local buttonNames = {
    'ZygorGuidesViewerMapIcon',
    'TrinketMenu_IconFrame',
    'CodexBrowserIcon',
  };

  for _, buttonName in ipairs(buttonNames) do
    scanButtonByName(buttonName);
  end
end

local function scanCovenantButton ()
  scanButtonByName('GarrisonLandingPageMinimapButton');
end

local function sortCollectedButtons ()
  _G.sort(collectedButtons, function (a, b)
    return a:GetName() < b:GetName();
  end);
end

local function collectMinimapButtons ()
  scanMinimapChildren();
  scanSpecificButtons();

  if (options.collectCovenantButton == true) then
    scanCovenantButton();
  end

  sortCollectedButtons();
end

local function restoreOptions ()
  if (options.position ~= nil) then
    mainFrame:ClearAllPoints();
    mainFrame:SetPoint(unpack(options.position));
  end

  if (options.buttonsShown == true) then
    showButtons();
  end
end

local function init ()
  restoreOptions();
  collectMinimapButtons();

  if (options.buttonsShown == true) then
    showButtons();
  end
end

addon.registerEvent('PLAYER_LOGIN', function ()
  --[[ executing on next frame to wait for addons that create minimap buttons
       on PLAYER_LOGIN ]]
  _G.C_Timer.After(0, init);

  return true;
end);

--##############################################################################
-- stored data handling
--##############################################################################

addon.registerEvent('ADDON_LOADED', function (loadedAddon)
  if (loadedAddon ~= addonName) then
    return;
  end

  if (type(_G.MinimapButtonButtonOptions) == 'table') then
    options = _G.MinimapButtonButtonOptions;
  else
    options = {};
  end

  if (type(options.blacklistedButtonNames) ~= 'table') then
    options.blacklistedButtonNames = {};
  end

  addon.registerEvent('PLAYER_LOGOUT', function ()
    _G.MinimapButtonButtonOptions = options;
  end);

  return true;
end);

--##############################################################################
-- slash commands
--##############################################################################

addon.addSlashHandlerName('mbb');

addon.slash('covenant', function (state)
  if (state == nil) then
    if (options.collectCovenantButton == true) then
      print(addonName .. ': Covenant button is currently being collected');
    else
      print('Covenant button is currently not being collected');
    end
  elseif (state == 'on') then
    options.collectCovenantButton = true;
    scanCovenantButton();
    sortCollectedButtons();
    print(addonName .. ': Covenant button is now being collected');
  elseif (state == 'off') then
    options.collectCovenantButton = false;
    print(addonName .. ': Covenant button is no longer being collected.\n' ..
      'This requires a /reload for this to take effect.');
  else
    print('unknown setting:', state);
  end
end);

addon.slash('list', function ()
  print(addonName .. ': Buttons currently being collected:');

  for _, button in ipairs(collectedButtons) do
    print(button:GetName());
  end

  if (next(options.blacklistedButtonNames) ~= nil) then
    print(addonName .. ': Buttons currently being ignored:');

    for buttonName in pairs(options.blacklistedButtonNames) do
      print(buttonName);
    end
  end
end);

addon.slash('ignore', function (buttonName)
  if (_G[buttonName] == nil) then
    print(format('%s: Could not find button named "%s"',
        addonName, buttonName));
    return;
  end

  options.blacklistedButtonNames[buttonName] = true;
  print(format('%s: Button "%s" is now being ignored.\n' ..
      'This requires a /reload to take effect.', addonName, buttonName));
end);

addon.slash('unignore', function (buttonName)
  if (options.blacklistedButtonNames[buttonName] == nil) then
    print(format('%s: Button "%s" is not being ignored.', addonName, buttonName));
    return;
  end

  options.blacklistedButtonNames[buttonName] = nil;
  print(format('%s: Button "%s" is no longer being ignored.\n' ..
    'This requires a /reload to take effect.', addonName, buttonName));
end);

addon.slash('unignoreall', function (buttonName)
  options.blacklistedButtonNames = {};
  print('addonName' .. ': No more buttons are being ignored.\n' ..
      'This requires a /reload to take effect.');
end);
