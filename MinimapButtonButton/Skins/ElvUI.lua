if (not _G.IsAddOnLoaded('ElvUI')) then return end

local _, addon = ...;

local ENGINE = _G.ElvUI[1];

local function applySkin ()
  local media = ENGINE.media;
  local backdrop = {
    bgFile = media.glossTex,
    edgeFile = media.blankTex,
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
    frame:SetBackdropColor(unpack(media.backdropcolor));
    frame:SetBackdropBorderColor(unpack(media.bordercolor));
  end

  skinFrame(addon.shared.buttonContainer);
  skinFrame(addon.shared.mainButton);
end

ENGINE.valueColorUpdateFuncs[applySkin] = true;
