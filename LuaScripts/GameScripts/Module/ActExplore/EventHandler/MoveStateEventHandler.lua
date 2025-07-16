local MoveStateEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.MoveState
}

function MoveStateEventHandler.OnEvent(world, entity, event)
  world.form:SetVisable(event.Enable)
end

return MoveStateEventHandler
