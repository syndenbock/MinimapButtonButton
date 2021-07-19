local _, addon = ...;

local format = _G.format;

function addon.isBlacklisted (frame)
  local frameName = addon.getFrameName(frame);

  return (frameName ~= nil and
      addon.options.blacklist[frameName] == true);
end

addon.slash('ignore', function (...)
  if (... == nil) then
    addon.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = addon.concatButtonName(...);

  if (_G[buttonName] == nil) then
    addon.printAddonMessage(format('No frame named "%s" was found.', buttonName));
    return;
  end

  addon.options.blacklist[buttonName] = true;
  addon.printReloadMessage(format('Button "%s" is now being ignored.', buttonName));
end);

addon.slash('unignore', function (...)
  if (... == nil) then
    addon.printAddonMessage('Please add a button name');
    return;
  end

  local buttonName = addon.concatButtonName(...);

  if (addon.options.blacklist[buttonName] == nil) then
    addon.printAddonMessage(format('Button "%s" is not being ignored.', buttonName));
    return;
  end

  addon.options.blacklist[buttonName] = nil;
  addon.collectMinimapButtons();

  addon.printAddonMessage(format('Button "%s" is no longer being ignored.',
      buttonName));
end);

addon.slash('unignoreall', function ()
  if (next(addon.options.blacklist) == nil) then
    addon.printAddonMessage('No buttons are currently being ignored.');
    return;
  end

  addon.options.blacklist = {};
  addon.printReloadMessage('No more buttons are being ignored.');
end);
