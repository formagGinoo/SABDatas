local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Shop_GetShop_CS = 10851
CmdId_Shop_GetShop_SC = 10852
CmdId_Shop_Buy_CS = 10853
CmdId_Shop_Buy_SC = 10854
CmdId_Shop_Refresh_CS = 10855
CmdId_Shop_Refresh_SC = 10856
CmdId_Shop_GetShopList_CS = 10857
CmdId_Shop_GetShopList_SC = 10858
ShopType_Normal = 1
ShopType_Activity = 2
ShopSpecialID_Base = 101
ShopRefreshType_None = 0
ShopRefreshType_Daily = 1
ShopRefreshType_Time = 2
ShopRefreshType_Weekly = 3
ShopRefreshType_Monthly = 4
ShopGoodsLimitType_None = 0
ShopGoodsLimitType_Daily = 1
ShopGoodsLimitType_Weekly = 2
ShopGoodsLimitType_Monthly = 3
ShopGoodsLimitType_Forever = 4
ShopGoodsConditionType_RoleLevel = 1
ShopGoodsConditionType_StageMain = 2
ShopGoodsConditionType_Time = 3
ShopGoodsConditionType_PreTime = 4
CmdShopGoods = sdp.SdpStruct("CmdShopGoods")
CmdShopGoods.Definition = {
  "iGroupId",
  "iGoodsId",
  "iBought",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iGoodsId = {
    1,
    0,
    8,
    0
  },
  iBought = {
    2,
    0,
    8,
    0
  }
}
CmdShop = sdp.SdpStruct("CmdShop")
CmdShop.Definition = {
  "iShopId",
  "iOpenTime",
  "iLastRefreshTime",
  "iRefreshTimes",
  "vGoods",
  "iActivityId",
  "iVersion",
  "mGoodsBought",
  "iFreeRefreshTimes",
  iShopId = {
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
  iLastRefreshTime = {
    2,
    0,
    8,
    0
  },
  iRefreshTimes = {
    3,
    0,
    8,
    0
  },
  vGoods = {
    4,
    0,
    sdp.SdpVector(CmdShopGoods),
    nil
  },
  iActivityId = {
    5,
    0,
    8,
    0
  },
  iVersion = {
    6,
    0,
    8,
    0
  },
  mGoodsBought = {
    7,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  },
  iFreeRefreshTimes = {
    8,
    0,
    8,
    0
  }
}
Cmd_Shop_GetShop_CS = sdp.SdpStruct("Cmd_Shop_GetShop_CS")
Cmd_Shop_GetShop_CS.Definition = {
  "iShopId",
  iShopId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Shop_GetShop_SC = sdp.SdpStruct("Cmd_Shop_GetShop_SC")
Cmd_Shop_GetShop_SC.Definition = {
  "stShop",
  stShop = {
    0,
    0,
    CmdShop,
    nil
  }
}
Cmd_Shop_Buy_CS = sdp.SdpStruct("Cmd_Shop_Buy_CS")
Cmd_Shop_Buy_CS.Definition = {
  "iShopId",
  "iGroupId",
  "iGoodsId",
  "iNum",
  iShopId = {
    0,
    0,
    8,
    0
  },
  iGroupId = {
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
  },
  iNum = {
    3,
    0,
    8,
    0
  }
}
Cmd_Shop_Buy_SC = sdp.SdpStruct("Cmd_Shop_Buy_SC")
Cmd_Shop_Buy_SC.Definition = {
  "iShopId",
  "iGroupId",
  "iGoodsId",
  "iNum",
  "vReward",
  "iStockBought",
  "iLimitBought",
  "mChangeReward",
  iShopId = {
    0,
    0,
    8,
    0
  },
  iGroupId = {
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
  },
  iNum = {
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
  iStockBought = {
    5,
    0,
    8,
    0
  },
  iLimitBought = {
    6,
    0,
    8,
    0
  },
  mChangeReward = {
    7,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
Cmd_Shop_Refresh_CS = sdp.SdpStruct("Cmd_Shop_Refresh_CS")
Cmd_Shop_Refresh_CS.Definition = {
  "iShopId",
  iShopId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Shop_Refresh_SC = sdp.SdpStruct("Cmd_Shop_Refresh_SC")
Cmd_Shop_Refresh_SC.Definition = {
  "stShop",
  stShop = {
    0,
    0,
    CmdShop,
    nil
  }
}
Cmd_Shop_GetShopList_CS = sdp.SdpStruct("Cmd_Shop_GetShopList_CS")
Cmd_Shop_GetShopList_CS.Definition = {
  "vShopId",
  vShopId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Shop_GetShopList_SC = sdp.SdpStruct("Cmd_Shop_GetShopList_SC")
Cmd_Shop_GetShopList_SC.Definition = {
  "vShopList",
  vShopList = {
    0,
    0,
    sdp.SdpVector(CmdShop),
    nil
  }
}
