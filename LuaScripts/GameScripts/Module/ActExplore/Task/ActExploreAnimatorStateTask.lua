local ActExploreAnimatorStateTask = class("ActExploreAnimatorStateTask")

function ActExploreAnimatorStateTask:ctor(stateName)
  self.stateName = stateName
end

function ActExploreAnimatorStateTask:OnCreate(world, entityObj)
  if entityObj.animator then
    entityObj.animator:CrossFadeInFixedTime(self.stateName, 0.17)
  end
end

return ActExploreAnimatorStateTask
