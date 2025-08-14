local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_SimRoom_GetData_CS = 11001
CmdId_SimRoom_GetData_SC = 11002
CmdId_SimRoom_StartSim_CS = 11003
CmdId_SimRoom_StartSim_SC = 11004
CmdId_SimRoom_ChooseEvent_CS = 11005
CmdId_SimRoom_ChooseEvent_SC = 11006
CmdId_SimRoom_ChooseOption_CS = 11007
CmdId_SimRoom_ChooseOption_SC = 11008
CmdId_SimRoom_EndSim_CS = 11009
CmdId_SimRoom_EndSim_SC = 11010
CmdId_SimRoom_ResetSim_CS = 11011
CmdId_SimRoom_ResetSim_SC = 11012
CmdId_SimRoom_Mop_CS = 11013
CmdId_SimRoom_Mop_SC = 11014
CmdId_SimRoom_MopChooseBuff_CS = 11015
CmdId_SimRoom_MopChooseBuff_SC = 11016
SimRoomEventType_Battle = 1
SimRoomEventType_Random = 2
SimRoomRegionType_Normal = 0
SimRoomRegionType_Guide = 1
SimRoomOptionResult_ChooseBuff = 1
SimRoomOptionResult_AddRandomBuff = 2
SimRoomOptionResult_ReplaceBuffRandom = 3
SimRoomOptionResult_ChangeBuffShape = 4
SimRoomOptionResult_ChangeBuffQuality = 5
SimRoomOptionResult_ChangeAllBuffShape = 6
SimRoomOptionResult_ChangeAllBuffQuality = 7
SimRoomOptionResult_RandomDeleteBuff = 8
SimRoomOptionResult_AddHeroHp = 9
SimRoomOptionResult_SubHeroHp = 10
SimRoomOptionResult_ReviveHero = 11
SimRoomOptionResult_KillHero = 12
SimRoomOptionResult_AddAllHeroHp = 13
SimRoomOptionResult_SubAllHeroHp = 14
SimRoomOptionResult_ReviveAllHero = 15
SimRoomStatus_None = 0
SimRoomStatus_BattleEnd = 1
SimRoomStatus_FlowEnd = 2
SimRoomStatus_MopEnd = 3
SimRoomBuffRangeType_All = 0
SimRoomBuffRangeType_Camp = 1
SimRoomBuffRangeType_EquipType = 2
SimRoomBuffRangeType_Career = 3
CmdSimBuff = sdp.SdpStruct("CmdSimBuff")
CmdSimBuff.Definition = {
  "iGroupId",
  "iShape",
  "iQuality",
  "iRangeId",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iShape = {
    1,
    0,
    8,
    0
  },
  iQuality = {
    2,
    0,
    8,
    0
  },
  iRangeId = {
    3,
    0,
    8,
    0
  }
}
CmdSimHero = sdp.SdpStruct("CmdSimHero")
CmdSimHero.Definition = {
  "iHeroId",
  "iHpPercent",
  "iEnergy",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iHpPercent = {
    1,
    0,
    8,
    0
  },
  iEnergy = {
    2,
    0,
    8,
    0
  }
}
CmdSimFightData = sdp.SdpStruct("CmdSimFightData")
CmdSimFightData.Definition = {
  "mHero",
  "vFinishArea",
  "mFightingMonster",
  "vMonsterGroupList",
  mHero = {
    0,
    0,
    sdp.SdpMap(8, CmdSimHero),
    nil
  },
  vFinishArea = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  mFightingMonster = {
    2,
    0,
    sdp.SdpMap(8, CmdFightingMonster),
    nil
  },
  vMonsterGroupList = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdSimDoing = sdp.SdpStruct("CmdSimDoing")
CmdSimDoing.Definition = {
  "iRegionId",
  "iFlowId",
  "iStartTime",
  "vBuff",
  "stFight",
  "iCurOrder",
  "vChooseEvent",
  "iCurEvent",
  "iStatus",
  "vChooseBuff",
  "iStartRegion",
  iRegionId = {
    0,
    0,
    8,
    0
  },
  iFlowId = {
    1,
    0,
    8,
    0
  },
  iStartTime = {
    2,
    0,
    8,
    0
  },
  vBuff = {
    3,
    0,
    sdp.SdpVector(CmdSimBuff),
    nil
  },
  stFight = {
    4,
    0,
    CmdSimFightData,
    nil
  },
  iCurOrder = {
    5,
    0,
    8,
    0
  },
  vChooseEvent = {
    6,
    0,
    sdp.SdpVector(8),
    nil
  },
  iCurEvent = {
    7,
    0,
    8,
    0
  },
  iStatus = {
    8,
    0,
    8,
    0
  },
  vChooseBuff = {
    9,
    0,
    sdp.SdpVector(CmdSimBuff),
    nil
  },
  iStartRegion = {
    10,
    0,
    8,
    0
  }
}
CmdSimRoom = sdp.SdpStruct("CmdSimRoom")
CmdSimRoom.Definition = {
  "vPassedRegion",
  "iDailyTakenReward",
  "vWeekBuff",
  "stDoingSim",
  "vDailyPassRegion",
  vPassedRegion = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iDailyTakenReward = {
    1,
    0,
    8,
    0
  },
  vWeekBuff = {
    2,
    0,
    sdp.SdpVector(CmdSimBuff),
    nil
  },
  stDoingSim = {
    3,
    0,
    CmdSimDoing,
    nil
  },
  vDailyPassRegion = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_SimRoom_GetData_CS = sdp.SdpStruct("Cmd_SimRoom_GetData_CS")
Cmd_SimRoom_GetData_CS.Definition = {}
Cmd_SimRoom_GetData_SC = sdp.SdpStruct("Cmd_SimRoom_GetData_SC")
Cmd_SimRoom_GetData_SC.Definition = {
  "stSimRoom",
  stSimRoom = {
    0,
    0,
    CmdSimRoom,
    nil
  }
}
Cmd_SimRoom_StartSim_CS = sdp.SdpStruct("Cmd_SimRoom_StartSim_CS")
Cmd_SimRoom_StartSim_CS.Definition = {
  "iRegionId",
  "bContinue",
  iRegionId = {
    0,
    0,
    8,
    0
  },
  bContinue = {
    1,
    0,
    1,
    false
  }
}
Cmd_SimRoom_StartSim_SC = sdp.SdpStruct("Cmd_SimRoom_StartSim_SC")
Cmd_SimRoom_StartSim_SC.Definition = {
  "iRegionId",
  "bContinue",
  "stDoingSim",
  iRegionId = {
    0,
    0,
    8,
    0
  },
  bContinue = {
    1,
    0,
    1,
    false
  },
  stDoingSim = {
    2,
    0,
    CmdSimDoing,
    nil
  }
}
Cmd_SimRoom_ChooseEvent_CS = sdp.SdpStruct("Cmd_SimRoom_ChooseEvent_CS")
Cmd_SimRoom_ChooseEvent_CS.Definition = {
  "iEventId",
  iEventId = {
    0,
    0,
    8,
    0
  }
}
Cmd_SimRoom_ChooseEvent_SC = sdp.SdpStruct("Cmd_SimRoom_ChooseEvent_SC")
Cmd_SimRoom_ChooseEvent_SC.Definition = {
  "iEventId",
  "vChooseBuff",
  iEventId = {
    0,
    0,
    8,
    0
  },
  vChooseBuff = {
    1,
    0,
    sdp.SdpVector(CmdSimBuff),
    nil
  }
}
Cmd_SimRoom_ChooseOption_CS = sdp.SdpStruct("Cmd_SimRoom_ChooseOption_CS")
Cmd_SimRoom_ChooseOption_CS.Definition = {
  "iEventId",
  "iOption",
  "bNotChoose",
  "iChooseIndex",
  "iReplaceIndex",
  iEventId = {
    0,
    0,
    8,
    0
  },
  iOption = {
    1,
    0,
    8,
    0
  },
  bNotChoose = {
    2,
    0,
    1,
    false
  },
  iChooseIndex = {
    3,
    0,
    8,
    0
  },
  iReplaceIndex = {
    4,
    0,
    8,
    0
  }
}
Cmd_SimRoom_ChooseOption_SC = sdp.SdpStruct("Cmd_SimRoom_ChooseOption_SC")
Cmd_SimRoom_ChooseOption_SC.Definition = {
  "iEventId",
  "iOption",
  "bNotChoose",
  "iChooseIndex",
  "iReplaceIndex",
  "stNewBuff",
  "stDoingSim",
  iEventId = {
    0,
    0,
    8,
    0
  },
  iOption = {
    1,
    0,
    8,
    0
  },
  bNotChoose = {
    2,
    0,
    1,
    false
  },
  iChooseIndex = {
    3,
    0,
    8,
    0
  },
  iReplaceIndex = {
    4,
    0,
    8,
    0
  },
  stNewBuff = {
    5,
    0,
    CmdSimBuff,
    nil
  },
  stDoingSim = {
    6,
    0,
    CmdSimDoing,
    nil
  }
}
Cmd_SimRoom_EndSim_CS = sdp.SdpStruct("Cmd_SimRoom_EndSim_CS")
Cmd_SimRoom_EndSim_CS.Definition = {
  "bNotChoose",
  "iChooseIndex",
  "iReplaceIndex",
  bNotChoose = {
    0,
    0,
    1,
    false
  },
  iChooseIndex = {
    1,
    0,
    8,
    0
  },
  iReplaceIndex = {
    2,
    0,
    8,
    0
  }
}
Cmd_SimRoom_EndSim_SC = sdp.SdpStruct("Cmd_SimRoom_EndSim_SC")
Cmd_SimRoom_EndSim_SC.Definition = {
  "bNotChoose",
  "iChooseIndex",
  "iReplaceIndex",
  "stSimRoom",
  bNotChoose = {
    0,
    0,
    1,
    false
  },
  iChooseIndex = {
    1,
    0,
    8,
    0
  },
  iReplaceIndex = {
    2,
    0,
    8,
    0
  },
  stSimRoom = {
    3,
    0,
    CmdSimRoom,
    nil
  }
}
Cmd_SimRoom_ResetSim_CS = sdp.SdpStruct("Cmd_SimRoom_ResetSim_CS")
Cmd_SimRoom_ResetSim_CS.Definition = {
  "bNotChoose",
  "iChooseIndex",
  "iReplaceIndex",
  bNotChoose = {
    0,
    0,
    1,
    false
  },
  iChooseIndex = {
    1,
    0,
    8,
    0
  },
  iReplaceIndex = {
    2,
    0,
    8,
    0
  }
}
Cmd_SimRoom_ResetSim_SC = sdp.SdpStruct("Cmd_SimRoom_ResetSim_SC")
Cmd_SimRoom_ResetSim_SC.Definition = {
  "bNotChoose",
  "iChooseIndex",
  "iReplaceIndex",
  "stDoingSim",
  bNotChoose = {
    0,
    0,
    1,
    false
  },
  iChooseIndex = {
    1,
    0,
    8,
    0
  },
  iReplaceIndex = {
    2,
    0,
    8,
    0
  },
  stDoingSim = {
    3,
    0,
    CmdSimDoing,
    nil
  }
}
Cmd_SimRoom_Mop_CS = sdp.SdpStruct("Cmd_SimRoom_Mop_CS")
Cmd_SimRoom_Mop_CS.Definition = {}
Cmd_SimRoom_Mop_SC = sdp.SdpStruct("Cmd_SimRoom_Mop_SC")
Cmd_SimRoom_Mop_SC.Definition = {
  "stSimRoom",
  "mRegionReward",
  "mRegionActReward",
  stSimRoom = {
    0,
    0,
    CmdSimRoom,
    nil
  },
  mRegionReward = {
    1,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  },
  mRegionActReward = {
    2,
    0,
    sdp.SdpMap(8, sdp.SdpVector(CmdIDNum)),
    nil
  }
}
Cmd_SimRoom_MopChooseBuff_CS = sdp.SdpStruct("Cmd_SimRoom_MopChooseBuff_CS")
Cmd_SimRoom_MopChooseBuff_CS.Definition = {
  "vChooseIndex",
  vChooseIndex = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_SimRoom_MopChooseBuff_SC = sdp.SdpStruct("Cmd_SimRoom_MopChooseBuff_SC")
Cmd_SimRoom_MopChooseBuff_SC.Definition = {
  "stDoingSim",
  stDoingSim = {
    0,
    0,
    CmdSimDoing,
    nil
  }
}
