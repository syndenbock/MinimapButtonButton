local _, addon = ...;

local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;

local config = addon.config;
local shared = addon.shared;

local directions = addon.enums.DIRECTIONS;
local anchors = addon.constants.ANCHORS;

local function isButtonDisplayed (button)
  return button.IsShown and button:IsShown();
end

local function getFrameEffectiveWidth (frame)
  return frame:GetWidth() * frame:GetScale();
end

local function getFrameEffectiveHeight (frame)
  return frame:GetHeight() * frame:GetScale();
end

local function isHorizontalLayout ()
  return (config.DIRECTION_MAJOR == directions.LEFT or
      config.DIRECTION_MAJOR == directions.RIGHT);
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
  return config.BUTTON_SPACING + (buttonWidth + config.BUTTON_SPACING) * columnCount;
end

local function calculateYOffset (buttonHeight, rowCount)
  return config.BUTTON_SPACING + (buttonHeight + config.BUTTON_SPACING) * rowCount;
end

local function calculateContainerWidth (buttonWidth, columnCount)
  if (columnCount == 0) then
    return config.BUTTON_WIDTH;
  end

  local overlap = 0;

  if (isHorizontalLayout()) then
    overlap = config.BUTTON_WIDTH;
  end

  return overlap + calculateXOffset(buttonWidth, columnCount) +
      config.EDGE_OFFSET;
end

local function calculateContainerHeight (buttonHeight, rowCount)
  if (rowCount == 0) then
    return config.BUTTON_HEIGHT;
  end

  local overlap = 0;

  if (not isHorizontalLayout()) then
    overlap = config.BUTTON_HEIGHT;
  end

  return overlap + calculateYOffset(buttonHeight, rowCount) +
      config.EDGE_OFFSET;
end

local function setButtonContainerSize (anchorInfo)
  local buttonContainer = shared.buttonContainer;
  local buttonCount = getShownChildrenCount(buttonContainer);
  local columnCount = min(buttonCount, config.BUTTONS_PER_ROW);
  local rowCount = ceil(buttonCount / config.BUTTONS_PER_ROW);

  if (anchorInfo.isHorizontalLayout) then
    buttonContainer:SetSize(calculateContainerWidth(anchorInfo.width, columnCount),
        calculateContainerHeight(anchorInfo.height, rowCount));
  else
    buttonContainer:SetSize(calculateContainerWidth(anchorInfo.width, rowCount),
        calculateContainerHeight(anchorInfo.height, columnCount));
  end

  buttonContainer:ClearAllPoints();
  buttonContainer:SetPoint(anchorInfo.relativeAnchor, shared.mainButton,
      anchorInfo.relativeAnchor, 0, 0);
end

local function setFrameEffectiveAnchor (frame, anchor, parent, parentAnchor, x, y)
  frame:ClearAllPoints();
  frame:SetPoint(anchor, parent, parentAnchor, x / frame:GetScale(), y / frame:GetScale());
end

local function anchorButton (button, rowIndex, columnIndex, anchorInfo)
  local xOffset = (calculateXOffset(anchorInfo.width, columnIndex) +
      anchorInfo.width / 2);
  local yOffset = (calculateYOffset(anchorInfo.height, rowIndex) +
      anchorInfo.height / 2);

  if (config.DIRECTION_MAJOR == directions.LEFT or
      config.DIRECTION_MINOR == directions.LEFT) then
    xOffset = - xOffset;
  end

  if (config.DIRECTION_MAJOR == directions.DOWN or
      config.DIRECTION_MINOR == directions.DOWN) then
    yOffset = -yOffset;
  end

  setFrameEffectiveAnchor(button, anchors.CENTER, shared.mainButton,
    anchorInfo.anchor, xOffset, yOffset);
end

local function reflowCollectedButtons (anchorInfo)
  local rowIndex = 0;
  local columnIndex = 0;
  local index = 0;

  for _, button in ipairs(shared.collectedButtons) do
    if (isButtonDisplayed(button)) then
      if (anchorInfo.isHorizontalLayout) then
        anchorButton(button, rowIndex, columnIndex, anchorInfo);
      else
        anchorButton(button, columnIndex, rowIndex, anchorInfo);
      end

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

local function getAnchors ()
  if (config.DIRECTION_MAJOR == directions.LEFT) then
    if (config.DIRECTION_MINOR == directions.DOWN) then
      return anchors.TOPLEFT, anchors.TOPRIGHT;
    elseif (config.DIRECTION_MINOR == directions.UP) then
      return anchors.BOTTOMLEFT, anchors.BOTTOMRIGHT;
    end
  elseif (config.DIRECTION_MAJOR == directions.RIGHT) then
    if (config.DIRECTION_MINOR == directions.DOWN) then
      return anchors.TOPRIGHT, anchors.TOPLEFT;
    elseif (config.DIRECTION_MINOR == directions.UP) then
      return anchors.TOPLEFT, anchors.TOPRIGHT;
    end
  elseif (config.DIRECTION_MAJOR == directions.UP) then
    if (config.DIRECTION_MINOR == directions.LEFT) then
      return anchors.TOPRIGHT, anchors.BOTTOMRIGHT;
    elseif (config.DIRECTION_MINOR == directions.RIGHT) then
      return anchors.TOPLEFT, anchors.BOTTOMLEFT;
    end
  elseif (config.DIRECTION_MAJOR == directions.DOWN) then
    if (config.DIRECTION_MINOR == directions.LEFT) then
      return anchors.BOTTOMRIGHT, anchors.TOPRIGHT;
    elseif (config.DIRECTION_MINOR == directions.RIGHT) then
      return anchors.BOTTOMLEFT, anchors.TOPLEFT;
    end
  end

  addon.printAddonMessage('invalid growth direction:',
      config.DIRECTION_MAJOR .. config.DIRECTION_MINOR);
  return anchors.TOPLEFT, anchors.TOPRIGHT;
end

function addon.updateLayout ()
  local buttonWidth, buttonHeight = getMaximumButtonDimensions();
  local anchor, relativeAnchor = getAnchors();
  local anchorInfo = {
    width = buttonWidth,
    height = buttonHeight,
    anchor = anchor,
    relativeAnchor = relativeAnchor,
    isHorizontalLayout = isHorizontalLayout(),
  };

  setButtonContainerSize(anchorInfo);
  reflowCollectedButtons(anchorInfo);
end
