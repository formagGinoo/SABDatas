local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoLogin")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Role_Init_CS = 10101
CmdId_Role_Init_SC = 10102
CmdId_Role_BindAccount_CS = 10103
CmdId_Role_BindAccount_SC = 10104
CmdId_Role_ServerTime_CS = 10105
CmdId_Role_ServerTime_SC = 10106
CmdId_Role_SetHead_CS = 10107
CmdId_Role_SetHead_SC = 10108
CmdId_Role_RandomName_CS = 10109
CmdId_Role_RandomName_SC = 10110
CmdId_Role_SetName_CS = 10111
CmdId_Role_SetName_SC = 10112
CmdId_Role_SetHeadFrame_CS = 10113
CmdId_Role_SetHeadFrame_SC = 10114
CmdId_Role_UpdateBindAccount_CS = 10115
CmdId_Role_UpdateBindAccount_SC = 10116
CmdId_Role_GetBindAccount_CS = 10117
CmdId_Role_GetBindAccount_SC = 10118
CmdId_Role_SeeOther_CS = 10119
CmdId_Role_SeeOther_SC = 10120
CmdId_Role_UpdateDeviceToken_CS = 10121
CmdId_Role_UpdateDeviceToken_SC = 10122
CmdId_Role_GetNotice_CS = 10123
CmdId_Role_GetNotice_SC = 10124
CmdId_Role_ReportPushClick_CS = 10125
CmdId_Role_ReportPushClick_SC = 10126
CmdId_Role_ExchangeCDKey_CS = 10127
CmdId_Role_ExchangeCDKey_SC = 10128
CmdId_Role_UnbindAccount_CS = 10129
CmdId_Role_UnbindAccount_SC = 10130
CmdId_Role_SetShowBackground_CS = 10131
CmdId_Role_SetShowBackground_SC = 10132
CmdId_Role_GetZoneList_CS = 10133
CmdId_Role_GetZoneList_SC = 10134
CmdId_Role_SetCard_CS = 10135
CmdId_Role_SetCard_SC = 10136
CmdId_Role_SetPushOption_CS = 10137
CmdId_Role_SetPushOption_SC = 10138
CmdId_Role_DisplayVip_CS = 10139
CmdId_Role_DisplayVip_SC = 10140
CmdId_Role_GetOtherProgress_CS = 10141
CmdId_Role_GetOtherProgress_SC = 10142
CmdId_Role_GetFBFace_CS = 10143
CmdId_Role_GetFBFace_SC = 10144
CmdId_Role_GetUserToken_CS = 10145
CmdId_Role_GetUserToken_SC = 10146
CmdId_Role_CheckSwitchZone_CS = 10147
CmdId_Role_CheckSwitchZone_SC = 10148
CmdId_Role_SurveyUrl_CS = 10149
CmdId_Role_SurveyUrl_SC = 10150
CmdId_Role_SetAcceptRequestFriend_CS = 10151
CmdId_Role_SetAcceptRequestFriend_SC = 10152
CmdId_Role_ReportFace_CS = 10153
CmdId_Role_ReportFace_SC = 10154
CmdId_Role_GetLuaRepair_CS = 10155
CmdId_Role_GetLuaRepair_SC = 10156
CmdId_Role_ReadElvaMessage_CS = 10157
CmdId_Role_ReadElvaMessage_SC = 10158
CmdId_Role_DisplayGender_CS = 10159
CmdId_Role_DisplayGender_SC = 10160
CmdId_Role_SetMainBackground_CS = 10161
CmdId_Role_SetMainBackground_SC = 10162
CmdId_Role_SetMainBackgroundIndex_CS = 10163
CmdId_Role_SetMainBackgroundIndex_SC = 10164
CmdId_Role_SetSignature_CS = 10165
CmdId_Role_SetSignature_SC = 10166
CmdId_Role_PushNoticeSelect_CS = 10169
CmdId_Role_PushNoticeSelect_SC = 10170
CmdId_Role_Report_CS = 10171
CmdId_Role_Report_SC = 10172
CmdId_Role_GetSurveyToken_CS = 10181
CmdId_Role_GetSurveyToken_SC = 10182
CmdId_Role_SeeBusinessCard_CS = 10185
CmdId_Role_SeeBusinessCard_SC = 10186
CmdId_Role_SetBirthDay_CS = 10187
CmdId_Role_SetBirthDay_SC = 10188
CmdId_Role_SetGender_CS = 10189
CmdId_Role_SetGender_SC = 10190
CmdId_Role_GetRoleInfoBatch_CS = 10191
CmdId_Role_GetRoleInfoBatch_SC = 10192
CmdId_Role_UploadFBFaceId_CS = 10193
CmdId_Role_UploadFBFaceId_SC = 10194
CmdId_Role_SetCountryId_CS = 10195
CmdId_Role_SetCountryId_SC = 10196
CmdId_Role_GetCirculation_CS = 10197
CmdId_Role_GetCirculation_SC = 10198
CmdId_Role_UpgradeCirculation_CS = 10199
CmdId_Role_UpgradeCirculation_SC = 10200
OSType_IOS = 1
OSType_Android = 2
OSType_Win = 3
AccountType_IosDevice = 1
AccountType_AndroidDevice = 2
AccountType_MSdk = 3
AccountType_GSDK = 4
AccountType_QuickSDK = 5
AccountType_DMM = 6
AccountType_WeGame = 7
AccountChannelGroupType_General = 1
AccountChannelGroupType_Other = 6
EnumDebugFlag_ShowDebug = 1
RepairStrType_Language = 1
RepairStrType_Template = 2
MainBackgroundType_Empty = 0
MainBackgroundType_Hero = 1
MainBackgroundType_Item = 2
MainBackgroundType_Fashion = 3
EnumLanguage_En = 0
EnumLanguage_Cn = 1
NoticeType_AllDialog = 1
NoticeType_MainDialog = 2
FaceType_System = 0
FaceType_Facebook = 2
FaceType_WeChat = 3
RolePushNoticeType_Level = 0
RolePushNoticeType_Mail_BeAttack = RolePushNoticeType_Level + 1
RolePushNoticeType_Mail_Arena = RolePushNoticeType_Mail_BeAttack + 1
RolePushNoticeType_PushSet = RolePushNoticeType_Mail_Arena + 1
ReportMessageType_RoleName = 6
ReportMessageType_AllianceName = 7
ReportMessageType_Profile = 10
ReportMessageType_Unknow = ReportMessageType_Profile + 1
ReportReasonType_RoleNameIllegal = 1
ReportReasonType_DataAbnormal = 2
ReportReasonType_RoleSignatureIllegal = 3
ReportReasonType_Other = ReportReasonType_RoleSignatureIllegal + 1
UserTokenType_Web = 1
CmdServerConfigData = sdp.SdpStruct("CmdServerConfigData")
CmdServerConfigData.Definition = {
  "iServerTimeMS",
  "bVerifyStageCheckLog",
  "iTimeGmtOff",
  "iNextFreshTime",
  iServerTimeMS = {
    0,
    0,
    10,
    "0"
  },
  bVerifyStageCheckLog = {
    1,
    0,
    1,
    false
  },
  iTimeGmtOff = {
    2,
    0,
    9,
    "0"
  },
  iNextFreshTime = {
    3,
    0,
    8,
    0
  }
}
Cmd_Role_Init_CS = sdp.SdpStruct("Cmd_Role_Init_CS")
Cmd_Role_Init_CS.Definition = {
  "sChannel",
  "sDevice",
  "sLuaCommMD5",
  "iOSType",
  "iAccType",
  "sAccount",
  "sOperator",
  "sNetType",
  "sOSLanguage",
  "sClientVersion",
  "iLanguageId",
  "sUserIp",
  "sIDFA",
  "sCokUid",
  "sDeviceId",
  "sGAID",
  "sCertificateSha1",
  "sCertificateSubject",
  "sPackageId",
  "sOSCountry",
  "iThirdRealNameAuth",
  "iClientCpuHz",
  "iClientMemory",
  "sClientOsVersion",
  "sInitFBName",
  "sInitFBFaceId",
  "sState",
  "bInWhiteList",
  "bSimulator",
  "sSimulatorUid",
  "sSimulatorBrand",
  "bWholePackage",
  "sOaId",
  "sDrmId",
  "sAndroidId",
  "sIDFV",
  "sAreaId",
  "sTagId",
  sChannel = {
    0,
    0,
    13,
    ""
  },
  sDevice = {
    1,
    0,
    13,
    ""
  },
  sLuaCommMD5 = {
    2,
    0,
    13,
    ""
  },
  iOSType = {
    3,
    0,
    8,
    0
  },
  iAccType = {
    4,
    0,
    8,
    0
  },
  sAccount = {
    5,
    0,
    13,
    ""
  },
  sOperator = {
    6,
    0,
    13,
    ""
  },
  sNetType = {
    7,
    0,
    13,
    ""
  },
  sOSLanguage = {
    8,
    0,
    13,
    ""
  },
  sClientVersion = {
    9,
    0,
    13,
    ""
  },
  iLanguageId = {
    10,
    0,
    8,
    0
  },
  sUserIp = {
    11,
    0,
    13,
    ""
  },
  sIDFA = {
    12,
    0,
    13,
    ""
  },
  sCokUid = {
    13,
    0,
    13,
    ""
  },
  sDeviceId = {
    14,
    0,
    13,
    ""
  },
  sGAID = {
    15,
    0,
    13,
    ""
  },
  sCertificateSha1 = {
    16,
    0,
    13,
    ""
  },
  sCertificateSubject = {
    17,
    0,
    13,
    ""
  },
  sPackageId = {
    18,
    0,
    13,
    ""
  },
  sOSCountry = {
    19,
    0,
    13,
    ""
  },
  iThirdRealNameAuth = {
    20,
    0,
    8,
    0
  },
  iClientCpuHz = {
    21,
    0,
    8,
    0
  },
  iClientMemory = {
    22,
    0,
    8,
    0
  },
  sClientOsVersion = {
    23,
    0,
    13,
    ""
  },
  sInitFBName = {
    24,
    0,
    13,
    ""
  },
  sInitFBFaceId = {
    25,
    0,
    13,
    ""
  },
  sState = {
    26,
    0,
    13,
    ""
  },
  bInWhiteList = {
    27,
    0,
    1,
    false
  },
  bSimulator = {
    28,
    0,
    1,
    false
  },
  sSimulatorUid = {
    29,
    0,
    13,
    ""
  },
  sSimulatorBrand = {
    30,
    0,
    13,
    ""
  },
  bWholePackage = {
    31,
    0,
    1,
    false
  },
  sOaId = {
    32,
    0,
    13,
    ""
  },
  sDrmId = {
    33,
    0,
    13,
    ""
  },
  sAndroidId = {
    37,
    0,
    13,
    ""
  },
  sIDFV = {
    38,
    0,
    13,
    ""
  },
  sAreaId = {
    39,
    0,
    13,
    ""
  },
  sTagId = {
    40,
    0,
    13,
    ""
  }
}
CmdRepairStr = sdp.SdpStruct("CmdRepairStr")
CmdRepairStr.Definition = {
  "iRepairType",
  "sTableName",
  "sKey1",
  "sValue1",
  "sKey2",
  "sValue2",
  "sItemKey",
  "sItemValue",
  iRepairType = {
    0,
    0,
    8,
    0
  },
  sTableName = {
    1,
    0,
    13,
    ""
  },
  sKey1 = {
    2,
    0,
    13,
    ""
  },
  sValue1 = {
    3,
    0,
    13,
    ""
  },
  sKey2 = {
    4,
    0,
    13,
    ""
  },
  sValue2 = {
    5,
    0,
    13,
    ""
  },
  sItemKey = {
    6,
    0,
    13,
    ""
  },
  sItemValue = {
    7,
    0,
    13,
    ""
  }
}
CmdMainBackground = sdp.SdpStruct("CmdMainBackground")
CmdMainBackground.Definition = {
  "iType",
  "iId",
  iType = {
    0,
    0,
    8,
    0
  },
  iId = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_Init_SC = sdp.SdpStruct("Cmd_Role_Init_SC")
Cmd_Role_Init_SC.Definition = {
  "iUid",
  "sName",
  "iLevel",
  "iDebugFlag",
  "iArenaCoin",
  "iLastArenaBeAttacked",
  "iAllianceId",
  "iJoinAllianceTime",
  "iAllianceLevel",
  "sAllianceName",
  "iVipLevel",
  "iVipExp",
  "iCountryId",
  "stServerConfigData",
  "bLuaCommMD5Mismatch",
  "iLastSetNameTime",
  "bDisplayVip",
  "iPublishTime",
  "iRoleRegTime",
  "iLastLoginTime",
  "iThisLoginTime",
  "iTotalRecharge",
  "iTotalRechargeDiamond",
  "mPushOption",
  "vRepairStr",
  "bOnlyCanRecharge",
  "sFacePath",
  "mLuaCodeRepair",
  "bNewRole",
  "mSpecialItem",
  "iGender",
  "iBirthMonth",
  "iBirthDay",
  "bHasEvlaMessage",
  "bDisplayGender",
  "bClaimedBindAccountReward",
  "bHasSetRoleName",
  "iNextWatchAdTime",
  "bHasWelfare",
  "bArenaAwardRed",
  "sFBFaceId",
  "iSetCountryTime",
  "iTotalVipLevel",
  "iFreeVipExp",
  "iTotalLoginDays",
  "iTodayRechargeNum",
  "sCreateRoleCountry",
  "iDeepLinkType",
  "iGroupId",
  "iDistrictId",
  "bTestServer",
  "bAcceptFriend",
  "iCreateRoleLanguageId",
  "sLoginRoleCountry",
  "iMaxLuaCodeRepairID",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  "iShowBackgroundId",
  "vMainBackground",
  "iMainBackgroundIndex",
  "sSignature",
  "mABTest",
  "iShowBackgroundExpireTime",
  iUid = {
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
  iLevel = {
    2,
    0,
    8,
    0
  },
  iDebugFlag = {
    3,
    0,
    8,
    0
  },
  iArenaCoin = {
    5,
    0,
    8,
    0
  },
  iLastArenaBeAttacked = {
    6,
    0,
    8,
    0
  },
  iAllianceId = {
    7,
    0,
    10,
    "0"
  },
  iJoinAllianceTime = {
    8,
    0,
    8,
    0
  },
  iAllianceLevel = {
    9,
    0,
    8,
    0
  },
  sAllianceName = {
    10,
    0,
    13,
    ""
  },
  iVipLevel = {
    11,
    0,
    8,
    0
  },
  iVipExp = {
    12,
    0,
    8,
    0
  },
  iCountryId = {
    13,
    0,
    8,
    0
  },
  stServerConfigData = {
    14,
    0,
    CmdServerConfigData,
    nil
  },
  bLuaCommMD5Mismatch = {
    15,
    0,
    1,
    false
  },
  iLastSetNameTime = {
    16,
    0,
    8,
    0
  },
  bDisplayVip = {
    17,
    0,
    1,
    false
  },
  iPublishTime = {
    19,
    0,
    8,
    0
  },
  iRoleRegTime = {
    20,
    0,
    8,
    0
  },
  iLastLoginTime = {
    21,
    0,
    8,
    0
  },
  iThisLoginTime = {
    22,
    0,
    8,
    0
  },
  iTotalRecharge = {
    23,
    0,
    8,
    0
  },
  iTotalRechargeDiamond = {
    24,
    0,
    8,
    0
  },
  mPushOption = {
    25,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  vRepairStr = {
    26,
    0,
    sdp.SdpVector(CmdRepairStr),
    nil
  },
  bOnlyCanRecharge = {
    27,
    0,
    1,
    false
  },
  sFacePath = {
    28,
    0,
    13,
    ""
  },
  mLuaCodeRepair = {
    29,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  bNewRole = {
    30,
    0,
    1,
    false
  },
  mSpecialItem = {
    31,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  iGender = {
    32,
    0,
    8,
    0
  },
  iBirthMonth = {
    33,
    0,
    8,
    0
  },
  iBirthDay = {
    34,
    0,
    8,
    0
  },
  bHasEvlaMessage = {
    35,
    0,
    1,
    false
  },
  bDisplayGender = {
    36,
    0,
    1,
    false
  },
  bClaimedBindAccountReward = {
    39,
    0,
    1,
    false
  },
  bHasSetRoleName = {
    40,
    0,
    1,
    false
  },
  iNextWatchAdTime = {
    41,
    0,
    8,
    0
  },
  bHasWelfare = {
    42,
    0,
    1,
    false
  },
  bArenaAwardRed = {
    43,
    0,
    1,
    false
  },
  sFBFaceId = {
    44,
    0,
    13,
    ""
  },
  iSetCountryTime = {
    45,
    0,
    8,
    0
  },
  iTotalVipLevel = {
    46,
    0,
    8,
    0
  },
  iFreeVipExp = {
    47,
    0,
    8,
    0
  },
  iTotalLoginDays = {
    48,
    0,
    8,
    0
  },
  iTodayRechargeNum = {
    49,
    0,
    8,
    0
  },
  sCreateRoleCountry = {
    50,
    0,
    13,
    ""
  },
  iDeepLinkType = {
    51,
    0,
    8,
    0
  },
  iGroupId = {
    52,
    0,
    8,
    0
  },
  iDistrictId = {
    53,
    0,
    8,
    0
  },
  bTestServer = {
    54,
    0,
    1,
    false
  },
  bAcceptFriend = {
    55,
    0,
    1,
    false
  },
  iCreateRoleLanguageId = {
    56,
    0,
    8,
    0
  },
  sLoginRoleCountry = {
    57,
    0,
    13,
    ""
  },
  iMaxLuaCodeRepairID = {
    58,
    0,
    8,
    0
  },
  iHeadId = {
    59,
    0,
    8,
    0
  },
  iHeadFrameId = {
    60,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    61,
    0,
    8,
    0
  },
  iShowBackgroundId = {
    62,
    0,
    8,
    0
  },
  vMainBackground = {
    63,
    0,
    sdp.SdpVector(CmdMainBackground),
    nil
  },
  iMainBackgroundIndex = {
    64,
    0,
    8,
    0
  },
  sSignature = {
    65,
    0,
    13,
    ""
  },
  mABTest = {
    66,
    0,
    sdp.SdpMap(6, 6),
    nil
  },
  iShowBackgroundExpireTime = {
    67,
    0,
    8,
    0
  }
}
Cmd_Role_BindAccount_CS = sdp.SdpStruct("Cmd_Role_BindAccount_CS")
Cmd_Role_BindAccount_CS.Definition = {
  "sAccountName",
  "sAuthKey",
  sAccountName = {
    0,
    0,
    13,
    ""
  },
  sAuthKey = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Role_BindAccount_SC = sdp.SdpStruct("Cmd_Role_BindAccount_SC")
Cmd_Role_BindAccount_SC.Definition = {
  "stAccountInfo",
  stAccountInfo = {
    0,
    0,
    CmdAccountInfo,
    nil
  }
}
Cmd_Role_UpdateBindAccount_CS = sdp.SdpStruct("Cmd_Role_UpdateBindAccount_CS")
Cmd_Role_UpdateBindAccount_CS.Definition = {
  "sAccountName",
  "sAuthKey",
  sAccountName = {
    0,
    0,
    13,
    ""
  },
  sAuthKey = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Role_UpdateBindAccount_SC = sdp.SdpStruct("Cmd_Role_UpdateBindAccount_SC")
Cmd_Role_UpdateBindAccount_SC.Definition = {}
Cmd_Role_GetBindAccount_CS = sdp.SdpStruct("Cmd_Role_GetBindAccount_CS")
Cmd_Role_GetBindAccount_CS.Definition = {
  "sAccountName",
  "sAuthKey",
  sAccountName = {
    0,
    0,
    13,
    ""
  },
  sAuthKey = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Role_GetBindAccount_SC = sdp.SdpStruct("Cmd_Role_GetBindAccount_SC")
Cmd_Role_GetBindAccount_SC.Definition = {
  "iAccountId",
  "vAccountInfo",
  "vRoleList",
  "vZoneList",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  vAccountInfo = {
    1,
    0,
    sdp.SdpVector(CmdAccountInfo),
    nil
  },
  vRoleList = {
    2,
    0,
    sdp.SdpVector(RoleInfo),
    nil
  },
  vZoneList = {
    3,
    0,
    sdp.SdpVector(ZoneInfo),
    nil
  }
}
Cmd_Role_UnbindAccount_CS = sdp.SdpStruct("Cmd_Role_UnbindAccount_CS")
Cmd_Role_UnbindAccount_CS.Definition = {
  "sAccountName",
  "sAuthKey",
  sAccountName = {
    0,
    0,
    13,
    ""
  },
  sAuthKey = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Role_UnbindAccount_SC = sdp.SdpStruct("Cmd_Role_UnbindAccount_SC")
Cmd_Role_UnbindAccount_SC.Definition = {}
Cmd_Role_ServerTime_CS = sdp.SdpStruct("Cmd_Role_ServerTime_CS")
Cmd_Role_ServerTime_CS.Definition = {}
Cmd_Role_ServerTime_SC = sdp.SdpStruct("Cmd_Role_ServerTime_SC")
Cmd_Role_ServerTime_SC.Definition = {
  "iServerTimeMS",
  "iTimeGmtOff",
  "iNextFreshTime",
  iServerTimeMS = {
    0,
    0,
    10,
    "0"
  },
  iTimeGmtOff = {
    1,
    0,
    9,
    "0"
  },
  iNextFreshTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Role_RandomName_CS = sdp.SdpStruct("Cmd_Role_RandomName_CS")
Cmd_Role_RandomName_CS.Definition = {}
Cmd_Role_RandomName_SC = sdp.SdpStruct("Cmd_Role_RandomName_SC")
Cmd_Role_RandomName_SC.Definition = {
  "vName",
  vName = {
    0,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Role_SetName_CS = sdp.SdpStruct("Cmd_Role_SetName_CS")
Cmd_Role_SetName_CS.Definition = {
  "sName",
  "bCheckNameOnly",
  sName = {
    0,
    0,
    13,
    ""
  },
  bCheckNameOnly = {
    1,
    0,
    1,
    false
  }
}
Cmd_Role_SetName_SC = sdp.SdpStruct("Cmd_Role_SetName_SC")
Cmd_Role_SetName_SC.Definition = {
  "bCheckNameOnly",
  "sName",
  "iLastSetNameTime",
  bCheckNameOnly = {
    0,
    0,
    1,
    false
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iLastSetNameTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Role_SetCountryId_CS = sdp.SdpStruct("Cmd_Role_SetCountryId_CS")
Cmd_Role_SetCountryId_CS.Definition = {
  "iCountryId",
  iCountryId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetCountryId_SC = sdp.SdpStruct("Cmd_Role_SetCountryId_SC")
Cmd_Role_SetCountryId_SC.Definition = {
  "iCountryId",
  "iSetCountryTime",
  iCountryId = {
    0,
    0,
    8,
    0
  },
  iSetCountryTime = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_SeeOther_CS = sdp.SdpStruct("Cmd_Role_SeeOther_CS")
Cmd_Role_SeeOther_CS.Definition = {
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
Cmd_Role_SeeOther_SC = sdp.SdpStruct("Cmd_Role_SeeOther_SC")
Cmd_Role_SeeOther_SC.Definition = {
  "stRoleSimpleInfo",
  stRoleSimpleInfo = {
    0,
    0,
    CmdRoleSimpleInfo,
    nil
  }
}
Cmd_Role_UpdateDeviceToken_CS = sdp.SdpStruct("Cmd_Role_UpdateDeviceToken_CS")
Cmd_Role_UpdateDeviceToken_CS.Definition = {
  "sDeviceToken",
  "sRegistrationId",
  sDeviceToken = {
    0,
    0,
    13,
    ""
  },
  sRegistrationId = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Role_UpdateDeviceToken_SC = sdp.SdpStruct("Cmd_Role_UpdateDeviceToken_SC")
Cmd_Role_UpdateDeviceToken_SC.Definition = {}
CmdNoticeData = sdp.SdpStruct("CmdNoticeData")
CmdNoticeData.Definition = {
  "iNoticeId",
  "sContent",
  "iBeginTime",
  "iEndTime",
  "iDisplayType",
  "iDisplayInterval",
  "iDisplayNum",
  "iTemplateId",
  "mTemplateParam",
  iNoticeId = {
    0,
    0,
    8,
    0
  },
  sContent = {
    1,
    0,
    13,
    ""
  },
  iBeginTime = {
    2,
    0,
    8,
    0
  },
  iEndTime = {
    3,
    0,
    8,
    0
  },
  iDisplayType = {
    4,
    0,
    8,
    0
  },
  iDisplayInterval = {
    5,
    0,
    8,
    0
  },
  iDisplayNum = {
    6,
    0,
    8,
    0
  },
  iTemplateId = {
    7,
    0,
    8,
    0
  },
  mTemplateParam = {
    8,
    0,
    sdp.SdpMap(13, 13),
    nil
  }
}
Cmd_Role_GetNotice_CS = sdp.SdpStruct("Cmd_Role_GetNotice_CS")
Cmd_Role_GetNotice_CS.Definition = {}
Cmd_Role_GetNotice_SC = sdp.SdpStruct("Cmd_Role_GetNotice_SC")
Cmd_Role_GetNotice_SC.Definition = {
  "vNoticeData",
  vNoticeData = {
    0,
    0,
    sdp.SdpVector(CmdNoticeData),
    nil
  }
}
Cmd_Role_ReportPushClick_CS = sdp.SdpStruct("Cmd_Role_ReportPushClick_CS")
Cmd_Role_ReportPushClick_CS.Definition = {
  "sPushTaskId",
  sPushTaskId = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_ReportPushClick_SC = sdp.SdpStruct("Cmd_Role_ReportPushClick_SC")
Cmd_Role_ReportPushClick_SC.Definition = {}
Cmd_Role_ExchangeCDKey_CS = sdp.SdpStruct("Cmd_Role_ExchangeCDKey_CS")
Cmd_Role_ExchangeCDKey_CS.Definition = {
  "sCDKey",
  sCDKey = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_ExchangeCDKey_SC = sdp.SdpStruct("Cmd_Role_ExchangeCDKey_SC")
Cmd_Role_ExchangeCDKey_SC.Definition = {}
Cmd_Role_GetZoneList_CS = sdp.SdpStruct("Cmd_Role_GetZoneList_CS")
Cmd_Role_GetZoneList_CS.Definition = {}
Cmd_Role_GetZoneList_SC = sdp.SdpStruct("Cmd_Role_GetZoneList_SC")
Cmd_Role_GetZoneList_SC.Definition = {
  "vZoneList",
  "vRoleList",
  "sErrMsg",
  vZoneList = {
    0,
    0,
    sdp.SdpVector(ZoneInfo),
    nil
  },
  vRoleList = {
    1,
    0,
    sdp.SdpVector(RoleInfo),
    nil
  },
  sErrMsg = {
    2,
    0,
    13,
    ""
  }
}
Cmd_Role_SetPushOption_CS = sdp.SdpStruct("Cmd_Role_SetPushOption_CS")
Cmd_Role_SetPushOption_CS.Definition = {
  "mPushOption",
  mPushOption = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Role_SetPushOption_SC = sdp.SdpStruct("Cmd_Role_SetPushOption_SC")
Cmd_Role_SetPushOption_SC.Definition = {}
Cmd_Role_DisplayVip_CS = sdp.SdpStruct("Cmd_Role_DisplayVip_CS")
Cmd_Role_DisplayVip_CS.Definition = {
  "bDisplay",
  bDisplay = {
    0,
    0,
    1,
    false
  }
}
Cmd_Role_DisplayVip_SC = sdp.SdpStruct("Cmd_Role_DisplayVip_SC")
Cmd_Role_DisplayVip_SC.Definition = {
  "bDisplay",
  bDisplay = {
    0,
    0,
    1,
    false
  }
}
Cmd_Role_ReportFace_CS = sdp.SdpStruct("Cmd_Role_ReportFace_CS")
Cmd_Role_ReportFace_CS.Definition = {
  "iUid",
  iUid = {
    0,
    0,
    10,
    "0"
  }
}
Cmd_Role_ReportFace_SC = sdp.SdpStruct("Cmd_Role_ReportFace_SC")
Cmd_Role_ReportFace_SC.Definition = {}
Cmd_Role_ReadElvaMessage_CS = sdp.SdpStruct("Cmd_Role_ReadElvaMessage_CS")
Cmd_Role_ReadElvaMessage_CS.Definition = {}
Cmd_Role_ReadElvaMessage_SC = sdp.SdpStruct("Cmd_Role_ReadElvaMessage_SC")
Cmd_Role_ReadElvaMessage_SC.Definition = {}
Cmd_Role_DisplayGender_CS = sdp.SdpStruct("Cmd_Role_DisplayGender_CS")
Cmd_Role_DisplayGender_CS.Definition = {
  "bDisplay",
  bDisplay = {
    0,
    0,
    1,
    false
  }
}
Cmd_Role_DisplayGender_SC = sdp.SdpStruct("Cmd_Role_DisplayGender_SC")
Cmd_Role_DisplayGender_SC.Definition = {}
Cmd_Role_PushNoticeSelect_CS = sdp.SdpStruct("Cmd_Role_PushNoticeSelect_CS")
Cmd_Role_PushNoticeSelect_CS.Definition = {
  "iNoticeType",
  "iSelect",
  iNoticeType = {
    0,
    0,
    8,
    0
  },
  iSelect = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_PushNoticeSelect_SC = sdp.SdpStruct("Cmd_Role_PushNoticeSelect_SC")
Cmd_Role_PushNoticeSelect_SC.Definition = {}
Cmd_Role_Report_CS = sdp.SdpStruct("Cmd_Role_Report_CS")
Cmd_Role_Report_CS.Definition = {
  "iType",
  "iTargetUid",
  "iZoneId",
  "iReportReasonType",
  "sReason",
  iType = {
    0,
    0,
    8,
    0
  },
  iTargetUid = {
    1,
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
  iReportReasonType = {
    3,
    0,
    sdp.SdpVector(8),
    nil
  },
  sReason = {
    4,
    0,
    13,
    ""
  }
}
Cmd_Role_Report_SC = sdp.SdpStruct("Cmd_Role_Report_SC")
Cmd_Role_Report_SC.Definition = {}
Cmd_Role_GetSurveyToken_CS = sdp.SdpStruct("Cmd_Role_GetSurveyToken_CS")
Cmd_Role_GetSurveyToken_CS.Definition = {}
Cmd_Role_GetSurveyToken_SC = sdp.SdpStruct("Cmd_Role_GetSurveyToken_SC")
Cmd_Role_GetSurveyToken_SC.Definition = {
  "sToken",
  sToken = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_SeeBusinessCard_CS = sdp.SdpStruct("Cmd_Role_SeeBusinessCard_CS")
Cmd_Role_SeeBusinessCard_CS.Definition = {
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
Cmd_Role_SeeBusinessCard_SC = sdp.SdpStruct("Cmd_Role_SeeBusinessCard_SC")
Cmd_Role_SeeBusinessCard_SC.Definition = {
  "stRoleBusinessCard",
  stRoleBusinessCard = {
    0,
    0,
    CmdRoleBusinessCard,
    nil
  }
}
Cmd_Role_SetBirthDay_CS = sdp.SdpStruct("Cmd_Role_SetBirthDay_CS")
Cmd_Role_SetBirthDay_CS.Definition = {
  "iMonth",
  "iDay",
  iMonth = {
    0,
    0,
    8,
    0
  },
  iDay = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_SetBirthDay_SC = sdp.SdpStruct("Cmd_Role_SetBirthDay_SC")
Cmd_Role_SetBirthDay_SC.Definition = {}
Cmd_Role_SetGender_CS = sdp.SdpStruct("Cmd_Role_SetGender_CS")
Cmd_Role_SetGender_CS.Definition = {
  "iGender",
  iGender = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetGender_SC = sdp.SdpStruct("Cmd_Role_SetGender_SC")
Cmd_Role_SetGender_SC.Definition = {}
Cmd_Role_GetRoleInfoBatch_CS = sdp.SdpStruct("Cmd_Role_GetRoleInfoBatch_CS")
Cmd_Role_GetRoleInfoBatch_CS.Definition = {
  "vRoleId",
  vRoleId = {
    0,
    0,
    sdp.SdpVector(PlayerIDType),
    nil
  }
}
Cmd_Role_GetRoleInfoBatch_SC = sdp.SdpStruct("Cmd_Role_GetRoleInfoBatch_SC")
Cmd_Role_GetRoleInfoBatch_SC.Definition = {
  "vRoleSimpleInfo",
  vRoleSimpleInfo = {
    0,
    0,
    sdp.SdpVector(CmdRoleSimpleInfo),
    nil
  }
}
Cmd_Role_UploadFBFaceId_CS = sdp.SdpStruct("Cmd_Role_UploadFBFaceId_CS")
Cmd_Role_UploadFBFaceId_CS.Definition = {
  "sFBFaceId",
  sFBFaceId = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_UploadFBFaceId_SC = sdp.SdpStruct("Cmd_Role_UploadFBFaceId_SC")
Cmd_Role_UploadFBFaceId_SC.Definition = {
  "sFBFaceId",
  sFBFaceId = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_GetOtherProgress_CS = sdp.SdpStruct("Cmd_Role_GetOtherProgress_CS")
Cmd_Role_GetOtherProgress_CS.Definition = {
  "iNeedNum",
  iNeedNum = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_GetOtherProgress_SC = sdp.SdpStruct("Cmd_Role_GetOtherProgress_SC")
Cmd_Role_GetOtherProgress_SC.Definition = {
  "vOthers",
  vOthers = {
    0,
    0,
    sdp.SdpVector(CmdRoleSimpleInfo),
    nil
  }
}
Cmd_Role_GetFBFace_CS = sdp.SdpStruct("Cmd_Role_GetFBFace_CS")
Cmd_Role_GetFBFace_CS.Definition = {}
Cmd_Role_GetFBFace_SC = sdp.SdpStruct("Cmd_Role_GetFBFace_SC")
Cmd_Role_GetFBFace_SC.Definition = {
  "sFBFace",
  "sFBId",
  sFBFace = {
    0,
    0,
    13,
    ""
  },
  sFBId = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Role_GetUserToken_CS = sdp.SdpStruct("Cmd_Role_GetUserToken_CS")
Cmd_Role_GetUserToken_CS.Definition = {
  "iTokenType",
  "sModule",
  "sCallBackId",
  iTokenType = {
    0,
    0,
    8,
    0
  },
  sModule = {
    1,
    0,
    13,
    ""
  },
  sCallBackId = {
    2,
    0,
    13,
    ""
  }
}
Cmd_Role_GetUserToken_SC = sdp.SdpStruct("Cmd_Role_GetUserToken_SC")
Cmd_Role_GetUserToken_SC.Definition = {
  "iTokenType",
  "sModule",
  "sCallBackId",
  "sUserToken",
  iTokenType = {
    0,
    0,
    8,
    0
  },
  sModule = {
    1,
    0,
    13,
    ""
  },
  sCallBackId = {
    2,
    0,
    13,
    ""
  },
  sUserToken = {
    3,
    0,
    13,
    ""
  }
}
Cmd_Role_CheckSwitchZone_CS = sdp.SdpStruct("Cmd_Role_CheckSwitchZone_CS")
Cmd_Role_CheckSwitchZone_CS.Definition = {
  "iZoneId",
  iZoneId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_CheckSwitchZone_SC = sdp.SdpStruct("Cmd_Role_CheckSwitchZone_SC")
Cmd_Role_CheckSwitchZone_SC.Definition = {
  "bCanSwitch",
  "vDeleteZoneId",
  "iDelTime",
  bCanSwitch = {
    0,
    0,
    1,
    false
  },
  vDeleteZoneId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  iDelTime = {
    2,
    0,
    8,
    0
  }
}
Cmd_Role_SurveyUrl_CS = sdp.SdpStruct("Cmd_Role_SurveyUrl_CS")
Cmd_Role_SurveyUrl_CS.Definition = {
  "sUrl",
  sUrl = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_SurveyUrl_SC = sdp.SdpStruct("Cmd_Role_SurveyUrl_SC")
Cmd_Role_SurveyUrl_SC.Definition = {
  "sUrl",
  sUrl = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_SetAcceptRequestFriend_CS = sdp.SdpStruct("Cmd_Role_SetAcceptRequestFriend_CS")
Cmd_Role_SetAcceptRequestFriend_CS.Definition = {
  "bAccept",
  bAccept = {
    0,
    0,
    1,
    false
  }
}
Cmd_Role_SetAcceptRequestFriend_SC = sdp.SdpStruct("Cmd_Role_SetAcceptRequestFriend_SC")
Cmd_Role_SetAcceptRequestFriend_SC.Definition = {
  "bAccept",
  bAccept = {
    0,
    0,
    1,
    false
  }
}
Cmd_Role_GetCirculation_CS = sdp.SdpStruct("Cmd_Role_GetCirculation_CS")
Cmd_Role_GetCirculation_CS.Definition = {}
Cmd_Role_GetCirculation_SC = sdp.SdpStruct("Cmd_Role_GetCirculation_SC")
Cmd_Role_GetCirculation_SC.Definition = {
  "mCirculationItem",
  mCirculationItem = {
    0,
    0,
    sdp.SdpMap(8, CmdCirculationItem),
    nil
  }
}
Cmd_Role_UpgradeCirculation_CS = sdp.SdpStruct("Cmd_Role_UpgradeCirculation_CS")
Cmd_Role_UpgradeCirculation_CS.Definition = {
  "iTypeID",
  "iItemNum",
  iTypeID = {
    0,
    0,
    8,
    0
  },
  iItemNum = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_UpgradeCirculation_SC = sdp.SdpStruct("Cmd_Role_UpgradeCirculation_SC")
Cmd_Role_UpgradeCirculation_SC.Definition = {
  "stCirculationItem",
  stCirculationItem = {
    0,
    0,
    CmdCirculationItem,
    nil
  }
}
Cmd_Role_GetLuaRepair_CS = sdp.SdpStruct("Cmd_Role_GetLuaRepair_CS")
Cmd_Role_GetLuaRepair_CS.Definition = {
  "iCurMaxRepairID",
  iCurMaxRepairID = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_GetLuaRepair_SC = sdp.SdpStruct("Cmd_Role_GetLuaRepair_SC")
Cmd_Role_GetLuaRepair_SC.Definition = {
  "mLuaIDSeverity",
  mLuaIDSeverity = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Role_SetHead_CS = sdp.SdpStruct("Cmd_Role_SetHead_CS")
Cmd_Role_SetHead_CS.Definition = {
  "iHeadId",
  iHeadId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetHead_SC = sdp.SdpStruct("Cmd_Role_SetHead_SC")
Cmd_Role_SetHead_SC.Definition = {
  "iHeadId",
  iHeadId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetHeadFrame_CS = sdp.SdpStruct("Cmd_Role_SetHeadFrame_CS")
Cmd_Role_SetHeadFrame_CS.Definition = {
  "iHeadFrameId",
  iHeadFrameId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetHeadFrame_SC = sdp.SdpStruct("Cmd_Role_SetHeadFrame_SC")
Cmd_Role_SetHeadFrame_SC.Definition = {
  "iHeadFrameId",
  iHeadFrameId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetShowBackground_CS = sdp.SdpStruct("Cmd_Role_SetShowBackground_CS")
Cmd_Role_SetShowBackground_CS.Definition = {
  "iShowBackgroundId",
  iShowBackgroundId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetShowBackground_SC = sdp.SdpStruct("Cmd_Role_SetShowBackground_SC")
Cmd_Role_SetShowBackground_SC.Definition = {
  "iShowBackgroundId",
  iShowBackgroundId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetCard_CS = sdp.SdpStruct("Cmd_Role_SetCard_CS")
Cmd_Role_SetCard_CS.Definition = {
  "iHeadId",
  "iHeadFrameId",
  "iShowBackgroundId",
  iHeadId = {
    0,
    0,
    8,
    0
  },
  iHeadFrameId = {
    1,
    0,
    8,
    0
  },
  iShowBackgroundId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Role_SetCard_SC = sdp.SdpStruct("Cmd_Role_SetCard_SC")
Cmd_Role_SetCard_SC.Definition = {
  "iHeadId",
  "iHeadFrameId",
  "iShowBackgroundId",
  iHeadId = {
    0,
    0,
    8,
    0
  },
  iHeadFrameId = {
    1,
    0,
    8,
    0
  },
  iShowBackgroundId = {
    2,
    0,
    8,
    0
  }
}
Cmd_Role_SetMainBackground_CS = sdp.SdpStruct("Cmd_Role_SetMainBackground_CS")
Cmd_Role_SetMainBackground_CS.Definition = {
  "vMainBackground",
  vMainBackground = {
    0,
    0,
    sdp.SdpVector(CmdMainBackground),
    nil
  }
}
Cmd_Role_SetMainBackground_SC = sdp.SdpStruct("Cmd_Role_SetMainBackground_SC")
Cmd_Role_SetMainBackground_SC.Definition = {
  "vMainBackground",
  "iIndex",
  vMainBackground = {
    0,
    0,
    sdp.SdpVector(CmdMainBackground),
    nil
  },
  iIndex = {
    1,
    0,
    8,
    0
  }
}
Cmd_Role_SetMainBackgroundIndex_CS = sdp.SdpStruct("Cmd_Role_SetMainBackgroundIndex_CS")
Cmd_Role_SetMainBackgroundIndex_CS.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetMainBackgroundIndex_SC = sdp.SdpStruct("Cmd_Role_SetMainBackgroundIndex_SC")
Cmd_Role_SetMainBackgroundIndex_SC.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Role_SetSignature_CS = sdp.SdpStruct("Cmd_Role_SetSignature_CS")
Cmd_Role_SetSignature_CS.Definition = {
  "sSignature",
  sSignature = {
    0,
    0,
    13,
    ""
  }
}
Cmd_Role_SetSignature_SC = sdp.SdpStruct("Cmd_Role_SetSignature_SC")
Cmd_Role_SetSignature_SC.Definition = {
  "sSignature",
  sSignature = {
    0,
    0,
    13,
    ""
  }
}
