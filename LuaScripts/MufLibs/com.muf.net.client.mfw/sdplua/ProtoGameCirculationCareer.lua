local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Role_GetCirculationCareer_CS = 60701
CmdId_Role_GetCirculationCareer_SC = 60702
CmdId_Role_UpgradeCirculationCareer_CS = 60703
CmdId_Role_UpgradeCirculationCareer_SC = 60704
CmdId_Role_SetCirculationCareerHero_CS = 60705
CmdId_Role_SetCirculationCareerHero_SC = 60706
Cmd_Role_GetCirculationCareer_CS = sdp.SdpStruct("Cmd_Role_GetCirculationCareer_CS")
Cmd_Role_GetCirculationCareer_CS.Definition = {}
Cmd_Role_GetCirculationCareer_SC = sdp.SdpStruct("Cmd_Role_GetCirculationCareer_SC")
Cmd_Role_GetCirculationCareer_SC.Definition = {
  "mCirculationCareerItem",
  "mCareerLocationHero",
  mCirculationCareerItem = {
    0,
    0,
    sdp.SdpMap(8, CmdCirculationCareerItem),
    nil
  },
  mCareerLocationHero = {
    1,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  }
}
Cmd_Role_UpgradeCirculationCareer_CS = sdp.SdpStruct("Cmd_Role_UpgradeCirculationCareer_CS")
Cmd_Role_UpgradeCirculationCareer_CS.Definition = {
  "iCareerType",
  "iItemNum",
  iCareerType = {
    0,
    0,
    8,
    0
  },
  iItemNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_UpgradeCirculationCareer_SC = sdp.SdpStruct("Cmd_Role_UpgradeCirculationCareer_SC")
Cmd_Role_UpgradeCirculationCareer_SC.Definition = {
  "stCirculationItem",
  stCirculationItem = {
    0,
    0,
    CmdCirculationCareerItem,
    nil
  }
}
CmdCirculationCareerHeroLocation = sdp.SdpStruct("CmdCirculationCareerHeroLocation")
CmdCirculationCareerHeroLocation.Definition = {
  "iCareerType",
  "iLocation",
  "iHeroID",
  iCareerType = {
    0,
    0,
    8,
    0
  },
  iLocation = {
    1,
    0,
    8,
    0
  },
  iHeroID = {
    2,
    0,
    8,
    0
  }
}
Cmd_Role_SetCirculationCareerHero_CS = sdp.SdpStruct("Cmd_Role_SetCirculationCareerHero_CS")
Cmd_Role_SetCirculationCareerHero_CS.Definition = {
  "vSetList",
  vSetList = {
    0,
    0,
    sdp.SdpVector(CmdCirculationCareerHeroLocation),
    nil
  }
}
Cmd_Role_SetCirculationCareerHero_SC = sdp.SdpStruct("Cmd_Role_SetCirculationCareerHero_SC")
Cmd_Role_SetCirculationCareerHero_SC.Definition = {
  "vSetList",
  vSetList = {
    0,
    0,
    sdp.SdpVector(CmdCirculationCareerHeroLocation),
    nil
  }
}
