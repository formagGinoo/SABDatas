local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActSystemSwitch_Status = sdp.SdpStruct("CmdActSystemSwitch_Status")
CmdActSystemSwitch_Status.Definition = {}
CmdActCfgSystemSwitchSystemCfg = sdp.SdpStruct("CmdActCfgSystemSwitchSystemCfg")
CmdActCfgSystemSwitchSystemCfg.Definition = {
  "iSystemId",
  "vConditionType",
  "vConditionData",
  "vClientMessage",
  "iForceClose",
  "sComment",
  iSystemId = {
    0,
    0,
    8,
    0
  },
  vConditionType = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vConditionData = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vClientMessage = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iForceClose = {
    4,
    0,
    8,
    0
  },
  sComment = {
    5,
    0,
    13,
    ""
  }
}
CmdActCommonCfgSystemSwitch = sdp.SdpStruct("CmdActCommonCfgSystemSwitch")
CmdActCommonCfgSystemSwitch.Definition = {
  "mSystemCfg",
  mSystemCfg = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgSystemSwitchSystemCfg),
    nil
  }
}
CmdActCfgSystemSwitch = sdp.SdpStruct("CmdActCfgSystemSwitch")
CmdActCfgSystemSwitch.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgSystemSwitch,
    nil
  }
}
