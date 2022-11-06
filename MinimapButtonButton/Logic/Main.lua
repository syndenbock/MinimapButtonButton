local addonName, addon = ...;

local sort = _G.sort;
local strmatch = _G.strmatch;
local tinsert = _G.tinsert;
local executeAfter = _G.C_Timer.After;
local hooksecurefunc = _G.hooksecurefunc;
local IsAltKeyDown = _G.IsAltKeyDown;
local issecurevariable = _G.issecurevariable;

local Minimap = _G.Minimap;

local LEFTBUTTON = 'LeftButton';
local MIDDLEBUTTON = 'MiddleButton';
local ONMOUSEUP = 'OnMouseUp';

local constants = addon.constants;
local anchors = constants.anchors;

local buttonContainer;
local mainButton;
local logo;
local collectedButtonMap = {};
local collectedButtons = {};

--##############################################################################
-- minimap button collecting
--##############################################################################

local function setButtonParent (button, parent)
  if (parent ~= buttonContainer) then
    button:SetParent(buttonContainer);
  end
end

local function doNothing () end

local function collectMinimapButton (button)
  -- print('collecting button:', button:GetName());

  button:SetParent(buttonContainer);
  button:SetFrameStrata(constants.FRAME_STRATA);
  button:SetScript('OnDragStart', nil);
  button:SetScript('OnDragStop', nil);
  button:SetIgnoreParentScale(false);

  -- Hook the function on the frame itself instead of setting a script handler
  -- to execute only when the function is called and not when the frame changes
  -- visibility because the parent gets shown/hidden
  hooksecurefunc(button, 'Show', addon.updateLayout);
  hooksecurefunc(button, 'Hide', addon.updateLayout);
  hooksecurefunc(button, 'SetParent', setButtonParent);
  -- There's still a ton of addons being coded like hot garbage moving their
  -- buttons on every single frame so to prevent a billion comments stating that
  -- MBB is apparently incompatible, we try to block moving the frame
  button.ClearAllPoints = doNothing;
  button.SetPoint = doNothing;

  tinsert(collectedButtons, button);
  collectedButtonMap[button] = true;
end

local function nameEndsWithNumber (frameName)
  return (strmatch(frameName, '%d$') ~= nil);
end

local function nameMatchesButtonPattern (frameName)
  local patterns = {
    '^LibDBIcon10_',
    'MinimapButton',
    'MinimapFrame',
    'MinimapIcon',
    '[-_]Minimap[-_]',
    'Minimap$',
  };

  for _, pattern in ipairs(patterns) do
    if (strmatch(frameName, pattern) ~= nil) then
      return true;
    end
  end

  return false;
end

local function isMinimapButton (frame)
  local frameName = addon.getFrameName(frame);

  if (not frameName) then
    return false;
  end;

  if (issecurevariable(frameName)) then
    return false;
  end

  if (nameEndsWithNumber(frameName)) then
    return false;
  end

  return (nameMatchesButtonPattern(frameName));
end

local function isButtonCollected (button)
  return (collectedButtonMap[button] ~= nil);
end

local function shouldButtonBeCollected (button)
  if (isButtonCollected(button) or addon.isButtonBlacklisted(button)) then
    return false;
  end

  return isMinimapButton(button);
end

local function scanMinimapChildren ()
  for _, child in ipairs({Minimap:GetChildren()}) do
    if (shouldButtonBeCollected(child)) then
      collectMinimapButton(child);
    end
  end
end

local function isValidFrame (frame)
  if (type(frame) ~= 'table') then
    return false;
  end

  if (not frame.IsObjectType or not frame:IsObjectType('Frame')) then
    return false;
  end

  return true;
end

local function scanButtonByName (buttonName)
  local button = _G[buttonName];

  if (isValidFrame(button) and not isButtonCollected(button)) then
    collectMinimapButton(button);
  end
end

local function collectWhitelistedButtons ()
  for buttonName in pairs(addon.options.whitelist) do
    scanButtonByName(buttonName);
  end
end

local function sortCollectedButtons ()
  sort(collectedButtons, function (a, b)
    return a:GetName() < b:GetName();
  end);
end

local function collectMinimapButtons ()
  local previousCount = #collectedButtons;

  scanMinimapChildren();
  collectWhitelistedButtons();

  if (#collectedButtons > previousCount) then
    sortCollectedButtons();
  end
end

local function collectMinimapButtonsAndUpdateLayout ()
  collectMinimapButtons();
  addon.updateLayout();
end

--##############################################################################
-- main button setup
--##############################################################################

local function toggleButtons ()
  collectMinimapButtonsAndUpdateLayout();

  if (buttonContainer:IsShown()) then
    addon.options.buttonsShown = false;
    buttonContainer:Hide();
  else
    addon.options.buttonsShown = true;
    buttonContainer:Show();
  end
end

local function setDefaultPosition ()
  mainButton:ClearAllPoints();
  mainButton:SetPoint(anchors.CENTER, _G.UIParent, anchors.CENTER, 0, 0);
end

local function storeMainButtonPosition ()
  addon.options.position = {mainButton:GetPoint()};
end

local function stopMovingMainButton ()
  mainButton:SetScript(ONMOUSEUP, nil);
  mainButton:SetMovable(false);
  mainButton:StopMovingOrSizing();
  storeMainButtonPosition();
end

local function moveMainButton ()
  mainButton:SetScript(ONMOUSEUP, stopMovingMainButton);
  mainButton:SetMovable(true);
  mainButton:StartMoving();
end

local function initMainButton ()
  mainButton = _G.CreateFrame('Frame', addonName .. 'Button', _G.UIParent,
      _G.BackdropTemplateMixin and 'BackdropTemplate');
  mainButton:SetParent(_G.UIParent);
  mainButton:SetFrameStrata(constants.FRAME_STRATA);
  mainButton:SetFrameLevel(constants.FRAME_LEVEL);
  setDefaultPosition();
  mainButton:SetClampedToScreen(true);
  mainButton:Show();

  mainButton:SetScript('OnMouseDown', function (_, button)
    if (button == MIDDLEBUTTON or IsAltKeyDown()) then
      moveMainButton();
    elseif (button == LEFTBUTTON) then
      toggleButtons();
    end
  end);
end

local function initButtonContainer ()
  buttonContainer = _G.CreateFrame('Frame', nil, _G.UIParent,
    _G.BackdropTemplateMixin and 'BackdropTemplate');
  buttonContainer:SetParent(mainButton);
  buttonContainer:SetFrameLevel(constants.FRAME_LEVEL);
  buttonContainer:Hide();
end

local function initLogo ()
  logo = mainButton:CreateTexture(nil, 'ARTWORK');
  logo:SetTexture('Interface\\AddOns\\' .. addonName ..
      '\\Media\\Logo.blp');

  logo:SetPoint(anchors.CENTER, mainButton, anchors.CENTER, 0, 0);
  logo:SetSize(constants.LOGO_SIZE, constants.LOGO_SIZE);
end

local function initFrames ()
  initMainButton();
  initButtonContainer();
  initLogo();
end

initFrames();

--##############################################################################
-- initialization
--##############################################################################

local function applyScale ()
  mainButton:SetScale(addon.options.scale);
end

local function restoreOptions ()
  if (addon.options.position ~= nil) then
    mainButton:ClearAllPoints();
    mainButton:SetPoint(unpack(addon.options.position));
  end

  applyScale();

  if (addon.options.buttonsShown == true) then
    buttonContainer:Show();
  end
end

local function init ()
  restoreOptions();
  collectMinimapButtonsAndUpdateLayout();
end

addon.registerEvent('PLAYER_LOGIN', function ()
  --[[ executing on next frame to wait for addons that create minimap buttons
       on PLAYER_LOGIN ]]
  executeAfter(0, init);

  return true;
end);

--##############################################################################
-- slash commands
--##############################################################################

addon.addSlashHandlerName('mbb');

local function printButtonLists ()
  addon.printAddonMessage('Buttons currently being collected:');

  for _, button in pairs(addon.shared.collectedButtons) do
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
end

addon.slash('list', printButtonLists);
addon.slash('default', printButtonLists);
addon.slash('reset', setDefaultPosition);

--##############################################################################
-- shared data
--##############################################################################

addon.shared = {
  buttonContainer = buttonContainer,
  mainButton = mainButton,
  logo = logo,
  collectedButtons = collectedButtons,
};

addon.applyScale = applyScale;
addon.collectMinimapButtonsAndUpdateLayout =
    collectMinimapButtonsAndUpdateLayout;
addon.isValidFrame = isValidFrame;
