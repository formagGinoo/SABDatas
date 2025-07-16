local ActExploreCameraAimPointReset = class("ActExploreCameraAimPointReset")
local cameraMoveSpeed = 10

function ActExploreCameraAimPointReset:ctor()
end

function ActExploreCameraAimPointReset:Update(world, entityObj, dt)
  local start = world.aimFollow.transform.position
  local endPos = entityObj.gameObject.transform.position
  local offset = CS.UnityEngine.Vector3(endPos.x - start.x, endPos.y - start.y, endPos.z - start.z)
  local distance = offset.magnitude
  local finished = false
  if 0.01 < distance then
    offset.x = offset.x / distance
    offset.y = offset.y / distance
    offset.z = offset.z / distance
    local moveDistance = dt * cameraMoveSpeed
    if distance <= moveDistance then
      moveDistance = distance
      finished = true
    end
    local newPos = CS.UnityEngine.Vector3(start.x + offset.x * moveDistance, start.y + offset.y * moveDistance, start.z + offset.z * moveDistance)
    world.aimFollow.transform.position = newPos
  else
    finished = true
  end
  if finished then
    world.aimFollow.Target = entityObj.gameObject.transform
  end
  return not finished
end

return ActExploreCameraAimPointReset
