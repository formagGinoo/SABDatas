local ActExploreDelayDestroyTask = class("ActExploreDelayDestroyTask")

function ActExploreDelayDestroyTask:ctor(serverTime)
  self.serverTime = serverTime - 1
end

function ActExploreDelayDestroyTask:Update(world, entityObj, dt)
  local currentTime = TimeUtil:GetServerTimeS()
  if currentTime >= self.serverTime then
    world:DestroyObject(entityObj, 0)
    return false
  end
  return true
end

return ActExploreDelayDestroyTask
