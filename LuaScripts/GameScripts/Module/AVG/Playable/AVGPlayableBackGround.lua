local AVGPlayable = require("Module/AVG/Playable/AVGPlayable")
local AVGPlayableBackGround = class("AVGPlayableBackGround", AVGPlayable)

function AVGPlayableBackGround:DoLoad()
  self.context:AddSpriteToLoadQueue(self.playableData.BGRes)
end

function AVGPlayableBackGround:OnStart()
  self.context:SwitchBG(self.playableData.BGRes)
  self.State = ACGAVGPlayableState.Finished
end

return AVGPlayableBackGround
