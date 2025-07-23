local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_Hunting_GetData_CS = 12501
CmdId_Hunting_GetData_SC = 12502
CmdId_Hunting_ChooseBuff_CS = 12503
CmdId_Hunting_ChooseBuff_SC = 12504
CmdId_Hunting_TakeBossReward_CS = 12505
CmdId_Hunting_TakeBossReward_SC = 12506
CmdId_Hunting_GetRankList_CS = 12507
CmdId_Hunting_GetRankList_SC = 12508
CmdId_Hunting_GetPlayerRecord_CS = 12509
CmdId_Hunting_GetPlayerRecord_SC = 12510
CmdId_Hunting_GetMyRank_CS = 12511
CmdId_Hunting_GetMyRank_SC = 12512
HuntingBossAchieveType_Bigger = 1
HuntingBossAchieveType_Smaller = 2
CmdHuntingBoss = sdp.SdpStruct("CmdHuntingBoss")
CmdHuntingBoss.Definition = {
  "iBossId",
  "iDamage",
  "vBuff",
  "vTaken",
  iBossId = {
    0,
    0,
    8,
    0
  },
  iDamage = {
    1,
    0,
    10,
    "0"
  },
  vBuff = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vTaken = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdHunting = sdp.SdpStruct("CmdHunting")
CmdHunting.Definition = {
  "iActivityId",
  "mBoss",
  "iRankGroupId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mBoss = {
    1,
    0,
    sdp.SdpMap(8, CmdHuntingBoss),
    nil
  },
  iRankGroupId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Hunting_GetData_CS = sdp.SdpStruct("Cmd_Hunting_GetData_CS")
Cmd_Hunting_GetData_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Hunting_GetData_SC = sdp.SdpStruct("Cmd_Hunting_GetData_SC")
Cmd_Hunting_GetData_SC.Definition = {
  "iActivityId",
  "stHunting",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  stHunting = {
    1,
    0,
    CmdHunting,
    nil
  }
}
Cmd_Hunting_ChooseBuff_CS = sdp.SdpStruct("Cmd_Hunting_ChooseBuff_CS")
Cmd_Hunting_ChooseBuff_CS.Definition = {
  "iActivityId",
  "iBossId",
  "vBuff",
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
  vBuff = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Hunting_ChooseBuff_SC = sdp.SdpStruct("Cmd_Hunting_ChooseBuff_SC")
Cmd_Hunting_ChooseBuff_SC.Definition = {
  "iActivityId",
  "iBossId",
  "vBuff",
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
  vBuff = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Hunting_TakeBossReward_CS = sdp.SdpStruct("Cmd_Hunting_TakeBossReward_CS")
Cmd_Hunting_TakeBossReward_CS.Definition = {
  "iActivityId",
  "iBossId",
  "vTakeReward",
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
  vTakeReward = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Hunting_TakeBossReward_SC = sdp.SdpStruct("Cmd_Hunting_TakeBossReward_SC")
Cmd_Hunting_TakeBossReward_SC.Definition = {
  "iActivityId",
  "iBossId",
  "vTaken",
  "vItem",
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
  vTaken = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vItem = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdHuntingRankItem = sdp.SdpStruct("CmdHuntingRankItem")
CmdHuntingRankItem.Definition = {
  "stRoleSimple",
  "iRank",
  "iValue",
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
  iValue = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Hunting_GetRankList_CS = sdp.SdpStruct("Cmd_Hunting_GetRankList_CS")
Cmd_Hunting_GetRankList_CS.Definition = {
  "iActivityId",
  "iBossId",
  "iBeginRank",
  "iEndRank",
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
  iBeginRank = {
    2,
    0,
    8,
    0
  },
  iEndRank = {
    3,
    0,
    8,
    0
  }
}
Cmd_Hunting_GetRankList_SC = sdp.SdpStruct("Cmd_Hunting_GetRankList_SC")
Cmd_Hunting_GetRankList_SC.Definition = {
  "iActivityId",
  "iBossId",
  "vRankList",
  "iMyRank",
  "iMyValue",
  "iRankSize",
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
  vRankList = {
    2,
    0,
    sdp.SdpVector(CmdHuntingRankItem),
    nil
  },
  iMyRank = {
    3,
    0,
    8,
    0
  },
  iMyValue = {
    4,
    0,
    10,
    "0"
  },
  iRankSize = {
    5,
    0,
    8,
    0
  }
}
CmdHuntingRecordHero = sdp.SdpStruct("CmdHuntingRecordHero")
CmdHuntingRecordHero.Definition = {
  "iHeroId",
  "iBreak",
  "iType",
  "iFashion",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iBreak = {
    1,
    0,
    8,
    0
  },
  iType = {
    2,
    0,
    8,
    0
  },
  iFashion = {
    3,
    0,
    8,
    0
  }
}
CmdHuntingBossRecord = sdp.SdpStruct("CmdHuntingBossRecord")
CmdHuntingBossRecord.Definition = {
  "vRecordHero",
  "vRecordBuff",
  vRecordHero = {
    0,
    0,
    sdp.SdpVector(CmdHuntingRecordHero),
    nil
  },
  vRecordBuff = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Hunting_GetPlayerRecord_CS = sdp.SdpStruct("Cmd_Hunting_GetPlayerRecord_CS")
Cmd_Hunting_GetPlayerRecord_CS.Definition = {
  "stTargetId",
  "iActivityId",
  "iBossId",
  stTargetId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iActivityId = {
    1,
    0,
    8,
    0
  },
  iBossId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Hunting_GetPlayerRecord_SC = sdp.SdpStruct("Cmd_Hunting_GetPlayerRecord_SC")
Cmd_Hunting_GetPlayerRecord_SC.Definition = {
  "stTargetId",
  "iActivityId",
  "iBossId",
  "stRecord",
  stTargetId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iActivityId = {
    1,
    0,
    8,
    0
  },
  iBossId = {
    2,
    0,
    8,
    0
  },
  stRecord = {
    3,
    0,
    CmdHuntingBossRecord,
    nil
  }
}
Cmd_Hunting_GetMyRank_CS = sdp.SdpStruct("Cmd_Hunting_GetMyRank_CS")
Cmd_Hunting_GetMyRank_CS.Definition = {
  "iActivityId",
  "iBossId",
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
  }
}
Cmd_Hunting_GetMyRank_SC = sdp.SdpStruct("Cmd_Hunting_GetMyRank_SC")
Cmd_Hunting_GetMyRank_SC.Definition = {
  "iActivityId",
  "iBossId",
  "iMyRank",
  "iRankSize",
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
  iMyRank = {
    2,
    0,
    8,
    0
  },
  iRankSize = {
    3,
    0,
    8,
    0
  }
}
