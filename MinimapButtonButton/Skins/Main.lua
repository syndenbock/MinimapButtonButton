local _, addon = ...;

local module = addon.export('Skins/Main', {});

local isSkinned = false;

function module.reserveSkin ()
  if (isSkinned == false) then
    isSkinned = true;
    return true;
  else
    return false;
  end
end
