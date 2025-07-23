local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActModuleControl_Status = sdp.SdpStruct("CmdActModuleControl_Status")
CmdActModuleControl_Status.Definition = {}
CmdActClientCfgLogReportPercentModuleControl = sdp.SdpStruct("CmdActClientCfgLogReportPercentModuleControl")
CmdActClientCfgLogReportPercentModuleControl.Definition = {
  "sLogName",
  "iLogPercent",
  "iLogOffset",
  "sExcludeUid",
  sLogName = {
    0,
    0,
    13,
    ""
  },
  iLogPercent = {
    1,
    0,
    8,
    0
  },
  iLogOffset = {
    2,
    0,
    8,
    0
  },
  sExcludeUid = {
    3,
    0,
    13,
    ""
  }
}
CmdActClientCfgFlogReportModuleControl = sdp.SdpStruct("CmdActClientCfgFlogReportModuleControl")
CmdActClientCfgFlogReportModuleControl.Definition = {
  "iOpenReport",
  "iReportButtonControl",
  "iLogLevel",
  iOpenReport = {
    0,
    0,
    8,
    0
  },
  iReportButtonControl = {
    1,
    0,
    8,
    0
  },
  iLogLevel = {
    2,
    0,
    8,
    0
  }
}
CmdActCfgModuleControlWatermark = sdp.SdpStruct("CmdActCfgModuleControlWatermark")
CmdActCfgModuleControlWatermark.Definition = {
  "iType",
  "sContent",
  "iPos",
  "iOffset",
  "iSize",
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
  iPos = {
    2,
    0,
    8,
    0
  },
  iOffset = {
    3,
    0,
    8,
    0
  },
  iSize = {
    4,
    0,
    8,
    0
  }
}
CmdActClientCfgModuleControl = sdp.SdpStruct("CmdActClientCfgModuleControl")
CmdActClientCfgModuleControl.Definition = {
  "vLogReportPercent",
  "stFlogReport",
  "mWatermark",
  "bCloseRogueJumpImprove",
  "vCloseFightCheatType",
  vLogReportPercent = {
    0,
    0,
    sdp.SdpVector(CmdActClientCfgLogReportPercentModuleControl),
    nil
  },
  stFlogReport = {
    1,
    0,
    CmdActClientCfgFlogReportModuleControl,
    nil
  },
  mWatermark = {
    2,
    0,
    sdp.SdpMap(8, CmdActCfgModuleControlWatermark),
    nil
  },
  bCloseRogueJumpImprove = {
    3,
    0,
    1,
    false
  },
  vCloseFightCheatType = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActCfgModuleControl = sdp.SdpStruct("CmdActCfgModuleControl")
CmdActCfgModuleControl.Definition = {
  "mCommParam",
  "stClientCfg",
  mCommParam = {
    0,
    0,
    sdp.SdpMap(13, 13),
    nil
  },
  stClientCfg = {
    1,
    0,
    CmdActClientCfgModuleControl,
    nil
  }
}
