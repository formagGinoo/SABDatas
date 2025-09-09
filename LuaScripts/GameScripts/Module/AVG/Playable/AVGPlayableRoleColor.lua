local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableRoleColor = class("AVGPlayableRoleColor", AVGPlayable)

function AVGPlayableRoleColor:OnStart()
  self.curve = self.context:GetCurve(self.playableData.RoleColorCurve)
  local roles = self.context:GetAllRoles()
  for k, r in pairs(roles) do
    if self.playableData.RoleIndex == -1 or self.playableData.RoleIndex == k then
      r:SetColor(self.playableData.RoleColor)
    end
  end
end

function AVGPlayableRoleColor:OnUpdate(dt)
  if self.passedTime == nil then
    self.passedTime = 0
  else
    self.passedTime = self.passedTime + dt
  end
  local roles = self.context:GetAllRoles()
  if 0 >= self.playableData.Duration or self.playableData.Duration <= self.passedTime then
    for k, r in pairs(roles) do
      if self.playableData.RoleIndex == -1 or self.playableData.RoleIndex == k then
        r:LerpColor(1)
      end
    end
    self.State = ACGAVGPlayableState.Finished
  else
    local p = self.curve:Evaluate(self.passedTime / self.playableData.Duration)
    for k, r in pairs(roles) do
      if self.playableData.RoleIndex == -1 or self.playableData.RoleIndex == k then
        r:LerpColor(p)
      end
    end
  end
end

return AVGPlayableRoleColor
