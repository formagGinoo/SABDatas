local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_Train_TakeTaskReward_CS = 60681
CmdId_Act_Train_TakeTaskReward_SC = 60682
TrainTaskType_Hero = 1
TrainTaskType_HeroBreak = 2
TrainTaskType_SkillLevel = 3
TrainTaskType_UltLevel = 4
TrainTaskType_Attract = 5
CmdActTrainTask = sdp.SdpStruct("CmdActTrainTask")
CmdActTrainTask.Definition = {
  "iIndexId",
  "iTakeTime",
  "iBought",
  iIndexId = {
    0,
    0,
    8,
    0
  },
  iTakeTime = {
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
CmdActTrain_Status = sdp.SdpStruct("CmdActTrain_Status")
CmdActTrain_Status.Definition = {
  "iActivityId",
  "mTask",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  mTask = {
    1,
    0,
    sdp.SdpMap(8, CmdActTrainTask),
    nil
  }
}
CmdActClientCfgTrain = sdp.SdpStruct("CmdActClientCfgTrain")
CmdActClientCfgTrain.Definition = {
  "sGiftBackground",
  "sGiftPackMask",
  "sTaskTypeTextColor",
  "sTaskPhaseTextColor",
  "sTaskTextColor",
  "sTaskPlate",
  "sGiftPackNameTextColor",
  "sGiftPackPlate",
  "sStockTextColor",
  "sPurchasePriceTextColor",
  "sValueForMoneyTextColor",
  "sValueForMoneyBaseImage",
  "sSoldOutTextColor",
  "sSoldOutPic",
  sGiftBackground = {
    0,
    0,
    13,
    ""
  },
  sGiftPackMask = {
    1,
    0,
    13,
    ""
  },
  sTaskTypeTextColor = {
    2,
    0,
    13,
    ""
  },
  sTaskPhaseTextColor = {
    3,
    0,
    13,
    ""
  },
  sTaskTextColor = {
    4,
    0,
    13,
    ""
  },
  sTaskPlate = {
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
  sGiftPackPlate = {
    7,
    0,
    13,
    ""
  },
  sStockTextColor = {
    8,
    0,
    13,
    ""
  },
  sPurchasePriceTextColor = {
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
  },
  sValueForMoneyBaseImage = {
    11,
    0,
    13,
    ""
  },
  sSoldOutTextColor = {
    12,
    0,
    13,
    ""
  },
  sSoldOutPic = {
    13,
    0,
    13,
    ""
  }
}
CmdActCfgTrainTaskGroup = sdp.SdpStruct("CmdActCfgTrainTaskGroup")
CmdActCfgTrainTaskGroup.Definition = {
  "iGroupId",
  "sTitle",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  sTitle = {
    1,
    0,
    13,
    ""
  }
}
CmdActCfgTrainTaskType = sdp.SdpStruct("CmdActCfgTrainTaskType")
CmdActCfgTrainTaskType.Definition = {
  "iTaskType",
  "sDesc",
  "iJump",
  iTaskType = {
    0,
    0,
    8,
    0
  },
  sDesc = {
    1,
    0,
    13,
    ""
  },
  iJump = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgTrainTrain = sdp.SdpStruct("CmdActCfgTrainTrain")
CmdActCfgTrainTrain.Definition = {
  "iId",
  "iTaskGroup",
  "iTaskType",
  "vTaskParam",
  "vTaskReward",
  "sProductId",
  "iProductSubId",
  "iLimitNum",
  "vProductReward",
  "sProductName",
  "iDiscount",
  iId = {
    0,
    0,
    8,
    0
  },
  iTaskGroup = {
    1,
    0,
    8,
    0
  },
  iTaskType = {
    2,
    0,
    8,
    0
  },
  vTaskParam = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  vTaskReward = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
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
  vProductReward = {
    8,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  sProductName = {
    9,
    0,
    13,
    ""
  },
  iDiscount = {
    10,
    0,
    8,
    0
  }
}
CmdActCommonCfgTrain = sdp.SdpStruct("CmdActCommonCfgTrain")
CmdActCommonCfgTrain.Definition = {
  "iHeroId",
  "iStoreId",
  "iResendMail",
  "mTaskGroup",
  "mTaskType",
  "mTrain",
  iHeroId = {
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
  iResendMail = {
    2,
    0,
    8,
    0
  },
  mTaskGroup = {
    3,
    0,
    sdp.SdpMap(8, CmdActCfgTrainTaskGroup),
    nil
  },
  mTaskType = {
    4,
    0,
    sdp.SdpMap(8, CmdActCfgTrainTaskType),
    nil
  },
  mTrain = {
    5,
    0,
    sdp.SdpMap(8, CmdActCfgTrainTrain),
    nil
  }
}
CmdActCfgTrain = sdp.SdpStruct("CmdActCfgTrain")
CmdActCfgTrain.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgTrain,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgTrain,
    nil
  }
}
Cmd_Act_Train_TakeTaskReward_CS = sdp.SdpStruct("Cmd_Act_Train_TakeTaskReward_CS")
Cmd_Act_Train_TakeTaskReward_CS.Definition = {
  "iActivityId",
  "iIndexId",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndexId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Act_Train_TakeTaskReward_SC = sdp.SdpStruct("Cmd_Act_Train_TakeTaskReward_SC")
Cmd_Act_Train_TakeTaskReward_SC.Definition = {
  "iActivityId",
  "iIndexId",
  "stTask",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iIndexId = {
    1,
    0,
    8,
    0
  },
  stTask = {
    2,
    0,
    CmdActTrainTask,
    nil
  },
  vReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
