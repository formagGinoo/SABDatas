local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_LevelAward_GetAward_CS = 59871
CmdId_Act_LevelAward_GetAward_SC = 59872
CmdActLevelAward_Status = sdp.SdpStruct("CmdActLevelAward_Status")
CmdActLevelAward_Status.Definition = {
  "vQuest",
  vQuest = {
    0,
    0,
    sdp.SdpVector(CmdQuest),
    nil
  }
}
CmdActCfgLevelAwardQuest = sdp.SdpStruct("CmdActCfgLevelAwardQuest")
CmdActCfgLevelAwardQuest.Definition = {
  "iId",
  "iObjectiveType",
  "sObjectiveData",
  "iObjectiveCount",
  "vReward",
  "iJump",
  "sName",
  iId = {
    0,
    0,
    8,
    0
  },
  iObjectiveType = {
    1,
    0,
    8,
    0
  },
  sObjectiveData = {
    2,
    0,
    13,
    ""
  },
  iObjectiveCount = {
    3,
    0,
    8,
    0
  },
  vReward = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iJump = {
    5,
    0,
    8,
    0
  },
  sName = {
    6,
    0,
    13,
    ""
  }
}
CmdActCfgLevelAwardHeroConfig = sdp.SdpStruct("CmdActCfgLevelAwardHeroConfig")
CmdActCfgLevelAwardHeroConfig.Definition = {
  "iHeroId",
  "vUseQuestId",
  "sUnlockDesc",
  "sJumpContent",
  "iJumpType",
  "sJumpParam",
  "iOrder",
  "sOutsideDesc",
  "sInsideDesc",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  vUseQuestId = {
    1,
    0,
    13,
    ""
  },
  sUnlockDesc = {
    2,
    0,
    13,
    ""
  },
  sJumpContent = {
    3,
    0,
    13,
    ""
  },
  iJumpType = {
    4,
    0,
    8,
    0
  },
  sJumpParam = {
    5,
    0,
    13,
    ""
  },
  iOrder = {
    6,
    0,
    8,
    0
  },
  sOutsideDesc = {
    7,
    0,
    13,
    ""
  },
  sInsideDesc = {
    8,
    0,
    13,
    ""
  }
}
CmdActCfgLevelAwardMultiHeroConfig = sdp.SdpStruct("CmdActCfgLevelAwardMultiHeroConfig")
CmdActCfgLevelAwardMultiHeroConfig.Definition = {
  "vHeroConfig",
  vHeroConfig = {
    0,
    0,
    sdp.SdpVector(CmdActCfgLevelAwardHeroConfig),
    nil
  }
}
CmdActCfgLevelAwardOneHeroConfig = sdp.SdpStruct("CmdActCfgLevelAwardOneHeroConfig")
CmdActCfgLevelAwardOneHeroConfig.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
CmdActClientCfgLevelAward = sdp.SdpStruct("CmdActClientCfgLevelAward")
CmdActClientCfgLevelAward.Definition = {
  "iShowType",
  "stOneHeroConfig",
  "stMultiHeroConfig",
  "iRedQuestId",
  iShowType = {
    0,
    0,
    8,
    0
  },
  stOneHeroConfig = {
    1,
    0,
    CmdActCfgLevelAwardOneHeroConfig,
    nil
  },
  stMultiHeroConfig = {
    2,
    0,
    CmdActCfgLevelAwardMultiHeroConfig,
    nil
  },
  iRedQuestId = {
    3,
    0,
    8,
    0
  }
}
CmdActCfgLevelAward = sdp.SdpStruct("CmdActCfgLevelAward")
CmdActCfgLevelAward.Definition = {
  "mQuest",
  "stClientCfg",
  mQuest = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgLevelAwardQuest),
    nil
  },
  stClientCfg = {
    1,
    0,
    CmdActClientCfgLevelAward,
    nil
  }
}
Cmd_Act_LevelAward_GetAward_CS = sdp.SdpStruct("Cmd_Act_LevelAward_GetAward_CS")
Cmd_Act_LevelAward_GetAward_CS.Definition = {
  "iActivityId",
  "iID",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iID = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_LevelAward_GetAward_SC = sdp.SdpStruct("Cmd_Act_LevelAward_GetAward_SC")
Cmd_Act_LevelAward_GetAward_SC.Definition = {
  "iActivityId",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
