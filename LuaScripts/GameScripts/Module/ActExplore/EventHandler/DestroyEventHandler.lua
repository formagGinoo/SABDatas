local DestroyEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityDestroyEvent
}

function DestroyEventHandler.OnEvent(world, entity, event)
  world:DestroyObject(entity)
end

return DestroyEventHandler
