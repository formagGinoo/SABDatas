local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActWelfareShow_Status = sdp.SdpStruct("CmdActWelfareShow_Status")
CmdActWelfareShow_Status.Definition = {}
CmdActCfgWelfareShowSystem = sdp.SdpStruct("CmdActCfgWelfareShowSystem")
CmdActCfgWelfareShowSystem.Definition = {
  "sContent",
  "iJumpType",
  "sJumpParam",
  "sDate",
  sContent = {
    0,
    0,
    13,
    ""
  },
  iJumpType = {
    1,
    0,
    8,
    0
  },
  sJumpParam = {
    2,
    0,
    13,
    ""
  },
  sDate = {
    3,
    0,
    13,
    ""
  }
}
CmdActClientCfgWelfareShow = sdp.SdpStruct("CmdActClientCfgWelfareShow")
CmdActClientCfgWelfareShow.Definition = {
  "vSystem",
  "iNeedGuideId",
  vSystem = {
    0,
    0,
    sdp.SdpVector(CmdActCfgWelfareShowSystem),
    nil
  },
  iNeedGuideId = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgWelfareShow = sdp.SdpStruct("CmdActCfgWelfareShow")
CmdActCfgWelfareShow.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgWelfareShow,
    nil
  }
}
