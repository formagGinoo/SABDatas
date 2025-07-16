local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActRechargeBack_Status = sdp.SdpStruct("CmdActRechargeBack_Status")
CmdActRechargeBack_Status.Definition = {}
CmdActCfgRechargeBackMessage = sdp.SdpStruct("CmdActCfgRechargeBackMessage")
CmdActCfgRechargeBackMessage.Definition = {
  "sItemTitile",
  "sDesc",
  sItemTitile = {
    0,
    0,
    13,
    ""
  },
  sDesc = {
    1,
    0,
    13,
    ""
  }
}
CmdActClientCfgRechargeBack = sdp.SdpStruct("CmdActClientCfgRechargeBack")
CmdActClientCfgRechargeBack.Definition = {
  "sTitle",
  "sMessage",
  sTitle = {
    0,
    0,
    13,
    ""
  },
  sMessage = {
    1,
    0,
    sdp.SdpVector(CmdActCfgRechargeBackMessage),
    nil
  }
}
CmdActCfgRechargeBack = sdp.SdpStruct("CmdActCfgRechargeBack")
CmdActCfgRechargeBack.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgRechargeBack,
    nil
  }
}
