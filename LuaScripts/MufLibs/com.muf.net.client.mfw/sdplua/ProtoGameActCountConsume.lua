local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_CountConsume_TakeReward_CS = 60741
CmdId_Act_CountConsume_TakeReward_SC = 60742
CmdId_Act_CountConsume_TakeRedpointReward_CS = 60743
CmdId_Act_CountConsume_TakeRedpointReward_SC = 60744
CmdActCountConsume_Status = sdp.SdpStruct("CmdActCountConsume_Status")
CmdActCountConsume_Status.Definition = {
  "vTakenReward",
  "iPoint",
  "bRedpointReward",
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
  },
  bRedpointReward = {
    2,
    0,
    1,
    false
  }
}
CmdActCfgCountConsumeProducts = sdp.SdpStruct("CmdActCfgCountConsumeProducts")
CmdActCfgCountConsumeProducts.Definition = {
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
CmdActCfgCountConsumeReward = sdp.SdpStruct("CmdActCfgCountConsumeReward")
CmdActCfgCountConsumeReward.Definition = {
  "iId",
  "iNeedPoint",
  "vReward",
  "iNeedLoginDays",
  "iShowType",
  iId = {
    0,
    0,
    8,
    0
  },
  iNeedPoint = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iNeedLoginDays = {
    3,
    0,
    8,
    0
  },
  iShowType = {
    4,
    0,
    8,
    0
  }
}
CmdActCommonCfgCountConsume = sdp.SdpStruct("CmdActCommonCfgCountConsume")
CmdActCommonCfgCountConsume.Definition = {
  "iPointItem",
  "iResendMail",
  "iAvatarId",
  "iPopNeedStage",
  "mReward",
  "mProducts",
  "vRedpointReward",
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
  iAvatarId = {
    2,
    0,
    8,
    0
  },
  iPopNeedStage = {
    3,
    0,
    8,
    0
  },
  mReward = {
    4,
    0,
    sdp.SdpMap(8, CmdActCfgCountConsumeReward),
    nil
  },
  mProducts = {
    5,
    0,
    sdp.SdpMap(13, CmdActCfgCountConsumeProducts),
    nil
  },
  vRedpointReward = {
    6,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdActCfgCountConsume = sdp.SdpStruct("CmdActCfgCountConsume")
CmdActCfgCountConsume.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgCountConsume,
    nil
  }
}
Cmd_Act_CountConsume_TakeReward_CS = sdp.SdpStruct("Cmd_Act_CountConsume_TakeReward_CS")
Cmd_Act_CountConsume_TakeReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_CountConsume_TakeReward_SC = sdp.SdpStruct("Cmd_Act_CountConsume_TakeReward_SC")
Cmd_Act_CountConsume_TakeReward_SC.Definition = {
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
Cmd_Act_CountConsume_TakeRedpointReward_CS = sdp.SdpStruct("Cmd_Act_CountConsume_TakeRedpointReward_CS")
Cmd_Act_CountConsume_TakeRedpointReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_CountConsume_TakeRedpointReward_SC = sdp.SdpStruct("Cmd_Act_CountConsume_TakeRedpointReward_SC")
Cmd_Act_CountConsume_TakeRedpointReward_SC.Definition = {
  "iActivityId",
  "vShowReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vShowReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
