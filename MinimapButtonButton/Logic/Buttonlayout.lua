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

local function calculateButtonAreaWidth (layoutInfo, columnCount)
  return calculateXOffset(layoutInfo.buttonWidth, max(columnCount, 1)) +
      constants.EDGE_OFFSET * 2;
end

local function calculateButtonAreaHeight (layoutInfo, rowCount)
  return calculateYOffset(layoutInfo.buttonHeight, max(rowCount, 1)) +
    constants.EDGE_OFFSET * 2;
end

local function enforceMainButtonBoundaries (dimension)
  if (dimension < constants.MAINBUTTON_MIN_SIZE or
      dimension > constants.MAINBUTTON_MAX_SIZE) then
      return constants.MAINBUTTON_DEFAULT_SIZE;
  end

  return dimension;
end

local function updateMainButton (layoutInfo)
  shared.mainFrame:SetSize(layoutInfo.mainButtonWidth,
      layoutInfo.mainButtonHeight);
  shared.mainButton:SetSize(layoutInfo.mainButtonWidth,
      layoutInfo.mainButtonHeight);
end

local function calculateContainerWidth (layoutInfo, columnCount)
  local width;

  if (columnCount == 0) then
    width = layoutInfo.mainButtonWidth;
  else
    width = calculateButtonAreaWidth(layoutInfo, columnCount);
  end

  if (layoutInfo.isHorizontalLayout) then
    width = width + layoutInfo.mainButtonWidth;
  end

  return width;
end

local function calculateContainerHeight (layoutInfo, rowCount)
  local height;

  if (rowCount == 0) then
    height = layoutInfo.mainButtonHeight;
  else
    height = calculateButtonAreaHeight(layoutInfo, rowCount);
  end

  if (not layoutInfo.isHorizontalLayout) then
    height = height + layoutInfo.mainButtonHeight;
  end

  return height;
end

local function setButtonContainerSize (layoutInfo)
  local buttonContainer = shared.buttonContainer;
  local buttonCount = getShownChildrenCount(buttonContainer);
  local columnCount = min(buttonCount, addon.options.buttonsPerRow);
  local rowCount = ceil(buttonCount / addon.options.buttonsPerRow);

  if (layoutInfo.isHorizontalLayout) then
    buttonContainer:SetSize(calculateContainerWidth(layoutInfo, columnCount),
        calculateContainerHeight(layoutInfo, rowCount));
  else
    buttonContainer:SetSize(calculateContainerWidth(layoutInfo, rowCount),
        calculateContainerHeight(layoutInfo, columnCount));
  end
end

local function anchorButtonContainer (layoutInfo)
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(layoutInfo.relativeAnchor, shared.mainButton,
      layoutInfo.relativeAnchor, 0, 0);
end

local function updateButtonContainer (layoutInfo)
  setButtonContainerSize(layoutInfo);
  anchorButtonContainer(layoutInfo);
end

local function setFrameEffectiveAnchor (frame, anchor, parent, parentAnchor, x, y)
  frame:ClearAllPoints();
  frame:SetPoint(anchor, parent, parentAnchor, x / frame:GetScale(), y / frame:GetScale());
end

local function anchorButton (button, rowIndex, columnIndex, layoutInfo)
  local xOffset = (calculateXOffset(layoutInfo.buttonWidth, columnIndex) +
      layoutInfo.buttonWidth / 2) + constants.EDGE_OFFSET;
  local yOffset = (calculateYOffset(layoutInfo.buttonHeight, rowIndex) +
      layoutInfo.buttonHeight / 2) + constants.EDGE_OFFSET;

  if (addon.options.majorDirection == directions.LEFT or
      addon.options.minorDirection == directions.LEFT) then
    xOffset = - xOffset;
  end

  if (addon.options.majorDirection == directions.DOWN or
      addon.options.minorDirection == directions.DOWN) then
    yOffset = -yOffset;
  end

  setFrameEffectiveAnchor(button, anchors.CENTER, shared.mainButton,
    layoutInfo.anchor, xOffset + constants.BUTTON_OFFSET_X,
        yOffset + constants.BUTTON_OFFSET_Y);
end

local function reflowCollectedButtons (layoutInfo)
  local buttonsPerRow = addon.options.buttonsPerRow;
  local rowIndex = 0;
  local columnIndex = 0;
  local index = 0;

  for _, button in ipairs(shared.collectedButtons) do
    if (isButtonDisplayed(button)) then
      if (layoutInfo.isHorizontalLayout) then
        anchorButton(button, rowIndex, columnIndex, layoutInfo);
      else
        anchorButton(button, columnIndex, rowIndex, layoutInfo);
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

local function isHorizontalLayout ()
  return (addon.options.majorDirection == directions.LEFT or
      addon.options.majorDirection == directions.RIGHT);
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
      return anchors.BOTTOMRIGHT, anchors.BOTTOMLEFT;
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

  addon.printAddonMessage('invalid growth direction: ',
      majorDirection, minorDirection);
  addon.options.majorDirection = directions.LEFT;
  addon.options.minorDirection = directions.DOWN;

  return anchors.TOPLEFT, anchors.TOPRIGHT;
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

local function calculateMainButtonHeight (layoutInfo)
  return enforceMainButtonBoundaries(calculateButtonAreaHeight(layoutInfo, 1));
end

local function calculateMainButtonWidth (layoutInfo)
  return enforceMainButtonBoundaries(calculateButtonAreaWidth(layoutInfo, 1));
end

local function calculateMainButtonRatioDimension (dimension)
  return dimension * 5 / 6;
end

local function calculateMainButtonSize (layoutInfo)
  local width, height;

  if (layoutInfo.isHorizontalLayout) then
    height = calculateMainButtonHeight(layoutInfo);
    width = calculateMainButtonRatioDimension(height);
  else
    width = calculateMainButtonWidth(layoutInfo);
    height = calculateMainButtonRatioDimension(width);
  end

  return width, height;
end

local function getLayoutInfo ()
  local layoutInfo = {};

  -- Call getAnchors first as that will validate and correct directions if
  -- needed.
  layoutInfo.anchor, layoutInfo.relativeAnchor = getAnchors();
  layoutInfo.isHorizontalLayout = isHorizontalLayout();
  layoutInfo.buttonWidth, layoutInfo.buttonHeight = getMaximumButtonDimensions();
  layoutInfo.mainButtonWidth, layoutInfo.mainButtonHeight =
      calculateMainButtonSize(layoutInfo);

  return layoutInfo;
end

function addon.updateLayout ()
  local layoutInfo = getLayoutInfo();

  updateMainButton(layoutInfo);
  updateButtonContainer(layoutInfo);
  reflowCollectedButtons(layoutInfo);
end
