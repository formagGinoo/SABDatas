local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdId_Recommend_GetInit_CS = 19451
CmdId_Recommend_GetInit_SC = 19452
HeroRecommendDataType_Hero = 1
HeroRecommendDataType_Form = 2
CmdRecommendHero = sdp.SdpStruct("CmdRecommendHero")
CmdRecommendHero.Definition = {
  "iHeroId",
  "fScore",
  "bIsNew",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  fScore = {
    1,
    0,
    11,
    0
  },
  bIsNew = {
    2,
    0,
    1,
    false
  }
}
CmdRecommendForm = sdp.SdpStruct("CmdRecommendForm")
CmdRecommendForm.Definition = {
  "vHeroId",
  "fScore",
  vHeroId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  fScore = {
    1,
    0,
    11,
    0
  }
}
CmdRecommendFormFlow = sdp.SdpStruct("CmdRecommendFormFlow")
CmdRecommendFormFlow.Definition = {
  "mvForm",
  mvForm = {
    0,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdRecommendForm)),
    nil
  }
}
Cmd_Recommend_GetInit_CS = sdp.SdpStruct("Cmd_Recommend_GetInit_CS")
Cmd_Recommend_GetInit_CS.Definition = {}
Cmd_Recommend_GetInit_SC = sdp.SdpStruct("Cmd_Recommend_GetInit_SC")
Cmd_Recommend_GetInit_SC.Definition = {
  "vHero",
  "mFlow",
  "iNextRefreshTime",
  vHero = {
    0,
    0,
    sdp.SdpVector(CmdRecommendHero),
    nil
  },
  mFlow = {
    1,
    0,
    sdp.SdpMap(8, CmdRecommendFormFlow),
    nil
  },
  iNextRefreshTime = {
    2,
    0,
    8,
    0
  }
}
