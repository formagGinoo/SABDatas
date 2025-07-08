local BaseComponent = require("Component/BaseComponent")
local meta = class("UpdateQueue", BaseComponent)

function meta:OnLoad(iInterval)
  self.m_iInterval = iInterval or 1
  self.m_vQueue = {}
  self.m_iCount = 0
end

function meta:setInterval(iInterval)
  self.m_iInterval = iInterval
end

function meta:add(func, ...)
  table.insert(self.m_vQueue, {
    func = func,
    params = {
      ...
    }
  })
end

function meta:addWait(func, ...)
  table.insert(self.m_vQueue, {
    func = func,
    params = {
      ...
    },
    bWait = true
  })
end

function meta:addToFrist(func, ...)
  table.insert(self.m_vQueue, 1, {
    func = func,
    params = {
      ...
    }
  })
end

function meta:addWaitToFrist(func, ...)
  table.insert(self.m_vQueue, 1, {
    func = func,
    params = {
      ...
    },
    bWait = true
  })
end

function meta:clear()
  self.m_vQueue = {}
  self.m_iCount = 0
end

function meta:isFinished()
  return #self.m_vQueue == 0
end

function meta:step()
  if self.m_vQueue[1] then
    self.m_iCount = self.m_iCount - 1
    if self.m_iCount <= 0 then
      self.m_iCount = self.m_iInterval
      local info = table.remove(self.m_vQueue, 1)
      local result = info.func(table.unpack(info.params))
      if info.bWait then
        if result then
          self:step()
        else
          table.insert(self.m_vQueue, 1, info)
        end
      end
    end
  end
end

function meta:OnUpdate()
  self:step()
end

function meta:finishAll()
  for i, v in ipairs(self.m_vQueue) do
    if v and v.func then
      v.func(unpack(v.params))
    end
  end
  self.m_vQueue = {}
end

function meta:OnDestroy()
  self:clear()
end

return meta
