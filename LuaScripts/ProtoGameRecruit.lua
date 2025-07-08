local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Recruit_Recruit_CS = 10701
CmdId_Recruit_Recruit_SC = 10702
CmdId_Recruit_GetInit_CS = 10703
CmdId_Recruit_GetInit_SC = 10704
CmdId_Recruit_Replacement_CS = 10705
CmdId_Recruit_Replacement_SC = 10706
CmdId_Recruit_ReplacementConfirm_CS = 10707
CmdId_Recruit_ReplacementConfirm_SC = 10708
CmdId_Recruit_ScoreAward_CS = 10709
CmdId_Recruit_ScoreAward_SC = 10710
CmdId_Recruit_SelectHero_CS = 10711
CmdId_Recruit_SelectHero_SC = 10712
CmdId_Recruit_StarLifeReward_CS = 10713
CmdId_Recruit_StarLifeReward_SC = 10714
RecruitType_Senior = 1
RecruitTimesType_One = 1
RecruitTimesType_Ten = 10
RecruitCostType_Free = 0
RecruitCostType_Item = 1
CmdRecruitInfo = sdp.SdpStruct("CmdRecruitInfo")
CmdRecruitInfo.Definition = {
  "iLastJuniorRecruitFreeTime",
  "iLastSeniorRecruitFreeTime",
  "iSeniorRecruitScore",
  "iLastEquipRecruitFreeTime",
  "iTotalSeniorRecruitScore",
  "bSeniorTen",
  "bOldReward",
  "iForecastGetHeros",
  "iForecastGetHeroTime",
  "iForecastCurHero",
  "iStarLifeRecruitScore",
  "iStarLifeRecruitScoreTotal",
  "iCNChannelDailyTotalRecruitTime",
  "iLastWishTick",
  iLastJuniorRecruitFreeTime = {
    1,
    0,
    8,
    0
  },
  iLastSeniorRecruitFreeTime = {
    2,
    0,
    8,
    0
  },
  iSeniorRecruitScore = {
    3,
    0,
    8,
    0
  },
  iLastEquipRecruitFreeTime = {
    4,
    0,
    8,
    0
  },
  iTotalSeniorRecruitScore = {
    5,
    0,
    8,
    0
  },
  bSeniorTen = {
    6,
    0,
    1,
    false
  },
  bOldReward = {
    7,
    0,
    1,
    false
  },
  iForecastGetHeros = {
    8,
    0,
    8,
    0
  },
  iForecastGetHeroTime = {
    9,
    0,
    8,
    0
  },
  iForecastCurHero = {
    10,
    0,
    8,
    0
  },
  iStarLifeRecruitScore = {
    11,
    0,
    8,
    0
  },
  iStarLifeRecruitScoreTotal = {
    12,
    0,
    8,
    0
  },
  iCNChannelDailyTotalRecruitTime = {
    13,
    0,
    8,
    0
  },
  iLastWishTick = {
    14,
    0,
    8,
    0
  }
}
Cmd_Recruit_Recruit_CS = sdp.SdpStruct("Cmd_Recruit_Recruit_CS")
Cmd_Recruit_Recruit_CS.Definition = {
  "iRecruitId",
  "iRecruitTimes",
  "iActivityId",
  iRecruitId = {
    0,
    0,
    8,
    0
  },
  iRecruitTimes = {
    1,
    0,
    8,
    0
  },
  iActivityId = {
    3,
    0,
    8,
    0
  }
}
Cmd_Recruit_Recruit_SC = sdp.SdpStruct("Cmd_Recruit_Recruit_SC")
Cmd_Recruit_Recruit_SC.Definition = {
  "vRecruitItem",
  "stRecruitInfo",
  "bCardToPiece",
  "vExtraItem",
  "vItemFromDecompose",
  vRecruitItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  stRecruitInfo = {
    1,
    0,
    CmdRecruitInfo,
    nil
  },
  bCardToPiece = {
    3,
    0,
    1,
    false
  },
  vExtraItem = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vItemFromDecompose = {
    5,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Recruit_GetInit_CS = sdp.SdpStruct("Cmd_Recruit_GetInit_CS")
Cmd_Recruit_GetInit_CS.Definition = {}
Cmd_Recruit_GetInit_SC = sdp.SdpStruct("Cmd_Recruit_GetInit_SC")
Cmd_Recruit_GetInit_SC.Definition = {
  "stRecruitInfo",
  stRecruitInfo = {
    0,
    0,
    CmdRecruitInfo,
    nil
  }
}
Cmd_Recruit_Replacement_CS = sdp.SdpStruct("Cmd_Recruit_Replacement_CS")
Cmd_Recruit_Replacement_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Recruit_Replacement_SC = sdp.SdpStruct("Cmd_Recruit_Replacement_SC")
Cmd_Recruit_Replacement_SC.Definition = {
  "stHeroData",
  stHeroData = {
    0,
    0,
    CmdHeroData,
    nil
  }
}
Cmd_Recruit_ReplacementConfirm_CS = sdp.SdpStruct("Cmd_Recruit_ReplacementConfirm_CS")
Cmd_Recruit_ReplacementConfirm_CS.Definition = {
  "bConfirm",
  bConfirm = {
    0,
    0,
    1,
    false
  }
}
Cmd_Recruit_ReplacementConfirm_SC = sdp.SdpStruct("Cmd_Recruit_ReplacementConfirm_SC")
Cmd_Recruit_ReplacementConfirm_SC.Definition = {}
Cmd_Recruit_ScoreAward_CS = sdp.SdpStruct("Cmd_Recruit_ScoreAward_CS")
Cmd_Recruit_ScoreAward_CS.Definition = {
  "iHeroCampType",
  iHeroCampType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Recruit_ScoreAward_SC = sdp.SdpStruct("Cmd_Recruit_ScoreAward_SC")
Cmd_Recruit_ScoreAward_SC.Definition = {
  "vItem",
  "iSeniorRecruitScore",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iSeniorRecruitScore = {
    1,
    0,
    8,
    0
  }
}
Cmd_Recruit_SelectHero_CS = sdp.SdpStruct("Cmd_Recruit_SelectHero_CS")
Cmd_Recruit_SelectHero_CS.Definition = {
  "iBaseId",
  iBaseId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Recruit_SelectHero_SC = sdp.SdpStruct("Cmd_Recruit_SelectHero_SC")
Cmd_Recruit_SelectHero_SC.Definition = {}
Cmd_Recruit_StarLifeReward_CS = sdp.SdpStruct("Cmd_Recruit_StarLifeReward_CS")
Cmd_Recruit_StarLifeReward_CS.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Recruit_StarLifeReward_SC = sdp.SdpStruct("Cmd_Recruit_StarLifeReward_SC")
Cmd_Recruit_StarLifeReward_SC.Definition = {
  "vItem",
  "iStarLifeRecruitScore",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iStarLifeRecruitScore = {
    1,
    0,
    8,
    0
  }
}
