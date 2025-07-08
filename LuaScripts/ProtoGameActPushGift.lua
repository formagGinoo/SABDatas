local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
ActPushGiftTriggerType_PassStage = 1
ActPushGiftTriggerType_RoleBreak = 2
ActPushGiftTriggerType_RoleLevelBreak = 3
ActPushGiftTriggerType_PassTower = 4
ActPushGiftTriggerType_PassTower1 = 5
ActPushGiftTriggerType_PassTower2 = 6
ActPushGiftTriggerType_PassTower3 = 7
ActPushGiftTriggerType_PassTower4 = 8
ActPushGiftTriggerType_CommanderLevel = 9
ActPushGiftPriceType_RegDays = 1
ActPushGiftPriceType_LastPayDate = 2
ActPushGiftPriceType_LastMonthPayCnt = 3
ActPushGiftPriceType_TotalPayAmount = 4
ActPushGiftPriceType_LastMonthActiveDays = 5
CmdActCfgPushGiftGoods = sdp.SdpStruct("CmdActCfgPushGiftGoods")
CmdActCfgPushGiftGoods.Definition = {
  "iGiftIndex",
  "sProductID",
  "sGiftItems",
  "iGiftDiscount",
  "sGiftName",
  "sGiftStr",
  "iShow",
  iGiftIndex = {
    0,
    0,
    8,
    0
  },
  sProductID = {
    1,
    0,
    13,
    ""
  },
  sGiftItems = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iGiftDiscount = {
    3,
    0,
    8,
    0
  },
  sGiftName = {
    4,
    0,
    13,
    ""
  },
  sGiftStr = {
    5,
    0,
    13,
    ""
  },
  iShow = {
    6,
    0,
    8,
    0
  }
}
CmdActCfgPushGiftPrice = sdp.SdpStruct("CmdActCfgPushGiftPrice")
CmdActCfgPushGiftPrice.Definition = {
  "iID",
  "iType",
  "sVal",
  "iWeight",
  iID = {
    0,
    0,
    8,
    0
  },
  iType = {
    1,
    0,
    8,
    0
  },
  sVal = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iWeight = {
    3,
    0,
    8,
    0
  }
}
CmdActCfgPushGiftPushMax = sdp.SdpStruct("CmdActCfgPushGiftPushMax")
CmdActCfgPushGiftPushMax.Definition = {
  "iID",
  "iMaxPayPrice",
  "iMaxPushIndex",
  iID = {
    0,
    0,
    8,
    0
  },
  iMaxPayPrice = {
    1,
    0,
    8,
    0
  },
  iMaxPushIndex = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgPushGiftPushRfm = sdp.SdpStruct("CmdActCfgPushGiftPushRfm")
CmdActCfgPushGiftPushRfm.Definition = {
  "iID",
  "iMinScore",
  "iMaxScore",
  "vGiftIndex",
  iID = {
    0,
    0,
    8,
    0
  },
  iMinScore = {
    1,
    0,
    8,
    0
  },
  iMaxScore = {
    2,
    0,
    8,
    0
  },
  vGiftIndex = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActCfgPushGiftPay = sdp.SdpStruct("CmdActCfgPushGiftPay")
CmdActCfgPushGiftPay.Definition = {
  "iID",
  "iMinCharge",
  "iMaxCharge",
  "iGiftIndex1",
  "iGiftIndex2",
  "iGiftIndex3",
  iID = {
    0,
    0,
    8,
    0
  },
  iMinCharge = {
    1,
    0,
    8,
    0
  },
  iMaxCharge = {
    2,
    0,
    8,
    0
  },
  iGiftIndex1 = {
    3,
    0,
    8,
    0
  },
  iGiftIndex2 = {
    4,
    0,
    8,
    0
  },
  iGiftIndex3 = {
    5,
    0,
    8,
    0
  }
}
CmdActCfgPushGiftPushGoodsConfig = sdp.SdpStruct("CmdActCfgPushGiftPushGoodsConfig")
CmdActCfgPushGiftPushGoodsConfig.Definition = {
  "mGoods",
  mGoods = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgPushGiftGoods),
    nil
  }
}
CmdActCfgPushGiftRfmConfig = sdp.SdpStruct("CmdActCfgPushGiftRfmConfig")
CmdActCfgPushGiftRfmConfig.Definition = {
  "sUidLast",
  "sUidList",
  "mPrice",
  "mPushMax",
  "mPushRfm",
  sUidLast = {
    0,
    0,
    13,
    ""
  },
  sUidList = {
    1,
    0,
    13,
    ""
  },
  mPrice = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgPushGiftPrice),
    nil
  },
  mPushMax = {
    3,
    0,
    sdp.SdpMap(8, CmdActCfgPushGiftPushMax),
    nil
  },
  mPushRfm = {
    4,
    0,
    sdp.SdpMap(8, CmdActCfgPushGiftPushRfm),
    nil
  }
}
CmdActCfgPushGiftPushGroup = sdp.SdpStruct("CmdActCfgPushGiftPushGroup")
CmdActCfgPushGiftPushGroup.Definition = {
  "iGroupIndex",
  "iTriggerType",
  "vTriggerParam",
  "sIcon",
  "iTimeDuration",
  "iTitle",
  "stPushGoodsConfig",
  iGroupIndex = {
    0,
    0,
    8,
    0
  },
  iTriggerType = {
    1,
    0,
    8,
    0
  },
  vTriggerParam = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  sIcon = {
    3,
    0,
    13,
    ""
  },
  iTimeDuration = {
    4,
    0,
    8,
    0
  },
  iTitle = {
    5,
    0,
    13,
    ""
  },
  stPushGoodsConfig = {
    6,
    0,
    CmdActCfgPushGiftPushGoodsConfig,
    nil
  }
}
CmdActCfgPushGiftPayConfig = sdp.SdpStruct("CmdActCfgPushGiftPayConfig")
CmdActCfgPushGiftPayConfig.Definition = {
  "mPay",
  "stRfmConfig",
  mPay = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgPushGiftPay),
    nil
  },
  stRfmConfig = {
    1,
    0,
    CmdActCfgPushGiftRfmConfig,
    nil
  }
}
CmdActCommonCfgPushGift = sdp.SdpStruct("CmdActCommonCfgPushGift")
CmdActCommonCfgPushGift.Definition = {
  "iPayStoreActivityID",
  "iPushInterval",
  "iTotalPushCountDaily",
  "vProductSubIdLimit",
  "iDuration",
  "iPushType",
  "mPushGroup",
  "stPayConfig",
  iPayStoreActivityID = {
    0,
    0,
    8,
    0
  },
  iPushInterval = {
    1,
    0,
    8,
    0
  },
  iTotalPushCountDaily = {
    2,
    0,
    8,
    0
  },
  vProductSubIdLimit = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iDuration = {
    4,
    0,
    8,
    0
  },
  iPushType = {
    5,
    0,
    8,
    0
  },
  mPushGroup = {
    6,
    0,
    sdp.SdpMap(8, CmdActCfgPushGiftPushGroup),
    nil
  },
  stPayConfig = {
    7,
    0,
    CmdActCfgPushGiftPayConfig,
    nil
  }
}
CmdActCfgPushGift = sdp.SdpStruct("CmdActCfgPushGift")
CmdActCfgPushGift.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgPushGift,
    nil
  }
}
CmdActPushGiftInfo = sdp.SdpStruct("CmdActPushGiftInfo")
CmdActPushGiftInfo.Definition = {
  "iActivityID",
  "iGroupIndex",
  "vGiftIndex",
  "iExpireTime",
  "iSubProductID",
  "iTriggerParam",
  "iTotalRecharge",
  iActivityID = {
    0,
    0,
    8,
    0
  },
  iGroupIndex = {
    1,
    0,
    8,
    0
  },
  vGiftIndex = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  iExpireTime = {
    3,
    0,
    8,
    0
  },
  iSubProductID = {
    4,
    0,
    8,
    0
  },
  iTriggerParam = {
    5,
    0,
    8,
    0
  },
  iTotalRecharge = {
    6,
    0,
    8,
    0
  }
}
CmdActPushGiftBuyParam = sdp.SdpStruct("CmdActPushGiftBuyParam")
CmdActPushGiftBuyParam.Definition = {
  "iActivityId",
  "sExtraData",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  sExtraData = {
    1,
    0,
    13,
    ""
  }
}
CmdActPushGift_Status = sdp.SdpStruct("CmdActPushGift_Status")
CmdActPushGift_Status.Definition = {
  "iActivityId",
  "vPushGift",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vPushGift = {
    1,
    0,
    sdp.SdpVector(CmdActPushGiftInfo),
    nil
  }
}
