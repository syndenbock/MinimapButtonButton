local _, addon = ...;

local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;

local constants = addon.constants;
local shared = addon.shared;

local directions = constants.directions;
local anchors = constants.anchors;

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
  return (addon.options.majorDirection == directions.LEFT or
      addon.options.majorDirection == directions.RIGHT);
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
  return constants.BUTTON_SPACING + constants.EDGE_OFFSET +
      (buttonWidth + constants.BUTTON_SPACING) * columnCount;
end

local function calculateYOffset (buttonHeight, rowCount)
  return constants.BUTTON_SPACING + constants.EDGE_OFFSET +
      (buttonHeight + constants.BUTTON_SPACING) * rowCount;
end

local function calculateContainerWidth (buttonWidth, columnCount)
  if (columnCount == 0) then
    return constants.BUTTON_WIDTH;
  end

  local overlap = 0;

  if (isHorizontalLayout()) then
    overlap = constants.BUTTON_WIDTH;
  end

  return overlap + calculateXOffset(buttonWidth, columnCount) +
      constants.EDGE_OFFSET;
end

local function calculateContainerHeight (buttonHeight, rowCount)
  if (rowCount == 0) then
    return constants.BUTTON_HEIGHT;
  end

  local overlap = 0;

  if (not isHorizontalLayout()) then
    overlap = constants.BUTTON_HEIGHT;
  end

  return overlap + calculateYOffset(buttonHeight, rowCount) +
      constants.EDGE_OFFSET;
end

local function setButtonContainerSize (anchorInfo)
  local buttonContainer = shared.buttonContainer;
  local buttonCount = getShownChildrenCount(buttonContainer);
  local columnCount = min(buttonCount, addon.options.buttonsPerRow);
  local rowCount = ceil(buttonCount / addon.options.buttonsPerRow);

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

  if (addon.options.majorDirection == directions.LEFT or
      addon.options.minorDirection == directions.LEFT) then
    xOffset = - xOffset;
  end

  if (addon.options.majorDirection == directions.DOWN or
      addon.options.minorDirection == directions.DOWN) then
    yOffset = -yOffset;
  end

  setFrameEffectiveAnchor(button, anchors.CENTER, shared.mainButton,
    anchorInfo.anchor, xOffset + constants.BUTTON_OFFSET_X,
        yOffset + constants.BUTTON_OFFSET_Y);
end

local function reflowCollectedButtons (anchorInfo)
  local buttonsPerRow = addon.options.buttonsPerRow;
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

      if (mod(index + 1, buttonsPerRow) == 0) then
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
  local majorDirection = addon.options.majorDirection;
  local minorDirection = addon.options.minorDirection;

  if (majorDirection == directions.LEFT) then
    if (minorDirection == directions.DOWN) then
      return anchors.TOPLEFT, anchors.TOPRIGHT;
    elseif (minorDirection == directions.UP) then
      return anchors.BOTTOMLEFT, anchors.BOTTOMRIGHT;
    end
  elseif (majorDirection == directions.RIGHT) then
    if (minorDirection == directions.DOWN) then
      return anchors.TOPRIGHT, anchors.TOPLEFT;
    elseif (minorDirection == directions.UP) then
      return anchors.TOPLEFT, anchors.TOPRIGHT;
    end
  elseif (majorDirection == directions.UP) then
    if (minorDirection == directions.LEFT) then
      return anchors.TOPRIGHT, anchors.BOTTOMRIGHT;
    elseif (minorDirection == directions.RIGHT) then
      return anchors.TOPLEFT, anchors.BOTTOMLEFT;
    end
  elseif (majorDirection == directions.DOWN) then
    if (minorDirection == directions.LEFT) then
      return anchors.BOTTOMRIGHT, anchors.TOPRIGHT;
    elseif (minorDirection == directions.RIGHT) then
      return anchors.BOTTOMLEFT, anchors.TOPLEFT;
    end
  end

  addon.printAddonMessage('invalid growth direction:',
      majorDirection .. minorDirection);
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

function addon.updateLayoutIfShown ()
  if (addon.shared.buttonContainer:IsShown()) then
    addon.updateLayout();
  end
end
