local CreateInteractiveEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.CreateInteractive
}

function CreateInteractiveEventHandler.OnEvent(world, entity, event)
  world:CreateDynamicInteractive(entity, event.ID, event.FlyTime)
end

return CreateInteractiveEventHandler
