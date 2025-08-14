local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActCommunityEntrance_Status = sdp.SdpStruct("CmdActCommunityEntrance_Status")
CmdActCommunityEntrance_Status.Definition = {}
CmdActCfgCommunityEntranceCommunityCfg = sdp.SdpStruct("CmdActCfgCommunityEntranceCommunityCfg")
CmdActCfgCommunityEntranceCommunityCfg.Definition = {
  "iCommunityType",
  "sJumpContent",
  "sJumpUrl",
  "iWeight",
  "sJumpPic",
  "sButtonName",
  iCommunityType = {
    0,
    0,
    13,
    ""
  },
  sJumpContent = {
    1,
    0,
    13,
    ""
  },
  sJumpUrl = {
    2,
    0,
    13,
    ""
  },
  iWeight = {
    3,
    0,
    8,
    0
  },
  sJumpPic = {
    4,
    0,
    13,
    ""
  },
  sButtonName = {
    5,
    0,
    13,
    ""
  }
}
CmdActClientCfgCommunityEntrance = sdp.SdpStruct("CmdActClientCfgCommunityEntrance")
CmdActClientCfgCommunityEntrance.Definition = {
  "vCommunityCfg",
  vCommunityCfg = {
    0,
    0,
    sdp.SdpVector(CmdActCfgCommunityEntranceCommunityCfg),
    nil
  }
}
CmdActCfgCommunityEntrance = sdp.SdpStruct("CmdActCfgCommunityEntrance")
CmdActCfgCommunityEntrance.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgCommunityEntrance,
    nil
  }
}
