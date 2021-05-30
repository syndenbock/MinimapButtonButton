local addonName, addon = ...;

local tinsert = _G.tinsert;
local tContains = _G.tContains;

local CENTER = 'CENTER';
local TOPRIGHT = 'TOPRIGHT';
local LEFTBUTTON = 'LeftButton';
local MIDDLEBUTTON = 'MiddleButton';

local config = addon.config;

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

local function hideButtons ()
  buttonContainer:Hide();
end

local function showButtons ()
  addon.updateLayout();
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
  mainFrame:SetFrameStrata(config.FRAME_STRATA);
  mainFrame:SetFrameLevel(config.FRAME_LEVEL);
  mainFrame:SetSize(config.BUTTON_WIDTH, config.BUTTON_HEIGHT);
  mainFrame:SetPoint(CENTER, _G.UIParent, CENTER, 0, 0);
  mainFrame:SetClampedToScreen(true);
end

local function initButtonContainer ()
  buttonContainer:SetParent(mainFrame);
  buttonContainer:SetSize(config.BUTTON_WIDTH, config.BUTTON_HEIGHT);
  buttonContainer:SetPoint(TOPRIGHT, mainFrame, TOPRIGHT, 0, 0);
  buttonContainer:Hide();

  buttonContainer:SetBackdrop({
    bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
    edgeSize = config.BUTTON_EDGE_SIZE,
    insets = {
      left = config.EDGE_OFFSET,
      right = config.EDGE_OFFSET,
      top = config.EDGE_OFFSET,
      bottom = config.EDGE_OFFSET
    },
  });
  buttonContainer:SetBackdropColor(0, 0, 0, 1);
end

local function initLogo ()
  local logo = mainButton:CreateTexture(nil, config.FRAME_STRATA);

  logo:SetTexture('Interface\\AddOns\\' .. addonName ..
      '\\Media\\Logo.blp');
  logo:SetVertexColor(0, 0, 0, 1);
  logo:SetPoint(CENTER, mainButton, CENTER, 0, 0);
  logo:SetSize(16, 16);

  addon.shared.logo = logo;
end

local function initMainButton ()
  mainButton:SetParent(mainFrame);
  mainButton:SetSize(config.BUTTON_WIDTH, config.BUTTON_HEIGHT);
  mainButton:SetPoint(TOPRIGHT, mainFrame, TOPRIGHT, 0, 0);
  mainButton:Show();

  mainButton:SetBackdrop({
    bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
    edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
    edgeSize = config.BUTTON_EDGE_SIZE,
    insets = {
      left = config.EDGE_OFFSET,
      right = config.EDGE_OFFSET,
      top = config.EDGE_OFFSET,
      bottom = config.EDGE_OFFSET
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
  button:SetFrameStrata(config.FRAME_STRATA);
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

local function sortCollectedButtons ()
  _G.sort(collectedButtons, function (a, b)
    return a:GetName() < b:GetName();
  end);
end

local function collectMinimapButtons ()
  scanMinimapChildren();
  collectWhitelistedButtons();
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

addon.slash('list', function ()
  addon.printAddonMessage('Buttons currently being collected:');

  for _, button in ipairs(addon.shared.collectedButtons) do
    print(button:GetName());
  end

  if (next(addon.options.whitelist) ~= nil) then
    addon.printAddonMessage('Buttons currently being manually collected:');

    for buttonName in pairs(addon.options.whitelist) do
      print(buttonName);
    end
  end

  if (next(addon.options.blacklist) ~= nil) then
    addon.printAddonMessage('Buttons currently being ignored:');

    for buttonName in pairs(addon.options.blacklist) do
      print(buttonName);
    end
  end
end);
