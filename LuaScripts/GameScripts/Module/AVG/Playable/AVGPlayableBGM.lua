local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBGM = class("AVGPlayableBGM", AVGPlayable)

function AVGPlayableBGM:OnStart()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(self.playableData.BGM)
  self.State = ACGAVGPlayableState.Finished
end

return AVGPlayableBGM
