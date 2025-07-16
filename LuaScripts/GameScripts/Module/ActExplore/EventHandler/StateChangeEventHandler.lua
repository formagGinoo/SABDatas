local StateChangeEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityStateChangeEvent
}

function StateChangeEventHandler.OnEvent(world, entity, event)
  local enable = event.State == CS.LogicActExplore.ActExploreEntityState.Active
  if enable then
    world:DoEntityLoad(entity)
    world.exploreManager.SceneSDF:SetObstacleActive(entity.UID, not entity.ObstacleDisable)
  else
    world.exploreManager.SceneSDF:SetObstacleActive(entity.UID, false)
  end
  entity.enable = enable
  entity:AddTask(world, ActExploreTask.Active.new(enable))
  local player = world.player
  if player == nil then
    return
  end
  local type = 1
  if not enable or not entity.Interoperability then
    type = 2
  end
  player:AddTask(world, ActExploreTask.InteractiveChange.new(entity.objectID, type))
end

return StateChangeEventHandler
