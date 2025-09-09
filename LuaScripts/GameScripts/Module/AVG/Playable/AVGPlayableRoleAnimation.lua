local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableRoleAnimation = class("AVGPlayableRoleAnimation", AVGPlayable)

function AVGPlayableRoleAnimation:OnStart()
  self.role = self.context:GetRole(self.playableData.RoleIndex)
  if not self.role then
    self.State = ACGAVGPlayableState.Finished
    return
  end
  self.role:SetVisable(true)
  self.duration = self.playableData.Duration
  if not string.isnullorempty(self.playableData.RoleMoveAnimation) then
    local time = self.role:PlayAnimation(self.playableData.RoleMoveAnimation)
    if 0 < time and self.duration <= 0 then
      self.duration = time
    end
  end
end

function AVGPlayableRoleAnimation:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  if self.passedTime >= self.duration then
    self.State = ACGAVGPlayableState.Finished
  end
end

return AVGPlayableRoleAnimation
