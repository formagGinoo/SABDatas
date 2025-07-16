local ActExploreRewardFlyTask = class("ActExploreRewardFlyTask")
local duration = 1
local vEaseType = CS.DG.Tweening.Ease.OutCubic
local hEaseType = CS.DG.Tweening.Ease.InCubic

function ActExploreRewardFlyTask:ctor()
end

function ActExploreRewardFlyTask:OnCreate(world, entityObj)
  self.passTime = 0
  self.startPosition = entityObj.gameObject.transform.position
  CS.WwiseMusicPlayer.Instance:StartPlay(ActExploreRes.PickAudioEvent)
end

function ActExploreRewardFlyTask:Update(world, entityObj, dt)
  self.passTime = self.passTime + dt
  local percent = self.passTime / duration
  local finished = false
  if 1 <= percent then
    percent = 1
    finished = true
    world:TakeReward(entityObj.element)
    world:DestroyObject(entityObj, 0)
  end
  local playerPosition = world.player.gameObject.transform.position
  playerPosition.y = playerPosition.y + 1.5
  local result = CS.VisualActExploreUtil.Lerp(self.startPosition, playerPosition, percent, vEaseType, hEaseType)
  entityObj.gameObject.transform.position = result
  return not finished
end

return ActExploreRewardFlyTask
