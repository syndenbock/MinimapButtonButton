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

local Layout = {
  innerOffset = 0,
  outerOffset = 0,
};

function Layout:calculateButtonXOffset (columnCount)
  return (self.buttonWidth + constants.BUTTON_SPACING) * columnCount +
      self.innerOffset + self.buttonWidth / 2;
end

function Layout:calculateButtonYOffset (rowCount)
  return (self.buttonHeight + constants.BUTTON_SPACING) * rowCount +
      self.innerOffset + self.buttonHeight / 2;
end

function Layout:calculateButtonAreaDimension (buttonDimension, buttonCount)
  local dimension = self.innerOffset * 2 + buttonDimension;

  if (buttonCount > 1) then
    dimension = dimension + (buttonCount - 1) *
        (buttonDimension + constants.BUTTON_SPACING);
  end

  return dimension;
end

function Layout:calculateButtonAreaWidth (columnCount)
  return self:calculateButtonAreaDimension(self.buttonWidth, columnCount);
end

function Layout:calculateButtonAreaHeight (rowCount)
  return self:calculateButtonAreaDimension(self.buttonHeight, rowCount);
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

function Layout:setButtonContainerSize ()
  shared.buttonContainer:SetSize(self:calculateButtonContainerSize());
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
  local xOffset, yOffset = self:calculateButtonOffsets(rowIndex, columnIndex);

  -- using center anchor to keep buttons of different sizes aligned
  setFrameEffectiveAnchor(button, anchors.CENTER, shared.buttonContainer,
    self.buttonAnchor, xOffset + constants.BUTTON_OFFSET_X,
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

local HorizontalLayout = {};

function HorizontalLayout:calculateButtonContainerSize ()
  local buttonCount = getShownChildrenCount(shared.buttonContainer);
  local columnCount = min(buttonCount, addon.options.buttonsPerRow);
  local rowCount = ceil(buttonCount / addon.options.buttonsPerRow);

  return self:calculateButtonAreaWidth(columnCount),
      self:calculateButtonAreaHeight(rowCount);
end

function HorizontalLayout:calculateMainButtonSize ()
  local height = self:calculateMainButtonHeight();

  return calculateMainButtonRatioDimension(height), height;
end

local VerticalLayout = {};

function VerticalLayout:calculateButtonContainerSize ()
  local buttonCount = getShownChildrenCount(shared.buttonContainer);
  local rowCount = min(buttonCount, addon.options.buttonsPerRow);
  local columnCount = ceil(buttonCount / addon.options.buttonsPerRow);

  return self:calculateButtonAreaWidth(columnCount),
      self:calculateButtonAreaHeight(rowCount);
end

function VerticalLayout:calculateMainButtonSize ()
  local width = self:calculateMainButtonWidth();

  return width, calculateMainButtonRatioDimension(width);
end

local LeftDownLayout = Mixin({
  relativeAnchor = anchors.TOPLEFT,
  buttonAnchor = anchors.TOPRIGHT,
}, HorizontalLayout);

function LeftDownLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.TOPLEFT, -self.outerOffset, 0);
end

function LeftDownLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateButtonXOffset(columnIndex);
  local yOffset = -self:calculateButtonYOffset(rowIndex);

  return xOffset, yOffset;
end

local LeftUpLayout = Mixin({
  relativeAnchor = anchors.BOTTOMLEFT,
  buttonAnchor = anchors.BOTTOMRIGHT,
}, HorizontalLayout);

function LeftUpLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.BOTTOMLEFT, -self.outerOffset, 0);
end

function LeftUpLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateButtonXOffset(columnIndex);
  local yOffset = self:calculateButtonYOffset(rowIndex);

  return xOffset, yOffset;
end

local RightDownLayout = Mixin({
  relativeAnchor = anchors.TOPRIGHT,
  buttonAnchor = anchors.TOPLEFT,
}, HorizontalLayout);

function RightDownLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.TOPRIGHT, self.outerOffset, 0);
end

function RightDownLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateButtonXOffset(columnIndex);
  local yOffset = -self:calculateButtonYOffset(rowIndex);

  return xOffset, yOffset;
end

local RightUpLayout = Mixin({
  relativeAnchor = anchors.BOTTOMRIGHT,
  buttonAnchor = anchors.BOTTOMLEFT,
}, HorizontalLayout);

function RightUpLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.BOTTOMRIGHT, self.outerOffset, 0);
end

function RightUpLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateButtonXOffset(columnIndex);
  local yOffset = self:calculateButtonYOffset(rowIndex);

  return xOffset, yOffset;
end

local UpLeftLayout = Mixin({
  relativeAnchor = anchors.TOPRIGHT,
  buttonAnchor = anchors.BOTTOMRIGHT,
}, VerticalLayout);

function UpLeftLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.TOPRIGHT, 0, self.outerOffset);
end

function UpLeftLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateButtonXOffset(rowIndex);
  local yOffset = self:calculateButtonYOffset(columnIndex);

  return xOffset, yOffset;
end

local UpRightLayout = Mixin({
  relativeAnchor = anchors.TOPLEFT,
  buttonAnchor = anchors.BOTTOMLEFT,
}, VerticalLayout);

function UpRightLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.TOPLEFT, 0, self.outerOffset);
end

function UpRightLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateButtonXOffset(rowIndex);
  local yOffset = self:calculateButtonYOffset(columnIndex);

  return xOffset, yOffset;
end

local DownLeftLayout = Mixin({
  relativeAnchor = anchors.BOTTOMRIGHT,
  buttonAnchor = anchors.TOPRIGHT,
}, VerticalLayout);

function DownLeftLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.BOTTOMRIGHT, 0, -self.outerOffset);
end

function DownLeftLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = -self:calculateButtonXOffset(rowIndex);
  local yOffset = -self:calculateButtonYOffset(columnIndex);

  return xOffset, yOffset;
end

local DownRightLayout = Mixin({
  relativeAnchor = anchors.BOTTOMLEFT,
  buttonAnchor = anchors.TOPLEFT,
}, VerticalLayout);

function DownRightLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(self.buttonAnchor,
      shared.mainButton, anchors.BOTTOMLEFT, 0, -self.outerOffset);
end

function DownRightLayout:calculateButtonOffsets (rowIndex, columnIndex)
  local xOffset = self:calculateButtonXOffset(rowIndex);
  local yOffset = -self:calculateButtonYOffset(columnIndex);

  return xOffset, yOffset;
end

--##############################################################################
-- public methods
--##############################################################################

local function updateLayout ()
  if (Layout.initialized) then
    Layout:updateLayout();
  end
end

local function applyLayout (layoutMixin)
  Layout.initialized = true;
  Mixin(Layout, layoutMixin);
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

function addon.setEdgeOffsets (innerOffset, outerOffset)
  innerOffset = innerOffset or 0;
  outerOffset = outerOffset or 0;

  if (Layout.innerOffset ~= innerOffset or Layout.outerOffset ~= outerOffset) then
    Layout.innerOffset = innerOffset;
    Layout.outerOffset = outerOffset;
    updateLayout();
  end
end

addon.updateLayout = updateLayout;
