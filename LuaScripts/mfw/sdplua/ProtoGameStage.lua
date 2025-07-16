local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_Stage_GetList_CS = 10601
CmdId_Stage_GetList_SC = 10602
CmdId_Stage_EnterChallenge_CS = 10603
CmdId_Stage_EnterChallenge_SC = 10604
CmdId_Stage_GetDungeonChapterMop_CS = 10609
CmdId_Stage_GetDungeonChapterMop_SC = 10610
CmdId_Stage_MopUp_CS = 10611
CmdId_Stage_MopUp_SC = 10612
CmdId_Stage_GetStageTimes_CS = 10615
CmdId_Stage_GetStageTimes_SC = 10616
CmdId_Stage_GetStageDetail_CS = 10617
CmdId_Stage_GetStageDetail_SC = 10618
StageChapterUnlock_MainStage = 1
StageChapterUnlock_RoleLevel = 2
StageChapterUnlock_GuideStep = 3
StageChapterUnlock_TowerFinish = 4
StageChapterUnlock_MainChapter = 5
Cmd_Stage_GetList_CS = sdp.SdpStruct("Cmd_Stage_GetList_CS")
Cmd_Stage_GetList_CS.Definition = {
  "iStageType",
  iStageType = {
    0,
    0,
    8,
    0
  }
}
CmdSubStageData = sdp.SdpStruct("CmdSubStageData")
CmdSubStageData.Definition = {
  "iLastPassStageId",
  "mStageFirstFinishTime",
  iLastPassStageId = {
    0,
    0,
    8,
    0
  },
  mStageFirstFinishTime = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Stage_GetList_SC = sdp.SdpStruct("Cmd_Stage_GetList_SC")
Cmd_Stage_GetList_SC.Definition = {
  "iStageType",
  "mSubStage",
  iStageType = {
    0,
    0,
    8,
    0
  },
  mSubStage = {
    1,
    0,
    sdp.SdpMap(8, CmdSubStageData),
    nil
  }
}
Cmd_Stage_EnterChallenge_CS = sdp.SdpStruct("Cmd_Stage_EnterChallenge_CS")
Cmd_Stage_EnterChallenge_CS.Definition = {
  "iStageType",
  "iStageId",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iStageId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Stage_EnterChallenge_SC = sdp.SdpStruct("Cmd_Stage_EnterChallenge_SC")
Cmd_Stage_EnterChallenge_SC.Definition = {
  "iStageType",
  "iStageId",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iStageId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Stage_GetDungeonChapterMop_CS = sdp.SdpStruct("Cmd_Stage_GetDungeonChapterMop_CS")
Cmd_Stage_GetDungeonChapterMop_CS.Definition = {}
Cmd_Stage_GetDungeonChapterMop_SC = sdp.SdpStruct("Cmd_Stage_GetDungeonChapterMop_SC")
Cmd_Stage_GetDungeonChapterMop_SC.Definition = {
  "iTimes",
  "mRotationLevelSubType",
  iTimes = {
    0,
    0,
    8,
    0
  },
  mRotationLevelSubType = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Stage_MopUp_CS = sdp.SdpStruct("Cmd_Stage_MopUp_CS")
Cmd_Stage_MopUp_CS.Definition = {
  "iStageType",
  "iStageId",
  "iMopTimes",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iStageId = {
    1,
    0,
    8,
    0
  },
  iMopTimes = {
    2,
    0,
    8,
    0
  }
}
Cmd_Stage_MopUp_SC = sdp.SdpStruct("Cmd_Stage_MopUp_SC")
Cmd_Stage_MopUp_SC.Definition = {
  "iStageType",
  "iStageId",
  "iMopTimes",
  "vReward",
  "vExtraReward",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iStageId = {
    1,
    0,
    8,
    0
  },
  iMopTimes = {
    2,
    0,
    8,
    0
  },
  vReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vExtraReward = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Stage_GetStageTimes_CS = sdp.SdpStruct("Cmd_Stage_GetStageTimes_CS")
Cmd_Stage_GetStageTimes_CS.Definition = {
  "iType",
  "vSubType",
  iType = {
    0,
    0,
    8,
    0
  },
  vSubType = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Stage_GetStageTimes_SC = sdp.SdpStruct("Cmd_Stage_GetStageTimes_SC")
Cmd_Stage_GetStageTimes_SC.Definition = {
  "iType",
  "mTimes",
  iType = {
    0,
    0,
    8,
    0
  },
  mTimes = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdStageDetail = sdp.SdpStruct("CmdStageDetail")
CmdStageDetail.Definition = {
  "iScore",
  "iDamage",
  "iFinishNum",
  iScore = {
    0,
    0,
    10,
    "0"
  },
  iDamage = {
    1,
    0,
    10,
    "0"
  },
  iFinishNum = {
    2,
    0,
    8,
    0
  }
}
Cmd_Stage_GetStageDetail_CS = sdp.SdpStruct("Cmd_Stage_GetStageDetail_CS")
Cmd_Stage_GetStageDetail_CS.Definition = {
  "iType",
  "vStageId",
  iType = {
    0,
    0,
    8,
    0
  },
  vStageId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Stage_GetStageDetail_SC = sdp.SdpStruct("Cmd_Stage_GetStageDetail_SC")
Cmd_Stage_GetStageDetail_SC.Definition = {
  "iType",
  "mStageDetail",
  iType = {
    0,
    0,
    8,
    0
  },
  mStageDetail = {
    1,
    0,
    sdp.SdpMap(8, CmdStageDetail),
    nil
  }
}
