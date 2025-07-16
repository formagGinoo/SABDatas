local SetIconEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntitySetIcon
}

function SetIconEventHandler.OnEvent(world, entity, event)
  entity:AddTask(world, ActExploreTask.SetIcon.new(event.Name))
end

return SetIconEventHandler
