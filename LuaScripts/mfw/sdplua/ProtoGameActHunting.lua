local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActHunting_Status = sdp.SdpStruct("CmdActHunting_Status")
CmdActHunting_Status.Definition = {}
CmdActCfgHuntingTimeManager = sdp.SdpStruct("CmdActCfgHuntingTimeManager")
CmdActCfgHuntingTimeManager.Definition = {
  "iIndex",
  "vBoss",
  "iStartTime",
  "iFightEndTime",
  "iEndTime",
  iIndex = {
    0,
    0,
    8,
    0
  },
  vBoss = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  iStartTime = {
    2,
    0,
    8,
    0
  },
  iFightEndTime = {
    3,
    0,
    8,
    0
  },
  iEndTime = {
    4,
    0,
    8,
    0
  }
}
CmdActCfgHuntingAllBoss = sdp.SdpStruct("CmdActCfgHuntingAllBoss")
CmdActCfgHuntingAllBoss.Definition = {
  "iBossId",
  "sDate",
  iBossId = {
    0,
    0,
    8,
    0
  },
  sDate = {
    1,
    0,
    13,
    ""
  }
}
CmdActCommonCfgHunting = sdp.SdpStruct("CmdActCommonCfgHunting")
CmdActCommonCfgHunting.Definition = {
  "vAllBoss",
  "iRewardTime",
  "mTimeManager",
  vAllBoss = {
    0,
    0,
    sdp.SdpVector(CmdActCfgHuntingAllBoss),
    nil
  },
  iRewardTime = {
    1,
    0,
    8,
    0
  },
  mTimeManager = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgHuntingTimeManager),
    nil
  }
}
CmdActCfgHunting = sdp.SdpStruct("CmdActCfgHunting")
CmdActCfgHunting.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgHunting,
    nil
  }
}
