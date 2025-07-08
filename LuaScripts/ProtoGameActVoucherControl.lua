local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActVoucherControl_Status = sdp.SdpStruct("CmdActVoucherControl_Status")
CmdActVoucherControl_Status.Definition = {}
CmdActCfgVoucherControlControlCfg = sdp.SdpStruct("CmdActCfgVoucherControlControlCfg")
CmdActCfgVoucherControlControlCfg.Definition = {
  "sChannel",
  "vCountry",
  "iControlType",
  "sSpecialJumpLink",
  sChannel = {
    0,
    0,
    13,
    ""
  },
  vCountry = {
    1,
    0,
    sdp.SdpVector(13),
    nil
  },
  iControlType = {
    2,
    0,
    8,
    0
  },
  sSpecialJumpLink = {
    3,
    0,
    13,
    ""
  }
}
CmdActCommonCfgVoucherControl = sdp.SdpStruct("CmdActCommonCfgVoucherControl")
CmdActCommonCfgVoucherControl.Definition = {
  "sJumpLink",
  "vControlCfg",
  sJumpLink = {
    0,
    0,
    13,
    ""
  },
  vControlCfg = {
    1,
    0,
    sdp.SdpVector(CmdActCfgVoucherControlControlCfg),
    nil
  }
}
CmdActCfgVoucherControl = sdp.SdpStruct("CmdActCfgVoucherControl")
CmdActCfgVoucherControl.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgVoucherControl,
    nil
  }
}
