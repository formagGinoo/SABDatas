local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_ReturnTask_GetReward_CS = 60661
CmdId_Act_ReturnTask_GetReward_SC = 60662
CmdId_Act_ReturnTask_GetQuestReward_CS = 60663
CmdId_Act_ReturnTask_GetQuestReward_SC = 60664
CmdReturnTaskQuest = sdp.SdpStruct("CmdReturnTaskQuest")
CmdReturnTaskQuest.Definition = {
  "iIndex",
  "iQuestID",
  "iAwardedTimes",
  "iCurProgress",
  "iFinishTimes",
  iIndex = {
    1,
    0,
    8,
    0
  },
  iQuestID = {
    2,
    0,
    8,
    0
  },
  iAwardedTimes = {
    3,
    0,
    8,
    0
  },
  iCurProgress = {
    4,
    0,
    8,
    0
  },
  iFinishTimes = {
    5,
    0,
    8,
    0
  }
}
CmdActReturnTask_Status = sdp.SdpStruct("CmdActReturnTask_Status")
CmdActReturnTask_Status.Definition = {
  "iActivityId",
  "iOpenTime",
  "iCloseTime",
  "iCurlProgressValue",
  "mQuestAwarded",
  "mGoodsBought",
  "vAllQuest",
  iActivityId = {
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
  iCloseTime = {
    2,
    0,
    8,
    0
  },
  iCurlProgressValue = {
    5,
    0,
    8,
    0
  },
  mQuestAwarded = {
    6,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  },
  mGoodsBought = {
    7,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  vAllQuest = {
    8,
    0,
    sdp.SdpVector(CmdReturnTaskQuest),
    nil
  }
}
CmdActCfgReturnTaskGoods = sdp.SdpStruct("CmdActCfgReturnTaskGoods")
CmdActCfgReturnTaskGoods.Definition = {
  "iIndex",
  "sProductId",
  "iSubProductId",
  "iCostEffectivenes",
  "iExtraBonusProgressValue",
  "iGiftPic",
  "iGiftName",
  iIndex = {
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
  iCostEffectivenes = {
    3,
    0,
    8,
    0
  },
  iExtraBonusProgressValue = {
    4,
    0,
    8,
    0
  },
  iGiftPic = {
    5,
    0,
    13,
    ""
  },
  iGiftName = {
    6,
    0,
    13,
    ""
  }
}
CmdActCfgReturnTaskQuest = sdp.SdpStruct("CmdActCfgReturnTaskQuest")
CmdActCfgReturnTaskQuest.Definition = {
  "iIndex",
  "iMaxFinishTimes",
  "iTaskID",
  "iProgressValue",
  "vReward",
  iIndex = {
    0,
    0,
    8,
    0
  },
  iMaxFinishTimes = {
    1,
    0,
    8,
    0
  },
  iTaskID = {
    2,
    0,
    8,
    0
  },
  iProgressValue = {
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
  }
}
CmdActCfgReturnTaskReward = sdp.SdpStruct("CmdActCfgReturnTaskReward")
CmdActCfgReturnTaskReward.Definition = {
  "iProgressValue",
  "vFreeReward",
  "vLowerPayReward",
  "vHigherPayReward",
  iProgressValue = {
    0,
    0,
    8,
    0
  },
  vFreeReward = {
    1,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vLowerPayReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  vHigherPayReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
CmdActCommonCfgReturnTask = sdp.SdpStruct("CmdActCommonCfgReturnTask")
CmdActCommonCfgReturnTask.Definition = {
  "iActiveDay",
  "iCloseDay",
  "iCDDay",
  "iResendMailTemplateId",
  "iLeftDayRemind",
  "mGoods",
  "mQuest",
  "mReward",
  iActiveDay = {
    0,
    0,
    8,
    0
  },
  iCloseDay = {
    1,
    0,
    8,
    0
  },
  iCDDay = {
    2,
    0,
    8,
    0
  },
  iResendMailTemplateId = {
    3,
    0,
    8,
    0
  },
  iLeftDayRemind = {
    4,
    0,
    8,
    0
  },
  mGoods = {
    5,
    0,
    sdp.SdpMap(8, CmdActCfgReturnTaskGoods),
    nil
  },
  mQuest = {
    6,
    0,
    sdp.SdpMap(8, CmdActCfgReturnTaskQuest),
    nil
  },
  mReward = {
    7,
    0,
    sdp.SdpMap(8, CmdActCfgReturnTaskReward),
    nil
  }
}
CmdActCfgReturnTask = sdp.SdpStruct("CmdActCfgReturnTask")
CmdActCfgReturnTask.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgReturnTask,
    nil
  }
}
Cmd_Act_ReturnTask_GetReward_CS = sdp.SdpStruct("Cmd_Act_ReturnTask_GetReward_CS")
Cmd_Act_ReturnTask_GetReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_ReturnTask_GetReward_SC = sdp.SdpStruct("Cmd_Act_ReturnTask_GetReward_SC")
Cmd_Act_ReturnTask_GetReward_SC.Definition = {
  "iActivityId",
  "vReward",
  "mQuestAwarded",
  iActivityId = {
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
  mQuestAwarded = {
    3,
    0,
    sdp.SdpMap(8, sdp.SdpMap(8, 8)),
    nil
  }
}
Cmd_Act_ReturnTask_GetQuestReward_CS = sdp.SdpStruct("Cmd_Act_ReturnTask_GetQuestReward_CS")
Cmd_Act_ReturnTask_GetQuestReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_ReturnTask_GetQuestReward_SC = sdp.SdpStruct("Cmd_Act_ReturnTask_GetQuestReward_SC")
Cmd_Act_ReturnTask_GetQuestReward_SC.Definition = {
  "iActivityId",
  "iQuestIndex",
  "vReward",
  iActivityId = {
    1,
    0,
    8,
    0
  },
  iQuestIndex = {
    2,
    0,
    8,
    0
  },
  vReward = {
    4,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
