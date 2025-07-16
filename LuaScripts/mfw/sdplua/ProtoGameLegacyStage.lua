local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_LegacyStage_GetInit_CS = 19351
CmdId_LegacyStage_GetInit_SC = 19352
CmdId_LegacyStage_GameLoad_CS = 19353
CmdId_LegacyStage_GameLoad_SC = 19354
CmdId_LegacyStage_GameOperate_CS = 19355
CmdId_LegacyStage_GameOperate_SC = 19356
CmdId_LegacyStage_GameEndRound_CS = 19357
CmdId_LegacyStage_GameEndRound_SC = 19358
CmdId_LegacyStage_GamePass_CS = 19359
CmdId_LegacyStage_GamePass_SC = 19360
CmdId_LegacyStage_GameReset_CS = 19361
CmdId_LegacyStage_GameReset_SC = 19362
CmdId_LegacyStage_GameRollback_CS = 19363
CmdId_LegacyStage_GameRollback_SC = 19364
CmdId_LegacyStage_TakeChapterReward_CS = 19365
CmdId_LegacyStage_TakeChapterReward_SC = 19366
CmdLegacyStageGameStep = sdp.SdpStruct("CmdLegacyStageGameStep")
CmdLegacyStageGameStep.Definition = {
  "iStepType",
  "iEntityID",
  "iPosX",
  "iPosY",
  "iExternValue1",
  "iExternValue2",
  "iExternValue3",
  iStepType = {
    0,
    0,
    8,
    0
  },
  iEntityID = {
    1,
    0,
    7,
    0
  },
  iPosX = {
    2,
    0,
    7,
    0
  },
  iPosY = {
    3,
    0,
    7,
    0
  },
  iExternValue1 = {
    4,
    0,
    7,
    0
  },
  iExternValue2 = {
    5,
    0,
    7,
    0
  },
  iExternValue3 = {
    6,
    0,
    7,
    0
  }
}
CmdLegacyStageGameRound = sdp.SdpStruct("CmdLegacyStageGameRound")
CmdLegacyStageGameRound.Definition = {
  "vStep",
  vStep = {
    0,
    0,
    sdp.SdpVector(CmdLegacyStageGameStep),
    nil
  }
}
CmdLegacyStageGame = sdp.SdpStruct("CmdLegacyStageGame")
CmdLegacyStageGame.Definition = {
  "vPassedMonster",
  "vRound",
  vPassedMonster = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vRound = {
    1,
    0,
    sdp.SdpVector(CmdLegacyStageGameRound),
    nil
  }
}
CmdLegacyStageLevel = sdp.SdpStruct("CmdLegacyStageLevel")
CmdLegacyStageLevel.Definition = {
  "iLevelId",
  "iPassTimes",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iPassTimes = {
    1,
    0,
    8,
    0
  }
}
CmdLegacyStageChapter = sdp.SdpStruct("CmdLegacyStageChapter")
CmdLegacyStageChapter.Definition = {
  "iChapterId",
  "bRewardTaken",
  iChapterId = {
    0,
    0,
    8,
    0
  },
  bRewardTaken = {
    1,
    0,
    1,
    false
  }
}
Cmd_LegacyStage_GetInit_CS = sdp.SdpStruct("Cmd_LegacyStage_GetInit_CS")
Cmd_LegacyStage_GetInit_CS.Definition = {}
Cmd_LegacyStage_GetInit_SC = sdp.SdpStruct("Cmd_LegacyStage_GetInit_SC")
Cmd_LegacyStage_GetInit_SC.Definition = {
  "mChapter",
  "mLevel",
  "vGameLevelId",
  mChapter = {
    0,
    0,
    sdp.SdpMap(8, CmdLegacyStageChapter),
    nil
  },
  mLevel = {
    1,
    0,
    sdp.SdpMap(8, CmdLegacyStageLevel),
    nil
  },
  vGameLevelId = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_LegacyStage_GameLoad_CS = sdp.SdpStruct("Cmd_LegacyStage_GameLoad_CS")
Cmd_LegacyStage_GameLoad_CS.Definition = {
  "iLevelId",
  iLevelId = {
    0,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_GameLoad_SC = sdp.SdpStruct("Cmd_LegacyStage_GameLoad_SC")
Cmd_LegacyStage_GameLoad_SC.Definition = {
  "vRound",
  vRound = {
    1,
    0,
    sdp.SdpVector(CmdLegacyStageGameRound),
    nil
  }
}
Cmd_LegacyStage_GameOperate_CS = sdp.SdpStruct("Cmd_LegacyStage_GameOperate_CS")
Cmd_LegacyStage_GameOperate_CS.Definition = {
  "iLevelId",
  "vStep",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  vStep = {
    1,
    0,
    sdp.SdpVector(CmdLegacyStageGameStep),
    nil
  }
}
Cmd_LegacyStage_GameOperate_SC = sdp.SdpStruct("Cmd_LegacyStage_GameOperate_SC")
Cmd_LegacyStage_GameOperate_SC.Definition = {}
Cmd_LegacyStage_GameEndRound_CS = sdp.SdpStruct("Cmd_LegacyStage_GameEndRound_CS")
Cmd_LegacyStage_GameEndRound_CS.Definition = {
  "iLevelId",
  iLevelId = {
    0,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_GameEndRound_SC = sdp.SdpStruct("Cmd_LegacyStage_GameEndRound_SC")
Cmd_LegacyStage_GameEndRound_SC.Definition = {}
Cmd_LegacyStage_GamePass_CS = sdp.SdpStruct("Cmd_LegacyStage_GamePass_CS")
Cmd_LegacyStage_GamePass_CS.Definition = {
  "iLevelId",
  "iWarningNum",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iWarningNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_GamePass_SC = sdp.SdpStruct("Cmd_LegacyStage_GamePass_SC")
Cmd_LegacyStage_GamePass_SC.Definition = {
  "vReward",
  "stLevel",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  stLevel = {
    1,
    0,
    CmdLegacyStageLevel,
    nil
  }
}
Cmd_LegacyStage_GameReset_CS = sdp.SdpStruct("Cmd_LegacyStage_GameReset_CS")
Cmd_LegacyStage_GameReset_CS.Definition = {
  "iLevelId",
  iLevelId = {
    0,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_GameReset_SC = sdp.SdpStruct("Cmd_LegacyStage_GameReset_SC")
Cmd_LegacyStage_GameReset_SC.Definition = {
  "iLevelId",
  iLevelId = {
    0,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_GameRollback_CS = sdp.SdpStruct("Cmd_LegacyStage_GameRollback_CS")
Cmd_LegacyStage_GameRollback_CS.Definition = {
  "iLevelId",
  "iRoundNum",
  "iStepNum",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iRoundNum = {
    1,
    0,
    8,
    0
  },
  iStepNum = {
    2,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_GameRollback_SC = sdp.SdpStruct("Cmd_LegacyStage_GameRollback_SC")
Cmd_LegacyStage_GameRollback_SC.Definition = {}
Cmd_LegacyStage_TakeChapterReward_CS = sdp.SdpStruct("Cmd_LegacyStage_TakeChapterReward_CS")
Cmd_LegacyStage_TakeChapterReward_CS.Definition = {
  "iChapterId",
  iChapterId = {
    0,
    0,
    8,
    0
  }
}
Cmd_LegacyStage_TakeChapterReward_SC = sdp.SdpStruct("Cmd_LegacyStage_TakeChapterReward_SC")
Cmd_LegacyStage_TakeChapterReward_SC.Definition = {
  "vReward",
  "iChapterId",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iChapterId = {
    1,
    0,
    8,
    0
  }
}
