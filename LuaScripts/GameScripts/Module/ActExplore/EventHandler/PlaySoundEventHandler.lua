local PlaySoundEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityPlaySoundEvent
}

function PlaySoundEventHandler.OnEvent(world, entity, event)
  entity:AddTask(world, ActExploreTask.PlaySound.new(event.EventName))
end

return PlaySoundEventHandler
