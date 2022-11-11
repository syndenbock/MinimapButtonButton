local _, addon = ...;

if (not addon.import('Skins/Main').reserveSkin()) then return end

local Constants = addon.import('Logic/Constants');
local Main = addon.import('Logic/Main');

local EDGE_INSET = 4;

Main.mainButton:SetBackdrop({
  bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
  edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
  edgeSize = Constants.EDGE_SIZE,
  insets = {
    left = EDGE_INSET,
    right = EDGE_INSET,
    top = EDGE_INSET,
    bottom = EDGE_INSET,
  },
});

Main.mainButton:SetBackdropColor(addon.import('Core/Utils').getUnitColor('player'));

Main.logo:SetVertexColor(0, 0, 0, 1);

Main.buttonContainer:SetBackdrop({
  bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
  edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
  edgeSize = Constants.EDGE_SIZE,
  insets = {
    left = EDGE_INSET,
    right = EDGE_INSET,
    top = EDGE_INSET,
    bottom = EDGE_INSET
  },
});

Main.buttonContainer:SetBackdropColor(0, 0, 0, 1);

addon.import('Layouts/Main').setEdgeOffsets(EDGE_INSET, -2);
