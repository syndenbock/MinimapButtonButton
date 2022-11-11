local _, addon = ...;

local modules = {};
local pendingModules = {};

local function updatePendingModule (name, module)
  local pendingModule = pendingModules[name];

  for k, v in pairs(module) do
    pendingModule[k] = v;
  end

  pendingModules[name] = nil;

  return pendingModule;
end

function addon.export (name, module)
  assert(name ~= nil);
  assert(modules[name] == nil, 'Module already exists: ' .. name);
  assert(type(module) == 'table', 'Module needs to be table: ' .. name);

  if (pendingModules[name] ~= nil) then
    module = updatePendingModule(name, module);
  end

  modules[name] = module;
  return module;
end

function addon.import (name)
  assert(name ~= nil);
  assert(modules[name] ~= nil, 'Module does not exist: ' .. name);
  return modules[name];
end

function addon.importPending (name)
  assert(name ~= nil);
  assert(modules[name] == nil, 'Module is already loaded: ' .. name);

  if (pendingModules[name] == nil) then
    pendingModules[name] = {};
  end

  return pendingModules[name];
end
