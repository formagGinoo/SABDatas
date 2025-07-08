local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActRechargeRebate_Status = sdp.SdpStruct("CmdActRechargeRebate_Status")
CmdActRechargeRebate_Status.Definition = {
  "iRabateTime",
  iRabateTime = {
    0,
    0,
    8,
    0
  }
}
CmdActCommonCfgRechargeRebate = sdp.SdpStruct("CmdActCommonCfgRechargeRebate")
CmdActCommonCfgRechargeRebate.Definition = {
  "iWelfareRatio",
  "vWelfareApp",
  iWelfareRatio = {
    0,
    0,
    8,
    0
  },
  vWelfareApp = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActCfgRechargeRebate = sdp.SdpStruct("CmdActCfgRechargeRebate")
CmdActCfgRechargeRebate.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgRechargeRebate,
    nil
  }
}
