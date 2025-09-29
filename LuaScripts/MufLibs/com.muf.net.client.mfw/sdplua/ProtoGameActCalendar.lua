local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActCalendar_Status = sdp.SdpStruct("CmdActCalendar_Status")
CmdActCalendar_Status.Definition = {}
CmdActCfgCalendarActStyle = sdp.SdpStruct("CmdActCfgCalendarActStyle")
CmdActCfgCalendarActStyle.Definition = {
  "iActType",
  "sIcon",
  "iUiType",
  "iOrder",
  iActType = {
    0,
    0,
    8,
    0
  },
  sIcon = {
    1,
    0,
    13,
    ""
  },
  iUiType = {
    2,
    0,
    8,
    0
  },
  iOrder = {
    3,
    0,
    8,
    0
  }
}
CmdActCfgCalendarUpcoming = sdp.SdpStruct("CmdActCfgCalendarUpcoming")
CmdActCfgCalendarUpcoming.Definition = {
  "iId",
  "sName",
  "sIcon",
  "sTime",
  "vReward",
  iId = {
    0,
    0,
    8,
    0
  },
  sName = {
    1,
    0,
    13,
    ""
  },
  sIcon = {
    2,
    0,
    13,
    ""
  },
  sTime = {
    3,
    0,
    13,
    ""
  },
  vReward = {
    4,
    0,
    sdp.SdpVector(8),
    nil
  }
}
CmdActClientCfgCalendar = sdp.SdpStruct("CmdActClientCfgCalendar")
CmdActClientCfgCalendar.Definition = {
  "mActStyle",
  "mUpcoming",
  mActStyle = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgCalendarActStyle),
    nil
  },
  mUpcoming = {
    1,
    0,
    sdp.SdpMap(8, CmdActCfgCalendarUpcoming),
    nil
  }
}
CmdActCfgCalendar = sdp.SdpStruct("CmdActCfgCalendar")
CmdActCfgCalendar.Definition = {
  "stClientCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgCalendar,
    nil
  }
}
