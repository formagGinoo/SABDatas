local CounterChangeEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityCounterChange
}

function CounterChangeEventHandler.OnEvent(world, entity, event)
  world.synchronizer:OnCounterChange(entity.UID, event.Name, event.Value)
end

return CounterChangeEventHandler
