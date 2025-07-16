local InteroperabilityHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityInteroperability
}

function InteroperabilityHandler.OnEvent(world, entity, event)
  local player = world.player
  if player == nil then
    return
  end
  entity.Interoperability = event.Enable
  local type = 1
  if not event.Enable then
    type = 2
  end
  player:AddTask(world, ActExploreTask.InteractiveChange.new(entity.objectID, type))
end

return InteroperabilityHandler
