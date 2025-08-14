local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Fight_StartChallenge_CS = 19301
CmdId_Fight_StartChallenge_SC = 19302
CmdId_Fight_FinishChallenge_CS = 19303
CmdId_Fight_FinishChallenge_SC = 19304
CmdId_Fight_VerifyReplay_CS = 19305
CmdId_Fight_VerifyReplay_SC = 19306
CmdId_Fight_QuitChallenge_CS = 19307
CmdId_Fight_QuitChallenge_SC = 19308
FightType_Main = 1
FightType_Dungeon = 2
FightType_Tower = 3
FightType_Goblin = 4
FightType_Lamia = 5
FightType_LegacyStage = 7
FightType_SoloRaid = 8
FightType_AllianceBattle = 9
FightType_Arena = 10
FightType_Rogue = 11
FightType_ReplaceArena = 12
FightType_Hunting = 13
FightType_Letter = 14
FightType_Test = 99
FightType_Friend = 33
BattleWorldType_Normal = 0
BattleWorldType_Explore = 1
FightTestSubType_Client = 1
FightMainSubType_Main = 1
FightMainSubType_Ex = 2
FightMainSubType_Hard = 3
FightMainSubType_Branch = 4
FightDungeonSubType_Equip = 1
FightTowerSubType_Main = 1
FightTowerSubType_Tribe1 = 2
FightTowerSubType_Tribe2 = 3
FightTowerSubType_Tribe3 = 4
FightTowerSubType_Tribe4 = 5
FightGoblinSubType_Skill = 1
FightMainSubType_OriginalPvp = 1
FightMainSubType_OriginalPvpDef = 2
FightAllianceBattleSubType_Battle = 1
ReplaceArenaSubType_Attack_1 = 1
ReplaceArenaSubType_Attack_2 = 2
ReplaceArenaSubType_Attack_3 = 3
ReplaceArenaSubType_Defence_1 = 4
ReplaceArenaSubType_Defence_2 = 5
ReplaceArenaSubType_Defence_3 = 6
SoloRaidSubType_Fight = 1
RogueSubFightType_Fight = 1
LetterSubType_Fight = 1
FormPresetId_Normal_Begin = 1
FormPresetId_Normal_End = 10
FormPresetId_SoloRaid_Begin = 11
FormPresetId_SoloRaid_End = 20
FormPresetId_Max = 21
FightResult_Unkown = 0
FightResult_Server = 1
FightResult_Client = 2
FightResult_ClientError = 3
FightVerifyCheatType_None = 0
FightVerifyCheatType_InRange = 1
FightVerifyCheatType_OutRange = 2
FightVerifyCheatType_FrameDiff = 3
FightVerifyCheatType_AllowInRange = 4
FightVerifyCheatType_AllowOutRange = 5
FightVerifyCheatType_AllowFrameDiff = 6
CmdStartChallengeInfoCS = sdp.SdpStruct("CmdStartChallengeInfoCS")
CmdStartChallengeInfoCS.Definition = {
  "sCSharpMd5",
  "stVerifyInput",
  sCSharpMd5 = {
    1,
    0,
    13,
    ""
  },
  stVerifyInput = {
    2,
    0,
    CmdFightVerifyInput,
    nil
  }
}
CmdStartChallengeInfoSC = sdp.SdpStruct("CmdStartChallengeInfoSC")
CmdStartChallengeInfoSC.Definition = {
  "sCSharpMd5",
  "stVerifyInput",
  sCSharpMd5 = {
    2,
    0,
    13,
    ""
  },
  stVerifyInput = {
    3,
    0,
    CmdFightVerifyInput,
    nil
  }
}
CmdFightVerifyInfo = sdp.SdpStruct("CmdFightVerifyInfo")
CmdFightVerifyInfo.Definition = {
  "iFightId",
  "iFightUid",
  "iFightType",
  "iFightSubType",
  "sCSharpMd5",
  "bOnlyServerRun",
  "bNeedVerify",
  "sVersion",
  "iBeginTime",
  "iClientFightUid",
  "bSkipFight",
  iFightId = {
    0,
    0,
    8,
    0
  },
  iFightUid = {
    1,
    0,
    10,
    "0"
  },
  iFightType = {
    2,
    0,
    8,
    0
  },
  iFightSubType = {
    3,
    0,
    8,
    0
  },
  sCSharpMd5 = {
    4,
    0,
    13,
    ""
  },
  bOnlyServerRun = {
    5,
    0,
    1,
    false
  },
  bNeedVerify = {
    6,
    0,
    1,
    true
  },
  sVersion = {
    7,
    0,
    13,
    ""
  },
  iBeginTime = {
    8,
    0,
    8,
    0
  },
  iClientFightUid = {
    9,
    0,
    10,
    "0"
  },
  bSkipFight = {
    10,
    0,
    1,
    false
  }
}
CmdFightVerifyResult = sdp.SdpStruct("CmdFightVerifyResult")
CmdFightVerifyResult.Definition = {
  "iVerifyReturnValue",
  "vCheatReason",
  "iFightUid",
  "iClientFightUid",
  "iVerifyWaitTimeMS",
  "iVerifyRealUsedTimeMS",
  "iCSharpReturnValue",
  "iFightResultType",
  "iCheatType",
  "iOverloadType",
  iVerifyReturnValue = {
    0,
    0,
    7,
    0
  },
  vCheatReason = {
    2,
    0,
    sdp.SdpVector(13),
    nil
  },
  iFightUid = {
    3,
    0,
    10,
    "0"
  },
  iClientFightUid = {
    4,
    0,
    10,
    "0"
  },
  iVerifyWaitTimeMS = {
    6,
    0,
    10,
    "0"
  },
  iVerifyRealUsedTimeMS = {
    7,
    0,
    10,
    "0"
  },
  iCSharpReturnValue = {
    8,
    0,
    7,
    0
  },
  iFightResultType = {
    9,
    0,
    5,
    0
  },
  iCheatType = {
    10,
    0,
    7,
    0
  },
  iOverloadType = {
    11,
    0,
    5,
    0
  }
}
CmdMultiFightTestInfo = sdp.SdpStruct("CmdMultiFightTestInfo")
CmdMultiFightTestInfo.Definition = {
  "iFightTestId",
  "iAllTimes",
  "iCurTimes",
  "iBeginTime",
  iFightTestId = {
    0,
    0,
    10,
    "0"
  },
  iAllTimes = {
    1,
    0,
    8,
    0
  },
  iCurTimes = {
    2,
    0,
    8,
    0
  },
  iBeginTime = {
    3,
    0,
    8,
    0
  }
}
CmdFightVerifyData = sdp.SdpStruct("CmdFightVerifyData")
CmdFightVerifyData.Definition = {
  "stVerifyInfo",
  "stVerifyResult",
  "stVerifyInput",
  "stVerifyOutputSer",
  "stVerifyOutputCli",
  "stMultiFightTestInfo",
  stVerifyInfo = {
    0,
    0,
    CmdFightVerifyInfo,
    nil
  },
  stVerifyResult = {
    1,
    0,
    CmdFightVerifyResult,
    nil
  },
  stVerifyInput = {
    2,
    0,
    CmdFightVerifyInput,
    nil
  },
  stVerifyOutputSer = {
    3,
    0,
    CmdFightVerifyOutput,
    nil
  },
  stVerifyOutputCli = {
    4,
    0,
    CmdFightVerifyOutput,
    nil
  },
  stMultiFightTestInfo = {
    5,
    0,
    CmdMultiFightTestInfo,
    nil
  }
}
CmdFinishChallengeInfoCS = sdp.SdpStruct("CmdFinishChallengeInfoCS")
CmdFinishChallengeInfoCS.Definition = {
  "iFightId",
  "iFightUid",
  "iFightType",
  "iFightSubType",
  "sCSharpMd5",
  "stVerifyInput",
  "stVerifyOutputCli",
  "stMultiFightTestInfo",
  "bClientErr",
  "bSkipFight",
  "sLogFightDataForReport",
  iFightId = {
    0,
    0,
    8,
    0
  },
  iFightUid = {
    1,
    0,
    10,
    "0"
  },
  iFightType = {
    2,
    0,
    8,
    0
  },
  iFightSubType = {
    3,
    0,
    8,
    0
  },
  sCSharpMd5 = {
    4,
    0,
    13,
    ""
  },
  stVerifyInput = {
    5,
    0,
    CmdFightVerifyInput,
    nil
  },
  stVerifyOutputCli = {
    6,
    0,
    CmdFightVerifyOutput,
    nil
  },
  stMultiFightTestInfo = {
    7,
    0,
    CmdMultiFightTestInfo,
    nil
  },
  bClientErr = {
    8,
    0,
    1,
    false
  },
  bSkipFight = {
    9,
    0,
    1,
    false
  },
  sLogFightDataForReport = {
    10,
    0,
    13,
    ""
  }
}
CmdFinishChallengeInfoSC = sdp.SdpStruct("CmdFinishChallengeInfoSC")
CmdFinishChallengeInfoSC.Definition = {
  "vReward",
  "vExtraReward",
  "vFirstPassReward",
  "stVerifyInfo",
  "stVerifyResult",
  "stMultiFightTestInfo",
  "bWin",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vExtraReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vFirstPassReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  stVerifyInfo = {
    3,
    0,
    CmdFightVerifyInfo,
    nil
  },
  stVerifyResult = {
    4,
    0,
    CmdFightVerifyResult,
    nil
  },
  stMultiFightTestInfo = {
    5,
    0,
    CmdMultiFightTestInfo,
    nil
  },
  bWin = {
    6,
    0,
    1,
    false
  }
}
Cmd_Fight_StartChallenge_CS = sdp.SdpStruct("Cmd_Fight_StartChallenge_CS")
Cmd_Fight_StartChallenge_CS.Definition = {
  "stStartChallengeInfoCS",
  "iActivityID",
  "iEnemyId",
  "iRound",
  "iBossId",
  stStartChallengeInfoCS = {
    0,
    0,
    CmdStartChallengeInfoCS,
    nil
  },
  iActivityID = {
    1,
    0,
    8,
    0
  },
  iEnemyId = {
    2,
    0,
    8,
    0
  },
  iRound = {
    3,
    0,
    8,
    0
  },
  iBossId = {
    4,
    0,
    8,
    0
  }
}
Cmd_Fight_StartChallenge_SC = sdp.SdpStruct("Cmd_Fight_StartChallenge_SC")
Cmd_Fight_StartChallenge_SC.Definition = {
  "iFightType",
  "iFightSubType",
  "iStageId",
  "stStartChallengeInfoSC",
  "iActivityID",
  "iEnemyId",
  "iRound",
  "iBossId",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  },
  iStageId = {
    2,
    0,
    8,
    0
  },
  stStartChallengeInfoSC = {
    3,
    0,
    CmdStartChallengeInfoSC,
    nil
  },
  iActivityID = {
    4,
    0,
    8,
    0
  },
  iEnemyId = {
    5,
    0,
    8,
    0
  },
  iRound = {
    6,
    0,
    8,
    0
  },
  iBossId = {
    7,
    0,
    8,
    0
  }
}
Cmd_Fight_FinishChallenge_CS = sdp.SdpStruct("Cmd_Fight_FinishChallenge_CS")
Cmd_Fight_FinishChallenge_CS.Definition = {
  "iFightType",
  "iFightSubType",
  "iStageId",
  "stFinishChallengeInfoCS",
  "iActivityID",
  "iEnemyId",
  "iRound",
  "iBossId",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  },
  iStageId = {
    2,
    0,
    8,
    0
  },
  stFinishChallengeInfoCS = {
    3,
    0,
    CmdFinishChallengeInfoCS,
    nil
  },
  iActivityID = {
    4,
    0,
    8,
    0
  },
  iEnemyId = {
    5,
    0,
    8,
    0
  },
  iRound = {
    6,
    0,
    8,
    0
  },
  iBossId = {
    7,
    0,
    8,
    0
  }
}
Cmd_Fight_FinishChallenge_SC = sdp.SdpStruct("Cmd_Fight_FinishChallenge_SC")
Cmd_Fight_FinishChallenge_SC.Definition = {
  "iFightType",
  "iFightSubType",
  "iStageId",
  "stFinishChallengeInfoSC",
  "iActivityID",
  "iScore",
  "mFightingMonster",
  "vResult",
  "iRound",
  "iBossId",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  },
  iStageId = {
    2,
    0,
    8,
    0
  },
  stFinishChallengeInfoSC = {
    3,
    0,
    CmdFinishChallengeInfoSC,
    nil
  },
  iActivityID = {
    4,
    0,
    8,
    0
  },
  iScore = {
    5,
    0,
    8,
    0
  },
  mFightingMonster = {
    6,
    0,
    sdp.SdpMap(8, CmdFightingMonster),
    nil
  },
  vResult = {
    7,
    0,
    sdp.SdpVector(8),
    nil
  },
  iRound = {
    8,
    0,
    8,
    0
  },
  iBossId = {
    9,
    0,
    8,
    0
  }
}
Cmd_Fight_VerifyReplay_CS = sdp.SdpStruct("Cmd_Fight_VerifyReplay_CS")
Cmd_Fight_VerifyReplay_CS.Definition = {
  "stFinishChallengeInfoCS",
  "stVerifyInput",
  stFinishChallengeInfoCS = {
    0,
    0,
    CmdFinishChallengeInfoCS,
    nil
  },
  stVerifyInput = {
    1,
    0,
    CmdFightVerifyInput,
    nil
  }
}
Cmd_Fight_VerifyReplay_SC = sdp.SdpStruct("Cmd_Fight_VerifyReplay_SC")
Cmd_Fight_VerifyReplay_SC.Definition = {
  "iFightType",
  "iFightSubType",
  "iScore",
  "stFinishChallengeInfoSC",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    8,
    0
  },
  stFinishChallengeInfoSC = {
    3,
    0,
    CmdFinishChallengeInfoSC,
    nil
  }
}
Cmd_Fight_QuitChallenge_CS = sdp.SdpStruct("Cmd_Fight_QuitChallenge_CS")
Cmd_Fight_QuitChallenge_CS.Definition = {
  "iFightType",
  "iFightSubType",
  "bRound",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  },
  bRound = {
    2,
    0,
    1,
    false
  }
}
Cmd_Fight_QuitChallenge_SC = sdp.SdpStruct("Cmd_Fight_QuitChallenge_SC")
Cmd_Fight_QuitChallenge_SC.Definition = {
  "iFightType",
  "iFightSubType",
  "bRound",
  iFightType = {
    0,
    0,
    8,
    0
  },
  iFightSubType = {
    1,
    0,
    8,
    0
  },
  bRound = {
    2,
    0,
    1,
    false
  }
}
