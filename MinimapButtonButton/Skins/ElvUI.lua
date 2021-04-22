if (not _G.IsAddOnLoaded('ElvUI')) then return end

local _, addon = ...;

local min = _G.min;

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

  local function updateLogo ()
    local logo = addon.shared.logo;
    local size = min(addon.shared.mainButton:GetSize()) - 10;

    logo:SetVertexColor(unpack(media.rgbvaluecolor));
    logo:SetSize(size, size);
  end

  skinFrame(addon.shared.buttonContainer);
  skinFrame(addon.shared.mainButton);
  updateLogo();
end

ENGINE.valueColorUpdateFuncs[applySkin] = true;
