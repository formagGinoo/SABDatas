local TransformEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityTransformEvent
}

function TransformEventHandler.OnEvent(world, entity, event)
  entity:AddTask(world, ActExploreTask.Transform.new(event.Position, event.Rotation))
end

return TransformEventHandler
