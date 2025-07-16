local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoComm")
module("MTTDProto")
CmdId_Chat_GetInit_CS = 12101
CmdId_Chat_GetInit_SC = 12102
CmdId_Chat_SendChat_CS = 12103
CmdId_Chat_SendChat_SC = 12104
CmdId_Chat_AddToShield_CS = 12105
CmdId_Chat_AddToShield_SC = 12106
CmdId_Chat_RemoveFromShield_CS = 12107
CmdId_Chat_RemoveFromShield_SC = 12108
CmdId_Chat_GetChat_CS = 12109
CmdId_Chat_GetChat_SC = 12110
CmdId_Chat_GroupInvite_CS = 12111
CmdId_Chat_GroupInvite_SC = 12112
CmdId_Chat_GroupLeave_CS = 12113
CmdId_Chat_GroupLeave_SC = 12114
CmdId_Chat_GroupSetName_CS = 12115
CmdId_Chat_GroupSetName_SC = 12116
CmdId_Chat_GetTranslate_CS = 12117
CmdId_Chat_GetTranslate_SC = 12118
CmdId_Chat_SyncTranslate_CS = 12119
CmdId_Chat_SyncTranslate_SC = 12120
CmdId_Chat_ReportBadMessage_CS = 12121
CmdId_Chat_ReportBadMessage_SC = 12122
CmdId_Chat_GroupKick_CS = 12123
CmdId_Chat_GroupKick_SC = 12124
CmdId_Chat_GroupDissolve_CS = 12125
CmdId_Chat_GroupDissolve_SC = 12126
CmdId_Chat_JoinCrossZoneRoom_CS = 12127
CmdId_Chat_JoinCrossZoneRoom_SC = 12128
CmdId_Chat_GetCrossZoneInit_CS = 12129
CmdId_Chat_GetCrossZoneInit_SC = 12130
CmdId_Chat_CrossGroup_Create_CS = 12131
CmdId_Chat_CrossGroup_Create_SC = 12132
CmdId_Chat_CrossGroup_Leave_CS = 12133
CmdId_Chat_CrossGroup_Leave_SC = 12134
CmdId_Chat_AddToCrossShield_CS = 12135
CmdId_Chat_AddToCrossShield_SC = 12136
CmdId_Chat_RemoveFromCrossShield_CS = 12137
CmdId_Chat_RemoveFromCrossShield_SC = 12138
CmdId_Chat_GetCrossZoneRoleDetail_CS = 12139
CmdId_Chat_GetCrossZoneRoleDetail_SC = 12140
CmdId_Chat_GroupSet_CS = 12141
CmdId_Chat_GroupSet_SC = 12142
CmdId_Chat_SetShowCrossChat_CS = 12143
CmdId_Chat_SetShowCrossChat_SC = 12144
CmdId_Chat_Like_CS = 12145
CmdId_Chat_Like_SC = 12146
CmdId_Chat_Unlike_CS = 12147
CmdId_Chat_Unlike_SC = 12148
CmdId_Chat_CreatePersonalChat_CS = 12149
CmdId_Chat_CreatePersonalChat_SC = 12150
CmdId_Chat_DelPersonalChat_CS = 12151
CmdId_Chat_DelPersonalChat_SC = 12152
CmdId_Chat_ReadPersonalMsg_CS = 12153
CmdId_Chat_ReadPersonalMsg_SC = 12154
CmdId_Chat_GetShieldList_CS = 12155
CmdId_Chat_GetShieldList_SC = 12156
CmdId_Chat_GetLanguageInit_CS = 12157
CmdId_Chat_GetLanguageInit_SC = 12158
CmdId_Chat_SwitchLanguage_CS = 12159
CmdId_Chat_SwitchLanguage_SC = 12160
CmdId_Chat_SetRefuseStranger_CS = 12161
CmdId_Chat_SetRefuseStranger_SC = 12162
CmdId_Chat_GetLanguageGroup_CS = 12163
CmdId_Chat_GetLanguageGroup_SC = 12164
CmdId_Chat_GetLastChatInfo_CS = 12165
CmdId_Chat_GetLastChatInfo_SC = 12166
CmdId_Chat_ReportBadMessages_CS = 12167
CmdId_Chat_ReportBadMessages_SC = 12168
CmdId_Chat_GetDirtyWords_CS = 12169
CmdId_Chat_GetDirtyWords_SC = 12170
ChatChannel_World = 1
ChatChannel_Alliance = 2
ChatChannel_Recruit = 3
ChatChannel_System = 4
ChatChannel_Personal = 9
ChatChannel_CrossZoneLang = 10
ChatChannel_Max = ChatChannel_CrossZoneLang + 1
GroupOPType_MIN = 0
GroupOPType_create = 1
GroupOPType_join = 2
GroupOPType_leave = 3
GroupOPType_setName = 4
GroupOPType_disband = 5
GroupOPType_kick = 6
GroupOPType_MAX = GroupOPType_kick + 1
Cmd_Chat_GetInit_CS = sdp.SdpStruct("Cmd_Chat_GetInit_CS")
Cmd_Chat_GetInit_CS.Definition = {}
CmdPersonalChatInitData = sdp.SdpStruct("CmdPersonalChatInitData")
CmdPersonalChatInitData.Definition = {
  "stToRoleId",
  "iChatUid",
  "iTime",
  "bHasUnreadMsg",
  "iCreateTime",
  "stRoleInfo",
  stToRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  },
  iChatUid = {
    1,
    0,
    8,
    0
  },
  iTime = {
    2,
    0,
    8,
    0
  },
  bHasUnreadMsg = {
    3,
    0,
    1,
    false
  },
  iCreateTime = {
    4,
    0,
    8,
    0
  },
  stRoleInfo = {
    5,
    0,
    CmdRoleSimpleInfo,
    nil
  }
}
Cmd_Chat_GetInit_SC = sdp.SdpStruct("Cmd_Chat_GetInit_SC")
Cmd_Chat_GetInit_SC.Definition = {
  "mChatTime",
  "vChatInfo",
  "vChatGroup",
  "bShowCrossChat",
  "vPersonalChat",
  "vShieldRole",
  "bRefuseStranger",
  "vEmojiId",
  mChatTime = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  vChatInfo = {
    2,
    0,
    sdp.SdpVector(CmdChatInfo),
    nil
  },
  vChatGroup = {
    3,
    0,
    sdp.SdpVector(CmdChatGroup),
    nil
  },
  bShowCrossChat = {
    4,
    0,
    1,
    false
  },
  vPersonalChat = {
    5,
    0,
    sdp.SdpVector(CmdPersonalChatInitData),
    nil
  },
  vShieldRole = {
    6,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  bRefuseStranger = {
    7,
    0,
    1,
    false
  },
  vEmojiId = {
    8,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Chat_GetCrossZoneInit_CS = sdp.SdpStruct("Cmd_Chat_GetCrossZoneInit_CS")
Cmd_Chat_GetCrossZoneInit_CS.Definition = {}
Cmd_Chat_GetCrossZoneInit_SC = sdp.SdpStruct("Cmd_Chat_GetCrossZoneInit_SC")
Cmd_Chat_GetCrossZoneInit_SC.Definition = {
  "iCrossChatLanguage",
  "iCrossChatLanguageTime",
  "vChatInfo",
  "vGroupChatInfo",
  "mZoneShieldUid",
  "mZoneFollowUid",
  iCrossChatLanguage = {
    0,
    0,
    8,
    0
  },
  iCrossChatLanguageTime = {
    1,
    0,
    8,
    0
  },
  vChatInfo = {
    2,
    0,
    sdp.SdpVector(PlayerChatInfo),
    nil
  },
  vGroupChatInfo = {
    3,
    0,
    sdp.SdpVector(GroupChatInfo),
    nil
  },
  mZoneShieldUid = {
    4,
    0,
    sdp.SdpMap(8, sdp.SdpVector(10)),
    nil
  },
  mZoneFollowUid = {
    5,
    0,
    sdp.SdpMap(8, sdp.SdpVector(10)),
    nil
  }
}
Cmd_Chat_SendChat_CS = sdp.SdpStruct("Cmd_Chat_SendChat_CS")
Cmd_Chat_SendChat_CS.Definition = {
  "iChannel",
  "sMessage",
  "iTemplateId",
  "mParam",
  "iFightReportId",
  "iFightType",
  "iSharedUid",
  "iSharedAllianceId",
  "iMailId",
  "iAllianceGiftPackUid",
  "vArenaBattleReportId",
  "iGroupId",
  "iAllianceBuildId",
  "iBuildAllianceId",
  "iRoomId",
  "iSharedUidZoneId",
  "iHeroId",
  "stToRoleId",
  "iActivityId",
  iChannel = {
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
  iTemplateId = {
    2,
    0,
    8,
    0
  },
  mParam = {
    3,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iFightReportId = {
    4,
    0,
    10,
    "0"
  },
  iFightType = {
    5,
    0,
    8,
    0
  },
  iSharedUid = {
    6,
    0,
    10,
    "0"
  },
  iSharedAllianceId = {
    8,
    0,
    10,
    "0"
  },
  iMailId = {
    9,
    0,
    8,
    0
  },
  iAllianceGiftPackUid = {
    10,
    0,
    10,
    "0"
  },
  vArenaBattleReportId = {
    12,
    0,
    sdp.SdpVector(CmdChatArenaBattleFightReport),
    nil
  },
  iGroupId = {
    13,
    0,
    10,
    "0"
  },
  iAllianceBuildId = {
    14,
    0,
    8,
    0
  },
  iBuildAllianceId = {
    15,
    0,
    10,
    "0"
  },
  iRoomId = {
    16,
    0,
    10,
    "0"
  },
  iSharedUidZoneId = {
    22,
    0,
    8,
    0
  },
  iHeroId = {
    23,
    0,
    8,
    0
  },
  stToRoleId = {
    24,
    0,
    PlayerIDType,
    nil
  },
  iActivityId = {
    25,
    0,
    8,
    0
  }
}
Cmd_Chat_SendChat_SC = sdp.SdpStruct("Cmd_Chat_SendChat_SC")
Cmd_Chat_SendChat_SC.Definition = {
  "iChannel",
  "iTime",
  "iGroupId",
  iChannel = {
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
  iGroupId = {
    3,
    0,
    10,
    "0"
  }
}
CmdFavoritRole = sdp.SdpStruct("CmdFavoritRole")
CmdFavoritRole.Definition = {}
Cmd_Chat_AddToShield_CS = sdp.SdpStruct("Cmd_Chat_AddToShield_CS")
Cmd_Chat_AddToShield_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_AddToShield_SC = sdp.SdpStruct("Cmd_Chat_AddToShield_SC")
Cmd_Chat_AddToShield_SC.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    CmdRoleSimpleInfo,
    nil
  }
}
Cmd_Chat_RemoveFromShield_CS = sdp.SdpStruct("Cmd_Chat_RemoveFromShield_CS")
Cmd_Chat_RemoveFromShield_CS.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_RemoveFromShield_SC = sdp.SdpStruct("Cmd_Chat_RemoveFromShield_SC")
Cmd_Chat_RemoveFromShield_SC.Definition = {
  "stRoleId",
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_GetChat_CS = sdp.SdpStruct("Cmd_Chat_GetChat_CS")
Cmd_Chat_GetChat_CS.Definition = {
  "iChannel",
  "iIndex",
  "bRequestAllianceGiftPack",
  "iGroupId",
  "bAllianceFilter",
  "iRoomId",
  "stToRoleId",
  iChannel = {
    0,
    0,
    8,
    0
  },
  iIndex = {
    1,
    0,
    8,
    0
  },
  bRequestAllianceGiftPack = {
    2,
    0,
    1,
    false
  },
  iGroupId = {
    3,
    0,
    10,
    "0"
  },
  bAllianceFilter = {
    4,
    0,
    1,
    false
  },
  iRoomId = {
    5,
    0,
    10,
    "0"
  },
  stToRoleId = {
    6,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_GetChat_SC = sdp.SdpStruct("Cmd_Chat_GetChat_SC")
Cmd_Chat_GetChat_SC.Definition = {
  "iChannel",
  "vChatInfo",
  "bRequestAllianceGiftPack",
  "iGroupId",
  "iRoomId",
  "vCrossChatInfo",
  "stToRoleId",
  iChannel = {
    0,
    0,
    8,
    0
  },
  vChatInfo = {
    1,
    0,
    sdp.SdpVector(CmdChatInfo),
    nil
  },
  bRequestAllianceGiftPack = {
    2,
    0,
    1,
    false
  },
  iGroupId = {
    3,
    0,
    10,
    "0"
  },
  iRoomId = {
    4,
    0,
    10,
    "0"
  },
  vCrossChatInfo = {
    5,
    0,
    sdp.SdpVector(PlayerChatInfo),
    nil
  },
  stToRoleId = {
    6,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_GroupInvite_CS = sdp.SdpStruct("Cmd_Chat_GroupInvite_CS")
Cmd_Chat_GroupInvite_CS.Definition = {
  "iGroupId",
  "vUid",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  vUid = {
    1,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Chat_GroupInvite_SC = sdp.SdpStruct("Cmd_Chat_GroupInvite_SC")
Cmd_Chat_GroupInvite_SC.Definition = {
  "bFailed",
  "vShieldName",
  "iGroupId",
  bFailed = {
    0,
    0,
    1,
    false
  },
  vShieldName = {
    1,
    0,
    sdp.SdpVector(13),
    nil
  },
  iGroupId = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Chat_GroupLeave_CS = sdp.SdpStruct("Cmd_Chat_GroupLeave_CS")
Cmd_Chat_GroupLeave_CS.Definition = {
  "iGroupId",
  iGroupId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Chat_GroupLeave_SC = sdp.SdpStruct("Cmd_Chat_GroupLeave_SC")
Cmd_Chat_GroupLeave_SC.Definition = {}
Cmd_Chat_GroupSetName_CS = sdp.SdpStruct("Cmd_Chat_GroupSetName_CS")
Cmd_Chat_GroupSetName_CS.Definition = {
  "iGroupId",
  "sName",
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
  }
}
Cmd_Chat_GroupSetName_SC = sdp.SdpStruct("Cmd_Chat_GroupSetName_SC")
Cmd_Chat_GroupSetName_SC.Definition = {}
Cmd_Chat_GetTranslate_CS = sdp.SdpStruct("Cmd_Chat_GetTranslate_CS")
Cmd_Chat_GetTranslate_CS.Definition = {
  "sStr",
  "iLanguageId",
  sStr = {
    0,
    0,
    13,
    ""
  },
  iLanguageId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Chat_GetTranslate_SC = sdp.SdpStruct("Cmd_Chat_GetTranslate_SC")
Cmd_Chat_GetTranslate_SC.Definition = {
  "sStr",
  "bFind",
  sStr = {
    0,
    0,
    13,
    ""
  },
  bFind = {
    1,
    0,
    1,
    false
  }
}
Cmd_Chat_SyncTranslate_CS = sdp.SdpStruct("Cmd_Chat_SyncTranslate_CS")
Cmd_Chat_SyncTranslate_CS.Definition = {
  "sStr",
  "iLanguageId",
  "sTranslateStr",
  sStr = {
    0,
    0,
    13,
    ""
  },
  iLanguageId = {
    1,
    0,
    8,
    0
  },
  sTranslateStr = {
    2,
    0,
    13,
    ""
  }
}
Cmd_Chat_SyncTranslate_SC = sdp.SdpStruct("Cmd_Chat_SyncTranslate_SC")
Cmd_Chat_SyncTranslate_SC.Definition = {}
Cmd_Chat_ReportBadMessage_CS = sdp.SdpStruct("Cmd_Chat_ReportBadMessage_CS")
Cmd_Chat_ReportBadMessage_CS.Definition = {
  "iChannel",
  "iChatUid",
  "sReason",
  "iGroupId",
  "iZoneId",
  "iReportReasonType",
  "stRoleId",
  iChannel = {
    0,
    0,
    8,
    0
  },
  iChatUid = {
    1,
    0,
    8,
    0
  },
  sReason = {
    2,
    0,
    13,
    ""
  },
  iGroupId = {
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
  },
  iReportReasonType = {
    5,
    0,
    8,
    0
  },
  stRoleId = {
    6,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_ReportBadMessage_SC = sdp.SdpStruct("Cmd_Chat_ReportBadMessage_SC")
Cmd_Chat_ReportBadMessage_SC.Definition = {}
Cmd_Chat_GetLastChatInfo_CS = sdp.SdpStruct("Cmd_Chat_GetLastChatInfo_CS")
Cmd_Chat_GetLastChatInfo_CS.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_GetLastChatInfo_SC = sdp.SdpStruct("Cmd_Chat_GetLastChatInfo_SC")
Cmd_Chat_GetLastChatInfo_SC.Definition = {
  "iNextIndex",
  "vMessages",
  iNextIndex = {
    0,
    0,
    8,
    0
  },
  vMessages = {
    1,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Chat_ReportBadMessages_CS = sdp.SdpStruct("Cmd_Chat_ReportBadMessages_CS")
Cmd_Chat_ReportBadMessages_CS.Definition = {
  "sReason",
  "iReportReasonType",
  "stRoleId",
  sReason = {
    1,
    0,
    13,
    ""
  },
  iReportReasonType = {
    2,
    0,
    8,
    0
  },
  stRoleId = {
    3,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_ReportBadMessages_SC = sdp.SdpStruct("Cmd_Chat_ReportBadMessages_SC")
Cmd_Chat_ReportBadMessages_SC.Definition = {}
Cmd_Chat_GroupKick_CS = sdp.SdpStruct("Cmd_Chat_GroupKick_CS")
Cmd_Chat_GroupKick_CS.Definition = {
  "iGroupId",
  "vKickUid",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  vKickUid = {
    1,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Chat_GroupKick_SC = sdp.SdpStruct("Cmd_Chat_GroupKick_SC")
Cmd_Chat_GroupKick_SC.Definition = {}
Cmd_Chat_GroupDissolve_CS = sdp.SdpStruct("Cmd_Chat_GroupDissolve_CS")
Cmd_Chat_GroupDissolve_CS.Definition = {
  "iGroupId",
  iGroupId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Chat_GroupDissolve_SC = sdp.SdpStruct("Cmd_Chat_GroupDissolve_SC")
Cmd_Chat_GroupDissolve_SC.Definition = {}
Cmd_Chat_JoinCrossZoneRoom_CS = sdp.SdpStruct("Cmd_Chat_JoinCrossZoneRoom_CS")
Cmd_Chat_JoinCrossZoneRoom_CS.Definition = {
  "iLanguageId",
  iLanguageId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Chat_JoinCrossZoneRoom_SC = sdp.SdpStruct("Cmd_Chat_JoinCrossZoneRoom_SC")
Cmd_Chat_JoinCrossZoneRoom_SC.Definition = {
  "iCrossChatLanguage",
  "iCrossChatLanguageTime",
  iCrossChatLanguage = {
    0,
    0,
    8,
    0
  },
  iCrossChatLanguageTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Chat_CrossGroup_Create_CS = sdp.SdpStruct("Cmd_Chat_CrossGroup_Create_CS")
Cmd_Chat_CrossGroup_Create_CS.Definition = {
  "vMembers",
  "sLocalName",
  vMembers = {
    0,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  sLocalName = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Chat_CrossGroup_Create_SC = sdp.SdpStruct("Cmd_Chat_CrossGroup_Create_SC")
Cmd_Chat_CrossGroup_Create_SC.Definition = {
  "stGroupInfo",
  stGroupInfo = {
    0,
    0,
    GroupChatInfo,
    nil
  }
}
Cmd_Chat_CrossGroup_Leave_CS = sdp.SdpStruct("Cmd_Chat_CrossGroup_Leave_CS")
Cmd_Chat_CrossGroup_Leave_CS.Definition = {
  "iGroupId",
  iGroupId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Chat_CrossGroup_Leave_SC = sdp.SdpStruct("Cmd_Chat_CrossGroup_Leave_SC")
Cmd_Chat_CrossGroup_Leave_SC.Definition = {
  "iGroupId",
  iGroupId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Chat_AddToCrossShield_CS = sdp.SdpStruct("Cmd_Chat_AddToCrossShield_CS")
Cmd_Chat_AddToCrossShield_CS.Definition = {
  "iUid",
  "iZoneId",
  "bShield",
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
  bShield = {
    2,
    0,
    1,
    false
  }
}
Cmd_Chat_AddToCrossShield_SC = sdp.SdpStruct("Cmd_Chat_AddToCrossShield_SC")
Cmd_Chat_AddToCrossShield_SC.Definition = {
  "stRole",
  "bShield",
  stRole = {
    0,
    0,
    PlayerBaseInfo,
    nil
  },
  bShield = {
    1,
    0,
    1,
    false
  }
}
Cmd_Chat_RemoveFromCrossShield_CS = sdp.SdpStruct("Cmd_Chat_RemoveFromCrossShield_CS")
Cmd_Chat_RemoveFromCrossShield_CS.Definition = {
  "iUid",
  "iZoneId",
  "bShield",
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
  bShield = {
    2,
    0,
    1,
    false
  }
}
Cmd_Chat_RemoveFromCrossShield_SC = sdp.SdpStruct("Cmd_Chat_RemoveFromCrossShield_SC")
Cmd_Chat_RemoveFromCrossShield_SC.Definition = {
  "iUid",
  "iZoneId",
  "bShield",
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
  bShield = {
    2,
    0,
    1,
    false
  }
}
Cmd_Chat_GetCrossZoneRoleDetail_CS = sdp.SdpStruct("Cmd_Chat_GetCrossZoneRoleDetail_CS")
Cmd_Chat_GetCrossZoneRoleDetail_CS.Definition = {
  "iZoneId",
  "vUid",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  vUid = {
    1,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Chat_GetCrossZoneRoleDetail_SC = sdp.SdpStruct("Cmd_Chat_GetCrossZoneRoleDetail_SC")
Cmd_Chat_GetCrossZoneRoleDetail_SC.Definition = {
  "iZoneId",
  "vUid",
  "mRoleDetail",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  vUid = {
    1,
    0,
    sdp.SdpVector(10),
    nil
  },
  mRoleDetail = {
    2,
    0,
    sdp.SdpMap(10, CrossChatRoleDetail),
    nil
  }
}
Cmd_Chat_GroupSet_CS = sdp.SdpStruct("Cmd_Chat_GroupSet_CS")
Cmd_Chat_GroupSet_CS.Definition = {
  "iGroupId",
  "bOpenPush",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  bOpenPush = {
    1,
    0,
    1,
    false
  }
}
Cmd_Chat_GroupSet_SC = sdp.SdpStruct("Cmd_Chat_GroupSet_SC")
Cmd_Chat_GroupSet_SC.Definition = {}
Cmd_Chat_SetShowCrossChat_CS = sdp.SdpStruct("Cmd_Chat_SetShowCrossChat_CS")
Cmd_Chat_SetShowCrossChat_CS.Definition = {
  "bShow",
  bShow = {
    0,
    0,
    1,
    false
  }
}
Cmd_Chat_SetShowCrossChat_SC = sdp.SdpStruct("Cmd_Chat_SetShowCrossChat_SC")
Cmd_Chat_SetShowCrossChat_SC.Definition = {}
Cmd_Chat_Like_CS = sdp.SdpStruct("Cmd_Chat_Like_CS")
Cmd_Chat_Like_CS.Definition = {
  "iChatUid",
  "iChannelId",
  "iGroupId",
  iChatUid = {
    0,
    0,
    10,
    "0"
  },
  iChannelId = {
    1,
    0,
    8,
    0
  },
  iGroupId = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Chat_Like_SC = sdp.SdpStruct("Cmd_Chat_Like_SC")
Cmd_Chat_Like_SC.Definition = {}
Cmd_Chat_Unlike_CS = sdp.SdpStruct("Cmd_Chat_Unlike_CS")
Cmd_Chat_Unlike_CS.Definition = {
  "iChatUid",
  "iChannelId",
  "iGroupId",
  iChatUid = {
    0,
    0,
    10,
    "0"
  },
  iChannelId = {
    1,
    0,
    8,
    0
  },
  iGroupId = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Chat_Unlike_SC = sdp.SdpStruct("Cmd_Chat_Unlike_SC")
Cmd_Chat_Unlike_SC.Definition = {}
Cmd_Chat_CreatePersonalChat_CS = sdp.SdpStruct("Cmd_Chat_CreatePersonalChat_CS")
Cmd_Chat_CreatePersonalChat_CS.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_CreatePersonalChat_SC = sdp.SdpStruct("Cmd_Chat_CreatePersonalChat_SC")
Cmd_Chat_CreatePersonalChat_SC.Definition = {
  "stPersonalChat",
  stPersonalChat = {
    0,
    0,
    CmdPersonalChatInitData,
    nil
  }
}
Cmd_Chat_DelPersonalChat_CS = sdp.SdpStruct("Cmd_Chat_DelPersonalChat_CS")
Cmd_Chat_DelPersonalChat_CS.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_DelPersonalChat_SC = sdp.SdpStruct("Cmd_Chat_DelPersonalChat_SC")
Cmd_Chat_DelPersonalChat_SC.Definition = {}
Cmd_Chat_ReadPersonalMsg_CS = sdp.SdpStruct("Cmd_Chat_ReadPersonalMsg_CS")
Cmd_Chat_ReadPersonalMsg_CS.Definition = {
  "iChatUid",
  "stRoleId",
  iChatUid = {
    0,
    0,
    8,
    0
  },
  stRoleId = {
    1,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Chat_ReadPersonalMsg_SC = sdp.SdpStruct("Cmd_Chat_ReadPersonalMsg_SC")
Cmd_Chat_ReadPersonalMsg_SC.Definition = {}
Cmd_Chat_GetShieldList_CS = sdp.SdpStruct("Cmd_Chat_GetShieldList_CS")
Cmd_Chat_GetShieldList_CS.Definition = {}
Cmd_Chat_GetShieldList_SC = sdp.SdpStruct("Cmd_Chat_GetShieldList_SC")
Cmd_Chat_GetShieldList_SC.Definition = {
  "vShieldRole",
  vShieldRole = {
    0,
    0,
    sdp.SdpVector(CmdFriendInfo),
    nil
  }
}
Cmd_Chat_GetLanguageInit_CS = sdp.SdpStruct("Cmd_Chat_GetLanguageInit_CS")
Cmd_Chat_GetLanguageInit_CS.Definition = {}
Cmd_Chat_GetLanguageInit_SC = sdp.SdpStruct("Cmd_Chat_GetLanguageInit_SC")
Cmd_Chat_GetLanguageInit_SC.Definition = {
  "iLanguageId",
  "iLangGroupId",
  "iLangEnterTime",
  iLanguageId = {
    0,
    0,
    8,
    0
  },
  iLangGroupId = {
    1,
    0,
    10,
    "0"
  },
  iLangEnterTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Chat_SwitchLanguage_CS = sdp.SdpStruct("Cmd_Chat_SwitchLanguage_CS")
Cmd_Chat_SwitchLanguage_CS.Definition = {
  "iLanguageId",
  "iLangGroupId",
  iLanguageId = {
    0,
    0,
    8,
    0
  },
  iLangGroupId = {
    1,
    0,
    10,
    "0"
  }
}
Cmd_Chat_SwitchLanguage_SC = sdp.SdpStruct("Cmd_Chat_SwitchLanguage_SC")
Cmd_Chat_SwitchLanguage_SC.Definition = {
  "iLanguageId",
  "iLangGroupId",
  "iLangEnterTime",
  iLanguageId = {
    0,
    0,
    8,
    0
  },
  iLangGroupId = {
    1,
    0,
    10,
    "0"
  },
  iLangEnterTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Chat_SetRefuseStranger_CS = sdp.SdpStruct("Cmd_Chat_SetRefuseStranger_CS")
Cmd_Chat_SetRefuseStranger_CS.Definition = {
  "bRefuseStranger",
  bRefuseStranger = {
    0,
    0,
    1,
    false
  }
}
Cmd_Chat_SetRefuseStranger_SC = sdp.SdpStruct("Cmd_Chat_SetRefuseStranger_SC")
Cmd_Chat_SetRefuseStranger_SC.Definition = {}
CmdChatLanguageGroup = sdp.SdpStruct("CmdChatLanguageGroup")
CmdChatLanguageGroup.Definition = {
  "iGroupId",
  "iRoleNum",
  iGroupId = {
    0,
    0,
    10,
    "0"
  },
  iRoleNum = {
    1,
    0,
    8,
    0
  }
}
CmdChatLanguage = sdp.SdpStruct("CmdChatLanguage")
CmdChatLanguage.Definition = {
  "iLanguageId",
  "vGroup",
  iLanguageId = {
    0,
    0,
    8,
    0
  },
  vGroup = {
    1,
    0,
    sdp.SdpVector(CmdChatLanguageGroup),
    nil
  }
}
Cmd_Chat_GetLanguageGroup_CS = sdp.SdpStruct("Cmd_Chat_GetLanguageGroup_CS")
Cmd_Chat_GetLanguageGroup_CS.Definition = {}
Cmd_Chat_GetLanguageGroup_SC = sdp.SdpStruct("Cmd_Chat_GetLanguageGroup_SC")
Cmd_Chat_GetLanguageGroup_SC.Definition = {
  "mLanguage",
  mLanguage = {
    0,
    0,
    sdp.SdpMap(8, CmdChatLanguage),
    nil
  }
}
Cmd_Chat_GetDirtyWords_CS = sdp.SdpStruct("Cmd_Chat_GetDirtyWords_CS")
Cmd_Chat_GetDirtyWords_CS.Definition = {}
Cmd_Chat_GetDirtyWords_SC = sdp.SdpStruct("Cmd_Chat_GetDirtyWords_SC")
Cmd_Chat_GetDirtyWords_SC.Definition = {
  "mDirtyWordChat",
  mDirtyWordChat = {
    0,
    0,
    sdp.SdpMap(13, 8),
    nil
  }
}
