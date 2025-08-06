local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_EmergencyGift_Trigger_CS = 60383
CmdId_Act_EmergencyGift_Trigger_SC = 60384
CmdActEmergencyGiftProduct = sdp.SdpStruct("CmdActEmergencyGiftProduct")
CmdActEmergencyGiftProduct.Definition = {
  "iGiftID",
  "sProductId",
  "iSubProductId",
  "iTriggerTime",
  "iBuyTimes",
  iGiftID = {
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
  iSubProductId = {
    2,
    0,
    8,
    0
  },
  iTriggerTime = {
    3,
    0,
    8,
    0
  },
  iBuyTimes = {
    4,
    0,
    8,
    0
  }
}
CmdActEmergencyGift_Status = sdp.SdpStruct("CmdActEmergencyGift_Status")
CmdActEmergencyGift_Status.Definition = {
  "iActivityId",
  "vNeedRandGiftId",
  "vProductInfo",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vNeedRandGiftId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vProductInfo = {
    2,
    0,
    sdp.SdpVector(CmdActEmergencyGiftProduct),
    nil
  }
}
CmdActEmergencyGiftBuyParam = sdp.SdpStruct("CmdActEmergencyGiftBuyParam")
CmdActEmergencyGiftBuyParam.Definition = {
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
CmdActCfgEmergencyGiftGift = sdp.SdpStruct("CmdActCfgEmergencyGiftGift")
CmdActCfgEmergencyGiftGift.Definition = {
  "iGiftID",
  "sProductId",
  "stItem",
  "iPushStyle",
  "iDiscount",
  "iGiftDuration",
  "iTriggerRate",
  "iMaxTriggerCount",
  "sConditionRegTimeBegin",
  "sConditionRegTimeEnd",
  "sConditionPassStage",
  "sConditionPayAmountRMB",
  "sConditionPayAmount",
  "iProductNameId",
  "sProductDesc",
  iGiftID = {
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
  stItem = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iPushStyle = {
    3,
    0,
    13,
    ""
  },
  iDiscount = {
    4,
    0,
    8,
    0
  },
  iGiftDuration = {
    5,
    0,
    8,
    0
  },
  iTriggerRate = {
    6,
    0,
    8,
    0
  },
  iMaxTriggerCount = {
    7,
    0,
    8,
    0
  },
  sConditionRegTimeBegin = {
    8,
    0,
    8,
    0
  },
  sConditionRegTimeEnd = {
    9,
    0,
    8,
    0
  },
  sConditionPassStage = {
    10,
    0,
    13,
    ""
  },
  sConditionPayAmountRMB = {
    11,
    0,
    13,
    ""
  },
  sConditionPayAmount = {
    12,
    0,
    13,
    ""
  },
  iProductNameId = {
    13,
    0,
    13,
    ""
  },
  sProductDesc = {
    14,
    0,
    13,
    ""
  }
}
CmdActCommonCfgEmergencyGift = sdp.SdpStruct("CmdActCommonCfgEmergencyGift")
CmdActCommonCfgEmergencyGift.Definition = {
  "mGift",
  "vProductSubIdLimit",
  mGift = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgEmergencyGiftGift),
    nil
  },
  vProductSubIdLimit = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActCfgEmergencyGift = sdp.SdpStruct("CmdActCfgEmergencyGift")
CmdActCfgEmergencyGift.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgEmergencyGift,
    nil
  }
}
Cmd_Act_EmergencyGift_Trigger_CS = sdp.SdpStruct("Cmd_Act_EmergencyGift_Trigger_CS")
Cmd_Act_EmergencyGift_Trigger_CS.Definition = {
  "iActivityId",
  "vGiftId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vGiftId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Act_EmergencyGift_Trigger_SC = sdp.SdpStruct("Cmd_Act_EmergencyGift_Trigger_SC")
Cmd_Act_EmergencyGift_Trigger_SC.Definition = {
  "iActivityId",
  "vNeedRandGiftId",
  "vNewProduct",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vNeedRandGiftId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vNewProduct = {
    2,
    0,
    sdp.SdpVector(CmdActEmergencyGiftProduct),
    nil
  }
}
