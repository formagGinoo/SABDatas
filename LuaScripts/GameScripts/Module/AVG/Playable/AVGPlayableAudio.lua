local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableAudio = class("AVGPlayableAudio", AVGPlayable)

function AVGPlayableAudio:OnStart()
  self.context:PlaySound(self.playableData.AudioEvent)
  self.State = ACGAVGPlayableState.Finished
end

return AVGPlayableAudio
