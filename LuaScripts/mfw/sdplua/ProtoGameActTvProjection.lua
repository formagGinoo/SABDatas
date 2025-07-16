local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActTvProjection_Status = sdp.SdpStruct("CmdActTvProjection_Status")
CmdActTvProjection_Status.Definition = {}
CmdActCfgTvProjectionTvProjectionCfg = sdp.SdpStruct("CmdActCfgTvProjectionTvProjectionCfg")
CmdActCfgTvProjectionTvProjectionCfg.Definition = {
  "iJumpType",
  "sJumpParam",
  "iWeight",
  "sPic",
  "iStartTime",
  "iEndTime",
  "iNeedStageId",
  "iNeedLevel",
  iJumpType = {
    0,
    0,
    13,
    ""
  },
  sJumpParam = {
    1,
    0,
    13,
    ""
  },
  iWeight = {
    2,
    0,
    8,
    0
  },
  sPic = {
    3,
    0,
    13,
    ""
  },
  iStartTime = {
    4,
    0,
    8,
    0
  },
  iEndTime = {
    5,
    0,
    8,
    0
  },
  iNeedStageId = {
    6,
    0,
    8,
    0
  },
  iNeedLevel = {
    7,
    0,
    8,
    0
  }
}
CmdActClientCfgTvProjection = sdp.SdpStruct("CmdActClientCfgTvProjection")
CmdActClientCfgTvProjection.Definition = {
  "sTvProjectionCfg",
  sTvProjectionCfg = {
    0,
    0,
    sdp.SdpVector(CmdActCfgTvProjectionTvProjectionCfg),
    nil
  }
}
CmdActCfgTvProjection = sdp.SdpStruct("CmdActCfgTvProjection")
CmdActCfgTvProjection.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgTvProjection,
    nil
  }
}
