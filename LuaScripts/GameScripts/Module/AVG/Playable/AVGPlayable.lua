local AVGPlayable = class("AVGPlayable")
ACGAVGPlayableState = {
  None = 0,
  Playing = 1,
  Finished = 2
}

function AVGPlayable:ctor(data, context)
  self.playableData = data
  self.context = context
  self.State = ACGAVGPlayableState.None
end

function AVGPlayable:Waitable()
  return false
end

function AVGPlayable:Delay()
  return self.playableData.Delay or 0
end

function AVGPlayable:Duration()
  return self.playableData.Duration or 0
end

function AVGPlayable:DoLoad()
end

function AVGPlayable:OnClickContinue()
end

function AVGPlayable:OnStart()
end

function AVGPlayable:OnUpdate(dt)
end

function AVGPlayable:OnDestroy()
end

return AVGPlayable
