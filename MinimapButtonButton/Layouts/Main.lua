local _, addon = ...;

local strlower = _G.strlower;

local module = addon.export('Layouts/Main', {});

local currentLayout = nil;
local availableLayouts = {};
local layoutOptions = {
  innerOffset = 0,
  outerOffset = 0,
};

local function initLayout (mixin)
  currentLayout = (mixin:New(layoutOptions));
  currentLayout:updateLayout();
end

local function updateLayout ()
  if (currentLayout) then
    currentLayout:updateLayout();
  end
end

function module.registerLayout (name, mixin)
  name = strlower(name);
  assert(availableLayouts[name] == nil,
      'Layout with name ' .. name .. ' already exists.');

  availableLayouts[name] = mixin;
end

local function applyLayout (name)
  local mixin = availableLayouts[strlower(name)];

  if (mixin ~= nil) then
    initLayout(mixin);
    return true;
  else
    return false;
  end
end

function module.setEdgeOffsets (innerOffset, outerOffset)
  innerOffset = innerOffset or 0;
  outerOffset = outerOffset or 0;

  if (layoutOptions.innerOffset ~= innerOffset or
      layoutOptions.outerOffset ~= outerOffset) then
    layoutOptions.innerOffset = innerOffset;
    layoutOptions.outerOffset = outerOffset;
    updateLayout();
  end
end

function module.applyDefaultLayout ()
  assert(applyLayout('leftdown'), 'Default leftdown layout was not registered.');
end

module.applyLayout = applyLayout;
module.updateLayout = updateLayout;
