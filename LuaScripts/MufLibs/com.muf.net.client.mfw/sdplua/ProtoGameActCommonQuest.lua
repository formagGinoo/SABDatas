local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_CommonQuest_TakeDailyReward_CS = 59831
CmdId_Act_CommonQuest_TakeDailyReward_SC = 59832
CmdId_Act_CommonQuest_TakeFinalReward_CS = 59833
CmdId_Act_CommonQuest_TakeFinalReward_SC = 59834
CmdActCommonQuest_Status = sdp.SdpStruct("CmdActCommonQuest_Status")
CmdActCommonQuest_Status.Definition = {
  "iActivityId",
  "iBeginTime",
  "iEndTime",
  "vTakenDailyReward",
  "vTakenFinalReward",
  "vQuest",
  "vOver",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBeginTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  },
  vTakenDailyReward = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  vTakenFinalReward = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  },
  vQuest = {
    5,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  vOver = {
    6,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActCfgCommonQuestQuest = sdp.SdpStruct("CmdActCfgCommonQuestQuest")
CmdActCfgCommonQuestQuest.Definition = {
  "iId",
  "iObjectiveType",
  "sObjectiveData",
  "iObjectiveCount",
  "iScore",
  "vReward",
  "iOpenDay",
  "iJump",
  "sName",
  "iSpecialType",
  iId = {
    0,
    0,
    8,
    0
  },
  iObjectiveType = {
    1,
    0,
    8,
    0
  },
  sObjectiveData = {
    2,
    0,
    13,
    ""
  },
  iObjectiveCount = {
    3,
    0,
    8,
    0
  },
  iScore = {
    4,
    0,
    8,
    0
  },
  vReward = {
    5,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iOpenDay = {
    6,
    0,
    8,
    0
  },
  iJump = {
    7,
    0,
    8,
    0
  },
  sName = {
    8,
    0,
    13,
    ""
  },
  iSpecialType = {
    9,
    0,
    8,
    0
  }
}
CmdActCfgCommonQuestDailyReward = sdp.SdpStruct("CmdActCfgCommonQuestDailyReward")
CmdActCfgCommonQuestDailyReward.Definition = {
  "iOpenDay",
  "iNeedScore",
  "vReward",
  iOpenDay = {
    0,
    0,
    8,
    0
  },
  iNeedScore = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdActCfgCommonQuest = sdp.SdpStruct("CmdActCfgCommonQuest")
CmdActCfgCommonQuest.Definition = {
  "sHelpTips",
  "mailTemplate",
  "mQuest",
  "mDailyReward",
  "mFinalReward",
  "sTitleWordColor",
  "sSubtitleWordColor",
  "sBgPic",
  "sAtmosphericAnimation",
  "sSignInFloorPlan",
  "iUiType",
  "iLamiaActId",
  sHelpTips = {
    0,
    0,
    13,
    ""
  },
  mailTemplate = {
    1,
    0,
    8,
    0
  },
  mQuest = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgCommonQuestQuest),
    nil
  },
  mDailyReward = {
    3,
    0,
    sdp.SdpMap(8, CmdActCfgCommonQuestDailyReward),
    nil
  },
  mFinalReward = {
    4,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  },
  sTitleWordColor = {
    5,
    0,
    13,
    ""
  },
  sSubtitleWordColor = {
    6,
    0,
    13,
    ""
  },
  sBgPic = {
    7,
    0,
    13,
    ""
  },
  sAtmosphericAnimation = {
    8,
    0,
    13,
    ""
  },
  sSignInFloorPlan = {
    9,
    0,
    13,
    ""
  },
  iUiType = {
    10,
    0,
    8,
    0
  },
  iLamiaActId = {
    11,
    0,
    8,
    0
  }
}
Cmd_Act_CommonQuest_TakeDailyReward_CS = sdp.SdpStruct("Cmd_Act_CommonQuest_TakeDailyReward_CS")
Cmd_Act_CommonQuest_TakeDailyReward_CS.Definition = {
  "iActivityId",
  "iDay",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iDay = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_CommonQuest_TakeDailyReward_SC = sdp.SdpStruct("Cmd_Act_CommonQuest_TakeDailyReward_SC")
Cmd_Act_CommonQuest_TakeDailyReward_SC.Definition = {
  "iActivityId",
  "iDay",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iDay = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_CommonQuest_TakeFinalReward_CS = sdp.SdpStruct("Cmd_Act_CommonQuest_TakeFinalReward_CS")
Cmd_Act_CommonQuest_TakeFinalReward_CS.Definition = {
  "iActivityId",
  "iScore",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iScore = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_CommonQuest_TakeFinalReward_SC = sdp.SdpStruct("Cmd_Act_CommonQuest_TakeFinalReward_SC")
Cmd_Act_CommonQuest_TakeFinalReward_SC.Definition = {
  "iActivityId",
  "iScore",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iScore = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
