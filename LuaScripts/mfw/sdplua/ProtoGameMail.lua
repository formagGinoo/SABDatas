local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
require("ProtoGameFightVerify")
require("ProtoGameAlliance")
module("MTTDProto")
CmdId_Mail_GetMail_CS = 11201
CmdId_Mail_GetMail_SC = 11202
CmdId_Mail_ReadMail_CS = 11203
CmdId_Mail_ReadMail_SC = 11204
CmdId_Mail_DelMail_CS = 11205
CmdId_Mail_DelMail_SC = 11206
CmdId_Mail_RcvMailAttach_CS = 11207
CmdId_Mail_RcvMailAttach_SC = 11208
CmdId_Mail_RcvAllMailAttach_CS = 11209
CmdId_Mail_RcvAllMailAttach_SC = 11210
CmdId_Mail_DelAllRcvMail_CS = 11211
CmdId_Mail_DelAllRcvMail_SC = 11212
CmdId_Mail_GetNewMail_CS = 11213
CmdId_Mail_GetNewMail_SC = 11214
CmdId_Mail_GetOneMail_CS = 11215
CmdId_Mail_GetOneMail_SC = 11216
CmdId_Mail_WriteMail_CS = 11217
CmdId_Mail_WriteMail_SC = 11218
CmdId_Mail_ReportBadMail_CS = 11219
CmdId_Mail_ReportBadMail_SC = 11220
CmdId_Mail_DelCollectMail_CS = 11221
CmdId_Mail_DelCollectMail_SC = 11222
MailType_System = 0
TemplateMailType_Normal = 0
TemplateMailType_Collect = 1
CollectMailConditionType_Date = 1
CollectMailConditionType_Stage = 2
CollectMailConditionType_RegDay = 3
CollectMailConditionType_ContinuousLoginDays = 4
CollectMailConditionType_RoleBirthday = 5
CollectMailConditionType_HeroBirthday = 6
MailData = sdp.SdpStruct("MailData")
MailData.Definition = {
  "iMailId",
  "iType",
  "iTime",
  "sFrom",
  "sTitle",
  "mTitleParam",
  "sContent",
  "vItems",
  "iOpenTime",
  "iRcvAttachTime",
  "iTemplateId",
  "mTemplateParam",
  "bSticky",
  "iDelTime",
  "iFromUid",
  iMailId = {
    0,
    0,
    8,
    0
  },
  iType = {
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
  sFrom = {
    3,
    0,
    13,
    ""
  },
  sTitle = {
    4,
    0,
    13,
    ""
  },
  mTitleParam = {
    5,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  sContent = {
    6,
    0,
    13,
    ""
  },
  vItems = {
    7,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iOpenTime = {
    8,
    0,
    8,
    0
  },
  iRcvAttachTime = {
    9,
    0,
    8,
    0
  },
  iTemplateId = {
    10,
    0,
    8,
    0
  },
  mTemplateParam = {
    11,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  bSticky = {
    12,
    0,
    1,
    false
  },
  iDelTime = {
    13,
    0,
    8,
    0
  },
  iFromUid = {
    14,
    0,
    10,
    "0"
  }
}
Cmd_Mail_GetMail_CS = sdp.SdpStruct("Cmd_Mail_GetMail_CS")
Cmd_Mail_GetMail_CS.Definition = {}
Cmd_Mail_GetMail_SC = sdp.SdpStruct("Cmd_Mail_GetMail_SC")
Cmd_Mail_GetMail_SC.Definition = {
  "vMail",
  "vCollectMail",
  vMail = {
    0,
    0,
    sdp.SdpVector(MailData),
    nil
  },
  vCollectMail = {
    1,
    0,
    sdp.SdpVector(MailData),
    nil
  }
}
Cmd_Mail_ReadMail_CS = sdp.SdpStruct("Cmd_Mail_ReadMail_CS")
Cmd_Mail_ReadMail_CS.Definition = {
  "iMailId",
  iMailId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Mail_ReadMail_SC = sdp.SdpStruct("Cmd_Mail_ReadMail_SC")
Cmd_Mail_ReadMail_SC.Definition = {
  "iMailId",
  "iOpenTime",
  "iDelTime",
  "bCollect",
  iMailId = {
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
  iDelTime = {
    2,
    0,
    8,
    0
  },
  bCollect = {
    3,
    0,
    1,
    false
  }
}
Cmd_Mail_DelMail_CS = sdp.SdpStruct("Cmd_Mail_DelMail_CS")
Cmd_Mail_DelMail_CS.Definition = {
  "vMailId",
  vMailId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Mail_DelMail_SC = sdp.SdpStruct("Cmd_Mail_DelMail_SC")
Cmd_Mail_DelMail_SC.Definition = {
  "vMailId",
  vMailId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Mail_RcvMailAttach_CS = sdp.SdpStruct("Cmd_Mail_RcvMailAttach_CS")
Cmd_Mail_RcvMailAttach_CS.Definition = {
  "iMailId",
  iMailId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Mail_RcvMailAttach_SC = sdp.SdpStruct("Cmd_Mail_RcvMailAttach_SC")
Cmd_Mail_RcvMailAttach_SC.Definition = {
  "iMailId",
  "bDel",
  "iRcvAttachTime",
  "vReward",
  "iOpenTime",
  "iDelTime",
  "bCollect",
  iMailId = {
    0,
    0,
    8,
    0
  },
  bDel = {
    1,
    0,
    1,
    false
  },
  iRcvAttachTime = {
    2,
    0,
    8,
    0
  },
  vReward = {
    3,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  iOpenTime = {
    4,
    0,
    8,
    0
  },
  iDelTime = {
    5,
    0,
    8,
    0
  },
  bCollect = {
    6,
    0,
    1,
    false
  }
}
Cmd_Mail_RcvAllMailAttach_CS = sdp.SdpStruct("Cmd_Mail_RcvAllMailAttach_CS")
Cmd_Mail_RcvAllMailAttach_CS.Definition = {}
Cmd_Mail_RcvAllMailAttach_SC = sdp.SdpStruct("Cmd_Mail_RcvAllMailAttach_SC")
Cmd_Mail_RcvAllMailAttach_SC.Definition = {
  "vMail",
  "vDelMailId",
  "vCollectId",
  vMail = {
    0,
    0,
    sdp.SdpVector(MailData),
    nil
  },
  vDelMailId = {
    1,
    0,
    sdp.SdpVector(8),
    nil
  },
  vCollectId = {
    2,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Mail_DelAllRcvMail_CS = sdp.SdpStruct("Cmd_Mail_DelAllRcvMail_CS")
Cmd_Mail_DelAllRcvMail_CS.Definition = {}
Cmd_Mail_DelAllRcvMail_SC = sdp.SdpStruct("Cmd_Mail_DelAllRcvMail_SC")
Cmd_Mail_DelAllRcvMail_SC.Definition = {
  "vMailId",
  vMailId = {
    0,
    0,
    sdp.SdpVector(8),
    nil
  }
}
Cmd_Mail_GetNewMail_CS = sdp.SdpStruct("Cmd_Mail_GetNewMail_CS")
Cmd_Mail_GetNewMail_CS.Definition = {}
Cmd_Mail_GetNewMail_SC = sdp.SdpStruct("Cmd_Mail_GetNewMail_SC")
Cmd_Mail_GetNewMail_SC.Definition = {
  "vMail",
  vMail = {
    0,
    0,
    sdp.SdpVector(MailData),
    nil
  }
}
Cmd_Mail_GetOneMail_CS = sdp.SdpStruct("Cmd_Mail_GetOneMail_CS")
Cmd_Mail_GetOneMail_CS.Definition = {
  "iMailId",
  iMailId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Mail_GetOneMail_SC = sdp.SdpStruct("Cmd_Mail_GetOneMail_SC")
Cmd_Mail_GetOneMail_SC.Definition = {
  "stMailData",
  stMailData = {
    0,
    0,
    MailData,
    nil
  }
}
Cmd_Mail_WriteMail_CS = sdp.SdpStruct("Cmd_Mail_WriteMail_CS")
Cmd_Mail_WriteMail_CS.Definition = {
  "sToUser",
  "sTitle",
  "sContent",
  "iToUserId",
  "iTemplateId",
  "mParam",
  "bEmergent",
  sToUser = {
    0,
    0,
    13,
    ""
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
  iToUserId = {
    3,
    0,
    10,
    "0"
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
  bEmergent = {
    6,
    0,
    1,
    false
  }
}
Cmd_Mail_WriteMail_SC = sdp.SdpStruct("Cmd_Mail_WriteMail_SC")
Cmd_Mail_WriteMail_SC.Definition = {
  "bWriteOK",
  bWriteOK = {
    0,
    0,
    1,
    false
  }
}
Cmd_Mail_ReportBadMail_CS = sdp.SdpStruct("Cmd_Mail_ReportBadMail_CS")
Cmd_Mail_ReportBadMail_CS.Definition = {
  "iMailId",
  "sReason",
  iMailId = {
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
  }
}
Cmd_Mail_ReportBadMail_SC = sdp.SdpStruct("Cmd_Mail_ReportBadMail_SC")
Cmd_Mail_ReportBadMail_SC.Definition = {}
Cmd_Mail_DelCollectMail_CS = sdp.SdpStruct("Cmd_Mail_DelCollectMail_CS")
Cmd_Mail_DelCollectMail_CS.Definition = {
  "iMailId",
  iMailId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Mail_DelCollectMail_SC = sdp.SdpStruct("Cmd_Mail_DelCollectMail_SC")
Cmd_Mail_DelCollectMail_SC.Definition = {
  "iMailId",
  iMailId = {
    0,
    0,
    8,
    0
  }
}
