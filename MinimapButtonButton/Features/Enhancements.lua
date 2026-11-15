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
    compartmentFrame:Hide();
  end

  function module.showCompartmentFrame ()
    compartmentFrame:Show();
  end
end
