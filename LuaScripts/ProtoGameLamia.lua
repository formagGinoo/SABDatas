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
LamiaMiniGameType_Memory = 1
LamiaMiniGameType_Whacka = 2
LamiaMiniGameType_Explore = 1001
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
  vQuest = {
    0,
    0,
    sdp.SdpVector(CmdQuest),
    nil
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
