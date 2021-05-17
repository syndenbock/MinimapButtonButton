local addonName, addon = ...;

local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;
local tinsert = _G.tinsert;
local tContains = _G.tContains;

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
local collectedButtons = {};

--##############################################################################
-- shared data
--##############################################################################

addon.shared = {
  buttonContainer = buttonContainer,
  mainButton = mainButton,
  collectedButtons = collectedButtons,
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

local function getFrameEffectiveWidth (frame)
  return frame:GetWidth() * frame:GetScale();
end

local function getFrameEffectiveHeight (frame)
  return frame:GetHeight() * frame:GetScale();
end

local function setFrameEffectiveAnchor (frame, anchor, parent, parentAnchor, x, y)
  frame:ClearAllPoints();
  frame:SetPoint(anchor, parent, parentAnchor, x / frame:GetScale(), y / frame:GetScale());
end

local function calculateXOffset (buttonWidth, columnCount)
  return getFrameEffectiveWidth(mainButton) + BUTTON_SPACING +
      (buttonWidth + BUTTON_SPACING) * columnCount;
end

local function calculateYOffset (buttonHeight, rowCount)
  return EDGE_OFFSET + BUTTON_SPACING +
      (buttonHeight + BUTTON_SPACING) * rowCount;
end

local function anchorButton (button, rowIndex, columnIndex, buttonWidth, buttonHeight)
  local xOffset = (calculateXOffset(buttonWidth, columnIndex) + buttonWidth / 2);
  local yOffset = (calculateYOffset(buttonHeight, rowIndex) + buttonHeight / 2);

  setFrameEffectiveAnchor(button, CENTER, buttonContainer, TOPRIGHT, -xOffset, -yOffset);
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
      maxWidth = max(maxWidth, getFrameEffectiveWidth(button));
      maxHeight = max(maxHeight, getFrameEffectiveHeight(button));
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
    addon.options.buttonsShown = false;
    hideButtons();
  else
    addon.options.buttonsShown = true;
    showButtons();
  end
end

local function storeMainFramePosition ()
  addon.options.position = {mainFrame:GetPoint()};
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

local function isMinimapButton (frame)
  local frameName = addon.getFrameName(frame);

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

local function scanMinimapChildren ()
  for _, child in ipairs({_G.Minimap:GetChildren()}) do
    if (not addon.isBlacklisted(child) and isMinimapButton(child)) then
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

local function collectWhitelistedButtons ()
  for buttonName in pairs(addon.options.whitelist) do
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
  collectWhitelistedButtons();

  if (addon.options.collectCovenantButton == true) then
    scanCovenantButton();
  end

  sortCollectedButtons();
end

local function restoreOptions ()
  if (addon.options.position ~= nil) then
    mainFrame:ClearAllPoints();
    mainFrame:SetPoint(unpack(addon.options.position));
  end

  if (addon.options.buttonsShown == true) then
    showButtons();
  end
end

local function init ()
  restoreOptions();
  collectMinimapButtons();

  if (addon.options.buttonsShown == true) then
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
-- slash commands
--##############################################################################

addon.addSlashHandlerName('mbb');

addon.slash('covenant', function (state)
  if (state == nil) then
    if (addon.options.collectCovenantButton == true) then
      addon.printAddonMessage('Covenant button is currently being collected');
    else
      addon.printAddonMessage('Covenant button is currently not being collected');
    end
  elseif (state == 'on') then
    addon.options.collectCovenantButton = true;
    scanCovenantButton();
    sortCollectedButtons();
    addon.printReloadMessage('Covenant button is now being collected.');
  elseif (state == 'off') then
    addon.options.collectCovenantButton = false;
    addon.printReloadMessage('Covenant button is no longer being collected.');
  else
    addon.printAddonMessage('unknown setting:', state);
  end
end);
