local _, addon = ...;

local Utils = addon.import('Core/Utils');
local options = addon.import('Logic/Options').getAll();

local module = addon.export('Features/Enhancements', {});

local compartmentFrame = _G.AddonCompartmentFrame;

if (compartmentFrame ~= nil) then
  module.compartment = true;

  compartmentFrame:HookScript('OnShow', function (self)
    if (options.hidecompartment == true) then
      self:Hide();
    end
  end);

  function module.hideCompartmentFrame ()
    if (Utils.isRetail()) then
      compartmentFrame:Hide();
    end
  end

  function module.showCompartmentFrame ()
    if (Utils.isRetail()) then
      compartmentFrame:Show();
    end
  end
end
