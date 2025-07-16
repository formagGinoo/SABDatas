local ActExploreMoveObstacle = class("ActExploreMoveObstacle")

function ActExploreMoveObstacle:ctor(type, cfg)
  self.type = type
  self.cfg = cfg
end

function ActExploreMoveObstacle:OnCreate(world, entityObj)
  if self.type == 0 then
    local navMeshObstacle = entityObj.gameObject:AddComponent(typeof(CS.UnityEngine.AI.NavMeshObstacle))
    entityObj.navMeshObstacle = navMeshObstacle
    local cfg = self.cfg
    navMeshObstacle.shape = cfg.ObstacleShape
    navMeshObstacle.center = cfg.ObstacleCenter
    navMeshObstacle.size = cfg.ObstacleSize
    navMeshObstacle.height = cfg.ObstacleHeight
    navMeshObstacle.radius = cfg.ObstacleRadius
    navMeshObstacle.carving = true
  elseif self.type == 1 then
    if entityObj.navMeshObstacle ~= nil then
      entityObj.navMeshObstacle.enabled = true
    end
  elseif self.type == 2 and entityObj.navMeshObstacle ~= nil then
    entityObj.navMeshObstacle.enabled = false
  end
end

return ActExploreMoveObstacle
