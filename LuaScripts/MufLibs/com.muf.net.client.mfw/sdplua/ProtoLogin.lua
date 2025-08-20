local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdId_Login_Auth_CS = 1
CmdId_Login_Auth_SC = 2
CmdId_Login_GetZone_CS = 3
CmdId_Login_GetZone_SC = 4
CmdId_Login_CheckUpgrade_CS = 5
CmdId_Login_CheckUpgrade_SC = 6
CmdId_Login_GetBulletin_CS = 7
CmdId_Login_GetBulletin_SC = 8
CmdId_Login_UpdateDeviceToken_CS = 9
CmdId_Login_UpdateDeviceToken_SC = 10
CmdId_Login_CheckSwitchZone_CS = 11
CmdId_Login_CheckSwitchZone_SC = 12
CmdId_Login_Register_CS = 13
CmdId_Login_Register_SC = 14
EM_ZoneStatus_Smooth = 1
EM_ZoneStatus_Crowd = 2
EM_ZoneStatus_Busy = 3
EM_ZoneStatus_Maintain = 4
EM_ZoneFlag_Normal = 1
EM_ZoneFlag_New = 2
EM_ZoneFlag_Close = 3
EM_ZoneFlag_Audit = 4
CmdBulletinDisplayGrade_A = 0
CmdBulletinDisplayGrade_B = 1
ZoneInfo = sdp.SdpStruct("ZoneInfo")
ZoneInfo.Definition = {
  "iZoneId",
  "sZoneName",
  "iStatus",
  "iFlag",
  "sVersion",
  "sPreLangs",
  "bIsTestZone",
  "sAuditChannel",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  sZoneName = {
    1,
    0,
    13,
    ""
  },
  iStatus = {
    2,
    0,
    8,
    0
  },
  iFlag = {
    3,
    0,
    8,
    0
  },
  sVersion = {
    4,
    0,
    13,
    ""
  },
  sPreLangs = {
    5,
    0,
    13,
    ""
  },
  bIsTestZone = {
    8,
    0,
    1,
    false
  },
  sAuditChannel = {
    10,
    0,
    13,
    ""
  }
}
RoleInfo = sdp.SdpStruct("RoleInfo")
RoleInfo.Definition = {
  "iZoneId",
  "iRoleId",
  "sRoleName",
  "iLevel",
  "iUpdateTime",
  "sFBFaceId",
  "iHeadId",
  "iHeadFrameId",
  "iHeadFrameExpireTime",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  iRoleId = {
    1,
    0,
    10,
    "0"
  },
  sRoleName = {
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
  iUpdateTime = {
    4,
    0,
    8,
    0
  },
  sFBFaceId = {
    6,
    0,
    13,
    ""
  },
  iHeadId = {
    7,
    0,
    8,
    0
  },
  iHeadFrameId = {
    8,
    0,
    8,
    0
  },
  iHeadFrameExpireTime = {
    9,
    0,
    8,
    0
  }
}
CmdAccountInfo = sdp.SdpStruct("CmdAccountInfo")
CmdAccountInfo.Definition = {
  "sAccountName",
  "mData",
  sAccountName = {
    0,
    0,
    13,
    ""
  },
  mData = {
    1,
    0,
    sdp.SdpMap(13, 13),
    nil
  }
}
CmdBulletinTitleContent = sdp.SdpStruct("CmdBulletinTitleContent")
CmdBulletinTitleContent.Definition = {
  "sTitle",
  "sContent",
  sTitle = {
    0,
    0,
    13,
    ""
  },
  sContent = {
    1,
    0,
    13,
    ""
  }
}
CmdBulletinInfo = sdp.SdpStruct("CmdBulletinInfo")
CmdBulletinInfo.Definition = {
  "iBulletinId",
  "sTitle",
  "sContent",
  "iDisplayNum",
  "iDisplayGrade",
  "sLuaVersion",
  "vContent",
  "iMaintainRemainSecs",
  "sHyperlink",
  "sHyperlinkName",
  iBulletinId = {
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
  },
  sContent = {
    2,
    0,
    13,
    ""
  },
  iDisplayNum = {
    3,
    0,
    8,
    0
  },
  iDisplayGrade = {
    4,
    0,
    8,
    0
  },
  sLuaVersion = {
    5,
    0,
    13,
    ""
  },
  vContent = {
    6,
    0,
    sdp.SdpVector(CmdBulletinTitleContent),
    nil
  },
  iMaintainRemainSecs = {
    7,
    0,
    8,
    0
  },
  sHyperlink = {
    8,
    0,
    13,
    ""
  },
  sHyperlinkName = {
    9,
    0,
    13,
    ""
  }
}
Cmd_Login_Auth_CS = sdp.SdpStruct("Cmd_Login_Auth_CS")
Cmd_Login_Auth_CS.Definition = {
  "sAccountName",
  "sAuthKey",
  "sClientVersion",
  "sChannel",
  "sOSLanguage",
  "iOSType",
  "mMiscData",
  "iLocalZoneId",
  "iRegionId",
  "mDeviceInfo",
  "iPrivacyId",
  "sIDFAAccountName",
  "bSimulator",
  "sSimulatorUid",
  "sSimulatorBrand",
  "sOaId",
  "sDrmId",
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
  },
  sClientVersion = {
    2,
    0,
    13,
    ""
  },
  sChannel = {
    3,
    0,
    13,
    ""
  },
  sOSLanguage = {
    5,
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
  mMiscData = {
    7,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iLocalZoneId = {
    8,
    0,
    8,
    0
  },
  iRegionId = {
    9,
    0,
    8,
    0
  },
  mDeviceInfo = {
    10,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iPrivacyId = {
    11,
    0,
    8,
    0
  },
  sIDFAAccountName = {
    12,
    0,
    13,
    ""
  },
  bSimulator = {
    13,
    0,
    1,
    false
  },
  sSimulatorUid = {
    14,
    0,
    13,
    ""
  },
  sSimulatorBrand = {
    15,
    0,
    13,
    ""
  },
  sOaId = {
    16,
    0,
    13,
    ""
  },
  sDrmId = {
    17,
    0,
    13,
    ""
  }
}
Cmd_Login_Auth_SC = sdp.SdpStruct("Cmd_Login_Auth_SC")
Cmd_Login_Auth_SC.Definition = {
  "iAccountId",
  "sSessionKey",
  "stZone",
  "vAccountInfo",
  "sExecuteLua",
  "sUserIP",
  "sAccountName",
  "iServerTimeMS",
  "iTimeGmtOff",
  "iNextFreshTime",
  "bNewAccount",
  "iThirdRealNameAuth",
  "sCountry",
  "bGDPRCountry",
  "mLuaCodeRepair",
  "sFBName",
  "sFBFaceId",
  "sState",
  "iPrivacyId",
  "bShowAge",
  "vDeleteZoneId",
  "iDelTime",
  "bInWhiteList",
  "iMaxLuaCodeRepairID",
  "mMiscData",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  sSessionKey = {
    1,
    0,
    13,
    ""
  },
  stZone = {
    2,
    0,
    ZoneInfo,
    nil
  },
  vAccountInfo = {
    3,
    0,
    sdp.SdpVector(CmdAccountInfo),
    nil
  },
  sExecuteLua = {
    4,
    0,
    13,
    ""
  },
  sUserIP = {
    8,
    0,
    13,
    ""
  },
  sAccountName = {
    9,
    0,
    13,
    ""
  },
  iServerTimeMS = {
    10,
    0,
    10,
    "0"
  },
  iTimeGmtOff = {
    11,
    0,
    9,
    "0"
  },
  iNextFreshTime = {
    12,
    0,
    8,
    0
  },
  bNewAccount = {
    14,
    0,
    1,
    false
  },
  iThirdRealNameAuth = {
    16,
    0,
    8,
    0
  },
  sCountry = {
    17,
    0,
    13,
    ""
  },
  bGDPRCountry = {
    18,
    0,
    1,
    false
  },
  mLuaCodeRepair = {
    19,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  sFBName = {
    20,
    0,
    13,
    ""
  },
  sFBFaceId = {
    21,
    0,
    13,
    ""
  },
  sState = {
    22,
    0,
    13,
    ""
  },
  iPrivacyId = {
    23,
    0,
    8,
    0
  },
  bShowAge = {
    24,
    0,
    1,
    false
  },
  vDeleteZoneId = {
    25,
    0,
    sdp.SdpVector(8),
    nil
  },
  iDelTime = {
    26,
    0,
    8,
    0
  },
  bInWhiteList = {
    27,
    0,
    1,
    false
  },
  iMaxLuaCodeRepairID = {
    28,
    0,
    8,
    0
  },
  mMiscData = {
    29,
    0,
    sdp.SdpMap(13, 13),
    nil
  }
}
Cmd_Login_GetZone_CS = sdp.SdpStruct("Cmd_Login_GetZone_CS")
Cmd_Login_GetZone_CS.Definition = {
  "iAccountId",
  "sSessionKey",
  "sClientVersion",
  "sChannel",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  sSessionKey = {
    1,
    0,
    13,
    ""
  },
  sClientVersion = {
    2,
    0,
    13,
    ""
  },
  sChannel = {
    3,
    0,
    13,
    ""
  }
}
Cmd_Login_GetZone_SC = sdp.SdpStruct("Cmd_Login_GetZone_SC")
Cmd_Login_GetZone_SC.Definition = {
  "vZoneList",
  "vRoleList",
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
  }
}
Cmd_Login_CheckUpgrade_CS = sdp.SdpStruct("Cmd_Login_CheckUpgrade_CS")
Cmd_Login_CheckUpgrade_CS.Definition = {
  "iAccountId",
  "sSessionKey",
  "sClientVersion",
  "iZoneId",
  "sChannel",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  sSessionKey = {
    1,
    0,
    13,
    ""
  },
  sClientVersion = {
    2,
    0,
    13,
    ""
  },
  iZoneId = {
    5,
    0,
    8,
    0
  },
  sChannel = {
    6,
    0,
    13,
    ""
  }
}
Cmd_Login_CheckUpgrade_SC = sdp.SdpStruct("Cmd_Login_CheckUpgrade_SC")
Cmd_Login_CheckUpgrade_SC.Definition = {
  "iZoneId",
  "sConnServer",
  "sClientVersion",
  "sForceVersion",
  "sOptionalVersion",
  "sResPatchVersion",
  "sResAllVersion",
  "sCdnVersion",
  "vProxyConnServer",
  "iNetTestTimeOutMS",
  "sFaceCdnHost",
  "sFaceUploadHost",
  "sApkUpdateAddr",
  "sActivityPictureAddr",
  "vCdnList",
  "vEchoServer",
  "bMiniPatchOpen",
  "iMiniPatchVersion",
  "sMiniPatchPath",
  "bMiniPatchBackground",
  "bMiniPatchRestart",
  "bStateScriptOpen",
  "iStateScriptVersion",
  "sStateScriptPath",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  sConnServer = {
    1,
    0,
    13,
    ""
  },
  sClientVersion = {
    2,
    0,
    13,
    ""
  },
  sForceVersion = {
    3,
    0,
    13,
    ""
  },
  sOptionalVersion = {
    4,
    0,
    13,
    ""
  },
  sResPatchVersion = {
    5,
    0,
    13,
    ""
  },
  sResAllVersion = {
    6,
    0,
    13,
    ""
  },
  sCdnVersion = {
    7,
    0,
    13,
    ""
  },
  vProxyConnServer = {
    8,
    0,
    sdp.SdpVector(13),
    nil
  },
  iNetTestTimeOutMS = {
    9,
    0,
    8,
    0
  },
  sFaceCdnHost = {
    10,
    0,
    13,
    ""
  },
  sFaceUploadHost = {
    11,
    0,
    13,
    ""
  },
  sApkUpdateAddr = {
    12,
    0,
    13,
    ""
  },
  sActivityPictureAddr = {
    13,
    0,
    13,
    ""
  },
  vCdnList = {
    14,
    0,
    sdp.SdpVector(13),
    nil
  },
  vEchoServer = {
    15,
    0,
    sdp.SdpVector(13),
    nil
  },
  bMiniPatchOpen = {
    16,
    0,
    1,
    false
  },
  iMiniPatchVersion = {
    17,
    0,
    8,
    0
  },
  sMiniPatchPath = {
    18,
    0,
    13,
    ""
  },
  bMiniPatchBackground = {
    19,
    0,
    1,
    false
  },
  bMiniPatchRestart = {
    20,
    0,
    1,
    false
  },
  bStateScriptOpen = {
    21,
    0,
    1,
    false
  },
  iStateScriptVersion = {
    22,
    0,
    8,
    0
  },
  sStateScriptPath = {
    23,
    0,
    13,
    ""
  }
}
Cmd_Login_GetBulletin_CS = sdp.SdpStruct("Cmd_Login_GetBulletin_CS")
Cmd_Login_GetBulletin_CS.Definition = {
  "iCurrId",
  "bHasAudit",
  "iLanguageId",
  "iZoneId",
  "iOSType",
  "sChannel",
  "sCountry",
  "sClientVersion",
  "iCurrUpdateId",
  "sZoneVersion",
  "iCurrMaintainId",
  "iAccountId",
  iCurrId = {
    0,
    0,
    8,
    0
  },
  bHasAudit = {
    1,
    0,
    1,
    false
  },
  iLanguageId = {
    2,
    0,
    8,
    0
  },
  iZoneId = {
    3,
    0,
    8,
    0
  },
  iOSType = {
    4,
    0,
    8,
    0
  },
  sChannel = {
    5,
    0,
    13,
    ""
  },
  sCountry = {
    6,
    0,
    13,
    ""
  },
  sClientVersion = {
    7,
    0,
    13,
    ""
  },
  iCurrUpdateId = {
    8,
    0,
    8,
    0
  },
  sZoneVersion = {
    9,
    0,
    13,
    ""
  },
  iCurrMaintainId = {
    10,
    0,
    8,
    0
  },
  iAccountId = {
    11,
    0,
    10,
    "0"
  }
}
Cmd_Login_GetBulletin_SC = sdp.SdpStruct("Cmd_Login_GetBulletin_SC")
Cmd_Login_GetBulletin_SC.Definition = {
  "vInfo",
  "vUpdateInfo",
  "vMaintainInfo",
  vInfo = {
    0,
    0,
    sdp.SdpVector(CmdBulletinInfo),
    nil
  },
  vUpdateInfo = {
    1,
    0,
    sdp.SdpVector(CmdBulletinInfo),
    nil
  },
  vMaintainInfo = {
    2,
    0,
    sdp.SdpVector(CmdBulletinInfo),
    nil
  }
}
Cmd_Login_UpdateDeviceToken_CS = sdp.SdpStruct("Cmd_Login_UpdateDeviceToken_CS")
Cmd_Login_UpdateDeviceToken_CS.Definition = {
  "iAccountId",
  "sSessionKey",
  "sDeviceToken",
  "sRegistrationId",
  iAccountId = {
    0,
    0,
    10,
    "0"
  },
  sSessionKey = {
    1,
    0,
    13,
    ""
  },
  sDeviceToken = {
    2,
    0,
    13,
    ""
  },
  sRegistrationId = {
    3,
    0,
    13,
    ""
  }
}
Cmd_Login_UpdateDeviceToken_SC = sdp.SdpStruct("Cmd_Login_UpdateDeviceToken_SC")
Cmd_Login_UpdateDeviceToken_SC.Definition = {}
Cmd_Login_CheckSwitchZone_CS = sdp.SdpStruct("Cmd_Login_CheckSwitchZone_CS")
Cmd_Login_CheckSwitchZone_CS.Definition = {
  "iZoneId",
  "iAccountId",
  "sSessionKey",
  iZoneId = {
    0,
    0,
    8,
    0
  },
  iAccountId = {
    1,
    0,
    10,
    "0"
  },
  sSessionKey = {
    2,
    0,
    13,
    ""
  }
}
Cmd_Login_CheckSwitchZone_SC = sdp.SdpStruct("Cmd_Login_CheckSwitchZone_SC")
Cmd_Login_CheckSwitchZone_SC.Definition = {
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
Cmd_Login_Register_CS = sdp.SdpStruct("Cmd_Login_Register_CS")
Cmd_Login_Register_CS.Definition = {
  "sAccount",
  "sPasswd",
  sAccount = {
    0,
    0,
    13,
    ""
  },
  sPasswd = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Login_Register_SC = sdp.SdpStruct("Cmd_Login_Register_SC")
Cmd_Login_Register_SC.Definition = {}
