local _, addon = ...;

local module = addon.export('Core/Events', {});
local callbacks = {};
local eventFrame = _G.CreateFrame('frame');

local function addCallback (event, callback)
  if (callbacks[event] == nil) then
    callbacks[event] = {
      [callback] = true;
    };
    eventFrame:RegisterEvent(event);
  else
    callbacks[event][callback] = true;
  end
end

local function removeCallback (event, callback)
  callbacks[event][callback] = nil;

  if (next(callbacks[event]) == nil) then
    callbacks[event] = nil;
    eventFrame:UnregisterEvent(event);
  end
end

eventFrame:SetScript('OnEvent', function (_, event, ...)
  for callback in pairs(callbacks[event]) do
    if (callback(...) == true) then
      removeCallback(event, callback);
    end
  end
end);

--##############################################################################
-- public methods
--##############################################################################

module.registerEvent = addCallback;
module.unregisterEvent = removeCallback;
