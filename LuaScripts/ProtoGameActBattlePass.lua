local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_BattlePass_GetLevelReward_CS = 59931
CmdId_Act_BattlePass_GetLevelReward_SC = 59932
CmdId_Act_BattlePass_BuyExp_CS = 59933
CmdId_Act_BattlePass_BuyExp_SC = 59934
BattlePassBuyStatus_Free = 0
BattlePassBuyStatus_Paid = 1
BattlePassBuyStatus_Advanced = 2
CmdActBattlePass_Status = sdp.SdpStruct("CmdActBattlePass_Status")
CmdActBattlePass_Status.Definition = {
  "iCurLevel",
  "iCurExp",
  "vDrawStatus",
  "vQuestId",
  "iBuyStatus",
  iCurLevel = {
    2,
    0,
    8,
    0
  },
  iCurExp = {
    3,
    0,
    8,
    0
  },
  vDrawStatus = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  },
  vQuestId = {
    5,
    0,
    sdp.SdpVector(8),
    nil
  },
  iBuyStatus = {
    6,
    0,
    8,
    0
  }
}
CmdActClientCfgBattlePass = sdp.SdpStruct("CmdActClientCfgBattlePass")
CmdActClientCfgBattlePass.Definition = {
  "sName",
  "iAvatarId",
  "iPrefab",
  sName = {
    0,
    0,
    13,
    ""
  },
  iAvatarId = {
    1,
    0,
    8,
    0
  },
  iPrefab = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgBattlePassLevelCfg = sdp.SdpStruct("CmdActCfgBattlePassLevelCfg")
CmdActCfgBattlePassLevelCfg.Definition = {
  "iLevel",
  "vFreeReward",
  "vPaidReward",
  iLevel = {
    0,
    0,
    8,
    0
  },
  vFreeReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vPaidReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdActCommonCfgBattlePass = sdp.SdpStruct("CmdActCommonCfgBattlePass")
CmdActCommonCfgBattlePass.Definition = {
  "sProductId",
  "iProductSubId",
  "vDailyQuest",
  "iCostPerExp",
  "iUpLevelExp",
  "iSendRewardMailId",
  "iNormalCostRatio",
  "iAdvancedCostRatio",
  "sAdvancedProductId",
  "iAdvancedProductSubId",
  "sAdvancedDifferenceProductId",
  "iAdvancedDifferenceProductSubId",
  "vAdvancedExtraReward",
  "iAdvancedExtraLevel",
  "mLevelCfg",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iProductSubId = {
    1,
    0,
    8,
    0
  },
  vDailyQuest = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  iCostPerExp = {
    3,
    0,
    8,
    0
  },
  iUpLevelExp = {
    4,
    0,
    8,
    0
  },
  iSendRewardMailId = {
    5,
    0,
    8,
    0
  },
  iNormalCostRatio = {
    6,
    0,
    8,
    0
  },
  iAdvancedCostRatio = {
    7,
    0,
    8,
    0
  },
  sAdvancedProductId = {
    8,
    0,
    13,
    ""
  },
  iAdvancedProductSubId = {
    9,
    0,
    8,
    0
  },
  sAdvancedDifferenceProductId = {
    10,
    0,
    13,
    ""
  },
  iAdvancedDifferenceProductSubId = {
    11,
    0,
    8,
    0
  },
  vAdvancedExtraReward = {
    12,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iAdvancedExtraLevel = {
    13,
    0,
    8,
    0
  },
  mLevelCfg = {
    14,
    0,
    sdp.SdpMap(8, CmdActCfgBattlePassLevelCfg),
    nil
  }
}
CmdActCfgBattlePass = sdp.SdpStruct("CmdActCfgBattlePass")
CmdActCfgBattlePass.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgBattlePass,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgBattlePass,
    nil
  }
}
CmdActBattlePassBuyParam = sdp.SdpStruct("CmdActBattlePassBuyParam")
CmdActBattlePassBuyParam.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_BattlePass_GetLevelReward_CS = sdp.SdpStruct("Cmd_Act_BattlePass_GetLevelReward_CS")
Cmd_Act_BattlePass_GetLevelReward_CS.Definition = {
  "iActivityId",
  "iLevel",
  iActivityId = {
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
  }
}
Cmd_Act_BattlePass_GetLevelReward_SC = sdp.SdpStruct("Cmd_Act_BattlePass_GetLevelReward_SC")
Cmd_Act_BattlePass_GetLevelReward_SC.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_BattlePass_BuyExp_CS = sdp.SdpStruct("Cmd_Act_BattlePass_BuyExp_CS")
Cmd_Act_BattlePass_BuyExp_CS.Definition = {
  "iActivityId",
  "iBuyExp",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBuyExp = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_BattlePass_BuyExp_SC = sdp.SdpStruct("Cmd_Act_BattlePass_BuyExp_SC")
Cmd_Act_BattlePass_BuyExp_SC.Definition = {}
