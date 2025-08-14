local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_Sign_Sign_CS = 59771
CmdId_Act_Sign_Sign_SC = 59772
CmdActSign_Status = sdp.SdpStruct("CmdActSign_Status")
CmdActSign_Status.Definition = {
  "iActivityId",
  "iBeginTime",
  "iEndTime",
  "iActDay",
  "iSignNum",
  "bSignToday",
  "bStageRestrict",
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
  iActDay = {
    3,
    0,
    8,
    0
  },
  iSignNum = {
    4,
    0,
    8,
    0
  },
  bSignToday = {
    5,
    0,
    1,
    false
  },
  bStageRestrict = {
    6,
    0,
    1,
    false
  }
}
CmdActCfgSignHeroChannelCfg = sdp.SdpStruct("CmdActCfgSignHeroChannelCfg")
CmdActCfgSignHeroChannelCfg.Definition = {
  "iIndex",
  "sChannel",
  "sHeroVerticalDrawing",
  "sHeroCampIcon",
  iIndex = {
    0,
    0,
    8,
    0
  },
  sChannel = {
    1,
    0,
    13,
    ""
  },
  sHeroVerticalDrawing = {
    2,
    0,
    13,
    ""
  },
  sHeroCampIcon = {
    3,
    0,
    13,
    ""
  }
}
CmdActCfgSignReward = sdp.SdpStruct("CmdActCfgSignReward")
CmdActCfgSignReward.Definition = {
  "iIndex",
  "sReward",
  "bSpecialReward",
  "sRewardPicture",
  "sRewardDesc",
  "bShowCount",
  iIndex = {
    0,
    0,
    8,
    0
  },
  sReward = {
    1,
    0,
    13,
    ""
  },
  bSpecialReward = {
    2,
    0,
    8,
    0
  },
  sRewardPicture = {
    3,
    0,
    13,
    ""
  },
  sRewardDesc = {
    4,
    0,
    13,
    ""
  },
  bShowCount = {
    5,
    0,
    8,
    0
  }
}
CmdActCfgSignShareReward = sdp.SdpStruct("CmdActCfgSignShareReward")
CmdActCfgSignShareReward.Definition = {
  "iIndex",
  "sReward",
  "sRewardPicture",
  iIndex = {
    0,
    0,
    8,
    0
  },
  sReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  sRewardPicture = {
    2,
    0,
    13,
    ""
  }
}
CmdActCfgSign = sdp.SdpStruct("CmdActCfgSign")
CmdActCfgSign.Definition = {
  "iUiType",
  "bSeasonAct",
  "iSeasonNum",
  "sCVChannel",
  "iHeroBaseId",
  "sArtTips",
  "sHelpTips",
  "sPic",
  "sColor",
  "mShareReward",
  "iShareBeginTime",
  "iShareEndTime",
  "mReward",
  "bResourceCanIn",
  "sTitleWordColor",
  "sSubtitleWordColor",
  "sBgPic",
  "mHeroChannelCfg",
  "sAtmosphericAnimation",
  "sSignInFloorPlan",
  "iRestrictStageType",
  "iRestrictStageId",
  "iRestrictGuideId",
  "iAvatarId",
  "iNotifyTime",
  iUiType = {
    0,
    0,
    8,
    0
  },
  bSeasonAct = {
    1,
    0,
    8,
    0
  },
  iSeasonNum = {
    2,
    0,
    8,
    0
  },
  sCVChannel = {
    3,
    0,
    13,
    ""
  },
  iHeroBaseId = {
    4,
    0,
    8,
    0
  },
  sArtTips = {
    5,
    0,
    13,
    ""
  },
  sHelpTips = {
    6,
    0,
    13,
    ""
  },
  sPic = {
    7,
    0,
    13,
    ""
  },
  sColor = {
    8,
    0,
    13,
    ""
  },
  mShareReward = {
    9,
    0,
    sdp.SdpMap(8, CmdActCfgSignShareReward),
    nil
  },
  iShareBeginTime = {
    10,
    0,
    8,
    0
  },
  iShareEndTime = {
    11,
    0,
    8,
    0
  },
  mReward = {
    12,
    0,
    sdp.SdpMap(8, CmdActCfgSignReward),
    nil
  },
  bResourceCanIn = {
    13,
    0,
    8,
    0
  },
  sTitleWordColor = {
    14,
    0,
    13,
    ""
  },
  sSubtitleWordColor = {
    15,
    0,
    13,
    ""
  },
  sBgPic = {
    16,
    0,
    13,
    ""
  },
  mHeroChannelCfg = {
    17,
    0,
    sdp.SdpMap(8, CmdActCfgSignHeroChannelCfg),
    nil
  },
  sAtmosphericAnimation = {
    18,
    0,
    13,
    ""
  },
  sSignInFloorPlan = {
    19,
    0,
    13,
    ""
  },
  iRestrictStageType = {
    20,
    0,
    8,
    0
  },
  iRestrictStageId = {
    21,
    0,
    8,
    0
  },
  iRestrictGuideId = {
    22,
    0,
    8,
    0
  },
  iAvatarId = {
    23,
    0,
    8,
    0
  },
  iNotifyTime = {
    24,
    0,
    8,
    0
  }
}
Cmd_Act_Sign_Sign_CS = sdp.SdpStruct("Cmd_Act_Sign_Sign_CS")
Cmd_Act_Sign_Sign_CS.Definition = {
  "iActivityId",
  "iIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndex = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_Sign_Sign_SC = sdp.SdpStruct("Cmd_Act_Sign_Sign_SC")
Cmd_Act_Sign_Sign_SC.Definition = {
  "iActivityId",
  "iIndex",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndex = {
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
