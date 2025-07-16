local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
FightTestResultState_Success = 1
FightTestResultState_Timeout = 2
FightTestResultState_ClientErr = 3
BalanceFightTestTeam = sdp.SdpStruct("BalanceFightTestTeam")
BalanceFightTestTeam.Definition = {
  "iTeamID",
  "iSeasonID",
  "vHero",
  "vPos",
  iTeamID = {
    0,
    0,
    8,
    0
  },
  iSeasonID = {
    1,
    0,
    8,
    0
  },
  vHero = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPos = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
FightTestOneResult = sdp.SdpStruct("FightTestOneResult")
FightTestOneResult.Definition = {
  "iID",
  "iReportID",
  "vAttackHero",
  "vDefendHero",
  "bWin",
  "iScore",
  "sError",
  "iCostTime",
  "iOverloadType",
  "iVerifyReturnValue",
  "sReportID",
  "iState",
  "iErrorType",
  "iArrangeID",
  "stAttacker",
  "stDefender",
  iID = {
    0,
    0,
    10,
    "0"
  },
  iReportID = {
    1,
    0,
    10,
    "0"
  },
  vAttackHero = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vDefendHero = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  bWin = {
    4,
    0,
    1,
    false
  },
  iScore = {
    5,
    0,
    8,
    0
  },
  sError = {
    6,
    0,
    13,
    ""
  },
  iCostTime = {
    7,
    0,
    8,
    0
  },
  iOverloadType = {
    8,
    0,
    5,
    0
  },
  iVerifyReturnValue = {
    9,
    0,
    7,
    0
  },
  sReportID = {
    10,
    0,
    13,
    ""
  },
  iState = {
    11,
    0,
    8,
    0
  },
  iErrorType = {
    12,
    0,
    8,
    0
  },
  iArrangeID = {
    13,
    0,
    8,
    0
  },
  stAttacker = {
    14,
    0,
    BalanceFightTestTeam,
    nil
  },
  stDefender = {
    15,
    0,
    BalanceFightTestTeam,
    nil
  }
}
FightTestResult = sdp.SdpStruct("FightTestResult")
FightTestResult.Definition = {
  "mResult",
  mResult = {
    0,
    0,
    sdp.SdpMap(10, FightTestOneResult),
    nil
  }
}
FightTestStatus = sdp.SdpStruct("FightTestStatus")
FightTestStatus.Definition = {
  "iStartTime",
  "iEndTime",
  "iTargetTestTimes",
  "iEachLoopTestTimes",
  "iFinishedTimes",
  "iFinishedAndRunningTimes",
  "eState",
  "iAttackIndex",
  "iDefendIndex",
  "iSuccessTimes",
  "iTimeoutTimes",
  "iErrorTimes",
  iStartTime = {
    0,
    0,
    10,
    "0"
  },
  iEndTime = {
    1,
    0,
    10,
    "0"
  },
  iTargetTestTimes = {
    2,
    0,
    10,
    "0"
  },
  iEachLoopTestTimes = {
    3,
    0,
    8,
    0
  },
  iFinishedTimes = {
    4,
    0,
    10,
    "0"
  },
  iFinishedAndRunningTimes = {
    5,
    0,
    10,
    "0"
  },
  eState = {
    6,
    0,
    8,
    0
  },
  iAttackIndex = {
    7,
    0,
    8,
    0
  },
  iDefendIndex = {
    8,
    0,
    8,
    0
  },
  iSuccessTimes = {
    9,
    0,
    8,
    0
  },
  iTimeoutTimes = {
    10,
    0,
    8,
    0
  },
  iErrorTimes = {
    11,
    0,
    8,
    0
  }
}
FightTestResumeData = sdp.SdpStruct("FightTestResumeData")
FightTestResumeData.Definition = {
  "stState",
  stState = {
    0,
    0,
    FightTestStatus,
    nil
  }
}
FightTestStartResult = sdp.SdpStruct("FightTestStartResult")
FightTestStartResult.Definition = {
  "iStartTime",
  iStartTime = {
    0,
    0,
    10,
    "0"
  }
}
BalanceFightTestRound = sdp.SdpStruct("BalanceFightTestRound")
BalanceFightTestRound.Definition = {
  "iRoundID",
  "vInitTeamID",
  "mTeamScore",
  "vResult",
  iRoundID = {
    0,
    0,
    8,
    0
  },
  vInitTeamID = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  mTeamScore = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  vResult = {
    3,
    0,
    sdp.SdpVector(FightTestOneResult),
    nil
  }
}
BalanceFightTestSeason = sdp.SdpStruct("BalanceFightTestSeason")
BalanceFightTestSeason.Definition = {
  "iSeasonID",
  "vRounds",
  "mTeams",
  "vWinTeams",
  iSeasonID = {
    0,
    0,
    8,
    0
  },
  vRounds = {
    1,
    0,
    sdp.SdpVector(BalanceFightTestRound),
    nil
  },
  mTeams = {
    2,
    0,
    sdp.SdpMap(8, BalanceFightTestTeam),
    nil
  },
  vWinTeams = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
BalanceFightFinalHeroSeasonTimes = sdp.SdpStruct("BalanceFightFinalHeroSeasonTimes")
BalanceFightFinalHeroSeasonTimes.Definition = {
  "iSeasonID",
  "mHeroTimes",
  iSeasonID = {
    0,
    0,
    8,
    0
  },
  mHeroTimes = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
BalanceFightFinalHeroData = sdp.SdpStruct("BalanceFightFinalHeroData")
BalanceFightFinalHeroData.Definition = {
  "vHeroList",
  "vHeroSeasonTimes",
  vHeroList = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vHeroSeasonTimes = {
    1,
    0,
    sdp.SdpVector(BalanceFightFinalHeroSeasonTimes),
    nil
  }
}
BalanceFightTestState = sdp.SdpStruct("BalanceFightTestState")
BalanceFightTestState.Definition = {
  "iStartTime",
  "iEndTime",
  "iFinishedTimes",
  "iScriptID",
  "iCurSeason",
  "iTotalSeason",
  "iCurRound",
  "iTotalRound",
  "eState",
  "iSuccessTimes",
  "iTimeoutTimes",
  "iErrorTimes",
  "vTeams",
  "vResult",
  "stFinalHeroData",
  iStartTime = {
    0,
    0,
    10,
    "0"
  },
  iEndTime = {
    1,
    0,
    10,
    "0"
  },
  iFinishedTimes = {
    2,
    0,
    10,
    "0"
  },
  iScriptID = {
    4,
    0,
    8,
    0
  },
  iCurSeason = {
    5,
    0,
    8,
    0
  },
  iTotalSeason = {
    6,
    0,
    8,
    0
  },
  iCurRound = {
    7,
    0,
    8,
    0
  },
  iTotalRound = {
    8,
    0,
    8,
    0
  },
  eState = {
    9,
    0,
    8,
    0
  },
  iSuccessTimes = {
    10,
    0,
    8,
    0
  },
  iTimeoutTimes = {
    11,
    0,
    8,
    0
  },
  iErrorTimes = {
    12,
    0,
    8,
    0
  },
  vTeams = {
    13,
    0,
    sdp.SdpVector(BalanceFightTestTeam),
    nil
  },
  vResult = {
    14,
    0,
    sdp.SdpVector(FightTestOneResult),
    nil
  },
  stFinalHeroData = {
    15,
    0,
    BalanceFightFinalHeroData,
    nil
  }
}
BalanceFightTestSeasonReport = sdp.SdpStruct("BalanceFightTestSeasonReport")
BalanceFightTestSeasonReport.Definition = {
  "stAttacker",
  "stDefender",
  "iFightReportID",
  "bWin",
  "iState",
  stAttacker = {
    0,
    0,
    BalanceFightTestTeam,
    nil
  },
  stDefender = {
    1,
    0,
    BalanceFightTestTeam,
    nil
  },
  iFightReportID = {
    2,
    0,
    10,
    "0"
  },
  bWin = {
    3,
    0,
    1,
    false
  },
  iState = {
    4,
    0,
    8,
    0
  }
}
BalanceFightTestSeasonInfo = sdp.SdpStruct("BalanceFightTestSeasonInfo")
BalanceFightTestSeasonInfo.Definition = {
  "iSeasonID",
  "vWinTeams",
  "mHeroRate",
  iSeasonID = {
    0,
    0,
    8,
    0
  },
  vWinTeams = {
    1,
    0,
    sdp.SdpVector(BalanceFightTestTeam),
    nil
  },
  mHeroRate = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
AutoTestArangeResult = sdp.SdpStruct("AutoTestArangeResult")
AutoTestArangeResult.Definition = {
  "iArrangeID",
  "iChallengeTimes",
  "iAttakerPower",
  "iDefenderPower",
  "iWinTimes",
  "vHeroID",
  "vHeroPos",
  "vResult",
  iArrangeID = {
    0,
    0,
    8,
    0
  },
  iChallengeTimes = {
    1,
    0,
    8,
    0
  },
  iAttakerPower = {
    2,
    0,
    7,
    0
  },
  iDefenderPower = {
    3,
    0,
    7,
    0
  },
  iWinTimes = {
    4,
    0,
    8,
    0
  },
  vHeroID = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  },
  vHeroPos = {
    6,
    0,
    sdp.SdpVector(8),
    nil
  },
  vResult = {
    7,
    0,
    sdp.SdpVector(FightTestOneResult),
    nil
  }
}
AutoTestStageResult = sdp.SdpStruct("AutoTestStageResult")
AutoTestStageResult.Definition = {
  "iStageID",
  "mResult",
  iStageID = {
    0,
    0,
    8,
    0
  },
  mResult = {
    1,
    0,
    sdp.SdpMap(8, AutoTestArangeResult),
    nil
  }
}
AutoTestData = sdp.SdpStruct("AutoTestData")
AutoTestData.Definition = {
  "iStartTime",
  "iEndTime",
  "iState",
  "mStageData",
  iStartTime = {
    0,
    0,
    8,
    0
  },
  iEndTime = {
    1,
    0,
    8,
    0
  },
  iState = {
    2,
    0,
    8,
    0
  },
  mStageData = {
    3,
    0,
    sdp.SdpMap(8, AutoTestStageResult),
    nil
  }
}
