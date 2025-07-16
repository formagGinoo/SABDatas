local BlackScreenEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.BlackScreen
}

function BlackScreenEventHandler.OnEvent(world, entity, event)
  world.form:SetVisable(not event.IsStart)
end

return BlackScreenEventHandler
