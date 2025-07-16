local TeleportPlayerEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.TeleportPlayer
}

function TeleportPlayerEventHandler.OnEvent(world, entity, event)
  local cfg = world.exploreManager:FindPoint(event.PointName)
  if cfg then
    local rot = CS.UnityEngine.Quaternion.Euler(cfg.Transform.Rotation)
    world.player:AddTask(world, ActExploreTask.Transform.new(cfg.Position, rot))
  else
    log.error("活动探索传送点不存在 ： " .. event.PointName)
  end
end

return TeleportPlayerEventHandler
