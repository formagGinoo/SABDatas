local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayablePostProfile = class("AVGPlayablePostProfile", AVGPlayable)

function AVGPlayablePostProfile:OnStart()
  self.context:SwitchPostProfile(self.playableData.PostProfile)
  self.State = ACGAVGPlayableState.Finished
end

return AVGPlayablePostProfile
