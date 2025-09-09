local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableRoleFade = class("AVGPlayableRoleFade", AVGPlayable)

function AVGPlayableRoleFade:OnStart()
  self.role = self.context:GetRole(self.playableData.RoleIndex)
  if not self.role then
    self.State = ACGAVGPlayableState.Finished
    return
  end
  self.curve = self.context:GetCurve(self.playableData.RoleFadeCurve)
end

function AVGPlayableRoleFade:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.playableData.Duration or self.playableData.Duration <= self.passedTime then
    self.role:SetFade(self.curve:Evaluate(1))
    self.State = ACGAVGPlayableState.Finished
  else
    local p = self.curve:Evaluate(self.passedTime / self.playableData.Duration)
    self.role:SetFade(p)
  end
end

return AVGPlayableRoleFade
