local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBackGroundOffset = class("AVGPlayableBackGroundOffset", AVGPlayable)
local zeroVector2 = CS.UnityEngine.Vector2.zero

function AVGPlayableBackGroundOffset:OnStart()
  self.curve = self.context:GetCurve(self.playableData.BGMoveCurve)
  self.preValue = CS.UnityEngine.Vector2.zero
end

function AVGPlayableBackGroundOffset:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.playableData.Duration or self.playableData.Duration < self.passedTime then
    self:SetOffset(self.playableData.BGOffset)
    self.State = ACGAVGPlayableState.Finished
  else
    local p = self.curve:Evaluate(self.passedTime / self.playableData.Duration)
    local value = CS.UnityEngine.Vector2.Lerp(zeroVector2, self.playableData.BGOffset, p)
    self:SetOffset(value)
  end
end

function AVGPlayableBackGroundOffset:SetOffset(value)
  self.preValue.x = value.x - self.preValue.x
  self.preValue.y = value.y - self.preValue.y
  self.context.form:SetBGOffset(self.preValue)
  self.preValue.x = value.x
  self.preValue.y = value.y
end

return AVGPlayableBackGroundOffset
