local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBackGroundScale = class("AVGPlayableBackGroundScale", AVGPlayable)

function AVGPlayableBackGroundScale:OnStart()
  self.curve = self.context:GetCurve(self.playableData.BGScaleCurve)
  self.startScale = self.context.form:GetBGScale()
end

function AVGPlayableBackGroundScale:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.playableData.Duration or self.playableData.Duration < self.passedTime then
    self.context.form:SetBGScale(self.playableData.BGScale)
    self.State = ACGAVGPlayableState.Finished
  else
    local p = self.curve:Evaluate(self.passedTime / self.playableData.Duration)
    local scale = self.startScale + (self.playableData.BGScale - self.startScale) * p
    self.context.form:SetBGScale(scale)
  end
end

return AVGPlayableBackGroundScale
