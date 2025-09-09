local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBackGroundColor = class("AVGPlayableBackGroundColor", AVGPlayable)

function AVGPlayableBackGroundColor:OnStart()
  self.curve = self.context:GetCurve(self.playableData.BGColorCurve)
  self.context.form:SetBGColor(self.playableData.BGColor)
end

function AVGPlayableBackGroundColor:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  local roles = self.context:GetAllRoles()
  if 0 >= self.playableData.Duration or self.playableData.Duration <= self.passedTime then
    self.context.form:LerpBGColor(1)
    self.State = ACGAVGPlayableState.Finished
  else
    local p = self.curve:Evaluate(self.passedTime / self.playableData.Duration)
    self.context.form:LerpBGColor(p)
  end
end

return AVGPlayableBackGroundColor
