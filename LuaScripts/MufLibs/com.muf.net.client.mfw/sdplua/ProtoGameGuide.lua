local module = _ENV.module
local _G = _ENV._G
local sdp = require("sdp")
require("ProtoGameStructs")
module("MTTDProto")
CmdId_Guide_SetGuide_CS = 14201
CmdId_Guide_SetGuide_SC = 14202
CmdId_Guide_GetGuide_CS = 14203
CmdId_Guide_GetGuide_SC = 14204
Cmd_Guide_SetGuide_CS = sdp.SdpStruct("Cmd_Guide_SetGuide_CS")
Cmd_Guide_SetGuide_CS.Definition = {
  "iGuideId",
  "iGuideStep",
  iGuideId = {
    0,
    0,
    8,
    0
  },
  iGuideStep = {
    1,
    0,
    8,
    0
  }
}
Cmd_Guide_SetGuide_SC = sdp.SdpStruct("Cmd_Guide_SetGuide_SC")
Cmd_Guide_SetGuide_SC.Definition = {
  "iGuideId",
  "iGuideStep",
  iGuideId = {
    0,
    0,
    8,
    0
  },
  iGuideStep = {
    1,
    0,
    8,
    0
  }
}
Cmd_Guide_GetGuide_CS = sdp.SdpStruct("Cmd_Guide_GetGuide_CS")
Cmd_Guide_GetGuide_CS.Definition = {}
Cmd_Guide_GetGuide_SC = sdp.SdpStruct("Cmd_Guide_GetGuide_SC")
Cmd_Guide_GetGuide_SC.Definition = {
  "mGuideData",
  mGuideData = {
    0,
    0,
    sdp.SdpMap(8, 8),
    nil
  }
}
