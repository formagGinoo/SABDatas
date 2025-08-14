local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_LoginSelect_SelectReward_CS = 59851
CmdId_Act_LoginSelect_SelectReward_SC = 59852
CmdActLoginSelect_Status = sdp.SdpStruct("CmdActLoginSelect_Status")
CmdActLoginSelect_Status.Definition = {
  "iActivityId",
  "iBeginTime",
  "iEndTime",
  "iLoginNum",
  "iSelectIndex",
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
  iLoginNum = {
    3,
    0,
    8,
    0
  },
  iSelectIndex = {
    4,
    0,
    8,
    0
  }
}
CmdActCfgLoginSelectSelectReward = sdp.SdpStruct("CmdActCfgLoginSelectSelectReward")
CmdActCfgLoginSelectSelectReward.Definition = {
  "iIndex",
  "sReward",
  "sRewardPicture",
  "sRewardDesc",
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
  sRewardPicture = {
    2,
    0,
    13,
    ""
  },
  sRewardDesc = {
    3,
    0,
    13,
    ""
  }
}
CmdActCfgLoginSelect = sdp.SdpStruct("CmdActCfgLoginSelect")
CmdActCfgLoginSelect.Definition = {
  "iNeedLogin",
  "sHelpTips",
  "sColor",
  "mSelectReward",
  "sTitleWordColor",
  "sSubtitleWordColor",
  "sBgPic",
  "sAtmosphericAnimation",
  iNeedLogin = {
    0,
    0,
    8,
    0
  },
  sHelpTips = {
    1,
    0,
    13,
    ""
  },
  sColor = {
    2,
    0,
    13,
    ""
  },
  mSelectReward = {
    3,
    0,
    sdp.SdpMap(8, CmdActCfgLoginSelectSelectReward),
    nil
  },
  sTitleWordColor = {
    4,
    0,
    13,
    ""
  },
  sSubtitleWordColor = {
    5,
    0,
    13,
    ""
  },
  sBgPic = {
    6,
    0,
    13,
    ""
  },
  sAtmosphericAnimation = {
    7,
    0,
    13,
    ""
  }
}
Cmd_Act_LoginSelect_SelectReward_CS = sdp.SdpStruct("Cmd_Act_LoginSelect_SelectReward_CS")
Cmd_Act_LoginSelect_SelectReward_CS.Definition = {
  "iActivityId",
  "iSelectIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iSelectIndex = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_LoginSelect_SelectReward_SC = sdp.SdpStruct("Cmd_Act_LoginSelect_SelectReward_SC")
Cmd_Act_LoginSelect_SelectReward_SC.Definition = {
  "iActivityId",
  "iSelectIndex",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iSelectIndex = {
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
