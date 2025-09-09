local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayablePendant = class("AVGPlayablePendant", AVGPlayable)

function AVGPlayablePendant:OnStart()
  local pendant = self.context:GetPendant(self.playableData.PendantIndex)
  if pendant == nil then
    self.State = ACGAVGPlayableState.Finished
    return
  end
  local type = self.playableData.PendantOperation
  if type == 1 then
    pendant:Show()
  elseif type == 2 then
    pendant:PlayAnimation(self.playableData.PendantAnimation)
  elseif type == 3 then
    pendant:Hide()
  elseif type == 4 then
    self.context:DestroyPendant(self.playableData.PendantIndex)
  end
end

function AVGPlayablePendant:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.playableData.Duration or self.playableData.Duration < self.passedTime then
    self.State = ACGAVGPlayableState.Finished
  end
end

return AVGPlayablePendant
