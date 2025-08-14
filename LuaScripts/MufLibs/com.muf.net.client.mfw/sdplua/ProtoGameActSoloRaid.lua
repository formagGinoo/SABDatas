local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActSoloRaid_Status = sdp.SdpStruct("CmdActSoloRaid_Status")
CmdActSoloRaid_Status.Definition = {}
CmdActCommonCfgSoloRaid = sdp.SdpStruct("CmdActCommonCfgSoloRaid")
CmdActCommonCfgSoloRaid.Definition = {
  "iBossId",
  "iSettleTime",
  iBossId = {
    0,
    0,
    8,
    0
  },
  iSettleTime = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgSoloRaid = sdp.SdpStruct("CmdActCfgSoloRaid")
CmdActCfgSoloRaid.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    0,
    0,
    CmdActCommonCfgSoloRaid,
    nil
  }
}
