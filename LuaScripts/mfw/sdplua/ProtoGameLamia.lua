local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
LamiaQuestType_Invalid = 0
LamiaQuestType_Daily = 1
LamiaQuestType_Total = 2
LamiaSubActType_Normal = 11
LamiaSubActType_Hard = 12
LamiaSubActType_Challenge = 13
LamiaSubActType_SignIn = 14
LamiaSubActType_Quest = 15
LamiaSubActType_MiniGame = 16
LamiaSubActType_DailyQuest = 18
LamiaSubActType_GameQuest = 19
LamiaMiniGameType_Memory = 1
LamiaMiniGameType_Whacka = 2
LamiaMiniGameType_LegacyStage = 3
LamiaMiniGameType_Explore = 1001
LamiaMiniGameMode_Normal = 1
LamiaMiniGameMode_Boss = 2
LamiaMiniGameMode_Infinite = 3
CmdId_Lamia_GetList_CS = 19101
CmdId_Lamia_GetList_SC = 19102
CmdId_Lamia_SignIn_GetAward_CS = 19103
CmdId_Lamia_SignIn_GetAward_SC = 19104
CmdId_Lamia_Quest_GetAward_CS = 19105
CmdId_Lamia_Quest_GetAward_SC = 19106
CmdId_Lamia_Quest_GetAllAward_CS = 19107
CmdId_Lamia_Quest_GetAllAward_SC = 19108
CmdId_Lamia_MiniGame_Finish_CS = 19109
CmdId_Lamia_MiniGame_Finish_SC = 19110
CmdId_Lamia_MiniGame_GetAllAward_CS = 19111
CmdId_Lamia_MiniGame_GetAllAward_SC = 19112
CmdId_Lamia_Stage_Sweep_CS = 19113
CmdId_Lamia_Stage_Sweep_SC = 19114
CmdId_Lamia_GetExploreData_CS = 19115
CmdId_Lamia_GetExploreData_SC = 19116
CmdId_Lamia_SetExploreData_CS = 19117
CmdId_Lamia_SetExploreData_SC = 19118
CmdId_Lamia_DailyQuest_GetAward_CS = 19119
CmdId_Lamia_DailyQuest_GetAward_SC = 19120
CmdId_Lamia_GameQuest_GetAward_CS = 19121
CmdId_Lamia_GameQuest_GetAward_SC = 19122
CmdId_Lamia_GameQuest_GetAllAward_CS = 19123
CmdId_Lamia_GameQuest_GetAllAward_SC = 19124
CmdId_Lamia_GetClueAward_CS = 19125
CmdId_Lamia_GetClueAward_SC = 19126
CmdId_Lamia_GetSubActAward_CS = 19127
CmdId_Lamia_GetSubActAward_SC = 19128
LamiaGameStat_Doing = 0
LamiaGameStat_Finish = 1
LamiaSignIn = sdp.SdpStruct("LamiaSignIn")
LamiaSignIn.Definition = {
  "iLoginDays",
  "iAwardedMaxDays",
  "iLastLoginTime",
  iLoginDays = {
    0,
    0,
    8,
    0
  },
  iAwardedMaxDays = {
    1,
    0,
    8,
    0
  },
  iLastLoginTime = {
    2,
    0,
    10,
    "0"
  }
}
LamiaQuest = sdp.SdpStruct("LamiaQuest")
LamiaQuest.Definition = {
  "vQuest",
  "vDailyQuest",
  "vGameQuest",
  "iDaiyQuestActive",
  vQuest = {
    0,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  vDailyQuest = {
    1,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  vGameQuest = {
    2,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  iDaiyQuestActive = {
    3,
    0,
    8,
    0
  }
}
LamiaMiniGame = sdp.SdpStruct("LamiaMiniGame")
LamiaMiniGame.Definition = {
  "mGameStat",
  "iMaxAwardedGame",
  mGameStat = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iMaxAwardedGame = {
    1,
    0,
    8,
    0
  }
}
LamiaStage = sdp.SdpStruct("LamiaStage")
LamiaStage.Definition = {
  "iLastPassedStage",
  "mStageStat",
  "iPassedTimesDaily",
  iLastPassedStage = {
    0,
    0,
    8,
    0
  },
  mStageStat = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iPassedTimesDaily = {
    2,
    0,
    8,
    0
  }
}
LamiaData = sdp.SdpStruct("LamiaData")
LamiaData.Definition = {
  "iActId",
  "stSign",
  "stQuest",
  "stMiniGame",
  "mStageStat",
  "vAwardedClue",
  "vAwardedSubAct",
  iActId = {
    0,
    0,
    8,
    0
  },
  stSign = {
    1,
    0,
    LamiaSignIn,
    nil
  },
  stQuest = {
    2,
    0,
    LamiaQuest,
    nil
  },
  stMiniGame = {
    3,
    0,
    LamiaMiniGame,
    nil
  },
  mStageStat = {
    4,
    0,
    sdp.SdpMap(8, LamiaStage),
    nil
  },
  vAwardedClue = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  },
  vAwardedSubAct = {
    6,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Lamia_GetList_CS = sdp.SdpStruct("Cmd_Lamia_GetList_CS")
Cmd_Lamia_GetList_CS.Definition = {}
Cmd_Lamia_GetList_SC = sdp.SdpStruct("Cmd_Lamia_GetList_SC")
Cmd_Lamia_GetList_SC.Definition = {
  "vList",
  vList = {
    0,
    0,
    sdp.SdpVector(LamiaData),
    nil
  }
}
Cmd_Lamia_SignIn_GetAward_CS = sdp.SdpStruct("Cmd_Lamia_SignIn_GetAward_CS")
Cmd_Lamia_SignIn_GetAward_CS.Definition = {
  "iActId",
  iActId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Lamia_SignIn_GetAward_SC = sdp.SdpStruct("Cmd_Lamia_SignIn_GetAward_SC")
Cmd_Lamia_SignIn_GetAward_SC.Definition = {
  "iActId",
  "iAwardedMaxDays",
  "vAward",
  iActId = {
    0,
    0,
    8,
    0
  },
  iAwardedMaxDays = {
    1,
    0,
    8,
    0
  },
  vAward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Lamia_Quest_GetAward_CS = sdp.SdpStruct("Cmd_Lamia_Quest_GetAward_CS")
Cmd_Lamia_Quest_GetAward_CS.Definition = {
  "iActId",
  "iQuestId",
  iActId = {
    0,
    0,
    8,
    0
  },
  iQuestId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Lamia_Quest_GetAward_SC = sdp.SdpStruct("Cmd_Lamia_Quest_GetAward_SC")
Cmd_Lamia_Quest_GetAward_SC.Definition = {
  "iActId",
  "vAward",
  "stQuest",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  stQuest = {
    2,
    0,
    CmdQuest,
    nil
  }
}
Cmd_Lamia_Quest_GetAllAward_CS = sdp.SdpStruct("Cmd_Lamia_Quest_GetAllAward_CS")
Cmd_Lamia_Quest_GetAllAward_CS.Definition = {
  "iActId",
  iActId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Lamia_Quest_GetAllAward_SC = sdp.SdpStruct("Cmd_Lamia_Quest_GetAllAward_SC")
Cmd_Lamia_Quest_GetAllAward_SC.Definition = {
  "iActId",
  "vAward",
  "vQuest",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vQuest = {
    2,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  }
}
Cmd_Lamia_MiniGame_Finish_CS = sdp.SdpStruct("Cmd_Lamia_MiniGame_Finish_CS")
Cmd_Lamia_MiniGame_Finish_CS.Definition = {
  "iActId",
  "iSubActId",
  "iGameId",
  "iScore",
  iActId = {
    0,
    0,
    8,
    0
  },
  iSubActId = {
    1,
    0,
    8,
    0
  },
  iGameId = {
    2,
    0,
    8,
    0
  },
  iScore = {
    3,
    0,
    8,
    0
  }
}
Cmd_Lamia_MiniGame_Finish_SC = sdp.SdpStruct("Cmd_Lamia_MiniGame_Finish_SC")
Cmd_Lamia_MiniGame_Finish_SC.Definition = {
  "iActId",
  "iSubActId",
  "iGameId",
  "iGameStat",
  "vAward",
  iActId = {
    0,
    0,
    8,
    0
  },
  iSubActId = {
    1,
    0,
    8,
    0
  },
  iGameId = {
    2,
    0,
    8,
    0
  },
  iGameStat = {
    3,
    0,
    8,
    0
  },
  vAward = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Lamia_MiniGame_GetAllAward_CS = sdp.SdpStruct("Cmd_Lamia_MiniGame_GetAllAward_CS")
Cmd_Lamia_MiniGame_GetAllAward_CS.Definition = {
  "iActId",
  "iSubActId",
  iActId = {
    0,
    0,
    8,
    0
  },
  iSubActId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Lamia_MiniGame_GetAllAward_SC = sdp.SdpStruct("Cmd_Lamia_MiniGame_GetAllAward_SC")
Cmd_Lamia_MiniGame_GetAllAward_SC.Definition = {
  "iActId",
  "iSubActId",
  "vAward",
  "iMaxAwardedGame",
  iActId = {
    0,
    0,
    8,
    0
  },
  iSubActId = {
    1,
    0,
    8,
    0
  },
  vAward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iMaxAwardedGame = {
    3,
    0,
    8,
    0
  }
}
Cmd_Lamia_Stage_Sweep_CS = sdp.SdpStruct("Cmd_Lamia_Stage_Sweep_CS")
Cmd_Lamia_Stage_Sweep_CS.Definition = {
  "iActId",
  "iStageId",
  "iTimes",
  "vHeroList",
  iActId = {
    0,
    0,
    8,
    0
  },
  iStageId = {
    1,
    0,
    8,
    0
  },
  iTimes = {
    2,
    0,
    8,
    0
  },
  vHeroList = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Lamia_Stage_Sweep_SC = sdp.SdpStruct("Cmd_Lamia_Stage_Sweep_SC")
Cmd_Lamia_Stage_Sweep_SC.Definition = {
  "iActId",
  "iStageId",
  "vAward",
  "vExtraAward",
  "iPassedTimesDaily",
  iActId = {
    0,
    0,
    8,
    0
  },
  iStageId = {
    1,
    0,
    8,
    0
  },
  vAward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vExtraAward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iPassedTimesDaily = {
    4,
    0,
    8,
    0
  }
}
CmdActExploreUnitData = sdp.SdpStruct("CmdActExploreUnitData")
CmdActExploreUnitData.Definition = {
  "iID",
  "iState",
  "fPosX",
  "fPosY",
  "fPosZ",
  "fRotation",
  "mCounters",
  "iCfgID",
  iID = {
    0,
    0,
    7,
    0
  },
  iState = {
    1,
    0,
    7,
    0
  },
  fPosX = {
    2,
    0,
    11,
    0
  },
  fPosY = {
    3,
    0,
    11,
    0
  },
  fPosZ = {
    4,
    0,
    11,
    0
  },
  fRotation = {
    5,
    0,
    11,
    0
  },
  mCounters = {
    6,
    0,
    sdp.SdpMap(13, 7),
    nil
  },
  iCfgID = {
    7,
    0,
    7,
    0
  }
}
Cmd_Lamia_GetExploreData_CS = sdp.SdpStruct("Cmd_Lamia_GetExploreData_CS")
Cmd_Lamia_GetExploreData_CS.Definition = {
  "iActId",
  iActId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Lamia_GetExploreData_SC = sdp.SdpStruct("Cmd_Lamia_GetExploreData_SC")
Cmd_Lamia_GetExploreData_SC.Definition = {
  "vExplore",
  vExplore = {
    0,
    0,
    sdp.SdpVector(CmdActExploreUnitData),
    nil
  }
}
Cmd_Lamia_SetExploreData_CS = sdp.SdpStruct("Cmd_Lamia_SetExploreData_CS")
Cmd_Lamia_SetExploreData_CS.Definition = {
  "iActId",
  "vExplore",
  iActId = {
    0,
    0,
    8,
    0
  },
  vExplore = {
    1,
    0,
    sdp.SdpVector(CmdActExploreUnitData),
    nil
  }
}
Cmd_Lamia_SetExploreData_SC = sdp.SdpStruct("Cmd_Lamia_SetExploreData_SC")
Cmd_Lamia_SetExploreData_SC.Definition = {}
Cmd_Lamia_DailyQuest_GetAward_CS = sdp.SdpStruct("Cmd_Lamia_DailyQuest_GetAward_CS")
Cmd_Lamia_DailyQuest_GetAward_CS.Definition = {
  "iActId",
  "vQuestId",
  iActId = {
    0,
    0,
    8,
    0
  },
  vQuestId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Lamia_DailyQuest_GetAward_SC = sdp.SdpStruct("Cmd_Lamia_DailyQuest_GetAward_SC")
Cmd_Lamia_DailyQuest_GetAward_SC.Definition = {
  "iActId",
  "vAward",
  "vQuest",
  "iDaiyQuestActive",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vQuest = {
    2,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  },
  iDaiyQuestActive = {
    3,
    0,
    8,
    0
  }
}
Cmd_Lamia_GameQuest_GetAward_CS = sdp.SdpStruct("Cmd_Lamia_GameQuest_GetAward_CS")
Cmd_Lamia_GameQuest_GetAward_CS.Definition = {
  "iActId",
  "iQuestId",
  iActId = {
    0,
    0,
    8,
    0
  },
  iQuestId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Lamia_GameQuest_GetAward_SC = sdp.SdpStruct("Cmd_Lamia_GameQuest_GetAward_SC")
Cmd_Lamia_GameQuest_GetAward_SC.Definition = {
  "iActId",
  "vAward",
  "stQuest",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  stQuest = {
    2,
    0,
    CmdQuest,
    nil
  }
}
Cmd_Lamia_GameQuest_GetAllAward_CS = sdp.SdpStruct("Cmd_Lamia_GameQuest_GetAllAward_CS")
Cmd_Lamia_GameQuest_GetAllAward_CS.Definition = {
  "iActId",
  iActId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Lamia_GameQuest_GetAllAward_SC = sdp.SdpStruct("Cmd_Lamia_GameQuest_GetAllAward_SC")
Cmd_Lamia_GameQuest_GetAllAward_SC.Definition = {
  "iActId",
  "vAward",
  "vQuest",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vQuest = {
    2,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  }
}
Cmd_Lamia_GetClueAward_CS = sdp.SdpStruct("Cmd_Lamia_GetClueAward_CS")
Cmd_Lamia_GetClueAward_CS.Definition = {
  "iActId",
  "iClueID",
  iActId = {
    0,
    0,
    8,
    0
  },
  iClueID = {
    1,
    0,
    8,
    0
  }
}
Cmd_Lamia_GetClueAward_SC = sdp.SdpStruct("Cmd_Lamia_GetClueAward_SC")
Cmd_Lamia_GetClueAward_SC.Definition = {
  "iActId",
  "vAwardedClue",
  "vReward",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAwardedClue = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Lamia_GetSubActAward_CS = sdp.SdpStruct("Cmd_Lamia_GetSubActAward_CS")
Cmd_Lamia_GetSubActAward_CS.Definition = {
  "iActId",
  "iSubActId",
  iActId = {
    0,
    0,
    8,
    0
  },
  iSubActId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Lamia_GetSubActAward_SC = sdp.SdpStruct("Cmd_Lamia_GetSubActAward_SC")
Cmd_Lamia_GetSubActAward_SC.Definition = {
  "iActId",
  "vAwardedSubAct",
  "vRewards",
  iActId = {
    0,
    0,
    8,
    0
  },
  vAwardedSubAct = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vRewards = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
