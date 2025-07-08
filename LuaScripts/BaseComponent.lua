local BaseObject = require("Base/BaseObject")
local meta = class("BaseComponent", BaseObject)

function meta:ctor(target)
  self.m_id = 0
  self.m_target = target
end

function meta:setId(id)
  self.m_id = id
end

function meta:getId()
  return self.m_id
end

function meta:bindFunction(sFuncName)
  if isfunction(self[sFuncName]) then
    self.m_target[sFuncName] = function(_, ...)
      return self[sFuncName](self, ...)
    end
  end
end

return meta
