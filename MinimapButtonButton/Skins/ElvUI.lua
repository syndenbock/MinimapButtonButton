local _, addon = ...;

if (not _G.IsAddOnLoaded('ElvUI') or
    not addon.import('Skins/Main').reserveSkin()) then return end

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
  addon.import('Layouts/Main').setEdgeOffsets(2, -1);
end

addon.import('Core/Events').registerEvent('PLAYER_LOGIN', function ()
  local ENGINE = _G.ElvUI[1];

  if (ENGINE.private.skins.blizzard.enable ~= true) then
    return;
  end

  local function applySkin ()
    local Main = addon.import('Logic/Main');

    skinFrame(Main.buttonContainer, ENGINE);
    skinFrame(Main.mainButton, ENGINE);
    Main.logo:SetVertexColor(unpack(ENGINE.media.rgbvaluecolor));
  end

  applySkin();
  -- ElvUI uses strings as the key here but to not risk an overlap and to keep
  -- compatibility for users that didn't update ElvUI the function itself is
  -- used
  ENGINE.valueColorUpdateFuncs[applySkin] = applySkin;

  return true;
end);
