if (not _G.IsAddOnLoaded('ElvUI')) then return end

local _, addon = ...;

local MEDIA = _G.ElvUI[1].media;

local function applySkin ()
  local backdrop = {
    bgFile = MEDIA.glossTex,
    edgeFile = MEDIA.blankTex,
    edgeSize = 1,
    insets = {
      left = 1,
      right = 1,
      top = 1,
      bottom = 1,
    },
  };

  local function skinFrame (frame)
    frame:SetBackdrop(backdrop);
    frame:SetBackdropColor(unpack(MEDIA.backdropcolor));
    frame:SetBackdropBorderColor(unpack(MEDIA.bordercolor));
  end

  skinFrame(addon.shared.buttonContainer);
  skinFrame(addon.shared.mainButton);
end

applySkin();
