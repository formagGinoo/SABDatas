local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_HeroTrial_SetLevelFinish_CS = 60601
CmdId_Act_HeroTrial_SetLevelFinish_SC = 60602
CmdId_Act_HeroTrial_TakeLevelReward_CS = 60603
CmdId_Act_HeroTrial_TakeLevelReward_SC = 60604
HeroTrialLevelStatus_Init = 0
HeroTrialLevelStatus_Finish = 1
HeroTrialLevelStatus_Rewarded = 2
CmdActHeroTrial_Status = sdp.SdpStruct("CmdActHeroTrial_Status")
CmdActHeroTrial_Status.Definition = {
  "mLevelStatus",
  mLevelStatus = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdActCfgHeroTrialTrialLevel = sdp.SdpStruct("CmdActCfgHeroTrialTrialLevel")
CmdActCfgHeroTrialTrialLevel.Definition = {
  "iLevelId",
  "iOpenTime",
  "iCloseTime",
  iLevelId = {
    0,
    0,
    8,
    0
  },
  iOpenTime = {
    1,
    0,
    8,
    0
  },
  iCloseTime = {
    2,
    0,
    8,
    0
  }
}
CmdActCommonCfgHeroTrial = sdp.SdpStruct("CmdActCommonCfgHeroTrial")
CmdActCommonCfgHeroTrial.Definition = {
  "mTrialLevel",
  mTrialLevel = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgHeroTrialTrialLevel),
    nil
  }
}
CmdActCfgHeroTrial = sdp.SdpStruct("CmdActCfgHeroTrial")
CmdActCfgHeroTrial.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgHeroTrial,
    nil
  }
}
Cmd_Act_HeroTrial_SetLevelFinish_CS = sdp.SdpStruct("Cmd_Act_HeroTrial_SetLevelFinish_CS")
Cmd_Act_HeroTrial_SetLevelFinish_CS.Definition = {
  "iActivityId",
  "iLevelId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_HeroTrial_SetLevelFinish_SC = sdp.SdpStruct("Cmd_Act_HeroTrial_SetLevelFinish_SC")
Cmd_Act_HeroTrial_SetLevelFinish_SC.Definition = {
  "iActivityId",
  "iLevelId",
  "iStatus",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  },
  iStatus = {
    2,
    0,
    8,
    0
  }
}
Cmd_Act_HeroTrial_TakeLevelReward_CS = sdp.SdpStruct("Cmd_Act_HeroTrial_TakeLevelReward_CS")
Cmd_Act_HeroTrial_TakeLevelReward_CS.Definition = {
  "iActivityId",
  "iLevelId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_HeroTrial_TakeLevelReward_SC = sdp.SdpStruct("Cmd_Act_HeroTrial_TakeLevelReward_SC")
Cmd_Act_HeroTrial_TakeLevelReward_SC.Definition = {
  "iActivityId",
  "iLevelId",
  "iStatus",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLevelId = {
    1,
    0,
    8,
    0
  },
  iStatus = {
    2,
    0,
    8,
    0
  },
  vReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
