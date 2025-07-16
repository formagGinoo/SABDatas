local ActExploreCurveFlyTask = class("ActExploreCurveFlyTask")

function ActExploreCurveFlyTask:ctor(curve, duration)
  self.curve = curve
  self.duration = duration
  self.passTime = 0
end

function ActExploreCurveFlyTask:Update(world, entityObj, dt)
  self.passTime = self.passTime + dt
  local percent = self.passTime / self.duration
  local finished = false
  if 1 <= percent then
    percent = 1
    finished = true
  end
  local transform = entityObj.gameObject.transform
  CS.BezierPathFunctions.MoveAlongPath(transform, self.curve, percent, true)
  if finished then
    world.player:AddTask(world, ActExploreTask.InteractiveChange.new(entityObj.objectID, 0, transform.position, nil, entityObj.element.m_InteractivityRange, entityObj.element.m_InteractivityType == 1))
    world.synchronizer:SyncToServer()
  end
  return not finished
end

return ActExploreCurveFlyTask
