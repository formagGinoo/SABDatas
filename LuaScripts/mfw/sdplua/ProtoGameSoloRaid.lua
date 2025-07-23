local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_SoloRaid_GetData_CS = 12451
CmdId_SoloRaid_GetData_SC = 12452
CmdId_SoloRaid_ChooseRaid_CS = 12453
CmdId_SoloRaid_ChooseRaid_SC = 12454
CmdId_SoloRaid_MopUp_CS = 12455
CmdId_SoloRaid_MopUp_SC = 12456
CmdId_SoloRaid_Reset_CS = 12457
CmdId_SoloRaid_Reset_SC = 12458
CmdId_SoloRaid_GetRankList_CS = 12459
CmdId_SoloRaid_GetRankList_SC = 12460
CmdId_SoloRaid_GetPlayerRecord_CS = 12461
CmdId_SoloRaid_GetPlayerRecord_SC = 12462
CmdId_SoloRaid_GetMyRank_CS = 12463
CmdId_SoloRaid_GetMyRank_SC = 12464
SoloRaidMode_Normal = 1
SoloRaidMode_Hard = 2
CmdSoloRaidChallenge = sdp.SdpStruct("CmdSoloRaidChallenge")
CmdSoloRaidChallenge.Definition = {
  "iRaidId",
  "iStartTime",
  "iDamage",
  "iFightStartTime",
  "bPass",
  "mFightingMonster",
  "vUseHero",
  "vDamage",
  iRaidId = {
    0,
    0,
    8,
    0
  },
  iStartTime = {
    1,
    0,
    8,
    0
  },
  iDamage = {
    2,
    0,
    10,
    "0"
  },
  iFightStartTime = {
    3,
    0,
    8,
    0
  },
  bPass = {
    4,
    0,
    1,
    false
  },
  mFightingMonster = {
    5,
    0,
    sdp.SdpMap(8, CmdFightingMonster),
    nil
  },
  vUseHero = {
    6,
    0,
    sdp.SdpVector(sdp.SdpVector(8)),
    nil
  },
  vDamage = {
    7,
    0,
    sdp.SdpVector(10),
    nil
  }
}
CmdSoloRaidRecordHero = sdp.SdpStruct("CmdSoloRaidRecordHero")
CmdSoloRaidRecordHero.Definition = {
  "iHeroId",
  "iLevel",
  "iBreak",
  "iPower",
  "iFashion",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLevel = {
    1,
    0,
    8,
    0
  },
  iBreak = {
    2,
    0,
    8,
    0
  },
  iPower = {
    3,
    0,
    8,
    0
  },
  iFashion = {
    4,
    0,
    8,
    0
  }
}
CmdSoloRaidRecord = sdp.SdpStruct("CmdSoloRaidRecord")
CmdSoloRaidRecord.Definition = {
  "iRaidId",
  "iTime",
  "iDamage",
  "bPass",
  "vRecordHero",
  "vDamage",
  iRaidId = {
    0,
    0,
    8,
    0
  },
  iTime = {
    1,
    0,
    8,
    0
  },
  iDamage = {
    2,
    0,
    10,
    "0"
  },
  bPass = {
    3,
    0,
    1,
    false
  },
  vRecordHero = {
    4,
    0,
    sdp.SdpVector(sdp.SdpVector(CmdSoloRaidRecordHero)),
    nil
  },
  vDamage = {
    5,
    0,
    sdp.SdpVector(10),
    nil
  }
}
CmdSoloRaid = sdp.SdpStruct("CmdSoloRaid")
CmdSoloRaid.Definition = {
  "iActivityId",
  "iBossId",
  "vPassRaid",
  "stCurRaid",
  "mRecord",
  "vDailyPassRaid",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBossId = {
    1,
    0,
    8,
    0
  },
  vPassRaid = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  stCurRaid = {
    3,
    0,
    CmdSoloRaidChallenge,
    nil
  },
  mRecord = {
    4,
    0,
    sdp.SdpMap(8, CmdSoloRaidRecord),
    nil
  },
  vDailyPassRaid = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdSoloRaidRankItem = sdp.SdpStruct("CmdSoloRaidRankItem")
CmdSoloRaidRankItem.Definition = {
  "stRoleSimple",
  "iRank",
  "iScore",
  stRoleSimple = {
    0,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  iRank = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_SoloRaid_GetData_CS = sdp.SdpStruct("Cmd_SoloRaid_GetData_CS")
Cmd_SoloRaid_GetData_CS.Definition = {}
Cmd_SoloRaid_GetData_SC = sdp.SdpStruct("Cmd_SoloRaid_GetData_SC")
Cmd_SoloRaid_GetData_SC.Definition = {
  "stSoloRaid",
  "iNormalTimes",
  "iHardTimes",
  stSoloRaid = {
    0,
    0,
    CmdSoloRaid,
    nil
  },
  iNormalTimes = {
    1,
    0,
    8,
    0
  },
  iHardTimes = {
    2,
    0,
    8,
    0
  }
}
Cmd_SoloRaid_ChooseRaid_CS = sdp.SdpStruct("Cmd_SoloRaid_ChooseRaid_CS")
Cmd_SoloRaid_ChooseRaid_CS.Definition = {
  "iRaidId",
  iRaidId = {
    0,
    0,
    8,
    0
  }
}
Cmd_SoloRaid_ChooseRaid_SC = sdp.SdpStruct("Cmd_SoloRaid_ChooseRaid_SC")
Cmd_SoloRaid_ChooseRaid_SC.Definition = {
  "iRaidId",
  "stCurRaid",
  iRaidId = {
    0,
    0,
    8,
    0
  },
  stCurRaid = {
    1,
    0,
    CmdSoloRaidChallenge,
    nil
  }
}
Cmd_SoloRaid_MopUp_CS = sdp.SdpStruct("Cmd_SoloRaid_MopUp_CS")
Cmd_SoloRaid_MopUp_CS.Definition = {
  "iRaidId",
  iRaidId = {
    0,
    0,
    8,
    0
  }
}
Cmd_SoloRaid_MopUp_SC = sdp.SdpStruct("Cmd_SoloRaid_MopUp_SC")
Cmd_SoloRaid_MopUp_SC.Definition = {
  "iRaidId",
  "iFightTimes",
  "vReward",
  iRaidId = {
    0,
    0,
    8,
    0
  },
  iFightTimes = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_SoloRaid_Reset_CS = sdp.SdpStruct("Cmd_SoloRaid_Reset_CS")
Cmd_SoloRaid_Reset_CS.Definition = {}
Cmd_SoloRaid_Reset_SC = sdp.SdpStruct("Cmd_SoloRaid_Reset_SC")
Cmd_SoloRaid_Reset_SC.Definition = {
  "iRaidId",
  "stCurRaid",
  iRaidId = {
    0,
    0,
    8,
    0
  },
  stCurRaid = {
    1,
    0,
    CmdSoloRaidChallenge,
    nil
  }
}
Cmd_SoloRaid_GetRankList_CS = sdp.SdpStruct("Cmd_SoloRaid_GetRankList_CS")
Cmd_SoloRaid_GetRankList_CS.Definition = {
  "iBeginRank",
  "iEndRank",
  iBeginRank = {
    0,
    0,
    8,
    0
  },
  iEndRank = {
    1,
    0,
    8,
    0
  }
}
Cmd_SoloRaid_GetRankList_SC = sdp.SdpStruct("Cmd_SoloRaid_GetRankList_SC")
Cmd_SoloRaid_GetRankList_SC.Definition = {
  "vRankList",
  "iMyRank",
  "iMyScore",
  "iRankSize",
  vRankList = {
    0,
    0,
    sdp.SdpVector(CmdSoloRaidRankItem),
    nil
  },
  iMyRank = {
    1,
    0,
    8,
    0
  },
  iMyScore = {
    2,
    0,
    10,
    "0"
  },
  iRankSize = {
    3,
    0,
    8,
    0
  }
}
Cmd_SoloRaid_GetPlayerRecord_CS = sdp.SdpStruct("Cmd_SoloRaid_GetPlayerRecord_CS")
Cmd_SoloRaid_GetPlayerRecord_CS.Definition = {
  "stTargetId",
  stTargetId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_SoloRaid_GetPlayerRecord_SC = sdp.SdpStruct("Cmd_SoloRaid_GetPlayerRecord_SC")
Cmd_SoloRaid_GetPlayerRecord_SC.Definition = {
  "stTargetId",
  "stRecord",
  stTargetId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  stRecord = {
    1,
    0,
    CmdSoloRaidRecord,
    nil
  }
}
Cmd_SoloRaid_GetMyRank_CS = sdp.SdpStruct("Cmd_SoloRaid_GetMyRank_CS")
Cmd_SoloRaid_GetMyRank_CS.Definition = {}
Cmd_SoloRaid_GetMyRank_SC = sdp.SdpStruct("Cmd_SoloRaid_GetMyRank_SC")
Cmd_SoloRaid_GetMyRank_SC.Definition = {
  "iMyRank",
  "iRankSize",
  iMyRank = {
    0,
    0,
    8,
    0
  },
  iRankSize = {
    1,
    0,
    8,
    0
  }
}
