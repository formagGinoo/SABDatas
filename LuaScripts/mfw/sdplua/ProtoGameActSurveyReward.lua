local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_SurveyReward_GetLink_CS = 59811
CmdId_Act_SurveyReward_GetLink_SC = 59812
CmdId_Act_SurveyReward_GetReward_CS = 59813
CmdId_Act_SurveyReward_GetReward_SC = 59814
SurveyRewardType_None = 0
SurveyRewardType_Mail = 1
SurveyRewardType_Reward = 2
SurveyRewardStatus_None = 0
SurveyRewardStatus_Answer = 1
SurveyRewardStatus_Reward = 2
CmdActSurveyReward_Status = sdp.SdpStruct("CmdActSurveyReward_Status")
CmdActSurveyReward_Status.Definition = {
  "iActivityId",
  "mSendReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mSendReward = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdActCfgSurveyRewardSurveyIds = sdp.SdpStruct("CmdActCfgSurveyRewardSurveyIds")
CmdActCfgSurveyRewardSurveyIds.Definition = {
  "iLangId",
  "sSurveyId",
  "sSystemNo",
  "sConditionNo",
  iLangId = {
    0,
    0,
    8,
    0
  },
  sSurveyId = {
    1,
    0,
    13,
    ""
  },
  sSystemNo = {
    2,
    0,
    13,
    ""
  },
  sConditionNo = {
    3,
    0,
    13,
    ""
  }
}
CmdActCfgSurveyRewardSurvey = sdp.SdpStruct("CmdActCfgSurveyRewardSurvey")
CmdActCfgSurveyRewardSurvey.Definition = {
  "mSurveyIds",
  mSurveyIds = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgSurveyRewardSurveyIds),
    nil
  }
}
CmdActCfgSurveyRewardReward = sdp.SdpStruct("CmdActCfgSurveyRewardReward")
CmdActCfgSurveyRewardReward.Definition = {
  "iId",
  "iDefaultLangId",
  "mSurvey",
  "sReward",
  "iRewardType",
  "sMailTitle",
  "sMailContent",
  iId = {
    0,
    0,
    8,
    0
  },
  iDefaultLangId = {
    1,
    0,
    8,
    0
  },
  mSurvey = {
    2,
    0,
    CmdActCfgSurveyRewardSurvey,
    nil
  },
  sReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iRewardType = {
    4,
    0,
    8,
    0
  },
  sMailTitle = {
    5,
    0,
    13,
    ""
  },
  sMailContent = {
    6,
    0,
    13,
    ""
  }
}
CmdActCommonCfgSurveyReward = sdp.SdpStruct("CmdActCommonCfgSurveyReward")
CmdActCommonCfgSurveyReward.Definition = {
  "mReward",
  mReward = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgSurveyRewardReward),
    nil
  }
}
CmdActCfgSurveyReward = sdp.SdpStruct("CmdActCfgSurveyReward")
CmdActCfgSurveyReward.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgSurveyReward,
    nil
  }
}
Cmd_Act_SurveyReward_GetLink_CS = sdp.SdpStruct("Cmd_Act_SurveyReward_GetLink_CS")
Cmd_Act_SurveyReward_GetLink_CS.Definition = {
  "iActivityId",
  "iIndexId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndexId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_SurveyReward_GetLink_SC = sdp.SdpStruct("Cmd_Act_SurveyReward_GetLink_SC")
Cmd_Act_SurveyReward_GetLink_SC.Definition = {
  "iActivityId",
  "sLink",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  sLink = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Act_SurveyReward_GetReward_CS = sdp.SdpStruct("Cmd_Act_SurveyReward_GetReward_CS")
Cmd_Act_SurveyReward_GetReward_CS.Definition = {
  "iActivityId",
  "iIndexId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndexId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_SurveyReward_GetReward_SC = sdp.SdpStruct("Cmd_Act_SurveyReward_GetReward_SC")
Cmd_Act_SurveyReward_GetReward_SC.Definition = {
  "iActivityId",
  "iIndexId",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndexId = {
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
