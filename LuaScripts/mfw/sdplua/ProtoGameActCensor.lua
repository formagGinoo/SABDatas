local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActCensor_Status = sdp.SdpStruct("CmdActCensor_Status")
CmdActCensor_Status.Definition = {}
CmdActCommonCfgCensor = sdp.SdpStruct("CmdActCommonCfgCensor")
CmdActCommonCfgCensor.Definition = {
  "bCensor",
  bCensor = {
    0,
    0,
    8,
    0
  }
}
CmdActCfgCensor = sdp.SdpStruct("CmdActCfgCensor")
CmdActCfgCensor.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgCensor,
    nil
  }
}
