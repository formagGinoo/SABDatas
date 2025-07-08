local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_NewbieLucky_SkillPoint_CS = 50101
CmdId_Act_NewbieLucky_SkillPoint_SC = 50102
CmdId_Act_Recharge_BuyFreeGift_SC = 50103
CmdId_Act_Recharge_BuyFreeGift_CS = 50104
CmdId_Act_Recharge_IAP_GetFreeReward_CS = 50105
CmdId_Act_Recharge_IAP_GetFreeReward_SC = 50106
CmdId_Act_Recharge_SelectGift_CS = 50107
CmdId_Act_Recharge_SelectGift_SC = 50108
CmdActRecharge_IAPLimitStatusItem = sdp.SdpStruct("CmdActRecharge_IAPLimitStatusItem")
CmdActRecharge_IAPLimitStatusItem.Definition = {
  "sProductId",
  "iUsedDayLimit",
  "iUsedServerLimit",
  "iUsedRoleLimit",
  "iProductSubId",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iUsedDayLimit = {
    1,
    0,
    8,
    0
  },
  iUsedServerLimit = {
    2,
    0,
    8,
    0
  },
  iUsedRoleLimit = {
    3,
    0,
    8,
    0
  },
  iProductSubId = {
    4,
    0,
    8,
    0
  }
}
CmdActRecharge_IAPLimitStatus = sdp.SdpStruct("CmdActRecharge_IAPLimitStatus")
CmdActRecharge_IAPLimitStatus.Definition = {
  "vProductLimit",
  "iBeginTimeForRoll",
  "iLastLimitRefreshTime",
  "bFreeRewarded",
  "mGiftStatus",
  "iInitTime",
  vProductLimit = {
    0,
    0,
    sdp.SdpVector(CmdActRecharge_IAPLimitStatusItem),
    nil
  },
  iBeginTimeForRoll = {
    1,
    0,
    8,
    0
  },
  iLastLimitRefreshTime = {
    2,
    0,
    8,
    0
  },
  bFreeRewarded = {
    3,
    0,
    8,
    0
  },
  mGiftStatus = {
    4,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iInitTime = {
    5,
    0,
    8,
    0
  }
}
CmdActRecharge_IAPPhaseGiftStatus = sdp.SdpStruct("CmdActRecharge_IAPPhaseGiftStatus")
CmdActRecharge_IAPPhaseGiftStatus.Definition = {
  "sProductId",
  "iStartCDTime",
  "iStartShowTime",
  "iCDType",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iStartCDTime = {
    1,
    0,
    8,
    0
  },
  iStartShowTime = {
    2,
    0,
    8,
    0
  },
  iCDType = {
    3,
    0,
    8,
    0
  }
}
CmdActRecharge_IAPNewbieLuckyStatus = sdp.SdpStruct("CmdActRecharge_IAPNewbieLuckyStatus")
CmdActRecharge_IAPNewbieLuckyStatus.Definition = {
  "sProductId",
  "iEndShowTime",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iEndShowTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_NewbieLucky_SkillPoint_CS = sdp.SdpStruct("Cmd_Act_NewbieLucky_SkillPoint_CS")
Cmd_Act_NewbieLucky_SkillPoint_CS.Definition = {
  "iNum",
  iNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_NewbieLucky_SkillPoint_SC = sdp.SdpStruct("Cmd_Act_NewbieLucky_SkillPoint_SC")
Cmd_Act_NewbieLucky_SkillPoint_SC.Definition = {}
Cmd_Act_Recharge_BuyFreeGift_CS = sdp.SdpStruct("Cmd_Act_Recharge_BuyFreeGift_CS")
Cmd_Act_Recharge_BuyFreeGift_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_Recharge_BuyFreeGift_SC = sdp.SdpStruct("Cmd_Act_Recharge_BuyFreeGift_SC")
Cmd_Act_Recharge_BuyFreeGift_SC.Definition = {
  "vItem",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_Recharge_IAP_GetFreeReward_CS = sdp.SdpStruct("Cmd_Act_Recharge_IAP_GetFreeReward_CS")
Cmd_Act_Recharge_IAP_GetFreeReward_CS.Definition = {
  "iActivityId",
  "sProductId",
  "iProductSubId",
  iActivityId = {
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
  }
}
Cmd_Act_Recharge_IAP_GetFreeReward_SC = sdp.SdpStruct("Cmd_Act_Recharge_IAP_GetFreeReward_SC")
Cmd_Act_Recharge_IAP_GetFreeReward_SC.Definition = {
  "vItem",
  vItem = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
Cmd_Act_Recharge_SelectGift_CS = sdp.SdpStruct("Cmd_Act_Recharge_SelectGift_CS")
Cmd_Act_Recharge_SelectGift_CS.Definition = {
  "iActivityId",
  "iCfgIndex",
  "iGiftIndex",
  "mSelectItemIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iCfgIndex = {
    1,
    0,
    8,
    0
  },
  iGiftIndex = {
    2,
    0,
    8,
    0
  },
  mSelectItemIndex = {
    3,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Act_Recharge_SelectGift_SC = sdp.SdpStruct("Cmd_Act_Recharge_SelectGift_SC")
Cmd_Act_Recharge_SelectGift_SC.Definition = {
  "iActivityId",
  "iGiftIndex",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iGiftIndex = {
    1,
    0,
    8,
    0
  }
}
