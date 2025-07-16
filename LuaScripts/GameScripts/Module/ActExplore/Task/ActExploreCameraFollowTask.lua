local ActExploreCameraFollowTask = class("ActExploreCameraFollowTask")

function ActExploreCameraFollowTask:ctor()
end

function ActExploreCameraFollowTask:OnCreate(world, entityObj)
  world.aimFollow.Target = entityObj.gameObject.transform
end

return ActExploreCameraFollowTask
