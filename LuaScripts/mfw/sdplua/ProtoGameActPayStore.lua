local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_PayStore_SelectReward_CS = 59911
CmdId_Act_PayStore_SelectReward_SC = 59912
CmdId_Act_PayStore_FreeReward_CS = 59913
CmdId_Act_PayStore_FreeReward_SC = 59914
CmdActPayStoreRefreshType_None = 1
CmdActPayStoreRefreshType_Day = 2
CmdActPayStoreRefreshType_Week = 3
CmdActPayStoreRefreshType_Month = 4
CmdActPayStoreRefreshType_Time = 5
CmdActPayStoreType_Up = 11
CmdActPayStoreType_StepupGift = 12
CmdActPayStoreType_PickupGift = 13
CmdActPayStoreType_OpenCard = 14
CmdActPayStoreType_OpenNewShop = 15
CmdActPayStoreType_OpenBeginner = 16
CmdActPayStoreType_PushGift = 17
CmdActPayStoreType_Permanent = 18
CmdActPayStoreType_MainStage = 19
CmdActPayStoreType_MonthlyCard = 20
CmdActPayStoreType_DaimondBuy = 21
CmdActPayStoreType_SignGift = 22
CmdActPayStoreType_FashionStore = 23
CmdActPayStoreType_PickupGiftNew = 24
CmdActPayStoreBuyParam = sdp.SdpStruct("CmdActPayStoreBuyParam")
CmdActPayStoreBuyParam.Definition = {
  "iActivityId",
  "iStoreId",
  "iGoodsId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iStoreId = {
    1,
    0,
    8,
    0
  },
  iGoodsId = {
    2,
    0,
    8,
    0
  }
}
CmdActPayStoreGoods = sdp.SdpStruct("CmdActPayStoreGoods")
CmdActPayStoreGoods.Definition = {
  "iGoodsId",
  "iBuyTimes",
  iGoodsId = {
    0,
    0,
    8,
    0
  },
  iBuyTimes = {
    1,
    0,
    8,
    0
  }
}
CmdActPayStoreInfo = sdp.SdpStruct("CmdActPayStoreInfo")
CmdActPayStoreInfo.Definition = {
  "iRefreshTime",
  "mGoods",
  iRefreshTime = {
    0,
    0,
    8,
    0
  },
  mGoods = {
    1,
    0,
    sdp.SdpMap(8, CmdActPayStoreGoods),
    nil
  }
}
CmdActPayStore_Status = sdp.SdpStruct("CmdActPayStore_Status")
CmdActPayStore_Status.Definition = {
  "iActivityId",
  "mStore",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mStore = {
    1,
    0,
    sdp.SdpMap(8, CmdActPayStoreInfo),
    nil
  }
}
CmdActCfgPayStoreGoods = sdp.SdpStruct("CmdActCfgPayStoreGoods")
CmdActCfgPayStoreGoods.Definition = {
  "iGoodsId",
  "iMinLevel",
  "iMaxLevel",
  "iMinMainStage",
  "iMaxMainStage",
  "sProductId",
  "iProductSubId",
  "iLimitNum",
  "iPreGoodsId",
  "vReward",
  "vRewardExt",
  "sGoodsName",
  "sGoodsDesc",
  "sGoodsPic",
  "iDiscount",
  "iShowOrder",
  "iRecommend",
  "iLaunchTime",
  "iRemovalTime",
  iGoodsId = {
    0,
    0,
    8,
    0
  },
  iMinLevel = {
    1,
    0,
    8,
    0
  },
  iMaxLevel = {
    2,
    0,
    8,
    0
  },
  iMinMainStage = {
    3,
    0,
    8,
    0
  },
  iMaxMainStage = {
    4,
    0,
    8,
    0
  },
  sProductId = {
    5,
    0,
    13,
    ""
  },
  iProductSubId = {
    6,
    0,
    8,
    0
  },
  iLimitNum = {
    7,
    0,
    8,
    0
  },
  iPreGoodsId = {
    8,
    0,
    8,
    0
  },
  vReward = {
    9,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vRewardExt = {
    10,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  sGoodsName = {
    11,
    0,
    13,
    ""
  },
  sGoodsDesc = {
    12,
    0,
    13,
    ""
  },
  sGoodsPic = {
    13,
    0,
    13,
    ""
  },
  iDiscount = {
    14,
    0,
    8,
    0
  },
  iShowOrder = {
    15,
    0,
    8,
    0
  },
  iRecommend = {
    16,
    0,
    8,
    0
  },
  iLaunchTime = {
    17,
    0,
    8,
    0
  },
  iRemovalTime = {
    18,
    0,
    8,
    0
  }
}
CmdActCfgPayStoreGoodsConfig = sdp.SdpStruct("CmdActCfgPayStoreGoodsConfig")
CmdActCfgPayStoreGoodsConfig.Definition = {
  "mGoods",
  mGoods = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgPayStoreGoods),
    nil
  }
}
CmdActCfgPayStoreUpInterfaceResourceConfig = sdp.SdpStruct("CmdActCfgPayStoreUpInterfaceResourceConfig")
CmdActCfgPayStoreUpInterfaceResourceConfig.Definition = {
  "sGiftBackground",
  "sGiftPackBasePlate",
  "sPurchasePriceTextColor",
  "sSoldOutPic",
  "sSoldOutTextColor",
  "sGiftPackNameTextColor",
  "sStockTextColor",
  "sValueForMoneyBaseImage",
  "sValueForMoneyMask",
  "sValueForMoneyTextColor",
  sGiftBackground = {
    0,
    0,
    13,
    ""
  },
  sGiftPackBasePlate = {
    1,
    0,
    13,
    ""
  },
  sPurchasePriceTextColor = {
    3,
    0,
    13,
    ""
  },
  sSoldOutPic = {
    4,
    0,
    13,
    ""
  },
  sSoldOutTextColor = {
    5,
    0,
    13,
    ""
  },
  sGiftPackNameTextColor = {
    6,
    0,
    13,
    ""
  },
  sStockTextColor = {
    7,
    0,
    13,
    ""
  },
  sValueForMoneyBaseImage = {
    8,
    0,
    13,
    ""
  },
  sValueForMoneyMask = {
    9,
    0,
    13,
    ""
  },
  sValueForMoneyTextColor = {
    10,
    0,
    13,
    ""
  }
}
CmdActCfgPayStoreStore = sdp.SdpStruct("CmdActCfgPayStoreStore")
CmdActCfgPayStoreStore.Definition = {
  "iStoreId",
  "iStoreType",
  "iRefreshType",
  "iRefreshTime",
  "sStoreName",
  "sStoreDesc",
  "sStorePic",
  "iWindowID",
  "sWindowName",
  "iShowOrder",
  "iStoreStatus",
  "iStoreBeginTime",
  "iStoreEndTime",
  "iMinLevel",
  "iMaxLevel",
  "iMinMainStage",
  "iMaxMainStage",
  "iFirstDouble",
  "stGoodsConfig",
  "iShowType",
  "sColorType",
  "iShowSingleTab",
  "stUpInterfaceResourceConfig",
  iStoreId = {
    0,
    0,
    8,
    0
  },
  iStoreType = {
    1,
    0,
    8,
    0
  },
  iRefreshType = {
    2,
    0,
    8,
    0
  },
  iRefreshTime = {
    3,
    0,
    8,
    0
  },
  sStoreName = {
    4,
    0,
    13,
    ""
  },
  sStoreDesc = {
    5,
    0,
    13,
    ""
  },
  sStorePic = {
    6,
    0,
    13,
    ""
  },
  iWindowID = {
    7,
    0,
    8,
    0
  },
  sWindowName = {
    8,
    0,
    13,
    ""
  },
  iShowOrder = {
    9,
    0,
    8,
    0
  },
  iStoreStatus = {
    10,
    0,
    8,
    0
  },
  iStoreBeginTime = {
    11,
    0,
    8,
    0
  },
  iStoreEndTime = {
    12,
    0,
    8,
    0
  },
  iMinLevel = {
    13,
    0,
    8,
    0
  },
  iMaxLevel = {
    14,
    0,
    8,
    0
  },
  iMinMainStage = {
    15,
    0,
    8,
    0
  },
  iMaxMainStage = {
    16,
    0,
    8,
    0
  },
  iFirstDouble = {
    17,
    0,
    8,
    0
  },
  stGoodsConfig = {
    18,
    0,
    CmdActCfgPayStoreGoodsConfig,
    nil
  },
  iShowType = {
    19,
    0,
    8,
    0
  },
  sColorType = {
    20,
    0,
    13,
    ""
  },
  iShowSingleTab = {
    21,
    0,
    8,
    0
  },
  stUpInterfaceResourceConfig = {
    22,
    0,
    CmdActCfgPayStoreUpInterfaceResourceConfig,
    nil
  }
}
CmdActCommonCfgPayStore = sdp.SdpStruct("CmdActCommonCfgPayStore")
CmdActCommonCfgPayStore.Definition = {
  "mStore",
  mStore = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgPayStoreStore),
    nil
  }
}
CmdActCfgPayStore = sdp.SdpStruct("CmdActCfgPayStore")
CmdActCfgPayStore.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgPayStore,
    nil
  }
}
Cmd_Act_PayStore_SelectReward_CS = sdp.SdpStruct("Cmd_Act_PayStore_SelectReward_CS")
Cmd_Act_PayStore_SelectReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_PayStore_SelectReward_SC = sdp.SdpStruct("Cmd_Act_PayStore_SelectReward_SC")
Cmd_Act_PayStore_SelectReward_SC.Definition = {}
Cmd_Act_PayStore_FreeReward_CS = sdp.SdpStruct("Cmd_Act_PayStore_FreeReward_CS")
Cmd_Act_PayStore_FreeReward_CS.Definition = {
  "iActivityId",
  "iStoreId",
  "iGoodsId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iStoreId = {
    1,
    0,
    8,
    0
  },
  iGoodsId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Act_PayStore_FreeReward_SC = sdp.SdpStruct("Cmd_Act_PayStore_FreeReward_SC")
Cmd_Act_PayStore_FreeReward_SC.Definition = {
  "vReward",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
