local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActGameNotice_Status = sdp.SdpStruct("CmdActGameNotice_Status")
CmdActGameNotice_Status.Definition = {}
CmdActCfgGameNoticeContentConfig = sdp.SdpStruct("CmdActCfgGameNoticeContentConfig")
CmdActCfgGameNoticeContentConfig.Definition = {
  "iType",
  "sContent",
  "iJumpType",
  "sJumpParam",
  "iContentSize",
  "iContentColor",
  "iEmptyLine",
  "sTextContent",
  "iOffsetX",
  "iOffsetY",
  iType = {
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
  iJumpType = {
    2,
    0,
    8,
    0
  },
  sJumpParam = {
    3,
    0,
    13,
    ""
  },
  iContentSize = {
    4,
    0,
    8,
    0
  },
  iContentColor = {
    5,
    0,
    8,
    0
  },
  iEmptyLine = {
    6,
    0,
    8,
    0
  },
  sTextContent = {
    7,
    0,
    13,
    ""
  },
  iOffsetX = {
    8,
    0,
    8,
    0
  },
  iOffsetY = {
    9,
    0,
    8,
    0
  }
}
CmdActClientCfgGameNotice = sdp.SdpStruct("CmdActClientCfgGameNotice")
CmdActClientCfgGameNotice.Definition = {
  "iNoticeType",
  "iShowWeight",
  "iNeedChargeMoney",
  "sTitle",
  "vContentConfig",
  "sJumpContent",
  "iJumpTypeLast",
  "sJumpParamLast",
  iNoticeType = {
    0,
    0,
    8,
    0
  },
  iShowWeight = {
    1,
    0,
    8,
    0
  },
  iNeedChargeMoney = {
    2,
    0,
    8,
    0
  },
  sTitle = {
    3,
    0,
    13,
    ""
  },
  vContentConfig = {
    4,
    0,
    sdp.SdpVector(CmdActCfgGameNoticeContentConfig),
    nil
  },
  sJumpContent = {
    5,
    0,
    13,
    ""
  },
  iJumpTypeLast = {
    6,
    0,
    8,
    0
  },
  sJumpParamLast = {
    7,
    0,
    13,
    ""
  }
}
CmdActCfgGameNotice = sdp.SdpStruct("CmdActCfgGameNotice")
CmdActCfgGameNotice.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgGameNotice,
    nil
  }
}
