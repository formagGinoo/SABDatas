local TakeRewardEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.TakeReward
}

function TakeRewardEventHandler.OnEvent(world, entity, event)
  if entity.element.m_Item.Length > 0 then
    entity:AddTask(world, ActExploreTask.RewardFly.new())
  end
end

return TakeRewardEventHandler
