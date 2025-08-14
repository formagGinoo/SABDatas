local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_BaseStore_GetBaseStore_CS = 10951
CmdId_BaseStore_GetBaseStore_SC = 10952
CmdId_BaseStore_Refresh_CS = 10953
CmdId_BaseStore_Refresh_SC = 10954
CmdId_BaseStore_GetBaseStoreMonthlyCard_CS = 10955
CmdId_BaseStore_GetBaseStoreMonthlyCard_SC = 10956
CmdId_BaseStore_GetBaseStoreChapter_CS = 10957
CmdId_BaseStore_GetBaseStoreChapter_SC = 10958
CmdId_BaseStore_GetBaseStoreChapterReward_CS = 10959
CmdId_BaseStore_GetBaseStoreChapterReward_SC = 10960
BaseStoreChapterRewardType_Free = 0
BaseStoreChapterRewardType_Pay = 1
Cmd_BaseStore_GetBaseStore_CS = sdp.SdpStruct("Cmd_BaseStore_GetBaseStore_CS")
Cmd_BaseStore_GetBaseStore_CS.Definition = {}
Cmd_BaseStore_GetBaseStore_SC = sdp.SdpStruct("Cmd_BaseStore_GetBaseStore_SC")
Cmd_BaseStore_GetBaseStore_SC.Definition = {}
Cmd_BaseStore_Refresh_CS = sdp.SdpStruct("Cmd_BaseStore_Refresh_CS")
Cmd_BaseStore_Refresh_CS.Definition = {}
Cmd_BaseStore_Refresh_SC = sdp.SdpStruct("Cmd_BaseStore_Refresh_SC")
Cmd_BaseStore_Refresh_SC.Definition = {}
CmdBaseStoreBuyParam = sdp.SdpStruct("CmdBaseStoreBuyParam")
CmdBaseStoreBuyParam.Definition = {
  "iStoreId",
  "iGoodsId",
  iStoreId = {
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
  }
}
CmdBaseStoreMonthlyCardGoods = sdp.SdpStruct("CmdBaseStoreMonthlyCardGoods")
CmdBaseStoreMonthlyCardGoods.Definition = {
  "iCardId",
  "iBuyTime",
  "iExpireTime",
  "iLastRewardTime",
  "iTotalRewardTimes",
  "iTotalBuyTimes",
  iCardId = {
    0,
    0,
    8,
    0
  },
  iBuyTime = {
    1,
    0,
    8,
    0
  },
  iExpireTime = {
    2,
    0,
    8,
    0
  },
  iLastRewardTime = {
    3,
    0,
    8,
    0
  },
  iTotalRewardTimes = {
    4,
    0,
    8,
    0
  },
  iTotalBuyTimes = {
    5,
    0,
    8,
    0
  }
}
CmdBaseStoreMonthlyCard = sdp.SdpStruct("CmdBaseStoreMonthlyCard")
CmdBaseStoreMonthlyCard.Definition = {
  "mMonthlyCard",
  mMonthlyCard = {
    0,
    0,
    sdp.SdpMap(8, CmdBaseStoreMonthlyCardGoods),
    nil
  }
}
CmdBaseStoreChapterLevel = sdp.SdpStruct("CmdBaseStoreChapterLevel")
CmdBaseStoreChapterLevel.Definition = {
  "iRewardTime",
  iRewardTime = {
    0,
    0,
    8,
    0
  }
}
CmdBaseStoreChapterGoods = sdp.SdpStruct("CmdBaseStoreChapterGoods")
CmdBaseStoreChapterGoods.Definition = {
  "iGoodsId",
  "iBuyTime",
  "iLevel",
  "mLevelInfo",
  iGoodsId = {
    0,
    0,
    8,
    0
  },
  iBuyTime = {
    1,
    0,
    8,
    0
  },
  iLevel = {
    2,
    0,
    6,
    0
  },
  mLevelInfo = {
    3,
    0,
    sdp.SdpMap(8, CmdBaseStoreChapterLevel),
    nil
  }
}
CmdBaseStoreChapter = sdp.SdpStruct("CmdBaseStoreChapter")
CmdBaseStoreChapter.Definition = {
  "mChapter",
  mChapter = {
    0,
    0,
    sdp.SdpMap(8, CmdBaseStoreChapterGoods),
    nil
  }
}
Cmd_BaseStore_GetBaseStoreMonthlyCard_CS = sdp.SdpStruct("Cmd_BaseStore_GetBaseStoreMonthlyCard_CS")
Cmd_BaseStore_GetBaseStoreMonthlyCard_CS.Definition = {
  "iStoreId",
  "iCardId",
  iStoreId = {
    0,
    0,
    8,
    0
  },
  iCardId = {
    1,
    0,
    8,
    0
  }
}
Cmd_BaseStore_GetBaseStoreMonthlyCard_SC = sdp.SdpStruct("Cmd_BaseStore_GetBaseStoreMonthlyCard_SC")
Cmd_BaseStore_GetBaseStoreMonthlyCard_SC.Definition = {
  "stMonthlyCard",
  stMonthlyCard = {
    0,
    0,
    CmdBaseStoreMonthlyCard,
    nil
  }
}
Cmd_BaseStore_GetBaseStoreChapter_CS = sdp.SdpStruct("Cmd_BaseStore_GetBaseStoreChapter_CS")
Cmd_BaseStore_GetBaseStoreChapter_CS.Definition = {
  "iStoreId",
  "iGoodsId",
  iStoreId = {
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
  }
}
Cmd_BaseStore_GetBaseStoreChapter_SC = sdp.SdpStruct("Cmd_BaseStore_GetBaseStoreChapter_SC")
Cmd_BaseStore_GetBaseStoreChapter_SC.Definition = {
  "stChapter",
  stChapter = {
    0,
    0,
    CmdBaseStoreChapter,
    nil
  }
}
Cmd_BaseStore_GetBaseStoreChapterReward_CS = sdp.SdpStruct("Cmd_BaseStore_GetBaseStoreChapterReward_CS")
Cmd_BaseStore_GetBaseStoreChapterReward_CS.Definition = {
  "iStoreId",
  "iGoodsId",
  "iLevel",
  "bAll",
  iStoreId = {
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
  iLevel = {
    2,
    0,
    8,
    0
  },
  bAll = {
    4,
    0,
    1,
    false
  }
}
Cmd_BaseStore_GetBaseStoreChapterReward_SC = sdp.SdpStruct("Cmd_BaseStore_GetBaseStoreChapterReward_SC")
Cmd_BaseStore_GetBaseStoreChapterReward_SC.Definition = {
  "vFreeReward",
  "vPayReward",
  vFreeReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vPayReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
