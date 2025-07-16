local ActExplorePlaySoundTask = class("ActExplorePlaySoundTask")

function ActExplorePlaySoundTask:ctor(eventName)
  self.eventName = eventName
end

function ActExplorePlaySoundTask:OnCreate(world, entityObj)
  CS.WwiseMusicPlayer.Instance:StartPlay(self.eventName, entityObj.gameObject, nil)
end

return ActExplorePlaySoundTask
