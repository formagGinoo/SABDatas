local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_LimitChainGift_OpenGiftGroup_CS = 60721
CmdId_Act_LimitChainGift_OpenGiftGroup_SC = 60722
CmdId_Act_LimitChainGift_CloseGiftGroup_CS = 60723
CmdId_Act_LimitChainGift_CloseGiftGroup_SC = 60724
CmdId_Act_LimitChainGift_TakeFreeGoods_CS = 60725
CmdId_Act_LimitChainGift_TakeFreeGoods_SC = 60726
CmdId_Act_LimitChainGift_TakeGroupScoreReward_CS = 60727
CmdId_Act_LimitChainGift_TakeGroupScoreReward_SC = 60728
LCGiftGoodsState_Purchased = 1
CmdActLimitChainGiftGroupInfo = sdp.SdpStruct("CmdActLimitChainGiftGroupInfo")
CmdActLimitChainGiftGroupInfo.Definition = {
  "iGiftGroupId",
  "iOpenTime",
  "GoodsState",
  "iScore",
  "bScoreRewarded",
  iGiftGroupId = {
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
  GoodsState = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iScore = {
    3,
    0,
    8,
    0
  },
  bScoreRewarded = {
    4,
    0,
    1,
    false
  }
}
CmdActLimitChainGift_Status = sdp.SdpStruct("CmdActLimitChainGift_Status")
CmdActLimitChainGift_Status.Definition = {
  "iActivityId",
  "stGiftGroupInfo",
  "mGiftGroupOpenedTimes",
  "iLastGiftGroupCloseTime",
  "mTriggeredGroup",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  stGiftGroupInfo = {
    1,
    0,
    CmdActLimitChainGiftGroupInfo,
    nil
  },
  mGiftGroupOpenedTimes = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iLastGiftGroupCloseTime = {
    3,
    0,
    8,
    0
  },
  mTriggeredGroup = {
    4,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdActLimitChainGiftBuyParam = sdp.SdpStruct("CmdActLimitChainGiftBuyParam")
CmdActLimitChainGiftBuyParam.Definition = {
  "iActivityId",
  "iGiftGroupId",
  "iGiftGoodsId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iGiftGroupId = {
    1,
    0,
    8,
    0
  },
  iGiftGoodsId = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgLimitChainGiftGoods = sdp.SdpStruct("CmdActCfgLimitChainGiftGoods")
CmdActCfgLimitChainGiftGoods.Definition = {
  "iGiftId",
  "sProductId",
  "iProductSubId",
  "vReward",
  "iScore",
  iGiftId = {
    0,
    0,
    8,
    0
  },
  sProductId = {
    1,
    0,
    13,
    ""
  },
  iProductSubId = {
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
  },
  iScore = {
    4,
    0,
    8,
    0
  }
}
CmdActCfgLimitChainGiftGiftGoodsCfg = sdp.SdpStruct("CmdActCfgLimitChainGiftGiftGoodsCfg")
CmdActCfgLimitChainGiftGiftGoodsCfg.Definition = {
  "mGoods",
  mGoods = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgLimitChainGiftGoods),
    nil
  }
}
CmdActCfgLimitChainGiftGiftGroup = sdp.SdpStruct("CmdActCfgLimitChainGiftGiftGroup")
CmdActCfgLimitChainGiftGiftGroup.Definition = {
  "iGiftGroupId",
  "iLimitTriggerNum",
  "sValueForMoney",
  "iTotalScore",
  "vScoreReward",
  "iCreateRoleDay",
  "iMinMainStage",
  "mGiftGoodsCfg",
  iGiftGroupId = {
    0,
    0,
    8,
    0
  },
  iLimitTriggerNum = {
    1,
    0,
    8,
    0
  },
  sValueForMoney = {
    2,
    0,
    13,
    ""
  },
  iTotalScore = {
    3,
    0,
    8,
    0
  },
  vScoreReward = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iCreateRoleDay = {
    5,
    0,
    8,
    0
  },
  iMinMainStage = {
    6,
    0,
    8,
    0
  },
  mGiftGoodsCfg = {
    7,
    0,
    CmdActCfgLimitChainGiftGiftGoodsCfg,
    nil
  }
}
CmdActCommonCfgLimitChainGift = sdp.SdpStruct("CmdActCommonCfgLimitChainGift")
CmdActCommonCfgLimitChainGift.Definition = {
  "iGiftGroupDuration",
  "iGiftGroupTriggerInterval",
  "mGiftGroup",
  iGiftGroupDuration = {
    0,
    0,
    8,
    0
  },
  iGiftGroupTriggerInterval = {
    1,
    0,
    8,
    0
  },
  mGiftGroup = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgLimitChainGiftGiftGroup),
    nil
  }
}
CmdActCfgLimitChainGift = sdp.SdpStruct("CmdActCfgLimitChainGift")
CmdActCfgLimitChainGift.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgLimitChainGift,
    nil
  }
}
Cmd_Act_LimitChainGift_OpenGiftGroup_CS = sdp.SdpStruct("Cmd_Act_LimitChainGift_OpenGiftGroup_CS")
Cmd_Act_LimitChainGift_OpenGiftGroup_CS.Definition = {
  "iActivityID",
  "iGiftGroupId",
  iActivityID = {
    0,
    0,
    8,
    0
  },
  iGiftGroupId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_LimitChainGift_OpenGiftGroup_SC = sdp.SdpStruct("Cmd_Act_LimitChainGift_OpenGiftGroup_SC")
Cmd_Act_LimitChainGift_OpenGiftGroup_SC.Definition = {
  "bSuccess",
  bSuccess = {
    0,
    0,
    1,
    false
  }
}
Cmd_Act_LimitChainGift_CloseGiftGroup_CS = sdp.SdpStruct("Cmd_Act_LimitChainGift_CloseGiftGroup_CS")
Cmd_Act_LimitChainGift_CloseGiftGroup_CS.Definition = {
  "iActivityID",
  "iGiftGroupId",
  iActivityID = {
    0,
    0,
    8,
    0
  },
  iGiftGroupId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_LimitChainGift_CloseGiftGroup_SC = sdp.SdpStruct("Cmd_Act_LimitChainGift_CloseGiftGroup_SC")
Cmd_Act_LimitChainGift_CloseGiftGroup_SC.Definition = {
  "bSuccess",
  bSuccess = {
    0,
    0,
    1,
    false
  }
}
Cmd_Act_LimitChainGift_TakeFreeGoods_CS = sdp.SdpStruct("Cmd_Act_LimitChainGift_TakeFreeGoods_CS")
Cmd_Act_LimitChainGift_TakeFreeGoods_CS.Definition = {
  "iActivityID",
  "iGiftGroupId",
  "iGiftGoodsId",
  iActivityID = {
    0,
    0,
    8,
    0
  },
  iGiftGroupId = {
    1,
    0,
    8,
    0
  },
  iGiftGoodsId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Act_LimitChainGift_TakeFreeGoods_SC = sdp.SdpStruct("Cmd_Act_LimitChainGift_TakeFreeGoods_SC")
Cmd_Act_LimitChainGift_TakeFreeGoods_SC.Definition = {
  "vReward",
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_LimitChainGift_TakeGroupScoreReward_CS = sdp.SdpStruct("Cmd_Act_LimitChainGift_TakeGroupScoreReward_CS")
Cmd_Act_LimitChainGift_TakeGroupScoreReward_CS.Definition = {
  "iActivityID",
  "iGiftGroupId",
  iActivityID = {
    0,
    0,
    8,
    0
  },
  iGiftGroupId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_LimitChainGift_TakeGroupScoreReward_SC = sdp.SdpStruct("Cmd_Act_LimitChainGift_TakeGroupScoreReward_SC")
Cmd_Act_LimitChainGift_TakeGroupScoreReward_SC.Definition = {
  "vReward",
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
