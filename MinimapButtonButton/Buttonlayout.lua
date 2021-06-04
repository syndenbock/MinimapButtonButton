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
  return (buttonWidth + constants.BUTTON_SPACING) * columnCount;
end

local function calculateYOffset (buttonHeight, rowCount)
  return (buttonHeight + constants.BUTTON_SPACING) * rowCount;
end

local function calculateButtonAreaWidth (anchorInfo, columnCount)
  return calculateXOffset(anchorInfo.width, max(columnCount, 1)) +
      constants.EDGE_OFFSET * 2;
end

local function calculateButtonAreaHeight (anchorInfo, rowCount)
  return calculateYOffset(anchorInfo.height, max(rowCount, 1)) +
    constants.EDGE_OFFSET * 2;
end

local function enforceMainButtonBoundaries (dimension)
  if (dimension < constants.MAINBUTTON_MIN_SIZE or
      dimension > constants.MAINBUTTON_MAX_SIZE) then
      return constants.MAINBUTTON_DEFAULT_SIZE;
  end

  return dimension;
end

local function setMainButtonSize (anchorInfo)
  shared.mainFrame:SetSize(anchorInfo.mainButtonWidth,
      anchorInfo.mainButtonHeight);
  shared.mainButton:SetSize(anchorInfo.mainButtonWidth,
      anchorInfo.mainButtonHeight);
end

local function calculateContainerWidth (anchorInfo, columnCount)
  local width;

  if (columnCount == 0) then
    width = anchorInfo.mainButtonWidth;
  else
    width = calculateButtonAreaWidth(anchorInfo, columnCount);
  end

  if (anchorInfo.isHorizontalLayout) then
    width = width + anchorInfo.mainButtonWidth;
  end

  return width;
end

local function calculateContainerHeight (anchorInfo, rowCount)
  local height;

  if (rowCount == 0) then
    height = anchorInfo.mainButtonHeight;
  else
    height = calculateButtonAreaHeight(anchorInfo, rowCount);
  end

  if (not anchorInfo.isHorizontalLayout) then
    height = height + anchorInfo.mainButtonHeight;
  end

  return height;
end

local function setButtonContainerSize (anchorInfo)
  local buttonContainer = shared.buttonContainer;
  local buttonCount = getShownChildrenCount(buttonContainer);
  local columnCount = min(buttonCount, addon.options.buttonsPerRow);
  local rowCount = ceil(buttonCount / addon.options.buttonsPerRow);

  if (anchorInfo.isHorizontalLayout) then
    buttonContainer:SetSize(calculateContainerWidth(anchorInfo, columnCount),
        calculateContainerHeight(anchorInfo, rowCount));
  else
    buttonContainer:SetSize(calculateContainerWidth(anchorInfo, rowCount),
        calculateContainerHeight(anchorInfo, columnCount));
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
      anchorInfo.width / 2) + constants.EDGE_OFFSET;
  local yOffset = (calculateYOffset(anchorInfo.height, rowIndex) +
      anchorInfo.height / 2) + constants.EDGE_OFFSET;

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

local function getAnchorInfo ()
  local buttonWidth, buttonHeight = getMaximumButtonDimensions();
  local anchor, relativeAnchor = getAnchors();

  return {
    width = buttonWidth,
    height = buttonHeight,
    anchor = anchor,
    relativeAnchor = relativeAnchor,
    isHorizontalLayout = isHorizontalLayout(),
  };
end

local function calculateMainButtonHeight (anchorInfo)
  return enforceMainButtonBoundaries(calculateButtonAreaHeight(anchorInfo, 1));
end

local function calculateMainButtonWidth (anchorInfo)
  return enforceMainButtonBoundaries(calculateButtonAreaWidth(anchorInfo, 1));
end

local function calculateMainButtonRatioDimension (dimension)
  return dimension * 5 / 6;
end

local function calculateMainButtonSize (anchorInfo)
  local width, height;

  if (anchorInfo.isHorizontalLayout == true) then
    height = calculateMainButtonHeight(anchorInfo);
    width = calculateMainButtonRatioDimension(height);
  else
    width = calculateMainButtonWidth(anchorInfo);
    height = calculateMainButtonRatioDimension(width);
  end

  return width, height;
end

local function getAnchorAndMainButtonInfo ()
  local anchorInfo = getAnchorInfo();
  local buttonWidth, buttonHeight = calculateMainButtonSize(anchorInfo);

  anchorInfo.mainButtonWidth = buttonWidth;
  anchorInfo.mainButtonHeight = buttonHeight;

  return anchorInfo;
end

function addon.updateLayout ()
  local anchorInfo = getAnchorAndMainButtonInfo();

  setMainButtonSize(anchorInfo);
  setButtonContainerSize(anchorInfo);
  reflowCollectedButtons(anchorInfo);
end

function addon.reflowButtons ()
  reflowCollectedButtons(getAnchorInfo());
end
