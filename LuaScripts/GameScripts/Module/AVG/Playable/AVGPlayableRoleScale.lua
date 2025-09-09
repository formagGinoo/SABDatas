local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableRoleScale = class("AVGPlayableRoleScale", AVGPlayable)

function AVGPlayableRoleScale:OnStart()
  self.role = self.context:GetRole(self.playableData.RoleIndex)
  if not self.role then
    self.State = ACGAVGPlayableState.Finished
    return
  end
  self.startScale = self.role:GetScale()
end

function AVGPlayableRoleScale:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if 0 >= self.playableData.Duration or self.playableData.Duration <= self.passedTime then
    self.role:SetScale(self.playableData.RoleScale)
    self.State = ACGAVGPlayableState.Finished
  else
    local t = self.passedTime / self.playableData.Duration
    local scale = self.startScale + (self.playableData.RoleScale - self.startScale) * t
    self.role:SetScale(scale)
  end
end

return AVGPlayableRoleScale
