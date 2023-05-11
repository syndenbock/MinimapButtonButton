local _, addon = ...;

local Utils = addon.import('Core/Utils');

if (not Utils.isRetail()) then return end

local options = addon.import('Logic/Options').getAll();

local module = addon.export('Features/Enhancements', {});

_G.AddonCompartmentFrame:HookScript('OnShow', function (self)
  if (options.hidecompartment == true) then
    self:Hide();
  end
end);

function module.hideCompartmentFrame ()
  if (Utils.isRetail()) then
    _G.AddonCompartmentFrame:Hide();
  end
end

function module.showCompartmentFrame ()
  if (Utils.isRetail()) then
    _G.AddonCompartmentFrame:Show();
  end
end
