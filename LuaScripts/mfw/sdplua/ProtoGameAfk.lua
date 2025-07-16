local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Afk_GetData_CS = 14301
CmdId_Afk_GetData_SC = 14302
CmdId_Afk_TakeReward_CS = 14303
CmdId_Afk_TakeReward_SC = 14304
CmdId_Afk_TakeInstant_CS = 14305
CmdId_Afk_TakeInstant_SC = 14306
CmdAfk = sdp.SdpStruct("CmdAfk")
CmdAfk.Definition = {
  "iAfkLevel",
  "iAfkExp",
  "iSeeRewardTime",
  "iTakeRewardTime",
  "iInstantTimes",
  "mReward",
  iAfkLevel = {
    0,
    0,
    8,
    0
  },
  iAfkExp = {
    1,
    0,
    8,
    0
  },
  iSeeRewardTime = {
    2,
    0,
    8,
    0
  },
  iTakeRewardTime = {
    3,
    0,
    8,
    0
  },
  iInstantTimes = {
    4,
    0,
    8,
    0
  },
  mReward = {
    5,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Afk_GetData_CS = sdp.SdpStruct("Cmd_Afk_GetData_CS")
Cmd_Afk_GetData_CS.Definition = {
  "bAuto",
  bAuto = {
    0,
    0,
    1,
    false
  }
}
Cmd_Afk_GetData_SC = sdp.SdpStruct("Cmd_Afk_GetData_SC")
Cmd_Afk_GetData_SC.Definition = {
  "stAfkData",
  stAfkData = {
    0,
    0,
    CmdAfk,
    nil
  }
}
Cmd_Afk_TakeReward_CS = sdp.SdpStruct("Cmd_Afk_TakeReward_CS")
Cmd_Afk_TakeReward_CS.Definition = {}
Cmd_Afk_TakeReward_SC = sdp.SdpStruct("Cmd_Afk_TakeReward_SC")
Cmd_Afk_TakeReward_SC.Definition = {
  "iTakeRewardTime",
  "vReward",
  iTakeRewardTime = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Afk_TakeInstant_CS = sdp.SdpStruct("Cmd_Afk_TakeInstant_CS")
Cmd_Afk_TakeInstant_CS.Definition = {}
Cmd_Afk_TakeInstant_SC = sdp.SdpStruct("Cmd_Afk_TakeInstant_SC")
Cmd_Afk_TakeInstant_SC.Definition = {
  "iInstantTimes",
  "vReward",
  iInstantTimes = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
