local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_LoginSendItem_TakeReward_CS = 60261
CmdId_Act_LoginSendItem_TakeReward_SC = 60262
CmdActLoginSendItem_Status = sdp.SdpStruct("CmdActLoginSendItem_Status")
CmdActLoginSendItem_Status.Definition = {
  "iTakeNum",
  iTakeNum = {
    0,
    0,
    8,
    0
  }
}
CmdActClientCfgLoginSendItem = sdp.SdpStruct("CmdActClientCfgLoginSendItem")
CmdActClientCfgLoginSendItem.Definition = {
  "sJumpContent",
  "iJumpType",
  "sJumpParam",
  sJumpContent = {
    0,
    0,
    13,
    ""
  },
  iJumpType = {
    1,
    0,
    8,
    0
  },
  sJumpParam = {
    2,
    0,
    13,
    ""
  }
}
CmdActCommonCfgLoginSendItem = sdp.SdpStruct("CmdActCommonCfgLoginSendItem")
CmdActCommonCfgLoginSendItem.Definition = {
  "iItemId",
  "iItemNum",
  iItemId = {
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
CmdActCfgLoginSendItem = sdp.SdpStruct("CmdActCfgLoginSendItem")
CmdActCfgLoginSendItem.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgLoginSendItem,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgLoginSendItem,
    nil
  }
}
Cmd_Act_LoginSendItem_TakeReward_CS = sdp.SdpStruct("Cmd_Act_LoginSendItem_TakeReward_CS")
Cmd_Act_LoginSendItem_TakeReward_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_LoginSendItem_TakeReward_SC = sdp.SdpStruct("Cmd_Act_LoginSendItem_TakeReward_SC")
Cmd_Act_LoginSendItem_TakeReward_SC.Definition = {
  "iActivityId",
  "iTakeNum",
  "vReward",
  iActivityId = {
    0,
    0,
    8,
    0
  },
  iTakeNum = {
    1,
    0,
    8,
    0
  },
  vReward = {
    2,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  }
}
