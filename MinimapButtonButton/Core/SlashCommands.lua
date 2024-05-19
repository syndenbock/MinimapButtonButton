local addonName, addon = ...;

local strlower = _G.strlower;
local strsplit = _G.strsplit;

local module = addon.export('Core/SlashCommands', {});

local slashCommands = {};
local handlerCount = 0;

local function executeSlashCommand (command, ...)
  local handler = slashCommands[strlower(command)];

  if (not handler) then
    return print(addonName .. ': unknown command "' .. command .. '"');
  end

  handler(...);
end

local function slashHandler (input)
  if (input == nil or input == '') then
    return executeSlashCommand('default');
  end

  executeSlashCommand(strsplit(' ', input));
end

local function addHandlerName (name)
  handlerCount = handlerCount + 1;
  _G['SLASH_' .. addonName .. handlerCount] = '/' .. name;
end

local function addCommand (command, callback)
  command = strlower(command);

  assert(type(callback) == 'function',
    addonName .. ': callback is not a function');
  assert(slashCommands[command] == nil,
      addonName .. ': slash handler already exists for ' .. command);

  slashCommands[command] = callback;
end

_G.SlashCmdList[addonName] = slashHandler;

--##############################################################################
-- public methods
--##############################################################################

module.addHandlerName = addHandlerName;

function module.addCommand (commands, callback)
  if (type(commands) == 'table') then
    for _, command in ipairs(commands) do
      addCommand(command, callback);
    end
  else
    addCommand(commands, callback);
  end
end
