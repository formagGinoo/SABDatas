local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableRoleFace = class("AVGPlayableRoleFace", AVGPlayable)

function AVGPlayableRoleFace:DoLoad()
  local role = self.context:GetRole(self.playableData.RoleIndex)
  if role then
    role:LoadFaceRes(self.playableData.Face)
  end
end

function AVGPlayableRoleFace:OnStart()
  local role = self.context:GetRole(self.playableData.RoleIndex)
  if role then
    role:PlayFace(self.playableData.Face)
  end
  self.State = ACGAVGPlayableState.Finished
end

return AVGPlayableRoleFace
