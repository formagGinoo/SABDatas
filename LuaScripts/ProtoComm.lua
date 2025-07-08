local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
FightTestType_Nill = 0
FightTestType_Pvp = 1
FightTestType_Pve = 2
FightTestType_Random = 3
MatchMode_PVP = 1
MatchMode_AI = 2
MatchMode_PVE = 3
MatchMode_Ladder = 4
RoomState_Idle = 0
RoomState_Match = 1
RoomState_Battle = 2
MatchState_None = 0
MatchState_Matching = 1
MatchState_MatchSuccess = 2
CampTypeUnkown = 0
CampTypeA = CampTypeUnkown + 1
CampTypeB = CampTypeA + 1
CampTypeJudge = 5
CampTypeLookerA = 11
CampTypeLookerB = 12
RoleStatus_Offline = 0
RoleStatus_Online = 1
RoleStatus_InMatch = 2
RoleStatus_InBattle = 3
RoleStatus_Max = RoleStatus_InBattle + 1
ReqProto = sdp.SdpStruct("ReqProto")
ReqProto.Definition = {
  "iReqCmdId",
  "iReqCmdSeq",
  "sReqData",
  "bDual",
  "uiFrameConfirm",
  iReqCmdId = {
    0,
    1,
    8,
    0
  },
  iReqCmdSeq = {
    1,
    0,
    8,
    0
  },
  sReqData = {
    5,
    0,
    13,
    ""
  },
  bDual = {
    6,
    0,
    1,
    false
  },
  uiFrameConfirm = {
    7,
    0,
    8,
    0
  }
}
RspProto = sdp.SdpStruct("RspProto")
RspProto.Definition = {
  "iRspCmdId",
  "iRspCmdSeq",
  "iPushSeqId",
  "iRspCode",
  "sRspData",
  iRspCmdId = {
    0,
    1,
    8,
    0
  },
  iRspCmdSeq = {
    1,
    0,
    8,
    0
  },
  iPushSeqId = {
    2,
    0,
    8,
    0
  },
  iRspCode = {
    5,
    0,
    7,
    0
  },
  sRspData = {
    6,
    0,
    13,
    ""
  }
}
ReqProtoHeader = sdp.SdpStruct("ReqProtoHeader")
ReqProtoHeader.Definition = {
  "iReqCmdId",
  "iReqCmdSeq",
  iReqCmdId = {
    0,
    1,
    8,
    0
  },
  iReqCmdSeq = {
    1,
    0,
    8,
    0
  }
}
RspProtoHeader = sdp.SdpStruct("RspProtoHeader")
RspProtoHeader.Definition = {
  "iRspCmdId",
  "iRspCmdSeq",
  iRspCmdId = {
    0,
    1,
    8,
    0
  },
  iRspCmdSeq = {
    1,
    0,
    8,
    0
  }
}
ChatGroupInfo = sdp.SdpStruct("ChatGroupInfo")
ChatGroupInfo.Definition = {
  "iGroupId",
  "sName",
  "stHost",
  "vMembers",
  "bIsSticky",
  "iMsgSeq",
  "iEventSeq",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  stHost = {
    2,
    0,
    PlayerIDType,
    nil
  },
  vMembers = {
    3,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  bIsSticky = {
    4,
    0,
    1,
    false
  },
  iMsgSeq = {
    5,
    0,
    10,
    "0"
  },
  iEventSeq = {
    6,
    0,
    10,
    "0"
  }
}
PlayerBaseInfo = sdp.SdpStruct("PlayerBaseInfo")
PlayerBaseInfo.Definition = {
  "iUid",
  "iZoneId",
  "sName",
  "iLevel",
  "iCountryId",
  "sAllianceName",
  "iVipLevel",
  "iGender",
  "bDisplayGender",
  "iFrameId",
  "sZoneName",
  "sFacePath",
  "sFBFaceId",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  iZoneId = {
    1,
    0,
    8,
    0
  },
  sName = {
    2,
    0,
    13,
    ""
  },
  iLevel = {
    3,
    0,
    8,
    0
  },
  iCountryId = {
    4,
    0,
    8,
    0
  },
  sAllianceName = {
    5,
    0,
    13,
    ""
  },
  iVipLevel = {
    6,
    0,
    8,
    0
  },
  iGender = {
    7,
    0,
    8,
    0
  },
  bDisplayGender = {
    8,
    0,
    1,
    false
  },
  iFrameId = {
    9,
    0,
    8,
    0
  },
  sZoneName = {
    11,
    0,
    13,
    ""
  },
  sFacePath = {
    13,
    0,
    13,
    ""
  },
  sFBFaceId = {
    14,
    0,
    13,
    ""
  },
  iHeadId = {
    15,
    0,
    8,
    0
  },
  iHeadFrameId = {
    16,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    17,
    0,
    8,
    0
  }
}
CrossChatRoleDetail = sdp.SdpStruct("CrossChatRoleDetail")
CrossChatRoleDetail.Definition = {
  "stBrief",
  "iAllianceBadge",
  "vHero",
  "iPower",
  "iArenaRank",
  "iArenaBattleRank",
  stBrief = {
    0,
    0,
    PlayerBaseInfo,
    nil
  },
  iAllianceBadge = {
    1,
    0,
    8,
    0
  },
  vHero = {
    2,
    0,
    sdp.SdpVector(CmdHeroBriefData),
    nil
  },
  iPower = {
    3,
    0,
    8,
    0
  },
  iArenaRank = {
    4,
    0,
    8,
    0
  },
  iArenaBattleRank = {
    5,
    0,
    8,
    0
  }
}
PlayerChatInfo = sdp.SdpStruct("PlayerChatInfo")
PlayerChatInfo.Definition = {
  "iChatType",
  "sMessage",
  "stBase",
  "iChatLanguage",
  "iChatTime",
  "iChatUid",
  "iTemplateId",
  "mParam",
  "iGroupId",
  "stSharedAlliance",
  "stSharedRole",
  "stShareHero",
  "iFightReportId",
  "iFightType",
  "iFightReportZoneId",
  "vArenaBattleReportId",
  "iMaxPassStageId",
  iChatType = {
    0,
    0,
    8,
    0
  },
  sMessage = {
    1,
    0,
    13,
    ""
  },
  stBase = {
    2,
    0,
    PlayerBaseInfo,
    nil
  },
  iChatLanguage = {
    3,
    0,
    8,
    0
  },
  iChatTime = {
    4,
    0,
    8,
    0
  },
  iChatUid = {
    5,
    0,
    8,
    0
  },
  iTemplateId = {
    6,
    0,
    8,
    0
  },
  mParam = {
    7,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iGroupId = {
    8,
    0,
    10,
    "0"
  },
  stSharedAlliance = {
    21,
    0,
    CmdAllianceBriefData,
    nil
  },
  stSharedRole = {
    23,
    0,
    CmdRoleSimpleInfo,
    nil
  },
  stShareHero = {
    25,
    0,
    CmdHeroData,
    nil
  },
  iFightReportId = {
    26,
    0,
    10,
    "0"
  },
  iFightType = {
    27,
    0,
    8,
    0
  },
  iFightReportZoneId = {
    28,
    0,
    8,
    0
  },
  vArenaBattleReportId = {
    29,
    0,
    sdp.SdpVector(CmdChatArenaBattleFightReport),
    nil
  },
  iMaxPassStageId = {
    31,
    0,
    8,
    0
  }
}
GroupChatInfo = sdp.SdpStruct("GroupChatInfo")
GroupChatInfo.Definition = {
  "iGroupId",
  "vMembers",
  "iChatUid",
  "iCreateUid",
  "sName",
  "iCreateTime",
  "sLocalName",
  "vChat",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  vMembers = {
    1,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  iChatUid = {
    2,
    0,
    8,
    0
  },
  iCreateUid = {
    3,
    0,
    PlayerIDType,
    nil
  },
  sName = {
    4,
    0,
    13,
    ""
  },
  iCreateTime = {
    5,
    0,
    8,
    0
  },
  sLocalName = {
    6,
    0,
    13,
    ""
  },
  vChat = {
    7,
    0,
    sdp.SdpVector(PlayerChatInfo),
    nil
  }
}
AllianceChatInfo = sdp.SdpStruct("AllianceChatInfo")
AllianceChatInfo.Definition = {
  "stRoleBase",
  "sMessage",
  "iChatUid",
  "iTime",
  "iTemplateId",
  "mParam",
  "iFightReportId",
  "iFightType",
  "sZoneName",
  "sShareHero",
  "iFightReportZoneId",
  "sChatSpecificData",
  stRoleBase = {
    0,
    0,
    PlayerBaseInfo,
    nil
  },
  sMessage = {
    1,
    0,
    13,
    ""
  },
  iChatUid = {
    2,
    0,
    8,
    0
  },
  iTime = {
    3,
    0,
    8,
    0
  },
  iTemplateId = {
    4,
    0,
    8,
    0
  },
  mParam = {
    5,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iFightReportId = {
    6,
    0,
    10,
    "0"
  },
  iFightType = {
    7,
    0,
    8,
    0
  },
  sZoneName = {
    8,
    0,
    13,
    ""
  },
  sShareHero = {
    9,
    0,
    13,
    ""
  },
  iFightReportZoneId = {
    10,
    0,
    8,
    0
  },
  sChatSpecificData = {
    11,
    0,
    13,
    ""
  }
}
AllianceChatSpecificData = sdp.SdpStruct("AllianceChatSpecificData")
AllianceChatSpecificData.Definition = {
  "stRoleBase",
  "sMessage",
  "iTemplateId",
  "mParam",
  "iFightReportId",
  "iFightType",
  "sZoneName",
  "sShareHero",
  "iFightReportZoneId",
  "sShareRoleSimpleInfo",
  "vArenaBattleFightReportId",
  "bSysMessage",
  "iMaxPassStageId",
  stRoleBase = {
    0,
    0,
    PlayerBaseInfo,
    nil
  },
  sMessage = {
    1,
    0,
    13,
    ""
  },
  iTemplateId = {
    4,
    0,
    8,
    0
  },
  mParam = {
    5,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iFightReportId = {
    6,
    0,
    10,
    "0"
  },
  iFightType = {
    7,
    0,
    8,
    0
  },
  sZoneName = {
    8,
    0,
    13,
    ""
  },
  sShareHero = {
    9,
    0,
    13,
    ""
  },
  iFightReportZoneId = {
    10,
    0,
    8,
    0
  },
  sShareRoleSimpleInfo = {
    11,
    0,
    13,
    ""
  },
  vArenaBattleFightReportId = {
    12,
    0,
    sdp.SdpVector(10),
    nil
  },
  bSysMessage = {
    14,
    0,
    1,
    false
  },
  iMaxPassStageId = {
    21,
    0,
    8,
    0
  }
}
PersonalChatInfo = sdp.SdpStruct("PersonalChatInfo")
PersonalChatInfo.Definition = {
  "iChatUid",
  "iTime",
  "sChatSpecificData",
  iChatUid = {
    0,
    0,
    8,
    0
  },
  iTime = {
    1,
    0,
    8,
    0
  },
  sChatSpecificData = {
    2,
    0,
    13,
    ""
  }
}
PersonalChatSpecificData = sdp.SdpStruct("PersonalChatSpecificData")
PersonalChatSpecificData.Definition = {
  "stRoleId",
  "stToRoleId",
  "sMessage",
  "iTemplateId",
  "stSharedAlliance",
  "iAllianceId",
  "sWebSharePic",
  "sWebLink",
  "sWebSystem",
  "sWebLogin",
  "iWebActId",
  "iMaxPassStageId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  stToRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  },
  sMessage = {
    2,
    0,
    13,
    ""
  },
  iTemplateId = {
    3,
    0,
    8,
    0
  },
  stSharedAlliance = {
    4,
    0,
    CmdAllianceBriefData,
    nil
  },
  iAllianceId = {
    5,
    0,
    10,
    "0"
  },
  sWebSharePic = {
    6,
    0,
    13,
    ""
  },
  sWebLink = {
    7,
    0,
    13,
    ""
  },
  sWebSystem = {
    8,
    0,
    13,
    ""
  },
  sWebLogin = {
    9,
    0,
    13,
    ""
  },
  iWebActId = {
    10,
    0,
    8,
    0
  },
  iMaxPassStageId = {
    12,
    0,
    8,
    0
  }
}
PlayerMatchingInfo = sdp.SdpStruct("PlayerMatchingInfo")
PlayerMatchingInfo.Definition = {
  "iRoleId",
  "iZoneId",
  "sName",
  iRoleId = {
    0,
    0,
    10,
    "0"
  },
  iZoneId = {
    1,
    0,
    8,
    0
  },
  sName = {
    5,
    0,
    13,
    ""
  }
}
MatchBattleInfo = sdp.SdpStruct("MatchBattleInfo")
MatchBattleInfo.Definition = {
  "iBattleUid",
  "sBattleIp",
  "iBattlePort",
  "sBattleProxy",
  "iProxyId",
  "iProxyPing",
  "sBattleConn",
  "iBattleSvrId",
  "bUseRUdp",
  "iMatchType",
  "iUdpPort",
  "vUp",
  "vDown",
  iBattleUid = {
    1,
    0,
    10,
    "0"
  },
  sBattleIp = {
    2,
    0,
    13,
    ""
  },
  iBattlePort = {
    3,
    0,
    8,
    0
  },
  sBattleProxy = {
    4,
    0,
    13,
    ""
  },
  iProxyId = {
    5,
    0,
    8,
    0
  },
  iProxyPing = {
    6,
    0,
    8,
    0
  },
  sBattleConn = {
    7,
    0,
    13,
    ""
  },
  iBattleSvrId = {
    8,
    0,
    8,
    0
  },
  bUseRUdp = {
    9,
    0,
    1,
    false
  },
  iMatchType = {
    11,
    0,
    8,
    0
  },
  iUdpPort = {
    12,
    0,
    8,
    0
  },
  vUp = {
    20,
    0,
    sdp.SdpVector(PlayerMatchingInfo),
    nil
  },
  vDown = {
    21,
    0,
    sdp.SdpVector(PlayerMatchingInfo),
    nil
  }
}
BattleGroupInfo = sdp.SdpStruct("BattleGroupInfo")
BattleGroupInfo.Definition = {
  "iGroupId",
  "iPing",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  iPing = {
    1,
    0,
    8,
    0
  }
}
SessionKeyAddition = sdp.SdpStruct("SessionKeyAddition")
SessionKeyAddition.Definition = {
  "iBattleSvrId",
  "iZoneId",
  iBattleSvrId = {
    0,
    0,
    8,
    0
  },
  iZoneId = {
    1,
    0,
    8,
    0
  }
}
RoomPlayerInfo = sdp.SdpStruct("RoomPlayerInfo")
RoomPlayerInfo.Definition = {
  "stPlayer",
  "sName",
  "iLevel",
  "vBattleGroupId",
  "iPos",
  stPlayer = {
    0,
    0,
    PlayerIDType,
    nil
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLevel = {
    2,
    0,
    8,
    0
  },
  vBattleGroupId = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iPos = {
    4,
    0,
    8,
    0
  }
}
RoomInfo = sdp.SdpStruct("RoomInfo")
RoomInfo.Definition = {
  "iRoomId",
  "stOwner",
  "vPlayer",
  iRoomId = {
    0,
    0,
    10,
    "0"
  },
  stOwner = {
    1,
    0,
    PlayerIDType,
    nil
  },
  vPlayer = {
    2,
    0,
    sdp.SdpVector(RoomPlayerInfo),
    nil
  }
}
