local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_PickupGift_SetReward_CS = 60121
CmdId_Act_PickupGift_SetReward_SC = 60122
CmdActPickupGiftInfo = sdp.SdpStruct("CmdActPickupGiftInfo")
CmdActPickupGiftInfo.Definition = {
  "iBoughtNum",
  "mGridRewardIndex",
  iBoughtNum = {
    0,
    0,
    8,
    0
  },
  mGridRewardIndex = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
CmdActPickupGift_Status = sdp.SdpStruct("CmdActPickupGift_Status")
CmdActPickupGift_Status.Definition = {
  "mGift",
  mGift = {
    0,
    0,
    sdp.SdpMap(8, CmdActPickupGiftInfo),
    nil
  }
}
CmdActCfgPickupGiftGrids = sdp.SdpStruct("CmdActCfgPickupGiftGrids")
CmdActCfgPickupGiftGrids.Definition = {
  "mGridCfg",
  mGridCfg = {
    0,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
CmdActCfgPickupGiftGiftList = sdp.SdpStruct("CmdActCfgPickupGiftGiftList")
CmdActCfgPickupGiftGiftList.Definition = {
  "iGiftId",
  "sProductId",
  "iProductSubId",
  "iBuyLimit",
  "sIcon",
  "sGiftName",
  "sGiftDesc",
  "iOrder",
  "iDiscount",
  "stGrids",
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
  iBuyLimit = {
    3,
    0,
    8,
    0
  },
  sIcon = {
    4,
    0,
    13,
    ""
  },
  sGiftName = {
    5,
    0,
    13,
    ""
  },
  sGiftDesc = {
    6,
    0,
    13,
    ""
  },
  iOrder = {
    7,
    0,
    8,
    0
  },
  iDiscount = {
    8,
    0,
    8,
    0
  },
  stGrids = {
    9,
    0,
    CmdActCfgPickupGiftGrids,
    nil
  }
}
CmdActCommonCfgPickupGift = sdp.SdpStruct("CmdActCommonCfgPickupGift")
CmdActCommonCfgPickupGift.Definition = {
  "mGiftList",
  mGiftList = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgPickupGiftGiftList),
    nil
  }
}
CmdActCfgPickupGift = sdp.SdpStruct("CmdActCfgPickupGift")
CmdActCfgPickupGift.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgPickupGift,
    nil
  }
}
CmdActPickupGiftBuyParam = sdp.SdpStruct("CmdActPickupGiftBuyParam")
CmdActPickupGiftBuyParam.Definition = {
  "iActivityId",
  "mGridRewardIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mGridRewardIndex = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Act_PickupGift_SetReward_CS = sdp.SdpStruct("Cmd_Act_PickupGift_SetReward_CS")
Cmd_Act_PickupGift_SetReward_CS.Definition = {
  "iActivityId",
  "iGiftId",
  "mGridRewardIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iGiftId = {
    1,
    0,
    8,
    0
  },
  mGridRewardIndex = {
    2,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Act_PickupGift_SetReward_SC = sdp.SdpStruct("Cmd_Act_PickupGift_SetReward_SC")
Cmd_Act_PickupGift_SetReward_SC.Definition = {}
