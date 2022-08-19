local _, addon = ...;

if (not _G.IsAddOnLoaded('Tukui') or addon.shared.skinned == true) then return end

addon.shared.skinned = true;

local function skinFrame (frame, config)
  local media = config.Medias;
  local edgeSize = 3;

  local backdrop = {
    bgFile = media.Blank,
    edgeFile = media.Glow,
    edgeSize = edgeSize,
    insets = {
      left = edgeSize,
      right = edgeSize,
      top = edgeSize,
      bottom = edgeSize,
    }
  };

  frame:SetBackdrop(backdrop);
  frame:SetBackdropColor(unpack(media.BackdropColor));
  frame:SetBackdropBorderColor(unpack(media.BorderColor));
  addon.setEdgeOffset(4);
end

addon.registerEvent('PLAYER_LOGIN', function ()
  local CONFIG = _G.Tukui[2];

  skinFrame(addon.shared.buttonContainer, CONFIG);
  skinFrame(addon.shared.mainButton, CONFIG);
  addon.shared.logo:SetVertexColor(unpack(CONFIG.Medias.BorderColor));
  return true;
end);
