local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoComm")
module("MTTDProto")
CmdId_Battle_Connect_CS = 1001
CmdId_Battle_Connect_SC = 1002
CmdId_Battle_DisConnect_CS = 1003
CmdId_Battle_DisConnect_SC = 1004
CmdId_Battle_Idle_CS = 1005
CmdId_Battle_Idle_SC = 1006
CmdId_Battle_Echo_CS = 1013
CmdId_Battle_Echo_SC = 1014
CmdId_Battle_Hash_CS = 1015
CmdId_Battle_Hash_SC = 1016
CmdId_Battle_GetFrameTime_CS = 1021
CmdId_Battle_GetFrameTime_SC = 1022
CmdId_Battle_SetUdpPattern_CS = 1023
CmdId_Battle_SetUdpPattern_SC = 1024
CmdId_Battle_SetUdpInitPattern_CS = 1027
CmdId_Battle_SetUdpInitPattern_SC = 1028
CmdId_Battle_Check_CS = 1029
CmdId_Battle_Check_SC = 1030
CmdId_Battle_Ping_CS = 1033
CmdId_Battle_Ping_SC = 1034
CmdId_Battle_ReportPing_CS = 1035
CmdId_Battle_ReportPing_SC = 1036
CmdId_Battle_Oper_CS = 1100
CmdId_Battle_Oper_SC = 1101
CmdId_Battle_Result_CS = 1102
CmdId_Battle_Result_SC = 1103
CmdId_Battle_RealEnd_CS = 1104
CmdId_Battle_RealEnd_SC = 1105
CmdId_Battle_ReconnectReady_CS = 1106
CmdId_Battle_ReconnectReady_SC = 1107
CmdId_Battle_UdpFramesData_CS = 1108
CmdId_Battle_UdpFrameReq_CS = 1110
CmdId_Battle_UdpFrameReq_SC = 1111
CmdId_Battle_UdpFramesDataRecon_CS = 1116
CmdId_Battle_UdpFramesDataRecon_SC = 1117
CmdId_Battle_UdpFrame_Confirm_CS = 1122
CmdId_Battle_NewUdpFramesData_SC = 1157
CmdId_Battle_NewUdpFramesDataNormal_SC = 1159
CmdId_Battle_ReportLogicError_CS = 1160
CmdId_Battle_ReportLogicError_SC = 1161
CmdId_Notify_BattlePlayerInfo = 1200
CmdId_Notify_ReadyStartSelect = 1201
CmdId_Notify_StartSelect = 1202
CmdId_Notify_StartLoading = 1203
CmdId_Notify_StartPlay = 1204
CmdId_Notify_WaitReady = 1205
CmdId_Notify_BattleStartFailed = 1206
CmdId_Notify_Reconnect = 1207
CmdId_Notify_MD5Failed = 1208
CmdId_Notify_RCPlayerInfo = 1209
CmdId_Notify_EndPlay = 1210
OperTypeId_Battle_Move = 1
OperTypeId_Battle_CastSkill = 2
OperTypeId_Battle_SkillUp = 4
OperTypeId_Battle_Sign = 5
OperTypeId_Battle_Quit = 7
OperTypeId_Battle_LevelUp = 12
OperTypeId_Battle_Move_Opt = 13
OperTypeId_Battle_OpenMatchOkUI = 50
OperTypeId_Battle_SelectHero = 51
OperTypeId_Battle_ConfirmHero = 52
OperTypeId_Battle_LoadingPer = 53
OperTypeId_Battle_ReadySelect = 54
OperTypeId_Battle_CancleConfirm = 59
OperTypeId_Battle_ConnStateChange = 62
OperTypeId_Battle_SelectHero_PlayPhase = 75
OperTypeId_Battle_ClientInfo = 80
OperTypeId_Battle_CommonOper = 112
ConnState_Battle_Disconnect = 1
ConnState_Battle_ReconnectReady = 2
Cmd_Battle_Connect_CS = sdp.SdpStruct("Cmd_Battle_Connect_CS")
Cmd_Battle_Connect_CS.Definition = {
  "iAccountId",
  "iZoneId",
  "iReconnectNum",
  "sClientVersion",
  "iOSType",
  "sProxyAddr",
  "iEchoTimeMS",
  "iBattleUid",
  "iFrameId",
  "uiDoubleConParam",
  "bOneReconnect",
  "bNoReadyData",
  "iBattleServerID",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  iZoneId = {
    2,
    0,
    8,
    0
  },
  iReconnectNum = {
    3,
    0,
    8,
    0
  },
  sClientVersion = {
    4,
    0,
    13,
    ""
  },
  iOSType = {
    6,
    0,
    8,
    0
  },
  sProxyAddr = {
    7,
    0,
    13,
    ""
  },
  iEchoTimeMS = {
    8,
    0,
    8,
    0
  },
  iBattleUid = {
    9,
    0,
    10,
    "0"
  },
  iFrameId = {
    10,
    0,
    8,
    0
  },
  uiDoubleConParam = {
    13,
    0,
    8,
    0
  },
  bOneReconnect = {
    14,
    0,
    1,
    false
  },
  bNoReadyData = {
    15,
    0,
    1,
    false
  },
  iBattleServerID = {
    16,
    0,
    8,
    0
  }
}
Cmd_Battle_Connect_SC = sdp.SdpStruct("Cmd_Battle_Connect_SC")
Cmd_Battle_Connect_SC.Definition = {
  "sAgoraToken",
  sAgoraToken = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Battle_DisConnect_CS = sdp.SdpStruct("Cmd_Battle_DisConnect_CS")
Cmd_Battle_DisConnect_CS.Definition = {}
Cmd_Battle_DisConnect_SC = sdp.SdpStruct("Cmd_Battle_DisConnect_SC")
Cmd_Battle_DisConnect_SC.Definition = {}
Cmd_Battle_Idle_CS = sdp.SdpStruct("Cmd_Battle_Idle_CS")
Cmd_Battle_Idle_CS.Definition = {}
Cmd_Battle_Idle_SC = sdp.SdpStruct("Cmd_Battle_Idle_SC")
Cmd_Battle_Idle_SC.Definition = {}
Cmd_Battle_Echo_CS = sdp.SdpStruct("Cmd_Battle_Echo_CS")
Cmd_Battle_Echo_CS.Definition = {
  "lClientTime",
  lClientTime = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Battle_Echo_SC = sdp.SdpStruct("Cmd_Battle_Echo_SC")
Cmd_Battle_Echo_SC.Definition = {
  "lClientTime",
  "lServerTime",
  lClientTime = {
    0,
    0,
    10,
    "0"
  },
  lServerTime = {
    1,
    0,
    10,
    "0"
  }
}
Cmd_Battle_Ping_CS = sdp.SdpStruct("Cmd_Battle_Ping_CS")
Cmd_Battle_Ping_CS.Definition = {
  "iTimeStampMS",
  "iPingSeq",
  "iCurIndex",
  "iRoleId",
  "iZoneId",
  iTimeStampMS = {
    0,
    0,
    10,
    "0"
  },
  iPingSeq = {
    1,
    0,
    10,
    "0"
  },
  iCurIndex = {
    2,
    0,
    10,
    "0"
  },
  iRoleId = {
    3,
    0,
    10,
    "0"
  },
  iZoneId = {
    4,
    0,
    8,
    0
  }
}
Cmd_Battle_Ping_SC = sdp.SdpStruct("Cmd_Battle_Ping_SC")
Cmd_Battle_Ping_SC.Definition = {
  "iTimeStampMS",
  "iPingSeq",
  "iCurIndex",
  "iRecvCnt",
  iTimeStampMS = {
    0,
    0,
    10,
    "0"
  },
  iPingSeq = {
    1,
    0,
    10,
    "0"
  },
  iCurIndex = {
    2,
    0,
    10,
    "0"
  },
  iRecvCnt = {
    3,
    0,
    10,
    "0"
  }
}
Cmd_Battle_ReportPing_CS = sdp.SdpStruct("Cmd_Battle_ReportPing_CS")
Cmd_Battle_ReportPing_CS.Definition = {
  "iPing",
  "iLoss",
  "iUpLoss",
  "iDownLoss",
  iPing = {
    0,
    0,
    8,
    0
  },
  iLoss = {
    1,
    0,
    8,
    0
  },
  iUpLoss = {
    2,
    0,
    8,
    0
  },
  iDownLoss = {
    3,
    0,
    8,
    0
  }
}
Cmd_Battle_ReportPing_SC = sdp.SdpStruct("Cmd_Battle_ReportPing_SC")
Cmd_Battle_ReportPing_SC.Definition = {}
Cmd_Battle_Hash_CS = sdp.SdpStruct("Cmd_Battle_Hash_CS")
Cmd_Battle_Hash_CS.Definition = {
  "uiData",
  "sMd5",
  uiData = {
    0,
    0,
    8,
    0
  },
  sMd5 = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Battle_Hash_SC = sdp.SdpStruct("Cmd_Battle_Hash_SC")
Cmd_Battle_Hash_SC.Definition = {
  "uiData",
  "sMd5",
  uiData = {
    0,
    0,
    8,
    0
  },
  sMd5 = {
    1,
    0,
    13,
    ""
  }
}
BattlePlayerInfo = sdp.SdpStruct("BattlePlayerInfo")
BattlePlayerInfo.Definition = {
  "iUid",
  "iCamp",
  "iPos",
  "sName",
  "bRobot",
  "iSelectHero",
  "iZoneId",
  "vCanSelectHero",
  "sClientVersion",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  iCamp = {
    1,
    0,
    8,
    0
  },
  iPos = {
    2,
    0,
    8,
    0
  },
  sName = {
    3,
    0,
    13,
    ""
  },
  bRobot = {
    4,
    0,
    1,
    false
  },
  iSelectHero = {
    6,
    0,
    8,
    0
  },
  iZoneId = {
    7,
    0,
    8,
    0
  },
  vCanSelectHero = {
    8,
    0,
    sdp.SdpVector(8),
    nil
  },
  sClientVersion = {
    9,
    0,
    13,
    ""
  }
}
BattleExParam = sdp.SdpStruct("BattleExParam")
BattleExParam.Definition = {}
Cmd_Notify_BattlePlayerInfo = sdp.SdpStruct("Cmd_Notify_BattlePlayerInfo")
Cmd_Notify_BattlePlayerInfo.Definition = {
  "vPlayer",
  "iPVPType",
  "stExParam",
  vPlayer = {
    0,
    0,
    sdp.SdpVector(BattlePlayerInfo),
    nil
  },
  iPVPType = {
    3,
    0,
    8,
    0
  },
  stExParam = {
    6,
    0,
    BattleExParam,
    nil
  }
}
Cmd_Notify_StartSelect = sdp.SdpStruct("Cmd_Notify_StartSelect")
Cmd_Notify_StartSelect.Definition = {
  "vPlayer",
  "iPVPType",
  "iMapID",
  "iTime",
  "stExParam",
  "iSelectHeroTime",
  "iFinalReadyTime",
  vPlayer = {
    0,
    0,
    sdp.SdpVector(BattlePlayerInfo),
    nil
  },
  iPVPType = {
    1,
    0,
    8,
    0
  },
  iMapID = {
    2,
    0,
    8,
    0
  },
  iTime = {
    4,
    0,
    8,
    0
  },
  stExParam = {
    6,
    0,
    BattleExParam,
    nil
  },
  iSelectHeroTime = {
    8,
    0,
    8,
    0
  },
  iFinalReadyTime = {
    9,
    0,
    8,
    0
  }
}
Cmd_Notify_StartLoading = sdp.SdpStruct("Cmd_Notify_StartLoading")
Cmd_Notify_StartLoading.Definition = {
  "vPlayer",
  "stExParam",
  vPlayer = {
    0,
    0,
    sdp.SdpVector(BattlePlayerInfo),
    nil
  },
  stExParam = {
    4,
    0,
    BattleExParam,
    nil
  }
}
Cmd_Notify_StartPlay = sdp.SdpStruct("Cmd_Notify_StartPlay")
Cmd_Notify_StartPlay.Definition = {
  "iRandSeed",
  "iEnvironment",
  "stExParam",
  iRandSeed = {
    0,
    0,
    8,
    0
  },
  iEnvironment = {
    1,
    0,
    8,
    0
  },
  stExParam = {
    13,
    0,
    BattleExParam,
    nil
  }
}
Cmd_Notify_WaitReady = sdp.SdpStruct("Cmd_Notify_WaitReady")
Cmd_Notify_WaitReady.Definition = {
  "iLeftTime",
  "iPVPType",
  iLeftTime = {
    0,
    0,
    8,
    0
  },
  iPVPType = {
    1,
    0,
    8,
    0
  }
}
Cmd_Notify_BattleStartFailed = sdp.SdpStruct("Cmd_Notify_BattleStartFailed")
Cmd_Notify_BattleStartFailed.Definition = {
  "iBattleUid",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Notify_Reconnect = sdp.SdpStruct("Cmd_Notify_Reconnect")
Cmd_Notify_Reconnect.Definition = {
  "iStep",
  "iFrameNum",
  "iRandSeed",
  "iPVPType",
  iStep = {
    0,
    0,
    8,
    0
  },
  iFrameNum = {
    1,
    0,
    8,
    0
  },
  iRandSeed = {
    2,
    0,
    8,
    0
  },
  iPVPType = {
    3,
    0,
    8,
    0
  }
}
Cmd_Notify_MD5Failed = sdp.SdpStruct("Cmd_Notify_MD5Failed")
Cmd_Notify_MD5Failed.Definition = {
  "iUid",
  iUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Notify_RCPlayerInfo = sdp.SdpStruct("Cmd_Notify_RCPlayerInfo")
Cmd_Notify_RCPlayerInfo.Definition = {
  "vPlayer",
  "iPVPType",
  "stExParam",
  "iRandSeed",
  vPlayer = {
    0,
    0,
    sdp.SdpVector(BattlePlayerInfo),
    nil
  },
  iPVPType = {
    1,
    0,
    8,
    0
  },
  stExParam = {
    5,
    0,
    BattleExParam,
    nil
  },
  iRandSeed = {
    10,
    0,
    8,
    0
  }
}
Cmd_Notify_EndPlay = sdp.SdpStruct("Cmd_Notify_EndPlay")
Cmd_Notify_EndPlay.Definition = {
  "iWinCamp",
  iWinCamp = {
    0,
    0,
    7,
    0
  }
}
BattleOperData = sdp.SdpStruct("BattleOperData")
BattleOperData.Definition = {
  "iUid",
  "iOperTypeId",
  "sOperData",
  "iTime",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  iOperTypeId = {
    1,
    0,
    8,
    0
  },
  sOperData = {
    3,
    0,
    13,
    ""
  },
  iTime = {
    4,
    0,
    8,
    0
  }
}
Cmd_Battle_Oper_CS = sdp.SdpStruct("Cmd_Battle_Oper_CS")
Cmd_Battle_Oper_CS.Definition = {
  "iBattleUid",
  "stOperData",
  "uiOperIndex",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  },
  stOperData = {
    1,
    0,
    BattleOperData,
    nil
  },
  uiOperIndex = {
    2,
    0,
    8,
    0
  }
}
Cmd_Battle_Oper_SC = sdp.SdpStruct("Cmd_Battle_Oper_SC")
Cmd_Battle_Oper_SC.Definition = {
  "iBattleUid",
  "vOperData",
  "uClientReceivedMsgFrame",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  },
  vOperData = {
    1,
    0,
    sdp.SdpVector(BattleOperData),
    nil
  },
  uClientReceivedMsgFrame = {
    2,
    0,
    10,
    "0"
  }
}
BattleOperOneFrameInSelectHeroPeriod = sdp.SdpStruct("BattleOperOneFrameInSelectHeroPeriod")
BattleOperOneFrameInSelectHeroPeriod.Definition = {
  "vOperData",
  vOperData = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
BattleOperFramePackInSelectHeroPeriod = sdp.SdpStruct("BattleOperFramePackInSelectHeroPeriod")
BattleOperFramePackInSelectHeroPeriod.Definition = {
  "strOperFrames",
  strOperFrames = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
BattleOperFramesInSelectHeroPeriod = sdp.SdpStruct("BattleOperFramesInSelectHeroPeriod")
BattleOperFramesInSelectHeroPeriod.Definition = {
  "iStartFrame",
  "strOperFrames",
  iStartFrame = {
    0,
    0,
    8,
    0
  },
  strOperFrames = {
    1,
    0,
    13,
    ""
  }
}
BattleOperOneFrame = sdp.SdpStruct("BattleOperOneFrame")
BattleOperOneFrame.Definition = {
  "vOperData",
  vOperData = {
    0,
    0,
    sdp.SdpVector(BattleOperData),
    nil
  }
}
BattleOperFramePack = sdp.SdpStruct("BattleOperFramePack")
BattleOperFramePack.Definition = {
  "strOperFrames",
  strOperFrames = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
BattleOperFrames = sdp.SdpStruct("BattleOperFrames")
BattleOperFrames.Definition = {
  "iStartFrame",
  "strOperFrames",
  "iPackTime",
  iStartFrame = {
    0,
    0,
    8,
    0
  },
  strOperFrames = {
    1,
    0,
    13,
    ""
  },
  iPackTime = {
    2,
    0,
    8,
    0
  }
}
PlayerDeadInfo = sdp.SdpStruct("PlayerDeadInfo")
PlayerDeadInfo.Definition = {
  "iBeginTime",
  "iEndTime",
  iBeginTime = {
    0,
    0,
    8,
    0
  },
  iEndTime = {
    1,
    0,
    8,
    0
  }
}
PrivateRecord = sdp.SdpStruct("PrivateRecord")
PrivateRecord.Definition = {
  "iFightRate",
  iFightRate = {
    0,
    0,
    8,
    0
  }
}
BattleReportFightValueVec = sdp.SdpStruct("BattleReportFightValueVec")
BattleReportFightValueVec.Definition = {
  "vInt",
  vInt = {
    0,
    0,
    sdp.SdpVector(7),
    nil
  }
}
BattleReportFightValueMap = sdp.SdpStruct("BattleReportFightValueMap")
BattleReportFightValueMap.Definition = {
  "mUInt",
  "mStr",
  mUInt = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mStr = {
    1,
    0,
    sdp.SdpMap(8, 13),
    nil
  }
}
BattleReportFightInfo = sdp.SdpStruct("BattleReportFightInfo")
BattleReportFightInfo.Definition = {
  "mFightValueInt",
  "mFightValueVec",
  "mFightValueMap",
  mFightValueInt = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mFightValueVec = {
    1,
    0,
    sdp.SdpMap(8, BattleReportFightValueVec),
    nil
  },
  mFightValueMap = {
    2,
    0,
    sdp.SdpMap(8, BattleReportFightValueMap),
    nil
  }
}
PlayerBattleRecord = sdp.SdpStruct("PlayerBattleRecord")
PlayerBattleRecord.Definition = {
  "iUid",
  "stPrivateRecord",
  "stFightInfo",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  stPrivateRecord = {
    1,
    0,
    PrivateRecord,
    nil
  },
  stFightInfo = {
    200,
    0,
    BattleReportFightInfo,
    nil
  }
}
Cmd_Battle_Result_CS = sdp.SdpStruct("Cmd_Battle_Result_CS")
Cmd_Battle_Result_CS.Definition = {
  "iBattleUid",
  "iBattleTime",
  "vPlayerBattleRecord",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  },
  iBattleTime = {
    1,
    0,
    8,
    0
  },
  vPlayerBattleRecord = {
    3,
    0,
    sdp.SdpVector(PlayerBattleRecord),
    nil
  }
}
Cmd_Battle_Result_SC = sdp.SdpStruct("Cmd_Battle_Result_SC")
Cmd_Battle_Result_SC.Definition = {
  "iBattleUid",
  "iResult",
  iBattleUid = {
    0,
    0,
    10,
    "0"
  },
  iResult = {
    1,
    0,
    8,
    0
  }
}
Cmd_Battle_RealEnd_CS = sdp.SdpStruct("Cmd_Battle_RealEnd_CS")
Cmd_Battle_RealEnd_CS.Definition = {}
Cmd_Battle_RealEnd_SC = sdp.SdpStruct("Cmd_Battle_RealEnd_SC")
Cmd_Battle_RealEnd_SC.Definition = {}
Cmd_Battle_ReconnectReady_CS = sdp.SdpStruct("Cmd_Battle_ReconnectReady_CS")
Cmd_Battle_ReconnectReady_CS.Definition = {}
Cmd_Battle_ReconnectReady_SC = sdp.SdpStruct("Cmd_Battle_ReconnectReady_SC")
Cmd_Battle_ReconnectReady_SC.Definition = {
  "iRspCode",
  iRspCode = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_Move = sdp.SdpStruct("OperType_Battle_Move")
OperType_Battle_Move.Definition = {
  "fDirX",
  "fDirY",
  "fPosX",
  "fPosY",
  "byDirX",
  "byDirY",
  fDirX = {
    0,
    0,
    11,
    0
  },
  fDirY = {
    1,
    0,
    11,
    0
  },
  fPosX = {
    2,
    0,
    11,
    0
  },
  fPosY = {
    3,
    0,
    11,
    0
  },
  byDirX = {
    4,
    0,
    2,
    0
  },
  byDirY = {
    5,
    0,
    2,
    0
  }
}
OperType_Battle_CastSkill = sdp.SdpStruct("OperType_Battle_CastSkill")
OperType_Battle_CastSkill.Definition = {
  "iSpellId",
  "fPosX",
  "fPosY",
  "fDirX",
  "fDirY",
  "iTargetId",
  "bStopMove",
  "iTranID",
  iSpellId = {
    0,
    0,
    8,
    0
  },
  fPosX = {
    1,
    0,
    11,
    0
  },
  fPosY = {
    2,
    0,
    11,
    0
  },
  fDirX = {
    3,
    0,
    11,
    0
  },
  fDirY = {
    4,
    0,
    11,
    0
  },
  iTargetId = {
    5,
    0,
    8,
    0
  },
  bStopMove = {
    6,
    0,
    1,
    false
  },
  iTranID = {
    7,
    0,
    8,
    0
  }
}
OperType_Battle_SkillUp = sdp.SdpStruct("OperType_Battle_SkillUp")
OperType_Battle_SkillUp.Definition = {
  "iSpellId",
  iSpellId = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_Sign = sdp.SdpStruct("OperType_Battle_Sign")
OperType_Battle_Sign.Definition = {
  "iOrderType",
  "bFloor",
  "fPosX",
  "fPosY",
  "iGuid",
  "iFriendGuid",
  iOrderType = {
    0,
    0,
    8,
    0
  },
  bFloor = {
    1,
    0,
    1,
    false
  },
  fPosX = {
    2,
    0,
    11,
    0
  },
  fPosY = {
    3,
    0,
    11,
    0
  },
  iGuid = {
    4,
    0,
    8,
    0
  },
  iFriendGuid = {
    5,
    0,
    8,
    0
  }
}
OperType_Battle_Quit = sdp.SdpStruct("OperType_Battle_Quit")
OperType_Battle_Quit.Definition = {}
OperType_Battle_OpenMatchOkUI = sdp.SdpStruct("OperType_Battle_OpenMatchOkUI")
OperType_Battle_OpenMatchOkUI.Definition = {}
OperType_Battle_LevelUp = sdp.SdpStruct("OperType_Battle_LevelUp")
OperType_Battle_LevelUp.Definition = {}
OperType_Battle_SelectHero = sdp.SdpStruct("OperType_Battle_SelectHero")
OperType_Battle_SelectHero.Definition = {
  "iHeroId",
  "bByServer",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  bByServer = {
    5,
    0,
    1,
    false
  }
}
OperType_Battle_SelectHero_PlayPhase = sdp.SdpStruct("OperType_Battle_SelectHero_PlayPhase")
OperType_Battle_SelectHero_PlayPhase.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_ConfirmHero = sdp.SdpStruct("OperType_Battle_ConfirmHero")
OperType_Battle_ConfirmHero.Definition = {
  "iHeroId",
  iHeroId = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_CancleConfirm = sdp.SdpStruct("OperType_Battle_CancleConfirm")
OperType_Battle_CancleConfirm.Definition = {}
OperType_Battle_LoadingPer = sdp.SdpStruct("OperType_Battle_LoadingPer")
OperType_Battle_LoadingPer.Definition = {
  "iLoadingPer",
  iLoadingPer = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_ReadySelect = sdp.SdpStruct("OperType_Battle_ReadySelect")
OperType_Battle_ReadySelect.Definition = {
  "iClientResRate",
  iClientResRate = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_ConnStateChange = sdp.SdpStruct("OperType_Battle_ConnStateChange")
OperType_Battle_ConnStateChange.Definition = {
  "iType",
  iType = {
    0,
    0,
    8,
    0
  }
}
OperType_Battle_ClientInfo = sdp.SdpStruct("OperType_Battle_ClientInfo")
OperType_Battle_ClientInfo.Definition = {
  "iCpuHz",
  "iMemory",
  "iMinfps",
  "iAvefps",
  "iPing80",
  "iPing100",
  "iPing120",
  "iPing150",
  "iPing200",
  "iPing300",
  "iPing500",
  "iPing800",
  "iPing_times",
  "iProxy_ping",
  "iBattle_ping",
  "iProxy_battle_ping",
  "iWifi",
  "iUseUdp",
  "iTimeDelay",
  "iTimeDelayMax",
  "iBigReconnect",
  "iSmallReconnect",
  "iProxyId",
  "iClientParam1",
  "iClientParam2",
  "iClientParam3",
  "iClientParam4",
  "iClientParam5",
  "iClientParam6",
  "iClientParam7",
  "iClientParam8",
  "iIncomingLagNum",
  "iOutgoingLagNum",
  "iSwitchUdpNum",
  "iSwitchTcpNum",
  "iIncoming265",
  "iIncoming530",
  "iIncoming1000",
  "iIncoming3000",
  "iMoveLag",
  "iSkillLag",
  "iOutgoingping50ms",
  "iOutgoingping100ms",
  "iOutgoingpingOver100ms",
  "iIncomingping50ms",
  "iIncomingping100ms",
  "iIncomingpingOver100ms",
  "iTotalClientSendPacket",
  "iOperate350",
  "iOperate450",
  "iOperate800",
  "iTcpFrameNum",
  "iUdpFrameNum",
  "sUdpStat",
  "sUnityVersion",
  "iIncoming66",
  "bLowPower",
  "uiBytesC2S",
  "uiPacketsC2S",
  "uiBytesS2C",
  "uiPacketsS2C",
  "iStdPing",
  "bIsVpn",
  iCpuHz = {
    0,
    0,
    8,
    0
  },
  iMemory = {
    1,
    0,
    8,
    0
  },
  iMinfps = {
    2,
    0,
    8,
    0
  },
  iAvefps = {
    3,
    0,
    8,
    0
  },
  iPing80 = {
    5,
    0,
    8,
    0
  },
  iPing100 = {
    6,
    0,
    8,
    0
  },
  iPing120 = {
    7,
    0,
    8,
    0
  },
  iPing150 = {
    8,
    0,
    8,
    0
  },
  iPing200 = {
    9,
    0,
    8,
    0
  },
  iPing300 = {
    10,
    0,
    8,
    0
  },
  iPing500 = {
    11,
    0,
    8,
    0
  },
  iPing800 = {
    12,
    0,
    8,
    0
  },
  iPing_times = {
    13,
    0,
    8,
    0
  },
  iProxy_ping = {
    14,
    0,
    8,
    0
  },
  iBattle_ping = {
    15,
    0,
    8,
    0
  },
  iProxy_battle_ping = {
    16,
    0,
    8,
    0
  },
  iWifi = {
    17,
    0,
    13,
    ""
  },
  iUseUdp = {
    18,
    0,
    8,
    0
  },
  iTimeDelay = {
    19,
    0,
    8,
    0
  },
  iTimeDelayMax = {
    20,
    0,
    8,
    0
  },
  iBigReconnect = {
    21,
    0,
    8,
    0
  },
  iSmallReconnect = {
    22,
    0,
    8,
    0
  },
  iProxyId = {
    23,
    0,
    8,
    0
  },
  iClientParam1 = {
    24,
    0,
    8,
    0
  },
  iClientParam2 = {
    25,
    0,
    8,
    0
  },
  iClientParam3 = {
    26,
    0,
    8,
    0
  },
  iClientParam4 = {
    27,
    0,
    8,
    0
  },
  iClientParam5 = {
    28,
    0,
    8,
    0
  },
  iClientParam6 = {
    29,
    0,
    8,
    0
  },
  iClientParam7 = {
    30,
    0,
    8,
    0
  },
  iClientParam8 = {
    31,
    0,
    8,
    0
  },
  iIncomingLagNum = {
    32,
    0,
    8,
    0
  },
  iOutgoingLagNum = {
    33,
    0,
    8,
    0
  },
  iSwitchUdpNum = {
    34,
    0,
    8,
    0
  },
  iSwitchTcpNum = {
    35,
    0,
    8,
    0
  },
  iIncoming265 = {
    36,
    0,
    8,
    0
  },
  iIncoming530 = {
    37,
    0,
    8,
    0
  },
  iIncoming1000 = {
    38,
    0,
    8,
    0
  },
  iIncoming3000 = {
    39,
    0,
    8,
    0
  },
  iMoveLag = {
    40,
    0,
    8,
    0
  },
  iSkillLag = {
    41,
    0,
    8,
    0
  },
  iOutgoingping50ms = {
    42,
    0,
    8,
    0
  },
  iOutgoingping100ms = {
    43,
    0,
    8,
    0
  },
  iOutgoingpingOver100ms = {
    44,
    0,
    8,
    0
  },
  iIncomingping50ms = {
    45,
    0,
    8,
    0
  },
  iIncomingping100ms = {
    46,
    0,
    8,
    0
  },
  iIncomingpingOver100ms = {
    47,
    0,
    8,
    0
  },
  iTotalClientSendPacket = {
    48,
    0,
    8,
    0
  },
  iOperate350 = {
    49,
    0,
    8,
    0
  },
  iOperate450 = {
    50,
    0,
    8,
    0
  },
  iOperate800 = {
    51,
    0,
    8,
    0
  },
  iTcpFrameNum = {
    52,
    0,
    8,
    0
  },
  iUdpFrameNum = {
    53,
    0,
    8,
    0
  },
  sUdpStat = {
    54,
    0,
    13,
    ""
  },
  sUnityVersion = {
    55,
    0,
    13,
    ""
  },
  iIncoming66 = {
    56,
    0,
    8,
    0
  },
  bLowPower = {
    57,
    0,
    1,
    false
  },
  uiBytesC2S = {
    58,
    0,
    8,
    0
  },
  uiPacketsC2S = {
    59,
    0,
    8,
    0
  },
  uiBytesS2C = {
    60,
    0,
    8,
    0
  },
  uiPacketsS2C = {
    61,
    0,
    8,
    0
  },
  iStdPing = {
    62,
    0,
    8,
    0
  },
  bIsVpn = {
    63,
    0,
    1,
    false
  }
}
OperType_Battle_ChangeSetting = sdp.SdpStruct("OperType_Battle_ChangeSetting")
OperType_Battle_ChangeSetting.Definition = {
  "byType",
  "iValue",
  byType = {
    0,
    0,
    2,
    0
  },
  iValue = {
    1,
    0,
    7,
    0
  }
}
OperType_Battle_CommonOper = sdp.SdpStruct("OperType_Battle_CommonOper")
OperType_Battle_CommonOper.Definition = {
  "uiType",
  "uiData1",
  "uiData2",
  "uiData3",
  "uiData4",
  "uiData5",
  "uiData6",
  "vData7",
  uiType = {
    0,
    0,
    8,
    0
  },
  uiData1 = {
    1,
    0,
    8,
    0
  },
  uiData2 = {
    2,
    0,
    8,
    0
  },
  uiData3 = {
    3,
    0,
    8,
    0
  },
  uiData4 = {
    4,
    0,
    8,
    0
  },
  uiData5 = {
    5,
    0,
    8,
    0
  },
  uiData6 = {
    6,
    0,
    8,
    0
  },
  vData7 = {
    7,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Battle_GetFrameTime_CS = sdp.SdpStruct("Cmd_Battle_GetFrameTime_CS")
Cmd_Battle_GetFrameTime_CS.Definition = {}
Cmd_Battle_GetFrameTime_SC = sdp.SdpStruct("Cmd_Battle_GetFrameTime_SC")
Cmd_Battle_GetFrameTime_SC.Definition = {
  "iLastFrameTime",
  "iLogicTime",
  iLastFrameTime = {
    0,
    0,
    10,
    "0"
  },
  iLogicTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Battle_SetUdpPattern_CS = sdp.SdpStruct("Cmd_Battle_SetUdpPattern_CS")
Cmd_Battle_SetUdpPattern_CS.Definition = {
  "vPatternA",
  "vPatternB",
  "bUseNewPack",
  vPatternA = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternB = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  bUseNewPack = {
    2,
    0,
    1,
    false
  }
}
Cmd_Battle_SetUdpPattern_SC = sdp.SdpStruct("Cmd_Battle_SetUdpPattern_SC")
Cmd_Battle_SetUdpPattern_SC.Definition = {
  "vPatternA",
  "vPatternB",
  "bUseNewPack",
  vPatternA = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternB = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  bUseNewPack = {
    2,
    0,
    1,
    false
  }
}
Cmd_Battle_SetUdpInitPattern_CS = sdp.SdpStruct("Cmd_Battle_SetUdpInitPattern_CS")
Cmd_Battle_SetUdpInitPattern_CS.Definition = {
  "vPatternANormal",
  "vPatternBNormal",
  "vPatternALag",
  "vPatternBLag",
  "bUseServerPush",
  vPatternANormal = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternBNormal = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternALag = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternBLag = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  bUseServerPush = {
    4,
    0,
    1,
    false
  }
}
Cmd_Battle_SetUdpInitPattern_SC = sdp.SdpStruct("Cmd_Battle_SetUdpInitPattern_SC")
Cmd_Battle_SetUdpInitPattern_SC.Definition = {
  "vPatternANormal",
  "vPatternBNormal",
  "vPatternALag",
  "vPatternBLag",
  "bUseServerPush",
  vPatternANormal = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternBNormal = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternALag = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  },
  vPatternBLag = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  bUseServerPush = {
    4,
    0,
    1,
    false
  }
}
Cmd_Battle_Check_CS = sdp.SdpStruct("Cmd_Battle_Check_CS")
Cmd_Battle_Check_CS.Definition = {
  "ulIndex",
  "sContent",
  ulIndex = {
    0,
    0,
    10,
    "0"
  },
  sContent = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Battle_Check_SC = sdp.SdpStruct("Cmd_Battle_Check_SC")
Cmd_Battle_Check_SC.Definition = {
  "ulIndex",
  "sContent",
  ulIndex = {
    0,
    0,
    10,
    "0"
  },
  sContent = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Battle_UdpFrameData_CS = sdp.SdpStruct("Cmd_Battle_UdpFrameData_CS")
Cmd_Battle_UdpFrameData_CS.Definition = {
  "uiLastLogicTime",
  "iTryNum",
  uiLastLogicTime = {
    0,
    0,
    8,
    0
  },
  iTryNum = {
    1,
    0,
    7,
    0
  }
}
Cmd_Battle_UdpFrameData_SC = sdp.SdpStruct("Cmd_Battle_UdpFrameData_SC")
Cmd_Battle_UdpFrameData_SC.Definition = {
  "vOperFrames",
  vOperFrames = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Battle_UdpFrame_Confirm_CS = sdp.SdpStruct("Cmd_Battle_UdpFrame_Confirm_CS")
Cmd_Battle_UdpFrame_Confirm_CS.Definition = {
  "uiFrameConfirm",
  uiFrameConfirm = {
    0,
    0,
    8,
    0
  }
}
Cmd_Battle_NewUdpFramesData_SC = sdp.SdpStruct("Cmd_Battle_NewUdpFramesData_SC")
Cmd_Battle_NewUdpFramesData_SC.Definition = {
  "uiStartFrame",
  "uiFrameIndex",
  "vOpers1",
  "vOpers2",
  "vOpers3",
  "vOpers4",
  uiStartFrame = {
    0,
    0,
    8,
    0
  },
  uiFrameIndex = {
    1,
    0,
    8,
    0
  },
  vOpers1 = {
    2,
    0,
    sdp.SdpVector(BattleOperData),
    nil
  },
  vOpers2 = {
    3,
    0,
    sdp.SdpVector(BattleOperData),
    nil
  },
  vOpers3 = {
    4,
    0,
    sdp.SdpVector(BattleOperData),
    nil
  },
  vOpers4 = {
    5,
    0,
    sdp.SdpVector(BattleOperData),
    nil
  }
}
Cmd_Battle_UdpFrameReq_CS = sdp.SdpStruct("Cmd_Battle_UdpFrameReq_CS")
Cmd_Battle_UdpFrameReq_CS.Definition = {
  "vOperIndex",
  "iReqIndex",
  "bReliable",
  vOperIndex = {
    0,
    0,
    sdp.SdpVector(7),
    nil
  },
  iReqIndex = {
    1,
    0,
    8,
    0
  },
  bReliable = {
    2,
    0,
    1,
    false
  }
}
Cmd_Battle_UdpFrameReq_SC = sdp.SdpStruct("Cmd_Battle_UdpFrameReq_SC")
Cmd_Battle_UdpFrameReq_SC.Definition = {
  "vOperFrames",
  vOperFrames = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Battle_ReportLogicError_CS = sdp.SdpStruct("Cmd_Battle_ReportLogicError_CS")
Cmd_Battle_ReportLogicError_CS.Definition = {}
Cmd_Battle_ReportLogicError_SC = sdp.SdpStruct("Cmd_Battle_ReportLogicError_SC")
Cmd_Battle_ReportLogicError_SC.Definition = {
  "iResult",
  iResult = {
    0,
    0,
    7,
    0
  }
}
BattleOperMD5 = sdp.SdpStruct("BattleOperMD5")
BattleOperMD5.Definition = {
  "uiData",
  "uiMD5Hash",
  uiData = {
    0,
    0,
    8,
    0
  },
  uiMD5Hash = {
    1,
    0,
    8,
    0
  }
}
