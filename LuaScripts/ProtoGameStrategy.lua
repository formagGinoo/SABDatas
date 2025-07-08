local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Strategy_GetList_CS = 10251
CmdId_Strategy_GetList_SC = 10252
CmdId_Strategy_Set_CS = 10253
CmdId_Strategy_Set_SC = 10254
CmdId_Strategy_Del_CS = 10255
CmdId_Strategy_Del_SC = 10256
CmdId_Strategy_Add_CS = 10257
CmdId_Strategy_Add_SC = 10258
CmdId_Strategy_Choose_CS = 10263
CmdId_Strategy_Choose_SC = 10264
Cmd_Strategy_GetList_CS = sdp.SdpStruct("Cmd_Strategy_GetList_CS")
Cmd_Strategy_GetList_CS.Definition = {}
Cmd_Strategy_GetList_SC = sdp.SdpStruct("Cmd_Strategy_GetList_SC")
Cmd_Strategy_GetList_SC.Definition = {
  "vStrategy",
  "iChooseIndex",
  vStrategy = {
    0,
    0,
    sdp.SdpVector(CmdStrategy),
    nil
  },
  iChooseIndex = {
    1,
    0,
    8,
    0
  }
}
Cmd_Strategy_Set_CS = sdp.SdpStruct("Cmd_Strategy_Set_CS")
Cmd_Strategy_Set_CS.Definition = {
  "iIndex",
  "stStrategy",
  iIndex = {
    0,
    0,
    8,
    0
  },
  stStrategy = {
    1,
    0,
    CmdStrategy,
    nil
  }
}
Cmd_Strategy_Set_SC = sdp.SdpStruct("Cmd_Strategy_Set_SC")
Cmd_Strategy_Set_SC.Definition = {
  "iIndex",
  "stStrategy",
  iIndex = {
    0,
    0,
    8,
    0
  },
  stStrategy = {
    1,
    0,
    CmdStrategy,
    nil
  }
}
Cmd_Strategy_Add_CS = sdp.SdpStruct("Cmd_Strategy_Add_CS")
Cmd_Strategy_Add_CS.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Strategy_Add_SC = sdp.SdpStruct("Cmd_Strategy_Add_SC")
Cmd_Strategy_Add_SC.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Strategy_Del_CS = sdp.SdpStruct("Cmd_Strategy_Del_CS")
Cmd_Strategy_Del_CS.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Strategy_Del_SC = sdp.SdpStruct("Cmd_Strategy_Del_SC")
Cmd_Strategy_Del_SC.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Strategy_Choose_CS = sdp.SdpStruct("Cmd_Strategy_Choose_CS")
Cmd_Strategy_Choose_CS.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
Cmd_Strategy_Choose_SC = sdp.SdpStruct("Cmd_Strategy_Choose_SC")
Cmd_Strategy_Choose_SC.Definition = {
  "iIndex",
  iIndex = {
    0,
    0,
    8,
    0
  }
}
