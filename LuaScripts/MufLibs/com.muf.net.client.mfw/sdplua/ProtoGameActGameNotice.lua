local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_GameNotice_ReqGetWard_CS = 57501
CmdId_Act_GameNotice_ReqGetWard_SC = 57502
ActivityGameNoticeRewardType_Unknow = 0
ActivityGameNoticeRewardType_Jump = 1
ActivityGameNoticeRewardType_Max = ActivityGameNoticeRewardType_Jump + 1
CmdActGameNotice_Status = sdp.SdpStruct("CmdActGameNotice_Status")
CmdActGameNotice_Status.Definition = {
  "bIsRewarded",
  bIsRewarded = {
    0,
    0,
    1,
    false
  }
}
CmdActCfgGameNoticeContentConfig = sdp.SdpStruct("CmdActCfgGameNoticeContentConfig")
CmdActCfgGameNoticeContentConfig.Definition = {
  "iType",
  "sContent",
  "iJumpType",
  "sJumpParam",
  "iContentSize",
  "iContentColor",
  "iEmptyLine",
  "sTextContent",
  "iOffsetX",
  "iOffsetY",
  iType = {
    0,
    0,
    8,
    0
  },
  sContent = {
    1,
    0,
    13,
    ""
  },
  iJumpType = {
    2,
    0,
    8,
    0
  },
  sJumpParam = {
    3,
    0,
    13,
    ""
  },
  iContentSize = {
    4,
    0,
    8,
    0
  },
  iContentColor = {
    5,
    0,
    8,
    0
  },
  iEmptyLine = {
    6,
    0,
    8,
    0
  },
  sTextContent = {
    7,
    0,
    13,
    ""
  },
  iOffsetX = {
    8,
    0,
    8,
    0
  },
  iOffsetY = {
    9,
    0,
    8,
    0
  }
}
CmdActCfgGameNoticeJumpContent = sdp.SdpStruct("CmdActCfgGameNoticeJumpContent")
CmdActCfgGameNoticeJumpContent.Definition = {
  "type",
  "portraitPosition",
  "sBackgroundPic",
  "sTitle",
  "sSubTitle",
  "sActivityInfo",
  "iCharacterId",
  "iJumpActivityId",
  "iActivityOpenTime",
  "iActivityEndTime",
  type = {
    0,
    0,
    8,
    0
  },
  portraitPosition = {
    1,
    0,
    8,
    0
  },
  sBackgroundPic = {
    2,
    0,
    13,
    ""
  },
  sTitle = {
    3,
    0,
    13,
    ""
  },
  sSubTitle = {
    4,
    0,
    13,
    ""
  },
  sActivityInfo = {
    5,
    0,
    13,
    ""
  },
  iCharacterId = {
    6,
    0,
    8,
    0
  },
  iJumpActivityId = {
    7,
    0,
    8,
    0
  },
  iActivityOpenTime = {
    8,
    0,
    8,
    0
  },
  iActivityEndTime = {
    9,
    0,
    8,
    0
  }
}
CmdActClientCfgGameNotice = sdp.SdpStruct("CmdActClientCfgGameNotice")
CmdActClientCfgGameNotice.Definition = {
  "iNoticeType",
  "iShowWeight",
  "iNeedChargeMoney",
  "sTitle",
  "vContentConfig",
  "sJumpContent",
  "iJumpTypeLast",
  "sJumpParamLast",
  "iHideTime",
  "sClientVersion",
  "iQuestId",
  "vJumpContent",
  iNoticeType = {
    0,
    0,
    8,
    0
  },
  iShowWeight = {
    1,
    0,
    8,
    0
  },
  iNeedChargeMoney = {
    2,
    0,
    8,
    0
  },
  sTitle = {
    3,
    0,
    13,
    ""
  },
  vContentConfig = {
    4,
    0,
    sdp.SdpVector(CmdActCfgGameNoticeContentConfig),
    nil
  },
  sJumpContent = {
    5,
    0,
    13,
    ""
  },
  iJumpTypeLast = {
    6,
    0,
    8,
    0
  },
  sJumpParamLast = {
    7,
    0,
    13,
    ""
  },
  iHideTime = {
    8,
    0,
    8,
    0
  },
  sClientVersion = {
    9,
    0,
    13,
    ""
  },
  iQuestId = {
    10,
    0,
    8,
    0
  },
  vJumpContent = {
    11,
    0,
    sdp.SdpVector(CmdActCfgGameNoticeJumpContent),
    nil
  }
}
CmdActCommonCfgGameNotice = sdp.SdpStruct("CmdActCommonCfgGameNotice")
CmdActCommonCfgGameNotice.Definition = {
  "reward_type",
  "mReward",
  "iCanGetRewardTime",
  reward_type = {
    0,
    0,
    8,
    0
  },
  mReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iCanGetRewardTime = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgGameNotice = sdp.SdpStruct("CmdActCfgGameNotice")
CmdActCfgGameNotice.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgGameNotice,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgGameNotice,
    nil
  }
}
Cmd_Act_GameNotice_ReqGetWard_CS = sdp.SdpStruct("Cmd_Act_GameNotice_ReqGetWard_CS")
Cmd_Act_GameNotice_ReqGetWard_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_GameNotice_ReqGetWard_SC = sdp.SdpStruct("Cmd_Act_GameNotice_ReqGetWard_SC")
Cmd_Act_GameNotice_ReqGetWard_SC.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
