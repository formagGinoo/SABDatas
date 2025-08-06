local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdActForbidCustomDescManager_Status = sdp.SdpStruct("CmdActForbidCustomDescManager_Status")
CmdActForbidCustomDescManager_Status.Definition = {}
CmdActCfgForbidCustomDescManagerForbidCustomDesc = sdp.SdpStruct("CmdActCfgForbidCustomDescManagerForbidCustomDesc")
CmdActCfgForbidCustomDescManagerForbidCustomDesc.Definition = {
  "id",
  "begin_time",
  "end_time",
  "comment",
  id = {
    0,
    0,
    8,
    0
  },
  begin_time = {
    1,
    0,
    13,
    ""
  },
  end_time = {
    2,
    0,
    13,
    ""
  },
  comment = {
    3,
    0,
    13,
    ""
  }
}
CmdActCfgForbidCustomDescManagerForbidCustomDescEmergency = sdp.SdpStruct("CmdActCfgForbidCustomDescManagerForbidCustomDescEmergency")
CmdActCfgForbidCustomDescManagerForbidCustomDescEmergency.Definition = {
  "id",
  "begin_time",
  "end_time",
  "comment",
  id = {
    0,
    0,
    8,
    0
  },
  begin_time = {
    1,
    0,
    8,
    0
  },
  end_time = {
    2,
    0,
    8,
    0
  },
  comment = {
    3,
    0,
    13,
    ""
  }
}
CmdActCommonCfgForbidCustomDescManager = sdp.SdpStruct("CmdActCommonCfgForbidCustomDescManager")
CmdActCommonCfgForbidCustomDescManager.Definition = {
  "mForbidCustomDesc",
  "mForbidCustomDescEmergency",
  mForbidCustomDesc = {
    0,
    0,
    sdp.SdpMap(8, CmdActCfgForbidCustomDescManagerForbidCustomDesc),
    nil
  },
  mForbidCustomDescEmergency = {
    1,
    0,
    sdp.SdpMap(8, CmdActCfgForbidCustomDescManagerForbidCustomDescEmergency),
    nil
  }
}
CmdActCfgForbidCustomDescManager = sdp.SdpStruct("CmdActCfgForbidCustomDescManager")
CmdActCfgForbidCustomDescManager.Definition = {
  "stCommonCfg",
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgForbidCustomDescManager,
    nil
  }
}
