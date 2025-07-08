local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Sns_Share_CS = 12001
CmdId_Sns_Share_SC = 12002
SnsShareType_Facebook = 1
SnsShareType_Twitter = 2
SnsShareType_Line = 3
SnsShareType_Naver = 4
SnsShareType_Any = 10
SnsShareFunc_Unknown = 0
SnsShareFunc_GetHero = 1
SnsShareFunc_HeroPanel = 2
CmdShareParams = sdp.SdpStruct("CmdShareParams")
CmdShareParams.Definition = {
  "vShareHeroId",
  vShareHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Sns_Share_CS = sdp.SdpStruct("Cmd_Sns_Share_CS")
Cmd_Sns_Share_CS.Definition = {
  "iSnsType",
  "iSnsFunc",
  "stParams",
  "iActivityId",
  iSnsType = {
    0,
    0,
    8,
    0
  },
  iSnsFunc = {
    1,
    0,
    8,
    0
  },
  stParams = {
    2,
    0,
    CmdShareParams,
    nil
  },
  iActivityId = {
    3,
    0,
    8,
    0
  }
}
Cmd_Sns_Share_SC = sdp.SdpStruct("Cmd_Sns_Share_SC")
Cmd_Sns_Share_SC.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
