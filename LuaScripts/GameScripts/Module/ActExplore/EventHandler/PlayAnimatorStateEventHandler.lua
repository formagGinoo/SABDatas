local PlayAnimatorStateEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityPlayAnimatorState
}

function PlayAnimatorStateEventHandler.OnEvent(world, entity, event)
  entity:AddTask(world, ActExploreTask.AnimatorState.new(event.State))
end

return PlayAnimatorStateEventHandler
