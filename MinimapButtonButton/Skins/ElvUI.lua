if (not _G.IsAddOnLoaded('ElvUI')) then return end

local _, addon = ...;

local function skinFrame (frame, engine)
  local media = engine.media;
  local edgeSize = 1;
  local backdrop = {
    bgFile = media.glossTex,
    edgeFile = media.blankTex,
    edgeSize = edgeSize,
    insets = {
      left = edgeSize,
      right = edgeSize,
      top = edgeSize,
      bottom = edgeSize,
    },
  };

  frame:SetBackdrop(backdrop);
  frame:SetBackdropColor(unpack(media.backdropcolor));
  frame:SetBackdropBorderColor(unpack(media.bordercolor));
  addon.setEdgeOffset(4);
end

addon.registerEvent('PLAYER_LOGIN', function ()
  local ENGINE = _G.ElvUI[1];

  if (ENGINE.private.skins.blizzard.enable ~= true) then
    return;
  end

  local function applySkin ()
    skinFrame(addon.shared.buttonContainer, ENGINE);
    skinFrame(addon.shared.mainButton, ENGINE);
    addon.shared.logo:SetVertexColor(unpack(ENGINE.media.rgbvaluecolor));
  end

  applySkin();
  ENGINE.valueColorUpdateFuncs[applySkin] = true;

  return true;
end);
