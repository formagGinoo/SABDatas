local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
module("MTTDProto")
CmdId_Ping_ReportPing_CS = 119150
CmdId_Ping_ReportPing_SC = 119151
CmdId_Ping_GetAllServerIp_CS = 119152
CmdId_Ping_GetAllServerIp_SC = 119153
CmdId_Ping_ReportPingNew_CS = 119154
CmdId_Ping_ReportPingNew_SC = 119155
CmdId_Ping_ReportPingV2_CS = 119456
CmdId_Ping_ReportPingV2_SC = 119457
PingDataType_None = 0
PingDataType_Udp = 1
PingDataType_Icmp = 2
PingData = sdp.SdpStruct("PingData")
PingData.Definition = {
  "iPing",
  "iLoss",
  "iUpLoss",
  "iDownLoss",
  "iPingType",
  "sClientIP",
  iPing = {
    0,
    0,
    8,
    0
  },
  iLoss = {
    1,
    0,
    8,
    0
  },
  iUpLoss = {
    2,
    0,
    8,
    0
  },
  iDownLoss = {
    3,
    0,
    8,
    0
  },
  iPingType = {
    4,
    0,
    8,
    0
  },
  sClientIP = {
    5,
    0,
    13,
    ""
  }
}
PlugReport = sdp.SdpStruct("PlugReport")
PlugReport.Definition = {
  "iPlugType",
  iPlugType = {
    0,
    0,
    8,
    0
  }
}
Cmd_Ping_ReportPing_CS = sdp.SdpStruct("Cmd_Ping_ReportPing_CS")
Cmd_Ping_ReportPing_CS.Definition = {
  "mPingData",
  "mBattlePing",
  "stPlugReport",
  mPingData = {
    0,
    0,
    sdp.SdpMap(13, PingData),
    nil
  },
  mBattlePing = {
    1,
    0,
    sdp.SdpMap(13, 8),
    nil
  },
  stPlugReport = {
    2,
    0,
    PlugReport,
    nil
  }
}
Cmd_Ping_ReportPing_SC = sdp.SdpStruct("Cmd_Ping_ReportPing_SC")
Cmd_Ping_ReportPing_SC.Definition = {}
Cmd_Ping_GetAllServerIp_CS = sdp.SdpStruct("Cmd_Ping_GetAllServerIp_CS")
Cmd_Ping_GetAllServerIp_CS.Definition = {}
ServerGroupInfo = sdp.SdpStruct("ServerGroupInfo")
ServerGroupInfo.Definition = {
  "iGroupId",
  "sGroupName",
  "iGroupType",
  "vIpList",
  iGroupId = {
    0,
    0,
    8,
    0
  },
  sGroupName = {
    1,
    0,
    13,
    ""
  },
  iGroupType = {
    2,
    0,
    8,
    0
  },
  vIpList = {
    3,
    0,
    sdp.SdpVector(13),
    nil
  }
}
Cmd_Ping_GetAllServerIp_SC = sdp.SdpStruct("Cmd_Ping_GetAllServerIp_SC")
Cmd_Ping_GetAllServerIp_SC.Definition = {
  "vSvrList",
  vSvrList = {
    0,
    0,
    sdp.SdpVector(ServerGroupInfo),
    nil
  }
}
Cmd_Ping_ReportPingV2_CS = sdp.SdpStruct("Cmd_Ping_ReportPingV2_CS")
Cmd_Ping_ReportPingV2_CS.Definition = {
  "mPingData",
  "mBattlePing",
  "stPlugReport",
  mPingData = {
    0,
    0,
    sdp.SdpMap(13, PingData),
    nil
  },
  mBattlePing = {
    1,
    0,
    sdp.SdpMap(13, 8),
    nil
  },
  stPlugReport = {
    2,
    0,
    PlugReport,
    nil
  }
}
Cmd_Ping_ReportPingV2_SC = sdp.SdpStruct("Cmd_Ping_ReportPingV2_SC")
Cmd_Ping_ReportPingV2_SC.Definition = {}
Cmd_Ping_ReportPingNew_CS = sdp.SdpStruct("Cmd_Ping_ReportPingNew_CS")
Cmd_Ping_ReportPingNew_CS.Definition = {
  "mPingData",
  mPingData = {
    0,
    0,
    sdp.SdpMap(13, PingData),
    nil
  }
}
Cmd_Ping_ReportPingNew_SC = sdp.SdpStruct("Cmd_Ping_ReportPingNew_SC")
Cmd_Ping_ReportPingNew_SC.Definition = {}
