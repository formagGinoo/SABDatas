local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_Arena_StartChallenge_CS = 11101
CmdId_Arena_StartChallenge_SC = 11102
CmdId_Arena_FinishChallenge_CS = 11103
CmdId_Arena_FinishChallenge_SC = 11104
CmdId_Arena_QuitChallenge_CS = 11105
CmdId_Arena_QuitChallenge_SC = 11106
Cmd_Arena_StartChallenge_CS = sdp.SdpStruct("Cmd_Arena_StartChallenge_CS")
Cmd_Arena_StartChallenge_CS.Definition = {
  "iFightType",
  "iFightSubType",
  "iEnemyId",
  "stStartChallengeInfoCS",
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
  iEnemyId = {
    2,
    0,
    8,
    0
  },
  stStartChallengeInfoCS = {
    3,
    0,
    CmdStartChallengeInfoCS,
    nil
  }
}
Cmd_Arena_StartChallenge_SC = sdp.SdpStruct("Cmd_Arena_StartChallenge_SC")
Cmd_Arena_StartChallenge_SC.Definition = {
  "iFightType",
  "iFightSubType",
  "stStartChallengeInfoSC",
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
  stStartChallengeInfoSC = {
    2,
    0,
    CmdStartChallengeInfoSC,
    nil
  }
}
Cmd_Arena_FinishChallenge_CS = sdp.SdpStruct("Cmd_Arena_FinishChallenge_CS")
Cmd_Arena_FinishChallenge_CS.Definition = {
  "iFightType",
  "iFightSubType",
  "iEnemyId",
  "stFinishChallengeInfoCS",
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
  iEnemyId = {
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
  }
}
Cmd_Arena_FinishChallenge_SC = sdp.SdpStruct("Cmd_Arena_FinishChallenge_SC")
Cmd_Arena_FinishChallenge_SC.Definition = {
  "iFightType",
  "iFightSubType",
  "stFinishChallengeInfoSC",
  "vResult",
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
  stFinishChallengeInfoSC = {
    2,
    0,
    CmdFinishChallengeInfoSC,
    nil
  },
  vResult = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Arena_QuitChallenge_CS = sdp.SdpStruct("Cmd_Arena_QuitChallenge_CS")
Cmd_Arena_QuitChallenge_CS.Definition = {
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
Cmd_Arena_QuitChallenge_SC = sdp.SdpStruct("Cmd_Arena_QuitChallenge_SC")
Cmd_Arena_QuitChallenge_SC.Definition = {
  "bRound",
  bRound = {
    0,
    0,
    1,
    false
  }
}
