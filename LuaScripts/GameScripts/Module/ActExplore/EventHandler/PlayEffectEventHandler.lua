local PlayEffectEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityPlayEffectEvent
}

function PlayEffectEventHandler.OnEvent(world, entity, event)
  entity = world:CreateEffectObject(event.EntityID, event.EffectName)
  if event.Duration > 0 then
    world:DestroyObject(entity, event.Duration)
  end
end

return PlayEffectEventHandler
