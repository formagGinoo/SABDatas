local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
FightDebugType_None = 0
FightDebugType_CheatUploadReport = 1
FightDebugType_AllUploadReport = 2
CmdActFightDebug_Status = sdp.SdpStruct("CmdActFightDebug_Status")
CmdActFightDebug_Status.Definition = {}
CmdActCommonCfgFightDebug = sdp.SdpStruct("CmdActCommonCfgFightDebug")
CmdActCommonCfgFightDebug.Definition = {
  "iFightDebugType",
  "sReportLink",
  "sReportAccount",
  "sReportPassword",
  "iFightDebugSizeLimit",
  iFightDebugType = {
    0,
    0,
    8,
    0
  },
  sReportLink = {
    1,
    0,
    13,
    ""
  },
  sReportAccount = {
    2,
    0,
    13,
    ""
  },
  sReportPassword = {
    3,
    0,
    13,
    ""
  },
  iFightDebugSizeLimit = {
    4,
    0,
    8,
    0
  }
}
CmdActCfgFightDebug = sdp.SdpStruct("CmdActCfgFightDebug")
CmdActCfgFightDebug.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgFightDebug,
    nil
  }
}
