local _, addon = ...;

local Mixin = _G.Mixin;
local mod = _G.mod;
local min = _G.min;
local max = _G.max;
local ceil = _G.ceil;
local strlower = _G.strlower;

local constants = addon.constants;
local anchors = constants.anchors;
local shared = addon.shared;

--##############################################################################
-- static Methods
--##############################################################################

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

local function enforceMainButtonBoundaries (dimension)
  if (dimension < constants.MAINBUTTON_MIN_SIZE or
      dimension > constants.MAINBUTTON_MAX_SIZE) then
      return constants.MAINBUTTON_DEFAULT_SIZE;
  end

  return dimension;
end

local function setFrameEffectiveAnchor (frame, anchor, parent, parentAnchor, x, y)
  frame:ClearAllPoints();
  frame:SetPoint(anchor, parent, parentAnchor, x / frame:GetScale(), y / frame:GetScale());
end

--##############################################################################
-- main Layout class
--##############################################################################

local Layout = {};

function Layout:calculateXOffset (columnCount)
  return (self.buttonWidth + constants.BUTTON_SPACING) * columnCount +
      constants.EDGE_OFFSET;
end

function Layout:calculateYOffset (rowCount)
  return (self.buttonHeight + constants.BUTTON_SPACING) * rowCount +
      constants.EDGE_OFFSET;
end

function Layout:calculateButtonAreaWidth (columnCount)
  return self:calculateXOffset(max(columnCount, 1)) +
      constants.EDGE_OFFSET;
end

function Layout:calculateButtonAreaHeight (rowCount)
  return self:calculateYOffset(max(rowCount, 1)) +
    constants.EDGE_OFFSET;
end

function Layout:calculateMainButtonHeight ()
  return enforceMainButtonBoundaries(self:calculateButtonAreaHeight(1));
end

function Layout:calculateMainButtonWidth ()
  return enforceMainButtonBoundaries(self:calculateButtonAreaWidth(1));
end

function Layout:updateMainButton ()
  shared.mainFrame:SetSize(self.mainButtonWidth, self.mainButtonHeight);
  shared.mainButton:SetSize(self.mainButtonWidth, self.mainButtonHeight);
end

function Layout:calculateContainerWidth (columnCount)
  local width;

  if (columnCount == 0) then
    width = self.mainButtonWidth;
  else
    width = self:calculateButtonAreaWidth(columnCount);
  end

  if (self.isHorizontalLayout) then
    width = width + self.mainButtonWidth;
  end

  return width;
end

function Layout:calculateContainerHeight (rowCount)
  local height;

  if (rowCount == 0) then
    height = self.mainButtonHeight;
  else
    height = self:calculateButtonAreaHeight(rowCount);
  end

  if (not self.isHorizontalLayout) then
    height = height + self.mainButtonHeight;
  end

  return height;
end

function Layout:setButtonContainerSize ()
  local buttonContainer = shared.buttonContainer;
  local buttonCount = getShownChildrenCount(buttonContainer);
  local columnCount = min(buttonCount, addon.options.buttonsPerRow);
  local rowCount = ceil(buttonCount / addon.options.buttonsPerRow);

  if (self.isHorizontalLayout) then
    buttonContainer:SetSize(self:calculateContainerWidth(columnCount),
        self:calculateContainerHeight(rowCount));
  else
    buttonContainer:SetSize(self:calculateContainerWidth(rowCount),
        self:calculateContainerHeight(columnCount));
  end
end

function Layout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.anchor, shared.mainButton,
      self.anchor, 0, 0);
end

function Layout:updateButtonContainer ()
  self:setButtonContainerSize();
  self:anchorButtonContainer();
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

function Layout:anchorButton (button, rowIndex, columnIndex)
  local xOffset, yOffset = self:calculateOffsets(rowIndex, columnIndex);

  setFrameEffectiveAnchor(button, self.anchor, shared.mainButton,
    self.relativeAnchor, xOffset + constants.BUTTON_OFFSET_X,
        yOffset + constants.BUTTON_OFFSET_Y);
end

function Layout:reflowCollectedButtons ()
  local buttonsPerRow = addon.options.buttonsPerRow;
  local rowIndex = 0;
  local columnIndex = 0;
  local index = 0;

  for _, button in ipairs(shared.collectedButtons) do
    if (isButtonDisplayed(button)) then
      self:anchorButton(button, rowIndex, columnIndex);

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

function Layout:updateButtonSizes ()
  self.buttonWidth, self.buttonHeight = getMaximumButtonDimensions();
  self.mainButtonWidth, self.mainButtonHeight =
      self:calculateMainButtonSize();
end

function Layout:updateLayout ()
  self:updateButtonSizes();
  self:updateMainButton();
  self:updateButtonContainer();
  self:reflowCollectedButtons();
end

local function calculateMainButtonRatioDimension (dimension)
  return dimension * 5 / 6;
end

--##############################################################################
-- Layout subclasses
--##############################################################################

local HorizontalLayout = {
  isHorizontalLayout = true,
};

function HorizontalLayout:calculateMainButtonSize ()
  local height = self:calculateMainButtonHeight();

  return calculateMainButtonRatioDimension(height), height;
end

local VerticalLayout = {
  isHorizontalLayout = false,
};

function VerticalLayout:calculateMainButtonSize ()
  local width = self:calculateMainButtonWidth();

  return width, calculateMainButtonRatioDimension(width);
end

local LeftDownLayout = Mixin({
  isHorizontalLayout = true,
  relativeAnchor = anchors.TOPLEFT,
  anchor = anchors.TOPRIGHT,
}, HorizontalLayout);

function LeftDownLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateXOffset(columnIndex);
  local yOffset = -self:calculateYOffset(rowIndex);

  return xOffset, yOffset;
end

local LeftUpLayout = Mixin({
  isHorizontalLayout = true,
  relativeAnchor = anchors.BOTTOMLEFT,
  anchor = anchors.BOTTOMRIGHT,
}, HorizontalLayout);

function LeftUpLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateXOffset(columnIndex);
  local yOffset = self:calculateYOffset(rowIndex);

  return xOffset, yOffset;
end

local RightDownLayout = Mixin({
  isHorizontalLayout = true,
  relativeAnchor = anchors.TOPRIGHT,
  anchor = anchors.TOPLEFT,
}, HorizontalLayout);

function RightDownLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateXOffset(columnIndex);
  local yOffset = -self:calculateYOffset(rowIndex);

  return xOffset, yOffset;
end

local RightUpLayout = Mixin({
  isHorizontalLayout = true,
  relativeAnchor = anchors.BOTTOMRIGHT,
  anchor = anchors.BOTTOMLEFT,
}, HorizontalLayout);

function RightUpLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateXOffset(columnIndex);
  local yOffset = self:calculateYOffset(rowIndex);

  return xOffset, yOffset;
end

local UpLeftLayout = Mixin({
  isHorizontalLayout = false,
  relativeAnchor = anchors.TOPRIGHT,
  anchor = anchors.BOTTOMRIGHT,
}, VerticalLayout);

function UpLeftLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateXOffset(rowIndex);
  local yOffset = self:calculateYOffset(columnIndex);

  return xOffset, yOffset;
end

local UpRightLayout = Mixin({
  isHorizontalLayout = false,
  relativeAnchor = anchors.TOPLEFT,
  anchor = anchors.BOTTOMLEFT,
}, VerticalLayout);

function UpRightLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateXOffset(rowIndex);
  local yOffset = self:calculateYOffset(columnIndex);

  return xOffset, yOffset;
end

local DownLeftLayout = Mixin({
  isHorizontalLayout = false,
  relativeAnchor = anchors.BOTTOMRIGHT,
  anchor = anchors.TOPRIGHT,
}, VerticalLayout);

function DownLeftLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateXOffset(rowIndex);
  local yOffset = -self:calculateYOffset(columnIndex);

  return xOffset, yOffset;
end

local DownRightLayout = Mixin({
  isHorizontalLayout = false,
  relativeAnchor = anchors.BOTTOMLEFT,
  anchor = anchors.TOPLEFT,
}, VerticalLayout);

function DownRightLayout:calculateOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateXOffset(rowIndex);
  local yOffset = -self:calculateYOffset(columnIndex);

  return xOffset, yOffset;
end

--##############################################################################
-- public methods
--##############################################################################

local function applyLayout (layoutMixin)
  Mixin(Layout, layoutMixin);
  Layout:updateLayout();
end

function addon.updateLayout ()
  Layout:updateLayout();
end

function addon.applyLayout (direction)
  local availableLayouts = {
    leftdown = LeftDownLayout,
    leftup = LeftUpLayout,
    rightup = RightUpLayout,
    rightdown = RightDownLayout,
    upleft = UpLeftLayout,
    upright = UpRightLayout,
    downleft = DownLeftLayout,
    downright = DownRightLayout,
  };
  local layoutMixin = availableLayouts[strlower(direction)];

  if (layoutMixin ~= nil) then
    applyLayout(layoutMixin);
    return true;
  else
    return false;
  end
end

function addon.applyDefaultLayout ()
  applyLayout(LeftDownLayout);
end
