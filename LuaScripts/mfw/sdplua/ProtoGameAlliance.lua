local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
module("MTTDProto")
CmdId_Alliance_GetInit_CS = 11501
CmdId_Alliance_GetInit_SC = 11502
CmdId_Alliance_GetRecommendList_CS = 11503
CmdId_Alliance_GetRecommendList_SC = 11504
CmdId_Alliance_GetDetail_CS = 11505
CmdId_Alliance_GetDetail_SC = 11506
CmdId_Alliance_Create_CS = 11507
CmdId_Alliance_Create_SC = 11508
CmdId_Alliance_Destroy_CS = 11509
CmdId_Alliance_Destroy_SC = 11510
CmdId_Alliance_Leave_CS = 11511
CmdId_Alliance_Leave_SC = 11512
CmdId_Alliance_Kick_CS = 11513
CmdId_Alliance_Kick_SC = 11514
CmdId_Alliance_ChangeName_CS = 11515
CmdId_Alliance_ChangeName_SC = 11516
CmdId_Alliance_ChangeBulletin_CS = 11517
CmdId_Alliance_ChangeBulletin_SC = 11518
CmdId_Alliance_ChangeRecruit_CS = 11519
CmdId_Alliance_ChangeRecruit_SC = 11520
CmdId_Alliance_ChangeSetting_CS = 11521
CmdId_Alliance_ChangeSetting_SC = 11522
CmdId_Alliance_Apply_CS = 11523
CmdId_Alliance_Apply_SC = 11524
CmdId_Alliance_GetRoleApplyList_CS = 11525
CmdId_Alliance_GetRoleApplyList_SC = 11526
CmdId_Alliance_CancelApply_CS = 11527
CmdId_Alliance_CancelApply_SC = 11528
CmdId_Alliance_GetApplyList_CS = 11529
CmdId_Alliance_GetApplyList_SC = 11530
CmdId_Alliance_OperateApply_CS = 11531
CmdId_Alliance_OperateApply_SC = 11532
CmdId_Alliance_RefuseAll_CS = 11533
CmdId_Alliance_RefuseAll_SC = 11534
CmdId_Alliance_Invite_CS = 11535
CmdId_Alliance_Invite_SC = 11536
CmdId_Alliance_GetInviteList_CS = 11537
CmdId_Alliance_GetInviteList_SC = 11538
CmdId_Alliance_RefuseAllBeInvite_CS = 11539
CmdId_Alliance_RefuseAllBeInvite_SC = 11540
CmdId_Alliance_ReplyInvite_CS = 11541
CmdId_Alliance_ReplyInvite_SC = 11542
CmdId_Alliance_Transfer_CS = 11543
CmdId_Alliance_Transfer_SC = 11544
CmdId_Alliance_ChangePost_CS = 11545
CmdId_Alliance_ChangePost_SC = 11546
CmdId_Alliance_AllianceHistory_CS = 11547
CmdId_Alliance_AllianceHistory_SC = 11548
CmdId_Alliance_Like_CS = 11549
CmdId_Alliance_Like_SC = 11550
CmdId_Alliance_Sign_CS = 11551
CmdId_Alliance_Sign_SC = 11552
CmdId_Alliance_Search_CS = 11553
CmdId_Alliance_Search_SC = 11554
CmdId_Alliance_SendMail_CS = 11555
CmdId_Alliance_SendMail_SC = 11556
CmdId_Alliance_Report_CS = 11557
CmdId_Alliance_Report_SC = 11558
CmdId_Alliance_CancelTransfer_CS = 11559
CmdId_Alliance_CancelTransfer_SC = 11560
CmdId_Alliance_Battle_GetBattleData_CS = 11600
CmdId_Alliance_Battle_GetBattleData_SC = 11601
CmdId_Alliance_Battle_GetBattleHistory_CS = 11606
CmdId_Alliance_Battle_GetBattleHistory_SC = 11607
CmdId_Alliance_Battle_GetRankList_CS = 11608
CmdId_Alliance_Battle_GetRankList_SC = 11609
AllianceJoinType_Review = 0
AllianceJoinType_All = 1
AllianceJoinType_None = 2
AllianceJoinTypeMax = AllianceJoinType_None + 1
AllianceSettingsType_Name = 1
AllianceSettingsType_Badge = 2
AllianceSettingsType_JoinType = 3
AllianceSettingsType_JoinLevel = 4
AllianceSettingsType_LanguageId = 5
AllianceSettingsType_Recruit = 6
AllianceSettingsType_Bulletin = 7
AllianceJoinLogType_Apply = 1
AllianceJoinLogType_Invite = 2
AllianceJoinLogType_NoLimit = 3
AlliancePost_Master = 1
AlliancePost_Vice = 2
AlliancePost_Member = 3
CmdAllianceHistoryType_Create = 1
CmdAllianceHistoryType_Transfer = 2
CmdAllianceHistoryType_PostToVice = 3
CmdAllianceHistoryType_PostToNormal = 4
CmdAllianceHistoryType_JoinAlliance = 5
CmdAllianceHistoryType_LeaveAlliance = 6
CmdAllianceHistoryType_KickAlliance = 7
CmdAllianceHistoryType_LevelUp = 8
CmdAllianceHistoryType_Like = 9
CmdAllianceHistoryType_AutoTransfer = 99
AllianceReportType_Name = 1
AllianceReportType_Bulletin = 2
AllianceBattleStatus_None = 0
AllianceBattleStatus_Battle = 1
AllianceBattleStatus_Settle = 2
Cmd_Alliance_GetInit_CS = sdp.SdpStruct("Cmd_Alliance_GetInit_CS")
Cmd_Alliance_GetInit_CS.Definition = {}
Cmd_Alliance_GetInit_SC = sdp.SdpStruct("Cmd_Alliance_GetInit_SC")
Cmd_Alliance_GetInit_SC.Definition = {
  "iAllianceId",
  "vAllianceApplyList",
  "iJoinAllianceCount",
  "iLastLeaveAllianceTime",
  "bHaveInvite",
  "iLikeTimes",
  "vLikedOther",
  "iSignNum",
  "iSignTime",
  "iBattleTimes",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  vAllianceApplyList = {
    1,
    0,
    sdp.SdpVector(10),
    nil
  },
  iJoinAllianceCount = {
    2,
    0,
    8,
    0
  },
  iLastLeaveAllianceTime = {
    3,
    0,
    8,
    0
  },
  bHaveInvite = {
    4,
    0,
    1,
    false
  },
  iLikeTimes = {
    5,
    0,
    8,
    0
  },
  vLikedOther = {
    6,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  },
  iSignNum = {
    7,
    0,
    8,
    0
  },
  iSignTime = {
    8,
    0,
    8,
    0
  },
  iBattleTimes = {
    9,
    0,
    8,
    0
  }
}
Cmd_Alliance_GetRecommendList_CS = sdp.SdpStruct("Cmd_Alliance_GetRecommendList_CS")
Cmd_Alliance_GetRecommendList_CS.Definition = {
  "iLanguageId",
  iLanguageId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Alliance_GetRecommendList_SC = sdp.SdpStruct("Cmd_Alliance_GetRecommendList_SC")
Cmd_Alliance_GetRecommendList_SC.Definition = {
  "vAllianceBriefData",
  vAllianceBriefData = {
    0,
    0,
    sdp.SdpVector(CmdAllianceBriefData),
    nil
  }
}
CmdAllianceBattleHeroRecord = sdp.SdpStruct("CmdAllianceBattleHeroRecord")
CmdAllianceBattleHeroRecord.Definition = {
  "iHeroId",
  "iLevel",
  "iFashion",
  iHeroId = {
    0,
    0,
    8,
    0
  },
  iLevel = {
    1,
    0,
    8,
    0
  },
  iFashion = {
    2,
    0,
    8,
    0
  }
}
CmdAllianceBattleHistory = sdp.SdpStruct("CmdAllianceBattleHistory")
CmdAllianceBattleHistory.Definition = {
  "iTime",
  "stRoleId",
  "sName",
  "iBossId",
  "iRound",
  "iRealDamage",
  "bKill",
  "iDamage",
  "vHero",
  iTime = {
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
  },
  sName = {
    2,
    0,
    13,
    ""
  },
  iBossId = {
    3,
    0,
    8,
    0
  },
  iRound = {
    4,
    0,
    8,
    0
  },
  iRealDamage = {
    5,
    0,
    10,
    "0"
  },
  bKill = {
    6,
    0,
    1,
    false
  },
  iDamage = {
    7,
    0,
    10,
    "0"
  },
  vHero = {
    8,
    0,
    sdp.SdpVector(CmdAllianceBattleHeroRecord),
    nil
  }
}
CmdAllianceBoss = sdp.SdpStruct("CmdAllianceBoss")
CmdAllianceBoss.Definition = {
  "iBossId",
  "iLastTime",
  "iBossHp",
  "bKill",
  "stLastRole",
  iBossId = {
    0,
    0,
    8,
    0
  },
  iLastTime = {
    1,
    0,
    8,
    0
  },
  iBossHp = {
    2,
    0,
    10,
    "0"
  },
  bKill = {
    3,
    0,
    1,
    false
  },
  stLastRole = {
    4,
    0,
    PlayerIDType,
    nil
  }
}
CmdAllianceBattleData = sdp.SdpStruct("CmdAllianceBattleData")
CmdAllianceBattleData.Definition = {
  "iActivityId",
  "iBattleId",
  "iCurRound",
  "mBoss",
  "iTotalDamage",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBattleId = {
    1,
    0,
    8,
    0
  },
  iCurRound = {
    2,
    0,
    8,
    0
  },
  mBoss = {
    3,
    0,
    sdp.SdpMap(8, CmdAllianceBoss),
    nil
  },
  iTotalDamage = {
    4,
    0,
    10,
    "0"
  }
}
CmdAllianceData = sdp.SdpStruct("CmdAllianceData")
CmdAllianceData.Definition = {
  "stBriefData",
  "sBulletin",
  "vMember",
  "bHaveNewApply",
  "iCurrDevelopment",
  "iTransferEffectTime",
  "stNewTransferMaster",
  stBriefData = {
    0,
    0,
    CmdAllianceBriefData,
    nil
  },
  sBulletin = {
    1,
    0,
    13,
    ""
  },
  vMember = {
    2,
    0,
    sdp.SdpVector(CmdAllianceMemberData),
    nil
  },
  bHaveNewApply = {
    3,
    0,
    1,
    false
  },
  iCurrDevelopment = {
    4,
    0,
    8,
    0
  },
  iTransferEffectTime = {
    5,
    0,
    8,
    0
  },
  stNewTransferMaster = {
    6,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Alliance_GetDetail_CS = sdp.SdpStruct("Cmd_Alliance_GetDetail_CS")
Cmd_Alliance_GetDetail_CS.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Alliance_GetDetail_SC = sdp.SdpStruct("Cmd_Alliance_GetDetail_SC")
Cmd_Alliance_GetDetail_SC.Definition = {
  "stAllianceData",
  stAllianceData = {
    0,
    0,
    CmdAllianceData,
    nil
  }
}
Cmd_Alliance_Create_CS = sdp.SdpStruct("Cmd_Alliance_Create_CS")
Cmd_Alliance_Create_CS.Definition = {
  "sAllianceName",
  "iBadgeId",
  "iJoinType",
  "iJoinLevel",
  sAllianceName = {
    0,
    0,
    13,
    ""
  },
  iBadgeId = {
    1,
    0,
    8,
    0
  },
  iJoinType = {
    2,
    0,
    8,
    0
  },
  iJoinLevel = {
    3,
    0,
    8,
    0
  }
}
Cmd_Alliance_Create_SC = sdp.SdpStruct("Cmd_Alliance_Create_SC")
Cmd_Alliance_Create_SC.Definition = {
  "iAllianceId",
  "stAllianceData",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  stAllianceData = {
    1,
    0,
    CmdAllianceData,
    nil
  }
}
Cmd_Alliance_Destroy_CS = sdp.SdpStruct("Cmd_Alliance_Destroy_CS")
Cmd_Alliance_Destroy_CS.Definition = {}
Cmd_Alliance_Destroy_SC = sdp.SdpStruct("Cmd_Alliance_Destroy_SC")
Cmd_Alliance_Destroy_SC.Definition = {}
Cmd_Alliance_Leave_CS = sdp.SdpStruct("Cmd_Alliance_Leave_CS")
Cmd_Alliance_Leave_CS.Definition = {}
Cmd_Alliance_Leave_SC = sdp.SdpStruct("Cmd_Alliance_Leave_SC")
Cmd_Alliance_Leave_SC.Definition = {}
Cmd_Alliance_Kick_CS = sdp.SdpStruct("Cmd_Alliance_Kick_CS")
Cmd_Alliance_Kick_CS.Definition = {
  "iBeKickUid",
  "iBeKickZoneId",
  iBeKickUid = {
    0,
    0,
    10,
    "0"
  },
  iBeKickZoneId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Alliance_Kick_SC = sdp.SdpStruct("Cmd_Alliance_Kick_SC")
Cmd_Alliance_Kick_SC.Definition = {}
Cmd_Alliance_ChangePost_CS = sdp.SdpStruct("Cmd_Alliance_ChangePost_CS")
Cmd_Alliance_ChangePost_CS.Definition = {
  "iUid",
  "iPost",
  "iZoneId",
  iUid = {
    0,
    0,
    10,
    "0"
  },
  iPost = {
    1,
    0,
    8,
    0
  },
  iZoneId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Alliance_ChangePost_SC = sdp.SdpStruct("Cmd_Alliance_ChangePost_SC")
Cmd_Alliance_ChangePost_SC.Definition = {}
Cmd_Alliance_ChangeName_CS = sdp.SdpStruct("Cmd_Alliance_ChangeName_CS")
Cmd_Alliance_ChangeName_CS.Definition = {
  "sName",
  sName = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Alliance_ChangeName_SC = sdp.SdpStruct("Cmd_Alliance_ChangeName_SC")
Cmd_Alliance_ChangeName_SC.Definition = {}
Cmd_Alliance_ChangeBulletin_CS = sdp.SdpStruct("Cmd_Alliance_ChangeBulletin_CS")
Cmd_Alliance_ChangeBulletin_CS.Definition = {
  "sBulletin",
  sBulletin = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Alliance_ChangeBulletin_SC = sdp.SdpStruct("Cmd_Alliance_ChangeBulletin_SC")
Cmd_Alliance_ChangeBulletin_SC.Definition = {}
Cmd_Alliance_ChangeRecruit_CS = sdp.SdpStruct("Cmd_Alliance_ChangeRecruit_CS")
Cmd_Alliance_ChangeRecruit_CS.Definition = {
  "sRecruit",
  sRecruit = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Alliance_ChangeRecruit_SC = sdp.SdpStruct("Cmd_Alliance_ChangeRecruit_SC")
Cmd_Alliance_ChangeRecruit_SC.Definition = {}
Cmd_Alliance_ChangeSetting_CS = sdp.SdpStruct("Cmd_Alliance_ChangeSetting_CS")
Cmd_Alliance_ChangeSetting_CS.Definition = {
  "vChangeSettingsType",
  "iBadgeId",
  "iLanguageId",
  "iJoinType",
  "iJoinLevel",
  vChangeSettingsType = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  },
  iBadgeId = {
    1,
    0,
    8,
    0
  },
  iLanguageId = {
    2,
    0,
    8,
    0
  },
  iJoinType = {
    3,
    0,
    8,
    0
  },
  iJoinLevel = {
    4,
    0,
    8,
    0
  }
}
Cmd_Alliance_ChangeSetting_SC = sdp.SdpStruct("Cmd_Alliance_ChangeSetting_SC")
Cmd_Alliance_ChangeSetting_SC.Definition = {}
Cmd_Alliance_RefuseAll_CS = sdp.SdpStruct("Cmd_Alliance_RefuseAll_CS")
Cmd_Alliance_RefuseAll_CS.Definition = {}
Cmd_Alliance_RefuseAll_SC = sdp.SdpStruct("Cmd_Alliance_RefuseAll_SC")
Cmd_Alliance_RefuseAll_SC.Definition = {}
Cmd_Alliance_GetApplyList_CS = sdp.SdpStruct("Cmd_Alliance_GetApplyList_CS")
Cmd_Alliance_GetApplyList_CS.Definition = {}
Cmd_Alliance_GetApplyList_SC = sdp.SdpStruct("Cmd_Alliance_GetApplyList_SC")
Cmd_Alliance_GetApplyList_SC.Definition = {
  "vApplyList",
  vApplyList = {
    0,
    0,
    sdp.SdpVector(CmdAllianceApplyerData),
    nil
  }
}
Cmd_Alliance_CancelApply_CS = sdp.SdpStruct("Cmd_Alliance_CancelApply_CS")
Cmd_Alliance_CancelApply_CS.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Alliance_CancelApply_SC = sdp.SdpStruct("Cmd_Alliance_CancelApply_SC")
Cmd_Alliance_CancelApply_SC.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Alliance_OperateApply_CS = sdp.SdpStruct("Cmd_Alliance_OperateApply_CS")
Cmd_Alliance_OperateApply_CS.Definition = {
  "iOperUid",
  "bAccept",
  "iOperZoneId",
  iOperUid = {
    0,
    0,
    10,
    "0"
  },
  bAccept = {
    1,
    0,
    1,
    false
  },
  iOperZoneId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Alliance_OperateApply_SC = sdp.SdpStruct("Cmd_Alliance_OperateApply_SC")
Cmd_Alliance_OperateApply_SC.Definition = {}
Cmd_Alliance_Apply_CS = sdp.SdpStruct("Cmd_Alliance_Apply_CS")
Cmd_Alliance_Apply_CS.Definition = {
  "iAllianceId",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Alliance_Apply_SC = sdp.SdpStruct("Cmd_Alliance_Apply_SC")
Cmd_Alliance_Apply_SC.Definition = {
  "iAllianceId",
  "iJoinType",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  iJoinType = {
    1,
    0,
    8,
    0
  }
}
Cmd_Alliance_GetRoleApplyList_CS = sdp.SdpStruct("Cmd_Alliance_GetRoleApplyList_CS")
Cmd_Alliance_GetRoleApplyList_CS.Definition = {}
Cmd_Alliance_GetRoleApplyList_SC = sdp.SdpStruct("Cmd_Alliance_GetRoleApplyList_SC")
Cmd_Alliance_GetRoleApplyList_SC.Definition = {
  "vAllianceId",
  vAllianceId = {
    0,
    0,
    sdp.SdpVector(10),
    nil
  }
}
Cmd_Alliance_Transfer_CS = sdp.SdpStruct("Cmd_Alliance_Transfer_CS")
Cmd_Alliance_Transfer_CS.Definition = {
  "iUid",
  "iZoneId",
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
  }
}
Cmd_Alliance_Transfer_SC = sdp.SdpStruct("Cmd_Alliance_Transfer_SC")
Cmd_Alliance_Transfer_SC.Definition = {
  "iTransferEffectTime",
  "stNewTransferMaster",
  iTransferEffectTime = {
    1,
    0,
    8,
    0
  },
  stNewTransferMaster = {
    2,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Alliance_CancelTransfer_CS = sdp.SdpStruct("Cmd_Alliance_CancelTransfer_CS")
Cmd_Alliance_CancelTransfer_CS.Definition = {}
Cmd_Alliance_CancelTransfer_SC = sdp.SdpStruct("Cmd_Alliance_CancelTransfer_SC")
Cmd_Alliance_CancelTransfer_SC.Definition = {
  "iTransferEffectTime",
  iTransferEffectTime = {
    0,
    0,
    8,
    0
  }
}
Cmd_Alliance_ReplyInvite_CS = sdp.SdpStruct("Cmd_Alliance_ReplyInvite_CS")
Cmd_Alliance_ReplyInvite_CS.Definition = {
  "iAllianceId",
  "bAccept",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  bAccept = {
    1,
    0,
    1,
    false
  }
}
Cmd_Alliance_ReplyInvite_SC = sdp.SdpStruct("Cmd_Alliance_ReplyInvite_SC")
Cmd_Alliance_ReplyInvite_SC.Definition = {
  "iAllianceId",
  "bAccept",
  iAllianceId = {
    0,
    0,
    10,
    "0"
  },
  bAccept = {
    1,
    0,
    1,
    false
  }
}
Cmd_Alliance_Invite_CS = sdp.SdpStruct("Cmd_Alliance_Invite_CS")
Cmd_Alliance_Invite_CS.Definition = {
  "stRoleId",
  stRoleId = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Alliance_Invite_SC = sdp.SdpStruct("Cmd_Alliance_Invite_SC")
Cmd_Alliance_Invite_SC.Definition = {
  "iRet",
  iRet = {
    0,
    0,
    7,
    0
  }
}
Cmd_Alliance_GetInviteList_CS = sdp.SdpStruct("Cmd_Alliance_GetInviteList_CS")
Cmd_Alliance_GetInviteList_CS.Definition = {}
Cmd_Alliance_GetInviteList_SC = sdp.SdpStruct("Cmd_Alliance_GetInviteList_SC")
Cmd_Alliance_GetInviteList_SC.Definition = {
  "vList",
  vList = {
    0,
    0,
    sdp.SdpVector(CmdAllianceInviteInfo),
    nil
  }
}
Cmd_Alliance_RefuseAllBeInvite_CS = sdp.SdpStruct("Cmd_Alliance_RefuseAllBeInvite_CS")
Cmd_Alliance_RefuseAllBeInvite_CS.Definition = {}
Cmd_Alliance_RefuseAllBeInvite_SC = sdp.SdpStruct("Cmd_Alliance_RefuseAllBeInvite_SC")
Cmd_Alliance_RefuseAllBeInvite_SC.Definition = {}
CmdAllianceHistory = sdp.SdpStruct("CmdAllianceHistory")
CmdAllianceHistory.Definition = {
  "iType",
  "iTime",
  "stOperator",
  "stMember",
  "sOperatorName",
  "sMemberName",
  "iLevel",
  "mParam",
  iType = {
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
  stOperator = {
    2,
    0,
    PlayerIDType,
    nil
  },
  stMember = {
    3,
    0,
    PlayerIDType,
    nil
  },
  sOperatorName = {
    4,
    0,
    13,
    ""
  },
  sMemberName = {
    5,
    0,
    13,
    ""
  },
  iLevel = {
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
  }
}
Cmd_Alliance_AllianceHistory_CS = sdp.SdpStruct("Cmd_Alliance_AllianceHistory_CS")
Cmd_Alliance_AllianceHistory_CS.Definition = {}
Cmd_Alliance_AllianceHistory_SC = sdp.SdpStruct("Cmd_Alliance_AllianceHistory_SC")
Cmd_Alliance_AllianceHistory_SC.Definition = {
  "vHistory",
  vHistory = {
    0,
    0,
    sdp.SdpVector(CmdAllianceHistory),
    nil
  }
}
Cmd_Alliance_Like_CS = sdp.SdpStruct("Cmd_Alliance_Like_CS")
Cmd_Alliance_Like_CS.Definition = {
  "stOther",
  stOther = {
    0,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Alliance_Like_SC = sdp.SdpStruct("Cmd_Alliance_Like_SC")
Cmd_Alliance_Like_SC.Definition = {
  "iLikeTimes",
  "vReward",
  "stOther",
  iLikeTimes = {
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
  stOther = {
    2,
    0,
    PlayerIDType,
    nil
  }
}
Cmd_Alliance_Sign_CS = sdp.SdpStruct("Cmd_Alliance_Sign_CS")
Cmd_Alliance_Sign_CS.Definition = {}
Cmd_Alliance_Sign_SC = sdp.SdpStruct("Cmd_Alliance_Sign_SC")
Cmd_Alliance_Sign_SC.Definition = {
  "vReward",
  "iSignNum",
  "iSignTime",
  vReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iSignNum = {
    1,
    0,
    8,
    0
  },
  iSignTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Alliance_Report_CS = sdp.SdpStruct("Cmd_Alliance_Report_CS")
Cmd_Alliance_Report_CS.Definition = {
  "iAllianceReportType",
  "sReason",
  "iAllianceId",
  "iReportReasonType",
  iAllianceReportType = {
    0,
    0,
    8,
    0
  },
  sReason = {
    1,
    0,
    13,
    ""
  },
  iAllianceId = {
    2,
    0,
    10,
    "0"
  },
  iReportReasonType = {
    3,
    0,
    8,
    0
  }
}
Cmd_Alliance_Report_SC = sdp.SdpStruct("Cmd_Alliance_Report_SC")
Cmd_Alliance_Report_SC.Definition = {}
Cmd_Alliance_SendMail_CS = sdp.SdpStruct("Cmd_Alliance_SendMail_CS")
Cmd_Alliance_SendMail_CS.Definition = {
  "sContent",
  sContent = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Alliance_SendMail_SC = sdp.SdpStruct("Cmd_Alliance_SendMail_SC")
Cmd_Alliance_SendMail_SC.Definition = {}
Cmd_Alliance_Search_CS = sdp.SdpStruct("Cmd_Alliance_Search_CS")
Cmd_Alliance_Search_CS.Definition = {
  "sInput",
  "iLanguageId",
  "iPage",
  "iPagePerNum",
  sInput = {
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
  iPage = {
    2,
    0,
    8,
    0
  },
  iPagePerNum = {
    3,
    0,
    8,
    0
  }
}
Cmd_Alliance_Search_SC = sdp.SdpStruct("Cmd_Alliance_Search_SC")
Cmd_Alliance_Search_SC.Definition = {
  "vAllianceBriefData",
  "iPage",
  "iTotal",
  vAllianceBriefData = {
    0,
    0,
    sdp.SdpVector(CmdAllianceBriefData),
    nil
  },
  iPage = {
    1,
    0,
    8,
    0
  },
  iTotal = {
    2,
    0,
    8,
    0
  }
}
Cmd_Alliance_Battle_GetBattleData_CS = sdp.SdpStruct("Cmd_Alliance_Battle_GetBattleData_CS")
Cmd_Alliance_Battle_GetBattleData_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Alliance_Battle_GetBattleData_SC = sdp.SdpStruct("Cmd_Alliance_Battle_GetBattleData_SC")
Cmd_Alliance_Battle_GetBattleData_SC.Definition = {
  "iActivityId",
  "stBattle",
  "iChallengeTimes",
  "vFightHero",
  "iMyRank",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  stBattle = {
    1,
    0,
    CmdAllianceBattleData,
    nil
  },
  iChallengeTimes = {
    2,
    0,
    8,
    0
  },
  vFightHero = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  iMyRank = {
    4,
    0,
    8,
    0
  }
}
Cmd_Alliance_Battle_GetBattleHistory_CS = sdp.SdpStruct("Cmd_Alliance_Battle_GetBattleHistory_CS")
Cmd_Alliance_Battle_GetBattleHistory_CS.Definition = {
  "iActivityId",
  "iBeginTime",
  "iEndTime",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBeginTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Alliance_Battle_GetBattleHistory_SC = sdp.SdpStruct("Cmd_Alliance_Battle_GetBattleHistory_SC")
Cmd_Alliance_Battle_GetBattleHistory_SC.Definition = {
  "iActivityId",
  "iBeginTime",
  "iEndTime",
  "vHistory",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBeginTime = {
    1,
    0,
    8,
    0
  },
  iEndTime = {
    2,
    0,
    8,
    0
  },
  vHistory = {
    3,
    0,
    sdp.SdpVector(CmdAllianceBattleHistory),
    nil
  }
}
CmdAllianceBattleRankItem = sdp.SdpStruct("CmdAllianceBattleRankItem")
CmdAllianceBattleRankItem.Definition = {
  "stBriefInfo",
  "iRank",
  "iScore",
  stBriefInfo = {
    0,
    0,
    CmdAllianceBriefData,
    nil
  },
  iRank = {
    1,
    0,
    8,
    0
  },
  iScore = {
    2,
    0,
    10,
    "0"
  }
}
Cmd_Alliance_Battle_GetRankList_CS = sdp.SdpStruct("Cmd_Alliance_Battle_GetRankList_CS")
Cmd_Alliance_Battle_GetRankList_CS.Definition = {
  "iActivityId",
  "iBeginRank",
  "iEndRank",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iBeginRank = {
    1,
    0,
    8,
    0
  },
  iEndRank = {
    2,
    0,
    8,
    0
  }
}
Cmd_Alliance_Battle_GetRankList_SC = sdp.SdpStruct("Cmd_Alliance_Battle_GetRankList_SC")
Cmd_Alliance_Battle_GetRankList_SC.Definition = {
  "iActivityId",
  "vRankList",
  "iMyRank",
  "iMyScore",
  "iRankSize",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  vRankList = {
    1,
    0,
    sdp.SdpVector(CmdAllianceBattleRankItem),
    nil
  },
  iMyRank = {
    2,
    0,
    8,
    0
  },
  iMyScore = {
    3,
    0,
    10,
    "0"
  },
  iRankSize = {
    4,
    0,
    8,
    0
  }
}
