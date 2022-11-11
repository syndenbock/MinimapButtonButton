local _, addon = ...;

local max = _G.max;
local Mixin = _G.Mixin;

local Constants = addon.import('Logic/Constants');
local Main = addon.import('Logic/Main');
local Layout = addon.export('Layouts/LayoutBase', {});

local ClearAllPoints = _G.UIParent.ClearAllPoints;
local SetPoint = _G.UIParent.SetPoint;

function Layout:New (options)
  return Mixin({
    options = options,
  }, self);
end

function Layout:isButtonDisplayed (button)
  return button.IsShown and button:IsShown();
end

function Layout:iterateDisplayedButtons (callback)
  for index, button in ipairs(Main.collectedButtons) do
    if (self:isButtonDisplayed(button)) then
      callback(button, index);
    end
  end
end

function Layout:getShownButtonCount ()
  local count = 0;

  self:iterateDisplayedButtons(function ()
    count = count + 1;
  end);

  return count;
end

function Layout:getMaximumButtonDimensions ()
  local maxWidth = 0;
  local maxHeight = 0;

  self:iterateDisplayedButtons(function (button)
    maxWidth = max(maxWidth, self:getFrameEffectiveWidth(button));
    maxHeight = max(maxHeight, self:getFrameEffectiveHeight(button));
  end);

  if (maxWidth == 0) then
    maxWidth = Constants.MAINBUTTON_MIN_SIZE;
  end

  if (maxHeight == 0) then
    maxHeight = Constants.MAINBUTTON_MIN_SIZE;
  end

  return maxWidth, maxHeight;
end

function Layout:getFrameEffectiveWidth (frame)
  return frame:GetWidth() * frame:GetScale();
end

function Layout:getFrameEffectiveHeight (frame)
  return frame:GetHeight() * frame:GetScale();
end

function Layout:setMainButtonSize (width, height)
  Main.mainButton:SetSize(width, height);
end

function Layout:setButtonContainerSize (width, height)
  Main.buttonContainer:SetSize(width, height);
end

function Layout:setFrameEffectiveAnchor (frame, anchor, parent, parentAnchor, x, y)
  -- Using deferred methods here because we have overriden the collected buttons
  -- methods to prevent other addons from moving them
  ClearAllPoints(frame);
  SetPoint(frame, anchor, parent, parentAnchor, x / frame:GetScale(),
      y / frame:GetScale());
end
