local _, addon = ...;

local strlower = _G.strlower;

addon.shared.Layouts = {};

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

function addon.registerLayout (name, mixin)
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

function addon.setEdgeOffsets (innerOffset, outerOffset)
  innerOffset = innerOffset or 0;
  outerOffset = outerOffset or 0;

  if (layoutOptions.innerOffset ~= innerOffset or
      layoutOptions.outerOffset ~= outerOffset) then
    layoutOptions.innerOffset = innerOffset;
    layoutOptions.outerOffset = outerOffset;
    updateLayout();
  end
end

function addon.applyDefaultLayout ()
  assert(applyLayout('leftdown'), 'Default leftdown layout was not registered.');
end

addon.applyLayout = applyLayout;
addon.updateLayout = updateLayout;
