local _, addon = ...;

local ipairs = _G.ipairs;
local pairs = _G.pairs;
local CreateFrame = _G.CreateFrame;
local UIParent = _G.UIParent;
local GameTooltip = _G.GameTooltip;
local GetCursorPosition = _G.GetCursorPosition;

local Main = addon.import('Logic/Main');
local Utils = addon.import('Core/Utils');
local SlashCommands = addon.import('Core/SlashCommands');
local HelpCommands = addon.import('Core/HelpCommands');
local Layout = addon.importPending('Layouts/Main');

local module = addon.export('Logic/Reorder', {});

local HIGHLIGHT_COLOR = {0.2, 0.6, 1, 0.3};
local TARGET_COLOR = {0.2, 1, 0.4, 0.55};

local active = false;
local overlays = {};
local currentTarget;
local wasShown;

local refreshOverlays;

--##############################################################################
-- ordering
--##############################################################################

local function isButtonDisplayed (button)
  return button.IsShown and button:IsShown();
end

-- Center of a frame in absolute screen pixels, so frames at different scales
-- (the dragged overlay vs. the collected buttons) can be compared directly.
local function getScreenCenter (frame)
  local x, y = frame:GetCenter();

  if (x == nil) then
    return nil;
  end

  local scale = frame:GetEffectiveScale();

  return x * scale, y * scale;
end

local function indexOf (list, value)
  for index, entry in ipairs(list) do
    if (entry == value) then
      return index;
    end
  end

  return nil;
end

-- The icon whose center is closest to the cursor (compared in screen pixels).
local function findNearestButton (draggedButton)
  local cursorX, cursorY = GetCursorPosition();
  local nearestButton;
  local nearestDistance;

  for _, button in ipairs(Main.collectedButtons) do
    -- Only named buttons take part: the saved order is keyed by name, so an
    -- anonymous button can't be a persistable drop target (see refreshOverlays).
    if (button ~= draggedButton and isButtonDisplayed(button) and button:GetName()) then
      local centerX, centerY = getScreenCenter(button);

      if (centerX) then
        local distance = (centerX - cursorX) ^ 2 + (centerY - cursorY) ^ 2;

        if (nearestDistance == nil or distance < nearestDistance) then
          nearestDistance = distance;
          nearestButton = button;
        end
      end
    end
  end

  return nearestButton;
end

-- Tints the targeted icon green so the user can see which slot the dragged icon
-- will drop into before releasing. Restores the previous target's normal tint.
local function setTarget (button)
  if (currentTarget == button) then
    return;
  end

  if (currentTarget and overlays[currentTarget]) then
    overlays[currentTarget].highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR));
  end

  currentTarget = button;

  if (button and overlays[button]) then
    overlays[button].highlight:SetColorTexture(unpack(TARGET_COLOR));
  end
end

local function finishDrag (draggedButton, targetButton)
  if (targetButton == nil) then
    return;
  end

  -- Swap the dragged icon with the highlighted target; every other icon keeps
  -- its slot.
  local buttons = Main.collectedButtons;
  local fromIndex = indexOf(buttons, draggedButton);
  local toIndex = indexOf(buttons, targetButton);

  buttons[fromIndex] = targetButton;
  buttons[toIndex] = draggedButton;

  Main.persistCurrentOrder();
  Layout.updateLayout();
end

--##############################################################################
-- drag overlays
--##############################################################################

local function createOverlay ()
  local overlay = CreateFrame('Button', nil, Main.buttonContainer);

  overlay:SetMovable(true);
  overlay:RegisterForDrag('LeftButton');

  local highlight = overlay:CreateTexture(nil, 'OVERLAY');
  highlight:SetAllPoints(overlay);
  highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR));
  overlay.highlight = highlight;

  overlay:SetScript('OnEnter', function (self)
    local button = self.button;
    local onEnter = button:GetScript('OnEnter');

    -- Forward to the button's own handler so the user sees its real tooltip;
    -- fall back to the frame name for buttons that have no tooltip of their own.
    -- pcall the third-party handler so its error can't bubble through the overlay.
    if (onEnter) then
      pcall(onEnter, button);
    else
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
      GameTooltip:SetText(button:GetName() or 'Unnamed button');
      GameTooltip:Show();
    end
  end);

  overlay:SetScript('OnLeave', function (self)
    local onLeave = self.button:GetScript('OnLeave');

    if (onLeave) then
      pcall(onLeave, self.button);
    end

    GameTooltip:Hide();
  end);

  overlay:SetScript('OnDragStart', function (self)
    GameTooltip:Hide();
    self:SetParent(UIParent);
    self:SetFrameStrata('TOOLTIP');
    self:StartMoving();
    self:SetScript('OnUpdate', function ()
      setTarget(findNearestButton(self.button));
    end);
  end);

  overlay:SetScript('OnDragStop', function (self)
    self:SetScript('OnUpdate', nil);
    self:StopMovingOrSizing();
    self:SetParent(Main.buttonContainer);

    local target = currentTarget;

    setTarget(nil);
    finishDrag(self.button, target);
    refreshOverlays();
  end);

  return overlay;
end

local function hideOverlays ()
  for _, overlay in pairs(overlays) do
    overlay:Hide();
  end
end

function refreshOverlays ()
  hideOverlays();
  currentTarget = nil;

  if (not active) then
    return;
  end

  for _, button in ipairs(Main.collectedButtons) do
    -- Skip anonymous buttons: their order can't be persisted (persistCurrentOrder
    -- / sortCollectedButtons key by name), so don't offer a reorder that won't stick.
    if (isButtonDisplayed(button) and button:GetName()) then
      local overlay = overlays[button] or createOverlay();

      overlays[button] = overlay;
      overlay.button = button;
      overlay:SetFrameStrata('HIGH');
      overlay.highlight:SetColorTexture(unpack(HIGHLIGHT_COLOR));
      overlay:ClearAllPoints();
      overlay:SetPoint('CENTER', button, 'CENTER', 0, 0);
      overlay:SetSize(button:GetWidth() * button:GetScale(),
          button:GetHeight() * button:GetScale());
      overlay:Show();
    end
  end
end

--##############################################################################
-- mode toggle
--##############################################################################

local function setActive (value)
  if (active == value) then
    return;
  end

  active = value;
  Main.setAutoCloseSuppressed(value);

  if (value) then
    -- Remember whether the container was already open so exiting arrange mode
    -- restores the prior state instead of leaving it shown (and persisted).
    wasShown = Main.buttonContainer:IsShown();

    if (not wasShown) then
      Main.showButtons();
    end

    refreshOverlays();
    Utils.printAddonMessage(
        'arrange mode ON - drag the icons to reposition them, then run the command again to finish.');
  else
    hideOverlays();

    if (not wasShown) then
      Main.hideButtons();
    end

    Utils.printAddonMessage('arrange mode OFF.');
  end
end

local function toggle ()
  setActive(not active);
end

SlashCommands.addCommand({'arrange', 'reorder'}, toggle);
HelpCommands.addHelper({'arrange', 'reorder'},
    'Toggles arrange mode (also bound to right-clicking the main button). While ' ..
    'active, drag the collected icons to reposition them; their order is saved. ' ..
    'Run the command again to finish.');

module.toggle = toggle;
module.refreshOverlays = refreshOverlays;

function module.isActive ()
  return active;
end
