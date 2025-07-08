local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Act_GachaJump_Order_CS = 60081
CmdId_Act_GachaJump_Order_SC = 60082
CmdActGachaJump_Status = sdp.SdpStruct("CmdActGachaJump_Status")
CmdActGachaJump_Status.Definition = {
  "bRecivedOrderAward",
  bRecivedOrderAward = {
    0,
    0,
    1,
    false
  }
}
CmdActClientCfgGachaJump = sdp.SdpStruct("CmdActClientCfgGachaJump")
CmdActClientCfgGachaJump.Definition = {
  "iJumpId",
  "sSpineName",
  "sSubPanelName",
  "iHasSpine",
  "sSpineAnimSting",
  "sSlideshow",
  "sSlideshowTitle",
  "iHeroId",
  iJumpId = {
    0,
    0,
    8,
    0
  },
  sSpineName = {
    1,
    0,
    13,
    ""
  },
  sSubPanelName = {
    2,
    0,
    13,
    ""
  },
  iHasSpine = {
    3,
    0,
    8,
    0
  },
  sSpineAnimSting = {
    4,
    0,
    13,
    ""
  },
  sSlideshow = {
    5,
    0,
    13,
    ""
  },
  sSlideshowTitle = {
    6,
    0,
    13,
    ""
  },
  iHeroId = {
    7,
    0,
    8,
    0
  }
}
CmdActCommonCfgGachaJump = sdp.SdpStruct("CmdActCommonCfgGachaJump")
CmdActCommonCfgGachaJump.Definition = {
  "sOrderReward",
  "sOrderBeginTime",
  "sOrderEndTime",
  "iUiType",
  sOrderReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  sOrderBeginTime = {
    1,
    0,
    8,
    0
  },
  sOrderEndTime = {
    2,
    0,
    8,
    0
  },
  iUiType = {
    3,
    0,
    8,
    0
  }
}
CmdActCfgGachaJump = sdp.SdpStruct("CmdActCfgGachaJump")
CmdActCfgGachaJump.Definition = {
  "stClientCfg",
  "stCommonCfg",
  stClientCfg = {
    0,
    0,
    CmdActClientCfgGachaJump,
    nil
  },
  stCommonCfg = {
    1,
    0,
    CmdActCommonCfgGachaJump,
    nil
  }
}
Cmd_Act_GachaJump_Order_CS = sdp.SdpStruct("Cmd_Act_GachaJump_Order_CS")
Cmd_Act_GachaJump_Order_CS.Definition = {
  "iActivityId",
  iActivityId = {
    0,
    0,
    8,
    0
  }
}
Cmd_Act_GachaJump_Order_SC = sdp.SdpStruct("Cmd_Act_GachaJump_Order_SC")
Cmd_Act_GachaJump_Order_SC.Definition = {
  "sOrderReward",
  "bRecivedOrderAward",
  sOrderReward = {
    0,
    0,
    sdp.SdpVector(CmdIDNum),
    nil
  },
  bRecivedOrderAward = {
    1,
    0,
    1,
    false
  }
}
