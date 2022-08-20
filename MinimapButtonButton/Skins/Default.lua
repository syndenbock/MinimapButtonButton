local _, addon = ...;

if (addon.shared.skinned == true) then return end

addon.shared.skinned = true;

local shared = addon.shared;
local constants = addon.constants;

local EDGE_INSET = 4;

shared.mainButton:SetBackdrop({
  bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
  edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
  edgeSize = constants.EDGE_SIZE,
  insets = {
    left = EDGE_INSET,
    right = EDGE_INSET,
    top = EDGE_INSET,
    bottom = EDGE_INSET,
  },
});

shared.mainButton:SetBackdropColor(addon.getUnitColor('player'));

shared.logo:SetVertexColor(0, 0, 0, 1);

shared.buttonContainer:SetBackdrop({
  bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
  edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
  edgeSize = constants.EDGE_SIZE,
  insets = {
    left = EDGE_INSET,
    right = EDGE_INSET,
    top = EDGE_INSET,
    bottom = EDGE_INSET
  },
});

shared.buttonContainer:SetBackdropColor(0, 0, 0, 1);

addon.setEdgeOffset(EDGE_INSET);
