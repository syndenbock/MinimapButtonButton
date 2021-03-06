local addonName, addon = ...;

local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;

local CENTER = 'CENTER';
local TOPRIGHT = 'TOPRIGHT';
local LEFTBUTTON = 'LeftButton';
local MIDDLEBUTTON = 'MiddleButton';

local FRAME_STRATA = 'MEDIUM';
local FRAME_LEVEL = 7;
local BUTTON_EDGE_SIZE = 16;
local BUTTON_HEIGHT = 42;
local BUTTON_WIDTH = 33;
local EDGE_OFFSET = 4;

local BUTTONS_PER_ROW = 10;
local BUTTON_SPACING = 2;

local mainFrame = _G.CreateFrame('Frame', addonName .. 'Frame');
local buttonContainer = _G.CreateFrame('Frame', nil, _G.UIParent,
    _G.BackdropTemplateMixin and 'BackdropTemplate');
local mainButton = _G.CreateFrame('Frame', addonName .. 'Button', _G.UIParent,
    _G.BackdropTemplateMixin and 'BackdropTemplate');
local events = {};
local options = {};
local collectedButtons = {};

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
  return calculateXOffset(buttonWidth, columnCount) + EDGE_OFFSET;
end

local function calculateContainerHeight (buttonHeight, rowCount)
    return calculateYOffset(buttonHeight, rowCount) + EDGE_OFFSET / 2;
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

local function toggleButtons ()
  if (buttonContainer:IsShown()) then
    buttonContainer:Hide();
  else
    local buttonWidth, buttonHeight = getMaximumButtonDimensions();

    setButtonContainerSize(buttonWidth, buttonHeight);
    reflowCollectedButtons(buttonWidth, buttonHeight);
    buttonContainer:Show();
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
end

local function isMinimapButton (frame)
  local frameName = frame.GetName and frame:GetName();

  if (not frameName) then
    return false;
  end;

  local patterns = {
    'LibDBIcon10_',
    'MinimapButton',
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
  local tinsert = _G.tinsert;
  local buttonList = {};

  for _, child in ipairs({_G.Minimap:GetChildren()}) do
    if (isMinimapButton(child)) then
      tinsert(buttonList, child);
    end
  end

  return buttonList;
end

local function findSpecificButtons ()
  local tinsert = _G.tinsert;
  local buttonNames = {
    'ZygorGuidesViewerMapIcon',
  };
  local buttons = {};

  for _, buttonName in ipairs(buttonNames) do
    local button = _G[buttonName];

    if (button ~= nil) then
      tinsert(buttons, button);
    end
  end

  return buttons;
end

local function getAllMinimapButtons ()
  local tinsert = _G.tinsert;
  local buttons = scanMinimapChildren();
  local specificButtons = findSpecificButtons();

  for _, button in ipairs(specificButtons) do
    tinsert(buttons, button);
  end

  return buttons;
end

local function collectMinimapButtons ()
  collectedButtons = getAllMinimapButtons();

  for _, button in ipairs(collectedButtons) do
    collectMinimapButton(button);
  end
end

events.PLAYER_LOGIN = function ()
  --[[ executing on next frame to wait for addons that create minimap buttons
       on PLAYER_LOGIN ]]
  _G.C_Timer.After(0, collectMinimapButtons);
end

--##############################################################################
-- stored data handling
--##############################################################################

local function restoreOptions ()
  if (options.position ~= nil) then
    mainFrame:ClearAllPoints();
    mainFrame:SetPoint(unpack(options.position));
  end
end

function events.ADDON_LOADED (loadedAddon)
  if (loadedAddon ~= addonName) then
    return;
  end

  if (type(_G.MinimapButtonButtonOptions) == type(options)) then
    options = _G.MinimapButtonButtonOptions;
    restoreOptions();
  end
end

function events.PLAYER_LOGOUT ()
  _G.MinimapButtonButtonOptions = options;
end

--##############################################################################
-- event handling
--##############################################################################

local eventFrame = _G.CreateFrame('Frame');

eventFrame:SetScript('OnEvent', function (_, event, ...)
  events[event](...);
end);

for event in pairs(events) do
  eventFrame:RegisterEvent(event);
end
