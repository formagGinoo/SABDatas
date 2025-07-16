local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActFullBurstDay_Status = sdp.SdpStruct("CmdActFullBurstDay_Status")
CmdActFullBurstDay_Status.Definition = {}
CmdActCommonCfgFullBurstDay = sdp.SdpStruct("CmdActCommonCfgFullBurstDay")
CmdActCommonCfgFullBurstDay.Definition = {
  "vOpenDay",
  vOpenDay = {
    0,
    0,
    13,
    ""
  }
}
CmdActCfgFullBurstDay = sdp.SdpStruct("CmdActCfgFullBurstDay")
CmdActCfgFullBurstDay.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgFullBurstDay,
    nil
  }
}
