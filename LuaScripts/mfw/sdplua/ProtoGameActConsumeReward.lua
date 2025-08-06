local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_ConsumeReward_TakeReward_CS = 60541
CmdId_Act_ConsumeReward_TakeReward_SC = 60542
CmdActConsumeReward_Status = sdp.SdpStruct("CmdActConsumeReward_Status")
CmdActConsumeReward_Status.Definition = {
  "vTakenReward",
  "iPoint",
  vTakenReward = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iPoint = {
    1,
    0,
    8,
    0
  }
}
CmdActCfgConsumeRewardPointReward = sdp.SdpStruct("CmdActCfgConsumeRewardPointReward")
CmdActCfgConsumeRewardPointReward.Definition = {
  "iNeedPoint",
  "vReward",
  "bFinal",
  iNeedPoint = {
    0,
    0,
    8,
    0
  },
  vReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  bFinal = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgConsumeRewardProducts = sdp.SdpStruct("CmdActCfgConsumeRewardProducts")
CmdActCfgConsumeRewardProducts.Definition = {
  "sProductId",
  "iPoint",
  sProductId = {
    0,
    0,
    13,
    ""
  },
  iPoint = {
    1,
    0,
    8,
    0
  }
}
CmdActCommonCfgConsumeReward = sdp.SdpStruct("CmdActCommonCfgConsumeReward")
CmdActCommonCfgConsumeReward.Definition = {
  "iPointItem",
  "iResendMail",
  "iPopId",
  "mPointReward",
  "mProducts",
  iPointItem = {
    0,
    0,
    8,
    0
  },
  iResendMail = {
    1,
    0,
    8,
    0
  },
  iPopId = {
    2,
    0,
    8,
    0
  },
  mPointReward = {
    3,
    0,
    sdp.SdpMap(8, CmdActCfgConsumeRewardPointReward),
    nil
  },
  mProducts = {
    4,
    0,
    sdp.SdpMap(13, CmdActCfgConsumeRewardProducts),
    nil
  }
}
CmdActCfgConsumeReward = sdp.SdpStruct("CmdActCfgConsumeReward")
CmdActCfgConsumeReward.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgConsumeReward,
    nil
  }
}
Cmd_Act_ConsumeReward_TakeReward_CS = sdp.SdpStruct("Cmd_Act_ConsumeReward_TakeReward_CS")
Cmd_Act_ConsumeReward_TakeReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_ConsumeReward_TakeReward_SC = sdp.SdpStruct("Cmd_Act_ConsumeReward_TakeReward_SC")
Cmd_Act_ConsumeReward_TakeReward_SC.Definition = {
  "iActivityId",
  "vTakenReward",
  "vShowReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vTakenReward = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vShowReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
