local _, addon = ...;

local modules = {};

function addon.export (name, module)
  assert(name ~= nil);
  assert(modules[name] == nil, 'Module already exists: ' .. name);
  assert(module ~= nil, 'Cannot export nil as module: ' .. name);

  modules[name] = module;
  return module;
end

function addon.import (name)
  assert(name ~= nil);
  assert(modules[name] ~= nil, 'Module does not exist: ' .. name);

  return modules[name];
end
