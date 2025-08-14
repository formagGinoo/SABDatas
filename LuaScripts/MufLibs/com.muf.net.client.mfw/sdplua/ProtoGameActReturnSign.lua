local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_ReturnSign_GetSignReward_CS = 60521
CmdId_Act_ReturnSign_GetSignReward_SC = 60522
CmdActReturnSign_Status = sdp.SdpStruct("CmdActReturnSign_Status")
CmdActReturnSign_Status.Definition = {
  "iActivityId",
  "iOpenTime",
  "iCloseTime",
  "iLoginDay",
  "iMaxAwardedDays",
  iActivityId = {
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
  },
  iLoginDay = {
    3,
    0,
    8,
    0
  },
  iMaxAwardedDays = {
    4,
    0,
    8,
    0
  }
}
CmdActCommonCfgReturnSign = sdp.SdpStruct("CmdActCommonCfgReturnSign")
CmdActCommonCfgReturnSign.Definition = {
  "iActiveDay",
  "iCloseDay",
  "iCDDay",
  "iResendMailTemplateId",
  "mReward",
  iActiveDay = {
    0,
    0,
    8,
    0
  },
  iCloseDay = {
    1,
    0,
    8,
    0
  },
  iCDDay = {
    2,
    0,
    8,
    0
  },
  iResendMailTemplateId = {
    3,
    0,
    8,
    0
  },
  mReward = {
    4,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
CmdActCfgReturnSign = sdp.SdpStruct("CmdActCfgReturnSign")
CmdActCfgReturnSign.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgReturnSign,
    nil
  }
}
Cmd_Act_ReturnSign_GetSignReward_CS = sdp.SdpStruct("Cmd_Act_ReturnSign_GetSignReward_CS")
Cmd_Act_ReturnSign_GetSignReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_ReturnSign_GetSignReward_SC = sdp.SdpStruct("Cmd_Act_ReturnSign_GetSignReward_SC")
Cmd_Act_ReturnSign_GetSignReward_SC.Definition = {
  "iActivityId",
  "iMaxAwardedDays",
  "vReward",
  iActivityId = {
    1,
    0,
    8,
    0
  },
  iMaxAwardedDays = {
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
  }
}
