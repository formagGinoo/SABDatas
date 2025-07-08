local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActGachaFree_Status = sdp.SdpStruct("CmdActGachaFree_Status")
CmdActGachaFree_Status.Definition = {}
CmdActCommonCfgGachaFree = sdp.SdpStruct("CmdActCommonCfgGachaFree")
CmdActCommonCfgGachaFree.Definition = {
  "iGachaId",
  "iDailyFreeTimesTen",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  iDailyFreeTimesTen = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgGachaFree = sdp.SdpStruct("CmdActCfgGachaFree")
CmdActCfgGachaFree.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgGachaFree,
    nil
  }
}
