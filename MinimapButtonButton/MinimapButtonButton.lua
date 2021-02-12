local addonName, addon = ...;

local CENTER = 'CENTER';
local RIGHT = 'RIGHT';
local LEFT = 'LEFT';
local LEFTBUTTON = 'LeftButton';
local RIGHTBUTTON = 'RightButton';
local MIDDLEBUTTON = 'MiddleButton';

local FRAME_STRATA = 'MEDIUM';
local FRAME_LEVEL = 7;
local BUTTON_EDGE_SIZE = 16;
local BUTTON_HEIGHT = 42;
local BUTTON_WIDTH = 33;
local EDGE_OFFSET = 4;
local BUTTON_SPACING = EDGE_OFFSET;

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

local function setButtonContainerWidth ()
  local width = EDGE_OFFSET + mainButton:GetWidth() + BUTTON_SPACING;

  for _, child in ipairs({buttonContainer:GetChildren()}) do
    if (child:IsShown()) then
      width = width + BUTTON_SPACING + child:GetWidth();
    end
  end

  buttonContainer:SetWidth(width);
end

local function setMinimapButtonPosition (button, anchorFrame)
  button:ClearAllPoints();

  if (anchorFrame) then
    button:SetPoint(LEFT, anchorFrame, RIGHT, BUTTON_SPACING, 0);
  else
    button:SetPoint(LEFT, buttonContainer, LEFT,
        EDGE_OFFSET + BUTTON_SPACING, 0);
  end
end

local function reflowCollectedButtons ()
  local lastButton = nil;

  for _, button in ipairs(collectedButtons) do
    if (button:IsShown()) then
      setMinimapButtonPosition(button, lastButton);
      lastButton = button;
    end
  end
end

local function toggleButtons ()
  if (buttonContainer:IsShown()) then
    buttonContainer:Hide();
  else
    setButtonContainerWidth();
    reflowCollectedButtons();
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
  buttonContainer:SetPoint(RIGHT, mainFrame, RIGHT, 0, 0);
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
  mainButton:SetPoint(RIGHT, mainFrame, RIGHT, 0, 0);
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

local function isMinimapButton (frame)
  local frameName = frame.GetName and frame:GetName();

  if (not frameName) then
    return false;
  end;

  local patterns = {
    'LibDBIcon10_',
    'MinimapButton',
  };

  for _, pattern in ipairs(patterns) do
    if (_G.strmatch(frameName, pattern) ~= nil) then
      return true;
    end
  end

  return false;
end

local function findMinimapButtons ()
  local tinsert = _G.tinsert;
  local buttonList = {};

  for _, child in ipairs({_G.Minimap:GetChildren()}) do
    if (isMinimapButton(child)) then
      tinsert(buttonList, child);
    end
  end

  return buttonList;
end

local function collectMinimapButton (button)
  -- print('collecting button:', button:GetName());

  button:SetParent(buttonContainer);
  button:SetFrameStrata(FRAME_STRATA);
  button:SetScript('OnDragStart', nil);
  button:SetScript('OnDragStop', nil);
end

local function collectMinimapButtons ()
  collectedButtons = findMinimapButtons();

  for _, button in ipairs(collectedButtons) do
    collectMinimapButton(button);
  end
end

events.PLAYER_LOGIN = collectMinimapButtons;

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
