local ActExploreActiveTask = class("ActExploreActiveTask")

function ActExploreActiveTask:ctor(isActive)
  self.isActive = isActive
end

function ActExploreActiveTask:OnCreate(world, entityObj)
  entityObj.gameObject:SetActive(self.isActive)
end

return ActExploreActiveTask
