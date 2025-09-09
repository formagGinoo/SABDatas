local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableRoleMove = class("AVGPlayableRoleMove", AVGPlayable)

function AVGPlayableRoleMove:OnStart()
  self.role = self.context:GetRole(self.playableData.RoleIndex)
  if not self.role then
    self.State = ACGAVGPlayableState.Finished
    return
  end
  self.role:SetVisable(true)
  if not string.isnullorempty(self.playableData.RolePos) then
    self.startPos = self.role:GetPosition()
    self.targetPos = self.role:GetPositionByName(self.playableData.RolePos)
  end
  self.duration = self.playableData.Duration
  self.curve = self.context:GetCurve(self.playableData.RoleMoveCurve)
end

function AVGPlayableRoleMove:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.duration or self.passedTime >= self.duration then
    self.role:SetPosition(self.targetPos)
    self.State = ACGAVGPlayableState.Finished
    return
  end
  local t = self.passedTime / self.duration
  t = self.curve:Evaluate(t)
  local pos = CS.UnityEngine.Vector2.Lerp(self.startPos, self.targetPos, t)
  self.role:SetPosition(pos)
end

return AVGPlayableRoleMove
