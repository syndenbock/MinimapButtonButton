local _, addon = ...;

local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;

local config = addon.config;
local shared = addon.shared;

local CENTER = 'CENTER';
local TOPRIGHT = 'TOPRIGHT';

local function isButtonDisplayed (button)
  return button.IsShown and button:IsShown();
end

local function getFrameEffectiveWidth (frame)
  return frame:GetWidth() * frame:GetScale();
end

local function getFrameEffectiveHeight (frame)
  return frame:GetHeight() * frame:GetScale();
end

local function getMaximumButtonDimensions ()
  local maxWidth = 0;
  local maxHeight = 0;

  for _, button in ipairs(shared.collectedButtons) do
    if (isButtonDisplayed(button)) then
      maxWidth = max(maxWidth, getFrameEffectiveWidth(button));
      maxHeight = max(maxHeight, getFrameEffectiveHeight(button));
    end
  end

  return maxWidth, maxHeight;
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
  return getFrameEffectiveWidth(shared.mainButton) + config.BUTTON_SPACING +
      (buttonWidth + config.BUTTON_SPACING) * columnCount;
end

local function calculateYOffset (buttonHeight, rowCount)
  return config.EDGE_OFFSET + config.BUTTON_SPACING +
      (buttonHeight + config.BUTTON_SPACING) * rowCount;
end

local function calculateContainerWidth (buttonWidth, columnCount)
  return max(calculateXOffset(buttonWidth, columnCount) + config.EDGE_OFFSET,
  config.BUTTON_WIDTH * 2 - config.EDGE_OFFSET);
end

local function calculateContainerHeight (buttonHeight, rowCount)
  return max(calculateYOffset(buttonHeight, rowCount) + config.EDGE_OFFSET / 2,
  config.BUTTON_HEIGHT);
end


local function setButtonContainerSize (buttonWidth, buttonHeight)
  local buttonCount = getShownChildrenCount(shared.buttonContainer);
  local columnCount = min(buttonCount, config.BUTTONS_PER_ROW);
  local rowCount = ceil(buttonCount / config.BUTTONS_PER_ROW);

  shared.buttonContainer:SetSize(calculateContainerWidth(buttonWidth, columnCount),
      calculateContainerHeight(buttonHeight, rowCount));
end

local function setFrameEffectiveAnchor (frame, anchor, parent, parentAnchor, x, y)
  frame:ClearAllPoints();
  frame:SetPoint(anchor, parent, parentAnchor, x / frame:GetScale(), y / frame:GetScale());
end

local function anchorButton (button, rowIndex, columnIndex, buttonWidth, buttonHeight)
  local xOffset = (calculateXOffset(buttonWidth, columnIndex) + buttonWidth / 2);
  local yOffset = (calculateYOffset(buttonHeight, rowIndex) + buttonHeight / 2);

  setFrameEffectiveAnchor(button, CENTER, shared.buttonContainer,
    TOPRIGHT, -xOffset, -yOffset);
end

local function reflowCollectedButtons (buttonWidth, buttonHeight)
  local rowIndex = 0;
  local columnIndex = 0;
  local index = 0;

  for _, button in ipairs(shared.collectedButtons) do
    if (isButtonDisplayed(button)) then
      anchorButton(button, rowIndex, columnIndex, buttonWidth, buttonHeight);

      if (mod(index + 1, config.BUTTONS_PER_ROW) == 0) then
        columnIndex = 0;
        rowIndex = rowIndex + 1;
      else
        columnIndex = columnIndex + 1;
      end

      index = index + 1;
    end
  end
end

function addon.updateLayout ()
  local buttonWidth, buttonHeight = getMaximumButtonDimensions();

  setButtonContainerSize(buttonWidth, buttonHeight);
  reflowCollectedButtons(buttonWidth, buttonHeight);
end
