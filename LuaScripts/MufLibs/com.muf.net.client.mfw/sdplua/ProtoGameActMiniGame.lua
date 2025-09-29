local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_MiniGame_PassLevel_CS = 60621
CmdId_Act_MiniGame_PassLevel_SC = 60622
CmdId_Act_MiniGame_TakeGroupReward_CS = 60623
CmdId_Act_MiniGame_TakeGroupReward_SC = 60624
CmdActMiniGameLevel = sdp.SdpStruct("CmdActMiniGameLevel")
CmdActMiniGameLevel.Definition = {
  "iLevelId",
  "iPassTime",
  "iScore",
  "iClueTime",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iPassTime = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    8,
    0
  },
  iClueTime = {
    3,
    0,
    8,
    0
  }
}
CmdActMiniGame_Status = sdp.SdpStruct("CmdActMiniGame_Status")
CmdActMiniGame_Status.Definition = {
  "mGameLevel",
  "mTakenGroup",
  mGameLevel = {
    0,
    0,
    sdp.SdpMap(8, CmdActMiniGameLevel),
    nil
  },
  mTakenGroup = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdActCfgMiniGameGameLevel = sdp.SdpStruct("CmdActCfgMiniGameGameLevel")
CmdActCfgMiniGameGameLevel.Definition = {
  "iLevelId",
  "iOpenTime",
  "iCloseTime",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iOpenTime = {
    1,
    0,
    8,
    0
  },
  iCloseTime = {
    2,
    0,
    8,
    0
  }
}
CmdActCommonCfgMiniGame = sdp.SdpStruct("CmdActCommonCfgMiniGame")
CmdActCommonCfgMiniGame.Definition = {
  "iGameType",
  "mGameLevel",
  "vClueGroup",
  iGameType = {
    0,
    0,
    8,
    0
  },
  mGameLevel = {
    1,
    0,
    sdp.SdpMap(8, CmdActCfgMiniGameGameLevel),
    nil
  },
  vClueGroup = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActCfgMiniGame = sdp.SdpStruct("CmdActCfgMiniGame")
CmdActCfgMiniGame.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgMiniGame,
    nil
  }
}
Cmd_Act_MiniGame_PassLevel_CS = sdp.SdpStruct("Cmd_Act_MiniGame_PassLevel_CS")
Cmd_Act_MiniGame_PassLevel_CS.Definition = {
  "iActivityId",
  "iLevelId",
  "iScore",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    8,
    0
  }
}
Cmd_Act_MiniGame_PassLevel_SC = sdp.SdpStruct("Cmd_Act_MiniGame_PassLevel_SC")
Cmd_Act_MiniGame_PassLevel_SC.Definition = {
  "iActivityId",
  "iLevelId",
  "iScore",
  "stLevel",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  },
  iScore = {
    3,
    0,
    8,
    0
  },
  stLevel = {
    4,
    0,
    CmdActMiniGameLevel,
    nil
  },
  vReward = {
    5,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_MiniGame_TakeGroupReward_CS = sdp.SdpStruct("Cmd_Act_MiniGame_TakeGroupReward_CS")
Cmd_Act_MiniGame_TakeGroupReward_CS.Definition = {
  "iActivityId",
  "mTakeGroupId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mTakeGroupId = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Act_MiniGame_TakeGroupReward_SC = sdp.SdpStruct("Cmd_Act_MiniGame_TakeGroupReward_SC")
Cmd_Act_MiniGame_TakeGroupReward_SC.Definition = {
  "iActivityId",
  "mTakenGroup",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mTakenGroup = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
