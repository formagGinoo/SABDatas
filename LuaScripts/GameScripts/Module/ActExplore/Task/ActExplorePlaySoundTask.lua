local ActExplorePlaySoundTask = class("ActExplorePlaySoundTask")

function ActExplorePlaySoundTask:ctor(eventName)
  self.eventName = eventName
end

function ActExplorePlaySoundTask:OnCreate(world, entityObj)
  CS.UI.UILuaHelper.StartPlaySFX(self.eventName, entityObj.gameObject)
end

return ActExplorePlaySoundTask
