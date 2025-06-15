local _, addon = ...;

local format = _G.format;

local Utils = addon.import('Core/Utils');
local SlashCommands = addon.import('Core/SlashCommands');

local module = addon.export('Core/HelpCommands', {});

local helpers = {};

local function addHelper(command, callback)
  helpers[command] = callback;
end

function module.addHelper(commands, callback)
  if (type(commands) == 'table') then
    for _, command in ipairs(commands) do
      addHelper(command, callback);
    end
  else
    addHelper(commands, callback);
  end
end

local function printAvailableHelpers ()
  for key, value in pairs(helpers) do
    print(key);
  end
end

SlashCommands.addCommand('help', function (command, ...)
  if (command == nil) then
    Utils.printAddonMessage('Help is available for these commands:');
    printAvailableHelpers();
    return;
  end

  local helper = helpers[command];

  if (helper == nil) then
    Utils.printAddonMessage(format('No help for command %s was found. Help is available for these commands:'), command);
    printAvailableHelpers();
    return;
  end

  if (type(helper) == 'function') then
    helper(...);
  else
    Utils.printAddonMessage(helper);
  end
end);
