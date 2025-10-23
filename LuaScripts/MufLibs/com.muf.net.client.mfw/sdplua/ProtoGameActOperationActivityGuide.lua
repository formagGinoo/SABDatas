local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActOperationActivityGuide_Status = sdp.SdpStruct("CmdActOperationActivityGuide_Status")
CmdActOperationActivityGuide_Status.Definition = {}
CmdActCfgOperationActivityGuideActivityCfg = sdp.SdpStruct("CmdActCfgOperationActivityGuideActivityCfg")
CmdActCfgOperationActivityGuideActivityCfg.Definition = {
  "iID",
  "iActivityType",
  "sActivityParam",
  "iPos",
  "iPosParam",
  "iOpenTime",
  "iCloseTime",
  "vJumpId",
  "sActivityName",
  "sActivityPic",
  iID = {
    0,
    0,
    8,
    0
  },
  iActivityType = {
    1,
    0,
    8,
    0
  },
  sActivityParam = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  iPos = {
    3,
    0,
    8,
    0
  },
  iPosParam = {
    4,
    0,
    8,
    0
  },
  iOpenTime = {
    5,
    0,
    8,
    0
  },
  iCloseTime = {
    6,
    0,
    8,
    0
  },
  vJumpId = {
    7,
    0,
    sdp.SdpVector(8),
    nil
  },
  sActivityName = {
    8,
    0,
    13,
    ""
  },
  sActivityPic = {
    9,
    0,
    13,
    ""
  }
}
CmdActClientCfgOperationActivityGuide = sdp.SdpStruct("CmdActClientCfgOperationActivityGuide")
CmdActClientCfgOperationActivityGuide.Definition = {
  "sPicPath",
  "sActName",
  "mActivityCfg",
  sPicPath = {
    0,
    0,
    13,
    ""
  },
  sActName = {
    1,
    0,
    13,
    ""
  },
  mActivityCfg = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgOperationActivityGuideActivityCfg),
    nil
  }
}
CmdActCfgOperationActivityGuide = sdp.SdpStruct("CmdActCfgOperationActivityGuide")
CmdActCfgOperationActivityGuide.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgOperationActivityGuide,
    nil
  }
}
