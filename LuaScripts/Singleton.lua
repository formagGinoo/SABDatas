local meta = class("Singleton")
meta._instance = {}

function meta:getInstance(...)
  local name = self:getName()
  if not meta._instance[name] then
    meta._instance[name] = self.new(...)
  end
  return meta._instance[name]
end

function meta:existInstance()
  local name = self:getName()
  if meta._instance[name] then
    return true
  end
  return false
end

function meta:isInstance()
  local name = self:getName()
  if meta._instance[name] == self then
    return true
  end
  return false
end

function meta:destoryInstance()
  local name = self:getName()
  if meta._instance[name] == self then
    meta._instance[name]:dispose()
    meta._instance[name] = nil
  end
end

function meta:clearInstance()
  local name = self:getName()
  if meta._instance[name] == self then
    meta._instance[name] = nil
  end
end

return meta
