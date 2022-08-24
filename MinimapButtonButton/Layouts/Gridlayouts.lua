local _, addon = ...;

local ceil = _G.ceil;
local min = _G.min;
local CreateFromMixins = _G.CreateFromMixins;

local constants = addon.constants;
local anchors = constants.anchors;
local shared = addon.shared;
local Base = shared.Layouts.Base;

local GridLayout = CreateFromMixins(Base);

function GridLayout:updateLayout ()
  self:updateButtonSizes();
  self:updateMainButton();
  self:updateButtonContainer();
  -- TODO you were here
  self:anchorDisplayedButtons();
end

function GridLayout:updateButtonSizes ()
  self.buttonWidth, self.buttonHeight = self:getMaximumButtonDimensions();
end

function GridLayout:updateMainButton ()
  self:setMainButtonSize(self:calculateMainButtonSize());
end

function GridLayout:calculateButtonAreaWidth (columnCount)
  return self:calculateButtonAreaDimension(self.buttonWidth, columnCount);
end

function GridLayout:calculateButtonAreaHeight (rowCount)
  return self:calculateButtonAreaDimension(self.buttonHeight, rowCount);
end

function GridLayout:calculateButtonAreaDimension (buttonDimension, buttonCount)
  local dimension = self.options.innerOffset * 2 + buttonDimension;

  if (buttonCount > 1) then
    dimension = dimension + (buttonCount - 1) *
        (buttonDimension + constants.BUTTON_SPACING);
  end

  return dimension;
end

function GridLayout:enforceMainButtonBoundaries (dimension)
  if (dimension < constants.MAINBUTTON_MIN_SIZE or
      dimension > constants.MAINBUTTON_MAX_SIZE) then
    return constants.MAINBUTTON_DEFAULT_SIZE;
  end

  return dimension;
end

function GridLayout:calculateMainButtonRatioDimension (dimension)
  return dimension * 5 / 6;
end

function GridLayout:updateButtonContainer ()
  self:setButtonContainerSize(self:calculateButtonContainerSize());
  self:anchorButtonContainer();
end

function GridLayout:calculateButtonContainerSize ()
  local columns, rows = self:calculateGridSize();

  return self:calculateButtonAreaWidth(columns),
      self:calculateButtonAreaHeight(rows);
end

function GridLayout:anchorDisplayedButtons ()
  local buttonsPerRow = addon.options.buttonsPerRow;
  local row = 0;
  local column = 0;

  self:iterateDisplayedButtons(function (button)
    if (column >= buttonsPerRow) then
      column = column - buttonsPerRow;
      row = row + 1;
    end

    self:anchorButton(button, row, column);
    column = column + 1;
  end);
end

function GridLayout:anchorButton (button, row, column)
  self:setFrameEffectiveAnchor(button, anchors.CENTER, shared.buttonContainer,
      self:getButtonAnchor(row, column));
end

function GridLayout:calculateButtonXOffset (column)
  return (self.buttonWidth + constants.BUTTON_SPACING) * column +
      self.options.innerOffset + self.buttonWidth / 2;
end

function GridLayout:calculateButtonYOffset (row)
  return (self.buttonHeight + constants.BUTTON_SPACING) * row +
      self.options.innerOffset + self.buttonHeight / 2;
end

--##############################################################################
-- Abstraction subclasses
--##############################################################################

local HorizontalLayout = CreateFromMixins(GridLayout);

function HorizontalLayout:calculateMainButtonSize ()
  local height = self:enforceMainButtonBoundaries(self:calculateButtonAreaHeight(1));

  return self:calculateMainButtonRatioDimension(height), height;
end

function HorizontalLayout:calculateGridSize ()
  local buttonCount = self:getShownButtonCount();

  return min(buttonCount, addon.options.buttonsPerRow),
      ceil(buttonCount / addon.options.buttonsPerRow);
end

local VerticalLayout = CreateFromMixins(GridLayout);

function VerticalLayout:calculateMainButtonSize ()
  local width = self:enforceMainButtonBoundaries(self:calculateButtonAreaWidth(1));

  return width, self:calculateMainButtonRatioDimension(width);
end

function VerticalLayout:calculateGridSize ()
  local buttonCount = self:getShownButtonCount();

  return ceil(buttonCount / addon.options.buttonsPerRow),
      min(buttonCount, addon.options.buttonsPerRow);
end

--##############################################################################
-- Grid layout subclasses
--##############################################################################

local LeftDownLayout = CreateFromMixins(HorizontalLayout);

function LeftDownLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.TOPRIGHT, shared.mainButton,
      anchors.TOPLEFT, -self.options.outerOffset, 0);
end

function LeftDownLayout:getButtonAnchor (row, column)
  return anchors.TOPRIGHT, -self:calculateButtonXOffset(column),
      -self:calculateButtonYOffset(row);
end

addon.registerLayout('leftdown', LeftDownLayout);

local LeftUpLayout = CreateFromMixins(HorizontalLayout);

function LeftUpLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.BOTTOMRIGHT, shared.mainButton,
      anchors.BOTTOMLEFT, -self.options.outerOffset, 0);
end

function LeftUpLayout:getButtonAnchor (row, column)
  return anchors.BOTTOMRIGHT, -self:calculateButtonXOffset(column),
      self:calculateButtonYOffset(row);
end

addon.registerLayout('leftup', LeftUpLayout);

local RightDownLayout = CreateFromMixins(HorizontalLayout);

function RightDownLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.TOPLEFT, shared.mainButton,
      anchors.TOPRIGHT, self.options.outerOffset, 0);
end

function RightDownLayout:getButtonAnchor (row, column)
  return anchors.TOPLEFT, self:calculateButtonXOffset(column),
      -self:calculateButtonYOffset(row);
end

addon.registerLayout('rightdown', RightDownLayout);

local RightUpLayout = CreateFromMixins(HorizontalLayout);

function RightUpLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.BOTTOMLEFT, shared.mainButton,
      anchors.BOTTOMRIGHT, self.options.outerOffset, 0);
end

function RightUpLayout:getButtonAnchor (row, column)
  return anchors.BOTTOMLEFT, self:calculateButtonXOffset(column),
      self:calculateButtonYOffset(row);
end

addon.registerLayout('rightup', RightUpLayout);

local UpLeftLayout = CreateFromMixins(VerticalLayout);

function UpLeftLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.BOTTOMRIGHT, shared.mainButton,
      anchors.TOPRIGHT, 0, self.options.outerOffset);
end

function UpLeftLayout:getButtonAnchor (row, column)
  return anchors.BOTTOMRIGHT, -self:calculateButtonXOffset(row),
      self:calculateButtonYOffset(column);
end

addon.registerLayout('upleft', UpLeftLayout);

local UpRightLayout = CreateFromMixins(VerticalLayout);

function UpRightLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.BOTTOMLEFT, shared.mainButton,
      anchors.TOPLEFT, 0, self.options.outerOffset);
end

function UpRightLayout:getButtonAnchor (row, column)
  return anchors.BOTTOMLEFT, self:calculateButtonXOffset(row),
      self:calculateButtonYOffset(column);
end

addon.registerLayout('upright', UpRightLayout);

local DownLeftLayout = CreateFromMixins(VerticalLayout);

function DownLeftLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.TOPRIGHT, shared.mainButton,
      anchors.BOTTOMRIGHT, 0, -self.options.outerOffset);
end

function DownLeftLayout:getButtonAnchor (row, column)
  return anchors.TOPRIGHT, -self:calculateButtonXOffset(row),
      -self:calculateButtonYOffset(column);
end

addon.registerLayout('downleft', DownLeftLayout);

local DownRightLayout = CreateFromMixins(VerticalLayout);

function DownRightLayout:anchorButtonContainer ()
  shared.buttonContainer:ClearAllPoints();
  shared.buttonContainer:SetPoint(anchors.TOPLEFT, shared.mainButton,
      anchors.BOTTOMLEFT, 0, -self.options.outerOffset);
end

function DownRightLayout:getButtonAnchor (row, column)
  return anchors.TOPLEFT, self:calculateButtonXOffset(row),
      -self:calculateButtonYOffset(column);
end

addon.registerLayout('downright', DownRightLayout);
