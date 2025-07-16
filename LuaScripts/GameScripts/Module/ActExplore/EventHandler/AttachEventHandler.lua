local AttachEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityAttachEvent
}

function AttachEventHandler.OnEvent(world, entity, event)
  local targetID = 0
  if event.TargetID ~= 0 then
    local target = world:FindObjectByEntityID(event.TargetID)
    if target then
      targetID = target.objectID
    end
  end
  entity:AddTask(world, ActExploreTask.Attach.new(targetID, event.AttachNode, event.Position, event.Rotation))
end

return AttachEventHandler
