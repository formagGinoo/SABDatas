local ActExploreTransformTask = class("ActExploreTransformTask")

function ActExploreTransformTask:ctor(position, rotaion)
  self.position = position
  self.rotation = rotaion
end

function ActExploreTransformTask:OnCreate(world, entityObj)
  entityObj.gameObject.transform:SetPositionAndRotation(self.position, self.rotation)
  if entityObj.playerController then
    entityObj.playerController:Wrap(self.position)
  end
end

return ActExploreTransformTask
