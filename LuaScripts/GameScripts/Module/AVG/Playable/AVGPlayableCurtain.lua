local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableCurtain = class("AVGPlayableCurtain", AVGPlayable)

function AVGPlayableCurtain:OnStart()
  self.curve = self.context:GetCurve(self.playableData.CurtainFadeCurve)
  self.context.form:SetCurtainLayer(self.playableData.CurtainLayer)
  self.color = CS.UnityEngine.Color(self.playableData.CurtainColor.r, self.playableData.CurtainColor.g, self.playableData.CurtainColor.b, self.playableData.CurtainColor.a)
end

function AVGPlayableCurtain:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.playableData.Duration or self.playableData.Duration < self.passedTime then
    local alpha = self.curve:Evaluate(1)
    self.color.a = alpha
    self.context.form:SetCurtainColor(self.color)
    self.State = ACGAVGPlayableState.Finished
  else
    local alpha = self.curve:Evaluate(self.passedTime / self.playableData.Duration)
    self.color.a = alpha
    self.context.form:SetCurtainColor(self.color)
  end
end

return AVGPlayableCurtain
