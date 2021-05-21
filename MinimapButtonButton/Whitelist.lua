local _, addon = ...;

local format = _G.format;

addon.slash('include', function (buttonName)
  if (buttonName == nil) then
    addon.printAddonMessage('Please add a button name');
    return;
  end

  if (_G[buttonName] == nil) then
    addon.printAddonMessage(format('No frame named "%s" was found.', buttonName));
    return;
  end

  addon.options.whitelist[buttonName] = true;
  addon.printReloadMessage(format('Button "%s" is now manually being collected.',
      buttonName));
end);

addon.slash('uninclude', function (buttonName)
  if (buttonName == nil) then
    addon.printAddonMessage('Please add a button name');
    return;
  end

  if (addon.options.whitelist[buttonName] == nil) then
    addon.printAddonMessage(format(
        'No button named "%s" is currently being manually collected.', buttonName));
    return;
  end

  addon.options.whitelist[buttonName] = nil;
  addon.printReloadMessage(format('Button "%s" is no longer being collected manually.',
      buttonName));
end);

addon.slash('unincludeall', function ()
  if (next(addon.options.whitelist) == nil) then
    addon.printAddonMessage('No buttons are currently being manually collected.');
    return;
  end

  addon.options.whitelist = {};
  addon.printReloadMessage('No more buttons are being manually collected.');
end);
