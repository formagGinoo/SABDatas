local SetMoveObstacleHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntitySetMoveObstacle
}

function SetMoveObstacleHandler.OnEvent(world, entity, event)
  if event.Enable then
    entity.ObstacleDisable = false
    world.exploreManager.SceneSDF:SetObstacleActive(entity.UID, true)
  else
    world.exploreManager.SceneSDF:SetObstacleActive(entity.UID, false)
    entity.ObstacleDisable = true
  end
end

return SetMoveObstacleHandler
