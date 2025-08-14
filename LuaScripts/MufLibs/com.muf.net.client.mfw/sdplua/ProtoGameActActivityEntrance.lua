local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActActivityEntrance_Status = sdp.SdpStruct("CmdActActivityEntrance_Status")
CmdActActivityEntrance_Status.Definition = {}
CmdActCfgActivityEntranceActListCfg = sdp.SdpStruct("CmdActCfgActivityEntranceActListCfg")
CmdActCfgActivityEntranceActListCfg.Definition = {
  "iSubActId",
  "sJumpParam",
  "iWeight",
  "sSubActTitle",
  "sSubActDesc",
  "sSubActPic",
  iSubActId = {
    0,
    0,
    8,
    0
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
  sSubActTitle = {
    3,
    0,
    13,
    ""
  },
  sSubActDesc = {
    4,
    0,
    13,
    ""
  },
  sSubActPic = {
    5,
    0,
    13,
    ""
  }
}
CmdActClientCfgActivityEntrance = sdp.SdpStruct("CmdActClientCfgActivityEntrance")
CmdActClientCfgActivityEntrance.Definition = {
  "vActListCfg",
  vActListCfg = {
    0,
    0,
    sdp.SdpVector(CmdActCfgActivityEntranceActListCfg),
    nil
  }
}
CmdActCfgActivityEntrance = sdp.SdpStruct("CmdActCfgActivityEntrance")
CmdActCfgActivityEntrance.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgActivityEntrance,
    nil
  }
}
