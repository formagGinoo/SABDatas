local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdId_Act_GetList_CS = 50001
CmdId_Act_GetList_SC = 50002
CmdId_Act_GetStatusById_CS = 50003
CmdId_Act_GetStatusById_SC = 50004
CmdId_Act_DayChangeZero_CS = 50005
CmdId_Act_DayChangeZero_SC = 50006
CmdCornerMarkType_None = 0
CmdCornerMarkType_Hot = 1
CmdCornerMarkType_New = 2
CmdCornerMarkType_Wait = 3
CmdActivityCatetory_Normal = 0
CmdActivityCatetory_New = 1
CmdActivityReceiveStatus_CanNotReceive = 0
CmdActivityReceiveStatus_CanReceive = 1
CmdActivityReceiveStatus_HasReceive = 2
CmdActivityMainCityIconDisplayType_Always = 1
CmdActivityMainCityIconDisplayType_Once = 2
CmdActivityMainCityIconDisplayType_Daily = 3
CmdActivityMainCityIconPosType_Down = 1
CmdActivityMainCityIconPosType_Right = 2
CmdActivityMarkType_None = 0
CmdActivityMarkType_Hot = 1
CmdActivityMarkType_New = 2
CmdActivityMarkType_Beta = 3
CmdActivityMainCityIcon = sdp.SdpStruct("CmdActivityMainCityIcon")
CmdActivityMainCityIcon.Definition = {
  "sIcon",
  "sName",
  "iPrior",
  "iDisplayType",
  "bEffect",
  "iPosType",
  sIcon = {
    0,
    0,
    13,
    ""
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  iPrior = {
    2,
    0,
    8,
    0
  },
  iDisplayType = {
    3,
    0,
    8,
    0
  },
  bEffect = {
    4,
    0,
    1,
    false
  },
  iPosType = {
    6,
    0,
    8,
    0
  }
}
CmdActivityShopParam = sdp.SdpStruct("CmdActivityShopParam")
CmdActivityShopParam.Definition = {
  "sPic",
  "sDesc",
  "bShowInShop",
  sPic = {
    0,
    0,
    13,
    ""
  },
  sDesc = {
    1,
    0,
    13,
    ""
  },
  bShowInShop = {
    2,
    0,
    1,
    false
  }
}
CmdSubTitile = sdp.SdpStruct("CmdSubTitile")
CmdSubTitile.Definition = {
  "sLanguageId",
  "sWordSize",
  "sWordColor",
  "sStroke",
  "sPosition",
  "iLocation",
  sLanguageId = {
    0,
    0,
    13,
    ""
  },
  sWordSize = {
    1,
    0,
    13,
    ""
  },
  sWordColor = {
    2,
    0,
    13,
    ""
  },
  sStroke = {
    3,
    0,
    13,
    ""
  },
  sPosition = {
    4,
    0,
    13,
    ""
  },
  iLocation = {
    5,
    0,
    8,
    0
  }
}
CmdActivityData = sdp.SdpStruct("CmdActivityData")
CmdActivityData.Definition = {
  "iActivityId",
  "iActivityType",
  "sTitle",
  "sBriefDesc",
  "sDetailDesc",
  "sIcon",
  "sJumpURL",
  "sJumpUI",
  "bIsTop",
  "bIsMajor",
  "iBeginTime",
  "iEndTime",
  "iShowTimeBegin",
  "iShowTimeEnd",
  "iMinLevel",
  "iMaxLevel",
  "bShowInList",
  "bHideJumpButton",
  "sDetailPic",
  "iJumpType",
  "sStatusDataSdp",
  "iCornerMarkType",
  "sDesignerRemark",
  "bShowOnLogin",
  "mMultiLanguage",
  "iActivityCategory",
  "bIsRecommend",
  "iRecommendDays",
  "iActivityPriority",
  "mDownloadPicture",
  "mRelativeActivityId",
  "sLoginAdvertisementParamLua",
  "stMainCityIcon",
  "iActivityPicPos",
  "sActivityPic",
  "iMarkType",
  "bShowTimer",
  "bShowReddot",
  "iEntry",
  "stShopParam",
  "sBriefDescImg",
  "mSubTitle",
  "sBriefDescImgLua",
  "sActBanner",
  "iActivitySpecialPriority",
  "iStageMin",
  "iStageMax",
  "sBuildingUi",
  "iPriority",
  "sBuildingAction",
  "sBuildingEdge",
  "iShowReddotNew",
  "iMainClassId",
  "sBuildingUnlockTxt",
  "sPageTitle",
  "iRegDayBegin",
  "iRegDayEnd",
  "sBuildingLinkCover",
  "sSdpConfig",
  "mCfgMultiLanguage",
  "mDownloadPictureCDN",
  "sJumpParam",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iActivityType = {
    1,
    0,
    8,
    0
  },
  sTitle = {
    2,
    0,
    13,
    ""
  },
  sBriefDesc = {
    3,
    0,
    13,
    ""
  },
  sDetailDesc = {
    4,
    0,
    13,
    ""
  },
  sIcon = {
    5,
    0,
    13,
    ""
  },
  sJumpURL = {
    6,
    0,
    13,
    ""
  },
  sJumpUI = {
    7,
    0,
    13,
    ""
  },
  bIsTop = {
    8,
    0,
    1,
    false
  },
  bIsMajor = {
    9,
    0,
    1,
    false
  },
  iBeginTime = {
    10,
    0,
    8,
    0
  },
  iEndTime = {
    11,
    0,
    8,
    0
  },
  iShowTimeBegin = {
    12,
    0,
    8,
    0
  },
  iShowTimeEnd = {
    13,
    0,
    8,
    0
  },
  iMinLevel = {
    14,
    0,
    8,
    0
  },
  iMaxLevel = {
    15,
    0,
    8,
    0
  },
  bShowInList = {
    16,
    0,
    1,
    false
  },
  bHideJumpButton = {
    17,
    0,
    1,
    false
  },
  sDetailPic = {
    18,
    0,
    13,
    ""
  },
  iJumpType = {
    19,
    0,
    8,
    0
  },
  sStatusDataSdp = {
    22,
    0,
    13,
    ""
  },
  iCornerMarkType = {
    23,
    0,
    8,
    0
  },
  sDesignerRemark = {
    24,
    0,
    13,
    ""
  },
  bShowOnLogin = {
    25,
    0,
    1,
    false
  },
  mMultiLanguage = {
    26,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  iActivityCategory = {
    27,
    0,
    8,
    0
  },
  bIsRecommend = {
    28,
    0,
    1,
    false
  },
  iRecommendDays = {
    29,
    0,
    8,
    0
  },
  iActivityPriority = {
    30,
    0,
    8,
    0
  },
  mDownloadPicture = {
    31,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  mRelativeActivityId = {
    32,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  sLoginAdvertisementParamLua = {
    33,
    0,
    13,
    ""
  },
  stMainCityIcon = {
    34,
    0,
    CmdActivityMainCityIcon,
    nil
  },
  iActivityPicPos = {
    35,
    0,
    8,
    0
  },
  sActivityPic = {
    36,
    0,
    13,
    ""
  },
  iMarkType = {
    37,
    0,
    8,
    0
  },
  bShowTimer = {
    38,
    0,
    1,
    false
  },
  bShowReddot = {
    39,
    0,
    1,
    false
  },
  iEntry = {
    40,
    0,
    8,
    0
  },
  stShopParam = {
    41,
    0,
    CmdActivityShopParam,
    nil
  },
  sBriefDescImg = {
    42,
    0,
    13,
    ""
  },
  mSubTitle = {
    43,
    0,
    sdp.SdpMap(13, CmdSubTitile),
    nil
  },
  sBriefDescImgLua = {
    44,
    0,
    13,
    ""
  },
  sActBanner = {
    45,
    0,
    13,
    ""
  },
  iActivitySpecialPriority = {
    46,
    0,
    8,
    0
  },
  iStageMin = {
    47,
    0,
    8,
    0
  },
  iStageMax = {
    48,
    0,
    8,
    0
  },
  sBuildingUi = {
    49,
    0,
    13,
    ""
  },
  iPriority = {
    50,
    0,
    8,
    0
  },
  sBuildingAction = {
    51,
    0,
    13,
    ""
  },
  sBuildingEdge = {
    52,
    0,
    13,
    ""
  },
  iShowReddotNew = {
    53,
    0,
    8,
    0
  },
  iMainClassId = {
    54,
    0,
    8,
    0
  },
  sBuildingUnlockTxt = {
    55,
    0,
    13,
    ""
  },
  sPageTitle = {
    56,
    0,
    13,
    ""
  },
  iRegDayBegin = {
    57,
    0,
    8,
    0
  },
  iRegDayEnd = {
    58,
    0,
    8,
    0
  },
  sBuildingLinkCover = {
    59,
    0,
    13,
    ""
  },
  sSdpConfig = {
    60,
    0,
    13,
    ""
  },
  mCfgMultiLanguage = {
    61,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  mDownloadPictureCDN = {
    62,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  sJumpParam = {
    63,
    0,
    13,
    ""
  }
}
CmdActivityStatus = sdp.SdpStruct("CmdActivityStatus")
CmdActivityStatus.Definition = {
  "iActivityId",
  "iActivityType",
  "sStatusDataSdp",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iActivityType = {
    1,
    0,
    8,
    0
  },
  sStatusDataSdp = {
    2,
    0,
    13,
    ""
  }
}
CmdActivityReceiveRewardStatus = sdp.SdpStruct("CmdActivityReceiveRewardStatus")
CmdActivityReceiveRewardStatus.Definition = {
  "mReceive",
  "mServerReceive",
  mReceive = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  },
  mServerReceive = {
    1,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
Cmd_Act_GetList_CS = sdp.SdpStruct("Cmd_Act_GetList_CS")
Cmd_Act_GetList_CS.Definition = {
  "sLanguage",
  "sChecksum",
  sLanguage = {
    0,
    0,
    13,
    ""
  },
  sChecksum = {
    1,
    0,
    13,
    ""
  }
}
Cmd_Act_GetList_SC = sdp.SdpStruct("Cmd_Act_GetList_SC")
Cmd_Act_GetList_SC.Definition = {
  "vActivity",
  "iPushVersion",
  "sNewChecksum",
  "bOnlyStatusData",
  "vStatusData",
  vActivity = {
    0,
    0,
    sdp.SdpVector(CmdActivityData),
    nil
  },
  iPushVersion = {
    1,
    0,
    8,
    0
  },
  sNewChecksum = {
    2,
    0,
    13,
    ""
  },
  bOnlyStatusData = {
    3,
    0,
    1,
    false
  },
  vStatusData = {
    4,
    0,
    sdp.SdpVector(CmdActivityStatus),
    nil
  }
}
Cmd_Act_GetStatusById_CS = sdp.SdpStruct("Cmd_Act_GetStatusById_CS")
Cmd_Act_GetStatusById_CS.Definition = {
  "vActivityId",
  vActivityId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Act_GetStatusById_SC = sdp.SdpStruct("Cmd_Act_GetStatusById_SC")
Cmd_Act_GetStatusById_SC.Definition = {
  "vStatus",
  vStatus = {
    0,
    0,
    sdp.SdpVector(CmdActivityStatus),
    nil
  }
}
Cmd_Act_DayChangeZero_CS = sdp.SdpStruct("Cmd_Act_DayChangeZero_CS")
Cmd_Act_DayChangeZero_CS.Definition = {}
Cmd_Act_DayChangeZero_SC = sdp.SdpStruct("Cmd_Act_DayChangeZero_SC")
Cmd_Act_DayChangeZero_SC.Definition = {
  "vStatus",
  vStatus = {
    0,
    0,
    sdp.SdpVector(CmdActivityStatus),
    nil
  }
}
