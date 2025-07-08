local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Misc_ReportBug_CS = 19151
CmdId_Misc_ReportBug_SC = 19152
CmdId_Misc_QueryPassStageArrange_CS = 19153
CmdId_Misc_QueryPassStageArrange_SC = 19154
PassStageArrangeType_Invalid = 0
PassStageArrangeType_Recommend = 1
PassStageArrangeType_Friend = 2
PassStageArrangeType_Alliance = 3
PassStageTimeType_Invalid = 0
PassStageTimeType_Day = 1
PassStageTimeType_Week = 2
PassStageTimeType_Month = 3
PassStageTimeType_All = 4
Cmd_Misc_ReportBug_CS = sdp.SdpStruct("Cmd_Misc_ReportBug_CS")
Cmd_Misc_ReportBug_CS.Definition = {
  "iChooseType",
  "sInputContent",
  "iPlayType",
  "iStageID",
  "iFightReportID",
  "sClientVersion",
  iChooseType = {
    0,
    0,
    8,
    0
  },
  sInputContent = {
    1,
    0,
    13,
    ""
  },
  iPlayType = {
    2,
    0,
    8,
    0
  },
  iStageID = {
    3,
    0,
    8,
    0
  },
  iFightReportID = {
    4,
    0,
    10,
    "0"
  },
  sClientVersion = {
    5,
    0,
    13,
    ""
  }
}
Cmd_Misc_ReportBug_SC = sdp.SdpStruct("Cmd_Misc_ReportBug_SC")
Cmd_Misc_ReportBug_SC.Definition = {
  "iResult",
  iResult = {
    0,
    0,
    8,
    0
  }
}
Cmd_Misc_QueryPassStageArrange_CS = sdp.SdpStruct("Cmd_Misc_QueryPassStageArrange_CS")
Cmd_Misc_QueryPassStageArrange_CS.Definition = {
  "iStageType",
  "iStageID",
  "iArrangeType",
  "iTimeType",
  "bOrderAsc",
  iStageType = {
    0,
    0,
    8,
    0
  },
  iStageID = {
    1,
    0,
    8,
    0
  },
  iArrangeType = {
    2,
    0,
    8,
    0
  },
  iTimeType = {
    3,
    0,
    8,
    0
  },
  bOrderAsc = {
    4,
    0,
    1,
    false
  }
}
Cmd_Misc_QueryPassStageArrange_SC = sdp.SdpStruct("Cmd_Misc_QueryPassStageArrange_SC")
Cmd_Misc_QueryPassStageArrange_SC.Definition = {
  "vRoleArrange",
  vRoleArrange = {
    5,
    0,
    sdp.SdpVector(CmdRoleArrange),
    nil
  }
}
