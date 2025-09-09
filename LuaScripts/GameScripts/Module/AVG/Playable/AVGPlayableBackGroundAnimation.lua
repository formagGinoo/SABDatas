local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBackGroundAnimation = class("AVGPlayableBackGroundAnimation", AVGPlayable)

function AVGPlayableBackGroundAnimation:OnStart()
  self.duration = self.context.form:PlayBGAnimation(self.playableData.BGAnimation)
  if self.playableData.Duration > 0 then
    self.duration = self.playableData.Duration
  end
end

function AVGPlayableBackGroundAnimation:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if self.passedTime >= self.duration then
    self.State = ACGAVGPlayableState.Finished
  end
end

return AVGPlayableBackGroundAnimation
