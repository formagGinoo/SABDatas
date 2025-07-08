local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Gacha_GetGacha_CS = 10751
CmdId_Gacha_GetGacha_SC = 10752
CmdId_Gacha_DoGacha_CS = 10753
CmdId_Gacha_DoGacha_SC = 10754
CmdId_Gacha_SetWishList_CS = 10755
CmdId_Gacha_SetWishList_SC = 10756
CmdId_Gacha_GetWishList_CS = 10757
CmdId_Gacha_GetWishList_SC = 10758
CmdId_Gacha_GetRecord_CS = 10759
CmdId_Gacha_GetRecord_SC = 10760
GachaType_Hero = 1
GachaTimesType_One = 1
GachaTimesType_Ten = 10
GachaUnlockType_StageMain = 1
GachaUnlockType_RoleLevel = 2
GachaUnlockType_Guide = 3
GachaDiscountType_Cheap = 1
GachaDiscountType_Free = 2
GachaGuaranteeType_Guarantee = 1
GachaGuaranteeType_MustGain = 2
GachaGuaranteeType_UpProtect = 3
Cmd_Gacha_GetGacha_CS = sdp.SdpStruct("Cmd_Gacha_GetGacha_CS")
Cmd_Gacha_GetGacha_CS.Definition = {
  "vGachaId",
  vGachaId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdGachaPool = sdp.SdpStruct("CmdGachaPool")
CmdGachaPool.Definition = {
  "iGachaId",
  "iGachaTimes",
  "vWishList",
  "iDailyTimes",
  "iCheapTimes",
  "iFreeTimes",
  "iFreeTimesTen",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  iGachaTimes = {
    1,
    0,
    8,
    0
  },
  vWishList = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  iDailyTimes = {
    3,
    0,
    8,
    0
  },
  iCheapTimes = {
    4,
    0,
    8,
    0
  },
  iFreeTimes = {
    5,
    0,
    8,
    0
  },
  iFreeTimesTen = {
    6,
    0,
    8,
    0
  }
}
Cmd_Gacha_GetGacha_SC = sdp.SdpStruct("Cmd_Gacha_GetGacha_SC")
Cmd_Gacha_GetGacha_SC.Definition = {
  "mGachaPool",
  mGachaPool = {
    1,
    0,
    sdp.SdpMap(8, CmdGachaPool),
    nil
  }
}
Cmd_Gacha_DoGacha_CS = sdp.SdpStruct("Cmd_Gacha_DoGacha_CS")
Cmd_Gacha_DoGacha_CS.Definition = {
  "iGachaId",
  "iTimesType",
  "bUseCost",
  "iDiscountType",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  iTimesType = {
    1,
    0,
    8,
    0
  },
  bUseCost = {
    2,
    0,
    1,
    false
  },
  iDiscountType = {
    3,
    0,
    8,
    0
  }
}
Cmd_Gacha_DoGacha_SC = sdp.SdpStruct("Cmd_Gacha_DoGacha_SC")
Cmd_Gacha_DoGacha_SC.Definition = {
  "iGachaId",
  "iTimesType",
  "iGachaTimes",
  "vGachaItem",
  "vRealItem",
  "vScoreItem",
  "iDailyTimes",
  "iDiscountType",
  "iCheapTimes",
  "iFreeTimes",
  "iFreeTimesTen",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  iTimesType = {
    1,
    0,
    8,
    0
  },
  iGachaTimes = {
    2,
    0,
    8,
    0
  },
  vGachaItem = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vRealItem = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vScoreItem = {
    5,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iDailyTimes = {
    6,
    0,
    8,
    0
  },
  iDiscountType = {
    7,
    0,
    8,
    0
  },
  iCheapTimes = {
    8,
    0,
    8,
    0
  },
  iFreeTimes = {
    9,
    0,
    8,
    0
  },
  iFreeTimesTen = {
    10,
    0,
    8,
    0
  }
}
Cmd_Gacha_SetWishList_CS = sdp.SdpStruct("Cmd_Gacha_SetWishList_CS")
Cmd_Gacha_SetWishList_CS.Definition = {
  "iGachaId",
  "vHeroIdList",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  vHeroIdList = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Gacha_SetWishList_SC = sdp.SdpStruct("Cmd_Gacha_SetWishList_SC")
Cmd_Gacha_SetWishList_SC.Definition = {
  "iGachaId",
  "vHeroIdList",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  vHeroIdList = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Gacha_GetWishList_CS = sdp.SdpStruct("Cmd_Gacha_GetWishList_CS")
Cmd_Gacha_GetWishList_CS.Definition = {
  "iGachaId",
  iGachaId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Gacha_GetWishList_SC = sdp.SdpStruct("Cmd_Gacha_GetWishList_SC")
Cmd_Gacha_GetWishList_SC.Definition = {
  "iGachaId",
  "vHeroIdList",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  vHeroIdList = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdGachaRecord = sdp.SdpStruct("CmdGachaRecord")
CmdGachaRecord.Definition = {
  "iTime",
  "vItem",
  "iGachaId",
  iTime = {
    0,
    0,
    8,
    0
  },
  vItem = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  iGachaId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Gacha_GetRecord_CS = sdp.SdpStruct("Cmd_Gacha_GetRecord_CS")
Cmd_Gacha_GetRecord_CS.Definition = {
  "iGachaId",
  "iBegin",
  "iEnd",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  iBegin = {
    1,
    0,
    8,
    0
  },
  iEnd = {
    2,
    0,
    8,
    0
  }
}
Cmd_Gacha_GetRecord_SC = sdp.SdpStruct("Cmd_Gacha_GetRecord_SC")
Cmd_Gacha_GetRecord_SC.Definition = {
  "iGachaId",
  "iBegin",
  "iEnd",
  "iTotal",
  "vRecord",
  iGachaId = {
    0,
    0,
    8,
    0
  },
  iBegin = {
    1,
    0,
    8,
    0
  },
  iEnd = {
    2,
    0,
    8,
    0
  },
  iTotal = {
    3,
    0,
    8,
    0
  },
  vRecord = {
    4,
    0,
    sdp.SdpVector(CmdGachaRecord),
    nil
  }
}
