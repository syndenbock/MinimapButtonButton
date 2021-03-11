local addonName, addon = ...;

local strsplit = _G.strsplit;
local tremove = _G.tremove;
local unpack = _G.unpack;

local slashCommands = {};
local handlerCount = 0;

local function executeSlashCommand (command, ...)
  local handler = slashCommands[command];

  if (not handler) then
    return print(addonName .. ': unknown command "' .. command .. '"');
  end

  handler(...);
end

local function slashHandler (input)
  input = input or '';

  local paramList = {strsplit(' ', input)}
  local command = tremove(paramList, 1)

  command = command or 'default';
  command = command == '' and 'default' or command;

  executeSlashCommand(command, unpack(paramList));
end

local function addHandlerName (name)
  handlerCount = handlerCount + 1;
  _G['SLASH_' .. addonName .. handlerCount] = '/' .. name;
end

_G.SlashCmdList[addonName] = slashHandler;
addHandlerName(addonName);

--##############################################################################
-- public methods
--##############################################################################

addon.addSlashHandlerName = addHandlerName;

function addon.slash (command, callback)
  assert(slashCommands[command] == nil,
      addonName .. ': slash handler already exists for ' .. command);

  slashCommands[command] = callback;
end
