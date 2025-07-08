local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActOnePicAct_Status = sdp.SdpStruct("CmdActOnePicAct_Status")
CmdActOnePicAct_Status.Definition = {}
CmdActClientCfgOnePicAct = sdp.SdpStruct("CmdActClientCfgOnePicAct")
CmdActClientCfgOnePicAct.Definition = {
  "sBGPicPath",
  "sSubPicPath",
  "iSubPicPosX",
  "iSubPicPosY",
  "sJumpContent",
  "iJumpType",
  "sJumpParam",
  "iWeight",
  sBGPicPath = {
    0,
    0,
    13,
    ""
  },
  sSubPicPath = {
    1,
    0,
    13,
    ""
  },
  iSubPicPosX = {
    2,
    0,
    7,
    0
  },
  iSubPicPosY = {
    3,
    0,
    7,
    0
  },
  sJumpContent = {
    4,
    0,
    13,
    ""
  },
  iJumpType = {
    5,
    0,
    8,
    0
  },
  sJumpParam = {
    6,
    0,
    13,
    ""
  },
  iWeight = {
    7,
    0,
    8,
    0
  }
}
CmdActCfgOnePicAct = sdp.SdpStruct("CmdActCfgOnePicAct")
CmdActCfgOnePicAct.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgOnePicAct,
    nil
  }
}
