local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_SignGift_GetSignReward_CS = 60461
CmdId_Act_SignGift_GetSignReward_SC = 60462
CmdActSignGift_Status = sdp.SdpStruct("CmdActSignGift_Status")
CmdActSignGift_Status.Definition = {
  "iActivityId",
  "iLatestGiftBuyTime",
  "iBuyTimes",
  "iLoginDays",
  "iMaxAwardedDays",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iLatestGiftBuyTime = {
    1,
    0,
    8,
    0
  },
  iBuyTimes = {
    2,
    0,
    8,
    0
  },
  iLoginDays = {
    3,
    0,
    8,
    0
  },
  iMaxAwardedDays = {
    4,
    0,
    8,
    0
  }
}
CmdActClientCfgSignGift = sdp.SdpStruct("CmdActClientCfgSignGift")
CmdActClientCfgSignGift.Definition = {
  "sProductName",
  "sRule",
  sProductName = {
    0,
    0,
    13,
    ""
  },
  sRule = {
    1,
    0,
    13,
    ""
  }
}
CmdActCommonCfgSignGift = sdp.SdpStruct("CmdActCommonCfgSignGift")
CmdActCommonCfgSignGift.Definition = {
  "sProductId",
  "iProductSubId",
  "iProductValue",
  "iForbidBuyHourBeforEnd",
  "mReward",
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
  iProductValue = {
    2,
    0,
    8,
    0
  },
  iForbidBuyHourBeforEnd = {
    3,
    0,
    8,
    0
  },
  mReward = {
    4,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
CmdActCfgSignGift = sdp.SdpStruct("CmdActCfgSignGift")
CmdActCfgSignGift.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgSignGift,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgSignGift,
    nil
  }
}
CmdActSignGiftBuyParam = sdp.SdpStruct("CmdActSignGiftBuyParam")
CmdActSignGiftBuyParam.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_SignGift_GetSignReward_CS = sdp.SdpStruct("Cmd_Act_SignGift_GetSignReward_CS")
Cmd_Act_SignGift_GetSignReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_SignGift_GetSignReward_SC = sdp.SdpStruct("Cmd_Act_SignGift_GetSignReward_SC")
Cmd_Act_SignGift_GetSignReward_SC.Definition = {
  "iActivityId",
  "iMaxAwardedDays",
  "vReward",
  iActivityId = {
    1,
    0,
    8,
    0
  },
  iMaxAwardedDays = {
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
  }
}
