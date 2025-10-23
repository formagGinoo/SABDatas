local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_PartDungeonWelfare_GetTotalScore_CS = 60781
CmdId_Act_PartDungeonWelfare_GetTotalScore_SC = 60782
CmdId_Act_PartDungeonWelfare_DrawReward_CS = 60783
CmdId_Act_PartDungeonWelfare_DrawReward_SC = 60784
CmdActPartDungeonWelfare_Status = sdp.SdpStruct("CmdActPartDungeonWelfare_Status")
CmdActPartDungeonWelfare_Status.Definition = {
  "iSelfScore",
  "iDrawScore",
  iSelfScore = {
    0,
    0,
    8,
    0
  },
  iDrawScore = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgPartDungeonWelfareStageConfig = sdp.SdpStruct("CmdActCfgPartDungeonWelfareStageConfig")
CmdActCfgPartDungeonWelfareStageConfig.Definition = {
  "iStageId",
  "iScore",
  iStageId = {
    0,
    0,
    8,
    0
  },
  iScore = {
    1,
    0,
    8,
    0
  }
}
CmdActCommonCfgPartDungeonWelfare = sdp.SdpStruct("CmdActCommonCfgPartDungeonWelfare")
CmdActCommonCfgPartDungeonWelfare.Definition = {
  "vFightSubType",
  "iScoreItemId",
  "mStageConfig",
  "vQuestId",
  "mRewardConfig",
  vFightSubType = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iScoreItemId = {
    1,
    0,
    8,
    0
  },
  mStageConfig = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgPartDungeonWelfareStageConfig),
    nil
  },
  vQuestId = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  mRewardConfig = {
    4,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
CmdActCfgPartDungeonWelfare = sdp.SdpStruct("CmdActCfgPartDungeonWelfare")
CmdActCfgPartDungeonWelfare.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgPartDungeonWelfare,
    nil
  }
}
Cmd_Act_PartDungeonWelfare_GetTotalScore_CS = sdp.SdpStruct("Cmd_Act_PartDungeonWelfare_GetTotalScore_CS")
Cmd_Act_PartDungeonWelfare_GetTotalScore_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_PartDungeonWelfare_GetTotalScore_SC = sdp.SdpStruct("Cmd_Act_PartDungeonWelfare_GetTotalScore_SC")
Cmd_Act_PartDungeonWelfare_GetTotalScore_SC.Definition = {
  "iTotalScore",
  iTotalScore = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_PartDungeonWelfare_DrawReward_CS = sdp.SdpStruct("Cmd_Act_PartDungeonWelfare_DrawReward_CS")
Cmd_Act_PartDungeonWelfare_DrawReward_CS.Definition = {
  "iActivityId",
  "iDrawScore",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iDrawScore = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_PartDungeonWelfare_DrawReward_SC = sdp.SdpStruct("Cmd_Act_PartDungeonWelfare_DrawReward_SC")
Cmd_Act_PartDungeonWelfare_DrawReward_SC.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
